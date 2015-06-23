----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    Regs_Group - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- 
-- Revision 1.00 - first release.  06.02.2007
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Regs_Group is
    port (

--      -- DCB protocol interface
--      protocol_link_act        : IN  std_logic_vector(2-1 downto 0);
--      protocol_rst             : OUT std_logic;
--
--      -- Fabric side: CTL Rx
--      ctl_rv                   : OUT std_logic;
--      ctl_rd                   : OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
--
--      -- Fabric side: CTL Tx
--      ctl_ttake                : OUT std_logic;
--      ctl_tv                   : IN  std_logic;
--      ctl_td                   : IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
--      ctl_tstop                : OUT std_logic;
--
--      ctl_reset                : OUT std_logic;
--      ctl_status               : IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
--
--      -- Fabric side: DLM Rx
--      dlm_tv                   : OUT std_logic;
--      dlm_td                   : OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
--
--      -- Fabric side: DLM Tx
--      dlm_rv                   : IN  std_logic;
--      dlm_rd                   : IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- Event Buffer status + reset
      eb_FIFO_Status           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      eb_FIFO_Rst              : OUT std_logic;
      eb_FIFO_ow               : IN  std_logic;

      self_feed_daq            : OUT std_logic;

      -- Write interface
      Regs_WrEnA               : IN  std_logic;
      Regs_WrMaskA             : IN  std_logic_vector(2-1 downto 0);
      Regs_WrAddrA             : IN  std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDinA              : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      Regs_WrEnB               : IN  std_logic;
      Regs_WrMaskB             : IN  std_logic_vector(2-1 downto 0);
      Regs_WrAddrB             : IN  std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDinB              : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Register Read interface
      Regs_RdAddr              : IN  std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_RdQout              : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add         : IN  std_logic;
      ds_DMA_Bytes             : IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

     -- Registers to/from Downstream Engine
      DMA_ds_PA                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length            : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control           : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null        : OUT std_logic;      -- obsolete
      DMA_ds_Status            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Done              : IN  std_logic;
      DMA_ds_Tout              : IN  std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b              : OUT std_logic;
      dsBDA_is_64b             : OUT std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True        : OUT std_logic;
      dsLeng_Lo7b_True         : OUT std_logic;

      -- Downstream Control Signals
      dsDMA_Start              : OUT std_logic;
      dsDMA_Stop               : OUT std_logic;
      dsDMA_Start2             : OUT std_logic;
      dsDMA_Stop2              : OUT std_logic;
      dsDMA_Channel_Rst        : OUT std_logic;
      dsDMA_Cmd_Ack            : IN  std_logic;


      -- Upstream DMA transferred bytes count up
      us_DMA_Bytes_Add         : IN  std_logic;
      us_DMA_Bytes             : IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- Registers to/from Upstream Engine
      DMA_us_PA                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA                : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length            : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control           : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null        : OUT std_logic;      -- obsolete
      us_MWr_Param_Vec         : OUT std_logic_vector(6-1 downto 0);
      DMA_us_Status            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Done              : IN  std_logic;
      DMA_us_Tout              : IN  std_logic;

      -- Calculation in advance, for better timing
      usHA_is_64b              : OUT std_logic;
      usBDA_is_64b             : OUT std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True        : OUT std_logic;
      usLeng_Lo7b_True         : OUT std_logic;

      -- Upstream Control Signals
      usDMA_Start              : OUT std_logic;
      usDMA_Stop               : OUT std_logic;
      usDMA_Start2             : OUT std_logic;
      usDMA_Stop2              : OUT std_logic;
      usDMA_Channel_Rst        : OUT std_logic;
      usDMA_Cmd_Ack            : IN  std_logic;

      -- MRd Channel Reset
      MRd_Channel_Rst          : OUT std_logic;

      -- Tx module reset
      Tx_Reset                 : OUT std_logic;

		-- to Interrupts Module
      Sys_IRQ                  : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      DAQ_irq                  : IN  std_logic;
--      CTL_irq                  : IN  std_logic;
--      DLM_irq                  : IN  std_logic;

      -- System error and info
      Tx_TimeOut               : IN  std_logic;
      Tx_eb_TimeOut            : IN  std_logic;
      Msg_Routing              : OUT std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);
      pcie_link_width          : IN  std_logic_vector(CINT_BIT_LWIDTH_IN_GSR_TOP-CINT_BIT_LWIDTH_IN_GSR_BOT downto 0);
      cfg_dcommand             : IN  std_logic_vector(16-1 downto 0);

      -- Interrupt Generation Signals
      IG_Reset                 : OUT std_logic;
      IG_Host_Clear            : OUT std_logic;
      IG_Latency               : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Assert            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Deassert          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Asserting             : IN  std_logic;

--      -- Data generator control
--      DG_is_Running            : IN  std_logic;
--      DG_Reset                 : OUT std_logic;
--      DG_Mask                  : OUT std_logic;

      -- Clock and reset
      trn_clk                  : IN  std_logic;
      trn_lnk_up_n             : IN  std_logic;
      trn_reset_n              : IN  std_logic

    );
end Regs_Group;


architecture Behavioral of Regs_Group is

  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  signal  Regs_WrDin_i         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  Regs_WrAddr_i        : std_logic_vector(C_EP_AWIDTH-1   downto 0);
  signal  Regs_WrMask_i        : std_logic_vector(2-1   downto 0);

  ------  Delay signals
  signal  Regs_WrEn_r1         : std_logic;
  signal  Regs_WrAddr_r1       : std_logic_vector(C_EP_AWIDTH-1   downto 0);
  signal  Regs_WrMask_r1       : std_logic_vector(2-1   downto 0);
  signal  Regs_WrDin_r1        : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  Regs_WrEn_r2         : std_logic;
  signal  Regs_WrDin_r2        : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  Regs_Wr_dma_V_hi_r2     : std_logic;
  signal  Regs_Wr_dma_nV_hi_r2    : std_logic;
  signal  Regs_Wr_dma_V_nE_hi_r2  : std_logic;
  signal  Regs_Wr_dma_V_lo_r2     : std_logic;
  signal  Regs_Wr_dma_nV_lo_r2    : std_logic;
  signal  Regs_Wr_dma_V_nE_lo_r2  : std_logic;
  signal  WrDin_r1_not_Zero_Hi    : std_logic_vector(4-1 downto 0);
  signal  WrDin_r2_not_Zero_Hi    : std_logic;
  signal  WrDin_r1_not_Zero_Lo    : std_logic_vector(4-1 downto 0);
  signal  WrDin_r2_not_Zero_Lo    : std_logic;

  --      Calculation in advance, just for better timing 
  signal  Regs_WrDin_Hi19b_True_hq_r2 : std_logic;
  signal  Regs_WrDin_Lo7b_True_hq_r2  : std_logic;
  signal  Regs_WrDin_Hi19b_True_lq_r2 : std_logic;
  signal  Regs_WrDin_Lo7b_True_lq_r2  : std_logic;

  signal  Regs_WrEnA_r1           : std_logic;
  signal  Regs_WrEnB_r1           : std_logic;
  signal  Regs_WrEnA_r2           : std_logic;
  signal  Regs_WrEnB_r2           : std_logic;

  --      Register write mux signals
  signal  Reg_WrMuxer_Hi          : std_logic_vector(C_NUM_OF_ADDRESSES-1 downto 0);
  signal  Reg_WrMuxer_Lo          : std_logic_vector(C_NUM_OF_ADDRESSES-1 downto 0);


  -- Signals for Tx reading
  signal  Regs_RdAddr_i           : std_logic_vector(C_EP_AWIDTH-1   downto 0);
  signal  Regs_RdQout_i           : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  --      Register read mux signals
  signal  Reg_RdMuxer_Hi          : std_logic_vector(C_NUM_OF_ADDRESSES-1 downto 0);
  signal  Reg_RdMuxer_Lo          : std_logic_vector(C_NUM_OF_ADDRESSES-1 downto 0);

--  -- Optical Link status
--  signal  Opto_Link_Status_i      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--  signal  Opto_Link_Status_o_Hi   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--  signal  Opto_Link_Status_o_Lo   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  -- Event Buffer
  signal  eb_FIFO_Status_r1       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  eb_FIFO_Status_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  eb_FIFO_Status_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  eb_FIFO_Rst_i           : std_logic;
  signal  eb_FIFO_Rst_b1          : std_logic;
  signal  eb_FIFO_Rst_b2          : std_logic;
  signal  eb_FIFO_Rst_b3          : std_logic;
  signal  eb_FIFO_OverWritten     : std_logic;

  -- Downstream DMA registers
  signal  DMA_ds_PA_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_HA_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_BDA_o_Hi         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Length_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Control_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Status_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Transf_Bytes_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_PA_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_HA_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_BDA_o_Lo         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Length_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Control_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Status_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Transf_Bytes_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Upstream DMA registers
  signal  DMA_us_PA_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_HA_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_BDA_o_Hi         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Length_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Control_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Status_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Transf_Bytes_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_PA_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_HA_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_BDA_o_Lo         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Length_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Control_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Status_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Transf_Bytes_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);


  -- System Interrupt Status/Control
  signal  Sys_IRQ_i               : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  Sys_Int_Status_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  Sys_Int_Status_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  Sys_Int_Status_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  Sys_Int_Enable_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  Sys_Int_Enable_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  Sys_Int_Enable_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);


--  -- Data generator control
--  signal  DG_Reset_i              : std_logic;
--  signal  DG_Mask_i               : std_logic;
--  signal  DG_is_Available         : std_logic;
--  signal  DG_Rst_Counter          : std_logic_vector(8-1 downto 0);
--  signal  DG_Status_i             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--  signal  DG_Status_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--  signal  DG_Status_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- General Control and Status
  signal  Sys_Error_i             : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  Sys_Error_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  Sys_Error_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  signal  General_Control_i       : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  General_Control_o_Hi    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  General_Control_o_Lo    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  signal  General_Status_i        : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  General_Status_o_Hi     : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  General_Status_o_Lo     : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Hardward version
  signal  HW_Version_o_Hi         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  HW_Version_o_Lo         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Signal as the source of interrupts
  signal  IG_Host_Clear_i         : std_logic;
  signal  IG_Reset_i              : std_logic;

  -- Interrupt Generator Control
  signal  IG_Control_i            : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Interrupt Generator Latency
  signal  IG_Latency_i            : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Latency_o_Hi         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Latency_o_Lo         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Interrupt Generator Statistic: Assert number
  signal  IG_Num_Assert_i         : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Num_Assert_o_Hi      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Num_Assert_o_Lo      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Interrupt Generator Statistic: Deassert number
  signal  IG_Num_Deassert_i       : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Num_Deassert_o_Hi    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  IG_Num_Deassert_o_Lo    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- IntClr character is written
  signal  Command_is_Host_iClr_Hi : std_logic;
  signal  Command_is_Host_iClr_Lo : std_logic;

  -- Downstream Registers
  signal  DMA_ds_PA_i          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_HA_i          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_BDA_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_ds_Length_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_ds_Control_i     : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_ds_Status_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_ds_Transf_Bytes_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  signal  Last_Ctrl_Word_ds    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Calculation in advance, for better timing
  signal  dsHA_is_64b_i        : std_logic;
  signal  dsBDA_is_64b_i       : std_logic;

  -- Calculation in advance, for better timing
  signal  dsLeng_Hi19b_True_i  : std_logic;
  signal  dsLeng_Lo7b_True_i   : std_logic;

  -- Downstream Control Signals
  signal  dsDMA_Start_i        : std_logic;
  signal  dsDMA_Stop_i         : std_logic;
  signal  dsDMA_Start2_i       : std_logic;
  signal  dsDMA_Start2_r1      : std_logic;
  signal  dsDMA_Stop2_i        : std_logic;
  signal  dsDMA_Channel_Rst_i  : std_logic;
  signal  ds_Param_Modified    : std_logic;


  -- Upstream Registers
  signal  DMA_us_PA_i          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_HA_i          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_BDA_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_us_Length_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_us_Control_i     : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_us_Status_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal  DMA_us_Transf_Bytes_i      : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  signal  Last_Ctrl_Word_us    : std_logic_vector(C_DBUS_WIDTH-1   downto 0);

  -- Calculation in advance, for better timing
  signal  usHA_is_64b_i        : std_logic;
  signal  usBDA_is_64b_i       : std_logic;

  -- Calculation in advance, for better timing
  signal  usLeng_Hi19b_True_i  : std_logic;
  signal  usLeng_Lo7b_True_i   : std_logic;


  -- Upstream Control Signals
  signal  usDMA_Start_i        : std_logic;
  signal  usDMA_Stop_i         : std_logic;
  signal  usDMA_Start2_i       : std_logic;
  signal  usDMA_Start2_r1      : std_logic;
  signal  usDMA_Stop2_i        : std_logic;
  signal  usDMA_Channel_Rst_i  : std_logic;
  signal  us_Param_Modified    : std_logic;

  -- Reset character is written
  signal  Command_is_Reset_Hi  : std_logic;
  signal  Command_is_Reset_Lo  : std_logic;

  -- MRd channel reset
  signal  MRd_Channel_Rst_i    : std_logic;

  -- Tx module reset
  signal  Tx_Reset_i           : std_logic;


  -- ICAP
  signal  icap_CLK             : std_logic;
  signal  icap_I               : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  icap_CE              : std_logic;
  signal  icap_Write           : std_logic;
  signal  icap_O               : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  icap_O_o_Hi          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  icap_O_o_Lo          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  icap_BUSY            : std_logic;

  -- DCB protocol interface
  signal  protocol_rst_i       : std_logic;
  signal  protocol_rst_b1      : std_logic;
  signal  protocol_rst_b2      : std_logic;

  -- Protocol : CTL
  signal  ctl_rv_i             : std_logic;
  signal  ctl_rd_i             : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

  signal  class_CTL_Status_i   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  class_CTL_Status_o_Hi: std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  class_CTL_Status_o_Lo: std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  ctl_td_o_Hi          : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal  ctl_td_o_Lo          : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal  ctl_td_r             : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

  signal  ctl_reset_i          : std_logic;
  signal  ctl_ttake_i          : std_logic;
  signal  ctl_tstop_i          : std_logic;
  signal  ctl_t_read_Hi_r1     : std_logic;
  signal  ctl_t_read_Lo_r1     : std_logic;
  signal  CTL_read_counter     : std_logic_vector(6-1 downto 0);

  -- Protocol : DLM
  signal  dlm_tv_i             : std_logic;
  signal  dlm_td_i             : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

  signal  dlm_rd_o_Hi          : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal  dlm_rd_o_Lo          : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal  dlm_rd_r             : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

begin


--   DG_is_Available   <= '0';

--   -- protocol interface reset
--   protocol_rst         <= protocol_rst_i;
--
--   ctl_rv               <= ctl_rv_i;
--   ctl_rd               <= ctl_rd_i;
--
--   ctl_ttake            <= ctl_ttake_i;
--   ctl_tstop            <= ctl_tstop_i;
--   ctl_reset            <= ctl_reset_i;
--
--   ctl_tstop_i          <= '0';   -- ???
--
--   dlm_tv               <= dlm_tv_i;
--   dlm_td               <= dlm_td_i;

--   -- Data generator control
--   DG_Reset             <= DG_Reset_i;
--   DG_Mask              <= DG_Mask_i;

   -- Event buffer reset
   eb_FIFO_Rst          <= eb_FIFO_Rst_i;

   -- MRd channel reset
   MRd_Channel_Rst      <= MRd_Channel_Rst_i;

   -- Tx module reset
   Tx_Reset             <= Tx_Reset_i;

   -- Upstream DMA engine reset
   usDMA_Channel_Rst    <= usDMA_Channel_Rst_i;

   -- Downstream DMA engine reset
   dsDMA_Channel_Rst    <= dsDMA_Channel_Rst_i;


   -- Upstream DMA registers
   DMA_us_PA            <= DMA_us_PA_i;
   DMA_us_HA            <= DMA_us_HA_i;
   DMA_us_BDA           <= DMA_us_BDA_i;
   DMA_us_Length        <= DMA_us_Length_i;
   DMA_us_Control       <= DMA_us_Control_i;
   usDMA_BDA_eq_Null    <= '0';
   DMA_us_Status_i      <= DMA_us_Status;

   usHA_is_64b          <= usHA_is_64b_i;
   usBDA_is_64b         <= usBDA_is_64b_i;

   usLeng_Hi19b_True    <= usLeng_Hi19b_True_i;
   usLeng_Lo7b_True     <= usLeng_Lo7b_True_i;

   usDMA_Start          <= usDMA_Start_i;
   usDMA_Stop           <= usDMA_Stop_i;
   usDMA_Start2         <= usDMA_Start2_r1;
--   usDMA_Start2         <= usDMA_Start2_i;
   usDMA_Stop2          <= usDMA_Stop2_i;

   -- Downstream DMA registers
   DMA_ds_PA            <= DMA_ds_PA_i;
   DMA_ds_HA            <= DMA_ds_HA_i;
   DMA_ds_BDA           <= DMA_ds_BDA_i;
   DMA_ds_Length        <= DMA_ds_Length_i;
   DMA_ds_Control       <= DMA_ds_Control_i;
   dsDMA_BDA_eq_Null    <= '0';
   DMA_ds_Status_i      <= DMA_ds_Status;

   dsHA_is_64b          <= dsHA_is_64b_i;
   dsBDA_is_64b         <= dsBDA_is_64b_i;

   dsLeng_Hi19b_True    <= dsLeng_Hi19b_True_i;
   dsLeng_Lo7b_True     <= dsLeng_Lo7b_True_i;

   dsDMA_Start          <= dsDMA_Start_i;
   dsDMA_Stop           <= dsDMA_Stop_i;
   dsDMA_Start2         <= dsDMA_Start2_r1;
--   dsDMA_Start2         <= dsDMA_Start2_i;
   dsDMA_Stop2          <= dsDMA_Stop2_i;


   -- Register to Interrupt handler module
   Sys_IRQ              <= Sys_IRQ_i;

   -- Message routing method
   Msg_Routing          <= General_Control_i(C_GCR_MSG_ROUT_BIT_TOP downto C_GCR_MSG_ROUT_BIT_BOT);

   -- us_MWr_TLP_Param 
   us_MWr_Param_Vec     <= General_Control_i(13 downto 8);

   self_feed_daq        <= General_Control_i(16);


   -- -------------   Interrupt generator generation    ----------------------
   Gen_IG:  if IMP_INT_GENERATOR generate

   IG_Reset             <= IG_Reset_i;
   IG_Host_Clear        <= IG_Host_Clear_i;  -- and Sys_Int_Enable_i(CINT_BIT_INTGEN_IN_ISR);
   IG_Latency           <= IG_Latency_i;
   IG_Num_Assert_i      <= IG_Num_Assert;
   IG_Num_Deassert_i    <= IG_Num_Deassert;


-- -----------------------------------------------
-- Synchronous Registered: IG_Control_i
   SysReg_IntGen_Control:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         IG_Control_i          <= (OTHERS => '0');
         IG_Reset_i            <= '1';
         IG_Host_Clear_i       <= '0';

      elsif trn_clk'event and trn_clk = '1' then

        if Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Hi(CINT_ADDR_IG_CONTROL)='1' 
			 then
            IG_Control_i(32-1 downto 0)       <=  Regs_WrDin_r2(64-1 downto 32);
            IG_Reset_i         <=  Command_is_Reset_Hi;
            IG_Host_Clear_i    <=  Command_is_Host_iClr_Hi;
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Lo(CINT_ADDR_IG_CONTROL)='1' 
			 then
            IG_Control_i(32-1 downto 0)       <=  Regs_WrDin_r2(32-1 downto 0);
            IG_Reset_i         <=  Command_is_Reset_Lo;
            IG_Host_Clear_i    <=  Command_is_Host_iClr_Lo;
        else
            IG_Control_i       <=  IG_Control_i;
            IG_Reset_i         <=  '0';
            IG_Host_Clear_i    <=  '0';
        end if;

      end if;
   end process;


-- -----------------------------------------------
-- Synchronous Registered: IG_Latency_i
   SysReg_IntGen_Latency:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         IG_Latency_i       <= (OTHERS => '0');

      elsif trn_clk'event and trn_clk = '1' then

        if IG_Reset_i='1' then
            IG_Latency_i    <=  (OTHERS => '0');
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Hi(CINT_ADDR_IG_LATENCY)='1' 
			 then
            IG_Latency_i(32-1 downto 0)    <=  Regs_WrDin_r2(64-1 downto 32);
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Lo(CINT_ADDR_IG_LATENCY)='1' 
			 then
            IG_Latency_i(32-1 downto 0)    <=  Regs_WrDin_r2(32-1 downto 0);
        else
            IG_Latency_i    <=  IG_Latency_i;
        end if;

      end if;
   end process;

   end generate;

   NotGen_IG:  if not IMP_INT_GENERATOR generate

   IG_Reset             <= '0';
   IG_Host_Clear        <= '0';
   IG_Latency           <= (OTHERS=>'0');
   IG_Num_Assert_i      <= (OTHERS=>'0');
   IG_Num_Deassert_i    <= (OTHERS=>'0');

   IG_Control_i         <= (OTHERS=>'0');
   IG_Reset_i           <= '0';
   IG_Host_Clear_i      <= '0';
   IG_Latency_i         <= (OTHERS=>'0');

   end generate;



-- ----------------------------------------------
-- Synchronous Delay : Sys_IRQ_i
-- 
   Synch_Delay_Sys_IRQ:
   process ( trn_clk, trn_lnk_up_n )
   begin
      if trn_lnk_up_n = '1' then
         Sys_IRQ_i   <=  (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then
         Sys_IRQ_i(C_NUM_OF_INTERRUPTS-1 downto 0)
                     <= Sys_Int_Enable_i(C_NUM_OF_INTERRUPTS-1 downto 0)
                    and Sys_Int_Status_i(C_NUM_OF_INTERRUPTS-1 downto 0);

      end if;
   end process;


-- ----------------------------------------------
-- Registers writing
-- 
   Regs_WrAddr_i        <= Regs_WrAddrA and Regs_WrAddrB;
   Regs_WrMask_i        <= Regs_WrMaskA or  Regs_WrMaskB;
   Regs_WrDin_i         <= Regs_WrDinA  or  Regs_WrDinB;

-- ----------------------------------------------
-- Registers reading
-- 
   Regs_RdAddr_i        <= Regs_RdAddr;
   Regs_RdQout          <= Regs_RdQout_i;

-- ----------------------------------------------
-- Synchronous Delay : Regs_WrEn
-- 
   Synch_Delay_Regs_WrEn:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         Regs_WrEn_r1   <= Regs_WrEnA or Regs_WrEnB;
         Regs_WrEn_r2   <= Regs_WrEn_r1;

         Regs_WrEnA_r1  <= Regs_WrEnA;
         Regs_WrEnA_r2  <= Regs_WrEnA_r1;

         Regs_WrEnB_r1  <= Regs_WrEnB;
         Regs_WrEnB_r2  <= Regs_WrEnB_r1;

      end if;
   end process;

---- ----------------------------------------------
---- Synchronous Delay : Opto_Link_Status
---- 
--   Synch_Delay_Opto_Link_Status:
--   process ( trn_clk )
--   begin
--      if trn_clk'event and trn_clk = '1' then
--         Opto_Link_Status_i(C_DBUS_WIDTH-1 downto 2)   <= (OTHERS=>'0');
--         Opto_Link_Status_i(2-1 downto 0)   <= protocol_link_act;
--      end if;
--   end process;

-- ----------------------------------------------
-- Synchronous Delay : eb_FIFO_Status
-- 
   Synch_Delay_eb_FIFO_Status:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         eb_FIFO_Status_r1   <= eb_FIFO_Status;
      end if;
   end process;

-- ----------------------------------------------
-- Synchronous Delay : Regs_WrAddr
-- 
   Synch_Delay_Regs_WrAddr:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         Regs_WrAddr_r1   <= Regs_WrAddr_i;
         Regs_WrMask_r1   <= Regs_WrMask_i;
      end if;
   end process;

-- ----------------------------------------------------
-- Synchronous Delay : dsDMA_Start2
--                     usDMA_Start2
--   (Special recipe for 64-bit successive descriptors)
-- 
   Synch_Delay_DMA_Start2:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         dsDMA_Start2_r1   <= dsDMA_Start2_i and not dsDMA_Cmd_Ack;
         usDMA_Start2_r1   <= usDMA_Start2_i and not usDMA_Cmd_Ack;
      end if;
   end process;


-- ----------------------------------------------
-- Synchronous Delay : Regs_WrDin_i
-- 
   Synch_Delay_Regs_WrDin:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         Regs_WrDin_r1   <= Regs_WrDin_i;
         Regs_WrDin_r2   <= Regs_WrDin_r1;

         if Regs_WrDin_i(31+32 downto 24+32) = C_ALL_ZEROS(31+32 downto 24+32) then
            WrDin_r1_not_Zero_Hi(3) <= '0';
         else
            WrDin_r1_not_Zero_Hi(3) <= '1';
         end if;
         if Regs_WrDin_i(23+32 downto 16+32) = C_ALL_ZEROS(23+32 downto 16+32) then
            WrDin_r1_not_Zero_Hi(2) <= '0';
         else
            WrDin_r1_not_Zero_Hi(2) <= '1';
         end if;
         if Regs_WrDin_i(15+32 downto 8+32) = C_ALL_ZEROS(15+32 downto 8+32) then
            WrDin_r1_not_Zero_Hi(1) <= '0';
         else
            WrDin_r1_not_Zero_Hi(1) <= '1';
         end if;
         if Regs_WrDin_i(7+32 downto 0+32) = C_ALL_ZEROS(7+32 downto 0+32) then
            WrDin_r1_not_Zero_Hi(0) <= '0';
         else
            WrDin_r1_not_Zero_Hi(0) <= '1';
         end if;

         if WrDin_r1_not_Zero_Hi = C_ALL_ZEROS(3 downto 0) then
            WrDin_r2_not_Zero_Hi <= '0';
         else
            WrDin_r2_not_Zero_Hi <= '1';
         end if;


         if Regs_WrDin_i(31 downto 24) = C_ALL_ZEROS(31 downto 24) then
            WrDin_r1_not_Zero_Lo(3) <= '0';
         else
            WrDin_r1_not_Zero_Lo(3) <= '1';
         end if;
         if Regs_WrDin_i(23 downto 16) = C_ALL_ZEROS(23 downto 16) then
            WrDin_r1_not_Zero_Lo(2) <= '0';
         else
            WrDin_r1_not_Zero_Lo(2) <= '1';
         end if;
         if Regs_WrDin_i(15 downto 8) = C_ALL_ZEROS(15 downto 8) then
            WrDin_r1_not_Zero_Lo(1) <= '0';
         else
            WrDin_r1_not_Zero_Lo(1) <= '1';
         end if;
         if Regs_WrDin_i(7 downto 0) = C_ALL_ZEROS(7 downto 0) then
            WrDin_r1_not_Zero_Lo(0) <= '0';
         else
            WrDin_r1_not_Zero_Lo(0) <= '1';
         end if;

         if WrDin_r1_not_Zero_Lo = C_ALL_ZEROS(3 downto 0) then
            WrDin_r2_not_Zero_Lo <= '0';
         else
            WrDin_r2_not_Zero_Lo <= '1';
         end if;
      end if;
   end process;


-- -----------------------------------------------------------
-- Synchronous Delay : DMA Commands Write Valid and not End
-- 
   Synch_Delay_dmaCmd_Wr_Valid_and_End:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         Regs_Wr_dma_V_hi_r2      <= Regs_WrEn_r1 
                               and Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID+32)
                               ;
         Regs_Wr_dma_nV_hi_r2     <= Regs_WrEn_r1 
                               and not Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID+32)
                               ;
         Regs_Wr_dma_V_nE_hi_r2   <= Regs_WrEn_r1 
                               and Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID+32)
                               and not Regs_WrDin_r1(CINT_BIT_DMA_CTRL_END+32)
                               ;


         Regs_Wr_dma_V_lo_r2      <= Regs_WrEn_r1 
                               and Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID)
                               ;
         Regs_Wr_dma_nV_lo_r2     <= Regs_WrEn_r1 
                               and not Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID)
                               ;
         Regs_Wr_dma_V_nE_lo_r2   <= Regs_WrEn_r1 
                               and Regs_WrDin_r1(CINT_BIT_DMA_CTRL_VALID)
                               and not Regs_WrDin_r1(CINT_BIT_DMA_CTRL_END)
                               ;
      end if;
   end process;



-- ------------------------------------------------
-- Synchronous Delay : Regs_WrDin_Hi19b_True_r2 x2
--                     Regs_WrDin_Lo7b_True_r2 x2
-- 
   Synch_Delay_Regs_WrDin_Hi19b_and_Lo7b_True:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then

         if Regs_WrDin_r1(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_TOP+1+32)
            = C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_TOP+1+32)
            then
            Regs_WrDin_Hi19b_True_hq_r2  <= '0';
         else
            Regs_WrDin_Hi19b_True_hq_r2  <= '1';
         end if;

         if Regs_WrDin_r1(C_MAXSIZE_FLD_BIT_BOT-1+32 downto 2+32)
            = C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_BOT-1+32 downto 2+32)
            then                               -- ! Lowest 2 bits ignored !
            Regs_WrDin_Lo7b_True_hq_r2  <= '0';
         else
            Regs_WrDin_Lo7b_True_hq_r2  <= '1';
         end if;

         if Regs_WrDin_r1(C_DBUS_WIDTH-1-32 downto C_MAXSIZE_FLD_BIT_TOP+1)
            = C_ALL_ZEROS(C_DBUS_WIDTH-1-32 downto C_MAXSIZE_FLD_BIT_TOP+1)
            then
            Regs_WrDin_Hi19b_True_lq_r2  <= '0';
         else
            Regs_WrDin_Hi19b_True_lq_r2  <= '1';
         end if;

         if Regs_WrDin_r1(C_MAXSIZE_FLD_BIT_BOT-1 downto 2)
            = C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_BOT-1 downto 2)
            then                               -- ! Lowest 2 bits ignored !
            Regs_WrDin_Lo7b_True_lq_r2  <= '0';
         else
            Regs_WrDin_Lo7b_True_lq_r2  <= '1';
         end if;

      end if;
   end process;



-- ---------------------------------------
-- 
   Write_DMA_Registers_Mux:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Reg_WrMuxer_Hi <= (Others => '0');
         Reg_WrMuxer_Lo <= (Others => '0');

      elsif trn_clk'event and trn_clk = '1' then

         if -- Regs_WrAddr_r1(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)=C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
            -- and 
            Regs_WrAddr_r1(C_DECODE_BIT_BOT-1 downto 2)=CONV_STD_LOGIC_VECTOR(0, C_DECODE_BIT_BOT-2)
            -- and Regs_WrAddr_r1(2-1 downto 0)="00"
            then
            Reg_WrMuxer_Hi(0)   <= not Regs_WrMask_r1(1);
         else
            Reg_WrMuxer_Hi(0)   <= '0';
         end if;

         FOR k IN 1 TO C_NUM_OF_ADDRESSES-1 LOOP

            if -- Regs_WrAddr_r1(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)=C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
               -- and 
               Regs_WrAddr_r1(C_DECODE_BIT_BOT-1 downto 2)=CONV_STD_LOGIC_VECTOR(k, C_DECODE_BIT_BOT-2)
               -- and Regs_WrAddr_r1(2-1 downto 0)="00"
               then
               Reg_WrMuxer_Hi(k)   <= not Regs_WrMask_r1(1);
            else
               Reg_WrMuxer_Hi(k)   <= '0';
            end if;

            if -- Regs_WrAddr_r1(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)=C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
               -- and 
               Regs_WrAddr_r1(C_DECODE_BIT_BOT-1 downto 2)=CONV_STD_LOGIC_VECTOR(k-1, C_DECODE_BIT_BOT-2)
               -- and Regs_WrAddr_r1(2-1 downto 0)="00"
               then
               Reg_WrMuxer_Lo(k)   <= not Regs_WrMask_r1(0);
            else
               Reg_WrMuxer_Lo(k)   <= '0';
            end if;

         END LOOP;

      end if;
   end process;



--  -----------------------------------------------
--  System Interrupt Status Control
--  -----------------------------------------------

-- -------------------------------------------------------
-- Synchronous Registered: Sys_Int_Enable_i
   SysReg_Sys_Int_Enable:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Sys_Int_Enable_i     <= (OTHERS => '0');
      elsif trn_clk'event and trn_clk = '1' then

        if Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Hi(CINT_ADDR_IRQ_EN)='1' 
			 then
            Sys_Int_Enable_i(32-1 downto 0) <=  Regs_WrDin_r2(64-1 downto 32);
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Lo(CINT_ADDR_IRQ_EN)='1' 
			 then
            Sys_Int_Enable_i(32-1 downto 0) <=  Regs_WrDin_r2(32-1 downto 0);
        else
            Sys_Int_Enable_i <=  Sys_Int_Enable_i;
        end if;

      end if;
   end process;


--  -----------------------------------------------
--    System General Control Register
--  -----------------------------------------------
-- -----------------------------------------------
-- Synchronous Registered: General_Control
   SysReg_General_Control:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         General_Control_i     <= (OTHERS => '0');
         General_Control_i(C_GCR_MSG_ROUT_BIT_TOP downto C_GCR_MSG_ROUT_BIT_BOT)   
                               <= C_TYPE_OF_MSG(C_TLP_TYPE_BIT_BOT+C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT 
                                  downto C_TLP_TYPE_BIT_BOT);

      elsif trn_clk'event and trn_clk = '1' then

        if Regs_WrEn_r2='1' 
           and Reg_WrMuxer_Hi(CINT_ADDR_CONTROL)='1' 
           then
            General_Control_i(32-1 downto 0)  <=  Regs_WrDin_r2(64-1 downto 32);
        elsif Regs_WrEn_r2='1' 
           and Reg_WrMuxer_Lo(CINT_ADDR_CONTROL)='1' 
           then
            General_Control_i(32-1 downto 0)  <=  Regs_WrDin_r2(32-1 downto 0);
        else
            General_Control_i  <=  General_Control_i;
        end if;

      end if;
   end process;

---- -----------------------------------------------
---- Synchronous Registered: DG_Reset_i
--   SysReg_DGen_Reset:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         DG_Reset_i            <= '1';
--         DG_Rst_Counter        <= (OTHERS=>'0');
--
--      elsif trn_clk'event and trn_clk = '1' then
--
--        if DG_Rst_Counter=X"FF" then
--           DG_Rst_Counter  <= DG_Rst_Counter;
--        else
--           DG_Rst_Counter  <= DG_Rst_Counter + '1';
--        end if;
--
--        if DG_Rst_Counter(7)='0' then
--            DG_Reset_i         <=  '1';
--        elsif Regs_WrEn_r2='1' 
--		    and Reg_WrMuxer_Hi(CINT_ADDR_DG_CTRL)='1' 
--			 then
--            DG_Reset_i         <=  Command_is_Reset_Hi;
--        elsif Regs_WrEn_r2='1' 
--		    and Reg_WrMuxer_Lo(CINT_ADDR_DG_CTRL)='1' 
--			 then
--            DG_Reset_i         <=  Command_is_Reset_Lo;
--        else
--            DG_Reset_i         <=  '0';
--        end if;
--
--      end if;
--   end process;
--
---- -----------------------------------------------
---- Synchronous Registered: DG_Mask_i
--   SysReg_DGen_Mask:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         DG_Mask_i     <= '0';
--      elsif trn_clk'event and trn_clk = '1' then
--
--        if Regs_WrEn_r2='1' 
--           and Reg_WrMuxer_Hi(CINT_ADDR_DG_CTRL)='1' 
--           then
--           DG_Mask_i  <=  Regs_WrDin_r2(32+CINT_BIT_DG_MASK);
--        elsif Regs_WrEn_r2='1' 
--           and Reg_WrMuxer_Lo(CINT_ADDR_DG_CTRL)='1' 
--           then
--           DG_Mask_i  <=  Regs_WrDin_r2(CINT_BIT_DG_MASK);
--        else
--           DG_Mask_i  <=  DG_Mask_i;
--        end if;
--
--      end if;
--   end process;
--
----------------------------------------------------------------------------
----  Data generator status
---- 
--   Synch_DG_Status_i:
--   process ( trn_clk, DG_Reset_i )
--   begin
--     if DG_Reset_i = '1' then
--        DG_Status_i    <= (OTHERS=>'0');
--     elsif trn_clk'event and trn_clk = '1' then
--        DG_Status_i(CINT_BIT_DG_MASK)    <= DG_Mask_i;
--        DG_Status_i(CINT_BIT_DG_BUSY)    <= DG_is_Running;
--     end if;
--   end process;

-- -----------------------------------------------
-- Synchronous Registered: IG_Control_i
   SysReg_IntGen_Control:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         IG_Control_i          <= (OTHERS => '0');
         IG_Reset_i            <= '1';
         IG_Host_Clear_i       <= '0';

      elsif trn_clk'event and trn_clk = '1' then

        if Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Hi(CINT_ADDR_IG_CONTROL)='1' 
			 then
            IG_Control_i(32-1 downto 0)       <=  Regs_WrDin_r2(64-1 downto 32);
            IG_Reset_i         <=  Command_is_Reset_Hi;
            IG_Host_Clear_i    <=  Command_is_Host_iClr_Hi;
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Lo(CINT_ADDR_IG_CONTROL)='1' 
			 then
            IG_Control_i(32-1 downto 0)       <=  Regs_WrDin_r2(32-1 downto 0);
            IG_Reset_i         <=  Command_is_Reset_Lo;
            IG_Host_Clear_i    <=  Command_is_Host_iClr_Lo;
        else
            IG_Control_i       <=  IG_Control_i;
            IG_Reset_i         <=  '0';
            IG_Host_Clear_i    <=  '0';
        end if;

      end if;
   end process;


-- -----------------------------------------------
-- Synchronous Registered: IG_Latency_i
   SysReg_IntGen_Latency:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         IG_Latency_i       <= (OTHERS => '0');

      elsif trn_clk'event and trn_clk = '1' then

        if IG_Reset_i='1' then
            IG_Latency_i    <=  (OTHERS => '0');
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Hi(CINT_ADDR_IG_LATENCY)='1' 
			 then
            IG_Latency_i(32-1 downto 0)    <=  Regs_WrDin_r2(64-1 downto 32);
        elsif Regs_WrEn_r2='1' 
		    and Reg_WrMuxer_Lo(CINT_ADDR_IG_LATENCY)='1' 
			 then
            IG_Latency_i(32-1 downto 0)    <=  Regs_WrDin_r2(32-1 downto 0);
        else
            IG_Latency_i    <=  IG_Latency_i;
        end if;

      end if;
   end process;




----  ------------------------------------------------------
----      Protocol CTL interface
----  ------------------------------------------------------
--
---- -------------------------------------------------------
---- Synchronous Registered: ctl_rd
--   Syn_CTL_rd:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         ctl_rd_i     <= (OTHERS => '0');
--         ctl_rv_i     <= '0';
--      elsif trn_clk'event and trn_clk = '1' then
--
--         if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_CTL_CLASS)='1' then
--            ctl_rd_i     <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
--            ctl_rv_i     <= '1';
--         elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_CTL_CLASS)='1' then
--            ctl_rd_i     <= Regs_WrDin_r2(32-1 downto 0);
--            ctl_rv_i     <= '1';
--         else
--            ctl_rd_i     <= ctl_rd_i;
--            ctl_rv_i     <= '0';
--         end if;
--
--      end if;
--   end process;
--
--
---- -----------------------------------------------
---- Synchronous Registered: ctl_reset
--   SysReg_ctl_reset:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         ctl_reset_i            <= '1';
--
--      elsif trn_clk'event and trn_clk = '1' then
--
--        if Regs_WrEn_r2='1' 
--		    and Reg_WrMuxer_Hi(CINT_ADDR_TC_STATUS)='1' 
--			 then
--            ctl_reset_i         <=  Command_is_Reset_Hi;
--        elsif Regs_WrEn_r2='1' 
--		    and Reg_WrMuxer_Lo(CINT_ADDR_TC_STATUS)='1' 
--			 then
--            ctl_reset_i         <=  Command_is_Reset_Lo;
--        else
--            ctl_reset_i         <=  '0';
--        end if;
--
--      end if;
--   end process;
--
--
--
---- -------------------------------------------------------
---- Synchronous Registered: ctl_td
----    ++++++++++++ INT triggering  ++++++++++++++++++
--   Syn_CTL_td:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         ctl_td_r     <= (OTHERS => '0');
--      elsif trn_clk'event and trn_clk = '1' then
--
--         if ctl_tv='1' then
--            ctl_td_r     <= ctl_td;
--         else
--            ctl_td_r     <= ctl_td_r;
--         end if;
--
--      end if;
--   end process;
--
--
--
----  ------------------------------------------------------
----      Protocol DLM interface
----  ------------------------------------------------------
--
---- -------------------------------------------------------
---- Synchronous Registered: dlm_td
--   Syn_DLM_td:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         dlm_td_i     <= (OTHERS => '0');
--         dlm_tv_i     <= '0';
--      elsif trn_clk'event and trn_clk = '1' then
--
--         if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DLM_CLASS)='1' then
--            dlm_td_i     <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
--            dlm_tv_i     <= '1';
--         elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DLM_CLASS)='1' then
--            dlm_td_i     <= Regs_WrDin_r2(32-1 downto 0);
--            dlm_tv_i     <= '1';
--         else
--            dlm_td_i     <= dlm_td_i;
--            dlm_tv_i     <= '0';
--         end if;
--
--      end if;
--   end process;
--
--
---- -------------------------------------------------------
---- Synchronous Registered: dlm_rd
----    ++++++++++++ INT triggering  ++++++++++++++++++
--   Syn_DLM_rd:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         dlm_rd_r     <= (OTHERS => '0');
--      elsif trn_clk'event and trn_clk = '1' then
--
--         if dlm_rv='1' then
--            dlm_rd_r     <= dlm_rd;
--         else
--            dlm_rd_r     <= dlm_rd_r;
--         end if;
--
--      end if;
--   end process;


--  ------------------------------------------------------
--  DMA Upstream Registers
--  ------------------------------------------------------

-- -------------------------------------------------------
-- Synchronous Registered: DMA_us_PA_i
   RxTrn_DMA_us_PA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_PA_i  <= (OTHERS => '0');
      elsif trn_clk'event and trn_clk = '1' then

        if usDMA_Channel_Rst_i = '1' then
            DMA_us_PA_i <= (OTHERS => '0');
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_PAH)='1' then
            DMA_us_PA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(64-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_PAH)='1' then
            DMA_us_PA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_us_PA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_us_PA_i(C_DBUS_WIDTH-1 downto 32);
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_PAL)='1' then
            DMA_us_PA_i(32-1 downto 0)  <= Regs_WrDin_r2(64-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_PAL)='1' then
            DMA_us_PA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_us_PA_i(32-1 downto 0)  <= DMA_us_PA_i(32-1 downto 0);
          end if;

        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous Registered: DMA_us_HA_i
   RxTrn_DMA_us_HA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_HA_i     <= (OTHERS => '1');
         usHA_is_64b_i   <= '0';

      elsif trn_clk'event and trn_clk = '1' then

        if usDMA_Channel_Rst_i = '1' then
            DMA_us_HA_i <= (OTHERS => '1');
            usHA_is_64b_i <= '0';
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_HAH)='1' then
            DMA_us_HA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(64-1 downto 32);
            usHA_is_64b_i   <=  WrDin_r2_not_Zero_Hi;
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_HAH)='1' then
            DMA_us_HA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
            usHA_is_64b_i   <=  WrDin_r2_not_Zero_Lo;
          else
            DMA_us_HA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_us_HA_i(C_DBUS_WIDTH-1 downto 32);
            usHA_is_64b_i   <=  usHA_is_64b_i;
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_HAL)='1' then
            DMA_us_HA_i(32-1 downto 0)  <= Regs_WrDin_r2(64-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_HAL)='1' then
            DMA_us_HA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_us_HA_i(32-1 downto 0)  <= DMA_us_HA_i(32-1 downto 0);
          end if;

        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_us_BDA_i
   Syn_Output_DMA_us_BDA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_BDA_i    <= (OTHERS =>'0');
         usBDA_is_64b_i  <= '0';
      elsif trn_clk'event and trn_clk = '1' then

        if usDMA_Channel_Rst_i = '1' then
           DMA_us_BDA_i <= (OTHERS => '0');
           usBDA_is_64b_i <= '0';
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_BDAH)='1' then
            DMA_us_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
            usBDA_is_64b_i   <=  WrDin_r2_not_Zero_Hi;
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_BDAH)='1' then
            DMA_us_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
            usBDA_is_64b_i   <=  WrDin_r2_not_Zero_Lo;
          else
            DMA_us_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_us_BDA_i(C_DBUS_WIDTH-1 downto 32);
            usBDA_is_64b_i   <=  usBDA_is_64b_i;
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_BDAL)='1' then
            DMA_us_BDA_i(32-1 downto 0)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_BDAL)='1' then
            DMA_us_BDA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_us_BDA_i(32-1 downto 0)  <= DMA_us_BDA_i(32-1 downto 0);
          end if;

        end if;

      end if;
   end process;



-- -------------------------------------------------------
-- Synchronous Registered: DMA_us_Length_i
   RxTrn_DMA_us_Length:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_Length_i     <= (OTHERS => '0');
         usLeng_Hi19b_True_i <= '0';
         usLeng_Lo7b_True_i  <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if usDMA_Channel_Rst_i = '1' then
            DMA_us_Length_i     <= (OTHERS => '0');
            usLeng_Hi19b_True_i <= '0';
            usLeng_Lo7b_True_i  <= '0';

         elsif Regs_WrEn_r2='1' and  Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_LENG)='1' then
            DMA_us_Length_i(32-1 downto 0)     <= Regs_WrDin_r2(64-1 downto 32);
            usLeng_Hi19b_True_i <= Regs_WrDin_Hi19b_True_hq_r2;
            usLeng_Lo7b_True_i  <= Regs_WrDin_Lo7b_True_hq_r2;
         elsif Regs_WrEn_r2='1' and  Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_LENG)='1' then
            DMA_us_Length_i(32-1 downto 0)     <= Regs_WrDin_r2(32-1 downto 0);
            usLeng_Hi19b_True_i <= Regs_WrDin_Hi19b_True_lq_r2;
            usLeng_Lo7b_True_i  <= Regs_WrDin_Lo7b_True_lq_r2;
         else
            DMA_us_Length_i     <= DMA_us_Length_i;
            usLeng_Hi19b_True_i <= usLeng_Hi19b_True_i;
            usLeng_Lo7b_True_i  <= usLeng_Lo7b_True_i;

         end if;

      end if;
   end process;



-- -------------------------------------------------------
-- Synchronous us_Param_Modified
   SynReg_us_Param_Modified:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         us_Param_Modified     <= '0';

      elsif trn_clk'event and trn_clk = '1' then

        if usDMA_Channel_Rst_i = '1'
           or usDMA_Start_i = '1'
           or usDMA_Start2_i = '1'
           then
             us_Param_Modified     <= '0';
        elsif Regs_WrEn_r2='1' and
                (
                    Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_PAL) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_PAL) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_HAH) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_HAH) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_HAL) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_HAL) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_BDAH)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_BDAH)='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_BDAL)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_BDAL)='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_LENG)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_LENG)='1'
                ) 
           then
             us_Param_Modified     <= '1';
        else
             us_Param_Modified     <= us_Param_Modified;

        end if;

      end if;
   end process;



-- -------------------------------------------------------
-- Synchronous output: DMA_us_Control_i
   Syn_Output_DMA_us_Control:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_Control_i <= (OTHERS =>'0');
      elsif trn_clk'event and trn_clk = '1' then

         if     Regs_Wr_dma_V_nE_Hi_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
            and us_Param_Modified='1'
            and usDMA_Stop_i='0'
            then
               DMA_us_Control_i(32-1 downto 0) <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 8+32)& X"00";
         elsif Regs_Wr_dma_V_nE_Lo_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
            and us_Param_Modified='1'
            and usDMA_Stop_i='0'
            then
               DMA_us_Control_i(32-1 downto 0) <= Regs_WrDin_r2(32-1 downto 8)& X"00";
         elsif  Regs_Wr_dma_nV_Hi_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               DMA_us_Control_i(32-1 downto 0) <= Last_Ctrl_Word_us(32-1 downto 0);
         elsif  Regs_Wr_dma_nV_Lo_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               DMA_us_Control_i(32-1 downto 0) <= Last_Ctrl_Word_us(32-1 downto 0);
         else
            DMA_us_Control_i  <= DMA_us_Control_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous Register: Last_Ctrl_Word_us
   Hold_Last_Ctrl_Word_us:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Last_Ctrl_Word_us  <= C_DEF_DMA_CTRL_WORD;
      elsif trn_clk'event and trn_clk = '1' then

        if usDMA_Channel_Rst_i = '1' then
            Last_Ctrl_Word_us <= C_DEF_DMA_CTRL_WORD;
        elsif Regs_Wr_dma_V_nE_Hi_r2='1' 
          and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
          and us_Param_Modified='1'
          and usDMA_Stop_i='0'
          then
            Last_Ctrl_Word_us(32-1 downto 0) <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 8+32) & X"00";
        elsif Regs_Wr_dma_V_nE_Lo_r2='1' 
          and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
          and us_Param_Modified='1'
          and usDMA_Stop_i='0'
          then
            Last_Ctrl_Word_us(32-1 downto 0) <= Regs_WrDin_r2(32-1 downto 8) & X"00";
        elsif Regs_Wr_dma_V_nE_Hi_r2='1' 
          and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
          and us_Param_Modified='1'
          and usDMA_Stop_i='0'
          then
            Last_Ctrl_Word_us(32-1 downto 0) <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 8+32) & X"00";
        elsif Regs_Wr_dma_V_nE_Lo_r2='1' 
          and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
          and us_Param_Modified='1'
          and usDMA_Stop_i='0'
          then
            Last_Ctrl_Word_us(32-1 downto 0) <= Regs_WrDin_r2(32-1 downto 8) & X"00";
        else
            Last_Ctrl_Word_us <= Last_Ctrl_Word_us;
        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_us_Start_Stop
   Syn_Output_DMA_us_Start_Stop:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         usDMA_Start_i  <= '0';
         usDMA_Stop_i   <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if     Regs_WrEnA_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
            then
               usDMA_Start_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) 
                            and not usDMA_Stop_i 
                            and not Command_is_Reset_Hi 
                            and us_Param_Modified
                            ;
               usDMA_Stop_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) 
                            and not Command_is_Reset_Hi
                            ;
         elsif Regs_WrEnA_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
            then
               usDMA_Start_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) 
                            and not usDMA_Stop_i 
                            and not Command_is_Reset_Lo 
                            and us_Param_Modified
                            ;
               usDMA_Stop_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) 
                            and not Command_is_Reset_Lo
                            ;
         elsif  Regs_WrEnA_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               usDMA_Start_i <= not Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END) 
                            and us_Param_Modified;
               usDMA_Stop_i  <= Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
         elsif  Regs_WrEnA_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               usDMA_Start_i <= not Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END) 
                            and us_Param_Modified;
               usDMA_Stop_i  <= Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
         elsif usDMA_Cmd_Ack='1'
            then
               usDMA_Start_i <= '0';
               usDMA_Stop_i  <= usDMA_Stop_i;
         else
               usDMA_Start_i <= usDMA_Start_i;
               usDMA_Stop_i  <= usDMA_Stop_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_us_Start2_Stop2
   Syn_Output_DMA_us_Start2_Stop2:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         usDMA_Start2_i <= '0';
         usDMA_Stop2_i  <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if usDMA_Channel_Rst_i='1' then
               usDMA_Start2_i <= '0';
               usDMA_Stop2_i  <= '0';
         elsif     Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
            then
               usDMA_Start2_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) and not Command_is_Reset_Hi;
               usDMA_Stop2_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) and not Command_is_Reset_Lo;
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
            then
               usDMA_Start2_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) and not Command_is_Reset_Lo;
               usDMA_Stop2_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) and not Command_is_Reset_Lo;
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='0'
            then
               usDMA_Start2_i <= not Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
               usDMA_Stop2_i  <= Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               usDMA_Start2_i <= not Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
               usDMA_Stop2_i  <= Last_Ctrl_Word_us(CINT_BIT_DMA_CTRL_END);
         elsif usDMA_Cmd_Ack='1' then
               usDMA_Start2_i <= '0';
               usDMA_Stop2_i  <= usDMA_Stop2_i;
         else
               usDMA_Start2_i <= usDMA_Start2_i;
               usDMA_Stop2_i  <= usDMA_Stop2_i;
         end if;

      end if;
   end process;


--  ------------------------------------------------------
--  DMA Downstream Registers
--  ------------------------------------------------------

-- -------------------------------------------------------
-- Synchronous Registered: DMA_ds_PA_i
   RxTrn_DMA_ds_PA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_PA_i     <= (OTHERS => '0');
      elsif trn_clk'event and trn_clk = '1' then

        if dsDMA_Channel_Rst_i = '1' then
            DMA_ds_PA_i <= (OTHERS => '0');
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_PAH)='1' then
            DMA_ds_PA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_PAH)='1' then
            DMA_ds_PA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_ds_PA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_ds_PA_i(C_DBUS_WIDTH-1 downto 32);
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_PAL)='1' then
            DMA_ds_PA_i(32-1 downto 0)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_PAL)='1' then
            DMA_ds_PA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_ds_PA_i(32-1 downto 0)  <= DMA_ds_PA_i(32-1 downto 0);
          end if;

        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous Registered: DMA_ds_HA_i
   RxTrn_DMA_ds_HA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_HA_i     <= (OTHERS => '1');
         dsHA_is_64b_i   <= '0';
      elsif trn_clk'event and trn_clk = '1' then

        if dsDMA_Channel_Rst_i = '1' then
            DMA_ds_HA_i <= (OTHERS => '1');
            dsHA_is_64b_i <= '0';
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_HAH)='1' then
            DMA_ds_HA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
            dsHA_is_64b_i   <=  WrDin_r2_not_Zero_Hi;
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_HAH)='1' then
            DMA_ds_HA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
            dsHA_is_64b_i   <=  WrDin_r2_not_Zero_Lo;
          else
            DMA_ds_HA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_ds_HA_i(C_DBUS_WIDTH-1 downto 32);
            dsHA_is_64b_i   <=  dsHA_is_64b_i;
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_HAL)='1' then
            DMA_ds_HA_i(32-1 downto 0)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_HAL)='1' then
            DMA_ds_HA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_ds_HA_i(32-1 downto 0)  <= DMA_ds_HA_i(32-1 downto 0);
          end if;

        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_ds_BDA_i
   Syn_Output_DMA_ds_BDA:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_BDA_i    <= (OTHERS =>'0');
         dsBDA_is_64b_i  <= '0';
      elsif trn_clk'event and trn_clk = '1' then

        if dsDMA_Channel_Rst_i = '1' then
            DMA_ds_BDA_i <= (OTHERS => '0');
            dsBDA_is_64b_i <= '0';
        else

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_BDAH)='1' then
            DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
            dsBDA_is_64b_i   <=  WrDin_r2_not_Zero_Hi;
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_BDAH)='1' then
            DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= Regs_WrDin_r2(32-1 downto 0);
            dsBDA_is_64b_i   <=  WrDin_r2_not_Zero_Lo;
          else
            DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto 32)  <= DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto 32);
            dsBDA_is_64b_i   <=  dsBDA_is_64b_i;
          end if;

          if Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_BDAL)='1' then
            DMA_ds_BDA_i(32-1 downto 0)  <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
          elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_BDAL)='1' then
            DMA_ds_BDA_i(32-1 downto 0)  <= Regs_WrDin_r2(32-1 downto 0);
          else
            DMA_ds_BDA_i(32-1 downto 0)  <= DMA_ds_BDA_i(32-1 downto 0);
          end if;

        end if;
      end if;
   end process;



-- Synchronous Registered: DMA_ds_Length_i
   RxTrn_DMA_ds_Length:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_Length_i     <= (OTHERS => '0');
         dsLeng_Hi19b_True_i <= '0';
         dsLeng_Lo7b_True_i  <= '0';
      elsif trn_clk'event and trn_clk = '1' then

         if dsDMA_Channel_Rst_i = '1' then
            DMA_ds_Length_i <= (OTHERS => '0');
            dsLeng_Hi19b_True_i <= '0';
            dsLeng_Lo7b_True_i  <= '0';

         elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_LENG)='1' then
            DMA_ds_Length_i(32-1 downto 0)     <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 32);
            dsLeng_Hi19b_True_i <= Regs_WrDin_Hi19b_True_hq_r2;
            dsLeng_Lo7b_True_i  <= Regs_WrDin_Lo7b_True_hq_r2;
         elsif Regs_WrEn_r2='1' and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_LENG)='1' then
            DMA_ds_Length_i(32-1 downto 0)     <= Regs_WrDin_r2(32-1 downto 0);
            dsLeng_Hi19b_True_i <= Regs_WrDin_Hi19b_True_lq_r2;
            dsLeng_Lo7b_True_i  <= Regs_WrDin_Lo7b_True_lq_r2;
         else
            DMA_ds_Length_i     <= DMA_ds_Length_i;
            dsLeng_Hi19b_True_i <= dsLeng_Hi19b_True_i;
            dsLeng_Lo7b_True_i  <= dsLeng_Lo7b_True_i;

         end if;

      end if;
   end process;



-- -------------------------------------------------------
-- Synchronous ds_Param_Modified
   SynReg_ds_Param_Modified:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         ds_Param_Modified     <= '0';

      elsif trn_clk'event and trn_clk = '1' then

        if dsDMA_Channel_Rst_i = '1'
           or dsDMA_Start_i = '1'
           or dsDMA_Start2_i = '1'
           then
             ds_Param_Modified     <= '0';
        elsif Regs_WrEn_r2='1' and
                (   
--                    Reg_WrMuxer(CINT_ADDR_DMA_DS_PAH) ='1'
--                 or 
                    Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_PAL) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_PAL) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_HAH) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_HAH) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_HAL) ='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_HAL) ='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_BDAH)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_BDAH)='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_BDAL)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_BDAL)='1'
                 or Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_LENG)='1'
                 or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_LENG)='1'
                )
           then
             ds_Param_Modified     <= '1';
        else
             ds_Param_Modified     <= ds_Param_Modified;

        end if;

      end if;
   end process;



-- -------------------------------------------------------
-- Synchronous output: DMA_ds_Control_i
   Syn_Output_DMA_ds_Control:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_Control_i <= (OTHERS =>'0');

      elsif trn_clk'event and trn_clk = '1' then

         if     Regs_Wr_dma_V_nE_Hi_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32)='0'
            and ds_Param_Modified='1'
            and dsDMA_Stop_i='0'
            then
               DMA_ds_Control_i(32-1 downto 0) <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 8+32)& X"00";
         elsif  Regs_Wr_dma_V_nE_Lo_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
            and ds_Param_Modified='1'
            and dsDMA_Stop_i='0'
            then
               DMA_ds_Control_i(32-1 downto 0) <= Regs_WrDin_r2(32-1 downto 8)& X"00";
         elsif  Regs_Wr_dma_nV_Hi_r2='1'
            and (Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1' or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1')
--            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               DMA_ds_Control_i <= Last_Ctrl_Word_ds;
         else
            DMA_ds_Control_i  <= DMA_ds_Control_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous Register: Last_Ctrl_Word_ds
   Hold_Last_Ctrl_Word_ds:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Last_Ctrl_Word_ds  <= C_DEF_DMA_CTRL_WORD;
      elsif trn_clk'event and trn_clk = '1' then

        if dsDMA_Channel_Rst_i = '1' then
            Last_Ctrl_Word_ds <= C_DEF_DMA_CTRL_WORD;
        elsif Regs_Wr_dma_V_nE_Hi_r2='1' 
          and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32)='0'
          and ds_Param_Modified='1'
          and dsDMA_Stop_i='0'
          then
            Last_Ctrl_Word_ds(32-1 downto 0) <= Regs_WrDin_r2(C_DBUS_WIDTH-1 downto 8+32) & X"00";
        elsif Regs_Wr_dma_V_nE_Lo_r2='1' 
          and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1' 
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
--          and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END)='0'
          and ds_Param_Modified='1'
          and dsDMA_Stop_i='0'
          then
            Last_Ctrl_Word_ds(32-1 downto 0) <= Regs_WrDin_r2(32-1 downto 8) & X"00";
        else
            Last_Ctrl_Word_ds <= Last_Ctrl_Word_ds;
        end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_ds_Start_Stop
   Syn_Output_DMA_ds_Start_Stop:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         dsDMA_Start_i  <= '0';
         dsDMA_Stop_i   <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if     Regs_WrEnA_r2='1' 
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
            then
               dsDMA_Start_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) 
                            and not dsDMA_Stop_i 
                            and not Command_is_Reset_Hi 
                            and ds_Param_Modified
                            ;
               dsDMA_Stop_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) 
                            and not Command_is_Reset_Hi
                            ;
         elsif  Regs_WrEnA_r2='1' 
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
            then
               dsDMA_Start_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) 
                            and not dsDMA_Stop_i 
                            and not Command_is_Reset_Lo 
                            and ds_Param_Modified
                            ;
               dsDMA_Stop_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) 
                            and not Command_is_Reset_Lo
                            ;
         elsif  Regs_WrEnA_r2='1'
            and (Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1' or Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1')
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='0'
            then
               dsDMA_Start_i <= not Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END) 
                            and ds_Param_Modified
                            ;
               dsDMA_Stop_i  <= Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END);
         elsif dsDMA_Cmd_Ack='1'
            then
               dsDMA_Start_i <= '0';
               dsDMA_Stop_i  <= dsDMA_Stop_i;
         else
               dsDMA_Start_i <= dsDMA_Start_i;
               dsDMA_Stop_i  <= dsDMA_Stop_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------
-- Synchronous output: DMA_ds_Start2_Stop2
   Syn_Output_DMA_ds_Start2_Stop2:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         dsDMA_Start2_i <= '0';
         dsDMA_Stop2_i  <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if dsDMA_Channel_Rst_i='1' then
               dsDMA_Start2_i <= '0';
               dsDMA_Stop2_i  <= '0';
         elsif     Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='1'
            then
               dsDMA_Start2_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) and not Command_is_Reset_Hi;
               dsDMA_Stop2_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END+32) and not Command_is_Reset_Hi;
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1'
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='1'
            then
               dsDMA_Start2_i <= not Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) and not Command_is_Reset_Lo;
               dsDMA_Stop2_i  <= Regs_WrDin_r2(CINT_BIT_DMA_CTRL_END) and not Command_is_Reset_Lo;
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1' 
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)='0'
            then
               dsDMA_Start2_i <= not Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END);
               dsDMA_Stop2_i  <= Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END);
         elsif  Regs_WrEnB_r2='1'
            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1' 
            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)='0'
            then
               dsDMA_Start2_i <= not Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END);
               dsDMA_Stop2_i  <= Last_Ctrl_Word_ds(CINT_BIT_DMA_CTRL_END);
         elsif dsDMA_Cmd_Ack='1' then
               dsDMA_Start2_i <= '0';
               dsDMA_Stop2_i  <= dsDMA_Stop2_i;
         else
               dsDMA_Start2_i <= dsDMA_Start2_i;
               dsDMA_Stop2_i  <= dsDMA_Stop2_i;
         end if;

      end if;
   end process;


------------------------------------------------------------------------
--                          Reset signals                             --
------------------------------------------------------------------------

-- --------------------------------------
-- Identification: Command_is_Reset
-- 
   Synch_Capture_Command_is_Reset:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Command_is_Reset_Hi    <= '0';
         Command_is_Reset_Lo    <= '0';

      elsif trn_clk'event and trn_clk = '1' then
         if Regs_WrDin_r1(C_FEAT_BITS_WIDTH-1+32 downto 32)=C_CHANNEL_RST_BITS then
            Command_is_Reset_Hi    <= '1';
         else
            Command_is_Reset_Hi    <= '0';
         end if;

         if Regs_WrDin_r1(C_FEAT_BITS_WIDTH-1 downto 0)=C_CHANNEL_RST_BITS then
            Command_is_Reset_Lo    <= '1';
         else
            Command_is_Reset_Lo    <= '0';
         end if;
      end if;
   end process;


-- --------------------------------------
-- Identification: Command_is_Host_iClr
-- 
   Synch_Capture_Command_is_Host_iClr:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Command_is_Host_iClr_Hi    <= '0';
         Command_is_Host_iClr_Lo    <= '0';

      elsif trn_clk'event and trn_clk = '1' then
         if Regs_WrDin_r1(C_FEAT_BITS_WIDTH-1+32 downto 32)=C_HOST_ICLR_BITS then
            Command_is_Host_iClr_Hi    <= '1';
         else
            Command_is_Host_iClr_Hi    <= '0';
         end if;

         if Regs_WrDin_r1(C_FEAT_BITS_WIDTH-1 downto 0)=C_HOST_ICLR_BITS then
            Command_is_Host_iClr_Lo    <= '1';
         else
            Command_is_Host_iClr_Lo    <= '0';
         end if;
      end if;
   end process;

-------------------------------------------
-- Synchronous output: usDMA_Channel_Rst_i
-- 
   Syn_Output_usDMA_Channel_Rst:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         usDMA_Channel_Rst_i <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         usDMA_Channel_Rst_i <= (Regs_Wr_dma_V_Hi_r2
                            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_US_CTRL)
--                            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)
                            and Command_is_Reset_Hi
                                )
                            or  (Regs_Wr_dma_V_LO_r2
                            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_US_CTRL)
--                            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)
                            and Command_is_Reset_Lo
                                )
                            ;
      end if;
   end process;



-------------------------------------------
-- Synchronous output: dsDMA_Channel_Rst_i
-- 
   Syn_Output_dsDMA_Channel_Rst:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         dsDMA_Channel_Rst_i <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         dsDMA_Channel_Rst_i <= (Regs_Wr_dma_V_Hi_r2
                            and Reg_WrMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)
--                            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID+32)
                            and Command_is_Reset_Hi
                            )
                            or
                           (Regs_Wr_dma_V_Lo_r2
                            and Reg_WrMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)
--                            and Regs_WrDin_r2(CINT_BIT_DMA_CTRL_VALID)
                            and Command_is_Reset_Lo
                            )
                            ;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous output: MRd_Channel_Rst_i
-- 
   Syn_Output_MRd_Channel_Rst:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         MRd_Channel_Rst_i <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         MRd_Channel_Rst_i    <= Regs_WrEn_r2
                             and (
                                 (Reg_WrMuxer_Hi(CINT_ADDR_MRD_CTRL)
                                  and Command_is_Reset_Hi)
                             or
                                 (Reg_WrMuxer_Lo(CINT_ADDR_MRD_CTRL)
                                  and Command_is_Reset_Lo)
                             )
                             ;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous output: Tx_Reset_i
-- 
   Syn_Output_Tx_Reset:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Tx_Reset_i   <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         Tx_Reset_i   <= Regs_WrEn_r2
                     and ((Reg_WrMuxer_Hi(CINT_ADDR_TX_CTRL)
                     and Command_is_Reset_Hi)
                     or  (Reg_WrMuxer_Lo(CINT_ADDR_TX_CTRL)
                     and Command_is_Reset_Lo))
                     ;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous output: eb_FIFO_Rst_i
-- 
   Syn_Output_eb_FIFO_Rst:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         eb_FIFO_Rst_i    <= '1';
         eb_FIFO_Rst_b3   <= '1';
         eb_FIFO_Rst_b2   <= '1';
         eb_FIFO_Rst_b1   <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         eb_FIFO_Rst_i   <= eb_FIFO_Rst_b1 or eb_FIFO_Rst_b2 or eb_FIFO_Rst_b3;
         eb_FIFO_Rst_b3  <= eb_FIFO_Rst_b2;
         eb_FIFO_Rst_b2  <= eb_FIFO_Rst_b1;
         eb_FIFO_Rst_b1  <= Regs_WrEn_r2
                         and ((Reg_WrMuxer_Hi(CINT_ADDR_EB_STACON)
                         and Command_is_Reset_Hi)
                         or  (Reg_WrMuxer_Lo(CINT_ADDR_EB_STACON)
                         and Command_is_Reset_Lo))
                         ;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous output: protocol_rst
-- 
--            !!!  reset by trn_reset_n  !!!
-- 
   Syn_Output_protocol_rst:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         protocol_rst_i   <= '1';
         protocol_rst_b1  <= '1';
         protocol_rst_b2  <= '1';
      elsif trn_clk'event and trn_clk = '1' then

         protocol_rst_i  <= protocol_rst_b1 or protocol_rst_b2;
         protocol_rst_b1 <= protocol_rst_b2;
         protocol_rst_b2 <= Regs_WrEn_r2
                         and ((Reg_WrMuxer_Hi(CINT_ADDR_PROTOCOL_STACON)
                         and Command_is_Reset_Hi)
                         or  (Reg_WrMuxer_Lo(CINT_ADDR_PROTOCOL_STACON)
                         and Command_is_Reset_Lo))
                         ;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous Calculation: DMA_us_Transf_Bytes
-- 
   Syn_Calc_DMA_us_Transf_Bytes:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_us_Transf_Bytes_i   <= (OTHERS=>'0');
      elsif trn_clk'event and trn_clk = '1' then

         if usDMA_Channel_Rst_i='1' then
            DMA_us_Transf_Bytes_i   <= (OTHERS=>'0');
         elsif us_DMA_Bytes_Add='1' then
            DMA_us_Transf_Bytes_i(32-1 downto 0)   
                                    <= DMA_us_Transf_Bytes_i(32-1 downto 0)
                                    +  us_DMA_Bytes;
         else
            DMA_us_Transf_Bytes_i   <= DMA_us_Transf_Bytes_i;
         end if;
      end if;
   end process;


-- -----------------------------------------------
-- Synchronous Calculation: DMA_ds_Transf_Bytes
-- 
   Syn_Calc_DMA_ds_Transf_Bytes:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         DMA_ds_Transf_Bytes_i   <= (OTHERS=>'0');
      elsif trn_clk'event and trn_clk = '1' then

         if dsDMA_Channel_Rst_i='1' then
            DMA_ds_Transf_Bytes_i   <= (OTHERS=>'0');
         elsif ds_DMA_Bytes_Add='1' then
            DMA_ds_Transf_Bytes_i(32-1 downto 0)   
                                    <= DMA_ds_Transf_Bytes_i(32-1 downto 0)
                                    +  ds_DMA_Bytes;
         else
            DMA_ds_Transf_Bytes_i   <= DMA_ds_Transf_Bytes_i;
         end if;
      end if;
   end process;



----------------------------------------------------------
---------------  Tx reading registers  -------------------
----------------------------------------------------------

----------------------------------------------------------
-- Synch Register:  Read Selection
-- 
   Tx_DMA_Reg_RdMuxer:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
           Reg_RdMuxer_Hi     <= (Others =>'0');
           Reg_RdMuxer_Lo     <= (Others =>'0');

      elsif trn_clk'event and trn_clk = '1' then

         FOR k IN 0 TO C_NUM_OF_ADDRESSES-1 LOOP
            if Regs_RdAddr_i(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)= C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
               and Regs_RdAddr_i(C_DECODE_BIT_BOT-1 downto 2)=CONV_STD_LOGIC_VECTOR(k, C_DECODE_BIT_BOT-2)
               and Regs_RdAddr_i(2-1 downto 0)="00"
               then
               Reg_RdMuxer_Hi(k) <= '1';
            else
               Reg_RdMuxer_Hi(k) <= '0';
            end if;
         END LOOP;

         if Regs_RdAddr_i(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)= C_ALL_ONES(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
            and Regs_RdAddr_i(C_DECODE_BIT_BOT-1 downto 2)=C_ALL_ONES(C_DECODE_BIT_BOT-1 downto 2)
            and Regs_RdAddr_i(2-1 downto 0)="00"
            then
            Reg_RdMuxer_Lo(0) <= '1';
         else
            Reg_RdMuxer_Lo(0) <= '0';
         end if;
         FOR k IN 1 TO C_NUM_OF_ADDRESSES-1 LOOP
            if Regs_RdAddr_i(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)= C_REGS_BASE_ADDR(C_DECODE_BIT_TOP downto C_DECODE_BIT_BOT)
               and Regs_RdAddr_i(C_DECODE_BIT_BOT-1 downto 2)=CONV_STD_LOGIC_VECTOR(k-1, C_DECODE_BIT_BOT-2)
               and Regs_RdAddr_i(2-1 downto 0)="00"
               then
               Reg_RdMuxer_Lo(k) <= '1';
            else
               Reg_RdMuxer_Lo(k) <= '0';
            end if;
         END LOOP;

      end if;
   end process;


------------------------------------------------------------
---- Synch Register:  CTL_TTake
---- 
--   Syn_CTL_ttake:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         ctl_ttake_i      <= '0';
--         ctl_t_read_Hi_r1 <= '0';
--         ctl_t_read_Lo_r1 <= '0';
--         CTL_read_counter <= (OTHERS=>'0');
--
--      elsif trn_clk'event and trn_clk = '1' then
--         ctl_t_read_Hi_r1 <= Reg_RdMuxer_Hi(CINT_ADDR_CTL_CLASS);
--         ctl_t_read_Lo_r1 <= Reg_RdMuxer_Lo(CINT_ADDR_CTL_CLASS);
--         ctl_ttake_i  <= (Reg_RdMuxer_Hi(CINT_ADDR_CTL_CLASS) and not ctl_t_read_Hi_r1)
--                      or (Reg_RdMuxer_Lo(CINT_ADDR_CTL_CLASS) and not ctl_t_read_Lo_r1)
--                      ;
--         if ctl_reset_i='1' then
--            CTL_read_counter <= (OTHERS=>'0');
--         else
--            CTL_read_counter <= CTL_read_counter + ctl_ttake_i;
--         end if;
--
--      end if;
--   end process;
--
------------------------------------------------------------
---- Synch Register:  class_CTL_Status
---- 
--   Syn_class_CTL_Status:
--   process ( trn_clk, trn_lnk_up_n)
--   begin
--      if trn_lnk_up_n = '1' then
--         class_CTL_Status_i      <= (OTHERS=>'0');
--
--      elsif trn_clk'event and trn_clk = '1' then
--         class_CTL_Status_i(C_DBUS_WIDTH/2-1 downto 0)      <= ctl_status;
--
--      end if;
--   end process;


-- -------------------------------------------------------
-- 
   Sys_Int_Status_i     <= ( 
--                            CINT_BIT_DLM_IN_ISR     => DLM_irq     ,
--                            CINT_BIT_CTL_IN_ISR     => CTL_irq     ,
--                            CINT_BIT_DAQ_IN_ISR     => DAQ_irq     ,

                            CINT_BIT_DSTOUT_IN_ISR  => DMA_ds_Tout ,
                            CINT_BIT_USTOUT_IN_ISR  => DMA_us_Tout ,

                            CINT_BIT_INTGEN_IN_ISR  => IG_Asserting,
                            CINT_BIT_DS_DONE_IN_ISR => DMA_ds_Done ,
                            CINT_BIT_US_DONE_IN_ISR => DMA_us_Done ,
                            OTHERS                  => '0'
                           );

   --------------------------------------------------------------------------
   -- Upstream Registers
   --------------------------------------------------------------------------
   
   --  Peripheral Address Start point
   DMA_us_PA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_PA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_PAH)='1'
         else (Others=>'0');

   DMA_us_PA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_PA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_PAL)='1'
         else (Others=>'0');


   --  Host Address Start point
   DMA_us_HA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_HA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_HAH)='1'
         else (Others=>'0');

   DMA_us_HA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_HA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_HAL)='1'
         else (Others=>'0');


   --  Next Descriptor Address
   DMA_us_BDA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_BDA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_BDAH)='1'
         else (Others=>'0');

   DMA_us_BDA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_BDA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_BDAL)='1'
         else (Others=>'0');

   --  Length
   DMA_us_Length_o_Hi(32-1 downto 0)
      <= DMA_us_Length_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_LENG)='1'
         else (Others=>'0');

   --  Control word
   DMA_us_Control_o_Hi(32-1 downto 0)
      <= DMA_us_Control_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_CTRL)='1'
         else (Others=>'0');

   --  Status (Read only)
   DMA_us_Status_o_Hi(32-1 downto 0)
      <= DMA_us_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_US_STA)='1'
         else (Others=>'0');

   --  Tranferred bytes (Read only)
   DMA_us_Transf_Bytes_o_Hi(32-1 downto 0)
      <= DMA_us_Transf_Bytes_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_US_TRANSF_BC)='1'
         else (Others=>'0');


   --  Peripheral Address Start point
   DMA_us_PA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_PA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_PAH)='1'
         else (Others=>'0');

   DMA_us_PA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_PA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_PAL)='1'
         else (Others=>'0');


   --  Host Address Start point
   DMA_us_HA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_HA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_HAH)='1'
         else (Others=>'0');

   DMA_us_HA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_HA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_HAL)='1'
         else (Others=>'0');


   --  Next Descriptor Address
   DMA_us_BDA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_us_BDA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_BDAH)='1'
         else (Others=>'0');

   DMA_us_BDA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_us_BDA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_BDAL)='1'
         else (Others=>'0');

   --  Length
   DMA_us_Length_o_Lo(32-1 downto 0)
      <= DMA_us_Length_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_LENG)='1'
         else (Others=>'0');

   --  Control word
   DMA_us_Control_o_Lo(32-1 downto 0)
      <= DMA_us_Control_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_CTRL)='1'
         else (Others=>'0');

   --  Status (Read only)
   DMA_us_Status_o_Lo(32-1 downto 0)
      <= DMA_us_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_US_STA)='1'
         else (Others=>'0');

   --  Tranferred bytes (Read only)
   DMA_us_Transf_Bytes_o_Lo(32-1 downto 0)
      <= DMA_us_Transf_Bytes_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_US_TRANSF_BC)='1'
         else (Others=>'0');

   --------------------------------------------------------------------------
   -- Downstream Registers
   --------------------------------------------------------------------------

   --  Peripheral Address Start point
   DMA_ds_PA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_PA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_PAH)='1'
         else (Others=>'0');

   DMA_ds_PA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_PA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_PAL)='1'
         else (Others=>'0');

   --  Host Address Start point
   DMA_ds_HA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_HA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_HAH)='1'
         else (Others=>'0');

   DMA_ds_HA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_HA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_HAL)='1'
         else (Others=>'0');

   --  Next Descriptor Address
   DMA_ds_BDA_o_Hi(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_BDAH)='1'
         else (Others=>'0');

   DMA_ds_BDA_o_Hi(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_BDA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_BDAL)='1'
         else (Others=>'0');

   --  Length
   DMA_ds_Length_o_Hi(32-1 downto 0)
      <= DMA_ds_Length_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_LENG)='1'
         else (Others=>'0');

   --  Control word
   DMA_ds_Control_o_Hi(32-1 downto 0)
      <= DMA_ds_Control_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_CTRL)='1'
         else (Others=>'0');

   --  Status (Read only)
   DMA_ds_Status_o_Hi(32-1 downto 0)
      <= DMA_ds_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DMA_DS_STA)='1'
         else (Others=>'0');

   --  Tranferred bytes (Read only)
   DMA_ds_Transf_Bytes_o_Hi(32-1 downto 0)
      <= DMA_ds_Transf_Bytes_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DS_TRANSF_BC)='1'
         else (Others=>'0');

   --  Peripheral Address Start point
   DMA_ds_PA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_PA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_PAH)='1'
         else (Others=>'0');

   DMA_ds_PA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_PA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_PAL)='1'
         else (Others=>'0');

   --  Host Address Start point
   DMA_ds_HA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_HA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_HAH)='1'
         else (Others=>'0');

   DMA_ds_HA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_HA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_HAL)='1'
         else (Others=>'0');

   --  Next Descriptor Address
   DMA_ds_BDA_o_Lo(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
      <= DMA_ds_BDA_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_BDAH)='1'
         else (Others=>'0');

   DMA_ds_BDA_o_Lo(C_DBUS_WIDTH/2-1 downto 0)
      <= DMA_ds_BDA_i(C_DBUS_WIDTH/2-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_BDAL)='1'
         else (Others=>'0');

   --  Length
   DMA_ds_Length_o_Lo(32-1 downto 0)
      <= DMA_ds_Length_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_LENG)='1'
         else (Others=>'0');

   --  Control word
   DMA_ds_Control_o_Lo(32-1 downto 0)
      <= DMA_ds_Control_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_CTRL)='1'
         else (Others=>'0');

   --  Status (Read only)
   DMA_ds_Status_o_Lo(32-1 downto 0)
      <= DMA_ds_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DMA_DS_STA)='1'
         else (Others=>'0');

   --  Tranferred bytes (Read only)
   DMA_ds_Transf_Bytes_o_Lo(32-1 downto 0)
      <= DMA_ds_Transf_Bytes_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DS_TRANSF_BC)='1'
         else (Others=>'0');


   --------------------------------------------------------------------------
   -- CTL
   --------------------------------------------------------------------------
   ctl_td_o_Hi(32-1 downto 0)
      <= ctl_td_r(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_CTL_CLASS)='1'
         else (Others=>'0');

   ctl_td_o_Lo(32-1 downto 0)
      <= ctl_td_r(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_CTL_CLASS)='1'
         else (Others=>'0');

   --------------------------------------------------------------------------
   -- DLM
   --------------------------------------------------------------------------
   dlm_rd_o_Hi(32-1 downto 0)
      <= dlm_rd_r(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DLM_CLASS)='1'
         else (Others=>'0');

   dlm_rd_o_Lo(32-1 downto 0)
      <= dlm_rd_r(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DLM_CLASS)='1'
         else (Others=>'0');


   --------------------------------------------------------------------------
   -- System Interrupt Status
   --------------------------------------------------------------------------
   Sys_Int_Status_o_Hi(32-1 downto 0)
      <= (Sys_Int_Status_i(32-1 downto 0) and Sys_Int_Enable_i(32-1 downto 0)) when Reg_RdMuxer_Hi(CINT_ADDR_IRQ_STAT)='1'
         else (Others=>'0');

   Sys_Int_Enable_o_Hi(32-1 downto 0)
      <= Sys_Int_Enable_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_IRQ_EN)='1'
         else (Others=>'0');

   Sys_Int_Status_o_Lo(32-1 downto 0)
      <= (Sys_Int_Status_i(32-1 downto 0) and Sys_Int_Enable_i(32-1 downto 0)) when Reg_RdMuxer_Lo(CINT_ADDR_IRQ_STAT)='1'
         else (Others=>'0');

   Sys_Int_Enable_o_Lo(32-1 downto 0)
      <= Sys_Int_Enable_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_IRQ_EN)='1'
         else (Others=>'0');


   -- ----------------------------------------------------------------------------------
   -- ----------------------------------------------------------------------------------
   Gen_IG_Read:  if IMP_INT_GENERATOR generate

   --------------------------------------------------------------------------
   -- Interrupt Generator Latency
   --------------------------------------------------------------------------
   IG_Latency_o_Hi(32-1 downto 0)
      <= IG_Latency_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_IG_LATENCY)='1'
         else (Others=>'0');

   IG_Latency_o_Lo(32-1 downto 0)
      <= IG_Latency_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_IG_LATENCY)='1'
         else (Others=>'0');
   --------------------------------------------------------------------------
   -- Interrupt Generator Statistics
   --------------------------------------------------------------------------
   IG_Num_Assert_o_Hi(32-1 downto 0)
      <= IG_Num_Assert_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_IG_NUM_ASSERT)='1'
         else (Others=>'0');

   IG_Num_Deassert_o_Hi(32-1 downto 0)
      <= IG_Num_Deassert_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_IG_NUM_DEASSERT)='1'
         else (Others=>'0');

   IG_Num_Assert_o_Lo(32-1 downto 0)
      <= IG_Num_Assert_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_IG_NUM_ASSERT)='1'
         else (Others=>'0');

   IG_Num_Deassert_o_Lo(32-1 downto 0)
      <= IG_Num_Deassert_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_IG_NUM_DEASSERT)='1'
         else (Others=>'0');

   end generate;


   NotGen_IG_Read:  if not IMP_INT_GENERATOR generate

   IG_Latency_o_Hi(32-1 downto 0)      <= (Others=>'0');
   IG_Latency_o_Lo(32-1 downto 0)      <= (Others=>'0');
   IG_Num_Assert_o_Hi(32-1 downto 0)   <= (Others=>'0');
   IG_Num_Deassert_o_Hi(32-1 downto 0) <= (Others=>'0');
   IG_Num_Assert_o_Lo(32-1 downto 0)   <= (Others=>'0');
   IG_Num_Deassert_o_Lo(32-1 downto 0) <= (Others=>'0');

   end generate;


   --------------------------------------------------------------------------
   --  System Error
   --------------------------------------------------------------------------
   Synch_Sys_Error_i:
   process ( trn_clk, trn_lnk_up_n)
   begin
     if trn_lnk_up_n = '1' then
        Sys_Error_i                            <= (OTHERS => '0');
        eb_FIFO_OverWritten                    <= '0';
     elsif trn_clk'event and trn_clk = '1' then
        Sys_Error_i(CINT_BIT_TX_TOUT_IN_SER)   <= Tx_TimeOut;
        Sys_Error_i(CINT_BIT_EB_TOUT_IN_SER)   <= Tx_eb_TimeOut;
        Sys_Error_i(CINT_BIT_EB_OVERWRITTEN)   <= eb_FIFO_OverWritten;
        --  !!!!!!!!!!!!!! capture eb_FIFO overflow, temp cleared by MRd_Channel_Rst_i 
        eb_FIFO_OverWritten      <= (not MRd_Channel_Rst_i) and (eb_FIFO_ow or eb_FIFO_OverWritten);
     end if;
   end process;


   --------------------------------------------------------------------------
   --  General Status and Control
   --------------------------------------------------------------------------
   Synch_General_Status_i:
   process ( trn_clk, trn_lnk_up_n)
   begin
     if trn_lnk_up_n = '1' then
       General_Status_i  <= (OTHERS => '0');
     elsif trn_clk'event and trn_clk = '1' then
       General_Status_i(32-1 downto 32-16)
                       <= cfg_dcommand;
       General_Status_i(CINT_BIT_LWIDTH_IN_GSR_TOP downto CINT_BIT_LWIDTH_IN_GSR_BOT)
                       <= pcie_link_width;
       General_Status_i(CINT_BIT_ICAP_BUSY_IN_GSR)
                       <= icap_Busy;
--       General_Status_i(CINT_BIT_DG_AVAIL_IN_GSR)
--                       <= DG_is_Available;
--       General_Status_i(CINT_BIT_LINK_ACT_IN_GSR+1 downto CINT_BIT_LINK_ACT_IN_GSR)
--                       <= protocol_link_act;

--       General_Status_i(8) <= CTL_read_counter(6-1);   ---- DEBUG !!!
     end if;
   end process;



   Sys_Error_o_Hi(32-1 downto 0)
      <= Sys_Error_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_ERROR)='1'
         else (Others=>'0');

   General_Status_o_Hi(32-1 downto 0)
      <= General_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_STATUS)='1'
         else (Others=>'0');

   General_Control_o_Hi(32-1 downto 0)
      <= General_Control_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_CONTROL)='1'
         else (Others=>'0');

   Sys_Error_o_Lo(32-1 downto 0)
      <= Sys_Error_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_ERROR)='1'
         else (Others=>'0');

   General_Status_o_Lo(32-1 downto 0)
      <= General_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_STATUS)='1'
         else (Others=>'0');

   General_Control_o_Lo(32-1 downto 0)
      <= General_Control_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_CONTROL)='1'
         else (Others=>'0');


   --------------------------------------------------------------------------
   -- ICAP
   --------------------------------------------------------------------------
   icap_O_o_Hi(32-1 downto 0)
      <= icap_O(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_ICAP)='1'
         else (Others=>'0');

   icap_O_o_Lo(32-1 downto 0)
      <= icap_O(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_ICAP)='1'
         else (Others=>'0');

   --------------------------------------------------------------------------
   -- FIFO Statuses (read only)
   --------------------------------------------------------------------------
   eb_FIFO_Status_o_Hi(32-1 downto 0)
      <= eb_FIFO_Status_r1(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_EB_STACON)='1'
         else (Others=>'0');

   eb_FIFO_Status_o_Lo(32-1 downto 0)
      <= eb_FIFO_Status_r1(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_EB_STACON)='1'
         else (Others=>'0');

--   --------------------------------------------------------------------------
--   -- Optical Link Status
--   --------------------------------------------------------------------------
--   Opto_Link_Status_o_Hi(32-1 downto 0)
--      <= Opto_Link_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_PROTOCOL_STACON)='1'
--         else (Others=>'0');
--
--   Opto_link_Status_o_Lo(32-1 downto 0)
--      <= Opto_Link_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_PROTOCOL_STACON)='1'
--         else (Others=>'0');
--
--   --------------------------------------------------------------------------
--   -- Class CTL status
--   --------------------------------------------------------------------------
--   class_CTL_Status_o_Hi(32-1 downto 0)
--      <= class_CTL_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_TC_STATUS)='1'
--         else (Others=>'0');
--
--   class_CTL_Status_o_Lo(32-1 downto 0)
--      <= class_CTL_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_TC_STATUS)='1'
--         else (Others=>'0');
--
--   --------------------------------------------------------------------------
--   -- Data generator Status
--   --------------------------------------------------------------------------
--   DG_Status_o_Hi(32-1 downto 0)
--      <= DG_Status_i(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_DG_CTRL)='1'
--         else (Others=>'0');
--
--   DG_Status_o_Lo(32-1 downto 0)
--      <= DG_Status_i(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_DG_CTRL)='1'
--         else (Others=>'0');

   --------------------------------------------------------------------------
   -- Hardware version
   --------------------------------------------------------------------------
   HW_Version_o_Hi(32-1 downto 0)
      <= C_DESIGN_ID(32-1 downto 0) when Reg_RdMuxer_Hi(CINT_ADDR_VERSION)='1'
         else (Others=>'0');

   HW_Version_o_Lo(32-1 downto 0)
      <= C_DESIGN_ID(32-1 downto 0) when Reg_RdMuxer_Lo(CINT_ADDR_VERSION)='1'
         else (Others=>'0');

-----------------------------------------------------
-- Sequential : Regs_RdQout_i
-- 
   Synch_Regs_RdQout:
   process ( trn_clk, trn_lnk_up_n)
   begin
      if trn_lnk_up_n = '1' then
         Regs_RdQout_i <= (OTHERS =>'0');

      elsif trn_clk'event and trn_clk = '1' then

         Regs_RdQout_i(64-1 downto 32)        <=  
                                  HW_Version_o_Hi     (32-1 downto 0)

                              or  Sys_Error_o_Hi      (32-1 downto 0)
                              or  General_Status_o_Hi (32-1 downto 0)
                              or  General_Control_o_Hi(32-1 downto 0)

                              or  Sys_Int_Status_o_Hi (32-1 downto 0)
                              or  Sys_Int_Enable_o_Hi (32-1 downto 0)

--                              or  DMA_us_PA_o_Hi      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_PA_o_Hi      (32-1   downto          0)
                              or  DMA_us_HA_o_Hi      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_HA_o_Hi      (32-1   downto          0)
                              or  DMA_us_BDA_o_Hi     (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_BDA_o_Hi     (32-1   downto          0)
                              or  DMA_us_Length_o_Hi  (32-1 downto 0)
                              or  DMA_us_Control_o_Hi (32-1 downto 0)
                              or  DMA_us_Status_o_Hi  (32-1 downto 0)
                              or  DMA_us_Transf_Bytes_o_Hi  (32-1 downto 0)

--                              or  DMA_ds_PA_o_Hi      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_PA_o_Hi      (32-1   downto          0)
                              or  DMA_ds_HA_o_Hi      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_HA_o_Hi      (32-1   downto          0)
                              or  DMA_ds_BDA_o_Hi     (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_BDA_o_Hi     (32-1   downto          0)
                              or  DMA_ds_Length_o_Hi  (32-1 downto 0)
                              or  DMA_ds_Control_o_Hi (32-1 downto 0)
                              or  DMA_ds_Status_o_Hi  (32-1 downto 0)
                              or  DMA_ds_Transf_Bytes_o_Hi  (32-1 downto 0)

                              or  IG_Latency_o_Hi     (32-1 downto 0)
                              or  IG_Num_Assert_o_Hi  (32-1 downto 0)
                              or  IG_Num_Deassert_o_Hi(32-1 downto 0)

--                              or  DG_Status_o_Hi      (32-1 downto 0)
--                              or  class_CTL_Status_o_Hi  (32-1 downto 0)

--                              or  icap_O_o_Hi         (32-1 downto 0)
--                              or  Opto_Link_Status_o_Hi (32-1 downto 0)
                              or  eb_FIFO_Status_o_Hi (32-1 downto 0)
--										or  dlm_rd_o_Hi
--										or  ctl_td_o_Hi
                              ;


         Regs_RdQout_i(32-1 downto 0)        <=  
                                  HW_Version_o_Lo     (32-1 downto 0)

                              or  Sys_Error_o_Lo      (32-1 downto 0)
                              or  General_Status_o_Lo (32-1 downto 0)
                              or  General_Control_o_Lo(32-1 downto 0)

                              or  Sys_Int_Status_o_Lo (32-1 downto 0)
                              or  Sys_Int_Enable_o_Lo (32-1 downto 0)

--                              or  DMA_us_PA_o_Lo      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_PA_o_Lo      (32-1   downto          0)
                              or  DMA_us_HA_o_Lo      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_HA_o_Lo      (32-1   downto          0)
                              or  DMA_us_BDA_o_Lo     (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_us_BDA_o_Lo     (32-1   downto          0)
                              or  DMA_us_Length_o_Lo  (32-1 downto 0)
                              or  DMA_us_Control_o_Lo (32-1 downto 0)
                              or  DMA_us_Status_o_Lo  (32-1 downto 0)
                              or  DMA_us_Transf_Bytes_o_Lo  (32-1 downto 0)

--                              or  DMA_ds_PA_o_Lo      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_PA_o_Lo      (32-1   downto          0)
                              or  DMA_ds_HA_o_Lo      (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_HA_o_Lo      (32-1   downto          0)
                              or  DMA_ds_BDA_o_Lo     (C_DBUS_WIDTH-1 downto 32)
                              or  DMA_ds_BDA_o_Lo     (32-1   downto          0)
                              or  DMA_ds_Length_o_Lo  (32-1 downto 0)
                              or  DMA_ds_Control_o_Lo (32-1 downto 0)
                              or  DMA_ds_Status_o_Lo  (32-1 downto 0)
                              or  DMA_ds_Transf_Bytes_o_Lo  (32-1 downto 0)

                              or  IG_Latency_o_Lo     (32-1 downto 0)
                              or  IG_Num_Assert_o_Lo  (32-1 downto 0)
                              or  IG_Num_Deassert_o_Lo(32-1 downto 0)

--                              or  DG_Status_o_Lo      (32-1 downto 0)
--                              or  class_CTL_Status_o_Lo  (32-1 downto 0)

--                              or  icap_O_o_Lo(32-1 downto 0)
--                              or  Opto_Link_Status_o_Lo (32-1 downto 0)
                              or  eb_FIFO_Status_o_Lo (32-1 downto 0)
--										or  dlm_rd_o_Lo
--										or  ctl_td_o_Lo
                              ;

      end if;
   end process;


end Behavioral;
