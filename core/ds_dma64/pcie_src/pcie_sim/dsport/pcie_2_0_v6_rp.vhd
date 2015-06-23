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
-- File       : pcie_2_0_v6_rp.vhd
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


entity pcie_2_0_v6_rp is
   generic (
      TCQ                                          : integer := 1;
      REF_CLK_FREQ                                 : integer := 0;		-- 0 - 100 MHz, 1 - 125 MHz, 2 - 250 MHz
      PIPE_PIPELINE_STAGES                         : integer := 0;		-- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
      LINK_CAP_MAX_LINK_WIDTH_int                  : integer := 8;
      AER_BASE_PTR                                 : bit_vector := X"128";
      AER_CAP_ECRC_CHECK_CAPABLE                   : boolean := FALSE;
      AER_CAP_ECRC_GEN_CAPABLE                     : boolean := FALSE;
      AER_CAP_ID                                   : bit_vector := X"0001";
      AER_CAP_INT_MSG_NUM_MSI                      : bit_vector := X"0A";
      AER_CAP_INT_MSG_NUM_MSIX                     : bit_vector := X"15";
      AER_CAP_NEXTPTR                              : bit_vector := X"160";
      AER_CAP_ON                                   : boolean := FALSE;
      AER_CAP_PERMIT_ROOTERR_UPDATE                : boolean := TRUE;
      AER_CAP_VERSION                              : bit_vector := X"1";
      ALLOW_X8_GEN2                                : boolean := FALSE;
      BAR0 					   : bit_vector := X"FFFFFF00";
      BAR1 					   : bit_vector := X"FFFF0000";
      BAR2 					   : bit_vector := X"FFFF000C";
      BAR3 					   : bit_vector := X"FFFFFFFF";
      BAR4 					   : bit_vector := X"00000000";
      BAR5 					   : bit_vector := X"00000000";
      CAPABILITIES_PTR                             : bit_vector := X"40";
      CARDBUS_CIS_POINTER                          : bit_vector := X"00000000";
      CLASS_CODE                                   : bit_vector := X"000000";
      CMD_INTX_IMPLEMENTED                         : boolean := TRUE;
      CPL_TIMEOUT_DISABLE_SUPPORTED                : boolean := FALSE;
      CPL_TIMEOUT_RANGES_SUPPORTED                 : bit_vector := X"0";
      CRM_MODULE_RSTS                              : bit_vector := X"00";
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE          : boolean := TRUE;
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE          : boolean := TRUE;
      DEV_CAP_ENDPOINT_L0S_LATENCY                 : integer := 0;
      DEV_CAP_ENDPOINT_L1_LATENCY                  : integer := 0;
      DEV_CAP_EXT_TAG_SUPPORTED                    : boolean := TRUE;
      DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE         : boolean := FALSE;
      DEV_CAP_MAX_PAYLOAD_SUPPORTED                : integer := 2;
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT            : integer := 0;
      DEV_CAP_ROLE_BASED_ERROR                     : boolean := TRUE;
      DEV_CAP_RSVD_14_12 			   : integer := 0;
      DEV_CAP_RSVD_17_16 			   : integer := 0;
      DEV_CAP_RSVD_31_29 			   : integer := 0;
      DEV_CONTROL_AUX_POWER_SUPPORTED              : boolean := FALSE;
      DEVICE_ID                                    : bit_vector := X"0007";
      DISABLE_ASPM_L1_TIMER 			   : boolean := FALSE;
      DISABLE_BAR_FILTERING 			   : boolean := FALSE;
      DISABLE_ID_CHECK                             : boolean := FALSE;
      DISABLE_LANE_REVERSAL                        : boolean := FALSE;
      DISABLE_RX_TC_FILTER                         : boolean := FALSE;
      DISABLE_SCRAMBLING                           : boolean := FALSE;
      DNSTREAM_LINK_NUM                            : bit_vector := X"00";
      DSN_BASE_PTR                                 : bit_vector := X"100";
      DSN_CAP_ID                                   : bit_vector := X"0003";
      DSN_CAP_NEXTPTR                              : bit_vector := X"000";
      DSN_CAP_ON                                   : boolean := TRUE;
      DSN_CAP_VERSION                              : bit_vector := X"1";
      ENABLE_MSG_ROUTE                             : bit_vector := X"000";
      ENABLE_RX_TD_ECRC_TRIM                       : boolean := FALSE;
      ENTER_RVRY_EI_L0                             : boolean := TRUE;
      EXPANSION_ROM                                : bit_vector := X"FFFFF001";
      EXT_CFG_CAP_PTR                              : bit_vector := X"3F";
      EXT_CFG_XP_CAP_PTR                           : bit_vector := X"3FF";
      HEADER_TYPE                                  : bit_vector := X"00";
      INFER_EI                                     : bit_vector := X"00";
      INTERRUPT_PIN                                : bit_vector := X"01";
      IS_SWITCH                                    : boolean := FALSE;
      LAST_CONFIG_DWORD                            : bit_vector := X"042";
      LINK_CAP_ASPM_SUPPORT                        : integer := 1;
      LINK_CAP_CLOCK_POWER_MANAGEMENT              : boolean := FALSE;
      LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP       : boolean := FALSE;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 	   : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 	   : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN1 		   : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN2 		   : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 	   : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 	   : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN1 		   : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN2 		   : integer := 7;
      LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP     : boolean := FALSE;
      LINK_CAP_MAX_LINK_SPEED 			   : bit_vector := X"1";
      LINK_CAP_MAX_LINK_WIDTH 			   : bit_vector := X"08";
      LINK_CAP_RSVD_23_22                          : integer := 0;
      LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE         : boolean := FALSE;
      LINK_CONTROL_RCB                             : integer := 0;
      LINK_CTRL2_DEEMPHASIS                        : boolean := FALSE;
      LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE       : boolean := FALSE;
      LINK_CTRL2_TARGET_LINK_SPEED                 : bit_vector := X"2";
      LINK_STATUS_SLOT_CLOCK_CONFIG                : boolean := TRUE;
      LL_ACK_TIMEOUT                               : bit_vector := X"0000";
      LL_ACK_TIMEOUT_EN                            : boolean := FALSE;
      LL_ACK_TIMEOUT_FUNC                          : integer := 0;
      LL_REPLAY_TIMEOUT                            : bit_vector := X"0000";
      LL_REPLAY_TIMEOUT_EN                         : boolean := FALSE;
      LL_REPLAY_TIMEOUT_FUNC                       : integer := 0;
      LTSSM_MAX_LINK_WIDTH                         : bit_vector := X"01";
      MSI_BASE_PTR                                 : bit_vector := X"48";
      MSI_CAP_ID                                   : bit_vector := X"05";
      MSI_CAP_MULTIMSGCAP                          : integer := 0;
      MSI_CAP_MULTIMSG_EXTENSION                   : integer := 0;
      MSI_CAP_NEXTPTR                              : bit_vector := X"60";
      MSI_CAP_ON                                   : boolean := FALSE;
      MSI_CAP_PER_VECTOR_MASKING_CAPABLE           : boolean := TRUE;
      MSI_CAP_64_BIT_ADDR_CAPABLE                  : boolean := TRUE;
      MSIX_BASE_PTR                                : bit_vector := X"9C";
      MSIX_CAP_ID                                  : bit_vector := X"11";
      MSIX_CAP_NEXTPTR                             : bit_vector := X"00";
      MSIX_CAP_ON                                  : boolean := FALSE;
      MSIX_CAP_PBA_BIR                             : integer := 0;
      MSIX_CAP_PBA_OFFSET                          : bit_vector := X"00000050";
      MSIX_CAP_TABLE_BIR                           : integer := 0;
      MSIX_CAP_TABLE_OFFSET                        : bit_vector := X"00000040";
      MSIX_CAP_TABLE_SIZE                          : bit_vector := X"000";
      N_FTS_COMCLK_GEN1 			   : integer := 255;
      N_FTS_COMCLK_GEN2 			   : integer := 255;
      N_FTS_GEN1 				   : integer := 255;
      N_FTS_GEN2 				   : integer := 255;
      PCIE_BASE_PTR                                : bit_vector := X"60";
      PCIE_CAP_CAPABILITY_ID                       : bit_vector := X"10";
      PCIE_CAP_CAPABILITY_VERSION                  : bit_vector := X"2";
      PCIE_CAP_DEVICE_PORT_TYPE                    : bit_vector := X"0";
      PCIE_CAP_INT_MSG_NUM                         : bit_vector := X"00";
      PCIE_CAP_NEXTPTR                             : bit_vector := X"00";
      PCIE_CAP_ON                                  : boolean := TRUE;
      PCIE_CAP_RSVD_15_14                          : integer := 0;
      PCIE_CAP_SLOT_IMPLEMENTED                    : boolean := FALSE;
      PCIE_REVISION                                : integer := 2;
      PGL0_LANE                                    : integer := 0;
      PGL1_LANE                                    : integer := 1;
      PGL2_LANE                                    : integer := 2;
      PGL3_LANE                                    : integer := 3;
      PGL4_LANE                                    : integer := 4;
      PGL5_LANE                                    : integer := 5;
      PGL6_LANE                                    : integer := 6;
      PGL7_LANE                                    : integer := 7;
      PL_AUTO_CONFIG                               : integer := 0;
      PL_FAST_TRAIN                                : boolean := FALSE;
      PM_BASE_PTR                                  : bit_vector := X"40";
      PM_CAP_AUXCURRENT                            : integer := 0;
      PM_CAP_DSI                                   : boolean := FALSE;
      PM_CAP_D1SUPPORT 				   : boolean := TRUE;
      PM_CAP_D2SUPPORT 				   : boolean := TRUE;
      PM_CAP_ID                                    : bit_vector := X"11";
      PM_CAP_NEXTPTR                               : bit_vector := X"48";
      PM_CAP_ON                                    : boolean := TRUE;
      PM_CAP_PME_CLOCK                             : boolean := FALSE;
      PM_CAP_PMESUPPORT                            : bit_vector := X"0F";
      PM_CAP_RSVD_04 				   : integer := 0;
      PM_CAP_VERSION 				   : integer := 3;
      PM_CSR_BPCCEN                                : boolean := FALSE;
      PM_CSR_B2B3                                  : boolean := FALSE;
      PM_CSR_NOSOFTRST                             : boolean := TRUE;
      PM_DATA0 					   : bit_vector := X"01";
      PM_DATA1 					   : bit_vector := X"01";
      PM_DATA2 					   : bit_vector := X"01";
      PM_DATA3 					   : bit_vector := X"01";
      PM_DATA4 					   : bit_vector := X"01";
      PM_DATA5 					   : bit_vector := X"01";
      PM_DATA6 					   : bit_vector := X"01";
      PM_DATA7 					   : bit_vector := X"01";
      PM_DATA_SCALE0 				   : bit_vector := X"1";
      PM_DATA_SCALE1 				   : bit_vector := X"1";
      PM_DATA_SCALE2 				   : bit_vector := X"1";
      PM_DATA_SCALE3 				   : bit_vector := X"1";
      PM_DATA_SCALE4 				   : bit_vector := X"1";
      PM_DATA_SCALE5 				   : bit_vector := X"1";
      PM_DATA_SCALE6 				   : bit_vector := X"1";
      PM_DATA_SCALE7 				   : bit_vector := X"1";
      RECRC_CHK                                    : integer := 0;
      RECRC_CHK_TRIM                               : boolean := FALSE;
      REVISION_ID                                  : bit_vector := X"00";
      ROOT_CAP_CRS_SW_VISIBILITY                   : boolean := FALSE;
      SELECT_DLL_IF                                : boolean := FALSE;
      SLOT_CAP_ATT_BUTTON_PRESENT                  : boolean := FALSE;
      SLOT_CAP_ATT_INDICATOR_PRESENT               : boolean := FALSE;
      SLOT_CAP_ELEC_INTERLOCK_PRESENT              : boolean := FALSE;
      SLOT_CAP_HOTPLUG_CAPABLE                     : boolean := FALSE;
      SLOT_CAP_HOTPLUG_SURPRISE                    : boolean := FALSE;
      SLOT_CAP_MRL_SENSOR_PRESENT                  : boolean := FALSE;
      SLOT_CAP_NO_CMD_COMPLETED_SUPPORT            : boolean := FALSE;
      SLOT_CAP_PHYSICAL_SLOT_NUM                   : bit_vector := X"0000";
      SLOT_CAP_POWER_CONTROLLER_PRESENT            : boolean := FALSE;
      SLOT_CAP_POWER_INDICATOR_PRESENT             : boolean := FALSE;
      SLOT_CAP_SLOT_POWER_LIMIT_SCALE              : integer := 0;
      SLOT_CAP_SLOT_POWER_LIMIT_VALUE              : bit_vector := X"00";
      SPARE_BIT0                                   : integer := 0;
      SPARE_BIT1                                   : integer := 0;
      SPARE_BIT2                                   : integer := 0;
      SPARE_BIT3                                   : integer := 0;
      SPARE_BIT4                                   : integer := 0;
      SPARE_BIT5                                   : integer := 0;
      SPARE_BIT6                                   : integer := 0;
      SPARE_BIT7                                   : integer := 0;
      SPARE_BIT8                                   : integer := 0;
      SPARE_BYTE0 				   : bit_vector := X"00";
      SPARE_BYTE1 				   : bit_vector := X"00";
      SPARE_BYTE2 				   : bit_vector := X"00";
      SPARE_BYTE3 				   : bit_vector := X"00";
      SPARE_WORD0 				   : bit_vector := X"00000000";
      SPARE_WORD1 				   : bit_vector := X"00000000";
      SPARE_WORD2 				   : bit_vector := X"00000000";
      SPARE_WORD3 				   : bit_vector := X"00000000";
      SUBSYSTEM_ID                                 : bit_vector := X"0007";
      SUBSYSTEM_VENDOR_ID                          : bit_vector := X"10EE";
      TL_RBYPASS                                   : boolean := FALSE;
      TL_RX_RAM_RADDR_LATENCY                      : integer := 0;
      TL_RX_RAM_RDATA_LATENCY                      : integer := 2;
      TL_RX_RAM_WRITE_LATENCY                      : integer := 0;
      TL_TFC_DISABLE                               : boolean := FALSE;
      TL_TX_CHECKS_DISABLE                         : boolean := FALSE;
      TL_TX_RAM_RADDR_LATENCY                      : integer := 0;
      TL_TX_RAM_RDATA_LATENCY                      : integer := 2;
      TL_TX_RAM_WRITE_LATENCY                      : integer := 0;
      UPCONFIG_CAPABLE                             : boolean := TRUE;
      UPSTREAM_FACING                              : boolean := TRUE;
      UR_INV_REQ                                   : boolean := TRUE;
      USER_CLK_FREQ                                : integer := 3;
      EXIT_LOOPBACK_ON_EI                          : boolean := TRUE;
      VC_BASE_PTR                                  : bit_vector := X"10C";
      VC_CAP_ID                                    : bit_vector := X"0002";
      VC_CAP_NEXTPTR                               : bit_vector := X"000";
      VC_CAP_ON                                    : boolean := FALSE;
      VC_CAP_REJECT_SNOOP_TRANSACTIONS             : boolean := FALSE;
      VC_CAP_VERSION                               : bit_vector := X"1";
      VC0_CPL_INFINITE                             : boolean := TRUE;
      VC0_RX_RAM_LIMIT                             : bit_vector := X"03FF";
      VC0_TOTAL_CREDITS_CD                         : integer := 127;
      VC0_TOTAL_CREDITS_CH                         : integer := 31;
      VC0_TOTAL_CREDITS_NPH                        : integer := 12;
      VC0_TOTAL_CREDITS_PD                         : integer := 288;
      VC0_TOTAL_CREDITS_PH                         : integer := 32;
      VC0_TX_LASTPACKET                            : integer := 31;
      VENDOR_ID                                    : bit_vector := X"10EE";
      VSEC_BASE_PTR                                : bit_vector := X"160";
      VSEC_CAP_HDR_ID                              : bit_vector := X"1234";
      VSEC_CAP_HDR_LENGTH                          : bit_vector := X"018";
      VSEC_CAP_HDR_REVISION                        : bit_vector := X"1";
      VSEC_CAP_ID                                  : bit_vector := X"000B";
      VSEC_CAP_IS_LINK_VISIBLE                     : boolean := TRUE;
      VSEC_CAP_NEXTPTR                             : bit_vector := X"000";
      VSEC_CAP_ON                                  : boolean := FALSE;
      VSEC_CAP_VERSION                             : bit_vector := X"1"
   );
   port (
      
      PCIEXPRXN                                    : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      PCIEXPRXP                                    : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      PCIEXPTXN                                    : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      PCIEXPTXP                                    : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      
      SYSCLK                                       : in std_logic;
      FUNDRSTN                                     : in std_logic;
      
      TRNLNKUPN                                    : out std_logic;
      TRNCLK                                       : out std_logic;
      
      PHYRDYN                                      : out std_logic;
      USERRSTN                                     : out std_logic;
      RECEIVEDFUNCLVLRSTN                          : out std_logic;
      LNKCLKEN                                     : out std_logic;
      SYSRSTN                                      : in std_logic;
      PLRSTN                                       : in std_logic;
      DLRSTN                                       : in std_logic;
      TLRSTN                                       : in std_logic;
      FUNCLVLRSTN                                  : in std_logic;
      CMRSTN                                       : in std_logic;
      CMSTICKYRSTN                                 : in std_logic;
      
      TRNRBARHITN                                  : out std_logic_vector(6 downto 0);
      TRNRD                                        : out std_logic_vector(63 downto 0);
      TRNRECRCERRN                                 : out std_logic;
      TRNREOFN                                     : out std_logic;
      
      TRNRERRFWDN                                  : out std_logic;
      TRNRREMN                                     : out std_logic;
      TRNRSOFN                                     : out std_logic;
      TRNRSRCDSCN                                  : out std_logic;
      TRNRSRCRDYN                                  : out std_logic;
      TRNRDSTRDYN                                  : in std_logic;
      TRNRNPOKN                                    : in std_logic;
      
      TRNTBUFAV                                    : out std_logic_vector(5 downto 0);
      TRNTCFGREQN                                  : out std_logic;
      
      TRNTDLLPDSTRDYN                              : out std_logic;
      TRNTDSTRDYN                                  : out std_logic;
      
      TRNTERRDROPN                                 : out std_logic;
      
      TRNTCFGGNTN                                  : in std_logic;
      
      TRNTD                                        : in std_logic_vector(63 downto 0);
      TRNTDLLPDATA                                 : in std_logic_vector(31 downto 0);
      TRNTDLLPSRCRDYN                              : in std_logic;
      TRNTECRCGENN                                 : in std_logic;
      TRNTEOFN                                     : in std_logic;
      
      TRNTERRFWDN                                  : in std_logic;
      TRNTREMN                                     : in std_logic;
      
      TRNTSOFN                                     : in std_logic;
      TRNTSRCDSCN                                  : in std_logic;
      TRNTSRCRDYN                                  : in std_logic;
      TRNTSTRN                                     : in std_logic;
      
      TRNFCCPLD                                    : out std_logic_vector(11 downto 0);
      TRNFCCPLH                                    : out std_logic_vector(7 downto 0);
      TRNFCNPD                                     : out std_logic_vector(11 downto 0);
      TRNFCNPH                                     : out std_logic_vector(7 downto 0);
      TRNFCPD                                      : out std_logic_vector(11 downto 0);
      TRNFCPH                                      : out std_logic_vector(7 downto 0);
      TRNFCSEL                                     : in std_logic_vector(2 downto 0);
      
      CFGAERECRCCHECKEN                            : out std_logic;
      CFGAERECRCGENEN                              : out std_logic;
      CFGCOMMANDBUSMASTERENABLE                    : out std_logic;
      CFGCOMMANDINTERRUPTDISABLE                   : out std_logic;
      CFGCOMMANDIOENABLE                           : out std_logic;
      CFGCOMMANDMEMENABLE                          : out std_logic;
      CFGCOMMANDSERREN                             : out std_logic;
      CFGDEVCONTROLAUXPOWEREN                      : out std_logic;
      CFGDEVCONTROLCORRERRREPORTINGEN              : out std_logic;
      CFGDEVCONTROLENABLERO                        : out std_logic;
      CFGDEVCONTROLEXTTAGEN                        : out std_logic;
      CFGDEVCONTROLFATALERRREPORTINGEN             : out std_logic;
      CFGDEVCONTROLMAXPAYLOAD                      : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLMAXREADREQ                      : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLNONFATALREPORTINGEN             : out std_logic;
      CFGDEVCONTROLNOSNOOPEN                       : out std_logic;
      CFGDEVCONTROLPHANTOMEN                       : out std_logic;
      CFGDEVCONTROLURERRREPORTINGEN                : out std_logic;
      CFGDEVCONTROL2CPLTIMEOUTDIS                  : out std_logic;
      CFGDEVCONTROL2CPLTIMEOUTVAL                  : out std_logic_vector(3 downto 0);
      CFGDEVSTATUSCORRERRDETECTED                  : out std_logic;
      CFGDEVSTATUSFATALERRDETECTED                 : out std_logic;
      CFGDEVSTATUSNONFATALERRDETECTED              : out std_logic;
      CFGDEVSTATUSURDETECTED                       : out std_logic;
      CFGDO                                        : out std_logic_vector(31 downto 0);
      CFGERRAERHEADERLOGSETN                       : out std_logic;
      CFGERRCPLRDYN                                : out std_logic;
      CFGINTERRUPTDO                               : out std_logic_vector(7 downto 0);
      CFGINTERRUPTMMENABLE                         : out std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIENABLE                        : out std_logic;
      CFGINTERRUPTMSIXENABLE                       : out std_logic;
      CFGINTERRUPTMSIXFM                           : out std_logic;
      CFGINTERRUPTRDYN                             : out std_logic;
      CFGLINKCONTROLRCB                            : out std_logic;
      CFGLINKCONTROLASPMCONTROL                    : out std_logic_vector(1 downto 0);
      CFGLINKCONTROLAUTOBANDWIDTHINTEN             : out std_logic;
      CFGLINKCONTROLBANDWIDTHINTEN                 : out std_logic;
      CFGLINKCONTROLCLOCKPMEN                      : out std_logic;
      CFGLINKCONTROLCOMMONCLOCK                    : out std_logic;
      CFGLINKCONTROLEXTENDEDSYNC                   : out std_logic;
      CFGLINKCONTROLHWAUTOWIDTHDIS                 : out std_logic;
      CFGLINKCONTROLLINKDISABLE                    : out std_logic;
      CFGLINKCONTROLRETRAINLINK                    : out std_logic;
      CFGLINKSTATUSAUTOBANDWIDTHSTATUS             : out std_logic;
      CFGLINKSTATUSBANDWITHSTATUS                  : out std_logic;
      CFGLINKSTATUSCURRENTSPEED                    : out std_logic_vector(1 downto 0);
      CFGLINKSTATUSDLLACTIVE                       : out std_logic;
      CFGLINKSTATUSLINKTRAINING                    : out std_logic;
      CFGLINKSTATUSNEGOTIATEDWIDTH                 : out std_logic_vector(3 downto 0);
      CFGMSGDATA                                   : out std_logic_vector(15 downto 0);
      CFGMSGRECEIVED                               : out std_logic;
      CFGMSGRECEIVEDASSERTINTA                     : out std_logic;
      CFGMSGRECEIVEDASSERTINTB                     : out std_logic;
      CFGMSGRECEIVEDASSERTINTC                     : out std_logic;
      CFGMSGRECEIVEDASSERTINTD                     : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTA                   : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTB                   : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTC                   : out std_logic;
      CFGMSGRECEIVEDDEASSERTINTD                   : out std_logic;
      CFGMSGRECEIVEDERRCOR                         : out std_logic;
      CFGMSGRECEIVEDERRFATAL                       : out std_logic;
      CFGMSGRECEIVEDERRNONFATAL                    : out std_logic;
      CFGMSGRECEIVEDPMASNAK                        : out std_logic;
      CFGMSGRECEIVEDPMETO                          : out std_logic;
      CFGMSGRECEIVEDPMETOACK                       : out std_logic;
      CFGMSGRECEIVEDPMPME                          : out std_logic;
      CFGMSGRECEIVEDSETSLOTPOWERLIMIT              : out std_logic;
      CFGMSGRECEIVEDUNLOCK                         : out std_logic;
      CFGPCIELINKSTATE                             : out std_logic_vector(2 downto 0);
      CFGPMCSRPMEEN                                : out std_logic;
      CFGPMCSRPMESTATUS                            : out std_logic;
      CFGPMCSRPOWERSTATE                           : out std_logic_vector(1 downto 0);
      CFGPMRCVASREQL1N                             : out std_logic;
      CFGPMRCVENTERL1N                             : out std_logic;
      CFGPMRCVENTERL23N                            : out std_logic;
      CFGPMRCVREQACKN                              : out std_logic;
      CFGRDWRDONEN                                 : out std_logic;
      CFGSLOTCONTROLELECTROMECHILCTLPULSE          : out std_logic;
      CFGTRANSACTION                               : out std_logic;
      CFGTRANSACTIONADDR                           : out std_logic_vector(6 downto 0);
      CFGTRANSACTIONTYPE                           : out std_logic;
      CFGVCTCVCMAP                                 : out std_logic_vector(6 downto 0);
      CFGBYTEENN                                   : in std_logic_vector(3 downto 0);
      CFGDI                                        : in std_logic_vector(31 downto 0);
      CFGDSBUSNUMBER                               : in std_logic_vector(7 downto 0);
      CFGDSDEVICENUMBER                            : in std_logic_vector(4 downto 0);
      CFGDSFUNCTIONNUMBER                          : in std_logic_vector(2 downto 0);
      CFGDSN                                       : in std_logic_vector(63 downto 0);
      CFGDWADDR                                    : in std_logic_vector(9 downto 0);
      CFGERRACSN                                   : in std_logic;
      CFGERRAERHEADERLOG                           : in std_logic_vector(127 downto 0);
      CFGERRCORN                                   : in std_logic;
      CFGERRCPLABORTN                              : in std_logic;
      CFGERRCPLTIMEOUTN                            : in std_logic;
      CFGERRCPLUNEXPECTN                           : in std_logic;
      CFGERRECRCN                                  : in std_logic;
      CFGERRLOCKEDN                                : in std_logic;
      CFGERRPOSTEDN                                : in std_logic;
      CFGERRTLPCPLHEADER                           : in std_logic_vector(47 downto 0);
      CFGERRURN                                    : in std_logic;
      CFGINTERRUPTASSERTN                          : in std_logic;
      CFGINTERRUPTDI                               : in std_logic_vector(7 downto 0);
      CFGINTERRUPTN                                : in std_logic;
      CFGPMDIRECTASPML1N                           : in std_logic;
      CFGPMSENDPMACKN                              : in std_logic;
      CFGPMSENDPMETON                              : in std_logic;
      CFGPMSENDPMNAKN                              : in std_logic;
      CFGPMTURNOFFOKN                              : in std_logic;
      CFGPMWAKEN                                   : in std_logic;
      CFGPORTNUMBER                                : in std_logic_vector(7 downto 0);
      CFGRDENN                                     : in std_logic;
      CFGTRNPENDINGN                               : in std_logic;
      CFGWRENN                                     : in std_logic;
      CFGWRREADONLYN                               : in std_logic;
      CFGWRRW1CASRWN                               : in std_logic;
      
      PLINITIALLINKWIDTH                           : out std_logic_vector(2 downto 0);
      PLLANEREVERSALMODE                           : out std_logic_vector(1 downto 0);
      PLLINKGEN2CAP                                : out std_logic;
      PLLINKPARTNERGEN2SUPPORTED                   : out std_logic;
      PLLINKUPCFGCAP                               : out std_logic;
      PLLTSSMSTATE                                 : out std_logic_vector(5 downto 0);
      PLPHYLNKUPN                                  : out std_logic;
      PLRECEIVEDHOTRST                             : out std_logic;
      PLRXPMSTATE                                  : out std_logic_vector(1 downto 0);
      PLSELLNKRATE                                 : out std_logic;
      PLSELLNKWIDTH                                : out std_logic_vector(1 downto 0);
      PLTXPMSTATE                                  : out std_logic_vector(2 downto 0);
      PLDIRECTEDLINKAUTON                          : in std_logic;
      PLDIRECTEDLINKCHANGE                         : in std_logic_vector(1 downto 0);
      PLDIRECTEDLINKSPEED                          : in std_logic;
      PLDIRECTEDLINKWIDTH                          : in std_logic_vector(1 downto 0);
      PLDOWNSTREAMDEEMPHSOURCE                     : in std_logic;
      PLUPSTREAMPREFERDEEMPH                       : in std_logic;
      PLTRANSMITHOTRST                             : in std_logic;
      
      DBGSCLRA                                     : out std_logic;
      DBGSCLRB                                     : out std_logic;
      DBGSCLRC                                     : out std_logic;
      DBGSCLRD                                     : out std_logic;
      DBGSCLRE                                     : out std_logic;
      DBGSCLRF                                     : out std_logic;
      DBGSCLRG                                     : out std_logic;
      DBGSCLRH                                     : out std_logic;
      DBGSCLRI                                     : out std_logic;
      DBGSCLRJ                                     : out std_logic;
      DBGSCLRK                                     : out std_logic;
      DBGVECA                                      : out std_logic_vector(63 downto 0);
      DBGVECB                                      : out std_logic_vector(63 downto 0);
      DBGVECC                                      : out std_logic_vector(11 downto 0);
      PLDBGVEC                                     : out std_logic_vector(11 downto 0);
      DBGMODE                                      : in std_logic_vector(1 downto 0);
      DBGSUBMODE                                   : in std_logic;
      PLDBGMODE                                    : in std_logic_vector(2 downto 0);
      PCIEDRPDO                                    : out std_logic_vector(15 downto 0);
      PCIEDRPDRDY                                  : out std_logic;
      PCIEDRPCLK                                   : in std_logic;
      PCIEDRPDADDR                                 : in std_logic_vector(8 downto 0);
      PCIEDRPDEN                                   : in std_logic;
      PCIEDRPDI                                    : in std_logic_vector(15 downto 0);
      PCIEDRPDWE                                   : in std_logic;
      
      GTPLLLOCK                                    : out std_logic;
      PIPECLK                                      : in std_logic;
      
      USERCLK                                      : in std_logic;
      DRPCLK                                       : in std_logic;
      CLOCKLOCKED                                  : in std_logic;
      
      TxOutClk                                     : out std_logic
   );
end pcie_2_0_v6_rp;

architecture v6_pcie of pcie_2_0_v6_rp is
   
   component pcie_pipe_v6
     generic (
       NO_OF_LANES             : integer;
       LINK_CAP_MAX_LINK_SPEED : bit_vector;
       PIPE_PIPELINE_STAGES    : integer);
     port (
       pipe_tx_rcvr_det_i       : in  std_logic;
       pipe_tx_reset_i          : in  std_logic;
       pipe_tx_rate_i           : in  std_logic;
       pipe_tx_deemph_i         : in  std_logic;
       pipe_tx_margin_i         : in  std_logic_vector(2 downto 0);
       pipe_tx_swing_i          : in  std_logic;
       pipe_tx_rcvr_det_o       : out std_logic;
       pipe_tx_reset_o          : out std_logic;
       pipe_tx_rate_o           : out std_logic;
       pipe_tx_deemph_o         : out std_logic;
       pipe_tx_margin_o         : out std_logic_vector(2 downto 0);
       pipe_tx_swing_o          : out std_logic;
       pipe_rx0_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx0_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx0_valid_o         : out std_logic;
       pipe_rx0_chanisaligned_o : out std_logic;
       pipe_rx0_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx0_phy_status_o    : out std_logic;
       pipe_rx0_elec_idle_o     : out std_logic;
       pipe_rx0_polarity_i      : in  std_logic;
       pipe_tx0_compliance_i    : in  std_logic;
       pipe_tx0_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx0_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx0_elec_idle_i     : in  std_logic;
       pipe_tx0_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx0_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx0_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx0_valid_i         : in  std_logic;
       pipe_rx0_chanisaligned_i : in  std_logic;
       pipe_rx0_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx0_phy_status_i    : in  std_logic;
       pipe_rx0_elec_idle_i     : in  std_logic;
       pipe_rx0_polarity_o      : out std_logic;
       pipe_tx0_compliance_o    : out std_logic;
       pipe_tx0_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx0_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx0_elec_idle_o     : out std_logic;
       pipe_tx0_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx1_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx1_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx1_valid_o         : out std_logic;
       pipe_rx1_chanisaligned_o : out std_logic;
       pipe_rx1_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx1_phy_status_o    : out std_logic;
       pipe_rx1_elec_idle_o     : out std_logic;
       pipe_rx1_polarity_i      : in  std_logic;
       pipe_tx1_compliance_i    : in  std_logic;
       pipe_tx1_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx1_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx1_elec_idle_i     : in  std_logic;
       pipe_tx1_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx1_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx1_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx1_valid_i         : in  std_logic;
       pipe_rx1_chanisaligned_i : in  std_logic;
       pipe_rx1_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx1_phy_status_i    : in  std_logic;
       pipe_rx1_elec_idle_i     : in  std_logic;
       pipe_rx1_polarity_o      : out std_logic;
       pipe_tx1_compliance_o    : out std_logic;
       pipe_tx1_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx1_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx1_elec_idle_o     : out std_logic;
       pipe_tx1_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx2_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx2_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx2_valid_o         : out std_logic;
       pipe_rx2_chanisaligned_o : out std_logic;
       pipe_rx2_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx2_phy_status_o    : out std_logic;
       pipe_rx2_elec_idle_o     : out std_logic;
       pipe_rx2_polarity_i      : in  std_logic;
       pipe_tx2_compliance_i    : in  std_logic;
       pipe_tx2_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx2_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx2_elec_idle_i     : in  std_logic;
       pipe_tx2_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx2_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx2_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx2_valid_i         : in  std_logic;
       pipe_rx2_chanisaligned_i : in  std_logic;
       pipe_rx2_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx2_phy_status_i    : in  std_logic;
       pipe_rx2_elec_idle_i     : in  std_logic;
       pipe_rx2_polarity_o      : out std_logic;
       pipe_tx2_compliance_o    : out std_logic;
       pipe_tx2_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx2_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx2_elec_idle_o     : out std_logic;
       pipe_tx2_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx3_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx3_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx3_valid_o         : out std_logic;
       pipe_rx3_chanisaligned_o : out std_logic;
       pipe_rx3_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx3_phy_status_o    : out std_logic;
       pipe_rx3_elec_idle_o     : out std_logic;
       pipe_rx3_polarity_i      : in  std_logic;
       pipe_tx3_compliance_i    : in  std_logic;
       pipe_tx3_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx3_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx3_elec_idle_i     : in  std_logic;
       pipe_tx3_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx3_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx3_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx3_valid_i         : in  std_logic;
       pipe_rx3_chanisaligned_i : in  std_logic;
       pipe_rx3_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx3_phy_status_i    : in  std_logic;
       pipe_rx3_elec_idle_i     : in  std_logic;
       pipe_rx3_polarity_o      : out std_logic;
       pipe_tx3_compliance_o    : out std_logic;
       pipe_tx3_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx3_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx3_elec_idle_o     : out std_logic;
       pipe_tx3_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx4_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx4_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx4_valid_o         : out std_logic;
       pipe_rx4_chanisaligned_o : out std_logic;
       pipe_rx4_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx4_phy_status_o    : out std_logic;
       pipe_rx4_elec_idle_o     : out std_logic;
       pipe_rx4_polarity_i      : in  std_logic;
       pipe_tx4_compliance_i    : in  std_logic;
       pipe_tx4_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx4_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx4_elec_idle_i     : in  std_logic;
       pipe_tx4_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx4_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx4_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx4_valid_i         : in  std_logic;
       pipe_rx4_chanisaligned_i : in  std_logic;
       pipe_rx4_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx4_phy_status_i    : in  std_logic;
       pipe_rx4_elec_idle_i     : in  std_logic;
       pipe_rx4_polarity_o      : out std_logic;
       pipe_tx4_compliance_o    : out std_logic;
       pipe_tx4_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx4_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx4_elec_idle_o     : out std_logic;
       pipe_tx4_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx5_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx5_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx5_valid_o         : out std_logic;
       pipe_rx5_chanisaligned_o : out std_logic;
       pipe_rx5_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx5_phy_status_o    : out std_logic;
       pipe_rx5_elec_idle_o     : out std_logic;
       pipe_rx5_polarity_i      : in  std_logic;
       pipe_tx5_compliance_i    : in  std_logic;
       pipe_tx5_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx5_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx5_elec_idle_i     : in  std_logic;
       pipe_tx5_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx5_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx5_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx5_valid_i         : in  std_logic;
       pipe_rx5_chanisaligned_i : in  std_logic;
       pipe_rx5_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx5_phy_status_i    : in  std_logic;
       pipe_rx5_elec_idle_i     : in  std_logic;
       pipe_rx5_polarity_o      : out std_logic;
       pipe_tx5_compliance_o    : out std_logic;
       pipe_tx5_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx5_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx5_elec_idle_o     : out std_logic;
       pipe_tx5_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx6_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx6_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx6_valid_o         : out std_logic;
       pipe_rx6_chanisaligned_o : out std_logic;
       pipe_rx6_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx6_phy_status_o    : out std_logic;
       pipe_rx6_elec_idle_o     : out std_logic;
       pipe_rx6_polarity_i      : in  std_logic;
       pipe_tx6_compliance_i    : in  std_logic;
       pipe_tx6_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx6_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx6_elec_idle_i     : in  std_logic;
       pipe_tx6_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx6_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx6_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx6_valid_i         : in  std_logic;
       pipe_rx6_chanisaligned_i : in  std_logic;
       pipe_rx6_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx6_phy_status_i    : in  std_logic;
       pipe_rx6_elec_idle_i     : in  std_logic;
       pipe_rx6_polarity_o      : out std_logic;
       pipe_tx6_compliance_o    : out std_logic;
       pipe_tx6_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx6_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx6_elec_idle_o     : out std_logic;
       pipe_tx6_powerdown_o     : out std_logic_vector(1 downto 0);
       pipe_rx7_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_rx7_data_o          : out std_logic_vector(15 downto 0);
       pipe_rx7_valid_o         : out std_logic;
       pipe_rx7_chanisaligned_o : out std_logic;
       pipe_rx7_status_o        : out std_logic_vector(2 downto 0);
       pipe_rx7_phy_status_o    : out std_logic;
       pipe_rx7_elec_idle_o     : out std_logic;
       pipe_rx7_polarity_i      : in  std_logic;
       pipe_tx7_compliance_i    : in  std_logic;
       pipe_tx7_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_tx7_data_i          : in  std_logic_vector(15 downto 0);
       pipe_tx7_elec_idle_i     : in  std_logic;
       pipe_tx7_powerdown_i     : in  std_logic_vector(1 downto 0);
       pipe_rx7_char_is_k_i     : in  std_logic_vector(1 downto 0);
       pipe_rx7_data_i          : in  std_logic_vector(15 downto 0);
       pipe_rx7_valid_i         : in  std_logic;
       pipe_rx7_chanisaligned_i : in  std_logic;
       pipe_rx7_status_i        : in  std_logic_vector(2 downto 0);
       pipe_rx7_phy_status_i    : in  std_logic;
       pipe_rx7_elec_idle_i     : in  std_logic;
       pipe_rx7_polarity_o      : out std_logic;
       pipe_tx7_compliance_o    : out std_logic;
       pipe_tx7_char_is_k_o     : out std_logic_vector(1 downto 0);
       pipe_tx7_data_o          : out std_logic_vector(15 downto 0);
       pipe_tx7_elec_idle_o     : out std_logic;
       pipe_tx7_powerdown_o     : out std_logic_vector(1 downto 0);
       pl_ltssm_state           : in  std_logic_vector(5 downto 0);
       pipe_clk                 : in  std_logic;
       rst_n                    : in  std_logic);
   end component;

   component pcie_gtx_v6
     generic (
       NO_OF_LANES             : integer;
       LINK_CAP_MAX_LINK_SPEED : bit_vector;
       REF_CLK_FREQ            : integer;
       PL_FAST_TRAIN           : boolean);
     port (
       pipe_tx_rcvr_det       : in  std_logic;
       pipe_tx_reset          : in  std_logic;
       pipe_tx_rate           : in  std_logic;
       pipe_tx_deemph         : in  std_logic;
       pipe_tx_margin         : in  std_logic_vector(2 downto 0);
       pipe_tx_swing          : in  std_logic;
       pipe_rx0_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx0_data          : out std_logic_vector(15 downto 0);
       pipe_rx0_valid         : out std_logic;
       pipe_rx0_chanisaligned : out std_logic;
       pipe_rx0_status        : out std_logic_vector(2 downto 0);
       pipe_rx0_phy_status    : out std_logic;
       pipe_rx0_elec_idle     : out std_logic;
       pipe_rx0_polarity      : in  std_logic;
       pipe_tx0_compliance    : in  std_logic;
       pipe_tx0_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx0_data          : in  std_logic_vector(15 downto 0);
       pipe_tx0_elec_idle     : in  std_logic;
       pipe_tx0_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx1_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx1_data          : out std_logic_vector(15 downto 0);
       pipe_rx1_valid         : out std_logic;
       pipe_rx1_chanisaligned : out std_logic;
       pipe_rx1_status        : out std_logic_vector(2 downto 0);
       pipe_rx1_phy_status    : out std_logic;
       pipe_rx1_elec_idle     : out std_logic;
       pipe_rx1_polarity      : in  std_logic;
       pipe_tx1_compliance    : in  std_logic;
       pipe_tx1_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx1_data          : in  std_logic_vector(15 downto 0);
       pipe_tx1_elec_idle     : in  std_logic;
       pipe_tx1_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx2_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx2_data          : out std_logic_vector(15 downto 0);
       pipe_rx2_valid         : out std_logic;
       pipe_rx2_chanisaligned : out std_logic;
       pipe_rx2_status        : out std_logic_vector(2 downto 0);
       pipe_rx2_phy_status    : out std_logic;
       pipe_rx2_elec_idle     : out std_logic;
       pipe_rx2_polarity      : in  std_logic;
       pipe_tx2_compliance    : in  std_logic;
       pipe_tx2_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx2_data          : in  std_logic_vector(15 downto 0);
       pipe_tx2_elec_idle     : in  std_logic;
       pipe_tx2_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx3_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx3_data          : out std_logic_vector(15 downto 0);
       pipe_rx3_valid         : out std_logic;
       pipe_rx3_chanisaligned : out std_logic;
       pipe_rx3_status        : out std_logic_vector(2 downto 0);
       pipe_rx3_phy_status    : out std_logic;
       pipe_rx3_elec_idle     : out std_logic;
       pipe_rx3_polarity      : in  std_logic;
       pipe_tx3_compliance    : in  std_logic;
       pipe_tx3_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx3_data          : in  std_logic_vector(15 downto 0);
       pipe_tx3_elec_idle     : in  std_logic;
       pipe_tx3_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx4_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx4_data          : out std_logic_vector(15 downto 0);
       pipe_rx4_valid         : out std_logic;
       pipe_rx4_chanisaligned : out std_logic;
       pipe_rx4_status        : out std_logic_vector(2 downto 0);
       pipe_rx4_phy_status    : out std_logic;
       pipe_rx4_elec_idle     : out std_logic;
       pipe_rx4_polarity      : in  std_logic;
       pipe_tx4_compliance    : in  std_logic;
       pipe_tx4_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx4_data          : in  std_logic_vector(15 downto 0);
       pipe_tx4_elec_idle     : in  std_logic;
       pipe_tx4_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx5_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx5_data          : out std_logic_vector(15 downto 0);
       pipe_rx5_valid         : out std_logic;
       pipe_rx5_chanisaligned : out std_logic;
       pipe_rx5_status        : out std_logic_vector(2 downto 0);
       pipe_rx5_phy_status    : out std_logic;
       pipe_rx5_elec_idle     : out std_logic;
       pipe_rx5_polarity      : in  std_logic;
       pipe_tx5_compliance    : in  std_logic;
       pipe_tx5_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx5_data          : in  std_logic_vector(15 downto 0);
       pipe_tx5_elec_idle     : in  std_logic;
       pipe_tx5_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx6_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx6_data          : out std_logic_vector(15 downto 0);
       pipe_rx6_valid         : out std_logic;
       pipe_rx6_chanisaligned : out std_logic;
       pipe_rx6_status        : out std_logic_vector(2 downto 0);
       pipe_rx6_phy_status    : out std_logic;
       pipe_rx6_elec_idle     : out std_logic;
       pipe_rx6_polarity      : in  std_logic;
       pipe_tx6_compliance    : in  std_logic;
       pipe_tx6_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx6_data          : in  std_logic_vector(15 downto 0);
       pipe_tx6_elec_idle     : in  std_logic;
       pipe_tx6_powerdown     : in  std_logic_vector(1 downto 0);
       pipe_rx7_char_is_k     : out std_logic_vector(1 downto 0);
       pipe_rx7_data          : out std_logic_vector(15 downto 0);
       pipe_rx7_valid         : out std_logic;
       pipe_rx7_chanisaligned : out std_logic;
       pipe_rx7_status        : out std_logic_vector(2 downto 0);
       pipe_rx7_phy_status    : out std_logic;
       pipe_rx7_elec_idle     : out std_logic;
       pipe_rx7_polarity      : in  std_logic;
       pipe_tx7_compliance    : in  std_logic;
       pipe_tx7_char_is_k     : in  std_logic_vector(1 downto 0);
       pipe_tx7_data          : in  std_logic_vector(15 downto 0);
       pipe_tx7_elec_idle     : in  std_logic;
       pipe_tx7_powerdown     : in  std_logic_vector(1 downto 0);
       pci_exp_txn            : out std_logic_vector((NO_OF_LANES - 1) downto 0);
       pci_exp_txp            : out std_logic_vector((NO_OF_LANES - 1) downto 0);
       pci_exp_rxn            : in  std_logic_vector((NO_OF_LANES - 1) downto 0);
       pci_exp_rxp            : in  std_logic_vector((NO_OF_LANES - 1) downto 0);
       sys_clk                : in  std_logic;
       sys_rst_n              : in  std_logic;
       pipe_clk               : in  std_logic;
       drp_clk                : in  std_logic;
       clock_locked           : in  std_logic;
       gt_pll_lock            : out std_logic;
       pl_ltssm_state         : in  std_logic_vector(5 downto 0);
       phy_rdy_n              : out std_logic;
       TxOutClk               : out std_logic);
   end component;

   component pcie_bram_top_v6
     generic (
       DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
       VC0_TX_LASTPACKET             : integer;
       TL_TX_RAM_RADDR_LATENCY       : integer;
       TL_TX_RAM_RDATA_LATENCY       : integer;
       TL_TX_RAM_WRITE_LATENCY       : integer;
       VC0_RX_LIMIT                  : bit_vector;
       TL_RX_RAM_RADDR_LATENCY       : integer;
       TL_RX_RAM_RDATA_LATENCY       : integer;
       TL_RX_RAM_WRITE_LATENCY       : integer);
     port (
       user_clk_i   : in  std_logic;
       reset_i      : in  std_logic;
       mim_tx_wen   : in  std_logic;
       mim_tx_waddr : in  std_logic_vector(12 downto 0);
       mim_tx_wdata : in  std_logic_vector(71 downto 0);
       mim_tx_ren   : in  std_logic;
       mim_tx_rce   : in  std_logic;
       mim_tx_raddr : in  std_logic_vector(12 downto 0);
       mim_tx_rdata : out std_logic_vector(71 downto 0);
       mim_rx_wen   : in  std_logic;
       mim_rx_waddr : in  std_logic_vector(12 downto 0);
       mim_rx_wdata : in  std_logic_vector(71 downto 0);
       mim_rx_ren   : in  std_logic;
       mim_rx_rce   : in  std_logic;
       mim_rx_raddr : in  std_logic_vector(12 downto 0);
       mim_rx_rdata : out std_logic_vector(71 downto 0));
   end component;

   component pcie_upconfig_fix_3451_v6
     generic (
       UPSTREAM_FACING         : boolean;
       PL_FAST_TRAIN           : boolean;
       LINK_CAP_MAX_LINK_WIDTH : bit_vector);
     port (
       pipe_clk                         : in  std_logic;
       pl_phy_lnkup_n                   : in  std_logic;
       pl_ltssm_state                   : in  std_logic_vector(5 downto 0);
       pl_sel_lnk_rate                  : in  std_logic;
       pl_directed_link_change          : in  std_logic_vector(1 downto 0);
       cfg_link_status_negotiated_width : in  std_logic_vector(3 downto 0);
       pipe_rx0_data                    : in std_logic_vector(15 downto 0);
       pipe_rx0_char_isk                : in std_logic_vector(1 downto 0);
       filter_pipe                      : out std_logic);
   end component;
   
   -- wire declarations
   
   signal LL2BADDLLPERRN                               : std_logic;
   signal LL2BADTLPERRN                                : std_logic;
   signal LL2PROTOCOLERRN                              : std_logic;
   signal LL2REPLAYROERRN                              : std_logic;
   signal LL2REPLAYTOERRN                              : std_logic;
   signal LL2SUSPENDOKN                                : std_logic;
   signal LL2TFCINIT1SEQN                              : std_logic;
   signal LL2TFCINIT2SEQN                              : std_logic;
   signal MIMRXRADDR                                   : std_logic_vector(12 downto 0);
   signal MIMRXRCE                                     : std_logic;
   signal MIMRXREN                                     : std_logic;
   signal MIMRXWADDR                                   : std_logic_vector(12 downto 0);
   signal MIMRXWDATA                                   : std_logic_vector(67 downto 0);
   signal MIMRXWDATA_tmp                               : std_logic_vector(71 downto 0);
   signal MIMRXWEN                                     : std_logic;
   signal MIMTXRADDR                                   : std_logic_vector(12 downto 0);
   signal MIMTXRCE                                     : std_logic;
   signal MIMTXREN                                     : std_logic;
   signal MIMTXWADDR                                   : std_logic_vector(12 downto 0);
   signal MIMTXWDATA                                   : std_logic_vector(68 downto 0);
   signal MIMTXWDATA_tmp                               : std_logic_vector(71 downto 0);
   signal MIMTXWEN                                     : std_logic;
   signal PIPERX0POLARITY                              : std_logic;
   signal PIPERX1POLARITY                              : std_logic;
   signal PIPERX2POLARITY                              : std_logic;
   signal PIPERX3POLARITY                              : std_logic;
   signal PIPERX4POLARITY                              : std_logic;
   signal PIPERX5POLARITY                              : std_logic;
   signal PIPERX6POLARITY                              : std_logic;
   signal PIPERX7POLARITY                              : std_logic;
   signal PIPETXDEEMPH                                 : std_logic;
   signal PIPETXMARGIN                                 : std_logic_vector(2 downto 0);
   signal PIPETXRATE                                   : std_logic;
   signal PIPETXRCVRDET                                : std_logic;
   signal PIPETXRESET                                  : std_logic;
   signal PIPETX0CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX0COMPLIANCE                            : std_logic;
   signal PIPETX0DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX0ELECIDLE                              : std_logic;
   signal PIPETX0POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX1CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX1COMPLIANCE                            : std_logic;
   signal PIPETX1DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX1ELECIDLE                              : std_logic;
   signal PIPETX1POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX2CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX2COMPLIANCE                            : std_logic;
   signal PIPETX2DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX2ELECIDLE                              : std_logic;
   signal PIPETX2POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX3CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX3COMPLIANCE                            : std_logic;
   signal PIPETX3DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX3ELECIDLE                              : std_logic;
   signal PIPETX3POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX4CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX4COMPLIANCE                            : std_logic;
   signal PIPETX4DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX4ELECIDLE                              : std_logic;
   signal PIPETX4POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX5CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX5COMPLIANCE                            : std_logic;
   signal PIPETX5DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX5ELECIDLE                              : std_logic;
   signal PIPETX5POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX6CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX6COMPLIANCE                            : std_logic;
   signal PIPETX6DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX6ELECIDLE                              : std_logic;
   signal PIPETX6POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PIPETX7CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPETX7COMPLIANCE                            : std_logic;
   signal PIPETX7DATA                                  : std_logic_vector(15 downto 0);
   signal PIPETX7ELECIDLE                              : std_logic;
   signal PIPETX7POWERDOWN                             : std_logic_vector(1 downto 0);
   signal PL2LINKUPN                                   : std_logic;
   signal PL2RECEIVERERRN                              : std_logic;
   signal PL2RECOVERYN                                 : std_logic;
   signal PL2RXELECIDLE                                : std_logic;
   signal PL2SUSPENDOK                                 : std_logic;
   signal TL2ASPMSUSPENDCREDITCHECKOKN                 : std_logic;
   signal TL2ASPMSUSPENDREQN                           : std_logic;
   signal TL2PPMSUSPENDOKN                             : std_logic;
   signal LL2SENDASREQL1N                              : std_logic;
   signal LL2SENDENTERL1N                              : std_logic;
   signal LL2SENDENTERL23N                             : std_logic;
   signal LL2SUSPENDNOWN                               : std_logic;
   signal LL2TLPRCVN                                   : std_logic;
   signal MIMRXRDATA                                   : std_logic_vector(71 downto 0);
   signal MIMTXRDATA                                   : std_logic_vector(71 downto 0);
   signal PL2DIRECTEDLSTATE                            : std_logic_vector(4 downto 0);
   signal TL2ASPMSUSPENDCREDITCHECKN                   : std_logic;
   signal TL2PPMSUSPENDREQN                            : std_logic;
   signal PIPERX0CHANISALIGNED                         : std_logic;
   signal PIPERX0CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX0DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX0ELECIDLE                              : std_logic;
   signal PIPERX0PHYSTATUS                             : std_logic;
   signal PIPERX0STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX0VALID                                 : std_logic;
   signal PIPERX1CHANISALIGNED                         : std_logic;
   signal PIPERX1CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX1DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX1ELECIDLE                              : std_logic;
   signal PIPERX1PHYSTATUS                             : std_logic;
   signal PIPERX1STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX1VALID                                 : std_logic;
   signal PIPERX2CHANISALIGNED                         : std_logic;
   signal PIPERX2CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX2DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX2ELECIDLE                              : std_logic;
   signal PIPERX2PHYSTATUS                             : std_logic;
   signal PIPERX2STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX2VALID                                 : std_logic;
   signal PIPERX3CHANISALIGNED                         : std_logic;
   signal PIPERX3CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX3DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX3ELECIDLE                              : std_logic;
   signal PIPERX3PHYSTATUS                             : std_logic;
   signal PIPERX3STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX3VALID                                 : std_logic;
   signal PIPERX4CHANISALIGNED                         : std_logic;
   signal PIPERX4CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX4DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX4ELECIDLE                              : std_logic;
   signal PIPERX4PHYSTATUS                             : std_logic;
   signal PIPERX4STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX4VALID                                 : std_logic;
   signal PIPERX5CHANISALIGNED                         : std_logic;
   signal PIPERX5CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX5DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX5ELECIDLE                              : std_logic;
   signal PIPERX5PHYSTATUS                             : std_logic;
   signal PIPERX5STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX5VALID                                 : std_logic;
   signal PIPERX6CHANISALIGNED                         : std_logic;
   signal PIPERX6CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX6DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX6ELECIDLE                              : std_logic;
   signal PIPERX6PHYSTATUS                             : std_logic;
   signal PIPERX6STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX6VALID                                 : std_logic;
   signal PIPERX7CHANISALIGNED                         : std_logic;
   signal PIPERX7CHARISK                               : std_logic_vector(1 downto 0);
   signal PIPERX7DATA                                  : std_logic_vector(15 downto 0);
   signal PIPERX7ELECIDLE                              : std_logic;
   signal PIPERX7PHYSTATUS                             : std_logic;
   signal PIPERX7STATUS                                : std_logic_vector(2 downto 0);
   signal PIPERX7VALID                                 : std_logic;
   
   signal PIPERX0POLARITYGT                            : std_logic;
   signal PIPERX1POLARITYGT                            : std_logic;
   signal PIPERX2POLARITYGT                            : std_logic;
   signal PIPERX3POLARITYGT                            : std_logic;
   signal PIPERX4POLARITYGT                            : std_logic;
   signal PIPERX5POLARITYGT                            : std_logic;
   signal PIPERX6POLARITYGT                            : std_logic;
   signal PIPERX7POLARITYGT                            : std_logic;
   signal PIPETXDEEMPHGT                               : std_logic;
   signal PIPETXMARGINGT                               : std_logic_vector(2 downto 0);
   signal PIPETXRATEGT                                 : std_logic;
   signal PIPETXRCVRDETGT                              : std_logic;
   signal PIPETX0CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX0COMPLIANCEGT                          : std_logic;
   signal PIPETX0DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX0ELECIDLEGT                            : std_logic;
   signal PIPETX0POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX1CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX1COMPLIANCEGT                          : std_logic;
   signal PIPETX1DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX1ELECIDLEGT                            : std_logic;
   signal PIPETX1POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX2CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX2COMPLIANCEGT                          : std_logic;
   signal PIPETX2DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX2ELECIDLEGT                            : std_logic;
   signal PIPETX2POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX3CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX3COMPLIANCEGT                          : std_logic;
   signal PIPETX3DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX3ELECIDLEGT                            : std_logic;
   signal PIPETX3POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX4CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX4COMPLIANCEGT                          : std_logic;
   signal PIPETX4DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX4ELECIDLEGT                            : std_logic;
   signal PIPETX4POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX5CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX5COMPLIANCEGT                          : std_logic;
   signal PIPETX5DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX5ELECIDLEGT                            : std_logic;
   signal PIPETX5POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX6CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX6COMPLIANCEGT                          : std_logic;
   signal PIPETX6DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX6ELECIDLEGT                            : std_logic;
   signal PIPETX6POWERDOWNGT                           : std_logic_vector(1 downto 0);
   signal PIPETX7CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPETX7COMPLIANCEGT                          : std_logic;
   signal PIPETX7DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPETX7ELECIDLEGT                            : std_logic;
   signal PIPETX7POWERDOWNGT                           : std_logic_vector(1 downto 0);
   
   signal PIPERX0CHANISALIGNEDGT                       : std_logic;
   signal PIPERX0CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX0DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX0ELECIDLEGT                            : std_logic;
   signal PIPERX0PHYSTATUSGT                           : std_logic;
   signal PIPERX0STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX0VALIDGT                               : std_logic;
   signal PIPERX1CHANISALIGNEDGT                       : std_logic;
   signal PIPERX1CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX1DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX1ELECIDLEGT                            : std_logic;
   signal PIPERX1PHYSTATUSGT                           : std_logic;
   signal PIPERX1STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX1VALIDGT                               : std_logic;
   signal PIPERX2CHANISALIGNEDGT                       : std_logic;
   signal PIPERX2CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX2DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX2ELECIDLEGT                            : std_logic;
   signal PIPERX2PHYSTATUSGT                           : std_logic;
   signal PIPERX2STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX2VALIDGT                               : std_logic;
   signal PIPERX3CHANISALIGNEDGT                       : std_logic;
   signal PIPERX3CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX3DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX3ELECIDLEGT                            : std_logic;
   signal PIPERX3PHYSTATUSGT                           : std_logic;
   signal PIPERX3STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX3VALIDGT                               : std_logic;
   signal PIPERX4CHANISALIGNEDGT                       : std_logic;
   signal PIPERX4CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX4DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX4ELECIDLEGT                            : std_logic;
   signal PIPERX4PHYSTATUSGT                           : std_logic;
   signal PIPERX4STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX4VALIDGT                               : std_logic;
   signal PIPERX5CHANISALIGNEDGT                       : std_logic;
   signal PIPERX5CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX5DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX5ELECIDLEGT                            : std_logic;
   signal PIPERX5PHYSTATUSGT                           : std_logic;
   signal PIPERX5STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX5VALIDGT                               : std_logic;
   signal PIPERX6CHANISALIGNEDGT                       : std_logic;
   signal PIPERX6CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX6DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX6ELECIDLEGT                            : std_logic;
   signal PIPERX6PHYSTATUSGT                           : std_logic;
   signal PIPERX6STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX6VALIDGT                               : std_logic;
   signal PIPERX7CHANISALIGNEDGT                       : std_logic;
   signal PIPERX7CHARISKGT                             : std_logic_vector(1 downto 0);
   signal PIPERX7DATAGT                                : std_logic_vector(15 downto 0);
   signal PIPERX7ELECIDLEGT                            : std_logic;
   signal PIPERX7PHYSTATUSGT                           : std_logic;
   signal PIPERX7STATUSGT                              : std_logic_vector(2 downto 0);
   signal PIPERX7VALIDGT                               : std_logic;
   
   signal filter_pipe_upconfig_fix_3451                : std_logic;
   
   signal TRNRDLLPSRCRDYN                              : std_logic;
   
   -- Declare intermediate signals for referenced outputs
   signal PCIEXPTXN_v6pcie100                          : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
   signal PCIEXPTXP_v6pcie101                          : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
   signal TRNLNKUPN_v6pcie123                          : std_logic;
   signal PHYRDYN_v6pcie102                            : std_logic;
   signal USERRSTN_v6pcie139                           : std_logic;
   signal RECEIVEDFUNCLVLRSTN_v6pcie116                : std_logic;
   signal LNKCLKEN_v6pcie97                            : std_logic;
   signal TRNRBARHITN_v6pcie124                        : std_logic_vector(6 downto 0);
   signal TRNRD_v6pcie125                              : std_logic_vector(63 downto 0);
   signal TRNRECRCERRN_v6pcie126                       : std_logic;
   signal TRNREOFN_v6pcie127                           : std_logic;
   signal TRNRERRFWDN_v6pcie128                        : std_logic;
   signal TRNRREMN_v6pcie129                           : std_logic;
   signal TRNRSOFN_v6pcie130                           : std_logic;
   signal TRNRSRCDSCN_v6pcie131                        : std_logic;
   signal TRNRSRCRDYN_v6pcie132                        : std_logic;
   signal TRNTBUFAV_v6pcie133                          : std_logic_vector(5 downto 0);
   signal TRNTCFGREQN_v6pcie134                        : std_logic;
   signal TRNTDLLPDSTRDYN_v6pcie135                    : std_logic;
   signal TRNTDSTRDYN_v6pcie136                        : std_logic;
   signal TRNTERRDROPN_v6pcie137                       : std_logic;
   signal TRNFCCPLD_v6pcie117                          : std_logic_vector(11 downto 0);
   signal TRNFCCPLH_v6pcie118                          : std_logic_vector(7 downto 0);
   signal TRNFCNPD_v6pcie119                           : std_logic_vector(11 downto 0);
   signal TRNFCNPH_v6pcie120                           : std_logic_vector(7 downto 0);
   signal TRNFCPD_v6pcie121                            : std_logic_vector(11 downto 0);
   signal TRNFCPH_v6pcie122                            : std_logic_vector(7 downto 0);
   signal CFGAERECRCCHECKEN_v6pcie0                    : std_logic;
   signal CFGAERECRCGENEN_v6pcie1                      : std_logic;
   signal CFGCOMMANDBUSMASTERENABLE_v6pcie2            : std_logic;
   signal CFGCOMMANDINTERRUPTDISABLE_v6pcie3           : std_logic;
   signal CFGCOMMANDIOENABLE_v6pcie4                   : std_logic;
   signal CFGCOMMANDMEMENABLE_v6pcie5                  : std_logic;
   signal CFGCOMMANDSERREN_v6pcie6                     : std_logic;
   signal CFGDEVCONTROLAUXPOWEREN_v6pcie9              : std_logic;
   signal CFGDEVCONTROLCORRERRREPORTINGEN_v6pcie10     : std_logic;
   signal CFGDEVCONTROLENABLERO_v6pcie11               : std_logic;
   signal CFGDEVCONTROLEXTTAGEN_v6pcie12               : std_logic;
   signal CFGDEVCONTROLFATALERRREPORTINGEN_v6pcie13    : std_logic;
   signal CFGDEVCONTROLMAXPAYLOAD_v6pcie14             : std_logic_vector(2 downto 0);
   signal CFGDEVCONTROLMAXREADREQ_v6pcie15             : std_logic_vector(2 downto 0);
   signal CFGDEVCONTROLNONFATALREPORTINGEN_v6pcie16    : std_logic;
   signal CFGDEVCONTROLNOSNOOPEN_v6pcie17              : std_logic;
   signal CFGDEVCONTROLPHANTOMEN_v6pcie18              : std_logic;
   signal CFGDEVCONTROLURERRREPORTINGEN_v6pcie19       : std_logic;
   signal CFGDEVCONTROL2CPLTIMEOUTDIS_v6pcie7          : std_logic;
   signal CFGDEVCONTROL2CPLTIMEOUTVAL_v6pcie8          : std_logic_vector(3 downto 0);
   signal CFGDEVSTATUSCORRERRDETECTED_v6pcie20         : std_logic;
   signal CFGDEVSTATUSFATALERRDETECTED_v6pcie21        : std_logic;
   signal CFGDEVSTATUSNONFATALERRDETECTED_v6pcie22     : std_logic;
   signal CFGDEVSTATUSURDETECTED_v6pcie23              : std_logic;
   signal CFGDO_v6pcie24                               : std_logic_vector(31 downto 0);
   signal CFGERRAERHEADERLOGSETN_v6pcie25              : std_logic;
   signal CFGERRCPLRDYN_v6pcie26                       : std_logic;
   signal CFGINTERRUPTDO_v6pcie27                      : std_logic_vector(7 downto 0);
   signal CFGINTERRUPTMMENABLE_v6pcie28                : std_logic_vector(2 downto 0);
   signal CFGINTERRUPTMSIENABLE_v6pcie29               : std_logic;
   signal CFGINTERRUPTMSIXENABLE_v6pcie30              : std_logic;
   signal CFGINTERRUPTMSIXFM_v6pcie31                  : std_logic;
   signal CFGINTERRUPTRDYN_v6pcie32                    : std_logic;
   signal CFGLINKCONTROLRCB_v6pcie41                   : std_logic;
   signal CFGLINKCONTROLASPMCONTROL_v6pcie33           : std_logic_vector(1 downto 0);
   signal CFGLINKCONTROLAUTOBANDWIDTHINTEN_v6pcie34    : std_logic;
   signal CFGLINKCONTROLBANDWIDTHINTEN_v6pcie35        : std_logic;
   signal CFGLINKCONTROLCLOCKPMEN_v6pcie36             : std_logic;
   signal CFGLINKCONTROLCOMMONCLOCK_v6pcie37           : std_logic;
   signal CFGLINKCONTROLEXTENDEDSYNC_v6pcie38          : std_logic;
   signal CFGLINKCONTROLHWAUTOWIDTHDIS_v6pcie39        : std_logic;
   signal CFGLINKCONTROLLINKDISABLE_v6pcie40           : std_logic;
   signal CFGLINKCONTROLRETRAINLINK_v6pcie42           : std_logic;
   signal CFGLINKSTATUSAUTOBANDWIDTHSTATUS_v6pcie43    : std_logic;
   signal CFGLINKSTATUSBANDWITHSTATUS_v6pcie44         : std_logic;
   signal CFGLINKSTATUSCURRENTSPEED_v6pcie45           : std_logic_vector(1 downto 0);
   signal CFGLINKSTATUSDLLACTIVE_v6pcie46              : std_logic;
   signal CFGLINKSTATUSLINKTRAINING_v6pcie47           : std_logic;
   signal CFGLINKSTATUSNEGOTIATEDWIDTH_v6pcie48        : std_logic_vector(3 downto 0);
   signal CFGMSGDATA_v6pcie49                          : std_logic_vector(15 downto 0);
   signal CFGMSGRECEIVED_v6pcie50                      : std_logic;
   signal CFGMSGRECEIVEDASSERTINTA_v6pcie51            : std_logic;
   signal CFGMSGRECEIVEDASSERTINTB_v6pcie52            : std_logic;
   signal CFGMSGRECEIVEDASSERTINTC_v6pcie53            : std_logic;
   signal CFGMSGRECEIVEDASSERTINTD_v6pcie54            : std_logic;
   signal CFGMSGRECEIVEDDEASSERTINTA_v6pcie55          : std_logic;
   signal CFGMSGRECEIVEDDEASSERTINTB_v6pcie56          : std_logic;
   signal CFGMSGRECEIVEDDEASSERTINTC_v6pcie57          : std_logic;
   signal CFGMSGRECEIVEDDEASSERTINTD_v6pcie58          : std_logic;
   signal CFGMSGRECEIVEDERRCOR_v6pcie59                : std_logic;
   signal CFGMSGRECEIVEDERRFATAL_v6pcie60              : std_logic;
   signal CFGMSGRECEIVEDERRNONFATAL_v6pcie61           : std_logic;
   signal CFGMSGRECEIVEDPMASNAK_v6pcie62               : std_logic;
   signal CFGMSGRECEIVEDPMETO_v6pcie63                 : std_logic;
   signal CFGMSGRECEIVEDPMETOACK_v6pcie64              : std_logic;
   signal CFGMSGRECEIVEDPMPME_v6pcie65                 : std_logic;
   signal CFGMSGRECEIVEDSETSLOTPOWERLIMIT_v6pcie66     : std_logic;
   signal CFGMSGRECEIVEDUNLOCK_v6pcie67                : std_logic;
   signal CFGPCIELINKSTATE_v6pcie68                    : std_logic_vector(2 downto 0);
   signal CFGPMCSRPMEEN_v6pcie69                       : std_logic;
   signal CFGPMCSRPMESTATUS_v6pcie70                   : std_logic;
   signal CFGPMCSRPOWERSTATE_v6pcie71                  : std_logic_vector(1 downto 0);
   signal CFGPMRCVASREQL1N_v6pcie72                    : std_logic;
   signal CFGPMRCVENTERL1N_v6pcie73                    : std_logic;
   signal CFGPMRCVENTERL23N_v6pcie74                   : std_logic;
   signal CFGPMRCVREQACKN_v6pcie75                     : std_logic;
   signal CFGRDWRDONEN_v6pcie76                        : std_logic;
   signal CFGSLOTCONTROLELECTROMECHILCTLPULSE_v6pcie77 : std_logic;
   signal CFGTRANSACTION_v6pcie78                      : std_logic;
   signal CFGTRANSACTIONADDR_v6pcie79                  : std_logic_vector(6 downto 0);
   signal CFGTRANSACTIONTYPE_v6pcie80                  : std_logic;
   signal CFGVCTCVCMAP_v6pcie81                        : std_logic_vector(6 downto 0);
   signal PLINITIALLINKWIDTH_v6pcie104                 : std_logic_vector(2 downto 0);
   signal PLLANEREVERSALMODE_v6pcie105                 : std_logic_vector(1 downto 0);
   signal PLLINKGEN2CAP_v6pcie106                      : std_logic;
   signal PLLINKPARTNERGEN2SUPPORTED_v6pcie107         : std_logic;
   signal PLLINKUPCFGCAP_v6pcie108                     : std_logic;
   signal PLLTSSMSTATE_v6pcie109                       : std_logic_vector(5 downto 0);
   signal PLPHYLNKUPN_v6pcie110                        : std_logic;
   signal PLRECEIVEDHOTRST_v6pcie111                   : std_logic;
   signal PLRXPMSTATE_v6pcie112                        : std_logic_vector(1 downto 0);
   signal PLSELLNKRATE_v6pcie113                       : std_logic;
   signal PLSELLNKWIDTH_v6pcie114                      : std_logic_vector(1 downto 0);
   signal PLTXPMSTATE_v6pcie115                        : std_logic_vector(2 downto 0);
   signal DBGSCLRA_v6pcie82                            : std_logic;
   signal DBGSCLRB_v6pcie83                            : std_logic;
   signal DBGSCLRC_v6pcie84                            : std_logic;
   signal DBGSCLRD_v6pcie85                            : std_logic;
   signal DBGSCLRE_v6pcie86                            : std_logic;
   signal DBGSCLRF_v6pcie87                            : std_logic;
   signal DBGSCLRG_v6pcie88                            : std_logic;
   signal DBGSCLRH_v6pcie89                            : std_logic;
   signal DBGSCLRI_v6pcie90                            : std_logic;
   signal DBGSCLRJ_v6pcie91                            : std_logic;
   signal DBGSCLRK_v6pcie92                            : std_logic;
   signal DBGVECA_v6pcie93                             : std_logic_vector(63 downto 0);
   signal DBGVECB_v6pcie94                             : std_logic_vector(63 downto 0);
   signal DBGVECC_v6pcie95                             : std_logic_vector(11 downto 0);
   signal PLDBGVEC_v6pcie103                           : std_logic_vector(11 downto 0);
   signal PCIEDRPDO_v6pcie98                           : std_logic_vector(15 downto 0);
   signal PCIEDRPDRDY_v6pcie99                         : std_logic;
   signal GTPLLLOCK_v6pcie96                           : std_logic;
   signal TxOutClk_v6pcie138                           : std_logic;

   signal PIPERX0CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX1CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX2CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX3CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX4CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX5CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX6CHARISK_v6pcie                        : std_logic_vector(1 downto 0);
   signal PIPERX7CHARISK_v6pcie                        : std_logic_vector(1 downto 0);

begin
   -- Drive referenced outputs
   PCIEXPTXN <= PCIEXPTXN_v6pcie100;
   PCIEXPTXP <= PCIEXPTXP_v6pcie101;
   TRNLNKUPN <= TRNLNKUPN_v6pcie123;
   PHYRDYN <= PHYRDYN_v6pcie102;
   USERRSTN <= USERRSTN_v6pcie139;
   RECEIVEDFUNCLVLRSTN <= RECEIVEDFUNCLVLRSTN_v6pcie116;
   LNKCLKEN <= LNKCLKEN_v6pcie97;
   TRNRBARHITN <= TRNRBARHITN_v6pcie124;
   TRNRD <= TRNRD_v6pcie125;
   TRNRECRCERRN <= TRNRECRCERRN_v6pcie126;
   TRNREOFN <= TRNREOFN_v6pcie127;
   TRNRERRFWDN <= TRNRERRFWDN_v6pcie128;
   TRNRREMN <= TRNRREMN_v6pcie129;
   TRNRSOFN <= TRNRSOFN_v6pcie130;
   TRNRSRCDSCN <= TRNRSRCDSCN_v6pcie131;
   TRNRSRCRDYN <= TRNRSRCRDYN_v6pcie132;
   TRNTBUFAV <= TRNTBUFAV_v6pcie133;
   TRNTCFGREQN <= TRNTCFGREQN_v6pcie134;
   TRNTDLLPDSTRDYN <= TRNTDLLPDSTRDYN_v6pcie135;
   TRNTDSTRDYN <= TRNTDSTRDYN_v6pcie136;
   TRNTERRDROPN <= TRNTERRDROPN_v6pcie137;
   TRNFCCPLD <= TRNFCCPLD_v6pcie117;
   TRNFCCPLH <= TRNFCCPLH_v6pcie118;
   TRNFCNPD <= TRNFCNPD_v6pcie119;
   TRNFCNPH <= TRNFCNPH_v6pcie120;
   TRNFCPD <= TRNFCPD_v6pcie121;
   TRNFCPH <= TRNFCPH_v6pcie122;
   CFGAERECRCCHECKEN <= CFGAERECRCCHECKEN_v6pcie0;
   CFGAERECRCGENEN <= CFGAERECRCGENEN_v6pcie1;
   CFGCOMMANDBUSMASTERENABLE <= CFGCOMMANDBUSMASTERENABLE_v6pcie2;
   CFGCOMMANDINTERRUPTDISABLE <= CFGCOMMANDINTERRUPTDISABLE_v6pcie3;
   CFGCOMMANDIOENABLE <= CFGCOMMANDIOENABLE_v6pcie4;
   CFGCOMMANDMEMENABLE <= CFGCOMMANDMEMENABLE_v6pcie5;
   CFGCOMMANDSERREN <= CFGCOMMANDSERREN_v6pcie6;
   CFGDEVCONTROLAUXPOWEREN <= CFGDEVCONTROLAUXPOWEREN_v6pcie9;
   CFGDEVCONTROLCORRERRREPORTINGEN <= CFGDEVCONTROLCORRERRREPORTINGEN_v6pcie10;
   CFGDEVCONTROLENABLERO <= CFGDEVCONTROLENABLERO_v6pcie11;
   CFGDEVCONTROLEXTTAGEN <= CFGDEVCONTROLEXTTAGEN_v6pcie12;
   CFGDEVCONTROLFATALERRREPORTINGEN <= CFGDEVCONTROLFATALERRREPORTINGEN_v6pcie13;
   CFGDEVCONTROLMAXPAYLOAD <= CFGDEVCONTROLMAXPAYLOAD_v6pcie14;
   CFGDEVCONTROLMAXREADREQ <= CFGDEVCONTROLMAXREADREQ_v6pcie15;
   CFGDEVCONTROLNONFATALREPORTINGEN <= CFGDEVCONTROLNONFATALREPORTINGEN_v6pcie16;
   CFGDEVCONTROLNOSNOOPEN <= CFGDEVCONTROLNOSNOOPEN_v6pcie17;
   CFGDEVCONTROLPHANTOMEN <= CFGDEVCONTROLPHANTOMEN_v6pcie18;
   CFGDEVCONTROLURERRREPORTINGEN <= CFGDEVCONTROLURERRREPORTINGEN_v6pcie19;
   CFGDEVCONTROL2CPLTIMEOUTDIS <= CFGDEVCONTROL2CPLTIMEOUTDIS_v6pcie7;
   CFGDEVCONTROL2CPLTIMEOUTVAL <= CFGDEVCONTROL2CPLTIMEOUTVAL_v6pcie8;
   CFGDEVSTATUSCORRERRDETECTED <= CFGDEVSTATUSCORRERRDETECTED_v6pcie20;
   CFGDEVSTATUSFATALERRDETECTED <= CFGDEVSTATUSFATALERRDETECTED_v6pcie21;
   CFGDEVSTATUSNONFATALERRDETECTED <= CFGDEVSTATUSNONFATALERRDETECTED_v6pcie22;
   CFGDEVSTATUSURDETECTED <= CFGDEVSTATUSURDETECTED_v6pcie23;
   CFGDO <= CFGDO_v6pcie24;
   CFGERRAERHEADERLOGSETN <= CFGERRAERHEADERLOGSETN_v6pcie25;
   CFGERRCPLRDYN <= CFGERRCPLRDYN_v6pcie26;
   CFGINTERRUPTDO <= CFGINTERRUPTDO_v6pcie27;
   CFGINTERRUPTMMENABLE <= CFGINTERRUPTMMENABLE_v6pcie28;
   CFGINTERRUPTMSIENABLE <= CFGINTERRUPTMSIENABLE_v6pcie29;
   CFGINTERRUPTMSIXENABLE <= CFGINTERRUPTMSIXENABLE_v6pcie30;
   CFGINTERRUPTMSIXFM <= CFGINTERRUPTMSIXFM_v6pcie31;
   CFGINTERRUPTRDYN <= CFGINTERRUPTRDYN_v6pcie32;
   CFGLINKCONTROLRCB <= CFGLINKCONTROLRCB_v6pcie41;
   CFGLINKCONTROLASPMCONTROL <= CFGLINKCONTROLASPMCONTROL_v6pcie33;
   CFGLINKCONTROLAUTOBANDWIDTHINTEN <= CFGLINKCONTROLAUTOBANDWIDTHINTEN_v6pcie34;
   CFGLINKCONTROLBANDWIDTHINTEN <= CFGLINKCONTROLBANDWIDTHINTEN_v6pcie35;
   CFGLINKCONTROLCLOCKPMEN <= CFGLINKCONTROLCLOCKPMEN_v6pcie36;
   CFGLINKCONTROLCOMMONCLOCK <= CFGLINKCONTROLCOMMONCLOCK_v6pcie37;
   CFGLINKCONTROLEXTENDEDSYNC <= CFGLINKCONTROLEXTENDEDSYNC_v6pcie38;
   CFGLINKCONTROLHWAUTOWIDTHDIS <= CFGLINKCONTROLHWAUTOWIDTHDIS_v6pcie39;
   CFGLINKCONTROLLINKDISABLE <= CFGLINKCONTROLLINKDISABLE_v6pcie40;
   CFGLINKCONTROLRETRAINLINK <= CFGLINKCONTROLRETRAINLINK_v6pcie42;
   CFGLINKSTATUSAUTOBANDWIDTHSTATUS <= CFGLINKSTATUSAUTOBANDWIDTHSTATUS_v6pcie43;
   CFGLINKSTATUSBANDWITHSTATUS <= CFGLINKSTATUSBANDWITHSTATUS_v6pcie44;
   CFGLINKSTATUSCURRENTSPEED <= CFGLINKSTATUSCURRENTSPEED_v6pcie45;
   CFGLINKSTATUSDLLACTIVE <= CFGLINKSTATUSDLLACTIVE_v6pcie46;
   CFGLINKSTATUSLINKTRAINING <= CFGLINKSTATUSLINKTRAINING_v6pcie47;
   CFGLINKSTATUSNEGOTIATEDWIDTH <= CFGLINKSTATUSNEGOTIATEDWIDTH_v6pcie48;
   CFGMSGDATA <= CFGMSGDATA_v6pcie49;
   CFGMSGRECEIVED <= CFGMSGRECEIVED_v6pcie50;
   CFGMSGRECEIVEDASSERTINTA <= CFGMSGRECEIVEDASSERTINTA_v6pcie51;
   CFGMSGRECEIVEDASSERTINTB <= CFGMSGRECEIVEDASSERTINTB_v6pcie52;
   CFGMSGRECEIVEDASSERTINTC <= CFGMSGRECEIVEDASSERTINTC_v6pcie53;
   CFGMSGRECEIVEDASSERTINTD <= CFGMSGRECEIVEDASSERTINTD_v6pcie54;
   CFGMSGRECEIVEDDEASSERTINTA <= CFGMSGRECEIVEDDEASSERTINTA_v6pcie55;
   CFGMSGRECEIVEDDEASSERTINTB <= CFGMSGRECEIVEDDEASSERTINTB_v6pcie56;
   CFGMSGRECEIVEDDEASSERTINTC <= CFGMSGRECEIVEDDEASSERTINTC_v6pcie57;
   CFGMSGRECEIVEDDEASSERTINTD <= CFGMSGRECEIVEDDEASSERTINTD_v6pcie58;
   CFGMSGRECEIVEDERRCOR <= CFGMSGRECEIVEDERRCOR_v6pcie59;
   CFGMSGRECEIVEDERRFATAL <= CFGMSGRECEIVEDERRFATAL_v6pcie60;
   CFGMSGRECEIVEDERRNONFATAL <= CFGMSGRECEIVEDERRNONFATAL_v6pcie61;
   CFGMSGRECEIVEDPMASNAK <= CFGMSGRECEIVEDPMASNAK_v6pcie62;
   CFGMSGRECEIVEDPMETO <= CFGMSGRECEIVEDPMETO_v6pcie63;
   CFGMSGRECEIVEDPMETOACK <= CFGMSGRECEIVEDPMETOACK_v6pcie64;
   CFGMSGRECEIVEDPMPME <= CFGMSGRECEIVEDPMPME_v6pcie65;
   CFGMSGRECEIVEDSETSLOTPOWERLIMIT <= CFGMSGRECEIVEDSETSLOTPOWERLIMIT_v6pcie66;
   CFGMSGRECEIVEDUNLOCK <= CFGMSGRECEIVEDUNLOCK_v6pcie67;
   CFGPCIELINKSTATE <= CFGPCIELINKSTATE_v6pcie68;
   CFGPMCSRPMEEN <= CFGPMCSRPMEEN_v6pcie69;
   CFGPMCSRPMESTATUS <= CFGPMCSRPMESTATUS_v6pcie70;
   CFGPMCSRPOWERSTATE <= CFGPMCSRPOWERSTATE_v6pcie71;
   CFGPMRCVASREQL1N <= CFGPMRCVASREQL1N_v6pcie72;
   CFGPMRCVENTERL1N <= CFGPMRCVENTERL1N_v6pcie73;
   CFGPMRCVENTERL23N <= CFGPMRCVENTERL23N_v6pcie74;
   CFGPMRCVREQACKN <= CFGPMRCVREQACKN_v6pcie75;
   CFGRDWRDONEN <= CFGRDWRDONEN_v6pcie76;
   CFGSLOTCONTROLELECTROMECHILCTLPULSE <= CFGSLOTCONTROLELECTROMECHILCTLPULSE_v6pcie77;
   CFGTRANSACTION <= CFGTRANSACTION_v6pcie78;
   CFGTRANSACTIONADDR <= CFGTRANSACTIONADDR_v6pcie79;
   CFGTRANSACTIONTYPE <= CFGTRANSACTIONTYPE_v6pcie80;
   CFGVCTCVCMAP <= CFGVCTCVCMAP_v6pcie81;
   PLINITIALLINKWIDTH <= PLINITIALLINKWIDTH_v6pcie104;
   PLLANEREVERSALMODE <= PLLANEREVERSALMODE_v6pcie105;
   PLLINKGEN2CAP <= PLLINKGEN2CAP_v6pcie106;
   PLLINKPARTNERGEN2SUPPORTED <= PLLINKPARTNERGEN2SUPPORTED_v6pcie107;
   PLLINKUPCFGCAP <= PLLINKUPCFGCAP_v6pcie108;
   PLLTSSMSTATE <= PLLTSSMSTATE_v6pcie109;
   PLPHYLNKUPN <= PLPHYLNKUPN_v6pcie110;
   PLRECEIVEDHOTRST <= PLRECEIVEDHOTRST_v6pcie111;
   PLRXPMSTATE <= PLRXPMSTATE_v6pcie112;
   PLSELLNKRATE <= PLSELLNKRATE_v6pcie113;
   PLSELLNKWIDTH <= PLSELLNKWIDTH_v6pcie114;
   PLTXPMSTATE <= PLTXPMSTATE_v6pcie115;
   DBGSCLRA <= DBGSCLRA_v6pcie82;
   DBGSCLRB <= DBGSCLRB_v6pcie83;
   DBGSCLRC <= DBGSCLRC_v6pcie84;
   DBGSCLRD <= DBGSCLRD_v6pcie85;
   DBGSCLRE <= DBGSCLRE_v6pcie86;
   DBGSCLRF <= DBGSCLRF_v6pcie87;
   DBGSCLRG <= DBGSCLRG_v6pcie88;
   DBGSCLRH <= DBGSCLRH_v6pcie89;
   DBGSCLRI <= DBGSCLRI_v6pcie90;
   DBGSCLRJ <= DBGSCLRJ_v6pcie91;
   DBGSCLRK <= DBGSCLRK_v6pcie92;
   DBGVECA <= DBGVECA_v6pcie93;
   DBGVECB <= DBGVECB_v6pcie94;
   DBGVECC <= DBGVECC_v6pcie95;
   PLDBGVEC <= PLDBGVEC_v6pcie103;
   PCIEDRPDO <= PCIEDRPDO_v6pcie98;
   PCIEDRPDRDY <= PCIEDRPDRDY_v6pcie99;
   GTPLLLOCK <= GTPLLLOCK_v6pcie96;
   TxOutClk <= TxOutClk_v6pcie138;
   LL2SENDASREQL1N <= '1';
   LL2SENDENTERL1N <= '1';
   LL2SENDENTERL23N <= '1';
   LL2SUSPENDNOWN <= '1';
   LL2TLPRCVN <= '1';
   PL2DIRECTEDLSTATE <= "00000";

   -- Assignments to outputs
   
   TRNCLK <= USERCLK;
   
   PIPERX0CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX0CHARISK;
   PIPERX1CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX1CHARISK;
   PIPERX2CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX2CHARISK;
   PIPERX3CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX3CHARISK;
   PIPERX4CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX4CHARISK;
   PIPERX5CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX5CHARISK;
   PIPERX6CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX6CHARISK;
   PIPERX7CHARISK_v6pcie       <= "11" when (filter_pipe_upconfig_fix_3451 = '1') else
                                  PIPERX7CHARISK;

   ---------------------------------------------------------
   -- Virtex6 PCI Express Block Module
   ---------------------------------------------------------
   
   pcie_block_i : PCIE_2_0
      generic map (
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
         BAR0                                      => BAR0,
         BAR1                                      => BAR1,
         BAR2                                      => BAR2,
         BAR3                                      => BAR3,
         BAR4                                      => BAR4,
         BAR5                                      => BAR5,
         CAPABILITIES_PTR                          => CAPABILITIES_PTR,
         CARDBUS_CIS_POINTER                       => CARDBUS_CIS_POINTER,
         CLASS_CODE                                => CLASS_CODE,
         CMD_INTX_IMPLEMENTED                      => CMD_INTX_IMPLEMENTED,
         CPL_TIMEOUT_DISABLE_SUPPORTED             => CPL_TIMEOUT_DISABLE_SUPPORTED,
         CPL_TIMEOUT_RANGES_SUPPORTED              => CPL_TIMEOUT_RANGES_SUPPORTED,
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
         DEVICE_ID                                 => DEVICE_ID,
         DISABLE_ASPM_L1_TIMER                     => DISABLE_ASPM_L1_TIMER,
         DISABLE_BAR_FILTERING                     => DISABLE_BAR_FILTERING,
         DISABLE_ID_CHECK                          => DISABLE_ID_CHECK,
         DISABLE_LANE_REVERSAL                     => DISABLE_LANE_REVERSAL,
         DISABLE_RX_TC_FILTER                      => DISABLE_RX_TC_FILTER,
         DISABLE_SCRAMBLING                        => DISABLE_SCRAMBLING,
         DNSTREAM_LINK_NUM                         => DNSTREAM_LINK_NUM,
         DSN_BASE_PTR                              => DSN_BASE_PTR,
         DSN_CAP_ID                                => DSN_CAP_ID,
         DSN_CAP_NEXTPTR                           => DSN_CAP_NEXTPTR,
         DSN_CAP_ON                                => DSN_CAP_ON,
         DSN_CAP_VERSION                           => DSN_CAP_VERSION,
         ENABLE_MSG_ROUTE                          => ENABLE_MSG_ROUTE,
         ENABLE_RX_TD_ECRC_TRIM                    => ENABLE_RX_TD_ECRC_TRIM,
         ENTER_RVRY_EI_L0                          => ENTER_RVRY_EI_L0,
         EXPANSION_ROM                             => EXPANSION_ROM,
         EXT_CFG_CAP_PTR                           => EXT_CFG_CAP_PTR,
         EXT_CFG_XP_CAP_PTR                        => EXT_CFG_XP_CAP_PTR,
         HEADER_TYPE                               => HEADER_TYPE,
         INFER_EI                                  => INFER_EI,
         INTERRUPT_PIN                             => INTERRUPT_PIN,
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
         LINK_CAP_MAX_LINK_SPEED                   => LINK_CAP_MAX_LINK_SPEED,
         LINK_CAP_MAX_LINK_WIDTH                   => LINK_CAP_MAX_LINK_WIDTH,
         LINK_CAP_RSVD_23_22                       => LINK_CAP_RSVD_23_22,
         LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE      => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE,
         LINK_CONTROL_RCB                          => LINK_CONTROL_RCB,
         LINK_CTRL2_DEEMPHASIS                     => LINK_CTRL2_DEEMPHASIS,
         LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE    => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE,
         LINK_CTRL2_TARGET_LINK_SPEED              => LINK_CTRL2_TARGET_LINK_SPEED,
         LINK_STATUS_SLOT_CLOCK_CONFIG             => LINK_STATUS_SLOT_CLOCK_CONFIG,
         LL_ACK_TIMEOUT                            => LL_ACK_TIMEOUT,
         LL_ACK_TIMEOUT_EN                         => LL_ACK_TIMEOUT_EN,
         LL_ACK_TIMEOUT_FUNC                       => LL_ACK_TIMEOUT_FUNC,
         LL_REPLAY_TIMEOUT                         => LL_REPLAY_TIMEOUT,
         LL_REPLAY_TIMEOUT_EN                      => LL_REPLAY_TIMEOUT_EN,
         LL_REPLAY_TIMEOUT_FUNC                    => LL_REPLAY_TIMEOUT_FUNC,
         LTSSM_MAX_LINK_WIDTH                      => LTSSM_MAX_LINK_WIDTH,
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
         MSIX_CAP_PBA_OFFSET                       => MSIX_CAP_PBA_OFFSET,
         MSIX_CAP_TABLE_BIR                        => MSIX_CAP_TABLE_BIR,
         MSIX_CAP_TABLE_OFFSET                     => MSIX_CAP_TABLE_OFFSET,
         MSIX_CAP_TABLE_SIZE                       => MSIX_CAP_TABLE_SIZE,
         N_FTS_COMCLK_GEN1                         => N_FTS_COMCLK_GEN1,
         N_FTS_COMCLK_GEN2                         => N_FTS_COMCLK_GEN2,
         N_FTS_GEN1                                => N_FTS_GEN1,
         N_FTS_GEN2                                => N_FTS_GEN2,
         PCIE_BASE_PTR                             => PCIE_BASE_PTR,
         PCIE_CAP_CAPABILITY_ID                    => PCIE_CAP_CAPABILITY_ID,
         PCIE_CAP_CAPABILITY_VERSION               => PCIE_CAP_CAPABILITY_VERSION,
         PCIE_CAP_DEVICE_PORT_TYPE                 => PCIE_CAP_DEVICE_PORT_TYPE,
         PCIE_CAP_INT_MSG_NUM                      => PCIE_CAP_INT_MSG_NUM,
         PCIE_CAP_NEXTPTR                          => PCIE_CAP_NEXTPTR,
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
         PM_CAP_PMESUPPORT                         => PM_CAP_PMESUPPORT,
         PM_CAP_RSVD_04                            => PM_CAP_RSVD_04,
         PM_CAP_VERSION                            => PM_CAP_VERSION,
         PM_CSR_BPCCEN                             => PM_CSR_BPCCEN,
         PM_CSR_B2B3                               => PM_CSR_B2B3,
         PM_CSR_NOSOFTRST                          => PM_CSR_NOSOFTRST,
         PM_DATA_SCALE0                            => PM_DATA_SCALE0,
         PM_DATA_SCALE1                            => PM_DATA_SCALE1,
         PM_DATA_SCALE2                            => PM_DATA_SCALE2,
         PM_DATA_SCALE3                            => PM_DATA_SCALE3,
         PM_DATA_SCALE4                            => PM_DATA_SCALE4,
         PM_DATA_SCALE5                            => PM_DATA_SCALE5,
         PM_DATA_SCALE6                            => PM_DATA_SCALE6,
         PM_DATA_SCALE7                            => PM_DATA_SCALE7,
         PM_DATA0                                  => PM_DATA0,
         PM_DATA1                                  => PM_DATA1,
         PM_DATA2                                  => PM_DATA2,
         PM_DATA3                                  => PM_DATA3,
         PM_DATA4                                  => PM_DATA4,
         PM_DATA5                                  => PM_DATA5,
         PM_DATA6                                  => PM_DATA6,
         PM_DATA7                                  => PM_DATA7,
         RECRC_CHK                                 => RECRC_CHK,
         RECRC_CHK_TRIM                            => RECRC_CHK_TRIM,
         REVISION_ID                               => REVISION_ID,
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
         SUBSYSTEM_ID                              => SUBSYSTEM_ID,
         SUBSYSTEM_VENDOR_ID                       => SUBSYSTEM_VENDOR_ID,
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
         VC_BASE_PTR                               => VC_BASE_PTR,
         VC_CAP_ID                                 => VC_CAP_ID,
         VC_CAP_NEXTPTR                            => VC_CAP_NEXTPTR,
         VC_CAP_ON                                 => VC_CAP_ON,
         VC_CAP_REJECT_SNOOP_TRANSACTIONS          => VC_CAP_REJECT_SNOOP_TRANSACTIONS,
         VC_CAP_VERSION                            => VC_CAP_VERSION,
         VC0_CPL_INFINITE                          => VC0_CPL_INFINITE,
         VC0_RX_RAM_LIMIT                          => VC0_RX_RAM_LIMIT,
         VC0_TOTAL_CREDITS_CD                      => VC0_TOTAL_CREDITS_CD,
         VC0_TOTAL_CREDITS_CH                      => VC0_TOTAL_CREDITS_CH,
         VC0_TOTAL_CREDITS_NPH                     => VC0_TOTAL_CREDITS_NPH,
         VC0_TOTAL_CREDITS_PD                      => VC0_TOTAL_CREDITS_PD,
         VC0_TOTAL_CREDITS_PH                      => VC0_TOTAL_CREDITS_PH,
         VC0_TX_LASTPACKET                         => VC0_TX_LASTPACKET,
         VENDOR_ID                                 => VENDOR_ID,
         VSEC_BASE_PTR                             => VSEC_BASE_PTR,
         VSEC_CAP_HDR_ID                           => VSEC_CAP_HDR_ID,
         VSEC_CAP_HDR_LENGTH                       => VSEC_CAP_HDR_LENGTH,
         VSEC_CAP_HDR_REVISION                     => VSEC_CAP_HDR_REVISION,
         VSEC_CAP_ID                               => VSEC_CAP_ID,
         VSEC_CAP_IS_LINK_VISIBLE                  => VSEC_CAP_IS_LINK_VISIBLE,
         VSEC_CAP_NEXTPTR                          => VSEC_CAP_NEXTPTR,
         VSEC_CAP_ON                               => VSEC_CAP_ON,
         VSEC_CAP_VERSION                          => VSEC_CAP_VERSION
      )
      port map (
         CFGAERECRCCHECKEN                    => CFGAERECRCCHECKEN_v6pcie0,
         CFGAERECRCGENEN                      => CFGAERECRCGENEN_v6pcie1,
         CFGCOMMANDBUSMASTERENABLE            => CFGCOMMANDBUSMASTERENABLE_v6pcie2,
         CFGCOMMANDINTERRUPTDISABLE           => CFGCOMMANDINTERRUPTDISABLE_v6pcie3,
         CFGCOMMANDIOENABLE                   => CFGCOMMANDIOENABLE_v6pcie4,
         CFGCOMMANDMEMENABLE                  => CFGCOMMANDMEMENABLE_v6pcie5,
         CFGCOMMANDSERREN                     => CFGCOMMANDSERREN_v6pcie6,
         CFGDEVCONTROLAUXPOWEREN              => CFGDEVCONTROLAUXPOWEREN_v6pcie9,
         CFGDEVCONTROLCORRERRREPORTINGEN      => CFGDEVCONTROLCORRERRREPORTINGEN_v6pcie10,
         CFGDEVCONTROLENABLERO                => CFGDEVCONTROLENABLERO_v6pcie11,
         CFGDEVCONTROLEXTTAGEN                => CFGDEVCONTROLEXTTAGEN_v6pcie12,
         CFGDEVCONTROLFATALERRREPORTINGEN     => CFGDEVCONTROLFATALERRREPORTINGEN_v6pcie13,
         CFGDEVCONTROLMAXPAYLOAD              => CFGDEVCONTROLMAXPAYLOAD_v6pcie14,
         CFGDEVCONTROLMAXREADREQ              => CFGDEVCONTROLMAXREADREQ_v6pcie15,
         CFGDEVCONTROLNONFATALREPORTINGEN     => CFGDEVCONTROLNONFATALREPORTINGEN_v6pcie16,
         CFGDEVCONTROLNOSNOOPEN               => CFGDEVCONTROLNOSNOOPEN_v6pcie17,
         CFGDEVCONTROLPHANTOMEN               => CFGDEVCONTROLPHANTOMEN_v6pcie18,
         CFGDEVCONTROLURERRREPORTINGEN        => CFGDEVCONTROLURERRREPORTINGEN_v6pcie19,
         CFGDEVCONTROL2CPLTIMEOUTDIS          => CFGDEVCONTROL2CPLTIMEOUTDIS_v6pcie7,
         CFGDEVCONTROL2CPLTIMEOUTVAL          => CFGDEVCONTROL2CPLTIMEOUTVAL_v6pcie8,
         CFGDEVSTATUSCORRERRDETECTED          => CFGDEVSTATUSCORRERRDETECTED_v6pcie20,
         CFGDEVSTATUSFATALERRDETECTED         => CFGDEVSTATUSFATALERRDETECTED_v6pcie21,
         CFGDEVSTATUSNONFATALERRDETECTED      => CFGDEVSTATUSNONFATALERRDETECTED_v6pcie22,
         CFGDEVSTATUSURDETECTED               => CFGDEVSTATUSURDETECTED_v6pcie23,
         CFGDO                                => CFGDO_v6pcie24,
         CFGERRAERHEADERLOGSETN               => CFGERRAERHEADERLOGSETN_v6pcie25,
         CFGERRCPLRDYN                        => CFGERRCPLRDYN_v6pcie26,
         CFGINTERRUPTDO                       => CFGINTERRUPTDO_v6pcie27,
         CFGINTERRUPTMMENABLE                 => CFGINTERRUPTMMENABLE_v6pcie28,
         CFGINTERRUPTMSIENABLE                => CFGINTERRUPTMSIENABLE_v6pcie29,
         CFGINTERRUPTMSIXENABLE               => CFGINTERRUPTMSIXENABLE_v6pcie30,
         CFGINTERRUPTMSIXFM                   => CFGINTERRUPTMSIXFM_v6pcie31,
         CFGINTERRUPTRDYN                     => CFGINTERRUPTRDYN_v6pcie32,
         CFGLINKCONTROLRCB                    => CFGLINKCONTROLRCB_v6pcie41,
         CFGLINKCONTROLASPMCONTROL            => CFGLINKCONTROLASPMCONTROL_v6pcie33,
         CFGLINKCONTROLAUTOBANDWIDTHINTEN     => CFGLINKCONTROLAUTOBANDWIDTHINTEN_v6pcie34,
         CFGLINKCONTROLBANDWIDTHINTEN         => CFGLINKCONTROLBANDWIDTHINTEN_v6pcie35,
         CFGLINKCONTROLCLOCKPMEN              => CFGLINKCONTROLCLOCKPMEN_v6pcie36,
         CFGLINKCONTROLCOMMONCLOCK            => CFGLINKCONTROLCOMMONCLOCK_v6pcie37,
         CFGLINKCONTROLEXTENDEDSYNC           => CFGLINKCONTROLEXTENDEDSYNC_v6pcie38,
         CFGLINKCONTROLHWAUTOWIDTHDIS         => CFGLINKCONTROLHWAUTOWIDTHDIS_v6pcie39,
         CFGLINKCONTROLLINKDISABLE            => CFGLINKCONTROLLINKDISABLE_v6pcie40,
         CFGLINKCONTROLRETRAINLINK            => CFGLINKCONTROLRETRAINLINK_v6pcie42,
         CFGLINKSTATUSAUTOBANDWIDTHSTATUS     => CFGLINKSTATUSAUTOBANDWIDTHSTATUS_v6pcie43,
         CFGLINKSTATUSBANDWITHSTATUS          => CFGLINKSTATUSBANDWITHSTATUS_v6pcie44,
         CFGLINKSTATUSCURRENTSPEED            => CFGLINKSTATUSCURRENTSPEED_v6pcie45,
         CFGLINKSTATUSDLLACTIVE               => CFGLINKSTATUSDLLACTIVE_v6pcie46,
         CFGLINKSTATUSLINKTRAINING            => CFGLINKSTATUSLINKTRAINING_v6pcie47,
         CFGLINKSTATUSNEGOTIATEDWIDTH         => CFGLINKSTATUSNEGOTIATEDWIDTH_v6pcie48,
         CFGMSGDATA                           => CFGMSGDATA_v6pcie49,
         CFGMSGRECEIVED                       => CFGMSGRECEIVED_v6pcie50,
         CFGMSGRECEIVEDASSERTINTA             => CFGMSGRECEIVEDASSERTINTA_v6pcie51,
         CFGMSGRECEIVEDASSERTINTB             => CFGMSGRECEIVEDASSERTINTB_v6pcie52,
         CFGMSGRECEIVEDASSERTINTC             => CFGMSGRECEIVEDASSERTINTC_v6pcie53,
         CFGMSGRECEIVEDASSERTINTD             => CFGMSGRECEIVEDASSERTINTD_v6pcie54,
         CFGMSGRECEIVEDDEASSERTINTA           => CFGMSGRECEIVEDDEASSERTINTA_v6pcie55,
         CFGMSGRECEIVEDDEASSERTINTB           => CFGMSGRECEIVEDDEASSERTINTB_v6pcie56,
         CFGMSGRECEIVEDDEASSERTINTC           => CFGMSGRECEIVEDDEASSERTINTC_v6pcie57,
         CFGMSGRECEIVEDDEASSERTINTD           => CFGMSGRECEIVEDDEASSERTINTD_v6pcie58,
         CFGMSGRECEIVEDERRCOR                 => CFGMSGRECEIVEDERRCOR_v6pcie59,
         CFGMSGRECEIVEDERRFATAL               => CFGMSGRECEIVEDERRFATAL_v6pcie60,
         CFGMSGRECEIVEDERRNONFATAL            => CFGMSGRECEIVEDERRNONFATAL_v6pcie61,
         CFGMSGRECEIVEDPMASNAK                => CFGMSGRECEIVEDPMASNAK_v6pcie62,
         CFGMSGRECEIVEDPMETO                  => CFGMSGRECEIVEDPMETO_v6pcie63,
         CFGMSGRECEIVEDPMETOACK               => CFGMSGRECEIVEDPMETOACK_v6pcie64,
         CFGMSGRECEIVEDPMPME                  => CFGMSGRECEIVEDPMPME_v6pcie65,
         CFGMSGRECEIVEDSETSLOTPOWERLIMIT      => CFGMSGRECEIVEDSETSLOTPOWERLIMIT_v6pcie66,
         CFGMSGRECEIVEDUNLOCK                 => CFGMSGRECEIVEDUNLOCK_v6pcie67,
         CFGPCIELINKSTATE                     => CFGPCIELINKSTATE_v6pcie68,
         CFGPMRCVASREQL1N                     => CFGPMRCVASREQL1N_v6pcie72,
         CFGPMRCVENTERL1N                     => CFGPMRCVENTERL1N_v6pcie73,
         CFGPMRCVENTERL23N                    => CFGPMRCVENTERL23N_v6pcie74,
         CFGPMRCVREQACKN                      => CFGPMRCVREQACKN_v6pcie75,
         CFGPMCSRPMEEN                        => CFGPMCSRPMEEN_v6pcie69,
         CFGPMCSRPMESTATUS                    => CFGPMCSRPMESTATUS_v6pcie70,
         CFGPMCSRPOWERSTATE                   => CFGPMCSRPOWERSTATE_v6pcie71,
         CFGRDWRDONEN                         => CFGRDWRDONEN_v6pcie76,
         CFGSLOTCONTROLELECTROMECHILCTLPULSE  => CFGSLOTCONTROLELECTROMECHILCTLPULSE_v6pcie77,
         CFGTRANSACTION                       => CFGTRANSACTION_v6pcie78,
         CFGTRANSACTIONADDR                   => CFGTRANSACTIONADDR_v6pcie79,
         CFGTRANSACTIONTYPE                   => CFGTRANSACTIONTYPE_v6pcie80,
         CFGVCTCVCMAP                         => CFGVCTCVCMAP_v6pcie81,
         DBGSCLRA                             => DBGSCLRA_v6pcie82,
         DBGSCLRB                             => DBGSCLRB_v6pcie83,
         DBGSCLRC                             => DBGSCLRC_v6pcie84,
         DBGSCLRD                             => DBGSCLRD_v6pcie85,
         DBGSCLRE                             => DBGSCLRE_v6pcie86,
         DBGSCLRF                             => DBGSCLRF_v6pcie87,
         DBGSCLRG                             => DBGSCLRG_v6pcie88,
         DBGSCLRH                             => DBGSCLRH_v6pcie89,
         DBGSCLRI                             => DBGSCLRI_v6pcie90,
         DBGSCLRJ                             => DBGSCLRJ_v6pcie91,
         DBGSCLRK                             => DBGSCLRK_v6pcie92,
         DBGVECA                              => DBGVECA_v6pcie93,
         DBGVECB                              => DBGVECB_v6pcie94,
         DBGVECC                              => DBGVECC_v6pcie95,
         DRPDO                                => PCIEDRPDO_v6pcie98,
         DRPDRDY                              => PCIEDRPDRDY_v6pcie99,
         LL2BADDLLPERRN                       => LL2BADDLLPERRN,
         LL2BADTLPERRN                        => LL2BADTLPERRN,
         LL2PROTOCOLERRN                      => LL2PROTOCOLERRN,
         LL2REPLAYROERRN                      => LL2REPLAYROERRN,
         LL2REPLAYTOERRN                      => LL2REPLAYTOERRN,
         LL2SUSPENDOKN                        => LL2SUSPENDOKN,
         LL2TFCINIT1SEQN                      => LL2TFCINIT1SEQN,
         LL2TFCINIT2SEQN                      => LL2TFCINIT2SEQN,
         MIMRXRADDR                           => MIMRXRADDR,
         MIMRXRCE                             => MIMRXRCE,
         MIMRXREN                             => MIMRXREN,
         MIMRXWADDR                           => MIMRXWADDR,
         MIMRXWDATA                           => MIMRXWDATA,
         MIMRXWEN                             => MIMRXWEN,
         MIMTXRADDR                           => MIMTXRADDR,
         MIMTXRCE                             => MIMTXRCE,
         MIMTXREN                             => MIMTXREN,
         MIMTXWADDR                           => MIMTXWADDR,
         MIMTXWDATA                           => MIMTXWDATA,
         MIMTXWEN                             => MIMTXWEN,
         PIPERX0POLARITY                      => PIPERX0POLARITY,
         PIPERX1POLARITY                      => PIPERX1POLARITY,
         PIPERX2POLARITY                      => PIPERX2POLARITY,
         PIPERX3POLARITY                      => PIPERX3POLARITY,
         PIPERX4POLARITY                      => PIPERX4POLARITY,
         PIPERX5POLARITY                      => PIPERX5POLARITY,
         PIPERX6POLARITY                      => PIPERX6POLARITY,
         PIPERX7POLARITY                      => PIPERX7POLARITY,
         PIPETXDEEMPH                         => PIPETXDEEMPH,
         PIPETXMARGIN                         => PIPETXMARGIN,
         PIPETXRATE                           => PIPETXRATE,
         PIPETXRCVRDET                        => PIPETXRCVRDET,
         PIPETXRESET                          => PIPETXRESET,
         PIPETX0CHARISK                       => PIPETX0CHARISK,
         PIPETX0COMPLIANCE                    => PIPETX0COMPLIANCE,
         PIPETX0DATA                          => PIPETX0DATA,
         PIPETX0ELECIDLE                      => PIPETX0ELECIDLE,
         PIPETX0POWERDOWN                     => PIPETX0POWERDOWN,
         PIPETX1CHARISK                       => PIPETX1CHARISK,
         PIPETX1COMPLIANCE                    => PIPETX1COMPLIANCE,
         PIPETX1DATA                          => PIPETX1DATA,
         PIPETX1ELECIDLE                      => PIPETX1ELECIDLE,
         PIPETX1POWERDOWN                     => PIPETX1POWERDOWN,
         PIPETX2CHARISK                       => PIPETX2CHARISK,
         PIPETX2COMPLIANCE                    => PIPETX2COMPLIANCE,
         PIPETX2DATA                          => PIPETX2DATA,
         PIPETX2ELECIDLE                      => PIPETX2ELECIDLE,
         PIPETX2POWERDOWN                     => PIPETX2POWERDOWN,
         PIPETX3CHARISK                       => PIPETX3CHARISK,
         PIPETX3COMPLIANCE                    => PIPETX3COMPLIANCE,
         PIPETX3DATA                          => PIPETX3DATA,
         PIPETX3ELECIDLE                      => PIPETX3ELECIDLE,
         PIPETX3POWERDOWN                     => PIPETX3POWERDOWN,
         PIPETX4CHARISK                       => PIPETX4CHARISK,
         PIPETX4COMPLIANCE                    => PIPETX4COMPLIANCE,
         PIPETX4DATA                          => PIPETX4DATA,
         PIPETX4ELECIDLE                      => PIPETX4ELECIDLE,
         PIPETX4POWERDOWN                     => PIPETX4POWERDOWN,
         PIPETX5CHARISK                       => PIPETX5CHARISK,
         PIPETX5COMPLIANCE                    => PIPETX5COMPLIANCE,
         PIPETX5DATA                          => PIPETX5DATA,
         PIPETX5ELECIDLE                      => PIPETX5ELECIDLE,
         PIPETX5POWERDOWN                     => PIPETX5POWERDOWN,
         PIPETX6CHARISK                       => PIPETX6CHARISK,
         PIPETX6COMPLIANCE                    => PIPETX6COMPLIANCE,
         PIPETX6DATA                          => PIPETX6DATA,
         PIPETX6ELECIDLE                      => PIPETX6ELECIDLE,
         PIPETX6POWERDOWN                     => PIPETX6POWERDOWN,
         PIPETX7CHARISK                       => PIPETX7CHARISK,
         PIPETX7COMPLIANCE                    => PIPETX7COMPLIANCE,
         PIPETX7DATA                          => PIPETX7DATA,
         PIPETX7ELECIDLE                      => PIPETX7ELECIDLE,
         PIPETX7POWERDOWN                     => PIPETX7POWERDOWN,
         PLDBGVEC                             => PLDBGVEC_v6pcie103,
         PLINITIALLINKWIDTH                   => PLINITIALLINKWIDTH_v6pcie104,
         PLLANEREVERSALMODE                   => PLLANEREVERSALMODE_v6pcie105,
         PLLINKGEN2CAP                        => PLLINKGEN2CAP_v6pcie106,
         PLLINKPARTNERGEN2SUPPORTED           => PLLINKPARTNERGEN2SUPPORTED_v6pcie107,
         PLLINKUPCFGCAP                       => PLLINKUPCFGCAP_v6pcie108,
         PLLTSSMSTATE                         => PLLTSSMSTATE_v6pcie109,
         PLPHYLNKUPN                          => PLPHYLNKUPN_v6pcie110,
         PLRECEIVEDHOTRST                     => PLRECEIVEDHOTRST_v6pcie111,
         PLRXPMSTATE                          => PLRXPMSTATE_v6pcie112,
         PLSELLNKRATE                         => PLSELLNKRATE_v6pcie113,
         PLSELLNKWIDTH                        => PLSELLNKWIDTH_v6pcie114,
         PLTXPMSTATE                          => PLTXPMSTATE_v6pcie115,
         PL2LINKUPN                           => PL2LINKUPN,
         PL2RECEIVERERRN                      => PL2RECEIVERERRN,
         PL2RECOVERYN                         => PL2RECOVERYN,
         PL2RXELECIDLE                        => PL2RXELECIDLE,
         PL2SUSPENDOK                         => PL2SUSPENDOK,
         RECEIVEDFUNCLVLRSTN                  => RECEIVEDFUNCLVLRSTN_v6pcie116,
         LNKCLKEN                             => LNKCLKEN_v6pcie97,
         TL2ASPMSUSPENDCREDITCHECKOKN         => TL2ASPMSUSPENDCREDITCHECKOKN,
         TL2ASPMSUSPENDREQN                   => TL2ASPMSUSPENDREQN,
         TL2PPMSUSPENDOKN                     => TL2PPMSUSPENDOKN,
         TRNFCCPLD                            => TRNFCCPLD_v6pcie117,
         TRNFCCPLH                            => TRNFCCPLH_v6pcie118,
         TRNFCNPD                             => TRNFCNPD_v6pcie119,
         TRNFCNPH                             => TRNFCNPH_v6pcie120,
         TRNFCPD                              => TRNFCPD_v6pcie121,
         TRNFCPH                              => TRNFCPH_v6pcie122,
         TRNLNKUPN                            => TRNLNKUPN_v6pcie123,
         TRNRBARHITN                          => TRNRBARHITN_v6pcie124,
         TRNRD                                => TRNRD_v6pcie125,
         TRNRDLLPDATA                         => open,
         TRNRDLLPSRCRDYN                      => TRNRDLLPSRCRDYN,
         TRNRECRCERRN                         => TRNRECRCERRN_v6pcie126,
         TRNREOFN                             => TRNREOFN_v6pcie127,
         TRNRERRFWDN                          => TRNRERRFWDN_v6pcie128,
         TRNRREMN                             => TRNRREMN_v6pcie129,
         TRNRSOFN                             => TRNRSOFN_v6pcie130,
         TRNRSRCDSCN                          => TRNRSRCDSCN_v6pcie131,
         TRNRSRCRDYN                          => TRNRSRCRDYN_v6pcie132,
         TRNTBUFAV                            => TRNTBUFAV_v6pcie133,
         TRNTCFGREQN                          => TRNTCFGREQN_v6pcie134,
         
         TRNTDLLPDSTRDYN                      => TRNTDLLPDSTRDYN_v6pcie135,
         TRNTDSTRDYN                          => TRNTDSTRDYN_v6pcie136,
         TRNTERRDROPN                         => TRNTERRDROPN_v6pcie137,
         
         USERRSTN                             => USERRSTN_v6pcie139,
         
         CFGBYTEENN                           => CFGBYTEENN,
         CFGDI                                => CFGDI,
         
         CFGDSBUSNUMBER                       => CFGDSBUSNUMBER,
         CFGDSDEVICENUMBER                    => CFGDSDEVICENUMBER,
         
         CFGDSFUNCTIONNUMBER                  => CFGDSFUNCTIONNUMBER,
         CFGDSN                               => CFGDSN,
         CFGDWADDR                            => CFGDWADDR,
         CFGERRACSN                           => CFGERRACSN,
         
         CFGERRAERHEADERLOG                   => CFGERRAERHEADERLOG,
         CFGERRCORN                           => CFGERRCORN,
         CFGERRCPLABORTN                      => CFGERRCPLABORTN,
         CFGERRCPLTIMEOUTN                    => CFGERRCPLTIMEOUTN,
         CFGERRCPLUNEXPECTN                   => CFGERRCPLUNEXPECTN,
         CFGERRECRCN                          => CFGERRECRCN,
         CFGERRLOCKEDN                        => CFGERRLOCKEDN,
         CFGERRPOSTEDN                        => CFGERRPOSTEDN,
         CFGERRTLPCPLHEADER                   => CFGERRTLPCPLHEADER,
         CFGERRURN                            => CFGERRURN,
         CFGINTERRUPTASSERTN                  => CFGINTERRUPTASSERTN,
         CFGINTERRUPTDI                       => CFGINTERRUPTDI,
         CFGINTERRUPTN                        => CFGINTERRUPTN,
         CFGPMDIRECTASPML1N                   => CFGPMDIRECTASPML1N,
         CFGPMSENDPMACKN                      => CFGPMSENDPMACKN,
         CFGPMSENDPMETON                      => CFGPMSENDPMETON,
         CFGPMSENDPMNAKN                      => CFGPMSENDPMNAKN,
         CFGPMTURNOFFOKN                      => CFGPMTURNOFFOKN,
         CFGPMWAKEN                           => CFGPMWAKEN,
         CFGPORTNUMBER                        => CFGPORTNUMBER,
         CFGRDENN                             => CFGRDENN,
         CFGTRNPENDINGN                       => CFGTRNPENDINGN,
         CFGWRENN                             => CFGWRENN,
         CFGWRREADONLYN                       => CFGWRREADONLYN,
         CFGWRRW1CASRWN                       => CFGWRRW1CASRWN,
         CMRSTN                               => CMRSTN,
         CMSTICKYRSTN                         => CMSTICKYRSTN,
         DBGMODE                              => DBGMODE,
         DBGSUBMODE                           => DBGSUBMODE,
         DLRSTN                               => DLRSTN,
         DRPCLK                               => PCIEDRPCLK,
         DRPDADDR                             => PCIEDRPDADDR,
         DRPDEN                               => PCIEDRPDEN,
         DRPDI                                => PCIEDRPDI,
         DRPDWE                               => PCIEDRPDWE,
         FUNCLVLRSTN                          => FUNCLVLRSTN,
         LL2SENDASREQL1N                      => LL2SENDASREQL1N,
         LL2SENDENTERL1N                      => LL2SENDENTERL1N,
         LL2SENDENTERL23N                     => LL2SENDENTERL23N,
         LL2SUSPENDNOWN                       => LL2SUSPENDNOWN,
         LL2TLPRCVN                           => LL2TLPRCVN,
         MIMRXRDATA                           => MIMRXRDATA(67 downto 0),
         MIMTXRDATA                           => MIMTXRDATA(68 downto 0),
         PIPECLK                              => PIPECLK,
         PIPERX0CHANISALIGNED                 => PIPERX0CHANISALIGNED,
         PIPERX0CHARISK                       => PIPERX0CHARISK_v6pcie,
         PIPERX0DATA                          => PIPERX0DATA,
         PIPERX0ELECIDLE                      => PIPERX0ELECIDLE,
         PIPERX0PHYSTATUS                     => PIPERX0PHYSTATUS,
         PIPERX0STATUS                        => PIPERX0STATUS,
         PIPERX0VALID                         => PIPERX0VALID,
         PIPERX1CHANISALIGNED                 => PIPERX1CHANISALIGNED,
         PIPERX1CHARISK                       => PIPERX1CHARISK_v6pcie,
         PIPERX1DATA                          => PIPERX1DATA,
         PIPERX1ELECIDLE                      => PIPERX1ELECIDLE,
         PIPERX1PHYSTATUS                     => PIPERX1PHYSTATUS,
         PIPERX1STATUS                        => PIPERX1STATUS,
         PIPERX1VALID                         => PIPERX1VALID,
         PIPERX2CHANISALIGNED                 => PIPERX2CHANISALIGNED,
         PIPERX2CHARISK                       => PIPERX2CHARISK_v6pcie,
         PIPERX2DATA                          => PIPERX2DATA,
         PIPERX2ELECIDLE                      => PIPERX2ELECIDLE,
         PIPERX2PHYSTATUS                     => PIPERX2PHYSTATUS,
         PIPERX2STATUS                        => PIPERX2STATUS,
         PIPERX2VALID                         => PIPERX2VALID,
         PIPERX3CHANISALIGNED                 => PIPERX3CHANISALIGNED,
         PIPERX3CHARISK                       => PIPERX3CHARISK_v6pcie,
         PIPERX3DATA                          => PIPERX3DATA,
         PIPERX3ELECIDLE                      => PIPERX3ELECIDLE,
         PIPERX3PHYSTATUS                     => PIPERX3PHYSTATUS,
         PIPERX3STATUS                        => PIPERX3STATUS,
         PIPERX3VALID                         => PIPERX3VALID,
         PIPERX4CHANISALIGNED                 => PIPERX4CHANISALIGNED,
         PIPERX4CHARISK                       => PIPERX4CHARISK_v6pcie,
         PIPERX4DATA                          => PIPERX4DATA,
         PIPERX4ELECIDLE                      => PIPERX4ELECIDLE,
         PIPERX4PHYSTATUS                     => PIPERX4PHYSTATUS,
         PIPERX4STATUS                        => PIPERX4STATUS,
         PIPERX4VALID                         => PIPERX4VALID,
         PIPERX5CHANISALIGNED                 => PIPERX5CHANISALIGNED,
         PIPERX5CHARISK                       => PIPERX5CHARISK_v6pcie,
         PIPERX5DATA                          => PIPERX5DATA,
         PIPERX5ELECIDLE                      => PIPERX5ELECIDLE,
         PIPERX5PHYSTATUS                     => PIPERX5PHYSTATUS,
         PIPERX5STATUS                        => PIPERX5STATUS,
         PIPERX5VALID                         => PIPERX5VALID,
         PIPERX6CHANISALIGNED                 => PIPERX6CHANISALIGNED,
         PIPERX6CHARISK                       => PIPERX6CHARISK_v6pcie,
         PIPERX6DATA                          => PIPERX6DATA,
         PIPERX6ELECIDLE                      => PIPERX6ELECIDLE,
         PIPERX6PHYSTATUS                     => PIPERX6PHYSTATUS,
         PIPERX6STATUS                        => PIPERX6STATUS,
         PIPERX6VALID                         => PIPERX6VALID,
         PIPERX7CHANISALIGNED                 => PIPERX7CHANISALIGNED,
         PIPERX7CHARISK                       => PIPERX7CHARISK_v6pcie,
         PIPERX7DATA                          => PIPERX7DATA,
         PIPERX7ELECIDLE                      => PIPERX7ELECIDLE,
         PIPERX7PHYSTATUS                     => PIPERX7PHYSTATUS,
         PIPERX7STATUS                        => PIPERX7STATUS,
         PIPERX7VALID                         => PIPERX7VALID,
         PLDBGMODE                            => PLDBGMODE,
         PLDIRECTEDLINKAUTON                  => PLDIRECTEDLINKAUTON,
         PLDIRECTEDLINKCHANGE                 => PLDIRECTEDLINKCHANGE,
         PLDIRECTEDLINKSPEED                  => PLDIRECTEDLINKSPEED,
         PLDIRECTEDLINKWIDTH                  => PLDIRECTEDLINKWIDTH,
         PLDOWNSTREAMDEEMPHSOURCE             => PLDOWNSTREAMDEEMPHSOURCE,
         PLRSTN                               => PLRSTN,
         PLTRANSMITHOTRST                     => PLTRANSMITHOTRST,
         PLUPSTREAMPREFERDEEMPH               => PLUPSTREAMPREFERDEEMPH,
         PL2DIRECTEDLSTATE                    => PL2DIRECTEDLSTATE,
         SYSRSTN                              => SYSRSTN,
         TLRSTN                               => TLRSTN,
         TL2ASPMSUSPENDCREDITCHECKN           => '1',
         TL2PPMSUSPENDREQN                    => '1',
         
         TRNFCSEL                             => TRNFCSEL,
         TRNRDSTRDYN                          => TRNRDSTRDYN,
         TRNRNPOKN                            => TRNRNPOKN,
         TRNTCFGGNTN                          => TRNTCFGGNTN,
         TRNTD                                => TRNTD,
         TRNTDLLPDATA                         => TRNTDLLPDATA,
         
         TRNTDLLPSRCRDYN                      => TRNTDLLPSRCRDYN,
         TRNTECRCGENN                         => TRNTECRCGENN,
         TRNTEOFN                             => TRNTEOFN,
         TRNTERRFWDN                          => TRNTERRFWDN,
         TRNTREMN                             => TRNTREMN,
         TRNTSOFN                             => TRNTSOFN,
         TRNTSRCDSCN                          => TRNTSRCDSCN,
         TRNTSRCRDYN                          => TRNTSRCRDYN,
         TRNTSTRN                             => TRNTSTRN,
         USERCLK                              => USERCLK
      );
   
   ---------------------------------------------------------
   -- Virtex6 PIPE Module
   ---------------------------------------------------------
   
   
   
   pcie_pipe_i : pcie_pipe_v6
      generic map (
         NO_OF_LANES              => LINK_CAP_MAX_LINK_WIDTH_int,
         LINK_CAP_MAX_LINK_SPEED  => LINK_CAP_MAX_LINK_SPEED,
         PIPE_PIPELINE_STAGES     => PIPE_PIPELINE_STAGES
      )
      port map (
         
         -- Pipe Per-Link Signals 
         pipe_tx_rcvr_det_i        => PIPETXRCVRDET,
         pipe_tx_reset_i           => PIPETXRESET,
         pipe_tx_rate_i            => PIPETXRATE,
         pipe_tx_deemph_i          => PIPETXDEEMPH,
         pipe_tx_margin_i          => PIPETXMARGIN,
         pipe_tx_swing_i           => '0',
         
         pipe_tx_rcvr_det_o        => PIPETXRCVRDETGT,
         pipe_tx_reset_o           => open,
         pipe_tx_rate_o            => PIPETXRATEGT,
         pipe_tx_deemph_o          => PIPETXDEEMPHGT,
         pipe_tx_margin_o          => PIPETXMARGINGT,
         pipe_tx_swing_o           => open,
         
         -- Pipe Per-Lane Signals - Lane 0
         pipe_rx0_char_is_k_o      => PIPERX0CHARISK,
         pipe_rx0_data_o           => PIPERX0DATA,
         pipe_rx0_valid_o          => PIPERX0VALID,
         pipe_rx0_chanisaligned_o  => PIPERX0CHANISALIGNED,
         pipe_rx0_status_o         => PIPERX0STATUS,
         pipe_rx0_phy_status_o     => PIPERX0PHYSTATUS,
         pipe_rx0_elec_idle_i      => PIPERX0ELECIDLEGT,
         pipe_rx0_polarity_i       => PIPERX0POLARITY,
         pipe_tx0_compliance_i     => PIPETX0COMPLIANCE,
         pipe_tx0_char_is_k_i      => PIPETX0CHARISK,
         pipe_tx0_data_i           => PIPETX0DATA,
         pipe_tx0_elec_idle_i      => PIPETX0ELECIDLE,
         pipe_tx0_powerdown_i      => PIPETX0POWERDOWN,
         
         pipe_rx0_char_is_k_i      => PIPERX0CHARISKGT,
         pipe_rx0_data_i           => PIPERX0DATAGT,
         pipe_rx0_valid_i          => PIPERX0VALIDGT,
         pipe_rx0_chanisaligned_i  => PIPERX0CHANISALIGNEDGT,
         pipe_rx0_status_i         => PIPERX0STATUSGT,
         pipe_rx0_phy_status_i     => PIPERX0PHYSTATUSGT,
         pipe_rx0_elec_idle_o      => PIPERX0ELECIDLE,
         pipe_rx0_polarity_o       => PIPERX0POLARITYGT,
         pipe_tx0_compliance_o     => PIPETX0COMPLIANCEGT,
         pipe_tx0_char_is_k_o      => PIPETX0CHARISKGT,
         pipe_tx0_data_o           => PIPETX0DATAGT,
         pipe_tx0_elec_idle_o      => PIPETX0ELECIDLEGT,
         pipe_tx0_powerdown_o      => PIPETX0POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 1
         pipe_rx1_char_is_k_o      => PIPERX1CHARISK,
         pipe_rx1_data_o           => PIPERX1DATA,
         pipe_rx1_valid_o          => PIPERX1VALID,
         pipe_rx1_chanisaligned_o  => PIPERX1CHANISALIGNED,
         pipe_rx1_status_o         => PIPERX1STATUS,
         pipe_rx1_phy_status_o     => PIPERX1PHYSTATUS,
         pipe_rx1_elec_idle_i      => PIPERX1ELECIDLEGT,
         pipe_rx1_polarity_i       => PIPERX1POLARITY,
         pipe_tx1_compliance_i     => PIPETX1COMPLIANCE,
         pipe_tx1_char_is_k_i      => PIPETX1CHARISK,
         pipe_tx1_data_i           => PIPETX1DATA,
         pipe_tx1_elec_idle_i      => PIPETX1ELECIDLE,
         pipe_tx1_powerdown_i      => PIPETX1POWERDOWN,
         
         pipe_rx1_char_is_k_i      => PIPERX1CHARISKGT,
         pipe_rx1_data_i           => PIPERX1DATAGT,
         pipe_rx1_valid_i          => PIPERX1VALIDGT,
         pipe_rx1_chanisaligned_i  => PIPERX1CHANISALIGNEDGT,
         pipe_rx1_status_i         => PIPERX1STATUSGT,
         pipe_rx1_phy_status_i     => PIPERX1PHYSTATUSGT,
         pipe_rx1_elec_idle_o      => PIPERX1ELECIDLE,
         pipe_rx1_polarity_o       => PIPERX1POLARITYGT,
         pipe_tx1_compliance_o     => PIPETX1COMPLIANCEGT,
         pipe_tx1_char_is_k_o      => PIPETX1CHARISKGT,
         pipe_tx1_data_o           => PIPETX1DATAGT,
         pipe_tx1_elec_idle_o      => PIPETX1ELECIDLEGT,
         pipe_tx1_powerdown_o      => PIPETX1POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 2
         pipe_rx2_char_is_k_o      => PIPERX2CHARISK,
         pipe_rx2_data_o           => PIPERX2DATA,
         pipe_rx2_valid_o          => PIPERX2VALID,
         pipe_rx2_chanisaligned_o  => PIPERX2CHANISALIGNED,
         pipe_rx2_status_o         => PIPERX2STATUS,
         pipe_rx2_phy_status_o     => PIPERX2PHYSTATUS,
         pipe_rx2_elec_idle_i      => PIPERX2ELECIDLEGT,
         pipe_rx2_polarity_i       => PIPERX2POLARITY,
         pipe_tx2_compliance_i     => PIPETX2COMPLIANCE,
         pipe_tx2_char_is_k_i      => PIPETX2CHARISK,
         pipe_tx2_data_i           => PIPETX2DATA,
         pipe_tx2_elec_idle_i      => PIPETX2ELECIDLE,
         pipe_tx2_powerdown_i      => PIPETX2POWERDOWN,
         
         pipe_rx2_char_is_k_i      => PIPERX2CHARISKGT,
         pipe_rx2_data_i           => PIPERX2DATAGT,
         pipe_rx2_valid_i          => PIPERX2VALIDGT,
         pipe_rx2_chanisaligned_i  => PIPERX2CHANISALIGNEDGT,
         pipe_rx2_status_i         => PIPERX2STATUSGT,
         pipe_rx2_phy_status_i     => PIPERX2PHYSTATUSGT,
         pipe_rx2_elec_idle_o      => PIPERX2ELECIDLE,
         pipe_rx2_polarity_o       => PIPERX2POLARITYGT,
         pipe_tx2_compliance_o     => PIPETX2COMPLIANCEGT,
         pipe_tx2_char_is_k_o      => PIPETX2CHARISKGT,
         pipe_tx2_data_o           => PIPETX2DATAGT,
         pipe_tx2_elec_idle_o      => PIPETX2ELECIDLEGT,
         pipe_tx2_powerdown_o      => PIPETX2POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 3
         pipe_rx3_char_is_k_o      => PIPERX3CHARISK,
         pipe_rx3_data_o           => PIPERX3DATA,
         pipe_rx3_valid_o          => PIPERX3VALID,
         pipe_rx3_chanisaligned_o  => PIPERX3CHANISALIGNED,
         pipe_rx3_status_o         => PIPERX3STATUS,
         pipe_rx3_phy_status_o     => PIPERX3PHYSTATUS,
         pipe_rx3_elec_idle_i      => PIPERX3ELECIDLEGT,
         pipe_rx3_polarity_i       => PIPERX3POLARITY,
         pipe_tx3_compliance_i     => PIPETX3COMPLIANCE,
         pipe_tx3_char_is_k_i      => PIPETX3CHARISK,
         pipe_tx3_data_i           => PIPETX3DATA,
         pipe_tx3_elec_idle_i      => PIPETX3ELECIDLE,
         pipe_tx3_powerdown_i      => PIPETX3POWERDOWN,
         
         pipe_rx3_char_is_k_i      => PIPERX3CHARISKGT,
         pipe_rx3_data_i           => PIPERX3DATAGT,
         pipe_rx3_valid_i          => PIPERX3VALIDGT,
         pipe_rx3_chanisaligned_i  => PIPERX3CHANISALIGNEDGT,
         pipe_rx3_status_i         => PIPERX3STATUSGT,
         pipe_rx3_phy_status_i     => PIPERX3PHYSTATUSGT,
         pipe_rx3_elec_idle_o      => PIPERX3ELECIDLE,
         pipe_rx3_polarity_o       => PIPERX3POLARITYGT,
         pipe_tx3_compliance_o     => PIPETX3COMPLIANCEGT,
         pipe_tx3_char_is_k_o      => PIPETX3CHARISKGT,
         pipe_tx3_data_o           => PIPETX3DATAGT,
         pipe_tx3_elec_idle_o      => PIPETX3ELECIDLEGT,
         pipe_tx3_powerdown_o      => PIPETX3POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 4
         pipe_rx4_char_is_k_o      => PIPERX4CHARISK,
         pipe_rx4_data_o           => PIPERX4DATA,
         pipe_rx4_valid_o          => PIPERX4VALID,
         pipe_rx4_chanisaligned_o  => PIPERX4CHANISALIGNED,
         pipe_rx4_status_o         => PIPERX4STATUS,
         pipe_rx4_phy_status_o     => PIPERX4PHYSTATUS,
         pipe_rx4_elec_idle_i      => PIPERX4ELECIDLEGT,
         pipe_rx4_polarity_i       => PIPERX4POLARITY,
         pipe_tx4_compliance_i     => PIPETX4COMPLIANCE,
         pipe_tx4_char_is_k_i      => PIPETX4CHARISK,
         pipe_tx4_data_i           => PIPETX4DATA,
         pipe_tx4_elec_idle_i      => PIPETX4ELECIDLE,
         pipe_tx4_powerdown_i      => PIPETX4POWERDOWN,
         
         pipe_rx4_char_is_k_i      => PIPERX4CHARISKGT,
         pipe_rx4_data_i           => PIPERX4DATAGT,
         pipe_rx4_valid_i          => PIPERX4VALIDGT,
         pipe_rx4_chanisaligned_i  => PIPERX4CHANISALIGNEDGT,
         pipe_rx4_status_i         => PIPERX4STATUSGT,
         pipe_rx4_phy_status_i     => PIPERX4PHYSTATUSGT,
         pipe_rx4_elec_idle_o      => PIPERX4ELECIDLE,
         pipe_rx4_polarity_o       => PIPERX4POLARITYGT,
         pipe_tx4_compliance_o     => PIPETX4COMPLIANCEGT,
         pipe_tx4_char_is_k_o      => PIPETX4CHARISKGT,
         pipe_tx4_data_o           => PIPETX4DATAGT,
         pipe_tx4_elec_idle_o      => PIPETX4ELECIDLEGT,
         pipe_tx4_powerdown_o      => PIPETX4POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 5
         pipe_rx5_char_is_k_o      => PIPERX5CHARISK,
         pipe_rx5_data_o           => PIPERX5DATA,
         pipe_rx5_valid_o          => PIPERX5VALID,
         pipe_rx5_chanisaligned_o  => PIPERX5CHANISALIGNED,
         pipe_rx5_status_o         => PIPERX5STATUS,
         pipe_rx5_phy_status_o     => PIPERX5PHYSTATUS,
         pipe_rx5_elec_idle_i      => PIPERX5ELECIDLEGT,
         pipe_rx5_polarity_i       => PIPERX5POLARITY,
         pipe_tx5_compliance_i     => PIPETX5COMPLIANCE,
         pipe_tx5_char_is_k_i      => PIPETX5CHARISK,
         pipe_tx5_data_i           => PIPETX5DATA,
         pipe_tx5_elec_idle_i      => PIPETX5ELECIDLE,
         pipe_tx5_powerdown_i      => PIPETX5POWERDOWN,
         
         pipe_rx5_char_is_k_i      => PIPERX5CHARISKGT,
         pipe_rx5_data_i           => PIPERX5DATAGT,
         pipe_rx5_valid_i          => PIPERX5VALIDGT,
         pipe_rx5_chanisaligned_i  => PIPERX5CHANISALIGNEDGT,
         pipe_rx5_status_i         => PIPERX5STATUSGT,
         pipe_rx5_phy_status_i     => PIPERX5PHYSTATUSGT,
         pipe_rx5_elec_idle_o      => PIPERX5ELECIDLE,
         pipe_rx5_polarity_o       => PIPERX5POLARITYGT,
         pipe_tx5_compliance_o     => PIPETX5COMPLIANCEGT,
         pipe_tx5_char_is_k_o      => PIPETX5CHARISKGT,
         pipe_tx5_data_o           => PIPETX5DATAGT,
         pipe_tx5_elec_idle_o      => PIPETX5ELECIDLEGT,
         pipe_tx5_powerdown_o      => PIPETX5POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 6
         pipe_rx6_char_is_k_o      => PIPERX6CHARISK,
         pipe_rx6_data_o           => PIPERX6DATA,
         pipe_rx6_valid_o          => PIPERX6VALID,
         pipe_rx6_chanisaligned_o  => PIPERX6CHANISALIGNED,
         pipe_rx6_status_o         => PIPERX6STATUS,
         pipe_rx6_phy_status_o     => PIPERX6PHYSTATUS,
         pipe_rx6_elec_idle_i      => PIPERX6ELECIDLEGT,
         pipe_rx6_polarity_i       => PIPERX6POLARITY,
         pipe_tx6_compliance_i     => PIPETX6COMPLIANCE,
         pipe_tx6_char_is_k_i      => PIPETX6CHARISK,
         pipe_tx6_data_i           => PIPETX6DATA,
         pipe_tx6_elec_idle_i      => PIPETX6ELECIDLE,
         pipe_tx6_powerdown_i      => PIPETX6POWERDOWN,
         
         pipe_rx6_char_is_k_i      => PIPERX6CHARISKGT,
         pipe_rx6_data_i           => PIPERX6DATAGT,
         pipe_rx6_valid_i          => PIPERX6VALIDGT,
         pipe_rx6_chanisaligned_i  => PIPERX6CHANISALIGNEDGT,
         pipe_rx6_status_i         => PIPERX6STATUSGT,
         pipe_rx6_phy_status_i     => PIPERX6PHYSTATUSGT,
         pipe_rx6_elec_idle_o      => PIPERX6ELECIDLE,
         pipe_rx6_polarity_o       => PIPERX6POLARITYGT,
         pipe_tx6_compliance_o     => PIPETX6COMPLIANCEGT,
         pipe_tx6_char_is_k_o      => PIPETX6CHARISKGT,
         pipe_tx6_data_o           => PIPETX6DATAGT,
         pipe_tx6_elec_idle_o      => PIPETX6ELECIDLEGT,
         pipe_tx6_powerdown_o      => PIPETX6POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 7
         pipe_rx7_char_is_k_o      => PIPERX7CHARISK,
         pipe_rx7_data_o           => PIPERX7DATA,
         pipe_rx7_valid_o          => PIPERX7VALID,
         pipe_rx7_chanisaligned_o  => PIPERX7CHANISALIGNED,
         pipe_rx7_status_o         => PIPERX7STATUS,
         pipe_rx7_phy_status_o     => PIPERX7PHYSTATUS,
         pipe_rx7_elec_idle_i      => PIPERX7ELECIDLEGT,
         pipe_rx7_polarity_i       => PIPERX7POLARITY,
         pipe_tx7_compliance_i     => PIPETX7COMPLIANCE,
         pipe_tx7_char_is_k_i      => PIPETX7CHARISK,
         pipe_tx7_data_i           => PIPETX7DATA,
         pipe_tx7_elec_idle_i      => PIPETX7ELECIDLE,
         pipe_tx7_powerdown_i      => PIPETX7POWERDOWN,
         
         pipe_rx7_char_is_k_i      => PIPERX7CHARISKGT,
         pipe_rx7_data_i           => PIPERX7DATAGT,
         pipe_rx7_valid_i          => PIPERX7VALIDGT,
         pipe_rx7_chanisaligned_i  => PIPERX7CHANISALIGNEDGT,
         pipe_rx7_status_i         => PIPERX7STATUSGT,
         pipe_rx7_phy_status_i     => PIPERX7PHYSTATUSGT,
         pipe_rx7_elec_idle_o      => PIPERX7ELECIDLE,
         pipe_rx7_polarity_o       => PIPERX7POLARITYGT,
         pipe_tx7_compliance_o     => PIPETX7COMPLIANCEGT,
         pipe_tx7_char_is_k_o      => PIPETX7CHARISKGT,
         pipe_tx7_data_o           => PIPETX7DATAGT,
         pipe_tx7_elec_idle_o      => PIPETX7ELECIDLEGT,
         pipe_tx7_powerdown_o      => PIPETX7POWERDOWNGT,
         
         -- Non PIPE signals
         pl_ltssm_state            => PLLTSSMSTATE_v6pcie109,
         pipe_clk                  => PIPECLK,
         rst_n                     => PHYRDYN_v6pcie102
      );
   
   ---------------------------------------------------------
   -- Virtex6 GTX Module
   ---------------------------------------------------------
   
   
   
   pcie_gt_i : pcie_gtx_v6
      generic map (
         NO_OF_LANES              => LINK_CAP_MAX_LINK_WIDTH_int,
         LINK_CAP_MAX_LINK_SPEED  => LINK_CAP_MAX_LINK_SPEED,
         REF_CLK_FREQ             => REF_CLK_FREQ,
         PL_FAST_TRAIN            => PL_FAST_TRAIN
      )
      port map (
         
         -- Pipe Common Signals 
         pipe_tx_rcvr_det        => PIPETXRCVRDETGT,
         pipe_tx_reset           => '0',
         pipe_tx_rate            => PIPETXRATEGT,
         pipe_tx_deemph          => PIPETXDEEMPHGT,
         pipe_tx_margin          => PIPETXMARGINGT,
         pipe_tx_swing           => '0',
         
         -- Pipe Per-Lane Signals - Lane 0
         pipe_rx0_char_is_k      => PIPERX0CHARISKGT,
         pipe_rx0_data           => PIPERX0DATAGT,
         pipe_rx0_valid          => PIPERX0VALIDGT,
         pipe_rx0_chanisaligned  => PIPERX0CHANISALIGNEDGT,
         pipe_rx0_status         => PIPERX0STATUSGT,
         pipe_rx0_phy_status     => PIPERX0PHYSTATUSGT,
         pipe_rx0_elec_idle      => PIPERX0ELECIDLEGT,
         pipe_rx0_polarity       => PIPERX0POLARITYGT,
         pipe_tx0_compliance     => PIPETX0COMPLIANCEGT,
         pipe_tx0_char_is_k      => PIPETX0CHARISKGT,
         pipe_tx0_data           => PIPETX0DATAGT,
         pipe_tx0_elec_idle      => PIPETX0ELECIDLEGT,
         pipe_tx0_powerdown      => PIPETX0POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 1
         pipe_rx1_char_is_k      => PIPERX1CHARISKGT,
         pipe_rx1_data           => PIPERX1DATAGT,
         pipe_rx1_valid          => PIPERX1VALIDGT,
         pipe_rx1_chanisaligned  => PIPERX1CHANISALIGNEDGT,
         pipe_rx1_status         => PIPERX1STATUSGT,
         pipe_rx1_phy_status     => PIPERX1PHYSTATUSGT,
         pipe_rx1_elec_idle      => PIPERX1ELECIDLEGT,
         pipe_rx1_polarity       => PIPERX1POLARITYGT,
         pipe_tx1_compliance     => PIPETX1COMPLIANCEGT,
         pipe_tx1_char_is_k      => PIPETX1CHARISKGT,
         pipe_tx1_data           => PIPETX1DATAGT,
         pipe_tx1_elec_idle      => PIPETX1ELECIDLEGT,
         pipe_tx1_powerdown      => PIPETX1POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 2
         pipe_rx2_char_is_k      => PIPERX2CHARISKGT,
         pipe_rx2_data           => PIPERX2DATAGT,
         pipe_rx2_valid          => PIPERX2VALIDGT,
         pipe_rx2_chanisaligned  => PIPERX2CHANISALIGNEDGT,
         pipe_rx2_status         => PIPERX2STATUSGT,
         pipe_rx2_phy_status     => PIPERX2PHYSTATUSGT,
         pipe_rx2_elec_idle      => PIPERX2ELECIDLEGT,
         pipe_rx2_polarity       => PIPERX2POLARITYGT,
         pipe_tx2_compliance     => PIPETX2COMPLIANCEGT,
         pipe_tx2_char_is_k      => PIPETX2CHARISKGT,
         pipe_tx2_data           => PIPETX2DATAGT,
         pipe_tx2_elec_idle      => PIPETX2ELECIDLEGT,
         pipe_tx2_powerdown      => PIPETX2POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 3
         pipe_rx3_char_is_k      => PIPERX3CHARISKGT,
         pipe_rx3_data           => PIPERX3DATAGT,
         pipe_rx3_valid          => PIPERX3VALIDGT,
         pipe_rx3_chanisaligned  => PIPERX3CHANISALIGNEDGT,
         pipe_rx3_status         => PIPERX3STATUSGT,
         pipe_rx3_phy_status     => PIPERX3PHYSTATUSGT,
         pipe_rx3_elec_idle      => PIPERX3ELECIDLEGT,
         pipe_rx3_polarity       => PIPERX3POLARITYGT,
         pipe_tx3_compliance     => PIPETX3COMPLIANCEGT,
         pipe_tx3_char_is_k      => PIPETX3CHARISKGT,
         pipe_tx3_data           => PIPETX3DATAGT,
         pipe_tx3_elec_idle      => PIPETX3ELECIDLEGT,
         pipe_tx3_powerdown      => PIPETX3POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 4
         pipe_rx4_char_is_k      => PIPERX4CHARISKGT,
         pipe_rx4_data           => PIPERX4DATAGT,
         pipe_rx4_valid          => PIPERX4VALIDGT,
         pipe_rx4_chanisaligned  => PIPERX4CHANISALIGNEDGT,
         pipe_rx4_status         => PIPERX4STATUSGT,
         pipe_rx4_phy_status     => PIPERX4PHYSTATUSGT,
         pipe_rx4_elec_idle      => PIPERX4ELECIDLEGT,
         pipe_rx4_polarity       => PIPERX4POLARITYGT,
         pipe_tx4_compliance     => PIPETX4COMPLIANCEGT,
         pipe_tx4_char_is_k      => PIPETX4CHARISKGT,
         pipe_tx4_data           => PIPETX4DATAGT,
         pipe_tx4_elec_idle      => PIPETX4ELECIDLEGT,
         pipe_tx4_powerdown      => PIPETX4POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 5
         pipe_rx5_char_is_k      => PIPERX5CHARISKGT,
         pipe_rx5_data           => PIPERX5DATAGT,
         pipe_rx5_valid          => PIPERX5VALIDGT,
         pipe_rx5_chanisaligned  => PIPERX5CHANISALIGNEDGT,
         pipe_rx5_status         => PIPERX5STATUSGT,
         pipe_rx5_phy_status     => PIPERX5PHYSTATUSGT,
         pipe_rx5_elec_idle      => PIPERX5ELECIDLEGT,
         pipe_rx5_polarity       => PIPERX5POLARITYGT,
         pipe_tx5_compliance     => PIPETX5COMPLIANCEGT,
         pipe_tx5_char_is_k      => PIPETX5CHARISKGT,
         pipe_tx5_data           => PIPETX5DATAGT,
         pipe_tx5_elec_idle      => PIPETX5ELECIDLEGT,
         pipe_tx5_powerdown      => PIPETX5POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 6
         pipe_rx6_char_is_k      => PIPERX6CHARISKGT,
         pipe_rx6_data           => PIPERX6DATAGT,
         pipe_rx6_valid          => PIPERX6VALIDGT,
         pipe_rx6_chanisaligned  => PIPERX6CHANISALIGNEDGT,
         pipe_rx6_status         => PIPERX6STATUSGT,
         pipe_rx6_phy_status     => PIPERX6PHYSTATUSGT,
         pipe_rx6_elec_idle      => PIPERX6ELECIDLEGT,
         pipe_rx6_polarity       => PIPERX6POLARITYGT,
         pipe_tx6_compliance     => PIPETX6COMPLIANCEGT,
         pipe_tx6_char_is_k      => PIPETX6CHARISKGT,
         pipe_tx6_data           => PIPETX6DATAGT,
         pipe_tx6_elec_idle      => PIPETX6ELECIDLEGT,
         pipe_tx6_powerdown      => PIPETX6POWERDOWNGT,
         
         -- Pipe Per-Lane Signals - Lane 7
         pipe_rx7_char_is_k      => PIPERX7CHARISKGT,
         pipe_rx7_data           => PIPERX7DATAGT,
         pipe_rx7_valid          => PIPERX7VALIDGT,
         pipe_rx7_chanisaligned  => PIPERX7CHANISALIGNEDGT,
         pipe_rx7_status         => PIPERX7STATUSGT,
         pipe_rx7_phy_status     => PIPERX7PHYSTATUSGT,
         pipe_rx7_elec_idle      => PIPERX7ELECIDLEGT,
         pipe_rx7_polarity       => PIPERX7POLARITYGT,
         pipe_tx7_compliance     => PIPETX7COMPLIANCEGT,
         pipe_tx7_char_is_k      => PIPETX7CHARISKGT,
         pipe_tx7_data           => PIPETX7DATAGT,
         pipe_tx7_elec_idle      => PIPETX7ELECIDLEGT,
         pipe_tx7_powerdown      => PIPETX7POWERDOWNGT,
         
         -- PCI Express Signals
         pci_exp_txn             => PCIEXPTXN_v6pcie100,
         pci_exp_txp             => PCIEXPTXP_v6pcie101,
         pci_exp_rxn             => PCIEXPRXN,
         pci_exp_rxp             => PCIEXPRXP,
         
         -- Non PIPE Signals
         sys_clk                 => SYSCLK,
         sys_rst_n               => FUNDRSTN,
         pipe_clk                => PIPECLK,
         drp_clk                 => DRPCLK,
         clock_locked            => CLOCKLOCKED,
         pl_ltssm_state          => PLLTSSMSTATE_v6pcie109,
         
         gt_pll_lock             => GTPLLLOCK_v6pcie96,
         phy_rdy_n               => PHYRDYN_v6pcie102,
         txoutclk                => TxOutClk_v6pcie138
      );
   
   ---------------------------------------------------------
   -- PCI Express BRAM Module
   ---------------------------------------------------------
   
   
   
   MIMTXWDATA_tmp <= "000" & MIMTXWDATA;
   MIMRXWDATA_tmp <= "0000" & MIMRXWDATA;
   
   pcie_bram_i : pcie_bram_top_v6
      generic map (
         DEV_CAP_MAX_PAYLOAD_SUPPORTED  => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
         VC0_TX_LASTPACKET              => VC0_TX_LASTPACKET,
         TL_TX_RAM_RADDR_LATENCY        => TL_TX_RAM_RADDR_LATENCY,
         TL_TX_RAM_RDATA_LATENCY        => TL_TX_RAM_RDATA_LATENCY,
         TL_TX_RAM_WRITE_LATENCY        => TL_TX_RAM_WRITE_LATENCY,
         VC0_RX_LIMIT                   => VC0_RX_RAM_LIMIT,
         TL_RX_RAM_RADDR_LATENCY        => TL_RX_RAM_RADDR_LATENCY,
         TL_RX_RAM_RDATA_LATENCY        => TL_RX_RAM_RDATA_LATENCY,
         TL_RX_RAM_WRITE_LATENCY        => TL_RX_RAM_WRITE_LATENCY
      )
      port map (
         
         -- elseEN_128B_INT
         user_clk_i    => USERCLK,
         reset_i       => PHYRDYN_v6pcie102,
         -- endifEN_128B_INT
         
         mim_tx_waddr  => MIMTXWADDR,
         mim_tx_wen    => MIMTXWEN,
         mim_tx_ren    => MIMTXREN,
         mim_tx_rce    => MIMTXRCE,
         mim_tx_wdata  => MIMTXWDATA_tmp,
         mim_tx_raddr  => MIMTXRADDR,
         mim_tx_rdata  => MIMTXRDATA,
         
         mim_rx_waddr  => MIMRXWADDR,
         mim_rx_wen    => MIMRXWEN,
         mim_rx_ren    => MIMRXREN,
         mim_rx_rce    => MIMRXRCE,
         mim_rx_wdata  => MIMRXWDATA_tmp,
         mim_rx_raddr  => MIMRXRADDR,
         mim_rx_rdata  => MIMRXRDATA
      );
   
   ---------------------------------------------------------
   -- PCI Express Port Workarounds
   ---------------------------------------------------------
   
   
   
   pcie_upconfig_fix_3451_v6_i : pcie_upconfig_fix_3451_v6
      generic map (
         UPSTREAM_FACING          => UPSTREAM_FACING,
         PL_FAST_TRAIN            => PL_FAST_TRAIN,
         LINK_CAP_MAX_LINK_WIDTH  => LINK_CAP_MAX_LINK_WIDTH
      )
      port map (
         
         pipe_clk                          => PIPECLK,
         pl_phy_lnkup_n                    => PLPHYLNKUPN_v6pcie110,
         
         pl_ltssm_state                    => PLLTSSMSTATE_v6pcie109,
         pl_sel_lnk_rate                   => PLSELLNKRATE_v6pcie113,
         pl_directed_link_change           => PLDIRECTEDLINKCHANGE,
         
         cfg_link_status_negotiated_width  => CFGLINKSTATUSNEGOTIATEDWIDTH_v6pcie48,
         pipe_rx0_data                     => PIPERX0DATAGT(15 downto 0),
         pipe_rx0_char_isk                 => PIPERX0CHARISKGT(1 downto 0),
         
         filter_pipe                       => filter_pipe_upconfig_fix_3451
      );
   
end v6_pcie;



