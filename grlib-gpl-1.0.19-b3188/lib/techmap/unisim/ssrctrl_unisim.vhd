------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
--
-----------------------------------------------------------------------------
-- Entity:        ssrctrl_unisim
-- file:          ssrctrl_unisim.vhd
-- Description:   32-bit SSRAM memory controller with PROM 16-bit bus support
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ssrctrl_unisim is
port(
  rst :  in std_logic;
  clk :  in std_logic;
  n_ahbsi_hsel : in std_logic_vector (0 to 15);
  n_ahbsi_haddr : in std_logic_vector (31 downto 0);
  n_ahbsi_hwrite :  in std_logic;
  n_ahbsi_htrans : in std_logic_vector (1 downto 0);
  n_ahbsi_hsize : in std_logic_vector (2 downto 0);
  n_ahbsi_hburst : in std_logic_vector (2 downto 0);
  n_ahbsi_hwdata : in std_logic_vector (31 downto 0);
  n_ahbsi_hprot : in std_logic_vector (3 downto 0);
  n_ahbsi_hready :  in std_logic;
  n_ahbsi_hmaster : in std_logic_vector (3 downto 0);
  n_ahbsi_hmastlock :  in std_logic;
  n_ahbsi_hmbsel : in std_logic_vector (0 to 3);
  n_ahbsi_hcache :  in std_logic;
  n_ahbsi_hirq : in std_logic_vector (31 downto 0);
  n_ahbso_hready :  out std_logic;
  n_ahbso_hresp : out std_logic_vector (1 downto 0);
  n_ahbso_hrdata : out std_logic_vector (31 downto 0);
  n_ahbso_hsplit : out std_logic_vector (15 downto 0);
  n_ahbso_hcache :  out std_logic;
  n_ahbso_hirq : out std_logic_vector (31 downto 0);
  n_apbi_psel : in std_logic_vector (0 to 15);
  n_apbi_penable :  in std_logic;
  n_apbi_paddr : in std_logic_vector (31 downto 0);
  n_apbi_pwrite :  in std_logic;
  n_apbi_pwdata : in std_logic_vector (31 downto 0);
  n_apbi_pirq : in std_logic_vector (31 downto 0);
  n_apbo_prdata : out std_logic_vector (31 downto 0);
  n_apbo_pirq : out std_logic_vector (31 downto 0);
  n_sri_data : in std_logic_vector (31 downto 0);
  n_sri_brdyn :  in std_logic;
  n_sri_bexcn :  in std_logic;
  n_sri_writen :  in std_logic;
  n_sri_wrn : in std_logic_vector (3 downto 0);
  n_sri_bwidth : in std_logic_vector (1 downto 0);
  n_sri_sd : in std_logic_vector (63 downto 0);
  n_sri_cb : in std_logic_vector (7 downto 0);
  n_sri_scb : in std_logic_vector (7 downto 0);
  n_sri_edac :  in std_logic;
  n_sro_address : out std_logic_vector (31 downto 0);
  n_sro_data : out std_logic_vector (31 downto 0);
  n_sro_sddata : out std_logic_vector (63 downto 0);
  n_sro_ramsn : out std_logic_vector (7 downto 0);
  n_sro_ramoen : out std_logic_vector (7 downto 0);
  n_sro_ramn :  out std_logic;
  n_sro_romn :  out std_logic;
  n_sro_mben : out std_logic_vector (3 downto 0);
  n_sro_iosn :  out std_logic;
  n_sro_romsn : out std_logic_vector (7 downto 0);
  n_sro_oen :  out std_logic;
  n_sro_writen :  out std_logic;
  n_sro_wrn : out std_logic_vector (3 downto 0);
  n_sro_bdrive : out std_logic_vector (3 downto 0);
  n_sro_vbdrive : out std_logic_vector (31 downto 0);
  n_sro_svbdrive : out std_logic_vector (63 downto 0);
  n_sro_read :  out std_logic;
  n_sro_sa : out std_logic_vector (14 downto 0);
  n_sro_cb : out std_logic_vector (7 downto 0);
  n_sro_scb : out std_logic_vector (7 downto 0);
  n_sro_vcdrive : out std_logic_vector (7 downto 0);
  n_sro_svcdrive : out std_logic_vector (7 downto 0);
  n_sro_ce :  out std_logic);
end ssrctrl_unisim;

--
library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ssrctrl_unisim_netlist is
port(
  n_sro_vbdrive : out std_logic_vector (31 downto 0);
  n_ahbso_hrdata : out std_logic_vector (31 downto 0);
  iows_0 :  out std_logic;
  iows_3 :  out std_logic;
  romwws_0 :  out std_logic;
  romwws_3 :  out std_logic;
  romrws_0 :  out std_logic;
  romrws_3 :  out std_logic;
  NoName_cnst : in std_logic_vector (0 downto 0);
  n_sri_bwidth : in std_logic_vector (1 downto 0);
  n_apbi_pwdata_19 :  in std_logic;
  n_apbi_pwdata_11 :  in std_logic;
  n_apbi_pwdata_9 :  in std_logic;
  n_apbi_pwdata_8 :  in std_logic;
  n_apbi_pwdata_23 :  in std_logic;
  n_apbi_pwdata_22 :  in std_logic;
  n_apbi_pwdata_21 :  in std_logic;
  n_apbi_pwdata_20 :  in std_logic;
  n_apbi_pwdata_3 :  in std_logic;
  n_apbi_pwdata_2 :  in std_logic;
  n_apbi_pwdata_1 :  in std_logic;
  n_apbi_pwdata_0 :  in std_logic;
  n_apbi_pwdata_7 :  in std_logic;
  n_apbi_pwdata_6 :  in std_logic;
  n_apbi_pwdata_5 :  in std_logic;
  n_apbi_pwdata_4 :  in std_logic;
  n_apbi_psel : in std_logic_vector (0 downto 0);
  n_apbi_paddr : in std_logic_vector (5 downto 2);
  n_apbo_prdata_0 :  out std_logic;
  n_apbo_prdata_4 :  out std_logic;
  n_apbo_prdata_20 :  out std_logic;
  n_apbo_prdata_23 :  out std_logic;
  n_apbo_prdata_22 :  out std_logic;
  n_apbo_prdata_21 :  out std_logic;
  n_apbo_prdata_19 :  out std_logic;
  n_apbo_prdata_7 :  out std_logic;
  n_apbo_prdata_6 :  out std_logic;
  n_apbo_prdata_5 :  out std_logic;
  n_apbo_prdata_3 :  out std_logic;
  n_apbo_prdata_2 :  out std_logic;
  n_apbo_prdata_1 :  out std_logic;
  n_apbo_prdata_11 :  out std_logic;
  n_apbo_prdata_9 :  out std_logic;
  n_apbo_prdata_8 :  out std_logic;
  n_apbo_prdata_28 :  out std_logic;
  n_sro_romsn : out std_logic_vector (0 downto 0);
  n_ahbsi_hsel : in std_logic_vector (0 downto 0);
  prstate_fast : out std_logic_vector (2 downto 2);
  n_ahbsi_htrans : in std_logic_vector (1 downto 0);
  ssrstate_1_m1 : inout std_logic_vector (4 downto 3) := (others => 'Z');
  hsel_1 : in std_logic_vector (0 downto 0);
  hmbsel_4 : out std_logic_vector (1 downto 1);
  n_sro_bdrive : out std_logic_vector (3 downto 3);
  ws_1_0 :  in std_logic;
  ws_1_3 :  in std_logic;
  ws : out std_logic_vector (3 downto 0);
  ssrstate_1_2 :  in std_logic;
  n_ahbsi_haddr : in std_logic_vector (31 downto 0);
  n_ahbsi_hmbsel : in std_logic_vector (2 downto 0);
  n_sri_data : in std_logic_vector (31 downto 0);
  ssrstate : out std_logic_vector (4 downto 0);
  n_ahbsi_hwdata : in std_logic_vector (31 downto 0);
  n_ahbsi_hsize : in std_logic_vector (1 downto 0);
  size : out std_logic_vector (1 downto 0);
  n_sro_data : out std_logic_vector (31 downto 0);
  n_sro_ramsn : out std_logic_vector (0 downto 0);
  n_sro_wrn : out std_logic_vector (3 downto 0);
  haddr_0 :  in std_logic;
  bwn_1_0_o3_0 :  in std_logic;
  hsize_1 : in std_logic_vector (1 downto 1);
  prstate_1_i_o4_s : in std_logic_vector (2 downto 2);
  prstate : out std_logic_vector (5 downto 0);
  hmbsel : out std_logic_vector (2 downto 0);
  n_sro_address : out std_logic_vector (31 downto 0);
  hready_2 :  in std_logic;
  n_ahbso_hready :  out std_logic;
  ssrhready_8 :  in std_logic;
  loadcount :  out std_logic;
  n_sro_writen :  out std_logic;
  ssrstatec :  in std_logic;
  prhready :  out std_logic;
  d_m2_0_a2_0 :  in std_logic;
  ssrstate17_2_0_m6_i_a3_a2 :  out std_logic;
  N_319_1 :  out std_logic;
  ws_0_sqmuxa_c :  out std_logic;
  N_365 :  in std_logic;
  ws_0_sqmuxa_0_c :  out std_logic;
  ws_2_sqmuxa_3_0_4 :  out std_logic;
  change_1_sqmuxa_0 :  in std_logic;
  d16mux_0_sqmuxa :  in std_logic;
  ssrstate_2_sqmuxa_1 :  in std_logic;
  un7_bus16en :  in std_logic;
  N_646 :  in std_logic;
  loadcount_1_sqmuxa :  in std_logic;
  ssrstate_1_sqmuxa_1_0_m3_0_1 :  out std_logic;
  n_apbi_penable :  in std_logic;
  n_apbi_pwrite :  in std_logic;
  d_m1_e_0_0 :  in std_logic;
  hsel_1_0_L3 :  out std_logic;
  ssrhready_8_f0_L8 :  out std_logic;
  ssrstate_1_sqmuxa_1 :  in std_logic;
  ssrhready :  out std_logic;
  ssrhready_8_f0_L5 :  out std_logic;
  ssrstate17_1_xx_mm_N_4 :  in std_logic;
  ws_1_sqmuxa :  out std_logic;
  ws_4_sqmuxa_0 :  in std_logic;
  ws_2_sqmuxa_0 :  in std_logic;
  ssrstate17_2_0_m6_i_1 :  out std_logic;
  ws_2_sqmuxa_3_0_x :  out std_logic;
  ws_3_sqmuxa_1 :  out std_logic;
  ws_2_sqmuxa_3_0_2 :  out std_logic;
  ssrstate_2_i :  out std_logic;
  ws_2_sqmuxa_3_d :  out std_logic;
  ws_0_sqmuxa_1 :  out std_logic;
  g0_30 :  in std_logic;
  hsel_4 :  in std_logic;
  n_ahbsi_hready :  in std_logic;
  hsel :  out std_logic;
  g0_25 :  in std_logic;
  bwn_0_sqmuxa_1 :  in std_logic;
  prstate_2_rep1 :  out std_logic;
  N_662 :  out std_logic;
  ssrstate_6_sqmuxa :  out std_logic;
  g0_52_x1 :  in std_logic;
  g0_52_x0 :  in std_logic;
  ssrhready_2_sqmuxa_0_0 :  out std_logic;
  change_1_sqmuxa_N_3 :  out std_logic;
  ssrstate6_xx_mm_m3 :  out std_logic;
  ssrstate6_1_d_0_L1 :  out std_logic;
  N_656 :  out std_logic;
  hsel_5 :  out std_logic;
  change_3_f0 :  in std_logic;
  un1_ahbsi :  out std_logic;
  change :  out std_logic;
  n_ahbsi_hwrite :  in std_logic;
  N_574_i :  in std_logic;
  n_sro_iosn :  out std_logic;
  N_618_i :  in std_logic;
  clk :  in std_logic;
  n_sro_oen :  out std_logic;
  rst :  in std_logic;
  bwn_1_sqmuxa_2_d :  in std_logic;
  bwn_1_sqmuxa_2_d_0_2 :  in std_logic;
  ssrstate_2_sqmuxa_i :  in std_logic;
  g0_23 :  in std_logic;
  N_371 :  out std_logic;
  loadcount_7 :  in std_logic;
  bus16en :  out std_logic;
  d16muxc_0_4 :  out std_logic;
  change_3_f1_d_0_0 :  in std_logic;
  g0_1_0 :  in std_logic;
  g0_44 :  in std_logic);
end ssrctrl_unisim_netlist;

architecture beh of ssrctrl_unisim_netlist is
  signal ACOUNT_QXU : std_logic_vector (9 downto 1);
  signal ACOUNT_LM_0_1 : std_logic_vector (0 to 0);
  signal ACOUNT_LM : std_logic_vector (9 downto 0);
  signal WS_1_0_BM : std_logic_vector (1 to 1);
  signal WS_1_0_RN_1 : std_logic_vector (1 to 1);
  signal WS_1 : std_logic_vector (2 downto 1);
  signal SSRSTATE_1_0_D_BM : std_logic_vector (3 to 3);
  signal SSRSTATE_1_0_1 : std_logic_vector (3 to 3);
  signal SSRSTATE_1 : std_logic_vector (3 downto 2);
  signal BWN_1_0_O3 : std_logic_vector (1 to 1);
  signal PRSTATE_I : std_logic_vector (1 to 1);
  signal HWDATAOUT_1 : std_logic_vector (31 downto 0);
  signal ROMWIDTH : std_logic_vector (1 downto 0);
  signal ROMWIDTH_1 : std_logic_vector (1 downto 0);
  signal DATA16 : std_logic_vector (15 downto 0);
  signal HRDATA : std_logic_vector (31 downto 0);
  signal HWDATA : std_logic_vector (31 downto 0);
  signal HADDR : std_logic_vector (11 downto 2);
  signal SSRSTATE_1_0_D_AM : std_logic_vector (3 to 3);
  signal HMBSEL_4_X1 : std_logic_vector (1 to 1);
  signal WS_1_2_0_D : std_logic_vector (2 downto 1);
  signal WS_1_0_AM_1 : std_logic_vector (1 to 1);
  signal BWN_1_0_0 : std_logic_vector (3 to 3);
  signal IOWS_1 : std_logic_vector (3 downto 0);
  signal ACOUNT_S : std_logic_vector (9 downto 1);
  signal SSRSTATE_11 : std_logic_vector (0 to 0);
  signal SSRSTATE23_U_0_AM : std_logic_vector (4 to 4);
  signal SSRSTATE23_U_0_BM : std_logic_vector (4 to 4);
  signal ROMRWS : std_logic_vector (2 downto 1);
  signal IOWS : std_logic_vector (2 downto 1);
  signal ROMWWS : std_logic_vector (2 downto 1);
  signal D16MUX : std_logic_vector (1 downto 0);
  signal ACOUNT_CRY : std_logic_vector (8 downto 1);
  signal ROMSN_1_IV_L1 : std_logic ;
  signal CHANGE_3 : std_logic ;
  signal ROMSN_1 : std_logic ;
  signal PRHREADY_6 : std_logic ;
  signal N_635_I_1 : std_logic ;
  signal N_635_I : std_logic ;
  signal D16MUXC_0_1 : std_logic ;
  signal D16MUXC_0_1_0 : std_logic ;
  signal D16MUXC_0_4_INT_73 : std_logic ;
  signal D16MUXC_0 : std_logic ;
  signal N_371_INT_71 : std_logic ;
  signal WS_1_L1 : std_logic ;
  signal WS_1_L1_0 : std_logic ;
  signal SSRSTATE_1_M2S2_0 : std_logic ;
  signal IOSN_9_IV_L1 : std_logic ;
  signal PRSTATE_0_INT_27 : std_logic ;
  signal IOSN_9 : std_logic ;
  signal N_317 : std_logic ;
  signal N_619_I_L1 : std_logic ;
  signal N_619_I : std_logic ;
  signal N_620_I : std_logic ;
  signal PRSTATE_1_INT_28 : std_logic ;
  signal RST_I : std_logic ;
  signal OEN_1 : std_logic ;
  signal OEN_1_SQMUXA_2_I : std_logic ;
  signal BWN_1_SQMUXA_3_I : std_logic ;
  signal N_617_I : std_logic ;
  signal N_599_I : std_logic ;
  signal SSRSTATE_9 : std_logic ;
  signal BEXCEN_1_SQMUXA_I : std_logic ;
  signal DATA16_0_SQMUXA : std_logic ;
  signal HMBSEL_0_SQMUXA : std_logic ;
  signal HWRITE : std_logic ;
  signal SSRSTATE_1_INT_21 : std_logic ;
  signal HMBSEL_0_INT_33 : std_logic ;
  signal HMBSEL_2_INT_35 : std_logic ;
  signal BDRIVE_1 : std_logic ;
  signal N_SRO_ADDRESS_2_INT_38 : std_logic ;
  signal N_SRO_ADDRESS_3_INT_39 : std_logic ;
  signal N_SRO_ADDRESS_4_INT_40 : std_logic ;
  signal N_SRO_ADDRESS_5_INT_41 : std_logic ;
  signal N_SRO_ADDRESS_6_INT_42 : std_logic ;
  signal N_SRO_ADDRESS_7_INT_43 : std_logic ;
  signal N_SRO_ADDRESS_8_INT_44 : std_logic ;
  signal N_SRO_ADDRESS_9_INT_45 : std_logic ;
  signal N_SRO_ADDRESS_10_INT_46 : std_logic ;
  signal OEN_1_SQMUXA_2_I_L4 : std_logic ;
  signal PRSTATE_1 : std_logic ;
  signal OEN_1_SQMUXA_2_I_L6 : std_logic ;
  signal N_654 : std_logic ;
  signal SSRSTATE_2_INT_22 : std_logic ;
  signal SSRSTATE_12_1 : std_logic ;
  signal WS_1_0_BM_L1 : std_logic ;
  signal WS_1_0_BM_L3 : std_logic ;
  signal UN1_AHBSI_INT_68 : std_logic ;
  signal HSEL_5_INT_67 : std_logic ;
  signal WS_1_0_BM_L5 : std_logic ;
  signal HMBSEL_4_1_INT_14 : std_logic ;
  signal N_619_I_L1_L1 : std_logic ;
  signal SSRSTATE6_XX_MM_M3_INT_64 : std_logic ;
  signal HMBSEL_1_INT_34 : std_logic ;
  signal SSRSTATE_6_SQMUXA_1 : std_logic ;
  signal N_SRO_ADDRESS_0_INT_36 : std_logic ;
  signal SIZE_0_INT_25 : std_logic ;
  signal BWN_1_0_O3_0_L1 : std_logic ;
  signal BWN_1_0_O3_0_L3 : std_logic ;
  signal BWN_1_0_O3_0_L5 : std_logic ;
  signal PRSTATE_2_REP1_INT_59 : std_logic ;
  signal PRSTATEC_0_REP1 : std_logic ;
  signal N_336 : std_logic ;
  signal PRSTATEC_0_FAST : std_logic ;
  signal WS_1_INT_17 : std_logic ;
  signal BDRIVE_1_IV_M9_I_A4_0_2_1 : std_logic ;
  signal BDRIVE_1_IV_M9_I_A4_0_2_2_1 : std_logic ;
  signal BDRIVE_0_SQMUXA_2_C : std_logic ;
  signal BDRIVE_1_IV_M9_I_A4_0_2_2_L1 : std_logic ;
  signal BDRIVE_1_TZ : std_logic ;
  signal BDRIVE_1_IV_M9_I_A4_0_2_2_1_L1 : std_logic ;
  signal N_SRO_BDRIVE_3_INT_15 : std_logic ;
  signal BDRIVE_1_IV_M9_I_A4_0_2_2_1_L3 : std_logic ;
  signal N_668 : std_logic ;
  signal BDRIVE_1_SQMUXA : std_logic ;
  signal N_662_INT_60 : std_logic ;
  signal SSRSTATE6_XX_MM_M3_L1 : std_logic ;
  signal PRSTATE_5_INT_32 : std_logic ;
  signal SSRSTATE_4_INT_24 : std_logic ;
  signal SSRSTATE6_XX_MM_M3_L3 : std_logic ;
  signal WS_2_SQMUXA_3_0_SX : std_logic ;
  signal WS_0_SQMUXA_1_INT_57 : std_logic ;
  signal WS_2_SQMUXA_3_D_INT_56 : std_logic ;
  signal SSRSTATE17_2_0_M6_I_A3_A0_1 : std_logic ;
  signal CHANGE_3_F1_D_0_L1 : std_logic ;
  signal CHANGE_INT_69 : std_logic ;
  signal PRSTATE_2_INT_29 : std_logic ;
  signal WRITEN_2_SQMUXA_L1 : std_logic ;
  signal WRITEN_2_SQMUXA_L3 : std_logic ;
  signal WRITEN_2_SQMUXA_L5 : std_logic ;
  signal WRITEN_2_SQMUXA_TZ_0 : std_logic ;
  signal BWN_1_SQMUXA_2_D_0 : std_logic ;
  signal WRITEN_2_SQMUXA : std_logic ;
  signal WS_3_SQMUXA_1_INT_53 : std_logic ;
  signal WS_1_L1_L1 : std_logic ;
  signal WS_2_INT_18 : std_logic ;
  signal WS_2_SQMUXA_3_0_2_L1 : std_logic ;
  signal WS_2_SQMUXA_3_0_2_INT_54 : std_logic ;
  signal WS_0_INT_16 : std_logic ;
  signal SSRSTATE_3_INT_23 : std_logic ;
  signal SSRSTATE6_1_D_0_L1_INT_65 : std_logic ;
  signal WS_3_SQMUXA_0_1 : std_logic ;
  signal WS_3_SQMUXA_1_A0_2 : std_logic ;
  signal N_SRO_ROMSN_0_INT_12 : std_logic ;
  signal PRSTATE_8_1 : std_logic ;
  signal N_656_INT_66 : std_logic ;
  signal N_SRO_IOSN_INT_70 : std_logic ;
  signal PRSTATE_FAST_2_INT_13 : std_logic ;
  signal BEXCEN_1_SQMUXA_I_1 : std_logic ;
  signal HSEL_INT_58 : std_logic ;
  signal PRSTATE_12_M7_I_A6_0 : std_logic ;
  signal PRSTATE_12_I : std_logic ;
  signal HWRITE_1 : std_logic ;
  signal PRSTATE_12_0 : std_logic ;
  signal PRSTATE_12_M7_I_A6 : std_logic ;
  signal PRSTATE_4_INT_31 : std_logic ;
  signal SIZE_1_INT_26 : std_logic ;
  signal PRSTATE_1_SQMUXA : std_logic ;
  signal BUS16EN_INT_72 : std_logic ;
  signal N_382 : std_logic ;
  signal N_383 : std_logic ;
  signal N_384 : std_logic ;
  signal N_385 : std_logic ;
  signal N_386 : std_logic ;
  signal N_387 : std_logic ;
  signal N_388 : std_logic ;
  signal N_389 : std_logic ;
  signal N_390 : std_logic ;
  signal N_391 : std_logic ;
  signal N_392 : std_logic ;
  signal N_393 : std_logic ;
  signal N_394 : std_logic ;
  signal N_395 : std_logic ;
  signal N_396 : std_logic ;
  signal N_397 : std_logic ;
  signal N_626_I : std_logic ;
  signal N_625_I : std_logic ;
  signal N_624_I : std_logic ;
  signal N_623_I : std_logic ;
  signal N_630_I : std_logic ;
  signal N_629_I : std_logic ;
  signal N_628_I : std_logic ;
  signal N_627_I : std_logic ;
  signal ROMWRITE_1 : std_logic ;
  signal IOEN_1 : std_logic ;
  signal SSRSTATE_6_SQMUXA_INT_61 : std_logic ;
  signal BDRIVE_1_IV_0_A0 : std_logic ;
  signal BDRIVE_1_IV_0_A1 : std_logic ;
  signal BDRIVE_1_IV_M9_I_0_0 : std_logic ;
  signal NN_1 : std_logic ;
  signal NN_2 : std_logic ;
  signal NN_3 : std_logic ;
  signal NN_4 : std_logic ;
  signal NN_5 : std_logic ;
  signal NN_6 : std_logic ;
  signal NN_7 : std_logic ;
  signal NN_8 : std_logic ;
  signal NN_9 : std_logic ;
  signal D16MUXC_1 : std_logic ;
  signal D16MUXC_2 : std_logic ;
  signal D16MUXC : std_logic ;
  signal BDRIVE_1_IV_0_1 : std_logic ;
  signal BDRIVE_1_IV_M9_I_0 : std_logic ;
  signal RBDRIVEC_18 : std_logic ;
  signal SSRSTATE_5_I : std_logic ;
  signal SSRSTATEC_0 : std_logic ;
  signal SSRSTATE23_1 : std_logic ;
  signal WS_3_INT_19 : std_logic ;
  signal PRSTATEC_1 : std_logic ;
  signal N_337_I : std_logic ;
  signal PRSTATEC_0 : std_logic ;
  signal PRSTATE_3_INT_30 : std_logic ;
  signal PRSTATEC : std_logic ;
  signal N_342 : std_logic ;
  signal PRSTATESR_0 : std_logic ;
  signal PRSTATES_I : std_logic ;
  signal N_SRO_ADDRESS_11_INT_47 : std_logic ;
  signal WRITEN_0_SQMUXA_0_2 : std_logic ;
  signal WRITEN_0_SQMUXA_D : std_logic ;
  signal RBDRIVEC : std_logic ;
  signal SSRSTATE_2_I_INT_55 : std_logic ;
  signal HADDR_0_SQMUXA_A0_0 : std_logic ;
  signal WRITEN_0_SQMUXA_0_0 : std_logic ;
  signal BDRIVE_1_SQMUXA_2 : std_logic ;
  signal WS_0_SQMUXA_0_0_0 : std_logic ;
  signal CHANGE_1_SQMUXA_N_3_INT_63 : std_logic ;
  signal SSRHREADY_2_SQMUXA_0_0_INT_62 : std_logic ;
  signal N_362 : std_logic ;
  signal N_363 : std_logic ;
  signal SETBDRIVE : std_logic ;
  signal N_341 : std_logic ;
  signal BDRIVE_0_SQMUXA_2_0_0 : std_logic ;
  signal BDRIVE_1_IV_0_A4_0 : std_logic ;
  signal SSRSTATE_0_INT_20 : std_logic ;
  signal PRHREADY_0_SQMUXA : std_logic ;
  signal SSRSTATE10 : std_logic ;
  signal WS_0_SQMUXA_0_C_INT_50 : std_logic ;
  signal N_SRO_ADDRESS_1_INT_37 : std_logic ;
  signal UN17_BUS16EN : std_logic ;
  signal WS_1_SQMUXA_INT_52 : std_logic ;
  signal SSRSTATE_3 : std_logic ;
  signal WS_0_SQMUXA_C_INT_49 : std_logic ;
  signal ROMWRITE : std_logic ;
  signal IOEN : std_logic ;
  signal N_APBO_PRDATA_28_INT_11 : std_logic ;
  signal NN_10 : std_logic ;
  signal N_481 : std_logic ;
  signal N_480 : std_logic ;
  signal IOWS_3_INT_6 : std_logic ;
  signal IOWS_0_INT_5 : std_logic ;
  signal ROMRWS_3_INT_10 : std_logic ;
  signal ROMRWS_0_INT_9 : std_logic ;
  signal ROMWWS_3_INT_8 : std_logic ;
  signal ROMWWS_0_INT_7 : std_logic ;
  signal SSRHREADY_INT_51 : std_logic ;
  signal PRHREADY_INT_48 : std_logic ;
  signal NN_11 : std_logic ;
begin
  II_r_acount_qxuHAKL1HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_3_INT_39,
    O => ACOUNT_QXU(1));
  II_r_acount_qxuHAKL2HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_4_INT_40,
    O => ACOUNT_QXU(2));
  II_r_acount_qxuHAKL3HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_5_INT_41,
    O => ACOUNT_QXU(3));
  II_r_acount_qxuHAKL4HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_6_INT_42,
    O => ACOUNT_QXU(4));
  II_r_acount_qxuHAKL5HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_7_INT_43,
    O => ACOUNT_QXU(5));
  II_r_acount_qxuHAKL6HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_8_INT_44,
    O => ACOUNT_QXU(6));
  II_r_acount_qxuHAKL7HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_9_INT_45,
    O => ACOUNT_QXU(7));
  II_r_acount_qxuHAKL8HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_10_INT_46,
    O => ACOUNT_QXU(8));
  II_ctrl_v_romsn_1_iv: LUT4_L
  generic map(
    INIT => X"0EEE"
  )
  port map (
    I0 => ROMSN_1_IV_L1,
    I1 => CHANGE_3,
    I2 => HMBSEL_0_INT_33,
    I3 => PRSTATE_0_INT_27,
    LO => ROMSN_1);
  II_v_prstate_1_i_o4_0HAKL2HAKR: LUT4_L
  generic map(
    INIT => X"80AA"
  )
  port map (
    I0 => g0_44,
    I1 => g0_1_0,
    I2 => change_3_f1_d_0_0,
    I3 => prstate_1_i_o4_s(2),
    LO => PRHREADY_6);
  II_v_N_635_i: LUT4_L
  generic map(
    INIT => X"888B"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => PRSTATE_1_INT_28,
    I2 => PRSTATE_2_INT_29,
    I3 => N_635_I_1,
    LO => N_635_I);
  II_r_d16muxc_0: LUT4_L
  generic map(
    INIT => X"8000"
  )
  port map (
    I0 => BUS16EN_INT_72,
    I1 => D16MUXC_0_1,
    I2 => D16MUXC_0_1_0,
    I3 => D16MUXC_0_4_INT_73,
    LO => D16MUXC_0);
  II_r_acount_lm_0HAKL0HAKR: LUT3_L
  generic map(
    INIT => X"1D"
  )
  port map (
    I0 => N_SRO_ADDRESS_2_INT_38,
    I1 => loadcount_7,
    I2 => ACOUNT_LM_0_1(0),
    LO => ACOUNT_LM(0));
  II_ctrl_v_ws_1_0HAKL1HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_371_INT_71,
    I1 => WS_1_0_BM(1),
    I2 => WS_1_0_RN_1(1),
    LO => WS_1(1));
  II_ctrl_v_ws_1HAKL2HAKR: LUT4_L
  generic map(
    INIT => X"1141"
  )
  port map (
    I0 => N_371_INT_71,
    I1 => WS_1_L1,
    I2 => g0_23,
    I3 => WS_1_L1_0,
    LO => WS_1(2));
  II_ctrl_v_ssrstate_1_0HAKL3HAKR: LUT4_L
  generic map(
    INIT => X"B333"
  )
  port map (
    I0 => SSRSTATE_1_0_D_BM(3),
    I1 => SSRSTATE_1_0_1(3),
    I2 => SSRSTATE_1_M2S2_0,
    I3 => ssrstate_2_sqmuxa_i,
    LO => SSRSTATE_1(3));
  II_ctrl_v_iosn_9_iv: LUT4_L
  generic map(
    INIT => X"0EEE"
  )
  port map (
    I0 => IOSN_9_IV_L1,
    I1 => CHANGE_3,
    I2 => HMBSEL_2_INT_35,
    I3 => PRSTATE_0_INT_27,
    LO => IOSN_9);
  II_ctrl_v_N_619_i: LUT4_L
  generic map(
    INIT => X"AFBF"
  )
  port map (
    I0 => N_317,
    I1 => N_619_I_L1,
    I2 => BWN_1_0_O3(1),
    I3 => bwn_1_sqmuxa_2_d_0_2,
    LO => N_619_I);
  II_ctrl_v_N_620_i: LUT4_L
  generic map(
    INIT => X"73FF"
  )
  port map (
    I0 => hsize_1(1),
    I1 => bwn_1_0_o3_0,
    I2 => haddr_0,
    I3 => bwn_1_sqmuxa_2_d,
    LO => N_620_I);
  II_r_prstate_iHAKL1HAKR: INV port map (
      I => PRSTATE_1_INT_28,
      O => PRSTATE_I(1));
  II_ctrl_v_rst_i: INV port map (
      I => rst,
      O => RST_I);
  II_r_oen: FDPE port map (
      Q => n_sro_oen,
      D => OEN_1,
      C => clk,
      PRE => RST_I,
      CE => OEN_1_SQMUXA_2_I);
  II_r_bwnHAKL0HAKR: FDE port map (
      Q => n_sro_wrn(0),
      D => N_620_I,
      C => clk,
      CE => BWN_1_SQMUXA_3_I);
  II_r_bwnHAKL1HAKR: FDE port map (
      Q => n_sro_wrn(1),
      D => N_619_I,
      C => clk,
      CE => BWN_1_SQMUXA_3_I);
  II_r_bwnHAKL2HAKR: FDE port map (
      Q => n_sro_wrn(2),
      D => N_618_i,
      C => clk,
      CE => BWN_1_SQMUXA_3_I);
  II_r_bwnHAKL3HAKR: FDE port map (
      Q => n_sro_wrn(3),
      D => N_617_I,
      C => clk,
      CE => BWN_1_SQMUXA_3_I);
  II_r_iosn: FDPE port map (
      Q => N_SRO_IOSN_INT_70,
      D => IOSN_9,
      C => clk,
      PRE => RST_I,
      CE => N_599_I);
  II_r_ramsn: FDPE port map (
      Q => n_sro_ramsn(0),
      D => N_574_i,
      C => clk,
      PRE => RST_I,
      CE => SSRSTATE_9);
  II_r_hwdataoutHAKL0HAKR: FDE port map (
      Q => n_sro_data(0),
      D => HWDATAOUT_1(0),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL1HAKR: FDE port map (
      Q => n_sro_data(1),
      D => HWDATAOUT_1(1),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL2HAKR: FDE port map (
      Q => n_sro_data(2),
      D => HWDATAOUT_1(2),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL3HAKR: FDE port map (
      Q => n_sro_data(3),
      D => HWDATAOUT_1(3),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL4HAKR: FDE port map (
      Q => n_sro_data(4),
      D => HWDATAOUT_1(4),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL5HAKR: FDE port map (
      Q => n_sro_data(5),
      D => HWDATAOUT_1(5),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL6HAKR: FDE port map (
      Q => n_sro_data(6),
      D => HWDATAOUT_1(6),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL7HAKR: FDE port map (
      Q => n_sro_data(7),
      D => HWDATAOUT_1(7),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL8HAKR: FDE port map (
      Q => n_sro_data(8),
      D => HWDATAOUT_1(8),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL9HAKR: FDE port map (
      Q => n_sro_data(9),
      D => HWDATAOUT_1(9),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL10HAKR: FDE port map (
      Q => n_sro_data(10),
      D => HWDATAOUT_1(10),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL11HAKR: FDE port map (
      Q => n_sro_data(11),
      D => HWDATAOUT_1(11),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL12HAKR: FDE port map (
      Q => n_sro_data(12),
      D => HWDATAOUT_1(12),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL13HAKR: FDE port map (
      Q => n_sro_data(13),
      D => HWDATAOUT_1(13),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL14HAKR: FDE port map (
      Q => n_sro_data(14),
      D => HWDATAOUT_1(14),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL15HAKR: FDE port map (
      Q => n_sro_data(15),
      D => HWDATAOUT_1(15),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL16HAKR: FDE port map (
      Q => n_sro_data(16),
      D => HWDATAOUT_1(16),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL17HAKR: FDE port map (
      Q => n_sro_data(17),
      D => HWDATAOUT_1(17),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL18HAKR: FDE port map (
      Q => n_sro_data(18),
      D => HWDATAOUT_1(18),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL19HAKR: FDE port map (
      Q => n_sro_data(19),
      D => HWDATAOUT_1(19),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL20HAKR: FDE port map (
      Q => n_sro_data(20),
      D => HWDATAOUT_1(20),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL21HAKR: FDE port map (
      Q => n_sro_data(21),
      D => HWDATAOUT_1(21),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL22HAKR: FDE port map (
      Q => n_sro_data(22),
      D => HWDATAOUT_1(22),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL23HAKR: FDE port map (
      Q => n_sro_data(23),
      D => HWDATAOUT_1(23),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL24HAKR: FDE port map (
      Q => n_sro_data(24),
      D => HWDATAOUT_1(24),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL25HAKR: FDE port map (
      Q => n_sro_data(25),
      D => HWDATAOUT_1(25),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL26HAKR: FDE port map (
      Q => n_sro_data(26),
      D => HWDATAOUT_1(26),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL27HAKR: FDE port map (
      Q => n_sro_data(27),
      D => HWDATAOUT_1(27),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL28HAKR: FDE port map (
      Q => n_sro_data(28),
      D => HWDATAOUT_1(28),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL29HAKR: FDE port map (
      Q => n_sro_data(29),
      D => HWDATAOUT_1(29),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL30HAKR: FDE port map (
      Q => n_sro_data(30),
      D => HWDATAOUT_1(30),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_hwdataoutHAKL31HAKR: FDE port map (
      Q => n_sro_data(31),
      D => HWDATAOUT_1(31),
      C => clk,
      CE => PRSTATE_I(1));
  II_r_mcfg1_romwidthHAKL0HAKR: FDE port map (
      Q => ROMWIDTH(0),
      D => ROMWIDTH_1(0),
      C => clk,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwidthHAKL1HAKR: FDE port map (
      Q => ROMWIDTH(1),
      D => ROMWIDTH_1(1),
      C => clk,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_data16HAKL0HAKR: FDE port map (
      Q => DATA16(0),
      D => HRDATA(16),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL1HAKR: FDE port map (
      Q => DATA16(1),
      D => HRDATA(17),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL2HAKR: FDE port map (
      Q => DATA16(2),
      D => HRDATA(18),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL3HAKR: FDE port map (
      Q => DATA16(3),
      D => HRDATA(19),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL4HAKR: FDE port map (
      Q => DATA16(4),
      D => HRDATA(20),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL5HAKR: FDE port map (
      Q => DATA16(5),
      D => HRDATA(21),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL6HAKR: FDE port map (
      Q => DATA16(6),
      D => HRDATA(22),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL7HAKR: FDE port map (
      Q => DATA16(7),
      D => HRDATA(23),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL8HAKR: FDE port map (
      Q => DATA16(8),
      D => HRDATA(24),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL9HAKR: FDE port map (
      Q => DATA16(9),
      D => HRDATA(25),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL10HAKR: FDE port map (
      Q => DATA16(10),
      D => HRDATA(26),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL11HAKR: FDE port map (
      Q => DATA16(11),
      D => HRDATA(27),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL12HAKR: FDE port map (
      Q => DATA16(12),
      D => HRDATA(28),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL13HAKR: FDE port map (
      Q => DATA16(13),
      D => HRDATA(29),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL14HAKR: FDE port map (
      Q => DATA16(14),
      D => HRDATA(30),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_data16HAKL15HAKR: FDE port map (
      Q => DATA16(15),
      D => HRDATA(31),
      C => clk,
      CE => DATA16_0_SQMUXA);
  II_r_sizeHAKL0HAKR: FDE port map (
      Q => SIZE_0_INT_25,
      D => n_ahbsi_hsize(0),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_sizeHAKL1HAKR: FDE port map (
      Q => SIZE_1_INT_26,
      D => n_ahbsi_hsize(1),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_hwrite: FDE port map (
      Q => HWRITE,
      D => n_ahbsi_hwrite,
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_hwdataHAKL0HAKR: FDE port map (
      Q => HWDATA(0),
      D => n_ahbsi_hwdata(0),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL1HAKR: FDE port map (
      Q => HWDATA(1),
      D => n_ahbsi_hwdata(1),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL2HAKR: FDE port map (
      Q => HWDATA(2),
      D => n_ahbsi_hwdata(2),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL3HAKR: FDE port map (
      Q => HWDATA(3),
      D => n_ahbsi_hwdata(3),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL4HAKR: FDE port map (
      Q => HWDATA(4),
      D => n_ahbsi_hwdata(4),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL5HAKR: FDE port map (
      Q => HWDATA(5),
      D => n_ahbsi_hwdata(5),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL6HAKR: FDE port map (
      Q => HWDATA(6),
      D => n_ahbsi_hwdata(6),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL7HAKR: FDE port map (
      Q => HWDATA(7),
      D => n_ahbsi_hwdata(7),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL8HAKR: FDE port map (
      Q => HWDATA(8),
      D => n_ahbsi_hwdata(8),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL9HAKR: FDE port map (
      Q => HWDATA(9),
      D => n_ahbsi_hwdata(9),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL10HAKR: FDE port map (
      Q => HWDATA(10),
      D => n_ahbsi_hwdata(10),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL11HAKR: FDE port map (
      Q => HWDATA(11),
      D => n_ahbsi_hwdata(11),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL12HAKR: FDE port map (
      Q => HWDATA(12),
      D => n_ahbsi_hwdata(12),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL13HAKR: FDE port map (
      Q => HWDATA(13),
      D => n_ahbsi_hwdata(13),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL14HAKR: FDE port map (
      Q => HWDATA(14),
      D => n_ahbsi_hwdata(14),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL15HAKR: FDE port map (
      Q => HWDATA(15),
      D => n_ahbsi_hwdata(15),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL16HAKR: FDE port map (
      Q => HWDATA(16),
      D => n_ahbsi_hwdata(16),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL17HAKR: FDE port map (
      Q => HWDATA(17),
      D => n_ahbsi_hwdata(17),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL18HAKR: FDE port map (
      Q => HWDATA(18),
      D => n_ahbsi_hwdata(18),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL19HAKR: FDE port map (
      Q => HWDATA(19),
      D => n_ahbsi_hwdata(19),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL20HAKR: FDE port map (
      Q => HWDATA(20),
      D => n_ahbsi_hwdata(20),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL21HAKR: FDE port map (
      Q => HWDATA(21),
      D => n_ahbsi_hwdata(21),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL22HAKR: FDE port map (
      Q => HWDATA(22),
      D => n_ahbsi_hwdata(22),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL23HAKR: FDE port map (
      Q => HWDATA(23),
      D => n_ahbsi_hwdata(23),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL24HAKR: FDE port map (
      Q => HWDATA(24),
      D => n_ahbsi_hwdata(24),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL25HAKR: FDE port map (
      Q => HWDATA(25),
      D => n_ahbsi_hwdata(25),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL26HAKR: FDE port map (
      Q => HWDATA(26),
      D => n_ahbsi_hwdata(26),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL27HAKR: FDE port map (
      Q => HWDATA(27),
      D => n_ahbsi_hwdata(27),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL28HAKR: FDE port map (
      Q => HWDATA(28),
      D => n_ahbsi_hwdata(28),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL29HAKR: FDE port map (
      Q => HWDATA(29),
      D => n_ahbsi_hwdata(29),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL30HAKR: FDE port map (
      Q => HWDATA(30),
      D => n_ahbsi_hwdata(30),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hwdataHAKL31HAKR: FDE port map (
      Q => HWDATA(31),
      D => n_ahbsi_hwdata(31),
      C => clk,
      CE => SSRSTATE_1_INT_21);
  II_r_hrdataHAKL22HAKR: FD port map (
      Q => HRDATA(22),
      D => n_sri_data(22),
      C => clk);
  II_r_hrdataHAKL23HAKR: FD port map (
      Q => HRDATA(23),
      D => n_sri_data(23),
      C => clk);
  II_r_hrdataHAKL24HAKR: FD port map (
      Q => HRDATA(24),
      D => n_sri_data(24),
      C => clk);
  II_r_hrdataHAKL25HAKR: FD port map (
      Q => HRDATA(25),
      D => n_sri_data(25),
      C => clk);
  II_r_hrdataHAKL26HAKR: FD port map (
      Q => HRDATA(26),
      D => n_sri_data(26),
      C => clk);
  II_r_hrdataHAKL27HAKR: FD port map (
      Q => HRDATA(27),
      D => n_sri_data(27),
      C => clk);
  II_r_hrdataHAKL28HAKR: FD port map (
      Q => HRDATA(28),
      D => n_sri_data(28),
      C => clk);
  II_r_hrdataHAKL29HAKR: FD port map (
      Q => HRDATA(29),
      D => n_sri_data(29),
      C => clk);
  II_r_hrdataHAKL30HAKR: FD port map (
      Q => HRDATA(30),
      D => n_sri_data(30),
      C => clk);
  II_r_hrdataHAKL31HAKR: FD port map (
      Q => HRDATA(31),
      D => n_sri_data(31),
      C => clk);
  II_r_hrdataHAKL7HAKR: FD port map (
      Q => HRDATA(7),
      D => n_sri_data(7),
      C => clk);
  II_r_hrdataHAKL8HAKR: FD port map (
      Q => HRDATA(8),
      D => n_sri_data(8),
      C => clk);
  II_r_hrdataHAKL9HAKR: FD port map (
      Q => HRDATA(9),
      D => n_sri_data(9),
      C => clk);
  II_r_hrdataHAKL10HAKR: FD port map (
      Q => HRDATA(10),
      D => n_sri_data(10),
      C => clk);
  II_r_hrdataHAKL11HAKR: FD port map (
      Q => HRDATA(11),
      D => n_sri_data(11),
      C => clk);
  II_r_hrdataHAKL12HAKR: FD port map (
      Q => HRDATA(12),
      D => n_sri_data(12),
      C => clk);
  II_r_hrdataHAKL13HAKR: FD port map (
      Q => HRDATA(13),
      D => n_sri_data(13),
      C => clk);
  II_r_hrdataHAKL14HAKR: FD port map (
      Q => HRDATA(14),
      D => n_sri_data(14),
      C => clk);
  II_r_hrdataHAKL15HAKR: FD port map (
      Q => HRDATA(15),
      D => n_sri_data(15),
      C => clk);
  II_r_hrdataHAKL16HAKR: FD port map (
      Q => HRDATA(16),
      D => n_sri_data(16),
      C => clk);
  II_r_hrdataHAKL17HAKR: FD port map (
      Q => HRDATA(17),
      D => n_sri_data(17),
      C => clk);
  II_r_hrdataHAKL18HAKR: FD port map (
      Q => HRDATA(18),
      D => n_sri_data(18),
      C => clk);
  II_r_hrdataHAKL19HAKR: FD port map (
      Q => HRDATA(19),
      D => n_sri_data(19),
      C => clk);
  II_r_hrdataHAKL20HAKR: FD port map (
      Q => HRDATA(20),
      D => n_sri_data(20),
      C => clk);
  II_r_hrdataHAKL21HAKR: FD port map (
      Q => HRDATA(21),
      D => n_sri_data(21),
      C => clk);
  II_r_hrdataHAKL0HAKR: FD port map (
      Q => HRDATA(0),
      D => n_sri_data(0),
      C => clk);
  II_r_hrdataHAKL1HAKR: FD port map (
      Q => HRDATA(1),
      D => n_sri_data(1),
      C => clk);
  II_r_hrdataHAKL2HAKR: FD port map (
      Q => HRDATA(2),
      D => n_sri_data(2),
      C => clk);
  II_r_hrdataHAKL3HAKR: FD port map (
      Q => HRDATA(3),
      D => n_sri_data(3),
      C => clk);
  II_r_hrdataHAKL4HAKR: FD port map (
      Q => HRDATA(4),
      D => n_sri_data(4),
      C => clk);
  II_r_hrdataHAKL5HAKR: FD port map (
      Q => HRDATA(5),
      D => n_sri_data(5),
      C => clk);
  II_r_hrdataHAKL6HAKR: FD port map (
      Q => HRDATA(6),
      D => n_sri_data(6),
      C => clk);
  II_r_hmbselHAKL0HAKR: FDCE port map (
      Q => HMBSEL_0_INT_33,
      D => n_ahbsi_hmbsel(0),
      C => clk,
      CLR => RST_I,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL21HAKR: FDE port map (
      Q => n_sro_address(21),
      D => n_ahbsi_haddr(21),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL22HAKR: FDE port map (
      Q => n_sro_address(22),
      D => n_ahbsi_haddr(22),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL23HAKR: FDE port map (
      Q => n_sro_address(23),
      D => n_ahbsi_haddr(23),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL24HAKR: FDE port map (
      Q => n_sro_address(24),
      D => n_ahbsi_haddr(24),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL25HAKR: FDE port map (
      Q => n_sro_address(25),
      D => n_ahbsi_haddr(25),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL26HAKR: FDE port map (
      Q => n_sro_address(26),
      D => n_ahbsi_haddr(26),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL27HAKR: FDE port map (
      Q => n_sro_address(27),
      D => n_ahbsi_haddr(27),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL28HAKR: FDE port map (
      Q => n_sro_address(28),
      D => n_ahbsi_haddr(28),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL29HAKR: FDE port map (
      Q => n_sro_address(29),
      D => n_ahbsi_haddr(29),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL30HAKR: FDE port map (
      Q => n_sro_address(30),
      D => n_ahbsi_haddr(30),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL31HAKR: FDE port map (
      Q => n_sro_address(31),
      D => n_ahbsi_haddr(31),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_hmbselHAKL2HAKR: FDCE port map (
      Q => HMBSEL_2_INT_35,
      D => n_ahbsi_hmbsel(2),
      C => clk,
      CLR => RST_I,
      CE => HMBSEL_0_SQMUXA);
  II_r_hmbselHAKL1HAKR: FDCE port map (
      Q => HMBSEL_1_INT_34,
      D => n_ahbsi_hmbsel(1),
      C => clk,
      CLR => RST_I,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL6HAKR: FDE port map (
      Q => HADDR(6),
      D => n_ahbsi_haddr(6),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL7HAKR: FDE port map (
      Q => HADDR(7),
      D => n_ahbsi_haddr(7),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL8HAKR: FDE port map (
      Q => HADDR(8),
      D => n_ahbsi_haddr(8),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL9HAKR: FDE port map (
      Q => HADDR(9),
      D => n_ahbsi_haddr(9),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL10HAKR: FDE port map (
      Q => HADDR(10),
      D => n_ahbsi_haddr(10),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL11HAKR: FDE port map (
      Q => HADDR(11),
      D => n_ahbsi_haddr(11),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL12HAKR: FDE port map (
      Q => n_sro_address(12),
      D => n_ahbsi_haddr(12),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL13HAKR: FDE port map (
      Q => n_sro_address(13),
      D => n_ahbsi_haddr(13),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL14HAKR: FDE port map (
      Q => n_sro_address(14),
      D => n_ahbsi_haddr(14),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL15HAKR: FDE port map (
      Q => n_sro_address(15),
      D => n_ahbsi_haddr(15),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL16HAKR: FDE port map (
      Q => n_sro_address(16),
      D => n_ahbsi_haddr(16),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL17HAKR: FDE port map (
      Q => n_sro_address(17),
      D => n_ahbsi_haddr(17),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL18HAKR: FDE port map (
      Q => n_sro_address(18),
      D => n_ahbsi_haddr(18),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL19HAKR: FDE port map (
      Q => n_sro_address(19),
      D => n_ahbsi_haddr(19),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL20HAKR: FDE port map (
      Q => n_sro_address(20),
      D => n_ahbsi_haddr(20),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_ssrstateHAKL4HAKR: FD port map (
      Q => SSRSTATE_4_INT_24,
      D => ssrstate_1_2,
      C => clk);
  II_r_ssrstateHAKL3HAKR: FD port map (
      Q => SSRSTATE_3_INT_23,
      D => SSRSTATE_1(3),
      C => clk);
  II_r_ssrstateHAKL2HAKR: FD port map (
      Q => SSRSTATE_2_INT_22,
      D => SSRSTATE_1(2),
      C => clk);
  II_r_haddrHAKL0HAKR: FDE port map (
      Q => N_SRO_ADDRESS_0_INT_36,
      D => n_ahbsi_haddr(0),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL2HAKR: FDE port map (
      Q => HADDR(2),
      D => n_ahbsi_haddr(2),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL3HAKR: FDE port map (
      Q => HADDR(3),
      D => n_ahbsi_haddr(3),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL4HAKR: FDE port map (
      Q => HADDR(4),
      D => n_ahbsi_haddr(4),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_haddrHAKL5HAKR: FDE port map (
      Q => HADDR(5),
      D => n_ahbsi_haddr(5),
      C => clk,
      CE => HMBSEL_0_SQMUXA);
  II_r_wsHAKL2HAKR: FD port map (
      Q => WS_2_INT_18,
      D => WS_1(2),
      C => clk);
  II_r_wsHAKL3HAKR: FD port map (
      Q => WS_3_INT_19,
      D => ws_1_3,
      C => clk);
  II_r_wsHAKL0HAKR: FD port map (
      Q => WS_0_INT_16,
      D => ws_1_0,
      C => clk);
  II_r_wsHAKL1HAKR: FD port map (
      Q => WS_1_INT_17,
      D => WS_1(1),
      C => clk);
  II_r_bdrive: FDP port map (
      Q => N_SRO_BDRIVE_3_INT_15,
      D => BDRIVE_1,
      C => clk,
      PRE => RST_I);
  II_r_change: FDC port map (
      Q => CHANGE_INT_69,
      D => CHANGE_3,
      C => clk,
      CLR => RST_I);
  II_r_acountHAKL0HAKR: FD port map (
      Q => N_SRO_ADDRESS_2_INT_38,
      D => ACOUNT_LM(0),
      C => clk);
  II_r_acountHAKL1HAKR: FD port map (
      Q => N_SRO_ADDRESS_3_INT_39,
      D => ACOUNT_LM(1),
      C => clk);
  II_r_acountHAKL2HAKR: FD port map (
      Q => N_SRO_ADDRESS_4_INT_40,
      D => ACOUNT_LM(2),
      C => clk);
  II_r_acountHAKL3HAKR: FD port map (
      Q => N_SRO_ADDRESS_5_INT_41,
      D => ACOUNT_LM(3),
      C => clk);
  II_r_acountHAKL4HAKR: FD port map (
      Q => N_SRO_ADDRESS_6_INT_42,
      D => ACOUNT_LM(4),
      C => clk);
  II_r_acountHAKL5HAKR: FD port map (
      Q => N_SRO_ADDRESS_7_INT_43,
      D => ACOUNT_LM(5),
      C => clk);
  II_r_acountHAKL6HAKR: FD port map (
      Q => N_SRO_ADDRESS_8_INT_44,
      D => ACOUNT_LM(6),
      C => clk);
  II_r_acountHAKL7HAKR: FD port map (
      Q => N_SRO_ADDRESS_9_INT_45,
      D => ACOUNT_LM(7),
      C => clk);
  II_r_acountHAKL8HAKR: FD port map (
      Q => N_SRO_ADDRESS_10_INT_46,
      D => ACOUNT_LM(8),
      C => clk);
  II_r_acountHAKL9HAKR: FD port map (
      Q => N_SRO_ADDRESS_11_INT_47,
      D => ACOUNT_LM(9),
      C => clk);
  II_v_oen_1_sqmuxa_2_i_L4: LUT4_L
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => change_3_f0,
    I2 => HMBSEL_4_1_INT_14,
    I3 => HSEL_5_INT_67,
    LO => OEN_1_SQMUXA_2_I_L4);
  II_v_oen_1_sqmuxa_2_i_L6: LUT4_L
  generic map(
    INIT => X"4303"
  )
  port map (
    I0 => OEN_1_SQMUXA_2_I_L4,
    I1 => PRSTATE_5_INT_32,
    I2 => PRSTATE_1,
    I3 => hsel_1(0),
    LO => OEN_1_SQMUXA_2_I_L6);
  II_v_oen_1_sqmuxa_2_i: LUT4
  generic map(
    INIT => X"DFCC"
  )
  port map (
    I0 => N_654,
    I1 => OEN_1_SQMUXA_2_I_L6,
    I2 => SSRSTATE_2_INT_22,
    I3 => SSRSTATE_12_1,
    O => OEN_1_SQMUXA_2_I);
  II_ctrl_v_ssrstate_1_0_1HAKL3HAKR: LUT3
  generic map(
    INIT => X"35"
  )
  port map (
    I0 => SSRSTATE_1_0_D_AM(3),
    I1 => ssrstate_1_m1(3),
    I2 => ssrstate_2_sqmuxa_i,
    O => SSRSTATE_1_0_1(3));
  II_ctrl_v_ws_1_0_bm_L1: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => SSRSTATE_1_INT_21,
    O => WS_1_0_BM_L1);
  II_ctrl_v_ws_1_0_bm_L3: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => N_656_INT_66,
    I1 => rst,
    O => WS_1_0_BM_L3);
  II_ctrl_v_ws_1_0_bm_L5: LUT4
  generic map(
    INIT => X"0E00"
  )
  port map (
    I0 => SSRSTATE6_1_D_0_L1_INT_65,
    I1 => WS_1_0_BM_L1,
    I2 => UN1_AHBSI_INT_68,
    I3 => HSEL_5_INT_67,
    O => WS_1_0_BM_L5);
  II_ctrl_v_ws_1_0_bmHAKL1HAKR: LUT4
  generic map(
    INIT => X"80AA"
  )
  port map (
    I0 => WS_1_0_BM_L3,
    I1 => WS_1_0_BM_L5,
    I2 => HMBSEL_4_1_INT_14,
    I3 => SSRSTATE6_XX_MM_M3_INT_64,
    O => WS_1_0_BM(1));
  II_ctrl_v_N_619_i_L1_L1: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => CHANGE_1_SQMUXA_N_3_INT_63,
    I1 => SSRHREADY_2_SQMUXA_0_0_INT_62,
    O => N_619_I_L1_L1);
  II_ctrl_v_N_619_i_L1: LUT4
  generic map(
    INIT => X"80CC"
  )
  port map (
    I0 => N_619_I_L1_L1,
    I1 => n_ahbsi_hwrite,
    I2 => HMBSEL_4_1_INT_14,
    I3 => SSRSTATE6_XX_MM_M3_INT_64,
    O => N_619_I_L1);
  II_ctrl_v_hmbsel_4HAKL1HAKR: LUT3
  generic map(
    INIT => X"B8"
  )
  port map (
    I0 => HMBSEL_4_X1(1),
    I1 => n_ahbsi_htrans(1),
    I2 => HMBSEL_1_INT_34,
    O => HMBSEL_4_1_INT_14);
  II_v_ssrstate_6_sqmuxa: LUT4
  generic map(
    INIT => X"0035"
  )
  port map (
    I0 => g0_52_x0,
    I1 => g0_52_x1,
    I2 => n_ahbsi_htrans(1),
    I3 => SSRSTATE_6_SQMUXA_1,
    O => SSRSTATE_6_SQMUXA_INT_61);
  II_v_ssrstate_6_sqmuxa_1: LUT2
  generic map(
    INIT => X"7"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => SSRSTATE_2_INT_22,
    O => SSRSTATE_6_SQMUXA_1);
  II_ctrl_v_bwn_1_0_o3_0_L1: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => N_SRO_ADDRESS_0_INT_36,
    I1 => SIZE_0_INT_25,
    O => BWN_1_0_O3_0_L1);
  II_ctrl_v_bwn_1_0_o3_0_L3: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => n_ahbsi_haddr(0),
    I1 => n_ahbsi_hsize(0),
    O => BWN_1_0_O3_0_L3);
  II_ctrl_v_bwn_1_0_o3_0_L5: LUT4_L
  generic map(
    INIT => X"00E4"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => BWN_1_0_O3_0_L1,
    I2 => BWN_1_0_O3_0_L3,
    I3 => hsize_1(1),
    LO => BWN_1_0_O3_0_L5);
  II_ctrl_v_bwn_1_0_o3_0HAKL1HAKR: LUT4
  generic map(
    INIT => X"5540"
  )
  port map (
    I0 => BWN_1_0_O3_0_L5,
    I1 => rst,
    I2 => PRSTATE_2_REP1_INT_59,
    I3 => bwn_0_sqmuxa_1,
    O => BWN_1_0_O3(1));
  II_r_prstate_2_rep1: FDR port map (
      Q => PRSTATE_2_REP1_INT_59,
      D => PRSTATEC_0_REP1,
      C => clk,
      R => RST_I);
  II_r_prstatec_0_rep1: LUT4_L
  generic map(
    INIT => X"A2A0"
  )
  port map (
    I0 => N_336,
    I1 => CHANGE_3,
    I2 => PRSTATE_0_INT_27,
    I3 => prstate_1_i_o4_s(2),
    LO => PRSTATEC_0_REP1);
  II_r_prstate_fastHAKL2HAKR: FDR port map (
      Q => PRSTATE_FAST_2_INT_13,
      D => PRSTATEC_0_FAST,
      C => clk,
      R => RST_I);
  II_r_prstatec_0_fast: LUT4_L
  generic map(
    INIT => X"A2A0"
  )
  port map (
    I0 => N_336,
    I1 => CHANGE_3,
    I2 => PRSTATE_0_INT_27,
    I3 => prstate_1_i_o4_s(2),
    LO => PRSTATEC_0_FAST);
  II_ctrl_v_ws_1_0_rnHAKL1HAKR: LUT4_L
  generic map(
    INIT => X"4EE4"
  )
  port map (
    I0 => g0_25,
    I1 => WS_1_2_0_D(1),
    I2 => WS_1_0_AM_1(1),
    I3 => WS_1_INT_17,
    LO => WS_1_0_RN_1(1));
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_2_L1: LUT4_L
  generic map(
    INIT => X"3100"
  )
  port map (
    I0 => BDRIVE_1_IV_M9_I_A4_0_2_1,
    I1 => BDRIVE_1_IV_M9_I_A4_0_2_2_1,
    I2 => SSRSTATE_1_INT_21,
    I3 => BDRIVE_0_SQMUXA_2_C,
    LO => BDRIVE_1_IV_M9_I_A4_0_2_2_L1);
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_2: LUT4
  generic map(
    INIT => X"D5F5"
  )
  port map (
    I0 => BDRIVE_1_IV_M9_I_A4_0_2_2_L1,
    I1 => UN1_AHBSI_INT_68,
    I2 => BDRIVE_1_IV_M9_I_A4_0_2_1,
    I3 => HSEL_5_INT_67,
    O => BDRIVE_1_TZ);
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_2_1_L1: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => SSRSTATE_0_INT_20,
    I1 => SSRSTATE_1_INT_21,
    O => BDRIVE_1_IV_M9_I_A4_0_2_2_1_L1);
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_2_1_L3: LUT4_L
  generic map(
    INIT => X"1015"
  )
  port map (
    I0 => N_SRO_BDRIVE_3_INT_15,
    I1 => D16MUXC_0_4_INT_73,
    I2 => PRSTATE_1_INT_28,
    I3 => PRSTATE_2_REP1_INT_59,
    LO => BDRIVE_1_IV_M9_I_A4_0_2_2_1_L3);
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_2_1: LUT4_L
  generic map(
    INIT => X"0F8F"
  )
  port map (
    I0 => N_668,
    I1 => BDRIVE_1_IV_M9_I_A4_0_2_2_1_L1,
    I2 => BDRIVE_1_IV_M9_I_A4_0_2_2_1_L3,
    I3 => BDRIVE_1_SQMUXA,
    LO => BDRIVE_1_IV_M9_I_A4_0_2_2_1);
  II_ctrl_v_romsn_1_iv_L1: LUT4_L
  generic map(
    INIT => X"27FF"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_hmbsel(0),
    I2 => HMBSEL_0_INT_33,
    I3 => prstate_1_i_o4_s(2),
    LO => ROMSN_1_IV_L1);
  II_ctrl_v_iosn_9_iv_L1: LUT4_L
  generic map(
    INIT => X"27FF"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_hmbsel(2),
    I2 => HMBSEL_2_INT_35,
    I3 => prstate_1_i_o4_s(2),
    LO => IOSN_9_IV_L1);
  II_ctrl_v_ssrstate6_xx_mm_m3_L1: LUT2
  generic map(
    INIT => X"7"
  )
  port map (
    I0 => HMBSEL_1_INT_34,
    I1 => HSEL_INT_58,
    O => SSRSTATE6_XX_MM_M3_L1);
  II_ctrl_v_ssrstate6_xx_mm_m3_L3: LUT4
  generic map(
    INIT => X"4FFF"
  )
  port map (
    I0 => n_ahbsi_hmbsel(1),
    I1 => n_ahbsi_hready,
    I2 => PRSTATE_5_INT_32,
    I3 => SSRSTATE_4_INT_24,
    O => SSRSTATE6_XX_MM_M3_L3);
  II_ctrl_v_ssrstate6_xx_mm_m3: LUT4
  generic map(
    INIT => X"CEFE"
  )
  port map (
    I0 => SSRSTATE6_XX_MM_M3_L1,
    I1 => SSRSTATE6_XX_MM_M3_L3,
    I2 => n_ahbsi_hready,
    I3 => hsel_4,
    O => SSRSTATE6_XX_MM_M3_INT_64);
  II_v_ws_2_sqmuxa_3_0: LUT4
  generic map(
    INIT => X"0700"
  )
  port map (
    I0 => g0_30,
    I1 => WS_0_SQMUXA_1_INT_57,
    I2 => WS_2_SQMUXA_3_0_SX,
    I3 => WS_2_SQMUXA_3_D_INT_56,
    O => N_371_INT_71);
  II_v_ws_2_sqmuxa_3_0_sx: LUT4_L
  generic map(
    INIT => X"CF4F"
  )
  port map (
    I0 => SSRSTATE_2_I_INT_55,
    I1 => WS_0_SQMUXA_1_INT_57,
    I2 => WS_2_SQMUXA_3_0_2_INT_54,
    I3 => WS_3_SQMUXA_1_INT_53,
    LO => WS_2_SQMUXA_3_0_SX);
  II_v_ws_2_sqmuxa_3_0_x: LUT3_L
  generic map(
    INIT => X"70"
  )
  port map (
    I0 => g0_30,
    I1 => WS_0_SQMUXA_1_INT_57,
    I2 => WS_2_SQMUXA_3_D_INT_56,
    LO => ws_2_sqmuxa_3_0_x);
  II_ctrl_v_hmbsel_4_x1HAKL1HAKR: LUT4_L
  generic map(
    INIT => X"BF80"
  )
  port map (
    I0 => n_ahbsi_hmbsel(1),
    I1 => n_ahbsi_hready,
    I2 => n_ahbsi_hsel(0),
    I3 => HMBSEL_1_INT_34,
    LO => HMBSEL_4_X1(1));
  II_un1_v_ssrstate17_2_0_m6_i_1: LUT4
  generic map(
    INIT => X"4F0F"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_htrans(0),
    I2 => SSRSTATE_2_INT_22,
    I3 => SSRSTATE17_2_0_M6_I_A3_A0_1,
    O => ssrstate17_2_0_m6_i_1);
  II_ctrl_v_change_3_f1_d_0_L1: LUT4_L
  generic map(
    INIT => X"4440"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HSEL_5_INT_67,
    I2 => SSRSTATE_1_INT_21,
    I3 => SSRSTATE_2_INT_22,
    LO => CHANGE_3_F1_D_0_L1);
  II_ctrl_v_change_3_f1_d_0: LUT4
  generic map(
    INIT => X"00F2"
  )
  port map (
    I0 => CHANGE_3_F1_D_0_L1,
    I1 => HMBSEL_4_1_INT_14,
    I2 => CHANGE_INT_69,
    I3 => SSRSTATE_4_INT_24,
    O => CHANGE_3);
  II_ctrl_un1_v_ssrstate17: LUT4
  generic map(
    INIT => X"E000"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => HMBSEL_4_1_INT_14,
    I3 => HSEL_5_INT_67,
    O => N_654);
  II_un1_v_writen_2_sqmuxa_L1: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => PRSTATE_1_INT_28,
    I1 => PRSTATE_2_INT_29,
    O => WRITEN_2_SQMUXA_L1);
  II_un1_v_writen_2_sqmuxa_L3: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    O => WRITEN_2_SQMUXA_L3);
  II_un1_v_writen_2_sqmuxa_L5: LUT4
  generic map(
    INIT => X"7F00"
  )
  port map (
    I0 => WRITEN_2_SQMUXA_L3,
    I1 => HMBSEL_4_1_INT_14,
    I2 => HSEL_5_INT_67,
    I3 => SSRSTATE_2_INT_22,
    O => WRITEN_2_SQMUXA_L5);
  II_un1_v_writen_2_sqmuxa: LUT4
  generic map(
    INIT => X"7555"
  )
  port map (
    I0 => WRITEN_2_SQMUXA_L1,
    I1 => WRITEN_2_SQMUXA_L5,
    I2 => WRITEN_2_SQMUXA_TZ_0,
    I3 => BWN_1_SQMUXA_2_D_0,
    O => WRITEN_2_SQMUXA);
  II_ctrl_v_ws_1_L1_L1: LUT3_L
  generic map(
    INIT => X"37"
  )
  port map (
    I0 => g0_30,
    I1 => WS_0_SQMUXA_1_INT_57,
    I2 => WS_3_SQMUXA_1_INT_53,
    LO => WS_1_L1_L1);
  II_ctrl_v_ws_1_L1: LUT4_L
  generic map(
    INIT => X"B11B"
  )
  port map (
    I0 => g0_25,
    I1 => WS_1_2_0_D(2),
    I2 => WS_1_L1_L1,
    I3 => WS_2_INT_18,
    LO => WS_1_L1);
  II_v_ws_2_sqmuxa_3_0_2_L1: LUT4
  generic map(
    INIT => X"0013"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_12,
    I1 => PRSTATE_1_INT_28,
    I2 => ws_2_sqmuxa_0,
    I3 => ws_4_sqmuxa_0,
    O => WS_2_SQMUXA_3_0_2_L1);
  II_v_ws_2_sqmuxa_3_0_2: LUT4
  generic map(
    INIT => X"003B"
  )
  port map (
    I0 => WS_2_SQMUXA_3_0_2_L1,
    I1 => rst,
    I2 => PRSTATE_3_INT_30,
    I3 => WS_1_SQMUXA_INT_52,
    O => WS_2_SQMUXA_3_0_2_INT_54);
  II_ctrl_v_ws_1_L1_0: LUT3
  generic map(
    INIT => X"57"
  )
  port map (
    I0 => g0_25,
    I1 => WS_0_INT_16,
    I2 => WS_1_INT_17,
    O => WS_1_L1_0);
  II_ctrl_v_ssrhready_8_f0_L5: LUT3_L
  generic map(
    INIT => X"2F"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => ssrstate17_1_xx_mm_N_4,
    I2 => SSRSTATE_1_INT_21,
    LO => ssrhready_8_f0_L5);
  II_ctrl_v_ssrhready_8_f0_L8: LUT4
  generic map(
    INIT => X"0013"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => SSRHREADY_INT_51,
    I2 => SSRSTATE_3_INT_23,
    I3 => ssrstate_1_sqmuxa_1,
    O => ssrhready_8_f0_L8);
  II_un1_v_hsel_1_0_L3: LUT2_L
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => n_ahbsi_hmbsel(0),
    I1 => n_ahbsi_hmbsel(2),
    LO => hsel_1_0_L3);
  II_un1_v_ssrstate6_1_d_0_L1: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => SSRSTATE_2_INT_22,
    O => SSRSTATE6_1_D_0_L1_INT_65);
  II_v_ws_3_sqmuxa_0: LUT4
  generic map(
    INIT => X"8B03"
  )
  port map (
    I0 => n_ahbsi_hmbsel(1),
    I1 => n_ahbsi_hready,
    I2 => WS_3_SQMUXA_0_1,
    I3 => WS_3_SQMUXA_1_A0_2,
    O => WS_3_SQMUXA_1_INT_53);
  II_v_ws_3_sqmuxa_0_1: LUT3
  generic map(
    INIT => X"7F"
  )
  port map (
    I0 => d_m1_e_0_0,
    I1 => n_ahbsi_htrans(0),
    I2 => SSRSTATE_1_INT_21,
    O => WS_3_SQMUXA_0_1);
  II_un1_r_prstate_8: LUT4
  generic map(
    INIT => X"0301"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_12,
    I1 => PRSTATE_0_INT_27,
    I2 => PRSTATE_5_INT_32,
    I3 => PRSTATE_8_1,
    O => N_656_INT_66);
  II_un1_r_prstate_8_1: LUT3_L
  generic map(
    INIT => X"57"
  )
  port map (
    I0 => N_SRO_IOSN_INT_70,
    I1 => PRSTATE_4_INT_31,
    I2 => PRSTATE_FAST_2_INT_13,
    LO => PRSTATE_8_1);
  II_v_mcfg1_bexcen_1_sqmuxa_i: LUT4
  generic map(
    INIT => X"B333"
  )
  port map (
    I0 => n_apbi_pwrite,
    I1 => rst,
    I2 => N_APBO_PRDATA_28_INT_11,
    I3 => BEXCEN_1_SQMUXA_I_1,
    O => BEXCEN_1_SQMUXA_I);
  II_v_mcfg1_bexcen_1_sqmuxa_i_1: LUT4
  generic map(
    INIT => X"1000"
  )
  port map (
    I0 => n_apbi_paddr(4),
    I1 => n_apbi_paddr(5),
    I2 => n_apbi_penable,
    I3 => n_apbi_psel(0),
    O => BEXCEN_1_SQMUXA_I_1);
  II_un1_v_ssrstate_1_sqmuxa_1_0_m3_0_1: LUT4
  generic map(
    INIT => X"0D08"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_hsel(0),
    I2 => n_ahbsi_htrans(0),
    I3 => HSEL_INT_58,
    O => ssrstate_1_sqmuxa_1_0_m3_0_1);
  II_un1_r_prstate: LUT4
  generic map(
    INIT => X"1911"
  )
  port map (
    I0 => PRSTATE_5_INT_32,
    I1 => PRSTATE_1,
    I2 => PRSTATE_12_M7_I_A6_0,
    I3 => hsel_1(0),
    O => PRSTATE_12_I);
  II_un1_r_prstate_1_0: LUT4
  generic map(
    INIT => X"0343"
  )
  port map (
    I0 => HWRITE_1,
    I1 => PRSTATE_5_INT_32,
    I2 => PRSTATE_12_0,
    I3 => PRSTATE_12_M7_I_A6,
    O => PRSTATE_1);
  II_ctrl_v_ws_1_0_am_1HAKL1HAKR: LUT4_L
  generic map(
    INIT => X"0515"
  )
  port map (
    I0 => WS_0_INT_16,
    I1 => g0_30,
    I2 => WS_0_SQMUXA_1_INT_57,
    I3 => WS_3_SQMUXA_1_INT_53,
    LO => WS_1_0_AM_1(1));
  II_r_d16muxc_0_1_0: LUT4
  generic map(
    INIT => X"0110"
  )
  port map (
    I0 => PRSTATE_1_INT_28,
    I1 => PRSTATE_4_INT_31,
    I2 => SIZE_0_INT_25,
    I3 => SIZE_1_INT_26,
    O => D16MUXC_0_1_0);
  II_r_acount_lm_0_1HAKL0HAKR: LUT3
  generic map(
    INIT => X"27"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(2),
    I2 => HADDR(2),
    O => ACOUNT_LM_0_1(0));
  II_v_N_635_i_1: LUT3_L
  generic map(
    INIT => X"0D"
  )
  port map (
    I0 => SSRSTATE_1_INT_21,
    I1 => loadcount_1_sqmuxa,
    I2 => ssrstate_1_sqmuxa_1,
    LO => N_635_I_1);
  II_ctrl_v_oen_1_iv: LUT3_L
  generic map(
    INIT => X"E2"
  )
  port map (
    I0 => SSRSTATE6_XX_MM_M3_INT_64,
    I1 => PRSTATE_12_I,
    I2 => PRSTATE_1_SQMUXA,
    LO => OEN_1);
  II_ctrl_v_N_617_i: LUT4_L
  generic map(
    INIT => X"0FBF"
  )
  port map (
    I0 => N_646,
    I1 => n_ahbsi_hwrite,
    I2 => BWN_1_0_0(3),
    I3 => bwn_1_sqmuxa_2_d_0_2,
    LO => N_617_I);
  II_ctrl_v_hwdataout_1_0HAKL0HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(0),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(0),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(0));
  II_ctrl_v_hwdataout_1_0HAKL1HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(1),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(1),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(1));
  II_ctrl_v_hwdataout_1_0HAKL2HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(2),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(2),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(2));
  II_ctrl_v_hwdataout_1_0HAKL3HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(3),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(3),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(3));
  II_ctrl_v_hwdataout_1_0HAKL4HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(4),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(4),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(4));
  II_ctrl_v_hwdataout_1_0HAKL5HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(5),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(5),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(5));
  II_ctrl_v_hwdataout_1_0HAKL6HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(6),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(6),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(6));
  II_ctrl_v_hwdataout_1_0HAKL7HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(7),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(7),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(7));
  II_ctrl_v_hwdataout_1_0HAKL8HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(8),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(8),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(8));
  II_ctrl_v_hwdataout_1_0HAKL9HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(9),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(9),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(9));
  II_ctrl_v_hwdataout_1_0HAKL10HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(10),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(10),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(10));
  II_ctrl_v_hwdataout_1_0HAKL11HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(11),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(11),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(11));
  II_ctrl_v_hwdataout_1_0HAKL12HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(12),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(12),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(12));
  II_ctrl_v_hwdataout_1_0HAKL13HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(13),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(13),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(13));
  II_ctrl_v_hwdataout_1_0HAKL14HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(14),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(14),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(14));
  II_ctrl_v_hwdataout_1_0HAKL15HAKR: LUT4_L
  generic map(
    INIT => X"E2F0"
  )
  port map (
    I0 => n_ahbsi_hwdata(15),
    I1 => BUS16EN_INT_72,
    I2 => HWDATA(15),
    I3 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(15));
  II_ctrl_v_hwdataout_1_0HAKL16HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_382,
    I1 => HWDATA(16),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(16));
  II_ctrl_v_hwdataout_1_0HAKL17HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_383,
    I1 => HWDATA(17),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(17));
  II_ctrl_v_hwdataout_1_0HAKL18HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_384,
    I1 => HWDATA(18),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(18));
  II_ctrl_v_hwdataout_1_0HAKL19HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_385,
    I1 => HWDATA(19),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(19));
  II_ctrl_v_hwdataout_1_0HAKL20HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_386,
    I1 => HWDATA(20),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(20));
  II_ctrl_v_hwdataout_1_0HAKL21HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_387,
    I1 => HWDATA(21),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(21));
  II_ctrl_v_hwdataout_1_0HAKL22HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_388,
    I1 => HWDATA(22),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(22));
  II_ctrl_v_hwdataout_1_0HAKL23HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_389,
    I1 => HWDATA(23),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(23));
  II_ctrl_v_hwdataout_1_0HAKL24HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_390,
    I1 => HWDATA(24),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(24));
  II_ctrl_v_hwdataout_1_0HAKL25HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_391,
    I1 => HWDATA(25),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(25));
  II_ctrl_v_hwdataout_1_0HAKL26HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_392,
    I1 => HWDATA(26),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(26));
  II_ctrl_v_hwdataout_1_0HAKL27HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_393,
    I1 => HWDATA(27),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(27));
  II_ctrl_v_hwdataout_1_0HAKL28HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_394,
    I1 => HWDATA(28),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(28));
  II_ctrl_v_hwdataout_1_0HAKL29HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_395,
    I1 => HWDATA(29),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(29));
  II_ctrl_v_hwdataout_1_0HAKL30HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_396,
    I1 => HWDATA(30),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(30));
  II_ctrl_v_hwdataout_1_0HAKL31HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => N_397,
    I1 => HWDATA(31),
    I2 => PRSTATE_2_INT_29,
    LO => HWDATAOUT_1(31));
  II_ctrl_v_mcfg1_N_626_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_4,
    I1 => rst,
    LO => N_626_I);
  II_ctrl_v_mcfg1_N_625_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_5,
    I1 => rst,
    LO => N_625_I);
  II_ctrl_v_mcfg1_N_624_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_6,
    I1 => rst,
    LO => N_624_I);
  II_ctrl_v_mcfg1_N_623_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_7,
    I1 => rst,
    LO => N_623_I);
  II_ctrl_v_mcfg1_N_630_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_0,
    I1 => rst,
    LO => N_630_I);
  II_ctrl_v_mcfg1_N_629_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_1,
    I1 => rst,
    LO => N_629_I);
  II_ctrl_v_mcfg1_N_628_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_2,
    I1 => rst,
    LO => N_628_I);
  II_ctrl_v_mcfg1_N_627_i: LUT2_L
  generic map(
    INIT => X"B"
  )
  port map (
    I0 => n_apbi_pwdata_3,
    I1 => rst,
    LO => N_627_I);
  II_ctrl_v_mcfg1_iows_1HAKL0HAKR: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_20,
    I1 => rst,
    LO => IOWS_1(0));
  II_ctrl_v_mcfg1_iows_1HAKL1HAKR: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_21,
    I1 => rst,
    LO => IOWS_1(1));
  II_ctrl_v_mcfg1_iows_1HAKL2HAKR: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_22,
    I1 => rst,
    LO => IOWS_1(2));
  II_ctrl_v_mcfg1_iows_1HAKL3HAKR: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_23,
    I1 => rst,
    LO => IOWS_1(3));
  II_ctrl_v_mcfg1_romwidth_1_0HAKL0HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => n_apbi_pwdata_8,
    I1 => n_sri_bwidth(0),
    I2 => rst,
    LO => ROMWIDTH_1(0));
  II_ctrl_v_mcfg1_romwidth_1_0HAKL1HAKR: LUT3_L
  generic map(
    INIT => X"AC"
  )
  port map (
    I0 => n_apbi_pwdata_9,
    I1 => n_sri_bwidth(1),
    I2 => rst,
    LO => ROMWIDTH_1(1));
  II_ctrl_v_mcfg1_romwrite_1: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_11,
    I1 => rst,
    LO => ROMWRITE_1);
  II_ctrl_v_mcfg1_ioen_1: LUT2_L
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_apbi_pwdata_19,
    I1 => rst,
    LO => IOEN_1);
  II_ctrl_v_ssrstate_1_0HAKL2HAKR: LUT4_L
  generic map(
    INIT => X"8A80"
  )
  port map (
    I0 => rst,
    I1 => D16MUXC_0_4_INT_73,
    I2 => SSRSTATE_3_INT_23,
    I3 => SSRSTATE_6_SQMUXA_INT_61,
    LO => SSRSTATE_1(2));
  II_ctrl_v_bdrive_1_iv_m9_i: LUT4_L
  generic map(
    INIT => X"1000"
  )
  port map (
    I0 => BDRIVE_1_IV_0_A0,
    I1 => BDRIVE_1_IV_0_A1,
    I2 => BDRIVE_1_IV_M9_I_0_0,
    I3 => BDRIVE_1_TZ,
    LO => BDRIVE_1);
  II_r_acount_lm_0HAKL1HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_1,
    I2 => ACOUNT_S(1),
    LO => ACOUNT_LM(1));
  II_r_acount_lm_0HAKL2HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_2,
    I2 => ACOUNT_S(2),
    LO => ACOUNT_LM(2));
  II_r_acount_lm_0HAKL3HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_3,
    I2 => ACOUNT_S(3),
    LO => ACOUNT_LM(3));
  II_r_acount_lm_0HAKL4HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_4,
    I2 => ACOUNT_S(4),
    LO => ACOUNT_LM(4));
  II_r_acount_lm_0HAKL5HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_5,
    I2 => ACOUNT_S(5),
    LO => ACOUNT_LM(5));
  II_r_acount_lm_0HAKL6HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_6,
    I2 => ACOUNT_S(6),
    LO => ACOUNT_LM(6));
  II_r_acount_lm_0HAKL7HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_7,
    I2 => ACOUNT_S(7),
    LO => ACOUNT_LM(7));
  II_r_acount_lm_0HAKL8HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_8,
    I2 => ACOUNT_S(8),
    LO => ACOUNT_LM(8));
  II_r_acount_lm_0HAKL9HAKR: LUT3_L
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => loadcount_7,
    I1 => NN_9,
    I2 => ACOUNT_S(9),
    LO => ACOUNT_LM(9));
  II_r_d16muxc: LUT3_L
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => un7_bus16en,
    I1 => D16MUXC_1,
    I2 => D16MUXC_2,
    LO => D16MUXC);
  II_rbdrivec_18: LUT4_L
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => BDRIVE_1_IV_0_A0,
    I1 => BDRIVE_1_IV_0_1,
    I2 => BDRIVE_1_IV_M9_I_0,
    I3 => BDRIVE_1_TZ,
    LO => RBDRIVEC_18);
  II_r_ssrstatec_0: LUT4_L
  generic map(
    INIT => X"0B08"
  )
  port map (
    I0 => NoName_cnst(0),
    I1 => SSRSTATE_5_I,
    I2 => ssrstate_2_sqmuxa_1,
    I3 => SSRSTATE_11(0),
    LO => SSRSTATEC_0);
  II_r_prstatec_1: LUT4_L
  generic map(
    INIT => X"0008"
  )
  port map (
    I0 => SSRSTATE23_1,
    I1 => PRSTATE_1_INT_28,
    I2 => WS_0_INT_16,
    I3 => WS_3_INT_19,
    LO => PRSTATEC_1);
  II_v_N_337_i: LUT3_L
  generic map(
    INIT => X"74"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => PRSTATE_1_INT_28,
    I2 => PRSTATE_2_INT_29,
    LO => N_337_I);
  II_r_prstatec_0: LUT4_L
  generic map(
    INIT => X"A2A0"
  )
  port map (
    I0 => N_336,
    I1 => CHANGE_3,
    I2 => PRSTATE_0_INT_27,
    I3 => prstate_1_i_o4_s(2),
    LO => PRSTATEC_0);
  II_r_prstatec: LUT3_L
  generic map(
    INIT => X"0E"
  )
  port map (
    I0 => PRSTATE_3_INT_30,
    I1 => PRSTATE_4_INT_31,
    I2 => d16mux_0_sqmuxa,
    LO => PRSTATEC);
  II_v_prstate_1_0_a3_0HAKL4HAKR: LUT4_L
  generic map(
    INIT => X"0200"
  )
  port map (
    I0 => rst,
    I1 => HWRITE_1,
    I2 => CHANGE_3,
    I3 => prstate_1_i_o4_s(2),
    LO => N_342);
  II_r_prstates_i: LUT4_L
  generic map(
    INIT => X"8FCF"
  )
  port map (
    I0 => CHANGE_3,
    I1 => PRSTATE_5_INT_32,
    I2 => PRSTATESR_0,
    I3 => hsel_1(0),
    LO => PRSTATES_I);
  II_r_acount_qxuHAKL9HAKR: LUT1
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_SRO_ADDRESS_11_INT_47,
    O => ACOUNT_QXU(9));
  II_un1_v_ssrstate23_u_0HAKL4HAKR: MUXF5 port map (
      I0 => SSRSTATE23_U_0_AM(4),
      I1 => SSRSTATE23_U_0_BM(4),
      S => SSRSTATE_5_I,
      O => ssrstate_1_m1(4));
  II_v_bwn_1_sqmuxa_3_i: LUT4
  generic map(
    INIT => X"D555"
  )
  port map (
    I0 => bwn_0_sqmuxa_1,
    I1 => BWN_1_SQMUXA_2_D_0,
    I2 => WRITEN_0_SQMUXA_0_2,
    I3 => WRITEN_0_SQMUXA_D,
    O => BWN_1_SQMUXA_3_I);
  II_rbdrivec_19: LUT4
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => BDRIVE_1_IV_0_A0,
    I1 => BDRIVE_1_IV_0_1,
    I2 => BDRIVE_1_IV_M9_I_0,
    I3 => BDRIVE_1_TZ,
    O => RBDRIVEC);
  II_ctrl_v_ssrstate_1_m2s2_0: LUT4_L
  generic map(
    INIT => X"0010"
  )
  port map (
    I0 => NoName_cnst(0),
    I1 => SSRSTATE_1_INT_21,
    I2 => change_1_sqmuxa_0,
    I3 => SSRSTATE_6_SQMUXA_INT_61,
    LO => SSRSTATE_1_M2S2_0);
  II_ctrl_v_bwn_1_0_0HAKL3HAKR: LUT3
  generic map(
    INIT => X"C8"
  )
  port map (
    I0 => hsize_1(1),
    I1 => BWN_1_0_O3(1),
    I2 => haddr_0,
    O => BWN_1_0_0(3));
  II_v_ws_2_sqmuxa_3_0_4: LUT4
  generic map(
    INIT => X"30B0"
  )
  port map (
    I0 => SSRSTATE_2_I_INT_55,
    I1 => WS_0_SQMUXA_1_INT_57,
    I2 => WS_2_SQMUXA_3_0_2_INT_54,
    I3 => WS_3_SQMUXA_1_INT_53,
    O => ws_2_sqmuxa_3_0_4);
  II_un1_v_N_599_i: LUT4
  generic map(
    INIT => X"FF8F"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => PRSTATE_1_INT_28,
    I2 => HADDR_0_SQMUXA_A0_0,
    I3 => PRSTATE_1_SQMUXA,
    O => N_599_I);
  II_ctrl_v_ssrstate_1_0_d_bmHAKL3HAKR: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => n_ahbsi_hwrite,
    I1 => ssrstate_1_sqmuxa_1,
    O => SSRSTATE_1_0_D_BM(3));
  II_ctrl_v_ssrstate_1_0_d_amHAKL3HAKR: LUT3
  generic map(
    INIT => X"20"
  )
  port map (
    I0 => rst,
    I1 => D16MUXC_0_4_INT_73,
    I2 => SSRSTATE_3_INT_23,
    O => SSRSTATE_1_0_D_AM(3));
  II_v_writen_0_sqmuxa_0_2: LUT4
  generic map(
    INIT => X"0E00"
  )
  port map (
    I0 => n_ahbsi_hwrite,
    I1 => SSRSTATE6_XX_MM_M3_INT_64,
    I2 => ssrstate_1_sqmuxa_1,
    I3 => WRITEN_0_SQMUXA_0_0,
    O => WRITEN_0_SQMUXA_0_2);
  II_un1_r_ssrstate_12_1: LUT4
  generic map(
    INIT => X"0111"
  )
  port map (
    I0 => SSRSTATE_3_INT_23,
    I1 => BDRIVE_1_SQMUXA_2,
    I2 => WS_0_SQMUXA_0_0_0,
    I3 => WS_0_SQMUXA_0_C_INT_50,
    O => SSRSTATE_12_1);
  II_v_ws_2_sqmuxa_3_d: LUT4
  generic map(
    INIT => X"4FFF"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HSEL_5_INT_67,
    I2 => SSRSTATE_1_INT_21,
    I3 => WS_0_SQMUXA_1_INT_57,
    O => WS_2_SQMUXA_3_D_INT_56);
  II_un1_v_writen_2_sqmuxa_tz_0: LUT4
  generic map(
    INIT => X"00E0"
  )
  port map (
    I0 => n_ahbsi_hwrite,
    I1 => SSRSTATE6_XX_MM_M3_INT_64,
    I2 => SSRSTATE_2_I_INT_55,
    I3 => WS_3_SQMUXA_1_INT_53,
    O => WRITEN_2_SQMUXA_TZ_0);
  II_un1_r_ssrstate_9: LUT4
  generic map(
    INIT => X"0070"
  )
  port map (
    I0 => N_654,
    I1 => SSRSTATE_2_INT_22,
    I2 => SSRSTATE_2_I_INT_55,
    I3 => WS_3_SQMUXA_1_INT_53,
    O => SSRSTATE_9);
  II_ctrl_v_bdrive_1_iv_m9_i_0_0: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => BDRIVE_1_IV_0_1,
    I1 => BDRIVE_1_IV_M9_I_0,
    O => BDRIVE_1_IV_M9_I_0_0);
  II_un1_r_prstate_12_m7_i_a6_0: LUT4_L
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => change_3_f0,
    I2 => HMBSEL_4_1_INT_14,
    I3 => HSEL_5_INT_67,
    LO => PRSTATE_12_M7_I_A6_0);
  II_v_bwn_1_sqmuxa_2_d_0: LUT4
  generic map(
    INIT => X"FBFF"
  )
  port map (
    I0 => n_ahbsi_hwrite,
    I1 => HMBSEL_4_1_INT_14,
    I2 => CHANGE_1_SQMUXA_N_3_INT_63,
    I3 => SSRHREADY_2_SQMUXA_0_0_INT_62,
    O => BWN_1_SQMUXA_2_D_0);
  II_un1_v_ssrstate23_u_0_bmHAKL4HAKR: LUT3
  generic map(
    INIT => X"B0"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HSEL_5_INT_67,
    I2 => SSRSTATE_2_INT_22,
    O => SSRSTATE23_U_0_BM(4));
  II_un1_v_ssrstate23_u_0_amHAKL4HAKR: LUT3
  generic map(
    INIT => X"02"
  )
  port map (
    I0 => SSRSTATE23_1,
    I1 => WS_0_INT_16,
    I2 => WS_3_INT_19,
    O => SSRSTATE23_U_0_AM(4));
  II_v_writen_0_sqmuxa_d: LUT4
  generic map(
    INIT => X"40FF"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HMBSEL_4_1_INT_14,
    I2 => HSEL_5_INT_67,
    I3 => SSRSTATE_2_INT_22,
    O => WRITEN_0_SQMUXA_D);
  II_ctrl_v_ws_1_2_0_dHAKL1HAKR: LUT3
  generic map(
    INIT => X"E2"
  )
  port map (
    I0 => N_362,
    I1 => N_365,
    I2 => ROMRWS(1),
    O => WS_1_2_0_D(1));
  II_ctrl_v_ws_1_2_0_dHAKL2HAKR: LUT3
  generic map(
    INIT => X"E2"
  )
  port map (
    I0 => N_363,
    I1 => N_365,
    I2 => ROMRWS(2),
    O => WS_1_2_0_D(2));
  II_r_prstatesr_0: LUT3
  generic map(
    INIT => X"0B"
  )
  port map (
    I0 => un7_bus16en,
    I1 => PRSTATE_0_INT_27,
    I2 => PRSTATE_1_SQMUXA,
    O => PRSTATESR_0);
  II_un1_v_haddr_0_sqmuxa_a0_0: LUT3
  generic map(
    INIT => X"07"
  )
  port map (
    I0 => un7_bus16en,
    I1 => PRSTATE_0_INT_27,
    I2 => PRSTATE_5_INT_32,
    O => HADDR_0_SQMUXA_A0_0);
  II_ctrl_v_bdrive_1_iv_0_a1: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => SETBDRIVE,
    I2 => BDRIVE_1_SQMUXA,
    O => BDRIVE_1_IV_0_A1);
  II_v_prstate_1_0_a3HAKL4HAKR: LUT3
  generic map(
    INIT => X"80"
  )
  port map (
    I0 => rst,
    I1 => un7_bus16en,
    I2 => d16mux_0_sqmuxa,
    O => N_341);
  II_v_bdrive_0_sqmuxa_2_0: LUT4
  generic map(
    INIT => X"FF10"
  )
  port map (
    I0 => N_668,
    I1 => D16MUXC_0_4_INT_73,
    I2 => PRSTATE_1_INT_28,
    I3 => BDRIVE_0_SQMUXA_2_0_0,
    O => BDRIVE_0_SQMUXA_2_C);
  II_ctrl_v_bdrive_1_iv_m9_i_0: LUT3
  generic map(
    INIT => X"13"
  )
  port map (
    I0 => BDRIVE_1_IV_0_A4_0,
    I1 => PRSTATE_2_REP1_INT_59,
    I2 => BDRIVE_1_SQMUXA,
    O => BDRIVE_1_IV_M9_I_0);
  II_v_ws_0_sqmuxa_0_0_0: LUT4
  generic map(
    INIT => X"3133"
  )
  port map (
    I0 => HSEL_5_INT_67,
    I1 => D16MUXC_0_4_INT_73,
    I2 => SSRSTATE_0_INT_20,
    I3 => WS_0_SQMUXA_C_INT_49,
    O => WS_0_SQMUXA_0_0_0);
  II_v_prhready_0_sqmuxa: LUT3
  generic map(
    INIT => X"A8"
  )
  port map (
    I0 => un7_bus16en,
    I1 => PRSTATE_0_INT_27,
    I2 => d16mux_0_sqmuxa,
    O => PRHREADY_0_SQMUXA);
  II_v_ws_0_sqmuxa_1: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => N_656_INT_66,
    I1 => rst,
    O => WS_0_SQMUXA_1_INT_57);
  II_v_ws_0_sqmuxa_0: LUT4
  generic map(
    INIT => X"040F"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HSEL_5_INT_67,
    I2 => SSRSTATE_0_INT_20,
    I3 => SSRSTATE_1_INT_21,
    O => SSRSTATE_5_I);
  II_v_prstate_1_i_m4_0HAKL2HAKR: LUT3
  generic map(
    INIT => X"CA"
  )
  port map (
    I0 => HWRITE_1,
    I1 => un7_bus16en,
    I2 => PRSTATE_0_INT_27,
    O => N_336);
  II_v_bdrive_1_sqmuxa_2: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => HSEL_5_INT_67,
    I2 => SSRSTATE_1_INT_21,
    O => BDRIVE_1_SQMUXA_2);
  II_ctrl_v_bdrive_1_iv_0_a0: LUT4
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => UN1_AHBSI_INT_68,
    I1 => BDRIVE_1_IV_0_A4_0,
    I2 => HSEL_5_INT_67,
    I3 => SSRSTATE_1_INT_21,
    O => BDRIVE_1_IV_0_A0);
  II_ctrl_v_bdrive_1_iv_m9_i_a4_0_2_1: LUT4
  generic map(
    INIT => X"80A0"
  )
  port map (
    I0 => N_668,
    I1 => SSRSTATE10,
    I2 => D16MUXC_0_4_INT_73,
    I3 => SSRSTATE_3_INT_23,
    O => BDRIVE_1_IV_M9_I_A4_0_2_1);
  II_v_ws_0_sqmuxa_0_c: LUT2
  generic map(
    INIT => X"E"
  )
  port map (
    I0 => SSRSTATE_0_INT_20,
    I1 => SSRSTATE_1_INT_21,
    O => WS_0_SQMUXA_0_C_INT_50);
  II_un1_r_prstate_12_m7_i_a6: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => change_3_f0,
    I1 => CHANGE_INT_69,
    O => PRSTATE_12_M7_I_A6);
  II_v_prstate_1_sqmuxa: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => un7_bus16en,
    I1 => d16mux_0_sqmuxa,
    O => PRSTATE_1_SQMUXA);
  II_ctrl_v_hwdataout_1_0_0HAKL16HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(0),
    I1 => n_ahbsi_hwdata(16),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_382);
  II_ctrl_v_hwdataout_1_0_0HAKL17HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(1),
    I1 => n_ahbsi_hwdata(17),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_383);
  II_ctrl_v_hwdataout_1_0_0HAKL18HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(2),
    I1 => n_ahbsi_hwdata(18),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_384);
  II_ctrl_v_hwdataout_1_0_0HAKL19HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(3),
    I1 => n_ahbsi_hwdata(19),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_385);
  II_ctrl_v_hwdataout_1_0_0HAKL20HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(4),
    I1 => n_ahbsi_hwdata(20),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_386);
  II_ctrl_v_hwdataout_1_0_0HAKL21HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(5),
    I1 => n_ahbsi_hwdata(21),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_387);
  II_ctrl_v_hwdataout_1_0_0HAKL22HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(6),
    I1 => n_ahbsi_hwdata(22),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_388);
  II_ctrl_v_hwdataout_1_0_0HAKL23HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(7),
    I1 => n_ahbsi_hwdata(23),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_389);
  II_ctrl_v_hwdataout_1_0_0HAKL24HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(8),
    I1 => n_ahbsi_hwdata(24),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_390);
  II_ctrl_v_hwdataout_1_0_0HAKL25HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(9),
    I1 => n_ahbsi_hwdata(25),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_391);
  II_ctrl_v_hwdataout_1_0_0HAKL26HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(10),
    I1 => n_ahbsi_hwdata(26),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_392);
  II_ctrl_v_hwdataout_1_0_0HAKL27HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(11),
    I1 => n_ahbsi_hwdata(27),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_393);
  II_ctrl_v_hwdataout_1_0_0HAKL28HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(12),
    I1 => n_ahbsi_hwdata(28),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_394);
  II_ctrl_v_hwdataout_1_0_0HAKL29HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(13),
    I1 => n_ahbsi_hwdata(29),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_395);
  II_ctrl_v_hwdataout_1_0_0HAKL30HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(14),
    I1 => n_ahbsi_hwdata(30),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_396);
  II_ctrl_v_hwdataout_1_0_0HAKL31HAKR: LUT4_L
  generic map(
    INIT => X"ACCC"
  )
  port map (
    I0 => n_ahbsi_hwdata(15),
    I1 => n_ahbsi_hwdata(31),
    I2 => N_SRO_ADDRESS_1_INT_37,
    I3 => BUS16EN_INT_72,
    LO => N_397);
  II_ctrl_v_bwn_1_0_a3_0_1HAKL0HAKR: LUT4_L
  generic map(
    INIT => X"0207"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_hsize(0),
    I2 => hsize_1(1),
    I3 => SIZE_0_INT_25,
    LO => N_319_1);
  II_ctrl_v_bwn_1_0_a3HAKL0HAKR: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => hsize_1(1),
    I1 => haddr_0,
    O => N_317);
  II_v_writen_0_sqmuxa_0_0: LUT4
  generic map(
    INIT => X"4F00"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => SSRSTATE_2_INT_22,
    I3 => SSRSTATE_2_I_INT_55,
    O => WRITEN_0_SQMUXA_0_0);
  II_v_ssrhready_2_sqmuxa_0_0: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => SSRSTATE_2_INT_22,
    O => SSRHREADY_2_SQMUXA_0_0_INT_62);
  II_v_bdrive_0_sqmuxa_2_0_0: LUT4_L
  generic map(
    INIT => X"01FF"
  )
  port map (
    I0 => N_668,
    I1 => PRSTATE_1_INT_28,
    I2 => PRSTATE_2_REP1_INT_59,
    I3 => SETBDRIVE,
    LO => BDRIVE_0_SQMUXA_2_0_0);
  II_r_d16muxc_0_1: LUT4
  generic map(
    INIT => X"000E"
  )
  port map (
    I0 => N_SRO_ADDRESS_1_INT_37,
    I1 => UN17_BUS16EN,
    I2 => PRSTATE_0_INT_27,
    I3 => PRSTATE_5_INT_32,
    O => D16MUXC_0_1);
  II_ctrl_v_bdrive_1_iv_0_1: LUT4
  generic map(
    INIT => X"BBBF"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => SETBDRIVE,
    I2 => SSRSTATE_0_INT_20,
    I3 => SSRSTATE_1_INT_21,
    O => BDRIVE_1_IV_0_1);
  II_v_ssrstate_11HAKL0HAKR: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => D16MUXC_0_4_INT_73,
    I1 => SSRSTATE_0_INT_20,
    O => SSRSTATE_11(0));
  II_v_bdrive_1_sqmuxa: LUT4
  generic map(
    INIT => X"CC4C"
  )
  port map (
    I0 => SSRSTATE23_1,
    I1 => SSRSTATE_3_INT_23,
    I2 => WS_0_INT_16,
    I3 => WS_3_INT_19,
    O => BDRIVE_1_SQMUXA);
  II_v_ssrhready_2_sqmuxa_m2: LUT4
  generic map(
    INIT => X"2A7F"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_hsel(0),
    I2 => n_ahbsi_htrans(1),
    I3 => HSEL_INT_58,
    O => CHANGE_1_SQMUXA_N_3_INT_63);
  II_ctrl_hwrite_1_0: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_hwrite,
    I2 => HWRITE,
    O => HWRITE_1);
  II_haddr_0HAKL3HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(3),
    I2 => HADDR(3),
    O => NN_1);
  II_haddr_0HAKL4HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(4),
    I2 => HADDR(4),
    O => NN_2);
  II_haddr_0HAKL5HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(5),
    I2 => HADDR(5),
    O => NN_3);
  II_haddr_0HAKL6HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(6),
    I2 => HADDR(6),
    O => NN_4);
  II_haddr_0HAKL7HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(7),
    I2 => HADDR(7),
    O => NN_5);
  II_haddr_0HAKL8HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(8),
    I2 => HADDR(8),
    O => NN_6);
  II_haddr_0HAKL9HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(9),
    I2 => HADDR(9),
    O => NN_7);
  II_haddr_0HAKL10HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(10),
    I2 => HADDR(10),
    O => NN_8);
  II_haddr_0HAKL11HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662_INT_60,
    I1 => n_ahbsi_haddr(11),
    I2 => HADDR(11),
    O => NN_9);
  II_ctrl_v_hsel_5_0: LUT4
  generic map(
    INIT => X"D580"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_hsel(0),
    I2 => n_ahbsi_htrans(1),
    I3 => HSEL_INT_58,
    O => HSEL_5_INT_67);
  II_ctrl_v_ws_1_1_0HAKL2HAKR: LUT4
  generic map(
    INIT => X"F780"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_12,
    I1 => rst,
    I2 => IOWS(2),
    I3 => ROMWWS(2),
    O => N_363);
  II_ctrl_v_ws_1_1_0HAKL1HAKR: LUT4
  generic map(
    INIT => X"F780"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_12,
    I1 => rst,
    I2 => IOWS(1),
    I3 => ROMWWS(1),
    O => N_362);
  II_v_ws_3_sqmuxa_1_a0_2: LUT4
  generic map(
    INIT => X"8000"
  )
  port map (
    I0 => n_ahbsi_hsel(0),
    I1 => n_ahbsi_htrans(0),
    I2 => n_ahbsi_htrans(1),
    I3 => SSRSTATE_1_INT_21,
    O => WS_3_SQMUXA_1_A0_2);
  II_r_d16muxc_2: LUT3
  generic map(
    INIT => X"02"
  )
  port map (
    I0 => BUS16EN_INT_72,
    I1 => WS_0_INT_16,
    I2 => WS_3_INT_19,
    O => D16MUXC_2);
  II_r_d16muxc_1: LUT4
  generic map(
    INIT => X"0020"
  )
  port map (
    I0 => PRSTATE_3_INT_30,
    I1 => SIZE_0_INT_25,
    I2 => SIZE_1_INT_26,
    I3 => WS_1_INT_17,
    O => D16MUXC_1);
  II_un1_v_ssrstate17_2_0_m6_i_a3_a0_1: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => HMBSEL_1_INT_34,
    I1 => HSEL_INT_58,
    O => SSRSTATE17_2_0_M6_I_A3_A0_1);
  II_un1_v_ssrstate17_2_0_m6_i_a3_a2: LUT4
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => n_ahbsi_hmbsel(1),
    I1 => n_ahbsi_hready,
    I2 => n_ahbsi_hsel(0),
    I3 => n_ahbsi_htrans(1),
    O => ssrstate17_2_0_m6_i_a3_a2);
  II_v_ws_1_sqmuxa: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_12,
    I1 => rst,
    I2 => PRSTATE_4_INT_31,
    O => WS_1_SQMUXA_INT_52);
  II_ctrl_v_ssrstate10: LUT4
  generic map(
    INIT => X"0002"
  )
  port map (
    I0 => WS_0_INT_16,
    I1 => WS_1_INT_17,
    I2 => WS_2_INT_18,
    I3 => WS_3_INT_19,
    O => SSRSTATE10);
  II_r_d16muxc_0_4: LUT4
  generic map(
    INIT => X"0001"
  )
  port map (
    I0 => WS_0_INT_16,
    I1 => WS_1_INT_17,
    I2 => WS_2_INT_18,
    I3 => WS_3_INT_19,
    O => D16MUXC_0_4_INT_73);
  II_un1_r_ssrstate_3: LUT3
  generic map(
    INIT => X"8A"
  )
  port map (
    I0 => d_m2_0_a2_0,
    I1 => SETBDRIVE,
    I2 => SSRSTATE_3_INT_23,
    O => SSRSTATE_3);
  II_v_ws_0_sqmuxa_c: LUT3
  generic map(
    INIT => X"EF"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => SSRSTATE_1_INT_21,
    O => WS_0_SQMUXA_C_INT_49);
  II_un1_r_prstate_12_0: LUT3
  generic map(
    INIT => X"01"
  )
  port map (
    I0 => PRSTATE_0_INT_27,
    I1 => PRSTATE_1_INT_28,
    I2 => PRSTATE_2_REP1_INT_59,
    O => PRSTATE_12_0);
  II_regsdHAKL8HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWIDTH(0),
    O => n_apbo_prdata_8);
  II_regsdHAKL9HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWIDTH(1),
    O => n_apbo_prdata_9);
  II_regsdHAKL11HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWRITE,
    O => n_apbo_prdata_11);
  II_regsdHAKL1HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMRWS(1),
    O => n_apbo_prdata_1);
  II_regsdHAKL2HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMRWS(2),
    O => n_apbo_prdata_2);
  II_regsdHAKL3HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMRWS_3_INT_10,
    O => n_apbo_prdata_3);
  II_regsdHAKL5HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWWS(1),
    O => n_apbo_prdata_5);
  II_regsdHAKL6HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWWS(2),
    O => n_apbo_prdata_6);
  II_regsdHAKL7HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWWS_3_INT_8,
    O => n_apbo_prdata_7);
  II_regsdHAKL19HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => IOEN,
    O => n_apbo_prdata_19);
  II_regsdHAKL21HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => IOWS(1),
    O => n_apbo_prdata_21);
  II_regsdHAKL22HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => IOWS(2),
    O => n_apbo_prdata_22);
  II_regsdHAKL23HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => IOWS_3_INT_6,
    O => n_apbo_prdata_23);
  II_regsdHAKL20HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => IOWS_0_INT_5,
    O => n_apbo_prdata_20);
  II_regsdHAKL4HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMWWS_0_INT_7,
    O => n_apbo_prdata_4);
  II_regsdHAKL0HAKR: LUT3
  generic map(
    INIT => X"10"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    I2 => ROMRWS_0_INT_9,
    O => n_apbo_prdata_0);
  II_v_hmbsel_0_sqmuxa: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => hsel_4,
    O => HMBSEL_0_SQMUXA);
  II_v_data16_0_sqmuxa: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => BUS16EN_INT_72,
    I1 => PRSTATE_4_INT_31,
    O => DATA16_0_SQMUXA);
  II_hrdata_0HAKL31HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(15),
    I2 => HRDATA(31),
    O => n_ahbso_hrdata(31));
  II_hrdata_0HAKL30HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(14),
    I2 => HRDATA(30),
    O => n_ahbso_hrdata(30));
  II_hrdata_0HAKL29HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(13),
    I2 => HRDATA(29),
    O => n_ahbso_hrdata(29));
  II_hrdata_0HAKL28HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(12),
    I2 => HRDATA(28),
    O => n_ahbso_hrdata(28));
  II_hrdata_0HAKL27HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(11),
    I2 => HRDATA(27),
    O => n_ahbso_hrdata(27));
  II_hrdata_0HAKL26HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(10),
    I2 => HRDATA(26),
    O => n_ahbso_hrdata(26));
  II_hrdata_0HAKL25HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(9),
    I2 => HRDATA(25),
    O => n_ahbso_hrdata(25));
  II_hrdata_0HAKL24HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(8),
    I2 => HRDATA(24),
    O => n_ahbso_hrdata(24));
  II_hrdata_0HAKL23HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(7),
    I2 => HRDATA(23),
    O => n_ahbso_hrdata(23));
  II_hrdata_0HAKL22HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(6),
    I2 => HRDATA(22),
    O => n_ahbso_hrdata(22));
  II_hrdata_0HAKL21HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(5),
    I2 => HRDATA(21),
    O => n_ahbso_hrdata(21));
  II_hrdata_0HAKL20HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(4),
    I2 => HRDATA(20),
    O => n_ahbso_hrdata(20));
  II_hrdata_0HAKL19HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(3),
    I2 => HRDATA(19),
    O => n_ahbso_hrdata(19));
  II_hrdata_0HAKL18HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(2),
    I2 => HRDATA(18),
    O => n_ahbso_hrdata(18));
  II_hrdata_0HAKL17HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(1),
    I2 => HRDATA(17),
    O => n_ahbso_hrdata(17));
  II_hrdata_0HAKL16HAKR: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => D16MUX(0),
    I1 => DATA16(0),
    I2 => HRDATA(16),
    O => n_ahbso_hrdata(16));
  II_hrdata_0HAKL15HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(15),
    I2 => HRDATA(31),
    O => n_ahbso_hrdata(15));
  II_hrdata_0HAKL14HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(14),
    I2 => HRDATA(30),
    O => n_ahbso_hrdata(14));
  II_hrdata_0HAKL13HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(13),
    I2 => HRDATA(29),
    O => n_ahbso_hrdata(13));
  II_hrdata_0HAKL12HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(12),
    I2 => HRDATA(28),
    O => n_ahbso_hrdata(12));
  II_hrdata_0HAKL11HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(11),
    I2 => HRDATA(27),
    O => n_ahbso_hrdata(11));
  II_hrdata_0HAKL10HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(10),
    I2 => HRDATA(26),
    O => n_ahbso_hrdata(10));
  II_hrdata_0HAKL9HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(9),
    I2 => HRDATA(25),
    O => n_ahbso_hrdata(9));
  II_hrdata_0HAKL8HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(8),
    I2 => HRDATA(24),
    O => n_ahbso_hrdata(8));
  II_hrdata_0HAKL7HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(7),
    I2 => HRDATA(23),
    O => n_ahbso_hrdata(7));
  II_hrdata_0HAKL6HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(6),
    I2 => HRDATA(22),
    O => n_ahbso_hrdata(6));
  II_hrdata_0HAKL5HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(5),
    I2 => HRDATA(21),
    O => n_ahbso_hrdata(5));
  II_hrdata_0HAKL4HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(4),
    I2 => HRDATA(20),
    O => n_ahbso_hrdata(4));
  II_hrdata_0HAKL3HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(3),
    I2 => HRDATA(19),
    O => n_ahbso_hrdata(3));
  II_hrdata_0HAKL2HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(2),
    I2 => HRDATA(18),
    O => n_ahbso_hrdata(2));
  II_hrdata_0HAKL1HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(1),
    I2 => HRDATA(17),
    O => n_ahbso_hrdata(1));
  II_hrdata_0HAKL0HAKR: LUT3
  generic map(
    INIT => X"E4"
  )
  port map (
    I0 => D16MUX(1),
    I1 => HRDATA(0),
    I2 => HRDATA(16),
    O => n_ahbso_hrdata(0));
  II_ctrl_v_bdrive_1_iv_0_a0_0: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => PRSTATE_1_INT_28,
    I1 => SETBDRIVE,
    O => BDRIVE_1_IV_0_A4_0);
  II_ctrl_hwrite6: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => CHANGE_INT_69,
    I1 => PRHREADY_INT_48,
    O => N_662_INT_60);
  II_ctrl_regsd24: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => n_apbi_paddr(2),
    I1 => n_apbi_paddr(3),
    O => N_APBO_PRDATA_28_INT_11);
  II_ctrl_bus16en: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => ROMWIDTH(0),
    I1 => ROMWIDTH(1),
    O => BUS16EN_INT_72);
  II_ctrl_v_ssrstate23_1: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => WS_1_INT_17,
    I1 => WS_2_INT_18,
    O => SSRSTATE23_1);
  II_ctrl_un1_ahbsi: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    O => UN1_AHBSI_INT_68);
  II_un1_r_ssrstate_2: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => SSRSTATE_0_INT_20,
    I1 => SSRSTATE_3_INT_23,
    O => SSRSTATE_2_I_INT_55);
  II_ctrl_un17_bus16en: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => SIZE_0_INT_25,
    I1 => SIZE_1_INT_26,
    O => UN17_BUS16EN);
  II_un1_r_ssrstate_1: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => SSRSTATE_2_INT_22,
    I1 => SSRSTATE_4_INT_24,
    O => N_668);
  II_r_haddrHAKL1HAKR: FDSE port map (
      Q => N_SRO_ADDRESS_1_INT_37,
      D => n_ahbsi_haddr(1),
      C => clk,
      S => PRHREADY_0_SQMUXA,
      CE => HMBSEL_0_SQMUXA);
  II_r_prstateHAKL5HAKR: FDS port map (
      Q => PRSTATE_5_INT_32,
      D => PRSTATES_I,
      C => clk,
      S => RST_I);
  II_r_prstateHAKL4HAKR: FDS port map (
      Q => PRSTATE_4_INT_31,
      D => N_342,
      C => clk,
      S => N_341);
  II_r_prstateHAKL3HAKR: FDR port map (
      Q => PRSTATE_3_INT_30,
      D => PRSTATEC,
      C => clk,
      R => RST_I);
  II_r_prstateHAKL2HAKR: FDR port map (
      Q => PRSTATE_2_INT_29,
      D => PRSTATEC_0,
      C => clk,
      R => RST_I);
  II_r_prstateHAKL1HAKR: FDR port map (
      Q => PRSTATE_1_INT_28,
      D => N_337_I,
      C => clk,
      R => RST_I);
  II_r_prstateHAKL0HAKR: FDR port map (
      Q => PRSTATE_0_INT_27,
      D => PRSTATEC_1,
      C => clk,
      R => RST_I);
  II_r_ssrstateHAKL1HAKR: FDR port map (
      Q => SSRSTATE_1_INT_21,
      D => ssrstatec,
      C => clk,
      R => RST_I);
  II_r_ssrstateHAKL0HAKR: FDR port map (
      Q => SSRSTATE_0_INT_20,
      D => SSRSTATEC_0,
      C => clk,
      R => RST_I);
  II_rbdriveHAKL28HAKR: FDR port map (
      Q => n_sro_vbdrive(28),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL29HAKR: FDR port map (
      Q => n_sro_vbdrive(29),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL30HAKR: FDR port map (
      Q => n_sro_vbdrive(30),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL31HAKR: FDR port map (
      Q => n_sro_vbdrive(31),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL13HAKR: FDR port map (
      Q => n_sro_vbdrive(13),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL14HAKR: FDR port map (
      Q => n_sro_vbdrive(14),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL15HAKR: FDR port map (
      Q => n_sro_vbdrive(15),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL16HAKR: FDR port map (
      Q => n_sro_vbdrive(16),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL17HAKR: FDR port map (
      Q => n_sro_vbdrive(17),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL18HAKR: FDR port map (
      Q => n_sro_vbdrive(18),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL19HAKR: FDR port map (
      Q => n_sro_vbdrive(19),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL20HAKR: FDR port map (
      Q => n_sro_vbdrive(20),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL21HAKR: FDR port map (
      Q => n_sro_vbdrive(21),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL22HAKR: FDR port map (
      Q => n_sro_vbdrive(22),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL23HAKR: FDR port map (
      Q => n_sro_vbdrive(23),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL24HAKR: FDR port map (
      Q => n_sro_vbdrive(24),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL25HAKR: FDR port map (
      Q => n_sro_vbdrive(25),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL26HAKR: FDR port map (
      Q => n_sro_vbdrive(26),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL27HAKR: FDR port map (
      Q => n_sro_vbdrive(27),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL0HAKR: FDR port map (
      Q => n_sro_vbdrive(0),
      D => RBDRIVEC_18,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL1HAKR: FDR port map (
      Q => n_sro_vbdrive(1),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL2HAKR: FDR port map (
      Q => n_sro_vbdrive(2),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL3HAKR: FDR port map (
      Q => n_sro_vbdrive(3),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL4HAKR: FDR port map (
      Q => n_sro_vbdrive(4),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL5HAKR: FDR port map (
      Q => n_sro_vbdrive(5),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL6HAKR: FDR port map (
      Q => n_sro_vbdrive(6),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL7HAKR: FDR port map (
      Q => n_sro_vbdrive(7),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL8HAKR: FDR port map (
      Q => n_sro_vbdrive(8),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL9HAKR: FDR port map (
      Q => n_sro_vbdrive(9),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL10HAKR: FDR port map (
      Q => n_sro_vbdrive(10),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL11HAKR: FDR port map (
      Q => n_sro_vbdrive(11),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_rbdriveHAKL12HAKR: FDR port map (
      Q => n_sro_vbdrive(12),
      D => RBDRIVEC,
      C => clk,
      R => BDRIVE_1_IV_0_A1);
  II_r_d16muxHAKL0HAKR: FDR port map (
      Q => D16MUX(0),
      D => D16MUXC,
      C => clk,
      R => WS_2_INT_18);
  II_r_d16muxHAKL1HAKR: FDR port map (
      Q => D16MUX(1),
      D => D16MUXC_0,
      C => clk,
      R => PRSTATE_2_INT_29);
  II_r_acount_sHAKL9HAKR: XORCY port map (
      LI => ACOUNT_QXU(9),
      CI => ACOUNT_CRY(8),
      O => ACOUNT_S(9));
  II_r_acount_sHAKL8HAKR: XORCY port map (
      LI => ACOUNT_QXU(8),
      CI => ACOUNT_CRY(7),
      O => ACOUNT_S(8));
  II_r_acount_cryHAKL8HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(7),
      S => ACOUNT_QXU(8),
      LO => ACOUNT_CRY(8));
  II_r_acount_sHAKL7HAKR: XORCY port map (
      LI => ACOUNT_QXU(7),
      CI => ACOUNT_CRY(6),
      O => ACOUNT_S(7));
  II_r_acount_cryHAKL7HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(6),
      S => ACOUNT_QXU(7),
      LO => ACOUNT_CRY(7));
  II_r_acount_sHAKL6HAKR: XORCY port map (
      LI => ACOUNT_QXU(6),
      CI => ACOUNT_CRY(5),
      O => ACOUNT_S(6));
  II_r_acount_cryHAKL6HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(5),
      S => ACOUNT_QXU(6),
      LO => ACOUNT_CRY(6));
  II_r_acount_sHAKL5HAKR: XORCY port map (
      LI => ACOUNT_QXU(5),
      CI => ACOUNT_CRY(4),
      O => ACOUNT_S(5));
  II_r_acount_cryHAKL5HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(4),
      S => ACOUNT_QXU(5),
      LO => ACOUNT_CRY(5));
  II_r_acount_sHAKL4HAKR: XORCY port map (
      LI => ACOUNT_QXU(4),
      CI => ACOUNT_CRY(3),
      O => ACOUNT_S(4));
  II_r_acount_cryHAKL4HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(3),
      S => ACOUNT_QXU(4),
      LO => ACOUNT_CRY(4));
  II_r_acount_sHAKL3HAKR: XORCY port map (
      LI => ACOUNT_QXU(3),
      CI => ACOUNT_CRY(2),
      O => ACOUNT_S(3));
  II_r_acount_cryHAKL3HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(2),
      S => ACOUNT_QXU(3),
      LO => ACOUNT_CRY(3));
  II_r_acount_sHAKL2HAKR: XORCY port map (
      LI => ACOUNT_QXU(2),
      CI => ACOUNT_CRY(1),
      O => ACOUNT_S(2));
  II_r_acount_cryHAKL2HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => ACOUNT_CRY(1),
      S => ACOUNT_QXU(2),
      LO => ACOUNT_CRY(2));
  II_r_acount_sHAKL1HAKR: XORCY port map (
      LI => ACOUNT_QXU(1),
      CI => N_SRO_ADDRESS_2_INT_38,
      O => ACOUNT_S(1));
  II_r_acount_cryHAKL1HAKR: MUXCY_L port map (
      DI => NN_10,
      CI => N_SRO_ADDRESS_2_INT_38,
      S => ACOUNT_QXU(1),
      LO => ACOUNT_CRY(1));
  II_r_hsel: FDRE port map (
      Q => HSEL_INT_58,
      D => hsel_4,
      C => clk,
      R => RST_I,
      CE => n_ahbsi_hready);
  II_r_mcfg1_ioen: FDRE port map (
      Q => IOEN,
      D => IOEN_1,
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwrite: FDRE port map (
      Q => ROMWRITE,
      D => ROMWRITE_1,
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_iowsHAKL3HAKR: FDRE port map (
      Q => IOWS_3_INT_6,
      D => IOWS_1(3),
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_iowsHAKL2HAKR: FDRE port map (
      Q => IOWS(2),
      D => IOWS_1(2),
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_iowsHAKL1HAKR: FDRE port map (
      Q => IOWS(1),
      D => IOWS_1(1),
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_iowsHAKL0HAKR: FDRE port map (
      Q => IOWS_0_INT_5,
      D => IOWS_1(0),
      C => clk,
      R => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romrwsHAKL3HAKR: FDSE port map (
      Q => ROMRWS_3_INT_10,
      D => N_627_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romrwsHAKL2HAKR: FDSE port map (
      Q => ROMRWS(2),
      D => N_628_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romrwsHAKL1HAKR: FDSE port map (
      Q => ROMRWS(1),
      D => N_629_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romrwsHAKL0HAKR: FDSE port map (
      Q => ROMRWS_0_INT_9,
      D => N_630_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwwsHAKL3HAKR: FDSE port map (
      Q => ROMWWS_3_INT_8,
      D => N_623_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwwsHAKL2HAKR: FDSE port map (
      Q => ROMWWS(2),
      D => N_624_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwwsHAKL1HAKR: FDSE port map (
      Q => ROMWWS(1),
      D => N_625_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_mcfg1_romwwsHAKL0HAKR: FDSE port map (
      Q => ROMWWS_0_INT_7,
      D => N_626_I,
      C => clk,
      S => RST_I,
      CE => BEXCEN_1_SQMUXA_I);
  II_r_writen: FDSE port map (
      Q => n_sro_writen,
      D => N_635_I,
      C => clk,
      S => RST_I,
      CE => WRITEN_2_SQMUXA);
  II_r_loadcount: FDS port map (
      Q => loadcount,
      D => loadcount_7,
      C => clk,
      S => RST_I);
  II_r_setbdrive: FDRE port map (
      Q => SETBDRIVE,
      D => SSRSTATE_1_INT_21,
      C => clk,
      R => RST_I,
      CE => SSRSTATE_3);
  II_r_ssrhready: FDS port map (
      Q => SSRHREADY_INT_51,
      D => ssrhready_8,
      C => clk,
      S => RST_I);
  II_r_prhready: FDS port map (
      Q => PRHREADY_INT_48,
      D => PRHREADY_6,
      C => clk,
      S => RST_I);
  II_r_romsn: FDSE port map (
      Q => N_SRO_ROMSN_0_INT_12,
      D => ROMSN_1,
      C => clk,
      S => RST_I,
      CE => N_599_I);
  II_r_hready: FDS port map (
      Q => n_ahbso_hready,
      D => hready_2,
      C => clk,
      S => RST_I);
  II_GND: GND port map (
      G => NN_10);
  II_VCC: VCC port map (
      P => NN_11);
  iows_0 <= IOWS_0_INT_5;
  iows_3 <= IOWS_3_INT_6;
  romwws_0 <= ROMWWS_0_INT_7;
  romwws_3 <= ROMWWS_3_INT_8;
  romrws_0 <= ROMRWS_0_INT_9;
  romrws_3 <= ROMRWS_3_INT_10;
  n_apbo_prdata_28 <= N_APBO_PRDATA_28_INT_11;
  n_sro_romsn(0) <= N_SRO_ROMSN_0_INT_12;
  prstate_fast(2) <= PRSTATE_FAST_2_INT_13;
  hmbsel_4(1) <= HMBSEL_4_1_INT_14;
  n_sro_bdrive(3) <= N_SRO_BDRIVE_3_INT_15;
  ws(0) <= WS_0_INT_16;
  ws(1) <= WS_1_INT_17;
  ws(2) <= WS_2_INT_18;
  ws(3) <= WS_3_INT_19;
  ssrstate(0) <= SSRSTATE_0_INT_20;
  ssrstate(1) <= SSRSTATE_1_INT_21;
  ssrstate(2) <= SSRSTATE_2_INT_22;
  ssrstate(3) <= SSRSTATE_3_INT_23;
  ssrstate(4) <= SSRSTATE_4_INT_24;
  size(0) <= SIZE_0_INT_25;
  size(1) <= SIZE_1_INT_26;
  prstate(0) <= PRSTATE_0_INT_27;
  prstate(1) <= PRSTATE_1_INT_28;
  prstate(2) <= PRSTATE_2_INT_29;
  prstate(3) <= PRSTATE_3_INT_30;
  prstate(4) <= PRSTATE_4_INT_31;
  prstate(5) <= PRSTATE_5_INT_32;
  hmbsel(0) <= HMBSEL_0_INT_33;
  hmbsel(1) <= HMBSEL_1_INT_34;
  hmbsel(2) <= HMBSEL_2_INT_35;
  n_sro_address(0) <= N_SRO_ADDRESS_0_INT_36;
  n_sro_address(1) <= N_SRO_ADDRESS_1_INT_37;
  n_sro_address(2) <= N_SRO_ADDRESS_2_INT_38;
  n_sro_address(3) <= N_SRO_ADDRESS_3_INT_39;
  n_sro_address(4) <= N_SRO_ADDRESS_4_INT_40;
  n_sro_address(5) <= N_SRO_ADDRESS_5_INT_41;
  n_sro_address(6) <= N_SRO_ADDRESS_6_INT_42;
  n_sro_address(7) <= N_SRO_ADDRESS_7_INT_43;
  n_sro_address(8) <= N_SRO_ADDRESS_8_INT_44;
  n_sro_address(9) <= N_SRO_ADDRESS_9_INT_45;
  n_sro_address(10) <= N_SRO_ADDRESS_10_INT_46;
  n_sro_address(11) <= N_SRO_ADDRESS_11_INT_47;
  prhready <= PRHREADY_INT_48;
  ws_0_sqmuxa_c <= WS_0_SQMUXA_C_INT_49;
  ws_0_sqmuxa_0_c <= WS_0_SQMUXA_0_C_INT_50;
  ssrhready <= SSRHREADY_INT_51;
  ws_1_sqmuxa <= WS_1_SQMUXA_INT_52;
  ws_3_sqmuxa_1 <= WS_3_SQMUXA_1_INT_53;
  ws_2_sqmuxa_3_0_2 <= WS_2_SQMUXA_3_0_2_INT_54;
  ssrstate_2_i <= SSRSTATE_2_I_INT_55;
  ws_2_sqmuxa_3_d <= WS_2_SQMUXA_3_D_INT_56;
  ws_0_sqmuxa_1 <= WS_0_SQMUXA_1_INT_57;
  hsel <= HSEL_INT_58;
  prstate_2_rep1 <= PRSTATE_2_REP1_INT_59;
  N_662 <= N_662_INT_60;
  ssrstate_6_sqmuxa <= SSRSTATE_6_SQMUXA_INT_61;
  ssrhready_2_sqmuxa_0_0 <= SSRHREADY_2_SQMUXA_0_0_INT_62;
  change_1_sqmuxa_N_3 <= CHANGE_1_SQMUXA_N_3_INT_63;
  ssrstate6_xx_mm_m3 <= SSRSTATE6_XX_MM_M3_INT_64;
  ssrstate6_1_d_0_L1 <= SSRSTATE6_1_D_0_L1_INT_65;
  N_656 <= N_656_INT_66;
  hsel_5 <= HSEL_5_INT_67;
  un1_ahbsi <= UN1_AHBSI_INT_68;
  change <= CHANGE_INT_69;
  n_sro_iosn <= N_SRO_IOSN_INT_70;
  N_371 <= N_371_INT_71;
  bus16en <= BUS16EN_INT_72;
  d16muxc_0_4 <= D16MUXC_0_4_INT_73;
end beh;

--

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

architecture beh of ssrctrl_unisim is
  signal WRP_R_HMBSEL : std_logic_vector (2 downto 0);
  signal WRP_R_WS : std_logic_vector (3 downto 0);
  signal WRP_R_SIZE : std_logic_vector (1 downto 0);
  signal WRP_R_PRSTATE : std_logic_vector (5 downto 0);
  signal WRP_R_SSRSTATE : std_logic_vector (4 downto 0);
  signal WRP_R_MCFG1_ROMRWS : std_logic_vector (3 downto 0);
  signal WRP_R_MCFG1_ROMWWS : std_logic_vector (3 downto 0);
  signal WRP_R_MCFG1_IOWS : std_logic_vector (3 downto 0);
  signal WRP_CTRL_V_SSRSTATE_1 : std_logic_vector (4 to 4);
  signal WRP_CTRL_V_SSRSTATE_1_M1 : std_logic_vector (4 downto 3);
  signal WRP_CTRL_V_WS_1 : std_logic_vector (3 downto 0);
  signal WRP_CTRL_V_HMBSEL_4 : std_logic_vector (1 to 1);
  signal WRP_NONAME_CNST : std_logic_vector (0 to 0);
  signal WRP_CTRL_HSIZE_1 : std_logic_vector (1 to 1);
  signal WRP_HADDR : std_logic_vector (1 to 1);
  signal WRP_UN1_V_HSEL_1 : std_logic_vector (0 to 0);
  signal WRP_CTRL_V_BWN_1_0_O3 : std_logic_vector (0 to 0);
  signal WRP_V_PRSTATE_1_I_O4_S : std_logic_vector (2 to 2);
  signal WRP_R_PRSTATE_FAST : std_logic_vector (2 to 2);
  signal N_SRO_ADDRESS_0_INT_172 : std_logic ;
  signal N_SRO_ADDRESS_1_INT_173 : std_logic ;
  signal N_SRO_IOSN_INT_259 : std_logic ;
  signal N_SRO_ROMSN_0_INT_260 : std_logic ;
  signal WRP_R_PRHREADY : std_logic ;
  signal WRP_R_CHANGE : std_logic ;
  signal WRP_CTRL_V_HSEL_5 : std_logic ;
  signal WRP_R_HSEL : std_logic ;
  signal WRP_CTRL_V_LOADCOUNT_7 : std_logic ;
  signal WRP_R_LOADCOUNT : std_logic ;
  signal WRP_CTRL_V_SSRHREADY_8 : std_logic ;
  signal WRP_R_SSRHREADY : std_logic ;
  signal WRP_CTRL_V_HREADY_2 : std_logic ;
  signal N_574_I : std_logic ;
  signal WRP_CTRL_BUS16EN : std_logic ;
  signal WRP_CTRL_V_HSEL_4 : std_logic ;
  signal WRP_CTRL_UN7_BUS16EN : std_logic ;
  signal WRP_V_D16MUX_0_SQMUXA : std_logic ;
  signal N_593 : std_logic ;
  signal N_597 : std_logic ;
  signal N_596 : std_logic ;
  signal WRP_V_SSRSTATE_2_SQMUXA_1 : std_logic ;
  signal WRP_V_SSRSTATE_6_SQMUXA : std_logic ;
  signal WRP_V_SSRSTATE_1_SQMUXA_1 : std_logic ;
  signal WRP_UN1_R_SSRSTATE_2_I : std_logic ;
  signal WRP_V_WS_0_SQMUXA_1 : std_logic ;
  signal WRP_V_BWN_0_SQMUXA_1 : std_logic ;
  signal WRP_V_WS_1_SQMUXA : std_logic ;
  signal N_646 : std_logic ;
  signal WRP_V_WS_3_SQMUXA_1 : std_logic ;
  signal N_662 : std_logic ;
  signal WRP_V_LOADCOUNT_1_SQMUXA : std_logic ;
  signal N_319_1 : std_logic ;
  signal WRP_CTRL_UN1_AHBSI : std_logic ;
  signal N_622 : std_logic ;
  signal WRP_UN1_V_SSRSTATE_2_SQMUXA_I : std_logic ;
  signal N_365 : std_logic ;
  signal N_371 : std_logic ;
  signal N_656 : std_logic ;
  signal WRP_UN1_V_CHANGE_1_SQMUXA_0 : std_logic ;
  signal G0_25 : std_logic ;
  signal WRP_CTRL_V_CHANGE_3_F0 : std_logic ;
  signal WRP_UN1_V_BWN_1_SQMUXA_2_D : std_logic ;
  signal WRP_CTRL_UN1_V_SSRSTATE17_1_XX_MM_N_4 : std_logic ;
  signal SSRSTATE17_2_0_M6_I_A3_A2 : std_logic ;
  signal SSRSTATE6_XX_MM_M3 : std_logic ;
  signal WRP_V_CHANGE_1_SQMUXA_N_3 : std_logic ;
  signal WRP_CTRL_V_CHANGE_3_F1_D_0_0 : std_logic ;
  signal WRP_V_WS_2_SQMUXA_3_D : std_logic ;
  signal WRP_V_WS_0_SQMUXA_C : std_logic ;
  signal WRP_V_WS_0_SQMUXA_0_C : std_logic ;
  signal G0_30 : std_logic ;
  signal D_M2_0_A2_0 : std_logic ;
  signal N_618_I : std_logic ;
  signal WRP_R_SSRSTATEC : std_logic ;
  signal WRP_R_D16MUXC_0_4 : std_logic ;
  signal WRP_V_WS_4_SQMUXA_0 : std_logic ;
  signal D_M1_E_0_0 : std_logic ;
  signal WRP_V_WS_2_SQMUXA_0 : std_logic ;
  signal WRP_V_SSRSTATE_1_SQMUXA_1_XX_MM_A1_0 : std_logic ;
  signal WRP_UN1_V_SSRSTATE17_2_0_M6_I_1 : std_logic ;
  signal WRP_V_SSRHREADY_2_SQMUXA_0_0 : std_logic ;
  signal WRP_V_WS_2_SQMUXA_3_0_2 : std_logic ;
  signal WRP_V_WS_2_SQMUXA_3_0_4 : std_logic ;
  signal WRP_UN1_V_BWN_1_SQMUXA_2_D_0_2 : std_logic ;
  signal WRP_UN1_V_SSRSTATE_1_SQMUXA_1_0_M3_0_1 : std_logic ;
  signal SSRSTATE6_1_D_0_L1 : std_logic ;
  signal HSEL_1_0_L3 : std_logic ;
  signal SSRHREADY_8_F0_L5 : std_logic ;
  signal SSRHREADY_8_F0_L8 : std_logic ;
  signal G0_I : std_logic ;
  signal N_5 : std_logic ;
  signal G0_23 : std_logic ;
  signal N_14 : std_logic ;
  signal N_19 : std_logic ;
  signal G0_34 : std_logic ;
  signal G0_29 : std_logic ;
  signal G0_28 : std_logic ;
  signal G0_31 : std_logic ;
  signal G2_1_0 : std_logic ;
  signal G0_44 : std_logic ;
  signal G0_I_M2_1 : std_logic ;
  signal G0_14 : std_logic ;
  signal G0_7_0 : std_logic ;
  signal G0_1_0 : std_logic ;
  signal G3 : std_logic ;
  signal N_4 : std_logic ;
  signal N_17 : std_logic ;
  signal G0_5_0 : std_logic ;
  signal G0_11 : std_logic ;
  signal G0_I_A3_0 : std_logic ;
  signal G0_51 : std_logic ;
  signal G0_8_1 : std_logic ;
  signal G0_56 : std_logic ;
  signal G0_I_M2_2 : std_logic ;
  signal N_9 : std_logic ;
  signal G0_8 : std_logic ;
  signal G0_I_M2_L1 : std_logic ;
  signal G0_54_L1 : std_logic ;
  signal G0_57_1 : std_logic ;
  signal G0_34_L1_0 : std_logic ;
  signal G0_34_L6 : std_logic ;
  signal G0_34_L10 : std_logic ;
  signal G0_55_L1 : std_logic ;
  signal G0_55_L5 : std_logic ;
  signal G0_55_L7 : std_logic ;
  signal G0_19_L1 : std_logic ;
  signal G0_52_X0 : std_logic ;
  signal G0_52_X1 : std_logic ;
  signal G0_50_X : std_logic ;
  signal WS_2_SQMUXA_3_0_X : std_logic ;
  signal D_M1_E_L1 : std_logic ;
  signal G0_57_1_L5 : std_logic ;
  signal G0_57_1_L7 : std_logic ;
  signal G0_55_L5_L1 : std_logic ;
  signal G0_55_L7_L1 : std_logic ;
  signal G0_36_L1 : std_logic ;
  signal G0_48_L1 : std_logic ;
  signal G0_34_L10_L1 : std_logic ;
  signal G0_34_L10_L3 : std_logic ;
  signal G0_57_1_L7_L4 : std_logic ;
  signal G0_57_1_L7_L6 : std_logic ;
  signal G0_57_1_L7_L8 : std_logic ;
  signal WRP_R_PRSTATE_2_REP1 : std_logic ;
  signal D_M1_E_L1_0 : std_logic ;
  signal D_M1_E_L3 : std_logic ;
  signal G0_I_M2_0_L1 : std_logic ;
  signal G0_I_M2_0_L3 : std_logic ;
  signal G0_I_M2_0_L5 : std_logic ;
  signal G3_1 : std_logic ;
  signal G0_0_L1 : std_logic ;
  signal G0_0_L3 : std_logic ;
  signal G0_0_L5 : std_logic ;
  signal G0_0_L7 : std_logic ;
  signal G0_0_L9 : std_logic ;
  signal G0_57_1_L7_L6_RN_0 : std_logic ;
  signal G0_57_1_L7_L6_SN : std_logic ;
  signal G0_55_L7_L1_RN_0 : std_logic ;
  signal G0_55_L7_L1_SN : std_logic ;
  signal G0_52X : std_logic ;
  signal G0_52X_0 : std_logic ;
  signal G2_0_1 : std_logic ;
  signal G0_46_L1 : std_logic ;
  signal G0_46_L3 : std_logic ;
  signal G0_46_L5 : std_logic ;
  signal G0_46_L7 : std_logic ;
  signal NN_1 : std_logic ;
  signal N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268 : std_logic ;
  signal N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272 : std_logic ;
  signal NN_2 : std_logic ;
  component ssrctrl_unisim_netlist
    port(
      n_sro_vbdrive : out std_logic_vector(31 downto 0);
      n_ahbso_hrdata : out std_logic_vector(31 downto 0);
      iows_0 : out std_logic;
      iows_3 : out std_logic;
      romwws_0 : out std_logic;
      romwws_3 : out std_logic;
      romrws_0 : out std_logic;
      romrws_3 : out std_logic;
      NoName_cnst : in std_logic_vector(0 downto 0);
      n_sri_bwidth : in std_logic_vector(1 downto 0);
      n_apbi_pwdata_19 : in std_logic;
      n_apbi_pwdata_11 : in std_logic;
      n_apbi_pwdata_9 : in std_logic;
      n_apbi_pwdata_8 : in std_logic;
      n_apbi_pwdata_23 : in std_logic;
      n_apbi_pwdata_22 : in std_logic;
      n_apbi_pwdata_21 : in std_logic;
      n_apbi_pwdata_20 : in std_logic;
      n_apbi_pwdata_3 : in std_logic;
      n_apbi_pwdata_2 : in std_logic;
      n_apbi_pwdata_1 : in std_logic;
      n_apbi_pwdata_0 : in std_logic;
      n_apbi_pwdata_7 : in std_logic;
      n_apbi_pwdata_6 : in std_logic;
      n_apbi_pwdata_5 : in std_logic;
      n_apbi_pwdata_4 : in std_logic;
      n_apbi_psel : in std_logic_vector(0 downto 0);
      n_apbi_paddr : in std_logic_vector(5 downto 2);
      n_apbo_prdata_0 : out std_logic;
      n_apbo_prdata_4 : out std_logic;
      n_apbo_prdata_20 : out std_logic;
      n_apbo_prdata_23 : out std_logic;
      n_apbo_prdata_22 : out std_logic;
      n_apbo_prdata_21 : out std_logic;
      n_apbo_prdata_19 : out std_logic;
      n_apbo_prdata_7 : out std_logic;
      n_apbo_prdata_6 : out std_logic;
      n_apbo_prdata_5 : out std_logic;
      n_apbo_prdata_3 : out std_logic;
      n_apbo_prdata_2 : out std_logic;
      n_apbo_prdata_1 : out std_logic;
      n_apbo_prdata_11 : out std_logic;
      n_apbo_prdata_9 : out std_logic;
      n_apbo_prdata_8 : out std_logic;
      n_apbo_prdata_28 : out std_logic;
      n_sro_romsn : out std_logic_vector(0 downto 0);
      n_ahbsi_hsel : in std_logic_vector(0 downto 0);
      prstate_fast : out std_logic_vector(2 downto 2);
      n_ahbsi_htrans : in std_logic_vector(1 downto 0);
      ssrstate_1_m1 : inout std_logic_vector(4 downto 3);
      hsel_1 : in std_logic_vector(0 downto 0);
      hmbsel_4 : out std_logic_vector(1 downto 1);
      n_sro_bdrive : out std_logic_vector(3 downto 3);
      ws_1_0 : in std_logic;
      ws_1_3 : in std_logic;
      ws : out std_logic_vector(3 downto 0);
      ssrstate_1_2 : in std_logic;
      n_ahbsi_haddr : in std_logic_vector(31 downto 0);
      n_ahbsi_hmbsel : in std_logic_vector(2 downto 0);
      n_sri_data : in std_logic_vector(31 downto 0);
      ssrstate : out std_logic_vector(4 downto 0);
      n_ahbsi_hwdata : in std_logic_vector(31 downto 0);
      n_ahbsi_hsize : in std_logic_vector(1 downto 0);
      size : out std_logic_vector(1 downto 0);
      n_sro_data : out std_logic_vector(31 downto 0);
      n_sro_ramsn : out std_logic_vector(0 downto 0);
      n_sro_wrn : out std_logic_vector(3 downto 0);
      haddr_0 : in std_logic;
      bwn_1_0_o3_0 : in std_logic;
      hsize_1 : in std_logic_vector(1 downto 1);
      prstate_1_i_o4_s : in std_logic_vector(2 downto 2);
      prstate : out std_logic_vector(5 downto 0);
      hmbsel : out std_logic_vector(2 downto 0);
      n_sro_address : out std_logic_vector(31 downto 0);
      hready_2 : in std_logic;
      n_ahbso_hready : out std_logic;
      ssrhready_8 : in std_logic;
      loadcount : out std_logic;
      n_sro_writen : out std_logic;
      ssrstatec : in std_logic;
      prhready : out std_logic;
      d_m2_0_a2_0 : in std_logic;
      ssrstate17_2_0_m6_i_a3_a2 : out std_logic;
      N_319_1 : out std_logic;
      ws_0_sqmuxa_c : out std_logic;
      N_365 : in std_logic;
      ws_0_sqmuxa_0_c : out std_logic;
      ws_2_sqmuxa_3_0_4 : out std_logic;
      change_1_sqmuxa_0 : in std_logic;
      d16mux_0_sqmuxa : in std_logic;
      ssrstate_2_sqmuxa_1 : in std_logic;
      un7_bus16en : in std_logic;
      N_646 : in std_logic;
      loadcount_1_sqmuxa : in std_logic;
      ssrstate_1_sqmuxa_1_0_m3_0_1 : out std_logic;
      n_apbi_penable : in std_logic;
      n_apbi_pwrite : in std_logic;
      d_m1_e_0_0 : in std_logic;
      hsel_1_0_L3 : out std_logic;
      ssrhready_8_f0_L8 : out std_logic;
      ssrstate_1_sqmuxa_1 : in std_logic;
      ssrhready : out std_logic;
      ssrhready_8_f0_L5 : out std_logic;
      ssrstate17_1_xx_mm_N_4 : in std_logic;
      ws_1_sqmuxa : out std_logic;
      ws_4_sqmuxa_0 : in std_logic;
      ws_2_sqmuxa_0 : in std_logic;
      ssrstate17_2_0_m6_i_1 : out std_logic;
      ws_2_sqmuxa_3_0_x : out std_logic;
      ws_3_sqmuxa_1 : out std_logic;
      ws_2_sqmuxa_3_0_2 : out std_logic;
      ssrstate_2_i : out std_logic;
      ws_2_sqmuxa_3_d : out std_logic;
      ws_0_sqmuxa_1 : out std_logic;
      g0_30 : in std_logic;
      hsel_4 : in std_logic;
      n_ahbsi_hready : in std_logic;
      hsel : out std_logic;
      g0_25 : in std_logic;
      bwn_0_sqmuxa_1 : in std_logic;
      prstate_2_rep1 : out std_logic;
      N_662 : out std_logic;
      ssrstate_6_sqmuxa : out std_logic;
      g0_52_x1 : in std_logic;
      g0_52_x0 : in std_logic;
      ssrhready_2_sqmuxa_0_0 : out std_logic;
      change_1_sqmuxa_N_3 : out std_logic;
      ssrstate6_xx_mm_m3 : out std_logic;
      ssrstate6_1_d_0_L1 : out std_logic;
      N_656 : out std_logic;
      hsel_5 : out std_logic;
      change_3_f0 : in std_logic;
      un1_ahbsi : out std_logic;
      change : out std_logic;
      n_ahbsi_hwrite : in std_logic;
      N_574_i : in std_logic;
      n_sro_iosn : out std_logic;
      N_618_i : in std_logic;
      clk : in std_logic;
      n_sro_oen : out std_logic;
      rst : in std_logic;
      bwn_1_sqmuxa_2_d : in std_logic;
      bwn_1_sqmuxa_2_d_0_2 : in std_logic;
      ssrstate_2_sqmuxa_i : in std_logic;
      g0_23 : in std_logic;
      N_371 : out std_logic;
      loadcount_7 : in std_logic;
      bus16en : out std_logic;
      d16muxc_0_4 : out std_logic;
      change_3_f1_d_0_0 : in std_logic;
      g0_1_0 : in std_logic;
      g0_44 : in std_logic  );
  end component;
begin
  II_g0_46: LUT4_L
  generic map(
    INIT => X"B000"
  )
  port map (
    I0 => N_4,
    I1 => N_17,
    I2 => G0_46_L7,
    I3 => G3,
    LO => WRP_CTRL_V_HREADY_2);
  II_g0_45: LUT4_L
  generic map(
    INIT => X"0B00"
  )
  port map (
    I0 => N_4,
    I1 => N_17,
    I2 => SSRHREADY_8_F0_L8,
    I3 => G3,
    LO => WRP_CTRL_V_SSRHREADY_8);
  II_g0_35: LUT4_L
  generic map(
    INIT => X"00B1"
  )
  port map (
    I0 => N_622,
    I1 => G0_34,
    I2 => G0_29,
    I3 => WRP_V_SSRSTATE_2_SQMUXA_1,
    LO => WRP_R_SSRSTATEC);
  II_g0_57: LUT4_L
  generic map(
    INIT => X"FA44"
  )
  port map (
    I0 => N_371,
    I1 => G0_56,
    I2 => G0_I_M2_2,
    I3 => G0_57_1,
    LO => WRP_CTRL_V_WS_1(0));
  II_g0_i_m2_0: LUT4_L
  generic map(
    INIT => X"B1E4"
  )
  port map (
    I0 => N_5,
    I1 => G0_I_M2_0_L3,
    I2 => G0_I_M2_0_L5,
    I3 => WRP_R_WS(3),
    LO => WRP_CTRL_V_WS_1(3));
  II_g0_i_m2: LUT4_L
  generic map(
    INIT => X"D8CC"
  )
  port map (
    I0 => N_622,
    I1 => G0_I_M2_L1,
    I2 => WRP_CTRL_V_SSRSTATE_1_M1(4),
    I3 => WRP_UN1_V_SSRSTATE_2_SQMUXA_I,
    LO => WRP_CTRL_V_SSRSTATE_1(4));
  II_g0_5: LUT4_L
  generic map(
    INIT => X"37FF"
  )
  port map (
    I0 => WRP_CTRL_HSIZE_1(1),
    I1 => WRP_CTRL_V_BWN_1_0_O3(0),
    I2 => WRP_HADDR(1),
    I3 => WRP_UN1_V_BWN_1_SQMUXA_2_D,
    LO => N_618_I);
  II_g0_46_L1: LUT3
  generic map(
    INIT => X"13"
  )
  port map (
    I0 => WRP_R_D16MUXC_0_4,
    I1 => WRP_R_SSRHREADY,
    I2 => WRP_R_SSRSTATE(3),
    O => G0_46_L1);
  II_g0_46_L3: LUT3
  generic map(
    INIT => X"0B"
  )
  port map (
    I0 => WRP_CTRL_UN1_AHBSI,
    I1 => WRP_CTRL_V_HSEL_5,
    I2 => WRP_R_CHANGE,
    O => G0_46_L3);
  II_g0_46_L5: LUT3
  generic map(
    INIT => X"5D"
  )
  port map (
    I0 => G0_44,
    I1 => G0_46_L1,
    I2 => WRP_V_SSRSTATE_1_SQMUXA_1,
    O => G0_46_L5);
  II_g0_46_L7: LUT4_L
  generic map(
    INIT => X"1033"
  )
  port map (
    I0 => G0_46_L3,
    I1 => G0_46_L5,
    I2 => WRP_CTRL_V_CHANGE_3_F1_D_0_0,
    I3 => WRP_V_PRSTATE_1_I_O4_S(2),
    LO => G0_46_L7);
  II_g2_0: LUT4
  generic map(
    INIT => X"E0EA"
  )
  port map (
    I0 => SSRHREADY_8_F0_L5,
    I1 => G2_0_1,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_R_SSRSTATE(2),
    O => N_4);
  II_g2_0_1: LUT3
  generic map(
    INIT => X"20"
  )
  port map (
    I0 => G0_48_L1,
    I1 => WRP_CTRL_UN1_AHBSI,
    I2 => WRP_CTRL_V_HSEL_5,
    O => G2_0_1);
  II_g0_52_x1x: LUT4
  generic map(
    INIT => X"35F5"
  )
  port map (
    I0 => D_M1_E_0_0,
    I1 => n_ahbsi_hmbsel(1),
    I2 => n_ahbsi_hready,
    I3 => n_ahbsi_hsel(0),
    O => G0_52X_0);
  II_g0_52_x0x: LUT2
  generic map(
    INIT => X"D"
  )
  port map (
    I0 => D_M1_E_0_0,
    I1 => n_ahbsi_hready,
    O => G0_52X);
  II_g0_55_L7_L1: LUT3
  generic map(
    INIT => X"E2"
  )
  port map (
    I0 => G0_55_L7_L1_RN_0,
    I1 => G0_55_L7_L1_SN,
    I2 => n_ahbsi_htrans(1),
    O => G0_55_L7_L1);
  II_g0_55_L7_L1_sn: LUT4
  generic map(
    INIT => X"8D88"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_hsel(0),
    I2 => n_ahbsi_htrans(0),
    I3 => WRP_R_HSEL,
    O => G0_55_L7_L1_SN);
  II_g0_55_L7_L1_rn: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => WRP_R_HSEL,
    O => G0_55_L7_L1_RN_0);
  II_g0_57_1_L7_L6: LUT3
  generic map(
    INIT => X"E2"
  )
  port map (
    I0 => G0_57_1_L7_L6_RN_0,
    I1 => G0_57_1_L7_L6_SN,
    I2 => n_ahbsi_htrans(1),
    O => G0_57_1_L7_L6);
  II_g0_57_1_L7_L6_sn: LUT4
  generic map(
    INIT => X"8D88"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => n_ahbsi_hsel(0),
    I2 => n_ahbsi_htrans(0),
    I3 => WRP_R_HSEL,
    O => G0_57_1_L7_L6_SN);
  II_g0_57_1_L7_L6_rn: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => WRP_R_HSEL,
    O => G0_57_1_L7_L6_RN_0);
  II_g0_0_L1: LUT2
  generic map(
    INIT => X"7"
  )
  port map (
    I0 => rst,
    I1 => WRP_R_PRSTATE_2_REP1,
    O => G0_0_L1);
  II_g0_0_L3: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => WRP_V_CHANGE_1_SQMUXA_N_3,
    I1 => WRP_V_SSRHREADY_2_SQMUXA_0_0,
    O => G0_0_L3);
  II_g0_0_L5: LUT4
  generic map(
    INIT => X"55DF"
  )
  port map (
    I0 => G0_0_L1,
    I1 => WRP_CTRL_UN1_AHBSI,
    I2 => WRP_CTRL_V_HSEL_5,
    I3 => WRP_R_D16MUXC_0_4,
    O => G0_0_L5);
  II_g0_0_L7: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => WRP_CTRL_UN1_V_SSRSTATE17_1_XX_MM_N_4,
    O => G0_0_L7);
  II_g0_0_L9: LUT4
  generic map(
    INIT => X"7F33"
  )
  port map (
    I0 => G0_0_L3,
    I1 => n_ahbsi_hwrite,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => SSRSTATE6_XX_MM_M3,
    O => G0_0_L9);
  II_g0_0: LUT4
  generic map(
    INIT => X"FFEF"
  )
  port map (
    I0 => G0_0_L5,
    I1 => G0_0_L7,
    I2 => G0_0_L9,
    I3 => WRP_V_LOADCOUNT_1_SQMUXA,
    O => WRP_UN1_V_BWN_1_SQMUXA_2_D);
  II_g3: LUT4
  generic map(
    INIT => X"DFCC"
  )
  port map (
    I0 => G3_1,
    I1 => n_ahbsi_hwrite,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => SSRSTATE6_XX_MM_M3,
    O => G3);
  II_g3_1: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => WRP_V_CHANGE_1_SQMUXA_N_3,
    I1 => WRP_V_SSRHREADY_2_SQMUXA_0_0,
    O => G3_1);
  II_g0_i_m2_0_L1: LUT3
  generic map(
    INIT => X"01"
  )
  port map (
    I0 => WRP_R_WS(0),
    I1 => WRP_R_WS(1),
    I2 => WRP_R_WS(2),
    O => G0_I_M2_0_L1);
  II_g0_i_m2_0_L3: LUT4
  generic map(
    INIT => X"0A2A"
  )
  port map (
    I0 => G0_I_M2_0_L1,
    I1 => G0_30,
    I2 => WRP_V_WS_0_SQMUXA_1,
    I3 => WRP_V_WS_3_SQMUXA_1,
    O => G0_I_M2_0_L3);
  II_g0_i_m2_0_L5: LUT4
  generic map(
    INIT => X"1555"
  )
  port map (
    I0 => D_M1_E_L1_0,
    I1 => D_M1_E_L3,
    I2 => WRP_V_WS_2_SQMUXA_3_0_2,
    I3 => WRP_V_WS_2_SQMUXA_3_D,
    O => G0_I_M2_0_L5);
  II_d_m1_e_L1_0: LUT3
  generic map(
    INIT => X"4E"
  )
  port map (
    I0 => N_365,
    I1 => D_M1_E_L1,
    I2 => WRP_R_MCFG1_ROMRWS(3),
    O => D_M1_E_L1_0);
  II_d_m1_e_L3: LUT4_L
  generic map(
    INIT => X"0F2F"
  )
  port map (
    I0 => WRP_UN1_R_SSRSTATE_2_I,
    I1 => G0_30,
    I2 => WRP_V_WS_0_SQMUXA_1,
    I3 => WRP_V_WS_3_SQMUXA_1,
    LO => D_M1_E_L3);
  II_g0_57_1_L7_L4: LUT4
  generic map(
    INIT => X"4555"
  )
  port map (
    I0 => SSRSTATE6_1_D_0_L1,
    I1 => n_ahbsi_htrans(0),
    I2 => n_ahbsi_htrans(1),
    I3 => WRP_R_SSRSTATE(1),
    O => G0_57_1_L7_L4);
  II_g0_57_1_L7_L8: LUT4_L
  generic map(
    INIT => X"4C40"
  )
  port map (
    I0 => G0_57_1_L7_L4,
    I1 => G0_57_1_L7_L6,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_R_SSRSTATE(2),
    LO => G0_57_1_L7_L8);
  II_g0_57_1_L7: LUT4_L
  generic map(
    INIT => X"4F5F"
  )
  port map (
    I0 => N_656,
    I1 => G0_57_1_L7_L8,
    I2 => rst,
    I3 => SSRSTATE6_XX_MM_M3,
    LO => G0_57_1_L7);
  II_g0_34_L10_L1: LUT4
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => n_ahbsi_hwrite,
    I3 => WRP_R_SSRSTATE(1),
    O => G0_34_L10_L1);
  II_g0_34_L10_L3: LUT2
  generic map(
    INIT => X"7"
  )
  port map (
    I0 => G0_34_L10_L1,
    I1 => WRP_CTRL_V_HSEL_5,
    O => G0_34_L10_L3);
  II_g0_34_L10: LUT4
  generic map(
    INIT => X"00B0"
  )
  port map (
    I0 => G0_34_L10_L3,
    I1 => WRP_CTRL_V_HMBSEL_4(1),
    I2 => WRP_UN1_V_CHANGE_1_SQMUXA_0,
    I3 => WRP_V_SSRSTATE_6_SQMUXA,
    O => G0_34_L10);
  II_g0_48_L1: LUT3
  generic map(
    INIT => X"40"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => n_ahbsi_hwrite,
    O => G0_48_L1);
  II_g0_48: LUT4
  generic map(
    INIT => X"2000"
  )
  port map (
    I0 => G0_48_L1,
    I1 => WRP_CTRL_UN1_AHBSI,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_CTRL_V_HSEL_5,
    O => WRP_V_LOADCOUNT_1_SQMUXA);
  II_g0_36_L1: LUT3
  generic map(
    INIT => X"2F"
  )
  port map (
    I0 => WRP_R_CHANGE,
    I1 => WRP_R_HSEL,
    I2 => WRP_R_PRSTATE(5),
    O => G0_36_L1);
  II_g0_36: LUT4
  generic map(
    INIT => X"2220"
  )
  port map (
    I0 => G0_I_M2_1,
    I1 => G0_36_L1,
    I2 => WRP_CTRL_V_HSEL_5,
    I3 => WRP_R_CHANGE,
    O => WRP_V_PRSTATE_1_I_O4_S(2));
  II_g0_55_L7: LUT4_L
  generic map(
    INIT => X"4CFC"
  )
  port map (
    I0 => G0_55_L1,
    I1 => G0_55_L5,
    I2 => G0_55_L7_L1,
    I3 => WRP_CTRL_V_HMBSEL_4(1),
    LO => G0_55_L7);
  II_g0_55_L5_L1: LUT4
  generic map(
    INIT => X"35FF"
  )
  port map (
    I0 => D_M1_E_0_0,
    I1 => n_ahbsi_hmbsel(1),
    I2 => n_ahbsi_hready,
    I3 => n_ahbsi_htrans(0),
    O => G0_55_L5_L1);
  II_g0_55_L5: LUT4
  generic map(
    INIT => X"51FF"
  )
  port map (
    I0 => G0_55_L5_L1,
    I1 => n_ahbsi_hready,
    I2 => WRP_CTRL_V_HSEL_4,
    I3 => WRP_R_SSRSTATE(2),
    O => G0_55_L5);
  II_g0_57_1_L5: LUT3
  generic map(
    INIT => X"70"
  )
  port map (
    I0 => G0_30,
    I1 => WRP_V_WS_0_SQMUXA_1,
    I2 => WRP_V_WS_2_SQMUXA_3_D,
    O => G0_57_1_L5);
  II_g0_57_1: LUT4_L
  generic map(
    INIT => X"1D55"
  )
  port map (
    I0 => N_365,
    I1 => G0_57_1_L5,
    I2 => G0_57_1_L7,
    I3 => WRP_V_WS_2_SQMUXA_3_0_4,
    LO => G0_57_1);
  II_d_m1_e_L1: LUT4
  generic map(
    INIT => X"087F"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_260,
    I1 => rst,
    I2 => WRP_R_MCFG1_IOWS(3),
    I3 => WRP_R_MCFG1_ROMWWS(3),
    O => D_M1_E_L1);
  II_g0_i_o4: LUT4_L
  generic map(
    INIT => X"FDF5"
  )
  port map (
    I0 => N_365,
    I1 => WS_2_SQMUXA_3_0_X,
    I2 => WRP_V_WS_1_SQMUXA,
    I3 => WRP_V_WS_2_SQMUXA_3_0_4,
    LO => N_5);
  II_g3_2: LUT4
  generic map(
    INIT => X"7FFF"
  )
  port map (
    I0 => G0_50_X,
    I1 => n_ahbsi_hmbsel(1),
    I2 => n_ahbsi_hsel(0),
    I3 => n_ahbsi_htrans(1),
    O => N_19);
  II_g0_50_x: LUT3_L
  generic map(
    INIT => X"80"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => WRP_R_PRSTATE(5),
    I2 => WRP_R_SSRSTATE(4),
    LO => G0_50_X);
  II_g0_52: MUXF5 port map (
      I0 => G0_52X,
      I1 => G0_52X_0,
      S => n_ahbsi_htrans(1),
      O => WRP_CTRL_UN1_V_SSRSTATE17_1_XX_MM_N_4);
  II_g0_52_x1: LUT4
  generic map(
    INIT => X"35F5"
  )
  port map (
    I0 => D_M1_E_0_0,
    I1 => n_ahbsi_hmbsel(1),
    I2 => n_ahbsi_hready,
    I3 => n_ahbsi_hsel(0),
    O => G0_52_X1);
  II_g0_52_x0: LUT2
  generic map(
    INIT => X"D"
  )
  port map (
    I0 => D_M1_E_0_0,
    I1 => n_ahbsi_hready,
    O => G0_52_X0);
  II_g1_1: LUT4
  generic map(
    INIT => X"0105"
  )
  port map (
    I0 => SSRSTATE17_2_0_M6_I_A3_A2,
    I1 => n_ahbsi_htrans(1),
    I2 => WRP_UN1_V_SSRSTATE17_2_0_M6_I_1,
    I3 => WRP_UN1_V_SSRSTATE_1_SQMUXA_1_0_M3_0_1,
    O => N_14);
  II_g0_19_L1: LUT4_L
  generic map(
    INIT => X"0001"
  )
  port map (
    I0 => G0_28,
    I1 => WRP_CTRL_UN1_AHBSI,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_V_CHANGE_1_SQMUXA_N_3,
    LO => G0_19_L1);
  II_g0_19: LUT4
  generic map(
    INIT => X"0010"
  )
  port map (
    I0 => G0_19_L1,
    I1 => WRP_R_SSRSTATE(1),
    I2 => WRP_UN1_V_CHANGE_1_SQMUXA_0,
    I3 => WRP_V_SSRSTATE_6_SQMUXA,
    O => N_622);
  II_g0_55_L1: LUT4
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => n_ahbsi_hwrite,
    I3 => WRP_R_SSRSTATE(1),
    O => G0_55_L1);
  II_g0_55: LUT4
  generic map(
    INIT => X"0F0D"
  )
  port map (
    I0 => G0_55_L7,
    I1 => WRP_R_LOADCOUNT,
    I2 => WRP_R_SSRSTATE(3),
    I3 => WRP_V_SSRSTATE_1_SQMUXA_1,
    O => WRP_CTRL_V_LOADCOUNT_7);
  II_g0_34_L1_0: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => WRP_R_D16MUXC_0_4,
    I1 => WRP_V_WS_0_SQMUXA_0_C,
    O => G0_34_L1_0);
  II_g0_34_L6: LUT4
  generic map(
    INIT => X"A2AA"
  )
  port map (
    I0 => G0_34_L1_0,
    I1 => WRP_CTRL_V_HSEL_5,
    I2 => WRP_R_SSRSTATE(0),
    I3 => WRP_V_WS_0_SQMUXA_C,
    O => G0_34_L6);
  II_g0_34: LUT4_L
  generic map(
    INIT => X"51F3"
  )
  port map (
    I0 => G0_34_L6,
    I1 => G0_34_L10,
    I2 => WRP_NONAME_CNST(0),
    I3 => WRP_R_SSRSTATE(1),
    LO => G0_34);
  II_g0_54_L1: LUT4_L
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => n_ahbsi_htrans(0),
    I1 => n_ahbsi_htrans(1),
    I2 => WRP_CTRL_UN1_AHBSI,
    I3 => WRP_CTRL_V_HSEL_5,
    LO => G0_54_L1);
  II_g0_54: LUT4
  generic map(
    INIT => X"2000"
  )
  port map (
    I0 => G0_54_L1,
    I1 => n_ahbsi_hwrite,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_R_SSRSTATE(1),
    O => WRP_CTRL_V_SSRSTATE_1_M1(3));
  II_g0_i_m2_L1: LUT3
  generic map(
    INIT => X"75"
  )
  port map (
    I0 => rst,
    I1 => WRP_R_SSRSTATE(3),
    I2 => WRP_V_SSRSTATE_1_SQMUXA_1,
    O => G0_I_M2_L1);
  II_g0_56: LUT4
  generic map(
    INIT => X"CC5A"
  )
  port map (
    I0 => N_9,
    I1 => WRP_R_MCFG1_ROMRWS(0),
    I2 => WRP_R_WS(0),
    I3 => WRP_V_WS_1_SQMUXA,
    O => G0_56);
  II_g1_3: LUT3_L
  generic map(
    INIT => X"37"
  )
  port map (
    I0 => G0_30,
    I1 => WRP_V_WS_0_SQMUXA_1,
    I2 => WRP_V_WS_3_SQMUXA_1,
    LO => N_9);
  II_g0_30: LUT4
  generic map(
    INIT => X"AEAA"
  )
  port map (
    I0 => N_14,
    I1 => N_19,
    I2 => G0_8,
    I3 => WRP_R_SSRSTATE(4),
    O => G0_30);
  II_g0_16: LUT4
  generic map(
    INIT => X"337F"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_260,
    I1 => rst,
    I2 => WRP_V_WS_2_SQMUXA_0,
    I3 => WRP_V_WS_4_SQMUXA_0,
    O => N_365);
  II_g0_8: LUT4
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => n_ahbsi_hready,
    I1 => WRP_R_HMBSEL(1),
    I2 => WRP_R_HSEL,
    I3 => WRP_R_PRSTATE(5),
    O => G0_8);
  II_g0_i_m2_2: LUT4
  generic map(
    INIT => X"F780"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_260,
    I1 => rst,
    I2 => WRP_R_MCFG1_IOWS(0),
    I3 => WRP_R_MCFG1_ROMWWS(0),
    O => G0_I_M2_2);
  II_g0_7: LUT3
  generic map(
    INIT => X"54"
  )
  port map (
    I0 => N_SRO_IOSN_INT_259,
    I1 => WRP_R_PRSTATE(4),
    I2 => WRP_R_PRSTATE_2_REP1,
    O => WRP_V_WS_2_SQMUXA_0);
  II_g0_6: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => N_SRO_ROMSN_0_INT_260,
    I1 => WRP_R_PRSTATE_FAST(2),
    O => WRP_V_WS_4_SQMUXA_0);
  II_g0_53: LUT4
  generic map(
    INIT => X"1050"
  )
  port map (
    I0 => G0_51,
    I1 => WRP_CTRL_V_HSEL_4,
    I2 => WRP_R_SSRSTATE(4),
    I3 => WRP_V_SSRSTATE_1_SQMUXA_1_XX_MM_A1_0,
    O => WRP_V_SSRSTATE_1_SQMUXA_1);
  II_g0_51: LUT4
  generic map(
    INIT => X"2000"
  )
  port map (
    I0 => G0_8_1,
    I1 => n_ahbsi_hready,
    I2 => WRP_R_HMBSEL(1),
    I3 => WRP_R_HSEL,
    O => G0_51);
  II_g0_50: LUT4
  generic map(
    INIT => X"8000"
  )
  port map (
    I0 => n_ahbsi_hmbsel(1),
    I1 => n_ahbsi_hready,
    I2 => WRP_R_PRSTATE(5),
    I3 => WRP_R_SSRSTATE(4),
    O => WRP_V_SSRSTATE_1_SQMUXA_1_XX_MM_A1_0);
  II_g0_8_1: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => WRP_R_PRSTATE(5),
    I1 => WRP_R_SSRSTATE(4),
    O => G0_8_1);
  II_g0_4: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => WRP_R_HMBSEL(1),
    I1 => WRP_R_HSEL,
    O => D_M1_E_0_0);
  II_g0_3: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => n_ahbsi_hsel(0),
    I1 => n_ahbsi_htrans(1),
    O => WRP_CTRL_V_HSEL_4);
  II_g0_i_0: LUT4
  generic map(
    INIT => X"AA80"
  )
  port map (
    I0 => G0_I_A3_0,
    I1 => rst,
    I2 => WRP_R_PRSTATE(2),
    I3 => WRP_V_BWN_0_SQMUXA_1,
    O => WRP_CTRL_V_BWN_1_0_O3(0));
  II_g0_2: LUT4
  generic map(
    INIT => X"C4CC"
  )
  port map (
    I0 => WRP_CTRL_V_HMBSEL_4(1),
    I1 => SSRSTATE6_XX_MM_M3,
    I2 => WRP_V_CHANGE_1_SQMUXA_N_3,
    I3 => WRP_V_SSRHREADY_2_SQMUXA_0_0,
    O => N_646);
  II_g0_i_a3_0: LUT4_L
  generic map(
    INIT => X"5D7F"
  )
  port map (
    I0 => N_319_1,
    I1 => N_662,
    I2 => n_ahbsi_haddr(0),
    I3 => N_SRO_ADDRESS_0_INT_172,
    LO => G0_I_A3_0);
  II_g0: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662,
    I1 => n_ahbsi_haddr(1),
    I2 => N_SRO_ADDRESS_1_INT_173,
    O => WRP_HADDR(1));
  II_g0_i: LUT4
  generic map(
    INIT => X"F3A2"
  )
  port map (
    I0 => G0_11,
    I1 => n_ahbsi_htrans(0),
    I2 => WRP_CTRL_UN1_V_SSRSTATE17_1_XX_MM_N_4,
    I3 => WRP_R_D16MUXC_0_4,
    O => G0_I);
  II_g0_47: LUT4
  generic map(
    INIT => X"202A"
  )
  port map (
    I0 => rst,
    I1 => WRP_R_D16MUXC_0_4,
    I2 => WRP_R_PRSTATE(1),
    I3 => WRP_R_PRSTATE_2_REP1,
    O => WRP_V_BWN_0_SQMUXA_1);
  II_g0_38: LUT3
  generic map(
    INIT => X"D8"
  )
  port map (
    I0 => N_662,
    I1 => n_ahbsi_hsize(1),
    I2 => WRP_R_SIZE(1),
    O => WRP_CTRL_HSIZE_1(1));
  II_g0_11: LUT2_L
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => WRP_CTRL_UN1_AHBSI,
    I1 => WRP_CTRL_V_HSEL_5,
    LO => G0_11);
  II_g0_44: LUT4
  generic map(
    INIT => X"BBBA"
  )
  port map (
    I0 => G0_5_0,
    I1 => WRP_CTRL_UN7_BUS16EN,
    I2 => WRP_R_PRSTATE(0),
    I3 => WRP_V_D16MUX_0_SQMUXA,
    O => G0_44);
  II_g0_43: LUT4
  generic map(
    INIT => X"0400"
  )
  port map (
    I0 => N_SRO_ADDRESS_1_INT_173,
    I1 => WRP_CTRL_BUS16EN,
    I2 => WRP_R_SIZE(0),
    I3 => WRP_R_SIZE(1),
    O => WRP_CTRL_UN7_BUS16EN);
  II_g0_41: LUT2
  generic map(
    INIT => X"E"
  )
  port map (
    I0 => N_17,
    I1 => WRP_R_CHANGE,
    O => G0_1_0);
  II_g0_5_0: LUT2
  generic map(
    INIT => X"E"
  )
  port map (
    I0 => WRP_R_PRHREADY,
    I1 => WRP_R_PRSTATE(5),
    O => G0_5_0);
  II_g0_40: LUT2
  generic map(
    INIT => X"4"
  )
  port map (
    I0 => WRP_CTRL_UN1_AHBSI,
    I1 => WRP_CTRL_V_HSEL_5,
    O => N_17);
  II_g0_39: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => WRP_R_D16MUXC_0_4,
    I1 => WRP_R_PRSTATE(3),
    O => WRP_V_D16MUX_0_SQMUXA);
  II_g0_18: LUT3
  generic map(
    INIT => X"A2"
  )
  port map (
    I0 => G0_7_0,
    I1 => WRP_CTRL_V_HMBSEL_4(1),
    I2 => WRP_R_CHANGE,
    O => WRP_CTRL_V_CHANGE_3_F1_D_0_0);
  II_g0_17: LUT4
  generic map(
    INIT => X"A808"
  )
  port map (
    I0 => G0_I_M2_1,
    I1 => WRP_CTRL_V_HSEL_5,
    I2 => WRP_R_CHANGE,
    I3 => WRP_R_HSEL,
    O => WRP_UN1_V_HSEL_1(0));
  II_g0_7_0: LUT4
  generic map(
    INIT => X"00FE"
  )
  port map (
    I0 => WRP_R_CHANGE,
    I1 => WRP_R_SSRSTATE(1),
    I2 => WRP_R_SSRSTATE(2),
    I3 => WRP_R_SSRSTATE(4),
    O => G0_7_0);
  II_g0_15: LUT4
  generic map(
    INIT => X"00FE"
  )
  port map (
    I0 => WRP_R_CHANGE,
    I1 => WRP_R_SSRSTATE(1),
    I2 => WRP_R_SSRSTATE(2),
    I3 => WRP_R_SSRSTATE(4),
    O => WRP_CTRL_V_CHANGE_3_F0);
  II_g0_i_m2_1: LUT4
  generic map(
    INIT => X"3353"
  )
  port map (
    I0 => HSEL_1_0_L3,
    I1 => G0_14,
    I2 => n_ahbsi_hready,
    I3 => WRP_R_CHANGE,
    O => G0_I_M2_1);
  II_g0_14: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => WRP_R_HMBSEL(0),
    I1 => WRP_R_HMBSEL(2),
    O => G0_14);
  II_g0_33: LUT4
  generic map(
    INIT => X"085D"
  )
  port map (
    I0 => G0_31,
    I1 => G2_1_0,
    I2 => WRP_R_SSRSTATE(1),
    I3 => WRP_V_CHANGE_1_SQMUXA_N_3,
    O => WRP_UN1_V_CHANGE_1_SQMUXA_0);
  II_g0_32: LUT4
  generic map(
    INIT => X"0001"
  )
  port map (
    I0 => G0_28,
    I1 => WRP_CTRL_UN1_AHBSI,
    I2 => WRP_CTRL_V_HMBSEL_4(1),
    I3 => WRP_V_CHANGE_1_SQMUXA_N_3,
    O => WRP_NONAME_CNST(0));
  II_g0_31: LUT4
  generic map(
    INIT => X"FFAB"
  )
  port map (
    I0 => G0_28,
    I1 => n_ahbsi_htrans(0),
    I2 => n_ahbsi_htrans(1),
    I3 => WRP_R_SSRSTATE(0),
    O => G0_31);
  II_g2_1_0: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => WRP_R_SSRSTATE(0),
    I1 => WRP_R_SSRSTATE(2),
    O => G2_1_0);
  II_g0_29: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => n_ahbsi_hwrite,
    I1 => WRP_V_SSRSTATE_1_SQMUXA_1,
    O => G0_29);
  II_g0_28: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => WRP_R_SSRSTATE(1),
    I1 => WRP_R_SSRSTATE(2),
    O => G0_28);
  II_g0_27: LUT2
  generic map(
    INIT => X"8"
  )
  port map (
    I0 => rst,
    I1 => WRP_R_SSRSTATE(3),
    O => WRP_V_SSRSTATE_2_SQMUXA_1);
  II_g0_25: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => N_365,
    I1 => WRP_V_WS_1_SQMUXA,
    O => G0_25);
  II_g0_23: LUT3
  generic map(
    INIT => X"37"
  )
  port map (
    I0 => G0_30,
    I1 => WRP_V_WS_0_SQMUXA_1,
    I2 => WRP_V_WS_3_SQMUXA_1,
    O => G0_23);
  II_g0_12: LUT2
  generic map(
    INIT => X"1"
  )
  port map (
    I0 => WRP_R_SSRSTATE(0),
    I1 => WRP_R_SSRSTATE(2),
    O => D_M2_0_A2_0);
  II_g0_10: LUT2
  generic map(
    INIT => X"2"
  )
  port map (
    I0 => rst,
    I1 => WRP_R_SSRSTATE(3),
    O => WRP_UN1_V_SSRSTATE_2_SQMUXA_I);
  II_g0_1: LUT4
  generic map(
    INIT => X"FFD5"
  )
  port map (
    I0 => G0_I,
    I1 => rst,
    I2 => WRP_R_PRSTATE(2),
    I3 => WRP_V_LOADCOUNT_1_SQMUXA,
    O => WRP_UN1_V_BWN_1_SQMUXA_2_D_0_2);
  II_N_574_i: LUT4_L
  generic map(
    INIT => X"5545"
  )
  port map (
    I0 => N_593,
    I1 => N_596,
    I2 => D_M1_E_0_0,
    I3 => n_ahbsi_hready,
    LO => N_574_I);
  II_N_574_i_a3_0: LUT4_L
  generic map(
    INIT => X"4000"
  )
  port map (
    I0 => N_597,
    I1 => n_ahbsi_hmbsel(1),
    I2 => n_ahbsi_hready,
    I3 => WRP_CTRL_V_HSEL_4,
    LO => N_593);
  II_N_574_i_o3_0: LUT4
  generic map(
    INIT => X"135F"
  )
  port map (
    I0 => n_ahbsi_htrans(1),
    I1 => WRP_R_PRSTATE(5),
    I2 => WRP_R_SSRSTATE(1),
    I3 => WRP_R_SSRSTATE(4),
    O => N_596);
  II_N_574_i_o3: LUT3
  generic map(
    INIT => X"13"
  )
  port map (
    I0 => WRP_R_PRSTATE(5),
    I1 => WRP_R_SSRSTATE(1),
    I2 => WRP_R_SSRSTATE(4),
    O => N_597);
  II_wrp: ssrctrl_unisim_netlist port map (
      n_sro_vbdrive(0) => n_sro_vbdrive(0),
      n_sro_vbdrive(1) => n_sro_vbdrive(1),
      n_sro_vbdrive(2) => n_sro_vbdrive(2),
      n_sro_vbdrive(3) => n_sro_vbdrive(3),
      n_sro_vbdrive(4) => n_sro_vbdrive(4),
      n_sro_vbdrive(5) => n_sro_vbdrive(5),
      n_sro_vbdrive(6) => n_sro_vbdrive(6),
      n_sro_vbdrive(7) => n_sro_vbdrive(7),
      n_sro_vbdrive(8) => n_sro_vbdrive(8),
      n_sro_vbdrive(9) => n_sro_vbdrive(9),
      n_sro_vbdrive(10) => n_sro_vbdrive(10),
      n_sro_vbdrive(11) => n_sro_vbdrive(11),
      n_sro_vbdrive(12) => n_sro_vbdrive(12),
      n_sro_vbdrive(13) => n_sro_vbdrive(13),
      n_sro_vbdrive(14) => n_sro_vbdrive(14),
      n_sro_vbdrive(15) => n_sro_vbdrive(15),
      n_sro_vbdrive(16) => n_sro_vbdrive(16),
      n_sro_vbdrive(17) => n_sro_vbdrive(17),
      n_sro_vbdrive(18) => n_sro_vbdrive(18),
      n_sro_vbdrive(19) => n_sro_vbdrive(19),
      n_sro_vbdrive(20) => n_sro_vbdrive(20),
      n_sro_vbdrive(21) => n_sro_vbdrive(21),
      n_sro_vbdrive(22) => n_sro_vbdrive(22),
      n_sro_vbdrive(23) => n_sro_vbdrive(23),
      n_sro_vbdrive(24) => n_sro_vbdrive(24),
      n_sro_vbdrive(25) => n_sro_vbdrive(25),
      n_sro_vbdrive(26) => n_sro_vbdrive(26),
      n_sro_vbdrive(27) => n_sro_vbdrive(27),
      n_sro_vbdrive(28) => n_sro_vbdrive(28),
      n_sro_vbdrive(29) => n_sro_vbdrive(29),
      n_sro_vbdrive(30) => n_sro_vbdrive(30),
      n_sro_vbdrive(31) => n_sro_vbdrive(31),
      n_ahbso_hrdata(0) => n_ahbso_hrdata(0),
      n_ahbso_hrdata(1) => n_ahbso_hrdata(1),
      n_ahbso_hrdata(2) => n_ahbso_hrdata(2),
      n_ahbso_hrdata(3) => n_ahbso_hrdata(3),
      n_ahbso_hrdata(4) => n_ahbso_hrdata(4),
      n_ahbso_hrdata(5) => n_ahbso_hrdata(5),
      n_ahbso_hrdata(6) => n_ahbso_hrdata(6),
      n_ahbso_hrdata(7) => n_ahbso_hrdata(7),
      n_ahbso_hrdata(8) => n_ahbso_hrdata(8),
      n_ahbso_hrdata(9) => n_ahbso_hrdata(9),
      n_ahbso_hrdata(10) => n_ahbso_hrdata(10),
      n_ahbso_hrdata(11) => n_ahbso_hrdata(11),
      n_ahbso_hrdata(12) => n_ahbso_hrdata(12),
      n_ahbso_hrdata(13) => n_ahbso_hrdata(13),
      n_ahbso_hrdata(14) => n_ahbso_hrdata(14),
      n_ahbso_hrdata(15) => n_ahbso_hrdata(15),
      n_ahbso_hrdata(16) => n_ahbso_hrdata(16),
      n_ahbso_hrdata(17) => n_ahbso_hrdata(17),
      n_ahbso_hrdata(18) => n_ahbso_hrdata(18),
      n_ahbso_hrdata(19) => n_ahbso_hrdata(19),
      n_ahbso_hrdata(20) => n_ahbso_hrdata(20),
      n_ahbso_hrdata(21) => n_ahbso_hrdata(21),
      n_ahbso_hrdata(22) => n_ahbso_hrdata(22),
      n_ahbso_hrdata(23) => n_ahbso_hrdata(23),
      n_ahbso_hrdata(24) => n_ahbso_hrdata(24),
      n_ahbso_hrdata(25) => n_ahbso_hrdata(25),
      n_ahbso_hrdata(26) => n_ahbso_hrdata(26),
      n_ahbso_hrdata(27) => n_ahbso_hrdata(27),
      n_ahbso_hrdata(28) => n_ahbso_hrdata(28),
      n_ahbso_hrdata(29) => n_ahbso_hrdata(29),
      n_ahbso_hrdata(30) => n_ahbso_hrdata(30),
      n_ahbso_hrdata(31) => n_ahbso_hrdata(31),
      iows_0 => WRP_R_MCFG1_IOWS(0),
      iows_3 => WRP_R_MCFG1_IOWS(3),
      romwws_0 => WRP_R_MCFG1_ROMWWS(0),
      romwws_3 => WRP_R_MCFG1_ROMWWS(3),
      romrws_0 => WRP_R_MCFG1_ROMRWS(0),
      romrws_3 => WRP_R_MCFG1_ROMRWS(3),
      NoName_cnst(0) => WRP_NONAME_CNST(0),
      n_sri_bwidth(0) => n_sri_bwidth(0),
      n_sri_bwidth(1) => n_sri_bwidth(1),
      n_apbi_pwdata_19 => n_apbi_pwdata(19),
      n_apbi_pwdata_11 => n_apbi_pwdata(11),
      n_apbi_pwdata_9 => n_apbi_pwdata(9),
      n_apbi_pwdata_8 => n_apbi_pwdata(8),
      n_apbi_pwdata_23 => n_apbi_pwdata(23),
      n_apbi_pwdata_22 => n_apbi_pwdata(22),
      n_apbi_pwdata_21 => n_apbi_pwdata(21),
      n_apbi_pwdata_20 => n_apbi_pwdata(20),
      n_apbi_pwdata_3 => n_apbi_pwdata(3),
      n_apbi_pwdata_2 => n_apbi_pwdata(2),
      n_apbi_pwdata_1 => n_apbi_pwdata(1),
      n_apbi_pwdata_0 => n_apbi_pwdata(0),
      n_apbi_pwdata_7 => n_apbi_pwdata(7),
      n_apbi_pwdata_6 => n_apbi_pwdata(6),
      n_apbi_pwdata_5 => n_apbi_pwdata(5),
      n_apbi_pwdata_4 => n_apbi_pwdata(4),
      n_apbi_psel(0) => n_apbi_psel(0),
      n_apbi_paddr(2) => n_apbi_paddr(2),
      n_apbi_paddr(3) => n_apbi_paddr(3),
      n_apbi_paddr(4) => n_apbi_paddr(4),
      n_apbi_paddr(5) => n_apbi_paddr(5),
      n_apbo_prdata_0 => n_apbo_prdata(0),
      n_apbo_prdata_4 => n_apbo_prdata(4),
      n_apbo_prdata_20 => n_apbo_prdata(20),
      n_apbo_prdata_23 => n_apbo_prdata(23),
      n_apbo_prdata_22 => n_apbo_prdata(22),
      n_apbo_prdata_21 => n_apbo_prdata(21),
      n_apbo_prdata_19 => n_apbo_prdata(19),
      n_apbo_prdata_7 => n_apbo_prdata(7),
      n_apbo_prdata_6 => n_apbo_prdata(6),
      n_apbo_prdata_5 => n_apbo_prdata(5),
      n_apbo_prdata_3 => n_apbo_prdata(3),
      n_apbo_prdata_2 => n_apbo_prdata(2),
      n_apbo_prdata_1 => n_apbo_prdata(1),
      n_apbo_prdata_11 => n_apbo_prdata(11),
      n_apbo_prdata_9 => n_apbo_prdata(9),
      n_apbo_prdata_8 => n_apbo_prdata(8),
      n_apbo_prdata_28 => n_apbo_prdata(28),
      n_sro_romsn(0) => N_SRO_ROMSN_0_INT_260,
      n_ahbsi_hsel(0) => n_ahbsi_hsel(0),
      prstate_fast(2) => WRP_R_PRSTATE_FAST(2),
      n_ahbsi_htrans(0) => n_ahbsi_htrans(0),
      n_ahbsi_htrans(1) => n_ahbsi_htrans(1),
      ssrstate_1_m1(3) => WRP_CTRL_V_SSRSTATE_1_M1(3),
      ssrstate_1_m1(4) => WRP_CTRL_V_SSRSTATE_1_M1(4),
      hsel_1(0) => WRP_UN1_V_HSEL_1(0),
      hmbsel_4(1) => WRP_CTRL_V_HMBSEL_4(1),
      n_sro_bdrive(3) => N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272,
      ws_1_0 => WRP_CTRL_V_WS_1(0),
      ws_1_3 => WRP_CTRL_V_WS_1(3),
      ws(0) => WRP_R_WS(0),
      ws(1) => WRP_R_WS(1),
      ws(2) => WRP_R_WS(2),
      ws(3) => WRP_R_WS(3),
      ssrstate_1_2 => WRP_CTRL_V_SSRSTATE_1(4),
      n_ahbsi_haddr(0) => n_ahbsi_haddr(0),
      n_ahbsi_haddr(1) => n_ahbsi_haddr(1),
      n_ahbsi_haddr(2) => n_ahbsi_haddr(2),
      n_ahbsi_haddr(3) => n_ahbsi_haddr(3),
      n_ahbsi_haddr(4) => n_ahbsi_haddr(4),
      n_ahbsi_haddr(5) => n_ahbsi_haddr(5),
      n_ahbsi_haddr(6) => n_ahbsi_haddr(6),
      n_ahbsi_haddr(7) => n_ahbsi_haddr(7),
      n_ahbsi_haddr(8) => n_ahbsi_haddr(8),
      n_ahbsi_haddr(9) => n_ahbsi_haddr(9),
      n_ahbsi_haddr(10) => n_ahbsi_haddr(10),
      n_ahbsi_haddr(11) => n_ahbsi_haddr(11),
      n_ahbsi_haddr(12) => n_ahbsi_haddr(12),
      n_ahbsi_haddr(13) => n_ahbsi_haddr(13),
      n_ahbsi_haddr(14) => n_ahbsi_haddr(14),
      n_ahbsi_haddr(15) => n_ahbsi_haddr(15),
      n_ahbsi_haddr(16) => n_ahbsi_haddr(16),
      n_ahbsi_haddr(17) => n_ahbsi_haddr(17),
      n_ahbsi_haddr(18) => n_ahbsi_haddr(18),
      n_ahbsi_haddr(19) => n_ahbsi_haddr(19),
      n_ahbsi_haddr(20) => n_ahbsi_haddr(20),
      n_ahbsi_haddr(21) => n_ahbsi_haddr(21),
      n_ahbsi_haddr(22) => n_ahbsi_haddr(22),
      n_ahbsi_haddr(23) => n_ahbsi_haddr(23),
      n_ahbsi_haddr(24) => n_ahbsi_haddr(24),
      n_ahbsi_haddr(25) => n_ahbsi_haddr(25),
      n_ahbsi_haddr(26) => n_ahbsi_haddr(26),
      n_ahbsi_haddr(27) => n_ahbsi_haddr(27),
      n_ahbsi_haddr(28) => n_ahbsi_haddr(28),
      n_ahbsi_haddr(29) => n_ahbsi_haddr(29),
      n_ahbsi_haddr(30) => n_ahbsi_haddr(30),
      n_ahbsi_haddr(31) => n_ahbsi_haddr(31),
      n_ahbsi_hmbsel(0) => n_ahbsi_hmbsel(0),
      n_ahbsi_hmbsel(1) => n_ahbsi_hmbsel(1),
      n_ahbsi_hmbsel(2) => n_ahbsi_hmbsel(2),
      n_sri_data(0) => n_sri_data(0),
      n_sri_data(1) => n_sri_data(1),
      n_sri_data(2) => n_sri_data(2),
      n_sri_data(3) => n_sri_data(3),
      n_sri_data(4) => n_sri_data(4),
      n_sri_data(5) => n_sri_data(5),
      n_sri_data(6) => n_sri_data(6),
      n_sri_data(7) => n_sri_data(7),
      n_sri_data(8) => n_sri_data(8),
      n_sri_data(9) => n_sri_data(9),
      n_sri_data(10) => n_sri_data(10),
      n_sri_data(11) => n_sri_data(11),
      n_sri_data(12) => n_sri_data(12),
      n_sri_data(13) => n_sri_data(13),
      n_sri_data(14) => n_sri_data(14),
      n_sri_data(15) => n_sri_data(15),
      n_sri_data(16) => n_sri_data(16),
      n_sri_data(17) => n_sri_data(17),
      n_sri_data(18) => n_sri_data(18),
      n_sri_data(19) => n_sri_data(19),
      n_sri_data(20) => n_sri_data(20),
      n_sri_data(21) => n_sri_data(21),
      n_sri_data(22) => n_sri_data(22),
      n_sri_data(23) => n_sri_data(23),
      n_sri_data(24) => n_sri_data(24),
      n_sri_data(25) => n_sri_data(25),
      n_sri_data(26) => n_sri_data(26),
      n_sri_data(27) => n_sri_data(27),
      n_sri_data(28) => n_sri_data(28),
      n_sri_data(29) => n_sri_data(29),
      n_sri_data(30) => n_sri_data(30),
      n_sri_data(31) => n_sri_data(31),
      ssrstate(0) => WRP_R_SSRSTATE(0),
      ssrstate(1) => WRP_R_SSRSTATE(1),
      ssrstate(2) => WRP_R_SSRSTATE(2),
      ssrstate(3) => WRP_R_SSRSTATE(3),
      ssrstate(4) => WRP_R_SSRSTATE(4),
      n_ahbsi_hwdata(0) => n_ahbsi_hwdata(0),
      n_ahbsi_hwdata(1) => n_ahbsi_hwdata(1),
      n_ahbsi_hwdata(2) => n_ahbsi_hwdata(2),
      n_ahbsi_hwdata(3) => n_ahbsi_hwdata(3),
      n_ahbsi_hwdata(4) => n_ahbsi_hwdata(4),
      n_ahbsi_hwdata(5) => n_ahbsi_hwdata(5),
      n_ahbsi_hwdata(6) => n_ahbsi_hwdata(6),
      n_ahbsi_hwdata(7) => n_ahbsi_hwdata(7),
      n_ahbsi_hwdata(8) => n_ahbsi_hwdata(8),
      n_ahbsi_hwdata(9) => n_ahbsi_hwdata(9),
      n_ahbsi_hwdata(10) => n_ahbsi_hwdata(10),
      n_ahbsi_hwdata(11) => n_ahbsi_hwdata(11),
      n_ahbsi_hwdata(12) => n_ahbsi_hwdata(12),
      n_ahbsi_hwdata(13) => n_ahbsi_hwdata(13),
      n_ahbsi_hwdata(14) => n_ahbsi_hwdata(14),
      n_ahbsi_hwdata(15) => n_ahbsi_hwdata(15),
      n_ahbsi_hwdata(16) => n_ahbsi_hwdata(16),
      n_ahbsi_hwdata(17) => n_ahbsi_hwdata(17),
      n_ahbsi_hwdata(18) => n_ahbsi_hwdata(18),
      n_ahbsi_hwdata(19) => n_ahbsi_hwdata(19),
      n_ahbsi_hwdata(20) => n_ahbsi_hwdata(20),
      n_ahbsi_hwdata(21) => n_ahbsi_hwdata(21),
      n_ahbsi_hwdata(22) => n_ahbsi_hwdata(22),
      n_ahbsi_hwdata(23) => n_ahbsi_hwdata(23),
      n_ahbsi_hwdata(24) => n_ahbsi_hwdata(24),
      n_ahbsi_hwdata(25) => n_ahbsi_hwdata(25),
      n_ahbsi_hwdata(26) => n_ahbsi_hwdata(26),
      n_ahbsi_hwdata(27) => n_ahbsi_hwdata(27),
      n_ahbsi_hwdata(28) => n_ahbsi_hwdata(28),
      n_ahbsi_hwdata(29) => n_ahbsi_hwdata(29),
      n_ahbsi_hwdata(30) => n_ahbsi_hwdata(30),
      n_ahbsi_hwdata(31) => n_ahbsi_hwdata(31),
      n_ahbsi_hsize(0) => n_ahbsi_hsize(0),
      n_ahbsi_hsize(1) => n_ahbsi_hsize(1),
      size(0) => WRP_R_SIZE(0),
      size(1) => WRP_R_SIZE(1),
      n_sro_data(0) => n_sro_data(0),
      n_sro_data(1) => n_sro_data(1),
      n_sro_data(2) => n_sro_data(2),
      n_sro_data(3) => n_sro_data(3),
      n_sro_data(4) => n_sro_data(4),
      n_sro_data(5) => n_sro_data(5),
      n_sro_data(6) => n_sro_data(6),
      n_sro_data(7) => n_sro_data(7),
      n_sro_data(8) => n_sro_data(8),
      n_sro_data(9) => n_sro_data(9),
      n_sro_data(10) => n_sro_data(10),
      n_sro_data(11) => n_sro_data(11),
      n_sro_data(12) => n_sro_data(12),
      n_sro_data(13) => n_sro_data(13),
      n_sro_data(14) => n_sro_data(14),
      n_sro_data(15) => n_sro_data(15),
      n_sro_data(16) => n_sro_data(16),
      n_sro_data(17) => n_sro_data(17),
      n_sro_data(18) => n_sro_data(18),
      n_sro_data(19) => n_sro_data(19),
      n_sro_data(20) => n_sro_data(20),
      n_sro_data(21) => n_sro_data(21),
      n_sro_data(22) => n_sro_data(22),
      n_sro_data(23) => n_sro_data(23),
      n_sro_data(24) => n_sro_data(24),
      n_sro_data(25) => n_sro_data(25),
      n_sro_data(26) => n_sro_data(26),
      n_sro_data(27) => n_sro_data(27),
      n_sro_data(28) => n_sro_data(28),
      n_sro_data(29) => n_sro_data(29),
      n_sro_data(30) => n_sro_data(30),
      n_sro_data(31) => n_sro_data(31),
      n_sro_ramsn(0) => n_sro_ramsn(0),
      n_sro_wrn(0) => n_sro_wrn(0),
      n_sro_wrn(1) => n_sro_wrn(1),
      n_sro_wrn(2) => n_sro_wrn(2),
      n_sro_wrn(3) => n_sro_wrn(3),
      haddr_0 => WRP_HADDR(1),
      bwn_1_0_o3_0 => WRP_CTRL_V_BWN_1_0_O3(0),
      hsize_1(1) => WRP_CTRL_HSIZE_1(1),
      prstate_1_i_o4_s(2) => WRP_V_PRSTATE_1_I_O4_S(2),
      prstate(0) => WRP_R_PRSTATE(0),
      prstate(1) => WRP_R_PRSTATE(1),
      prstate(2) => WRP_R_PRSTATE(2),
      prstate(3) => WRP_R_PRSTATE(3),
      prstate(4) => WRP_R_PRSTATE(4),
      prstate(5) => WRP_R_PRSTATE(5),
      hmbsel(0) => WRP_R_HMBSEL(0),
      hmbsel(1) => WRP_R_HMBSEL(1),
      hmbsel(2) => WRP_R_HMBSEL(2),
      n_sro_address(0) => N_SRO_ADDRESS_0_INT_172,
      n_sro_address(1) => N_SRO_ADDRESS_1_INT_173,
      n_sro_address(2) => n_sro_address(2),
      n_sro_address(3) => n_sro_address(3),
      n_sro_address(4) => n_sro_address(4),
      n_sro_address(5) => n_sro_address(5),
      n_sro_address(6) => n_sro_address(6),
      n_sro_address(7) => n_sro_address(7),
      n_sro_address(8) => n_sro_address(8),
      n_sro_address(9) => n_sro_address(9),
      n_sro_address(10) => n_sro_address(10),
      n_sro_address(11) => n_sro_address(11),
      n_sro_address(12) => n_sro_address(12),
      n_sro_address(13) => n_sro_address(13),
      n_sro_address(14) => n_sro_address(14),
      n_sro_address(15) => n_sro_address(15),
      n_sro_address(16) => n_sro_address(16),
      n_sro_address(17) => n_sro_address(17),
      n_sro_address(18) => n_sro_address(18),
      n_sro_address(19) => n_sro_address(19),
      n_sro_address(20) => n_sro_address(20),
      n_sro_address(21) => n_sro_address(21),
      n_sro_address(22) => n_sro_address(22),
      n_sro_address(23) => n_sro_address(23),
      n_sro_address(24) => n_sro_address(24),
      n_sro_address(25) => n_sro_address(25),
      n_sro_address(26) => n_sro_address(26),
      n_sro_address(27) => n_sro_address(27),
      n_sro_address(28) => n_sro_address(28),
      n_sro_address(29) => n_sro_address(29),
      n_sro_address(30) => n_sro_address(30),
      n_sro_address(31) => n_sro_address(31),
      hready_2 => WRP_CTRL_V_HREADY_2,
      n_ahbso_hready => n_ahbso_hready,
      ssrhready_8 => WRP_CTRL_V_SSRHREADY_8,
      loadcount => WRP_R_LOADCOUNT,
      n_sro_writen => n_sro_writen,
      ssrstatec => WRP_R_SSRSTATEC,
      prhready => WRP_R_PRHREADY,
      d_m2_0_a2_0 => D_M2_0_A2_0,
      ssrstate17_2_0_m6_i_a3_a2 => SSRSTATE17_2_0_M6_I_A3_A2,
      N_319_1 => N_319_1,
      ws_0_sqmuxa_c => WRP_V_WS_0_SQMUXA_C,
      N_365 => N_365,
      ws_0_sqmuxa_0_c => WRP_V_WS_0_SQMUXA_0_C,
      ws_2_sqmuxa_3_0_4 => WRP_V_WS_2_SQMUXA_3_0_4,
      change_1_sqmuxa_0 => WRP_UN1_V_CHANGE_1_SQMUXA_0,
      d16mux_0_sqmuxa => WRP_V_D16MUX_0_SQMUXA,
      ssrstate_2_sqmuxa_1 => WRP_V_SSRSTATE_2_SQMUXA_1,
      un7_bus16en => WRP_CTRL_UN7_BUS16EN,
      N_646 => N_646,
      loadcount_1_sqmuxa => WRP_V_LOADCOUNT_1_SQMUXA,
      ssrstate_1_sqmuxa_1_0_m3_0_1 => WRP_UN1_V_SSRSTATE_1_SQMUXA_1_0_M3_0_1,
      n_apbi_penable => n_apbi_penable,
      n_apbi_pwrite => n_apbi_pwrite,
      d_m1_e_0_0 => D_M1_E_0_0,
      hsel_1_0_L3 => HSEL_1_0_L3,
      ssrhready_8_f0_L8 => SSRHREADY_8_F0_L8,
      ssrstate_1_sqmuxa_1 => WRP_V_SSRSTATE_1_SQMUXA_1,
      ssrhready => WRP_R_SSRHREADY,
      ssrhready_8_f0_L5 => SSRHREADY_8_F0_L5,
      ssrstate17_1_xx_mm_N_4 => WRP_CTRL_UN1_V_SSRSTATE17_1_XX_MM_N_4,
      ws_1_sqmuxa => WRP_V_WS_1_SQMUXA,
      ws_4_sqmuxa_0 => WRP_V_WS_4_SQMUXA_0,
      ws_2_sqmuxa_0 => WRP_V_WS_2_SQMUXA_0,
      ssrstate17_2_0_m6_i_1 => WRP_UN1_V_SSRSTATE17_2_0_M6_I_1,
      ws_2_sqmuxa_3_0_x => WS_2_SQMUXA_3_0_X,
      ws_3_sqmuxa_1 => WRP_V_WS_3_SQMUXA_1,
      ws_2_sqmuxa_3_0_2 => WRP_V_WS_2_SQMUXA_3_0_2,
      ssrstate_2_i => WRP_UN1_R_SSRSTATE_2_I,
      ws_2_sqmuxa_3_d => WRP_V_WS_2_SQMUXA_3_D,
      ws_0_sqmuxa_1 => WRP_V_WS_0_SQMUXA_1,
      g0_30 => G0_30,
      hsel_4 => WRP_CTRL_V_HSEL_4,
      n_ahbsi_hready => n_ahbsi_hready,
      hsel => WRP_R_HSEL,
      g0_25 => G0_25,
      bwn_0_sqmuxa_1 => WRP_V_BWN_0_SQMUXA_1,
      prstate_2_rep1 => WRP_R_PRSTATE_2_REP1,
      N_662 => N_662,
      ssrstate_6_sqmuxa => WRP_V_SSRSTATE_6_SQMUXA,
      g0_52_x1 => G0_52_X1,
      g0_52_x0 => G0_52_X0,
      ssrhready_2_sqmuxa_0_0 => WRP_V_SSRHREADY_2_SQMUXA_0_0,
      change_1_sqmuxa_N_3 => WRP_V_CHANGE_1_SQMUXA_N_3,
      ssrstate6_xx_mm_m3 => SSRSTATE6_XX_MM_M3,
      ssrstate6_1_d_0_L1 => SSRSTATE6_1_D_0_L1,
      N_656 => N_656,
      hsel_5 => WRP_CTRL_V_HSEL_5,
      change_3_f0 => WRP_CTRL_V_CHANGE_3_F0,
      un1_ahbsi => WRP_CTRL_UN1_AHBSI,
      change => WRP_R_CHANGE,
      n_ahbsi_hwrite => n_ahbsi_hwrite,
      N_574_i => N_574_I,
      n_sro_iosn => N_SRO_IOSN_INT_259,
      N_618_i => N_618_I,
      clk => clk,
      n_sro_oen => N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268,
      rst => rst,
      bwn_1_sqmuxa_2_d => WRP_UN1_V_BWN_1_SQMUXA_2_D,
      bwn_1_sqmuxa_2_d_0_2 => WRP_UN1_V_BWN_1_SQMUXA_2_D_0_2,
      ssrstate_2_sqmuxa_i => WRP_UN1_V_SSRSTATE_2_SQMUXA_I,
      g0_23 => G0_23,
      N_371 => N_371,
      loadcount_7 => WRP_CTRL_V_LOADCOUNT_7,
      bus16en => WRP_CTRL_BUS16EN,
      d16muxc_0_4 => WRP_R_D16MUXC_0_4,
      change_3_f1_d_0_0 => WRP_CTRL_V_CHANGE_3_F1_D_0_0,
      g0_1_0 => G0_1_0,
      g0_44 => G0_44);
  II_GND: GND port map (
      G => NN_2);
  II_VCC: VCC port map (
      P => NN_1);
  n_ahbso_hresp(0) <= NN_2;
  n_ahbso_hresp(1) <= NN_2;
  n_ahbso_hsplit(0) <= NN_2;
  n_ahbso_hsplit(1) <= NN_2;
  n_ahbso_hsplit(2) <= NN_2;
  n_ahbso_hsplit(3) <= NN_2;
  n_ahbso_hsplit(4) <= NN_2;
  n_ahbso_hsplit(5) <= NN_2;
  n_ahbso_hsplit(6) <= NN_2;
  n_ahbso_hsplit(7) <= NN_2;
  n_ahbso_hsplit(8) <= NN_2;
  n_ahbso_hsplit(9) <= NN_2;
  n_ahbso_hsplit(10) <= NN_2;
  n_ahbso_hsplit(11) <= NN_2;
  n_ahbso_hsplit(12) <= NN_2;
  n_ahbso_hsplit(13) <= NN_2;
  n_ahbso_hsplit(14) <= NN_2;
  n_ahbso_hsplit(15) <= NN_2;
  n_ahbso_hcache <= NN_1;
  n_ahbso_hirq(0) <= NN_2;
  n_ahbso_hirq(1) <= NN_2;
  n_ahbso_hirq(2) <= NN_2;
  n_ahbso_hirq(3) <= NN_2;
  n_ahbso_hirq(4) <= NN_2;
  n_ahbso_hirq(5) <= NN_2;
  n_ahbso_hirq(6) <= NN_2;
  n_ahbso_hirq(7) <= NN_2;
  n_ahbso_hirq(8) <= NN_2;
  n_ahbso_hirq(9) <= NN_2;
  n_ahbso_hirq(10) <= NN_2;
  n_ahbso_hirq(11) <= NN_2;
  n_ahbso_hirq(12) <= NN_2;
  n_ahbso_hirq(13) <= NN_2;
  n_ahbso_hirq(14) <= NN_2;
  n_ahbso_hirq(15) <= NN_2;
  n_ahbso_hirq(16) <= NN_2;
  n_ahbso_hirq(17) <= NN_2;
  n_ahbso_hirq(18) <= NN_2;
  n_ahbso_hirq(19) <= NN_2;
  n_ahbso_hirq(20) <= NN_2;
  n_ahbso_hirq(21) <= NN_2;
  n_ahbso_hirq(22) <= NN_2;
  n_ahbso_hirq(23) <= NN_2;
  n_ahbso_hirq(24) <= NN_2;
  n_ahbso_hirq(25) <= NN_2;
  n_ahbso_hirq(26) <= NN_2;
  n_ahbso_hirq(27) <= NN_2;
  n_ahbso_hirq(28) <= NN_2;
  n_ahbso_hirq(29) <= NN_2;
  n_ahbso_hirq(30) <= NN_2;
  n_ahbso_hirq(31) <= NN_2;
  n_apbo_prdata(10) <= NN_2;
  n_apbo_prdata(12) <= NN_2;
  n_apbo_prdata(13) <= NN_2;
  n_apbo_prdata(14) <= NN_2;
  n_apbo_prdata(15) <= NN_2;
  n_apbo_prdata(16) <= NN_2;
  n_apbo_prdata(17) <= NN_2;
  n_apbo_prdata(18) <= NN_2;
  n_apbo_prdata(24) <= NN_2;
  n_apbo_prdata(25) <= NN_2;
  n_apbo_prdata(26) <= NN_2;
  n_apbo_prdata(27) <= NN_2;
  n_apbo_prdata(29) <= NN_2;
  n_apbo_prdata(30) <= NN_2;
  n_apbo_prdata(31) <= NN_2;
  n_apbo_pirq(0) <= NN_2;
  n_apbo_pirq(1) <= NN_2;
  n_apbo_pirq(2) <= NN_2;
  n_apbo_pirq(3) <= NN_2;
  n_apbo_pirq(4) <= NN_2;
  n_apbo_pirq(5) <= NN_2;
  n_apbo_pirq(6) <= NN_2;
  n_apbo_pirq(7) <= NN_2;
  n_apbo_pirq(8) <= NN_2;
  n_apbo_pirq(9) <= NN_2;
  n_apbo_pirq(10) <= NN_2;
  n_apbo_pirq(11) <= NN_2;
  n_apbo_pirq(12) <= NN_2;
  n_apbo_pirq(13) <= NN_2;
  n_apbo_pirq(14) <= NN_2;
  n_apbo_pirq(15) <= NN_2;
  n_apbo_pirq(16) <= NN_2;
  n_apbo_pirq(17) <= NN_2;
  n_apbo_pirq(18) <= NN_2;
  n_apbo_pirq(19) <= NN_2;
  n_apbo_pirq(20) <= NN_2;
  n_apbo_pirq(21) <= NN_2;
  n_apbo_pirq(22) <= NN_2;
  n_apbo_pirq(23) <= NN_2;
  n_apbo_pirq(24) <= NN_2;
  n_apbo_pirq(25) <= NN_2;
  n_apbo_pirq(26) <= NN_2;
  n_apbo_pirq(27) <= NN_2;
  n_apbo_pirq(28) <= NN_2;
  n_apbo_pirq(29) <= NN_2;
  n_apbo_pirq(30) <= NN_2;
  n_apbo_pirq(31) <= NN_2;
  n_sro_address(0) <= N_SRO_ADDRESS_0_INT_172;
  n_sro_address(1) <= N_SRO_ADDRESS_1_INT_173;
  n_sro_sddata(0) <= NN_2;
  n_sro_sddata(1) <= NN_2;
  n_sro_sddata(2) <= NN_2;
  n_sro_sddata(3) <= NN_2;
  n_sro_sddata(4) <= NN_2;
  n_sro_sddata(5) <= NN_2;
  n_sro_sddata(6) <= NN_2;
  n_sro_sddata(7) <= NN_2;
  n_sro_sddata(8) <= NN_2;
  n_sro_sddata(9) <= NN_2;
  n_sro_sddata(10) <= NN_2;
  n_sro_sddata(11) <= NN_2;
  n_sro_sddata(12) <= NN_2;
  n_sro_sddata(13) <= NN_2;
  n_sro_sddata(14) <= NN_2;
  n_sro_sddata(15) <= NN_2;
  n_sro_sddata(16) <= NN_2;
  n_sro_sddata(17) <= NN_2;
  n_sro_sddata(18) <= NN_2;
  n_sro_sddata(19) <= NN_2;
  n_sro_sddata(20) <= NN_2;
  n_sro_sddata(21) <= NN_2;
  n_sro_sddata(22) <= NN_2;
  n_sro_sddata(23) <= NN_2;
  n_sro_sddata(24) <= NN_2;
  n_sro_sddata(25) <= NN_2;
  n_sro_sddata(26) <= NN_2;
  n_sro_sddata(27) <= NN_2;
  n_sro_sddata(28) <= NN_2;
  n_sro_sddata(29) <= NN_2;
  n_sro_sddata(30) <= NN_2;
  n_sro_sddata(31) <= NN_2;
  n_sro_sddata(32) <= NN_2;
  n_sro_sddata(33) <= NN_2;
  n_sro_sddata(34) <= NN_2;
  n_sro_sddata(35) <= NN_2;
  n_sro_sddata(36) <= NN_2;
  n_sro_sddata(37) <= NN_2;
  n_sro_sddata(38) <= NN_2;
  n_sro_sddata(39) <= NN_2;
  n_sro_sddata(40) <= NN_2;
  n_sro_sddata(41) <= NN_2;
  n_sro_sddata(42) <= NN_2;
  n_sro_sddata(43) <= NN_2;
  n_sro_sddata(44) <= NN_2;
  n_sro_sddata(45) <= NN_2;
  n_sro_sddata(46) <= NN_2;
  n_sro_sddata(47) <= NN_2;
  n_sro_sddata(48) <= NN_2;
  n_sro_sddata(49) <= NN_2;
  n_sro_sddata(50) <= NN_2;
  n_sro_sddata(51) <= NN_2;
  n_sro_sddata(52) <= NN_2;
  n_sro_sddata(53) <= NN_2;
  n_sro_sddata(54) <= NN_2;
  n_sro_sddata(55) <= NN_2;
  n_sro_sddata(56) <= NN_2;
  n_sro_sddata(57) <= NN_2;
  n_sro_sddata(58) <= NN_2;
  n_sro_sddata(59) <= NN_2;
  n_sro_sddata(60) <= NN_2;
  n_sro_sddata(61) <= NN_2;
  n_sro_sddata(62) <= NN_2;
  n_sro_sddata(63) <= NN_2;
  n_sro_ramsn(1) <= NN_1;
  n_sro_ramsn(2) <= NN_1;
  n_sro_ramsn(3) <= NN_1;
  n_sro_ramsn(4) <= NN_1;
  n_sro_ramsn(5) <= NN_1;
  n_sro_ramsn(6) <= NN_1;
  n_sro_ramsn(7) <= NN_1;
  n_sro_ramoen(0) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(1) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(2) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(3) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(4) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(5) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(6) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramoen(7) <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_ramn <= NN_2;
  n_sro_romn <= NN_2;
  n_sro_mben(0) <= NN_2;
  n_sro_mben(1) <= NN_2;
  n_sro_mben(2) <= NN_2;
  n_sro_mben(3) <= NN_2;
  n_sro_iosn <= N_SRO_IOSN_INT_259;
  n_sro_romsn(0) <= N_SRO_ROMSN_0_INT_260;
  n_sro_romsn(1) <= NN_1;
  n_sro_romsn(2) <= NN_1;
  n_sro_romsn(3) <= NN_1;
  n_sro_romsn(4) <= NN_1;
  n_sro_romsn(5) <= NN_1;
  n_sro_romsn(6) <= NN_1;
  n_sro_romsn(7) <= NN_1;
  n_sro_oen <= N_SRO_OEN_INT_245_INT_246_INT_247_INT_248_INT_249_INT_250_INT_251_INT_252_INT_268;
  n_sro_bdrive(0) <= N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272;
  n_sro_bdrive(1) <= N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272;
  n_sro_bdrive(2) <= N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272;
  n_sro_bdrive(3) <= N_SRO_BDRIVE_3_INT_269_INT_270_INT_271_INT_272;
  n_sro_svbdrive(0) <= NN_2;
  n_sro_svbdrive(1) <= NN_2;
  n_sro_svbdrive(2) <= NN_2;
  n_sro_svbdrive(3) <= NN_2;
  n_sro_svbdrive(4) <= NN_2;
  n_sro_svbdrive(5) <= NN_2;
  n_sro_svbdrive(6) <= NN_2;
  n_sro_svbdrive(7) <= NN_2;
  n_sro_svbdrive(8) <= NN_2;
  n_sro_svbdrive(9) <= NN_2;
  n_sro_svbdrive(10) <= NN_2;
  n_sro_svbdrive(11) <= NN_2;
  n_sro_svbdrive(12) <= NN_2;
  n_sro_svbdrive(13) <= NN_2;
  n_sro_svbdrive(14) <= NN_2;
  n_sro_svbdrive(15) <= NN_2;
  n_sro_svbdrive(16) <= NN_2;
  n_sro_svbdrive(17) <= NN_2;
  n_sro_svbdrive(18) <= NN_2;
  n_sro_svbdrive(19) <= NN_2;
  n_sro_svbdrive(20) <= NN_2;
  n_sro_svbdrive(21) <= NN_2;
  n_sro_svbdrive(22) <= NN_2;
  n_sro_svbdrive(23) <= NN_2;
  n_sro_svbdrive(24) <= NN_2;
  n_sro_svbdrive(25) <= NN_2;
  n_sro_svbdrive(26) <= NN_2;
  n_sro_svbdrive(27) <= NN_2;
  n_sro_svbdrive(28) <= NN_2;
  n_sro_svbdrive(29) <= NN_2;
  n_sro_svbdrive(30) <= NN_2;
  n_sro_svbdrive(31) <= NN_2;
  n_sro_svbdrive(32) <= NN_2;
  n_sro_svbdrive(33) <= NN_2;
  n_sro_svbdrive(34) <= NN_2;
  n_sro_svbdrive(35) <= NN_2;
  n_sro_svbdrive(36) <= NN_2;
  n_sro_svbdrive(37) <= NN_2;
  n_sro_svbdrive(38) <= NN_2;
  n_sro_svbdrive(39) <= NN_2;
  n_sro_svbdrive(40) <= NN_2;
  n_sro_svbdrive(41) <= NN_2;
  n_sro_svbdrive(42) <= NN_2;
  n_sro_svbdrive(43) <= NN_2;
  n_sro_svbdrive(44) <= NN_2;
  n_sro_svbdrive(45) <= NN_2;
  n_sro_svbdrive(46) <= NN_2;
  n_sro_svbdrive(47) <= NN_2;
  n_sro_svbdrive(48) <= NN_2;
  n_sro_svbdrive(49) <= NN_2;
  n_sro_svbdrive(50) <= NN_2;
  n_sro_svbdrive(51) <= NN_2;
  n_sro_svbdrive(52) <= NN_2;
  n_sro_svbdrive(53) <= NN_2;
  n_sro_svbdrive(54) <= NN_2;
  n_sro_svbdrive(55) <= NN_2;
  n_sro_svbdrive(56) <= NN_2;
  n_sro_svbdrive(57) <= NN_2;
  n_sro_svbdrive(58) <= NN_2;
  n_sro_svbdrive(59) <= NN_2;
  n_sro_svbdrive(60) <= NN_2;
  n_sro_svbdrive(61) <= NN_2;
  n_sro_svbdrive(62) <= NN_2;
  n_sro_svbdrive(63) <= NN_2;
  n_sro_read <= NN_2;
  n_sro_sa(0) <= NN_2;
  n_sro_sa(1) <= NN_2;
  n_sro_sa(2) <= NN_2;
  n_sro_sa(3) <= NN_2;
  n_sro_sa(4) <= NN_2;
  n_sro_sa(5) <= NN_2;
  n_sro_sa(6) <= NN_2;
  n_sro_sa(7) <= NN_2;
  n_sro_sa(8) <= NN_2;
  n_sro_sa(9) <= NN_2;
  n_sro_sa(10) <= NN_2;
  n_sro_sa(11) <= NN_2;
  n_sro_sa(12) <= NN_2;
  n_sro_sa(13) <= NN_2;
  n_sro_sa(14) <= NN_2;
  n_sro_cb(0) <= NN_2;
  n_sro_cb(1) <= NN_2;
  n_sro_cb(2) <= NN_2;
  n_sro_cb(3) <= NN_2;
  n_sro_cb(4) <= NN_2;
  n_sro_cb(5) <= NN_2;
  n_sro_cb(6) <= NN_2;
  n_sro_cb(7) <= NN_2;
  n_sro_scb(0) <= NN_2;
  n_sro_scb(1) <= NN_2;
  n_sro_scb(2) <= NN_2;
  n_sro_scb(3) <= NN_2;
  n_sro_scb(4) <= NN_2;
  n_sro_scb(5) <= NN_2;
  n_sro_scb(6) <= NN_2;
  n_sro_scb(7) <= NN_2;
  n_sro_vcdrive(0) <= NN_2;
  n_sro_vcdrive(1) <= NN_2;
  n_sro_vcdrive(2) <= NN_2;
  n_sro_vcdrive(3) <= NN_2;
  n_sro_vcdrive(4) <= NN_2;
  n_sro_vcdrive(5) <= NN_2;
  n_sro_vcdrive(6) <= NN_2;
  n_sro_vcdrive(7) <= NN_2;
  n_sro_svcdrive(0) <= NN_2;
  n_sro_svcdrive(1) <= NN_2;
  n_sro_svcdrive(2) <= NN_2;
  n_sro_svcdrive(3) <= NN_2;
  n_sro_svcdrive(4) <= NN_2;
  n_sro_svcdrive(5) <= NN_2;
  n_sro_svcdrive(6) <= NN_2;
  n_sro_svcdrive(7) <= NN_2;
  n_sro_ce <= NN_2;
end beh;

