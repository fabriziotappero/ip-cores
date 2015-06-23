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
-- File       : cl_a7pcie_x4_pcie_7x.vhd
-- Version    : 1.11
--
-- Description: Solution wrapper for Virtex7 Hard Block for PCI Express
--
--
--
----------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity cl_a7pcie_x4_pcie_7x is
  generic (
  C_DATA_WIDTH                                   : INTEGER range 32 to 128 := 64;
  C_REM_WIDTH                                      : INTEGER range 0 to 128  :=  1;
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
port(

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
  drp_rdy                                        : out std_logic := '0' ;
  drp_do                                         : out std_logic_vector(15 downto 0):= (others => '0');
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

end cl_a7pcie_x4_pcie_7x;

architecture rtl of cl_a7pcie_x4_pcie_7x is
  ---------------------------
  -- Component Declarations
  ---------------------------
  component cl_a7pcie_x4_pcie_bram_top_7x
  generic (
    LINK_CAP_MAX_LINK_SPEED       : integer;
    LINK_CAP_MAX_LINK_WIDTH       : integer;
    DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
    VC0_TX_LASTPACKET             : integer;
    TL_TX_RAM_RADDR_LATENCY       : integer;
    TL_TX_RAM_RDATA_LATENCY       : integer;
    TL_TX_RAM_WRITE_LATENCY       : integer;
    VC0_RX_RAM_LIMIT              : bit_vector;
    TL_RX_RAM_RADDR_LATENCY       : integer;
    TL_RX_RAM_RDATA_LATENCY       : integer;
    TL_RX_RAM_WRITE_LATENCY       : integer
  );
  port (
    user_clk_i                    : in  std_logic;
    reset_i                       : in  std_logic;

    mim_tx_waddr                  : in  std_logic_vector(12 downto 0);
    mim_tx_wen                    : in  std_logic;
    mim_tx_ren                    : in  std_logic;
    mim_tx_rce                    : in  std_logic;
    mim_tx_wdata                  : in  std_logic_vector(71 downto 0);
    mim_tx_raddr                  : in  std_logic_vector(12 downto 0);
    mim_tx_rdata                  : out std_logic_vector(71 downto 0);

    mim_rx_waddr                  : in  std_logic_vector(12 downto 0);
    mim_rx_wen                    : in  std_logic;
    mim_rx_ren                    : in  std_logic;
    mim_rx_rce                    : in  std_logic;
    mim_rx_wdata                  : in  std_logic_vector(71 downto 0);
    mim_rx_raddr                  : in  std_logic_vector(12 downto 0);
    mim_rx_rdata                  : out std_logic_vector(71 downto 0)
   );
  end component;

  --------------------------------------------------------------------------
  -- BRAM                                                                 --
  --------------------------------------------------------------------------

  -- transmit bram interface
  signal mim_tx_wen          : std_logic;
  signal mim_tx_waddr        : std_logic_vector(12 downto 0);
  signal mim_tx_wdata        : std_logic_vector(68 downto 0);
  signal mim_tx_wdata_int    : std_logic_vector(71 downto 0);
  signal mim_tx_ren          : std_logic;
  signal mim_tx_rce          : std_logic;
  signal mim_tx_raddr        : std_logic_vector(12 downto 0);
  signal mim_tx_rdata        : std_logic_vector(68 downto 0);
--  signal unused_mim_tx_rdata : std_logic_vector( 2 downto 0);
  signal mim_tx_rdata_int    : std_logic_vector(71 downto 0);


  -- receive bram interface
  signal mim_rx_wen          : std_logic;
  signal mim_rx_waddr        : std_logic_vector(12 downto 0);
  signal mim_rx_wdata        : std_logic_vector(67 downto 0);
  signal mim_rx_wdata_int    : std_logic_vector(71 downto 0);
  signal mim_rx_ren          : std_logic;
  signal mim_rx_rce          : std_logic;
  signal mim_rx_raddr        : std_logic_vector(12 downto 0);
  signal mim_rx_rdata        : std_logic_vector(67 downto 0);
 -- signal unused_mim_rx_rdata : std_logic_vector( 3 downto 0);
  signal mim_rx_rdata_int    : std_logic_vector(71 downto 0);

  signal trn_tdst_rdy_bus    : std_logic_vector( 3 downto 0);
  signal trn_rd_int          : std_logic_vector(127 downto 0);
  signal trn_rrem_int        : std_logic_vector(1 downto 0);
  signal trn_td_int          : std_logic_vector(127 downto 0);
  signal trn_trem_int        : std_logic_vector(1 downto 0);


  begin
  trn_rd <= trn_rd_int((C_DATA_WIDTH-1) downto 0);
  trn_rrem <= trn_rrem_int((C_REM_WIDTH- 1) downto 0);

  wire_scaling_128 : if (C_DATA_WIDTH = 128) generate
    trn_td_int   <= trn_td ;
    trn_trem_int <= trn_trem;
  end generate;

  wire_scaling_64 : if (C_DATA_WIDTH = 64) generate
    trn_td_int   <= (X"0000000000000000" & trn_td);
    trn_trem_int <= ('0' & trn_trem);
  end generate;


  -- Assignments to outputs
  trn_clk      <= user_clk2;
  trn_tdst_rdy <= trn_tdst_rdy_bus(0);

  mim_tx_wdata_int <= "000" & mim_tx_wdata;
  mim_tx_rce       <= '1';
  mim_tx_rdata     <= mim_tx_rdata_int(68 downto 0);
  mim_rx_wdata_int <= "0000" & mim_rx_wdata;
  mim_rx_rce       <= '1';
  mim_rx_rdata     <=  mim_rx_rdata_int(67 downto 0);

  pcie_bram_top : cl_a7pcie_x4_pcie_bram_top_7x
  generic map (
    LINK_CAP_MAX_LINK_SPEED       =>  LINK_CAP_MAX_LINK_SPEED_int,
    LINK_CAP_MAX_LINK_WIDTH       =>  LINK_CAP_MAX_LINK_WIDTH_int,
    DEV_CAP_MAX_PAYLOAD_SUPPORTED =>  DEV_CAP_MAX_PAYLOAD_SUPPORTED,
    VC0_TX_LASTPACKET             =>  VC0_TX_LASTPACKET,
    TL_TX_RAM_RADDR_LATENCY       =>  TL_TX_RAM_RADDR_LATENCY,
    TL_TX_RAM_RDATA_LATENCY       =>  TL_TX_RAM_RDATA_LATENCY,
    TL_TX_RAM_WRITE_LATENCY       =>  TL_TX_RAM_WRITE_LATENCY,
    VC0_RX_RAM_LIMIT              =>  VC0_RX_RAM_LIMIT,
    TL_RX_RAM_RADDR_LATENCY       =>  TL_RX_RAM_RADDR_LATENCY,
    TL_RX_RAM_RDATA_LATENCY       =>  TL_RX_RAM_RDATA_LATENCY,
    TL_RX_RAM_WRITE_LATENCY       =>  TL_RX_RAM_WRITE_LATENCY
  )
  port map (
    user_clk_i                    => user_clk,
    reset_i                       => '0',

    mim_tx_waddr                  => mim_tx_waddr,
    mim_tx_wen                    => mim_tx_wen,
    mim_tx_ren                    => mim_tx_ren,
    mim_tx_rce                    => mim_tx_rce,
    mim_tx_wdata                  => mim_tx_wdata_int,
    mim_tx_raddr                  => mim_tx_raddr,
    mim_tx_rdata                  => mim_tx_rdata_int,

    mim_rx_waddr                  => mim_rx_waddr,
    mim_rx_wen                    => mim_rx_wen,
    mim_rx_ren                    => mim_rx_ren,
    mim_rx_rce                    => mim_rx_rce,
    mim_rx_wdata                  => mim_rx_wdata_int,
    mim_rx_raddr                  => mim_rx_raddr,
    mim_rx_rdata                  => mim_rx_rdata_int
 );

  ---------------------------------------------------------
  -- Virtex7 PCI Express Block Module
  ---------------------------------------------------------

  pcie_block_i : PCIE_2_1
  generic map (
    AER_BASE_PTR                             => AER_BASE_PTR                              ,
    AER_CAP_ECRC_CHECK_CAPABLE               => AER_CAP_ECRC_CHECK_CAPABLE                ,
    AER_CAP_ECRC_GEN_CAPABLE                 => AER_CAP_ECRC_GEN_CAPABLE                  ,
    AER_CAP_ID                               => AER_CAP_ID                                ,
    AER_CAP_MULTIHEADER                      => AER_CAP_MULTIHEADER                       ,
    AER_CAP_NEXTPTR                          => AER_CAP_NEXTPTR                           ,
    AER_CAP_ON                               => AER_CAP_ON                                ,
    AER_CAP_OPTIONAL_ERR_SUPPORT             => AER_CAP_OPTIONAL_ERR_SUPPORT              ,
    AER_CAP_PERMIT_ROOTERR_UPDATE            => AER_CAP_PERMIT_ROOTERR_UPDATE             ,
    AER_CAP_VERSION                          => AER_CAP_VERSION                           ,
    ALLOW_X8_GEN2                            => ALLOW_X8_GEN2                             ,
    BAR0                                     => BAR0                                      ,
    BAR1                                     => BAR1                                      ,
    BAR2                                     => BAR2                                      ,
    BAR3                                     => BAR3                                      ,
    BAR4                                     => BAR4                                      ,
    BAR5                                     => BAR5                                      ,
    CAPABILITIES_PTR                         => CAPABILITIES_PTR                          ,
    CARDBUS_CIS_POINTER                      => CARDBUS_CIS_POINTER                       ,
    CFG_ECRC_ERR_CPLSTAT                     => CFG_ECRC_ERR_CPLSTAT                      ,
    CLASS_CODE                               => CLASS_CODE                                ,
    CMD_INTX_IMPLEMENTED                     => CMD_INTX_IMPLEMENTED                      ,
    CPL_TIMEOUT_DISABLE_SUPPORTED            => CPL_TIMEOUT_DISABLE_SUPPORTED             ,
    CPL_TIMEOUT_RANGES_SUPPORTED             => CPL_TIMEOUT_RANGES_SUPPORTED              ,
    CRM_MODULE_RSTS                          => CRM_MODULE_RSTS                           ,
    DEV_CAP2_ARI_FORWARDING_SUPPORTED        => DEV_CAP2_ARI_FORWARDING_SUPPORTED         ,
    DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED  => DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED   ,
    DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED  => DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED   ,
    DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED      => DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED       ,
    DEV_CAP2_CAS128_COMPLETER_SUPPORTED      => DEV_CAP2_CAS128_COMPLETER_SUPPORTED       ,
    DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED     => DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED      ,
    DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED    => DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED     ,
    DEV_CAP2_LTR_MECHANISM_SUPPORTED         => DEV_CAP2_LTR_MECHANISM_SUPPORTED          ,
    DEV_CAP2_MAX_ENDEND_TLP_PREFIXES         => DEV_CAP2_MAX_ENDEND_TLP_PREFIXES          ,
    DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING      => DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING       ,
    DEV_CAP2_TPH_COMPLETER_SUPPORTED         => DEV_CAP2_TPH_COMPLETER_SUPPORTED          ,
    DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE      => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE       ,
    DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE      => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE       ,
    DEV_CAP_ENDPOINT_L0S_LATENCY             => DEV_CAP_ENDPOINT_L0S_LATENCY              ,
    DEV_CAP_ENDPOINT_L1_LATENCY              => DEV_CAP_ENDPOINT_L1_LATENCY               ,
    DEV_CAP_EXT_TAG_SUPPORTED                => DEV_CAP_EXT_TAG_SUPPORTED                 ,
    DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE     => DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE      ,
    DEV_CAP_MAX_PAYLOAD_SUPPORTED            => DEV_CAP_MAX_PAYLOAD_SUPPORTED             ,
    DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT        => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT         ,
    DEV_CAP_ROLE_BASED_ERROR                 => DEV_CAP_ROLE_BASED_ERROR                  ,
    DEV_CAP_RSVD_14_12                       => DEV_CAP_RSVD_14_12                        ,
    DEV_CAP_RSVD_17_16                       => DEV_CAP_RSVD_17_16                        ,
    DEV_CAP_RSVD_31_29                       => DEV_CAP_RSVD_31_29                        ,
    DEV_CONTROL_AUX_POWER_SUPPORTED          => DEV_CONTROL_AUX_POWER_SUPPORTED           ,
    DEV_CONTROL_EXT_TAG_DEFAULT              => DEV_CONTROL_EXT_TAG_DEFAULT               ,
    DISABLE_ASPM_L1_TIMER                    => DISABLE_ASPM_L1_TIMER                     ,
    DISABLE_BAR_FILTERING                    => DISABLE_BAR_FILTERING                     ,
    DISABLE_ERR_MSG                          => DISABLE_ERR_MSG                           ,
    DISABLE_ID_CHECK                         => DISABLE_ID_CHECK                          ,
    DISABLE_LANE_REVERSAL                    => DISABLE_LANE_REVERSAL                     ,
    DISABLE_LOCKED_FILTER                    => DISABLE_LOCKED_FILTER                     ,
    DISABLE_PPM_FILTER                       => DISABLE_PPM_FILTER                        ,
    DISABLE_RX_POISONED_RESP                 => DISABLE_RX_POISONED_RESP                  ,
    DISABLE_RX_TC_FILTER                     => DISABLE_RX_TC_FILTER                      ,
    DISABLE_SCRAMBLING                       => DISABLE_SCRAMBLING                        ,
    DNSTREAM_LINK_NUM                        => DNSTREAM_LINK_NUM                         ,
    DSN_BASE_PTR                             => DSN_BASE_PTR                              ,
    DSN_CAP_ID                               => DSN_CAP_ID                                ,
    DSN_CAP_NEXTPTR                          => DSN_CAP_NEXTPTR                           ,
    DSN_CAP_ON                               => DSN_CAP_ON                                ,
    DSN_CAP_VERSION                          => DSN_CAP_VERSION                           ,
    ENABLE_MSG_ROUTE                         => ENABLE_MSG_ROUTE                          ,
    ENABLE_RX_TD_ECRC_TRIM                   => ENABLE_RX_TD_ECRC_TRIM                    ,
    ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED   => ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED    ,
    ENTER_RVRY_EI_L0                         => ENTER_RVRY_EI_L0                          ,
    EXIT_LOOPBACK_ON_EI                      => EXIT_LOOPBACK_ON_EI                       ,
    EXPANSION_ROM                            => EXPANSION_ROM                             ,
    EXT_CFG_CAP_PTR                          => EXT_CFG_CAP_PTR                           ,
    EXT_CFG_XP_CAP_PTR                       => EXT_CFG_XP_CAP_PTR                        ,
    HEADER_TYPE                              => HEADER_TYPE                               ,
    INFER_EI                                 => INFER_EI                                  ,
    INTERRUPT_PIN                            => INTERRUPT_PIN                             ,
    INTERRUPT_STAT_AUTO                      => INTERRUPT_STAT_AUTO                       ,
    IS_SWITCH                                => IS_SWITCH                                 ,
    LAST_CONFIG_DWORD                        => LAST_CONFIG_DWORD                         ,
    LINK_CAP_ASPM_OPTIONALITY                => LINK_CAP_ASPM_OPTIONALITY                 ,
    LINK_CAP_ASPM_SUPPORT                    => LINK_CAP_ASPM_SUPPORT                     ,
    LINK_CAP_CLOCK_POWER_MANAGEMENT          => LINK_CAP_CLOCK_POWER_MANAGEMENT           ,
    LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP   => LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP    ,
    LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1    => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1     ,
    LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2    => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2     ,
    LINK_CAP_L0S_EXIT_LATENCY_GEN1           => LINK_CAP_L0S_EXIT_LATENCY_GEN1            ,
    LINK_CAP_L0S_EXIT_LATENCY_GEN2           => LINK_CAP_L0S_EXIT_LATENCY_GEN2            ,
    LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1     => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1      ,
    LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2     => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2      ,
    LINK_CAP_L1_EXIT_LATENCY_GEN1            => LINK_CAP_L1_EXIT_LATENCY_GEN1             ,
    LINK_CAP_L1_EXIT_LATENCY_GEN2            => LINK_CAP_L1_EXIT_LATENCY_GEN2             ,
    LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP => LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP  ,
    LINK_CAP_MAX_LINK_SPEED                  => LINK_CAP_MAX_LINK_SPEED                   ,
    LINK_CAP_MAX_LINK_WIDTH                  => LINK_CAP_MAX_LINK_WIDTH                   ,
    LINK_CAP_RSVD_23                         => LINK_CAP_RSVD_23                          ,
    LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE     => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE      ,
    LINK_CONTROL_RCB                         => LINK_CONTROL_RCB                          ,
    LINK_CTRL2_DEEMPHASIS                    => LINK_CTRL2_DEEMPHASIS                     ,
    LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE   => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE    ,
    LINK_CTRL2_TARGET_LINK_SPEED             => LINK_CTRL2_TARGET_LINK_SPEED              ,
    LINK_STATUS_SLOT_CLOCK_CONFIG            => LINK_STATUS_SLOT_CLOCK_CONFIG             ,
    LL_ACK_TIMEOUT                           => LL_ACK_TIMEOUT                            ,
    LL_ACK_TIMEOUT_EN                        => LL_ACK_TIMEOUT_EN                         ,
    LL_ACK_TIMEOUT_FUNC                      => LL_ACK_TIMEOUT_FUNC                       ,
    LL_REPLAY_TIMEOUT                        => LL_REPLAY_TIMEOUT                         ,
    LL_REPLAY_TIMEOUT_EN                     => LL_REPLAY_TIMEOUT_EN                      ,
    LL_REPLAY_TIMEOUT_FUNC                   => LL_REPLAY_TIMEOUT_FUNC                    ,
    LTSSM_MAX_LINK_WIDTH                     => LTSSM_MAX_LINK_WIDTH                      ,
    MPS_FORCE                                => MPS_FORCE                                 ,
    MSIX_BASE_PTR                            => MSIX_BASE_PTR                             ,
    MSIX_CAP_ID                              => MSIX_CAP_ID                               ,
    MSIX_CAP_NEXTPTR                         => MSIX_CAP_NEXTPTR                          ,
    MSIX_CAP_ON                              => MSIX_CAP_ON                               ,
    MSIX_CAP_PBA_BIR                         => MSIX_CAP_PBA_BIR                          ,
    MSIX_CAP_PBA_OFFSET                      => MSIX_CAP_PBA_OFFSET                       ,
    MSIX_CAP_TABLE_BIR                       => MSIX_CAP_TABLE_BIR                        ,
    MSIX_CAP_TABLE_OFFSET                    => MSIX_CAP_TABLE_OFFSET                     ,
    MSIX_CAP_TABLE_SIZE                      => MSIX_CAP_TABLE_SIZE                       ,
    MSI_BASE_PTR                             => MSI_BASE_PTR                              ,
    MSI_CAP_64_BIT_ADDR_CAPABLE              => MSI_CAP_64_BIT_ADDR_CAPABLE               ,
    MSI_CAP_ID                               => MSI_CAP_ID                                ,
    MSI_CAP_MULTIMSGCAP                      => MSI_CAP_MULTIMSGCAP                       ,
    MSI_CAP_MULTIMSG_EXTENSION               => MSI_CAP_MULTIMSG_EXTENSION                ,
    MSI_CAP_NEXTPTR                          => MSI_CAP_NEXTPTR                           ,
    MSI_CAP_ON                               => MSI_CAP_ON                                ,
    MSI_CAP_PER_VECTOR_MASKING_CAPABLE       => MSI_CAP_PER_VECTOR_MASKING_CAPABLE        ,
    N_FTS_COMCLK_GEN1                        => N_FTS_COMCLK_GEN1                         ,
    N_FTS_COMCLK_GEN2                        => N_FTS_COMCLK_GEN2                         ,
    N_FTS_GEN1                               => N_FTS_GEN1                                ,
    N_FTS_GEN2                               => N_FTS_GEN2                                ,
    PCIE_BASE_PTR                            => PCIE_BASE_PTR                             ,
    PCIE_CAP_CAPABILITY_ID                   => PCIE_CAP_CAPABILITY_ID                    ,
    PCIE_CAP_CAPABILITY_VERSION              => PCIE_CAP_CAPABILITY_VERSION               ,
    PCIE_CAP_DEVICE_PORT_TYPE                => PCIE_CAP_DEVICE_PORT_TYPE                 ,
    PCIE_CAP_NEXTPTR                         => PCIE_CAP_NEXTPTR                          ,
    PCIE_CAP_ON                              => PCIE_CAP_ON                               ,
    PCIE_CAP_RSVD_15_14                      => PCIE_CAP_RSVD_15_14                       ,
    PCIE_CAP_SLOT_IMPLEMENTED                => PCIE_CAP_SLOT_IMPLEMENTED                 ,
    PCIE_REVISION                            => PCIE_REVISION                             ,
    PL_AUTO_CONFIG                           => PL_AUTO_CONFIG                            ,
    PL_FAST_TRAIN                            => PL_FAST_TRAIN                             ,
    PM_ASPML0S_TIMEOUT                       => PM_ASPML0S_TIMEOUT                        ,
    PM_ASPML0S_TIMEOUT_EN                    => PM_ASPML0S_TIMEOUT_EN                     ,
    PM_ASPML0S_TIMEOUT_FUNC                  => PM_ASPML0S_TIMEOUT_FUNC                   ,
    PM_ASPM_FASTEXIT                         => PM_ASPM_FASTEXIT                          ,
    PM_BASE_PTR                              => PM_BASE_PTR                               ,
    PM_CAP_AUXCURRENT                        => PM_CAP_AUXCURRENT                         ,
    PM_CAP_D1SUPPORT                         => PM_CAP_D1SUPPORT                          ,
    PM_CAP_D2SUPPORT                         => PM_CAP_D2SUPPORT                          ,
    PM_CAP_DSI                               => PM_CAP_DSI                                ,
    PM_CAP_ID                                => PM_CAP_ID                                 ,
    PM_CAP_NEXTPTR                           => PM_CAP_NEXTPTR                            ,
    PM_CAP_ON                                => PM_CAP_ON                                 ,
    PM_CAP_PMESUPPORT                        => PM_CAP_PMESUPPORT                         ,
    PM_CAP_PME_CLOCK                         => PM_CAP_PME_CLOCK                          ,
    PM_CAP_RSVD_04                           => PM_CAP_RSVD_04                            ,
    PM_CAP_VERSION                           => PM_CAP_VERSION                            ,
    PM_CSR_B2B3                              => PM_CSR_B2B3                               ,
    PM_CSR_BPCCEN                            => PM_CSR_BPCCEN                             ,
    PM_CSR_NOSOFTRST                         => PM_CSR_NOSOFTRST                          ,
    PM_DATA0                                 => PM_DATA0                                  ,
    PM_DATA1                                 => PM_DATA1                                  ,
    PM_DATA2                                 => PM_DATA2                                  ,
    PM_DATA3                                 => PM_DATA3                                  ,
    PM_DATA4                                 => PM_DATA4                                  ,
    PM_DATA5                                 => PM_DATA5                                  ,
    PM_DATA6                                 => PM_DATA6                                  ,
    PM_DATA7                                 => PM_DATA7                                  ,
    PM_DATA_SCALE0                           => PM_DATA_SCALE0                            ,
    PM_DATA_SCALE1                           => PM_DATA_SCALE1                            ,
    PM_DATA_SCALE2                           => PM_DATA_SCALE2                            ,
    PM_DATA_SCALE3                           => PM_DATA_SCALE3                            ,
    PM_DATA_SCALE4                           => PM_DATA_SCALE4                            ,
    PM_DATA_SCALE5                           => PM_DATA_SCALE5                            ,
    PM_DATA_SCALE6                           => PM_DATA_SCALE6                            ,
    PM_DATA_SCALE7                           => PM_DATA_SCALE7                            ,
    PM_MF                                    => PM_MF                                     ,
    RBAR_BASE_PTR                            => RBAR_BASE_PTR                             ,
    RBAR_CAP_CONTROL_ENCODEDBAR0             => RBAR_CAP_CONTROL_ENCODEDBAR0              ,
    RBAR_CAP_CONTROL_ENCODEDBAR1             => RBAR_CAP_CONTROL_ENCODEDBAR1              ,
    RBAR_CAP_CONTROL_ENCODEDBAR2             => RBAR_CAP_CONTROL_ENCODEDBAR2              ,
    RBAR_CAP_CONTROL_ENCODEDBAR3             => RBAR_CAP_CONTROL_ENCODEDBAR3              ,
    RBAR_CAP_CONTROL_ENCODEDBAR4             => RBAR_CAP_CONTROL_ENCODEDBAR4              ,
    RBAR_CAP_CONTROL_ENCODEDBAR5             => RBAR_CAP_CONTROL_ENCODEDBAR5              ,
    RBAR_CAP_ID                              => RBAR_CAP_ID                               ,
    RBAR_CAP_INDEX0                          => RBAR_CAP_INDEX0                           ,
    RBAR_CAP_INDEX1                          => RBAR_CAP_INDEX1                           ,
    RBAR_CAP_INDEX2                          => RBAR_CAP_INDEX2                           ,
    RBAR_CAP_INDEX3                          => RBAR_CAP_INDEX3                           ,
    RBAR_CAP_INDEX4                          => RBAR_CAP_INDEX4                           ,
    RBAR_CAP_INDEX5                          => RBAR_CAP_INDEX5                           ,
    RBAR_CAP_NEXTPTR                         => RBAR_CAP_NEXTPTR                          ,
    RBAR_CAP_ON                              => RBAR_CAP_ON                               ,
    RBAR_CAP_SUP0                            => RBAR_CAP_SUP0                             ,
    RBAR_CAP_SUP1                            => RBAR_CAP_SUP1                             ,
    RBAR_CAP_SUP2                            => RBAR_CAP_SUP2                             ,
    RBAR_CAP_SUP3                            => RBAR_CAP_SUP3                             ,
    RBAR_CAP_SUP4                            => RBAR_CAP_SUP4                             ,
    RBAR_CAP_SUP5                            => RBAR_CAP_SUP5                             ,
    RBAR_CAP_VERSION                         => RBAR_CAP_VERSION                          ,
    RBAR_NUM                                 => RBAR_NUM                                  ,
    RECRC_CHK                                => RECRC_CHK                                 ,
    RECRC_CHK_TRIM                           => RECRC_CHK_TRIM                            ,
    ROOT_CAP_CRS_SW_VISIBILITY               => ROOT_CAP_CRS_SW_VISIBILITY                ,
    RP_AUTO_SPD                              => RP_AUTO_SPD                               ,
    RP_AUTO_SPD_LOOPCNT                      => RP_AUTO_SPD_LOOPCNT                       ,
    SELECT_DLL_IF                            => SELECT_DLL_IF                             ,
    SIM_VERSION                              => SIM_VERSION                               ,--
    SLOT_CAP_ATT_BUTTON_PRESENT              => SLOT_CAP_ATT_BUTTON_PRESENT               ,
    SLOT_CAP_ATT_INDICATOR_PRESENT           => SLOT_CAP_ATT_INDICATOR_PRESENT            ,
    SLOT_CAP_ELEC_INTERLOCK_PRESENT          => SLOT_CAP_ELEC_INTERLOCK_PRESENT           ,
    SLOT_CAP_HOTPLUG_CAPABLE                 => SLOT_CAP_HOTPLUG_CAPABLE                  ,
    SLOT_CAP_HOTPLUG_SURPRISE                => SLOT_CAP_HOTPLUG_SURPRISE                 ,
    SLOT_CAP_MRL_SENSOR_PRESENT              => SLOT_CAP_MRL_SENSOR_PRESENT               ,
    SLOT_CAP_NO_CMD_COMPLETED_SUPPORT        => SLOT_CAP_NO_CMD_COMPLETED_SUPPORT         ,
    SLOT_CAP_PHYSICAL_SLOT_NUM               => SLOT_CAP_PHYSICAL_SLOT_NUM                ,
    SLOT_CAP_POWER_CONTROLLER_PRESENT        => SLOT_CAP_POWER_CONTROLLER_PRESENT         ,
    SLOT_CAP_POWER_INDICATOR_PRESENT         => SLOT_CAP_POWER_INDICATOR_PRESENT          ,
    SLOT_CAP_SLOT_POWER_LIMIT_SCALE          => SLOT_CAP_SLOT_POWER_LIMIT_SCALE           ,
    SLOT_CAP_SLOT_POWER_LIMIT_VALUE          => SLOT_CAP_SLOT_POWER_LIMIT_VALUE           ,
    SPARE_BIT0                               => SPARE_BIT0                                ,
    SPARE_BIT1                               => SPARE_BIT1                                ,
    SPARE_BIT2                               => SPARE_BIT2                                ,
    SPARE_BIT3                               => SPARE_BIT3                                ,
    SPARE_BIT4                               => SPARE_BIT4                                ,
    SPARE_BIT5                               => SPARE_BIT5                                ,
    SPARE_BIT6                               => SPARE_BIT6                                ,
    SPARE_BIT7                               => SPARE_BIT7                                ,
    SPARE_BIT8                               => SPARE_BIT8                                ,
    SPARE_BYTE0                              => SPARE_BYTE0                               ,
    SPARE_BYTE1                              => SPARE_BYTE1                               ,
    SPARE_BYTE2                              => SPARE_BYTE2                               ,
    SPARE_BYTE3                              => SPARE_BYTE3                               ,
    SPARE_WORD0                              => SPARE_WORD0                               ,
    SPARE_WORD1                              => SPARE_WORD1                               ,
    SPARE_WORD2                              => SPARE_WORD2                               ,
    SPARE_WORD3                              => SPARE_WORD3                               ,
    SSL_MESSAGE_AUTO                         => SSL_MESSAGE_AUTO                          ,
    TECRC_EP_INV                             => TECRC_EP_INV                              ,
    TL_RBYPASS                               => TL_RBYPASS                                ,
    TL_RX_RAM_RADDR_LATENCY                  => TL_RX_RAM_RADDR_LATENCY                   ,
    TL_RX_RAM_RDATA_LATENCY                  => TL_RX_RAM_RDATA_LATENCY                   ,
    TL_RX_RAM_WRITE_LATENCY                  => TL_RX_RAM_WRITE_LATENCY                   ,
    TL_TFC_DISABLE                           => TL_TFC_DISABLE                            ,
    TL_TX_CHECKS_DISABLE                     => TL_TX_CHECKS_DISABLE                      ,
    TL_TX_RAM_RADDR_LATENCY                  => TL_TX_RAM_RADDR_LATENCY                   ,
    TL_TX_RAM_RDATA_LATENCY                  => TL_TX_RAM_RDATA_LATENCY                   ,
    TL_TX_RAM_WRITE_LATENCY                  => TL_TX_RAM_WRITE_LATENCY                   ,
    TRN_DW                                   => TRN_DW                                    ,
    TRN_NP_FC                                => TRN_NP_FC                                 ,
    UPCONFIG_CAPABLE                         => UPCONFIG_CAPABLE                          ,
    UPSTREAM_FACING                          => UPSTREAM_FACING                           ,
    UR_ATOMIC                                => UR_ATOMIC                                 ,
    UR_CFG1                                  => UR_CFG1                                   ,
    UR_INV_REQ                               => UR_INV_REQ                                ,
    UR_PRS_RESPONSE                          => UR_PRS_RESPONSE                           ,
    USER_CLK2_DIV2                           => USER_CLK2_DIV2                            ,
    USER_CLK_FREQ                            => USER_CLK_FREQ                             ,
    USE_RID_PINS                             => USE_RID_PINS                              ,
    VC0_CPL_INFINITE                         => VC0_CPL_INFINITE                          ,
    VC0_RX_RAM_LIMIT                         => VC0_RX_RAM_LIMIT                          ,
    VC0_TOTAL_CREDITS_CD                     => VC0_TOTAL_CREDITS_CD                      ,
    VC0_TOTAL_CREDITS_CH                     => VC0_TOTAL_CREDITS_CH                      ,
    VC0_TOTAL_CREDITS_NPD                    => VC0_TOTAL_CREDITS_NPD                     ,
    VC0_TOTAL_CREDITS_NPH                    => VC0_TOTAL_CREDITS_NPH                     ,
    VC0_TOTAL_CREDITS_PD                     => VC0_TOTAL_CREDITS_PD                      ,
    VC0_TOTAL_CREDITS_PH                     => VC0_TOTAL_CREDITS_PH                      ,
    VC0_TX_LASTPACKET                        => VC0_TX_LASTPACKET                         ,
    VC_BASE_PTR                              => VC_BASE_PTR                               ,
    VC_CAP_ID                                => VC_CAP_ID                                 ,
    VC_CAP_NEXTPTR                           => VC_CAP_NEXTPTR                            ,
    VC_CAP_ON                                => VC_CAP_ON                                 ,
    VC_CAP_REJECT_SNOOP_TRANSACTIONS         => VC_CAP_REJECT_SNOOP_TRANSACTIONS          ,
    VC_CAP_VERSION                           => VC_CAP_VERSION                            ,
    VSEC_BASE_PTR                            => VSEC_BASE_PTR                             ,
    VSEC_CAP_HDR_ID                          => VSEC_CAP_HDR_ID                           ,
    VSEC_CAP_HDR_LENGTH                      => VSEC_CAP_HDR_LENGTH                       ,--
    VSEC_CAP_HDR_REVISION                    => VSEC_CAP_HDR_REVISION                     ,
    VSEC_CAP_ID                              => VSEC_CAP_ID                               ,
    VSEC_CAP_IS_LINK_VISIBLE                 => VSEC_CAP_IS_LINK_VISIBLE                  ,
    VSEC_CAP_NEXTPTR                         => VSEC_CAP_NEXTPTR                          ,
    VSEC_CAP_ON                              => VSEC_CAP_ON                               ,
    VSEC_CAP_VERSION                         => VSEC_CAP_VERSION
  )
  port map (
     CFGAERECRCCHECKEN                       => cfg_aer_ecrc_check_en,
     CFGAERECRCGENEN                         => cfg_aer_ecrc_gen_en,
     CFGAERROOTERRCORRERRRECEIVED            => cfg_aer_rooterr_corr_err_received,
     CFGAERROOTERRCORRERRREPORTINGEN         => cfg_aer_rooterr_corr_err_reporting_en,
     CFGAERROOTERRFATALERRRECEIVED           => cfg_aer_rooterr_fatal_err_received,
     CFGAERROOTERRFATALERRREPORTINGEN        => cfg_aer_rooterr_fatal_err_reporting_en,
     CFGAERROOTERRNONFATALERRRECEIVED        => cfg_aer_rooterr_non_fatal_err_received,
     CFGAERROOTERRNONFATALERRREPORTINGEN     => cfg_aer_rooterr_non_fatal_err_reporting_en,
     CFGBRIDGESERREN                         => cfg_bridge_serr_en,
     CFGCOMMANDBUSMASTERENABLE               => cfg_command_bus_master_enable,
     CFGCOMMANDINTERRUPTDISABLE              => cfg_command_interrupt_disable,
     CFGCOMMANDIOENABLE                      => cfg_command_io_enable,
     CFGCOMMANDMEMENABLE                     => cfg_command_mem_enable,
     CFGCOMMANDSERREN                        => cfg_command_serr_en,
     CFGDEVCONTROL2ARIFORWARDEN              => cfg_dev_control2_ari_forward_en,
     CFGDEVCONTROL2ATOMICEGRESSBLOCK         => cfg_dev_control2_atomic_egress_block,
     CFGDEVCONTROL2ATOMICREQUESTEREN         => cfg_dev_control2_atomic_requester_en,
     CFGDEVCONTROL2CPLTIMEOUTDIS             => cfg_dev_control2_cpl_timeout_dis,
     CFGDEVCONTROL2CPLTIMEOUTVAL             => cfg_dev_control2_cpl_timeout_val,
     CFGDEVCONTROL2IDOCPLEN                  => cfg_dev_control2_ido_cpl_en,
     CFGDEVCONTROL2IDOREQEN                  => cfg_dev_control2_ido_req_en,
     CFGDEVCONTROL2LTREN                     => cfg_dev_control2_ltr_en,
     CFGDEVCONTROL2TLPPREFIXBLOCK            => cfg_dev_control2_tlp_prefix_block,
     CFGDEVCONTROLAUXPOWEREN                 => cfg_dev_control_aux_power_en,
     CFGDEVCONTROLCORRERRREPORTINGEN         => cfg_dev_control_corr_err_reporting_en,
     CFGDEVCONTROLENABLERO                   => cfg_dev_control_enable_ro,
     CFGDEVCONTROLEXTTAGEN                   => cfg_dev_control_ext_tag_en,
     CFGDEVCONTROLFATALERRREPORTINGEN        => cfg_dev_control_fatal_err_reporting_en,
     CFGDEVCONTROLMAXPAYLOAD                 => cfg_dev_control_max_payload,
     CFGDEVCONTROLMAXREADREQ                 => cfg_dev_control_max_read_req,
     CFGDEVCONTROLNONFATALREPORTINGEN        => cfg_dev_control_non_fatal_reporting_en,
     CFGDEVCONTROLNOSNOOPEN                  => cfg_dev_control_no_snoop_en,
     CFGDEVCONTROLPHANTOMEN                  => cfg_dev_control_phantom_en,
     CFGDEVCONTROLURERRREPORTINGEN           => cfg_dev_control_ur_err_reporting_en,
     CFGDEVSTATUSCORRERRDETECTED             => cfg_dev_status_corr_err_detected,
     CFGDEVSTATUSFATALERRDETECTED            => cfg_dev_status_fatal_err_detected,
     CFGDEVSTATUSNONFATALERRDETECTED         => cfg_dev_status_non_fatal_err_detected,
     CFGDEVSTATUSURDETECTED                  => cfg_dev_status_ur_detected,
     CFGERRAERHEADERLOGSETN                  => cfg_err_aer_headerlog_set_n,
     CFGERRCPLRDYN                           => cfg_err_cpl_rdy_n,
     CFGINTERRUPTDO                          => cfg_interrupt_do,
     CFGINTERRUPTMMENABLE                    => cfg_interrupt_mmenable,
     CFGINTERRUPTMSIENABLE                   => cfg_interrupt_msienable,
     CFGINTERRUPTMSIXENABLE                  => cfg_interrupt_msixenable,
     CFGINTERRUPTMSIXFM                      => cfg_interrupt_msixfm,
     CFGINTERRUPTRDYN                        => cfg_interrupt_rdy_n,
     CFGLINKCONTROLASPMCONTROL               => cfg_link_control_aspm_control,
     CFGLINKCONTROLAUTOBANDWIDTHINTEN        => cfg_link_control_auto_bandwidth_int_en,
     CFGLINKCONTROLBANDWIDTHINTEN            => cfg_link_control_bandwidth_int_en,
     CFGLINKCONTROLCLOCKPMEN                 => cfg_link_control_clock_pm_en,
     CFGLINKCONTROLCOMMONCLOCK               => cfg_link_control_common_clock,
     CFGLINKCONTROLEXTENDEDSYNC              => cfg_link_control_extended_sync,
     CFGLINKCONTROLHWAUTOWIDTHDIS            => cfg_link_control_hw_auto_width_dis,
     CFGLINKCONTROLLINKDISABLE               => cfg_link_control_link_disable,
     CFGLINKCONTROLRCB                       => cfg_link_control_rcb,
     CFGLINKCONTROLRETRAINLINK               => cfg_link_control_retrain_link,
     CFGLINKSTATUSAUTOBANDWIDTHSTATUS        => cfg_link_status_auto_bandwidth_status,
     CFGLINKSTATUSBANDWIDTHSTATUS            => cfg_link_status_bandwidth_status,
     CFGLINKSTATUSCURRENTSPEED               => cfg_link_status_current_speed,
     CFGLINKSTATUSDLLACTIVE                  => cfg_link_status_dll_active,
     CFGLINKSTATUSLINKTRAINING               => cfg_link_status_link_training,
     CFGLINKSTATUSNEGOTIATEDWIDTH            => cfg_link_status_negotiated_width,
     CFGMGMTDO                               => cfg_mgmt_do,
     CFGMGMTRDWRDONEN                        => cfg_mgmt_rd_wr_done_n,
     CFGMSGDATA                              => cfg_msg_data,
     CFGMSGRECEIVED                          => cfg_msg_received,
     CFGMSGRECEIVEDASSERTINTA                => cfg_msg_received_assert_int_a,
     CFGMSGRECEIVEDASSERTINTB                => cfg_msg_received_assert_int_b,
     CFGMSGRECEIVEDASSERTINTC                => cfg_msg_received_assert_int_c,
     CFGMSGRECEIVEDASSERTINTD                => cfg_msg_received_assert_int_d,
     CFGMSGRECEIVEDDEASSERTINTA              => cfg_msg_received_deassert_int_a,
     CFGMSGRECEIVEDDEASSERTINTB              => cfg_msg_received_deassert_int_b,
     CFGMSGRECEIVEDDEASSERTINTC              => cfg_msg_received_deassert_int_c,
     CFGMSGRECEIVEDDEASSERTINTD              => cfg_msg_received_deassert_int_d,
     CFGMSGRECEIVEDERRCOR                    => cfg_msg_received_err_cor,
     CFGMSGRECEIVEDERRFATAL                  => cfg_msg_received_err_fatal,
     CFGMSGRECEIVEDERRNONFATAL               => cfg_msg_received_err_non_fatal,
     CFGMSGRECEIVEDPMASNAK                   => cfg_msg_received_pm_as_nak,
     CFGMSGRECEIVEDPMETO                     => cfg_msg_received_pme_to,
     CFGMSGRECEIVEDPMETOACK                  => cfg_msg_received_pme_to_ack,
     CFGMSGRECEIVEDPMPME                     => cfg_msg_received_pm_pme,
     CFGMSGRECEIVEDSETSLOTPOWERLIMIT         => cfg_msg_received_setslotpowerlimit,
     CFGMSGRECEIVEDUNLOCK                    => cfg_msg_received_unlock,
     CFGPCIELINKSTATE                        => cfg_pcie_link_state,
     CFGPMCSRPMEEN                           => cfg_pmcsr_pme_en,
     CFGPMCSRPMESTATUS                       => cfg_pmcsr_pme_status,
     CFGPMCSRPOWERSTATE                      => cfg_pmcsr_powerstate,
     CFGPMRCVASREQL1N                        => cfg_pm_rcv_as_req_l1_n,
     CFGPMRCVENTERL1N                        => cfg_pm_rcv_enter_l1_n,
     CFGPMRCVENTERL23N                       => cfg_pm_rcv_enter_l23_n,
     CFGPMRCVREQACKN                         => cfg_pm_rcv_req_ack_n,
     CFGROOTCONTROLPMEINTEN                  => cfg_root_control_pme_int_en,
     CFGROOTCONTROLSYSERRCORRERREN           => cfg_root_control_syserr_corr_err_en,
     CFGROOTCONTROLSYSERRFATALERREN          => cfg_root_control_syserr_fatal_err_en,
     CFGROOTCONTROLSYSERRNONFATALERREN       => cfg_root_control_syserr_non_fatal_err_en,
     CFGSLOTCONTROLELECTROMECHILCTLPULSE     => cfg_slot_control_electromech_il_ctl_pulse,
     CFGTRANSACTION                          => cfg_transaction,
     CFGTRANSACTIONADDR                      => cfg_transaction_addr,
     CFGTRANSACTIONTYPE                      => cfg_transaction_type,
     CFGVCTCVCMAP                            => cfg_vc_tcvc_map,
     DBGSCLRA                                => dbg_sclr_a,
     DBGSCLRB                                => dbg_sclr_b,
     DBGSCLRC                                => dbg_sclr_c,
     DBGSCLRD                                => dbg_sclr_d,
     DBGSCLRE                                => dbg_sclr_e,
     DBGSCLRF                                => dbg_sclr_f,
     DBGSCLRG                                => dbg_sclr_g,
     DBGSCLRH                                => dbg_sclr_h,
     DBGSCLRI                                => dbg_sclr_i,
     DBGSCLRJ                                => dbg_sclr_j,
     DBGSCLRK                                => dbg_sclr_k,
     DBGVECA                                 => dbg_vec_a,
     DBGVECB                                 => dbg_vec_b,
     DBGVECC                                 => dbg_vec_c,
     LL2BADDLLPERR                           => ll2_bad_dllp_err,
     LL2BADTLPERR                            => ll2_bad_tlp_err,
     LL2LINKSTATUS                           => ll2_link_status,
     LL2PROTOCOLERR                          => ll2_protocol_err,
     LL2RECEIVERERR                          => ll2_receiver_err,
     LL2REPLAYROERR                          => ll2_replay_ro_err,
     LL2REPLAYTOERR                          => ll2_replay_to_err,
     LL2SUSPENDOK                            => ll2_suspend_ok,
     LL2TFCINIT1SEQ                          => ll2_tfc_init1_seq,
     LL2TFCINIT2SEQ                          => ll2_tfc_init2_seq,
     LL2TXIDLE                               => ll2_tx_idle,
     LNKCLKEN                                => lnk_clk_en,
     MIMRXRADDR                              => mim_rx_raddr,
     MIMRXREN                                => mim_rx_ren,
     MIMRXWADDR                              => mim_rx_waddr,
     MIMRXWDATA                              => mim_rx_wdata,
     MIMRXWEN                                => mim_rx_wen,
     MIMTXRADDR                              => mim_tx_raddr,
     MIMTXREN                                => mim_tx_ren,
     MIMTXWADDR                              => mim_tx_waddr,
     MIMTXWDATA                              => mim_tx_wdata,
     MIMTXWEN                                => mim_tx_wen,
     PIPERX0POLARITY                         => pipe_rx0_polarity,
     PIPERX1POLARITY                         => pipe_rx1_polarity,
     PIPERX2POLARITY                         => pipe_rx2_polarity,
     PIPERX3POLARITY                         => pipe_rx3_polarity,
     PIPERX4POLARITY                         => pipe_rx4_polarity,
     PIPERX5POLARITY                         => pipe_rx5_polarity,
     PIPERX6POLARITY                         => pipe_rx6_polarity,
     PIPERX7POLARITY                         => pipe_rx7_polarity,
     PIPETX0CHARISK                          => pipe_tx0_char_is_k,
     PIPETX0COMPLIANCE                       => pipe_tx0_compliance,
     PIPETX0DATA                             => pipe_tx0_data,
     PIPETX0ELECIDLE                         => pipe_tx0_elec_idle,
     PIPETX0POWERDOWN                        => pipe_tx0_powerdown,
     PIPETX1CHARISK                          => pipe_tx1_char_is_k,
     PIPETX1COMPLIANCE                       => pipe_tx1_compliance,
     PIPETX1DATA                             => pipe_tx1_data,
     PIPETX1ELECIDLE                         => pipe_tx1_elec_idle,
     PIPETX1POWERDOWN                        => pipe_tx1_powerdown,
     PIPETX2CHARISK                          => pipe_tx2_char_is_k,
     PIPETX2COMPLIANCE                       => pipe_tx2_compliance,
     PIPETX2DATA                             => pipe_tx2_data,
     PIPETX2ELECIDLE                         => pipe_tx2_elec_idle,
     PIPETX2POWERDOWN                        => pipe_tx2_powerdown,
     PIPETX3CHARISK                          => pipe_tx3_char_is_k,
     PIPETX3COMPLIANCE                       => pipe_tx3_compliance,
     PIPETX3DATA                             => pipe_tx3_data,
     PIPETX3ELECIDLE                         => pipe_tx3_elec_idle,
     PIPETX3POWERDOWN                        => pipe_tx3_powerdown,
     PIPETX4CHARISK                          => pipe_tx4_char_is_k,
     PIPETX4COMPLIANCE                       => pipe_tx4_compliance,
     PIPETX4DATA                             => pipe_tx4_data,
     PIPETX4ELECIDLE                         => pipe_tx4_elec_idle,
     PIPETX4POWERDOWN                        => pipe_tx4_powerdown,
     PIPETX5CHARISK                          => pipe_tx5_char_is_k,
     PIPETX5COMPLIANCE                       => pipe_tx5_compliance,
     PIPETX5DATA                             => pipe_tx5_data,
     PIPETX5ELECIDLE                         => pipe_tx5_elec_idle,
     PIPETX5POWERDOWN                        => pipe_tx5_powerdown,
     PIPETX6CHARISK                          => pipe_tx6_char_is_k,
     PIPETX6COMPLIANCE                       => pipe_tx6_compliance,
     PIPETX6DATA                             => pipe_tx6_data,
     PIPETX6ELECIDLE                         => pipe_tx6_elec_idle,
     PIPETX6POWERDOWN                        => pipe_tx6_powerdown,
     PIPETX7CHARISK                          => pipe_tx7_char_is_k,
     PIPETX7COMPLIANCE                       => pipe_tx7_compliance,
     PIPETX7DATA                             => pipe_tx7_data,
     PIPETX7ELECIDLE                         => pipe_tx7_elec_idle,
     PIPETX7POWERDOWN                        => pipe_tx7_powerdown,
     PIPETXDEEMPH                            => pipe_tx_deemph,
     PIPETXMARGIN                            => pipe_tx_margin,
     PIPETXRATE                              => pipe_tx_rate,
     PIPETXRCVRDET                           => pipe_tx_rcvr_det,
     PIPETXRESET                             => pipe_tx_reset,
     PL2L0REQ                                => pl2_l0_req,
     PL2LINKUP                               => pl2_link_up,
     PL2RECEIVERERR                          => pl2_receiver_err,
     PL2RECOVERY                             => pl2_recovery,
     PL2RXELECIDLE                           => pl2_rx_elec_idle,
     PL2RXPMSTATE                            => pl2_rx_pm_state,
     PL2SUSPENDOK                            => pl2_suspend_ok,
     PLDBGVEC                                => pl_dbg_vec,
     PLDIRECTEDCHANGEDONE                    => pl_directed_change_done,
     PLINITIALLINKWIDTH                      => pl_initial_link_width,
     PLLANEREVERSALMODE                      => pl_lane_reversal_mode,
     PLLINKGEN2CAP                           => pl_link_gen2_cap,
     PLLINKPARTNERGEN2SUPPORTED              => pl_link_partner_gen2_supported,
     PLLINKUPCFGCAP                          => pl_link_upcfg_cap,
     PLLTSSMSTATE                            => pl_ltssm_state,
     PLPHYLNKUPN                             => pl_phy_lnk_up_n,
     PLRECEIVEDHOTRST                        => pl_received_hot_rst,
     PLRXPMSTATE                             => pl_rx_pm_state,
     PLSELLNKRATE                            => pl_sel_lnk_rate,
     PLSELLNKWIDTH                           => pl_sel_lnk_width,
     PLTXPMSTATE                             => pl_tx_pm_state,
     RECEIVEDFUNCLVLRSTN                     => received_func_lvl_rst_n,
     TL2ASPMSUSPENDCREDITCHECKOK             => tl2_aspm_suspend_credit_check_ok,
     TL2ASPMSUSPENDREQ                       => tl2_aspm_suspend_req,
     TL2ERRFCPE                              => tl2_err_fcpe,
     TL2ERRHDR                               => tl2_err_hdr,
     TL2ERRMALFORMED                         => tl2_err_malformed,
     TL2ERRRXOVERFLOW                        => tl2_err_rxoverflow,
     TL2PPMSUSPENDOK                         => tl2_ppm_suspend_ok,
     TRNFCCPLD                               => trn_fc_cpld,
     TRNFCCPLH                               => trn_fc_cplh,
     TRNFCNPD                                => trn_fc_npd,
     TRNFCNPH                                => trn_fc_nph,
     TRNFCPD                                 => trn_fc_pd,
     TRNFCPH                                 => trn_fc_ph,
     TRNLNKUP                                => trn_lnk_up,
     TRNRBARHIT                              => trn_rbar_hit,
     TRNRD                                   => trn_rd_int,
     TRNRDLLPDATA                            => trn_rdllp_data,
     TRNRDLLPSRCRDY                          => trn_rdllp_src_rdy,
     TRNRECRCERR                             => trn_recrc_err,
     TRNREOF                                 => trn_reof,
     TRNRERRFWD                              => trn_rerrfwd,
     TRNRREM                                 => trn_rrem_int,
     TRNRSOF                                 => trn_rsof,
     TRNRSRCDSC                              => trn_rsrc_dsc,
     TRNRSRCRDY                              => trn_rsrc_rdy,
     TRNTBUFAV                               => trn_tbuf_av,
     TRNTCFGREQ                              => trn_tcfg_req,
     TRNTDLLPDSTRDY                          => trn_tdllp_dst_rdy,
     TRNTDSTRDY                              => trn_tdst_rdy_bus,
     TRNTERRDROP                             => trn_terr_drop,
     USERRSTN                                => user_rst_n,
     CFGAERINTERRUPTMSGNUM                   => cfg_aer_interrupt_msgnum,
     CFGDEVID                                => cfg_dev_id,
     CFGDSBUSNUMBER                          => cfg_ds_bus_number,
     CFGDSDEVICENUMBER                       => cfg_ds_device_number,
     CFGDSFUNCTIONNUMBER                     => cfg_ds_function_number,
     CFGDSN                                  => cfg_dsn,
     CFGERRACSN                              => cfg_err_acs_n,
     CFGERRAERHEADERLOG                      => cfg_err_aer_headerlog,
     CFGERRATOMICEGRESSBLOCKEDN              => cfg_err_atomic_egress_blocked_n,
     CFGERRCORN                              => cfg_err_cor_n,
     CFGERRCPLABORTN                         => cfg_err_cpl_abort_n,
     CFGERRCPLTIMEOUTN                       => cfg_err_cpl_timeout_n,
     CFGERRCPLUNEXPECTN                      => cfg_err_cpl_unexpect_n,
     CFGERRECRCN                             => cfg_err_ecrc_n,
     CFGERRINTERNALCORN                      => cfg_err_internal_cor_n,
     CFGERRINTERNALUNCORN                    => cfg_err_internal_uncor_n,
     CFGERRLOCKEDN                           => cfg_err_locked_n,
     CFGERRMALFORMEDN                        => cfg_err_malformed_n,
     CFGERRMCBLOCKEDN                        => cfg_err_mc_blocked_n,
     CFGERRNORECOVERYN                       => cfg_err_norecovery_n,
     CFGERRPOISONEDN                         => cfg_err_poisoned_n,
     CFGERRPOSTEDN                           => cfg_err_posted_n,
     CFGERRTLPCPLHEADER                      => cfg_err_tlp_cpl_header,
     CFGERRURN                               => cfg_err_ur_n,
     CFGFORCECOMMONCLOCKOFF                  => cfg_force_common_clock_off,
     CFGFORCEEXTENDEDSYNCON                  => cfg_force_extended_sync_on,
     CFGFORCEMPS                             => cfg_force_mps,
     CFGINTERRUPTASSERTN                     => cfg_interrupt_assert_n,
     CFGINTERRUPTDI                          => cfg_interrupt_di,
     CFGINTERRUPTN                           => cfg_interrupt_n,
     CFGINTERRUPTSTATN                       => cfg_interrupt_stat_n,
     CFGMGMTBYTEENN                          => cfg_mgmt_byte_en_n,
     CFGMGMTDI                               => cfg_mgmt_di,
     CFGMGMTDWADDR                           => cfg_mgmt_dwaddr,
     CFGMGMTRDENN                            => cfg_mgmt_rd_en_n,
     CFGMGMTWRENN                            => cfg_mgmt_wr_en_n,
     CFGMGMTWRREADONLYN                      => cfg_mgmt_wr_readonly_n,
     CFGMGMTWRRW1CASRWN                      => cfg_mgmt_wr_rw1c_as_rw_n,
     CFGPCIECAPINTERRUPTMSGNUM               => cfg_pciecap_interrupt_msgnum,
     CFGPMFORCESTATE                         => cfg_pm_force_state,
     CFGPMFORCESTATEENN                      => cfg_pm_force_state_en_n,
     CFGPMHALTASPML0SN                       => cfg_pm_halt_aspm_l0s_n,
     CFGPMHALTASPML1N                        => cfg_pm_halt_aspm_l1_n,
     CFGPMSENDPMETON                         => cfg_pm_send_pme_to_n,
     CFGPMTURNOFFOKN                         => cfg_pm_turnoff_ok_n,
     CFGPMWAKEN                              => cfg_pm_wake_n,
     CFGPORTNUMBER                           => cfg_port_number,
     CFGREVID                                => cfg_rev_id,
     CFGSUBSYSID                             => cfg_subsys_id,
     CFGSUBSYSVENDID                         => cfg_subsys_vend_id,
     CFGTRNPENDINGN                          => cfg_trn_pending_n,
     CFGVENDID                               => cfg_vend_id,
     CMRSTN                                  => cm_rst_n,
     CMSTICKYRSTN                            => cm_sticky_rst_n,
     DBGMODE                                 => dbg_mode,
     DBGSUBMODE                              => dbg_sub_mode,
     DLRSTN                                  => dl_rst_n,
     DRPADDR                                 => "000000000",
     DRPCLK                                  => '0',
     DRPDI                                   => X"0000",
     DRPEN                                   => '0',
     DRPWE                                   => '0',
     DRPDO                                   => open,
     DRPRDY                                  => open,
     FUNCLVLRSTN                             => func_lvl_rst_n,
     LL2SENDASREQL1                          => ll2_send_as_req_l1,
     LL2SENDENTERL1                          => ll2_send_enter_l1,
     LL2SENDENTERL23                         => ll2_send_enter_l23,
     LL2SENDPMACK                            => ll2_send_pm_ack,
     LL2SUSPENDNOW                           => ll2_suspend_now,
     LL2TLPRCV                               => ll2_tlp_rcv,
     MIMRXRDATA                              => mim_rx_rdata,
     MIMTXRDATA                              => mim_tx_rdata,
     PIPECLK                                 => pipe_clk,
     PIPERX0CHANISALIGNED                    => pipe_rx0_chanisaligned,
     PIPERX0CHARISK                          => pipe_rx0_char_is_k,
     PIPERX0DATA                             => pipe_rx0_data,
     PIPERX0ELECIDLE                         => pipe_rx0_elec_idle,
     PIPERX0PHYSTATUS                        => pipe_rx0_phy_status,
     PIPERX0STATUS                           => pipe_rx0_status,
     PIPERX0VALID                            => pipe_rx0_valid,
     PIPERX1CHANISALIGNED                    => pipe_rx1_chanisaligned,
     PIPERX1CHARISK                          => pipe_rx1_char_is_k,
     PIPERX1DATA                             => pipe_rx1_data,
     PIPERX1ELECIDLE                         => pipe_rx1_elec_idle,
     PIPERX1PHYSTATUS                        => pipe_rx1_phy_status,
     PIPERX1STATUS                           => pipe_rx1_status,
     PIPERX1VALID                            => pipe_rx1_valid,
     PIPERX2CHANISALIGNED                    => pipe_rx2_chanisaligned,
     PIPERX2CHARISK                          => pipe_rx2_char_is_k,
     PIPERX2DATA                             => pipe_rx2_data,
     PIPERX2ELECIDLE                         => pipe_rx2_elec_idle,
     PIPERX2PHYSTATUS                        => pipe_rx2_phy_status,
     PIPERX2STATUS                           => pipe_rx2_status,
     PIPERX2VALID                            => pipe_rx2_valid,
     PIPERX3CHANISALIGNED                    => pipe_rx3_chanisaligned,
     PIPERX3CHARISK                          => pipe_rx3_char_is_k,
     PIPERX3DATA                             => pipe_rx3_data,
     PIPERX3ELECIDLE                         => pipe_rx3_elec_idle,
     PIPERX3PHYSTATUS                        => pipe_rx3_phy_status,
     PIPERX3STATUS                           => pipe_rx3_status,
     PIPERX3VALID                            => pipe_rx3_valid,
     PIPERX4CHANISALIGNED                    => pipe_rx4_chanisaligned,
     PIPERX4CHARISK                          => pipe_rx4_char_is_k,
     PIPERX4DATA                             => pipe_rx4_data,
     PIPERX4ELECIDLE                         => pipe_rx4_elec_idle,
     PIPERX4PHYSTATUS                        => pipe_rx4_phy_status,
     PIPERX4STATUS                           => pipe_rx4_status,
     PIPERX4VALID                            => pipe_rx4_valid,
     PIPERX5CHANISALIGNED                    => pipe_rx5_chanisaligned,
     PIPERX5CHARISK                          => pipe_rx5_char_is_k,
     PIPERX5DATA                             => pipe_rx5_data,
     PIPERX5ELECIDLE                         => pipe_rx5_elec_idle,
     PIPERX5PHYSTATUS                        => pipe_rx5_phy_status,
     PIPERX5STATUS                           => pipe_rx5_status,
     PIPERX5VALID                            => pipe_rx5_valid,
     PIPERX6CHANISALIGNED                    => pipe_rx6_chanisaligned,
     PIPERX6CHARISK                          => pipe_rx6_char_is_k,
     PIPERX6DATA                             => pipe_rx6_data,
     PIPERX6ELECIDLE                         => pipe_rx6_elec_idle,
     PIPERX6PHYSTATUS                        => pipe_rx6_phy_status,
     PIPERX6STATUS                           => pipe_rx6_status,
     PIPERX6VALID                            => pipe_rx6_valid,
     PIPERX7CHANISALIGNED                    => pipe_rx7_chanisaligned,
     PIPERX7CHARISK                          => pipe_rx7_char_is_k,
     PIPERX7DATA                             => pipe_rx7_data,
     PIPERX7ELECIDLE                         => pipe_rx7_elec_idle,
     PIPERX7PHYSTATUS                        => pipe_rx7_phy_status,
     PIPERX7STATUS                           => pipe_rx7_status,
     PIPERX7VALID                            => pipe_rx7_valid,
     PL2DIRECTEDLSTATE                       => pl2_directed_lstate,
     PLDBGMODE                               => pl_dbg_mode,
     PLDIRECTEDLINKAUTON                     => pl_directed_link_auton,
     PLDIRECTEDLINKCHANGE                    => pl_directed_link_change,
     PLDIRECTEDLINKSPEED                     => pl_directed_link_speed,
     PLDIRECTEDLINKWIDTH                     => pl_directed_link_width,
     PLDIRECTEDLTSSMNEW                      => pl_directed_ltssm_new,
     PLDIRECTEDLTSSMNEWVLD                   => pl_directed_ltssm_new_vld,
     PLDIRECTEDLTSSMSTALL                    => pl_directed_ltssm_stall,
     PLDOWNSTREAMDEEMPHSOURCE                => pl_downstream_deemph_source,
     PLRSTN                                  => pl_rst_n,
     PLTRANSMITHOTRST                        => pl_transmit_hot_rst,
     PLUPSTREAMPREFERDEEMPH                  => pl_upstream_prefer_deemph,
     SYSRSTN                                 => sys_rst_n,
     TL2ASPMSUSPENDCREDITCHECK               => tl2_aspm_suspend_credit_check,
     TL2PPMSUSPENDREQ                        => tl2_ppm_suspend_req,
     TLRSTN                                  => tl_rst_n,
     TRNFCSEL                                => trn_fc_sel,
     TRNRDSTRDY                              => trn_rdst_rdy,
     TRNRFCPRET                              => trn_rfcp_ret,
     TRNRNPOK                                => trn_rnp_ok,
     TRNRNPREQ                               => trn_rnp_req,
     TRNTCFGGNT                              => trn_tcfg_gnt,
     TRNTD                                   => trn_td_int,
     TRNTDLLPDATA                            => trn_tdllp_data,
     TRNTDLLPSRCRDY                          => trn_tdllp_src_rdy,
     TRNTECRCGEN                             => trn_tecrc_gen,
     TRNTEOF                                 => trn_teof,
     TRNTERRFWD                              => trn_terrfwd,
     TRNTREM                                 => trn_trem_int,
     TRNTSOF                                 => trn_tsof,
     TRNTSRCDSC                              => trn_tsrc_dsc,
     TRNTSRCRDY                              => trn_tsrc_rdy,
     TRNTSTR                                 => trn_tstr,
     USERCLK                                 => user_clk,
     USERCLK2                                => user_clk2
  );

end rtl;
