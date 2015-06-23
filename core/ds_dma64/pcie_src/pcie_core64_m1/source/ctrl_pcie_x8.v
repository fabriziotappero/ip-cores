//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : ctrl_pcie_x8.v
//--------------------------------------------------------------------------------
// Description: This is the top-level PCI Express wrapper.
//--------------------------------------------------------------------------------
`timescale 1ns/1ns

module ctrl_pcie_x8 # ( 
  parameter        C_XDEVICE = "xc5vsx50t",
  parameter        USE_V5FXT = 0,
  parameter        PCI_EXP_LINK_WIDTH = 8,
  parameter        PCI_EXP_INT_FREQ = 2,
  parameter        PCI_EXP_REF_FREQ = 1,
  parameter        PCI_EXP_TRN_DATA_WIDTH = 64,
  parameter        PCI_EXP_TRN_REM_WIDTH = 8,
  parameter        PCI_EXP_TRN_BUF_AV_WIDTH = 4,
  parameter        PCI_EXP_BAR_HIT_WIDTH = 7,
  parameter        PCI_EXP_FC_HDR_WIDTH = 8,
  parameter        PCI_EXP_FC_DATA_WIDTH = 12,
  parameter        PCI_EXP_CFG_DATA_WIDTH = 32,
  parameter        PCI_EXP_CFG_ADDR_WIDTH = 10,
  parameter        PCI_EXP_CFG_CPLHDR_WIDTH = 48,
  parameter        PCI_EXP_CFG_BUSNUM_WIDTH = 8,
  parameter        PCI_EXP_CFG_DEVNUM_WIDTH = 5,
  parameter        PCI_EXP_CFG_FUNNUM_WIDTH = 3,
  parameter        PCI_EXP_CFG_CAP_WIDTH = 16,
  parameter        PCI_EXP_CFG_WIDTH = 1024,
  
  parameter        VEN_ID_temp = 32'h00004953,
  parameter        VEN_ID = VEN_ID_temp[15 : 0],
  parameter        DEV_ID = 16'h5507,
  parameter        REV_ID = 8'h20,
  parameter        CLASS_CODE = 24'hFFFFFF,
  parameter        BAR0 = 32'hFFE00000,
  parameter        BAR1 = 32'hFFE00000,
  parameter        BAR2 = 32'h00000000,
  parameter        BAR3 = 32'h00000000,
  parameter        BAR4 = 32'h00000000,
  parameter        BAR5 = 32'h00000000,
  parameter        CARDBUS_CIS_PTR = 32'h00000000,
  parameter        SUBSYS_VEN_ID_temp = 32'h00004953,
  parameter        SUBSYS_ID_temp = 32'h00000001,
  parameter        SUBSYS_VEN_ID = SUBSYS_VEN_ID_temp[15 : 0],
  parameter        SUBSYS_ID = SUBSYS_ID_temp[15 : 0],
  parameter        XROM_BAR = 32'hFFF00001,
               
  parameter        INTR_MSG_NUM = 5'b00000,
  parameter        SLT_IMPL = 0,
  parameter        DEV_PORT_TYPE = 4'b0000,
  parameter        CAP_VER = 4'h1,
  
  parameter        CAPT_SLT_PWR_LIM_SC = 2'b00,
  parameter        CAPT_SLT_PWR_LIM_VA = 8'h00,
  parameter        PWR_INDI_PRSNT = 0,
  parameter        ATTN_INDI_PRSNT = 0,
  parameter        ATTN_BUTN_PRSNT = 0,
  parameter        EP_L1_ACCPT_LAT = 3'b111,
  parameter        EP_L0s_ACCPT_LAT = 3'b111,
  parameter        EXT_TAG_FLD_SUP = 1,
  parameter        PHANTM_FUNC_SUP = 2'b01,
  parameter        MPS = 3'b001,
  
  parameter        L1_EXIT_LAT = 3'b111,
  parameter        L0s_EXIT_LAT = 3'b111,
  parameter        ASPM_SUP = 2'b01,
  parameter        MAX_LNK_WDT = 6'b1000,
  parameter        MAX_LNK_SPD = 4'b1,
  
  parameter        ACK_TO = 16'h0204,
  parameter        RPLY_TO = 16'h060d,

  parameter        MSI = 4'b0000,

  parameter        PCI_CONFIG_SPACE_ACCESS = 0,
  parameter        EXT_CONFIG_SPACE_ACCESS = 0,
  
  parameter        TRM_TLP_DGST_ECRC = 1,
  parameter        FRCE_NOSCRMBL = 0,
  parameter        TWO_PLM_ATOCFGR = 0,
  
  parameter        PME_SUP = 5'h0,
  parameter        D2_SUP = 0,
  parameter        D1_SUP = 0,
  parameter        AUX_CT = 3'b000,
  parameter        DSI = 1,
  parameter        PME_CLK = 0,
  parameter        PM_CAP_VER = 3'b010,
  
  parameter        PWR_CON_D0_STATE = 8'h0,
  parameter        CON_SCL_FCTR_D0_STATE = 8'h0,
  parameter        PWR_CON_D1_STATE = 8'h0,
  parameter        CON_SCL_FCTR_D1_STATE = 8'h0,
  parameter        PWR_CON_D2_STATE = 8'h0,
  parameter        CON_SCL_FCTR_D2_STATE = 8'h0,
  parameter        PWR_CON_D3_STATE = 8'h0,
  parameter        CON_SCL_FCTR_D3_STATE = 8'h0,
  
  parameter        PWR_DIS_D0_STATE = 8'h0,
  parameter        DIS_SCL_FCTR_D0_STATE = 8'h0,
  parameter        PWR_DIS_D1_STATE = 8'h0,
  parameter        DIS_SCL_FCTR_D1_STATE = 8'h0,
  parameter        PWR_DIS_D2_STATE = 8'h0,
  parameter        DIS_SCL_FCTR_D2_STATE = 8'h0,
  parameter        PWR_DIS_D3_STATE = 8'h0,
  parameter        DIS_SCL_FCTR_D3_STATE = 8'h0,
  
  parameter        CAL_BLK_DISABLE = 0,
  parameter        SWAP_A_B_PAIRS = 0,
  
  parameter        INFINITECOMPLETIONS = "TRUE",
  parameter        VC0_CREDITS_PH = 1,
  parameter        VC0_CREDITS_NPH = 1,
  parameter        CPL_STREAMING_PRIORITIZE_P_NP = 1,
  
  parameter        SLOT_CLK = "TRUE",

  parameter        TX_DIFF_BOOST = "TRUE",
  parameter        TXDIFFCTRL = 3'b100,
  parameter        TXBUFDIFFCTRL = 3'b100,
  parameter        TXPREEMPHASIS = 3'b111,
  parameter        GT_Debug_Ports = 0,
  parameter        GTDEBUGPORTS = 0  
  
)
( 
       // PCI Express Fabric Interface
    output      [PCI_EXP_LINK_WIDTH-1 : 0]     pci_exp_txp,
    output      [PCI_EXP_LINK_WIDTH-1 : 0]     pci_exp_txn,            
    input       [PCI_EXP_LINK_WIDTH-1 : 0]     pci_exp_rxp,
    input       [PCI_EXP_LINK_WIDTH-1 : 0]     pci_exp_rxn,



    // Transaction (TRN) Interface
    output                                     trn_clk,
    output                                     trn_reset_n,
    output                                     trn_lnk_up_n,

    // Tx
    input       [PCI_EXP_TRN_DATA_WIDTH-1 : 0] trn_td,
    input       [PCI_EXP_TRN_REM_WIDTH-1 : 0]  trn_trem_n,
    input                                      trn_tsof_n,
    input                                      trn_teof_n,
    input                                      trn_tsrc_rdy_n,
    output                                     trn_tdst_rdy_n,
    output                                     trn_tdst_dsc_n,
    input                                      trn_tsrc_dsc_n,
    input                                      trn_terrfwd_n,
    output      [PCI_EXP_TRN_BUF_AV_WIDTH-1:0] trn_tbuf_av,
    
    
    // Rx
    output [PCI_EXP_TRN_DATA_WIDTH-1 : 0]      trn_rd,
    output [PCI_EXP_TRN_REM_WIDTH-1 : 0]       trn_rrem_n,
    output                                     trn_rsof_n,
    output                                     trn_reof_n,
    output                                     trn_rsrc_rdy_n,
    output                                     trn_rsrc_dsc_n,
    input                                      trn_rdst_rdy_n,
    output                                     trn_rerrfwd_n,
    input                                      trn_rnp_ok_n,
    output [PCI_EXP_BAR_HIT_WIDTH-1 : 0]       trn_rbar_hit_n,
    output [PCI_EXP_FC_HDR_WIDTH-1 : 0]        trn_rfc_nph_av,
    output [PCI_EXP_FC_DATA_WIDTH-1 : 0]       trn_rfc_npd_av,
    output [PCI_EXP_FC_HDR_WIDTH-1 : 0]        trn_rfc_ph_av,
    output [PCI_EXP_FC_DATA_WIDTH-1 : 0]       trn_rfc_pd_av,
    input  trn_rcpl_streaming_n,
    

    // Host (CFG) Interface
    output [PCI_EXP_CFG_DATA_WIDTH-1 : 0]      cfg_do,
    output                                     cfg_rd_wr_done_n,
    input  [PCI_EXP_CFG_DATA_WIDTH-1 : 0]      cfg_di,
    input  [PCI_EXP_CFG_DATA_WIDTH/8-1 : 0]    cfg_byte_en_n,
    input  [PCI_EXP_CFG_ADDR_WIDTH-1 : 0]      cfg_dwaddr,
    input                                      cfg_wr_en_n,
    input                                      cfg_rd_en_n,
    input                                      cfg_err_cor_n,
    input                                      cfg_err_ur_n,
    input                                      cfg_err_ecrc_n,
    input                                      cfg_err_cpl_timeout_n,
    input                                      cfg_err_cpl_abort_n,
    input                                      cfg_err_cpl_unexpect_n,
    input                                      cfg_err_posted_n,
    input  [PCI_EXP_CFG_CPLHDR_WIDTH-1 : 0]    cfg_err_tlp_cpl_header,

    output                                     cfg_err_cpl_rdy_n,
    input                                      cfg_err_locked_n, 
    input                                      cfg_interrupt_n,
    output                                     cfg_interrupt_rdy_n,
    input                                      cfg_interrupt_assert_n,
    input  [7 : 0]                             cfg_interrupt_di,
    output [7 : 0]                             cfg_interrupt_do,
    output [2 : 0]                             cfg_interrupt_mmenable,
    output                                     cfg_interrupt_msienable,
    output                                     cfg_to_turnoff_n,
    input                                      cfg_pm_wake_n,
    output [2 : 0]                             cfg_pcie_link_state_n,
    input                                      cfg_trn_pending_n,
    output [PCI_EXP_CFG_BUSNUM_WIDTH-1 : 0]    cfg_bus_number,
    output [PCI_EXP_CFG_DEVNUM_WIDTH-1 : 0]    cfg_device_number,
    output [PCI_EXP_CFG_FUNNUM_WIDTH-1 : 0]    cfg_function_number,
    input  [63 : 0]                            cfg_dsn,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_status,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_command,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_dstatus,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_dcommand,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_lstatus,
    output [PCI_EXP_CFG_CAP_WIDTH-1 : 0]       cfg_lcommand,
    input                                      fast_train_simulation_only,

    // System (SYS) Interface
    input                                      sys_clk,
    // sys_clk_n              : in  std_logic;
    output                                     refclkout,
    input                                      sys_reset_n
);  


wire [8*16-1 : 0]    gt_do_x;
wire [8-1 : 0]       gt_drdy_x;


  pcie_ep_top   #(

     // G_USE_DCM => 1,
     // G_USER_RESETS => 0,
     // G_SIM => 0,
     // G_CHIPSCOPE => 0,

      .USE_V5FXT ( USE_V5FXT),
      .INTF_CLK_FREQ ( PCI_EXP_INT_FREQ),
      .REF_CLK_FREQ ( PCI_EXP_REF_FREQ),
      .VEN_ID ( VEN_ID),
      .DEV_ID ( DEV_ID),
      .REV_ID ( REV_ID),
      .CLASS_CODE ( CLASS_CODE),
      .BAR0 ( BAR0),
      .BAR1 ( BAR1),
      .BAR2 ( BAR2),
      .BAR3 ( BAR3),
      .BAR4 ( BAR4),
      .BAR5 ( BAR5),
      .CARDBUS_CIS_PTR ( CARDBUS_CIS_PTR),
      .SUBSYS_VEN_ID ( SUBSYS_VEN_ID),
      .SUBSYS_ID ( SUBSYS_ID),
      .XROM_BAR ( XROM_BAR),
      .INTR_MSG_NUM ( INTR_MSG_NUM),
      .SLT_IMPL ( SLT_IMPL),
      .DEV_PORT_TYPE ( DEV_PORT_TYPE),
      .CAP_VER ( CAP_VER),
      .CAPT_SLT_PWR_LIM_SC ( CAPT_SLT_PWR_LIM_SC),
      .CAPT_SLT_PWR_LIM_VA ( CAPT_SLT_PWR_LIM_VA),
      .PWR_INDI_PRSNT ( PWR_INDI_PRSNT),
      .ATTN_INDI_PRSNT ( ATTN_INDI_PRSNT),
      .ATTN_BUTN_PRSNT ( ATTN_BUTN_PRSNT),
      .EP_L1_ACCPT_LAT ( EP_L1_ACCPT_LAT),
      .EP_L0s_ACCPT_LAT ( EP_L0s_ACCPT_LAT),
      .EXT_TAG_FLD_SUP ( EXT_TAG_FLD_SUP),
      .PHANTM_FUNC_SUP ( PHANTM_FUNC_SUP),
      .MPS ( MPS),
      .L1_EXIT_LAT ( L1_EXIT_LAT),
      .L0s_EXIT_LAT ( L0s_EXIT_LAT),
      .ASPM_SUP ( ASPM_SUP),
      .MAX_LNK_WDT ( MAX_LNK_WDT),
      .MAX_LNK_SPD ( MAX_LNK_SPD),
      .TRM_TLP_DGST_ECRC ( TRM_TLP_DGST_ECRC),
      .FRCE_NOSCRMBL ( FRCE_NOSCRMBL),
      .INFINITECOMPLETIONS ( INFINITECOMPLETIONS),
      .VC0_CREDITS_PH ( VC0_CREDITS_PH),
      .VC0_CREDITS_NPH ( VC0_CREDITS_NPH),
      .CPL_STREAMING_PRIORITIZE_P_NP ( CPL_STREAMING_PRIORITIZE_P_NP),
      .SLOT_CLOCK_CONFIG ( SLOT_CLK),
      .PME_SUP ( PME_SUP),
      .D2_SUP ( D2_SUP),
      .D1_SUP ( D1_SUP),
      .AUX_CT ( AUX_CT),
      .DSI ( DSI),
      .PME_CLK ( PME_CLK),
      .PM_CAP_VER ( PM_CAP_VER),
      .MSI_VECTOR ( MSI[2:0]),
      .MSI_8BIT_EN ( MSI[3]),
      .PWR_CON_D0_STATE ( PWR_CON_D0_STATE),
      .CON_SCL_FCTR_D0_STATE ( CON_SCL_FCTR_D0_STATE),
      .PWR_CON_D1_STATE ( PWR_CON_D1_STATE),
      .CON_SCL_FCTR_D1_STATE ( CON_SCL_FCTR_D1_STATE),
      .PWR_CON_D2_STATE ( PWR_CON_D2_STATE),
      .CON_SCL_FCTR_D2_STATE ( CON_SCL_FCTR_D2_STATE),
      .PWR_CON_D3_STATE ( PWR_CON_D3_STATE),
      .CON_SCL_FCTR_D3_STATE ( CON_SCL_FCTR_D3_STATE),
      .PWR_DIS_D0_STATE ( PWR_DIS_D0_STATE),
      .DIS_SCL_FCTR_D0_STATE ( DIS_SCL_FCTR_D0_STATE),
      .PWR_DIS_D1_STATE ( PWR_DIS_D1_STATE),
      .DIS_SCL_FCTR_D1_STATE ( DIS_SCL_FCTR_D1_STATE),
      .PWR_DIS_D2_STATE ( PWR_DIS_D2_STATE),
      .DIS_SCL_FCTR_D2_STATE ( DIS_SCL_FCTR_D2_STATE),
      .PWR_DIS_D3_STATE ( PWR_DIS_D3_STATE),
      .DIS_SCL_FCTR_D3_STATE ( DIS_SCL_FCTR_D3_STATE),
      .TXDIFFBOOST ( TX_DIFF_BOOST),
      .GTDEBUGPORTS ( GTDEBUGPORTS)
      )
  pcie_ep0 (

    // PCI Express Fabric Interface
    .pci_exp_txp            ( pci_exp_txp),
    .pci_exp_txn            ( pci_exp_txn),
    .pci_exp_rxp            ( pci_exp_rxp),
    .pci_exp_rxn            ( pci_exp_rxn),

`ifdef GTP_DEBUG    
    .GTPCLK_bufg(GTPCLK_bufg),
    .REFCLK_OUT_bufg(REFCLK_OUT_bufg),
    .LINK_UP(LINK_UP),
    .clock_lock(clock_lock),
    .pll_lock(pll_lock),
    .core_clk(core_clk),
    .user_clk(user_clk),
`endif

    // GTP/X Debug ports

    .gt_txdiffctrl_0        ( TXDIFFCTRL),
    .gt_txdiffctrl_1        ( TXDIFFCTRL),
    .gt_txbuffctrl_0        ( TXBUFDIFFCTRL),
    .gt_txbuffctrl_1        ( TXBUFDIFFCTRL),
    .gt_txpreemphesis_0     ( TXPREEMPHASIS),
    .gt_txpreemphesis_1     ( TXPREEMPHASIS),


    .gt_dclk                ( 1'b0),
    .gt_daddr               ( 0),
    .gt_den                 ( 0),
    .gt_dwen                ( 0),
    .gt_di                  ( 0),

    .gt_do                  ( gt_do_x),
    .gt_drdy                ( gt_drdy_x),


    // Transaction (TRN) Interface
    .trn_clk                ( trn_clk),
    .trn_reset_n            ( trn_reset_n),
    .trn_lnk_up_n           ( trn_lnk_up_n),

    // Tx
    .trn_td                 ( trn_td),

    .trn_trem_n             ( trn_trem_n),
    .trn_tsof_n             ( trn_tsof_n),
    .trn_teof_n             ( trn_teof_n),
    .trn_tsrc_rdy_n         ( trn_tsrc_rdy_n),
    .trn_tdst_rdy_n         ( trn_tdst_rdy_n),
    .trn_tdst_dsc_n         ( trn_tdst_dsc_n),
    .trn_tsrc_dsc_n         ( trn_tsrc_dsc_n),
    .trn_terrfwd_n          ( trn_terrfwd_n),
    .trn_tbuf_av            ( trn_tbuf_av),


    // Rx
    .trn_rd                 ( trn_rd),

    .trn_rrem_n             ( trn_rrem_n),
    .trn_rsof_n             ( trn_rsof_n),
    .trn_reof_n             ( trn_reof_n),
    .trn_rsrc_rdy_n         ( trn_rsrc_rdy_n),
    .trn_rsrc_dsc_n         ( trn_rsrc_dsc_n),
    .trn_rdst_rdy_n         ( trn_rdst_rdy_n),
    .trn_rerrfwd_n          ( trn_rerrfwd_n),
    .trn_rnp_ok_n           ( trn_rnp_ok_n),
    .trn_rbar_hit_n         ( trn_rbar_hit_n),
    .trn_rfc_nph_av         ( trn_rfc_nph_av),
    .trn_rfc_npd_av         ( trn_rfc_npd_av),
    .trn_rfc_ph_av          ( trn_rfc_ph_av),
    .trn_rfc_pd_av          ( trn_rfc_pd_av),
//    trn_rfc_cplh_av        => trn_rfc_cplh_av,
//    trn_rfc_cpld_av        => trn_rfc_cpld_av,
//    trn_pfc_nph_cl         => trn_pfc_nph_cl,
//    trn_pfc_npd_cl         => trn_pfc_npd_cl,
//    trn_pfc_ph_cl          => trn_pfc_ph_cl,
//    trn_pfc_pd_cl          => trn_pfc_pd_cl,
//    trn_pfc_cplh_cl        => trn_pfc_cplh_cl,
//    trn_pfc_cpld_cl        => trn_pfc_cpld_cl,
    .trn_rcpl_streaming_n   ( trn_rcpl_streaming_n),

    // Host (CFG) Interface
    .cfg_do                 ( cfg_do),
    .cfg_rd_wr_done_n       ( cfg_rd_wr_done_n),
    .cfg_di                 ( cfg_di),
    .cfg_byte_en_n          ( cfg_byte_en_n),
    .cfg_dwaddr             ( cfg_dwaddr),
    .cfg_wr_en_n            ( cfg_wr_en_n),
    .cfg_rd_en_n            ( cfg_rd_en_n),
    .cfg_err_cor_n          ( cfg_err_cor_n),
    .cfg_err_ur_n           ( cfg_err_ur_n),
    .cfg_err_ecrc_n         ( cfg_err_ecrc_n),
    .cfg_err_cpl_timeout_n  ( cfg_err_cpl_timeout_n),
    .cfg_err_cpl_abort_n    ( cfg_err_cpl_abort_n),
    .cfg_err_cpl_unexpect_n ( cfg_err_cpl_unexpect_n),
    .cfg_err_posted_n       ( cfg_err_posted_n),
    .cfg_err_locked_n       ( cfg_err_locked_n),
    .cfg_err_tlp_cpl_header ( cfg_err_tlp_cpl_header),
    .cfg_err_cpl_rdy_n      ( cfg_err_cpl_rdy_n),
    .cfg_interrupt_n        ( cfg_interrupt_n),
    .cfg_interrupt_rdy_n    ( cfg_interrupt_rdy_n),
    .cfg_interrupt_assert_n ( cfg_interrupt_assert_n),
    .cfg_interrupt_di       ( cfg_interrupt_di),
    .cfg_interrupt_do       ( cfg_interrupt_do),
    .cfg_interrupt_mmenable ( cfg_interrupt_mmenable),
    .cfg_interrupt_msienable ( cfg_interrupt_msienable),
    .cfg_turnoff_ok_n       ( 1'b1),
    .cfg_to_turnoff_n       ( cfg_to_turnoff_n),
    .cfg_pm_wake_n          ( cfg_pm_wake_n),
    .cfg_pcie_link_state_n  ( cfg_pcie_link_state_n),
    .cfg_trn_pending_n      ( cfg_trn_pending_n),
    .cfg_bus_number         ( cfg_bus_number),
    .cfg_device_number      ( cfg_device_number),
    .cfg_function_number    ( cfg_function_number),
    .cfg_dsn                ( cfg_dsn),
    .cfg_status             ( cfg_status),
    .cfg_command            ( cfg_command),
    .cfg_dstatus            ( cfg_dstatus),
    .cfg_dcommand           ( cfg_dcommand),
    .cfg_lstatus            ( cfg_lstatus),
    .cfg_lcommand           ( cfg_lcommand),

    // System (SYS) Interface
    .sys_clk              ( sys_clk),
    .refclkout              ( refclkout),
    .sys_reset_n            ( sys_reset_n),
    .fast_train_simulation_only ( fast_train_simulation_only)
  );

                

endmodule
