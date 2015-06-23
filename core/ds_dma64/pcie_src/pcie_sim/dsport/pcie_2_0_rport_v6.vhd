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
-- File       : pcie_2_0_rport_v6.vhd
-- Version    : 2.3
-- Description: Virtex6 solution wrapper : Root Port for PCI Express
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_2_0_rport_v6 is
   generic (
     REF_CLK_FREQ : integer := 0;		-- 0 - 100MHz, 1 - 125 MHz, 2 - 250 MHz
     PIPE_PIPELINE_STAGES : integer := 0;                -- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
     PCIE_DRP_ENABLE : boolean := FALSE;
     DS_PORT_HOT_RST : boolean := FALSE;               -- FALSE - for ROOT PORT(default), TRUE - for DOWNSTREAM PORT 
     LINK_CAP_MAX_LINK_WIDTH_int : integer := 8;
     LTSSM_MAX_LINK_WIDTH : bit_vector := X"01";
     AER_BASE_PTR : bit_vector := X"128";
     AER_CAP_ECRC_CHECK_CAPABLE : boolean := FALSE;
     AER_CAP_ECRC_GEN_CAPABLE : boolean := FALSE;
     AER_CAP_ID : bit_vector := X"1111";
     AER_CAP_INT_MSG_NUM_MSI : bit_vector := X"0A";
     AER_CAP_INT_MSG_NUM_MSIX : bit_vector := X"15";
     AER_CAP_NEXTPTR : bit_vector := X"160";
     AER_CAP_ON : boolean := FALSE;
     AER_CAP_PERMIT_ROOTERR_UPDATE : boolean := TRUE;
     AER_CAP_VERSION : bit_vector := X"1";
     ALLOW_X8_GEN2 : boolean := FALSE;
     BAR0 : bit_vector := X"00000000";		-- Memory aperture disabled
     BAR1 : bit_vector := X"00000000";		-- Memory aperture disabled
     BAR2 : bit_vector := X"00FFFFFF";		-- Constant for rport 
     BAR3 : bit_vector := X"FFFF0000";		-- IO Limit/Base Registers not implemented
     BAR4 : bit_vector := X"FFF0FFF0";		-- Constant for rport
     BAR5 : bit_vector := X"FFF1FFF1";		-- Prefetchable Memory Limit/Base Registers implemented
     CAPABILITIES_PTR : bit_vector := X"40";
     CARDBUS_CIS_POINTER : bit_vector := X"00000000";
     CLASS_CODE : bit_vector := X"060400";
     CMD_INTX_IMPLEMENTED : boolean := TRUE;
     CPL_TIMEOUT_DISABLE_SUPPORTED : boolean := FALSE;
     CPL_TIMEOUT_RANGES_SUPPORTED : bit_vector := X"0";
     CRM_MODULE_RSTS : bit_vector := X"00";
     DEVICE_ID : bit_vector := X"0007";
     DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE : boolean := TRUE;
     DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE : boolean := TRUE;
     DEV_CAP_ENDPOINT_L0S_LATENCY : integer := 0;
     DEV_CAP_ENDPOINT_L1_LATENCY : integer := 0;
     DEV_CAP_EXT_TAG_SUPPORTED : boolean := TRUE;
     DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : boolean := FALSE;
     DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer := 2;
     DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer := 0;
     DEV_CAP_ROLE_BASED_ERROR : boolean := TRUE;
     DEV_CAP_RSVD_14_12 : integer := 0;
     DEV_CAP_RSVD_17_16 : integer := 0;
     DEV_CAP_RSVD_31_29 : integer := 0;
     DEV_CONTROL_AUX_POWER_SUPPORTED : boolean := FALSE;
     DISABLE_ASPM_L1_TIMER : boolean := FALSE;
     DISABLE_BAR_FILTERING : boolean := TRUE;
     DISABLE_ID_CHECK : boolean := TRUE;
     DISABLE_LANE_REVERSAL : boolean := FALSE;
     DISABLE_RX_TC_FILTER : boolean := TRUE;
     DISABLE_SCRAMBLING : boolean := FALSE;
     DNSTREAM_LINK_NUM : bit_vector := X"00";
     DSN_BASE_PTR : bit_vector := X"100";
     DSN_CAP_ID : bit_vector := X"0003";
     DSN_CAP_NEXTPTR : bit_vector := X"01C";
     DSN_CAP_ON : boolean := TRUE;
     DSN_CAP_VERSION : bit_vector := X"1";
     ENABLE_MSG_ROUTE : bit_vector := X"000";
     ENABLE_RX_TD_ECRC_TRIM : boolean := FALSE;
     ENTER_RVRY_EI_L0 : boolean := TRUE;
     EXIT_LOOPBACK_ON_EI : boolean := TRUE;
     EXPANSION_ROM : bit_vector := X"00000000";		-- Memory aperture disabled
     EXT_CFG_CAP_PTR : bit_vector := X"3F";
     EXT_CFG_XP_CAP_PTR : bit_vector := X"3FF";
     HEADER_TYPE : bit_vector := X"01";
     INFER_EI : bit_vector := X"0C";
     INTERRUPT_PIN : bit_vector := X"01";
     IS_SWITCH : boolean := FALSE;
     LAST_CONFIG_DWORD : bit_vector := X"042";
     LINK_CAP_ASPM_SUPPORT : integer := 1;
     LINK_CAP_CLOCK_POWER_MANAGEMENT : boolean := FALSE;
     LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP : boolean := FALSE;
     LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
     LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
     LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer := 7;
     LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer := 7;
     LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
     LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
     LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer := 7;
     LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer := 7;
     LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP : boolean := FALSE;
     LINK_CAP_MAX_LINK_SPEED : bit_vector := X"1";
     LINK_CAP_MAX_LINK_WIDTH : bit_vector := X"08";
     LINK_CAP_RSVD_23_22 : integer := 0;
     LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE : boolean := FALSE;
     LINK_CONTROL_RCB : integer := 0;
     LINK_CTRL2_DEEMPHASIS : boolean := FALSE;
     LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE : boolean := FALSE;
     LINK_CTRL2_TARGET_LINK_SPEED : bit_vector := X"2";
     LINK_STATUS_SLOT_CLOCK_CONFIG : boolean := TRUE;
     LL_ACK_TIMEOUT : bit_vector := X"0000";
     LL_ACK_TIMEOUT_EN : boolean := FALSE;
     LL_ACK_TIMEOUT_FUNC : integer := 0;
     LL_REPLAY_TIMEOUT : bit_vector := X"0000";
     LL_REPLAY_TIMEOUT_EN : boolean := FALSE;
     LL_REPLAY_TIMEOUT_FUNC : integer := 0;
     MSIX_BASE_PTR : bit_vector := X"9C";
     MSIX_CAP_ID : bit_vector := X"11";
     MSIX_CAP_NEXTPTR : bit_vector := X"00";
     MSIX_CAP_ON : boolean := TRUE;
     MSIX_CAP_PBA_BIR : integer := 0;
     MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
     MSIX_CAP_TABLE_BIR : integer := 0;
     MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
     MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
     MSI_BASE_PTR : bit_vector := X"48";
     MSI_CAP_64_BIT_ADDR_CAPABLE : boolean := TRUE;
     MSI_CAP_ID : bit_vector := X"05";
     MSI_CAP_MULTIMSGCAP : integer := 0;
     MSI_CAP_MULTIMSG_EXTENSION : integer := 0;
     MSI_CAP_NEXTPTR : bit_vector := X"60";
     MSI_CAP_ON : boolean := TRUE;
     MSI_CAP_PER_VECTOR_MASKING_CAPABLE : boolean := TRUE;
     N_FTS_COMCLK_GEN1 : integer := 255;
     N_FTS_COMCLK_GEN2 : integer := 255;
     N_FTS_GEN1 : integer := 255;
     N_FTS_GEN2 : integer := 255;
     PCIE_BASE_PTR : bit_vector := X"60";
     PCIE_CAP_CAPABILITY_ID : bit_vector := X"10";
     PCIE_CAP_CAPABILITY_VERSION : bit_vector := X"2";
     PCIE_CAP_DEVICE_PORT_TYPE : bit_vector := X"4";
     PCIE_CAP_INT_MSG_NUM : bit_vector := X"00";
     PCIE_CAP_NEXTPTR : bit_vector := X"9C";
     PCIE_CAP_ON : boolean := TRUE;
     PCIE_CAP_RSVD_15_14 : integer := 0;
     PCIE_CAP_SLOT_IMPLEMENTED : boolean := TRUE;
     PCIE_REVISION : integer := 2;
     PGL0_LANE : integer := 0;
     PGL1_LANE : integer := 1;
     PGL2_LANE : integer := 2;
     PGL3_LANE : integer := 3;
     PGL4_LANE : integer := 4;
     PGL5_LANE : integer := 5;
     PGL6_LANE : integer := 6;
     PGL7_LANE : integer := 7;
     PL_AUTO_CONFIG : integer := 0;
     PL_FAST_TRAIN : boolean := FALSE;
     PM_BASE_PTR : bit_vector := X"40";
     PM_CAP_AUXCURRENT : integer := 0;
     PM_CAP_D1SUPPORT : boolean := TRUE;
     PM_CAP_D2SUPPORT : boolean := TRUE;
     PM_CAP_DSI : boolean := FALSE;
     PM_CAP_ID : bit_vector := X"11";
     PM_CAP_NEXTPTR : bit_vector := X"48";
     PM_CAP_ON : boolean := TRUE;
     PM_CAP_PMESUPPORT : bit_vector := X"0F";
     PM_CAP_PME_CLOCK : boolean := FALSE;
     PM_CAP_RSVD_04 : integer := 0;
     PM_CAP_VERSION : integer := 3;
     PM_CSR_B2B3 : boolean := FALSE;
     PM_CSR_BPCCEN : boolean := FALSE;
     PM_CSR_NOSOFTRST : boolean := TRUE;
     PM_DATA0 : bit_vector := X"01";
     PM_DATA1 : bit_vector := X"01";
     PM_DATA2 : bit_vector := X"01";
     PM_DATA3 : bit_vector := X"01";
     PM_DATA4 : bit_vector := X"01";
     PM_DATA5 : bit_vector := X"01";
     PM_DATA6 : bit_vector := X"01";
     PM_DATA7 : bit_vector := X"01";
     PM_DATA_SCALE0 : bit_vector := X"1";
     PM_DATA_SCALE1 : bit_vector := X"1";
     PM_DATA_SCALE2 : bit_vector := X"1";
     PM_DATA_SCALE3 : bit_vector := X"1";
     PM_DATA_SCALE4 : bit_vector := X"1";
     PM_DATA_SCALE5 : bit_vector := X"1";
     PM_DATA_SCALE6 : bit_vector := X"1";
     PM_DATA_SCALE7 : bit_vector := X"1";
     RECRC_CHK : integer := 0;
     RECRC_CHK_TRIM : boolean := FALSE;
     REVISION_ID : bit_vector := X"00";
     ROOT_CAP_CRS_SW_VISIBILITY : boolean := FALSE;
     SELECT_DLL_IF : boolean := FALSE;
     SIM_VERSION : string := "1.0";
     SLOT_CAP_ATT_BUTTON_PRESENT : boolean := FALSE;
     SLOT_CAP_ATT_INDICATOR_PRESENT : boolean := FALSE;
     SLOT_CAP_ELEC_INTERLOCK_PRESENT : boolean := FALSE;
     SLOT_CAP_HOTPLUG_CAPABLE : boolean := FALSE;
     SLOT_CAP_HOTPLUG_SURPRISE : boolean := FALSE;
     SLOT_CAP_MRL_SENSOR_PRESENT : boolean := FALSE;
     SLOT_CAP_NO_CMD_COMPLETED_SUPPORT : boolean := FALSE;
     SLOT_CAP_PHYSICAL_SLOT_NUM : bit_vector := X"0000";
     SLOT_CAP_POWER_CONTROLLER_PRESENT : boolean := FALSE;
     SLOT_CAP_POWER_INDICATOR_PRESENT : boolean := FALSE;
     SLOT_CAP_SLOT_POWER_LIMIT_SCALE : integer := 0;
     SLOT_CAP_SLOT_POWER_LIMIT_VALUE : bit_vector := X"00";
     SPARE_BIT0 : integer := 0;
     SPARE_BIT1 : integer := 0;
     SPARE_BIT2 : integer := 0;
     SPARE_BIT3 : integer := 0;
     SPARE_BIT4 : integer := 0;
     SPARE_BIT5 : integer := 0;
     SPARE_BIT6 : integer := 0;
     SPARE_BIT7 : integer := 0;
     SPARE_BIT8 : integer := 0;
     SPARE_BYTE0 : bit_vector := X"00";
     SPARE_BYTE1 : bit_vector := X"00";
     SPARE_BYTE2 : bit_vector := X"00";
     SPARE_BYTE3 : bit_vector := X"00";
     SPARE_WORD0 : bit_vector := X"00000000";
     SPARE_WORD1 : bit_vector := X"00000000";
     SPARE_WORD2 : bit_vector := X"00000000";
     SPARE_WORD3 : bit_vector := X"00000000";
     SUBSYSTEM_ID : bit_vector := X"0007";
     SUBSYSTEM_VENDOR_ID : bit_vector := X"10EE";
     TL_RBYPASS : boolean := FALSE;
     TL_RX_RAM_RADDR_LATENCY : integer := 0;
     TL_RX_RAM_RDATA_LATENCY : integer := 2;
     TL_RX_RAM_WRITE_LATENCY : integer := 0;
     TL_TFC_DISABLE : boolean := FALSE;
     TL_TX_CHECKS_DISABLE : boolean := FALSE;
     TL_TX_RAM_RADDR_LATENCY : integer := 0;
     TL_TX_RAM_RDATA_LATENCY : integer := 2;
     TL_TX_RAM_WRITE_LATENCY : integer := 0;
     UPCONFIG_CAPABLE : boolean := TRUE;
     UPSTREAM_FACING : boolean := FALSE;
     UR_INV_REQ : boolean := TRUE;
     USER_CLK_FREQ : integer := 3;
     VC0_CPL_INFINITE : boolean := TRUE;
     VC0_RX_RAM_LIMIT : bit_vector := X"03FF";
     VC0_TOTAL_CREDITS_CD : integer := 127;
     VC0_TOTAL_CREDITS_CH : integer := 31;
     VC0_TOTAL_CREDITS_NPH : integer := 12;
     VC0_TOTAL_CREDITS_PD : integer := 288;
     VC0_TOTAL_CREDITS_PH : integer := 32;
     VC0_TX_LASTPACKET : integer := 31;
     VC_BASE_PTR : bit_vector := X"10C";
     VC_CAP_ID : bit_vector := X"0002";
     VC_CAP_NEXTPTR : bit_vector := X"128";
     VC_CAP_ON : boolean := TRUE;
     VC_CAP_REJECT_SNOOP_TRANSACTIONS : boolean := FALSE;
     VC_CAP_VERSION : bit_vector := X"1";
     VENDOR_ID : bit_vector := X"10EE";
     VSEC_BASE_PTR : bit_vector := X"160";
     VSEC_CAP_HDR_ID : bit_vector := X"1234";
     VSEC_CAP_HDR_LENGTH : bit_vector := X"018";
     VSEC_CAP_HDR_REVISION : bit_vector := X"1";
     VSEC_CAP_ID : bit_vector := X"000B";
     VSEC_CAP_IS_LINK_VISIBLE : boolean := TRUE;
     VSEC_CAP_NEXTPTR : bit_vector := X"000";
     VSEC_CAP_ON : boolean := TRUE;
     VSEC_CAP_VERSION : bit_vector := X"1"
   );
   port (
      ---------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface
      ---------------------------------------------------------
      
      -- Tx
      pci_exp_txp                                  : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      pci_exp_txn                                  : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      
      -- Rx
      pci_exp_rxp                                  : in std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      pci_exp_rxn                                  : in std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      
      ---------------------------------------------------------
      -- 2. Transaction (TRN) Interface
      ---------------------------------------------------------
      
      -- Common
      
      trn_clk                                      : out std_logic;
      trn_reset_n                                  : out std_logic;
      trn_lnk_up_n                                 : out std_logic;
      
      -- Tx
      trn_tbuf_av                                  : out std_logic_vector(5 downto 0);
      trn_tcfg_req_n                               : out std_logic;
      trn_terr_drop_n                              : out std_logic;
      trn_tdst_rdy_n                               : out std_logic;
      trn_td                                       : in std_logic_vector(63 downto 0);
      trn_trem_n                                   : in std_logic;
      trn_tsof_n                                   : in std_logic;
      trn_teof_n                                   : in std_logic;
      trn_tsrc_rdy_n                               : in std_logic;
      trn_tsrc_dsc_n                               : in std_logic;
      trn_terrfwd_n                                : in std_logic;
      trn_tcfg_gnt_n                               : in std_logic;
      trn_tstr_n                                   : in std_logic;
      
      -- Rx
      trn_rd                                       : out std_logic_vector(63 downto 0);
      trn_rrem_n                                   : out std_logic;
      trn_rsof_n                                   : out std_logic;
      trn_reof_n                                   : out std_logic;
      trn_rsrc_rdy_n                               : out std_logic;
      trn_rsrc_dsc_n                               : out std_logic;
      trn_rerrfwd_n                                : out std_logic;
      trn_rbar_hit_n                               : out std_logic_vector(6 downto 0);
      trn_rdst_rdy_n                               : in std_logic;
      trn_rnp_ok_n                                 : in std_logic;
      trn_recrc_err_n                              : out std_logic;
      
      -- Flow Control
      trn_fc_cpld                                  : out std_logic_vector(11 downto 0);
      trn_fc_cplh                                  : out std_logic_vector(7 downto 0);
      trn_fc_npd                                   : out std_logic_vector(11 downto 0);
      trn_fc_nph                                   : out std_logic_vector(7 downto 0);
      trn_fc_pd                                    : out std_logic_vector(11 downto 0);
      trn_fc_ph                                    : out std_logic_vector(7 downto 0);
      trn_fc_sel                                   : in std_logic_vector(2 downto 0);

      ---------------------------------------------------------
      -- 3. Configuration (CFG) Interface
      ---------------------------------------------------------
      
      cfg_do                                       : out std_logic_vector(31 downto 0);
      cfg_rd_wr_done_n                             : out std_logic;
      cfg_di                                       : in std_logic_vector(31 downto 0);
      cfg_byte_en_n                                : in std_logic_vector(3 downto 0);
      cfg_dwaddr                                   : in std_logic_vector(9 downto 0);
      cfg_wr_en_n                                  : in std_logic;
      cfg_wr_rw1c_as_rw_n                          : in std_logic;
      cfg_rd_en_n                                  : in std_logic;

      cfg_err_cor_n                                : in std_logic;
      cfg_err_ur_n                                 : in std_logic;
      cfg_err_ecrc_n                               : in std_logic;
      cfg_err_cpl_timeout_n                        : in std_logic;
      cfg_err_cpl_abort_n                          : in std_logic;
      cfg_err_cpl_unexpect_n                       : in std_logic;
      cfg_err_posted_n                             : in std_logic;
      cfg_err_locked_n                             : in std_logic;
      cfg_err_tlp_cpl_header                       : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy_n                            : out std_logic;
      cfg_interrupt_n                              : in std_logic;
      cfg_interrupt_rdy_n                          : out std_logic;
      cfg_interrupt_assert_n                       : in std_logic;
      cfg_interrupt_di                             : in std_logic_vector(7 downto 0);
      cfg_interrupt_do                             : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                       : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                      : out std_logic;
      cfg_interrupt_msixenable                     : out std_logic;
      cfg_interrupt_msixfm                         : out std_logic;
      cfg_trn_pending_n                            : in std_logic;
      cfg_pm_send_pme_to_n                         : in std_logic;
      cfg_status                                   : out std_logic_vector(15 downto 0);
      cfg_command                                  : out std_logic_vector(15 downto 0);
      cfg_dstatus                                  : out std_logic_vector(15 downto 0);
      cfg_dcommand                                 : out std_logic_vector(15 downto 0);
      cfg_lstatus                                  : out std_logic_vector(15 downto 0);
      cfg_lcommand                                 : out std_logic_vector(15 downto 0);
      cfg_dcommand2                                : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state_n                        : out std_logic_vector(2 downto 0);
      cfg_dsn                                      : in std_logic_vector(63 downto 0);
      cfg_pmcsr_pme_en                             : out std_logic;
      cfg_pmcsr_pme_status                         : out std_logic;
      cfg_pmcsr_powerstate                         : out std_logic_vector(1 downto 0);

      cfg_msg_received                             : out std_logic;
      cfg_msg_data                                 : out std_logic_vector(15 downto 0);
      cfg_msg_received_err_cor                     : out std_logic;
      cfg_msg_received_err_non_fatal               : out std_logic;
      cfg_msg_received_err_fatal                   : out std_logic;
      cfg_msg_received_pme_to_ack                  : out std_logic;
      cfg_msg_received_assert_inta                 : out std_logic;
      cfg_msg_received_assert_intb                 : out std_logic;
      cfg_msg_received_assert_intc                 : out std_logic;
      cfg_msg_received_assert_intd                 : out std_logic;
      cfg_msg_received_deassert_inta               : out std_logic;
      cfg_msg_received_deassert_intb               : out std_logic;
      cfg_msg_received_deassert_intc               : out std_logic;
      cfg_msg_received_deassert_intd               : out std_logic;

      cfg_ds_bus_number                            : in std_logic_vector(7 downto 0);
      cfg_ds_device_number                         : in std_logic_vector(4 downto 0);

      ---------------------------------------------------------
      -- 4. Physical Layer Control and Status (PL) Interface
      ---------------------------------------------------------
      
      pl_initial_link_width                        : out std_logic_vector(2 downto 0);
      pl_lane_reversal_mode                        : out std_logic_vector(1 downto 0);
      pl_link_gen2_capable                         : out std_logic;
      pl_link_partner_gen2_supported               : out std_logic;
      pl_link_upcfg_capable                        : out std_logic;
      pl_ltssm_state                               : out std_logic_vector(5 downto 0);
      pl_sel_link_rate                             : out std_logic;
      pl_sel_link_width                            : out std_logic_vector(1 downto 0);
      pl_directed_link_auton                       : in std_logic;
      pl_directed_link_change                      : in std_logic_vector(1 downto 0);
      pl_directed_link_speed                       : in std_logic;
      pl_directed_link_width                       : in std_logic_vector(1 downto 0);
      pl_upstream_prefer_deemph                    : in std_logic;
      pl_transmit_hot_rst                          : in std_logic;
      
      ---------------------------------------------------------
      -- 5. PCIe DRP (PCIe DRP) Interface
      ---------------------------------------------------------
      
      pcie_drp_clk                              : in std_logic;
      pcie_drp_den                              : in std_logic;
      pcie_drp_dwe                              : in std_logic;
      pcie_drp_daddr                            : in std_logic_vector(8 downto 0);
      pcie_drp_di                               : in std_logic_vector(15 downto 0);
      pcie_drp_do                               : out std_logic_vector(15 downto 0);
      pcie_drp_drdy                             : out std_logic;
      
      ---------------------------------------------------------
      -- 6. System  (SYS) Interface
      ---------------------------------------------------------
      
      sys_clk                                      : in std_logic;
      sys_reset_n                                  : in std_logic
   );
end pcie_2_0_rport_v6;

architecture v6_pcie of pcie_2_0_rport_v6 is
   
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
      IS_ENDPOINT    : boolean;
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

  component pcie_2_0_v6_rp
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
      PCIEXPRXN                           : in  std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      PCIEXPRXP                           : in  std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      PCIEXPTXN                           : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      PCIEXPTXP                           : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int - 1 downto 0);
      SYSCLK                              : in  std_logic;
      FUNDRSTN                            : in  std_logic;
      TRNLNKUPN                           : out std_logic;
      TRNCLK                              : out std_logic;
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

  FUNCTION to_integer (
      val_in    : bit_vector) RETURN integer IS
      
      CONSTANT vctr   : bit_vector(val_in'high-val_in'low DOWNTO 0) := val_in;
      VARIABLE ret    : integer := 0;
   BEGIN
      FOR index IN vctr'RANGE LOOP
         IF (vctr(index) = '1') THEN
            ret := ret + (2**index);
         END IF;
      END LOOP;
      RETURN(ret);
   END to_integer;
         
   FUNCTION to_stdlogic (
      in_val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (in_val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

   function lp_lnk_bw_notif (
     link_width : integer;
     link_spd   : integer)
     return boolean is
   begin  -- lp_lnk_bw_notif
     if ((link_width > 1) or (link_spd > 1)) then 
      return true;
     else
       return false;
     end if;
   end lp_lnk_bw_notif;

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

   constant LP_LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP  : boolean := lp_lnk_bw_notif(LINK_CAP_MAX_LINK_WIDTH_int, LINK_CAP_MAX_LINK_SPEED_int);

   constant LINK_STATUS_SLOT_CLOCK_CONFIG_lstatus : std_logic := to_stdlogic(LINK_STATUS_SLOT_CLOCK_CONFIG);

   signal rx_func_level_reset_n                       : std_logic;

   signal block_clk                                   : std_logic;
   
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
   signal cfg_link_status_auto_bandwidth_status       : std_logic;
   signal cfg_link_status_bandwidth_status            : std_logic;
   signal cfg_link_status_dll_active                  : std_logic;
   signal cfg_link_status_link_training               : std_logic;
   signal cfg_link_status_negotiated_link_width       : std_logic_vector(3 downto 0);
   signal cfg_link_status_current_speed               : std_logic_vector(1 downto 0);
   
   signal sys_reset_n_d                               : std_logic;
   signal phy_rdy_n                                   : std_logic;
   
   signal trn_lnk_up_n_int                            : std_logic;
   signal trn_lnk_up_n_int1                           : std_logic;
   
   signal trn_reset_n_int                             : std_logic;
   signal trn_reset_n_int1                            : std_logic;
   

   signal TxOutClk                                    : std_logic;
   signal TxOutClk_bufg                               : std_logic;
   
   signal gt_pll_lock                                 : std_logic;
   
   signal user_clk                                    : std_logic;
   signal drp_clk                                     : std_logic;
   signal clock_locked                                : std_logic;
   -- X-HDL generated signals

   signal v6pcie63 : std_logic;
   signal v6pcie64 : std_logic;
   signal v6pcie65 : std_logic;
   signal v6pcie66 : std_logic;
   signal v6pcie67 : std_logic;
   signal v6pcie68 : std_logic_vector(1 downto 0);
   signal v6pcie69 : std_logic;
   signal func_lvl_rstn : std_logic;
   signal cm_rstn : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal pci_exp_txp_v6pcie28                        : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
   signal pci_exp_txn_v6pcie27                        : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
   signal trn_clk_v6pcie41                            : std_logic;
   signal trn_reset_n_v6pcie54                        : std_logic;
   signal trn_lnk_up_n_v6pcie48                       : std_logic;
   signal trn_tbuf_av_v6pcie59                        : std_logic_vector(5 downto 0);
   signal trn_tcfg_req_n_v6pcie60                     : std_logic;
   signal trn_terr_drop_n_v6pcie62                    : std_logic;
   signal trn_tdst_rdy_n_v6pcie61                     : std_logic;
   signal trn_rd_v6pcie50                             : std_logic_vector(63 downto 0);
   signal trn_rrem_n_v6pcie55                         : std_logic;
   signal trn_rsof_n_v6pcie56                         : std_logic;
   signal trn_reof_n_v6pcie52                         : std_logic;
   signal trn_rsrc_rdy_n_v6pcie58                     : std_logic;
   signal trn_rsrc_dsc_n_v6pcie57                     : std_logic;
   signal trn_rerrfwd_n_v6pcie53                      : std_logic;
   signal trn_rbar_hit_n_v6pcie49                     : std_logic_vector(6 downto 0);
   signal trn_recrc_err_n_v6pcie51                    : std_logic;
   signal trn_fc_cpld_v6pcie42                        : std_logic_vector(11 downto 0);
   signal trn_fc_cplh_v6pcie43                        : std_logic_vector(7 downto 0);
   signal trn_fc_npd_v6pcie44                         : std_logic_vector(11 downto 0);
   signal trn_fc_nph_v6pcie45                         : std_logic_vector(7 downto 0);
   signal trn_fc_pd_v6pcie46                          : std_logic_vector(11 downto 0);
   signal trn_fc_ph_v6pcie47                          : std_logic_vector(7 downto 0);
   signal cfg_err_cpl_rdy_n_v6pcie1                   : std_logic;
   signal cfg_interrupt_rdy_n_v6pcie7                 : std_logic;
   signal cfg_interrupt_do_v6pcie2                    : std_logic_vector(7 downto 0);
   signal cfg_interrupt_mmenable_v6pcie3              : std_logic_vector(2 downto 0);
   signal cfg_interrupt_msienable_v6pcie4             : std_logic;
   signal cfg_interrupt_msixenable_v6pcie5            : std_logic;
   signal cfg_interrupt_msixfm_v6pcie6                : std_logic;
   signal cfg_pcie_link_state_n_v6pcie22              : std_logic_vector(2 downto 0);
   signal cfg_pmcsr_pme_en_v6pcie23                   : std_logic;
   signal cfg_pmcsr_pme_status_v6pcie24               : std_logic;
   signal cfg_pmcsr_powerstate_v6pcie25               : std_logic_vector(1 downto 0);
   signal cfg_msg_received_v6pcie9                    : std_logic;
   signal cfg_msg_data_v6pcie8                        : std_logic_vector(15 downto 0);
   signal cfg_msg_received_err_cor_v6pcie18           : std_logic;
   signal cfg_msg_received_err_non_fatal_v6pcie20     : std_logic;
   signal cfg_msg_received_err_fatal_v6pcie19         : std_logic;
   signal cfg_msg_received_pme_to_ack_v6pcie21        : std_logic;
   signal cfg_msg_received_assert_inta_v6pcie10       : std_logic;
   signal cfg_msg_received_assert_intb_v6pcie11       : std_logic;
   signal cfg_msg_received_assert_intc_v6pcie12       : std_logic;
   signal cfg_msg_received_assert_intd_v6pcie13       : std_logic;
   signal cfg_msg_received_deassert_inta_v6pcie14     : std_logic;
   signal cfg_msg_received_deassert_intb_v6pcie15     : std_logic;
   signal cfg_msg_received_deassert_intc_v6pcie16     : std_logic;
   signal cfg_msg_received_deassert_intd_v6pcie17     : std_logic;
   signal pipe_clk                                    : std_logic;
   signal pl_phy_lnk_up_n                             : std_logic;
   signal pl_initial_link_width_v6pcie32              : std_logic_vector(2 downto 0);
   signal pl_lane_reversal_mode_v6pcie33              : std_logic_vector(1 downto 0);
   signal pl_link_gen2_capable_v6pcie34               : std_logic;
   signal pl_link_partner_gen2_supported_v6pcie35     : std_logic;
   signal pl_link_upcfg_capable_v6pcie36              : std_logic;
   signal pl_ltssm_state_v6pcie37                     : std_logic_vector(5 downto 0);
   signal pl_sel_link_rate_v6pcie39                   : std_logic;
   signal pl_sel_link_width_v6pcie40                  : std_logic_vector(1 downto 0);
   signal pcie_drp_do_v6pcie29                        : std_logic_vector(15 downto 0);
   signal pcie_drp_drdy_v6pcie30                      : std_logic;
begin
   -- Drive referenced outputs
   pci_exp_txp <= pci_exp_txp_v6pcie28;
   pci_exp_txn <= pci_exp_txn_v6pcie27;
   trn_clk <= trn_clk_v6pcie41;
   trn_reset_n <= trn_reset_n_v6pcie54;
   trn_lnk_up_n <= trn_lnk_up_n_v6pcie48;
   trn_tbuf_av <= trn_tbuf_av_v6pcie59;
   trn_tcfg_req_n <= trn_tcfg_req_n_v6pcie60;
   trn_terr_drop_n <= trn_terr_drop_n_v6pcie62;
   trn_tdst_rdy_n <= trn_tdst_rdy_n_v6pcie61;
   trn_rd <= trn_rd_v6pcie50;
   trn_rrem_n <= trn_rrem_n_v6pcie55;
   trn_rsof_n <= trn_rsof_n_v6pcie56;
   trn_reof_n <= trn_reof_n_v6pcie52;
   trn_rsrc_rdy_n <= trn_rsrc_rdy_n_v6pcie58;
   trn_rsrc_dsc_n <= trn_rsrc_dsc_n_v6pcie57;
   trn_rerrfwd_n <= trn_rerrfwd_n_v6pcie53;
   trn_rbar_hit_n <= trn_rbar_hit_n_v6pcie49;
   trn_recrc_err_n <= trn_recrc_err_n_v6pcie51;
   trn_fc_cpld <= trn_fc_cpld_v6pcie42;
   trn_fc_cplh <= trn_fc_cplh_v6pcie43;
   trn_fc_npd <= trn_fc_npd_v6pcie44;
   trn_fc_nph <= trn_fc_nph_v6pcie45;
   trn_fc_pd <= trn_fc_pd_v6pcie46;
   trn_fc_ph <= trn_fc_ph_v6pcie47;
   cfg_err_cpl_rdy_n <= cfg_err_cpl_rdy_n_v6pcie1;
   cfg_interrupt_rdy_n <= cfg_interrupt_rdy_n_v6pcie7;
   cfg_interrupt_do <= cfg_interrupt_do_v6pcie2;
   cfg_interrupt_mmenable <= cfg_interrupt_mmenable_v6pcie3;
   cfg_interrupt_msienable <= cfg_interrupt_msienable_v6pcie4;
   cfg_interrupt_msixenable <= cfg_interrupt_msixenable_v6pcie5;
   cfg_interrupt_msixfm <= cfg_interrupt_msixfm_v6pcie6;
   cfg_pcie_link_state_n <= cfg_pcie_link_state_n_v6pcie22;
   cfg_pmcsr_pme_en <= cfg_pmcsr_pme_en_v6pcie23;
   cfg_pmcsr_pme_status <= cfg_pmcsr_pme_status_v6pcie24;
   cfg_pmcsr_powerstate <= cfg_pmcsr_powerstate_v6pcie25;
   cfg_msg_received <= cfg_msg_received_v6pcie9;
   cfg_msg_data <= cfg_msg_data_v6pcie8;
   cfg_msg_received_err_cor <= cfg_msg_received_err_cor_v6pcie18;
   cfg_msg_received_err_non_fatal <= cfg_msg_received_err_non_fatal_v6pcie20;
   cfg_msg_received_err_fatal <= cfg_msg_received_err_fatal_v6pcie19;
   cfg_msg_received_pme_to_ack <= cfg_msg_received_pme_to_ack_v6pcie21;
   cfg_msg_received_assert_inta <= cfg_msg_received_assert_inta_v6pcie10;
   cfg_msg_received_assert_intb <= cfg_msg_received_assert_intb_v6pcie11;
   cfg_msg_received_assert_intc <= cfg_msg_received_assert_intc_v6pcie12;
   cfg_msg_received_assert_intd <= cfg_msg_received_assert_intd_v6pcie13;
   cfg_msg_received_deassert_inta <= cfg_msg_received_deassert_inta_v6pcie14;
   cfg_msg_received_deassert_intb <= cfg_msg_received_deassert_intb_v6pcie15;
   cfg_msg_received_deassert_intc <= cfg_msg_received_deassert_intc_v6pcie16;
   cfg_msg_received_deassert_intd <= cfg_msg_received_deassert_intd_v6pcie17;
   pl_initial_link_width <= pl_initial_link_width_v6pcie32;
   pl_lane_reversal_mode <= pl_lane_reversal_mode_v6pcie33;
   pl_link_gen2_capable <= pl_link_gen2_capable_v6pcie34;
   pl_link_partner_gen2_supported <= pl_link_partner_gen2_supported_v6pcie35;
   pl_link_upcfg_capable <= pl_link_upcfg_capable_v6pcie36;
   pl_ltssm_state <= pl_ltssm_state_v6pcie37;
   pl_sel_link_rate <= pl_sel_link_rate_v6pcie39;
   pl_sel_link_width <= pl_sel_link_width_v6pcie40;
   pcie_drp_do <= pcie_drp_do_v6pcie29;
   pcie_drp_drdy <= pcie_drp_drdy_v6pcie30;

   -- assigns to outputs
   
   cfg_status <= "0000000000000000";

   cfg_command <= ("00000" & 
                   cfg_cmd_intdis & 
                   '0' & 
                   cfg_cmd_serr_en & 
                   "00000" & 
                   cfg_cmd_bme & 
                   cfg_cmd_mem_en & 
                   cfg_cmd_io_en);

   cfg_dstatus <= ("0000000000" & 
                    cfg_trn_pending_n & 
                    '0' & 
                    cfg_dev_status_ur_detected & 
                    cfg_dev_status_fatal_err_detected & 
                    cfg_dev_status_nonfatal_err_detected & 
                    cfg_dev_status_corr_err_detected);

   cfg_dcommand <= ('0' & 
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

   cfg_lstatus <= (cfg_link_status_auto_bandwidth_status & 
                   cfg_link_status_bandwidth_status & 
                   cfg_link_status_dll_active & 
                   LINK_STATUS_SLOT_CLOCK_CONFIG_lstatus & 
                   cfg_link_status_link_training & 
                   '0' & 
                   ("00" & cfg_link_status_negotiated_link_width) & 
                   ("00" & cfg_link_status_current_speed));

   cfg_lcommand <= ("0000" & 
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

   cfg_dcommand2 <= ("00000000000" & 
                     cfg_dev_control2_cpltimeout_dis & 
                     cfg_dev_control2_cpltimeout_val);
   
   
   -- Generate trn_lnk_up_n
   
   trn_lnk_up_n_i : FDCP
      generic map (
         INIT  => '1'
      )
      port map (
         Q    => trn_lnk_up_n_v6pcie48,
         D    => trn_lnk_up_n_int1,
         C    => trn_clk_v6pcie41,
         CLR  => '0',
         PRE  => '0'
      );
   
   
   trn_lnk_up_n_int_i : FDCP
      generic map (
         INIT  => '1'
      )
      port map (
         Q    => trn_lnk_up_n_int1,
         D    => trn_lnk_up_n_int,
         C    => trn_clk_v6pcie41,
         CLR  => '0',
         PRE  => '0'
      );
   
   
   -- Generate trn_reset_n
   
   v6pcie63 <= trn_reset_n_int1 and not(phy_rdy_n);
   v6pcie64 <= not(sys_reset_n_d);

   -- Generate trn_reset_n
   
   trn_reset_n_i : FDCP
      generic map (
         INIT  => '0'
      )
      port map (
         Q    => trn_reset_n_v6pcie54,
         D    => v6pcie63,
         C    => trn_clk_v6pcie41,
         CLR  => v6pcie64,
         PRE  => '0'
      );
   
   v6pcie65 <= trn_reset_n_int and not(phy_rdy_n);
   v6pcie66 <= not(sys_reset_n_d);

   trn_reset_n_int_i : FDCP
      generic map (
         INIT  => '0'
      )
      port map (
         Q    => trn_reset_n_int1,
         D    => v6pcie65,
         C    => trn_clk_v6pcie41,
         CLR  => v6pcie66,
         PRE  => '0'
      );
   
   
   ---------------------------------------------------------
   -- PCI Express Reset Delay Module
   ---------------------------------------------------------
   
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
         IS_ENDPOINT     => FALSE,
         CAP_LINK_WIDTH  => LINK_CAP_MAX_LINK_WIDTH_int,
         CAP_LINK_SPEED  => LINK_CAP_MAX_LINK_SPEED_int,
         REF_CLK_FREQ    => REF_CLK_FREQ,
         USER_CLK_FREQ   => USER_CLK_FREQ
      )
      port map (
         sys_clk        => TxOutClk,
         gt_pll_lock    => gt_pll_lock,
         sel_lnk_rate   => pl_sel_link_rate_v6pcie39,
         sel_lnk_width  => pl_sel_link_width_v6pcie40,
         sys_clk_bufg   => TxOutClk_bufg,
         pipe_clk       => pipe_clk,
         user_clk       => user_clk,
         block_clk      => open,
         drp_clk        => drp_clk,
         clock_locked   => clock_locked
      );
   
   ---------------------------------------------------------
   -- Virtex6 PCI Express Block Module
   ---------------------------------------------------------
   
   
   
   
   v6pcie67 <= not(phy_rdy_n);
   
   -- Debug
   -- Debug
   -- Debug
   v6pcie68 <= pl_directed_link_change;
   v6pcie69 <= pl_directed_link_speed;

   func_lvl_rstn <= not(pl_transmit_hot_rst) when DS_PORT_HOT_RST else
                    '1';
   cm_rstn <= not(pl_transmit_hot_rst) when DS_PORT_HOT_RST else
              '1';

   pcie_2_0_i : pcie_2_0_v6_rp
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
         LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP  => LP_LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP,
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
         PCIEXPTXN                            => pci_exp_txn_v6pcie27,
         PCIEXPTXP                            => pci_exp_txp_v6pcie28,
         SYSCLK                               => sys_clk,
         TRNLNKUPN                            => trn_lnk_up_n_int,
         TRNCLK                               => trn_clk_v6pcie41,
         FUNDRSTN                             => sys_reset_n_d,
         PHYRDYN                              => phy_rdy_n,
         LNKCLKEN                             => open,
         USERRSTN                             => trn_reset_n_int,
         RECEIVEDFUNCLVLRSTN                  => rx_func_level_reset_n,
         SYSRSTN                              => v6pcie67,
         PLRSTN                               => '1',
         DLRSTN                               => '1',
         TLRSTN                               => '1',
         FUNCLVLRSTN                          => func_lvl_rstn,
         CMRSTN                               => cm_rstn,
         CMSTICKYRSTN                         => '1',

         TRNRBARHITN                          => trn_rbar_hit_n_v6pcie49,
         TRNRD                                => trn_rd_v6pcie50,
         TRNRECRCERRN                         => trn_recrc_err_n_v6pcie51,
         TRNREOFN                             => trn_reof_n_v6pcie52,
         TRNRERRFWDN                          => trn_rerrfwd_n_v6pcie53,
         TRNRREMN                             => trn_rrem_n_v6pcie55,
         TRNRSOFN                             => trn_rsof_n_v6pcie56,
         TRNRSRCDSCN                          => trn_rsrc_dsc_n_v6pcie57,
         TRNRSRCRDYN                          => trn_rsrc_rdy_n_v6pcie58,
         TRNRDSTRDYN                          => trn_rdst_rdy_n,
         TRNRNPOKN                            => trn_rnp_ok_n,

         TRNTBUFAV                            => trn_tbuf_av_v6pcie59,
         TRNTCFGREQN                          => trn_tcfg_req_n_v6pcie60,
         TRNTDLLPDSTRDYN                      => open,
         TRNTDSTRDYN                          => trn_tdst_rdy_n_v6pcie61,
         TRNTERRDROPN                         => trn_terr_drop_n_v6pcie62,
         TRNTCFGGNTN                          => trn_tcfg_gnt_n,
         TRNTD                                => trn_td,
         TRNTDLLPDATA                         => "00000000000000000000000000000000",
         TRNTDLLPSRCRDYN                      => '1',
         TRNTECRCGENN                         => '1',
         TRNTEOFN                             => trn_teof_n,
         TRNTERRFWDN                          => trn_terrfwd_n,
         TRNTREMN                             => trn_trem_n,
         TRNTSOFN                             => trn_tsof_n,
         TRNTSRCDSCN                          => trn_tsrc_dsc_n,
         TRNTSRCRDYN                          => trn_tsrc_rdy_n,
         TRNTSTRN                             => trn_tstr_n,
         TRNFCCPLD                            => trn_fc_cpld_v6pcie42,
         TRNFCCPLH                            => trn_fc_cplh_v6pcie43,
         TRNFCNPD                             => trn_fc_npd_v6pcie44,
         TRNFCNPH                             => trn_fc_nph_v6pcie45,
         TRNFCPD                              => trn_fc_pd_v6pcie46,
         TRNFCPH                              => trn_fc_ph_v6pcie47,
         TRNFCSEL                             => trn_fc_sel,
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
         CFGERRCPLRDYN                        => cfg_err_cpl_rdy_n_v6pcie1,
         CFGINTERRUPTDO                       => cfg_interrupt_do_v6pcie2,
         CFGINTERRUPTMMENABLE                 => cfg_interrupt_mmenable_v6pcie3,
         CFGINTERRUPTMSIENABLE                => cfg_interrupt_msienable_v6pcie4,
         CFGINTERRUPTMSIXENABLE               => cfg_interrupt_msixenable_v6pcie5,
         CFGINTERRUPTMSIXFM                   => cfg_interrupt_msixfm_v6pcie6,
         CFGINTERRUPTRDYN                     => cfg_interrupt_rdy_n_v6pcie7,
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
         CFGLINKSTATUSAUTOBANDWIDTHSTATUS     => cfg_link_status_auto_bandwidth_status,
         CFGLINKSTATUSBANDWITHSTATUS          => cfg_link_status_bandwidth_status,
         CFGLINKSTATUSCURRENTSPEED            => cfg_link_status_current_speed,
         CFGLINKSTATUSDLLACTIVE               => cfg_link_status_dll_active,
         CFGLINKSTATUSLINKTRAINING            => cfg_link_status_link_training,
         CFGLINKSTATUSNEGOTIATEDWIDTH         => cfg_link_status_negotiated_link_width,
         CFGMSGDATA                           => cfg_msg_data_v6pcie8,
         CFGMSGRECEIVED                       => cfg_msg_received_v6pcie9,
         CFGMSGRECEIVEDASSERTINTA             => cfg_msg_received_assert_inta_v6pcie10,
         CFGMSGRECEIVEDASSERTINTB             => cfg_msg_received_assert_intb_v6pcie11,
         CFGMSGRECEIVEDASSERTINTC             => cfg_msg_received_assert_intc_v6pcie12,
         CFGMSGRECEIVEDASSERTINTD             => cfg_msg_received_assert_intd_v6pcie13,
         CFGMSGRECEIVEDDEASSERTINTA           => cfg_msg_received_deassert_inta_v6pcie14,
         CFGMSGRECEIVEDDEASSERTINTB           => cfg_msg_received_deassert_intb_v6pcie15,
         CFGMSGRECEIVEDDEASSERTINTC           => cfg_msg_received_deassert_intc_v6pcie16,
         CFGMSGRECEIVEDDEASSERTINTD           => cfg_msg_received_deassert_intd_v6pcie17,
         CFGMSGRECEIVEDERRCOR                 => cfg_msg_received_err_cor_v6pcie18,
         CFGMSGRECEIVEDERRFATAL               => cfg_msg_received_err_fatal_v6pcie19,
         CFGMSGRECEIVEDERRNONFATAL            => cfg_msg_received_err_non_fatal_v6pcie20,
         CFGMSGRECEIVEDPMASNAK                => open,
         CFGMSGRECEIVEDPMETO                  => open,
         CFGMSGRECEIVEDPMETOACK               => cfg_msg_received_pme_to_ack_v6pcie21,
         CFGMSGRECEIVEDPMPME                  => open,
         CFGMSGRECEIVEDSETSLOTPOWERLIMIT      => open,
         CFGMSGRECEIVEDUNLOCK                 => open,
         CFGPCIELINKSTATE                     => cfg_pcie_link_state_n_v6pcie22,
         CFGPMRCVASREQL1N                     => open,
         CFGPMRCVENTERL1N                     => open,
         CFGPMRCVENTERL23N                    => open,
         CFGPMRCVREQACKN                      => open,
         CFGPMCSRPMEEN                        => cfg_pmcsr_pme_en_v6pcie23,
         CFGPMCSRPMESTATUS                    => cfg_pmcsr_pme_status_v6pcie24,
         CFGPMCSRPOWERSTATE                   => cfg_pmcsr_powerstate_v6pcie25,
         CFGRDWRDONEN                         => cfg_rd_wr_done_n,
         CFGSLOTCONTROLELECTROMECHILCTLPULSE  => open,
         CFGTRANSACTION                       => open,
         CFGTRANSACTIONADDR                   => open,
         CFGTRANSACTIONTYPE                   => open,
         CFGVCTCVCMAP                         => open,
         CFGBYTEENN                           => cfg_byte_en_n,
         CFGDI                                => cfg_di,
         CFGDSBUSNUMBER                       => cfg_ds_bus_number,
         CFGDSDEVICENUMBER                    => cfg_ds_device_number,
         CFGDSFUNCTIONNUMBER                  => "000",
         CFGDSN                               => cfg_dsn,
         CFGDWADDR                            => cfg_dwaddr,
         CFGERRACSN                           => '1',
         CFGERRAERHEADERLOG                   => "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
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
         CFGPMSENDPMETON                      => cfg_pm_send_pme_to_n,
         CFGPMSENDPMNAKN                      => '1',
         CFGPMTURNOFFOKN                      => '1',
         CFGPMWAKEN                           => '1',
         CFGPORTNUMBER                        => "00000000",
         CFGRDENN                             => cfg_rd_en_n,
         CFGTRNPENDINGN                       => cfg_trn_pending_n,
         CFGWRENN                             => cfg_wr_en_n,
         CFGWRREADONLYN                       => '1',
         CFGWRRW1CASRWN                       => '1',
         PLINITIALLINKWIDTH                   => pl_initial_link_width_v6pcie32,
         PLLANEREVERSALMODE                   => pl_lane_reversal_mode_v6pcie33,
         PLLINKGEN2CAP                        => pl_link_gen2_capable_v6pcie34,
         PLLINKPARTNERGEN2SUPPORTED           => pl_link_partner_gen2_supported_v6pcie35,
         PLLINKUPCFGCAP                       => pl_link_upcfg_capable_v6pcie36,
         PLLTSSMSTATE                         => pl_ltssm_state_v6pcie37,
         PLPHYLNKUPN                          => pl_phy_lnk_up_n,
         PLRECEIVEDHOTRST                     => open,
         PLRXPMSTATE                          => open,
         PLSELLNKRATE                         => pl_sel_link_rate_v6pcie39,
         PLSELLNKWIDTH                        => pl_sel_link_width_v6pcie40,
         PLTXPMSTATE                          => open,
         PLDIRECTEDLINKAUTON                  => pl_directed_link_auton,
         PLDIRECTEDLINKCHANGE                 => v6pcie68,
         PLDIRECTEDLINKSPEED                  => v6pcie69,
         PLDIRECTEDLINKWIDTH                  => pl_directed_link_width,
         PLDOWNSTREAMDEEMPHSOURCE             => '1',
         PLUPSTREAMPREFERDEEMPH               => pl_upstream_prefer_deemph,
         PLTRANSMITHOTRST                     => pl_transmit_hot_rst,
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
         
         PCIEDRPDO                            => pcie_drp_do_v6pcie29,
         PCIEDRPDRDY                          => pcie_drp_drdy_v6pcie30,
         PCIEDRPCLK                           => pcie_drp_clk,
         PCIEDRPDADDR                         => pcie_drp_daddr,
         PCIEDRPDEN                           => pcie_drp_den,
         PCIEDRPDI                            => pcie_drp_di,
         PCIEDRPDWE                           => pcie_drp_dwe,
         
         GTPLLLOCK                            => gt_pll_lock,
         PIPECLK                              => pipe_clk,
         USERCLK                              => user_clk,
         DRPCLK                               => drp_clk,
         CLOCKLOCKED                          => clock_locked,
         TxOutClk                             => TxOutClk      );
   
   
end v6_pcie;
