----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    rx_CplD_Transact - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  14.12.2006
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_CplD_Transact is
    port (
      -- Transaction receive interface
      trn_rsof_n         : IN  std_logic;
      trn_reof_n         : IN  std_logic;
      trn_rd             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n         : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n      : IN  std_logic;
      trn_rsrc_rdy_n     : IN  std_logic;
      trn_rdst_rdy_n     : IN  std_logic;  -- !!
      trn_rsrc_dsc_n     : IN  std_logic;
      trn_rbar_hit_n     : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av      : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av      : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av     : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av     : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av    : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av    : IN  std_logic_vector(11 downto 0);


      CplD_Type          : IN  std_logic_vector(3 downto 0);

      Req_ID_Match       : IN  std_logic;
      usDex_Tag_Matched  : IN  std_logic;
      dsDex_Tag_Matched  : IN  std_logic;

      Tlp_has_4KB        : IN  std_logic;
      Tlp_has_1DW        : IN  std_logic;
      CplD_on_Pool       : IN  std_logic;
      CplD_on_EB         : IN  std_logic;
      CplD_is_the_Last   : IN  std_logic;
      CplD_Tag           : IN  std_logic_vector(C_TAG_WIDTH-1 downto  0);
      FC_pop             : OUT std_logic;


      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add   : OUT std_logic;
      ds_DMA_Bytes       : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);


      -- Tag output to downstream DMA channel
      dsDMA_dex_Tag      : OUT std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Downstream Handshake Signals with ds Channel for Busy/Done
      Tag_Map_Clear      : OUT std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);


      -- Downstream tRAM port A write request
      tRAM_weB           : IN  std_logic;
      tRAM_addrB         : IN  std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB          : IN  std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- Tag output to upstream DMA channel
      usDMA_dex_Tag      : OUT std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Event Buffer write port
      eb_FIFO_we         : OUT std_logic;
      eb_FIFO_wsof       : OUT std_logic;
      eb_FIFO_weof       : OUT std_logic;
      eb_FIFO_din        : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Registers Write Port
      Regs_WrEn          : OUT std_logic;
      Regs_WrMask        : OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr        : OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof         : OUT std_logic;
      DDR_wr_eof         : OUT std_logic;
      DDR_wr_v           : OUT std_logic;
      DDR_wr_FA          : OUT std_logic;
      DDR_wr_Shift       : OUT std_logic;
      DDR_wr_Mask        : OUT std_logic_vector(2-1 downto 0);
      DDR_wr_din         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full        : IN  std_logic;

      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic;
      trn_lnk_up_n       : IN  std_logic

    );

end entity rx_CplD_Transact;



architecture Behavioral of rx_CplD_Transact is

  type RxCplDEBStates is ( ST_EBWR_IDLE
                         , ST_EBWR_TAG
                         , ST_EBWR_DATA
                         );

  signal EB_Write_State  : RxCplDEBStates;


  type RxCplDTrnStates is ( ST_CplD_RESET
                          , ST_CplD_IDLE
--                          , ST_Cpl_HEAD1            -- Cpl Header #1  (not used)
--                          , ST_CplD_HEAD1           -- CplD Header #1
                          , ST_Cpl_HEAD2            -- Cpl Header #2  (not used)
                          , ST_CplD_HEAD2           -- CplD Header #2
                          , ST_CplD_AFetch_Special  -- 
                          , ST_CplD_AFetch_Special_Tail  -- 
                          , ST_CplD_AFetch          -- Target address fetch from tRAM/registers
                          , ST_CplD_AFetch_THROTTLE -- Target address fetch throttled
                          , ST_CplD_ONLY_1DW        -- Current CplD has only 1 DW
--                          , ST_CplD_ONLY_1DW_THROTTLE        -- Current CplD has only 1 DW, throttled
                          , ST_CplD_1ST_DATA        -- 1st data payload of the CplD
                          , ST_CplD_1ST_DATA_THROTTLE        -- 1st data payload of the CplD
                          , ST_CplD_DATA            -- data receiving
                          , ST_CplD_DATA_THROTTLE   -- data receiving throttled
                          , ST_CplD_LAST_DATA       -- Last data payload of the CplD
                          );

  -- State variables
  signal RxCplDTrn_NextState  : RxCplDTrnStates;
  signal RxCplDTrn_State      : RxCplDTrnStates;

  -- State delay
  signal RxCplDTrn_State_r1   : RxCplDTrnStates;
  signal RxCplDTrn_State_r2   : RxCplDTrnStates;

  signal CplD_State_is_AFetch : std_logic;
  signal CplD_State_is_AFetch_r1 : std_logic;
  signal CplD_State_is_after_AFetch : std_logic;
  signal CplD_State_is_after_AFetch_r1 : std_logic;


  -- Shifted-glued payload
  signal hybrid_rd            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);

  -- trn_rx stubs
  signal trn_rd_i             : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_r1            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_r2            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_r3            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_r4            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);

  -- trn_rd_*  in little endian
  signal trn_rd_Little        : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_Little_r1     : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_Little_r2     : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_Little_r3     : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal trn_rd_Little_r4     : std_logic_vector (C_DBUS_WIDTH-1 downto 0);

  --  signal  trn_rbar_hit_n_i   : std_logic_vector(C_BAR_NUMBER-1 downto 0);
  signal trn_rerrfwd_n_i      : std_logic;
  signal trn_rsrc_dsc_n_i     : std_logic;

  signal trn_rsof_n_i         : std_logic;
  signal trn_rsof_n_r1        : std_logic;
  signal trn_rsof_n_r2        : std_logic;
  signal trn_rsof_n_r3        : std_logic;
  signal trn_rsof_n_r4        : std_logic;
  signal trn_reof_n_i         : std_logic;
  signal trn_reof_n_r1        : std_logic;
  signal trn_reof_n_r2        : std_logic;
  signal trn_reof_n_r3        : std_logic;
  signal trn_reof_n_r4        : std_logic;

--  signal Tlp_has_4KB_r1       : std_logic;
  signal trn_rrem_n_i         : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal trn_rrem_n_r1        : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal trn_rrem_n_r2        : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal trn_rrem_n_r3        : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal trn_rrem_n_r4        : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);

  --  Whether address increases
  signal Addr_Inc             : std_logic;

  --  Spaces hit
--  signal FIFO_Space_Hit       : std_logic;
  signal DDR_Space_Hit        : std_logic;


  -- DDR write port
  signal DDR_wr_sof_i         : std_logic;
  signal DDR_wr_eof_i         : std_logic;
  signal DDR_wr_v_i           : std_logic;
  signal DDR_wr_FA_i          : std_logic;
  signal DDR_wr_void          : std_logic;
  signal DDR_wr_Shift_i       : std_logic;
  signal DDR_wr_Mask_i        : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_wr_full_i        : std_logic;


  -- Event Buffer write port
  signal eb_FIFO_we_i         : std_logic;
  signal eb_FIFO_wsof_i       : std_logic;
  signal eb_FIFO_weof_i       : std_logic;
  signal eb_FIFO_sof_marker   : std_logic;
  signal eb_FIFO_din_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  --  Register write port
  signal Regs_WrEn_i          : std_logic;
  signal Regs_WrMask_i        : std_logic_vector(2-1 downto 0);
  signal Regs_WrAddr_i        : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_WrDin_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  --  Calculation @ trn_rsof_n=0
  signal Dex_CplD_Illegal     : std_logic;
  signal Reg_WrAddr_if_last_us: std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Reg_WrAddr_if_last_ds: std_logic_vector(C_EP_AWIDTH-1 downto 0);


  -- Flow control signals
  signal trn_rdst_rdy_n_i     : std_logic;
  signal trn_rsrc_rdy_n_i     : std_logic;
  signal trn_rsrc_rdy_n_r1    : std_logic;
  signal trn_rsrc_rdy_n_r2    : std_logic;
  signal trn_rsrc_rdy_n_r3    : std_logic;
  signal trn_rsrc_rdy_n_r4    : std_logic;


  signal trn_rx_throttle      : std_logic;
  signal trn_rx_throttle_r1   : std_logic;
  signal trn_rx_throttle_r2   : std_logic;
  signal trn_rx_throttle_r3   : std_logic;
  signal trn_rx_throttle_r4   : std_logic;


  -- Downstream DMA transferred bytes count up
  signal ds_DMA_Bytes_Add_i   : std_logic;
  signal ds_DMA_Bytes_i       : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);
  signal CplD_is_Payloaded    : std_logic;
  signal TLP_is_not_CplD      : std_logic;
  signal TLP_is_not_CplD_r1   : std_logic;
  signal TLP_is_not_CplD_r2   : std_logic;
  signal TLP_is_not_CplD_r3   : std_logic;
  signal TLP_is_not_CplD_r4   : std_logic;
  signal TLP_is_not_CplD_r5   : std_logic;

  -- Alias for header resolution
  signal CplD_Length          : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto 0);
  signal CplD_Leng_in_Bytes   : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal CplD_Leng_in_Bytes_r1: std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal CplD_Leng_in_Bytes_r2: std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal CplD_is_1DW          : std_logic;
  --     Small_CplD means CplD with less than 4 DW payload
  signal Small_CplD           : std_logic;
  signal Small_CplD_r1        : std_logic;


  signal RegAddr_us_Dex       : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal RegAddr_ds_Dex       : std_logic_vector(C_EP_AWIDTH-1 downto 0);

  signal CplD_Tag_on_Dex      : std_logic;

  -- ----------------------------------------------------------------------
  signal Req_ID_Match_i       : std_logic;
  signal Dex_Tag_Matched_i    : std_logic;

  -- The top bit of the CplD_Tag is for distinguishing data CplD or descriptor CplD
  signal MSB_DSP_Tag          : std_logic;
  signal MSB_DSP_Tag_r1       : std_logic;
  signal DSP_Tag_on_RAM       : std_logic;
  signal DSP_Tag_on_RAM_r1    : std_logic;
  signal DSP_Tag_on_RAM_r2    : std_logic;
  signal DSP_Tag_on_RAM_r3    : std_logic;
  signal DSP_Tag_on_RAM_r4p   : std_logic;
  signal DSP_Tag_on_FIFO      : std_logic;
  -- ----------------------------------------------------------------------
  signal FC_pop_i              : std_logic;


  signal Tag_Map_Clear_i      : std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);

  signal Local_Reset_i        : std_logic;


  -- upstream Descriptors' tags
  signal usDMA_dex_Tag_i      :  std_logic_vector(C_TAG_WIDTH-1 downto 0);

  -- downstream Descriptors' tags
  signal dsDMA_dex_Tag_i      : std_logic_vector(C_TAG_WIDTH-1 downto  0);


--  --- ------------------------------------------
--  ---   Dual port Block Memory, used as tag RAM
--  component 
--    v5tagram64x36
--    port (
--            clka     : IN  std_logic;
--            addra    : IN  std_logic_VECTOR(C_TAGRAM_AWIDTH-1 downto 0);
--            wea      : IN  std_logic_vector(0 downto 0);
--            dina     : IN  std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
--            douta    : OUT std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
--            clkb     : IN  std_logic;
--            addrb    : IN  std_logic_VECTOR(C_TAGRAM_AWIDTH-1 downto 0);
--            web      : IN  std_logic_vector(0 downto 0);
--            dinb     : IN  std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
--            doutb    : OUT std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0)
--         );
--  end component;

  --- ------------------------------------------
  ---   Dual port Block Memory, used as tag RAM
  component 
    FF_TagRam64x36
    port (
            clk      : IN  std_logic;
            addra    : IN  std_logic_VECTOR(C_TAGRAM_AWIDTH-1 downto 0);
            wea      : IN  std_logic;
            dina     : IN  std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
            douta    : OUT std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
            addrb    : IN  std_logic_VECTOR(C_TAGRAM_AWIDTH-1 downto 0);
            web      : IN  std_logic;
            dinb     : IN  std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0);
            doutb    : OUT std_logic_VECTOR(C_TAGRAM_DWIDTH-1 downto 0)
         );
  end component;

  signal tRAM_wea             : std_logic_vector(0 downto 0);
  signal tRAM_addra           : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
  signal tRAM_dina            : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tRAM_doutA           : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tRAM_weB_i           : std_logic_vector(0 downto 0);

  signal tRAM_DoutA_r1        : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tRAM_DoutA_r2        : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tRAM_dina_aInc       : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tRAM_DoutA_latch     : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

  --  updates the tag RAM as soon as possible
  signal CplD_Tag_r1          : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal CplD_Tag_r2          : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal CplD_Tag_r3          : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal CplD_Tag_r4          : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal CplD_is_the_Last_r1  : std_logic;
  signal CplD_is_the_Last_r2  : std_logic;
  signal Updates_tRAM         : std_logic;
  signal Updates_tRAM_r1      : std_logic;
  signal Update_was_too_late  : std_logic;

  signal hazard_update        : std_logic;
  signal hazard_update_r1     : std_logic;
  signal hazard_update_r2     : std_logic;
  signal hazard_update_r3     : std_logic;
--  signal hazard_tag           : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal curr_tag_latch       : std_logic_vector(C_TAG_WIDTH-1 downto  0);
  signal hazard_content       : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal tag_matches_hazard   : std_logic;
  signal tag_matches_hazard_r1   : std_logic;
  signal tag_matches_hazard_r2   : std_logic;

  --  aka TLB unit
  signal TLB_Addr             : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
  signal TLB_Content          : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal TLB_cnt              : std_logic_vector(4-1 downto 0);
  signal TLB_Valid            : std_logic;
  signal TLB_Hit              : std_logic;

  Constant C_TLB_VALID_CNT    : std_logic_vector(4-1 downto 0)       := X"6";

begin

   -- Event Buffer write
   eb_FIFO_we         <=  eb_FIFO_we_i   ;
   eb_FIFO_wsof       <=  eb_FIFO_wsof_i ;
   eb_FIFO_weof       <=  eb_FIFO_weof_i ;
   eb_FIFO_din        <=  eb_FIFO_din_i  ;

   -- DDR
   DDR_wr_sof         <=  DDR_wr_sof_i   ;
   DDR_wr_eof         <=  DDR_wr_eof_i   ;
   DDR_wr_v           <=  DDR_wr_v_i     ;
   DDR_wr_FA          <=  DDR_wr_FA_i    ;
   DDR_wr_Shift       <=  DDR_wr_Shift_i ;
   DDR_wr_Mask        <=  DDR_wr_Mask_i  ;
   DDR_wr_din         <=  DDR_wr_din_i   ;
   DDR_wr_full_i      <=  DDR_wr_full    ;

   ds_DMA_Bytes_Add   <=  ds_DMA_Bytes_Add_i ;
   ds_DMA_Bytes       <=  ds_DMA_Bytes_i     ;

   -- 
   Tag_Map_Clear      <=  Tag_Map_Clear_i;

   --
   FC_pop             <=  FC_pop_i;
   -- ----------------------------------------------
   -- 
   Syn_FC_pop:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         FC_pop_i   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         FC_pop_i   <=  (CplD_on_Pool or CplD_on_EB)
                    and CplD_is_the_Last
                    and not MSB_DSP_Tag
                    and not trn_reof_n_i
                    and trn_reof_n_r1      -- Catch the falling edge of trn_reof_n
--                    and not trn_rx_throttle
                    ;
      end if;

   end process;

   -- ----------------------------------------------
   -- Synchronous: CplD_is_Payloaded
   -- 
   Syn_CplD_is_Payloaded:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         CplD_is_Payloaded   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n_i='0' and trn_rx_throttle='0' then
            CplD_is_Payloaded   <= CplD_Type(3) or CplD_Type(1);
         else
            CplD_is_Payloaded   <= CplD_is_Payloaded;
         end if;
      end if;

   end process;


   -- ----------------------------------------------
   -- Synchronous Accumulation: us_DMA_Bytes
   -- 
   Syn_ds_DMA_Bytes_Add:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         ds_DMA_Bytes_Add_i <=  '0' ;
         ds_DMA_Bytes_i     <=  (OTHERS=>'0');
      elsif trn_clk'event and trn_clk = '1' then
         if trn_reof_n_i='0' and trn_rx_throttle='0'
            and CplD_is_Payloaded='1' and MSB_DSP_Tag='0'
            then
            ds_DMA_Bytes_Add_i <=  '1' ;
            ds_DMA_Bytes_i     <=  CplD_Leng_in_Bytes(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);
         else
            ds_DMA_Bytes_Add_i <=  '0' ;
            ds_DMA_Bytes_i     <=  (OTHERS=>'0');
         end if;
      end if;

   end process;


   -- Registers writing
   Regs_WrEn          <=  Regs_WrEn_i;
   Regs_WrMask        <=  Regs_WrMask_i;
   Regs_WrAddr        <=  Regs_WrAddr_i;
   Regs_WrDin         <=  Regs_WrDin_i;


   ---  Dex Tag output to us DMA channel
   usDMA_dex_Tag      <=  usDMA_dex_Tag_i;

   ---  Dex Tag output to ds DMA channel
   dsDMA_dex_Tag      <=  dsDMA_dex_Tag_i;


   ---------------------------------------------------
   Req_ID_Match_i     <= Req_ID_Match;

   Dex_Tag_Matched_i  <= usDex_Tag_Matched or dsDex_Tag_Matched;

   -- positive reset
   Local_Reset_i      <= not trn_reset_n;


   -- Frame signals
   trn_rsof_n_i       <= trn_rsof_n;
   trn_reof_n_i       <= trn_reof_n;
   trn_rd_i           <= trn_rd;
   trn_rrem_n_i       <= trn_rrem_n;
   trn_rsrc_rdy_n_i   <= trn_rsrc_rdy_n;
   trn_rdst_rdy_n_i   <= trn_rdst_rdy_n;


   --  BC of the current TLP payloads
   CplD_Leng_in_Bytes <= C_ALL_ZEROS(C_DBUS_WIDTH/2-1 downto C_TLP_FLD_WIDTH_OF_LENG+3) 
                       & CplD_Length & "00";


   -- Exception signals
   trn_rerrfwd_n_i    <= trn_rerrfwd_n;
   trn_rsrc_dsc_n_i   <= trn_rsrc_dsc_n;


   -- ( trn_rsrc_rdy_n seems never deasserted during packet)
   trn_rx_throttle    <= trn_rsrc_rdy_n_i or trn_rdst_rdy_n_i;


   Syn_TLP_is_not_CplD:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         TLP_is_not_CplD     <= '1';
         TLP_is_not_CplD_r1  <= '1';
         TLP_is_not_CplD_r2  <= '1';
         TLP_is_not_CplD_r3  <= '1';
         TLP_is_not_CplD_r4  <= '1';
         TLP_is_not_CplD_r5  <= '1';
      elsif trn_clk'event and trn_clk = '1' then
         TLP_is_not_CplD_r1  <= TLP_is_not_CplD;
         TLP_is_not_CplD_r2  <= TLP_is_not_CplD_r1;
         TLP_is_not_CplD_r3  <= TLP_is_not_CplD_r2;
         TLP_is_not_CplD_r4  <= TLP_is_not_CplD_r3;
         TLP_is_not_CplD_r5  <= TLP_is_not_CplD_r4;
         if trn_rsof_n_i='0' and trn_rx_throttle='0' then
            if CplD_Type=C_TLP_TYPE_IS_CPLD then
               TLP_is_not_CplD   <= '0';
            else
               TLP_is_not_CplD   <= '1';
            end if;
         else
            TLP_is_not_CplD   <= TLP_is_not_CplD;
         end if;
      end if;

   end process;

-- ---------------------------------------------
-- Synchronous bit: CplD_State_is_AFetch
-- 
   RxFSM_CplD_State_is_AFetch:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then

         CplD_State_is_AFetch_r1  <= CplD_State_is_AFetch;

         case RxCplDTrn_State is
           when  ST_CplD_AFetch  =>
             CplD_State_is_AFetch     <= '1';
           when  ST_CplD_AFetch_Special  =>
             CplD_State_is_AFetch     <= '1';
           when  OTHERS =>
             CplD_State_is_AFetch     <= '0';
         end case;

      end if;
   end process;


-- ---------------------------------------------
-- Synchronous bit: CplD_State_is_after_AFetch
-- 
   RxFSM_CplD_State_is_after_AFetch:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then

         CplD_State_is_after_AFetch_r1   <= CplD_State_is_after_AFetch;

         case RxCplDTrn_State is
           when  ST_CplD_AFetch_Special_Tail  =>
             CplD_State_is_after_AFetch     <= '1';
           when  ST_CplD_AFetch_Special  =>
             CplD_State_is_after_AFetch     <= '0';
           when  ST_CplD_ONLY_1DW  =>
             CplD_State_is_after_AFetch     <= '1';
           when  ST_CplD_1ST_DATA  =>
             CplD_State_is_after_AFetch     <= '1';
           when  OTHERS =>
             CplD_State_is_after_AFetch     <= CplD_State_is_AFetch and not trn_rx_throttle_r1;  --'0';
         end case;

      end if;
   end process;


-- ---------------------------------------------
-- Delay Synchronous Delay: trn_r*
-- 
   Syn_Delay_trn_r_x:
   process ( trn_clk )
   begin
       if trn_clk'event and trn_clk = '1' then
         trn_rsof_n_r1         <= trn_rsof_n_i;
         trn_rsof_n_r2         <= trn_rsof_n_r1;
         trn_rsof_n_r3         <= trn_rsof_n_r2;
         trn_rsof_n_r4         <= trn_rsof_n_r3;

         trn_reof_n_r1         <= trn_reof_n_i;
         trn_reof_n_r2         <= trn_reof_n_r1;
         trn_reof_n_r3         <= trn_reof_n_r2;
         trn_reof_n_r4         <= trn_reof_n_r3;

         trn_rsrc_rdy_n_r1     <= trn_rx_throttle;  -- trn_rsrc_rdy_n_i;
         trn_rsrc_rdy_n_r2     <= trn_rsrc_rdy_n_r1;
         trn_rsrc_rdy_n_r3     <= trn_rsrc_rdy_n_r2;
         trn_rsrc_rdy_n_r4     <= trn_rsrc_rdy_n_r3;

         trn_rx_throttle_r1     <= trn_rx_throttle;
         trn_rx_throttle_r2     <= trn_rx_throttle_r1;
         trn_rx_throttle_r3     <= trn_rx_throttle_r2;
         trn_rx_throttle_r4     <= trn_rx_throttle_r3;

         trn_rd_r1             <= trn_rd_i;
         trn_rd_r2             <= trn_rd_r1;
         trn_rd_r3             <= trn_rd_r2;
         trn_rd_r4             <= trn_rd_r3;

         trn_rrem_n_r1         <= trn_rrem_n_i;
         trn_rrem_n_r2         <= trn_rrem_n_r1;
         trn_rrem_n_r3         <= trn_rrem_n_r2;
         trn_rrem_n_r4         <= trn_rrem_n_r3;

      end if;
   end process;


   -- Endian reversed
   trn_rd_Little      <= Endian_Invert_64 (trn_rd_i);
   trn_rd_Little_r1   <= Endian_Invert_64 (trn_rd_r1);
   trn_rd_Little_r2   <= Endian_Invert_64 (trn_rd_r2);
   trn_rd_Little_r3   <= Endian_Invert_64 (trn_rd_r3);
   trn_rd_Little_r4   <= Endian_Invert_64 (trn_rd_r4);


-- ---------------------------------------------
   MSB_DSP_Tag        <= CplD_Tag(C_TAG_WIDTH-1);
   DSP_Tag_on_RAM     <= not CplD_Tag(C_TAG_WIDTH-1) and not CplD_Tag(C_TAG_WIDTH-2);
   DSP_Tag_on_FIFO    <= not CplD_Tag(C_TAG_WIDTH-1) and CplD_Tag(C_TAG_WIDTH-2);

-- 
-- Delay Synchronous: MSB_DSP_Tag_r1
-- 
   Syn_Delay_MSB_DSP_Tag_r1:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         CplD_Tag_r1        <= CplD_Tag;
         CplD_Tag_r2        <= CplD_Tag_r1;
         CplD_Tag_r3        <= CplD_Tag_r2;
         CplD_Tag_r4        <= CplD_Tag_r3;
         MSB_DSP_Tag_r1     <= MSB_DSP_Tag;
         DSP_Tag_on_RAM_r1  <= DSP_Tag_on_RAM;
         DSP_Tag_on_RAM_r2  <= DSP_Tag_on_RAM_r1;
         DSP_Tag_on_RAM_r3  <= DSP_Tag_on_RAM_r2;
         DSP_Tag_on_RAM_r4p <= DSP_Tag_on_RAM_r2 or DSP_Tag_on_RAM_r3;
      end if;
   end process;


-- 
-- Delay Synchronous: CplD_Leng_in_Bytes
-- 
   Syn_Delay_CplD_Leng_in_Bytes:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         CplD_Leng_in_Bytes_r1     <= CplD_Leng_in_Bytes;
         CplD_Leng_in_Bytes_r2     <= CplD_Leng_in_Bytes_r1;
      end if;
   end process;


-- ---------------------------------------------
-- Delay Synchronous Delay: RxCplDTrn_State
-- 
   RxFSM_Delay_RxTrn_State:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         RxCplDTrn_State_r1     <= RxCplDTrn_State;
         RxCplDTrn_State_r2     <= RxCplDTrn_State_r1;
      end if;
   end process;


-- ----------------------------------------------
-- States synchronous
-- 
   Syn_RxTrn_States:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         RxCplDTrn_State   <= ST_CplD_RESET;
      elsif trn_clk'event and trn_clk = '1' then
         RxCplDTrn_State   <= RxCplDTrn_NextState;
      end if;

   end process;


-- Next States
   Comb_RxTrn_NextStates:
   process ( 
             RxCplDTrn_State
           , CplD_Type
           , MSB_DSP_Tag
           , trn_reof_n_i
           , trn_rx_throttle
           , Req_ID_Match_i
           , Dex_Tag_Matched_i
           )
   begin
     case RxCplDTrn_State  is

        when ST_CplD_RESET =>
              RxCplDTrn_NextState <= ST_CplD_IDLE;

        when ST_CplD_IDLE =>

          if trn_rx_throttle='0' then
            case CplD_Type is
              when C_TLP_TYPE_IS_CPLD =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPL =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when C_TLP_TYPE_IS_CPLDLK =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPLLK =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when OTHERS =>
                RxCplDTrn_NextState <= ST_CplD_IDLE;
            end case;  -- CplD_Type
          else
            RxCplDTrn_NextState <= ST_CplD_IDLE;
          end if;



        when ST_Cpl_HEAD2 =>   -- further processing to be done ...
           RxCplDTrn_NextState <= ST_CplD_IDLE;


        when ST_CplD_HEAD2 =>
           if trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_HEAD2;
           elsif Req_ID_Match_i='1' and Dex_Tag_Matched_i='1' then
              if trn_reof_n_i='0' then
                RxCplDTrn_NextState <= ST_CplD_AFetch_Special;
              else
                RxCplDTrn_NextState <= ST_CplD_AFetch;
              end if;
           elsif Req_ID_Match_i='1' and MSB_DSP_Tag='0' then
              if trn_reof_n_i='0' then
                RxCplDTrn_NextState <= ST_CplD_AFetch_Special;
              else
                RxCplDTrn_NextState <= ST_CplD_AFetch;
              end if;
           else
              RxCplDTrn_NextState <= ST_CplD_IDLE;
           end if;


        when ST_CplD_AFetch =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_ONLY_1DW;
           elsif trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_AFetch_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_1ST_DATA;
           end if;

        when ST_CplD_AFetch_Special =>
          if trn_rx_throttle='0' then
            case CplD_Type is
              when C_TLP_TYPE_IS_CPLD =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPL =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when C_TLP_TYPE_IS_CPLDLK =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPLLK =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when OTHERS =>
                RxCplDTrn_NextState <= ST_CplD_IDLE;
            end case;  -- CplD_Type
          else
            RxCplDTrn_NextState <= ST_CplD_AFetch_Special_Tail;
          end if;


        when ST_CplD_AFetch_Special_Tail =>
          if trn_rx_throttle='0' then
            case CplD_Type is
              when C_TLP_TYPE_IS_CPLD =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPL =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when C_TLP_TYPE_IS_CPLDLK =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPLLK =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when OTHERS =>
                RxCplDTrn_NextState <= ST_CplD_IDLE;
            end case;  -- CplD_Type
          else
            RxCplDTrn_NextState <= ST_CplD_IDLE;
          end if;


        when ST_CplD_AFetch_THROTTLE =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_ONLY_1DW;
           elsif trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_AFetch_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_1ST_DATA;
           end if;


        when ST_CplD_ONLY_1DW =>
          if trn_rx_throttle='0' then
            case CplD_Type is
              when C_TLP_TYPE_IS_CPLD =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPL =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when C_TLP_TYPE_IS_CPLDLK =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPLLK =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when OTHERS =>
                RxCplDTrn_NextState <= ST_CplD_IDLE;
            end case;  -- CplD_Type
          else
            RxCplDTrn_NextState <= ST_CplD_IDLE;
          end if;


        when ST_CplD_1ST_DATA =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_LAST_DATA;
           elsif trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_1ST_DATA_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_DATA;
           end if;

        when ST_CplD_1ST_DATA_THROTTLE =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_LAST_DATA;
           elsif trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_1ST_DATA_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_DATA;
           end if;


        when ST_CplD_DATA =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_LAST_DATA;
           elsif  trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_DATA_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_DATA;
           end if;


        when ST_CplD_DATA_THROTTLE =>
           if trn_reof_n_i='0' then
              RxCplDTrn_NextState <= ST_CplD_LAST_DATA;
           elsif trn_rx_throttle = '1' then
              RxCplDTrn_NextState <= ST_CplD_DATA_THROTTLE;
           else
              RxCplDTrn_NextState <= ST_CplD_DATA;
           end if;


        when ST_CplD_LAST_DATA =>                 -- Same as IDLE, to support 
                                                  --  back-to-back transactions
          if trn_rx_throttle='0' then
            case CplD_Type is
              when C_TLP_TYPE_IS_CPLD =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPL =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when C_TLP_TYPE_IS_CPLDLK =>
                RxCplDTrn_NextState <= ST_CplD_HEAD2;
              when C_TLP_TYPE_IS_CPLLK =>
                RxCplDTrn_NextState <= ST_Cpl_HEAD2;
              when OTHERS =>
                RxCplDTrn_NextState <= ST_CplD_IDLE;
            end case;  -- CplD_Type
          else
            RxCplDTrn_NextState <= ST_CplD_IDLE;
          end if;


        when OTHERS =>
           RxCplDTrn_NextState <= ST_CplD_RESET;

     end case;

   end process;


-- -------------------------------------------------
-- Synchronous Registered: Tag_Map_Clear_i
-- 
   RxTrn_Tag_Map_Clear:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Tag_Map_Clear_i     <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         FOR j IN 0 TO C_TAG_MAP_WIDTH-1 LOOP

             -- CplD_Tag(C_TAG_WIDTH-2) used as token of BAR
             if CplD_Tag(C_TAG_WIDTH-1)='0'
                and CplD_Tag(C_TAG_WIDTH-2-1 downto 0)=CONV_STD_LOGIC_VECTOR(j, C_TAG_WIDTH-2) 
                and CplD_is_the_Last='1' then
                Tag_Map_Clear_i(j) <=  '1';
             else
                Tag_Map_Clear_i(j) <=  '0';
             end if;

         END LOOP;

      end if;
   end process;



-- -------------------------------------------------
-- Synchronous Registered: CplD_Length
-- 
   RxTrn_CplD_Length:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         CplD_Length     <= (OTHERS => '0');
         CplD_is_1DW     <= '0';
         Small_CplD      <= '0';
         Small_CplD_r1   <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         Small_CplD_r1   <= Small_CplD;

         if trn_rsof_n_i='0' then
            CplD_Length     <= Tlp_has_4KB & trn_rd_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
            CplD_is_1DW     <= Tlp_has_1DW;
            if trn_rd_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT+3)=C_ALL_ZEROS(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT+3)
               and 
                   (trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="000" 
                 or trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="001" 
                 or trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="010" 
                 or trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="011" 
                 or trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="100" 
                 or trn_rd_i(C_TLP_LENG_BIT_BOT+2 downto C_TLP_LENG_BIT_BOT)="101" 
                 )
               and trn_rd_i(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1)="01"   -- Cpl/D
               then
               Small_CplD      <= '1';
            else
               Small_CplD      <= '0';
            end if;
         else
            CplD_Length     <= CplD_Length;
            CplD_is_1DW     <= CplD_is_1DW;
            Small_CplD      <= Small_CplD;
         end if;

      end if;
   end process;



-- -------------------------------------------------
-- Synchronous outputs: Addr_Inc
-- 
   RxFSM_Output_Addr_Inc:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Addr_Inc  <= '1';

      elsif trn_clk'event and trn_clk = '1' then

         case RxCplDTrn_State_r1 is

            when ST_CplD_RESET =>
               Addr_Inc  <= '1';

            when  ST_CplD_1ST_DATA =>
               Addr_Inc  <= tRAM_DoutA_r1(CBIT_AINC_IN_TAGRAM);  

            when ST_CplD_ONLY_1DW =>
               Addr_Inc  <= tRAM_DoutA_r1(CBIT_AINC_IN_TAGRAM);

            when OTHERS =>
               Addr_Inc  <= Addr_Inc;

         end case;
      end if;
   end process;


-------------------------------------------------
-- Calculation at trn_rsof_n
-- 
   Syn_Dex_wrAddress:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Dex_CplD_Illegal        <= '0';
         Reg_WrAddr_if_last_us   <= (OTHERS=>'0');   -- C_REGS_BASE_ADDR;
         Reg_WrAddr_if_last_ds   <= (OTHERS=>'0');   -- C_REGS_BASE_ADDR;

      elsif trn_clk'event and trn_clk = '1' then

         if trn_rsof_n_i = '0' then
            Reg_WrAddr_if_last_us(C_EP_AWIDTH-2-1 downto 2) <= CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_US_CTRL, C_EP_AWIDTH-2-2) - trn_rd_i(C_NEXT_BD_LENG_MSB+32 downto 32);
            Reg_WrAddr_if_last_ds(C_EP_AWIDTH-2-1 downto 2) <= CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_DS_CTRL, C_EP_AWIDTH-2-2) - trn_rd_i(C_NEXT_BD_LENG_MSB+32 downto 32);
--            Reg_WrAddr_if_last_us(C_EP_AWIDTH-2-1 downto 2) <= CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_US_STA, C_EP_AWIDTH-2-2) - trn_rd_i(C_NEXT_BD_LENG_MSB+32 downto 32);
--            Reg_WrAddr_if_last_ds(C_EP_AWIDTH-2-1 downto 2) <= CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_DS_STA, C_EP_AWIDTH-2-2) - trn_rd_i(C_NEXT_BD_LENG_MSB+32 downto 32);
         else
            Reg_WrAddr_if_last_us   <= Reg_WrAddr_if_last_us;
            Reg_WrAddr_if_last_ds   <= Reg_WrAddr_if_last_ds;
         end if;

      end if;

   end process;


-- ---------------------------------------------
-- Reg Synchronous: RegAddr_?s_Dex
-- 
   RxFSM_Reg_RegAddr_xs_Dex:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         RegAddr_us_Dex   <= (Others=>'1');
         RegAddr_ds_Dex   <= (Others=>'1');

      elsif trn_clk'event and trn_clk = '1' then

         if CplD_Tag(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS)/=C_TAG0_DMA_USB(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS) then
            RegAddr_us_Dex   <= (Others=>'1');
         elsif  CplD_is_the_Last = '1' then   -- us last/2nd dex
            RegAddr_us_Dex   <= Reg_WrAddr_if_last_us;
         else                                 -- us 1st/unique dex
            RegAddr_us_Dex   <= -- C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT) &  ,(C_DECODE_BIT_BOT-2)
--                                CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_US_PAH, C_DECODE_BIT_BOT) & "00";
                                CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_US_PAH-1, C_DECODE_BIT_BOT) & "00";
         end if;


         if CplD_Tag(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS)/=C_TAG0_DMA_DSB(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS) then
            RegAddr_ds_Dex   <= (Others=>'1');
         elsif  CplD_is_the_Last = '1' then   -- ds last/2nd dex
            RegAddr_ds_Dex   <= Reg_WrAddr_if_last_ds;
         else                                 -- ds 1st/unique dex
            RegAddr_ds_Dex   <= -- C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT) &  ,(C_DECODE_BIT_BOT-2)
--                                CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_DS_PAH, C_DECODE_BIT_BOT) & "00";
                                CONV_STD_LOGIC_VECTOR(CINT_ADDR_DMA_DS_PAH-1, C_DECODE_BIT_BOT) & "00";
         end if;


      end if;
   end process;



-- ---------------------------------------------
-- Reg Synchronous Delay: CplD_Tag_on_Dex
-- 
   RxFSM_Delay_CplD_Tag_on_Dex:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         CplD_Tag_on_Dex   <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if    CplD_Tag(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS)=C_TAG0_DMA_USB(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS) then
            CplD_Tag_on_Dex   <= '1';
         elsif CplD_Tag(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS)=C_TAG0_DMA_DSB(C_TAG_WIDTH-1 downto C_TAG_WIDTH-C_TAG_DECODE_BITS) then
            CplD_Tag_on_Dex   <= '1';
         else
            CplD_Tag_on_Dex   <= '0';
         end if;

      end if;
   end process;


-------------------------------------------------------
-- Synchronous outputs: DMA_Registers
-- 
   RxFSM_Output_DMA_Registers:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Regs_WrEn_i     <= '0';
         Regs_WrMask_i   <= (OTHERS=>'0');
         Regs_WrDin_i    <= (OTHERS => '0');

      elsif trn_clk'event and trn_clk = '1' then

         case RxCplDTrn_State is

            when  ST_CplD_AFetch =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= "10";
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when  ST_CplD_AFetch_Special =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= "10";
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when  ST_CplD_1ST_DATA =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when ST_CplD_ONLY_1DW =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when ST_CplD_DATA =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= '0' & (trn_rrem_n_r1(3) or trn_rrem_n_r1(0));
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when ST_CplD_LAST_DATA =>
               if CplD_Tag_on_Dex='1' then
                  Regs_WrEn_i     <= '1';
                  Regs_WrMask_i   <= '0' & (trn_rrem_n_r1(3) or trn_rrem_n_r1(0));
                  Regs_WrDin_i    <= trn_rd_Little_r1;
               else
                  Regs_WrEn_i     <= '0';
                  Regs_WrMask_i   <= (OTHERS=>'0');
                  Regs_WrDin_i    <= (Others=>'0');
               end if;

            when OTHERS =>
               Regs_WrEn_i     <= '0';
               Regs_WrMask_i   <= (OTHERS=>'0');
               Regs_WrDin_i    <= (Others=>'0');

         end case;

      end if;
   end process;


-------------------------------------------------------
-- Synchronous outputs: DMA_Registers write Address
-- 
   RxFSM_Output_DMA_Registers_WrAddr:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Regs_WrAddr_i   <= (OTHERS => '1');

      elsif trn_clk'event and trn_clk = '1' then

         case RxCplDTrn_State is

            when ST_CplD_IDLE =>
               Regs_WrAddr_i   <= (OTHERS => '1');

            when  ST_CplD_AFetch =>
               Regs_WrAddr_i   <= RegAddr_us_Dex and RegAddr_ds_Dex;

            when  ST_CplD_AFetch_Special =>
               Regs_WrAddr_i   <= RegAddr_us_Dex and RegAddr_ds_Dex;

            when  ST_CplD_1ST_DATA =>
               Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0)
                               <= Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0) + CONV_STD_LOGIC_VECTOR(8, C_DECODE_BIT_BOT);

            when ST_CplD_ONLY_1DW =>
               Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0)
                               <= Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0) + CONV_STD_LOGIC_VECTOR(8, C_DECODE_BIT_BOT);

            when ST_CplD_DATA =>
               Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0)
                               <= Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0) + CONV_STD_LOGIC_VECTOR(8, C_DECODE_BIT_BOT);

            when ST_CplD_LAST_DATA =>
               Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0)
                               <= Regs_WrAddr_i(C_DECODE_BIT_BOT-1 downto 0) + CONV_STD_LOGIC_VECTOR(8, C_DECODE_BIT_BOT);

            when OTHERS =>
               Regs_WrAddr_i   <= Regs_WrAddr_i;

         end case;

      end if;
   end process;



-----------------------------------------------------
-- Synchronous Register: 
--                      dsDMA_dex_Tag_i
--                      usDMA_dex_Tag_i
--
   FSM_Reg_DMA_dex_Tags:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         usDMA_dex_Tag_i     <= C_TAG0_DMA_USB;
         dsDMA_dex_Tag_i     <= C_TAG0_DMA_DSB;

      elsif trn_clk'event and trn_clk = '1' then

         case RxCplDTrn_State is

           when ST_CplD_AFetch =>

              if  trn_rd_r1(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=usDMA_dex_Tag_i and CplD_is_the_Last = '1' then
                usDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0)   <= usDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) + X"1";
              else 
                usDMA_dex_Tag_i   <= usDMA_dex_Tag_i;
              end if;

              if trn_rd_r1(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=dsDMA_dex_Tag_i and CplD_is_the_Last = '1' then
                dsDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0)   <= dsDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) + X"1";
              else
                dsDMA_dex_Tag_i   <= dsDMA_dex_Tag_i;
              end if;

           when ST_CplD_AFetch_Special =>

              if  trn_rd_r1(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=usDMA_dex_Tag_i and CplD_is_the_Last = '1' then
                usDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0)   <= usDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) + X"1";
              else 
                usDMA_dex_Tag_i   <= usDMA_dex_Tag_i;
              end if;

              if trn_rd_r1(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=dsDMA_dex_Tag_i and CplD_is_the_Last = '1' then
                dsDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0)   <= dsDMA_dex_Tag_i(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) + X"1";
              else
                dsDMA_dex_Tag_i   <= dsDMA_dex_Tag_i;
              end if;

           when Others =>
              usDMA_dex_Tag_i   <= usDMA_dex_Tag_i;
              dsDMA_dex_Tag_i   <= dsDMA_dex_Tag_i;

         end case;

      end if;
   end process;


-- -------------------------------------------------------------
--   RAM holding downstream Tags of packet MRd requests
-- -------------------------------------------------------------

   tRAM_addra    <= CplD_Tag(C_TAGRAM_AWIDTH-1 downto 0);
   tRAM_weB_i(0) <= tRAM_weB;

   dspTag_BRAM:
   FF_TagRam64x36
     port map(
              clk       =>  trn_clk    ,

              wea       =>  tRAM_wea(0)   ,
              addra     =>  tRAM_addra ,
              dina      =>  tRAM_dina  ,
              douta     =>  tRAM_doutA ,

              web       =>  tRAM_weB_i(0) ,
              addrb     =>  tRAM_addrB ,
              dinb      =>  tRAM_dinB  ,
              doutb     =>  open       
             );


--   dspTag_BRAM:
--   v5tagram64x36
--     port map(
--              clka      =>  trn_clk    ,
--              addra     =>  tRAM_addra ,
--              wea       =>  tRAM_wea   ,
--              dina      =>  tRAM_dina  ,
--              douta     =>  tRAM_doutA ,
--              clkb      =>  trn_clk    ,
--              addrb     =>  tRAM_addrB ,
--              web       =>  tRAM_weB_i ,
--              dinb      =>  tRAM_dinB  ,
--              doutb     =>  open       
--             );


-- -----------------------------------------------------------------------------------
-- Synchronous delay: CplD_is_the_Last
-- 
   Syn_Delay_CplD_is_the_Last:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         CplD_is_the_Last_r1  <= CplD_is_the_Last;
         CplD_is_the_Last_r2  <= CplD_is_the_Last_r1;
      end if;
   end process;

-- -----------------------------------------------------------------------------------
-- Synchronous output: Updates_tRAM
--                     Update happens only at data TLP
--                     The last CplD of one MRd does not trigger tRAM update, 
--                         to enable back-to-back transactions.
-- 
   RxFSM_Output_Updates_tRAM:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Updates_tRAM <= '0';

      elsif trn_clk'event and trn_clk = '1' then

            Updates_tRAM   <=  CplD_State_is_AFetch
                           and DSP_Tag_on_RAM_r1
                           and not CplD_is_the_Last_r2
                           ;

      end if;
   end process;


-- -----------------------------------------------------------------------------------
-- Synchronous output: Update_was_too_late
--                     For 1DW CplD the update might be too late for the
--                     next CplD with the same TAG
-- 
   RxFSM_Output_Update_was_too_late:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Update_was_too_late     <= '0';
--         hazard_tag              <= (OTHERS=>'1');
         tag_matches_hazard      <= '0';
         tag_matches_hazard_r1   <= '0';
         tag_matches_hazard_r2   <= '0';
         hazard_update           <= '0';
         hazard_update_r1        <= '0';
         hazard_update_r2        <= '0';
         hazard_update_r3        <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if (Small_CplD='1' or Small_CplD_r1='1')
----??            and (CplD_State_is_after_AFetch='1' or CplD_State_is_after_AFetch_r1='1')
            and (CplD_State_is_AFetch='1')
            and CplD_Tag_on_Dex='0'
            then
           hazard_update          <= '1';
         else
           hazard_update          <= '0';
         end if;

         hazard_update_r1       <= hazard_update;
         hazard_update_r2       <= hazard_update_r1;
         hazard_update_r3       <= hazard_update_r2;

--         Update_was_too_late    <= hazard_update_r1 or hazard_update_r2 or hazard_update_r3;
         Update_was_too_late    <= hazard_update or hazard_update_r1 or hazard_update_r2 or hazard_update_r3;



         if trn_rsof_n_i='1' and trn_rsof_n_r1='0' then
            if trn_rd_r1(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="10"
               and trn_rd_r1(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="01"
               then
               curr_tag_latch         <= CplD_Tag;
               if CplD_Tag=curr_tag_latch then
                  tag_matches_hazard    <= '1';
               else
                  tag_matches_hazard    <= '0';
               end if;
            else
               curr_tag_latch         <= (OTHERS=>'1');
            end if;
         else
           curr_tag_latch         <= curr_tag_latch;
         end if;

         tag_matches_hazard_r1    <= tag_matches_hazard;
         tag_matches_hazard_r2    <= tag_matches_hazard_r1;


--         if DDR_Space_Hit='0' then
--           hazard_tag             <= (OTHERS=>'1');
--         elsif CplD_State_is_after_AFetch='1' then
--           hazard_tag             <= curr_tag_latch;  -- CplD_Tag_r1;
--         else
--           hazard_tag             <= hazard_tag;
--         end if;
--
--         if trn_rsof_n_i='1' and trn_rsof_n_r1='0' then
--            if trn_rd_r1(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="10"
--               and trn_rd_r1(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="01"
--               then
--               curr_tag_latch         <= CplD_Tag;
--            else
--               curr_tag_latch         <= (OTHERS=>'1');
--            end if;
--         else
--           curr_tag_latch         <= curr_tag_latch;
--         end if;
--
--         if CplD_Tag=hazard_tag then
--            tag_matches_hazard    <= '1';
--         else
--            tag_matches_hazard    <= '0';
--         end if;

      end if;
   end process;


-- ---------------------------------------------
-- Delay Synchronous Delay: Updates_tRAM
-- 
   RxFSM_Delay_Updates_tRAM:
   process ( trn_clk )
   begin
       if trn_clk'event and trn_clk = '1' then
         Updates_tRAM_r1     <= Updates_tRAM;
      end if;
   end process;


-- ---------------------------------------------
-- Synchronous Delay: tRAM_DoutA_r2
-- 
   Delay_tRAM_DoutA:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then

----         if CplD_State_is_AFetch='1' then    -- [ avoid confilict in simulation, can be removed ]
--            if TLB_Hit='1'
--               and TLB_Valid='1'               -- [ only for simulation. can be removed for imp.]
--               then 
--               tRAM_DoutA_r1 <= TLB_Content;
--            else
--               tRAM_DoutA_r1 <= tRAM_doutA;
--            end if;
----         else
----            tRAM_DoutA_r1 <= tRAM_DoutA_r1;
----         end if;

         if Update_was_too_late='1' and tag_matches_hazard='1' then
           tRAM_DoutA_r1 <= hazard_content;
         else
           tRAM_DoutA_r1 <= tRAM_doutA;
         end if;
--         tRAM_DoutA_r1 <= tRAM_doutA;
         tRAM_DoutA_r2 <= tRAM_DoutA_r1;

      end if;
   end process;


-- ---------------------------------------------
-- Synchronous Output: hazard_content
-- 
   Syn_Reg_hazard_content:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         hazard_content  <= (OTHERS =>'1');
      elsif trn_clk'event and trn_clk = '1' then
         if tRAM_wea(0)='1' then
            hazard_content  <= tRAM_dina;
         else
            hazard_content  <= hazard_content;
         end if;
      end if;
   end process;


-- ---------------------------------------------
-- Synchronous Calculation: tRAM_dina_aInc
-- 
   Syn_Calc_tRAM_dina_aInc:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         tRAM_dina_aInc  <= (CBIT_AINC_IN_TAGRAM=>'1',
                             OTHERS =>'0'
                            );
      elsif trn_clk'event and trn_clk = '1' then
         tRAM_dina_aInc(C_TAGBAR_BIT_TOP downto C_TAGBAR_BIT_BOT)
                         <= tRAM_DoutA_r1(C_TAGBAR_BIT_TOP downto C_TAGBAR_BIT_BOT);
         tRAM_dina_aInc(C_TAGBAR_BIT_BOT-1 downto 0)                   --C_EP_AWIDTH  !!!!!
                         <= tRAM_DoutA_r1(C_TAGBAR_BIT_BOT-1 downto 0) --C_EP_AWIDTH  !!!!!
                          + CplD_Leng_in_Bytes_r2(C_TLP_FLD_WIDTH_OF_LENG+2 downto  0) ;
      end if;
   end process;


   tRAM_wea(0)  <= Updates_tRAM_r1;
   tRAM_dina    <= tRAM_dina_aInc;
--   tRAM_dina    <=   ('1' & tRAM_dina_aInc(C_TAGRAM_DWIDTH-1-1 downto 0)) 
--                     when Addr_Inc='1'
--                     else ('0' & tRAM_DoutA_r2(C_TAGRAM_DWIDTH-1-1 downto 0));


-- ---------------------------------------------
-- Synchronous Calculation: tRAM_DoutA_latch
-- 
   Syn_tRAM_DoutA_latch:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         tRAM_DoutA_latch  <= (CBIT_AINC_IN_TAGRAM=>'1',OTHERS =>'0');
      elsif trn_clk'event and trn_clk = '1' then
         if CplD_State_is_AFetch_r1='0' then
           tRAM_DoutA_latch <= tRAM_DoutA_latch;
         elsif Update_was_too_late='0' then
           tRAM_DoutA_latch <= tRAM_DoutA;
         elsif tag_matches_hazard='1' then
           tRAM_DoutA_latch <= hazard_content;
         else
           tRAM_DoutA_latch <= tRAM_DoutA_r1;
         end if;
      end if;
   end process;

-- ---------------------------------------------
-- Synchronous Output: TLB  (not used)
-- 
   Syn_Reg_TLB_Operation:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         TLB_Addr     <= (OTHERS =>'1');
         TLB_Content  <= (OTHERS =>'0');
         TLB_cnt      <= (OTHERS =>'0');
         TLB_Valid    <= '0';
         TLB_Hit      <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if Updates_tRAM_r1='0' then
            TLB_Content  <= TLB_Content;
            TLB_Addr     <= TLB_Addr;
            if TLB_cnt=C_ALL_ZEROS(3 downto 0) then
               TLB_cnt      <= TLB_cnt;
               TLB_Valid    <= '0';
            else
               TLB_cnt      <= TLB_cnt - '1';
               TLB_Valid    <= '1';
            end if;
         else
            TLB_Addr     <= tRAM_addra;
            TLB_cnt      <= C_TLB_VALID_CNT;
            TLB_Valid    <= '0';
            if Addr_Inc='1' then
               TLB_Content  <= '1' & tRAM_dina_aInc(C_TAGRAM_DWIDTH-1-1 downto 0);
            else
               TLB_Content  <= '0' & tRAM_DoutA_r2(C_TAGRAM_DWIDTH-1-1 downto 0);
            end if;
         end if;

         if TLB_Addr=tRAM_addra then
            TLB_Hit      <= '1';
         else
            TLB_Hit      <= '0';
         end if;

      end if;
   end process;


   hybrid_rd  <= trn_rd_r1(32-1 downto 0) & trn_rd_i(64-1 downto 32);

-- -------------------------------------------------
-- Synchronous outputs: eb_FIFO_Write
-- 
   RxFSM_Output_FIFO_Space_Hit:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         eb_FIFO_we_i   <= '0';
         eb_FIFO_wsof_i <= '0';
         eb_FIFO_weof_i <= '0';
         eb_FIFO_sof_marker <= '0';
         eb_FIFO_din_i  <= (OTHERS=>'0');
         EB_Write_State <= ST_EBWR_IDLE;

      elsif trn_clk'event and trn_clk = '1' then

         case EB_Write_State is

            when ST_EBWR_IDLE =>
               eb_FIFO_we_i    <= '0';
               eb_FIFO_wsof_i  <= '0';
               eb_FIFO_weof_i  <= '0';
               eb_FIFO_sof_marker  <= '0';
               eb_FIFO_din_i   <= (OTHERS=>'0');
               if trn_rx_throttle='0'
                  and CplD_Type=C_TLP_TYPE_IS_CPLD
                  and trn_rd_i(0)='0'              -- Odd-DW CplD is illegal
                  then
                  EB_Write_State  <= ST_EBWR_TAG;
               else
                  EB_Write_State  <= ST_EBWR_IDLE;
               end if;

            when  ST_EBWR_TAG =>
               eb_FIFO_we_i    <= '0';
               eb_FIFO_wsof_i  <= '0';
               eb_FIFO_weof_i  <= '0';
               eb_FIFO_din_i   <= (OTHERS=>'0');
               if trn_rsof_n_i='0' then
                  eb_FIFO_sof_marker  <= '0';
                  EB_Write_State  <= ST_EBWR_TAG;
               elsif trn_rx_throttle='0' and DSP_Tag_on_FIFO='1' then
                  eb_FIFO_sof_marker  <= '1';
                  EB_Write_State  <= ST_EBWR_DATA;
               else
                  eb_FIFO_sof_marker  <= '0';
                  EB_Write_State  <= ST_EBWR_IDLE;
               end if;

            when  ST_EBWR_DATA =>
               eb_FIFO_we_i    <= not trn_rx_throttle;
               eb_FIFO_wsof_i  <= eb_FIFO_sof_marker and not trn_rx_throttle;
               eb_FIFO_sof_marker  <= eb_FIFO_sof_marker and trn_rx_throttle;
               eb_FIFO_din_i   <= Endian_Invert_64(hybrid_rd);
               if trn_rx_throttle='0' and trn_reof_n_i='0' then
                  eb_FIFO_weof_i  <= '1';
                  EB_Write_State  <= ST_EBWR_IDLE;
               else
                  eb_FIFO_weof_i  <= '0';
                  EB_Write_State  <= ST_EBWR_DATA;
               end if;


            when OTHERS =>
               eb_FIFO_we_i    <= '0';
               eb_FIFO_wsof_i  <= '0';
               eb_FIFO_weof_i  <= '0';
               eb_FIFO_sof_marker  <= '0';
               eb_FIFO_din_i   <= (OTHERS=>'0');
               EB_Write_State  <= ST_EBWR_IDLE;

         end case;

      end if;
   end process;


-- -------------------------------------------------
-- Synchronous outputs: DDR_Space_Hit
-- 
   RxFSM_Output_DDR_Space_Hit:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         DDR_Space_Hit  <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if CplD_State_is_AFetch='1' then
            DDR_Space_Hit  <= DSP_Tag_on_RAM and not TLP_is_not_CplD_r1;
         elsif trn_reof_n_r4='0' then
            DDR_Space_Hit  <= '0';
         else
            DDR_Space_Hit  <= DDR_Space_Hit;
         end if;

      end if;
   end process;


-- -------------------------------------------------
-- Synchronous outputs: DDR write
-- 
   RxFSM_Output_DDR_Write:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         DDR_wr_sof_i   <= '0';
         DDR_wr_eof_i   <= '0';
         DDR_wr_v_i     <= '0';
         DDR_wr_FA_i    <= '0';
         DDR_wr_void    <= '1';
         DDR_wr_Shift_i <= '0';
         DDR_wr_Mask_i  <= (OTHERS=>'0');
         DDR_wr_din_i   <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         if DDR_wr_eof_i='1' and (CplD_State_is_after_AFetch='1' and DSP_Tag_on_RAM_r1='1') then
            DDR_wr_void  <= '0';
         elsif DDR_wr_eof_i='1' then
            DDR_wr_void  <= '1';
         elsif CplD_State_is_after_AFetch='1' and DSP_Tag_on_RAM_r1='1' then
            DDR_wr_void  <= '0';
         else
            DDR_wr_void  <= DDR_wr_void;
         end if;

         DDR_wr_sof_i   <= DDR_Space_Hit and CplD_State_is_after_AFetch;

         DDR_wr_eof_i   <= (DDR_Space_Hit and not trn_reof_n_r4)
                        or (CplD_State_is_AFetch and DSP_Tag_on_RAM_r4p and not TLP_is_not_CplD_r4 and not DSP_Tag_on_RAM_r1)
                        ;

         if CplD_State_is_after_AFetch='1' then
            DDR_wr_v_i     <= DDR_Space_Hit;
         elsif CplD_State_is_AFetch='1' then
            DDR_wr_v_i     <= DSP_Tag_on_RAM_r4p and not TLP_is_not_CplD_r4 and not DDR_wr_eof_i and not DDR_wr_void;
         elsif DDR_Space_Hit='1' then
            DDR_wr_v_i     <= (CplD_State_is_after_AFetch 
                           or not (trn_rx_throttle_r4 and trn_reof_n_r4)
                           or DDR_wr_sof_i) and not DDR_wr_eof_i and not DDR_wr_void
                           ;
         else
            DDR_wr_v_i     <= '0';
         end if;

         if CplD_State_is_after_AFetch='1' and DDR_Space_Hit='1' then
            if Update_was_too_late='1' and tag_matches_hazard_r2='1' then
              DDR_wr_din_i   <= CplD_Leng_in_Bytes_r2(C_DBUS_WIDTH/2-1 downto 0) & hazard_content(C_DBUS_WIDTH/2-1 downto 0);
            elsif CplD_State_is_AFetch_r1 = '0' then
              DDR_wr_din_i   <= CplD_Leng_in_Bytes_r2(C_DBUS_WIDTH/2-1 downto 0) & tRAM_DoutA_latch(C_DBUS_WIDTH/2-1 downto 0);
            else
              DDR_wr_din_i   <= CplD_Leng_in_Bytes_r2(C_DBUS_WIDTH/2-1 downto 0) & tRAM_DoutA_r1(C_DBUS_WIDTH/2-1 downto 0);
            end if;
         elsif DDR_Space_Hit='1' then
            DDR_wr_din_i   <= trn_rd_Little_r4;
         else
            DDR_wr_din_i   <= (OTHERS=>'0');
         end if;

         if CplD_State_is_after_AFetch='1' and DDR_Space_Hit='1' then
            if Update_was_too_late='1' and tag_matches_hazard_r2='1' then
              DDR_wr_Shift_i <= not hazard_content(2);
            elsif CplD_State_is_AFetch_r1 = '0' then
              DDR_wr_Shift_i <= not tRAM_DoutA_latch(2);
            else
              DDR_wr_Shift_i <= not tRAM_DoutA_r1(2);
            end if;
         else
            DDR_wr_Shift_i <= '0';
         end if;

         if DDR_wr_sof_i='1' then
            DDR_wr_Mask_i  <= "10";
         else
            DDR_wr_Mask_i  <= '0' & (trn_rrem_n_r4(3) or trn_rrem_n_r4(0));
         end if;

      end if;
   end process;


end architecture Behavioral;
