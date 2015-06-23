-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : cl_a7pcie_x4_pcie_top.vhd
-- Version    : 1.11
-- Description: Solution wrapper for Virtex7 Hard Block for PCI Express
--
--
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

--library unisim;
--use unisim.vcomponents.all;

entity cl_a7pcie_x4_pcie_top is
  generic (
  -- PCIE_2_1 params
  C_DATA_WIDTH                                   : INTEGER range 64 to 128 := 64;
  C_REM_WIDTH                                    : INTEGER range 0 to 128  :=  1;
  PIPE_PIPELINE_STAGES                           : INTEGER range 0 to 2 := 0;      -- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
  -- PCIE_2_1 params
  AER_BASE_PTR                                   : bit_vector := X"140";
  AER_CAP_ECRC_CHECK_CAPABLE                     : string     := "FALSE";
  AER_CAP_ECRC_GEN_CAPABLE                       : string     := "FALSE";
  AER_CAP_ID                                     : bit_vector := X"0001";
  AER_CAP_MULTIHEADER                            : string     := "FALSE";
  AER_CAP_NEXTPTR                                : bit_vector := X"178";
  AER_CAP_ON                                     : string     := "FALSE";
  AER_CAP_OPTIONAL_ERR_SUPPORT                   : bit_vector := X"000000";
  AER_CAP_PERMIT_ROOTERR_UPDATE                  : string     := "TRUE";
  AER_CAP_VERSION                                : bit_vector := X"2";
  ALLOW_X8_GEN2                                  : string     := "FALSE";
  BAR0                                           : bit_vector := X"FFFFFF00";
  BAR1                                           : bit_vector := X"FFFF0000";
  BAR2                                           : bit_vector := X"FFFF000C";
  BAR3                                           : bit_vector := X"FFFFFFFF";
  BAR4                                           : bit_vector := X"00000000";
  BAR5                                           : bit_vector := X"00000000";
  CAPABILITIES_PTR                               : bit_vector := X"40";
  CARDBUS_CIS_POINTER                            : bit_vector := X"00000000";
  CFG_ECRC_ERR_CPLSTAT                           : integer    := 0;
  CLASS_CODE                                     : bit_vector := X"000000";
  CMD_INTX_IMPLEMENTED                           : string     := "TRUE";
  CPL_TIMEOUT_DISABLE_SUPPORTED                  : string     := "FALSE";
  CPL_TIMEOUT_RANGES_SUPPORTED                   : bit_vector := X"0";
  CRM_MODULE_RSTS                                : bit_vector := X"00";
  DEV_CAP2_ARI_FORWARDING_SUPPORTED              : string     := "FALSE";
  DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED        : string     := "FALSE";
  DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED        : string     := "FALSE";
  DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED            : string     := "FALSE";
  DEV_CAP2_CAS128_COMPLETER_SUPPORTED            : string     := "FALSE";
  DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED           : string     := "FALSE";
  DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED          : string     := "FALSE";
  DEV_CAP2_LTR_MECHANISM_SUPPORTED               : string     := "FALSE";
  DEV_CAP2_MAX_ENDEND_TLP_PREFIXES               : bit_vector := X"0";
  DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING            : string     := "FALSE";
  DEV_CAP2_TPH_COMPLETER_SUPPORTED               : bit_vector := X"0";
  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE            : string     := "TRUE";
  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE            : string     := "TRUE";
  DEV_CAP_ENDPOINT_L0S_LATENCY                   : integer    := 0;
  DEV_CAP_ENDPOINT_L1_LATENCY                    : integer    := 0;
  DEV_CAP_EXT_TAG_SUPPORTED                      : string     := "TRUE";
  DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE           : string     := "FALSE";
  DEV_CAP_MAX_PAYLOAD_SUPPORTED                  : integer    := 2;
  DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT              : integer    := 0;
  DEV_CAP_ROLE_BASED_ERROR                       : string     := "TRUE";
  DEV_CAP_RSVD_14_12                             : integer    := 0;
  DEV_CAP_RSVD_17_16                             : integer    := 0;
  DEV_CAP_RSVD_31_29                             : integer    := 0;
  DEV_CONTROL_AUX_POWER_SUPPORTED                : string     := "FALSE";
  DEV_CONTROL_EXT_TAG_DEFAULT                    : string     := "FALSE";
  DISABLE_ASPM_L1_TIMER                          : string     := "FALSE";
  DISABLE_BAR_FILTERING                          : string     := "FALSE";
  DISABLE_ERR_MSG                                : string     := "FALSE";
  DISABLE_ID_CHECK                               : string     := "FALSE";
  DISABLE_LANE_REVERSAL                          : string     := "FALSE";
  DISABLE_LOCKED_FILTER                          : string     := "FALSE";
  DISABLE_PPM_FILTER                             : string     := "FALSE";
  DISABLE_RX_POISONED_RESP                       : string     := "FALSE";
  DISABLE_RX_TC_FILTER                           : string     := "FALSE";
  DISABLE_SCRAMBLING                             : string     := "FALSE";
  DNSTREAM_LINK_NUM                              : bit_vector := X"00";
  DSN_BASE_PTR                                   : bit_vector := X"100";
  DSN_CAP_ID                                     : bit_vector := X"0003";
  DSN_CAP_NEXTPTR                                : bit_vector := X"10C";
  DSN_CAP_ON                                     : string     := "TRUE";
  DSN_CAP_VERSION                                : bit_vector := X"1";
  ENABLE_MSG_ROUTE                               : bit_vector := X"000";
  ENABLE_RX_TD_ECRC_TRIM                         : string     := "FALSE";
  ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED         : string     := "FALSE";
  ENTER_RVRY_EI_L0                               : string     := "TRUE";
  EXIT_LOOPBACK_ON_EI                            : string     := "TRUE";
  EXPANSION_ROM                                  : bit_vector := X"FFFFF001";
  EXT_CFG_CAP_PTR                                : bit_vector := X"3F";
  EXT_CFG_XP_CAP_PTR                             : bit_vector := X"3FF";
  HEADER_TYPE                                    : bit_vector := X"00";
  INFER_EI                                       : bit_vector := X"00";
  INTERRUPT_PIN                                  : bit_vector := X"01";
  INTERRUPT_STAT_AUTO                            : string     := "TRUE";
  IS_SWITCH                                      : string     := "FALSE";
  LAST_CONFIG_DWORD                              : bit_vector := X"3FF";
  LINK_CAP_ASPM_OPTIONALITY                      : string     := "TRUE";
  LINK_CAP_ASPM_SUPPORT                          : integer    := 1;
  LINK_CAP_CLOCK_POWER_MANAGEMENT                : string     := "FALSE";
  LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP         : string     := "FALSE";
  LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1          : integer    := 7;
  LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2          : integer    := 7;
  LINK_CAP_L0S_EXIT_LATENCY_GEN1                 : integer    := 7;
  LINK_CAP_L0S_EXIT_LATENCY_GEN2                 : integer    := 7;
  LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1           : integer    := 7;
  LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2           : integer    := 7;
  LINK_CAP_L1_EXIT_LATENCY_GEN1                  : integer    := 7;
  LINK_CAP_L1_EXIT_LATENCY_GEN2                  : integer    := 7;
  LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP       : string     := "FALSE";
  LINK_CAP_MAX_LINK_SPEED                        : bit_vector := X"1";
  LINK_CAP_MAX_LINK_SPEED_int                    : integer    := 1;
  LINK_CAP_MAX_LINK_WIDTH                        : bit_vector := X"08";
  LINK_CAP_MAX_LINK_WIDTH_int                    : integer    := 8;
  LINK_CAP_RSVD_23                               : integer    := 0;
  LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE           : string     := "FALSE";
  LINK_CONTROL_RCB                               : integer    := 0;
  LINK_CTRL2_DEEMPHASIS                          : string     := "FALSE";
  LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE         : string     := "FALSE";
  LINK_CTRL2_TARGET_LINK_SPEED                   : bit_vector := X"2";
  LINK_STATUS_SLOT_CLOCK_CONFIG                  : string     := "TRUE";
  LL_ACK_TIMEOUT                                 : bit_vector := X"0000";
  LL_ACK_TIMEOUT_EN                              : string     := "FALSE";
  LL_ACK_TIMEOUT_FUNC                            : integer    := 0;
  LL_REPLAY_TIMEOUT                              : bit_vector := X"0000";
  LL_REPLAY_TIMEOUT_EN                           : string     := "FALSE";
  LL_REPLAY_TIMEOUT_FUNC                         : integer    := 0;
  LTSSM_MAX_LINK_WIDTH                           : bit_vector := X"01";
  MPS_FORCE                                      : string     := "FALSE";
  MSIX_BASE_PTR                                  : bit_vector := X"9C";
  MSIX_CAP_ID                                    : bit_vector := X"11";
  MSIX_CAP_NEXTPTR                               : bit_vector := X"00";
  MSIX_CAP_ON                                    : string     := "FALSE";
  MSIX_CAP_PBA_BIR                               : integer    := 0;
  MSIX_CAP_PBA_OFFSET                            : bit_vector := X"00000050";
  MSIX_CAP_TABLE_BIR                             : integer    := 0;
  MSIX_CAP_TABLE_OFFSET                          : bit_vector := X"00000040";
  MSIX_CAP_TABLE_SIZE                            : bit_vector := X"000";
  MSI_BASE_PTR                                   : bit_vector := X"48";
  MSI_CAP_64_BIT_ADDR_CAPABLE                    : string     := "TRUE";
  MSI_CAP_ID                                     : bit_vector := X"05";
  MSI_CAP_MULTIMSGCAP                            : integer    := 0;
  MSI_CAP_MULTIMSG_EXTENSION                     : integer    := 0;
  MSI_CAP_NEXTPTR                                : bit_vector := X"60";
  MSI_CAP_ON                                     : string     := "FALSE";
  MSI_CAP_PER_VECTOR_MASKING_CAPABLE             : string     := "TRUE";
  N_FTS_COMCLK_GEN1                              : integer    := 255;
  N_FTS_COMCLK_GEN2                              : integer    := 255;
  N_FTS_GEN1                                     : integer    := 255;
  N_FTS_GEN2                                     : integer    := 255;
  PCIE_BASE_PTR                                  : bit_vector := X"60";
  PCIE_CAP_CAPABILITY_ID                         : bit_vector := X"10";
  PCIE_CAP_CAPABILITY_VERSION                    : bit_vector := X"2";
  PCIE_CAP_DEVICE_PORT_TYPE                      : bit_vector := X"0";
  PCIE_CAP_NEXTPTR                               : bit_vector := X"9C";
  PCIE_CAP_ON                                    : string     := "TRUE";
  PCIE_CAP_RSVD_15_14                            : integer    := 0;
  PCIE_CAP_SLOT_IMPLEMENTED                      : string     := "FALSE";
  PCIE_REVISION                                  : integer    := 2;
  PL_AUTO_CONFIG                                 : integer    := 0;
  PL_FAST_TRAIN                                  : string     := "FALSE";
  PM_ASPML0S_TIMEOUT                             : bit_vector := X"0000";
  PM_ASPML0S_TIMEOUT_EN                          : string     := "FALSE";
  PM_ASPML0S_TIMEOUT_FUNC                        : integer    := 0;
  PM_ASPM_FASTEXIT                               : string     := "FALSE";
  PM_BASE_PTR                                    : bit_vector := X"40";
  PM_CAP_AUXCURRENT                              : integer    := 0;
  PM_CAP_D1SUPPORT                               : string     := "TRUE";
  PM_CAP_D2SUPPORT                               : string     := "TRUE";
  PM_CAP_DSI                                     : string     := "FALSE";
  PM_CAP_ID                                      : bit_vector := X"01";
  PM_CAP_NEXTPTR                                 : bit_vector := X"48";
  PM_CAP_ON                                      : string     := "TRUE";
  PM_CAP_PMESUPPORT                              : bit_vector := X"0F";
  PM_CAP_PME_CLOCK                               : string     := "FALSE";
  PM_CAP_RSVD_04                                 : integer    := 0;
  PM_CAP_VERSION                                 : integer    := 3;
  PM_CSR_B2B3                                    : string     := "FALSE";
  PM_CSR_BPCCEN                                  : string     := "FALSE";
  PM_CSR_NOSOFTRST                               : string     := "TRUE";
  PM_DATA0                                       : bit_vector := X"01";
  PM_DATA1                                       : bit_vector := X"01";
  PM_DATA2                                       : bit_vector := X"01";
  PM_DATA3                                       : bit_vector := X"01";
  PM_DATA4                                       : bit_vector := X"01";
  PM_DATA5                                       : bit_vector := X"01";
  PM_DATA6                                       : bit_vector := X"01";
  PM_DATA7                                       : bit_vector := X"01";
  PM_DATA_SCALE0                                 : bit_vector := X"1";
  PM_DATA_SCALE1                                 : bit_vector := X"1";
  PM_DATA_SCALE2                                 : bit_vector := X"1";
  PM_DATA_SCALE3                                 : bit_vector := X"1";
  PM_DATA_SCALE4                                 : bit_vector := X"1";
  PM_DATA_SCALE5                                 : bit_vector := X"1";
  PM_DATA_SCALE6                                 : bit_vector := X"1";
  PM_DATA_SCALE7                                 : bit_vector := X"1";
  PM_MF                                          : string     := "FALSE";
  RBAR_BASE_PTR                                  : bit_vector := X"178";
  RBAR_CAP_CONTROL_ENCODEDBAR0                   : bit_vector := X"00";
  RBAR_CAP_CONTROL_ENCODEDBAR1                   : bit_vector := X"00";
  RBAR_CAP_CONTROL_ENCODEDBAR2                   : bit_vector := X"00";
  RBAR_CAP_CONTROL_ENCODEDBAR3                   : bit_vector := X"00";
  RBAR_CAP_CONTROL_ENCODEDBAR4                   : bit_vector := X"00";
  RBAR_CAP_CONTROL_ENCODEDBAR5                   : bit_vector := X"00";
  RBAR_CAP_ID                                    : bit_vector := X"0015";
  RBAR_CAP_INDEX0                                : bit_vector := X"0";
  RBAR_CAP_INDEX1                                : bit_vector := X"0";
  RBAR_CAP_INDEX2                                : bit_vector := X"0";
  RBAR_CAP_INDEX3                                : bit_vector := X"0";
  RBAR_CAP_INDEX4                                : bit_vector := X"0";
  RBAR_CAP_INDEX5                                : bit_vector := X"0";
  RBAR_CAP_NEXTPTR                               : bit_vector := X"000";
  RBAR_CAP_ON                                    : string     := "FALSE";
  RBAR_CAP_SUP0                                  : bit_vector := X"00000000";
  RBAR_CAP_SUP1                                  : bit_vector := X"00000000";
  RBAR_CAP_SUP2                                  : bit_vector := X"00000000";
  RBAR_CAP_SUP3                                  : bit_vector := X"00000000";
  RBAR_CAP_SUP4                                  : bit_vector := X"00000000";
  RBAR_CAP_SUP5                                  : bit_vector := X"00000000";
  RBAR_CAP_VERSION                               : bit_vector := X"1";
  RBAR_NUM                                       : bit_vector := X"1";
  RECRC_CHK                                      : integer    := 0;
  RECRC_CHK_TRIM                                 : string     := "FALSE";
  ROOT_CAP_CRS_SW_VISIBILITY                     : string     := "FALSE";
  RP_AUTO_SPD                                    : bit_vector := X"1";
  RP_AUTO_SPD_LOOPCNT                            : bit_vector := X"1F";
  SELECT_DLL_IF                                  : string     := "FALSE";
  SIM_VERSION                                    : string     := "1.0";
  SLOT_CAP_ATT_BUTTON_PRESENT                    : string     := "FALSE";
  SLOT_CAP_ATT_INDICATOR_PRESENT                 : string     := "FALSE";
  SLOT_CAP_ELEC_INTERLOCK_PRESENT                : string     := "FALSE";
  SLOT_CAP_HOTPLUG_CAPABLE                       : string     := "FALSE";
  SLOT_CAP_HOTPLUG_SURPRISE                      : string     := "FALSE";
  SLOT_CAP_MRL_SENSOR_PRESENT                    : string     := "FALSE";
  SLOT_CAP_NO_CMD_COMPLETED_SUPPORT              : string     := "FALSE";
  SLOT_CAP_PHYSICAL_SLOT_NUM                     : bit_vector := X"0000";
  SLOT_CAP_POWER_CONTROLLER_PRESENT              : string     := "FALSE";
  SLOT_CAP_POWER_INDICATOR_PRESENT               : string     := "FALSE";
  SLOT_CAP_SLOT_POWER_LIMIT_SCALE                : integer    := 0;
  SLOT_CAP_SLOT_POWER_LIMIT_VALUE                : bit_vector := X"00";
  SPARE_BIT0                                     : integer    := 0;
  SPARE_BIT1                                     : integer    := 0;
  SPARE_BIT2                                     : integer    := 0;
  SPARE_BIT3                                     : integer    := 0;
  SPARE_BIT4                                     : integer    := 0;
  SPARE_BIT5                                     : integer    := 0;
  SPARE_BIT6                                     : integer    := 0;
  SPARE_BIT7                                     : integer    := 0;
  SPARE_BIT8                                     : integer    := 0;
  SPARE_BYTE0                                    : bit_vector := X"00";
  SPARE_BYTE1                                    : bit_vector := X"00";
  SPARE_BYTE2                                    : bit_vector := X"00";
  SPARE_BYTE3                                    : bit_vector := X"00";
  SPARE_WORD0                                    : bit_vector := X"00000000";
  SPARE_WORD1                                    : bit_vector := X"00000000";
  SPARE_WORD2                                    : bit_vector := X"00000000";
  SPARE_WORD3                                    : bit_vector := X"00000000";
  SSL_MESSAGE_AUTO                               : string     := "FALSE";
  TECRC_EP_INV                                   : string     := "FALSE";
  TL_RBYPASS                                     : string     := "FALSE";
  TL_RX_RAM_RADDR_LATENCY                        : integer    := 0;
  TL_RX_RAM_RDATA_LATENCY                        : integer    := 2;
  TL_RX_RAM_WRITE_LATENCY                        : integer    := 0;
  TL_TFC_DISABLE                                 : string     := "FALSE";
  TL_TX_CHECKS_DISABLE                           : string     := "FALSE";
  TL_TX_RAM_RADDR_LATENCY                        : integer    := 0;
  TL_TX_RAM_RDATA_LATENCY                        : integer    := 2;
  TL_TX_RAM_WRITE_LATENCY                        : integer    := 0;
  TRN_DW                                         : string     := "FALSE";
  TRN_NP_FC                                      : string     := "FALSE";
  UPCONFIG_CAPABLE                               : string     := "TRUE";
  UPSTREAM_FACING                                : string     := "TRUE";
  UR_ATOMIC                                      : string     := "TRUE";
  UR_CFG1                                        : string     := "TRUE";
  UR_INV_REQ                                     : string     := "TRUE";
  UR_PRS_RESPONSE                                : string     := "TRUE";
  USER_CLK2_DIV2                                 : string     := "FALSE";
  USER_CLK_FREQ                                  : integer    := 3;
  USE_RID_PINS                                   : string     := "FALSE";
  VC0_CPL_INFINITE                               : string     := "TRUE";
  VC0_RX_RAM_LIMIT                               : bit_vector := X"03FF";
  VC0_TOTAL_CREDITS_CD                           : integer    := 127;
  VC0_TOTAL_CREDITS_CH                           : integer    := 31;
  VC0_TOTAL_CREDITS_NPD                          : integer    := 24;
  VC0_TOTAL_CREDITS_NPH                          : integer    := 12;
  VC0_TOTAL_CREDITS_PD                           : integer    := 288;
  VC0_TOTAL_CREDITS_PH                           : integer    := 32;
  VC0_TX_LASTPACKET                              : integer    := 31;
  VC_BASE_PTR                                    : bit_vector := X"10C";
  VC_CAP_ID                                      : bit_vector := X"0002";
  VC_CAP_NEXTPTR                                 : bit_vector := X"000";
  VC_CAP_ON                                      : string     := "FALSE";
  VC_CAP_REJECT_SNOOP_TRANSACTIONS               : string     := "FALSE";
  VC_CAP_VERSION                                 : bit_vector := X"1";
  VSEC_BASE_PTR                                  : bit_vector := X"128";
  VSEC_CAP_HDR_ID                                : bit_vector := X"1234";
  VSEC_CAP_HDR_LENGTH                            : bit_vector := X"018";
  VSEC_CAP_HDR_REVISION                          : bit_vector := X"1";
  VSEC_CAP_ID                                    : bit_vector := X"000B";
  VSEC_CAP_IS_LINK_VISIBLE                       : string     := "TRUE";
  VSEC_CAP_NEXTPTR                               : bit_vector := X"140";
  VSEC_CAP_ON                                    : string     := "FALSE";
  VSEC_CAP_VERSION                               : bit_vector := X"1"
  );
  port (

  -- wrapper input
  -- Common
  user_clk_out                                   : out std_logic;
  user_reset                                     : in std_logic;
  user_lnk_up                                    : in std_logic;

  trn_lnk_up                                     : out std_logic;
  user_rst_n                                     : out std_logic;

  -- Tx
  tx_buf_av                                      : out std_logic_vector(5 downto 0);
  tx_cfg_req                                     : out std_logic;
  tx_err_drop                                    : out std_logic;
  s_axis_tx_tready                               : out std_logic;
  s_axis_tx_tdata                                : in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  s_axis_tx_tkeep                                : in std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
  s_axis_tx_tlast                                : in std_logic;
  s_axis_tx_tvalid                               : in std_logic;
  s_axis_tx_tuser                                : in std_logic_vector(3 downto 0);
  tx_cfg_gnt                                     : in std_logic;

  -- Rx
  m_axis_rx_tdata                                : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  m_axis_rx_tkeep                                : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
  m_axis_rx_tlast                                : out std_logic;
  m_axis_rx_tvalid                               : out std_logic;
  m_axis_rx_tready                               : in std_logic;
  m_axis_rx_tuser                                : out std_logic_vector(21 downto 0);
  rx_np_ok                                       : in std_logic;
  rx_np_req                                      : in std_logic;

  -- Flow Control
  fc_cpld                                        : out std_logic_vector(11 downto 0);
  fc_cplh                                        : out std_logic_vector(7 downto 0);
  fc_npd                                         : out std_logic_vector(11 downto 0);
  fc_nph                                         : out std_logic_vector(7 downto 0);
  fc_pd                                          : out std_logic_vector(11 downto 0);
  fc_ph                                          : out std_logic_vector(7 downto 0);
  fc_sel                                         : in std_logic_vector(2 downto 0);

  pl_directed_link_change                        : in std_logic_vector(1 downto 0);
  pl_directed_link_width                         : in std_logic_vector(1 downto 0);
  pl_directed_link_speed                         : in std_logic;
  pl_directed_link_auton                         : in std_logic;
  pl_upstream_prefer_deemph                      : in std_logic;
  pl_downstream_deemph_source                    : in std_logic;
  pl_directed_ltssm_new_vld                      : in std_logic;
  pl_directed_ltssm_new                          : in std_logic_vector (5 downto 0);
  pl_directed_ltssm_stall                        : in std_logic;

  cm_rst_n                                       : in std_logic;
  func_lvl_rst_n                                 : in std_logic;
  pl_transmit_hot_rst                            : in std_logic;
  cfg_mgmt_di                                    : in std_logic_vector(31 downto 0);
  cfg_mgmt_byte_en_n                             : in std_logic_vector(3 downto 0);
  cfg_mgmt_dwaddr                                : in std_logic_vector(9 downto 0);
  cfg_mgmt_wr_rw1c_as_rw_n                       : in std_logic;
  cfg_mgmt_wr_readonly_n                         : in std_logic;
  cfg_mgmt_wr_en_n                               : in std_logic;
  cfg_mgmt_rd_en_n                               : in std_logic;
  cfg_err_malformed_n                            : in std_logic;
  cfg_err_cor_n                                  : in std_logic;
  cfg_err_ur_n                                   : in std_logic;
  cfg_err_ecrc_n                                 : in std_logic;
  cfg_err_cpl_timeout_n                          : in std_logic;
  cfg_err_cpl_abort_n                            : in std_logic;
  cfg_err_cpl_unexpect_n                         : in std_logic;
  cfg_err_poisoned_n                             : in std_logic;
  cfg_err_acs_n                                  : in std_logic;
  cfg_err_atomic_egress_blocked_n                : in std_logic;
  cfg_err_mc_blocked_n                           : in std_logic;
  cfg_err_internal_uncor_n                       : in std_logic;
  cfg_err_internal_cor_n                         : in std_logic;
  cfg_err_posted_n                               : in std_logic;
  cfg_err_locked_n                               : in std_logic;
  cfg_err_norecovery_n                           : in std_logic;
  cfg_err_aer_headerlog                          : in std_logic_vector(127 downto 0);
  cfg_err_tlp_cpl_header                         : in std_logic_vector(47 downto 0);
  cfg_interrupt_n                                : in std_logic;
  cfg_interrupt_di                               : in std_logic_vector(7 downto 0);
  cfg_interrupt_assert_n                         : in std_logic;
  cfg_interrupt_stat_n                           : in std_logic;
  cfg_ds_bus_number                              : in std_logic_vector(7 downto 0);
  cfg_ds_device_number                           : in std_logic_vector(4 downto 0);
  cfg_ds_function_number                         : in std_logic_vector( 2 downto 0);
  cfg_port_number                                : in std_logic_vector(7 downto 0);
  cfg_pm_halt_aspm_l0s_n                         : in std_logic;
  cfg_pm_halt_aspm_l1_n                          : in std_logic;
  cfg_pm_force_state_en_n                        : in std_logic;
  cfg_pm_force_state                             : in std_logic_vector(1 downto 0);
  cfg_pm_wake_n                                  : in std_logic;
  cfg_turnoff_ok                                 : in std_logic;
  cfg_pm_send_pme_to_n                           : in std_logic;
  cfg_pciecap_interrupt_msgnum                   : in std_logic_vector(4 downto 0);
  cfg_trn_pending                                : in std_logic;
  cfg_force_mps                                  : in std_logic_vector( 2 downto 0);
  cfg_force_common_clock_off                     : in std_logic;
  cfg_force_extended_sync_on                     : in std_logic;
  cfg_dsn                                        : in std_logic_vector(63 downto 0);
  cfg_aer_interrupt_msgnum                       : in std_logic_vector(4 downto 0);
  cfg_dev_id                                     : in std_logic_vector(15 downto 0);
  cfg_vend_id                                    : in std_logic_vector(15 downto 0);
  cfg_rev_id                                     : in std_logic_vector(7 downto 0);
  cfg_subsys_id                                  : in std_logic_vector(15 downto 0);
  cfg_subsys_vend_id                             : in std_logic_vector(15 downto 0);
  drp_clk                                        : in std_logic;
  drp_en                                         : in std_logic;
  drp_we                                         : in std_logic;
  drp_addr                                       : in std_logic_vector(8 downto 0);
  drp_di                                         : in std_logic_vector(15 downto 0);
  drp_rdy                                        : out std_logic;
  drp_do                                         : out std_logic_vector(15 downto 0);
  dbg_mode                                       : in std_logic_vector(1 downto 0);
  dbg_sub_mode                                   : in std_logic;
  pl_dbg_mode                                    : in std_logic_vector(2 downto 0);

  pl_sel_lnk_rate                                : out std_logic;
  pl_sel_lnk_width                               : out std_logic_vector(1 downto 0);
  pl_ltssm_state                                 : out std_logic_vector(5 downto 0);
  pl_lane_reversal_mode                          : out std_logic_vector(1 downto 0);
  pl_phy_lnk_up                                  : out std_logic;
  pl_tx_pm_state                                 : out std_logic_vector(2 downto 0);
  pl_rx_pm_state                                 : out std_logic_vector(1 downto 0);
  pl_link_upcfg_cap                              : out std_logic;
  pl_link_gen2_cap                               : out std_logic;
  pl_link_partner_gen2_supported                 : out std_logic;
  pl_initial_link_width                          : out std_logic_vector(2 downto 0);
  pl_directed_change_done                        : out std_logic;
  pl_received_hot_rst                            : out std_logic;
  lnk_clk_en                                     : out std_logic;
  cfg_mgmt_do                                    : out std_logic_vector(31 downto 0);
  cfg_mgmt_rd_wr_done                            : out std_logic;
  cfg_err_aer_headerlog_set                      : out std_logic;
  cfg_err_cpl_rdy                                : out std_logic;
  cfg_interrupt_rdy                              : out std_logic;
  cfg_interrupt_mmenable                         : out std_logic_vector(2 downto 0);
  cfg_interrupt_msienable                        : out std_logic;
  cfg_interrupt_do                               : out std_logic_vector(7 downto 0);
  cfg_interrupt_msixenable                       : out std_logic;
  cfg_interrupt_msixfm                           : out std_logic;
  cfg_bus_number                                 : out std_logic_vector(7 downto 0);
  cfg_device_number                              : out std_logic_vector(4 downto 0);
  cfg_function_number                            : out std_logic_vector(2 downto 0);
  cfg_status                                     : out std_logic_vector(15 downto 0);
  cfg_command                                    : out std_logic_vector(15 downto 0);
  cfg_dstatus                                    : out std_logic_vector(15 downto 0);
  cfg_dcommand                                   : out std_logic_vector(15 downto 0);
  cfg_lstatus                                    : out std_logic_vector(15 downto 0);
  cfg_lcommand                                   : out std_logic_vector(15 downto 0);
  cfg_dcommand2                                  : out std_logic_vector(15 downto 0);
  cfg_received_func_lvl_rst                      : out std_logic;
  cfg_msg_received                               : out std_logic;
  cfg_msg_data                                   : out std_logic_vector(15 downto 0);
  cfg_msg_received_err_cor                       : out std_logic;
  cfg_msg_received_err_non_fatal                 : out std_logic;
  cfg_msg_received_err_fatal                     : out std_logic;
  cfg_msg_received_assert_int_a                  : out std_logic;
  cfg_msg_received_deassert_int_a                : out std_logic;
  cfg_msg_received_assert_int_b                  : out std_logic;
  cfg_msg_received_deassert_int_b                : out std_logic;
  cfg_msg_received_assert_int_c                  : out std_logic;
  cfg_msg_received_deassert_int_c                : out std_logic;
  cfg_msg_received_assert_int_d                  : out std_logic;
  cfg_msg_received_deassert_int_d                : out std_logic;
  cfg_msg_received_pm_pme                        : out std_logic;
  cfg_msg_received_pme_to_ack                    : out std_logic;
  cfg_msg_received_pme_to                        : out std_logic;
  cfg_msg_received_setslotpowerlimit             : out std_logic;
  cfg_msg_received_unlock                        : out std_logic;
  cfg_msg_received_pm_as_nak                     : out std_logic;
  cfg_to_turnoff                                 : out std_logic;
  cfg_pcie_link_state                            : out std_logic_vector(2 downto 0);
  cfg_pm_rcv_as_req_l1_n                         : out std_logic;
  cfg_pm_rcv_enter_l1_n                          : out std_logic;
  cfg_pm_rcv_enter_l23_n                         : out std_logic;
  cfg_pm_rcv_req_ack_n                           : out std_logic;
  cfg_pmcsr_powerstate                           : out std_logic_vector(1 downto 0);
  cfg_pmcsr_pme_en                               : out std_logic;
  cfg_pmcsr_pme_status                           : out std_logic;
  cfg_transaction                                : out std_logic;
  cfg_transaction_type                           : out std_logic;
  cfg_transaction_addr                           : out std_logic_vector(6 downto 0);
  cfg_command_io_enable                          : out std_logic;
  cfg_command_mem_enable                         : out std_logic;
  cfg_command_bus_master_enable                  : out std_logic;
  cfg_command_interrupt_disable                  : out std_logic;
  cfg_command_serr_en                            : out std_logic;
  cfg_bridge_serr_en                             : out std_logic;
  cfg_dev_status_corr_err_detected               : out std_logic;
  cfg_dev_status_non_fatal_err_detected          : out std_logic;
  cfg_dev_status_fatal_err_detected              : out std_logic;
  cfg_dev_status_ur_detected                     : out std_logic;
  cfg_dev_control_corr_err_reporting_en          : out std_logic;
  cfg_dev_control_non_fatal_reporting_en         : out std_logic;
  cfg_dev_control_fatal_err_reporting_en         : out std_logic;
  cfg_dev_control_ur_err_reporting_en            : out std_logic;
  cfg_dev_control_enable_ro                      : out std_logic;
  cfg_dev_control_max_payload                    : out std_logic_vector(2 downto 0);
  cfg_dev_control_ext_tag_en                     : out std_logic;
  cfg_dev_control_phantom_en                     : out std_logic;
  cfg_dev_control_aux_power_en                   : out std_logic;
  cfg_dev_control_no_snoop_en                    : out std_logic;
  cfg_dev_control_max_read_req                   : out std_logic_vector(2 downto 0);
  cfg_link_status_current_speed                  : out std_logic_vector(1 downto 0);
  cfg_link_status_negotiated_width               : out std_logic_vector(3 downto 0);
  cfg_link_status_link_training                  : out std_logic;
  cfg_link_status_dll_active                     : out std_logic;
  cfg_link_status_bandwidth_status               : out std_logic;
  cfg_link_status_auto_bandwidth_status          : out std_logic;
  cfg_link_control_aspm_control                  : out std_logic_vector(1 downto 0);
  cfg_link_control_rcb                           : out std_logic;
  cfg_link_control_link_disable                  : out std_logic;
  cfg_link_control_retrain_link                  : out std_logic;
  cfg_link_control_common_clock                  : out std_logic;
  cfg_link_control_extended_sync                 : out std_logic;
  cfg_link_control_clock_pm_en                   : out std_logic;
  cfg_link_control_hw_auto_width_dis             : out std_logic;
  cfg_link_control_bandwidth_int_en              : out std_logic;
  cfg_link_control_auto_bandwidth_int_en         : out std_logic;
  cfg_dev_control2_cpl_timeout_val               : out std_logic_vector(3 downto 0);
  cfg_dev_control2_cpl_timeout_dis               : out std_logic;
  cfg_dev_control2_ari_forward_en                : out std_logic;
  cfg_dev_control2_atomic_requester_en           : out std_logic;
  cfg_dev_control2_atomic_egress_block           : out std_logic;
  cfg_dev_control2_ido_req_en                    : out std_logic;
  cfg_dev_control2_ido_cpl_en                    : out std_logic;
  cfg_dev_control2_ltr_en                        : out std_logic;
  cfg_dev_control2_tlp_prefix_block              : out std_logic;
  cfg_slot_control_electromech_il_ctl_pulse      : out std_logic;
  cfg_root_control_syserr_corr_err_en            : out std_logic;
  cfg_root_control_syserr_non_fatal_err_en       : out std_logic;
  cfg_root_control_syserr_fatal_err_en           : out std_logic;
  cfg_root_control_pme_int_en                    : out std_logic;
  cfg_aer_ecrc_check_en                          : out std_logic;
  cfg_aer_ecrc_gen_en                            : out std_logic;
  cfg_aer_rooterr_corr_err_reporting_en          : out std_logic;
  cfg_aer_rooterr_non_fatal_err_reporting_en     : out std_logic;
  cfg_aer_rooterr_fatal_err_reporting_en         : out std_logic;
  cfg_aer_rooterr_corr_err_received              : out std_logic;
  cfg_aer_rooterr_non_fatal_err_received         : out std_logic;
  cfg_aer_rooterr_fatal_err_received             : out std_logic;
  cfg_vc_tcvc_map                                : out std_logic_vector(6 downto 0);
  dbg_vec_a                                      : out std_logic_vector(63 downto 0);
  dbg_vec_b                                      : out std_logic_vector(63 downto 0);
  dbg_vec_c                                      : out std_logic_vector(11 downto 0);
  dbg_sclr_a                                     : out std_logic;
  dbg_sclr_b                                     : out std_logic;
  dbg_sclr_c                                     : out std_logic;
  dbg_sclr_d                                     : out std_logic;
  dbg_sclr_e                                     : out std_logic;
  dbg_sclr_f                                     : out std_logic;
  dbg_sclr_g                                     : out std_logic;
  dbg_sclr_h                                     : out std_logic;
  dbg_sclr_i                                     : out std_logic;
  dbg_sclr_j                                     : out std_logic;
  dbg_sclr_k                                     : out std_logic;
  trn_rdllp_data                                 : out std_logic_vector(63 downto 0);
  trn_rdllp_src_rdy                              : out std_logic_vector(1 downto 0);
  pl_dbg_vec                                     : out std_logic_vector(11 downto 0);

  phy_rdy_n                                      : in std_logic;
  pipe_clk                                       : in std_logic;
  user_clk                                       : in std_logic;
  user_clk2                                      : in std_logic;
  pipe_rx0_polarity_gt                           : out std_logic;
  pipe_rx1_polarity_gt                           : out std_logic;
  pipe_rx2_polarity_gt                           : out std_logic;
  pipe_rx3_polarity_gt                           : out std_logic;
  pipe_rx4_polarity_gt                           : out std_logic;
  pipe_rx5_polarity_gt                           : out std_logic;
  pipe_rx6_polarity_gt                           : out std_logic;
  pipe_rx7_polarity_gt                           : out std_logic;
  pipe_tx_deemph_gt                              : out std_logic;
  pipe_tx_margin_gt                              : out std_logic_vector (2 downto 0);
  pipe_tx_rate_gt                                : out std_logic;
  pipe_tx_rcvr_det_gt                            : out std_logic;
  pipe_tx0_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx0_compliance_gt                         : out std_logic;
  pipe_tx0_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx0_elec_idle_gt                          : out std_logic;
  pipe_tx0_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx1_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx1_compliance_gt                         : out std_logic;
  pipe_tx1_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx1_elec_idle_gt                          : out std_logic;
  pipe_tx1_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx2_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx2_compliance_gt                         : out std_logic;
  pipe_tx2_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx2_elec_idle_gt                          : out std_logic;
  pipe_tx2_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx3_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx3_compliance_gt                         : out std_logic;
  pipe_tx3_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx3_elec_idle_gt                          : out std_logic;
  pipe_tx3_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx4_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx4_compliance_gt                         : out std_logic;
  pipe_tx4_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx4_elec_idle_gt                          : out std_logic;
  pipe_tx4_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx5_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx5_compliance_gt                         : out std_logic;
  pipe_tx5_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx5_elec_idle_gt                          : out std_logic;
  pipe_tx5_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx6_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx6_compliance_gt                         : out std_logic;
  pipe_tx6_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx6_elec_idle_gt                          : out std_logic;
  pipe_tx6_powerdown_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx7_char_is_k_gt                          : out std_logic_vector (1 downto 0);
  pipe_tx7_compliance_gt                         : out std_logic;
  pipe_tx7_data_gt                               : out std_logic_vector (15 downto 0);
  pipe_tx7_elec_idle_gt                          : out std_logic;
  pipe_tx7_powerdown_gt                          : out std_logic_vector (1 downto 0);

  pipe_rx0_chanisaligned_gt                      : in std_logic;
  pipe_rx0_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx0_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx0_elec_idle_gt                          : in std_logic;
  pipe_rx0_phy_status_gt                         : in std_logic;
  pipe_rx0_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx0_valid_gt                              : in std_logic;
  pipe_rx1_chanisaligned_gt                      : in std_logic;
  pipe_rx1_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx1_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx1_elec_idle_gt                          : in std_logic;
  pipe_rx1_phy_status_gt                         : in std_logic;
  pipe_rx1_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx1_valid_gt                              : in std_logic;
  pipe_rx2_chanisaligned_gt                      : in std_logic;
  pipe_rx2_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx2_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx2_elec_idle_gt                          : in std_logic;
  pipe_rx2_phy_status_gt                         : in std_logic;
  pipe_rx2_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx2_valid_gt                              : in std_logic;
  pipe_rx3_chanisaligned_gt                      : in std_logic;
  pipe_rx3_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx3_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx3_elec_idle_gt                          : in std_logic;
  pipe_rx3_phy_status_gt                         : in std_logic;
  pipe_rx3_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx3_valid_gt                              : in std_logic;
  pipe_rx4_chanisaligned_gt                      : in std_logic;
  pipe_rx4_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx4_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx4_elec_idle_gt                          : in std_logic;
  pipe_rx4_phy_status_gt                         : in std_logic;
  pipe_rx4_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx4_valid_gt                              : in std_logic;
  pipe_rx5_chanisaligned_gt                      : in std_logic;
  pipe_rx5_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx5_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx5_elec_idle_gt                          : in std_logic;
  pipe_rx5_phy_status_gt                         : in std_logic;
  pipe_rx5_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx5_valid_gt                              : in std_logic;
  pipe_rx6_chanisaligned_gt                      : in std_logic;
  pipe_rx6_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx6_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx6_elec_idle_gt                          : in std_logic;
  pipe_rx6_phy_status_gt                         : in std_logic;
  pipe_rx6_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx6_valid_gt                              : in std_logic;
  pipe_rx7_chanisaligned_gt                      : in std_logic;
  pipe_rx7_char_is_k_gt                          : in std_logic_vector (1 downto 0);
  pipe_rx7_data_gt                               : in std_logic_vector (15 downto 0);
  pipe_rx7_elec_idle_gt                          : in std_logic;
  pipe_rx7_phy_status_gt                         : in std_logic;
  pipe_rx7_status_gt                             : in std_logic_vector (2 downto 0);
  pipe_rx7_valid_gt                              : in std_logic
);
end cl_a7pcie_x4_pcie_top;

architecture pcie_7x of cl_a7pcie_x4_pcie_top is
   component cl_a7pcie_x4_pcie_7x is
      generic (
        C_DATA_WIDTH                                   : INTEGER range 32 to 128 := 64;
        C_REM_WIDTH                                    : INTEGER range 0 to 128  :=  1;
        -- PCIE_2_1 params
        AER_BASE_PTR                                   : bit_vector := X"140";
        AER_CAP_ECRC_CHECK_CAPABLE                     : string     := "FALSE";
        AER_CAP_ECRC_GEN_CAPABLE                       : string     := "FALSE";
        AER_CAP_ID                                     : bit_vector := X"0001";
        AER_CAP_MULTIHEADER                            : string     := "FALSE";
        AER_CAP_NEXTPTR                                : bit_vector := X"178";
        AER_CAP_ON                                     : string     := "FALSE";
        AER_CAP_OPTIONAL_ERR_SUPPORT                   : bit_vector := X"000000";
        AER_CAP_PERMIT_ROOTERR_UPDATE                  : string     := "TRUE";
        AER_CAP_VERSION                                : bit_vector := X"2";
        ALLOW_X8_GEN2                                  : string     := "FALSE";
        BAR0                                           : bit_vector := X"FFFFFF00";
        BAR1                                           : bit_vector := X"FFFF0000";
        BAR2                                           : bit_vector := X"FFFF000C";
        BAR3                                           : bit_vector := X"FFFFFFFF";
        BAR4                                           : bit_vector := X"00000000";
        BAR5                                           : bit_vector := X"00000000";
        CAPABILITIES_PTR                               : bit_vector := X"40";
        CARDBUS_CIS_POINTER                            : bit_vector := X"00000000";
        CFG_ECRC_ERR_CPLSTAT                           : integer    := 0;
        CLASS_CODE                                     : bit_vector := X"000000";
        CMD_INTX_IMPLEMENTED                           : string     := "TRUE";
        CPL_TIMEOUT_DISABLE_SUPPORTED                  : string     := "FALSE";
        CPL_TIMEOUT_RANGES_SUPPORTED                   : bit_vector := X"0";
        CRM_MODULE_RSTS                                : bit_vector := X"00";
        DEV_CAP2_ARI_FORWARDING_SUPPORTED              : string     := "FALSE";
        DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED        : string     := "FALSE";
        DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED        : string     := "FALSE";
        DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED            : string     := "FALSE";
        DEV_CAP2_CAS128_COMPLETER_SUPPORTED            : string     := "FALSE";
        DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED           : string     := "FALSE";
        DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED          : string     := "FALSE";
        DEV_CAP2_LTR_MECHANISM_SUPPORTED               : string     := "FALSE";
        DEV_CAP2_MAX_ENDEND_TLP_PREFIXES               : bit_vector := X"0";
        DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING            : string     := "FALSE";
        DEV_CAP2_TPH_COMPLETER_SUPPORTED               : bit_vector := X"0";
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE            : string     := "TRUE";
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE            : string     := "TRUE";
        DEV_CAP_ENDPOINT_L0S_LATENCY                   : integer    := 0;
        DEV_CAP_ENDPOINT_L1_LATENCY                    : integer    := 0;
        DEV_CAP_EXT_TAG_SUPPORTED                      : string     := "TRUE";
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE           : string     := "FALSE";
        DEV_CAP_MAX_PAYLOAD_SUPPORTED                  : integer    := 2;
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT              : integer    := 0;
        DEV_CAP_ROLE_BASED_ERROR                       : string     := "TRUE";
        DEV_CAP_RSVD_14_12                             : integer    := 0;
        DEV_CAP_RSVD_17_16                             : integer    := 0;
        DEV_CAP_RSVD_31_29                             : integer    := 0;
        DEV_CONTROL_AUX_POWER_SUPPORTED                : string     := "FALSE";
        DEV_CONTROL_EXT_TAG_DEFAULT                    : string     := "FALSE";
        DISABLE_ASPM_L1_TIMER                          : string     := "FALSE";
        DISABLE_BAR_FILTERING                          : string     := "FALSE";
        DISABLE_ERR_MSG                                : string     := "FALSE";
        DISABLE_ID_CHECK                               : string     := "FALSE";
        DISABLE_LANE_REVERSAL                          : string     := "FALSE";
        DISABLE_LOCKED_FILTER                          : string     := "FALSE";
        DISABLE_PPM_FILTER                             : string     := "FALSE";
        DISABLE_RX_POISONED_RESP                       : string     := "FALSE";
        DISABLE_RX_TC_FILTER                           : string     := "FALSE";
        DISABLE_SCRAMBLING                             : string     := "FALSE";
        DNSTREAM_LINK_NUM                              : bit_vector := X"00";
        DSN_BASE_PTR                                   : bit_vector := X"100";
        DSN_CAP_ID                                     : bit_vector := X"0003";
        DSN_CAP_NEXTPTR                                : bit_vector := X"10C";
        DSN_CAP_ON                                     : string     := "TRUE";
        DSN_CAP_VERSION                                : bit_vector := X"1";
        ENABLE_MSG_ROUTE                               : bit_vector := X"000";
        ENABLE_RX_TD_ECRC_TRIM                         : string     := "FALSE";
        ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED         : string     := "FALSE";
        ENTER_RVRY_EI_L0                               : string     := "TRUE";
        EXIT_LOOPBACK_ON_EI                            : string     := "TRUE";
        EXPANSION_ROM                                  : bit_vector := X"FFFFF001";
        EXT_CFG_CAP_PTR                                : bit_vector := X"3F";
        EXT_CFG_XP_CAP_PTR                             : bit_vector := X"3FF";
        HEADER_TYPE                                    : bit_vector := X"00";
        INFER_EI                                       : bit_vector := X"00";
        INTERRUPT_PIN                                  : bit_vector := X"01";
        INTERRUPT_STAT_AUTO                            : string     := "TRUE";
        IS_SWITCH                                      : string     := "FALSE";
        LAST_CONFIG_DWORD                              : bit_vector := X"3FF";
        LINK_CAP_ASPM_OPTIONALITY                      : string     := "TRUE";
        LINK_CAP_ASPM_SUPPORT                          : integer    := 1;
        LINK_CAP_CLOCK_POWER_MANAGEMENT                : string     := "FALSE";
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP         : string     := "FALSE";
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1          : integer    := 7;
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2          : integer    := 7;
        LINK_CAP_L0S_EXIT_LATENCY_GEN1                 : integer    := 7;
        LINK_CAP_L0S_EXIT_LATENCY_GEN2                 : integer    := 7;
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1           : integer    := 7;
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2           : integer    := 7;
        LINK_CAP_L1_EXIT_LATENCY_GEN1                  : integer    := 7;
        LINK_CAP_L1_EXIT_LATENCY_GEN2                  : integer    := 7;
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP       : string     := "FALSE";
        LINK_CAP_MAX_LINK_SPEED                        : bit_vector := X"1";
        LINK_CAP_MAX_LINK_SPEED_int                    : integer    := 1;
        LINK_CAP_MAX_LINK_WIDTH                        : bit_vector := X"08";
        LINK_CAP_MAX_LINK_WIDTH_int                    : integer    := 8;
        LINK_CAP_RSVD_23                               : integer    := 0;
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE           : string     := "FALSE";
        LINK_CONTROL_RCB                               : integer    := 0;
        LINK_CTRL2_DEEMPHASIS                          : string     := "FALSE";
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE         : string     := "FALSE";
        LINK_CTRL2_TARGET_LINK_SPEED                   : bit_vector := X"2";
        LINK_STATUS_SLOT_CLOCK_CONFIG                  : string     := "TRUE";
        LL_ACK_TIMEOUT                                 : bit_vector := X"0000";
        LL_ACK_TIMEOUT_EN                              : string     := "FALSE";
        LL_ACK_TIMEOUT_FUNC                            : integer    := 0;
        LL_REPLAY_TIMEOUT                              : bit_vector := X"0000";
        LL_REPLAY_TIMEOUT_EN                           : string     := "FALSE";
        LL_REPLAY_TIMEOUT_FUNC                         : integer    := 0;
        LTSSM_MAX_LINK_WIDTH                           : bit_vector := X"01";
        MPS_FORCE                                      : string     := "FALSE";
        MSIX_BASE_PTR                                  : bit_vector := X"9C";
        MSIX_CAP_ID                                    : bit_vector := X"11";
        MSIX_CAP_NEXTPTR                               : bit_vector := X"00";
        MSIX_CAP_ON                                    : string     := "FALSE";
        MSIX_CAP_PBA_BIR                               : integer    := 0;
        MSIX_CAP_PBA_OFFSET                            : bit_vector := X"00000050";
        MSIX_CAP_TABLE_BIR                             : integer    := 0;
        MSIX_CAP_TABLE_OFFSET                          : bit_vector := X"00000040";
        MSIX_CAP_TABLE_SIZE                            : bit_vector := X"000";
        MSI_BASE_PTR                                   : bit_vector := X"48";
        MSI_CAP_64_BIT_ADDR_CAPABLE                    : string     := "TRUE";
        MSI_CAP_ID                                     : bit_vector := X"05";
        MSI_CAP_MULTIMSGCAP                            : integer    := 0;
        MSI_CAP_MULTIMSG_EXTENSION                     : integer    := 0;
        MSI_CAP_NEXTPTR                                : bit_vector := X"60";
        MSI_CAP_ON                                     : string     := "FALSE";
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE             : string     := "TRUE";
        N_FTS_COMCLK_GEN1                              : integer    := 255;
        N_FTS_COMCLK_GEN2                              : integer    := 255;
        N_FTS_GEN1                                     : integer    := 255;
        N_FTS_GEN2                                     : integer    := 255;
        PCIE_BASE_PTR                                  : bit_vector := X"60";
        PCIE_CAP_CAPABILITY_ID                         : bit_vector := X"10";
        PCIE_CAP_CAPABILITY_VERSION                    : bit_vector := X"2";
        PCIE_CAP_DEVICE_PORT_TYPE                      : bit_vector := X"0";
        PCIE_CAP_NEXTPTR                               : bit_vector := X"9C";
        PCIE_CAP_ON                                    : string     := "TRUE";
        PCIE_CAP_RSVD_15_14                            : integer    := 0;
        PCIE_CAP_SLOT_IMPLEMENTED                      : string     := "FALSE";
        PCIE_REVISION                                  : integer    := 2;
        PL_AUTO_CONFIG                                 : integer    := 0;
        PL_FAST_TRAIN                                  : string     := "FALSE";
        PM_ASPML0S_TIMEOUT                             : bit_vector := X"0000";
        PM_ASPML0S_TIMEOUT_EN                          : string     := "FALSE";
        PM_ASPML0S_TIMEOUT_FUNC                        : integer    := 0;
        PM_ASPM_FASTEXIT                               : string     := "FALSE";
        PM_BASE_PTR                                    : bit_vector := X"40";
        PM_CAP_AUXCURRENT                              : integer    := 0;
        PM_CAP_D1SUPPORT                               : string     := "TRUE";
        PM_CAP_D2SUPPORT                               : string     := "TRUE";
        PM_CAP_DSI                                     : string     := "FALSE";
        PM_CAP_ID                                      : bit_vector := X"01";
        PM_CAP_NEXTPTR                                 : bit_vector := X"48";
        PM_CAP_ON                                      : string     := "TRUE";
        PM_CAP_PMESUPPORT                              : bit_vector := X"0F";
        PM_CAP_PME_CLOCK                               : string     := "FALSE";
        PM_CAP_RSVD_04                                 : integer    := 0;
        PM_CAP_VERSION                                 : integer    := 3;
        PM_CSR_B2B3                                    : string     := "FALSE";
        PM_CSR_BPCCEN                                  : string     := "FALSE";
        PM_CSR_NOSOFTRST                               : string     := "TRUE";
        PM_DATA0                                       : bit_vector := X"01";
        PM_DATA1                                       : bit_vector := X"01";
        PM_DATA2                                       : bit_vector := X"01";
        PM_DATA3                                       : bit_vector := X"01";
        PM_DATA4                                       : bit_vector := X"01";
        PM_DATA5                                       : bit_vector := X"01";
        PM_DATA6                                       : bit_vector := X"01";
        PM_DATA7                                       : bit_vector := X"01";
        PM_DATA_SCALE0                                 : bit_vector := X"1";
        PM_DATA_SCALE1                                 : bit_vector := X"1";
        PM_DATA_SCALE2                                 : bit_vector := X"1";
        PM_DATA_SCALE3                                 : bit_vector := X"1";
        PM_DATA_SCALE4                                 : bit_vector := X"1";
        PM_DATA_SCALE5                                 : bit_vector := X"1";
        PM_DATA_SCALE6                                 : bit_vector := X"1";
        PM_DATA_SCALE7                                 : bit_vector := X"1";
        PM_MF                                          : string     := "FALSE";
        RBAR_BASE_PTR                                  : bit_vector := X"178";
        RBAR_CAP_CONTROL_ENCODEDBAR0                   : bit_vector := X"00";
        RBAR_CAP_CONTROL_ENCODEDBAR1                   : bit_vector := X"00";
        RBAR_CAP_CONTROL_ENCODEDBAR2                   : bit_vector := X"00";
        RBAR_CAP_CONTROL_ENCODEDBAR3                   : bit_vector := X"00";
        RBAR_CAP_CONTROL_ENCODEDBAR4                   : bit_vector := X"00";
        RBAR_CAP_CONTROL_ENCODEDBAR5                   : bit_vector := X"00";
        RBAR_CAP_ID                                    : bit_vector := X"0015";
        RBAR_CAP_INDEX0                                : bit_vector := X"0";
        RBAR_CAP_INDEX1                                : bit_vector := X"0";
        RBAR_CAP_INDEX2                                : bit_vector := X"0";
        RBAR_CAP_INDEX3                                : bit_vector := X"0";
        RBAR_CAP_INDEX4                                : bit_vector := X"0";
        RBAR_CAP_INDEX5                                : bit_vector := X"0";
        RBAR_CAP_NEXTPTR                               : bit_vector := X"000";
        RBAR_CAP_ON                                    : string     := "FALSE";
        RBAR_CAP_SUP0                                  : bit_vector := X"00000000";
        RBAR_CAP_SUP1                                  : bit_vector := X"00000000";
        RBAR_CAP_SUP2                                  : bit_vector := X"00000000";
        RBAR_CAP_SUP3                                  : bit_vector := X"00000000";
        RBAR_CAP_SUP4                                  : bit_vector := X"00000000";
        RBAR_CAP_SUP5                                  : bit_vector := X"00000000";
        RBAR_CAP_VERSION                               : bit_vector := X"1";
        RBAR_NUM                                       : bit_vector := X"1";
        RECRC_CHK                                      : integer    := 0;
        RECRC_CHK_TRIM                                 : string     := "FALSE";
        ROOT_CAP_CRS_SW_VISIBILITY                     : string     := "FALSE";
        RP_AUTO_SPD                                    : bit_vector := X"1";
        RP_AUTO_SPD_LOOPCNT                            : bit_vector := X"1F";
        SELECT_DLL_IF                                  : string     := "FALSE";
        SIM_VERSION                                    : string     := "1.0";
        SLOT_CAP_ATT_BUTTON_PRESENT                    : string     := "FALSE";
        SLOT_CAP_ATT_INDICATOR_PRESENT                 : string     := "FALSE";
        SLOT_CAP_ELEC_INTERLOCK_PRESENT                : string     := "FALSE";
        SLOT_CAP_HOTPLUG_CAPABLE                       : string     := "FALSE";
        SLOT_CAP_HOTPLUG_SURPRISE                      : string     := "FALSE";
        SLOT_CAP_MRL_SENSOR_PRESENT                    : string     := "FALSE";
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT              : string     := "FALSE";
        SLOT_CAP_PHYSICAL_SLOT_NUM                     : bit_vector := X"0000";
        SLOT_CAP_POWER_CONTROLLER_PRESENT              : string     := "FALSE";
        SLOT_CAP_POWER_INDICATOR_PRESENT               : string     := "FALSE";
        SLOT_CAP_SLOT_POWER_LIMIT_SCALE                : integer    := 0;
        SLOT_CAP_SLOT_POWER_LIMIT_VALUE                : bit_vector := X"00";
        SPARE_BIT0                                     : integer    := 0;
        SPARE_BIT1                                     : integer    := 0;
        SPARE_BIT2                                     : integer    := 0;
        SPARE_BIT3                                     : integer    := 0;
        SPARE_BIT4                                     : integer    := 0;
        SPARE_BIT5                                     : integer    := 0;
        SPARE_BIT6                                     : integer    := 0;
        SPARE_BIT7                                     : integer    := 0;
        SPARE_BIT8                                     : integer    := 0;
        SPARE_BYTE0                                    : bit_vector := X"00";
        SPARE_BYTE1                                    : bit_vector := X"00";
        SPARE_BYTE2                                    : bit_vector := X"00";
        SPARE_BYTE3                                    : bit_vector := X"00";
        SPARE_WORD0                                    : bit_vector := X"00000000";
        SPARE_WORD1                                    : bit_vector := X"00000000";
        SPARE_WORD2                                    : bit_vector := X"00000000";
        SPARE_WORD3                                    : bit_vector := X"00000000";
        SSL_MESSAGE_AUTO                               : string     := "FALSE";
        TECRC_EP_INV                                   : string     := "FALSE";
        TL_RBYPASS                                     : string     := "FALSE";
        TL_RX_RAM_RADDR_LATENCY                        : integer    := 0;
        TL_RX_RAM_RDATA_LATENCY                        : integer    := 2;
        TL_RX_RAM_WRITE_LATENCY                        : integer    := 0;
        TL_TFC_DISABLE                                 : string     := "FALSE";
        TL_TX_CHECKS_DISABLE                           : string     := "FALSE";
        TL_TX_RAM_RADDR_LATENCY                        : integer    := 0;
        TL_TX_RAM_RDATA_LATENCY                        : integer    := 2;
        TL_TX_RAM_WRITE_LATENCY                        : integer    := 0;
        TRN_DW                                         : string     := "FALSE";
        TRN_NP_FC                                      : string     := "FALSE";
        UPCONFIG_CAPABLE                               : string     := "TRUE";
        UPSTREAM_FACING                                : string     := "TRUE";
        UR_ATOMIC                                      : string     := "TRUE";
        UR_CFG1                                        : string     := "TRUE";
        UR_INV_REQ                                     : string     := "TRUE";
        UR_PRS_RESPONSE                                : string     := "TRUE";
        USER_CLK2_DIV2                                 : string     := "FALSE";
        USER_CLK_FREQ                                  : integer    := 3;
        USE_RID_PINS                                   : string     := "FALSE";
        VC0_CPL_INFINITE                               : string     := "TRUE";
        VC0_RX_RAM_LIMIT                               : bit_vector := X"03FF";
        VC0_TOTAL_CREDITS_CD                           : integer    := 127;
        VC0_TOTAL_CREDITS_CH                           : integer    := 31;
        VC0_TOTAL_CREDITS_NPD                          : integer    := 24;
        VC0_TOTAL_CREDITS_NPH                          : integer    := 12;
        VC0_TOTAL_CREDITS_PD                           : integer    := 288;
        VC0_TOTAL_CREDITS_PH                           : integer    := 32;
        VC0_TX_LASTPACKET                              : integer    := 31;
        VC_BASE_PTR                                    : bit_vector := X"10C";
        VC_CAP_ID                                      : bit_vector := X"0002";
        VC_CAP_NEXTPTR                                 : bit_vector := X"000";
        VC_CAP_ON                                      : string     := "FALSE";
        VC_CAP_REJECT_SNOOP_TRANSACTIONS               : string     := "FALSE";
        VC_CAP_VERSION                                 : bit_vector := X"1";
        VSEC_BASE_PTR                                  : bit_vector := X"128";
        VSEC_CAP_HDR_ID                                : bit_vector := X"1234";
        VSEC_CAP_HDR_LENGTH                            : bit_vector := X"018";
        VSEC_CAP_HDR_REVISION                          : bit_vector := X"1";
        VSEC_CAP_ID                                    : bit_vector := X"000B";
        VSEC_CAP_IS_LINK_VISIBLE                       : string     := "TRUE";
        VSEC_CAP_NEXTPTR                               : bit_vector := X"140";
        VSEC_CAP_ON                                    : string     := "FALSE";
        VSEC_CAP_VERSION                               : bit_vector := X"1"
      );
      port (
        trn_td                                         : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
        trn_trem                                       : in std_logic_vector(C_REM_WIDTH-1 downto 0);
        trn_tsof                                       : in std_logic;
        trn_teof                                       : in std_logic;
        trn_tsrc_rdy                                   : in std_logic;
        trn_tsrc_dsc                                   : in std_logic;
        trn_terrfwd                                    : in std_logic;
        trn_tecrc_gen                                  : in std_logic;
        trn_tstr                                       : in std_logic;
        trn_tcfg_gnt                                   : in std_logic;
        trn_rdst_rdy                                   : in std_logic;
        trn_rnp_req                                    : in std_logic;
        trn_rfcp_ret                                   : in std_logic;
        trn_rnp_ok                                     : in std_logic;
        trn_fc_sel                                     : in std_logic_vector( 2 downto 0);
        trn_tdllp_data                                 : in std_logic_vector(31 downto 0);
        trn_tdllp_src_rdy                              : in std_logic;
        ll2_tlp_rcv                                    : in std_logic;
        ll2_send_enter_l1                              : in std_logic;
        ll2_send_enter_l23                             : in std_logic;
        ll2_send_as_req_l1                             : in std_logic;
        ll2_send_pm_ack                                : in std_logic;
        pl2_directed_lstate                            : in std_logic_vector(4 downto 0);
        ll2_suspend_now                                : in std_logic;
        tl2_ppm_suspend_req                            : in std_logic;
        tl2_aspm_suspend_credit_check                  : in std_logic;
        pl_directed_link_change                        : in std_logic_vector( 1 downto 0);
        pl_directed_link_width                         : in std_logic_vector( 1 downto 0);
        pl_directed_link_speed                         : in std_logic;
        pl_directed_link_auton                         : in std_logic;
        pl_upstream_prefer_deemph                      : in std_logic;
        pl_downstream_deemph_source                    : in std_logic;
        pl_directed_ltssm_new_vld                      : in std_logic;
        pl_directed_ltssm_new                          : in std_logic_vector( 5 downto 0);
        pl_directed_ltssm_stall                        : in std_logic;
        pipe_rx0_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx1_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx2_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx3_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx4_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx5_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx6_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx7_char_is_k                             : in std_logic_vector( 1 downto 0);
        pipe_rx0_valid                                 : in std_logic;
        pipe_rx1_valid                                 : in std_logic;
        pipe_rx2_valid                                 : in std_logic;
        pipe_rx3_valid                                 : in std_logic;
        pipe_rx4_valid                                 : in std_logic;
        pipe_rx5_valid                                 : in std_logic;
        pipe_rx6_valid                                 : in std_logic;
        pipe_rx7_valid                                 : in std_logic;
        pipe_rx0_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx1_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx2_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx3_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx4_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx5_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx6_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx7_data                                  : in std_logic_vector(15 downto 0);
        pipe_rx0_chanisaligned                         : in std_logic;
        pipe_rx1_chanisaligned                         : in std_logic;
        pipe_rx2_chanisaligned                         : in std_logic;
        pipe_rx3_chanisaligned                         : in std_logic;
        pipe_rx4_chanisaligned                         : in std_logic;
        pipe_rx5_chanisaligned                         : in std_logic;
        pipe_rx6_chanisaligned                         : in std_logic;
        pipe_rx7_chanisaligned                         : in std_logic;
        pipe_rx0_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx1_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx2_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx3_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx4_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx5_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx6_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx7_status                                : in std_logic_vector( 2 downto 0);
        pipe_rx0_phy_status                            : in std_logic;
        pipe_rx1_phy_status                            : in std_logic;
        pipe_rx2_phy_status                            : in std_logic;
        pipe_rx3_phy_status                            : in std_logic;
        pipe_rx4_phy_status                            : in std_logic;
        pipe_rx5_phy_status                            : in std_logic;
        pipe_rx6_phy_status                            : in std_logic;
        pipe_rx7_phy_status                            : in std_logic;
        pipe_rx0_elec_idle                             : in std_logic;
        pipe_rx1_elec_idle                             : in std_logic;
        pipe_rx2_elec_idle                             : in std_logic;
        pipe_rx3_elec_idle                             : in std_logic;
        pipe_rx4_elec_idle                             : in std_logic;
        pipe_rx5_elec_idle                             : in std_logic;
        pipe_rx6_elec_idle                             : in std_logic;
        pipe_rx7_elec_idle                             : in std_logic;
        pipe_clk                                       : in std_logic;
        user_clk                                       : in std_logic;
        user_clk2                                      : in std_logic;
        user_clk_prebuf                                : in std_logic;
        user_clk_prebuf_en                             : in std_logic;
        scanmode_n                                     : in std_logic;
        scanenable_n                                   : in std_logic;
        edt_clk                                        : in std_logic;
        edt_bypass                                     : in std_logic;
        edt_update                                     : in std_logic;
        edt_configuration                              : in std_logic;
        edt_single_bypass_chain                        : in std_logic;
        edt_channels_in1                               : in std_logic;
        edt_channels_in2                               : in std_logic;
        edt_channels_in3                               : in std_logic;
        edt_channels_in4                               : in std_logic;
        edt_channels_in5                               : in std_logic;
        edt_channels_in6                               : in std_logic;
        edt_channels_in7                               : in std_logic;
        edt_channels_in8                               : in std_logic;
        pmv_enable_n                                   : in std_logic;
        pmv_select                                     : in std_logic_vector( 2 downto 0);
        pmv_divide                                     : in std_logic_vector( 1 downto 0);
        sys_rst_n                                      : in std_logic;
        cm_rst_n                                       : in std_logic;
        cm_sticky_rst_n                                : in std_logic;
        func_lvl_rst_n                                 : in std_logic;
        tl_rst_n                                       : in std_logic;
        dl_rst_n                                       : in std_logic;
        pl_rst_n                                       : in std_logic;
        pl_transmit_hot_rst                            : in std_logic;
        cfg_reset                                      : in std_logic;
        gwe                                            : in std_logic;
        grestore                                       : in std_logic;
        ghigh                                          : in std_logic;
        cfg_mgmt_di                                    : in std_logic_vector(31 downto 0);
        cfg_mgmt_byte_en_n                             : in std_logic_vector( 3 downto 0);
        cfg_mgmt_dwaddr                                : in std_logic_vector( 9 downto 0);
        cfg_mgmt_wr_rw1c_as_rw_n                       : in std_logic;
        cfg_mgmt_wr_readonly_n                         : in std_logic;
        cfg_mgmt_wr_en_n                               : in std_logic;
        cfg_mgmt_rd_en_n                               : in std_logic;
        cfg_err_malformed_n                            : in std_logic;
        cfg_err_cor_n                                  : in std_logic;
        cfg_err_ur_n                                   : in std_logic;
        cfg_err_ecrc_n                                 : in std_logic;
        cfg_err_cpl_timeout_n                          : in std_logic;
        cfg_err_cpl_abort_n                            : in std_logic;
        cfg_err_cpl_unexpect_n                         : in std_logic;
        cfg_err_poisoned_n                             : in std_logic;
        cfg_err_acs_n                                  : in std_logic;
        cfg_err_atomic_egress_blocked_n                : in std_logic;
        cfg_err_mc_blocked_n                           : in std_logic;
        cfg_err_internal_uncor_n                       : in std_logic;
        cfg_err_internal_cor_n                         : in std_logic;
        cfg_err_posted_n                               : in std_logic;
        cfg_err_locked_n                               : in std_logic;
        cfg_err_norecovery_n                           : in std_logic;
        cfg_err_aer_headerlog                          : in std_logic_vector(127 downto 0);
        cfg_err_tlp_cpl_header                         : in std_logic_vector(47 downto 0);
        cfg_interrupt_n                                : in std_logic;
        cfg_interrupt_di                               : in std_logic_vector(7 downto 0);
        cfg_interrupt_assert_n                         : in std_logic;
        cfg_interrupt_stat_n                           : in std_logic;
        cfg_ds_bus_number                              : in std_logic_vector(7 downto 0);
        cfg_ds_device_number                           : in std_logic_vector(4 downto 0);
        cfg_ds_function_number                         : in std_logic_vector( 2 downto 0);
        cfg_port_number                                : in std_logic_vector(7 downto 0);
        cfg_pm_halt_aspm_l0s_n                         : in std_logic;
        cfg_pm_halt_aspm_l1_n                          : in std_logic;
        cfg_pm_force_state_en_n                        : in std_logic;
        cfg_pm_force_state                             : in std_logic_vector(1 downto 0);
        cfg_pm_wake_n                                  : in std_logic;
        cfg_pm_turnoff_ok_n                            : in std_logic;
        cfg_pm_send_pme_to_n                           : in std_logic;
        cfg_pciecap_interrupt_msgnum                   : in std_logic_vector(4 downto 0);
        cfg_trn_pending_n                              : in std_logic;
        cfg_force_mps                                  : in std_logic_vector( 2 downto 0);
        cfg_force_common_clock_off                     : in std_logic;
        cfg_force_extended_sync_on                     : in std_logic;
        cfg_dsn                                        : in std_logic_vector(63 downto 0);
        cfg_aer_interrupt_msgnum                       : in std_logic_vector(4 downto 0);
        cfg_dev_id                                     : in std_logic_vector(15 downto 0);
        cfg_vend_id                                    : in std_logic_vector(15 downto 0);
        cfg_rev_id                                     : in std_logic_vector(7 downto 0);
        cfg_subsys_id                                  : in std_logic_vector(15 downto 0);
        cfg_subsys_vend_id                             : in std_logic_vector(15 downto 0);
        drp_clk                                        : in std_logic;
        drp_en                                         : in std_logic;
        drp_we                                         : in std_logic;
        drp_addr                                       : in std_logic_vector(8 downto 0);
        drp_di                                         : in std_logic_vector(15 downto 0);
        drp_rdy                                        : out std_logic;
        drp_do                                         : out std_logic_vector(15 downto 0);
        dbg_mode                                       : in std_logic_vector(1 downto 0);
        dbg_sub_mode                                   : in std_logic;
        pl_dbg_mode                                    : in std_logic_vector( 2 downto 0);

        trn_clk                                        : out std_logic;

        trn_tdst_rdy                                   : out std_logic;
        trn_terr_drop                                  : out std_logic;
        trn_tbuf_av                                    : out std_logic_vector( 5 downto 0);
        trn_tcfg_req                                   : out std_logic;

        trn_rd                                         : out std_logic_vector(C_DATA_WIDTH- 1 downto 0);
        trn_rrem                                       : out std_logic_vector(C_REM_WIDTH- 1 downto 0);

        trn_rsof                                       : out std_logic;
        trn_reof                                       : out std_logic;
        trn_rsrc_rdy                                   : out std_logic;
        trn_rsrc_dsc                                   : out std_logic;
        trn_recrc_err                                  : out std_logic;
        trn_rerrfwd                                    : out std_logic;
        trn_rbar_hit                                   : out std_logic_vector( 7 downto 0);
        trn_lnk_up                                     : out std_logic;
        trn_fc_ph                                      : out std_logic_vector( 7 downto 0);
        trn_fc_pd                                      : out std_logic_vector(11 downto 0);
        trn_fc_nph                                     : out std_logic_vector( 7 downto 0);
        trn_fc_npd                                     : out std_logic_vector(11 downto 0);
        trn_fc_cplh                                    : out std_logic_vector( 7 downto 0);
        trn_fc_cpld                                    : out std_logic_vector(11 downto 0);
        trn_tdllp_dst_rdy                              : out std_logic;
        trn_rdllp_data                                 : out std_logic_vector(63 downto 0);
        trn_rdllp_src_rdy                              : out std_logic_vector( 1 downto 0);
        ll2_tfc_init1_seq                              : out std_logic;
        ll2_tfc_init2_seq                              : out std_logic;
        pl2_suspend_ok                                 : out std_logic;
        pl2_recovery                                   : out std_logic;
        pl2_rx_elec_idle                               : out std_logic;
        pl2_rx_pm_state                                : out std_logic_vector( 1 downto 0);
        pl2_l0_req                                     : out std_logic;
        ll2_suspend_ok                                 : out std_logic;
        ll2_tx_idle                                    : out std_logic;
        ll2_link_status                                : out std_logic_vector( 4 downto 0);
        tl2_ppm_suspend_ok                             : out std_logic;
        tl2_aspm_suspend_req                           : out std_logic;
        tl2_aspm_suspend_credit_check_ok               : out std_logic;
        pl2_link_up                                    : out std_logic;
        pl2_receiver_err                               : out std_logic;
        ll2_receiver_err                               : out std_logic;
        ll2_protocol_err                               : out std_logic;
        ll2_bad_tlp_err                                : out std_logic;
        ll2_bad_dllp_err                               : out std_logic;
        ll2_replay_ro_err                              : out std_logic;
        ll2_replay_to_err                              : out std_logic;
        tl2_err_hdr                                    : out std_logic_vector(63 downto 0);
        tl2_err_malformed                              : out std_logic;
        tl2_err_rxoverflow                             : out std_logic;
        tl2_err_fcpe                                   : out std_logic;
        pl_sel_lnk_rate                                : out std_logic;
        pl_sel_lnk_width                               : out std_logic_vector( 1 downto 0);
        pl_ltssm_state                                 : out std_logic_vector( 5 downto 0);
        pl_lane_reversal_mode                          : out std_logic_vector( 1 downto 0);
        pl_phy_lnk_up_n                                : out std_logic;
        pl_tx_pm_state                                 : out std_logic_vector( 2 downto 0);
        pl_rx_pm_state                                 : out std_logic_vector( 1 downto 0);
        pl_link_upcfg_cap                              : out std_logic;
        pl_link_gen2_cap                               : out std_logic;
        pl_link_partner_gen2_supported                 : out std_logic;
        pl_initial_link_width                          : out std_logic_vector( 2 downto 0);
        pl_directed_change_done                        : out std_logic;
        pipe_tx_rcvr_det                               : out std_logic;
        pipe_tx_reset                                  : out std_logic;
        pipe_tx_rate                                   : out std_logic;
        pipe_tx_deemph                                 : out std_logic;
        pipe_tx_margin                                 : out std_logic_vector( 2 downto 0);
        pipe_rx0_polarity                              : out std_logic;
        pipe_rx1_polarity                              : out std_logic;
        pipe_rx2_polarity                              : out std_logic;
        pipe_rx3_polarity                              : out std_logic;
        pipe_rx4_polarity                              : out std_logic;
        pipe_rx5_polarity                              : out std_logic;
        pipe_rx6_polarity                              : out std_logic;
        pipe_rx7_polarity                              : out std_logic;
        pipe_tx0_compliance                            : out std_logic;
        pipe_tx1_compliance                            : out std_logic;
        pipe_tx2_compliance                            : out std_logic;
        pipe_tx3_compliance                            : out std_logic;
        pipe_tx4_compliance                            : out std_logic;
        pipe_tx5_compliance                            : out std_logic;
        pipe_tx6_compliance                            : out std_logic;
        pipe_tx7_compliance                            : out std_logic;
        pipe_tx0_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx1_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx2_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx3_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx4_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx5_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx6_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx7_char_is_k                             : out std_logic_vector( 1 downto 0);
        pipe_tx0_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx1_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx2_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx3_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx4_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx5_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx6_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx7_data                                  : out std_logic_vector(15 downto 0);
        pipe_tx0_elec_idle                             : out std_logic;
        pipe_tx1_elec_idle                             : out std_logic;
        pipe_tx2_elec_idle                             : out std_logic;
        pipe_tx3_elec_idle                             : out std_logic;
        pipe_tx4_elec_idle                             : out std_logic;
        pipe_tx5_elec_idle                             : out std_logic;
        pipe_tx6_elec_idle                             : out std_logic;
        pipe_tx7_elec_idle                             : out std_logic;
        pipe_tx0_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx1_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx2_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx3_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx4_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx5_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx6_powerdown                             : out std_logic_vector( 1 downto 0);
        pipe_tx7_powerdown                             : out std_logic_vector( 1 downto 0);
        pmv_out                                        : out std_logic;
        user_rst_n                                     : out std_logic;
        pl_received_hot_rst                            : out std_logic;
        received_func_lvl_rst_n                        : out std_logic;
        lnk_clk_en                                     : out std_logic;
        cfg_mgmt_do                                    : out std_logic_vector(31 downto 0);
        cfg_mgmt_rd_wr_done_n                          : out std_logic;
        cfg_err_aer_headerlog_set_n                    : out std_logic;
        cfg_err_cpl_rdy_n                              : out std_logic;
        cfg_interrupt_rdy_n                            : out std_logic;
        cfg_interrupt_mmenable                         : out std_logic_vector( 2 downto 0);
        cfg_interrupt_msienable                        : out std_logic;
        cfg_interrupt_do                               : out std_logic_vector( 7 downto 0);
        cfg_interrupt_msixenable                       : out std_logic;
        cfg_interrupt_msixfm                           : out std_logic;
        cfg_msg_received                               : out std_logic;
        cfg_msg_data                                   : out std_logic_vector(15 downto 0);
        cfg_msg_received_err_cor                       : out std_logic;
        cfg_msg_received_err_non_fatal                 : out std_logic;
        cfg_msg_received_err_fatal                     : out std_logic;
        cfg_msg_received_assert_int_a                  : out std_logic;
        cfg_msg_received_deassert_int_a                : out std_logic;
        cfg_msg_received_assert_int_b                  : out std_logic;
        cfg_msg_received_deassert_int_b                : out std_logic;
        cfg_msg_received_assert_int_c                  : out std_logic;
        cfg_msg_received_deassert_int_c                : out std_logic;
        cfg_msg_received_assert_int_d                  : out std_logic;
        cfg_msg_received_deassert_int_d                : out std_logic;
        cfg_msg_received_pm_pme                        : out std_logic;
        cfg_msg_received_pme_to_ack                    : out std_logic;
        cfg_msg_received_pme_to                        : out std_logic;
        cfg_msg_received_setslotpowerlimit             : out std_logic;
        cfg_msg_received_unlock                        : out std_logic;
        cfg_msg_received_pm_as_nak                     : out std_logic;
        cfg_pcie_link_state                            : out std_logic_vector( 2 downto 0);
        cfg_pm_rcv_as_req_l1_n                         : out std_logic;
        cfg_pm_rcv_enter_l1_n                          : out std_logic;
        cfg_pm_rcv_enter_l23_n                         : out std_logic;
        cfg_pm_rcv_req_ack_n                           : out std_logic;
        cfg_pmcsr_powerstate                           : out std_logic_vector( 1 downto 0);
        cfg_pmcsr_pme_en                               : out std_logic;
        cfg_pmcsr_pme_status                           : out std_logic;
        cfg_transaction                                : out std_logic;
        cfg_transaction_type                           : out std_logic;
        cfg_transaction_addr                           : out std_logic_vector( 6 downto 0);
        cfg_command_io_enable                          : out std_logic;
        cfg_command_mem_enable                         : out std_logic;
        cfg_command_bus_master_enable                  : out std_logic;
        cfg_command_interrupt_disable                  : out std_logic;
        cfg_command_serr_en                            : out std_logic;
        cfg_bridge_serr_en                             : out std_logic;
        cfg_dev_status_corr_err_detected               : out std_logic;
        cfg_dev_status_non_fatal_err_detected          : out std_logic;
        cfg_dev_status_fatal_err_detected              : out std_logic;
        cfg_dev_status_ur_detected                     : out std_logic;
        cfg_dev_control_corr_err_reporting_en          : out std_logic;
        cfg_dev_control_non_fatal_reporting_en         : out std_logic;
        cfg_dev_control_fatal_err_reporting_en         : out std_logic;
        cfg_dev_control_ur_err_reporting_en            : out std_logic;
        cfg_dev_control_enable_ro                      : out std_logic;
        cfg_dev_control_max_payload                    : out std_logic_vector( 2 downto 0);
        cfg_dev_control_ext_tag_en                     : out std_logic;
        cfg_dev_control_phantom_en                     : out std_logic;
        cfg_dev_control_aux_power_en                   : out std_logic;
        cfg_dev_control_no_snoop_en                    : out std_logic;
        cfg_dev_control_max_read_req                   : out std_logic_vector( 2 downto 0);
        cfg_link_status_current_speed                  : out std_logic_vector( 1 downto 0);
        cfg_link_status_negotiated_width               : out std_logic_vector( 3 downto 0);
        cfg_link_status_link_training                  : out std_logic;
        cfg_link_status_dll_active                     : out std_logic;
        cfg_link_status_bandwidth_status               : out std_logic;
        cfg_link_status_auto_bandwidth_status          : out std_logic;
        cfg_link_control_aspm_control                  : out std_logic_vector( 1 downto 0);
        cfg_link_control_rcb                           : out std_logic;
        cfg_link_control_link_disable                  : out std_logic;
        cfg_link_control_retrain_link                  : out std_logic;
        cfg_link_control_common_clock                  : out std_logic;
        cfg_link_control_extended_sync                 : out std_logic;
        cfg_link_control_clock_pm_en                   : out std_logic;
        cfg_link_control_hw_auto_width_dis             : out std_logic;
        cfg_link_control_bandwidth_int_en              : out std_logic;
        cfg_link_control_auto_bandwidth_int_en         : out std_logic;
        cfg_dev_control2_cpl_timeout_val               : out std_logic_vector( 3 downto 0);
        cfg_dev_control2_cpl_timeout_dis               : out std_logic;
        cfg_dev_control2_ari_forward_en                : out std_logic;
        cfg_dev_control2_atomic_requester_en           : out std_logic;
        cfg_dev_control2_atomic_egress_block           : out std_logic;
        cfg_dev_control2_ido_req_en                    : out std_logic;
        cfg_dev_control2_ido_cpl_en                    : out std_logic;
        cfg_dev_control2_ltr_en                        : out std_logic;
        cfg_dev_control2_tlp_prefix_block              : out std_logic;
        cfg_slot_control_electromech_il_ctl_pulse      : out std_logic;
        cfg_root_control_syserr_corr_err_en            : out std_logic;
        cfg_root_control_syserr_non_fatal_err_en       : out std_logic;
        cfg_root_control_syserr_fatal_err_en           : out std_logic;
        cfg_root_control_pme_int_en                    : out std_logic;
        cfg_aer_ecrc_check_en                          : out std_logic;
        cfg_aer_ecrc_gen_en                            : out std_logic;
        cfg_aer_rooterr_corr_err_reporting_en          : out std_logic;
        cfg_aer_rooterr_non_fatal_err_reporting_en     : out std_logic;
        cfg_aer_rooterr_fatal_err_reporting_en         : out std_logic;
        cfg_aer_rooterr_corr_err_received              : out std_logic;
        cfg_aer_rooterr_non_fatal_err_received         : out std_logic;
        cfg_aer_rooterr_fatal_err_received             : out std_logic;
        cfg_vc_tcvc_map                                : out std_logic_vector( 6 downto 0);
        dbg_vec_a                                      : out std_logic_vector(63 downto 0);
        dbg_vec_b                                      : out std_logic_vector(63 downto 0);
        dbg_vec_c                                      : out std_logic_vector(11 downto 0);
        dbg_sclr_a                                     : out std_logic;
        dbg_sclr_b                                     : out std_logic;
        dbg_sclr_c                                     : out std_logic;
        dbg_sclr_d                                     : out std_logic;
        dbg_sclr_e                                     : out std_logic;
        dbg_sclr_f                                     : out std_logic;
        dbg_sclr_g                                     : out std_logic;
        dbg_sclr_h                                     : out std_logic;
        dbg_sclr_i                                     : out std_logic;
        dbg_sclr_j                                     : out std_logic;
        dbg_sclr_k                                     : out std_logic;
        pl_dbg_vec                                     : out std_logic_vector(11 downto 0);
        xil_unconn_out                                 : out std_logic_vector(18 downto 0)
      );
   end component;

   component cl_a7pcie_x4_axi_basic_top is
      generic (
        C_DATA_WIDTH              : INTEGER := 128;     -- RX/TX interface data width
        C_FAMILY                  : STRING := "X7";    -- Targeted FPGA family
        C_ROOT_PORT               : BOOLEAN := FALSE; -- PCIe block is in root port mode
        C_PM_PRIORITY             : BOOLEAN := FALSE; -- Disable TX packet boundary thrtl
        TCQ                       : INTEGER := 1;      -- Clock to Q time
        C_REM_WIDTH               : INTEGER := 1       -- trem/rrem width
      );
      port (
        -----------------------------------------------
        -- User Design I/O
        -----------------------------------------------

        -- AXI TX
        -------------
        s_axis_tx_tdata         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
        s_axis_tx_tvalid        : IN STD_LOGIC                                   := '0';
        s_axis_tx_tready        : OUT STD_LOGIC                                  := '0';
        s_axis_tx_tkeep         : IN STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0) := (OTHERS=>'0');
        s_axis_tx_tlast         : IN STD_LOGIC                                   := '0';
        s_axis_tx_tuser         : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS=>'0');

        -- AXI RX
        -------------
        m_axis_rx_tdata         : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
        m_axis_rx_tvalid        : OUT STD_LOGIC                                   := '0';
        m_axis_rx_tready        : IN STD_LOGIC                                    := '0';
        m_axis_rx_tkeep         : OUT STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0) := (OTHERS=>'0');
        m_axis_rx_tlast         : OUT STD_LOGIC                                   := '0';
        m_axis_rx_tuser         : OUT STD_LOGIC_VECTOR(21 DOWNTO 0) := (OTHERS=>'0');

        -- User Misc.
        -------------
        user_turnoff_ok         : IN STD_LOGIC                                   := '0';
        user_tcfg_gnt           : IN STD_LOGIC                                   := '0';

        -----------------------------------------------
        -- PCIe Block I/O
        -----------------------------------------------

        -- TRN TX
        -------------
        trn_td                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
        trn_tsof                : OUT STD_LOGIC                                   := '0';
        trn_teof                : OUT STD_LOGIC                                   := '0';
        trn_tsrc_rdy            : OUT STD_LOGIC                                   := '0';
        trn_tdst_rdy            : IN STD_LOGIC                                    := '0';
        trn_tsrc_dsc            : OUT STD_LOGIC                                   := '0';
        trn_trem                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
        trn_terrfwd             : OUT STD_LOGIC                                   := '0';
        trn_tstr                : OUT STD_LOGIC                                   := '0';
        trn_tbuf_av             : IN STD_LOGIC_VECTOR(5 DOWNTO 0)                 := (OTHERS=>'0');
        trn_tecrc_gen           : OUT STD_LOGIC                                   := '0';

        -- TRN RX
        -------------
        trn_rd                  : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
        trn_rsof                : IN STD_LOGIC                                   := '0';
        trn_reof                : IN STD_LOGIC                                   := '0';
        trn_rsrc_rdy            : IN STD_LOGIC                                   := '0';
        trn_rdst_rdy            : OUT STD_LOGIC                                  := '0';
        trn_rsrc_dsc            : IN STD_LOGIC                                   := '0';
        trn_rrem                : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
        trn_rerrfwd             : IN STD_LOGIC                                   := '0';
        trn_rbar_hit            : IN STD_LOGIC_VECTOR(6 DOWNTO 0)                := (OTHERS=>'0');
        trn_recrc_err           : IN STD_LOGIC                                   := '0';

        -- TRN Misc.
        -------------
        trn_tcfg_req            : IN STD_LOGIC                                   := '0';
        trn_tcfg_gnt            : OUT STD_LOGIC                                  := '0';
        trn_lnk_up              : IN STD_LOGIC                                   := '0';

        -- 7 Series/Virtex6 PM
        -------------
        cfg_pcie_link_state     : IN STD_LOGIC_VECTOR(2 DOWNTO 0)                := (OTHERS=>'0');

        -- Virtex6 PM
        -------------
        cfg_pm_send_pme_to      : IN STD_LOGIC                                   := '0';
        cfg_pmcsr_powerstate    : IN STD_LOGIC_VECTOR(1 DOWNTO 0)                := (OTHERS=>'0');
        trn_rdllp_data          : IN STD_LOGIC_VECTOR(31 DOWNTO 0)               := (OTHERS=>'0');
        trn_rdllp_src_rdy       : IN STD_LOGIC                                   := '0';

        -- Virtex6/Spartan6 PM
        -------------
        cfg_to_turnoff          : IN STD_LOGIC                                   := '0';
        cfg_turnoff_ok          : OUT STD_LOGIC                                  := '0';

        np_counter              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)               := (OTHERS=>'0');
        user_clk                : IN STD_LOGIC                                   := '0';
        user_rst                : IN STD_LOGIC                                   := '0'
      );
   end component;

   component cl_a7pcie_x4_pcie_pipe_pipeline is
      generic (
       LINK_CAP_MAX_LINK_WIDTH_int                  : integer := 8;
       PIPE_PIPELINE_STAGES                         : integer := 0  -- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
      );
      port (
        -- Pipe Per-Link Signals
        pipe_tx_rcvr_det_i                           : in std_logic;
        pipe_tx_reset_i                              : in std_logic;
        pipe_tx_rate_i                               : in std_logic;
        pipe_tx_deemph_i                             : in std_logic;
        pipe_tx_margin_i                             : in std_logic_vector(2 downto 0);
        pipe_tx_swing_i                              : in std_logic;

        pipe_tx_rcvr_det_o                           : out std_logic;
        pipe_tx_reset_o                              : out std_logic;
        pipe_tx_rate_o                               : out std_logic;
        pipe_tx_deemph_o                             : out std_logic;
        pipe_tx_margin_o                             : out std_logic_vector(2 downto 0);
        pipe_tx_swing_o                              : out std_logic;

        -- Pipe Per-Lane Signals - Lane 0
        pipe_rx0_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx0_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx0_valid_o                             : out std_logic;
        pipe_rx0_chanisaligned_o                     : out std_logic;
        pipe_rx0_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx0_phy_status_o                        : out std_logic;
        pipe_rx0_elec_idle_o                         : out std_logic;
        pipe_rx0_polarity_i                          : in std_logic;

        pipe_tx0_compliance_i                        : in std_logic;
        pipe_tx0_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx0_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx0_elec_idle_i                         : in std_logic;
        pipe_tx0_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx0_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx0_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx0_valid_i                             : in std_logic;
        pipe_rx0_chanisaligned_i                     : in std_logic;
        pipe_rx0_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx0_phy_status_i                        : in std_logic;
        pipe_rx0_elec_idle_i                         : in std_logic;
        pipe_rx0_polarity_o                          : out std_logic;

        pipe_tx0_compliance_o                        : out std_logic;
        pipe_tx0_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx0_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx0_elec_idle_o                         : out std_logic;
        pipe_tx0_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 1
        pipe_rx1_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx1_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx1_valid_o                             : out std_logic;
        pipe_rx1_chanisaligned_o                     : out std_logic;
        pipe_rx1_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx1_phy_status_o                        : out std_logic;
        pipe_rx1_elec_idle_o                         : out std_logic;
        pipe_rx1_polarity_i                          : in std_logic;

        pipe_tx1_compliance_i                        : in std_logic;
        pipe_tx1_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx1_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx1_elec_idle_i                         : in std_logic;
        pipe_tx1_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx1_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx1_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx1_valid_i                             : in std_logic;
        pipe_rx1_chanisaligned_i                     : in std_logic;
        pipe_rx1_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx1_phy_status_i                        : in std_logic;
        pipe_rx1_elec_idle_i                         : in std_logic;
        pipe_rx1_polarity_o                          : out std_logic;

        pipe_tx1_compliance_o                        : out std_logic;
        pipe_tx1_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx1_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx1_elec_idle_o                         : out std_logic;
        pipe_tx1_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 2
        pipe_rx2_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx2_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx2_valid_o                             : out std_logic;
        pipe_rx2_chanisaligned_o                     : out std_logic;
        pipe_rx2_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx2_phy_status_o                        : out std_logic;
        pipe_rx2_elec_idle_o                         : out std_logic;
        pipe_rx2_polarity_i                          : in std_logic;

        pipe_tx2_compliance_i                        : in std_logic;
        pipe_tx2_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx2_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx2_elec_idle_i                         : in std_logic;
        pipe_tx2_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx2_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx2_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx2_valid_i                             : in std_logic;
        pipe_rx2_chanisaligned_i                     : in std_logic;
        pipe_rx2_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx2_phy_status_i                        : in std_logic;
        pipe_rx2_elec_idle_i                         : in std_logic;
        pipe_rx2_polarity_o                          : out std_logic;

        pipe_tx2_compliance_o                        : out std_logic;
        pipe_tx2_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx2_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx2_elec_idle_o                         : out std_logic;
        pipe_tx2_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 3
        pipe_rx3_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx3_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx3_valid_o                             : out std_logic;
        pipe_rx3_chanisaligned_o                     : out std_logic;
        pipe_rx3_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx3_phy_status_o                        : out std_logic;
        pipe_rx3_elec_idle_o                         : out std_logic;
        pipe_rx3_polarity_i                          : in std_logic;

        pipe_tx3_compliance_i                        : in std_logic;
        pipe_tx3_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx3_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx3_elec_idle_i                         : in std_logic;
        pipe_tx3_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx3_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx3_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx3_valid_i                             : in std_logic;
        pipe_rx3_chanisaligned_i                     : in std_logic;
        pipe_rx3_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx3_phy_status_i                        : in std_logic;
        pipe_rx3_elec_idle_i                         : in std_logic;
        pipe_rx3_polarity_o                          : out std_logic;

        pipe_tx3_compliance_o                        : out std_logic;
        pipe_tx3_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx3_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx3_elec_idle_o                         : out std_logic;
        pipe_tx3_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 4
        pipe_rx4_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx4_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx4_valid_o                             : out std_logic;
        pipe_rx4_chanisaligned_o                     : out std_logic;
        pipe_rx4_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx4_phy_status_o                        : out std_logic;
        pipe_rx4_elec_idle_o                         : out std_logic;
        pipe_rx4_polarity_i                          : in std_logic;

        pipe_tx4_compliance_i                        : in std_logic;
        pipe_tx4_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx4_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx4_elec_idle_i                         : in std_logic;
        pipe_tx4_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx4_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx4_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx4_valid_i                             : in std_logic;
        pipe_rx4_chanisaligned_i                     : in std_logic;
        pipe_rx4_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx4_phy_status_i                        : in std_logic;
        pipe_rx4_elec_idle_i                         : in std_logic;
        pipe_rx4_polarity_o                          : out std_logic;

        pipe_tx4_compliance_o                        : out std_logic;
        pipe_tx4_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx4_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx4_elec_idle_o                         : out std_logic;
        pipe_tx4_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 5
        pipe_rx5_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx5_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx5_valid_o                             : out std_logic;
        pipe_rx5_chanisaligned_o                     : out std_logic;
        pipe_rx5_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx5_phy_status_o                        : out std_logic;
        pipe_rx5_elec_idle_o                         : out std_logic;
        pipe_rx5_polarity_i                          : in std_logic;

        pipe_tx5_compliance_i                        : in std_logic;
        pipe_tx5_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx5_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx5_elec_idle_i                         : in std_logic;
        pipe_tx5_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx5_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx5_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx5_valid_i                             : in std_logic;
        pipe_rx5_chanisaligned_i                     : in std_logic;
        pipe_rx5_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx5_phy_status_i                        : in std_logic;
        pipe_rx5_elec_idle_i                         : in std_logic;
        pipe_rx5_polarity_o                          : out std_logic;

        pipe_tx5_compliance_o                        : out std_logic;
        pipe_tx5_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx5_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx5_elec_idle_o                         : out std_logic;
        pipe_tx5_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 6
        pipe_rx6_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx6_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx6_valid_o                             : out std_logic;
        pipe_rx6_chanisaligned_o                     : out std_logic;
        pipe_rx6_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx6_phy_status_o                        : out std_logic;
        pipe_rx6_elec_idle_o                         : out std_logic;
        pipe_rx6_polarity_i                          : in std_logic;

        pipe_tx6_compliance_i                        : in std_logic;
        pipe_tx6_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx6_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx6_elec_idle_i                         : in std_logic;
        pipe_tx6_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx6_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx6_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx6_valid_i                             : in std_logic;
        pipe_rx6_chanisaligned_i                     : in std_logic;
        pipe_rx6_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx6_phy_status_i                        : in std_logic;
        pipe_rx6_elec_idle_i                         : in std_logic;
        pipe_rx6_polarity_o                          : out std_logic;

        pipe_tx6_compliance_o                        : out std_logic;
        pipe_tx6_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx6_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx6_elec_idle_o                         : out std_logic;
        pipe_tx6_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Pipe Per-Lane Signals - Lane 7
        pipe_rx7_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_rx7_data_o                              : out std_logic_vector(15 downto 0);
        pipe_rx7_valid_o                             : out std_logic;
        pipe_rx7_chanisaligned_o                     : out std_logic;
        pipe_rx7_status_o                            : out std_logic_vector(2 downto 0);
        pipe_rx7_phy_status_o                        : out std_logic;
        pipe_rx7_elec_idle_o                         : out std_logic;
        pipe_rx7_polarity_i                          : in std_logic;

        pipe_tx7_compliance_i                        : in std_logic;
        pipe_tx7_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_tx7_data_i                              : in std_logic_vector(15 downto 0);
        pipe_tx7_elec_idle_i                         : in std_logic;
        pipe_tx7_powerdown_i                         : in std_logic_vector(1 downto 0);

        pipe_rx7_char_is_k_i                         : in std_logic_vector(1 downto 0);
        pipe_rx7_data_i                              : in std_logic_vector(15 downto 0);
        pipe_rx7_valid_i                             : in std_logic;
        pipe_rx7_chanisaligned_i                     : in std_logic;
        pipe_rx7_status_i                            : in std_logic_vector(2 downto 0);
        pipe_rx7_phy_status_i                        : in std_logic;
        pipe_rx7_elec_idle_i                         : in std_logic;
        pipe_rx7_polarity_o                          : out std_logic;

        pipe_tx7_compliance_o                        : out std_logic;
        pipe_tx7_char_is_k_o                         : out std_logic_vector(1 downto 0);
        pipe_tx7_data_o                              : out std_logic_vector(15 downto 0);
        pipe_tx7_elec_idle_o                         : out std_logic;
        pipe_tx7_powerdown_o                         : out std_logic_vector(1 downto 0);

        -- Non PIPE signals
        pl_ltssm_state                               : in std_logic_vector(5 downto 0);
        pipe_clk                                     : in std_logic;
        rst_n                                        : in std_logic
      );
   end component;

  -- TRN Interface
  signal    trn_td                   : std_logic_vector ((C_DATA_WIDTH - 1) downto 0);
  signal    trn_trem                 : std_logic_vector ((C_REM_WIDTH - 1) downto 0);
  signal    trn_tsof                 : std_logic;
  signal    trn_teof                 : std_logic;
  signal    trn_tsrc_rdy             : std_logic;
  signal    trn_tsrc_dsc             : std_logic;
  signal    trn_terrfwd              : std_logic;
  signal    trn_tecrc_gen            : std_logic;
  signal    trn_tstr                 : std_logic;
  signal    trn_tcfg_gnt             : std_logic;
  signal    trn_tdst_rdy             : std_logic;
  signal    trn_recrc_err            : std_logic;


  signal    trn_rd                   : std_logic_vector ((C_DATA_WIDTH - 1) downto 0);
  signal    trn_rrem                 : std_logic_vector ((C_REM_WIDTH - 1) downto 0);
  signal    trn_rdst_rdy             : std_logic;
  signal    trn_rsof                 : std_logic;
  signal    trn_reof                 : std_logic;
  signal    trn_rsrc_rdy             : std_logic;
  signal    trn_rsrc_dsc             : std_logic;
  signal    trn_rerrfwd              : std_logic;
  signal    trn_rbar_hit             : std_logic_vector (7 downto 0);

  signal sys_reset_n_d               : std_logic;
  signal pipe_rx0_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx1_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx2_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx3_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx4_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx5_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx6_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx7_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_rx0_valid              : std_logic;
  signal pipe_rx1_valid              : std_logic;
  signal pipe_rx2_valid              : std_logic;
  signal pipe_rx3_valid              : std_logic;
  signal pipe_rx4_valid              : std_logic;
  signal pipe_rx5_valid              : std_logic;
  signal pipe_rx6_valid              : std_logic;
  signal pipe_rx7_valid              : std_logic;
  signal pipe_rx0_data               : std_logic_vector(15 downto 0);
  signal pipe_rx1_data               : std_logic_vector(15 downto 0);
  signal pipe_rx2_data               : std_logic_vector(15 downto 0);
  signal pipe_rx3_data               : std_logic_vector(15 downto 0);
  signal pipe_rx4_data               : std_logic_vector(15 downto 0);
  signal pipe_rx5_data               : std_logic_vector(15 downto 0);
  signal pipe_rx6_data               : std_logic_vector(15 downto 0);
  signal pipe_rx7_data               : std_logic_vector(15 downto 0);
  signal pipe_rx0_chanisaligned      : std_logic;
  signal pipe_rx1_chanisaligned      : std_logic;
  signal pipe_rx2_chanisaligned      : std_logic;
  signal pipe_rx3_chanisaligned      : std_logic;
  signal pipe_rx4_chanisaligned      : std_logic;
  signal pipe_rx5_chanisaligned      : std_logic;
  signal pipe_rx6_chanisaligned      : std_logic;
  signal pipe_rx7_chanisaligned      : std_logic;
  signal pipe_rx0_status             : std_logic_vector(2 downto 0);
  signal pipe_rx1_status             : std_logic_vector(2 downto 0);
  signal pipe_rx2_status             : std_logic_vector(2 downto 0);
  signal pipe_rx3_status             : std_logic_vector(2 downto 0);
  signal pipe_rx4_status             : std_logic_vector(2 downto 0);
  signal pipe_rx5_status             : std_logic_vector(2 downto 0);
  signal pipe_rx6_status             : std_logic_vector(2 downto 0);
  signal pipe_rx7_status             : std_logic_vector(2 downto 0);
  signal pipe_rx0_phy_status         : std_logic;
  signal pipe_rx1_phy_status         : std_logic;
  signal pipe_rx2_phy_status         : std_logic;
  signal pipe_rx3_phy_status         : std_logic;
  signal pipe_rx4_phy_status         : std_logic;
  signal pipe_rx5_phy_status         : std_logic;
  signal pipe_rx6_phy_status         : std_logic;
  signal pipe_rx7_phy_status         : std_logic;

  signal pipe_rx0_elec_idle          : std_logic;
  signal pipe_rx1_elec_idle          : std_logic;
  signal pipe_rx2_elec_idle          : std_logic;
  signal pipe_rx3_elec_idle          : std_logic;
  signal pipe_rx4_elec_idle          : std_logic;
  signal pipe_rx5_elec_idle          : std_logic;
  signal pipe_rx6_elec_idle          : std_logic;
  signal pipe_rx7_elec_idle          : std_logic;


  signal pipe_tx_reset               : std_logic;
  signal pipe_tx_rate                : std_logic;
  signal pipe_tx_deemph              : std_logic;
  signal pipe_tx_margin              : std_logic_vector(2 downto 0);
  signal pipe_rx0_polarity           : std_logic;
  signal pipe_rx1_polarity           : std_logic;
  signal pipe_rx2_polarity           : std_logic;
  signal pipe_rx3_polarity           : std_logic;
  signal pipe_rx4_polarity           : std_logic;
  signal pipe_rx5_polarity           : std_logic;
  signal pipe_rx6_polarity           : std_logic;
  signal pipe_rx7_polarity           : std_logic;
  signal pipe_tx0_compliance         : std_logic;
  signal pipe_tx1_compliance         : std_logic;
  signal pipe_tx2_compliance         : std_logic;
  signal pipe_tx3_compliance         : std_logic;
  signal pipe_tx4_compliance         : std_logic;
  signal pipe_tx5_compliance         : std_logic;
  signal pipe_tx6_compliance         : std_logic;
  signal pipe_tx7_compliance         : std_logic;
  signal pipe_tx0_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx1_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx2_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx3_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx4_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx5_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx6_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx7_char_is_k          : std_logic_vector(1 downto 0);
  signal pipe_tx0_data               : std_logic_vector(15 downto 0);
  signal pipe_tx1_data               : std_logic_vector(15 downto 0);
  signal pipe_tx2_data               : std_logic_vector(15 downto 0);
  signal pipe_tx3_data               : std_logic_vector(15 downto 0);
  signal pipe_tx4_data               : std_logic_vector(15 downto 0);
  signal pipe_tx5_data               : std_logic_vector(15 downto 0);
  signal pipe_tx6_data               : std_logic_vector(15 downto 0);
  signal pipe_tx7_data               : std_logic_vector(15 downto 0);
  signal pipe_tx0_elec_idle          : std_logic;
  signal pipe_tx1_elec_idle          : std_logic;
  signal pipe_tx2_elec_idle          : std_logic;
  signal pipe_tx3_elec_idle          : std_logic;
  signal pipe_tx4_elec_idle          : std_logic;
  signal pipe_tx5_elec_idle          : std_logic;
  signal pipe_tx6_elec_idle          : std_logic;
  signal pipe_tx7_elec_idle          : std_logic;
  signal pipe_tx0_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx1_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx2_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx3_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx4_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx5_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx6_powerdown          : std_logic_vector(1 downto 0);
  signal pipe_tx7_powerdown          : std_logic_vector(1 downto 0);

  signal cfg_received_func_lvl_rst_n : std_logic;
  signal cfg_err_cpl_rdy_n           : std_logic;
  signal cfg_interrupt_rdy_n         : std_logic;
  signal cfg_bus_number_d            : std_logic_vector(7 downto 0);
  signal cfg_device_number_d         : std_logic_vector(4 downto 0);
  signal cfg_function_number_d       : std_logic_vector(2 downto 0);

  signal cfg_mgmt_rd_wr_done_n         : std_logic;
  signal pl_phy_lnk_up_n               : std_logic;
  signal cfg_err_aer_headerlog_set_n   : std_logic;

  -- Define intermediate wires
  signal cfg_command_mem_enable_int    : std_logic;
  signal cfg_msg_received_pme_to_int   : std_logic;
  signal cfg_command_interrupt_disable_int : std_logic;
  signal cfg_command_serr_en_int           : std_logic;
  signal cfg_command_bus_master_enable_int : std_logic;
  signal cfg_command_io_enable_int         : std_logic;
  signal cfg_trn_pending_n                 : std_logic;
  signal cfg_dev_status_ur_detected_int    : std_logic;
  signal cfg_dev_status_fatal_err_detected_int : std_logic;
  signal cfg_dev_status_non_fatal_err_detected_int : std_logic;
  signal cfg_dev_status_corr_err_detected_int : std_logic;
  signal cfg_dev_control_non_fatal_reporting_en_int : std_logic;
  signal cfg_dev_control_fatal_err_reporting_en_int : std_logic;
  signal cfg_dev_control_corr_err_reporting_en_int : std_logic;
  signal cfg_dev_control_ur_err_reporting_en_int : std_logic;
  signal cfg_dev_control_max_read_req_int : std_logic_vector(2 downto 0);
  signal cfg_dev_control_max_payload_int : std_logic_vector(2 downto 0);
  signal cfg_dev_control_enable_ro_int : std_logic;
  signal cfg_dev_control_no_snoop_en_int : std_logic;
  signal cfg_dev_control_aux_power_en_int : std_logic;
  signal cfg_dev_control_phantom_en_int : std_logic;
  signal cfg_dev_control_ext_tag_en_int : std_logic;
  signal cfg_link_status_auto_bandwidth_status_int   : std_logic;
  signal cfg_link_status_bandwidth_status_int        : std_logic;
  signal cfg_link_status_dll_active_int              : std_logic;
  signal cfg_link_status_link_training_int           : std_logic;
  signal cfg_link_status_negotiated_width_int        : std_logic_vector(3 downto 0);
  signal cfg_link_status_current_speed_int           : std_logic_vector(1 downto 0);
  signal cfg_link_control_auto_bandwidth_int_en_int  : std_logic;
  signal cfg_link_control_bandwidth_int_en_int       : std_logic;
  signal cfg_link_control_hw_auto_width_dis_int      : std_logic;
  signal cfg_link_control_clock_pm_en_int            : std_logic;
  signal cfg_link_control_extended_sync_int          : std_logic;
  signal cfg_link_control_common_clock_int           : std_logic;
  signal cfg_link_control_retrain_link_int           : std_logic;
  signal cfg_link_control_link_disable_int           : std_logic;
  signal cfg_link_control_rcb_int                    : std_logic;
  signal cfg_link_control_aspm_control_int           : std_logic_vector(1 downto 0);
  signal cfg_dev_control2_tlp_prefix_block_int       : std_logic;
  signal cfg_dev_control2_ltr_en_int                 : std_logic;
  signal cfg_dev_control2_ido_cpl_en_int             : std_logic;
  signal cfg_dev_control2_ido_req_en_int             : std_logic;
  signal cfg_dev_control2_atomic_egress_block_int    : std_logic;
  signal cfg_dev_control2_atomic_requester_en_int    : std_logic;
  signal cfg_dev_control2_ari_forward_en_int         : std_logic;
  signal cfg_dev_control2_cpl_timeout_dis_int        : std_logic;
  signal cfg_dev_control2_cpl_timeout_val_int        : std_logic_vector(3 downto 0);
  signal user_clk_out_int                            : std_logic;
  signal cfg_msg_received_int                        : std_logic;
  signal cfg_msg_data_int                            : std_logic_vector(15 downto 0);
  signal cfg_turnoff_ok_int_n                        : std_logic;
  signal cfg_turnoff_ok_int                          : std_logic;
  signal phy_rdy                                     : std_logic;
  signal tx_buf_av_int                               : std_logic_vector(5 downto 0);
  signal tx_cfg_req_int                              : std_logic;
  signal cfg_pcie_link_state_int                     : std_logic_vector(2 downto 0);
  signal cfg_pmcsr_powerstate_int                    : std_logic_vector(1 downto 0);
  signal pipe_tx_rcvr_det                            : std_logic;
  signal pl_ltssm_state_int                          : std_logic_vector(5 downto 0);

 -- signal cfg_to_turnoff              : std_logic;
   -- Calculate Link Status Slot Clock Config Bit
  function get_slot_clk_cfg (
    constant lstat_clk_cfg   : string)
    return std_logic is
  begin  -- msb_d
    if (lstat_clk_cfg = "TRUE") then
      return '1';
    else
      return '0';
    end if;
  end get_slot_clk_cfg;

  constant lstatus_slot_clk_config  : std_logic :=  get_slot_clk_cfg(LINK_STATUS_SLOT_CLOCK_CONFIG);
  constant TCQ     : integer := 1;

  begin

    -- Assign outputs
    cfg_msg_received_pme_to                 <= cfg_msg_received_pme_to_int;
    cfg_command_mem_enable                  <= cfg_command_mem_enable_int;
    cfg_command_interrupt_disable           <= cfg_command_interrupt_disable_int;
    cfg_command_serr_en                     <= cfg_command_serr_en_int;
    cfg_command_bus_master_enable           <= cfg_command_bus_master_enable_int;
    cfg_command_io_enable                   <= cfg_command_io_enable_int;
    cfg_trn_pending_n                       <= not cfg_trn_pending;
    cfg_dev_status_ur_detected              <= cfg_dev_status_ur_detected_int;
    cfg_dev_status_fatal_err_detected       <= cfg_dev_status_fatal_err_detected_int;
    cfg_dev_status_non_fatal_err_detected   <= cfg_dev_status_non_fatal_err_detected_int;
    cfg_dev_status_corr_err_detected        <= cfg_dev_status_corr_err_detected_int;
    cfg_dev_control_non_fatal_reporting_en  <= cfg_dev_control_non_fatal_reporting_en_int;
    cfg_dev_control_fatal_err_reporting_en  <= cfg_dev_control_fatal_err_reporting_en_int;
    cfg_dev_control_corr_err_reporting_en   <= cfg_dev_control_corr_err_reporting_en_int;
    cfg_dev_control_ur_err_reporting_en     <= cfg_dev_control_ur_err_reporting_en_int;
    cfg_dev_control_max_read_req            <= cfg_dev_control_max_read_req_int;
    cfg_dev_control_max_payload             <= cfg_dev_control_max_payload_int;
    cfg_dev_control_enable_ro               <= cfg_dev_control_enable_ro_int;
    cfg_dev_control_no_snoop_en             <= cfg_dev_control_no_snoop_en_int;
    cfg_dev_control_aux_power_en            <= cfg_dev_control_aux_power_en_int;
    cfg_dev_control_phantom_en              <= cfg_dev_control_phantom_en_int;
    cfg_dev_control_ext_tag_en              <= cfg_dev_control_ext_tag_en_int;
    cfg_link_status_auto_bandwidth_status   <= cfg_link_status_auto_bandwidth_status_int;
    cfg_link_status_bandwidth_status        <= cfg_link_status_bandwidth_status_int;
    cfg_link_status_dll_active              <= cfg_link_status_dll_active_int;
    cfg_link_status_link_training           <= cfg_link_status_link_training_int;
    cfg_link_status_negotiated_width        <= cfg_link_status_negotiated_width_int;
    cfg_link_status_current_speed           <= cfg_link_status_current_speed_int;
    cfg_link_control_auto_bandwidth_int_en  <= cfg_link_control_auto_bandwidth_int_en_int;
    cfg_link_control_bandwidth_int_en       <= cfg_link_control_bandwidth_int_en_int;
    cfg_link_control_hw_auto_width_dis      <= cfg_link_control_hw_auto_width_dis_int;
    cfg_link_control_clock_pm_en            <= cfg_link_control_clock_pm_en_int;
    cfg_link_control_extended_sync          <= cfg_link_control_extended_sync_int;
    cfg_link_control_common_clock           <= cfg_link_control_common_clock_int;
    cfg_link_control_retrain_link           <= cfg_link_control_retrain_link_int;
    cfg_link_control_link_disable           <= cfg_link_control_link_disable_int;
    cfg_link_control_rcb                    <= cfg_link_control_rcb_int;
    cfg_link_control_aspm_control           <= cfg_link_control_aspm_control_int;
    cfg_dev_control2_tlp_prefix_block       <= cfg_dev_control2_tlp_prefix_block_int;
    cfg_dev_control2_ltr_en                 <= cfg_dev_control2_ltr_en_int;
    cfg_dev_control2_ido_cpl_en             <= cfg_dev_control2_ido_cpl_en_int;
    cfg_dev_control2_ido_req_en             <= cfg_dev_control2_ido_req_en_int;
    cfg_dev_control2_atomic_egress_block    <= cfg_dev_control2_atomic_egress_block_int;
    cfg_dev_control2_atomic_requester_en    <= cfg_dev_control2_atomic_requester_en_int;
    cfg_dev_control2_ari_forward_en         <= cfg_dev_control2_ari_forward_en_int;
    cfg_dev_control2_cpl_timeout_dis        <= cfg_dev_control2_cpl_timeout_dis_int;
    cfg_dev_control2_cpl_timeout_val        <= cfg_dev_control2_cpl_timeout_val_int;
    user_clk_out                            <= user_clk_out_int;
    cfg_msg_received                        <= cfg_msg_received_int;
    cfg_msg_data                            <= cfg_msg_data_int;
    cfg_turnoff_ok_int_n                    <= not cfg_turnoff_ok_int;
    phy_rdy                                 <= not phy_rdy_n;
    tx_buf_av                               <= tx_buf_av_int;
    tx_cfg_req                              <= tx_cfg_req_int;
    cfg_pcie_link_state                     <= cfg_pcie_link_state_int;
    cfg_pmcsr_powerstate                    <= cfg_pmcsr_powerstate_int;
    pl_ltssm_state                          <= pl_ltssm_state_int;

    -- Assign intermediate signals
    cfg_received_func_lvl_rst <= not cfg_received_func_lvl_rst_n;
    cfg_err_cpl_rdy           <= not cfg_err_cpl_rdy_n;
    cfg_interrupt_rdy         <= not cfg_interrupt_rdy_n;
    cfg_mgmt_rd_wr_done       <= not cfg_mgmt_rd_wr_done_n;
    pl_phy_lnk_up             <= not pl_phy_lnk_up_n;
    cfg_err_aer_headerlog_set <= not cfg_err_aer_headerlog_set_n;
    cfg_to_turnoff            <= cfg_msg_received_pme_to_int;

    cfg_status                <=  X"0000";

    cfg_command               <=  ("00000" &
                                  cfg_command_interrupt_disable_int &
                                  '0' &
                                  cfg_command_serr_en_int &
                                  "00000" &
                                  cfg_command_bus_master_enable_int &
                                  cfg_command_mem_enable_int &
                                  cfg_command_io_enable_int);

    cfg_dstatus                   <= "0000000000" &
                                  cfg_trn_pending &
                                  '0' &
                                  cfg_dev_status_ur_detected_int &
                                  cfg_dev_status_fatal_err_detected_int &
                                  cfg_dev_status_non_fatal_err_detected_int &
                                  cfg_dev_status_corr_err_detected_int;

    cfg_dcommand                  <= '0' &
                                     cfg_dev_control_max_read_req_int &
                                     cfg_dev_control_no_snoop_en_int &
                                     cfg_dev_control_aux_power_en_int &
                                     cfg_dev_control_phantom_en_int &
                                     cfg_dev_control_ext_tag_en_int &
                                     cfg_dev_control_max_payload_int &
                                     cfg_dev_control_enable_ro_int &
                                     cfg_dev_control_ur_err_reporting_en_int &
                                     cfg_dev_control_fatal_err_reporting_en_int &
                                     cfg_dev_control_non_fatal_reporting_en_int &
                                     cfg_dev_control_corr_err_reporting_en_int;

    cfg_lstatus                   <= cfg_link_status_auto_bandwidth_status_int &
                                     cfg_link_status_bandwidth_status_int &
                                     cfg_link_status_dll_active_int &
                                     lstatus_slot_clk_config &
                                     cfg_link_status_link_training_int &
                                     '0' &
                                     "00" &
                                     cfg_link_status_negotiated_width_int &
                                     "00" &
                                     cfg_link_status_current_speed_int;

    cfg_lcommand                   <= "0000" &
                                     cfg_link_control_auto_bandwidth_int_en_int &
                                     cfg_link_control_bandwidth_int_en_int &
                                     cfg_link_control_hw_auto_width_dis_int &
                                     cfg_link_control_clock_pm_en_int &
                                     cfg_link_control_extended_sync_int &
                                     cfg_link_control_common_clock_int &
                                     cfg_link_control_retrain_link_int &
                                     cfg_link_control_link_disable_int &
                                     cfg_link_control_rcb_int &
                                     '0' &
                                     cfg_link_control_aspm_control_int;

    cfg_bus_number                <= cfg_bus_number_d;

    cfg_device_number             <= cfg_device_number_d;

    cfg_function_number           <=  cfg_function_number_d;

    cfg_dcommand2                 <= "0000" &
                                     cfg_dev_control2_tlp_prefix_block_int &
                                     cfg_dev_control2_ltr_en_int &
                                     cfg_dev_control2_ido_cpl_en_int  &
                                     cfg_dev_control2_ido_req_en_int &
                                     cfg_dev_control2_atomic_egress_block_int &
                                     cfg_dev_control2_atomic_requester_en_int &
                                     cfg_dev_control2_ari_forward_en_int &
                                     cfg_dev_control2_cpl_timeout_dis_int &
                                     cfg_dev_control2_cpl_timeout_val_int;

  -- Capture Bus/Device/Function number
    process (user_clk_out_int)
    begin
      if (user_clk_out_int'event and user_clk_out_int = '1') then

        if (user_lnk_up = '0') then

          cfg_bus_number_d <= X"00" after (TCQ)*1 ps;
        elsif (cfg_msg_received_int = '0') then
          cfg_bus_number_d <= cfg_msg_data_int(15 downto 8) after (TCQ)*1 ps;
        else
          cfg_bus_number_d <=  cfg_bus_number_d after (TCQ)*1 ps;
        end if;
      end if;
    end process;

  -- Capture Bus/Device/Function number
    process (user_clk_out_int)
    begin
      if (user_clk_out_int'event and user_clk_out_int = '1') then
        if (user_lnk_up = '0') then
          cfg_device_number_d <= "00000" after (TCQ)*1 ps;
        elsif (cfg_msg_received_int = '0') then
          cfg_device_number_d <= cfg_msg_data_int(7 downto 3) after (TCQ)*1 ps;
        else
          cfg_device_number_d <=  cfg_device_number_d after (TCQ)*1 ps;
        end if;
      end if;
    end process;

  -- Capture Bus/Device/Function number
    process (user_clk_out_int)
    begin
      if (user_clk_out_int'event and user_clk_out_int = '1') then
        if (user_lnk_up = '0') then
          cfg_function_number_d <= "000" after (TCQ)*1 ps;
        elsif (cfg_msg_received_int = '0') then
          cfg_function_number_d <= cfg_msg_data_int(2 downto 0) after (TCQ)*1 ps;
        else
          cfg_function_number_d <=  cfg_function_number_d after (TCQ)*1 ps;
        end if;
      end if;
    end process;

  axi_basic_top_i : cl_a7pcie_x4_axi_basic_top
    generic map (
      C_DATA_WIDTH     => C_DATA_WIDTH,       -- RX/TX interface data width
      C_FAMILY         => "X7",               -- Targeted FPGA family
      C_ROOT_PORT      => FALSE,            -- PCIe block is in root port mode
      C_PM_PRIORITY    => FALSE,            -- Disable TX packet boundary thrtl
      TCQ              => TCQ,             -- Clock to Q time
      C_REM_WIDTH      => C_REM_WIDTH 

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
      s_axis_tx_tkeep          => s_axis_tx_tkeep,          --  input
      s_axis_tx_tlast          => s_axis_tx_tlast,          --  input
      s_axis_tx_tuser          => s_axis_tx_tuser,          --  input

      -- AXI RX
      -------------
      m_axis_rx_tdata          => m_axis_rx_tdata,          --  output
      m_axis_rx_tvalid         => m_axis_rx_tvalid,         --  output
      m_axis_rx_tready         => m_axis_rx_tready,         --  input
      m_axis_rx_tkeep          => m_axis_rx_tkeep,          --  output
      m_axis_rx_tlast          => m_axis_rx_tlast,          --  output
      m_axis_rx_tuser          => m_axis_rx_tuser,          --  output

      -- User Misc.
      ------------
      user_turnoff_ok          => cfg_turnoff_ok,           --  input
      user_tcfg_gnt            => tx_cfg_gnt,               --  input

      ------------------------------------------------
      -- PCIe Block I/O                              --
      ------------------------------------------------

      -- TRN TX
      ------------
      trn_td                   => trn_td,                   --  output
      trn_tsof                 => trn_tsof,                 --  output
      trn_teof                 => trn_teof,                 --  output
      trn_tsrc_rdy             => trn_tsrc_rdy,             --  output
      trn_tdst_rdy             => trn_tdst_rdy,             --  input
      trn_tsrc_dsc             => trn_tsrc_dsc,             --  output
      trn_trem                 => trn_trem,                 --  output
      trn_terrfwd              => trn_terrfwd,              --  output
      trn_tstr                 => trn_tstr,                 --  output
      trn_tbuf_av              => tx_buf_av_int,                --  input
      trn_tecrc_gen            => trn_tecrc_gen,            --  output

      -- TRN RX
      ------------
      trn_rd                   => trn_rd,                   --  input
      trn_rsof                 => trn_rsof,                 --  input
      trn_reof                 => trn_reof,                 --  input
      trn_rsrc_rdy             => trn_rsrc_rdy,             --  input
      trn_rdst_rdy             => trn_rdst_rdy,             --  output
      trn_rsrc_dsc             => trn_rsrc_dsc,             --  input
      trn_rrem                 => trn_rrem,                 --  input
      trn_rerrfwd              => trn_rerrfwd,              --  input
      trn_rbar_hit             => trn_rbar_hit(6 downto 0), --  input
      trn_recrc_err            => trn_recrc_err,            --  input

      -- TRN Misc.
      ------------
      trn_tcfg_req             =>  tx_cfg_req_int ,         --  input
      trn_tcfg_gnt             =>  trn_tcfg_gnt,            --  output
      trn_lnk_up               =>  user_lnk_up,             --  input

      -- Fuji3/Virtex6 PM
      ------------
      cfg_pcie_link_state      => cfg_pcie_link_state_int,      --  input

      -- Virtex6 PM
      ------------
      cfg_pm_send_pme_to       => '0',                          --  input  NOT USED FOR EP
      cfg_pmcsr_powerstate     => cfg_pmcsr_powerstate_int,     --  input
      trn_rdllp_data           => x"00000000",                  --  input
      trn_rdllp_src_rdy        => '0',                          --  input

      -- Power Mgmt for S6/V6
      ------------
      cfg_to_turnoff           => cfg_msg_received_pme_to_int,  --  input
      cfg_turnoff_ok           => cfg_turnoff_ok_int,           --  output

      -- System
      ------------
      user_clk                 => user_clk_out_int,             --  input
      user_rst                 => user_reset,                   --  input
      np_counter               => open                          --  output

    );


 ---------------------------------------------------------
 -- PCI Express Pipe Wrapper
 ---------------------------------------------------------
  pcie_7x_i : cl_a7pcie_x4_pcie_7x
    generic map (
      AER_BASE_PTR    => AER_BASE_PTR ,
      AER_CAP_ECRC_CHECK_CAPABLE      => AER_CAP_ECRC_CHECK_CAPABLE ,
      AER_CAP_ECRC_GEN_CAPABLE=> AER_CAP_ECRC_GEN_CAPABLE ,
      AER_CAP_ID      => AER_CAP_ID ,
      AER_CAP_MULTIHEADER => AER_CAP_MULTIHEADER ,
      AER_CAP_NEXTPTR => AER_CAP_NEXTPTR ,
      AER_CAP_ON      => AER_CAP_ON ,
      AER_CAP_OPTIONAL_ERR_SUPPORT    => AER_CAP_OPTIONAL_ERR_SUPPORT ,
      AER_CAP_PERMIT_ROOTERR_UPDATE   => AER_CAP_PERMIT_ROOTERR_UPDATE ,
      AER_CAP_VERSION => AER_CAP_VERSION ,
      ALLOW_X8_GEN2 =>ALLOW_X8_GEN2,
      BAR0    => BAR0 ,
      BAR1    => BAR1 ,
      BAR2    => BAR2 ,
      BAR3    => BAR3 ,
      BAR4    => BAR4 ,
      BAR5    => BAR5 ,
      C_DATA_WIDTH => C_DATA_WIDTH ,
      C_REM_WIDTH  => C_REM_WIDTH ,
      CAPABILITIES_PTR=> CAPABILITIES_PTR ,
      CFG_ECRC_ERR_CPLSTAT    => CFG_ECRC_ERR_CPLSTAT ,
      CARDBUS_CIS_POINTER     => CARDBUS_CIS_POINTER ,
      CLASS_CODE      => CLASS_CODE ,
      CMD_INTX_IMPLEMENTED    => CMD_INTX_IMPLEMENTED ,
      CPL_TIMEOUT_DISABLE_SUPPORTED   => CPL_TIMEOUT_DISABLE_SUPPORTED ,
      CPL_TIMEOUT_RANGES_SUPPORTED    => CPL_TIMEOUT_RANGES_SUPPORTED ,
      CRM_MODULE_RSTS =>CRM_MODULE_RSTS,
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE     => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE ,
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE     => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE ,
      DEV_CAP_ENDPOINT_L0S_LATENCY    => DEV_CAP_ENDPOINT_L0S_LATENCY ,
      DEV_CAP_ENDPOINT_L1_LATENCY     => DEV_CAP_ENDPOINT_L1_LATENCY ,
      DEV_CAP_EXT_TAG_SUPPORTED => DEV_CAP_EXT_TAG_SUPPORTED ,
      DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE    => DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE ,
      DEV_CAP_MAX_PAYLOAD_SUPPORTED   => DEV_CAP_MAX_PAYLOAD_SUPPORTED ,
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT ,
      DEV_CAP_ROLE_BASED_ERROR=> DEV_CAP_ROLE_BASED_ERROR ,
      DEV_CAP_RSVD_14_12      => DEV_CAP_RSVD_14_12 ,
      DEV_CAP_RSVD_17_16      => DEV_CAP_RSVD_17_16 ,
      DEV_CAP_RSVD_31_29      => DEV_CAP_RSVD_31_29 ,
      DEV_CONTROL_AUX_POWER_SUPPORTED => DEV_CONTROL_AUX_POWER_SUPPORTED ,
      DEV_CONTROL_EXT_TAG_DEFAULT => DEV_CONTROL_EXT_TAG_DEFAULT ,
      DISABLE_ASPM_L1_TIMER   => DISABLE_ASPM_L1_TIMER ,
      DISABLE_BAR_FILTERING   => DISABLE_BAR_FILTERING ,
      DISABLE_ID_CHECK=> DISABLE_ID_CHECK ,
      DISABLE_LANE_REVERSAL   => DISABLE_LANE_REVERSAL ,
      DISABLE_RX_POISONED_RESP =>DISABLE_RX_POISONED_RESP,
      DISABLE_RX_TC_FILTER    => DISABLE_RX_TC_FILTER ,
      DISABLE_SCRAMBLING      => DISABLE_SCRAMBLING ,
      DNSTREAM_LINK_NUM => DNSTREAM_LINK_NUM ,
      DSN_BASE_PTR    => DSN_BASE_PTR ,
      DSN_CAP_ID      => DSN_CAP_ID ,
      DSN_CAP_NEXTPTR => DSN_CAP_NEXTPTR ,
      DSN_CAP_ON      => DSN_CAP_ON ,
      DSN_CAP_VERSION => DSN_CAP_VERSION ,
      DEV_CAP2_ARI_FORWARDING_SUPPORTED=>DEV_CAP2_ARI_FORWARDING_SUPPORTED,
      DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED =>DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED,
      DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED =>DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED,
      DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED =>DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED,
      DEV_CAP2_CAS128_COMPLETER_SUPPORTED =>DEV_CAP2_CAS128_COMPLETER_SUPPORTED,
      DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED =>DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED,
      DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED =>DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED,
      DEV_CAP2_LTR_MECHANISM_SUPPORTED =>DEV_CAP2_LTR_MECHANISM_SUPPORTED,
      DEV_CAP2_MAX_ENDEND_TLP_PREFIXES =>DEV_CAP2_MAX_ENDEND_TLP_PREFIXES,
      DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING =>DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING,
      DEV_CAP2_TPH_COMPLETER_SUPPORTED =>DEV_CAP2_TPH_COMPLETER_SUPPORTED,
      DISABLE_ERR_MSG =>DISABLE_ERR_MSG,
      DISABLE_LOCKED_FILTER =>DISABLE_LOCKED_FILTER,
      DISABLE_PPM_FILTER =>DISABLE_PPM_FILTER,
      ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED =>ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED,
      ENABLE_MSG_ROUTE=> ENABLE_MSG_ROUTE ,
      ENABLE_RX_TD_ECRC_TRIM  => ENABLE_RX_TD_ECRC_TRIM ,
      ENTER_RVRY_EI_L0=> ENTER_RVRY_EI_L0 ,
      EXIT_LOOPBACK_ON_EI =>EXIT_LOOPBACK_ON_EI,
      EXPANSION_ROM   => EXPANSION_ROM ,
      EXT_CFG_CAP_PTR => EXT_CFG_CAP_PTR ,
      EXT_CFG_XP_CAP_PTR      => EXT_CFG_XP_CAP_PTR ,
      HEADER_TYPE     => HEADER_TYPE ,
      INFER_EI=> INFER_EI ,
      INTERRUPT_PIN   => INTERRUPT_PIN ,
      INTERRUPT_STAT_AUTO =>INTERRUPT_STAT_AUTO,
      IS_SWITCH => IS_SWITCH ,
      LAST_CONFIG_DWORD => LAST_CONFIG_DWORD ,
      LINK_CAP_ASPM_OPTIONALITY => LINK_CAP_ASPM_OPTIONALITY ,
      LINK_CAP_ASPM_SUPPORT   => LINK_CAP_ASPM_SUPPORT ,
      LINK_CAP_CLOCK_POWER_MANAGEMENT => LINK_CAP_CLOCK_POWER_MANAGEMENT ,
      LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP  => LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP ,
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1   => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 ,
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2   => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 ,
      LINK_CAP_L0S_EXIT_LATENCY_GEN1  => LINK_CAP_L0S_EXIT_LATENCY_GEN1 ,
      LINK_CAP_L0S_EXIT_LATENCY_GEN2  => LINK_CAP_L0S_EXIT_LATENCY_GEN2 ,
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1    => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 ,
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2    => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 ,
      LINK_CAP_L1_EXIT_LATENCY_GEN1   => LINK_CAP_L1_EXIT_LATENCY_GEN1 ,
      LINK_CAP_L1_EXIT_LATENCY_GEN2   => LINK_CAP_L1_EXIT_LATENCY_GEN2 ,
      LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP =>LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP,
      LINK_CAP_MAX_LINK_SPEED => LINK_CAP_MAX_LINK_SPEED ,
      LINK_CAP_MAX_LINK_SPEED_int => LINK_CAP_MAX_LINK_SPEED_int ,
      LINK_CAP_MAX_LINK_WIDTH => LINK_CAP_MAX_LINK_WIDTH ,
      LINK_CAP_MAX_LINK_WIDTH_int => LINK_CAP_MAX_LINK_WIDTH_int ,
      LINK_CAP_RSVD_23=> LINK_CAP_RSVD_23 ,
      LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE    => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE ,
      LINK_CONTROL_RCB=> LINK_CONTROL_RCB ,
      LINK_CTRL2_DEEMPHASIS   => LINK_CTRL2_DEEMPHASIS ,
      LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE  => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE ,
      LINK_CTRL2_TARGET_LINK_SPEED    => LINK_CTRL2_TARGET_LINK_SPEED ,
      LINK_STATUS_SLOT_CLOCK_CONFIG   => LINK_STATUS_SLOT_CLOCK_CONFIG ,
      LL_ACK_TIMEOUT  => LL_ACK_TIMEOUT ,
      LL_ACK_TIMEOUT_EN => LL_ACK_TIMEOUT_EN ,
      LL_ACK_TIMEOUT_FUNC     => LL_ACK_TIMEOUT_FUNC ,
      LL_REPLAY_TIMEOUT => LL_REPLAY_TIMEOUT ,
      LL_REPLAY_TIMEOUT_EN    => LL_REPLAY_TIMEOUT_EN ,
      LL_REPLAY_TIMEOUT_FUNC  => LL_REPLAY_TIMEOUT_FUNC ,
      LTSSM_MAX_LINK_WIDTH    => LTSSM_MAX_LINK_WIDTH ,
      MPS_FORCE =>MPS_FORCE,
      MSI_BASE_PTR    => MSI_BASE_PTR ,
      MSI_CAP_ID      => MSI_CAP_ID ,
      MSI_CAP_MULTIMSGCAP     => MSI_CAP_MULTIMSGCAP ,
      MSI_CAP_MULTIMSG_EXTENSION      => MSI_CAP_MULTIMSG_EXTENSION ,
      MSI_CAP_NEXTPTR => MSI_CAP_NEXTPTR ,
      MSI_CAP_ON      => MSI_CAP_ON ,
      MSI_CAP_PER_VECTOR_MASKING_CAPABLE      => MSI_CAP_PER_VECTOR_MASKING_CAPABLE ,
      MSI_CAP_64_BIT_ADDR_CAPABLE     => MSI_CAP_64_BIT_ADDR_CAPABLE ,
      MSIX_BASE_PTR   => MSIX_BASE_PTR ,
      MSIX_CAP_ID     => MSIX_CAP_ID ,
      MSIX_CAP_NEXTPTR=> MSIX_CAP_NEXTPTR ,
      MSIX_CAP_ON     => MSIX_CAP_ON ,
      MSIX_CAP_PBA_BIR=> MSIX_CAP_PBA_BIR ,
      MSIX_CAP_PBA_OFFSET     => MSIX_CAP_PBA_OFFSET ,
      MSIX_CAP_TABLE_BIR      => MSIX_CAP_TABLE_BIR ,
      MSIX_CAP_TABLE_OFFSET   => MSIX_CAP_TABLE_OFFSET ,
      MSIX_CAP_TABLE_SIZE     => MSIX_CAP_TABLE_SIZE ,
      N_FTS_COMCLK_GEN1 => N_FTS_COMCLK_GEN1 ,
      N_FTS_COMCLK_GEN2 => N_FTS_COMCLK_GEN2 ,
      N_FTS_GEN1      => N_FTS_GEN1 ,
      N_FTS_GEN2      => N_FTS_GEN2 ,
      PCIE_BASE_PTR   => PCIE_BASE_PTR ,
      PCIE_CAP_CAPABILITY_ID  => PCIE_CAP_CAPABILITY_ID ,
      PCIE_CAP_CAPABILITY_VERSION     => PCIE_CAP_CAPABILITY_VERSION ,
      PCIE_CAP_DEVICE_PORT_TYPE => PCIE_CAP_DEVICE_PORT_TYPE ,
      PCIE_CAP_NEXTPTR=> PCIE_CAP_NEXTPTR ,
      PCIE_CAP_ON     => PCIE_CAP_ON ,
      PCIE_CAP_RSVD_15_14     => PCIE_CAP_RSVD_15_14 ,
      PCIE_CAP_SLOT_IMPLEMENTED => PCIE_CAP_SLOT_IMPLEMENTED ,
      PCIE_REVISION   => PCIE_REVISION ,
      PL_AUTO_CONFIG  => PL_AUTO_CONFIG ,
      PL_FAST_TRAIN   => PL_FAST_TRAIN ,
      PM_ASPML0S_TIMEOUT => PM_ASPML0S_TIMEOUT ,
      PM_ASPML0S_TIMEOUT_EN => PM_ASPML0S_TIMEOUT_EN ,
      PM_ASPML0S_TIMEOUT_FUNC => PM_ASPML0S_TIMEOUT_FUNC ,
      PM_ASPM_FASTEXIT => PM_ASPM_FASTEXIT ,
      PM_BASE_PTR     => PM_BASE_PTR ,
      PM_CAP_AUXCURRENT => PM_CAP_AUXCURRENT ,
      PM_CAP_D1SUPPORT=> PM_CAP_D1SUPPORT ,
      PM_CAP_D2SUPPORT=> PM_CAP_D2SUPPORT ,
      PM_CAP_DSI      => PM_CAP_DSI ,
      PM_CAP_ID => PM_CAP_ID ,
      PM_CAP_NEXTPTR  => PM_CAP_NEXTPTR ,
      PM_CAP_ON => PM_CAP_ON ,
      PM_CAP_PME_CLOCK=> PM_CAP_PME_CLOCK ,
      PM_CAP_PMESUPPORT => PM_CAP_PMESUPPORT ,
      PM_CAP_RSVD_04  => PM_CAP_RSVD_04 ,
      PM_CAP_VERSION  => PM_CAP_VERSION ,
      PM_CSR_B2B3     => PM_CSR_B2B3 ,
      PM_CSR_BPCCEN   => PM_CSR_BPCCEN ,
      PM_CSR_NOSOFTRST=> PM_CSR_NOSOFTRST ,
      PM_DATA0=> PM_DATA0 ,
      PM_DATA1=> PM_DATA1 ,
      PM_DATA2=> PM_DATA2 ,
      PM_DATA3=> PM_DATA3 ,
      PM_DATA4=> PM_DATA4 ,
      PM_DATA5=> PM_DATA5 ,
      PM_DATA6=> PM_DATA6 ,
      PM_DATA7=> PM_DATA7 ,
      PM_DATA_SCALE0  => PM_DATA_SCALE0 ,
      PM_DATA_SCALE1  => PM_DATA_SCALE1 ,
      PM_DATA_SCALE2  => PM_DATA_SCALE2 ,
      PM_DATA_SCALE3  => PM_DATA_SCALE3 ,
      PM_DATA_SCALE4  => PM_DATA_SCALE4 ,
      PM_DATA_SCALE5  => PM_DATA_SCALE5 ,
      PM_DATA_SCALE6  => PM_DATA_SCALE6 ,
      PM_DATA_SCALE7  => PM_DATA_SCALE7 ,
      PM_MF =>PM_MF,
      RBAR_BASE_PTR =>RBAR_BASE_PTR,
      RBAR_CAP_CONTROL_ENCODEDBAR0 =>RBAR_CAP_CONTROL_ENCODEDBAR0,
      RBAR_CAP_CONTROL_ENCODEDBAR1 =>RBAR_CAP_CONTROL_ENCODEDBAR1,
      RBAR_CAP_CONTROL_ENCODEDBAR2 =>RBAR_CAP_CONTROL_ENCODEDBAR2,
      RBAR_CAP_CONTROL_ENCODEDBAR3 =>RBAR_CAP_CONTROL_ENCODEDBAR3,
      RBAR_CAP_CONTROL_ENCODEDBAR4 =>RBAR_CAP_CONTROL_ENCODEDBAR4,
      RBAR_CAP_CONTROL_ENCODEDBAR5 =>RBAR_CAP_CONTROL_ENCODEDBAR5,
      RBAR_CAP_ID =>RBAR_CAP_ID,
      RBAR_CAP_INDEX0 =>RBAR_CAP_INDEX0,
      RBAR_CAP_INDEX1 =>RBAR_CAP_INDEX1,
      RBAR_CAP_INDEX2 =>RBAR_CAP_INDEX2,
      RBAR_CAP_INDEX3 =>RBAR_CAP_INDEX3,
      RBAR_CAP_INDEX4 =>RBAR_CAP_INDEX4,
      RBAR_CAP_INDEX5 =>RBAR_CAP_INDEX5,
      RBAR_CAP_NEXTPTR =>RBAR_CAP_NEXTPTR,
      RBAR_CAP_ON =>RBAR_CAP_ON,
      RBAR_CAP_SUP0 =>RBAR_CAP_SUP0,
      RBAR_CAP_SUP1 =>RBAR_CAP_SUP1,
      RBAR_CAP_SUP2 =>RBAR_CAP_SUP2,
      RBAR_CAP_SUP3 =>RBAR_CAP_SUP3,
      RBAR_CAP_SUP4 =>RBAR_CAP_SUP4,
      RBAR_CAP_SUP5 =>RBAR_CAP_SUP5,
      RBAR_CAP_VERSION =>RBAR_CAP_VERSION,
      RBAR_NUM =>RBAR_NUM,
      RECRC_CHK  =>RECRC_CHK,
      RECRC_CHK_TRIM =>RECRC_CHK_TRIM,
      ROOT_CAP_CRS_SW_VISIBILITY      => ROOT_CAP_CRS_SW_VISIBILITY ,
      RP_AUTO_SPD       => RP_AUTO_SPD ,
      RP_AUTO_SPD_LOOPCNT        => RP_AUTO_SPD_LOOPCNT ,
      SELECT_DLL_IF   => SELECT_DLL_IF ,
      SLOT_CAP_ATT_BUTTON_PRESENT     => SLOT_CAP_ATT_BUTTON_PRESENT ,
      SLOT_CAP_ATT_INDICATOR_PRESENT  => SLOT_CAP_ATT_INDICATOR_PRESENT ,
      SLOT_CAP_ELEC_INTERLOCK_PRESENT => SLOT_CAP_ELEC_INTERLOCK_PRESENT ,
      SLOT_CAP_HOTPLUG_CAPABLE=> SLOT_CAP_HOTPLUG_CAPABLE ,
      SLOT_CAP_HOTPLUG_SURPRISE => SLOT_CAP_HOTPLUG_SURPRISE ,
      SLOT_CAP_MRL_SENSOR_PRESENT     => SLOT_CAP_MRL_SENSOR_PRESENT ,
      SLOT_CAP_NO_CMD_COMPLETED_SUPPORT => SLOT_CAP_NO_CMD_COMPLETED_SUPPORT ,
      SLOT_CAP_PHYSICAL_SLOT_NUM      => SLOT_CAP_PHYSICAL_SLOT_NUM ,
      SLOT_CAP_POWER_CONTROLLER_PRESENT => SLOT_CAP_POWER_CONTROLLER_PRESENT ,
      SLOT_CAP_POWER_INDICATOR_PRESENT=> SLOT_CAP_POWER_INDICATOR_PRESENT ,
      SLOT_CAP_SLOT_POWER_LIMIT_SCALE => SLOT_CAP_SLOT_POWER_LIMIT_SCALE ,
      SLOT_CAP_SLOT_POWER_LIMIT_VALUE => SLOT_CAP_SLOT_POWER_LIMIT_VALUE ,
      SPARE_BIT0      => SPARE_BIT0 ,
      SPARE_BIT1      => SPARE_BIT1 ,
      SPARE_BIT2      => SPARE_BIT2 ,
      SPARE_BIT3      => SPARE_BIT3 ,
      SPARE_BIT4      => SPARE_BIT4 ,
      SPARE_BIT5      => SPARE_BIT5 ,
      SPARE_BIT6      => SPARE_BIT6 ,
      SPARE_BIT7      => SPARE_BIT7 ,
      SPARE_BIT8      => SPARE_BIT8 ,
      SPARE_BYTE0     => SPARE_BYTE0 ,
      SPARE_BYTE1     => SPARE_BYTE1 ,
      SPARE_BYTE2     => SPARE_BYTE2 ,
      SPARE_BYTE3     => SPARE_BYTE3 ,
      SPARE_WORD0     => SPARE_WORD0 ,
      SPARE_WORD1     => SPARE_WORD1 ,
      SPARE_WORD2     => SPARE_WORD2 ,
      SPARE_WORD3     => SPARE_WORD3 ,
      SSL_MESSAGE_AUTO =>SSL_MESSAGE_AUTO,
      TECRC_EP_INV      => TECRC_EP_INV ,
      TL_RBYPASS=>TL_RBYPASS,
      TL_RX_RAM_RADDR_LATENCY => TL_RX_RAM_RADDR_LATENCY ,
      TL_RX_RAM_RDATA_LATENCY => TL_RX_RAM_RDATA_LATENCY ,
      TL_RX_RAM_WRITE_LATENCY => TL_RX_RAM_WRITE_LATENCY ,
      TL_TFC_DISABLE  => TL_TFC_DISABLE ,
      TL_TX_CHECKS_DISABLE    => TL_TX_CHECKS_DISABLE ,
      TL_TX_RAM_RADDR_LATENCY => TL_TX_RAM_RADDR_LATENCY ,
      TL_TX_RAM_RDATA_LATENCY => TL_TX_RAM_RDATA_LATENCY ,
      TL_TX_RAM_WRITE_LATENCY => TL_TX_RAM_WRITE_LATENCY ,
      TRN_DW =>TRN_DW,
      TRN_NP_FC =>TRN_NP_FC,
      UPCONFIG_CAPABLE=> UPCONFIG_CAPABLE ,
      UPSTREAM_FACING => UPSTREAM_FACING ,
      UR_ATOMIC =>UR_ATOMIC,
      UR_CFG1 =>UR_CFG1,
      UR_INV_REQ=>UR_INV_REQ,
      UR_PRS_RESPONSE =>UR_PRS_RESPONSE,
      USER_CLK2_DIV2 =>USER_CLK2_DIV2,
      USER_CLK_FREQ   => USER_CLK_FREQ ,
      USE_RID_PINS =>USE_RID_PINS,
      VC0_CPL_INFINITE=> VC0_CPL_INFINITE ,
      VC0_RX_RAM_LIMIT=> VC0_RX_RAM_LIMIT ,
      VC0_TOTAL_CREDITS_CD    => VC0_TOTAL_CREDITS_CD ,
      VC0_TOTAL_CREDITS_CH    => VC0_TOTAL_CREDITS_CH ,
      VC0_TOTAL_CREDITS_NPD =>VC0_TOTAL_CREDITS_NPD,
      VC0_TOTAL_CREDITS_NPH   => VC0_TOTAL_CREDITS_NPH ,
      VC0_TOTAL_CREDITS_PD    => VC0_TOTAL_CREDITS_PD ,
      VC0_TOTAL_CREDITS_PH    => VC0_TOTAL_CREDITS_PH ,
      VC0_TX_LASTPACKET => VC0_TX_LASTPACKET ,
      VC_BASE_PTR     => VC_BASE_PTR ,
      VC_CAP_ID => VC_CAP_ID ,
      VC_CAP_NEXTPTR  => VC_CAP_NEXTPTR ,
      VC_CAP_ON => VC_CAP_ON ,
      VC_CAP_REJECT_SNOOP_TRANSACTIONS=> VC_CAP_REJECT_SNOOP_TRANSACTIONS ,
      VC_CAP_VERSION  => VC_CAP_VERSION ,
      VSEC_BASE_PTR   => VSEC_BASE_PTR ,
      VSEC_CAP_HDR_ID => VSEC_CAP_HDR_ID ,
      VSEC_CAP_HDR_LENGTH     => VSEC_CAP_HDR_LENGTH ,
      VSEC_CAP_HDR_REVISION   => VSEC_CAP_HDR_REVISION ,
      VSEC_CAP_ID     => VSEC_CAP_ID ,
      VSEC_CAP_IS_LINK_VISIBLE=> VSEC_CAP_IS_LINK_VISIBLE ,
      VSEC_CAP_NEXTPTR=> VSEC_CAP_NEXTPTR ,
      VSEC_CAP_ON     => VSEC_CAP_ON ,
      VSEC_CAP_VERSION=> VSEC_CAP_VERSION
    )
    port map (
      trn_lnk_up                                => trn_lnk_up ,
      trn_clk                                   => user_clk_out_int ,
      lnk_clk_en                                => lnk_clk_en,
      user_rst_n                                => user_rst_n ,
      received_func_lvl_rst_n                   => cfg_received_func_lvl_rst_n ,
      sys_rst_n                                 => phy_rdy,
      pl_rst_n                                  => '1' ,
      dl_rst_n                                  => '1' ,
      tl_rst_n                                  => '1' ,
      cm_sticky_rst_n                           => '1' ,

      func_lvl_rst_n                            => func_lvl_rst_n ,
      cm_rst_n                                  => cm_rst_n ,
      trn_rbar_hit                              => trn_rbar_hit ,
      trn_rd                                    => trn_rd ,
      trn_recrc_err                             => trn_recrc_err ,
      trn_reof                                  => trn_reof ,
      trn_rerrfwd                               => trn_rerrfwd ,
      trn_rrem                                  => trn_rrem ,
      trn_rsof                                  => trn_rsof ,
      trn_rsrc_dsc                              => trn_rsrc_dsc ,
      trn_rsrc_rdy                              => trn_rsrc_rdy ,
      trn_rdst_rdy                              => trn_rdst_rdy ,
      trn_rnp_ok                                => rx_np_ok ,
      trn_rnp_req                               => rx_np_req ,
      trn_rfcp_ret                              => '1' ,
      trn_tbuf_av                               => tx_buf_av_int ,
      trn_tcfg_req                              => tx_cfg_req_int ,
      trn_tdllp_dst_rdy                         => open ,
      trn_tdst_rdy                              => trn_tdst_rdy ,
      trn_terr_drop                             => tx_err_drop ,
      trn_tcfg_gnt                              => trn_tcfg_gnt ,
      trn_td                                    => trn_td ,
      trn_tdllp_data                            => x"00000000" ,
      trn_tdllp_src_rdy                         => '0' ,
      trn_tecrc_gen                             => trn_tecrc_gen ,
      trn_teof                                  => trn_teof ,
      trn_terrfwd                               => trn_terrfwd ,
      trn_trem                                  => trn_trem,
      trn_tsof                                  => trn_tsof ,
      trn_tsrc_dsc                              => trn_tsrc_dsc ,
      trn_tsrc_rdy                              => trn_tsrc_rdy ,
      trn_tstr                                  => trn_tstr ,

      trn_fc_cpld                               => fc_cpld ,
      trn_fc_cplh                               => fc_cplh ,
      trn_fc_npd                                => fc_npd ,
      trn_fc_nph                                => fc_nph ,
      trn_fc_pd                                 => fc_pd ,
      trn_fc_ph                                 => fc_ph ,
      trn_fc_sel                                => fc_sel ,

      cfg_dev_id                                => cfg_dev_id,
      cfg_vend_id                               => cfg_vend_id,
      cfg_rev_id                                => cfg_rev_id,
      cfg_subsys_id                             => cfg_subsys_id,
      cfg_subsys_vend_id                        => cfg_subsys_vend_id,
      cfg_pciecap_interrupt_msgnum              => cfg_pciecap_interrupt_msgnum,

      cfg_bridge_serr_en                        => cfg_bridge_serr_en,

      cfg_command_bus_master_enable             => cfg_command_bus_master_enable_int ,
      cfg_command_interrupt_disable             => cfg_command_interrupt_disable_int ,
      cfg_command_io_enable                     => cfg_command_io_enable_int ,
      cfg_command_mem_enable                    => cfg_command_mem_enable_int ,
      cfg_command_serr_en                       => cfg_command_serr_en_int ,
      cfg_dev_control_aux_power_en              => cfg_dev_control_aux_power_en_int ,
      cfg_dev_control_corr_err_reporting_en     => cfg_dev_control_corr_err_reporting_en_int ,
      cfg_dev_control_enable_ro                 => cfg_dev_control_enable_ro_int ,
      cfg_dev_control_ext_tag_en                => cfg_dev_control_ext_tag_en_int ,
      cfg_dev_control_fatal_err_reporting_en    => cfg_dev_control_fatal_err_reporting_en_int ,
      cfg_dev_control_max_payload               => cfg_dev_control_max_payload_int ,
      cfg_dev_control_max_read_req              => cfg_dev_control_max_read_req_int ,
      cfg_dev_control_non_fatal_reporting_en    => cfg_dev_control_non_fatal_reporting_en_int ,
      cfg_dev_control_no_snoop_en               => cfg_dev_control_no_snoop_en_int ,
      cfg_dev_control_phantom_en                => cfg_dev_control_phantom_en_int ,
      cfg_dev_control_ur_err_reporting_en       => cfg_dev_control_ur_err_reporting_en_int ,
      cfg_dev_control2_cpl_timeout_dis          => cfg_dev_control2_cpl_timeout_dis_int ,
      cfg_dev_control2_cpl_timeout_val          => cfg_dev_control2_cpl_timeout_val_int ,
      cfg_dev_control2_ari_forward_en           => cfg_dev_control2_ari_forward_en_int,
      cfg_dev_control2_atomic_requester_en      => cfg_dev_control2_atomic_requester_en_int,
      cfg_dev_control2_atomic_egress_block      => cfg_dev_control2_atomic_egress_block_int,
      cfg_dev_control2_ido_req_en               => cfg_dev_control2_ido_req_en_int,
      cfg_dev_control2_ido_cpl_en               => cfg_dev_control2_ido_cpl_en_int,
      cfg_dev_control2_ltr_en                   => cfg_dev_control2_ltr_en_int,
      cfg_dev_control2_tlp_prefix_block         => cfg_dev_control2_tlp_prefix_block_int,
      cfg_dev_status_corr_err_detected          => cfg_dev_status_corr_err_detected_int ,
      cfg_dev_status_fatal_err_detected         => cfg_dev_status_fatal_err_detected_int ,
      cfg_dev_status_non_fatal_err_detected     => cfg_dev_status_non_fatal_err_detected_int ,
      cfg_dev_status_ur_detected                => cfg_dev_status_ur_detected_int ,

      cfg_mgmt_do                               => cfg_mgmt_do ,
      cfg_err_aer_headerlog_set_n               => cfg_err_aer_headerlog_set_n,
      cfg_err_aer_headerlog                     => cfg_err_aer_headerlog,
      cfg_err_cpl_rdy_n                         => cfg_err_cpl_rdy_n ,
      cfg_interrupt_do                          => cfg_interrupt_do ,
      cfg_interrupt_mmenable                    => cfg_interrupt_mmenable ,
      cfg_interrupt_msienable                   => cfg_interrupt_msienable ,
      cfg_interrupt_msixenable                  => cfg_interrupt_msixenable ,
      cfg_interrupt_msixfm                      => cfg_interrupt_msixfm ,
      cfg_interrupt_rdy_n                       => cfg_interrupt_rdy_n ,
      cfg_link_control_rcb                      => cfg_link_control_rcb_int ,
      cfg_link_control_aspm_control             => cfg_link_control_aspm_control_int ,
      cfg_link_control_auto_bandwidth_int_en    => cfg_link_control_auto_bandwidth_int_en_int ,
      cfg_link_control_bandwidth_int_en         => cfg_link_control_bandwidth_int_en_int ,
      cfg_link_control_clock_pm_en              => cfg_link_control_clock_pm_en_int ,
      cfg_link_control_common_clock             => cfg_link_control_common_clock_int ,
      cfg_link_control_extended_sync            => cfg_link_control_extended_sync_int ,
      cfg_link_control_hw_auto_width_dis        => cfg_link_control_hw_auto_width_dis_int ,
      cfg_link_control_link_disable             => cfg_link_control_link_disable_int ,
      cfg_link_control_retrain_link             => cfg_link_control_retrain_link_int ,
      cfg_link_status_auto_bandwidth_status     => cfg_link_status_auto_bandwidth_status_int ,
      cfg_link_status_bandwidth_status          => cfg_link_status_bandwidth_status_int ,
      cfg_link_status_current_speed             => cfg_link_status_current_speed_int ,
      cfg_link_status_dll_active                => cfg_link_status_dll_active_int ,
      cfg_link_status_link_training             => cfg_link_status_link_training_int ,
      cfg_link_status_negotiated_width          => cfg_link_status_negotiated_width_int,
      cfg_msg_data                              => cfg_msg_data_int ,
      cfg_msg_received                          => cfg_msg_received_int ,
      cfg_msg_received_assert_int_a             => cfg_msg_received_assert_int_a,
      cfg_msg_received_assert_int_b             => cfg_msg_received_assert_int_b,
      cfg_msg_received_assert_int_c             => cfg_msg_received_assert_int_c,
      cfg_msg_received_assert_int_d             => cfg_msg_received_assert_int_d,
      cfg_msg_received_deassert_int_a           => cfg_msg_received_deassert_int_a,
      cfg_msg_received_deassert_int_b           => cfg_msg_received_deassert_int_b,
      cfg_msg_received_deassert_int_c           => cfg_msg_received_deassert_int_c,
      cfg_msg_received_deassert_int_d           => cfg_msg_received_deassert_int_d,
      cfg_msg_received_err_cor                  => cfg_msg_received_err_cor,
      cfg_msg_received_err_fatal                => cfg_msg_received_err_fatal,
      cfg_msg_received_err_non_fatal            => cfg_msg_received_err_non_fatal,
      cfg_msg_received_pm_as_nak                => cfg_msg_received_pm_as_nak,
      cfg_msg_received_pme_to                   => cfg_msg_received_pme_to_int ,
      cfg_msg_received_pme_to_ack               => cfg_msg_received_pme_to_ack,
      cfg_msg_received_pm_pme                   => cfg_msg_received_pm_pme,
      cfg_msg_received_setslotpowerlimit        => cfg_msg_received_setslotpowerlimit,
      cfg_msg_received_unlock                   => cfg_msg_received_unlock,
      cfg_pcie_link_state                       => cfg_pcie_link_state_int ,
      cfg_pmcsr_pme_en                          => cfg_pmcsr_pme_en,
      cfg_pmcsr_powerstate                      => cfg_pmcsr_powerstate_int,
      cfg_pmcsr_pme_status                      => cfg_pmcsr_pme_status,
      cfg_pm_rcv_as_req_l1_n                    => cfg_pm_rcv_as_req_l1_n,
      cfg_pm_rcv_enter_l1_n                     => cfg_pm_rcv_enter_l1_n,
      cfg_pm_rcv_enter_l23_n                    => cfg_pm_rcv_enter_l23_n,

      cfg_pm_rcv_req_ack_n                      => cfg_pm_rcv_req_ack_n,
      cfg_mgmt_rd_wr_done_n                     => cfg_mgmt_rd_wr_done_n ,
      cfg_slot_control_electromech_il_ctl_pulse =>cfg_slot_control_electromech_il_ctl_pulse,
      cfg_root_control_syserr_corr_err_en       => cfg_root_control_syserr_corr_err_en,
      cfg_root_control_syserr_non_fatal_err_en  => cfg_root_control_syserr_non_fatal_err_en,
      cfg_root_control_syserr_fatal_err_en      => cfg_root_control_syserr_fatal_err_en,
      cfg_root_control_pme_int_en               => cfg_root_control_pme_int_en   ,
      cfg_aer_ecrc_check_en                     => cfg_aer_ecrc_check_en ,
      cfg_aer_ecrc_gen_en                       => cfg_aer_ecrc_gen_en ,
      cfg_aer_rooterr_corr_err_reporting_en     => cfg_aer_rooterr_corr_err_reporting_en,
      cfg_aer_rooterr_non_fatal_err_reporting_en=> cfg_aer_rooterr_non_fatal_err_reporting_en,
      cfg_aer_rooterr_fatal_err_reporting_en    => cfg_aer_rooterr_fatal_err_reporting_en,
      cfg_aer_rooterr_corr_err_received         => cfg_aer_rooterr_corr_err_received,
      cfg_aer_rooterr_non_fatal_err_received    => cfg_aer_rooterr_non_fatal_err_received,
      cfg_aer_rooterr_fatal_err_received        => cfg_aer_rooterr_fatal_err_received,
      cfg_aer_interrupt_msgnum                  => cfg_aer_interrupt_msgnum      ,
      cfg_transaction                           => cfg_transaction,
      cfg_transaction_addr                      => cfg_transaction_addr,
      cfg_transaction_type                      => cfg_transaction_type,
      cfg_vc_tcvc_map                           => cfg_vc_tcvc_map,
      cfg_mgmt_byte_en_n                        => cfg_mgmt_byte_en_n ,
      cfg_mgmt_di                               => cfg_mgmt_di ,
      cfg_ds_bus_number                         => cfg_ds_bus_number ,
      cfg_ds_device_number                      => cfg_ds_device_number ,
      cfg_ds_function_number                    => cfg_ds_function_number ,
      cfg_dsn                                   => cfg_dsn ,
      cfg_mgmt_dwaddr                           => cfg_mgmt_dwaddr ,
      cfg_err_acs_n                             => '1' ,
      cfg_err_cor_n                             => cfg_err_cor_n ,
      cfg_err_cpl_abort_n                       => cfg_err_cpl_abort_n ,
      cfg_err_cpl_timeout_n                     => cfg_err_cpl_timeout_n ,
      cfg_err_cpl_unexpect_n                    => cfg_err_cpl_unexpect_n ,
      cfg_err_ecrc_n                            => cfg_err_ecrc_n ,
      cfg_err_locked_n                          => cfg_err_locked_n ,
      cfg_err_posted_n                          => cfg_err_posted_n ,
      cfg_err_tlp_cpl_header                    => cfg_err_tlp_cpl_header ,
      cfg_err_ur_n                              => cfg_err_ur_n ,
      cfg_err_malformed_n                       => cfg_err_malformed_n ,
      cfg_err_poisoned_n                        => cfg_err_poisoned_n,
      cfg_err_atomic_egress_blocked_n           => cfg_err_atomic_egress_blocked_n ,
      cfg_err_mc_blocked_n                      => cfg_err_mc_blocked_n  ,
      cfg_err_internal_uncor_n                  => cfg_err_internal_uncor_n      ,
      cfg_err_internal_cor_n                    => cfg_err_internal_cor_n ,
      cfg_err_norecovery_n                      => cfg_err_norecovery_n  ,

      cfg_interrupt_assert_n                    => cfg_interrupt_assert_n ,
      cfg_interrupt_di                          => cfg_interrupt_di ,
      cfg_interrupt_n                           => cfg_interrupt_n ,
      cfg_interrupt_stat_n                      => cfg_interrupt_stat_n,
      cfg_pm_send_pme_to_n                      => cfg_pm_send_pme_to_n ,
      cfg_pm_turnoff_ok_n                       => cfg_turnoff_ok_int_n ,
      cfg_pm_wake_n                             => cfg_pm_wake_n ,
      cfg_pm_halt_aspm_l0s_n                    => cfg_pm_halt_aspm_l0s_n ,
      cfg_pm_halt_aspm_l1_n                     => cfg_pm_halt_aspm_l1_n ,
      cfg_pm_force_state_en_n                   => cfg_pm_force_state_en_n ,
      cfg_pm_force_state                        => cfg_pm_force_state ,
      cfg_force_mps                             => cfg_force_mps ,
      cfg_force_common_clock_off                => cfg_force_common_clock_off ,
      cfg_force_extended_sync_on                => cfg_force_extended_sync_on ,
      cfg_port_number                           => cfg_port_number ,
      cfg_mgmt_rd_en_n                          => cfg_mgmt_rd_en_n ,
      cfg_trn_pending_n                         => cfg_trn_pending_n ,
      cfg_mgmt_wr_en_n                          => cfg_mgmt_wr_en_n ,
      cfg_mgmt_wr_readonly_n                    => cfg_mgmt_wr_readonly_n ,
      cfg_mgmt_wr_rw1c_as_rw_n                  => cfg_mgmt_wr_rw1c_as_rw_n ,

      pl_initial_link_width                     => pl_initial_link_width ,
      pl_lane_reversal_mode                     => pl_lane_reversal_mode ,
      pl_link_gen2_cap                          => pl_link_gen2_cap ,
      pl_link_partner_gen2_supported            => pl_link_partner_gen2_supported ,
      pl_link_upcfg_cap                         => pl_link_upcfg_cap ,
      pl_ltssm_state                            => pl_ltssm_state_int ,
      pl_phy_lnk_up_n                           => pl_phy_lnk_up_n ,
      pl_received_hot_rst                       => pl_received_hot_rst ,
      pl_rx_pm_state                            => pl_rx_pm_state ,
      pl_sel_lnk_rate                           => pl_sel_lnk_rate,
      pl_sel_lnk_width                          => pl_sel_lnk_width ,
      pl_tx_pm_state                            => pl_tx_pm_state ,
      pl_directed_link_auton                    => pl_directed_link_auton ,
      pl_directed_link_change                   => pl_directed_link_change ,
      pl_directed_link_speed                    => pl_directed_link_speed ,
      pl_directed_link_width                    => pl_directed_link_width ,
      pl_downstream_deemph_source               => pl_downstream_deemph_source ,
      pl_upstream_prefer_deemph                 => pl_upstream_prefer_deemph ,
      pl_transmit_hot_rst                       => pl_transmit_hot_rst ,
      pl_directed_ltssm_new_vld                 => pl_directed_ltssm_new_vld ,
      pl_directed_ltssm_new                     => pl_directed_ltssm_new ,
      pl_directed_ltssm_stall                   => pl_directed_ltssm_stall ,
      pl_directed_change_done                   => pl_directed_change_done ,

      dbg_sclr_a                                => dbg_sclr_a ,
      dbg_sclr_b                                => dbg_sclr_b ,
      dbg_sclr_c                                => dbg_sclr_c ,
      dbg_sclr_d                                => dbg_sclr_d ,
      dbg_sclr_e                                => dbg_sclr_e ,
      dbg_sclr_f                                => dbg_sclr_f ,
      dbg_sclr_g                                => dbg_sclr_g ,
      dbg_sclr_h                                => dbg_sclr_h ,
      dbg_sclr_i                                => dbg_sclr_i ,
      dbg_sclr_j                                => dbg_sclr_j ,
      dbg_sclr_k                                => dbg_sclr_k ,

      dbg_vec_a                                 => dbg_vec_a ,
      dbg_vec_b                                 => dbg_vec_b ,
      dbg_vec_c                                 => dbg_vec_c ,
      pl_dbg_vec                                => pl_dbg_vec ,
      dbg_mode                                  => dbg_mode ,
      dbg_sub_mode                              => dbg_sub_mode ,
      pl_dbg_mode                               => pl_dbg_mode ,

      drp_clk                                   => drp_clk ,
      drp_addr                                  => drp_addr ,
      drp_en                                    => drp_en ,
      drp_di                                    => drp_di ,
      drp_we                                    => drp_we ,
      drp_do                                    => drp_do ,
      drp_rdy                                   => drp_rdy ,

      ll2_tlp_rcv                               => '0' ,
      ll2_send_enter_l1                         => '0' ,
      ll2_send_enter_l23                        => '0' ,
      ll2_send_as_req_l1                        => '0' ,
      ll2_send_pm_ack                           => '0' ,
      ll2_suspend_now                           => '0' ,
      ll2_tfc_init1_seq                         => open ,
      ll2_tfc_init2_seq                         => open ,
      ll2_suspend_ok                            => open ,
      ll2_tx_idle                               => open ,
      ll2_link_status                           => open ,
      ll2_receiver_err                          => open ,
      ll2_protocol_err                          => open ,
      ll2_bad_tlp_err                           => open ,
      ll2_bad_dllp_err                          => open ,
      ll2_replay_ro_err                         => open ,
      ll2_replay_to_err                         => open ,
      tl2_ppm_suspend_req                       => '0' ,
      tl2_aspm_suspend_credit_check             => '0' ,
      tl2_ppm_suspend_ok                        => open ,
      tl2_aspm_suspend_req                      => open ,
      tl2_aspm_suspend_credit_check_ok          => open ,
      tl2_err_hdr                               => open ,
      tl2_err_malformed                         => open ,
      tl2_err_rxoverflow                        => open ,
      tl2_err_fcpe                              => open ,
      pl2_directed_lstate                       => "00000" ,
      pl2_suspend_ok                            => open ,
      pl2_recovery                              => open ,
      pl2_rx_elec_idle                          => open ,
      pl2_rx_pm_state                           => open ,
      pl2_l0_req                                => open ,
      pl2_link_up                               => open ,
      pl2_receiver_err                          => open ,

      trn_rdllp_data                            =>trn_rdllp_data ,
      trn_rdllp_src_rdy                         =>trn_rdllp_src_rdy ,

      pipe_clk                                  => pipe_clk ,
      user_clk2                                 => user_clk2 ,
      user_clk                                  => user_clk ,
      user_clk_prebuf                           => '0' ,
      user_clk_prebuf_en                        => '0' ,

      pipe_rx0_polarity                         => pipe_rx0_polarity ,
      pipe_rx1_polarity                         => pipe_rx1_polarity ,
      pipe_rx2_polarity                         => pipe_rx2_polarity ,
      pipe_rx3_polarity                         => pipe_rx3_polarity ,
      pipe_rx4_polarity                         => pipe_rx4_polarity ,
      pipe_rx5_polarity                         => pipe_rx5_polarity ,
      pipe_rx6_polarity                         => pipe_rx6_polarity ,
      pipe_rx7_polarity                         => pipe_rx7_polarity ,
      pipe_tx0_compliance                       => pipe_tx0_compliance ,
      pipe_tx1_compliance                       => pipe_tx1_compliance ,
      pipe_tx2_compliance                       => pipe_tx2_compliance ,
      pipe_tx3_compliance                       => pipe_tx3_compliance ,
      pipe_tx4_compliance                       => pipe_tx4_compliance ,
      pipe_tx5_compliance                       => pipe_tx5_compliance ,
      pipe_tx6_compliance                       => pipe_tx6_compliance ,
      pipe_tx7_compliance                       => pipe_tx7_compliance ,
      pipe_tx0_char_is_k                        => pipe_tx0_char_is_k ,
      pipe_tx1_char_is_k                        => pipe_tx1_char_is_k ,
      pipe_tx2_char_is_k                        => pipe_tx2_char_is_k ,
      pipe_tx3_char_is_k                        => pipe_tx3_char_is_k ,
      pipe_tx4_char_is_k                        => pipe_tx4_char_is_k ,
      pipe_tx5_char_is_k                        => pipe_tx5_char_is_k ,
      pipe_tx6_char_is_k                        => pipe_tx6_char_is_k ,
      pipe_tx7_char_is_k                        => pipe_tx7_char_is_k ,
      pipe_tx0_data                             => pipe_tx0_data ,
      pipe_tx1_data                             => pipe_tx1_data ,
      pipe_tx2_data                             => pipe_tx2_data ,
      pipe_tx3_data                             => pipe_tx3_data ,
      pipe_tx4_data                             => pipe_tx4_data ,
      pipe_tx5_data                             => pipe_tx5_data ,
      pipe_tx6_data                             => pipe_tx6_data ,
      pipe_tx7_data                             => pipe_tx7_data ,
      pipe_tx0_elec_idle                        => pipe_tx0_elec_idle ,
      pipe_tx1_elec_idle                        => pipe_tx1_elec_idle ,
      pipe_tx2_elec_idle                        => pipe_tx2_elec_idle ,
      pipe_tx3_elec_idle                        => pipe_tx3_elec_idle ,
      pipe_tx4_elec_idle                        => pipe_tx4_elec_idle ,
      pipe_tx5_elec_idle                        => pipe_tx5_elec_idle ,
      pipe_tx6_elec_idle                        => pipe_tx6_elec_idle ,
      pipe_tx7_elec_idle                        => pipe_tx7_elec_idle ,
      pipe_tx0_powerdown                        => pipe_tx0_powerdown ,
      pipe_tx1_powerdown                        => pipe_tx1_powerdown ,
      pipe_tx2_powerdown                        => pipe_tx2_powerdown ,
      pipe_tx3_powerdown                        => pipe_tx3_powerdown ,
      pipe_tx4_powerdown                        => pipe_tx4_powerdown ,
      pipe_tx5_powerdown                        => pipe_tx5_powerdown ,
      pipe_tx6_powerdown                        => pipe_tx6_powerdown ,
      pipe_tx7_powerdown                        => pipe_tx7_powerdown ,

      pipe_rx0_char_is_k                        => pipe_rx0_char_is_k ,
      pipe_rx1_char_is_k                        => pipe_rx1_char_is_k ,
      pipe_rx2_char_is_k                        => pipe_rx2_char_is_k ,
      pipe_rx3_char_is_k                        => pipe_rx3_char_is_k ,
      pipe_rx4_char_is_k                        => pipe_rx4_char_is_k ,
      pipe_rx5_char_is_k                        => pipe_rx5_char_is_k ,
      pipe_rx6_char_is_k                        => pipe_rx6_char_is_k ,
      pipe_rx7_char_is_k                        => pipe_rx7_char_is_k ,
      pipe_rx0_valid                            => pipe_rx0_valid ,
      pipe_rx1_valid                            => pipe_rx1_valid ,
      pipe_rx2_valid                            => pipe_rx2_valid ,
      pipe_rx3_valid                            => pipe_rx3_valid ,
      pipe_rx4_valid                            => pipe_rx4_valid ,
      pipe_rx5_valid                            => pipe_rx5_valid ,
      pipe_rx6_valid                            => pipe_rx6_valid ,
      pipe_rx7_valid                            => pipe_rx7_valid ,
      pipe_rx0_data                             => pipe_rx0_data ,
      pipe_rx1_data                             => pipe_rx1_data ,
      pipe_rx2_data                             => pipe_rx2_data ,
      pipe_rx3_data                             => pipe_rx3_data ,
      pipe_rx4_data                             => pipe_rx4_data ,
      pipe_rx5_data                             => pipe_rx5_data ,
      pipe_rx6_data                             => pipe_rx6_data ,
      pipe_rx7_data                             => pipe_rx7_data ,
      pipe_rx0_chanisaligned                    => pipe_rx0_chanisaligned ,
      pipe_rx1_chanisaligned                    => pipe_rx1_chanisaligned ,
      pipe_rx2_chanisaligned                    => pipe_rx2_chanisaligned ,
      pipe_rx3_chanisaligned                    => pipe_rx3_chanisaligned ,
      pipe_rx4_chanisaligned                    => pipe_rx4_chanisaligned ,
      pipe_rx5_chanisaligned                    => pipe_rx5_chanisaligned ,
      pipe_rx6_chanisaligned                    => pipe_rx6_chanisaligned ,
      pipe_rx7_chanisaligned                    => pipe_rx7_chanisaligned ,
      pipe_rx0_status                           => pipe_rx0_status ,
      pipe_rx1_status                           => pipe_rx1_status ,
      pipe_rx2_status                           => pipe_rx2_status ,
      pipe_rx3_status                           => pipe_rx3_status ,
      pipe_rx4_status                           => pipe_rx4_status ,
      pipe_rx5_status                           => pipe_rx5_status ,
      pipe_rx6_status                           => pipe_rx6_status ,
      pipe_rx7_status                           => pipe_rx7_status ,
      pipe_rx0_phy_status                       => pipe_rx0_phy_status ,
      pipe_rx1_phy_status                       => pipe_rx1_phy_status ,
      pipe_rx2_phy_status                       => pipe_rx2_phy_status ,
      pipe_rx3_phy_status                       => pipe_rx3_phy_status ,
      pipe_rx4_phy_status                       => pipe_rx4_phy_status ,
      pipe_rx5_phy_status                       => pipe_rx5_phy_status ,
      pipe_rx6_phy_status                       => pipe_rx6_phy_status ,
      pipe_rx7_phy_status                       => pipe_rx7_phy_status ,
      pipe_tx_deemph                            => pipe_tx_deemph ,
      pipe_tx_margin                            => pipe_tx_margin ,
      pipe_tx_reset                             => pipe_tx_reset ,
      pipe_tx_rcvr_det                          => pipe_tx_rcvr_det ,
      pipe_tx_rate                              => pipe_tx_rate ,

      pipe_rx0_elec_idle                        => pipe_rx0_elec_idle ,
      pipe_rx1_elec_idle                        => pipe_rx1_elec_idle ,
      pipe_rx2_elec_idle                        => pipe_rx2_elec_idle ,
      pipe_rx3_elec_idle                        => pipe_rx3_elec_idle ,
      pipe_rx4_elec_idle                        => pipe_rx4_elec_idle ,
      pipe_rx5_elec_idle                        => pipe_rx5_elec_idle ,
      pipe_rx6_elec_idle                        => pipe_rx6_elec_idle ,
      pipe_rx7_elec_idle                        => pipe_rx7_elec_idle,

      scanmode_n                                => '1',
      scanenable_n                              => '1',
      edt_clk                                   => '0',
      edt_bypass                                => '0',
      edt_update                                => '0',
      edt_configuration                         => '0',
      edt_single_bypass_chain                   => '0',
      edt_channels_in1                          => '0',
      edt_channels_in2                          => '0',
      edt_channels_in3                          => '0',
      edt_channels_in4                          => '0',
      edt_channels_in5                          => '0',
      edt_channels_in6                          => '0',
      edt_channels_in7                          => '0',
      edt_channels_in8                          => '0',
      pmv_enable_n                              => '0',
      pmv_select                                => "000",
      pmv_divide                                => "00",
      cfg_reset                                 => '0',
      gwe                                       => '0',
      grestore                                  => '0',
      ghigh                                     => '0'
    );

  ----------------------------------------------------------------------------------------------------------------------
  -- PIPE Interface PIPELINE Module                                                                                   --
  ----------------------------------------------------------------------------------------------------------------------
  pcie_pipe_pipeline_i : cl_a7pcie_x4_pcie_pipe_pipeline
    generic map (
      LINK_CAP_MAX_LINK_WIDTH_int => LINK_CAP_MAX_LINK_WIDTH_int ,
      PIPE_PIPELINE_STAGES        => PIPE_PIPELINE_STAGES
    )
    port map (

      -- Pipe Per-Link Signals
      pipe_tx_rcvr_det_i       => pipe_tx_rcvr_det,
      pipe_tx_reset_i          => '0',
      pipe_tx_rate_i           => pipe_tx_rate,
      pipe_tx_deemph_i         => pipe_tx_deemph,
      pipe_tx_margin_i         => pipe_tx_margin,
      pipe_tx_swing_i          => '0',

      pipe_tx_rcvr_det_o       => pipe_tx_rcvr_det_gt,
      pipe_tx_reset_o          => open ,
      pipe_tx_rate_o           => pipe_tx_rate_gt,
      pipe_tx_deemph_o         => pipe_tx_deemph_gt,
      pipe_tx_margin_o         => pipe_tx_margin_gt,
      pipe_tx_swing_o          => open ,

      -- Pipe Per-Lane Signals - Lane 0

      pipe_rx0_char_is_k_o     => pipe_rx0_char_is_k     ,
      pipe_rx0_data_o          => pipe_rx0_data          ,
      pipe_rx0_valid_o         => pipe_rx0_valid         ,
      pipe_rx0_chanisaligned_o => pipe_rx0_chanisaligned ,
      pipe_rx0_status_o        => pipe_rx0_status        ,
      pipe_rx0_phy_status_o    => pipe_rx0_phy_status    ,
      pipe_rx0_elec_idle_i     => pipe_rx0_elec_idle_gt  ,
      pipe_rx0_polarity_i      => pipe_rx0_polarity      ,
      pipe_tx0_compliance_i    => pipe_tx0_compliance    ,
      pipe_tx0_char_is_k_i     => pipe_tx0_char_is_k     ,
      pipe_tx0_data_i          => pipe_tx0_data          ,
      pipe_tx0_elec_idle_i     => pipe_tx0_elec_idle     ,
      pipe_tx0_powerdown_i     => pipe_tx0_powerdown     ,

      pipe_rx0_char_is_k_i     => pipe_rx0_char_is_k_gt  ,
      pipe_rx0_data_i          => pipe_rx0_data_gt       ,
      pipe_rx0_valid_i         => pipe_rx0_valid_gt      ,
      pipe_rx0_chanisaligned_i => pipe_rx0_chanisaligned_gt,
      pipe_rx0_status_i        => pipe_rx0_status_gt     ,
      pipe_rx0_phy_status_i    => pipe_rx0_phy_status_gt ,
      pipe_rx0_elec_idle_o     => pipe_rx0_elec_idle     ,
      pipe_rx0_polarity_o      => pipe_rx0_polarity_gt   ,
      pipe_tx0_compliance_o    => pipe_tx0_compliance_gt ,
      pipe_tx0_char_is_k_o     => pipe_tx0_char_is_k_gt  ,
      pipe_tx0_data_o          => pipe_tx0_data_gt       ,
      pipe_tx0_elec_idle_o     => pipe_tx0_elec_idle_gt  ,
      pipe_tx0_powerdown_o     => pipe_tx0_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 1

      pipe_rx1_char_is_k_o     => pipe_rx1_char_is_k     ,
      pipe_rx1_data_o          => pipe_rx1_data          ,
      pipe_rx1_valid_o         => pipe_rx1_valid         ,
      pipe_rx1_chanisaligned_o => pipe_rx1_chanisaligned ,
      pipe_rx1_status_o        => pipe_rx1_status        ,
      pipe_rx1_phy_status_o    => pipe_rx1_phy_status    ,
      pipe_rx1_elec_idle_i     => pipe_rx1_elec_idle_gt  ,
      pipe_rx1_polarity_i      => pipe_rx1_polarity      ,
      pipe_tx1_compliance_i    => pipe_tx1_compliance    ,
      pipe_tx1_char_is_k_i     => pipe_tx1_char_is_k     ,
      pipe_tx1_data_i          => pipe_tx1_data          ,
      pipe_tx1_elec_idle_i     => pipe_tx1_elec_idle     ,
      pipe_tx1_powerdown_i     => pipe_tx1_powerdown     ,

      pipe_rx1_char_is_k_i     => pipe_rx1_char_is_k_gt  ,
      pipe_rx1_data_i          => pipe_rx1_data_gt       ,
      pipe_rx1_valid_i         => pipe_rx1_valid_gt      ,
      pipe_rx1_chanisaligned_i => pipe_rx1_chanisaligned_gt,
      pipe_rx1_status_i        => pipe_rx1_status_gt     ,
      pipe_rx1_phy_status_i    => pipe_rx1_phy_status_gt ,
      pipe_rx1_elec_idle_o     => pipe_rx1_elec_idle     ,
      pipe_rx1_polarity_o      => pipe_rx1_polarity_gt   ,
      pipe_tx1_compliance_o    => pipe_tx1_compliance_gt ,
      pipe_tx1_char_is_k_o     => pipe_tx1_char_is_k_gt  ,
      pipe_tx1_data_o          => pipe_tx1_data_gt       ,
      pipe_tx1_elec_idle_o     => pipe_tx1_elec_idle_gt  ,
      pipe_tx1_powerdown_o     => pipe_tx1_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 2

      pipe_rx2_char_is_k_o     => pipe_rx2_char_is_k     ,
      pipe_rx2_data_o          => pipe_rx2_data          ,
      pipe_rx2_valid_o         => pipe_rx2_valid         ,
      pipe_rx2_chanisaligned_o => pipe_rx2_chanisaligned ,
      pipe_rx2_status_o        => pipe_rx2_status        ,
      pipe_rx2_phy_status_o    => pipe_rx2_phy_status    ,
      pipe_rx2_elec_idle_i     => pipe_rx2_elec_idle_gt  ,
      pipe_rx2_polarity_i      => pipe_rx2_polarity      ,
      pipe_tx2_compliance_i    => pipe_tx2_compliance    ,
      pipe_tx2_char_is_k_i     => pipe_tx2_char_is_k     ,
      pipe_tx2_data_i          => pipe_tx2_data          ,
      pipe_tx2_elec_idle_i     => pipe_tx2_elec_idle     ,
      pipe_tx2_powerdown_i     => pipe_tx2_powerdown     ,

      pipe_rx2_char_is_k_i     => pipe_rx2_char_is_k_gt  ,
      pipe_rx2_data_i          => pipe_rx2_data_gt       ,
      pipe_rx2_valid_i         => pipe_rx2_valid_gt      ,
      pipe_rx2_chanisaligned_i => pipe_rx2_chanisaligned_gt,
      pipe_rx2_status_i        => pipe_rx2_status_gt     ,
      pipe_rx2_phy_status_i    => pipe_rx2_phy_status_gt ,
      pipe_rx2_elec_idle_o     => pipe_rx2_elec_idle     ,
      pipe_rx2_polarity_o      => pipe_rx2_polarity_gt   ,
      pipe_tx2_compliance_o    => pipe_tx2_compliance_gt ,
      pipe_tx2_char_is_k_o     => pipe_tx2_char_is_k_gt  ,
      pipe_tx2_data_o          => pipe_tx2_data_gt       ,
      pipe_tx2_elec_idle_o     => pipe_tx2_elec_idle_gt  ,
      pipe_tx2_powerdown_o     => pipe_tx2_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 3

      pipe_rx3_char_is_k_o     => pipe_rx3_char_is_k     ,
      pipe_rx3_data_o          => pipe_rx3_data          ,
      pipe_rx3_valid_o         => pipe_rx3_valid         ,
      pipe_rx3_chanisaligned_o => pipe_rx3_chanisaligned ,
      pipe_rx3_status_o        => pipe_rx3_status        ,
      pipe_rx3_phy_status_o    => pipe_rx3_phy_status    ,
      pipe_rx3_elec_idle_i     => pipe_rx3_elec_idle_gt  ,
      pipe_rx3_polarity_i      => pipe_rx3_polarity      ,
      pipe_tx3_compliance_i    => pipe_tx3_compliance    ,
      pipe_tx3_char_is_k_i     => pipe_tx3_char_is_k     ,
      pipe_tx3_data_i          => pipe_tx3_data          ,
      pipe_tx3_elec_idle_i     => pipe_tx3_elec_idle     ,
      pipe_tx3_powerdown_i     => pipe_tx3_powerdown     ,

      pipe_rx3_char_is_k_i     => pipe_rx3_char_is_k_gt  ,
      pipe_rx3_data_i          => pipe_rx3_data_gt       ,
      pipe_rx3_valid_i         => pipe_rx3_valid_gt      ,
      pipe_rx3_chanisaligned_i => pipe_rx3_chanisaligned_gt,
      pipe_rx3_status_i        => pipe_rx3_status_gt     ,
      pipe_rx3_phy_status_i    => pipe_rx3_phy_status_gt ,
      pipe_rx3_elec_idle_o     => pipe_rx3_elec_idle     ,
      pipe_rx3_polarity_o      => pipe_rx3_polarity_gt   ,
      pipe_tx3_compliance_o    => pipe_tx3_compliance_gt ,
      pipe_tx3_char_is_k_o     => pipe_tx3_char_is_k_gt  ,
      pipe_tx3_data_o          => pipe_tx3_data_gt       ,
      pipe_tx3_elec_idle_o     => pipe_tx3_elec_idle_gt  ,
      pipe_tx3_powerdown_o     => pipe_tx3_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 4

      pipe_rx4_char_is_k_o     => pipe_rx4_char_is_k     ,
      pipe_rx4_data_o          => pipe_rx4_data          ,
      pipe_rx4_valid_o         => pipe_rx4_valid         ,
      pipe_rx4_chanisaligned_o => pipe_rx4_chanisaligned ,
      pipe_rx4_status_o        => pipe_rx4_status        ,
      pipe_rx4_phy_status_o    => pipe_rx4_phy_status    ,
      pipe_rx4_elec_idle_i     => pipe_rx4_elec_idle_gt  ,
      pipe_rx4_polarity_i      => pipe_rx4_polarity      ,
      pipe_tx4_compliance_i    => pipe_tx4_compliance    ,
      pipe_tx4_char_is_k_i     => pipe_tx4_char_is_k     ,
      pipe_tx4_data_i          => pipe_tx4_data          ,
      pipe_tx4_elec_idle_i     => pipe_tx4_elec_idle     ,
      pipe_tx4_powerdown_i     => pipe_tx4_powerdown     ,
      pipe_rx4_char_is_k_i     => pipe_rx4_char_is_k_gt  ,
      pipe_rx4_data_i          => pipe_rx4_data_gt       ,
      pipe_rx4_valid_i         => pipe_rx4_valid_gt      ,
      pipe_rx4_chanisaligned_i => pipe_rx4_chanisaligned_gt,
      pipe_rx4_status_i        => pipe_rx4_status_gt     ,
      pipe_rx4_phy_status_i    => pipe_rx4_phy_status_gt ,
      pipe_rx4_elec_idle_o     => pipe_rx4_elec_idle     ,
      pipe_rx4_polarity_o      => pipe_rx4_polarity_gt   ,
      pipe_tx4_compliance_o    => pipe_tx4_compliance_gt ,
      pipe_tx4_char_is_k_o     => pipe_tx4_char_is_k_gt  ,
      pipe_tx4_data_o          => pipe_tx4_data_gt       ,
      pipe_tx4_elec_idle_o     => pipe_tx4_elec_idle_gt  ,
      pipe_tx4_powerdown_o     => pipe_tx4_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 5

      pipe_rx5_char_is_k_o     => pipe_rx5_char_is_k     ,
      pipe_rx5_data_o          => pipe_rx5_data          ,
      pipe_rx5_valid_o         => pipe_rx5_valid         ,
      pipe_rx5_chanisaligned_o => pipe_rx5_chanisaligned ,
      pipe_rx5_status_o        => pipe_rx5_status        ,
      pipe_rx5_phy_status_o    => pipe_rx5_phy_status    ,
      pipe_rx5_elec_idle_i     => pipe_rx5_elec_idle_gt  ,
      pipe_rx5_polarity_i      => pipe_rx5_polarity      ,
      pipe_tx5_compliance_i    => pipe_tx5_compliance    ,
      pipe_tx5_char_is_k_i     => pipe_tx5_char_is_k     ,
      pipe_tx5_data_i          => pipe_tx5_data          ,
      pipe_tx5_elec_idle_i     => pipe_tx5_elec_idle     ,
      pipe_tx5_powerdown_i     => pipe_tx5_powerdown     ,
      pipe_rx5_char_is_k_i     => pipe_rx5_char_is_k_gt  ,
      pipe_rx5_data_i          => pipe_rx5_data_gt       ,
      pipe_rx5_valid_i         => pipe_rx5_valid_gt      ,
      pipe_rx5_chanisaligned_i => pipe_rx5_chanisaligned_gt,
      pipe_rx5_status_i        => pipe_rx5_status_gt     ,
      pipe_rx5_phy_status_i    => pipe_rx5_phy_status_gt ,
      pipe_rx5_elec_idle_o     => pipe_rx5_elec_idle     ,
      pipe_rx5_polarity_o      => pipe_rx5_polarity_gt   ,
      pipe_tx5_compliance_o    => pipe_tx5_compliance_gt ,
      pipe_tx5_char_is_k_o     => pipe_tx5_char_is_k_gt  ,
      pipe_tx5_data_o          => pipe_tx5_data_gt       ,
      pipe_tx5_elec_idle_o     => pipe_tx5_elec_idle_gt  ,
      pipe_tx5_powerdown_o     => pipe_tx5_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 6

      pipe_rx6_char_is_k_o     => pipe_rx6_char_is_k     ,
      pipe_rx6_data_o          => pipe_rx6_data          ,
      pipe_rx6_valid_o         => pipe_rx6_valid         ,
      pipe_rx6_chanisaligned_o => pipe_rx6_chanisaligned ,
      pipe_rx6_status_o        => pipe_rx6_status        ,
      pipe_rx6_phy_status_o    => pipe_rx6_phy_status    ,
      pipe_rx6_elec_idle_i     => pipe_rx6_elec_idle_gt  ,
      pipe_rx6_polarity_i      => pipe_rx6_polarity      ,
      pipe_tx6_compliance_i    => pipe_tx6_compliance    ,
      pipe_tx6_char_is_k_i     => pipe_tx6_char_is_k     ,
      pipe_tx6_data_i          => pipe_tx6_data          ,
      pipe_tx6_elec_idle_i     => pipe_tx6_elec_idle     ,
      pipe_tx6_powerdown_i     => pipe_tx6_powerdown     ,
      pipe_rx6_char_is_k_i     => pipe_rx6_char_is_k_gt  ,
      pipe_rx6_data_i          => pipe_rx6_data_gt       ,
      pipe_rx6_valid_i         => pipe_rx6_valid_gt      ,
      pipe_rx6_chanisaligned_i => pipe_rx6_chanisaligned_gt,
      pipe_rx6_status_i        => pipe_rx6_status_gt     ,
      pipe_rx6_phy_status_i    => pipe_rx6_phy_status_gt ,
      pipe_rx6_elec_idle_o     => pipe_rx6_elec_idle     ,
      pipe_rx6_polarity_o      => pipe_rx6_polarity_gt   ,
      pipe_tx6_compliance_o    => pipe_tx6_compliance_gt ,
      pipe_tx6_char_is_k_o     => pipe_tx6_char_is_k_gt  ,
      pipe_tx6_data_o          => pipe_tx6_data_gt       ,
      pipe_tx6_elec_idle_o     => pipe_tx6_elec_idle_gt  ,
      pipe_tx6_powerdown_o     => pipe_tx6_powerdown_gt  ,

      -- Pipe Per-Lane Signals - Lane 7

      pipe_rx7_char_is_k_o     => pipe_rx7_char_is_k     ,
      pipe_rx7_data_o          => pipe_rx7_data          ,
      pipe_rx7_valid_o         => pipe_rx7_valid         ,
      pipe_rx7_chanisaligned_o => pipe_rx7_chanisaligned ,
      pipe_rx7_status_o        => pipe_rx7_status        ,
      pipe_rx7_phy_status_o    => pipe_rx7_phy_status    ,
      pipe_rx7_elec_idle_i     => pipe_rx7_elec_idle_gt  ,
      pipe_rx7_polarity_i      => pipe_rx7_polarity      ,
      pipe_tx7_compliance_i    => pipe_tx7_compliance    ,
      pipe_tx7_char_is_k_i     => pipe_tx7_char_is_k     ,
      pipe_tx7_data_i          => pipe_tx7_data          ,
      pipe_tx7_elec_idle_i     => pipe_tx7_elec_idle     ,
      pipe_tx7_powerdown_i     => pipe_tx7_powerdown     ,
      pipe_rx7_char_is_k_i     => pipe_rx7_char_is_k_gt  ,
      pipe_rx7_data_i          => pipe_rx7_data_gt       ,
      pipe_rx7_valid_i         => pipe_rx7_valid_gt      ,
      pipe_rx7_chanisaligned_i => pipe_rx7_chanisaligned_gt,
      pipe_rx7_status_i        => pipe_rx7_status_gt     ,
      pipe_rx7_phy_status_i    => pipe_rx7_phy_status_gt ,
      pipe_rx7_elec_idle_o     => pipe_rx7_elec_idle     ,
      pipe_rx7_polarity_o      => pipe_rx7_polarity_gt   ,
      pipe_tx7_compliance_o    => pipe_tx7_compliance_gt ,
      pipe_tx7_char_is_k_o     => pipe_tx7_char_is_k_gt  ,
      pipe_tx7_data_o          => pipe_tx7_data_gt       ,
      pipe_tx7_elec_idle_o     => pipe_tx7_elec_idle_gt  ,
      pipe_tx7_powerdown_o     => pipe_tx7_powerdown_gt  ,

      -- Non PIPE signals
      pipe_clk                 => pipe_clk               ,
      rst_n                    => phy_rdy_n              ,
      pl_ltssm_state           => pl_ltssm_state_int
    );



end pcie_7x;

