----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    rx_Transact - Behavioral 
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

entity rx_Transact is
    port (
      -- Common ports
      trn_clk                   : IN  std_logic;
      trn_reset_n               : IN  std_logic;
      trn_lnk_up_n              : IN  std_logic;

      -- Transaction receive interface
      trn_rsof_n                : IN  std_logic;
      trn_reof_n                : IN  std_logic;
      trn_rd                    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n                : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n             : IN  std_logic;
      trn_rsrc_rdy_n            : IN  std_logic;
      trn_rdst_rdy_n            : OUT std_logic;
      trn_rnp_ok_n              : OUT std_logic;
      trn_rsrc_dsc_n            : IN  std_logic;
      trn_rbar_hit_n            : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av             : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av             : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av            : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av            : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av           : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av           : IN  std_logic_vector(11 downto 0);

      -- PIO MRd Channel
      pioCplD_Req               : OUT std_logic;
      pioCplD_RE                : IN  std_logic;
      pioCplD_Qout              : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      pio_FC_stop               : IN  std_logic;

      -- downstream MRd Channel
      dsMRd_Req                 : OUT std_logic;
      dsMRd_RE                  : IN  std_logic;
      dsMRd_Qout                : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- upstream MWr/MRd Channel
      usTlp_Req                 : OUT std_logic;
      usTlp_RE                  : IN  std_logic;
      usTlp_Qout                : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      us_FC_stop                : IN  std_logic;
      us_Last_sof               : IN  std_logic;
      us_Last_eof               : IN  std_logic;

      -- Irpt Channel
      Irpt_Req                  : OUT std_logic;
      Irpt_RE                   : IN  std_logic;
      Irpt_Qout                 : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Interrupt Interface
		cfg_interrupt_n           : OUT std_logic;
		cfg_interrupt_rdy_n       : IN  std_logic;
		cfg_interrupt_mmenable    : IN  std_logic_VECTOR(2 downto 0);
		cfg_interrupt_msienable   : IN  std_logic;
		cfg_interrupt_di          : OUT std_logic_VECTOR(7 downto 0);
		cfg_interrupt_do          : IN  std_logic_VECTOR(7 downto 0);
		cfg_interrupt_assert_n    : OUT std_logic;

      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add          : OUT std_logic;
      ds_DMA_Bytes              : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- --------------------------
      -- Registers
      DMA_ds_PA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA                : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null         : IN  std_logic;
      DMA_ds_Status             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Done               : OUT std_logic;
      DMA_ds_Busy               : OUT std_logic;
      DMA_ds_Tout               : OUT std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b               : IN  std_logic;
      dsBDA_is_64b              : IN  std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True         : IN  std_logic;
      dsLeng_Lo7b_True          : IN  std_logic;

      --
      dsDMA_Start               : IN  std_logic;
      dsDMA_Stop                : IN  std_logic;
      dsDMA_Start2              : IN  std_logic;
      dsDMA_Stop2               : IN  std_logic;
      dsDMA_Channel_Rst         : IN  std_logic;
      dsDMA_Cmd_Ack             : OUT std_logic;

      --
      DMA_us_PA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA                : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null         : IN  std_logic;
      us_MWr_Param_Vec          : IN  std_logic_vector(6-1   downto 0);
      DMA_us_Status             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Done               : OUT std_logic;
      DMA_us_Busy               : OUT std_logic;
      DMA_us_Tout               : OUT std_logic;

      -- Calculation in advance, for better timing
      usHA_is_64b               : IN  std_logic;
      usBDA_is_64b              : IN  std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True         : IN  std_logic;
      usLeng_Lo7b_True          : IN  std_logic;

      --
      usDMA_Start               : IN  std_logic;
      usDMA_Stop                : IN  std_logic;
      usDMA_Start2              : IN  std_logic;
      usDMA_Stop2               : IN  std_logic;
      usDMA_Channel_Rst         : IN  std_logic;
      usDMA_Cmd_Ack             : OUT std_logic;

      MRd_Channel_Rst           : IN  std_logic;

      -- to Interrupt module
      Sys_IRQ                   : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);


      -- Event Buffer write port
      eb_FIFO_we                : OUT std_logic;
      eb_FIFO_wsof              : OUT std_logic;
      eb_FIFO_weof              : OUT std_logic;
      eb_FIFO_din               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      eb_FIFO_data_count        : IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      eb_FIFO_Empty             : IN  std_logic;
      eb_FIFO_Reading           : IN  std_logic;
      pio_reading_status        : OUT std_logic; 

      Link_Buf_full             : IN  std_logic;

      -- Registers Write Port
      Regs_WrEn0                : OUT std_logic;
      Regs_WrMask0              : OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr0              : OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin0               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      Regs_WrEn1                : OUT std_logic;
      Regs_WrMask1              : OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr1              : OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin1               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof_A              : OUT std_logic;
      DDR_wr_eof_A              : OUT std_logic;
      DDR_wr_v_A                : OUT std_logic;
      DDR_wr_FA_A               : OUT std_logic;
      DDR_wr_Shift_A            : OUT std_logic;
      DDR_wr_Mask_A             : OUT std_logic_vector(2-1 downto 0);
      DDR_wr_din_A              : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      DDR_wr_sof_B              : OUT std_logic;
      DDR_wr_eof_B              : OUT std_logic;
      DDR_wr_v_B                : OUT std_logic;
      DDR_wr_FA_B               : OUT std_logic;
      DDR_wr_Shift_B            : OUT std_logic;
      DDR_wr_Mask_B             : OUT std_logic_vector(2-1 downto 0);
      DDR_wr_din_B              : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      DDR_wr_full               : IN  std_logic;

      -- Data generator table write
      tab_we                    : OUT std_logic_vector(2-1 downto 0);
      tab_wa                    : OUT std_logic_vector(12-1 downto 0);
      tab_wd                    : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Interrupt generator signals
      IG_Reset                  : IN  std_logic;
      IG_Host_Clear             : IN  std_logic;
      IG_Latency                : IN  std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Assert             : OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Deassert           : OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Asserting              : OUT std_logic;

      -- Additional
      cfg_dcommand              : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);
      localID                   : IN  std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity rx_Transact;


architecture Behavioral of rx_Transact is

   signal  eb_FIFO_we_i         : std_logic;
   signal  eb_FIFO_wsof_i       : std_logic;
   signal  eb_FIFO_weof_i       : std_logic;
   signal  eb_FIFO_din_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    ------------------------------------------------------------------
    --  Rx input delay
    --  some calculation in advance, to achieve better timing
    -- 
    COMPONENT 
    RxIn_Delay
    PORT (
      -- Common ports
      trn_clk                   : IN  std_logic;
      trn_reset_n               : IN  std_logic;
      trn_lnk_up_n              : IN  std_logic;

      -- Transaction receive interface
      trn_rsof_n                : IN  std_logic;
      trn_reof_n                : IN  std_logic;
      trn_rd                    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n                : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n             : IN  std_logic;
      trn_rsrc_rdy_n            : IN  std_logic;
      trn_rsrc_dsc_n            : IN  std_logic;
      trn_rbar_hit_n            : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
      trn_rdst_rdy_n            : OUT std_logic;
      Pool_wrBuf_full           : IN  std_logic;
      Link_Buf_full             : IN  std_logic;

      -- Delayed
      trn_rsof_n_dly            : OUT std_logic;
      trn_reof_n_dly            : OUT std_logic;
      trn_rd_dly                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n_dly            : OUT std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n_dly         : OUT std_logic;
      trn_rsrc_rdy_n_dly        : OUT std_logic;
      trn_rdst_rdy_n_dly        : OUT std_logic;
      trn_rsrc_dsc_n_dly        : OUT std_logic;
      trn_rbar_hit_n_dly        : OUT std_logic_vector(C_BAR_NUMBER-1 downto 0);

      -- TLP resolution
      IORd_Type                 : OUT std_logic;
      IOWr_Type                 : OUT std_logic;
      MRd_Type                  : OUT std_logic_vector(3 downto 0);
      MWr_Type                  : OUT std_logic_vector(1 downto 0);
      CplD_Type                 : OUT std_logic_vector(3 downto 0);

      -- From Cpl/D channel
      usDMA_dex_Tag             : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);
      dsDMA_dex_Tag             : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Memory request process modules
      Tlp_straddles_4KB         : OUT std_logic;

      -- To Cpl/D channel
      Tlp_has_4KB               : OUT std_logic;
      Tlp_has_1DW               : OUT std_logic;
      CplD_is_the_Last          : OUT std_logic;
      CplD_on_Pool              : OUT std_logic;
      CplD_on_EB                : OUT std_logic;
      Req_ID_Match              : OUT std_logic;
      usDex_Tag_Matched         : OUT std_logic;
      dsDex_Tag_Matched         : OUT std_logic;
      CplD_Tag                  : OUT std_logic_vector(C_TAG_WIDTH-1 downto  0);

      -- Additional
      cfg_dcommand              : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);
      localID                   : IN  std_logic_vector(C_ID_WIDTH-1 downto 0)
    );
    END COMPONENT;

   -- One clock delayed
   signal   trn_rsof_n_dly      :  std_logic;
   signal   trn_reof_n_dly      :  std_logic;
   signal   trn_rd_dly          :  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
   signal   trn_rrem_n_dly      :  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
   signal   trn_rerrfwd_n_dly   :  std_logic;
   signal   trn_rsrc_rdy_n_dly  :  std_logic;
   signal   trn_rdst_rdy_n_dly  :  std_logic;
   signal   trn_rsrc_dsc_n_dly  :  std_logic;
   signal   trn_rbar_hit_n_dly  :  std_logic_vector(C_BAR_NUMBER-1 downto 0);

   -- TLP types
   signal   IORd_Type           :  std_logic;
   signal   IOWr_Type           :  std_logic;
   signal   MRd_Type            :  std_logic_vector(3 downto 0);
   signal   MWr_Type            :  std_logic_vector(1 downto 0);
   signal   CplD_Type           :  std_logic_vector(3 downto 0);

   signal   Tlp_straddles_4KB   :  std_logic;

   -- To Cpl/D channel
   signal   Tlp_has_4KB         :  std_logic;
   signal   Tlp_has_1DW         :  std_logic;
   signal   CplD_is_the_Last    :  std_logic;
   signal   CplD_on_Pool        :  std_logic;
   signal   CplD_on_EB          :  std_logic;
   signal   Req_ID_Match        :  std_logic;
   signal   usDex_Tag_Matched   :  std_logic;
   signal   dsDex_Tag_Matched   :  std_logic;
   signal   CplD_Tag            :  std_logic_vector(C_TAG_WIDTH-1 downto  0);


   ------------------------------------------------------------------
   --  MRd TLP processing
   --   contains channel buffer for PIO Completions
   -- 
	COMPONENT 
   rx_MRd_Transact
	PORT(
		trn_rsof_n                : IN  std_logic;
		trn_reof_n                : IN  std_logic;
		trn_rd                    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n                : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
--		trn_rdst_rdy_n            : OUT std_logic;
		trn_rnp_ok_n              : OUT std_logic;  -----------------
		trn_rerrfwd_n             : IN  std_logic;
		trn_rsrc_rdy_n            : IN  std_logic;
		trn_rsrc_dsc_n            : IN  std_logic;
		trn_rbar_hit_n            : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);

      IORd_Type                 : IN  std_logic;
      MRd_Type                  : IN  std_logic_vector(3 downto 0);
      Tlp_straddles_4KB         : IN  std_logic;

		pioCplD_RE                : IN  std_logic;
		pioCplD_Req               : OUT std_logic;
		pioCplD_Qout              : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      FIFO_Empty                : IN  std_logic;
      FIFO_Reading              : IN  std_logic;
      pio_FC_stop               : IN  std_logic;
      pio_reading_status        : OUT std_logic; 

      Channel_Rst               : IN  std_logic;

		trn_clk                   : IN  std_logic;
		trn_reset_n               : IN  std_logic;
		trn_lnk_up_n              : IN  std_logic
		);
	END COMPONENT;


   ------------------------------------------------------------------
   --  MWr TLP processing
   -- 
	COMPONENT 
   rx_MWr_Transact
	PORT(
      --
		trn_rsof_n                : IN  std_logic;
		trn_reof_n                : IN  std_logic;
		trn_rd                    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n                : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
		trn_rdst_rdy_n            : IN  std_logic;  -- !!
		trn_rerrfwd_n             : IN  std_logic;
		trn_rsrc_rdy_n            : IN  std_logic;
		trn_rsrc_dsc_n            : IN  std_logic;
		trn_rbar_hit_n            : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);

      IOWr_Type                 : IN  std_logic;
      MWr_Type                  : IN  std_logic_vector(1 downto 0);
      Tlp_straddles_4KB         : IN  std_logic;
      Tlp_has_4KB               : IN  std_logic;


      -- Event Buffer write port
      eb_FIFO_we                : OUT std_logic;
      eb_FIFO_wsof              : OUT std_logic;
      eb_FIFO_weof              : OUT std_logic;
      eb_FIFO_din               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Registers Write Port
      Regs_WrEn                 : OUT std_logic;
      Regs_WrMask               : OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr               : OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof                : OUT std_logic;
      DDR_wr_eof                : OUT std_logic;
      DDR_wr_v                  : OUT std_logic;
      DDR_wr_FA                 : OUT std_logic;
      DDR_wr_Shift              : OUT std_logic;
      DDR_wr_Mask               : OUT std_logic_vector(2-1 downto 0);
      DDR_wr_din                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full               : IN  std_logic;

      -- Data generator table write
      tab_we             : OUT std_logic_vector(2-1 downto 0);
      tab_wa             : OUT std_logic_vector(12-1 downto 0);
      tab_wd             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Common
		trn_clk                   : IN  std_logic;
		trn_reset_n               : IN  std_logic;
		trn_lnk_up_n              : IN  std_logic

		);
	END COMPONENT;

   signal  eb_FIFO_we_MWr       : std_logic;
   signal  eb_FIFO_wsof_MWr     : std_logic;
   signal  eb_FIFO_weof_MWr     : std_logic;
   signal  eb_FIFO_din_MWr      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);


   ------------------------------------------------------------------
   --  Cpl/D TLP processing
   -- 
	COMPONENT 
   rx_CplD_Transact
	PORT(
		trn_rsof_n                : IN  std_logic;
		trn_reof_n                : IN  std_logic;
		trn_rd                    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n                : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
		trn_rdst_rdy_n            : IN  std_logic;
		trn_rerrfwd_n             : IN  std_logic;
		trn_rsrc_rdy_n            : IN  std_logic;
		trn_rsrc_dsc_n            : IN  std_logic;
		trn_rbar_hit_n            : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);

      CplD_Type                 : IN  std_logic_vector(3 downto 0);

      Req_ID_Match              : IN  std_logic;
      usDex_Tag_Matched         : IN  std_logic;
      dsDex_Tag_Matched         : IN  std_logic;

      Tlp_has_4KB               : IN  std_logic;
      Tlp_has_1DW               : IN  std_logic;
      CplD_is_the_Last          : IN  std_logic;
      CplD_on_Pool              : IN  std_logic;
      CplD_on_EB                : IN  std_logic;
      CplD_Tag                  : IN  std_logic_vector(C_TAG_WIDTH-1 downto  0);
      FC_pop                    : OUT std_logic;

      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add          : OUT std_logic;
      ds_DMA_Bytes              : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- for descriptor of the downstream DMA
      dsDMA_Dex_Tag             : OUT std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Downstream Handshake Signals with ds Channel for Busy/Done
      Tag_Map_Clear             : OUT std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);

      -- Downstream tRAM port A write request
      tRAM_weB                  : IN  std_logic;
      tRAM_addrB                : IN  std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB                 : IN  std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- for descriptor of the upstream DMA
      usDMA_dex_Tag             : OUT std_logic_vector(C_TAG_WIDTH-1 downto 0);


      -- Event Buffer write port
      eb_FIFO_we                : OUT std_logic;
      eb_FIFO_wsof              : OUT std_logic;
      eb_FIFO_weof              : OUT std_logic;
      eb_FIFO_din               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Registers Write Port
      Regs_WrEn                 : OUT std_logic;
      Regs_WrMask               : OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr               : OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof                : OUT std_logic;
      DDR_wr_eof                : OUT std_logic;
      DDR_wr_v                  : OUT std_logic;
      DDR_wr_FA                 : OUT std_logic;
      DDR_wr_Shift              : OUT std_logic;
      DDR_wr_Mask               : OUT std_logic_vector(2-1 downto 0);
      DDR_wr_din                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full               : IN  std_logic;

      -- Common signals
		trn_clk                   : IN  std_logic;
		trn_reset_n               : IN  std_logic;
		trn_lnk_up_n              : IN  std_logic
		);
	END COMPONENT;

   signal  eb_FIFO_we_CplD      : std_logic;
   signal  eb_FIFO_wsof_CplD    : std_logic;
   signal  eb_FIFO_weof_CplD    : std_logic;
   signal  eb_FIFO_din_CplD     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

   signal  usDMA_dex_Tag        : std_logic_vector(C_TAG_WIDTH-1 downto 0);
   signal  dsDMA_dex_Tag        : std_logic_vector(C_TAG_WIDTH-1 downto 0);

   signal  Tag_Map_Clear        : std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
   signal  FC_pop               : std_logic;


   ------------------------------------------------------------------
   --  Interrupts generation
   -- 
   COMPONENT 
   Interrupts
   PORT(
      Sys_IRQ                   : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Interrupt generator signals
      IG_Reset                  : IN  std_logic;
      IG_Host_Clear             : IN  std_logic;
      IG_Latency                : IN  std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Assert             : OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Deassert           : OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Asserting              : OUT std_logic;

      -- cfg interface
      cfg_interrupt_n           : OUT std_logic;
      cfg_interrupt_rdy_n       : IN  std_logic;
      cfg_interrupt_mmenable    : IN  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable   : IN  std_logic;
      cfg_interrupt_di          : OUT std_logic_vector(7 downto 0);
      cfg_interrupt_do          : IN  std_logic_vector(7 downto 0);
      cfg_interrupt_assert_n    : OUT std_logic;

      -- Irpt Channel
      Irpt_Req                  : OUT std_logic;
      Irpt_RE                   : IN  std_logic;
      Irpt_Qout                 : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      trn_clk                   : IN  std_logic;
      trn_reset_n               : IN  std_logic
      );
   END COMPONENT;


   ------------------------------------------------------------------
   --  Upstream DMA Channel
   --   contains channel buffer for upstream DMA
   -- 
	COMPONENT 
   usDMA_Transact
	PORT(

      -- command buffer  
      usTlp_Req                 : OUT std_logic;
      usTlp_RE                  : IN  std_logic;
      usTlp_Qout                : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      FIFO_Data_Count           : IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      FIFO_Empty                : IN  std_logic;
      FIFO_Reading              : IN  std_logic;

      -- Upstream DMA Control Signals from MWr Channel
      usDMA_Start               : IN  std_logic;
      usDMA_Stop                : IN  std_logic;
      usDMA_Channel_Rst         : IN  std_logic;
      us_FC_stop                : IN  std_logic;
      us_Last_sof               : IN  std_logic;
      us_Last_eof               : IN  std_logic;

      --- Upstream registers from CplD channel
      DMA_us_PA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA                : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null         : IN  std_logic;
      us_MWr_Param_Vec          : IN  std_logic_vector(6-1   downto 0);

      -- Calculation in advance, for better timing
      usHA_is_64b               : IN  std_logic;
      usBDA_is_64b              : IN  std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True         : IN  std_logic;
      usLeng_Lo7b_True          : IN  std_logic;

      --- Upstream commands from CplD channel
      usDMA_Start2              : IN  std_logic;
      usDMA_Stop2               : IN  std_logic;

      -- DMA Acknowledge to the start command
      DMA_Cmd_Ack               : OUT std_logic;

      --- Tag for descriptor
      usDMA_dex_Tag             : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Interrupt module
      DMA_Done                  : OUT std_logic;
      DMA_TimeOut               : OUT std_logic;
      DMA_Busy                  : OUT std_logic;

      -- To Tx channel   
      DMA_us_Status             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand              : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

      -- common
		trn_clk                   : IN  std_logic;
		trn_reset_n               : IN  std_logic
		);
	END COMPONENT;


   ------------------------------------------------------------------
   --  Downstream DMA Channel
   --   contains channel buffer for downstream DMA
   -- 
	COMPONENT 
   dsDMA_Transact
	PORT(
      -- command buffer
		MRd_dsp_RE                : IN std_logic;
		MRd_dsp_Req               : OUT std_logic;
		MRd_dsp_Qout              : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Downstream tRAM port A write request, to CplD channel
      tRAM_weB                  : OUT std_logic;
      tRAM_addrB                : OUT std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB                 : OUT std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- Downstream Registers from MWr Channel
      DMA_ds_PA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA                 : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA                : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null         : IN  std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b               : IN  std_logic;
      dsBDA_is_64b              : IN  std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True         : IN  std_logic;
      dsLeng_Lo7b_True          : IN  std_logic;

      -- Downstream Control Signals from MWr Channel
      dsDMA_Start               : IN  std_logic;
      dsDMA_Stop                : IN  std_logic;

      -- DMA Acknowledge to the start command
      DMA_Cmd_Ack               : OUT std_logic;

      dsDMA_Channel_Rst         : IN  std_logic;

      -- Downstream Control Signals from CplD Channel, out of consecutive dex
      dsDMA_Start2              : IN  std_logic;
      dsDMA_Stop2               : IN  std_logic;

      -- Downstream Handshake Signals with CplD Channel for Busy/Done
      Tag_Map_Clear             : IN  std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
      FC_pop                    : IN  std_logic;


      -- Tag for descriptor
      dsDMA_dex_Tag             : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Interrupt module
      DMA_Done                  : OUT std_logic;
      DMA_TimeOut               : OUT std_logic;
      DMA_Busy                  : OUT std_logic;

      -- To Cpl/D channel
      DMA_ds_Status             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand              : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

      -- common
		trn_clk                   : IN  std_logic;
		trn_reset_n               : IN  std_logic
		);
	END COMPONENT;

   -- tag RAM port A write request
   signal  tRAM_weB             : std_logic;
   signal  tRAM_addrB           : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
   signal  tRAM_dinB            : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);


begin

   eb_FIFO_we       <= eb_FIFO_we_i     ;
   eb_FIFO_wsof     <= eb_FIFO_wsof_i   ;
   eb_FIFO_weof     <= eb_FIFO_weof_i   ;
   eb_FIFO_din      <= eb_FIFO_din_i    ;


   eb_FIFO_we_i     <= eb_FIFO_we_MWr or eb_FIFO_we_CplD;
   eb_FIFO_wsof_i   <= eb_FIFO_wsof_CplD when eb_FIFO_we_CplD='1' else eb_FIFO_wsof_MWr;
   eb_FIFO_weof_i   <= eb_FIFO_weof_CplD when eb_FIFO_we_CplD='1' else eb_FIFO_weof_MWr;
   eb_FIFO_din_i    <= eb_FIFO_din_CplD  when eb_FIFO_we_CplD='1' else eb_FIFO_din_MWr;

   -- ------------------------------------------------
   -- Delay of Rx inputs
   -- ------------------------------------------------
    Rx_Input_Delays: 
    RxIn_Delay
    PORT MAP(
      -- Common ports
      trn_clk             =>  trn_clk           ,        -- IN  std_logic;
      trn_reset_n         =>  trn_reset_n       ,        -- IN  std_logic;
      trn_lnk_up_n        =>  trn_lnk_up_n      ,        -- IN  std_logic;

      -- Transaction receive interface
      trn_rsof_n          =>  trn_rsof_n        ,        -- IN  std_logic;
      trn_reof_n          =>  trn_reof_n        ,        -- IN  std_logic;
      trn_rd              =>  trn_rd            ,        -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n          =>  trn_rrem_n        ,        -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n       =>  trn_rerrfwd_n     ,        -- IN  std_logic;
      trn_rsrc_rdy_n      =>  trn_rsrc_rdy_n    ,        -- IN  std_logic;
      trn_rsrc_dsc_n      =>  trn_rsrc_dsc_n    ,        -- IN  std_logic;
      trn_rbar_hit_n      =>  trn_rbar_hit_n    ,        -- IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
      trn_rdst_rdy_n      =>  trn_rdst_rdy_n    ,        -- OUT std_logic;
      Pool_wrBuf_full     =>  DDR_wr_full       ,        -- IN  std_logic;
      Link_Buf_full       =>  Link_Buf_full     ,        -- IN  std_logic;

      -- Delayed
      trn_rsof_n_dly      =>  trn_rsof_n_dly    ,        -- OUT std_logic;
      trn_reof_n_dly      =>  trn_reof_n_dly    ,        -- OUT std_logic;
      trn_rd_dly          =>  trn_rd_dly        ,        -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n_dly      =>  trn_rrem_n_dly    ,        -- OUT std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n_dly   =>  trn_rerrfwd_n_dly ,        -- OUT std_logic;
      trn_rsrc_rdy_n_dly  =>  trn_rsrc_rdy_n_dly,        -- OUT std_logic;
      trn_rdst_rdy_n_dly  =>  trn_rdst_rdy_n_dly,        -- OUT std_logic;
      trn_rsrc_dsc_n_dly  =>  trn_rsrc_dsc_n_dly,        -- OUT std_logic;
      trn_rbar_hit_n_dly  =>  trn_rbar_hit_n_dly,        -- OUT std_logic_vector(C_BAR_NUMBER-1 downto 0);

      -- TLP resolution
      IORd_Type           =>  IORd_Type         ,        -- OUT std_logic;
      IOWr_Type           =>  IOWr_Type         ,        -- OUT std_logic;
      MRd_Type            =>  MRd_Type          ,        -- OUT std_logic_vector(3 downto 0);
      MWr_Type            =>  MWr_Type          ,        -- OUT std_logic_vector(1 downto 0);
      CplD_Type           =>  CplD_Type         ,        -- OUT std_logic_vector(3 downto 0);

      -- From Cpl/D channel
      usDMA_dex_Tag       =>  usDMA_dex_Tag     ,        -- IN  std_logic_vector(7 downto 0);
      dsDMA_dex_Tag       =>  dsDMA_dex_Tag     ,        -- IN  std_logic_vector(7 downto 0);

      -- To Memory request process modules
      Tlp_straddles_4KB   =>  Tlp_straddles_4KB ,        -- OUT std_logic;

      -- To Cpl/D channel
      Tlp_has_4KB         =>  Tlp_has_4KB       ,        -- OUT std_logic;
      Tlp_has_1DW         =>  Tlp_has_1DW       ,        -- OUT std_logic;
      CplD_is_the_Last    =>  CplD_is_the_Last  ,        -- OUT std_logic;
      CplD_on_Pool        =>  CplD_on_Pool      ,        -- OUT std_logic;
      CplD_on_EB          =>  CplD_on_EB        ,        -- OUT std_logic;
      Req_ID_Match        =>  Req_ID_Match      ,        -- OUT std_logic;
      usDex_Tag_Matched   =>  usDex_Tag_Matched ,        -- OUT std_logic;
      dsDex_Tag_Matched   =>  dsDex_Tag_Matched ,        -- OUT std_logic;
      CplD_Tag            =>  CplD_Tag          ,        -- OUT std_logic_vector(7 downto  0);

      -- Additional
      cfg_dcommand        =>  cfg_dcommand      ,        -- IN  std_logic_vector(16-1 downto 0)
      localID             =>  localID                    -- IN  std_logic_vector(15 downto 0)
    );


  -- ------------------------------------------------
  -- Processing MRd Requests
  -- ------------------------------------------------
   MRd_Channel: 
   rx_MRd_Transact 
   PORT MAP(
      -- 
      trn_rsof_n          =>  trn_rsof_n_dly,            -- IN  std_logic;
      trn_reof_n          =>  trn_reof_n_dly,            -- IN  std_logic;
      trn_rd              =>  trn_rd_dly,                -- IN  std_logic_vector(31 downto 0);
      trn_rrem_n          =>  trn_rrem_n_dly,            -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n       =>  trn_rerrfwd_n_dly,         -- IN  std_logic;
      trn_rsrc_rdy_n      =>  trn_rsrc_rdy_n_dly,        -- IN  std_logic;
      trn_rsrc_dsc_n      =>  trn_rsrc_dsc_n_dly,        -- IN  std_logic;
      trn_rbar_hit_n      =>  trn_rbar_hit_n_dly,        -- IN  std_logic_vector(6 downto 0);
--      trn_rdst_rdy_n      =>  open,  -- trn_rdst_rdy_n_MRd,            -- OUT std_logic;
		trn_rnp_ok_n        =>  trn_rnp_ok_n,              -- OUT std_logic;

      IORd_Type           =>  IORd_Type         ,        -- IN  std_logic;
      MRd_Type            =>  MRd_Type          ,        -- IN  std_logic_vector(3 downto 0);
      Tlp_straddles_4KB   =>  Tlp_straddles_4KB ,        -- IN  std_logic;

      pioCplD_RE          =>  pioCplD_RE,                -- IN  std_logic;
      pioCplD_Req         =>  pioCplD_Req,               -- OUT std_logic;
      pioCplD_Qout        =>  pioCplD_Qout,              -- OUT std_logic_vector(127 downto 0);
      pio_FC_stop         =>  pio_FC_stop,               -- IN  std_logic;

      FIFO_Empty          =>  eb_FIFO_Empty,                -- IN  std_logic;
      FIFO_Reading        =>  eb_FIFO_Reading,              -- IN  std_logic;
      pio_reading_status  =>  pio_reading_status,           -- OUT std_logic; 

      Channel_Rst         =>  MRd_Channel_Rst,           -- IN  std_logic;
                                                   
      trn_clk             =>  trn_clk,                   -- IN  std_logic;
      trn_reset_n         =>  trn_reset_n,               -- IN  std_logic;
      trn_lnk_up_n        =>  trn_lnk_up_n               -- IN  std_logic;
	);


  -- ------------------------------------------------
  -- Processing MWr Requests
  -- ------------------------------------------------
   MWr_Channel: 
   rx_MWr_Transact 
   PORT MAP(
      --
      trn_rsof_n          =>  trn_rsof_n_dly,            -- IN  std_logic;
      trn_reof_n          =>  trn_reof_n_dly,            -- IN  std_logic;
      trn_rd              =>  trn_rd_dly,                -- IN  std_logic_vector(31 downto 0);
      trn_rrem_n          =>  trn_rrem_n_dly,            -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n       =>  trn_rerrfwd_n_dly ,        -- IN  std_logic;
      trn_rsrc_rdy_n      =>  trn_rsrc_rdy_n_dly,        -- IN  std_logic;
      trn_rdst_rdy_n      =>  trn_rdst_rdy_n_dly,        -- IN  std_logic;
      trn_rsrc_dsc_n      =>  trn_rsrc_dsc_n_dly,        -- IN  std_logic;
      trn_rbar_hit_n      =>  trn_rbar_hit_n_dly,        -- IN  std_logic_vector(6 downto 0);

      IOWr_Type           =>  IOWr_Type         ,        -- OUT std_logic;
      MWr_Type            =>  MWr_Type          ,        -- IN  std_logic_vector(1 downto 0);
      Tlp_straddles_4KB   =>  Tlp_straddles_4KB ,        -- IN  std_logic;
      Tlp_has_4KB         =>  Tlp_has_4KB       ,        -- IN  std_logic;


      -- Event Buffer write port
      eb_FIFO_we          =>  eb_FIFO_we_MWr    ,        -- OUT std_logic;
      eb_FIFO_wsof        =>  eb_FIFO_wsof_MWr  ,        -- OUT std_logic;
      eb_FIFO_weof        =>  eb_FIFO_weof_MWr  ,        -- OUT std_logic;
      eb_FIFO_din         =>  eb_FIFO_din_MWr   ,        -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- To registers module                          
      Regs_WrEn           =>  Regs_WrEn0     ,           -- OUT std_logic;
      Regs_WrMask         =>  Regs_WrMask0   ,           -- OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr         =>  Regs_WrAddr0   ,           -- OUT std_logic_vector(16-1 downto 0);
      Regs_WrDin          =>  Regs_WrDin0    ,           -- OUT std_logic_vector(32-1 downto 0);

      -- DDR write port
      DDR_wr_sof          =>  DDR_wr_sof_A   ,  --        OUT   std_logic;
      DDR_wr_eof          =>  DDR_wr_eof_A   ,  --        OUT   std_logic;
      DDR_wr_v            =>  DDR_wr_v_A     ,  --        OUT   std_logic;
      DDR_wr_FA           =>  DDR_wr_FA_A    ,  --        OUT   std_logic;
      DDR_wr_Shift        =>  DDR_wr_Shift_A ,  --        OUT   std_logic;
      DDR_wr_din          =>  DDR_wr_din_A   ,  --        OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_Mask         =>  DDR_wr_Mask_A  ,  --        OUT   std_logic_vector(2-1 downto 0);
      DDR_wr_full         =>  DDR_wr_full    ,  --        IN    std_logic;

      -- Data generator table write
      tab_we              =>  tab_we ,  -- OUT std_logic_vector(2-1 downto 0);
      tab_wa              =>  tab_wa ,  -- OUT std_logic_vector(12-1 downto 0);
      tab_wd              =>  tab_wd ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Common
      trn_clk             =>  trn_clk        ,  --        IN  std_logic;
      trn_reset_n         =>  trn_reset_n    ,  --        IN  std_logic;
      trn_lnk_up_n        =>  trn_lnk_up_n      --        IN  std_logic;
	);


  -- --------------------------------------------------- 
  -- Processing Completions
  -- --------------------------------------------------- 
   CplD_Channel: 
   rx_CplD_Transact 
   PORT MAP(
      --
      trn_rsof_n          =>  trn_rsof_n_dly,            -- IN  std_logic;
      trn_reof_n          =>  trn_reof_n_dly,            -- IN  std_logic;
      trn_rd              =>  trn_rd_dly,                -- IN  std_logic_vector(31 downto 0);
      trn_rrem_n          =>  trn_rrem_n_dly,            -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n       =>  trn_rerrfwd_n_dly,         -- IN  std_logic;
      trn_rsrc_rdy_n      =>  trn_rsrc_rdy_n_dly,        -- IN  std_logic;
      trn_rdst_rdy_n      =>  trn_rdst_rdy_n_dly,        -- IN  std_logic;
      trn_rsrc_dsc_n      =>  trn_rsrc_dsc_n_dly,        -- IN  std_logic;
      trn_rbar_hit_n      =>  trn_rbar_hit_n_dly,        -- IN  std_logic_vector(6 downto 0);

      CplD_Type           =>  CplD_Type,                 -- IN  std_logic_vector(3 downto 0);

      Req_ID_Match        =>  Req_ID_Match,              -- IN  std_logic;
      usDex_Tag_Matched   =>  usDex_Tag_Matched,         -- IN  std_logic;
      dsDex_Tag_Matched   =>  dsDex_Tag_Matched,         -- IN  std_logic;

      Tlp_has_4KB         =>  Tlp_has_4KB     ,          -- IN  std_logic;
      Tlp_has_1DW         =>  Tlp_has_1DW     ,          -- IN  std_logic;
      CplD_is_the_Last    =>  CplD_is_the_Last,          -- IN  std_logic;
      CplD_on_Pool        =>  CplD_on_Pool    ,          -- IN  std_logic;
      CplD_on_EB          =>  CplD_on_EB      ,          -- IN  std_logic;
      CplD_Tag            =>  CplD_Tag,                  -- IN  std_logic_vector( 7 downto  0);
      FC_pop              =>  FC_pop,                    -- OUT std_logic;


      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add    =>  ds_DMA_Bytes_Add,          -- OUT std_logic;
      ds_DMA_Bytes        =>  ds_DMA_Bytes    ,          -- OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- Downstream tRAM port A write request
      tRAM_weB            =>  tRAM_weB,                  -- IN  std_logic;
      tRAM_addrB          =>  tRAM_addrB,                -- IN  std_logic_vector( 6 downto 0);
      tRAM_dinB           =>  tRAM_dinB,                 -- IN  std_logic_vector(47 downto 0);

      -- Downstream channel descriptor tag 
      dsDMA_dex_Tag       =>  dsDMA_dex_Tag,             -- OUT std_logic_vector( 7 downto 0);

      -- Downstream Tag Map Signal for Busy/Done
      Tag_Map_Clear       =>  Tag_Map_Clear,             -- OUT std_logic_vector(127 downto 0);

      -- Upstream channel descriptor tag 
      usDMA_dex_Tag       =>  usDMA_dex_Tag,             -- OUT std_logic_vector( 7 downto 0);


      -- Event Buffer write port
      eb_FIFO_we          =>  eb_FIFO_we_CplD   ,        -- OUT std_logic;
      eb_FIFO_wsof        =>  eb_FIFO_wsof_CplD ,        -- OUT std_logic;
      eb_FIFO_weof        =>  eb_FIFO_weof_CplD ,        -- OUT std_logic;
      eb_FIFO_din         =>  eb_FIFO_din_CplD  ,        -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- To registers module
      Regs_WrEn           =>  Regs_WrEn1,                -- OUT std_logic;
      Regs_WrMask         =>  Regs_WrMask1,              -- OUT std_logic_vector(2-1 downto 0);
      Regs_WrAddr         =>  Regs_WrAddr1,              -- OUT std_logic_vector(16-1 downto 0);
      Regs_WrDin          =>  Regs_WrDin1,               -- OUT std_logic_vector(32-1 downto 0);

      -- DDR write port
      DDR_wr_sof          =>  DDR_wr_sof_B   ,  --        OUT   std_logic;
      DDR_wr_eof          =>  DDR_wr_eof_B   ,  --        OUT   std_logic;
      DDR_wr_v            =>  DDR_wr_v_B     ,  --        OUT   std_logic;
      DDR_wr_FA           =>  DDR_wr_FA_B    ,  --        OUT   std_logic;
      DDR_wr_Shift        =>  DDR_wr_Shift_B ,  --        OUT   std_logic;
      DDR_wr_Mask         =>  DDR_wr_Mask_B  ,  --        OUT   std_logic_vector(2-1 downto 0);
      DDR_wr_din          =>  DDR_wr_din_B   ,  --        OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full         =>  DDR_wr_full    ,  --        IN    std_logic;


      -- Common
      trn_clk             =>  trn_clk,                   -- IN std_logic;
      trn_reset_n         =>  trn_reset_n,               -- IN std_logic;
      trn_lnk_up_n        =>  trn_lnk_up_n               -- IN std_logic;
	);


  -- ------------------------------------------------
  -- Processing upstream DMA Requests
  -- ------------------------------------------------
   Upstream_DMA_Engine: 
   usDMA_Transact 
   PORT MAP(
      -- TLP buffer
      usTlp_RE            =>  usTlp_RE,                 -- IN std_logic;
      usTlp_Req           =>  usTlp_Req,                -- OUT std_logic;
      usTlp_Qout          =>  usTlp_Qout,               -- OUT std_logic_vector(127 downto 0)

      FIFO_Data_Count     =>  eb_FIFO_data_count,          -- IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      FIFO_Empty          =>  eb_FIFO_Empty,               -- IN  std_logic;
      FIFO_Reading        =>  eb_FIFO_Reading,             -- IN  std_logic;

      -- upstream Control Signals from MWr Channel
      usDMA_Start         =>  usDMA_Start,              -- IN  std_logic;
      usDMA_Stop          =>  usDMA_Stop,               -- IN  std_logic;

      -- Upstream Control Signals from CplD Channel
      usDMA_Start2        =>  usDMA_Start2,             -- IN  std_logic;
      usDMA_Stop2         =>  usDMA_Stop2,              -- IN  std_logic;

      DMA_Cmd_Ack         =>  usDMA_Cmd_Ack,            -- OUT std_logic;
      usDMA_Channel_Rst   =>  usDMA_Channel_Rst,        -- IN  std_logic;
      us_FC_stop          =>  us_FC_stop,               -- IN  std_logic;
      us_Last_sof         =>  us_Last_sof,              -- IN  std_logic;
      us_Last_eof         =>  us_Last_eof,              -- IN  std_logic;

      -- To Interrupt module
      DMA_Done            =>  DMA_us_Done,              -- OUT std_logic;
      DMA_TimeOut         =>  DMA_us_Tout,              -- OUT std_logic;
      DMA_Busy            =>  DMA_us_Busy,              -- OUT std_logic;

      -- To Tx channel
      DMA_us_Status       =>  DMA_us_Status,            -- OUT std_logic_vector(31 downto 0);

      -- upstream Registers
      DMA_us_PA           =>  DMA_us_PA,                -- IN  std_logic_vector(63 downto 0);
      DMA_us_HA           =>  DMA_us_HA,                -- IN  std_logic_vector(63 downto 0);
      DMA_us_BDA          =>  DMA_us_BDA,               -- IN  std_logic_vector(63 downto 0);
      DMA_us_Length       =>  DMA_us_Length,            -- IN  std_logic_vector(31 downto 0);
      DMA_us_Control      =>  DMA_us_Control,           -- IN  std_logic_vector(31 downto 0);
      usDMA_BDA_eq_Null   =>  usDMA_BDA_eq_Null,        -- IN  std_logic;
      us_MWr_Param_Vec    =>  us_MWr_Param_Vec,         -- IN  std_logic_vector(5 downto 0);

      -- Calculation in advance, for better timing
      usHA_is_64b         =>  usHA_is_64b          ,    -- IN  std_logic;
      usBDA_is_64b        =>  usBDA_is_64b         ,    -- IN  std_logic;

      usLeng_Hi19b_True   =>  usLeng_Hi19b_True    ,    --  IN  std_logic;
      usLeng_Lo7b_True    =>  usLeng_Lo7b_True     ,    --  IN  std_logic;

      usDMA_dex_Tag       =>  usDMA_dex_Tag        ,    -- OUT std_logic_vector( 7 downto 0);

      cfg_dcommand        =>  cfg_dcommand         ,    -- IN  std_logic_vector(16-1 downto 0)

      trn_clk             =>  trn_clk              ,    -- IN std_logic;
      trn_reset_n         =>  trn_reset_n               -- IN std_logic;
	);


  -- ------------------------------------------------
  -- Processing downstream DMA Requests
  -- ------------------------------------------------
   Downstream_DMA_Engine: 
   dsDMA_Transact 
   PORT MAP(
      -- Downstream tRAM port A write request
      tRAM_weB            =>  tRAM_weB,                 -- OUT std_logic;
      tRAM_addrB          =>  tRAM_addrB,               -- OUT std_logic_vector( 6 downto 0);
      tRAM_dinB           =>  tRAM_dinB,                -- OUT std_logic_vector(47 downto 0);

      -- TLP buffer
      MRd_dsp_RE          =>  dsMRd_RE,                 -- IN std_logic;
      MRd_dsp_Req         =>  dsMRd_Req,                -- OUT std_logic;
      MRd_dsp_Qout        =>  dsMRd_Qout,               -- OUT std_logic_vector(127 downto 0);

      -- Downstream Registers
      DMA_ds_PA           =>  DMA_ds_PA,                -- IN  std_logic_vector(63 downto 0);
      DMA_ds_HA           =>  DMA_ds_HA,                -- IN  std_logic_vector(63 downto 0);
      DMA_ds_BDA          =>  DMA_ds_BDA,               -- IN  std_logic_vector(63 downto 0);
      DMA_ds_Length       =>  DMA_ds_Length,            -- IN  std_logic_vector(31 downto 0);
      DMA_ds_Control      =>  DMA_ds_Control,           -- IN  std_logic_vector(31 downto 0);
      dsDMA_BDA_eq_Null   =>  dsDMA_BDA_eq_Null,        -- IN  std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b         =>  dsHA_is_64b          ,    -- IN  std_logic;
      dsBDA_is_64b        =>  dsBDA_is_64b         ,    -- IN  std_logic;

      dsLeng_Hi19b_True   =>  dsLeng_Hi19b_True    ,    -- IN  std_logic;
      dsLeng_Lo7b_True    =>  dsLeng_Lo7b_True     ,    -- IN  std_logic;

      -- Downstream Control Signals from MWr Channel
      dsDMA_Start         =>  dsDMA_Start,              -- IN  std_logic;
      dsDMA_Stop          =>  dsDMA_Stop,               -- IN  std_logic;

      -- Downstream Control Signals from CplD Channel
      dsDMA_Start2        =>  dsDMA_Start2,             -- IN  std_logic;
      dsDMA_Stop2         =>  dsDMA_Stop2,              -- IN  std_logic;

      DMA_Cmd_Ack         =>  dsDMA_Cmd_Ack,            -- OUT std_logic;
      dsDMA_Channel_Rst   =>  dsDMA_Channel_Rst,        -- IN  std_logic;

      -- Downstream Handshake Signals with CplD Channel for Busy/Done
      Tag_Map_Clear       =>  Tag_Map_Clear,            -- IN  std_logic_vector(127 downto 0);

      FC_pop              =>  FC_pop,                   -- IN  std_logic;

      -- To Interrupt module
      DMA_Done            =>  DMA_ds_Done,              -- OUT std_logic;
      DMA_TimeOut         =>  DMA_ds_Tout,              -- OUT std_logic;
      DMA_Busy            =>  DMA_ds_Busy,              -- OUT std_logic;

      -- To Tx channel
      DMA_ds_Status       =>  DMA_ds_Status,            -- OUT std_logic_vector(31 downto 0);

      -- tag for descriptor
      dsDMA_dex_Tag       =>  dsDMA_dex_Tag,            -- IN  std_logic_vector( 7 downto 0);

      -- Additional
      cfg_dcommand        =>  cfg_dcommand ,            -- IN  std_logic_vector(16-1 downto 0)

      -- common
      trn_clk             =>  trn_clk      ,            -- IN std_logic;
      trn_reset_n         =>  trn_reset_n               -- IN std_logic;
	);


  -- ------------------------------------------------
  --   Interrupts generation
  -- ------------------------------------------------
   Intrpt_Handle:
   Interrupts
   PORT MAP(
      Sys_IRQ                 => Sys_IRQ                 ,  -- IN  std_logic_vector(31 downto 0);

      -- Interrupt generator signals
      IG_Reset                => IG_Reset                ,  -- IN  std_logic;
      IG_Host_Clear           => IG_Host_Clear           ,  -- IN  std_logic;
      IG_Latency              => IG_Latency              ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Assert           => IG_Num_Assert           ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Num_Deassert         => IG_Num_Deassert         ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
      IG_Asserting            => IG_Asserting            ,  -- OUT std_logic;

      -- cfg interface
      cfg_interrupt_n         => cfg_interrupt_n         ,  -- OUT std_logic;
      cfg_interrupt_rdy_n     => cfg_interrupt_rdy_n     ,  -- IN  std_logic;
      cfg_interrupt_mmenable  => cfg_interrupt_mmenable  ,  -- IN  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable => cfg_interrupt_msienable ,  -- IN  std_logic;
      cfg_interrupt_di        => cfg_interrupt_di        ,  -- OUT std_logic_vector(7 downto 0);
      cfg_interrupt_do        => cfg_interrupt_do        ,  -- IN  std_logic_vector(7 downto 0);
      cfg_interrupt_assert_n  => cfg_interrupt_assert_n  ,  -- OUT std_logic;

      -- Irpt Channel
      Irpt_Req                => Irpt_Req                ,  -- OUT std_logic;
      Irpt_RE                 => Irpt_RE                 ,  -- IN  std_logic;
      Irpt_Qout               => Irpt_Qout               ,  -- OUT std_logic_vector(127 downto 0);

      trn_clk                 => trn_clk                 ,  -- IN  std_logic;
      trn_reset_n             => trn_reset_n                -- IN  std_logic
      );


end architecture Behavioral;
