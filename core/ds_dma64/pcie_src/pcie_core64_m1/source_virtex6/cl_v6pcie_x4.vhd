-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : cl_v6pcie_x4.vhd
-- Version    : 2.3
-- Description: Virtex6 solution wrapper : Endpoint for PCI Express
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity cl_v6pcie_x4 is
   generic (
   PCIE_DRP_ENABLE                              : boolean := FALSE;
   ALLOW_X8_GEN2                                : boolean := FALSE;
   BAR0                                         : bit_vector := X"FFE00000";
   BAR1                                         : bit_vector := X"FFE00000";
   BAR2                                         : bit_vector := X"00000000";
   BAR3                                         : bit_vector := X"00000000";
   BAR4                                         : bit_vector := X"00000000";
   BAR5                                         : bit_vector := X"00000000";

   CARDBUS_CIS_POINTER                          : bit_vector := X"00000000";
   CLASS_CODE                                   : bit_vector := X"FFFFFF";
   CMD_INTX_IMPLEMENTED                         : boolean    := TRUE;
   CPL_TIMEOUT_DISABLE_SUPPORTED                : boolean    := FALSE;
   CPL_TIMEOUT_RANGES_SUPPORTED                 : bit_vector := X"2";

   DEV_CAP_ENDPOINT_L0S_LATENCY                 : integer    := 0;
   DEV_CAP_ENDPOINT_L1_LATENCY                  : integer    := 7;
   DEV_CAP_EXT_TAG_SUPPORTED                    : boolean    := FALSE;
   DEV_CAP_MAX_PAYLOAD_SUPPORTED                : integer    := 1;
   DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT            : integer    := 0;
   DEVICE_ID                                    : bit_vector := X"5507";

   DISABLE_LANE_REVERSAL                        : boolean    := FALSE;
   DISABLE_SCRAMBLING                           : boolean    := FALSE;
   DSN_BASE_PTR                                 : bit_vector := X"0";
   DSN_CAP_NEXTPTR                              : bit_vector := X"000";
   DSN_CAP_ON                                   : boolean    := FALSE;

   ENABLE_MSG_ROUTE                             : bit_vector := "00000000000";
   ENABLE_RX_TD_ECRC_TRIM                       : boolean    := TRUE;
   EXPANSION_ROM                                : bit_vector := X"00000000";
   EXT_CFG_CAP_PTR                              : bit_vector := X"3F";
   EXT_CFG_XP_CAP_PTR                           : bit_vector := X"3FF";
   HEADER_TYPE                                  : bit_vector := X"00";
   INTERRUPT_PIN                                : bit_vector := X"1";

   LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP       : boolean    := FALSE;
   LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP     : boolean    := FALSE;
   LINK_CAP_MAX_LINK_SPEED                      : bit_vector := X"2";
   LINK_CAP_MAX_LINK_WIDTH                      : bit_vector := X"04";
   LINK_CAP_MAX_LINK_WIDTH_int                  : integer    := 4;
   LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE         : boolean    := FALSE;

   LINK_CTRL2_DEEMPHASIS                        : boolean    := FALSE;
   LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE       : boolean    := FALSE;
   LINK_CTRL2_TARGET_LINK_SPEED                 : bit_vector := X"2";
   LINK_STATUS_SLOT_CLOCK_CONFIG                : boolean    := TRUE;

   LL_ACK_TIMEOUT                               : bit_vector := X"0000";
   LL_ACK_TIMEOUT_EN                            : boolean    := FALSE;
   LL_ACK_TIMEOUT_FUNC                          : integer    := 0;
   LL_REPLAY_TIMEOUT                            : bit_vector := X"0026";
   LL_REPLAY_TIMEOUT_EN                         : boolean    := TRUE;
   LL_REPLAY_TIMEOUT_FUNC                       : integer    := 1;

   LTSSM_MAX_LINK_WIDTH                         : bit_vector := X"04";
   MSI_CAP_MULTIMSGCAP                          : integer    := 0;
   MSI_CAP_MULTIMSG_EXTENSION                   : integer    := 0;
   MSI_CAP_ON                                   : boolean    := FALSE;
   MSI_CAP_PER_VECTOR_MASKING_CAPABLE           : boolean    := FALSE;
   MSI_CAP_64_BIT_ADDR_CAPABLE                  : boolean    := TRUE;

   MSIX_CAP_ON                                  : boolean    := FALSE;
   MSIX_CAP_PBA_BIR                             : integer    := 0;
   MSIX_CAP_PBA_OFFSET                          : bit_vector := X"0";
   MSIX_CAP_TABLE_BIR                           : integer    := 0;
   MSIX_CAP_TABLE_OFFSET                        : bit_vector := X"0";
   MSIX_CAP_TABLE_SIZE                          : bit_vector := X"000";

   PCIE_CAP_DEVICE_PORT_TYPE                    : bit_vector := X"0";
   PCIE_CAP_INT_MSG_NUM                         : bit_vector := X"1";
   PCIE_CAP_NEXTPTR                             : bit_vector := X"00";
   PIPE_PIPELINE_STAGES                         : integer    := 0;                -- 0 - 0 stages; 1 - 1 stage; 2 - 2 stages

   PM_CAP_DSI                                   : boolean    := FALSE;
   PM_CAP_D1SUPPORT                             : boolean    := FALSE;
   PM_CAP_D2SUPPORT                             : boolean    := FALSE;
   PM_CAP_NEXTPTR                               : bit_vector := X"60";
   PM_CAP_PMESUPPORT                            : bit_vector := X"0F";
   PM_CSR_NOSOFTRST                             : boolean    := TRUE;

   PM_DATA_SCALE0                               : bit_vector := X"0";
   PM_DATA_SCALE1                               : bit_vector := X"0";
   PM_DATA_SCALE2                               : bit_vector := X"0";
   PM_DATA_SCALE3                               : bit_vector := X"0";
   PM_DATA_SCALE4                               : bit_vector := X"0";
   PM_DATA_SCALE5                               : bit_vector := X"0";
   PM_DATA_SCALE6                               : bit_vector := X"0";
   PM_DATA_SCALE7                               : bit_vector := X"0";

   PM_DATA0                                     : bit_vector := X"00";
   PM_DATA1                                     : bit_vector := X"00";
   PM_DATA2                                     : bit_vector := X"00";
   PM_DATA3                                     : bit_vector := X"00";
   PM_DATA4                                     : bit_vector := X"00";
   PM_DATA5                                     : bit_vector := X"00";
   PM_DATA6                                     : bit_vector := X"00";
   PM_DATA7                                     : bit_vector := X"00";

   REF_CLK_FREQ                                 : integer    := 0;                        -- 0 - 100 MHz; 1 - 125 MHz; 2 - 250 MHz
   REVISION_ID                                  : bit_vector := X"20";
   SPARE_BIT0                                   : integer    := 0;
   SUBSYSTEM_ID                                 : bit_vector := X"0002";
   SUBSYSTEM_VENDOR_ID                          : bit_vector := X"4953";

   TL_RX_RAM_RADDR_LATENCY                      : integer    := 0;
   TL_RX_RAM_RDATA_LATENCY                      : integer    := 2;
   TL_RX_RAM_WRITE_LATENCY                      : integer    := 0;
   TL_TX_RAM_RADDR_LATENCY                      : integer    := 0;
   TL_TX_RAM_RDATA_LATENCY                      : integer    := 2;
   TL_TX_RAM_WRITE_LATENCY                      : integer    := 0;

   UPCONFIG_CAPABLE                             : boolean    := TRUE;
   USER_CLK_FREQ                                : integer    := 3;
   VC_BASE_PTR                                  : bit_vector := X"0";
   VC_CAP_NEXTPTR                               : bit_vector := X"000";
   VC_CAP_ON                                    : boolean    := FALSE;
   VC_CAP_REJECT_SNOOP_TRANSACTIONS             : boolean    := FALSE;

   VC0_CPL_INFINITE                             : boolean    := TRUE;
   VC0_RX_RAM_LIMIT                             : bit_vector := X"3FF";
   VC0_TOTAL_CREDITS_CD                         : integer    := 378;
   VC0_TOTAL_CREDITS_CH                         : integer    := 36;
   VC0_TOTAL_CREDITS_NPH                        : integer    := 12;
   VC0_TOTAL_CREDITS_PD                         : integer    := 32;
   VC0_TOTAL_CREDITS_PH                         : integer    := 32;
   VC0_TX_LASTPACKET                            : integer    := 28;

   VENDOR_ID                                    : bit_vector := X"4953";
   VSEC_BASE_PTR                                : bit_vector := X"0";
   VSEC_CAP_NEXTPTR                             : bit_vector := X"000";
   VSEC_CAP_ON                                  : boolean    := FALSE;

   AER_BASE_PTR                                 : bit_vector := X"128";
   AER_CAP_ECRC_CHECK_CAPABLE                   : boolean    := FALSE;
   AER_CAP_ECRC_GEN_CAPABLE                     : boolean    := FALSE;
   AER_CAP_ID                                   : bit_vector := X"0001";
   AER_CAP_INT_MSG_NUM_MSI                      : bit_vector := X"0a";
   AER_CAP_INT_MSG_NUM_MSIX                     : bit_vector := X"15";
   AER_CAP_NEXTPTR                              : bit_vector := X"160";
   AER_CAP_ON                                   : boolean    := FALSE;
   AER_CAP_PERMIT_ROOTERR_UPDATE                : boolean    := TRUE;
   AER_CAP_VERSION                              : bit_vector := X"1";

   CAPABILITIES_PTR                             : bit_vector := X"40";
   CRM_MODULE_RSTS                              : bit_vector := X"00";
   DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE          : boolean    := TRUE;
   DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE          : boolean    := TRUE;
   DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE         : boolean    := FALSE;
   DEV_CAP_ROLE_BASED_ERROR                     : boolean    := TRUE;
   DEV_CAP_RSVD_14_12                           : integer    := 0;
   DEV_CAP_RSVD_17_16                           : integer    := 0;
   DEV_CAP_RSVD_31_29                           : integer    := 0;
   DEV_CONTROL_AUX_POWER_SUPPORTED              : boolean    := FALSE;

   DISABLE_ASPM_L1_TIMER                        : boolean    := FALSE;
   DISABLE_BAR_FILTERING                        : boolean    := FALSE;
   DISABLE_ID_CHECK                             : boolean    := FALSE;
   DISABLE_RX_TC_FILTER                         : boolean    := FALSE;
   DNSTREAM_LINK_NUM                            : bit_vector := X"00";

   DSN_CAP_ID                                   : bit_vector := X"0003";
   DSN_CAP_VERSION                              : bit_vector := X"1";
   ENTER_RVRY_EI_L0                             : boolean    := TRUE;
   INFER_EI                                     : bit_vector := X"0c";
   IS_SWITCH                                    : boolean    := FALSE;

   LAST_CONFIG_DWORD                            : bit_vector := X"3FF";
   LINK_CAP_ASPM_SUPPORT                        : integer    := 1;
   LINK_CAP_CLOCK_POWER_MANAGEMENT              : boolean    := FALSE;
   LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1        : integer    := 7;
   LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2        : integer    := 7;
   LINK_CAP_L0S_EXIT_LATENCY_GEN1               : integer    := 7;
   LINK_CAP_L0S_EXIT_LATENCY_GEN2               : integer    := 7;
   LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1         : integer    := 7;
   LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2         : integer    := 7;
   LINK_CAP_L1_EXIT_LATENCY_GEN1                : integer    := 7;
   LINK_CAP_L1_EXIT_LATENCY_GEN2                : integer    := 7;
   LINK_CAP_RSVD_23_22                          : integer    := 0;
   LINK_CONTROL_RCB                             : integer    := 0;

   MSI_BASE_PTR                                 : bit_vector := X"48";
   MSI_CAP_ID                                   : bit_vector := X"05";
   MSI_CAP_NEXTPTR                              : bit_vector := X"60";
   MSIX_BASE_PTR                                : bit_vector := X"9c";
   MSIX_CAP_ID                                  : bit_vector := X"11";
   MSIX_CAP_NEXTPTR                             : bit_vector := X"00";
   N_FTS_COMCLK_GEN1                            : integer    := 255;
   N_FTS_COMCLK_GEN2                            : integer    := 254;
   N_FTS_GEN1                                   : integer    := 255;
   N_FTS_GEN2                                   : integer    := 255;

   PCIE_BASE_PTR                                : bit_vector := X"60";
   PCIE_CAP_CAPABILITY_ID                       : bit_vector := X"10";
   PCIE_CAP_CAPABILITY_VERSION                  : bit_vector := X"2";
   PCIE_CAP_ON                                  : boolean    := TRUE;
   PCIE_CAP_RSVD_15_14                          : integer    := 0;
   PCIE_CAP_SLOT_IMPLEMENTED                    : boolean    := FALSE;
   PCIE_REVISION                                : integer    := 2;
   PGL0_LANE                                    : integer    := 0;
   PGL1_LANE                                    : integer    := 1;
   PGL2_LANE                                    : integer    := 2;
   PGL3_LANE                                    : integer    := 3;
   PGL4_LANE                                    : integer    := 4;
   PGL5_LANE                                    : integer    := 5;
   PGL6_LANE                                    : integer    := 6;
   PGL7_LANE                                    : integer    := 7;
   PL_AUTO_CONFIG                               : integer    := 0;
   PL_FAST_TRAIN                                : boolean    := FALSE;

   PM_BASE_PTR                                  : bit_vector := X"40";
   PM_CAP_AUXCURRENT                            : integer    := 0;
   PM_CAP_ID                                    : bit_vector := X"01";
   PM_CAP_ON                                    : boolean    := TRUE;
   PM_CAP_PME_CLOCK                             : boolean    := FALSE;
   PM_CAP_RSVD_04                               : integer    := 0;
   PM_CAP_VERSION                               : integer    := 3;
   PM_CSR_BPCCEN                                : boolean    := FALSE;
   PM_CSR_B2B3                                  : boolean    := FALSE;

   RECRC_CHK                                    : integer    := 0;
   RECRC_CHK_TRIM                               : boolean    := FALSE;
   ROOT_CAP_CRS_SW_VISIBILITY                   : boolean    := FALSE;
   SELECT_DLL_IF                                : boolean    := FALSE;
   SLOT_CAP_ATT_BUTTON_PRESENT                  : boolean    := FALSE;
   SLOT_CAP_ATT_INDICATOR_PRESENT               : boolean    := FALSE;
   SLOT_CAP_ELEC_INTERLOCK_PRESENT              : boolean    := FALSE;
   SLOT_CAP_HOTPLUG_CAPABLE                     : boolean    := FALSE;
   SLOT_CAP_HOTPLUG_SURPRISE                    : boolean    := FALSE;
   SLOT_CAP_MRL_SENSOR_PRESENT                  : boolean    := FALSE;
   SLOT_CAP_NO_CMD_COMPLETED_SUPPORT            : boolean    := FALSE;
   SLOT_CAP_PHYSICAL_SLOT_NUM                   : bit_vector := X"0000";
   SLOT_CAP_POWER_CONTROLLER_PRESENT            : boolean    := FALSE;
   SLOT_CAP_POWER_INDICATOR_PRESENT             : boolean    := FALSE;
   SLOT_CAP_SLOT_POWER_LIMIT_SCALE              : integer    := 0;
   SLOT_CAP_SLOT_POWER_LIMIT_VALUE              : bit_vector := X"00";
   SPARE_BIT1                                   : integer    := 0;
   SPARE_BIT2                                   : integer    := 0;
   SPARE_BIT3                                   : integer    := 0;
   SPARE_BIT4                                   : integer    := 0;
   SPARE_BIT5                                   : integer    := 0;
   SPARE_BIT6                                   : integer    := 0;
   SPARE_BIT7                                   : integer    := 0;
   SPARE_BIT8                                   : integer    := 0;
   SPARE_BYTE0                                  : bit_vector := X"00";
   SPARE_BYTE1                                  : bit_vector := X"00";
   SPARE_BYTE2                                  : bit_vector := X"00";
   SPARE_BYTE3                                  : bit_vector := X"00";
   SPARE_WORD0                                  : bit_vector := X"00000000";
   SPARE_WORD1                                  : bit_vector := X"00000000";
   SPARE_WORD2                                  : bit_vector := X"00000000";
   SPARE_WORD3                                  : bit_vector := X"00000000";

   TL_RBYPASS                                   : boolean    := FALSE;
   TL_TFC_DISABLE                               : boolean    := FALSE;
   TL_TX_CHECKS_DISABLE                         : boolean    := FALSE;
   EXIT_LOOPBACK_ON_EI                          : boolean    := TRUE;
   UPSTREAM_FACING                              : boolean    := TRUE;
   UR_INV_REQ                                   : boolean    := TRUE;

   VC_CAP_ID                                    : bit_vector := X"0002";
   VC_CAP_VERSION                               : bit_vector := X"1";
   VSEC_CAP_HDR_ID                              : bit_vector := X"1234";
   VSEC_CAP_HDR_LENGTH                          : bit_vector := X"018";
   VSEC_CAP_HDR_REVISION                        : bit_vector := X"1";
   VSEC_CAP_ID                                  : bit_vector := X"000b";
   VSEC_CAP_IS_LINK_VISIBLE                     : boolean    := TRUE;
   VSEC_CAP_VERSION                             : bit_vector := X"1"
      );
   port (
      ---------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface
      ---------------------------------------------------------

      -- Tx
      pci_exp_txp                               : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      pci_exp_txn                               : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);

      -- Rx
      pci_exp_rxp                               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      pci_exp_rxn                               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);

      ---------------------------------------------------------
      -- 2. Transaction (TRN) Interface
      ---------------------------------------------------------

      -- Common
      user_clk_out                              : out std_logic;
      user_reset_out                            : out std_logic;
      user_lnk_up                               : out std_logic;

      -- Tx
      tx_buf_av                                 : out std_logic_vector(5 downto 0);
      tx_cfg_req                                : out std_logic;
      tx_err_drop                               : out std_logic;

      s_axis_tx_tready                          : out std_logic;
      s_axis_tx_tdata                           : in std_logic_vector(63 downto 0);
      s_axis_tx_tstrb                           : in std_logic_vector(7 downto 0);
      s_axis_tx_tuser                           : in std_logic_vector(3 downto 0);
      s_axis_tx_tlast                           : in std_logic;
      s_axis_tx_tvalid                          : in std_logic;

      tx_cfg_gnt                                : in std_logic;

      -- Rx
      m_axis_rx_tdata                           : out std_logic_vector(63 downto 0);
      m_axis_rx_tstrb                           : out std_logic_vector(7 downto 0);
      m_axis_rx_tlast                           : out std_logic;
      m_axis_rx_tvalid                          : out std_logic;
      m_axis_rx_tuser                           : out std_logic_vector(21 downto 0);
      m_axis_rx_tready                          : in std_logic;
      rx_np_ok                                  : in std_logic;

      -- Flow Control
      fc_cpld                                   : out std_logic_vector(11 downto 0);
      fc_cplh                                   : out std_logic_vector(7 downto 0);
      fc_npd                                    : out std_logic_vector(11 downto 0);
      fc_nph                                    : out std_logic_vector(7 downto 0);
      fc_pd                                     : out std_logic_vector(11 downto 0);
      fc_ph                                     : out std_logic_vector(7 downto 0);
      fc_sel                                    : in std_logic_vector(2 downto 0);

      ---------------------------------------------------------
      -- 3. Configuration (CFG) Interface
      ---------------------------------------------------------

      cfg_do                                    : out std_logic_vector(31 downto 0);
      cfg_rd_wr_done                            : out std_logic;
      cfg_di                                    : in std_logic_vector(31 downto 0);
      cfg_byte_en                               : in std_logic_vector(3 downto 0);
      cfg_dwaddr                                : in std_logic_vector(9 downto 0);
      cfg_wr_en                                 : in std_logic;
      cfg_rd_en                                 : in std_logic;

      cfg_err_cor                               : in std_logic;
      cfg_err_ur                                : in std_logic;
      cfg_err_ecrc                              : in std_logic;
      cfg_err_cpl_timeout                       : in std_logic;
      cfg_err_cpl_abort                         : in std_logic;
      cfg_err_cpl_unexpect                      : in std_logic;
      cfg_err_posted                            : in std_logic;
      cfg_err_locked                            : in std_logic;
      cfg_err_tlp_cpl_header                    : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy                           : out std_logic;
      cfg_interrupt                             : in std_logic;
      cfg_interrupt_rdy                         : out std_logic;
      cfg_interrupt_assert                      : in std_logic;
      cfg_interrupt_di                          : in std_logic_vector(7 downto 0);
      cfg_interrupt_do                          : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                    : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                   : out std_logic;
      cfg_interrupt_msixenable                  : out std_logic;
      cfg_interrupt_msixfm                      : out std_logic;
      cfg_turnoff_ok                            : in std_logic;
      cfg_to_turnoff                            : out std_logic;
      cfg_trn_pending                           : in std_logic;
      cfg_pm_wake                               : in std_logic;
      cfg_bus_number                            : out std_logic_vector(7 downto 0);
      cfg_device_number                         : out std_logic_vector(4 downto 0);
      cfg_function_number                       : out std_logic_vector(2 downto 0);
      cfg_status                                : out std_logic_vector(15 downto 0);
      cfg_command                               : out std_logic_vector(15 downto 0);
      cfg_dstatus                               : out std_logic_vector(15 downto 0);
      cfg_dcommand                              : out std_logic_vector(15 downto 0);
      cfg_lstatus                               : out std_logic_vector(15 downto 0);
      cfg_lcommand                              : out std_logic_vector(15 downto 0);
      cfg_dcommand2                             : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state                       : out std_logic_vector(2 downto 0);
      cfg_dsn                                   : in std_logic_vector(63 downto 0);
      cfg_pmcsr_pme_en                          : out std_logic;
      cfg_pmcsr_pme_status                      : out std_logic;
      cfg_pmcsr_powerstate                      : out std_logic_vector(1 downto 0);

      ---------------------------------------------------------
      -- 4. Physical Layer Control and Status (PL) Interface
      ---------------------------------------------------------

      pl_initial_link_width                     : out std_logic_vector(2 downto 0);
      pl_lane_reversal_mode                     : out std_logic_vector(1 downto 0);
      pl_link_gen2_capable                      : out std_logic;
      pl_link_partner_gen2_supported            : out std_logic;
      pl_link_upcfg_capable                     : out std_logic;
      pl_ltssm_state                            : out std_logic_vector(5 downto 0);
      pl_received_hot_rst                       : out std_logic;
      pl_sel_link_rate                          : out std_logic;
      pl_sel_link_width                         : out std_logic_vector(1 downto 0);
      pl_directed_link_auton                    : in std_logic;
      pl_directed_link_change                   : in std_logic_vector(1 downto 0);
      pl_directed_link_speed                    : in std_logic;
      pl_directed_link_width                    : in std_logic_vector(1 downto 0);
      pl_upstream_prefer_deemph                 : in std_logic;

      ---------------------------------------------------------
      -- 5. System  (SYS) Interface
      ---------------------------------------------------------

      sys_clk                                   : in std_logic;
      sys_reset                                 : in std_logic
   );
end cl_v6pcie_x4;

architecture v6_pcie of cl_v6pcie_x4 is

   attribute CORE_GENERATION_INFO : string;
   attribute CORE_GENERATION_INFO of v6_pcie : ARCHITECTURE is
     "cl_v6pcie_x4,v6_pcie_v2_3,{LINK_CAP_MAX_LINK_SPEED=2,LINK_CAP_MAX_LINK_WIDTH=04,PCIE_CAP_DEVICE_PORT_TYPE=0000,DEV_CAP_MAX_PAYLOAD_SUPPORTED=1,USER_CLK_FREQ=3,REF_CLK_FREQ=0,MSI_CAP_ON=FALSE,MSI_CAP_MULTIMSGCAP=0,MSI_CAP_MULTIMSG_EXTENSION=0,MSIX_CAP_ON=FALSE,TL_TX_RAM_RADDR_LATENCY=0,TL_TX_RAM_RDATA_LATENCY=2,TL_RX_RAM_RADDR_LATENCY=0,TL_RX_RAM_RDATA_LATENCY=2,TL_RX_RAM_WRITE_LATENCY=0,VC0_TX_LASTPACKET=28,VC0_RX_RAM_LIMIT=3FF,VC0_TOTAL_CREDITS_PH=32,VC0_TOTAL_CREDITS_PD=32,VC0_TOTAL_CREDITS_NPH=12,VC0_TOTAL_CREDITS_CH=36,VC0_TOTAL_CREDITS_CD=378,VC0_CPL_INFINITE=TRUE,DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT=0,DEV_CAP_EXT_TAG_SUPPORTED=FALSE,LINK_STATUS_SLOT_CLOCK_CONFIG=TRUE,ENABLE_RX_TD_ECRC_TRIM=TRUE,DISABLE_LANE_REVERSAL=TRUE,DISABLE_SCRAMBLING=FALSE,DSN_CAP_ON=FALSE,PIPE_PIPELINE_STAGES=0,REVISION_ID=20,VC_CAP_ON=FALSE}";

   component axi_basic_top
   generic (
      C_DATA_WIDTH              : integer := 32;     -- rx/tx interface data width
      C_FAMILY                  : string  := "x7";    -- targeted fpga family
      C_ROOT_PORT               : BOOLEAN := FALSE; -- pcie block is in root port mode
      C_PM_PRIORITY             : BOOLEAN := FALSE; -- disable tx packet boundary thrtl
      TCQ                       : integer := 1;      -- clock to q time

      C_REM_WIDTH               : integer := 1;      -- trem/rrem width
      C_STRB_WIDTH              : integer := 4       -- tstrb width
   );
   port (
      -----------------------------------------------
      -- user design I/O
      -----------------------------------------------

      -- AXI TX
      -------------
      s_axis_tx_tdata         : in std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      s_axis_tx_tvalid        : in std_logic                                   := '0';
      s_axis_tx_tready        : out std_logic                                  := '0';
      s_axis_tx_tstrb         : in std_logic_vector(C_STRB_WIDTH - 1 downto 0) := (others=>'0');
      s_axis_tx_tlast         : in std_logic                                   := '0';
      s_axis_tx_tuser         : in std_logic_vector(3 downto 0) := (others=>'0');

      -- AXI RX
      -------------
      m_axis_rx_tdata         : out std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      m_axis_rx_tvalid        : out std_logic                                   := '0';
      m_axis_rx_tready        : in std_logic                                    := '0';
      m_axis_rx_tstrb         : out std_logic_vector(C_STRB_WIDTH - 1 downto 0) := (others=>'0');
      m_axis_rx_tlast         : out std_logic                                   := '0';
      m_axis_rx_tuser         : out std_logic_vector(21 downto 0) := (others=>'0');

      -- user misc.
      -------------
      user_turnoff_ok         : in std_logic                                   := '0';
      user_tcfg_gnt           : in std_logic                                   := '0';

      -----------------------------------------------
      -- PCIe block I/O
      -----------------------------------------------

      -- TRN TX
      -------------
      trn_td                  : out std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      trn_tsof                : out std_logic                                   := '0';
      trn_teof                : out std_logic                                   := '0';
      trn_tsrc_rdy            : out std_logic                                   := '0';
      trn_tdst_rdy            : in std_logic                                    := '0';
      trn_tsrc_dsc            : out std_logic                                   := '0';
      trn_trem                : out std_logic_vector(C_REM_WIDTH - 1 downto 0)  := (others=>'0');
      trn_terrfwd             : out std_logic                                   := '0';
      trn_tstr                : out std_logic                                   := '0';
      trn_tbuf_av             : in std_logic_vector(5 downto 0)                 := (others=>'0');
      trn_tecrc_gen           : out std_logic                                   := '0';

      -- TRN RX
      -------------
      trn_rd                  : in std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      trn_rsof                : in std_logic                                   := '0';
      trn_reof                : in std_logic                                   := '0';
      trn_rsrc_rdy            : in std_logic                                   := '0';
      trn_rdst_rdy            : out std_logic                                  := '0';
      trn_rsrc_dsc            : in std_logic                                   := '0';
      trn_rrem                : in std_logic_vector(C_REM_WIDTH - 1 downto 0)  := (others=>'0');
      trn_rerrfwd             : in std_logic                                   := '0';
      trn_rbar_hit            : in std_logic_vector(6 downto 0)                := (others=>'0');
      trn_recrc_err           : in std_logic                                   := '0';

      -- TRN misc.
      -------------
      trn_tcfg_req            : in std_logic                                   := '0';
      trn_tcfg_gnt            : out std_logic                                  := '0';
      trn_lnk_up              : in std_logic                                   := '0';

      -- 7 series/Virtex6 PM
      -------------
      cfg_pcie_link_state     : in std_logic_vector(2 downto 0)                := (others=>'0');

      -- Virtex6 PM
      -------------
      cfg_pm_send_pme_to      : in std_logic                                   := '0';
      cfg_pmcsr_powerstate    : in std_logic_vector(1 downto 0)                := (others=>'0');
      trn_rdllp_data          : in std_logic_vector(31 downto 0)               := (others=>'0');
      trn_rdllp_src_rdy       : in std_logic                                   := '0';

      -- Virtex6/Spartan6 PM
      -------------
      cfg_to_turnoff          : in std_logic                                   := '0';
      cfg_turnoff_ok          : out std_logic                                  := '0';

      np_counter              : out std_logic_vector(2 downto 0)               := (others=>'0');
      user_clk                : in std_logic                                   := '0';
      user_rst                : in std_logic                                   := '0'
   );
   end component;

  component pcie_reset_delay_v6
    generic (
      PL_FAST_TRAIN : boolean;
      REF_CLK_FREQ  : integer);
    port (
      ref_clk             : in  std_logic;
      sys_reset_n         : in  std_logic;
      delayed_sys_reset_n : out std_logic);
  end component;

  component pcie_clocking_v6
    generic (
      CAP_LINK_WIDTH : integer;
      CAP_LINK_SPEED : integer;
      REF_CLK_FREQ   : integer;
      USER_CLK_FREQ  : integer);
    port (
      sys_clk       : in  std_logic;
      gt_pll_lock   : in  std_logic;
      sel_lnk_rate  : in  std_logic;
      sel_lnk_width : in  std_logic_vector(1 downto 0);
      sys_clk_bufg  : out std_logic;
      pipe_clk      : out std_logic;
      user_clk      : out std_logic;
      block_clk     : out std_logic;
      drp_clk       : out std_logic;
      clock_locked  : out std_logic);
  end component;

  component pcie_2_0_v6
    generic (
      REF_CLK_FREQ                             : integer;
      PIPE_PIPELINE_STAGES                     : integer;
      LINK_CAP_MAX_LINK_WIDTH_int              : integer;
      AER_BASE_PTR                             : bit_vector;
      AER_CAP_ECRC_CHECK_CAPABLE               : boolean;
      AER_CAP_ECRC_GEN_CAPABLE                 : boolean;
      AER_CAP_ID                               : bit_vector;
      AER_CAP_INT_MSG_NUM_MSI                  : bit_vector;
      AER_CAP_INT_MSG_NUM_MSIX                 : bit_vector;
      AER_CAP_NEXTPTR                          : bit_vector;
      AER_CAP_ON                               : boolean;
      AER_CAP_PERMIT_ROOTERR_UPDATE            : boolean;
      AER_CAP_VERSION                          : bit_vector;
      ALLOW_X8_GEN2                            : boolean;
      BAR0                                     : bit_vector;
      BAR1                                     : bit_vector;
      BAR2                                     : bit_vector;
      BAR3                                     : bit_vector;
      BAR4                                     : bit_vector;
      BAR5                                     : bit_vector;
      CAPABILITIES_PTR                         : bit_vector;
      CARDBUS_CIS_POINTER                      : bit_vector;
      CLASS_CODE                               : bit_vector;
      CMD_INTX_IMPLEMENTED                     : boolean;
      CPL_TIMEOUT_DISABLE_SUPPORTED            : boolean;
      CPL_TIMEOUT_RANGES_SUPPORTED             : bit_vector;
      CRM_MODULE_RSTS                          : bit_vector;
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE      : boolean;
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE      : boolean;
      DEV_CAP_ENDPOINT_L0S_LATENCY             : integer;
      DEV_CAP_ENDPOINT_L1_LATENCY              : integer;
      DEV_CAP_EXT_TAG_SUPPORTED                : boolean;
      DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE     : boolean;
      DEV_CAP_MAX_PAYLOAD_SUPPORTED            : integer;
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT        : integer;
      DEV_CAP_ROLE_BASED_ERROR                 : boolean;
      DEV_CAP_RSVD_14_12                       : integer;
      DEV_CAP_RSVD_17_16                       : integer;
      DEV_CAP_RSVD_31_29                       : integer;
      DEV_CONTROL_AUX_POWER_SUPPORTED          : boolean;
      DEVICE_ID                                : bit_vector;
      DISABLE_ASPM_L1_TIMER                    : boolean;
      DISABLE_BAR_FILTERING                    : boolean;
      DISABLE_ID_CHECK                         : boolean;
      DISABLE_LANE_REVERSAL                    : boolean;
      DISABLE_RX_TC_FILTER                     : boolean;
      DISABLE_SCRAMBLING                       : boolean;
      DNSTREAM_LINK_NUM                        : bit_vector;
      DSN_BASE_PTR                             : bit_vector;
      DSN_CAP_ID                               : bit_vector;
      DSN_CAP_NEXTPTR                          : bit_vector;
      DSN_CAP_ON                               : boolean;
      DSN_CAP_VERSION                          : bit_vector;
      ENABLE_MSG_ROUTE                         : bit_vector;
      ENABLE_RX_TD_ECRC_TRIM                   : boolean;
      ENTER_RVRY_EI_L0                         : boolean;
      EXPANSION_ROM                            : bit_vector;
      EXT_CFG_CAP_PTR                          : bit_vector;
      EXT_CFG_XP_CAP_PTR                       : bit_vector;
      HEADER_TYPE                              : bit_vector;
      INFER_EI                                 : bit_vector;
      INTERRUPT_PIN                            : bit_vector;
      IS_SWITCH                                : boolean;
      LAST_CONFIG_DWORD                        : bit_vector;
      LINK_CAP_ASPM_SUPPORT                    : integer;
      LINK_CAP_CLOCK_POWER_MANAGEMENT          : boolean;
      LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP   : boolean;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1    : integer;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2    : integer;
      LINK_CAP_L0S_EXIT_LATENCY_GEN1           : integer;
      LINK_CAP_L0S_EXIT_LATENCY_GEN2           : integer;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1     : integer;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2     : integer;
      LINK_CAP_L1_EXIT_LATENCY_GEN1            : integer;
      LINK_CAP_L1_EXIT_LATENCY_GEN2            : integer;
      LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP : boolean;
      LINK_CAP_MAX_LINK_SPEED                  : bit_vector;
      LINK_CAP_MAX_LINK_WIDTH                  : bit_vector;
      LINK_CAP_RSVD_23_22                      : integer;
      LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE     : boolean;
      LINK_CONTROL_RCB                         : integer;
      LINK_CTRL2_DEEMPHASIS                    : boolean;
      LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE   : boolean;
      LINK_CTRL2_TARGET_LINK_SPEED             : bit_vector;
      LINK_STATUS_SLOT_CLOCK_CONFIG            : boolean;
      LL_ACK_TIMEOUT                           : bit_vector;
      LL_ACK_TIMEOUT_EN                        : boolean;
      LL_ACK_TIMEOUT_FUNC                      : integer;
      LL_REPLAY_TIMEOUT                        : bit_vector;
      LL_REPLAY_TIMEOUT_EN                     : boolean;
      LL_REPLAY_TIMEOUT_FUNC                   : integer;
      LTSSM_MAX_LINK_WIDTH                     : bit_vector;
      MSI_BASE_PTR                             : bit_vector;
      MSI_CAP_ID                               : bit_vector;
      MSI_CAP_MULTIMSGCAP                      : integer;
      MSI_CAP_MULTIMSG_EXTENSION               : integer;
      MSI_CAP_NEXTPTR                          : bit_vector;
      MSI_CAP_ON                               : boolean;
      MSI_CAP_PER_VECTOR_MASKING_CAPABLE       : boolean;
      MSI_CAP_64_BIT_ADDR_CAPABLE              : boolean;
      MSIX_BASE_PTR                            : bit_vector;
      MSIX_CAP_ID                              : bit_vector;
      MSIX_CAP_NEXTPTR                         : bit_vector;
      MSIX_CAP_ON                              : boolean;
      MSIX_CAP_PBA_BIR                         : integer;
      MSIX_CAP_PBA_OFFSET                      : bit_vector;
      MSIX_CAP_TABLE_BIR                       : integer;
      MSIX_CAP_TABLE_OFFSET                    : bit_vector;
      MSIX_CAP_TABLE_SIZE                      : bit_vector;
      N_FTS_COMCLK_GEN1                        : integer;
      N_FTS_COMCLK_GEN2                        : integer;
      N_FTS_GEN1                               : integer;
      N_FTS_GEN2                               : integer;
      PCIE_BASE_PTR                            : bit_vector;
      PCIE_CAP_CAPABILITY_ID                   : bit_vector;
      PCIE_CAP_CAPABILITY_VERSION              : bit_vector;
      PCIE_CAP_DEVICE_PORT_TYPE                : bit_vector;
      PCIE_CAP_INT_MSG_NUM                     : bit_vector;
      PCIE_CAP_NEXTPTR                         : bit_vector;
      PCIE_CAP_ON                              : boolean;
      PCIE_CAP_RSVD_15_14                      : integer;
      PCIE_CAP_SLOT_IMPLEMENTED                : boolean;
      PCIE_REVISION                            : integer;
      PGL0_LANE                                : integer;
      PGL1_LANE                                : integer;
      PGL2_LANE                                : integer;
      PGL3_LANE                                : integer;
      PGL4_LANE                                : integer;
      PGL5_LANE                                : integer;
      PGL6_LANE                                : integer;
      PGL7_LANE                                : integer;
      PL_AUTO_CONFIG                           : integer;
      PL_FAST_TRAIN                            : boolean;
      PM_BASE_PTR                              : bit_vector;
      PM_CAP_AUXCURRENT                        : integer;
      PM_CAP_DSI                               : boolean;
      PM_CAP_D1SUPPORT                         : boolean;
      PM_CAP_D2SUPPORT                         : boolean;
      PM_CAP_ID                                : bit_vector;
      PM_CAP_NEXTPTR                           : bit_vector;
      PM_CAP_ON                                : boolean;
      PM_CAP_PME_CLOCK                         : boolean;
      PM_CAP_PMESUPPORT                        : bit_vector;
      PM_CAP_RSVD_04                           : integer;
      PM_CAP_VERSION                           : integer;
      PM_CSR_BPCCEN                            : boolean;
      PM_CSR_B2B3                              : boolean;
      PM_CSR_NOSOFTRST                         : boolean;
      PM_DATA0                                 : bit_vector;
      PM_DATA1                                 : bit_vector;
      PM_DATA2                                 : bit_vector;
      PM_DATA3                                 : bit_vector;
      PM_DATA4                                 : bit_vector;
      PM_DATA5                                 : bit_vector;
      PM_DATA6                                 : bit_vector;
      PM_DATA7                                 : bit_vector;
      PM_DATA_SCALE0                           : bit_vector;
      PM_DATA_SCALE1                           : bit_vector;
      PM_DATA_SCALE2                           : bit_vector;
      PM_DATA_SCALE3                           : bit_vector;
      PM_DATA_SCALE4                           : bit_vector;
      PM_DATA_SCALE5                           : bit_vector;
      PM_DATA_SCALE6                           : bit_vector;
      PM_DATA_SCALE7                           : bit_vector;
      RECRC_CHK                                : integer;
      RECRC_CHK_TRIM                           : boolean;
      REVISION_ID                              : bit_vector;
      ROOT_CAP_CRS_SW_VISIBILITY               : boolean;
      SELECT_DLL_IF                            : boolean;
      SLOT_CAP_ATT_BUTTON_PRESENT              : boolean;
      SLOT_CAP_ATT_INDICATOR_PRESENT           : boolean;
      SLOT_CAP_ELEC_INTERLOCK_PRESENT          : boolean;
      SLOT_CAP_HOTPLUG_CAPABLE                 : boolean;
      SLOT_CAP_HOTPLUG_SURPRISE                : boolean;
      SLOT_CAP_MRL_SENSOR_PRESENT              : boolean;
      SLOT_CAP_NO_CMD_COMPLETED_SUPPORT        : boolean;
      SLOT_CAP_PHYSICAL_SLOT_NUM               : bit_vector;
      SLOT_CAP_POWER_CONTROLLER_PRESENT        : boolean;
      SLOT_CAP_POWER_INDICATOR_PRESENT         : boolean;
      SLOT_CAP_SLOT_POWER_LIMIT_SCALE          : integer;
      SLOT_CAP_SLOT_POWER_LIMIT_VALUE          : bit_vector;
      SPARE_BIT0                               : integer;
      SPARE_BIT1                               : integer;
      SPARE_BIT2                               : integer;
      SPARE_BIT3                               : integer;
      SPARE_BIT4                               : integer;
      SPARE_BIT5                               : integer;
      SPARE_BIT6                               : integer;
      SPARE_BIT7                               : integer;
      SPARE_BIT8                               : integer;
      SPARE_BYTE0                              : bit_vector;
      SPARE_BYTE1                              : bit_vector;
      SPARE_BYTE2                              : bit_vector;
      SPARE_BYTE3                              : bit_vector;
      SPARE_WORD0                              : bit_vector;
      SPARE_WORD1                              : bit_vector;
      SPARE_WORD2                              : bit_vector;
      SPARE_WORD3                              : bit_vector;
      SUBSYSTEM_ID                             : bit_vector;
      SUBSYSTEM_VENDOR_ID                      : bit_vector;
      TL_RBYPASS                               : boolean;
      TL_RX_RAM_RADDR_LATENCY                  : integer;
      TL_RX_RAM_RDATA_LATENCY                  : integer;
      TL_RX_RAM_WRITE_LATENCY                  : integer;
      TL_TFC_DISABLE                           : boolean;
      TL_TX_CHECKS_DISABLE                     : boolean;
      TL_TX_RAM_RADDR_LATENCY                  : integer;
      TL_TX_RAM_RDATA_LATENCY                  : integer;
      TL_TX_RAM_WRITE_LATENCY                  : integer;
      UPCONFIG_CAPABLE                         : boolean;
      UPSTREAM_FACING                          : boolean;
      UR_INV_REQ                               : boolean;
      USER_CLK_FREQ                            : integer;
      EXIT_LOOPBACK_ON_EI                      : boolean;
      VC_BASE_PTR                              : bit_vector;
      VC_CAP_ID                                : bit_vector;
      VC_CAP_NEXTPTR                           : bit_vector;
      VC_CAP_ON                                : boolean;
      VC_CAP_REJECT_SNOOP_TRANSACTIONS         : boolean;
      VC_CAP_VERSION                           : bit_vector;
      VC0_CPL_INFINITE                         : boolean;
      VC0_RX_RAM_LIMIT                         : bit_vector;
      VC0_TOTAL_CREDITS_CD                     : integer;
      VC0_TOTAL_CREDITS_CH                     : integer;
      VC0_TOTAL_CREDITS_NPH                    : integer;
      VC0_TOTAL_CREDITS_PD                     : integer;
      VC0_TOTAL_CREDITS_PH                     : integer;
      VC0_TX_LASTPACKET                        : integer;
      VENDOR_ID                                : bit_vector;
      VSEC_BASE_PTR                            : bit_vector;
      VSEC_CAP_HDR_ID                          : bit_vector;
      VSEC_CAP_HDR_LENGTH                      : bit_vector;
      VSEC_CAP_HDR_REVISION                    : bit_vector;
      VSEC_CAP_ID                              : bit_vector;
      VSEC_CAP_IS_LINK_VISIBLE                 : boolean;
      VSEC_CAP_NEXTPTR                         : bit_vector;
      VSEC_CAP_ON                              : boolean;
      VSEC_CAP_VERSION                         : bit_vector);
    port (
      PCIEXPRXN                           : in  std_logic_vector(3 downto 0);
      PCIEXPRXP                           : in  std_logic_vector(3 downto 0);
      PCIEXPTXN                           : out std_logic_vector(3 downto 0);
      PCIEXPTXP                           : out std_logic_vector(3 downto 0);
      SYSCLK                              : in  std_logic;
      FUNDRSTN                            : in  std_logic;
      TRNLNKUPN                           : out std_logic;
      PHYRDYN                             : out std_logic;
      USERRSTN                            : out std_logic;
      RECEIVEDFUNCLVLRSTN                 : out std_logic;
      LNKCLKEN                            : out std_logic;
      SYSRSTN                             : in  std_logic;
      PLRSTN                              : in  std_logic;
      DLRSTN                              : in  std_logic;
      TLRSTN                              : in  std_logic;
      FUNCLVLRSTN                         : in  std_logic;
      CMRSTN                              : in  std_logic;
      CMSTICKYRSTN                        : in  std_logic;
      TRNRBARHITN                         : out std_logic_vector(6 downto 0);
      TRNRD                               : out std_logic_vector(63 downto 0);
      TRNRECRCERRN                        : out std_logic;
      TRNREOFN                            : out std_logic;
      TRNRERRFWDN                         : out std_logic;
      TRNRREMN                            : out std_logic;
      TRNRSOFN                            : out std_logic;
      TRNRSRCDSCN                         : out std_logic;
      TRNRSRCRDYN                         : out std_logic;
      TRNRDSTRDYN                         : in  std_logic;
      TRNRNPOKN                           : in  std_logic;
      TRNRDLLPDATA                        : out std_logic_vector(31 downto 0);
      TRNRDLLPSRCRDYN                     : out std_logic;
      TRNTBUFAV                           : out std_logic_vector(5 downto 0);
      TRNTCFGREQN                         : out std_logic;
      TRNTDLLPDSTRDYN                     : out std_logic;
      TRNTDSTRDYN                         : out std_logic;
      TRNTERRDROPN                        : out std_logic;
      TRNTCFGGNTN                         : in  std_logic;
      TRNTD                               : in  std_logic_vector(63 downto 0);
      TRNTDLLPDATA                        : in  std_logic_vector(31 downto 0);
      TRNTDLLPSRCRDYN                     : in  std_logic;
      TRNTECRCGENN                        : in  std_logic;
      TRNTEOFN                            : in  std_logic;
      TRNTERRFWDN                         : in  std_logic;
      TRNTREMN                            : in  std_logic;
      TRNTSOFN                            : in  std_logic;
      TRNTSRCDSCN                         : in  std_logic;
      TRNTSRCRDYN                         : in  std_logic;
      TRNTSTRN                            : in  std_logic;
      TRNFCCPLD                           : out std_logic_vector(11 downto 0);
      TRNFCCPLH                           : out std_logic_vector(7 downto 0);
      TRNFCNPD                            : out std_logic_vector(11 downto 0);
      TRNFCNPH                            : out std_logic_vector(7 downto 0);
      TRNFCPD                             : out std_logic_vector(11 downto 0);
      TRNFCPH                             : out std_logic_vector(7 downto 0);
      TRNFCSEL                            : in  std_logic_vector(2 downto 0);
      CFGAERECRCCHECKEN                   : out std_logic;
      CFGAERECRCGENEN                     : out std_logic;
      CFGCOMMANDBUSMASTERENABLE           : out std_logic;
      CFGCOMMANDINTERRUPTDISABLE          : out std_logic;
      CFGCOMMANDIOENABLE                  : out std_logic;
      CFGCOMMANDMEMENABLE                 : out std_logic;
      CFGCOMMANDSERREN                    : out std_logic;
      CFGDEVCONTROLAUXPOWEREN             : out std_logic;
      CFGDEVCONTROLCORRERRREPORTINGEN     : out std_logic;
      CFGDEVCONTROLENABLERO               : out std_logic;
      CFGDEVCONTROLEXTTAGEN               : out std_logic;
      CFGDEVCONTROLFATALERRREPORTINGEN    : out std_logic;
      CFGDEVCONTROLMAXPAYLOAD             : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLMAXREADREQ             : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLNONFATALREPORTINGEN    : out std_logic;
      CFGDEVCONTROLNOSNOOPEN              : out std_logic;
      CFGDEVCONTROLPHANTOMEN              : out std_logic;
      CFGDEVCONTROLURERRREPORTINGEN       : out std_logic;
      CFGDEVCONTROL2CPLTIMEOUTDIS         : out std_logic;
      CFGDEVCONTROL2CPLTIMEOUTVAL         : out std_logic_vector(3 downto 0);
      CFGDEVSTATUSCORRERRDETECTED         : out std_logic;
      CFGDEVSTATUSFATALERRDETECTED        : out std_logic;
      CFGDEVSTATUSNONFATALERRDETECTED     : out std_logic;
      CFGDEVSTATUSURDETECTED              : out std_logic;
      CFGDO                               : out std_logic_vector(31 downto 0);
      CFGERRAERHEADERLOGSETN              : out std_logic;
      CFGERRCPLRDYN                       : out std_logic;
      CFGINTERRUPTDO                      : out std_logic_vector(7 downto 0);
      CFGINTERRUPTMMENABLE                : out std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIENABLE               : out std_logic;
      CFGINTERRUPTMSIXENABLE              : out std_logic;
      CFGINTERRUPTMSIXFM                  : out std_logic;
      CFGINTERRUPTRDYN                    : out std_logic;
      CFGLINKCONTROLRCB                   : out std_logic;
      CFGLINKCONTROLASPMCONTROL           : out std_logic_vector(1 downto 0);
      CFGLINKCONTROLAUTOBANDWIDTHINTEN    : out std_logic;
      CFGLINKCONTROLBANDWIDTHINTEN        : out std_logic;
      CFGLINKCONTROLCLOCKPMEN             : out std_logic;
      CFGLINKCONTROLCOMMONCLOCK           : out std_logic;
      CFGLINKCONTROLEXTENDEDSYNC          : out std_logic;
      CFGLINKCONTROLHWAUTOWIDTHDIS        : out std_logic;
      CFGLINKCONTROLLINKDISABLE           : out std_logic;
      CFGLINKCONTROLRETRAINLINK           : out std_logic;
      CFGLINKSTATUSAUTOBANDWIDTHSTATUS    : out std_logic;
      CFGLINKSTATUSBANDWITHSTATUS         : out std_logic;
      CFGLINKSTATUSCURRENTSPEED           : out std_logic_vector(1 downto 0);
      CFGLINKSTATUSDLLACTIVE              : out std_logic;
      CFGLINKSTATUSLINKTRAINING           : out std_logic;
      CFGLINKSTATUSNEGOTIATEDWIDTH        : out std_logic_vector(3 downto 0);
      CFGMSGDATA                          : out std_logic_vector(15 downto 0);
      CFGMSGRECEIVED                      : out std_logic;
      CFGMSGRECEIVEDASSERTINTA            : out std_logic;
      CFGMSGRECEIVEDASSERTINTB            : out std_logic;
      CFGMSGRECEIVEDASSERTINTC            : out std_logic;
      CFGMSGRECEIVEDASSERTINTD            : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTA          : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTB          : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTC          : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTD          : out std_logic;
      CFGMSGRECEIVEDERRCOR                : out std_logic;
      CFGMSGRECEIVEDERRFATAL              : out std_logic;
      CFGMSGRECEIVEDERRNONFATAL           : out std_logic;
      CFGMSGRECEIVEDPMASNAK               : out std_logic;
      CFGMSGRECEIVEDPMETO                 : out std_logic;
      CFGMSGRECEIVEDPMETOACK              : out std_logic;
      CFGMSGRECEIVEDPMPME                 : out std_logic;
      CFGMSGRECEIVEDSETSLOTPOWERLIMIT     : out std_logic;
      CFGMSGRECEIVEDUNLOCK                : out std_logic;
      CFGPCIELINKSTATE                    : out std_logic_vector(2 downto 0);
      CFGPMCSRPMEEN                       : out std_logic;
      CFGPMCSRPMESTATUS                   : out std_logic;
      CFGPMCSRPOWERSTATE                  : out std_logic_vector(1 downto 0);
      CFGPMRCVASREQL1N                    : out std_logic;
      CFGPMRCVENTERL1N                    : out std_logic;
      CFGPMRCVENTERL23N                   : out std_logic;
      CFGPMRCVREQACKN                     : out std_logic;
      CFGRDWRDONEN                        : out std_logic;
      CFGSLOTCONTROLELECTROMECHILCTLPULSE : out std_logic;
      CFGTRANSACTION                      : out std_logic;
      CFGTRANSACTIONADDR                  : out std_logic_vector(6 downto 0);
      CFGTRANSACTIONTYPE                  : out std_logic;
      CFGVCTCVCMAP                        : out std_logic_vector(6 downto 0);
      CFGBYTEENN                          : in  std_logic_vector(3 downto 0);
      CFGDI                               : in  std_logic_vector(31 downto 0);
      CFGDSBUSNUMBER                      : in  std_logic_vector(7 downto 0);
      CFGDSDEVICENUMBER                   : in  std_logic_vector(4 downto 0);
      CFGDSFUNCTIONNUMBER                 : in  std_logic_vector(2 downto 0);
      CFGDSN                              : in  std_logic_vector(63 downto 0);
      CFGDWADDR                           : in  std_logic_vector(9 downto 0);
      CFGERRACSN                          : in  std_logic;
      CFGERRAERHEADERLOG                  : in  std_logic_vector(127 downto 0);
      CFGERRCORN                          : in  std_logic;
      CFGERRCPLABORTN                     : in  std_logic;
      CFGERRCPLTIMEOUTN                   : in  std_logic;
      CFGERRCPLUNEXPECTN                  : in  std_logic;
      CFGERRECRCN                         : in  std_logic;
      CFGERRLOCKEDN                       : in  std_logic;
      CFGERRPOSTEDN                       : in  std_logic;
      CFGERRTLPCPLHEADER                  : in  std_logic_vector(47 downto 0);
      CFGERRURN                           : in  std_logic;
      CFGINTERRUPTASSERTN                 : in  std_logic;
      CFGINTERRUPTDI                      : in  std_logic_vector(7 downto 0);
      CFGINTERRUPTN                       : in  std_logic;
      CFGPMDIRECTASPML1N                  : in  std_logic;
      CFGPMSENDPMACKN                     : in  std_logic;
      CFGPMSENDPMETON                     : in  std_logic;
      CFGPMSENDPMNAKN                     : in  std_logic;
      CFGPMTURNOFFOKN                     : in  std_logic;
      CFGPMWAKEN                          : in  std_logic;
      CFGPORTNUMBER                       : in  std_logic_vector(7 downto 0);
      CFGRDENN                            : in  std_logic;
      CFGTRNPENDINGN                      : in  std_logic;
      CFGWRENN                            : in  std_logic;
      CFGWRREADONLYN                      : in  std_logic;
      CFGWRRW1CASRWN                      : in  std_logic;
      PLINITIALLINKWIDTH                  : out std_logic_vector(2 downto 0);
      PLLANEREVERSALMODE                  : out std_logic_vector(1 downto 0);
      PLLINKGEN2CAP                       : out std_logic;
      PLLINKPARTNERGEN2SUPPORTED          : out std_logic;
      PLLINKUPCFGCAP                      : out std_logic;
      PLLTSSMSTATE                        : out std_logic_vector(5 downto 0);
      PLPHYLNKUPN                         : out std_logic;
      PLRECEIVEDHOTRST                    : out std_logic;
      PLRXPMSTATE                         : out std_logic_vector(1 downto 0);
      PLSELLNKRATE                        : out std_logic;
      PLSELLNKWIDTH                       : out std_logic_vector(1 downto 0);
      PLTXPMSTATE                         : out std_logic_vector(2 downto 0);
      PLDIRECTEDLINKAUTON                 : in  std_logic;
      PLDIRECTEDLINKCHANGE                : in  std_logic_vector(1 downto 0);
      PLDIRECTEDLINKSPEED                 : in  std_logic;
      PLDIRECTEDLINKWIDTH                 : in  std_logic_vector(1 downto 0);
      PLDOWNSTREAMDEEMPHSOURCE            : in  std_logic;
      PLUPSTREAMPREFERDEEMPH              : in  std_logic;
      PLTRANSMITHOTRST                    : in  std_logic;
      DBGSCLRA                            : out std_logic;
      DBGSCLRB                            : out std_logic;
      DBGSCLRC                            : out std_logic;
      DBGSCLRD                            : out std_logic;
      DBGSCLRE                            : out std_logic;
      DBGSCLRF                            : out std_logic;
      DBGSCLRG                            : out std_logic;
      DBGSCLRH                            : out std_logic;
      DBGSCLRI                            : out std_logic;
      DBGSCLRJ                            : out std_logic;
      DBGSCLRK                            : out std_logic;
      DBGVECA                             : out std_logic_vector(63 downto 0);
      DBGVECB                             : out std_logic_vector(63 downto 0);
      DBGVECC                             : out std_logic_vector(11 downto 0);
      PLDBGVEC                            : out std_logic_vector(11 downto 0);
      DBGMODE                             : in  std_logic_vector(1 downto 0);
      DBGSUBMODE                          : in  std_logic;
      PLDBGMODE                           : in  std_logic_vector(2 downto 0);
      PCIEDRPDO                           : out std_logic_vector(15 downto 0);
      PCIEDRPDRDY                         : out std_logic;
      PCIEDRPCLK                          : in  std_logic;
      PCIEDRPDADDR                        : in  std_logic_vector(8 downto 0);
      PCIEDRPDEN                          : in  std_logic;
      PCIEDRPDI                           : in  std_logic_vector(15 downto 0);
      PCIEDRPDWE                          : in  std_logic;
      GTPLLLOCK                           : out std_logic;
      PIPECLK                             : in  std_logic;
      USERCLK                             : in  std_logic;
      DRPCLK                              : in  std_logic;
      CLOCKLOCKED                         : in  std_logic;
      TxOutClk                            : out std_logic);
   end component;

   function to_integer (
      val_in    : bit_vector) return integer is

      constant vctr   : bit_vector(val_in'high-val_in'low downto 0) := val_in;
      variable ret    : integer := 0;
   begin
      for index in vctr'range loop
         if (vctr(index) = '1') then
            ret := ret + (2**index);
         end if;
      end loop;
      return(ret);
   end to_integer;

   function to_stdlogic (
      in_val      : in boolean) return std_logic is
   begin
      if (in_val) then
         return('1');
      else
         return('0');
      end if;
   end to_stdlogic;

   function pad_gen (
      in_vec   : bit_vector;
      op_len   : integer)
      return bit_vector is
      variable ret : bit_vector(op_len-1 downto 0) := (others => '0');
      constant len : integer := in_vec'length;  -- length of input vector
   begin  -- pad_gen
      for i in 0 to op_len-1 loop
         if (i < len) then
            ret(i) := in_vec(len-i-1);
         else
            ret(i) := '0';
         end if;
      end loop;  -- i
      return ret;
   end pad_gen;

   constant LINK_CAP_MAX_LINK_SPEED_int : integer := to_integer(LINK_CAP_MAX_LINK_SPEED);

   signal rx_func_level_reset_n                       : std_logic;
   signal cfg_msg_received                            : std_logic;
   signal cfg_msg_received_pme_to                     : std_logic;

   signal cfg_cmd_bme                                 : std_logic;
   signal cfg_cmd_intdis                              : std_logic;
   signal cfg_cmd_io_en                               : std_logic;
   signal cfg_cmd_mem_en                              : std_logic;
   signal cfg_cmd_serr_en                             : std_logic;
   signal cfg_dev_control_aux_power_en                : std_logic;
   signal cfg_dev_control_corr_err_reporting_en       : std_logic;
   signal cfg_dev_control_enable_relaxed_order        : std_logic;
   signal cfg_dev_control_ext_tag_en                  : std_logic;
   signal cfg_dev_control_fatal_err_reporting_en      : std_logic;
   signal cfg_dev_control_maxpayload                  : std_logic_vector(2 downto 0);
   signal cfg_dev_control_max_read_req                : std_logic_vector(2 downto 0);
   signal cfg_dev_control_non_fatal_reporting_en      : std_logic;
   signal cfg_dev_control_nosnoop_en                  : std_logic;
   signal cfg_dev_control_phantom_en                  : std_logic;
   signal cfg_dev_control_ur_err_reporting_en         : std_logic;
   signal cfg_dev_control2_cpltimeout_dis             : std_logic;
   signal cfg_dev_control2_cpltimeout_val             : std_logic_vector(3 downto 0);
   signal cfg_dev_status_corr_err_detected            : std_logic;
   signal cfg_dev_status_fatal_err_detected           : std_logic;
   signal cfg_dev_status_nonfatal_err_detected        : std_logic;
   signal cfg_dev_status_ur_detected                  : std_logic;
   signal cfg_link_control_auto_bandwidth_int_en      : std_logic;
   signal cfg_link_control_bandwidth_int_en           : std_logic;
   signal cfg_link_control_hw_auto_width_dis          : std_logic;
   signal cfg_link_control_clock_pm_en                : std_logic;
   signal cfg_link_control_extended_sync              : std_logic;
   signal cfg_link_control_common_clock               : std_logic;
   signal cfg_link_control_retrain_link               : std_logic;
   signal cfg_link_control_linkdisable                : std_logic;
   signal cfg_link_control_rcb                        : std_logic;
   signal cfg_link_control_aspm_control               : std_logic_vector(1 downto 0);
   signal cfg_link_status_autobandwidth_status        : std_logic;
   signal cfg_link_status_bandwidth_status            : std_logic;
   signal cfg_link_status_dll_active                  : std_logic;
   signal cfg_link_status_link_training               : std_logic;
   signal cfg_link_status_negotiated_link_width       : std_logic_vector(3 downto 0);
   signal cfg_link_status_current_speed               : std_logic_vector(1 downto 0);
   signal cfg_msg_data                                : std_logic_vector(15 downto 0);

   signal sys_reset_n                                 : std_logic;
   signal sys_reset_n_d                               : std_logic;
   signal phy_rdy_n                                   : std_logic;

   signal TxOutClk                                    : std_logic;
   signal TxOutClk_bufg                               : std_logic;

   signal cfg_bus_number_d                            : std_logic_vector(7 downto 0);
   signal cfg_device_number_d                         : std_logic_vector(4 downto 0);
   signal cfg_function_number_d                       : std_logic_vector(2 downto 0);

   signal trn_rdllp_data                              : std_logic_vector(31 downto 0);
   signal trn_rdllp_src_rdy_n                         : std_logic;
   signal trn_rdllp_src_rdy                           : std_logic;

   -- assigns to outputs

   signal gt_pll_lock                                 : std_logic;

   signal pipe_clk                                    : std_logic;
   signal user_clk                                    : std_logic;
   signal clock_locked                                : std_logic;
   signal phy_rdy                                     : std_logic;

   signal drp_clk                                     : std_logic;

   signal trn_reset_n_d                               : std_logic;
   signal sys_reset_d                                 : std_logic;
   signal trn_reset_n                                 : std_logic;
   signal trn_reset_n_int1                            : std_logic;
   signal trn_reset_n_1_d                             : std_logic;
   signal trn_lnk_up_n                                : std_logic;
   signal trn_lnk_up_n_1                              : std_logic;
   signal user_reset_out_int                          : std_logic;
   signal user_lnk_up_int                             : std_logic;
   signal user_lnk_up_d                               : std_logic;
   signal tx_cfg_req_int                              : std_logic;
   signal cfg_pcie_link_state_int                     : std_logic_vector(2 downto 0);
   signal cfg_pmcsr_powerstate_int                    : std_logic_vector(1 downto 0);
   signal cfg_to_turnoff_int                          : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal trn_tcfg_req_n                              : std_logic;
   signal trn_tcfg_gnt_n                              : std_logic;
   signal trn_tcfg_gnt                                : std_logic;
   signal trn_terr_drop_n                             : std_logic;
   signal trn_rdst_rdy_n                              : std_logic;
   signal trn_rnp_ok_n                                : std_logic;
   signal trn_tdst_rdy_n                              : std_logic;
   signal trn_tdst_rdy                                : std_logic;
   signal trn_rd                                      : std_logic_vector(63 downto 0);
   signal trn_rrem_n                                  : std_logic;
   signal trn_rrem                                    : std_logic_vector(0 downto 0);
   signal trn_td                                      : std_logic_vector(63 downto 0);
   signal trn_trem_n                                  : std_logic;
   signal trn_trem                                    : std_logic_vector(0 downto 0);
   signal trn_rsof_n                                  : std_logic;
   signal trn_reof_n                                  : std_logic;
   signal trn_rsrc_rdy_n                              : std_logic;
   signal trn_rsrc_dsc_n                              : std_logic;
   signal trn_rerrfwd_n                               : std_logic;
   signal trn_rbar_hit_n                              : std_logic_vector(6 downto 0);
   signal trn_recrc_err_n                             : std_logic;
   signal trn_rsof                                    : std_logic;
   signal trn_reof                                    : std_logic;
   signal trn_rsrc_rdy                                : std_logic;
   signal trn_rdst_rdy                                : std_logic;
   signal trn_rsrc_dsc                                : std_logic;
   signal trn_rerrfwd                                 : std_logic;
   signal trn_rbar_hit                                : std_logic_vector(6 downto 0);
   signal trn_recrc_err                               : std_logic;
   signal trn_tsof_n                                  : std_logic;
   signal trn_teof_n                                  : std_logic;
   signal trn_tsrc_rdy_n                              : std_logic;
   signal trn_tsrc_dsc_n                              : std_logic;
   signal trn_terrfwd_n                               : std_logic;
   signal trn_tstr_n                                  : std_logic;
   signal trn_tecrc_gen                               : std_logic;
   signal trn_tsof                                    : std_logic;
   signal trn_teof                                    : std_logic;
   signal trn_tsrc_rdy                                : std_logic;
   signal trn_tsrc_dsc                                : std_logic;
   signal trn_terrfwd                                 : std_logic;
   signal trn_tstr                                    : std_logic;
   signal cfg_rd_wr_done_n                            : std_logic;
   signal cfg_err_cpl_rdy_n                           : std_logic;
   signal cfg_interrupt_rdy_n                         : std_logic;
   signal cfg_byte_en_n                               : std_logic_vector(3 downto 0);
   signal cfg_err_cor_n                               : std_logic;
   signal cfg_err_cpl_abort_n                         : std_logic;
   signal cfg_err_cpl_timeout_n                       : std_logic;
   signal cfg_err_cpl_unexpect_n                      : std_logic;
   signal cfg_err_ecrc_n                              : std_logic;
   signal cfg_err_locked_n                            : std_logic;
   signal cfg_err_posted_n                            : std_logic;
   signal cfg_err_ur_n                                : std_logic;
   signal cfg_interrupt_assert_n                      : std_logic;
   signal cfg_interrupt_n                             : std_logic;
   signal cfg_turnoff_ok_n                            : std_logic;
   signal cfg_turnoff_ok_axi                          : std_logic;
   signal cfg_pm_wake_n                               : std_logic;
   signal cfg_rd_en_n                                 : std_logic;
   signal cfg_trn_pending_n                           : std_logic;
   signal cfg_wr_en_n                                 : std_logic;
   signal tx_buf_av_int                               : std_logic_vector(5 downto 0);

   signal pl_sel_link_rate_int                        : std_logic;
   signal pl_sel_link_width_int                       : std_logic_vector(1 downto 0);

   signal LINK_STATUS_SLOT_CLOCK_CONFIG_lstatus       : std_logic;

begin
   -- Drive referenced outputs
   user_clk_out           <= user_clk;
   user_reset_out         <= user_reset_out_int;
   user_lnk_up            <= user_lnk_up_int;
   pl_sel_link_rate       <= pl_sel_link_rate_int;
   pl_sel_link_width      <= pl_sel_link_width_int;
   tx_buf_av              <= tx_buf_av_int;
   tx_cfg_req_int         <= not(trn_tcfg_req_n);
   tx_cfg_req             <= tx_cfg_req_int;
   cfg_pcie_link_state    <= cfg_pcie_link_state_int;
   cfg_pmcsr_powerstate   <= cfg_pmcsr_powerstate_int;
   cfg_to_turnoff_int     <= cfg_msg_received_pme_to;
   cfg_to_turnoff         <= cfg_to_turnoff_int;

   -- Invert outputs
   tx_err_drop            <= not(trn_terr_drop_n);
   cfg_rd_wr_done         <= not(cfg_rd_wr_done_n);
   cfg_err_cpl_rdy        <= not(cfg_err_cpl_rdy_n);
   cfg_interrupt_rdy      <= not(cfg_interrupt_rdy_n);
   trn_tdst_rdy           <= not(trn_tdst_rdy_n);
   trn_rsof               <= not(trn_rsof_n);
   trn_reof               <= not(trn_reof_n);
   trn_rrem(0)            <= not(trn_rrem_n);
   trn_rsrc_rdy           <= not(trn_rsrc_rdy_n);
   trn_rsrc_dsc           <= not(trn_rsrc_dsc_n);
   trn_rerrfwd            <= not(trn_rerrfwd_n);
   trn_rbar_hit           <= not(trn_rbar_hit_n);
   trn_recrc_err          <= not(trn_recrc_err_n);
   trn_rdllp_src_rdy      <= not(trn_rdllp_src_rdy_n);

   -- Invert inputs
   cfg_byte_en_n          <= not(cfg_byte_en);
   cfg_err_cor_n          <= not(cfg_err_cor);
   cfg_err_cpl_abort_n    <= not(cfg_err_cpl_abort);
   cfg_err_cpl_timeout_n  <= not(cfg_err_cpl_timeout);
   cfg_err_cpl_unexpect_n <= not(cfg_err_cpl_unexpect);
   cfg_err_ecrc_n         <= not(cfg_err_ecrc);
   cfg_err_locked_n       <= not(cfg_err_locked);
   cfg_err_posted_n       <= not(cfg_err_posted);
   cfg_err_ur_n           <= not(cfg_err_ur);
   cfg_interrupt_assert_n <= not(cfg_interrupt_assert);
   cfg_interrupt_n        <= not(cfg_interrupt);
   cfg_turnoff_ok_n       <= not(cfg_turnoff_ok_axi);
   cfg_pm_wake_n          <= not(cfg_pm_wake);
   cfg_rd_en_n            <= not(cfg_rd_en);
   cfg_trn_pending_n      <= not(cfg_trn_pending);
   cfg_wr_en_n            <= not(cfg_wr_en);
   trn_tcfg_gnt_n         <= not(trn_tcfg_gnt);
   trn_rdst_rdy_n         <= not(trn_rdst_rdy);
   trn_rnp_ok_n           <= not(rx_np_ok);
   trn_tsof_n             <= not(trn_tsof);
   trn_teof_n             <= not(trn_teof);
   trn_tsrc_rdy_n         <= not(trn_tsrc_rdy);
   trn_tsrc_dsc_n         <= not(trn_tsrc_dsc);
   trn_terrfwd_n          <= not(trn_terrfwd);
   trn_trem_n             <= not(trn_trem(0));
   trn_tstr_n             <= not(trn_tstr);

   LINK_STATUS_SLOT_CLOCK_CONFIG_lstatus <= '1' when (LINK_STATUS_SLOT_CLOCK_CONFIG) else '0';

   -- Calculated/concatenated oututs
   cfg_status             <= "0000000000000000";
   cfg_command            <= ("00000" &
                              cfg_cmd_intdis &
                              '0' &
                              cfg_cmd_serr_en &
                              "00000" &
                              cfg_cmd_bme &
                              cfg_cmd_mem_en &
                              cfg_cmd_io_en);
   cfg_dstatus            <= ("0000000000" &
                              not(cfg_trn_pending_n) &
                              '0' &
                              cfg_dev_status_ur_detected &
                              cfg_dev_status_fatal_err_detected &
                              cfg_dev_status_nonfatal_err_detected &
                              cfg_dev_status_corr_err_detected);
   cfg_dcommand           <= ('0' &
                              cfg_dev_control_max_read_req &
                              cfg_dev_control_nosnoop_en &
                              cfg_dev_control_aux_power_en &
                              cfg_dev_control_phantom_en &
                              cfg_dev_control_ext_tag_en &
                              cfg_dev_control_maxpayload &
                              cfg_dev_control_enable_relaxed_order &
                              cfg_dev_control_ur_err_reporting_en &
                              cfg_dev_control_fatal_err_reporting_en &
                              cfg_dev_control_non_fatal_reporting_en &
                              cfg_dev_control_corr_err_reporting_en);
   cfg_lstatus            <= (cfg_link_status_autobandwidth_status &
                              cfg_link_status_bandwidth_status &
                              cfg_link_status_dll_active &
                              LINK_STATUS_SLOT_CLOCK_CONFIG_lstatus &
                              cfg_link_status_link_training &
                              '0' &
                              "00" &
                              cfg_link_status_negotiated_link_width &
                              "00" &
                              cfg_link_status_current_speed);
   cfg_lcommand           <= ("0000" &
                              cfg_link_control_auto_bandwidth_int_en &
                              cfg_link_control_bandwidth_int_en &
                              cfg_link_control_hw_auto_width_dis &
                              cfg_link_control_clock_pm_en &
                              cfg_link_control_extended_sync &
                              cfg_link_control_common_clock &
                              cfg_link_control_retrain_link &
                              cfg_link_control_linkdisable &
                              cfg_link_control_rcb &
                              '0' &
                              cfg_link_control_aspm_control);
   cfg_bus_number         <= cfg_bus_number_d;
   cfg_device_number      <= cfg_device_number_d;
   cfg_function_number    <= cfg_function_number_d;
   cfg_dcommand2          <= ("00000000000" &
                              cfg_dev_control2_cpltimeout_dis &
                              cfg_dev_control2_cpltimeout_val);

   -- Capture Bus/Device/Function number

   process (user_clk)
   begin
      if (rising_edge(user_clk)) then
         if (user_lnk_up_int = '0') then
            cfg_bus_number_d       <= "00000000";
            cfg_device_number_d    <= "00000";
            cfg_function_number_d  <= "000";
         elsif (cfg_msg_received = '0') then
            cfg_bus_number_d       <= cfg_msg_data(15 downto 8);
            cfg_device_number_d    <= cfg_msg_data(7 downto 3);
            cfg_function_number_d  <= cfg_msg_data(2 downto 0);
         end if;
      end if;
   end process;

   -- Generate user_lnk_up

   user_lnk_up_int_i : FDCP
      generic map (
         INIT  => '0'
      )
      port map (
         Q    => user_lnk_up_int,
         D    => user_lnk_up_d,
         C    => user_clk,
         CLR  => '0',
         PRE  => '0'
      );

   user_lnk_up_d <= not(trn_lnk_up_n_1);

   trn_lnk_up_n_1_i : FDCP
      generic map (
         INIT  => '1'
      )
      port map (
         Q    => trn_lnk_up_n_1,
         D    => trn_lnk_up_n,
         C    => user_clk,
         CLR  => '0',
         PRE  => '0'
      );


   -- Generate user_reset_out

   trn_reset_n_d <= not(trn_reset_n_int1 and not(phy_rdy_n));
   sys_reset_d   <= not(sys_reset_n_d);

   trn_reset_n_i : FDCP
      generic map (
         INIT  => '1'
      )
      port map (
         Q    => user_reset_out_int,
         D    => trn_reset_n_d,
         C    => user_clk,
         CLR  => sys_reset_d,
         PRE  => '0'
      );


   trn_reset_n_1_d <= trn_reset_n and not(phy_rdy_n);
   trn_reset_n_int_i : FDCP
      generic map (
         INIT  => '0'
      )
      port map (
         Q    => trn_reset_n_int1,
         D    => trn_reset_n_1_d,
         C    => user_clk,
         CLR  => sys_reset_d,
         PRE  => '0'
      );


   ---------------------------------------------------------
   -- AXI Basic Bridge
   -- Converts between TRN and AXI
   ---------------------------------------------------------

   axi_basic_top_i : axi_basic_top
      generic map (
         C_DATA_WIDTH     => 64,           -- RX/TX interface data width
         C_REM_WIDTH      => 1,            -- trem/rrem width
         C_STRB_WIDTH     => 8,            -- tstrb width
         TCQ              => 1,            -- Clock to Q time

         C_FAMILY         => "V6",         -- Targeted FPGA family
         C_ROOT_PORT      => FALSE,      -- PCIe block is in root port mode
         C_PM_PRIORITY    => FALSE       -- Disable TX packet boundary thrtl
      )
      port map (
         -------------------------------------------------
         -- User Design I/O                             --
         -------------------------------------------------

         -- AXI TX
         -------------
         s_axis_tx_tdata          => s_axis_tx_tdata,          --  input
         s_axis_tx_tvalid         => s_axis_tx_tvalid,         --  input
         s_axis_tx_tready         => s_axis_tx_tready,         --  output
         s_axis_tx_tstrb          => s_axis_tx_tstrb,          --  input
         s_axis_tx_tlast          => s_axis_tx_tlast,          --  input
         s_axis_tx_tuser          => s_axis_tx_tuser,          --  input

         -- AXI RX
         -------------
         m_axis_rx_tdata          => m_axis_rx_tdata,          --  output
         m_axis_rx_tvalid         => m_axis_rx_tvalid,         --  output
         m_axis_rx_tready         => m_axis_rx_tready,         --  input
         m_axis_rx_tstrb          => m_axis_rx_tstrb,          --  output
         m_axis_rx_tlast          => m_axis_rx_tlast,          --  output
         m_axis_rx_tuser          => m_axis_rx_tuser,          --  output

         -- User Misc.
         -------------
         user_turnoff_ok          => cfg_turnoff_ok,           --  input
         user_tcfg_gnt            => tx_cfg_gnt,               --  input

         -------------------------------------------------
         -- PCIe Block I/O                              --
         -------------------------------------------------

         -- TRN TX
         -------------
         trn_td                   => trn_td,                   --  output
         trn_tsof                 => trn_tsof,                 --  output
         trn_teof                 => trn_teof,                 --  output
         trn_tsrc_rdy             => trn_tsrc_rdy,             --  output
         trn_tdst_rdy             => trn_tdst_rdy,             --  input
         trn_tsrc_dsc             => trn_tsrc_dsc,             --  output
         trn_trem                 => trn_trem,                 --  output
         trn_terrfwd              => trn_terrfwd,              --  output
         trn_tstr                 => trn_tstr,                 --  output
         trn_tbuf_av              => tx_buf_av_int,            --  input
         trn_tecrc_gen            => trn_tecrc_gen,            --  output

         -- TRN RX
         -------------
         trn_rd                   => trn_rd,                   --  input
         trn_rsof                 => trn_rsof,                 --  input
         trn_reof                 => trn_reof,                 --  input
         trn_rsrc_rdy             => trn_rsrc_rdy,             --  input
         trn_rdst_rdy             => trn_rdst_rdy,             --  output
         trn_rsrc_dsc             => trn_rsrc_dsc,             --  input
         trn_rrem                 => trn_rrem,                 --  input
         trn_rerrfwd              => trn_rerrfwd,              --  input
         trn_rbar_hit             => trn_rbar_hit,             --  input
         trn_recrc_err            => trn_recrc_err,            --  input

         -- TRN Misc.
         -------------
         trn_tcfg_req             => tx_cfg_req_int,           --  input
         trn_tcfg_gnt             => trn_tcfg_gnt,             --  output
         trn_lnk_up               => user_lnk_up_int,          --  input

         -- Artix/Kintex/Virtex PM
         -------------
         cfg_pcie_link_state      => cfg_pcie_link_state_int,  --  input

         -- Virtex6 PM
         -------------
         cfg_pm_send_pme_to       => '0',                      --  input  NOT USED FOR EP
         cfg_pmcsr_powerstate     => cfg_pmcsr_powerstate_int, --  input
         trn_rdllp_data           => trn_rdllp_data,           --  input
         trn_rdllp_src_rdy        => trn_rdllp_src_rdy,        --  input

         -- Power Mgmt for S6/V6
         -------------
         cfg_to_turnoff           => cfg_to_turnoff_int,       --  input
         cfg_turnoff_ok           => cfg_turnoff_ok_axi,       --  output

         -- System
         -------------
         user_clk                 => user_clk,                 --  input
         user_rst                 => user_reset_out_int,       --  input
         np_counter               => open                      --  output
   );

   ---------------------------------------------------------
   -- PCI Express Reset Delay Module
   ---------------------------------------------------------

   sys_reset_n <= not(sys_reset);

   pcie_reset_delay_i : pcie_reset_delay_v6
      generic map (
         PL_FAST_TRAIN  => PL_FAST_TRAIN,
         REF_CLK_FREQ   => REF_CLK_FREQ
      )
      port map (
         ref_clk              => TxOutClk_bufg,
         sys_reset_n          => sys_reset_n,
         delayed_sys_reset_n  => sys_reset_n_d
      );


   ---------------------------------------------------------
   -- PCI Express Clocking Module
   ---------------------------------------------------------

   pcie_clocking_i : pcie_clocking_v6
      generic map (
         CAP_LINK_WIDTH  => LINK_CAP_MAX_LINK_WIDTH_int,
         CAP_LINK_SPEED  => LINK_CAP_MAX_LINK_SPEED_int,
         REF_CLK_FREQ    => REF_CLK_FREQ,
         USER_CLK_FREQ   => USER_CLK_FREQ
      )
      port map (
         sys_clk        => TxOutClk,
         gt_pll_lock    => gt_pll_lock,
         sel_lnk_rate   => pl_sel_link_rate_int,
         sel_lnk_width  => pl_sel_link_width_int,
         sys_clk_bufg   => TxOutClk_bufg,
         pipe_clk       => pipe_clk,
         user_clk       => user_clk,
         block_clk      => open,
         drp_clk        => drp_clk,
         clock_locked   => clock_locked
      );


   phy_rdy <= not(phy_rdy_n);

   ---------------------------------------------------------
   -- Virtex6 PCI Express Block Module
   ---------------------------------------------------------

   pcie_2_0_i : pcie_2_0_v6
      generic map (
         REF_CLK_FREQ                              => REF_CLK_FREQ,
         PIPE_PIPELINE_STAGES                      => PIPE_PIPELINE_STAGES,
         LINK_CAP_MAX_LINK_WIDTH_int               => LINK_CAP_MAX_LINK_WIDTH_int,
         AER_BASE_PTR                              => AER_BASE_PTR,
         AER_CAP_ECRC_CHECK_CAPABLE                => AER_CAP_ECRC_CHECK_CAPABLE,
         AER_CAP_ECRC_GEN_CAPABLE                  => AER_CAP_ECRC_GEN_CAPABLE,
         AER_CAP_ID                                => AER_CAP_ID,
         AER_CAP_INT_MSG_NUM_MSI                   => AER_CAP_INT_MSG_NUM_MSI,
         AER_CAP_INT_MSG_NUM_MSIX                  => AER_CAP_INT_MSG_NUM_MSIX,
         AER_CAP_NEXTPTR                           => AER_CAP_NEXTPTR,
         AER_CAP_ON                                => AER_CAP_ON,
         AER_CAP_PERMIT_ROOTERR_UPDATE             => AER_CAP_PERMIT_ROOTERR_UPDATE,
         AER_CAP_VERSION                           => AER_CAP_VERSION,
         ALLOW_X8_GEN2                             => ALLOW_X8_GEN2,
         BAR0                                      => pad_gen(BAR0, 32),
         BAR1                                      => pad_gen(BAR1, 32),
         BAR2                                      => pad_gen(BAR2, 32),
         BAR3                                      => pad_gen(BAR3, 32),
         BAR4                                      => pad_gen(BAR4, 32),
         BAR5                                      => pad_gen(BAR5, 32),
         CAPABILITIES_PTR                          => CAPABILITIES_PTR,
         CARDBUS_CIS_POINTER                       => pad_gen(CARDBUS_CIS_POINTER, 32),
         CLASS_CODE                                => pad_gen(CLASS_CODE, 24),
         CMD_INTX_IMPLEMENTED                      => CMD_INTX_IMPLEMENTED,
         CPL_TIMEOUT_DISABLE_SUPPORTED             => CPL_TIMEOUT_DISABLE_SUPPORTED,
         CPL_TIMEOUT_RANGES_SUPPORTED              => pad_gen(CPL_TIMEOUT_RANGES_SUPPORTED, 4),
         CRM_MODULE_RSTS                           => CRM_MODULE_RSTS,
         DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE       => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE,
         DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE       => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE,
         DEV_CAP_ENDPOINT_L0S_LATENCY              => DEV_CAP_ENDPOINT_L0S_LATENCY,
         DEV_CAP_ENDPOINT_L1_LATENCY               => DEV_CAP_ENDPOINT_L1_LATENCY,
         DEV_CAP_EXT_TAG_SUPPORTED                 => DEV_CAP_EXT_TAG_SUPPORTED,
         DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE      => DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE,
         DEV_CAP_MAX_PAYLOAD_SUPPORTED             => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
         DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT         => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT,
         DEV_CAP_ROLE_BASED_ERROR                  => DEV_CAP_ROLE_BASED_ERROR,
         DEV_CAP_RSVD_14_12                        => DEV_CAP_RSVD_14_12,
         DEV_CAP_RSVD_17_16                        => DEV_CAP_RSVD_17_16,
         DEV_CAP_RSVD_31_29                        => DEV_CAP_RSVD_31_29,
         DEV_CONTROL_AUX_POWER_SUPPORTED           => DEV_CONTROL_AUX_POWER_SUPPORTED,
         DEVICE_ID                                 => pad_gen(DEVICE_ID, 16),
         DISABLE_ASPM_L1_TIMER                     => DISABLE_ASPM_L1_TIMER,
         DISABLE_BAR_FILTERING                     => DISABLE_BAR_FILTERING,
         DISABLE_ID_CHECK                          => DISABLE_ID_CHECK,
         DISABLE_LANE_REVERSAL                     => DISABLE_LANE_REVERSAL,
         DISABLE_RX_TC_FILTER                      => DISABLE_RX_TC_FILTER,
         DISABLE_SCRAMBLING                        => DISABLE_SCRAMBLING,
         DNSTREAM_LINK_NUM                         => DNSTREAM_LINK_NUM,
         DSN_BASE_PTR                              => pad_gen(DSN_BASE_PTR, 12),
         DSN_CAP_ID                                => DSN_CAP_ID,
         DSN_CAP_NEXTPTR                           => pad_gen(DSN_CAP_NEXTPTR, 12),
         DSN_CAP_ON                                => DSN_CAP_ON,
         DSN_CAP_VERSION                           => DSN_CAP_VERSION,
         ENABLE_MSG_ROUTE                          => pad_gen(ENABLE_MSG_ROUTE, 11),
         ENABLE_RX_TD_ECRC_TRIM                    => ENABLE_RX_TD_ECRC_TRIM,
         ENTER_RVRY_EI_L0                          => ENTER_RVRY_EI_L0,
         EXPANSION_ROM                             => pad_gen(EXPANSION_ROM, 32),
         EXT_CFG_CAP_PTR                           => EXT_CFG_CAP_PTR,
         EXT_CFG_XP_CAP_PTR                        => pad_gen(EXT_CFG_XP_CAP_PTR, 10),
         HEADER_TYPE                               => pad_gen(HEADER_TYPE, 8),
         INFER_EI                                  => INFER_EI,
         INTERRUPT_PIN                             => pad_gen(INTERRUPT_PIN, 8),
         IS_SWITCH                                 => IS_SWITCH,
         LAST_CONFIG_DWORD                         => LAST_CONFIG_DWORD,
         LINK_CAP_ASPM_SUPPORT                     => LINK_CAP_ASPM_SUPPORT,
         LINK_CAP_CLOCK_POWER_MANAGEMENT           => LINK_CAP_CLOCK_POWER_MANAGEMENT,
         LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP    => LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP,
         LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP  => LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP,
         LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1     => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1,
         LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2     => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2,
         LINK_CAP_L0S_EXIT_LATENCY_GEN1            => LINK_CAP_L0S_EXIT_LATENCY_GEN1,
         LINK_CAP_L0S_EXIT_LATENCY_GEN2            => LINK_CAP_L0S_EXIT_LATENCY_GEN2,
         LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1      => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1,
         LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2      => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2,
         LINK_CAP_L1_EXIT_LATENCY_GEN1             => LINK_CAP_L1_EXIT_LATENCY_GEN1,
         LINK_CAP_L1_EXIT_LATENCY_GEN2             => LINK_CAP_L1_EXIT_LATENCY_GEN2,
         LINK_CAP_MAX_LINK_SPEED                   => pad_gen(LINK_CAP_MAX_LINK_SPEED, 4),
         LINK_CAP_MAX_LINK_WIDTH                   => pad_gen(LINK_CAP_MAX_LINK_WIDTH, 6),
         LINK_CAP_RSVD_23_22                       => LINK_CAP_RSVD_23_22,
         LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE      => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE,
         LINK_CONTROL_RCB                          => LINK_CONTROL_RCB,
         LINK_CTRL2_DEEMPHASIS                     => LINK_CTRL2_DEEMPHASIS,
         LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE    => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE,
         LINK_CTRL2_TARGET_LINK_SPEED              => pad_gen(LINK_CTRL2_TARGET_LINK_SPEED, 4),
         LINK_STATUS_SLOT_CLOCK_CONFIG             => LINK_STATUS_SLOT_CLOCK_CONFIG,
         LL_ACK_TIMEOUT                            => pad_gen(LL_ACK_TIMEOUT, 15),
         LL_ACK_TIMEOUT_EN                         => LL_ACK_TIMEOUT_EN,
         LL_ACK_TIMEOUT_FUNC                       => LL_ACK_TIMEOUT_FUNC,
         LL_REPLAY_TIMEOUT                         => pad_gen(LL_REPLAY_TIMEOUT, 15),
         LL_REPLAY_TIMEOUT_EN                      => LL_REPLAY_TIMEOUT_EN,
         LL_REPLAY_TIMEOUT_FUNC                    => LL_REPLAY_TIMEOUT_FUNC,
         LTSSM_MAX_LINK_WIDTH                      => pad_gen(LTSSM_MAX_LINK_WIDTH, 6),
         MSI_BASE_PTR                              => MSI_BASE_PTR,
         MSI_CAP_ID                                => MSI_CAP_ID,
         MSI_CAP_MULTIMSGCAP                       => MSI_CAP_MULTIMSGCAP,
         MSI_CAP_MULTIMSG_EXTENSION                => MSI_CAP_MULTIMSG_EXTENSION,
         MSI_CAP_NEXTPTR                           => MSI_CAP_NEXTPTR,
         MSI_CAP_ON                                => MSI_CAP_ON,
         MSI_CAP_PER_VECTOR_MASKING_CAPABLE        => MSI_CAP_PER_VECTOR_MASKING_CAPABLE,
         MSI_CAP_64_BIT_ADDR_CAPABLE               => MSI_CAP_64_BIT_ADDR_CAPABLE,
         MSIX_BASE_PTR                             => MSIX_BASE_PTR,
         MSIX_CAP_ID                               => MSIX_CAP_ID,
         MSIX_CAP_NEXTPTR                          => MSIX_CAP_NEXTPTR,
         MSIX_CAP_ON                               => MSIX_CAP_ON,
         MSIX_CAP_PBA_BIR                          => MSIX_CAP_PBA_BIR,
         MSIX_CAP_PBA_OFFSET                       => pad_gen(MSIX_CAP_PBA_OFFSET, 29),
         MSIX_CAP_TABLE_BIR                        => MSIX_CAP_TABLE_BIR,
         MSIX_CAP_TABLE_OFFSET                     => pad_gen(MSIX_CAP_TABLE_OFFSET, 29),
         MSIX_CAP_TABLE_SIZE                       => pad_gen(MSIX_CAP_TABLE_SIZE, 11),
         N_FTS_COMCLK_GEN1                         => N_FTS_COMCLK_GEN1,
         N_FTS_COMCLK_GEN2                         => N_FTS_COMCLK_GEN2,
         N_FTS_GEN1                                => N_FTS_GEN1,
         N_FTS_GEN2                                => N_FTS_GEN2,
         PCIE_BASE_PTR                             => PCIE_BASE_PTR,
         PCIE_CAP_CAPABILITY_ID                    => PCIE_CAP_CAPABILITY_ID,
         PCIE_CAP_CAPABILITY_VERSION               => PCIE_CAP_CAPABILITY_VERSION,
         PCIE_CAP_DEVICE_PORT_TYPE                 => pad_gen(PCIE_CAP_DEVICE_PORT_TYPE, 4),
         PCIE_CAP_INT_MSG_NUM                      => pad_gen(PCIE_CAP_INT_MSG_NUM, 5),
         PCIE_CAP_NEXTPTR                          => pad_gen(PCIE_CAP_NEXTPTR, 8),
         PCIE_CAP_ON                               => PCIE_CAP_ON,
         PCIE_CAP_RSVD_15_14                       => PCIE_CAP_RSVD_15_14,
         PCIE_CAP_SLOT_IMPLEMENTED                 => PCIE_CAP_SLOT_IMPLEMENTED,
         PCIE_REVISION                             => PCIE_REVISION,
         PGL0_LANE                                 => PGL0_LANE,
         PGL1_LANE                                 => PGL1_LANE,
         PGL2_LANE                                 => PGL2_LANE,
         PGL3_LANE                                 => PGL3_LANE,
         PGL4_LANE                                 => PGL4_LANE,
         PGL5_LANE                                 => PGL5_LANE,
         PGL6_LANE                                 => PGL6_LANE,
         PGL7_LANE                                 => PGL7_LANE,
         PL_AUTO_CONFIG                            => PL_AUTO_CONFIG,
         PL_FAST_TRAIN                             => PL_FAST_TRAIN,
         PM_BASE_PTR                               => PM_BASE_PTR,
         PM_CAP_AUXCURRENT                         => PM_CAP_AUXCURRENT,
         PM_CAP_DSI                                => PM_CAP_DSI,
         PM_CAP_D1SUPPORT                          => PM_CAP_D1SUPPORT,
         PM_CAP_D2SUPPORT                          => PM_CAP_D2SUPPORT,
         PM_CAP_ID                                 => PM_CAP_ID,
         PM_CAP_NEXTPTR                            => PM_CAP_NEXTPTR,
         PM_CAP_ON                                 => PM_CAP_ON,
         PM_CAP_PME_CLOCK                          => PM_CAP_PME_CLOCK,
         PM_CAP_PMESUPPORT                         => pad_gen(PM_CAP_PMESUPPORT, 5),
         PM_CAP_RSVD_04                            => PM_CAP_RSVD_04,
         PM_CAP_VERSION                            => PM_CAP_VERSION,
         PM_CSR_BPCCEN                             => PM_CSR_BPCCEN,
         PM_CSR_B2B3                               => PM_CSR_B2B3,
         PM_CSR_NOSOFTRST                          => PM_CSR_NOSOFTRST,
         PM_DATA_SCALE0                            => pad_gen(PM_DATA_SCALE0, 2),
         PM_DATA_SCALE1                            => pad_gen(PM_DATA_SCALE1, 2),
         PM_DATA_SCALE2                            => pad_gen(PM_DATA_SCALE2, 2),
         PM_DATA_SCALE3                            => pad_gen(PM_DATA_SCALE3, 2),
         PM_DATA_SCALE4                            => pad_gen(PM_DATA_SCALE4, 2),
         PM_DATA_SCALE5                            => pad_gen(PM_DATA_SCALE5, 2),
         PM_DATA_SCALE6                            => pad_gen(PM_DATA_SCALE6, 2),
         PM_DATA_SCALE7                            => pad_gen(PM_DATA_SCALE7, 2),
         PM_DATA0                                  => pad_gen(PM_DATA0, 8),
         PM_DATA1                                  => pad_gen(PM_DATA1, 8),
         PM_DATA2                                  => pad_gen(PM_DATA2, 8),
         PM_DATA3                                  => pad_gen(PM_DATA3, 8),
         PM_DATA4                                  => pad_gen(PM_DATA4, 8),
         PM_DATA5                                  => pad_gen(PM_DATA5, 8),
         PM_DATA6                                  => pad_gen(PM_DATA6, 8),
         PM_DATA7                                  => pad_gen(PM_DATA7, 8),
         RECRC_CHK                                 => RECRC_CHK,
         RECRC_CHK_TRIM                            => RECRC_CHK_TRIM,
         REVISION_ID                               => pad_gen(REVISION_ID, 8),
         ROOT_CAP_CRS_SW_VISIBILITY                => ROOT_CAP_CRS_SW_VISIBILITY,
         SELECT_DLL_IF                             => SELECT_DLL_IF,
         SLOT_CAP_ATT_BUTTON_PRESENT               => SLOT_CAP_ATT_BUTTON_PRESENT,
         SLOT_CAP_ATT_INDICATOR_PRESENT            => SLOT_CAP_ATT_INDICATOR_PRESENT,
         SLOT_CAP_ELEC_INTERLOCK_PRESENT           => SLOT_CAP_ELEC_INTERLOCK_PRESENT,
         SLOT_CAP_HOTPLUG_CAPABLE                  => SLOT_CAP_HOTPLUG_CAPABLE,
         SLOT_CAP_HOTPLUG_SURPRISE                 => SLOT_CAP_HOTPLUG_SURPRISE,
         SLOT_CAP_MRL_SENSOR_PRESENT               => SLOT_CAP_MRL_SENSOR_PRESENT,
         SLOT_CAP_NO_CMD_COMPLETED_SUPPORT         => SLOT_CAP_NO_CMD_COMPLETED_SUPPORT,
         SLOT_CAP_PHYSICAL_SLOT_NUM                => SLOT_CAP_PHYSICAL_SLOT_NUM,
         SLOT_CAP_POWER_CONTROLLER_PRESENT         => SLOT_CAP_POWER_CONTROLLER_PRESENT,
         SLOT_CAP_POWER_INDICATOR_PRESENT          => SLOT_CAP_POWER_INDICATOR_PRESENT,
         SLOT_CAP_SLOT_POWER_LIMIT_SCALE           => SLOT_CAP_SLOT_POWER_LIMIT_SCALE,
         SLOT_CAP_SLOT_POWER_LIMIT_VALUE           => SLOT_CAP_SLOT_POWER_LIMIT_VALUE,
         SPARE_BIT0                                => SPARE_BIT0,
         SPARE_BIT1                                => SPARE_BIT1,
         SPARE_BIT2                                => SPARE_BIT2,
         SPARE_BIT3                                => SPARE_BIT3,
         SPARE_BIT4                                => SPARE_BIT4,
         SPARE_BIT5                                => SPARE_BIT5,
         SPARE_BIT6                                => SPARE_BIT6,
         SPARE_BIT7                                => SPARE_BIT7,
         SPARE_BIT8                                => SPARE_BIT8,
         SPARE_BYTE0                               => SPARE_BYTE0,
         SPARE_BYTE1                               => SPARE_BYTE1,
         SPARE_BYTE2                               => SPARE_BYTE2,
         SPARE_BYTE3                               => SPARE_BYTE3,
         SPARE_WORD0                               => SPARE_WORD0,
         SPARE_WORD1                               => SPARE_WORD1,
         SPARE_WORD2                               => SPARE_WORD2,
         SPARE_WORD3                               => SPARE_WORD3,
         SUBSYSTEM_ID                              => pad_gen(SUBSYSTEM_ID, 16),
         SUBSYSTEM_VENDOR_ID                       => pad_gen(SUBSYSTEM_VENDOR_ID, 16),
         TL_RBYPASS                                => TL_RBYPASS,
         TL_RX_RAM_RADDR_LATENCY                   => TL_RX_RAM_RADDR_LATENCY,
         TL_RX_RAM_RDATA_LATENCY                   => TL_RX_RAM_RDATA_LATENCY,
         TL_RX_RAM_WRITE_LATENCY                   => TL_RX_RAM_WRITE_LATENCY,
         TL_TFC_DISABLE                            => TL_TFC_DISABLE,
         TL_TX_CHECKS_DISABLE                      => TL_TX_CHECKS_DISABLE,
         TL_TX_RAM_RADDR_LATENCY                   => TL_TX_RAM_RADDR_LATENCY,
         TL_TX_RAM_RDATA_LATENCY                   => TL_TX_RAM_RDATA_LATENCY,
         TL_TX_RAM_WRITE_LATENCY                   => TL_TX_RAM_WRITE_LATENCY,
         UPCONFIG_CAPABLE                          => UPCONFIG_CAPABLE,
         UPSTREAM_FACING                           => UPSTREAM_FACING,
         EXIT_LOOPBACK_ON_EI                       => EXIT_LOOPBACK_ON_EI,
         UR_INV_REQ                                => UR_INV_REQ,
         USER_CLK_FREQ                             => USER_CLK_FREQ,
         VC_BASE_PTR                               => pad_gen(VC_BASE_PTR, 12),
         VC_CAP_ID                                 => VC_CAP_ID,
         VC_CAP_NEXTPTR                            => pad_gen(VC_CAP_NEXTPTR, 12),
         VC_CAP_ON                                 => VC_CAP_ON,
         VC_CAP_REJECT_SNOOP_TRANSACTIONS          => VC_CAP_REJECT_SNOOP_TRANSACTIONS,
         VC_CAP_VERSION                            => VC_CAP_VERSION,
         VC0_CPL_INFINITE                          => VC0_CPL_INFINITE,
         VC0_RX_RAM_LIMIT                          => pad_gen(VC0_RX_RAM_LIMIT, 13),
         VC0_TOTAL_CREDITS_CD                      => VC0_TOTAL_CREDITS_CD,
         VC0_TOTAL_CREDITS_CH                      => VC0_TOTAL_CREDITS_CH,
         VC0_TOTAL_CREDITS_NPH                     => VC0_TOTAL_CREDITS_NPH,
         VC0_TOTAL_CREDITS_PD                      => VC0_TOTAL_CREDITS_PD,
         VC0_TOTAL_CREDITS_PH                      => VC0_TOTAL_CREDITS_PH,
         VC0_TX_LASTPACKET                         => VC0_TX_LASTPACKET,
         VENDOR_ID                                 => pad_gen(VENDOR_ID, 16),
         VSEC_BASE_PTR                             => pad_gen(VSEC_BASE_PTR, 12),
         VSEC_CAP_HDR_ID                           => VSEC_CAP_HDR_ID,
         VSEC_CAP_HDR_LENGTH                       => VSEC_CAP_HDR_LENGTH,
         VSEC_CAP_HDR_REVISION                     => VSEC_CAP_HDR_REVISION,
         VSEC_CAP_ID                               => VSEC_CAP_ID,
         VSEC_CAP_IS_LINK_VISIBLE                  => VSEC_CAP_IS_LINK_VISIBLE,
         VSEC_CAP_NEXTPTR                          => pad_gen(VSEC_CAP_NEXTPTR, 12),
         VSEC_CAP_ON                               => VSEC_CAP_ON,
         VSEC_CAP_VERSION                          => VSEC_CAP_VERSION
      )
      port map (
         PCIEXPRXN                            => pci_exp_rxn,
         PCIEXPRXP                            => pci_exp_rxp,
         PCIEXPTXN                            => pci_exp_txn,
         PCIEXPTXP                            => pci_exp_txp,
         SYSCLK                               => sys_clk,
         TRNLNKUPN                            => trn_lnk_up_n,
         FUNDRSTN                             => sys_reset_n_d,
         PHYRDYN                              => phy_rdy_n,
         LNKCLKEN                             => open,
         USERRSTN                             => trn_reset_n,
         RECEIVEDFUNCLVLRSTN                  => rx_func_level_reset_n,
         SYSRSTN                              => phy_rdy,
         PLRSTN                               => '1',
         DLRSTN                               => '1',
         TLRSTN                               => '1',
         FUNCLVLRSTN                          => '1',
         CMRSTN                               => '1',
         CMSTICKYRSTN                         => '1',

         TRNRBARHITN                          => trn_rbar_hit_n,
         TRNRD                                => trn_rd,
         TRNRECRCERRN                         => trn_recrc_err_n,
         TRNREOFN                             => trn_reof_n,
         TRNRERRFWDN                          => trn_rerrfwd_n,
         TRNRREMN                             => trn_rrem_n,
         TRNRSOFN                             => trn_rsof_n,
         TRNRSRCDSCN                          => trn_rsrc_dsc_n,
         TRNRSRCRDYN                          => trn_rsrc_rdy_n,
         TRNRDSTRDYN                          => trn_rdst_rdy_n,
         TRNRNPOKN                            => trn_rnp_ok_n,
         TRNRDLLPDATA                         => trn_rdllp_data,
         TRNRDLLPSRCRDYN                      => trn_rdllp_src_rdy_n,

         TRNTBUFAV                            => tx_buf_av_int,
         TRNTCFGREQN                          => trn_tcfg_req_n,
         TRNTDLLPDSTRDYN                      => open,
         TRNTDSTRDYN                          => trn_tdst_rdy_n,
         TRNTERRDROPN                         => trn_terr_drop_n,
         TRNTCFGGNTN                          => trn_tcfg_gnt_n,
         TRNTD                                => trn_td,
         TRNTDLLPDATA                         => (others => '0'),
         TRNTDLLPSRCRDYN                      => '1',
         TRNTECRCGENN                         => '1',
         TRNTEOFN                             => trn_teof_n,
         TRNTERRFWDN                          => trn_terrfwd_n,
         TRNTREMN                             => trn_trem_n,
         TRNTSOFN                             => trn_tsof_n,
         TRNTSRCDSCN                          => trn_tsrc_dsc_n,
         TRNTSRCRDYN                          => trn_tsrc_rdy_n,
         TRNTSTRN                             => trn_tstr_n,
         TRNFCCPLD                            => fc_cpld,
         TRNFCCPLH                            => fc_cplh,
         TRNFCNPD                             => fc_npd,
         TRNFCNPH                             => fc_nph,
         TRNFCPD                              => fc_pd,
         TRNFCPH                              => fc_ph,
         TRNFCSEL                             => fc_sel,
         CFGAERECRCCHECKEN                    => open,
         CFGAERECRCGENEN                      => open,
         CFGCOMMANDBUSMASTERENABLE            => cfg_cmd_bme,
         CFGCOMMANDINTERRUPTDISABLE           => cfg_cmd_intdis,
         CFGCOMMANDIOENABLE                   => cfg_cmd_io_en,
         CFGCOMMANDMEMENABLE                  => cfg_cmd_mem_en,
         CFGCOMMANDSERREN                     => cfg_cmd_serr_en,
         CFGDEVCONTROLAUXPOWEREN              => cfg_dev_control_aux_power_en,
         CFGDEVCONTROLCORRERRREPORTINGEN      => cfg_dev_control_corr_err_reporting_en,
         CFGDEVCONTROLENABLERO                => cfg_dev_control_enable_relaxed_order,
         CFGDEVCONTROLEXTTAGEN                => cfg_dev_control_ext_tag_en,
         CFGDEVCONTROLFATALERRREPORTINGEN     => cfg_dev_control_fatal_err_reporting_en,
         CFGDEVCONTROLMAXPAYLOAD              => cfg_dev_control_maxpayload,
         CFGDEVCONTROLMAXREADREQ              => cfg_dev_control_max_read_req,
         CFGDEVCONTROLNONFATALREPORTINGEN     => cfg_dev_control_non_fatal_reporting_en,
         CFGDEVCONTROLNOSNOOPEN               => cfg_dev_control_nosnoop_en,
         CFGDEVCONTROLPHANTOMEN               => cfg_dev_control_phantom_en,
         CFGDEVCONTROLURERRREPORTINGEN        => cfg_dev_control_ur_err_reporting_en,
         CFGDEVCONTROL2CPLTIMEOUTDIS          => cfg_dev_control2_cpltimeout_dis,
         CFGDEVCONTROL2CPLTIMEOUTVAL          => cfg_dev_control2_cpltimeout_val,
         CFGDEVSTATUSCORRERRDETECTED          => cfg_dev_status_corr_err_detected,
         CFGDEVSTATUSFATALERRDETECTED         => cfg_dev_status_fatal_err_detected,
         CFGDEVSTATUSNONFATALERRDETECTED      => cfg_dev_status_nonfatal_err_detected,
         CFGDEVSTATUSURDETECTED               => cfg_dev_status_ur_detected,
         CFGDO                                => cfg_do,
         CFGERRAERHEADERLOGSETN               => open,
         CFGERRCPLRDYN                        => cfg_err_cpl_rdy_n,
         CFGINTERRUPTDO                       => cfg_interrupt_do,
         CFGINTERRUPTMMENABLE                 => cfg_interrupt_mmenable,
         CFGINTERRUPTMSIENABLE                => cfg_interrupt_msienable,
         CFGINTERRUPTMSIXENABLE               => cfg_interrupt_msixenable,
         CFGINTERRUPTMSIXFM                   => cfg_interrupt_msixfm,
         CFGINTERRUPTRDYN                     => cfg_interrupt_rdy_n,
         CFGLINKCONTROLRCB                    => cfg_link_control_rcb,
         CFGLINKCONTROLASPMCONTROL            => cfg_link_control_aspm_control,
         CFGLINKCONTROLAUTOBANDWIDTHINTEN     => cfg_link_control_auto_bandwidth_int_en,
         CFGLINKCONTROLBANDWIDTHINTEN         => cfg_link_control_bandwidth_int_en,
         CFGLINKCONTROLCLOCKPMEN              => cfg_link_control_clock_pm_en,
         CFGLINKCONTROLCOMMONCLOCK            => cfg_link_control_common_clock,
         CFGLINKCONTROLEXTENDEDSYNC           => cfg_link_control_extended_sync,
         CFGLINKCONTROLHWAUTOWIDTHDIS         => cfg_link_control_hw_auto_width_dis,
         CFGLINKCONTROLLINKDISABLE            => cfg_link_control_linkdisable,
         CFGLINKCONTROLRETRAINLINK            => cfg_link_control_retrain_link,
         CFGLINKSTATUSAUTOBANDWIDTHSTATUS     => cfg_link_status_autobandwidth_status,
         CFGLINKSTATUSBANDWITHSTATUS          => cfg_link_status_bandwidth_status,
         CFGLINKSTATUSCURRENTSPEED            => cfg_link_status_current_speed,
         CFGLINKSTATUSDLLACTIVE               => cfg_link_status_dll_active,
         CFGLINKSTATUSLINKTRAINING            => cfg_link_status_link_training,
         CFGLINKSTATUSNEGOTIATEDWIDTH         => cfg_link_status_negotiated_link_width,
         CFGMSGDATA                           => cfg_msg_data,
         CFGMSGRECEIVED                       => cfg_msg_received,
         CFGMSGRECEIVEDASSERTINTA             => open,
         CFGMSGRECEIVEDASSERTINTB             => open,
         CFGMSGRECEIVEDASSERTINTC             => open,
         CFGMSGRECEIVEDASSERTINTD             => open,
         CFGMSGRECEIVEDDEASSERTINTA           => open,
         CFGMSGRECEIVEDDEASSERTINTB           => open,
         CFGMSGRECEIVEDDEASSERTINTC           => open,
         CFGMSGRECEIVEDDEASSERTINTD           => open,
         CFGMSGRECEIVEDERRCOR                 => open,
         CFGMSGRECEIVEDERRFATAL               => open,
         CFGMSGRECEIVEDERRNONFATAL            => open,
         CFGMSGRECEIVEDPMASNAK                => open,
         CFGMSGRECEIVEDPMETO                  => cfg_msg_received_pme_to,
         CFGMSGRECEIVEDPMETOACK               => open,
         CFGMSGRECEIVEDPMPME                  => open,
         CFGMSGRECEIVEDSETSLOTPOWERLIMIT      => open,
         CFGMSGRECEIVEDUNLOCK                 => open,
         CFGPCIELINKSTATE                     => cfg_pcie_link_state_int,
         CFGPMCSRPMEEN                        => cfg_pmcsr_pme_en,
         CFGPMCSRPMESTATUS                    => cfg_pmcsr_pme_status,
         CFGPMCSRPOWERSTATE                   => cfg_pmcsr_powerstate_int,
         CFGPMRCVASREQL1N                     => open,
         CFGPMRCVENTERL1N                     => open,
         CFGPMRCVENTERL23N                    => open,
         CFGPMRCVREQACKN                      => open,
         CFGRDWRDONEN                         => cfg_rd_wr_done_n,
         CFGSLOTCONTROLELECTROMECHILCTLPULSE  => open,
         CFGTRANSACTION                       => open,
         CFGTRANSACTIONADDR                   => open,
         CFGTRANSACTIONTYPE                   => open,
         CFGVCTCVCMAP                         => open,
         CFGBYTEENN                           => cfg_byte_en_n,
         CFGDI                                => cfg_di,
         CFGDSBUSNUMBER                       => "00000000",
         CFGDSDEVICENUMBER                    => "00000",
         CFGDSFUNCTIONNUMBER                  => "000",
         CFGDSN                               => cfg_dsn,
         CFGDWADDR                            => cfg_dwaddr,
         CFGERRACSN                           => '1',
         CFGERRAERHEADERLOG                   => (others => '0'),
         CFGERRCORN                           => cfg_err_cor_n,
         CFGERRCPLABORTN                      => cfg_err_cpl_abort_n,
         CFGERRCPLTIMEOUTN                    => cfg_err_cpl_timeout_n,
         CFGERRCPLUNEXPECTN                   => cfg_err_cpl_unexpect_n,
         CFGERRECRCN                          => cfg_err_ecrc_n,
         CFGERRLOCKEDN                        => cfg_err_locked_n,
         CFGERRPOSTEDN                        => cfg_err_posted_n,
         CFGERRTLPCPLHEADER                   => cfg_err_tlp_cpl_header,
         CFGERRURN                            => cfg_err_ur_n,
         CFGINTERRUPTASSERTN                  => cfg_interrupt_assert_n,
         CFGINTERRUPTDI                       => cfg_interrupt_di,
         CFGINTERRUPTN                        => cfg_interrupt_n,
         CFGPMDIRECTASPML1N                   => '1',
         CFGPMSENDPMACKN                      => '1',
         CFGPMSENDPMETON                      => '1',
         CFGPMSENDPMNAKN                      => '1',
         CFGPMTURNOFFOKN                      => cfg_turnoff_ok_n,
         CFGPMWAKEN                           => cfg_pm_wake_n,
         CFGPORTNUMBER                        => "00000000",
         CFGRDENN                             => cfg_rd_en_n,
         CFGTRNPENDINGN                       => cfg_trn_pending_n,
         CFGWRENN                             => cfg_wr_en_n,
         CFGWRREADONLYN                       => '1',
         CFGWRRW1CASRWN                       => '1',

         PLINITIALLINKWIDTH                   => pl_initial_link_width,
         PLLANEREVERSALMODE                   => pl_lane_reversal_mode,
         PLLINKGEN2CAP                        => pl_link_gen2_capable,
         PLLINKPARTNERGEN2SUPPORTED           => pl_link_partner_gen2_supported,
         PLLINKUPCFGCAP                       => pl_link_upcfg_capable,
         PLLTSSMSTATE                         => pl_ltssm_state,
         PLPHYLNKUPN                          => open,                                 -- Debug
         PLRECEIVEDHOTRST                     => pl_received_hot_rst,
         PLRXPMSTATE                          => open,                                 -- Debug
         PLSELLNKRATE                         => pl_sel_link_rate_int,
         PLSELLNKWIDTH                        => pl_sel_link_width_int,
         PLTXPMSTATE                          => open,                                 -- Debug
         PLDIRECTEDLINKAUTON                  => pl_directed_link_auton,
         PLDIRECTEDLINKCHANGE                 => pl_directed_link_change,
         PLDIRECTEDLINKSPEED                  => pl_directed_link_speed,
         PLDIRECTEDLINKWIDTH                  => pl_directed_link_width,
         PLDOWNSTREAMDEEMPHSOURCE             => '1',
         PLUPSTREAMPREFERDEEMPH               => pl_upstream_prefer_deemph,
         PLTRANSMITHOTRST                     => '0',

         DBGSCLRA                             => open,
         DBGSCLRB                             => open,
         DBGSCLRC                             => open,
         DBGSCLRD                             => open,
         DBGSCLRE                             => open,
         DBGSCLRF                             => open,
         DBGSCLRG                             => open,
         DBGSCLRH                             => open,
         DBGSCLRI                             => open,
         DBGSCLRJ                             => open,
         DBGSCLRK                             => open,
         DBGVECA                              => open,
         DBGVECB                              => open,
         DBGVECC                              => open,
         PLDBGVEC                             => open,
         DBGMODE                              => "00",
         DBGSUBMODE                           => '0',
         PLDBGMODE                            => "000",

         PCIEDRPDO                            => open,
         PCIEDRPDRDY                          => open,
         PCIEDRPCLK                           => '0',
         PCIEDRPDADDR                         => "000000000",
         PCIEDRPDEN                           => '0',
         PCIEDRPDI                            => X"0000",
         PCIEDRPDWE                           => '0',

         GTPLLLOCK                            => gt_pll_lock,
         PIPECLK                              => pipe_clk,
         USERCLK                              => user_clk,
         DRPCLK                               => drp_clk,
         CLOCKLOCKED                          => clock_locked,
         TxOutClk                             => TxOutClk
      );

end v6_pcie;

