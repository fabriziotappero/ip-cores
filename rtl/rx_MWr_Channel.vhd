----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    rx_MWr_Transact - Behavioral 
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

entity rx_MWr_Transact is
    port (
      -- Transaction receive interface
      trn_rsof_n         : IN  std_logic;
      trn_reof_n         : IN  std_logic;
      trn_rd             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n         : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n      : IN  std_logic;
      trn_rsrc_rdy_n     : IN  std_logic;
      trn_rdst_rdy_n     : IN  std_logic;  -- !!
      trn_rsrc_dsc_n     : IN std_logic;
      trn_rbar_hit_n     : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av      : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av      : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av     : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av     : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av    : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av    : IN  std_logic_vector(11 downto 0);

      -- from pre-process module
      IOWr_Type          : IN  std_logic;
      MWr_Type           : IN  std_logic_vector(1 downto 0);
      Tlp_straddles_4KB  : IN  std_logic;
--      Last_DW_of_TLP     : IN  std_logic;
      Tlp_has_4KB        : IN  std_logic;


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

      -- Data generator table write
      tab_we             : OUT std_logic_vector(2-1 downto 0);
      tab_wa             : OUT std_logic_vector(12-1 downto 0);
      tab_wd             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic;
      trn_lnk_up_n       : IN  std_logic
    );

end entity rx_MWr_Transact;



architecture Behavioral of rx_MWr_Transact is


  type RxMWrTrnStates is       ( ST_MWr_RESET
                               , ST_MWr_IDLE
--                               , ST_MWr3_HEAD1
--                               , ST_MWr4_HEAD1
                               , ST_MWr3_HEAD2
                               , ST_MWr4_HEAD2
--                               , ST_MWr4_HEAD3
--                               , ST_MWr_Last_HEAD
                               , ST_MWr4_1ST_DATA
                               , ST_MWr_1ST_DATA
                               , ST_MWr_1ST_DATA_THROTTLE
                               , ST_MWr_DATA
                               , ST_MWr_DATA_THROTTLE
                               , ST_MWr_LAST_DATA
                               );

  -- State variables
  signal RxMWrTrn_NextState    : RxMWrTrnStates;
  signal RxMWrTrn_State        : RxMWrTrnStates;

  -- trn_rx stubs
  signal  trn_rd_i             : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal  trn_rd_r1            : std_logic_vector (C_DBUS_WIDTH-1 downto 0);

  signal  trn_rrem_n_i         : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal  trn_rrem_n_r1        : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);

  signal  trn_rbar_hit_n_i     : std_logic_vector (C_BAR_NUMBER-1 downto 0);
  signal  trn_rbar_hit_n_r1    : std_logic_vector (C_BAR_NUMBER-1 downto 0);

  signal  trn_rsrc_rdy_n_i     : std_logic;
  signal  trn_rerrfwd_n_i      : std_logic;
  signal  trn_rsof_n_i         : std_logic;
  signal  trn_reof_n_i         : std_logic;
  signal  trn_rsrc_rdy_n_r1    : std_logic;
  signal  trn_reof_n_r1        : std_logic;


  -- packet RAM and packet FIFOs selection signals
  signal  FIFO_Space_Sel       : std_logic;
  signal  DDR_Space_Sel        : std_logic;
  signal  REGS_Space_Sel       : std_logic;

  -- DDR write port
  signal  DDR_wr_sof_i         : std_logic;
  signal  DDR_wr_eof_i         : std_logic;
  signal  DDR_wr_v_i           : std_logic;
  signal  DDR_wr_FA_i          : std_logic;
  signal  DDR_wr_Shift_i       : std_logic;
  signal  DDR_wr_Mask_i        : std_logic_vector(2-1 downto 0);
  signal  ddr_wr_1st_mask_hi   : std_logic;
  signal  DDR_wr_din_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DDR_wr_full_i        : std_logic;

  -- Data generator sequence table write
  signal  dg_table_Sel         : std_logic;
  signal  tab_wa_odd           : std_logic;
  signal  tab_we_i             : std_logic_vector(2-1 downto 0);
  signal  tab_wa_i             : std_logic_vector(12-1 downto 0);
  signal  tab_wd_i             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Event Buffer write port
  signal  eb_FIFO_we_i         : std_logic;
  signal  eb_FIFO_wsof_i       : std_logic;
  signal  eb_FIFO_weof_i       : std_logic;
  signal  eb_FIFO_din_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- 
  signal  Regs_WrEn_i          : std_logic;
  signal  Regs_WrMask_i        : std_logic_vector(2-1 downto 0);
  signal  Regs_WrAddr_i        : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal  Regs_WrDin_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  trn_rdst_rdy_n_i     : std_logic;
  signal  trn_rsrc_dsc_n_i     : std_logic;

  signal  trn_rx_throttle      : std_logic;
  signal  trn_rx_throttle_r1   : std_logic;

  -- 1st DW BE = "0000" means the TLP is of zero-length.
  signal  MWr_Has_4DW_Header   : std_logic;
  signal  Tlp_is_Zero_Length   : std_logic;
  signal  MWr_Leng_in_Bytes    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);



begin

   -- Event Buffer write
   eb_FIFO_we        <= eb_FIFO_we_i   ;
   eb_FIFO_wsof      <= eb_FIFO_wsof_i ;
   eb_FIFO_weof      <= eb_FIFO_weof_i ;
   eb_FIFO_din       <= eb_FIFO_din_i  ;

   -- DDR
   DDR_wr_sof        <= DDR_wr_sof_i   ;
   DDR_wr_eof        <= DDR_wr_eof_i   ;
   DDR_wr_v          <= DDR_wr_v_i     ;
   DDR_wr_FA         <= DDR_wr_FA_i    ;
   DDR_wr_Shift      <= DDR_wr_Shift_i ;
   DDR_wr_Mask       <= DDR_wr_Mask_i  ;
   DDR_wr_din        <= DDR_wr_din_i   ;
   DDR_wr_full_i     <= DDR_wr_full    ;

   -- Data generator table
   tab_we            <= tab_we_i ;
   tab_wa            <= tab_wa_i ;
   tab_wd            <= tab_wd_i ;

   -- Registers writing
   Regs_WrEn         <= Regs_WrEn_i;
   Regs_WrMask       <= Regs_WrMask_i;
   Regs_WrAddr       <= Regs_WrAddr_i;
   Regs_WrDin        <= Regs_WrDin_i;    -- Mem_WrData;



   -- TLP info stubs
   trn_rd_i          <= trn_rd;
   trn_rsof_n_i      <= trn_rsof_n;
   trn_reof_n_i      <= trn_reof_n;
   trn_rrem_n_i      <= trn_rrem_n;


   -- Output to the core as handshaking
   trn_rerrfwd_n_i   <= trn_rerrfwd_n;
   trn_rbar_hit_n_i  <= trn_rbar_hit_n;
   trn_rsrc_dsc_n_i  <= trn_rsrc_dsc_n;

   -- Output to the core as handshaking
   trn_rsrc_rdy_n_i  <= trn_rsrc_rdy_n;
   trn_rdst_rdy_n_i  <= trn_rdst_rdy_n;


   -- ( trn_rsrc_rdy_n seems never deasserted during packet)
   trn_rx_throttle   <= trn_rsrc_rdy_n_i or trn_rdst_rdy_n_i;


-- -----------------------------------------------------
--   Delays: trn_rd_i, trn_rbar_hit_n_i, trn_reof_n_i
-- -----------------------------------------------------
   Sync_Delays_trn_rd_rbar_reof:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         trn_rsrc_rdy_n_r1  <= trn_rsrc_rdy_n_i;
         trn_reof_n_r1      <= trn_reof_n_i;
         trn_rd_r1          <= trn_rd_i;
         trn_rrem_n_r1      <= trn_rrem_n_i;
         trn_rbar_hit_n_r1  <= trn_rbar_hit_n_i;
         trn_rx_throttle_r1 <= trn_rx_throttle;
      end if;
   end process;


-- -----------------------------------------------------------------------
-- States synchronous
-- 
   Syn_RxTrn_States:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         RxMWrTrn_State   <= ST_MWr_RESET;
      elsif trn_clk'event and trn_clk = '1' then
         RxMWrTrn_State   <= RxMWrTrn_NextState;
      end if;
   end process;


-- Next States
   Comb_RxTrn_NextStates:
   process ( 
             RxMWrTrn_State
           , MWr_Type
--           , IOWr_Type
           , Tlp_straddles_4KB
           , trn_rx_throttle
           , trn_reof_n_i
--           , Last_DW_of_TLP
           )
   begin
     case RxMWrTrn_State  is

        when ST_MWr_RESET =>
              RxMWrTrn_NextState <= ST_MWr_IDLE;

        when ST_MWr_IDLE =>
          if trn_rx_throttle='0' then
           case MWr_Type is
             when C_TLP_TYPE_IS_MWR_H3 =>
               RxMWrTrn_NextState <= ST_MWr3_HEAD2;
             when C_TLP_TYPE_IS_MWR_H4 =>
               RxMWrTrn_NextState <= ST_MWr4_HEAD2;
             when OTHERS =>
--               if IOWr_Type='1' then   -- Temp taking IOWr as MWr3
--                 RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--               else
                 RxMWrTrn_NextState <= ST_MWr_IDLE;
--               end if;
           end case;  -- MWr_Type
          else
            RxMWrTrn_NextState <= ST_MWr_IDLE;
          end if;


--        when ST_MWr3_HEAD1 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--           else
--              RxMWrTrn_NextState <= ST_MWr3_HEAD2;
--           end if;

--        when ST_MWr4_HEAD1 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr4_HEAD1;
--           else
--              RxMWrTrn_NextState <= ST_MWr4_HEAD2;
--           end if;


        when ST_MWr3_HEAD2 =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr3_HEAD2;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_IDLE;      -- ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_1ST_DATA;  -- ST_MWr_Last_HEAD;
           end if;

        when ST_MWr4_HEAD2 =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr4_HEAD2;
           else
              RxMWrTrn_NextState <= ST_MWr4_1ST_DATA;  -- ST_MWr4_HEAD3;
           end if;

--        when ST_MWr4_HEAD3 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr4_HEAD3;
--           else
--              RxMWrTrn_NextState <= ST_MWr_Last_HEAD;
--           end if;


--        when ST_MWr_Last_HEAD =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr_Last_HEAD;
--           elsif Tlp_straddles_4KB = '1' then      -- !!
--              RxMWrTrn_NextState <= ST_MWr_IDLE;
----           elsif Last_DW_of_TLP='1' then
----              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
--           elsif trn_reof_n_i = '0' then
--              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
--           else
--              RxMWrTrn_NextState <= ST_MWr_1ST_DATA;
--           end if;


        when ST_MWr_1ST_DATA =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_DATA;
           end if;

        when ST_MWr4_1ST_DATA =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_DATA;
           end if;

        when ST_MWr_1ST_DATA_THROTTLE =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_DATA;
           end if;


        when ST_MWr_DATA =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr_DATA_THROTTLE;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_DATA;
           end if;


        when ST_MWr_DATA_THROTTLE =>
           if trn_rx_throttle = '1' then
              RxMWrTrn_NextState <= ST_MWr_DATA_THROTTLE;
           elsif trn_reof_n_i = '0' then
              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
           else
              RxMWrTrn_NextState <= ST_MWr_DATA;
           end if;


        when ST_MWr_LAST_DATA =>              -- Same as ST_MWr_IDLE, to support 
                                              --  back-to-back transactions
           case MWr_Type is
             when C_TLP_TYPE_IS_MWR_H3 =>
               RxMWrTrn_NextState <= ST_MWr3_HEAD2;
             when C_TLP_TYPE_IS_MWR_H4 =>
               RxMWrTrn_NextState <= ST_MWr4_HEAD2;
             when OTHERS =>
--               if IOWr_Type='1' then
--                 RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--               else
                 RxMWrTrn_NextState <= ST_MWr_IDLE;
--               end if;
           end case;  -- MWr_Type


        when OTHERS =>
           RxMWrTrn_NextState <= ST_MWr_RESET;

     end case;

   end process;



-- ----------------------------------------------
-- registers Write Enable
-- 
   RxFSM_Output_Regs_Write_En:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         Regs_WrEn_i    <= '0';
         Regs_WrMask_i  <= (OTHERS=>'0');
         Regs_WrAddr_i  <= (OTHERS=>'1');
         Regs_WrDin_i   <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         case RxMWrTrn_State is

            when ST_MWr3_HEAD2 =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;
                  Regs_WrMask_i  <= "01";
                  Regs_WrAddr_i  <= trn_rd_i(C_EP_AWIDTH-1+32 downto 2+32) & "00";
                  Regs_WrDin_i   <= Endian_Invert_32(trn_rd_i(31 downto 0)) & X"00000000";
--                  Regs_WrDin_i   <= Endian_Invert_64((trn_rd_r1(31 downto 0)&trn_rd_r1(63 downto 32)));
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;

            when ST_MWr4_HEAD2 =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= trn_rd_i(C_EP_AWIDTH-1 downto 2) &"00";
                  Regs_WrDin_i   <= Endian_Invert_64(trn_rd_i);
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;

            when ST_MWr_1ST_DATA =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;
                  Regs_WrDin_i   <= Endian_Invert_64 (trn_rd_i);
                  if trn_reof_n_i='0' then
                    Regs_WrMask_i  <= '0' & (trn_rrem_n_i(3) or trn_rrem_n_i(0));
                  else
                    Regs_WrMask_i  <= (OTHERS=>'0');
                  end if;
                  if MWr_Has_4DW_Header='1' then
                    Regs_WrAddr_i  <= Regs_WrAddr_i;
                  else
                    Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
                  end if;
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;

            when ST_MWr4_1ST_DATA =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;
                  Regs_WrDin_i   <= Endian_Invert_64 (trn_rd_i);
                  if trn_reof_n_i='0' then
                    Regs_WrMask_i  <= '0' & (trn_rrem_n_i(3) or trn_rrem_n_i(0));
                  else
                    Regs_WrMask_i  <= (OTHERS=>'0');
                  end if;
--                  if MWr_Has_4DW_Header='1' then
                    Regs_WrAddr_i  <= Regs_WrAddr_i;
--                  else
--                    Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
--                  end if;
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;

            when ST_MWr_1ST_DATA_THROTTLE =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;
                  Regs_WrDin_i   <= Endian_Invert_64 (trn_rd_i);
                  if trn_reof_n_i='0' then
                    Regs_WrMask_i  <= '0' & (trn_rrem_n_i(3) or trn_rrem_n_i(0));
                  else
                    Regs_WrMask_i  <= (OTHERS=>'0');
                  end if;
--                  if MWr_Has_4DW_Header='1' then
                    Regs_WrAddr_i  <= Regs_WrAddr_i;
--                  else
--                    Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
--                  end if;
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;

            when ST_MWr_DATA =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;  -- '1';
                  if trn_reof_n_i='0' then
                    Regs_WrMask_i  <= '0' & (trn_rrem_n_i(3) or trn_rrem_n_i(0));
                  else
                    Regs_WrMask_i  <= (OTHERS=>'0');
                  end if;
                  Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(8, C_EP_AWIDTH);
                  Regs_WrDin_i   <= Endian_Invert_64 (trn_rd_i);
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;


            when ST_MWr_DATA_THROTTLE =>
               if    REGS_Space_Sel='1' then
                  Regs_WrEn_i    <= not trn_rx_throttle;  -- '1';
                  if trn_reof_n_i='0' then
                    Regs_WrMask_i  <= '0' & (trn_rrem_n_i(3) or trn_rrem_n_i(0));
                  else
                    Regs_WrMask_i  <= (OTHERS=>'0');
                  end if;
                  Regs_WrAddr_i  <= Regs_WrAddr_i;  -- + CONV_STD_LOGIC_VECTOR(8, C_EP_AWIDTH);
                  Regs_WrDin_i   <= Endian_Invert_64 (trn_rd_i);
               else
                  Regs_WrEn_i    <= '0';
                  Regs_WrMask_i  <= (OTHERS=>'0');
                  Regs_WrAddr_i  <= (OTHERS=>'1');
                  Regs_WrDin_i   <= (OTHERS=>'0');
               end if;


            when OTHERS =>
               Regs_WrEn_i    <= '0';
               Regs_WrMask_i  <= (OTHERS=>'0');
               Regs_WrAddr_i  <= (OTHERS=>'1');
               Regs_WrDin_i   <= (OTHERS=>'0');

         end case;

      end if;

   end process;



-- -----------------------------------------------------------------------
-- Capture: REGS_Space_Sel
-- 
   Syn_Capture_REGS_Space_Sel:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         REGS_Space_Sel       <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n_i='0' then
            REGS_Space_Sel       <= (trn_rd_i(3) or trn_rd_i(2) or trn_rd_i(1) or trn_rd_i(0))
                                 and not trn_rbar_hit_n_i(CINT_REGS_SPACE_BAR);
         else
            REGS_Space_Sel       <= REGS_Space_Sel;
         end if;
      end if;
   end process;


-- -----------------------------------------------------------------------
-- Capture: MWr_Has_4DW_Header
--        : Tlp_is_Zero_Length
-- 
   Syn_Capture_MWr_Has_4DW_Header:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         MWr_Has_4DW_Header   <= '0';
         Tlp_is_Zero_Length   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n_i='0' then
            MWr_Has_4DW_Header   <= trn_rd_i(C_TLP_FMT_BIT_BOT);
            Tlp_is_Zero_Length   <= not (trn_rd_i(3) or trn_rd_i(2) or trn_rd_i(1) or trn_rd_i(0));
         else
            MWr_Has_4DW_Header   <= MWr_Has_4DW_Header;
            Tlp_is_Zero_Length   <= Tlp_is_Zero_Length;
         end if;
      end if;
   end process;

-- -----------------------------------------------------------------------
-- Capture: MWr_Leng_in_Bytes
-- 
   Syn_Capture_MWr_Length_in_Bytes:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         MWr_Leng_in_Bytes   <= (OTHERS=>'0');
      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n_i='0' then
            -- Assume no 4KB length for MWr
            MWr_Leng_in_Bytes(C_TLP_FLD_WIDTH_OF_LENG+2 downto 2) 
                                <= Tlp_has_4KB & trn_rd_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
         else
            MWr_Leng_in_Bytes   <= MWr_Leng_in_Bytes;
         end if;
      end if;
   end process;


-- ----------------------------------------------
--  Synchronous outputs:  DDR Space Select     --
-- ----------------------------------------------
   RxFSM_Output_DDR_Space_Selected:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         DDR_Space_Sel  <= '0';
         DDR_wr_sof_i   <= '0';
         DDR_wr_eof_i   <= '0';
         DDR_wr_v_i     <= '0';
         DDR_wr_FA_i    <= '0';
         DDR_wr_Shift_i <= '0';
         DDR_wr_Mask_i  <= (OTHERS=>'0');
         DDR_wr_din_i   <= (OTHERS=>'0');
         ddr_wr_1st_mask_hi <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         case RxMWrTrn_State is

           when ST_MWr3_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 DDR_Space_Sel  <= not trn_rd_i(32+19) and not trn_rd_i(32+18);   -- '1';
                 DDR_wr_sof_i   <= not trn_rd_i(32+19) and not trn_rd_i(32+18);   -- '1';
                 DDR_wr_eof_i   <= '0';
                 DDR_wr_v_i     <= not trn_rsrc_rdy_n_i and not trn_rd_i(32+19) and not trn_rd_i(32+18);
                 DDR_wr_FA_i    <= '0';
                 DDR_wr_Shift_i <= not trn_rd_i(2+32);
                 DDR_wr_Mask_i  <= (OTHERS=>'0');
                 ddr_wr_1st_mask_hi <= '1';
                 DDR_wr_din_i   <= MWr_Leng_in_Bytes(31 downto 0) & trn_rd_i(64-1 downto 32);
               else
                 DDR_Space_Sel  <= '0';
                 DDR_wr_sof_i   <= '0';
                 DDR_wr_eof_i   <= '0';
                 DDR_wr_v_i     <= '0';
                 DDR_wr_FA_i    <= '0';
                 DDR_wr_Shift_i <= '0';
                 DDR_wr_Mask_i  <= (OTHERS=>'0');
                 ddr_wr_1st_mask_hi <= '0';
                 DDR_wr_din_i   <= MWr_Leng_in_Bytes(31 downto 0) & trn_rd_i(64-1 downto 32);
               end if;

           when ST_MWr4_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 DDR_Space_Sel  <= not trn_rd_i(19) and not trn_rd_i(18);   -- '1';
                 DDR_wr_sof_i   <= not trn_rd_i(19) and not trn_rd_i(18);   -- '1';
                 DDR_wr_eof_i   <= '0';
                 DDR_wr_v_i     <= not trn_rsrc_rdy_n_i and not trn_rd_i(19) and not trn_rd_i(18);
                 DDR_wr_FA_i    <= '0';
                 DDR_wr_Shift_i <= trn_rd_i(2);
                 DDR_wr_Mask_i  <= (OTHERS=>'0');
                 ddr_wr_1st_mask_hi <= '0';
                 DDR_wr_din_i   <= MWr_Leng_in_Bytes(31 downto 0) & trn_rd_i(32-1 downto 0);
               else
                 DDR_Space_Sel  <= '0';
                 DDR_wr_sof_i   <= '0';
                 DDR_wr_eof_i   <= '0';
                 DDR_wr_v_i     <= '0';
                 DDR_wr_FA_i    <= '0';
                 DDR_wr_Shift_i <= '0';
                 DDR_wr_Mask_i  <= (OTHERS=>'0');
                 ddr_wr_1st_mask_hi <= '0';
                 DDR_wr_din_i   <= MWr_Leng_in_Bytes(31 downto 0) & trn_rd_i(32-1 downto 0);
               end if;

           when ST_MWr4_1ST_DATA =>
               DDR_Space_Sel  <= DDR_Space_Sel;
               DDR_wr_sof_i   <= '0';
               DDR_wr_eof_i   <= '0';
               DDR_wr_v_i     <= '0';
               DDR_wr_FA_i    <= '0';
               DDR_wr_Shift_i <= '0';
               DDR_wr_Mask_i  <= (OTHERS=>'0');
               ddr_wr_1st_mask_hi <= '0';
               DDR_wr_din_i   <= (OTHERS=>'0');


            when OTHERS =>
               if trn_reof_n_r1='0' then
                  DDR_Space_Sel    <= '0';
               else
                  DDR_Space_Sel    <= DDR_Space_Sel;
               end if;

               if DDR_Space_Sel='1' then
                  DDR_wr_sof_i   <= '0';
                  DDR_wr_eof_i   <= not trn_reof_n_r1;
                  DDR_wr_v_i     <= not trn_rx_throttle_r1;  -- not trn_rsrc_rdy_n_r1;
                  DDR_wr_FA_i    <= '0';
                  DDR_wr_Shift_i <= '0';
                  DDR_wr_Mask_i  <= ddr_wr_1st_mask_hi & (trn_rrem_n_r1(3) or trn_rrem_n_r1(0));
                  DDR_wr_din_i   <= Endian_Invert_64 (trn_rd_r1);
               else
                  DDR_wr_sof_i   <= '0';
                  DDR_wr_eof_i   <= '0';
                  DDR_wr_v_i     <= '0';
                  DDR_wr_FA_i    <= '0';
                  DDR_wr_Shift_i <= '0';
                  DDR_wr_Mask_i  <= (OTHERS=>'0');
                  DDR_wr_din_i   <= Endian_Invert_64 (trn_rd_r1);
               end if;
               if DDR_wr_v_i='1' then
                  ddr_wr_1st_mask_hi <= '0';
               else
                  ddr_wr_1st_mask_hi <= ddr_wr_1st_mask_hi;
               end if;

         end case;

      end if;

   end process;


-- ----------------------------------------------
--  Synchronous outputs:  DGen Table write     --
-- ----------------------------------------------
   RxFSM_Output_DGen_Table_write:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         --  Assume every PIO MWr contains only 1 DW(32 bits) payload
         dg_table_Sel   <= '0';
         tab_we_i       <= (OTHERS=>'0');
         tab_wa_i       <= (OTHERS=>'0');
         tab_wd_i       <= (OTHERS=>'0');
         tab_wa_odd     <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         case RxMWrTrn_State is

           when ST_MWr3_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 dg_table_Sel   <= trn_rd_i(19) and trn_rd_i(18) and not trn_rd_i(17) and not trn_rd_i(16);  -- any expression
                 tab_we_i       <= (trn_rd_i(32+19) and trn_rd_i(32+18) and not trn_rd_i(32+17) and not trn_rd_i(32+16) and not trn_rd_i(34))
                                 & (trn_rd_i(32+19) and trn_rd_i(32+18) and not trn_rd_i(32+17) and not trn_rd_i(32+16) and trn_rd_i(34));
                 tab_wa_i       <= trn_rd_i(32+3+11 downto 32+3);
                 tab_wa_odd     <= trn_rd_i(32+2);
                 tab_wd_i       <= Endian_Invert_64 ( (trn_rd_i(32-1 downto 0) & trn_rd_i(32-1 downto 0)) );
               else
                 dg_table_Sel   <= '0';
                 tab_we_i       <= (OTHERS=>'0');
                 tab_wa_i       <= trn_rd_i(32+3+11 downto 32+3);
                 tab_wa_odd     <= trn_rd_i(32+2);
                 tab_wd_i       <= Endian_Invert_64 ( (trn_rd_i(32-1 downto 0) & trn_rd_i(32-1 downto 0)));
               end if;

           when ST_MWr4_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 dg_table_Sel   <= trn_rd_i(19) and trn_rd_i(18) and not trn_rd_i(17) and not trn_rd_i(16);
                 tab_we_i       <= (OTHERS=>'0');
                 tab_wa_i       <= trn_rd_i(3+11 downto 3);
                 tab_wa_odd     <= trn_rd_i(2);
                 tab_wd_i       <= Endian_Invert_64 ( (trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));
               else
                 dg_table_Sel   <= '0';
                 tab_we_i       <= (OTHERS=>'0');
                 tab_wa_i       <= trn_rd_i(3+11 downto 3);
                 tab_wa_odd     <= trn_rd_i(2);
                 tab_wd_i       <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));
               end if;


           when ST_MWr4_1ST_DATA =>
               dg_table_Sel   <= dg_table_Sel;
               tab_we_i       <= (dg_table_Sel and not trn_rx_throttle and not tab_wa_odd)
                               & (dg_table_Sel and not trn_rx_throttle and tab_wa_odd);
               tab_wa_i       <= tab_wa_i;
               tab_wa_odd     <= tab_wa_odd;
               tab_wd_i       <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));


           when ST_MWr_1ST_DATA_THROTTLE =>
               dg_table_Sel   <= dg_table_Sel;
               tab_we_i       <= (dg_table_Sel and not trn_rx_throttle and not tab_wa_odd)
                               & (dg_table_Sel and not trn_rx_throttle and tab_wa_odd);
               tab_wa_i       <= tab_wa_i;
               tab_wa_odd     <= tab_wa_odd;
               tab_wd_i       <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));


            when OTHERS =>
               dg_table_Sel   <= '0';
               tab_we_i       <= (OTHERS=>'0');
               tab_wa_i       <= tab_wa_i;
               tab_wa_odd     <= tab_wa_odd;
               tab_wd_i       <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));

         end case;

      end if;

   end process;



-- ----------------------------------------------
--  Synchronous outputs:  EB FIFO Select       --
-- ----------------------------------------------
   RxFSM_Output_FIFO_Space_Selected:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         FIFO_Space_Sel  <= '0';
         eb_FIFO_we_i    <= '0';
         eb_FIFO_wsof_i  <= '0';
         eb_FIFO_weof_i  <= '0';
         eb_FIFO_din_i   <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         case RxMWrTrn_State is

           when ST_MWr3_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_FIFO_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 FIFO_Space_Sel <= '1';
                 eb_FIFO_we_i   <= not trn_reof_n_i;           -- '1';
                 eb_FIFO_wsof_i <= not trn_reof_n_i;           -- '1';
                 eb_FIFO_weof_i <= not trn_reof_n_i;           -- '1';
                 eb_FIFO_din_i  <= Endian_Invert_64 ((trn_rd_i(32-1 downto 0) & trn_rd_i(32-1 downto 0)));
               else
                 FIFO_Space_Sel <= '0';
                 eb_FIFO_we_i   <= '0';
                 eb_FIFO_wsof_i <= '0';
                 eb_FIFO_weof_i <= '0';
                 eb_FIFO_din_i  <= Endian_Invert_64 ((trn_rd_i(32-1 downto 0) & trn_rd_i(32-1 downto 0)));
               end if;

           when ST_MWr_1ST_DATA =>
               FIFO_Space_Sel <= FIFO_Space_Sel;
               eb_FIFO_we_i   <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
               eb_FIFO_wsof_i <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
               eb_FIFO_weof_i <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
               eb_FIFO_din_i  <= Endian_Invert_64 (( trn_rd_r1(32-1 downto 0) & trn_rd_i(64-1 downto 32) ));


           when ST_MWr4_HEAD2 =>
             if trn_rbar_hit_n_r1(CINT_FIFO_SPACE_BAR)='0'
                and Tlp_is_Zero_Length='0'
               then
                 FIFO_Space_Sel <= '1';
                 eb_FIFO_we_i   <= '0';
                 eb_FIFO_wsof_i <= '0';
                 eb_FIFO_weof_i <= '0';
                 eb_FIFO_din_i  <= (OTHERS=>'0');
               else
                 FIFO_Space_Sel <= '0';
                 eb_FIFO_we_i   <= '0';
                 eb_FIFO_wsof_i <= '0';
                 eb_FIFO_weof_i <= '0';
                 eb_FIFO_din_i  <= (OTHERS=>'0');
               end if;

           when ST_MWr4_1ST_DATA =>
               FIFO_Space_Sel <= FIFO_Space_Sel;
               eb_FIFO_we_i   <= FIFO_Space_Sel and not trn_reof_n_i;    -- trn_rx_throttle;
               eb_FIFO_wsof_i <= FIFO_Space_Sel and not trn_reof_n_i;    -- trn_rx_throttle;
               eb_FIFO_weof_i <= FIFO_Space_Sel and not trn_reof_n_i;    -- trn_rx_throttle;
                 if trn_rrem_n_i(3)='1' or trn_rrem_n_i(0)='1' then
                   eb_FIFO_din_i  <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));
                 else
                   eb_FIFO_din_i  <= Endian_Invert_64 (trn_rd_i);
                 end if;

           when ST_MWr_1ST_DATA_THROTTLE =>
               if MWr_Has_4DW_Header='1' then
                 FIFO_Space_Sel <= FIFO_Space_Sel;
                 eb_FIFO_we_i   <= FIFO_Space_Sel and not trn_reof_n_i;  -- trn_rx_throttle;
                 eb_FIFO_wsof_i <= FIFO_Space_Sel and not trn_reof_n_i;  -- trn_rx_throttle;
                 eb_FIFO_weof_i <= FIFO_Space_Sel and not trn_reof_n_i;  -- trn_rx_throttle;
                 if trn_rrem_n_i(3)='1' or trn_rrem_n_i(0)='1' then
                   eb_FIFO_din_i  <= Endian_Invert_64 ((trn_rd_i(64-1 downto 32) & trn_rd_i(64-1 downto 32)));
                 else
                   eb_FIFO_din_i  <= Endian_Invert_64 (trn_rd_i);
                 end if;
               else
                 FIFO_Space_Sel <= FIFO_Space_Sel;
                 eb_FIFO_we_i   <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
                 eb_FIFO_wsof_i <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
                 eb_FIFO_weof_i <= FIFO_Space_Sel and not trn_reof_n_i;           -- '1';
                 eb_FIFO_din_i  <= Endian_Invert_64 (( trn_rd_r1(32-1 downto 0) & trn_rd_i(64-1 downto 32) ));
               end if;

            when OTHERS =>
               FIFO_Space_Sel <= '0';
               eb_FIFO_we_i   <= '0';
               eb_FIFO_wsof_i <= '0';
               eb_FIFO_weof_i <= '0';
               eb_FIFO_din_i  <= (OTHERS=>'0');

         end case;

      end if;

   end process;


end architecture Behavioral;
