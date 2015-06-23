--------------------------------------------------------------------------------
-- Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: J.40
--  \   \         Application: netgen
--  /   /         Filename: processor_E.vhd
-- /___/   /\     Timestamp: Wed Jul  2 12:25:57 2008
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -sim -ofmt vhdl processor_E.ncd 
-- Device	: 3s50tq144-4 (PRODUCTION 1.39 2007-10-19)
-- Input file	: processor_E.ncd
-- Output file	: processor_E.vhd
-- # of Entities	: 1
-- Design Name	: processor_E
-- Xilinx	: /sse/eda/xilinx-9.2i
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Development System Reference Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library SIMPRIM;
use SIMPRIM.VCOMPONENTS.ALL;
use SIMPRIM.VPACKAGE.ALL;

entity processor_E is
  port (
    clk : in STD_LOGIC := 'X'; 
    one_step : in STD_LOGIC := 'X'; 
    nreset : in STD_LOGIC := 'X'; 
    cflag : out STD_LOGIC; 
    datmem_nrd : out STD_LOGIC; 
    datmem_nwr : out STD_LOGIC; 
    go_step : in STD_LOGIC := 'X'; 
    zflag : out STD_LOGIC; 
    nreset_int : in STD_LOGIC := 'X'; 
    prog_adr : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    a : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    b : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    datmem_data_out : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    datmem_adr : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    prog_data : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    datmem_data_in : in STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end processor_E;

architecture STRUCTURE of processor_E is
  signal prog_data_0_IBUF_0 : STD_LOGIC; 
  signal control_i_pr_state_or00096_SW1_O : STD_LOGIC; 
  signal N1275_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0056 : STD_LOGIC; 
  signal control_i_N5 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0016 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0013 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_2 : STD_LOGIC; 
  signal N1322_0 : STD_LOGIC; 
  signal control_int_1_0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal control_int_3_0 : STD_LOGIC; 
  signal control_int_4_0 : STD_LOGIC; 
  signal control_int_0_0 : STD_LOGIC; 
  signal ram_control_i_ram_data_reg_or0000_0 : STD_LOGIC; 
  signal reg_i_carry_out_3 : STD_LOGIC; 
  signal reg_i_carry_out_mux000023_O : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map20_0 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map24_0 : STD_LOGIC; 
  signal N1318 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map26_0 : STD_LOGIC; 
  signal reg_i_N0_0 : STD_LOGIC; 
  signal alu_i_xor0002 : STD_LOGIC; 
  signal alu_i_N9 : STD_LOGIC; 
  signal alu_i_temp_carry_4_or0001_4 : STD_LOGIC; 
  signal N1180_0 : STD_LOGIC; 
  signal N1181_0 : STD_LOGIC; 
  signal N1285_0 : STD_LOGIC; 
  signal clk_IBUF_5 : STD_LOGIC; 
  signal rst_int_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map73_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0002_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map25_0 : STD_LOGIC; 
  signal N1291_0 : STD_LOGIC; 
  signal reg_i_zero_out_or0000 : STD_LOGIC; 
  signal N1281_0 : STD_LOGIC; 
  signal N1255_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000314_O : STD_LOGIC; 
  signal reg_i_zero_out_6 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0012 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_In_SW0_O : STD_LOGIC; 
  signal control_i_N12_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0009 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0043_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_7 : STD_LOGIC; 
  signal reg_i_zero_out_mux00005_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map6_0 : STD_LOGIC; 
  signal N1310_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0006_0 : STD_LOGIC; 
  signal alu_i_result_0_41_SW0_O : STD_LOGIC; 
  signal N1345 : STD_LOGIC; 
  signal alu_i_N61_0 : STD_LOGIC; 
  signal alu_i_result_0_map17_0 : STD_LOGIC; 
  signal alu_i_N4_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0004_0 : STD_LOGIC; 
  signal alu_i_result_0_map7 : STD_LOGIC; 
  signal alu_i_result_0_4_O : STD_LOGIC; 
  signal alu_i_zero_out_or0001_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0010_0 : STD_LOGIC; 
  signal alu_i_result_0_map8_0 : STD_LOGIC; 
  signal alu_i_zero_out_or0002_map7_0 : STD_LOGIC; 
  signal alu_i_zero_out_or0002_map12_0 : STD_LOGIC; 
  signal alu_i_zero_out_or000234_SW0_O : STD_LOGIC; 
  signal alu_i_N1_0 : STD_LOGIC; 
  signal prog_data_1_IBUF_8 : STD_LOGIC; 
  signal alu_i_zero_out_or0000_0 : STD_LOGIC; 
  signal alu_i_result_1_111_SW0_O : STD_LOGIC; 
  signal alu_i_result_1_map2 : STD_LOGIC; 
  signal alu_i_result_1_map7_0 : STD_LOGIC; 
  signal alu_i_N22 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq00101_SW0_O : STD_LOGIC; 
  signal alu_i_N71 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map8 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map2_0 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map5 : STD_LOGIC; 
  signal control_i_pr_state_or000323_9 : STD_LOGIC; 
  signal alu_i_N3_0 : STD_LOGIC; 
  signal reg_i_b_out_and0000 : STD_LOGIC; 
  signal N620_0 : STD_LOGIC; 
  signal alu_i_xor0005_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0014_0 : STD_LOGIC; 
  signal alu_i_result_2_map6 : STD_LOGIC; 
  signal alu_i_result_2_4_SW0_O : STD_LOGIC; 
  signal alu_i_result_2_map7_0 : STD_LOGIC; 
  signal alu_i_result_1_44_O : STD_LOGIC; 
  signal alu_i_result_1_map12_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0000_0 : STD_LOGIC; 
  signal alu_i_result_1_map19_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0012 : STD_LOGIC; 
  signal alu_i_result_2_map12_0 : STD_LOGIC; 
  signal alu_i_result_2_44_O : STD_LOGIC; 
  signal alu_i_result_2_map19_0 : STD_LOGIC; 
  signal alu_i_zero_out_or0002 : STD_LOGIC; 
  signal alu_i_result_4_map18_0 : STD_LOGIC; 
  signal alu_i_result_5_8_O : STD_LOGIC; 
  signal alu_i_result_5_map3 : STD_LOGIC; 
  signal alu_i_result_5_map7_0 : STD_LOGIC; 
  signal alu_i_xor0001 : STD_LOGIC; 
  signal alu_i_temp_carry_6_or0001_0 : STD_LOGIC; 
  signal alu_i_N10_0 : STD_LOGIC; 
  signal N1283_0 : STD_LOGIC; 
  signal alu_i_result_5_36_SW0_O : STD_LOGIC; 
  signal alu_i_result_5_map10 : STD_LOGIC; 
  signal alu_i_result_5_map15_0 : STD_LOGIC; 
  signal alu_i_result_6_8_O : STD_LOGIC; 
  signal alu_i_result_6_map3 : STD_LOGIC; 
  signal alu_i_result_6_map7_0 : STD_LOGIC; 
  signal alu_i_result_6_36_SW0_O : STD_LOGIC; 
  signal alu_i_result_6_map10 : STD_LOGIC; 
  signal alu_i_result_6_map15_0 : STD_LOGIC; 
  signal alu_i_result_7_8_O : STD_LOGIC; 
  signal alu_i_result_7_map3 : STD_LOGIC; 
  signal alu_i_result_7_map7_0 : STD_LOGIC; 
  signal alu_i_result_7_36_SW0_O : STD_LOGIC; 
  signal alu_i_result_7_map10 : STD_LOGIC; 
  signal alu_i_result_7_map15_0 : STD_LOGIC; 
  signal alu_i_N8 : STD_LOGIC; 
  signal alu_i_xor0003_0 : STD_LOGIC; 
  signal alu_i_xor0004_0 : STD_LOGIC; 
  signal alu_i_result_3_8_SW0_O : STD_LOGIC; 
  signal alu_i_result_3_map4_0 : STD_LOGIC; 
  signal alu_i_result_4_8_SW0_O : STD_LOGIC; 
  signal alu_i_result_4_map4_0 : STD_LOGIC; 
  signal alu_i_xor0000 : STD_LOGIC; 
  signal N1178 : STD_LOGIC; 
  signal N1177_0 : STD_LOGIC; 
  signal alu_i_N11_0 : STD_LOGIC; 
  signal N1287_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd16_10 : STD_LOGIC; 
  signal control_i_pr_state_FFd18_11 : STD_LOGIC; 
  signal control_i_pr_state_or0000_map6 : STD_LOGIC; 
  signal control_i_pr_state_or0000_map2_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd19_12 : STD_LOGIC; 
  signal control_i_pr_state_FFd22_13 : STD_LOGIC; 
  signal control_i_pr_state_FFd24_14 : STD_LOGIC; 
  signal control_i_pr_state_FFd25_15 : STD_LOGIC; 
  signal control_i_pr_state_FFd10_16 : STD_LOGIC; 
  signal control_i_pr_state_or0001_map6 : STD_LOGIC; 
  signal control_i_pr_state_or0001_map2 : STD_LOGIC; 
  signal control_i_pr_state_FFd21_17 : STD_LOGIC; 
  signal control_i_pr_state_FFd23_18 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_19 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map8 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map2_0 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map5_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd2_20 : STD_LOGIC; 
  signal control_i_pr_state_FFd3_21 : STD_LOGIC; 
  signal control_i_pr_state_or00059_O : STD_LOGIC; 
  signal N1279_0 : STD_LOGIC; 
  signal N1278_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd14_22 : STD_LOGIC; 
  signal control_i_pr_state_FFd13_23 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_24 : STD_LOGIC; 
  signal control_i_pr_state_or0005_map7_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd9_25 : STD_LOGIC; 
  signal N1249 : STD_LOGIC; 
  signal control_i_pr_state_or0004_map6 : STD_LOGIC; 
  signal control_i_pr_state_or0004_map9_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000500_SW0_SW1_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map130_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map123_0 : STD_LOGIC; 
  signal N1251_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0054_0 : STD_LOGIC; 
  signal control_i_pr_state_or0006_map2_0 : STD_LOGIC; 
  signal control_i_pr_state_or000615_O : STD_LOGIC; 
  signal control_i_pr_state_or0006_map5_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0053_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0057_0 : STD_LOGIC; 
  signal control_nxt_int_3_0 : STD_LOGIC; 
  signal control_i_pr_state_or0007_map2_0 : STD_LOGIC; 
  signal control_i_pr_state_or0007_map7_0 : STD_LOGIC; 
  signal control_i_pr_state_or000726_SW0_O : STD_LOGIC; 
  signal N1253_0 : STD_LOGIC; 
  signal control_i_N6 : STD_LOGIC; 
  signal control_i_N7_0 : STD_LOGIC; 
  signal control_i_N11 : STD_LOGIC; 
  signal control_nxt_int_2_0 : STD_LOGIC; 
  signal control_i_pr_state_or000827_SW0_O : STD_LOGIC; 
  signal control_i_pr_state_or0008_map11_0 : STD_LOGIC; 
  signal control_i_pr_state_or0008_map12_0 : STD_LOGIC; 
  signal N1289_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd12_26 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0045 : STD_LOGIC; 
  signal control_nxt_int_1_0 : STD_LOGIC; 
  signal control_i_N9 : STD_LOGIC; 
  signal prog_data_5_IBUF_27 : STD_LOGIC; 
  signal prog_data_7_IBUF_28 : STD_LOGIC; 
  signal prog_data_6_IBUF_29 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0066_0 : STD_LOGIC; 
  signal control_i_pr_state_or000923_O : STD_LOGIC; 
  signal control_i_pr_state_or0009_map5_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0067_0 : STD_LOGIC; 
  signal control_i_pr_state_or0009_map8_0 : STD_LOGIC; 
  signal control_nxt_int_0_0 : STD_LOGIC; 
  signal N1299_0 : STD_LOGIC; 
  signal alu_i_xor0006_or0000 : STD_LOGIC; 
  signal N1300_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map39_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map22_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map15_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux000077_SW0_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000403_O : STD_LOGIC; 
  signal alu_i_N5 : STD_LOGIC; 
  signal alu_i_N6_0 : STD_LOGIC; 
  signal alu_i_N7 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map32_0 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_5_SW1_O : STD_LOGIC; 
  signal N623_0 : STD_LOGIC; 
  signal alu_i_result_5_map18 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_6_SW1_O : STD_LOGIC; 
  signal alu_i_result_6_map18 : STD_LOGIC; 
  signal alu_i_xor0007_0 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq00141_SW0_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map155_0 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_7_SW1_O : STD_LOGIC; 
  signal N1173_0 : STD_LOGIC; 
  signal alu_i_result_7_map18 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000478_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map146_0 : STD_LOGIC; 
  signal reg_i_a_out_cmp_eq0009_30 : STD_LOGIC; 
  signal reg_i_a_out_or0001_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0055 : STD_LOGIC; 
  signal N1263_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0047_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0064_0 : STD_LOGIC; 
  signal N1267_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0044 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0015_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_1_31 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_32 : STD_LOGIC; 
  signal prog_data_3_IBUF_33 : STD_LOGIC; 
  signal prog_data_2_IBUF_34 : STD_LOGIC; 
  signal control_i_pr_state_FFd5_35 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0007 : STD_LOGIC; 
  signal N166_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_36 : STD_LOGIC; 
  signal control_i_pr_state_FFd7_37 : STD_LOGIC; 
  signal N1265 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map17_0 : STD_LOGIC; 
  signal pc_i_pc_int_or0000_38 : STD_LOGIC; 
  signal prog_data_4_IBUF_39 : STD_LOGIC; 
  signal control_i_pr_state_or0002231_0 : STD_LOGIC; 
  signal N1355_0 : STD_LOGIC; 
  signal N1320_0 : STD_LOGIC; 
  signal N1302 : STD_LOGIC; 
  signal control_i_pr_state_FFd1_40 : STD_LOGIC; 
  signal N1304 : STD_LOGIC; 
  signal control_i_pr_state_or0005_map1_0 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map14 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map5 : STD_LOGIC; 
  signal N1357_0 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0046 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_41 : STD_LOGIC; 
  signal N1259 : STD_LOGIC; 
  signal N65_0 : STD_LOGIC; 
  signal N1351_0 : STD_LOGIC; 
  signal N1353_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map88_0 : STD_LOGIC; 
  signal control_i_pr_state_or000017_42 : STD_LOGIC; 
  signal control_i_pr_state_or000117_0 : STD_LOGIC; 
  signal control_i_pr_state_or000427_0 : STD_LOGIC; 
  signal clk_IBUF1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map81_0 : STD_LOGIC; 
  signal N1257_0 : STD_LOGIC; 
  signal nreset_IBUF_43 : STD_LOGIC; 
  signal nreset_int_IBUF_44 : STD_LOGIC; 
  signal GLOBAL_LOGIC0 : STD_LOGIC; 
  signal control_i_pr_state_FFd6_45 : STD_LOGIC; 
  signal pc_i_pc_int_cmp_eq0003_0 : STD_LOGIC; 
  signal N547 : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_1_Q : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_3_Q : STD_LOGIC; 
  signal reg_i_a_out_or0000_0 : STD_LOGIC; 
  signal alu_i_result_3_map18_0 : STD_LOGIC; 
  signal N1361 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map64_0 : STD_LOGIC; 
  signal alu_i_result_3_map10_0 : STD_LOGIC; 
  signal N1359 : STD_LOGIC; 
  signal alu_i_result_4_map10_0 : STD_LOGIC; 
  signal alu_i_result_3_map17_0 : STD_LOGIC; 
  signal alu_i_result_4_map15 : STD_LOGIC; 
  signal alu_i_result_3_map15 : STD_LOGIC; 
  signal alu_i_result_4_map17_0 : STD_LOGIC; 
  signal N1261 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map49_0 : STD_LOGIC; 
  signal alu_i_xor0000_or0000_0 : STD_LOGIC; 
  signal N1330_0 : STD_LOGIC; 
  signal N1340_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map56_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map71 : STD_LOGIC; 
  signal GLOBAL_LOGIC1 : STD_LOGIC; 
  signal N224 : STD_LOGIC; 
  signal N1316 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000356_SW0_O : STD_LOGIC; 
  signal N1332_0 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000500_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000565_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000290_O : STD_LOGIC; 
  signal reg_i_carry_out_mux0000117_O : STD_LOGIC; 
  signal control_i_pr_state_or000223_0 : STD_LOGIC; 
  signal N1322 : STD_LOGIC; 
  signal control_i_pr_state_or00096_SW1_O_pack_1 : STD_LOGIC; 
  signal ram_control_i_ram_data_reg_or0000 : STD_LOGIC; 
  signal N1_pack_1 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map26 : STD_LOGIC; 
  signal reg_i_carry_out_mux000023_O_pack_1 : STD_LOGIC; 
  signal N1285 : STD_LOGIC; 
  signal alu_i_xor0002_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000314_O_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_REVUSED_46 : STD_LOGIC; 
  signal reg_i_zero_out_DYMUX_47 : STD_LOGIC; 
  signal N1237 : STD_LOGIC; 
  signal reg_i_zero_out_SRINV_48 : STD_LOGIC; 
  signal reg_i_zero_out_CLKINV_49 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_DXMUX_50 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_FXMUX_51 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0043 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_In_SW0_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_SRINV_52 : STD_LOGIC; 
  signal control_i_pr_state_FFd11_CLKINV_53 : STD_LOGIC; 
  signal N1310 : STD_LOGIC; 
  signal reg_i_zero_out_mux00005_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_0_map17 : STD_LOGIC; 
  signal alu_i_result_0_41_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_0_map8 : STD_LOGIC; 
  signal alu_i_result_0_4_O_pack_1 : STD_LOGIC; 
  signal alu_i_N1 : STD_LOGIC; 
  signal alu_i_zero_out_or000234_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_1_map7 : STD_LOGIC; 
  signal alu_i_result_1_111_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_N3 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq00101_SW0_O_pack_1 : STD_LOGIC; 
  signal N620 : STD_LOGIC; 
  signal reg_i_b_out_and0000_pack_1 : STD_LOGIC; 
  signal alu_i_result_2_map7 : STD_LOGIC; 
  signal alu_i_result_2_4_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_1_map19 : STD_LOGIC; 
  signal alu_i_result_1_44_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_2_map12 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0012_pack_1 : STD_LOGIC; 
  signal alu_i_result_2_map19 : STD_LOGIC; 
  signal alu_i_result_2_44_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_4_map18 : STD_LOGIC; 
  signal alu_i_zero_out_or0002_pack_1 : STD_LOGIC; 
  signal alu_i_result_5_map7 : STD_LOGIC; 
  signal alu_i_result_5_8_O_pack_1 : STD_LOGIC; 
  signal N1283 : STD_LOGIC; 
  signal alu_i_xor0001_pack_1 : STD_LOGIC; 
  signal alu_i_result_5_map15 : STD_LOGIC; 
  signal alu_i_result_5_36_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_6_map7 : STD_LOGIC; 
  signal alu_i_result_6_8_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_6_map15 : STD_LOGIC; 
  signal alu_i_result_6_36_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_7_map7 : STD_LOGIC; 
  signal alu_i_result_7_8_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_7_map15 : STD_LOGIC; 
  signal alu_i_result_7_36_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_xor0003 : STD_LOGIC; 
  signal alu_i_N8_pack_1 : STD_LOGIC; 
  signal alu_i_result_3_map4 : STD_LOGIC; 
  signal alu_i_result_3_8_SW0_O_pack_1 : STD_LOGIC; 
  signal alu_i_result_4_map4 : STD_LOGIC; 
  signal alu_i_result_4_8_SW0_O_pack_1 : STD_LOGIC; 
  signal N1287 : STD_LOGIC; 
  signal alu_i_xor0000_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0000_map6_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0001_map6_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map8_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0005_map7 : STD_LOGIC; 
  signal control_i_pr_state_or00059_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0004_map6_pack_1 : STD_LOGIC; 
  signal N1251 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000500_SW0_SW1_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000615_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000726_SW0_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000827_SW0_O_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0008_map11 : STD_LOGIC; 
  signal control_i_N11_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000923_O_pack_1 : STD_LOGIC; 
  signal alu_i_temp_carry_6_or0001_54 : STD_LOGIC; 
  signal alu_i_temp_carry_4_or0001_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map39 : STD_LOGIC; 
  signal alu_i_N9_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map25 : STD_LOGIC; 
  signal reg_i_zero_out_mux000077_SW0_O_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map123 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000403_O_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map32 : STD_LOGIC; 
  signal alu_i_N5_pack_1 : STD_LOGIC; 
  signal reg_i_b_out_5_DXMUX_55 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_5_SW1_O_pack_1 : STD_LOGIC; 
  signal reg_i_b_out_5_SRINV_56 : STD_LOGIC; 
  signal reg_i_b_out_5_CLKINV_57 : STD_LOGIC; 
  signal reg_i_b_out_6_DXMUX_58 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_6_SW1_O_pack_1 : STD_LOGIC; 
  signal reg_i_b_out_6_SRINV_59 : STD_LOGIC; 
  signal reg_i_b_out_6_CLKINV_60 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map155 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq00141_SW0_O_pack_1 : STD_LOGIC; 
  signal reg_i_b_out_7_DXMUX_61 : STD_LOGIC; 
  signal reg_i_b_out_mux0000_7_SW1_O_pack_1 : STD_LOGIC; 
  signal reg_i_b_out_7_SRINV_62 : STD_LOGIC; 
  signal reg_i_b_out_7_CLKINV_63 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map146 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000478_O_pack_1 : STD_LOGIC; 
  signal N84 : STD_LOGIC; 
  signal reg_i_a_out_cmp_eq0009_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0008_map12 : STD_LOGIC; 
  signal control_i_pr_state_FFd10_DYMUX_64 : STD_LOGIC; 
  signal control_i_pr_state_FFd10_GYMUX_65 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0055_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd10_SRINV_66 : STD_LOGIC; 
  signal control_i_pr_state_FFd10_CLKINV_67 : STD_LOGIC; 
  signal N1289 : STD_LOGIC; 
  signal control_i_pr_state_FFd12_DYMUX_68 : STD_LOGIC; 
  signal control_i_pr_state_FFd12_GYMUX_69 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0056_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd12_SRINV_70 : STD_LOGIC; 
  signal control_i_pr_state_FFd12_CLKINV_71 : STD_LOGIC; 
  signal control_i_pr_state_or0009_map8 : STD_LOGIC; 
  signal control_i_pr_state_FFd14_DYMUX_72 : STD_LOGIC; 
  signal control_i_pr_state_FFd14_GYMUX_73 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0044_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd14_SRINV_74 : STD_LOGIC; 
  signal control_i_pr_state_FFd14_CLKINV_75 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_DXMUX_76 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0061 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_DYMUX_77 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_GYMUX_78 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0066 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_SRINV_79 : STD_LOGIC; 
  signal control_i_pr_state_FFd4_CLKINV_80 : STD_LOGIC; 
  signal control_i_pr_state_or0006_map5 : STD_LOGIC; 
  signal control_i_pr_state_FFd5_DYMUX_81 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0062 : STD_LOGIC; 
  signal control_i_pr_state_FFd5_SRINV_82 : STD_LOGIC; 
  signal control_i_pr_state_FFd5_CLKINV_83 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_DXMUX_84 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_FXMUX_85 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0053 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_DYMUX_86 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_GYMUX_87 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0064 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_SRINV_88 : STD_LOGIC; 
  signal control_i_pr_state_FFd8_CLKINV_89 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map17 : STD_LOGIC; 
  signal control_i_pr_state_FFd9_DYMUX_90 : STD_LOGIC; 
  signal control_i_pr_state_FFd9_GYMUX_91 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0054 : STD_LOGIC; 
  signal control_i_pr_state_FFd9_SRINV_92 : STD_LOGIC; 
  signal control_i_pr_state_FFd9_CLKINV_93 : STD_LOGIC; 
  signal control_i_N7 : STD_LOGIC; 
  signal pc_i_pc_int_1_DYMUX_94 : STD_LOGIC; 
  signal pc_i_pc_int_1_SRINV_95 : STD_LOGIC; 
  signal pc_i_pc_int_1_CLKINV_96 : STD_LOGIC; 
  signal pc_i_pc_int_3_DXMUX_97 : STD_LOGIC; 
  signal pc_i_pc_int_3_DYMUX_98 : STD_LOGIC; 
  signal pc_i_pc_int_3_SRINV_99 : STD_LOGIC; 
  signal pc_i_pc_int_3_CLKINV_100 : STD_LOGIC; 
  signal pc_i_pc_int_5_DXMUX_101 : STD_LOGIC; 
  signal pc_i_pc_int_5_DYMUX_102 : STD_LOGIC; 
  signal pc_i_pc_int_5_SRINV_103 : STD_LOGIC; 
  signal pc_i_pc_int_5_CLKINV_104 : STD_LOGIC; 
  signal pc_i_pc_int_7_DXMUX_105 : STD_LOGIC; 
  signal pc_i_pc_int_7_DYMUX_106 : STD_LOGIC; 
  signal pc_i_pc_int_7_SRINV_107 : STD_LOGIC; 
  signal pc_i_pc_int_7_CLKINV_108 : STD_LOGIC; 
  signal alu_i_N6 : STD_LOGIC; 
  signal N1355 : STD_LOGIC; 
  signal N712 : STD_LOGIC; 
  signal N312 : STD_LOGIC; 
  signal N92 : STD_LOGIC; 
  signal N310 : STD_LOGIC; 
  signal N1320 : STD_LOGIC; 
  signal control_i_pr_state_FFd1_DXMUX_109 : STD_LOGIC; 
  signal control_i_pr_state_FFd1_FXMUX_110 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0067 : STD_LOGIC; 
  signal N1302_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd1_SRINV_111 : STD_LOGIC; 
  signal control_i_pr_state_FFd1_CLKINV_112 : STD_LOGIC; 
  signal N1275 : STD_LOGIC; 
  signal N1304_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd22_DXMUX_113 : STD_LOGIC; 
  signal control_i_pr_state_FFd22_DYMUX_114 : STD_LOGIC; 
  signal control_i_pr_state_FFd22_SRINV_115 : STD_LOGIC; 
  signal control_i_pr_state_FFd22_CLKINV_116 : STD_LOGIC; 
  signal control_i_pr_state_FFd24_DXMUX_117 : STD_LOGIC; 
  signal control_i_pr_state_FFd24_DYMUX_118 : STD_LOGIC; 
  signal control_i_pr_state_FFd24_SRINV_119 : STD_LOGIC; 
  signal control_i_pr_state_FFd24_CLKINV_120 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_DXMUX_121 : STD_LOGIC; 
  signal control_i_pr_state_or0005_map1 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_DYMUX_122 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_GYMUX_123 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0045_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_SRINV_124 : STD_LOGIC; 
  signal control_i_pr_state_FFd15_CLKINV_125 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_DXMUX_126 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_FXMUX_127 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In : STD_LOGIC; 
  signal control_i_pr_state_FFd26_DYMUX_128 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map5_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_SRINV_129 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_CLKINV_130 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_DXMUX_131 : STD_LOGIC; 
  signal N1253 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_DYMUX_132 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_GYMUX_133 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0046_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_SRINV_134 : STD_LOGIC; 
  signal control_i_pr_state_FFd17_CLKINV_135 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_DXMUX_136 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_FXMUX_137 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0047 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_DYMUX_138 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0016_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_SRINV_139 : STD_LOGIC; 
  signal control_i_pr_state_FFd20_CLKINV_140 : STD_LOGIC; 
  signal control_i_pr_state_or0009_map5 : STD_LOGIC; 
  signal N1259_pack_1 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map0 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map0 : STD_LOGIC; 
  signal N65 : STD_LOGIC; 
  signal N1351 : STD_LOGIC; 
  signal N1353 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map88 : STD_LOGIC; 
  signal control_i_N12 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0010 : STD_LOGIC; 
  signal alu_i_N71_pack_1 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map24 : STD_LOGIC; 
  signal alu_i_zero_out_or0002_map7 : STD_LOGIC; 
  signal datmem_nwr_OBUF_141 : STD_LOGIC; 
  signal datmem_nrd_OBUF_142 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0002 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0000 : STD_LOGIC; 
  signal N1257 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0014 : STD_LOGIC; 
  signal N1263 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0012_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd13_DXMUX_143 : STD_LOGIC; 
  signal control_i_pr_state_FFd13_FXMUX_144 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0057 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0013_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd13_SRINV_145 : STD_LOGIC; 
  signal control_i_pr_state_FFd13_CLKINV_146 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map81 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0015 : STD_LOGIC; 
  signal N166 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0007_pack_1 : STD_LOGIC; 
  signal N1267 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0009_pack_1 : STD_LOGIC; 
  signal N1278 : STD_LOGIC; 
  signal N1357 : STD_LOGIC; 
  signal rst_int : STD_LOGIC; 
  signal N1181 : STD_LOGIC; 
  signal N1180 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_1_DYMUX_147 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_1_SRINV_148 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_1_CLKINV_149 : STD_LOGIC; 
  signal alu_i_N11 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000_map20 : STD_LOGIC; 
  signal N1300 : STD_LOGIC; 
  signal N1299 : STD_LOGIC; 
  signal control_i_pr_state_or0004_map9 : STD_LOGIC; 
  signal control_i_pr_state_or0000_map2 : STD_LOGIC; 
  signal alu_i_N4_CYINIT_150 : STD_LOGIC; 
  signal alu_i_N4_CY0F_151 : STD_LOGIC; 
  signal alu_i_N4_CYSELF_152 : STD_LOGIC; 
  signal alu_i_N4 : STD_LOGIC; 
  signal alu_i_N4_XORG_153 : STD_LOGIC; 
  signal alu_i_N4_CYMUXG_154 : STD_LOGIC; 
  signal alu_i_N4_CY0G_155 : STD_LOGIC; 
  signal alu_i_N4_CYSELG_156 : STD_LOGIC; 
  signal N1244 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map2 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map2 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_XORF_157 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYINIT_158 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CY0F_159 : STD_LOGIC; 
  signal N1243 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_XORG_160 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYSELF_161 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYMUXFAST_162 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYAND_163 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_FASTCARRY_164 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYMUXG2_165 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYMUXF2_166 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CY0G_167 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_2_CYSELG_168 : STD_LOGIC; 
  signal N1242 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_XORF_169 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYINIT_170 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CY0F_171 : STD_LOGIC; 
  signal N1241 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_XORG_172 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYSELF_173 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYMUXFAST_174 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYAND_175 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_FASTCARRY_176 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYMUXG2_177 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYMUXF2_178 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CY0G_179 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_4_CYSELG_180 : STD_LOGIC; 
  signal N1240 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_XORF_181 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYINIT_182 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CY0F_183 : STD_LOGIC; 
  signal N1239 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_XORG_184 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYSELF_185 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYMUXFAST_186 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYAND_187 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_FASTCARRY_188 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYMUXG2_189 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYMUXF2_190 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CY0G_191 : STD_LOGIC; 
  signal alu_i_add_result_int_add0000_6_CYSELG_192 : STD_LOGIC; 
  signal N1238 : STD_LOGIC; 
  signal control_i_pr_state_or0006_map2 : STD_LOGIC; 
  signal control_i_pr_state_or0003_map5 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CYINIT_193 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CY0F_194 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CYSELF_195 : STD_LOGIC; 
  signal pc_i_N4 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_XORG_196 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CYMUXG_197 : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_0_Q : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CY0G_198 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_1_CYSELG_199 : STD_LOGIC; 
  signal pc_i_N5 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_XORF_200 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYINIT_201 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_F : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_XORG_202 : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_2_Q : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYSELF_203 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYMUXFAST_204 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYAND_205 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_FASTCARRY_206 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYMUXG2_207 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYMUXF2_208 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_CYSELG_210 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_2_G : STD_LOGIC; 
  signal control_i_pr_state_or0007_map2 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_XORF_211 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYINIT_212 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_F : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_XORG_213 : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_4_Q : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYSELF_214 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYMUXFAST_215 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYAND_216 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_FASTCARRY_217 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYMUXG2_218 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYMUXF2_219 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_CYSELG_221 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_4_G : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_XORF_222 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_LOGIC_ZERO_223 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_CYINIT_224 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_CYSELF_225 : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_F : STD_LOGIC; 
  signal pc_i_pc_int_addsub0000_6_XORG_226 : STD_LOGIC; 
  signal pc_i_Madd_pc_int_addsub0000_cy_6_Q : STD_LOGIC; 
  signal pc_i_pc_int_7_rt_227 : STD_LOGIC; 
  signal N1173 : STD_LOGIC; 
  signal N623 : STD_LOGIC; 
  signal cflag_O : STD_LOGIC; 
  signal result_alu_reg_0_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_0_REVUSED_228 : STD_LOGIC; 
  signal reg_i_a_out_0_DYMUX_229 : STD_LOGIC; 
  signal N1236 : STD_LOGIC; 
  signal reg_i_a_out_0_SRINV_230 : STD_LOGIC; 
  signal reg_i_a_out_0_CLKINV_231 : STD_LOGIC; 
  signal a_0_O : STD_LOGIC; 
  signal alu_i_result_3_map18 : STD_LOGIC; 
  signal alu_i_result_1_map12 : STD_LOGIC; 
  signal datmem_data_out_0_O : STD_LOGIC; 
  signal result_alu_reg_1_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_1_REVUSED_232 : STD_LOGIC; 
  signal reg_i_a_out_1_DYMUX_233 : STD_LOGIC; 
  signal N1235 : STD_LOGIC; 
  signal reg_i_a_out_1_SRINV_234 : STD_LOGIC; 
  signal reg_i_a_out_1_CLKINV_235 : STD_LOGIC; 
  signal a_1_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map64 : STD_LOGIC; 
  signal alu_i_result_3_map10 : STD_LOGIC; 
  signal datmem_data_out_1_O : STD_LOGIC; 
  signal result_alu_reg_2_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_2_REVUSED_236 : STD_LOGIC; 
  signal reg_i_a_out_2_DYMUX_237 : STD_LOGIC; 
  signal N1234 : STD_LOGIC; 
  signal reg_i_a_out_2_SRINV_238 : STD_LOGIC; 
  signal reg_i_a_out_2_CLKINV_239 : STD_LOGIC; 
  signal a_2_O : STD_LOGIC; 
  signal datmem_data_out_2_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map6 : STD_LOGIC; 
  signal alu_i_result_4_map10 : STD_LOGIC; 
  signal a_3_O : STD_LOGIC; 
  signal result_alu_reg_3_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_3_REVUSED_240 : STD_LOGIC; 
  signal reg_i_a_out_3_DYMUX_241 : STD_LOGIC; 
  signal N1233 : STD_LOGIC; 
  signal reg_i_a_out_3_SRINV_242 : STD_LOGIC; 
  signal reg_i_a_out_3_CLKINV_243 : STD_LOGIC; 
  signal datmem_data_out_3_O : STD_LOGIC; 
  signal alu_i_result_4_map17 : STD_LOGIC; 
  signal alu_i_result_3_map17 : STD_LOGIC; 
  signal b_0_O : STD_LOGIC; 
  signal result_alu_reg_4_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_4_REVUSED_244 : STD_LOGIC; 
  signal reg_i_a_out_4_DYMUX_245 : STD_LOGIC; 
  signal N1232 : STD_LOGIC; 
  signal reg_i_a_out_4_SRINV_246 : STD_LOGIC; 
  signal reg_i_a_out_4_CLKINV_247 : STD_LOGIC; 
  signal a_4_O : STD_LOGIC; 
  signal datmem_data_out_4_O : STD_LOGIC; 
  signal b_1_O : STD_LOGIC; 
  signal a_5_O : STD_LOGIC; 
  signal control_i_pr_state_or0007_map7 : STD_LOGIC; 
  signal N1261_pack_1 : STD_LOGIC; 
  signal datmem_data_out_5_O : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map49 : STD_LOGIC; 
  signal alu_i_xor0007 : STD_LOGIC; 
  signal b_2_O : STD_LOGIC; 
  signal alu_i_N10 : STD_LOGIC; 
  signal N1177 : STD_LOGIC; 
  signal a_6_O : STD_LOGIC; 
  signal alu_i_xor0000_or0000_248 : STD_LOGIC; 
  signal N1178_pack_1 : STD_LOGIC; 
  signal datmem_data_out_6_O : STD_LOGIC; 
  signal control_i_pr_state_FFd2_DXMUX_249 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0065 : STD_LOGIC; 
  signal control_i_N9_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd2_SRINV_250 : STD_LOGIC; 
  signal control_i_pr_state_FFd2_CLKINV_251 : STD_LOGIC; 
  signal b_3_O : STD_LOGIC; 
  signal a_7_O : STD_LOGIC; 
  signal control_i_pr_state_FFd6_DXMUX_252 : STD_LOGIC; 
  signal control_i_pr_state_cmp_eq0063 : STD_LOGIC; 
  signal control_i_N6_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_FFd6_SRINV_253 : STD_LOGIC; 
  signal control_i_pr_state_FFd6_CLKINV_254 : STD_LOGIC; 
  signal datmem_data_out_7_O : STD_LOGIC; 
  signal N1279 : STD_LOGIC; 
  signal control_i_N5_pack_1 : STD_LOGIC; 
  signal b_4_O : STD_LOGIC; 
  signal b_5_O : STD_LOGIC; 
  signal alu_i_zero_out_or0001 : STD_LOGIC; 
  signal control_int_2_pack_1 : STD_LOGIC; 
  signal b_6_O : STD_LOGIC; 
  signal b_7_O : STD_LOGIC; 
  signal datmem_adr_0_O : STD_LOGIC; 
  signal datmem_adr_1_O : STD_LOGIC; 
  signal datmem_adr_2_O : STD_LOGIC; 
  signal N88 : STD_LOGIC; 
  signal N90 : STD_LOGIC; 
  signal datmem_adr_3_O : STD_LOGIC; 
  signal datmem_adr_4_O : STD_LOGIC; 
  signal datmem_adr_5_O : STD_LOGIC; 
  signal datmem_adr_6_O : STD_LOGIC; 
  signal reg_i_a_out_or0000_255 : STD_LOGIC; 
  signal N1330 : STD_LOGIC; 
  signal datmem_adr_7_O : STD_LOGIC; 
  signal nreset_int_INBUF : STD_LOGIC; 
  signal datmem_nrd_O : STD_LOGIC; 
  signal N1340 : STD_LOGIC; 
  signal datmem_nwr_O : STD_LOGIC; 
  signal zflag_O : STD_LOGIC; 
  signal datmem_data_in_0_INBUF : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map73 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map71_pack_1 : STD_LOGIC; 
  signal datmem_data_in_1_INBUF : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map22 : STD_LOGIC; 
  signal datmem_data_in_2_INBUF : STD_LOGIC; 
  signal N86 : STD_LOGIC; 
  signal datmem_data_in_3_INBUF : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map15 : STD_LOGIC; 
  signal datmem_data_in_4_INBUF : STD_LOGIC; 
  signal datmem_data_in_5_INBUF : STD_LOGIC; 
  signal datmem_data_in_6_INBUF : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map56 : STD_LOGIC; 
  signal datmem_data_in_7_INBUF : STD_LOGIC; 
  signal reg_i_zero_out_mux0000_map130 : STD_LOGIC; 
  signal clk_INBUF : STD_LOGIC; 
  signal prog_adr_0_O : STD_LOGIC; 
  signal prog_adr_1_O : STD_LOGIC; 
  signal prog_adr_2_O : STD_LOGIC; 
  signal prog_adr_3_O : STD_LOGIC; 
  signal prog_adr_4_O : STD_LOGIC; 
  signal prog_adr_5_O : STD_LOGIC; 
  signal prog_adr_6_O : STD_LOGIC; 
  signal prog_adr_7_O : STD_LOGIC; 
  signal nreset_INBUF : STD_LOGIC; 
  signal prog_data_0_INBUF : STD_LOGIC; 
  signal prog_data_0_IFF_ISR_USED_256 : STD_LOGIC; 
  signal prog_data_0_IFF_ICLK1INV_257 : STD_LOGIC; 
  signal prog_data_0_IFF_IFFDMUX_258 : STD_LOGIC; 
  signal prog_data_1_INBUF : STD_LOGIC; 
  signal prog_data_1_IFF_ISR_USED_259 : STD_LOGIC; 
  signal prog_data_1_IFF_ICLK1INV_260 : STD_LOGIC; 
  signal prog_data_1_IFF_IFFDMUX_261 : STD_LOGIC; 
  signal prog_data_2_INBUF : STD_LOGIC; 
  signal prog_data_2_IFF_ISR_USED_262 : STD_LOGIC; 
  signal prog_data_2_IFF_ICLK1INV_263 : STD_LOGIC; 
  signal prog_data_2_IFF_IFFDMUX_264 : STD_LOGIC; 
  signal prog_data_3_INBUF : STD_LOGIC; 
  signal prog_data_3_IFF_ISR_USED_265 : STD_LOGIC; 
  signal prog_data_3_IFF_ICLK1INV_266 : STD_LOGIC; 
  signal prog_data_3_IFF_IFFDMUX_267 : STD_LOGIC; 
  signal prog_data_4_INBUF : STD_LOGIC; 
  signal prog_data_4_IFF_ISR_USED_268 : STD_LOGIC; 
  signal prog_data_4_IFF_ICLK1INV_269 : STD_LOGIC; 
  signal prog_data_4_IFF_IFFDMUX_270 : STD_LOGIC; 
  signal prog_data_5_INBUF : STD_LOGIC; 
  signal prog_data_5_IFF_ISR_USED_271 : STD_LOGIC; 
  signal prog_data_5_IFF_ICLK1INV_272 : STD_LOGIC; 
  signal prog_data_5_IFF_IFFDMUX_273 : STD_LOGIC; 
  signal prog_data_6_INBUF : STD_LOGIC; 
  signal prog_data_6_IFF_ISR_USED_274 : STD_LOGIC; 
  signal prog_data_6_IFF_ICLK1INV_275 : STD_LOGIC; 
  signal prog_data_6_IFF_IFFDMUX_276 : STD_LOGIC; 
  signal prog_data_7_INBUF : STD_LOGIC; 
  signal prog_data_7_IFF_ISR_USED_277 : STD_LOGIC; 
  signal prog_data_7_IFF_ICLK1INV_278 : STD_LOGIC; 
  signal prog_data_7_IFF_IFFDMUX_279 : STD_LOGIC; 
  signal clk_IBUF_BUFG_S_INVNOT : STD_LOGIC; 
  signal clk_IBUF_BUFG_I0_INV : STD_LOGIC; 
  signal N1361_F5MUX_280 : STD_LOGIC; 
  signal N1386 : STD_LOGIC; 
  signal N1361_BXINV_281 : STD_LOGIC; 
  signal N1385 : STD_LOGIC; 
  signal N1359_F5MUX_282 : STD_LOGIC; 
  signal N1384 : STD_LOGIC; 
  signal N1359_BXINV_283 : STD_LOGIC; 
  signal N1383 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map14_F5MUX_284 : STD_LOGIC; 
  signal N1388 : STD_LOGIC; 
  signal control_i_pr_state_FFd26_In_map14_BXINV_285 : STD_LOGIC; 
  signal N1387 : STD_LOGIC; 
  signal alu_i_result_0_map7_F5MUX_286 : STD_LOGIC; 
  signal N1392 : STD_LOGIC; 
  signal alu_i_result_0_map7_BXINV_287 : STD_LOGIC; 
  signal N1391 : STD_LOGIC; 
  signal alu_i_result_2_map6_F5MUX_288 : STD_LOGIC; 
  signal N1396 : STD_LOGIC; 
  signal alu_i_result_2_map6_BXINV_289 : STD_LOGIC; 
  signal N1395 : STD_LOGIC; 
  signal alu_i_result_3_map15_F5MUX_290 : STD_LOGIC; 
  signal N1400 : STD_LOGIC; 
  signal alu_i_result_3_map15_BXINV_291 : STD_LOGIC; 
  signal N1399 : STD_LOGIC; 
  signal alu_i_result_4_map15_F5MUX_292 : STD_LOGIC; 
  signal N1398 : STD_LOGIC; 
  signal alu_i_result_4_map15_BXINV_293 : STD_LOGIC; 
  signal N1397 : STD_LOGIC; 
  signal alu_i_result_5_map10_F5MUX_294 : STD_LOGIC; 
  signal N1404 : STD_LOGIC; 
  signal alu_i_result_5_map10_BXINV_295 : STD_LOGIC; 
  signal N1403 : STD_LOGIC; 
  signal alu_i_result_6_map10_F5MUX_296 : STD_LOGIC; 
  signal N1402 : STD_LOGIC; 
  signal alu_i_result_6_map10_BXINV_297 : STD_LOGIC; 
  signal N1401 : STD_LOGIC; 
  signal alu_i_result_7_map10_F5MUX_298 : STD_LOGIC; 
  signal N1406 : STD_LOGIC; 
  signal alu_i_result_7_map10_BXINV_299 : STD_LOGIC; 
  signal N1405 : STD_LOGIC; 
  signal alu_i_result_1_map2_F5MUX_300 : STD_LOGIC; 
  signal N1390 : STD_LOGIC; 
  signal alu_i_result_1_map2_BXINV_301 : STD_LOGIC; 
  signal N1389 : STD_LOGIC; 
  signal alu_i_result_5_map3_F5MUX_302 : STD_LOGIC; 
  signal N1380 : STD_LOGIC; 
  signal alu_i_result_5_map3_BXINV_303 : STD_LOGIC; 
  signal N1379 : STD_LOGIC; 
  signal alu_i_result_6_map3_F5MUX_304 : STD_LOGIC; 
  signal N1378 : STD_LOGIC; 
  signal alu_i_result_6_map3_BXINV_305 : STD_LOGIC; 
  signal N1377 : STD_LOGIC; 
  signal alu_i_result_7_map3_F5MUX_306 : STD_LOGIC; 
  signal N1382 : STD_LOGIC; 
  signal alu_i_result_7_map3_BXINV_307 : STD_LOGIC; 
  signal N1381 : STD_LOGIC; 
  signal N1345_F5MUX_308 : STD_LOGIC; 
  signal N1394 : STD_LOGIC; 
  signal N1345_BXINV_309 : STD_LOGIC; 
  signal N1393 : STD_LOGIC; 
  signal N1265_F5MUX_310 : STD_LOGIC; 
  signal N1409 : STD_LOGIC; 
  signal N1265_BXINV_311 : STD_LOGIC; 
  signal N1265_G : STD_LOGIC; 
  signal reg_i_b_out_0_DXMUX_312 : STD_LOGIC; 
  signal reg_i_b_out_0_F5MUX_313 : STD_LOGIC; 
  signal N1368 : STD_LOGIC; 
  signal reg_i_b_out_0_BXINV_314 : STD_LOGIC; 
  signal N1367 : STD_LOGIC; 
  signal reg_i_b_out_0_SRINV_315 : STD_LOGIC; 
  signal reg_i_b_out_0_CLKINV_316 : STD_LOGIC; 
  signal reg_i_b_out_1_DXMUX_317 : STD_LOGIC; 
  signal reg_i_b_out_1_F5MUX_318 : STD_LOGIC; 
  signal N1376 : STD_LOGIC; 
  signal reg_i_b_out_1_BXINV_319 : STD_LOGIC; 
  signal N1375 : STD_LOGIC; 
  signal reg_i_b_out_1_SRINV_320 : STD_LOGIC; 
  signal reg_i_b_out_1_CLKINV_321 : STD_LOGIC; 
  signal reg_i_b_out_2_DXMUX_322 : STD_LOGIC; 
  signal reg_i_b_out_2_F5MUX_323 : STD_LOGIC; 
  signal N1374 : STD_LOGIC; 
  signal reg_i_b_out_2_BXINV_324 : STD_LOGIC; 
  signal N1373 : STD_LOGIC; 
  signal reg_i_b_out_2_SRINV_325 : STD_LOGIC; 
  signal reg_i_b_out_2_CLKINV_326 : STD_LOGIC; 
  signal reg_i_b_out_3_DXMUX_327 : STD_LOGIC; 
  signal reg_i_b_out_3_F5MUX_328 : STD_LOGIC; 
  signal N1372 : STD_LOGIC; 
  signal reg_i_b_out_3_BXINV_329 : STD_LOGIC; 
  signal N1371 : STD_LOGIC; 
  signal reg_i_b_out_3_SRINV_330 : STD_LOGIC; 
  signal reg_i_b_out_3_CLKINV_331 : STD_LOGIC; 
  signal reg_i_b_out_4_DXMUX_332 : STD_LOGIC; 
  signal reg_i_b_out_4_F5MUX_333 : STD_LOGIC; 
  signal N1370 : STD_LOGIC; 
  signal reg_i_b_out_4_BXINV_334 : STD_LOGIC; 
  signal N1369 : STD_LOGIC; 
  signal reg_i_b_out_4_SRINV_335 : STD_LOGIC; 
  signal reg_i_b_out_4_CLKINV_336 : STD_LOGIC; 
  signal N1332 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000356_SW0_O_pack_1 : STD_LOGIC; 
  signal N1281 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000500_O_pack_1 : STD_LOGIC; 
  signal N1255 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000565_O_pack_1 : STD_LOGIC; 
  signal alu_i_xor0004 : STD_LOGIC; 
  signal alu_i_N7_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_or0001 : STD_LOGIC; 
  signal reg_i_zero_out_or0000_pack_1 : STD_LOGIC; 
  signal alu_i_result_5_map18_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_5_REVUSED_337 : STD_LOGIC; 
  signal reg_i_a_out_5_DYMUX_338 : STD_LOGIC; 
  signal N1231 : STD_LOGIC; 
  signal reg_i_a_out_5_SRINV_339 : STD_LOGIC; 
  signal reg_i_a_out_5_CLKINV_340 : STD_LOGIC; 
  signal alu_i_result_6_map18_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_6_REVUSED_341 : STD_LOGIC; 
  signal reg_i_a_out_6_DYMUX_342 : STD_LOGIC; 
  signal N1230 : STD_LOGIC; 
  signal reg_i_a_out_6_SRINV_343 : STD_LOGIC; 
  signal reg_i_a_out_6_CLKINV_344 : STD_LOGIC; 
  signal alu_i_result_7_map18_pack_1 : STD_LOGIC; 
  signal reg_i_a_out_7_REVUSED_345 : STD_LOGIC; 
  signal reg_i_a_out_7_DYMUX_346 : STD_LOGIC; 
  signal N1229 : STD_LOGIC; 
  signal reg_i_a_out_7_SRINV_347 : STD_LOGIC; 
  signal reg_i_a_out_7_CLKINV_348 : STD_LOGIC; 
  signal reg_i_N0 : STD_LOGIC; 
  signal control_i_pr_state_or000323_pack_1 : STD_LOGIC; 
  signal pc_i_pc_int_cmp_eq0003_349 : STD_LOGIC; 
  signal N547_pack_1 : STD_LOGIC; 
  signal N1291 : STD_LOGIC; 
  signal reg_i_zero_out_mux0000290_O_pack_1 : STD_LOGIC; 
  signal reg_i_carry_out_mux0000117_O_pack_1 : STD_LOGIC; 
  signal reg_i_carry_out_REVUSED_350 : STD_LOGIC; 
  signal reg_i_carry_out_DYMUX_351 : STD_LOGIC; 
  signal N1228 : STD_LOGIC; 
  signal reg_i_carry_out_SRINV_352 : STD_LOGIC; 
  signal reg_i_carry_out_CLKINV_353 : STD_LOGIC; 
  signal alu_i_xor0005 : STD_LOGIC; 
  signal alu_i_xor0006_or0000_pack_1 : STD_LOGIC; 
  signal alu_i_zero_out_or0000_354 : STD_LOGIC; 
  signal N224_pack_1 : STD_LOGIC; 
  signal pc_i_pc_int_0_DXMUX_355 : STD_LOGIC; 
  signal pc_i_pc_int_or0000_pack_1 : STD_LOGIC; 
  signal pc_i_pc_int_0_SRINV_356 : STD_LOGIC; 
  signal pc_i_pc_int_0_CLKINV_357 : STD_LOGIC; 
  signal alu_i_zero_out_or0002_map12 : STD_LOGIC; 
  signal N1318_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000117_358 : STD_LOGIC; 
  signal control_i_pr_state_or0001_map2_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000223_359 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map8_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or0002231 : STD_LOGIC; 
  signal control_i_pr_state_or0002_map5_pack_1 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0004 : STD_LOGIC; 
  signal N1316_pack_1 : STD_LOGIC; 
  signal alu_i_zero_out_cmp_eq0006 : STD_LOGIC; 
  signal alu_i_N22_pack_1 : STD_LOGIC; 
  signal alu_i_N61 : STD_LOGIC; 
  signal control_i_pr_state_or000017_pack_1 : STD_LOGIC; 
  signal control_i_pr_state_or000427_360 : STD_LOGIC; 
  signal N1249_pack_1 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_ICLK1INV_361 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_ICEINV_362 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_IFFDMUX_363 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_ICLK1INV_364 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_ICEINV_365 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_IFFDMUX_366 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_ICLK1INV_367 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_ICEINV_368 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_IFFDMUX_369 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_ICLK1INV_370 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_ICEINV_371 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_IFFDMUX_372 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_ICLK1INV_373 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_ICEINV_374 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_IFFDMUX_375 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_ICLK1INV_376 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_ICEINV_377 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_IFFDMUX_378 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_ICLK1INV_379 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_ICEINV_380 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_IFFDMUX_381 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_ICLK1INV_382 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_ICEINV_383 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_IFFDMUX_384 : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal control_int : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal reg_i_a_out : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal reg_i_b_out : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal ram_control_i_ram_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal reg_i_rom_data_intern : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal alu_i_add_result_int_add0000 : STD_LOGIC_VECTOR ( 7 downto 1 ); 
  signal pc_i_pc_int_addsub0000 : STD_LOGIC_VECTOR ( 7 downto 1 ); 
  signal pc_i_pc_int : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal alu_i_Madd_add_result_int_add0000_cy : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal result_alu_reg : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal control_nxt_int : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal reg_i_b_out_mux0000 : STD_LOGIC_VECTOR ( 7 downto 5 ); 
  signal pc_i_pc_int_mux0002 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
begin
  N1322_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1322,
      O => N1322_0
    );
  N1322_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or00096_SW1_O_pack_1,
      O => control_i_pr_state_or00096_SW1_O
    );
  control_i_pr_state_or00096_SW1 : X_LUT4
    generic map(
      INIT => X"F3F7",
      LOC => "SLICE_X2Y16"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0016,
      ADR1 => control_i_N5,
      ADR2 => control_i_pr_state_FFd26_2,
      ADR3 => control_i_pr_state_cmp_eq0013,
      O => control_i_pr_state_or00096_SW1_O_pack_1
    );
  ram_control_i_ram_data_reg_or0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000,
      O => ram_control_i_ram_data_reg_or0000_0
    );
  ram_control_i_ram_data_reg_or0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1_pack_1,
      O => N1
    );
  ram_control_i_ce_nwr_cmp_eq000011 : X_LUT4
    generic map(
      INIT => X"4040",
      LOC => "SLICE_X20Y5"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => VCC,
      O => N1_pack_1
    );
  reg_i_carry_out_mux0000_map26_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux0000_map26,
      O => reg_i_carry_out_mux0000_map26_0
    );
  reg_i_carry_out_mux0000_map26_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux000023_O_pack_1,
      O => reg_i_carry_out_mux000023_O
    );
  reg_i_carry_out_mux000023 : X_LUT4
    generic map(
      INIT => X"EFFB",
      LOC => "SLICE_X14Y12"
    )
    port map (
      ADR0 => control_int_4_0,
      ADR1 => control_int_3_0,
      ADR2 => control_int(2),
      ADR3 => N1318,
      O => reg_i_carry_out_mux000023_O_pack_1
    );
  N1285_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1285,
      O => N1285_0
    );
  N1285_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0002_pack_1,
      O => alu_i_xor0002
    );
  alu_i_Mxor_xor0002_Result1 : X_LUT4
    generic map(
      INIT => X"2D78",
      LOC => "SLICE_X19Y4"
    )
    port map (
      ADR0 => alu_i_temp_carry_4_or0001_4,
      ADR1 => N1181_0,
      ADR2 => alu_i_N9,
      ADR3 => N1180_0,
      O => alu_i_xor0002_pack_1
    );
  reg_i_zero_out_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000314_O_pack_1,
      O => reg_i_zero_out_mux0000314_O
    );
  reg_i_zero_out_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map0,
      O => reg_i_zero_out_REVUSED_46
    );
  reg_i_zero_out_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X19Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1237,
      O => reg_i_zero_out_DYMUX_47
    );
  reg_i_zero_out_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X19Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_zero_out_SRINV_48
    );
  reg_i_zero_out_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X19Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_zero_out_CLKINV_49
    );
  control_i_pr_state_FFd11_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd11_FXMUX_51,
      O => control_i_pr_state_FFd11_DXMUX_50
    );
  control_i_pr_state_FFd11_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd11_FXMUX_51,
      O => control_i_pr_state_cmp_eq0043_0
    );
  control_i_pr_state_FFd11_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0043,
      O => control_i_pr_state_FFd11_FXMUX_51
    );
  control_i_pr_state_FFd11_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd11_In_SW0_O_pack_1,
      O => control_i_pr_state_FFd11_In_SW0_O
    );
  control_i_pr_state_FFd11_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd11_SRINV_52
    );
  control_i_pr_state_FFd11_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd11_CLKINV_53
    );
  N1310_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1310,
      O => N1310_0
    );
  N1310_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux00005_O_pack_1,
      O => reg_i_zero_out_mux00005_O
    );
  reg_i_zero_out_mux00005 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X16Y6"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => reg_i_a_out(2),
      ADR2 => reg_i_a_out(0),
      ADR3 => reg_i_a_out(3),
      O => reg_i_zero_out_mux00005_O_pack_1
    );
  alu_i_result_0_map17_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_0_map17,
      O => alu_i_result_0_map17_0
    );
  alu_i_result_0_map17_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_0_41_SW0_O_pack_1,
      O => alu_i_result_0_41_SW0_O
    );
  alu_i_result_0_41_SW0 : X_LUT4
    generic map(
      INIT => X"8010",
      LOC => "SLICE_X11Y5"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N61_0,
      ADR3 => control_int(2),
      O => alu_i_result_0_41_SW0_O_pack_1
    );
  alu_i_result_0_map8_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_0_map8,
      O => alu_i_result_0_map8_0
    );
  alu_i_result_0_map8_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_0_4_O_pack_1,
      O => alu_i_result_0_4_O
    );
  alu_i_result_0_4 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X12Y5"
    )
    port map (
      ADR0 => alu_i_zero_out_or0001_0,
      ADR1 => reg_i_carry_out_3,
      ADR2 => alu_i_zero_out_cmp_eq0010_0,
      ADR3 => ram_control_i_ram_data_reg(0),
      O => alu_i_result_0_4_O_pack_1
    );
  alu_i_N1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N1,
      O => alu_i_N1_0
    );
  alu_i_N1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or000234_SW0_O_pack_1,
      O => alu_i_zero_out_or000234_SW0_O
    );
  alu_i_zero_out_or000234_SW0 : X_LUT4
    generic map(
      INIT => X"F000",
      LOC => "SLICE_X11Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => control_int_3_0,
      ADR3 => reg_i_N0_0,
      O => alu_i_zero_out_or000234_SW0_O_pack_1
    );
  alu_i_result_1_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_map7,
      O => alu_i_result_1_map7_0
    );
  alu_i_result_1_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_111_SW0_O_pack_1,
      O => alu_i_result_1_111_SW0_O
    );
  alu_i_result_1_111_SW0 : X_LUT4
    generic map(
      INIT => X"8800",
      LOC => "SLICE_X11Y10"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => reg_i_b_out(1),
      ADR2 => VCC,
      ADR3 => alu_i_zero_out_cmp_eq0002_0,
      O => alu_i_result_1_111_SW0_O_pack_1
    );
  alu_i_N3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N3,
      O => alu_i_N3_0
    );
  alu_i_N3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq00101_SW0_O_pack_1,
      O => alu_i_zero_out_cmp_eq00101_SW0_O
    );
  alu_i_zero_out_cmp_eq00101_SW0 : X_LUT4
    generic map(
      INIT => X"F0E0",
      LOC => "SLICE_X13Y9"
    )
    port map (
      ADR0 => control_i_pr_state_or0002_map2_0,
      ADR1 => control_i_pr_state_or0002_map8,
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_i_pr_state_or0002_map5,
      O => alu_i_zero_out_cmp_eq00101_SW0_O_pack_1
    );
  N620_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N620,
      O => N620_0
    );
  N620_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_and0000_pack_1,
      O => reg_i_b_out_and0000
    );
  reg_i_b_out_and00001 : X_LUT4
    generic map(
      INIT => X"1000",
      LOC => "SLICE_X17Y6"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_0_0,
      ADR2 => control_int_4_0,
      ADR3 => control_int_1_0,
      O => reg_i_b_out_and0000_pack_1
    );
  alu_i_result_2_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_map7,
      O => alu_i_result_2_map7_0
    );
  alu_i_result_2_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_4_SW0_O_pack_1,
      O => alu_i_result_2_4_SW0_O
    );
  alu_i_result_2_4_SW0 : X_LUT4
    generic map(
      INIT => X"6060",
      LOC => "SLICE_X13Y11"
    )
    port map (
      ADR0 => reg_i_b_out(2),
      ADR1 => reg_i_a_out(2),
      ADR2 => alu_i_zero_out_cmp_eq0004_0,
      ADR3 => VCC,
      O => alu_i_result_2_4_SW0_O_pack_1
    );
  alu_i_result_1_map19_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_map19,
      O => alu_i_result_1_map19_0
    );
  alu_i_result_1_map19_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_44_O_pack_1,
      O => alu_i_result_1_44_O
    );
  alu_i_result_1_44 : X_LUT4
    generic map(
      INIT => X"BA30",
      LOC => "SLICE_X10Y9"
    )
    port map (
      ADR0 => alu_i_zero_out_or0001_0,
      ADR1 => reg_i_a_out(1),
      ADR2 => alu_i_zero_out_cmp_eq0000_0,
      ADR3 => ram_control_i_ram_data_reg(1),
      O => alu_i_result_1_44_O_pack_1
    );
  alu_i_result_2_map12_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_map12,
      O => alu_i_result_2_map12_0
    );
  alu_i_result_2_map12_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0012_pack_1,
      O => alu_i_zero_out_cmp_eq0012
    );
  alu_i_zero_out_cmp_eq00121 : X_LUT4
    generic map(
      INIT => X"A000",
      LOC => "SLICE_X8Y9"
    )
    port map (
      ADR0 => control_i_pr_state_or000323_9,
      ADR1 => VCC,
      ADR2 => alu_i_N61_0,
      ADR3 => control_int(2),
      O => alu_i_zero_out_cmp_eq0012_pack_1
    );
  alu_i_result_2_map19_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_map19,
      O => alu_i_result_2_map19_0
    );
  alu_i_result_2_map19_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_44_O_pack_1,
      O => alu_i_result_2_44_O
    );
  alu_i_result_2_44 : X_LUT4
    generic map(
      INIT => X"F444",
      LOC => "SLICE_X8Y8"
    )
    port map (
      ADR0 => reg_i_a_out(2),
      ADR1 => alu_i_zero_out_cmp_eq0000_0,
      ADR2 => alu_i_zero_out_or0001_0,
      ADR3 => ram_control_i_ram_data_reg(2),
      O => alu_i_result_2_44_O_pack_1
    );
  alu_i_result_4_map18_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_map18,
      O => alu_i_result_4_map18_0
    );
  alu_i_result_4_map18_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or0002_pack_1,
      O => alu_i_zero_out_or0002
    );
  alu_i_zero_out_or000234 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X12Y9"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_zero_out_or0002_map12_0,
      ADR2 => alu_i_zero_out_or0002_map7_0,
      ADR3 => reg_i_N0_0,
      O => alu_i_zero_out_or0002_pack_1
    );
  alu_i_result_5_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y1",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_map7,
      O => alu_i_result_5_map7_0
    );
  alu_i_result_5_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y1",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_8_O_pack_1,
      O => alu_i_result_5_8_O
    );
  alu_i_result_5_8 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X16Y1"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N61_0,
      ADR3 => alu_i_add_result_int_add0000(5),
      O => alu_i_result_5_8_O_pack_1
    );
  N1283_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1283,
      O => N1283_0
    );
  N1283_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0001_pack_1,
      O => alu_i_xor0001
    );
  alu_i_Mxor_xor0001_Result1 : X_LUT4
    generic map(
      INIT => X"17E8",
      LOC => "SLICE_X19Y3"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => alu_i_temp_carry_6_or0001_0,
      ADR2 => reg_i_b_out(5),
      ADR3 => alu_i_N10_0,
      O => alu_i_xor0001_pack_1
    );
  alu_i_result_5_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_map15,
      O => alu_i_result_5_map15_0
    );
  alu_i_result_5_map15_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_36_SW0_O_pack_1,
      O => alu_i_result_5_36_SW0_O
    );
  alu_i_result_5_36_SW0 : X_LUT4
    generic map(
      INIT => X"2000",
      LOC => "SLICE_X14Y3"
    )
    port map (
      ADR0 => control_int_1_0,
      ADR1 => control_int(2),
      ADR2 => alu_i_N71,
      ADR3 => reg_i_a_out(5),
      O => alu_i_result_5_36_SW0_O_pack_1
    );
  alu_i_result_6_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_map7,
      O => alu_i_result_6_map7_0
    );
  alu_i_result_6_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_8_O_pack_1,
      O => alu_i_result_6_8_O
    );
  alu_i_result_6_8 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X16Y5"
    )
    port map (
      ADR0 => control_int_1_0,
      ADR1 => alu_i_add_result_int_add0000(6),
      ADR2 => alu_i_N61_0,
      ADR3 => control_int(2),
      O => alu_i_result_6_8_O_pack_1
    );
  alu_i_result_6_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_map15,
      O => alu_i_result_6_map15_0
    );
  alu_i_result_6_map15_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_36_SW0_O_pack_1,
      O => alu_i_result_6_36_SW0_O
    );
  alu_i_result_6_36_SW0 : X_LUT4
    generic map(
      INIT => X"0080",
      LOC => "SLICE_X16Y3"
    )
    port map (
      ADR0 => reg_i_a_out(6),
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N71,
      ADR3 => control_int(2),
      O => alu_i_result_6_36_SW0_O_pack_1
    );
  alu_i_result_7_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_map7,
      O => alu_i_result_7_map7_0
    );
  alu_i_result_7_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_8_O_pack_1,
      O => alu_i_result_7_8_O
    );
  alu_i_result_7_8 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X18Y3"
    )
    port map (
      ADR0 => control_int_1_0,
      ADR1 => alu_i_add_result_int_add0000(7),
      ADR2 => alu_i_N61_0,
      ADR3 => control_int(2),
      O => alu_i_result_7_8_O_pack_1
    );
  alu_i_result_7_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_map15,
      O => alu_i_result_7_map15_0
    );
  alu_i_result_7_map15_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_36_SW0_O_pack_1,
      O => alu_i_result_7_36_SW0_O
    );
  alu_i_result_7_36_SW0 : X_LUT4
    generic map(
      INIT => X"4000",
      LOC => "SLICE_X17Y3"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => alu_i_N71,
      ADR2 => reg_i_a_out(7),
      ADR3 => control_int_1_0,
      O => alu_i_result_7_36_SW0_O_pack_1
    );
  alu_i_xor0003_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0003,
      O => alu_i_xor0003_0
    );
  alu_i_xor0003_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N8_pack_1,
      O => alu_i_N8
    );
  alu_i_Madd_add_result_int_add0000_lut_4_Q : X_LUT4
    generic map(
      INIT => X"0FF0",
      LOC => "SLICE_X18Y7"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => reg_i_a_out(4),
      ADR3 => reg_i_b_out(4),
      O => alu_i_N8_pack_1
    );
  alu_i_result_3_map4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_map4,
      O => alu_i_result_3_map4_0
    );
  alu_i_result_3_map4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_8_SW0_O_pack_1,
      O => alu_i_result_3_8_SW0_O
    );
  alu_i_result_3_8_SW0 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X15Y7"
    )
    port map (
      ADR0 => alu_i_add_result_int_add0000(3),
      ADR1 => alu_i_zero_out_cmp_eq0006_0,
      ADR2 => reg_i_b_out(3),
      ADR3 => alu_i_zero_out_cmp_eq0012,
      O => alu_i_result_3_8_SW0_O_pack_1
    );
  alu_i_result_4_map4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_map4,
      O => alu_i_result_4_map4_0
    );
  alu_i_result_4_map4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_8_SW0_O_pack_1,
      O => alu_i_result_4_8_SW0_O
    );
  alu_i_result_4_8_SW0 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X14Y7"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0012,
      ADR1 => reg_i_b_out(4),
      ADR2 => alu_i_zero_out_cmp_eq0006_0,
      ADR3 => alu_i_add_result_int_add0000(4),
      O => alu_i_result_4_8_SW0_O_pack_1
    );
  N1287_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1287,
      O => N1287_0
    );
  N1287_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y3",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0000_pack_1,
      O => alu_i_xor0000
    );
  alu_i_Mxor_xor0000_Result1 : X_LUT4
    generic map(
      INIT => X"56A6",
      LOC => "SLICE_X20Y3"
    )
    port map (
      ADR0 => alu_i_N11_0,
      ADR1 => N1177_0,
      ADR2 => alu_i_temp_carry_6_or0001_0,
      ADR3 => N1178,
      O => alu_i_xor0000_pack_1
    );
  control_int_4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(4),
      O => control_int_4_0
    );
  control_int_4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0000_map6_pack_1,
      O => control_i_pr_state_or0000_map6
    );
  control_i_pr_state_or000010 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd22_13,
      ADR1 => control_i_pr_state_FFd24_14,
      ADR2 => control_i_pr_state_FFd19_12,
      ADR3 => control_i_pr_state_FFd25_15,
      O => control_i_pr_state_or0000_map6_pack_1
    );
  control_int_3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(3),
      O => control_int_3_0
    );
  control_int_3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0001_map6_pack_1,
      O => control_i_pr_state_or0001_map6
    );
  control_i_pr_state_or000110 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y13"
    )
    port map (
      ADR0 => control_i_pr_state_FFd15_19,
      ADR1 => control_i_pr_state_FFd23_18,
      ADR2 => control_i_pr_state_FFd21_17,
      ADR3 => control_i_pr_state_FFd25_15,
      O => control_i_pr_state_or0001_map6_pack_1
    );
  control_int_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(1),
      O => control_int_1_0
    );
  control_int_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0003_map8_pack_1,
      O => control_i_pr_state_or0003_map8
    );
  control_i_pr_state_or000314 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y12"
    )
    port map (
      ADR0 => control_i_pr_state_FFd2_20,
      ADR1 => control_i_pr_state_FFd24_14,
      ADR2 => control_i_pr_state_FFd3_21,
      ADR3 => control_i_pr_state_FFd19_12,
      O => control_i_pr_state_or0003_map8_pack_1
    );
  control_i_pr_state_or0005_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0005_map7,
      O => control_i_pr_state_or0005_map7_0
    );
  control_i_pr_state_or0005_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or00059_O_pack_1,
      O => control_i_pr_state_or00059_O
    );
  control_i_pr_state_or00059 : X_LUT4
    generic map(
      INIT => X"FFFA",
      LOC => "SLICE_X2Y18"
    )
    port map (
      ADR0 => control_i_pr_state_FFd20_24,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_FFd13_23,
      ADR3 => control_i_pr_state_FFd14_22,
      O => control_i_pr_state_or00059_O_pack_1
    );
  control_int_0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(0),
      O => control_int_0_0
    );
  control_int_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0004_map6_pack_1,
      O => control_i_pr_state_or0004_map6
    );
  control_i_pr_state_or000412 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd14_22,
      ADR1 => control_i_pr_state_FFd13_23,
      ADR2 => control_i_pr_state_FFd18_11,
      ADR3 => control_i_pr_state_FFd16_10,
      O => control_i_pr_state_or0004_map6_pack_1
    );
  N1251_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1251,
      O => N1251_0
    );
  N1251_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000500_SW0_SW1_O_pack_1,
      O => reg_i_zero_out_mux0000500_SW0_SW1_O
    );
  reg_i_zero_out_mux0000500_SW0_SW1 : X_LUT4
    generic map(
      INIT => X"030F",
      LOC => "SLICE_X16Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_zero_out_mux0000_map123_0,
      ADR2 => control_int_0_0,
      ADR3 => reg_i_zero_out_mux0000_map130_0,
      O => reg_i_zero_out_mux0000500_SW0_SW1_O_pack_1
    );
  control_nxt_int_3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_nxt_int(3),
      O => control_nxt_int_3_0
    );
  control_nxt_int_3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000615_O_pack_1,
      O => control_i_pr_state_or000615_O
    );
  control_i_pr_state_or000615 : X_LUT4
    generic map(
      INIT => X"FEEE",
      LOC => "SLICE_X4Y18"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0057_0,
      ADR1 => control_i_pr_state_cmp_eq0053_0,
      ADR2 => control_i_N12_0,
      ADR3 => control_i_pr_state_or0006_map5_0,
      O => control_i_pr_state_or000615_O_pack_1
    );
  control_nxt_int_2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_nxt_int(2),
      O => control_nxt_int_2_0
    );
  control_nxt_int_2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000726_SW0_O_pack_1,
      O => control_i_pr_state_or000726_SW0_O
    );
  control_i_pr_state_or000726_SW0 : X_LUT4
    generic map(
      INIT => X"A888",
      LOC => "SLICE_X2Y17"
    )
    port map (
      ADR0 => control_i_N11,
      ADR1 => control_i_N6,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_N7_0,
      O => control_i_pr_state_or000726_SW0_O_pack_1
    );
  control_nxt_int_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_nxt_int(1),
      O => control_nxt_int_1_0
    );
  control_nxt_int_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000827_SW0_O_pack_1,
      O => control_i_pr_state_or000827_SW0_O
    );
  control_i_pr_state_or000827_SW0 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y19"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0045,
      ADR1 => control_i_pr_state_FFd18_11,
      ADR2 => control_i_pr_state_FFd12_26,
      ADR3 => control_i_pr_state_FFd14_22,
      O => control_i_pr_state_or000827_SW0_O_pack_1
    );
  control_i_pr_state_or0008_map11_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0008_map11,
      O => control_i_pr_state_or0008_map11_0
    );
  control_i_pr_state_or0008_map11_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N11_pack_1,
      O => control_i_N11
    );
  control_i_pr_state_FFd1_In11 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X3Y17"
    )
    port map (
      ADR0 => prog_data_7_IBUF_28,
      ADR1 => prog_data_6_IBUF_29,
      ADR2 => prog_data_5_IBUF_27,
      ADR3 => control_i_pr_state_FFd26_2,
      O => control_i_N11_pack_1
    );
  control_nxt_int_0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_nxt_int(0),
      O => control_nxt_int_0_0
    );
  control_nxt_int_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000923_O_pack_1,
      O => control_i_pr_state_or000923_O
    );
  control_i_pr_state_or000923 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y16"
    )
    port map (
      ADR0 => control_i_pr_state_or0009_map8_0,
      ADR1 => control_i_pr_state_or0009_map5_0,
      ADR2 => control_i_pr_state_cmp_eq0067_0,
      ADR3 => control_i_pr_state_cmp_eq0054_0,
      O => control_i_pr_state_or000923_O_pack_1
    );
  alu_i_temp_carry_6_or0001_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_temp_carry_6_or0001_54,
      O => alu_i_temp_carry_6_or0001_0
    );
  alu_i_temp_carry_6_or0001_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X20Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_temp_carry_4_or0001_pack_1,
      O => alu_i_temp_carry_4_or0001_4
    );
  alu_i_temp_carry_4_or0001 : X_LUT4
    generic map(
      INIT => X"F5A0",
      LOC => "SLICE_X20Y2"
    )
    port map (
      ADR0 => alu_i_xor0006_or0000,
      ADR1 => VCC,
      ADR2 => N1300_0,
      ADR3 => N1299_0,
      O => alu_i_temp_carry_4_or0001_pack_1
    );
  reg_i_zero_out_mux0000_map39_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map39,
      O => reg_i_zero_out_mux0000_map39_0
    );
  reg_i_zero_out_mux0000_map39_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N9_pack_1,
      O => alu_i_N9
    );
  alu_i_Madd_add_result_int_add0000_lut_5_Q : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X17Y4"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => reg_i_b_out(5),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_N9_pack_1
    );
  reg_i_zero_out_mux0000_map25_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map25,
      O => reg_i_zero_out_mux0000_map25_0
    );
  reg_i_zero_out_mux0000_map25_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux000077_SW0_O_pack_1,
      O => reg_i_zero_out_mux000077_SW0_O
    );
  reg_i_zero_out_mux000077_SW0 : X_LUT4
    generic map(
      INIT => X"1000",
      LOC => "SLICE_X19Y7"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => N1310_0,
      O => reg_i_zero_out_mux000077_SW0_O_pack_1
    );
  reg_i_zero_out_mux0000_map123_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map123,
      O => reg_i_zero_out_mux0000_map123_0
    );
  reg_i_zero_out_mux0000_map123_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000403_O_pack_1,
      O => reg_i_zero_out_mux0000403_O
    );
  reg_i_zero_out_mux0000403 : X_LUT4
    generic map(
      INIT => X"0055",
      LOC => "SLICE_X16Y13"
    )
    port map (
      ADR0 => reg_i_b_out(3),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_b_out(2),
      O => reg_i_zero_out_mux0000403_O_pack_1
    );
  reg_i_zero_out_mux0000_map32_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map32,
      O => reg_i_zero_out_mux0000_map32_0
    );
  reg_i_zero_out_mux0000_map32_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N5_pack_1,
      O => alu_i_N5
    );
  alu_i_Madd_add_result_int_add0000_lut_1_Q : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X14Y11"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_a_out(1),
      ADR2 => reg_i_b_out(1),
      ADR3 => VCC,
      O => alu_i_N5_pack_1
    );
  reg_i_b_out_5_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000(5),
      O => reg_i_b_out_5_DXMUX_55
    );
  reg_i_b_out_5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000_5_SW1_O_pack_1,
      O => reg_i_b_out_mux0000_5_SW1_O
    );
  reg_i_b_out_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_5_SRINV_56
    );
  reg_i_b_out_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_5_CLKINV_57
    );
  reg_i_b_out_6_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X17Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000(6),
      O => reg_i_b_out_6_DXMUX_58
    );
  reg_i_b_out_6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000_6_SW1_O_pack_1,
      O => reg_i_b_out_mux0000_6_SW1_O
    );
  reg_i_b_out_6_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X17Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_6_SRINV_59
    );
  reg_i_b_out_6_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X17Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_6_CLKINV_60
    );
  reg_i_zero_out_mux0000_map155_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map155,
      O => reg_i_zero_out_mux0000_map155_0
    );
  reg_i_zero_out_mux0000_map155_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq00141_SW0_O_pack_1,
      O => alu_i_zero_out_cmp_eq00141_SW0_O
    );
  alu_i_zero_out_cmp_eq00141_SW0 : X_LUT4
    generic map(
      INIT => X"97FE",
      LOC => "SLICE_X19Y8"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => alu_i_xor0006_or0000,
      ADR2 => reg_i_b_out(1),
      ADR3 => alu_i_N6_0,
      O => alu_i_zero_out_cmp_eq00141_SW0_O_pack_1
    );
  reg_i_b_out_7_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X19Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000(7),
      O => reg_i_b_out_7_DXMUX_61
    );
  reg_i_b_out_7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_mux0000_7_SW1_O_pack_1,
      O => reg_i_b_out_mux0000_7_SW1_O
    );
  reg_i_b_out_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X19Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_7_SRINV_62
    );
  reg_i_b_out_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X19Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_7_CLKINV_63
    );
  reg_i_zero_out_mux0000_map146_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map146,
      O => reg_i_zero_out_mux0000_map146_0
    );
  reg_i_zero_out_mux0000_map146_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000478_O_pack_1,
      O => reg_i_zero_out_mux0000478_O
    );
  reg_i_zero_out_mux0000478 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X16Y7"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => reg_i_a_out(2),
      ADR2 => reg_i_a_out(6),
      ADR3 => reg_i_a_out(3),
      O => reg_i_zero_out_mux0000478_O_pack_1
    );
  N84_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_cmp_eq0009_pack_1,
      O => reg_i_a_out_cmp_eq0009_30
    );
  reg_i_a_out_cmp_eq0009 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X13Y8"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => control_int_4_0,
      ADR2 => N1318,
      ADR3 => control_int_3_0,
      O => reg_i_a_out_cmp_eq0009_pack_1
    );
  control_i_pr_state_FFd10_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0008_map12,
      O => control_i_pr_state_or0008_map12_0
    );
  control_i_pr_state_FFd10_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd10_GYMUX_65,
      O => control_i_pr_state_FFd10_DYMUX_64
    );
  control_i_pr_state_FFd10_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd10_GYMUX_65,
      O => control_i_pr_state_cmp_eq0055
    );
  control_i_pr_state_FFd10_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0055_pack_1,
      O => control_i_pr_state_FFd10_GYMUX_65
    );
  control_i_pr_state_FFd10_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd10_SRINV_66
    );
  control_i_pr_state_FFd10_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd10_CLKINV_67
    );
  control_i_pr_state_FFd12_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1289,
      O => N1289_0
    );
  control_i_pr_state_FFd12_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd12_GYMUX_69,
      O => control_i_pr_state_FFd12_DYMUX_68
    );
  control_i_pr_state_FFd12_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd12_GYMUX_69,
      O => control_i_pr_state_cmp_eq0056
    );
  control_i_pr_state_FFd12_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0056_pack_1,
      O => control_i_pr_state_FFd12_GYMUX_69
    );
  control_i_pr_state_FFd12_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd12_SRINV_70
    );
  control_i_pr_state_FFd12_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd12_CLKINV_71
    );
  control_i_pr_state_FFd14_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0009_map8,
      O => control_i_pr_state_or0009_map8_0
    );
  control_i_pr_state_FFd14_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd14_GYMUX_73,
      O => control_i_pr_state_FFd14_DYMUX_72
    );
  control_i_pr_state_FFd14_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd14_GYMUX_73,
      O => control_i_pr_state_cmp_eq0044
    );
  control_i_pr_state_FFd14_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0044_pack_1,
      O => control_i_pr_state_FFd14_GYMUX_73
    );
  control_i_pr_state_FFd14_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd14_SRINV_74
    );
  control_i_pr_state_FFd14_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd14_CLKINV_75
    );
  control_i_pr_state_FFd4_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0061,
      O => control_i_pr_state_FFd4_DXMUX_76
    );
  control_i_pr_state_FFd4_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd4_GYMUX_78,
      O => control_i_pr_state_FFd4_DYMUX_77
    );
  control_i_pr_state_FFd4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd4_GYMUX_78,
      O => control_i_pr_state_cmp_eq0066_0
    );
  control_i_pr_state_FFd4_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0066,
      O => control_i_pr_state_FFd4_GYMUX_78
    );
  control_i_pr_state_FFd4_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd4_SRINV_79
    );
  control_i_pr_state_FFd4_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd4_CLKINV_80
    );
  control_i_pr_state_FFd3_In1 : X_LUT4
    generic map(
      INIT => X"0088",
      LOC => "SLICE_X6Y16"
    )
    port map (
      ADR0 => control_i_N7_0,
      ADR1 => control_i_N11,
      ADR2 => VCC,
      ADR3 => prog_data_0_IBUF_0,
      O => control_i_pr_state_cmp_eq0066
    );
  control_i_pr_state_FFd5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0006_map5,
      O => control_i_pr_state_or0006_map5_0
    );
  control_i_pr_state_FFd5_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0062,
      O => control_i_pr_state_FFd5_DYMUX_81
    );
  control_i_pr_state_FFd5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd5_SRINV_82
    );
  control_i_pr_state_FFd5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd5_CLKINV_83
    );
  control_i_pr_state_FFd8_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd8_FXMUX_85,
      O => control_i_pr_state_FFd8_DXMUX_84
    );
  control_i_pr_state_FFd8_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd8_FXMUX_85,
      O => control_i_pr_state_cmp_eq0053_0
    );
  control_i_pr_state_FFd8_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0053,
      O => control_i_pr_state_FFd8_FXMUX_85
    );
  control_i_pr_state_FFd8_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd8_GYMUX_87,
      O => control_i_pr_state_FFd8_DYMUX_86
    );
  control_i_pr_state_FFd8_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd8_GYMUX_87,
      O => control_i_pr_state_cmp_eq0064_0
    );
  control_i_pr_state_FFd8_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0064,
      O => control_i_pr_state_FFd8_GYMUX_87
    );
  control_i_pr_state_FFd8_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd8_SRINV_88
    );
  control_i_pr_state_FFd8_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd8_CLKINV_89
    );
  control_i_pr_state_FFd9_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_In_map17,
      O => control_i_pr_state_FFd26_In_map17_0
    );
  control_i_pr_state_FFd9_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd9_GYMUX_91,
      O => control_i_pr_state_FFd9_DYMUX_90
    );
  control_i_pr_state_FFd9_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd9_GYMUX_91,
      O => control_i_pr_state_cmp_eq0054_0
    );
  control_i_pr_state_FFd9_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0054,
      O => control_i_pr_state_FFd9_GYMUX_91
    );
  control_i_pr_state_FFd9_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd9_SRINV_92
    );
  control_i_pr_state_FFd9_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd9_CLKINV_93
    );
  pc_i_pc_int_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N7,
      O => control_i_N7_0
    );
  pc_i_pc_int_1_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(1),
      O => pc_i_pc_int_1_DYMUX_94
    );
  pc_i_pc_int_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => pc_i_pc_int_1_SRINV_95
    );
  pc_i_pc_int_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => pc_i_pc_int_1_CLKINV_96
    );
  pc_i_pc_int_mux0002_1_1 : X_LUT4
    generic map(
      INIT => X"D8D8",
      LOC => "SLICE_X4Y16"
    )
    port map (
      ADR0 => pc_i_pc_int_or0000_38,
      ADR1 => prog_data_1_IBUF_8,
      ADR2 => pc_i_pc_int_addsub0000(1),
      ADR3 => VCC,
      O => pc_i_pc_int_mux0002(1)
    );
  pc_i_pc_int_3_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(3),
      O => pc_i_pc_int_3_DXMUX_97
    );
  pc_i_pc_int_3_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(2),
      O => pc_i_pc_int_3_DYMUX_98
    );
  pc_i_pc_int_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => pc_i_pc_int_3_SRINV_99
    );
  pc_i_pc_int_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => pc_i_pc_int_3_CLKINV_100
    );
  pc_i_pc_int_mux0002_2_1 : X_LUT4
    generic map(
      INIT => X"BB88",
      LOC => "SLICE_X8Y18"
    )
    port map (
      ADR0 => prog_data_2_IBUF_34,
      ADR1 => pc_i_pc_int_or0000_38,
      ADR2 => VCC,
      ADR3 => pc_i_pc_int_addsub0000(2),
      O => pc_i_pc_int_mux0002(2)
    );
  pc_i_pc_int_5_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(5),
      O => pc_i_pc_int_5_DXMUX_101
    );
  pc_i_pc_int_5_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(4),
      O => pc_i_pc_int_5_DYMUX_102
    );
  pc_i_pc_int_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => pc_i_pc_int_5_SRINV_103
    );
  pc_i_pc_int_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => pc_i_pc_int_5_CLKINV_104
    );
  pc_i_pc_int_mux0002_4_1 : X_LUT4
    generic map(
      INIT => X"FC30",
      LOC => "SLICE_X8Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => pc_i_pc_int_or0000_38,
      ADR2 => pc_i_pc_int_addsub0000(4),
      ADR3 => prog_data_4_IBUF_39,
      O => pc_i_pc_int_mux0002(4)
    );
  pc_i_pc_int_7_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(7),
      O => pc_i_pc_int_7_DXMUX_105
    );
  pc_i_pc_int_7_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(6),
      O => pc_i_pc_int_7_DYMUX_106
    );
  pc_i_pc_int_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => pc_i_pc_int_7_SRINV_107
    );
  pc_i_pc_int_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => pc_i_pc_int_7_CLKINV_108
    );
  pc_i_pc_int_mux0002_6_1 : X_LUT4
    generic map(
      INIT => X"FA50",
      LOC => "SLICE_X6Y18"
    )
    port map (
      ADR0 => pc_i_pc_int_or0000_38,
      ADR1 => VCC,
      ADR2 => pc_i_pc_int_addsub0000(6),
      ADR3 => prog_data_6_IBUF_29,
      O => pc_i_pc_int_mux0002(6)
    );
  alu_i_N6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N6,
      O => alu_i_N6_0
    );
  alu_i_N6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1355,
      O => N1355_0
    );
  alu_i_result_2_11_SW0 : X_LUT4
    generic map(
      INIT => X"FF7F",
      LOC => "SLICE_X15Y11"
    )
    port map (
      ADR0 => reg_i_b_out(2),
      ADR1 => reg_i_a_out(2),
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_i_pr_state_or0002231_0,
      O => N1355
    );
  reg_i_a_out_mux0000_5_SW0 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X17Y2"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(5),
      ADR1 => reg_i_a_out_or0001_0,
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_a_out(5),
      O => N312
    );
  reg_i_a_out_mux0000_6_SW0 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X12Y8"
    )
    port map (
      ADR0 => reg_i_a_out_or0001_0,
      ADR1 => reg_i_a_out_cmp_eq0009_30,
      ADR2 => reg_i_rom_data_intern(6),
      ADR3 => reg_i_a_out(6),
      O => N310
    );
  N1320_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1320,
      O => N1320_0
    );
  pc_i_pc_int_cmp_eq0003_SW1 : X_LUT4
    generic map(
      INIT => X"000F",
      LOC => "SLICE_X5Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => control_nxt_int_2_0,
      ADR3 => control_nxt_int_1_0,
      O => N1320
    );
  control_i_pr_state_FFd1_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd1_FXMUX_110,
      O => control_i_pr_state_FFd1_DXMUX_109
    );
  control_i_pr_state_FFd1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd1_FXMUX_110,
      O => control_i_pr_state_cmp_eq0067_0
    );
  control_i_pr_state_FFd1_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0067,
      O => control_i_pr_state_FFd1_FXMUX_110
    );
  control_i_pr_state_FFd1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1302_pack_1,
      O => N1302
    );
  control_i_pr_state_FFd1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd1_SRINV_111
    );
  control_i_pr_state_FFd1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd1_CLKINV_112
    );
  N1275_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1275,
      O => N1275_0
    );
  N1275_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1304_pack_1,
      O => N1304
    );
  control_i_pr_state_FFd1_In11_SW1 : X_LUT4
    generic map(
      INIT => X"FFBF",
      LOC => "SLICE_X3Y18"
    )
    port map (
      ADR0 => prog_data_2_IBUF_34,
      ADR1 => prog_data_3_IBUF_33,
      ADR2 => prog_data_5_IBUF_27,
      ADR3 => prog_data_1_IBUF_8,
      O => N1304_pack_1
    );
  control_i_pr_state_FFd22_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd16_10,
      O => control_i_pr_state_FFd22_DXMUX_113
    );
  control_i_pr_state_FFd22_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd9_25,
      O => control_i_pr_state_FFd22_DYMUX_114
    );
  control_i_pr_state_FFd22_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd22_SRINV_115
    );
  control_i_pr_state_FFd22_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd22_CLKINV_116
    );
  control_i_pr_state_FFd24_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd18_11,
      O => control_i_pr_state_FFd24_DXMUX_117
    );
  control_i_pr_state_FFd24_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd10_16,
      O => control_i_pr_state_FFd24_DYMUX_118
    );
  control_i_pr_state_FFd24_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd24_SRINV_119
    );
  control_i_pr_state_FFd24_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd24_CLKINV_120
    );
  control_i_pr_state_FFd15_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd12_26,
      O => control_i_pr_state_FFd15_DXMUX_121
    );
  control_i_pr_state_FFd15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0005_map1,
      O => control_i_pr_state_or0005_map1_0
    );
  control_i_pr_state_FFd15_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd15_GYMUX_123,
      O => control_i_pr_state_FFd15_DYMUX_122
    );
  control_i_pr_state_FFd15_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd15_GYMUX_123,
      O => control_i_pr_state_cmp_eq0045
    );
  control_i_pr_state_FFd15_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0045_pack_1,
      O => control_i_pr_state_FFd15_GYMUX_123
    );
  control_i_pr_state_FFd15_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd15_SRINV_124
    );
  control_i_pr_state_FFd15_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd15_CLKINV_125
    );
  control_i_pr_state_FFd26_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_FXMUX_127,
      O => control_i_pr_state_FFd26_DXMUX_126
    );
  control_i_pr_state_FFd26_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_In,
      O => control_i_pr_state_FFd26_FXMUX_127
    );
  control_i_pr_state_FFd26_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd20_24,
      O => control_i_pr_state_FFd26_DYMUX_128
    );
  control_i_pr_state_FFd26_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_In_map5_pack_1,
      O => control_i_pr_state_FFd26_In_map5
    );
  control_i_pr_state_FFd26_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd26_SRINV_129
    );
  control_i_pr_state_FFd26_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd26_CLKINV_130
    );
  control_i_pr_state_FFd17_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd13_23,
      O => control_i_pr_state_FFd17_DXMUX_131
    );
  control_i_pr_state_FFd17_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1253,
      O => N1253_0
    );
  control_i_pr_state_FFd17_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd17_GYMUX_133,
      O => control_i_pr_state_FFd17_DYMUX_132
    );
  control_i_pr_state_FFd17_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd17_GYMUX_133,
      O => control_i_pr_state_cmp_eq0046
    );
  control_i_pr_state_FFd17_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0046_pack_1,
      O => control_i_pr_state_FFd17_GYMUX_133
    );
  control_i_pr_state_FFd17_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd17_SRINV_134
    );
  control_i_pr_state_FFd17_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd17_CLKINV_135
    );
  control_i_pr_state_FFd20_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd20_FXMUX_137,
      O => control_i_pr_state_FFd20_DXMUX_136
    );
  control_i_pr_state_FFd20_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd20_FXMUX_137,
      O => control_i_pr_state_cmp_eq0047_0
    );
  control_i_pr_state_FFd20_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0047,
      O => control_i_pr_state_FFd20_FXMUX_137
    );
  control_i_pr_state_FFd20_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd14_22,
      O => control_i_pr_state_FFd20_DYMUX_138
    );
  control_i_pr_state_FFd20_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0016_pack_1,
      O => control_i_pr_state_cmp_eq0016
    );
  control_i_pr_state_FFd20_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd20_SRINV_139
    );
  control_i_pr_state_FFd20_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd20_CLKINV_140
    );
  control_i_pr_state_or0009_map5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0009_map5,
      O => control_i_pr_state_or0009_map5_0
    );
  control_i_pr_state_or0009_map5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1259_pack_1,
      O => N1259
    );
  control_i_pr_state_or000912_SW0 : X_LUT4
    generic map(
      INIT => X"0003",
      LOC => "SLICE_X3Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => N166_0,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => prog_data_3_IBUF_33,
      O => N1259_pack_1
    );
  reg_i_carry_out_mux00000 : X_LUT4
    generic map(
      INIT => X"CC00",
      LOC => "SLICE_X18Y11"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_carry_out_3,
      ADR2 => VCC,
      ADR3 => reg_i_zero_out_or0000,
      O => reg_i_carry_out_mux0000_map0
    );
  N65_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => N65,
      O => N65_0
    );
  pc_i_pc_int_or0000_SW0 : X_LUT4
    generic map(
      INIT => X"FFEF",
      LOC => "SLICE_X7Y19"
    )
    port map (
      ADR0 => control_i_pr_state_or0005_map1_0,
      ADR1 => control_i_pr_state_or0005_map7_0,
      ADR2 => control_nxt_int_3_0,
      ADR3 => control_i_pr_state_cmp_eq0043_0,
      O => N65
    );
  N1351_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1351,
      O => N1351_0
    );
  N1351_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1353,
      O => N1353_0
    );
  alu_i_result_3_44_SW0 : X_LUT4
    generic map(
      INIT => X"FF7F",
      LOC => "SLICE_X8Y10"
    )
    port map (
      ADR0 => reg_i_b_out(3),
      ADR1 => reg_i_a_out(3),
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_i_pr_state_or0002231_0,
      O => N1353
    );
  reg_i_zero_out_mux0000_map88_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map88,
      O => reg_i_zero_out_mux0000_map88_0
    );
  reg_i_zero_out_mux0000_map88_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N12,
      O => control_i_N12_0
    );
  control_i_pr_state_FFd10_In11 : X_LUT4
    generic map(
      INIT => X"0200",
      LOC => "SLICE_X7Y10"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => control_i_pr_state_FFd26_1_31,
      ADR2 => prog_data_7_IBUF_28,
      ADR3 => prog_data_5_IBUF_27,
      O => control_i_N12
    );
  alu_i_zero_out_cmp_eq0010_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0010,
      O => alu_i_zero_out_cmp_eq0010_0
    );
  alu_i_zero_out_cmp_eq0010_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N71_pack_1,
      O => alu_i_N71
    );
  alu_i_zero_out_or000214 : X_LUT4
    generic map(
      INIT => X"0003",
      LOC => "SLICE_X9Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or000427_0,
      ADR2 => control_i_pr_state_or000017_42,
      ADR3 => control_i_pr_state_or000117_0,
      O => alu_i_N71_pack_1
    );
  reg_i_carry_out_mux0000_map24_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux0000_map24,
      O => reg_i_carry_out_mux0000_map24_0
    );
  reg_i_carry_out_mux0000_map24_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or0002_map7,
      O => alu_i_zero_out_or0002_map7_0
    );
  alu_i_zero_out_or000216 : X_LUT4
    generic map(
      INIT => X"8200",
      LOC => "SLICE_X10Y12"
    )
    port map (
      ADR0 => control_int_0_0,
      ADR1 => control_i_pr_state_or0002231_0,
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_int_4_0,
      O => alu_i_zero_out_or0002_map7
    );
  ram_control_i_ce_nrd1 : X_LUT4
    generic map(
      INIT => X"EFBF",
      LOC => "SLICE_X20Y4"
    )
    port map (
      ADR0 => clk_IBUF1,
      ADR1 => control_int_1_0,
      ADR2 => N1,
      ADR3 => control_int(2),
      O => datmem_nrd_OBUF_142
    );
  alu_i_zero_out_cmp_eq0002_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0002,
      O => alu_i_zero_out_cmp_eq0002_0
    );
  alu_i_zero_out_cmp_eq0002_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0000,
      O => alu_i_zero_out_cmp_eq0000_0
    );
  alu_i_zero_out_cmp_eq00002 : X_LUT4
    generic map(
      INIT => X"0044",
      LOC => "SLICE_X9Y8"
    )
    port map (
      ADR0 => control_i_pr_state_or0002231_0,
      ADR1 => alu_i_N61_0,
      ADR2 => VCC,
      ADR3 => control_int_1_0,
      O => alu_i_zero_out_cmp_eq0000
    );
  N1257_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1257,
      O => N1257_0
    );
  N1257_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0014,
      O => alu_i_zero_out_cmp_eq0014_0
    );
  alu_i_zero_out_cmp_eq00141 : X_LUT4
    generic map(
      INIT => X"5500",
      LOC => "SLICE_X7Y11"
    )
    port map (
      ADR0 => reg_i_N0_0,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => control_int_3_0,
      O => alu_i_zero_out_cmp_eq0014
    );
  N1263_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1263,
      O => N1263_0
    );
  N1263_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0012_pack_1,
      O => control_i_pr_state_cmp_eq0012
    );
  control_i_pr_state_cmp_eq00121 : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X4Y10"
    )
    port map (
      ADR0 => prog_data_1_IBUF_8,
      ADR1 => prog_data_2_IBUF_34,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => prog_data_0_IBUF_0,
      O => control_i_pr_state_cmp_eq0012_pack_1
    );
  control_i_pr_state_FFd13_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd13_FXMUX_144,
      O => control_i_pr_state_FFd13_DXMUX_143
    );
  control_i_pr_state_FFd13_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd13_FXMUX_144,
      O => control_i_pr_state_cmp_eq0057_0
    );
  control_i_pr_state_FFd13_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0057,
      O => control_i_pr_state_FFd13_FXMUX_144
    );
  control_i_pr_state_FFd13_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0013_pack_1,
      O => control_i_pr_state_cmp_eq0013
    );
  control_i_pr_state_FFd13_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd13_SRINV_145
    );
  control_i_pr_state_FFd13_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd13_CLKINV_146
    );
  reg_i_zero_out_mux0000_map81_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map81,
      O => reg_i_zero_out_mux0000_map81_0
    );
  reg_i_zero_out_mux0000_map81_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0015,
      O => control_i_pr_state_cmp_eq0015_0
    );
  control_i_pr_state_cmp_eq00151 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X6Y11"
    )
    port map (
      ADR0 => prog_data_1_IBUF_8,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => prog_data_2_IBUF_34,
      O => control_i_pr_state_cmp_eq0015
    );
  N166_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N166,
      O => N166_0
    );
  N166_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0007_pack_1,
      O => control_i_pr_state_cmp_eq0007
    );
  control_i_pr_state_cmp_eq00071 : X_LUT4
    generic map(
      INIT => X"1100",
      LOC => "SLICE_X3Y11"
    )
    port map (
      ADR0 => prog_data_5_IBUF_27,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => VCC,
      ADR3 => prog_data_6_IBUF_29,
      O => control_i_pr_state_cmp_eq0007_pack_1
    );
  N1267_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1267,
      O => N1267_0
    );
  N1267_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0009_pack_1,
      O => control_i_pr_state_cmp_eq0009
    );
  control_i_pr_state_cmp_eq00091 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X4Y11"
    )
    port map (
      ADR0 => prog_data_1_IBUF_8,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => prog_data_2_IBUF_34,
      O => control_i_pr_state_cmp_eq0009_pack_1
    );
  N1278_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1278,
      O => N1278_0
    );
  N1278_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1357,
      O => N1357_0
    );
  control_i_pr_state_FFd26_In11_SW0 : X_LUT4
    generic map(
      INIT => X"C888",
      LOC => "SLICE_X2Y19"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0016,
      ADR1 => control_i_N5,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_pr_state_cmp_eq0013,
      O => N1357
    );
  rst_int_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int,
      O => rst_int_0
    );
  rst_int1 : X_LUT4
    generic map(
      INIT => X"33FF",
      LOC => "SLICE_X0Y0"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nreset_int_IBUF_44,
      ADR2 => VCC,
      ADR3 => nreset_IBUF_43,
      O => rst_int
    );
  N1181_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X21Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1181,
      O => N1181_0
    );
  N1181_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X21Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1180,
      O => N1180_0
    );
  alu_i_temp_carry_6_or0001_SW0 : X_LUT4
    generic map(
      INIT => X"E8A0",
      LOC => "SLICE_X21Y4"
    )
    port map (
      ADR0 => reg_i_b_out(4),
      ADR1 => reg_i_a_out(3),
      ADR2 => reg_i_a_out(4),
      ADR3 => reg_i_b_out(3),
      O => N1180
    );
  control_i_pr_state_FFd26_1_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_FXMUX_127,
      O => control_i_pr_state_FFd26_1_DYMUX_147
    );
  control_i_pr_state_FFd26_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd26_1_SRINV_148
    );
  control_i_pr_state_FFd26_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd26_1_CLKINV_149
    );
  alu_i_N11_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N11,
      O => alu_i_N11_0
    );
  alu_i_N11_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux0000_map20,
      O => reg_i_carry_out_mux0000_map20_0
    );
  reg_i_carry_out_mux000067 : X_LUT4
    generic map(
      INIT => X"BC80",
      LOC => "SLICE_X17Y11"
    )
    port map (
      ADR0 => alu_i_Madd_add_result_int_add0000_cy(7),
      ADR1 => control_int_0_0,
      ADR2 => control_int_1_0,
      ADR3 => reg_i_a_out(7),
      O => reg_i_carry_out_mux0000_map20
    );
  N1300_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1300,
      O => N1300_0
    );
  N1300_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1299,
      O => N1299_0
    );
  alu_i_temp_carry_4_or0001_SW0_SW0 : X_LUT4
    generic map(
      INIT => X"EA80",
      LOC => "SLICE_X15Y4"
    )
    port map (
      ADR0 => reg_i_a_out(2),
      ADR1 => reg_i_a_out(1),
      ADR2 => reg_i_b_out(1),
      ADR3 => reg_i_b_out(2),
      O => N1299
    );
  control_i_pr_state_or0004_map9_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0004_map9,
      O => control_i_pr_state_or0004_map9_0
    );
  control_i_pr_state_or0004_map9_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0000_map2,
      O => control_i_pr_state_or0000_map2_0
    );
  control_i_pr_state_or00004 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd20_24,
      ADR1 => control_i_pr_state_FFd11_7,
      ADR2 => control_i_pr_state_FFd14_22,
      ADR3 => control_i_pr_state_FFd17_41,
      O => control_i_pr_state_or0000_map2
    );
  alu_i_N4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N4,
      O => alu_i_N4_0
    );
  alu_i_N4_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y8"
    )
    port map (
      IA => alu_i_N4_CY0F_151,
      IB => alu_i_N4_CYINIT_150,
      SEL => alu_i_N4_CYSELF_152,
      O => alu_i_Madd_add_result_int_add0000_cy(0)
    );
  alu_i_N4_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC0,
      O => alu_i_N4_CYINIT_150
    );
  alu_i_N4_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(0),
      O => alu_i_N4_CY0F_151
    );
  alu_i_N4_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N4,
      O => alu_i_N4_CYSELF_152
    );
  alu_i_N4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N4_XORG_153,
      O => alu_i_add_result_int_add0000(1)
    );
  alu_i_N4_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y8"
    )
    port map (
      I0 => alu_i_Madd_add_result_int_add0000_cy(0),
      I1 => N1244,
      O => alu_i_N4_XORG_153
    );
  alu_i_N4_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N4_CYMUXG_154,
      O => alu_i_Madd_add_result_int_add0000_cy(1)
    );
  alu_i_N4_CYMUXG : X_MUX2
    generic map(
      LOC => "SLICE_X16Y8"
    )
    port map (
      IA => alu_i_N4_CY0G_155,
      IB => alu_i_Madd_add_result_int_add0000_cy(0),
      SEL => alu_i_N4_CYSELG_156,
      O => alu_i_N4_CYMUXG_154
    );
  alu_i_N4_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(1),
      O => alu_i_N4_CY0G_155
    );
  alu_i_N4_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1244,
      O => alu_i_N4_CYSELG_156
    );
  alu_i_Madd_add_result_int_add0000_lut_1_1 : X_LUT4
    generic map(
      INIT => X"5A5A",
      LOC => "SLICE_X16Y8"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => VCC,
      ADR2 => reg_i_b_out(1),
      ADR3 => VCC,
      O => N1244
    );
  control_i_pr_state_or0003_map2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0003_map2,
      O => control_i_pr_state_or0003_map2_0
    );
  control_i_pr_state_or0003_map2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0002_map2,
      O => control_i_pr_state_or0002_map2_0
    );
  control_i_pr_state_or00024 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X5Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd13_23,
      ADR1 => control_i_pr_state_FFd18_11,
      ADR2 => control_i_pr_state_FFd6_45,
      ADR3 => control_i_pr_state_FFd7_37,
      O => control_i_pr_state_or0002_map2
    );
  alu_i_add_result_int_add0000_2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_2_XORF_157,
      O => alu_i_add_result_int_add0000(2)
    );
  alu_i_add_result_int_add0000_2_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_2_CYINIT_158,
      I1 => N1243,
      O => alu_i_add_result_int_add0000_2_XORF_157
    );
  alu_i_add_result_int_add0000_2_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      IA => alu_i_add_result_int_add0000_2_CY0F_159,
      IB => alu_i_add_result_int_add0000_2_CYINIT_158,
      SEL => alu_i_add_result_int_add0000_2_CYSELF_161,
      O => alu_i_Madd_add_result_int_add0000_cy(2)
    );
  alu_i_add_result_int_add0000_2_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      IA => alu_i_add_result_int_add0000_2_CY0F_159,
      IB => alu_i_add_result_int_add0000_2_CY0F_159,
      SEL => alu_i_add_result_int_add0000_2_CYSELF_161,
      O => alu_i_add_result_int_add0000_2_CYMUXF2_166
    );
  alu_i_add_result_int_add0000_2_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(1),
      O => alu_i_add_result_int_add0000_2_CYINIT_158
    );
  alu_i_add_result_int_add0000_2_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(2),
      O => alu_i_add_result_int_add0000_2_CY0F_159
    );
  alu_i_add_result_int_add0000_2_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1243,
      O => alu_i_add_result_int_add0000_2_CYSELF_161
    );
  alu_i_add_result_int_add0000_2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_2_XORG_160,
      O => alu_i_add_result_int_add0000(3)
    );
  alu_i_add_result_int_add0000_2_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      I0 => alu_i_Madd_add_result_int_add0000_cy(2),
      I1 => N1242,
      O => alu_i_add_result_int_add0000_2_XORG_160
    );
  alu_i_add_result_int_add0000_2_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_2_CYMUXFAST_162,
      O => alu_i_Madd_add_result_int_add0000_cy(3)
    );
  alu_i_add_result_int_add0000_2_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(1),
      O => alu_i_add_result_int_add0000_2_FASTCARRY_164
    );
  alu_i_add_result_int_add0000_2_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_2_CYSELG_168,
      I1 => alu_i_add_result_int_add0000_2_CYSELF_161,
      O => alu_i_add_result_int_add0000_2_CYAND_163
    );
  alu_i_add_result_int_add0000_2_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      IA => alu_i_add_result_int_add0000_2_CYMUXG2_165,
      IB => alu_i_add_result_int_add0000_2_FASTCARRY_164,
      SEL => alu_i_add_result_int_add0000_2_CYAND_163,
      O => alu_i_add_result_int_add0000_2_CYMUXFAST_162
    );
  alu_i_add_result_int_add0000_2_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y9"
    )
    port map (
      IA => alu_i_add_result_int_add0000_2_CY0G_167,
      IB => alu_i_add_result_int_add0000_2_CYMUXF2_166,
      SEL => alu_i_add_result_int_add0000_2_CYSELG_168,
      O => alu_i_add_result_int_add0000_2_CYMUXG2_165
    );
  alu_i_add_result_int_add0000_2_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(3),
      O => alu_i_add_result_int_add0000_2_CY0G_167
    );
  alu_i_add_result_int_add0000_2_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1242,
      O => alu_i_add_result_int_add0000_2_CYSELG_168
    );
  alu_i_Madd_add_result_int_add0000_lut_3_1 : X_LUT4
    generic map(
      INIT => X"5A5A",
      LOC => "SLICE_X16Y9"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => VCC,
      ADR2 => reg_i_b_out(3),
      ADR3 => VCC,
      O => N1242
    );
  alu_i_add_result_int_add0000_4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_4_XORF_169,
      O => alu_i_add_result_int_add0000(4)
    );
  alu_i_add_result_int_add0000_4_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_4_CYINIT_170,
      I1 => N1241,
      O => alu_i_add_result_int_add0000_4_XORF_169
    );
  alu_i_add_result_int_add0000_4_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      IA => alu_i_add_result_int_add0000_4_CY0F_171,
      IB => alu_i_add_result_int_add0000_4_CYINIT_170,
      SEL => alu_i_add_result_int_add0000_4_CYSELF_173,
      O => alu_i_Madd_add_result_int_add0000_cy(4)
    );
  alu_i_add_result_int_add0000_4_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      IA => alu_i_add_result_int_add0000_4_CY0F_171,
      IB => alu_i_add_result_int_add0000_4_CY0F_171,
      SEL => alu_i_add_result_int_add0000_4_CYSELF_173,
      O => alu_i_add_result_int_add0000_4_CYMUXF2_178
    );
  alu_i_add_result_int_add0000_4_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(3),
      O => alu_i_add_result_int_add0000_4_CYINIT_170
    );
  alu_i_add_result_int_add0000_4_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(4),
      O => alu_i_add_result_int_add0000_4_CY0F_171
    );
  alu_i_add_result_int_add0000_4_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1241,
      O => alu_i_add_result_int_add0000_4_CYSELF_173
    );
  alu_i_add_result_int_add0000_4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_4_XORG_172,
      O => alu_i_add_result_int_add0000(5)
    );
  alu_i_add_result_int_add0000_4_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      I0 => alu_i_Madd_add_result_int_add0000_cy(4),
      I1 => N1240,
      O => alu_i_add_result_int_add0000_4_XORG_172
    );
  alu_i_add_result_int_add0000_4_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_4_CYMUXFAST_174,
      O => alu_i_Madd_add_result_int_add0000_cy(5)
    );
  alu_i_add_result_int_add0000_4_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(3),
      O => alu_i_add_result_int_add0000_4_FASTCARRY_176
    );
  alu_i_add_result_int_add0000_4_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_4_CYSELG_180,
      I1 => alu_i_add_result_int_add0000_4_CYSELF_173,
      O => alu_i_add_result_int_add0000_4_CYAND_175
    );
  alu_i_add_result_int_add0000_4_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      IA => alu_i_add_result_int_add0000_4_CYMUXG2_177,
      IB => alu_i_add_result_int_add0000_4_FASTCARRY_176,
      SEL => alu_i_add_result_int_add0000_4_CYAND_175,
      O => alu_i_add_result_int_add0000_4_CYMUXFAST_174
    );
  alu_i_add_result_int_add0000_4_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y10"
    )
    port map (
      IA => alu_i_add_result_int_add0000_4_CY0G_179,
      IB => alu_i_add_result_int_add0000_4_CYMUXF2_178,
      SEL => alu_i_add_result_int_add0000_4_CYSELG_180,
      O => alu_i_add_result_int_add0000_4_CYMUXG2_177
    );
  alu_i_add_result_int_add0000_4_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(5),
      O => alu_i_add_result_int_add0000_4_CY0G_179
    );
  alu_i_add_result_int_add0000_4_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1240,
      O => alu_i_add_result_int_add0000_4_CYSELG_180
    );
  alu_i_Madd_add_result_int_add0000_lut_5_1 : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X16Y10"
    )
    port map (
      ADR0 => reg_i_b_out(5),
      ADR1 => reg_i_a_out(5),
      ADR2 => VCC,
      ADR3 => VCC,
      O => N1240
    );
  alu_i_add_result_int_add0000_6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_6_XORF_181,
      O => alu_i_add_result_int_add0000(6)
    );
  alu_i_add_result_int_add0000_6_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_6_CYINIT_182,
      I1 => N1239,
      O => alu_i_add_result_int_add0000_6_XORF_181
    );
  alu_i_add_result_int_add0000_6_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      IA => alu_i_add_result_int_add0000_6_CY0F_183,
      IB => alu_i_add_result_int_add0000_6_CYINIT_182,
      SEL => alu_i_add_result_int_add0000_6_CYSELF_185,
      O => alu_i_Madd_add_result_int_add0000_cy(6)
    );
  alu_i_add_result_int_add0000_6_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      IA => alu_i_add_result_int_add0000_6_CY0F_183,
      IB => alu_i_add_result_int_add0000_6_CY0F_183,
      SEL => alu_i_add_result_int_add0000_6_CYSELF_185,
      O => alu_i_add_result_int_add0000_6_CYMUXF2_190
    );
  alu_i_add_result_int_add0000_6_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(5),
      O => alu_i_add_result_int_add0000_6_CYINIT_182
    );
  alu_i_add_result_int_add0000_6_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(6),
      O => alu_i_add_result_int_add0000_6_CY0F_183
    );
  alu_i_add_result_int_add0000_6_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1239,
      O => alu_i_add_result_int_add0000_6_CYSELF_185
    );
  alu_i_add_result_int_add0000_6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_6_XORG_184,
      O => alu_i_add_result_int_add0000(7)
    );
  alu_i_add_result_int_add0000_6_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      I0 => alu_i_Madd_add_result_int_add0000_cy(6),
      I1 => N1238,
      O => alu_i_add_result_int_add0000_6_XORG_184
    );
  alu_i_add_result_int_add0000_6_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_add_result_int_add0000_6_CYMUXFAST_186,
      O => alu_i_Madd_add_result_int_add0000_cy(7)
    );
  alu_i_add_result_int_add0000_6_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_Madd_add_result_int_add0000_cy(5),
      O => alu_i_add_result_int_add0000_6_FASTCARRY_188
    );
  alu_i_add_result_int_add0000_6_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      I0 => alu_i_add_result_int_add0000_6_CYSELG_192,
      I1 => alu_i_add_result_int_add0000_6_CYSELF_185,
      O => alu_i_add_result_int_add0000_6_CYAND_187
    );
  alu_i_add_result_int_add0000_6_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      IA => alu_i_add_result_int_add0000_6_CYMUXG2_189,
      IB => alu_i_add_result_int_add0000_6_FASTCARRY_188,
      SEL => alu_i_add_result_int_add0000_6_CYAND_187,
      O => alu_i_add_result_int_add0000_6_CYMUXFAST_186
    );
  alu_i_add_result_int_add0000_6_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y11"
    )
    port map (
      IA => alu_i_add_result_int_add0000_6_CY0G_191,
      IB => alu_i_add_result_int_add0000_6_CYMUXF2_190,
      SEL => alu_i_add_result_int_add0000_6_CYSELG_192,
      O => alu_i_add_result_int_add0000_6_CYMUXG2_189
    );
  alu_i_add_result_int_add0000_6_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(7),
      O => alu_i_add_result_int_add0000_6_CY0G_191
    );
  alu_i_add_result_int_add0000_6_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1238,
      O => alu_i_add_result_int_add0000_6_CYSELG_192
    );
  alu_i_Madd_add_result_int_add0000_lut_7_1 : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X16Y11"
    )
    port map (
      ADR0 => reg_i_a_out(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_b_out(7),
      O => N1238
    );
  control_i_pr_state_or0006_map2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0006_map2,
      O => control_i_pr_state_or0006_map2_0
    );
  control_i_pr_state_or0006_map2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0003_map5,
      O => control_i_pr_state_or0003_map5_0
    );
  control_i_pr_state_or00039 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd16_10,
      ADR1 => control_i_pr_state_FFd15_19,
      ADR2 => control_i_pr_state_FFd13_23,
      ADR3 => control_i_pr_state_FFd20_24,
      O => control_i_pr_state_or0003_map5
    );
  pc_i_pc_int_addsub0000_1_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X9Y16"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_1_CY0F_194,
      IB => pc_i_pc_int_addsub0000_1_CYINIT_193,
      SEL => pc_i_pc_int_addsub0000_1_CYSELF_195,
      O => pc_i_Madd_pc_int_addsub0000_cy_0_Q
    );
  pc_i_pc_int_addsub0000_1_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC0,
      O => pc_i_pc_int_addsub0000_1_CYINIT_193
    );
  pc_i_pc_int_addsub0000_1_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(0),
      O => pc_i_pc_int_addsub0000_1_CY0F_194
    );
  pc_i_pc_int_addsub0000_1_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_N4,
      O => pc_i_pc_int_addsub0000_1_CYSELF_195
    );
  pc_i_pc_int_addsub0000_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_1_XORG_196,
      O => pc_i_pc_int_addsub0000(1)
    );
  pc_i_pc_int_addsub0000_1_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X9Y16"
    )
    port map (
      I0 => pc_i_Madd_pc_int_addsub0000_cy_0_Q,
      I1 => pc_i_N5,
      O => pc_i_pc_int_addsub0000_1_XORG_196
    );
  pc_i_pc_int_addsub0000_1_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_1_CYMUXG_197,
      O => pc_i_Madd_pc_int_addsub0000_cy_1_Q
    );
  pc_i_pc_int_addsub0000_1_CYMUXG : X_MUX2
    generic map(
      LOC => "SLICE_X9Y16"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_1_CY0G_198,
      IB => pc_i_Madd_pc_int_addsub0000_cy_0_Q,
      SEL => pc_i_pc_int_addsub0000_1_CYSELG_199,
      O => pc_i_pc_int_addsub0000_1_CYMUXG_197
    );
  pc_i_pc_int_addsub0000_1_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(1),
      O => pc_i_pc_int_addsub0000_1_CY0G_198
    );
  pc_i_pc_int_addsub0000_1_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_N5,
      O => pc_i_pc_int_addsub0000_1_CYSELG_199
    );
  pc_i_Madd_pc_int_addsub0000_lut_1_Q : X_LUT4
    generic map(
      INIT => X"9AAA",
      LOC => "SLICE_X9Y16"
    )
    port map (
      ADR0 => pc_i_pc_int(1),
      ADR1 => N547,
      ADR2 => control_nxt_int_0_0,
      ADR3 => N1320_0,
      O => pc_i_N5
    );
  pc_i_pc_int_addsub0000_2_LOGIC_ZERO : X_ZERO
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      O => pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209
    );
  pc_i_pc_int_addsub0000_2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_2_XORF_200,
      O => pc_i_pc_int_addsub0000(2)
    );
  pc_i_pc_int_addsub0000_2_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      I0 => pc_i_pc_int_addsub0000_2_CYINIT_201,
      I1 => pc_i_pc_int_addsub0000_2_F,
      O => pc_i_pc_int_addsub0000_2_XORF_200
    );
  pc_i_pc_int_addsub0000_2_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209,
      IB => pc_i_pc_int_addsub0000_2_CYINIT_201,
      SEL => pc_i_pc_int_addsub0000_2_CYSELF_203,
      O => pc_i_Madd_pc_int_addsub0000_cy_2_Q
    );
  pc_i_pc_int_addsub0000_2_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209,
      IB => pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209,
      SEL => pc_i_pc_int_addsub0000_2_CYSELF_203,
      O => pc_i_pc_int_addsub0000_2_CYMUXF2_208
    );
  pc_i_pc_int_addsub0000_2_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_Madd_pc_int_addsub0000_cy_1_Q,
      O => pc_i_pc_int_addsub0000_2_CYINIT_201
    );
  pc_i_pc_int_addsub0000_2_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_2_F,
      O => pc_i_pc_int_addsub0000_2_CYSELF_203
    );
  pc_i_pc_int_addsub0000_2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_2_XORG_202,
      O => pc_i_pc_int_addsub0000(3)
    );
  pc_i_pc_int_addsub0000_2_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      I0 => pc_i_Madd_pc_int_addsub0000_cy_2_Q,
      I1 => pc_i_pc_int_addsub0000_2_G,
      O => pc_i_pc_int_addsub0000_2_XORG_202
    );
  pc_i_pc_int_addsub0000_2_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_2_CYMUXFAST_204,
      O => pc_i_Madd_pc_int_addsub0000_cy_3_Q
    );
  pc_i_pc_int_addsub0000_2_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_Madd_pc_int_addsub0000_cy_1_Q,
      O => pc_i_pc_int_addsub0000_2_FASTCARRY_206
    );
  pc_i_pc_int_addsub0000_2_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      I0 => pc_i_pc_int_addsub0000_2_CYSELG_210,
      I1 => pc_i_pc_int_addsub0000_2_CYSELF_203,
      O => pc_i_pc_int_addsub0000_2_CYAND_205
    );
  pc_i_pc_int_addsub0000_2_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_2_CYMUXG2_207,
      IB => pc_i_pc_int_addsub0000_2_FASTCARRY_206,
      SEL => pc_i_pc_int_addsub0000_2_CYAND_205,
      O => pc_i_pc_int_addsub0000_2_CYMUXFAST_204
    );
  pc_i_pc_int_addsub0000_2_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X9Y17"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_2_LOGIC_ZERO_209,
      IB => pc_i_pc_int_addsub0000_2_CYMUXF2_208,
      SEL => pc_i_pc_int_addsub0000_2_CYSELG_210,
      O => pc_i_pc_int_addsub0000_2_CYMUXG2_207
    );
  pc_i_pc_int_addsub0000_2_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_2_G,
      O => pc_i_pc_int_addsub0000_2_CYSELG_210
    );
  control_i_pr_state_or0007_map2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0007_map2,
      O => control_i_pr_state_or0007_map2_0
    );
  control_i_pr_state_or00074 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X3Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd9_25,
      ADR1 => control_i_pr_state_FFd12_26,
      ADR2 => control_i_pr_state_FFd10_16,
      ADR3 => control_i_pr_state_FFd16_10,
      O => control_i_pr_state_or0007_map2
    );
  pc_i_pc_int_addsub0000_4_LOGIC_ZERO : X_ZERO
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      O => pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220
    );
  pc_i_pc_int_addsub0000_4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_4_XORF_211,
      O => pc_i_pc_int_addsub0000(4)
    );
  pc_i_pc_int_addsub0000_4_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      I0 => pc_i_pc_int_addsub0000_4_CYINIT_212,
      I1 => pc_i_pc_int_addsub0000_4_F,
      O => pc_i_pc_int_addsub0000_4_XORF_211
    );
  pc_i_pc_int_addsub0000_4_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220,
      IB => pc_i_pc_int_addsub0000_4_CYINIT_212,
      SEL => pc_i_pc_int_addsub0000_4_CYSELF_214,
      O => pc_i_Madd_pc_int_addsub0000_cy_4_Q
    );
  pc_i_pc_int_addsub0000_4_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220,
      IB => pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220,
      SEL => pc_i_pc_int_addsub0000_4_CYSELF_214,
      O => pc_i_pc_int_addsub0000_4_CYMUXF2_219
    );
  pc_i_pc_int_addsub0000_4_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_Madd_pc_int_addsub0000_cy_3_Q,
      O => pc_i_pc_int_addsub0000_4_CYINIT_212
    );
  pc_i_pc_int_addsub0000_4_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_4_F,
      O => pc_i_pc_int_addsub0000_4_CYSELF_214
    );
  pc_i_pc_int_addsub0000_4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_4_XORG_213,
      O => pc_i_pc_int_addsub0000(5)
    );
  pc_i_pc_int_addsub0000_4_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      I0 => pc_i_Madd_pc_int_addsub0000_cy_4_Q,
      I1 => pc_i_pc_int_addsub0000_4_G,
      O => pc_i_pc_int_addsub0000_4_XORG_213
    );
  pc_i_pc_int_addsub0000_4_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_Madd_pc_int_addsub0000_cy_3_Q,
      O => pc_i_pc_int_addsub0000_4_FASTCARRY_217
    );
  pc_i_pc_int_addsub0000_4_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      I0 => pc_i_pc_int_addsub0000_4_CYSELG_221,
      I1 => pc_i_pc_int_addsub0000_4_CYSELF_214,
      O => pc_i_pc_int_addsub0000_4_CYAND_216
    );
  pc_i_pc_int_addsub0000_4_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_4_CYMUXG2_218,
      IB => pc_i_pc_int_addsub0000_4_FASTCARRY_217,
      SEL => pc_i_pc_int_addsub0000_4_CYAND_216,
      O => pc_i_pc_int_addsub0000_4_CYMUXFAST_215
    );
  pc_i_pc_int_addsub0000_4_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X9Y18"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_4_LOGIC_ZERO_220,
      IB => pc_i_pc_int_addsub0000_4_CYMUXF2_219,
      SEL => pc_i_pc_int_addsub0000_4_CYSELG_221,
      O => pc_i_pc_int_addsub0000_4_CYMUXG2_218
    );
  pc_i_pc_int_addsub0000_4_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_4_G,
      O => pc_i_pc_int_addsub0000_4_CYSELG_221
    );
  pc_i_pc_int_addsub0000_6_LOGIC_ZERO : X_ZERO
    generic map(
      LOC => "SLICE_X9Y19"
    )
    port map (
      O => pc_i_pc_int_addsub0000_6_LOGIC_ZERO_223
    );
  pc_i_pc_int_addsub0000_6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_6_XORF_222,
      O => pc_i_pc_int_addsub0000(6)
    );
  pc_i_pc_int_addsub0000_6_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X9Y19"
    )
    port map (
      I0 => pc_i_pc_int_addsub0000_6_CYINIT_224,
      I1 => pc_i_pc_int_addsub0000_6_F,
      O => pc_i_pc_int_addsub0000_6_XORF_222
    );
  pc_i_pc_int_addsub0000_6_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X9Y19"
    )
    port map (
      IA => pc_i_pc_int_addsub0000_6_LOGIC_ZERO_223,
      IB => pc_i_pc_int_addsub0000_6_CYINIT_224,
      SEL => pc_i_pc_int_addsub0000_6_CYSELF_225,
      O => pc_i_Madd_pc_int_addsub0000_cy_6_Q
    );
  pc_i_pc_int_addsub0000_6_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_4_CYMUXFAST_215,
      O => pc_i_pc_int_addsub0000_6_CYINIT_224
    );
  pc_i_pc_int_addsub0000_6_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_6_F,
      O => pc_i_pc_int_addsub0000_6_CYSELF_225
    );
  pc_i_pc_int_addsub0000_6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_addsub0000_6_XORG_226,
      O => pc_i_pc_int_addsub0000(7)
    );
  pc_i_pc_int_addsub0000_6_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X9Y19"
    )
    port map (
      I0 => pc_i_Madd_pc_int_addsub0000_cy_6_Q,
      I1 => pc_i_pc_int_7_rt_227,
      O => pc_i_pc_int_addsub0000_6_XORG_226
    );
  N1173_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1173,
      O => N1173_0
    );
  N1173_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => N623,
      O => N623_0
    );
  reg_i_b_out_mux0000_5_SW0 : X_LUT4
    generic map(
      INIT => X"5C0C",
      LOC => "SLICE_X16Y2"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_b_out(5),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_rom_data_intern(5),
      O => N623
    );
  cflag_OBUF : X_OBUF
    generic map(
      LOC => "PAD39"
    )
    port map (
      I => cflag_O,
      O => cflag
    );
  reg_i_a_out_0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_0_pack_1,
      O => result_alu_reg(0)
    );
  reg_i_a_out_0_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => N92,
      O => reg_i_a_out_0_REVUSED_228
    );
  reg_i_a_out_0_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X13Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1236,
      O => reg_i_a_out_0_DYMUX_229
    );
  reg_i_a_out_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_0_SRINV_230
    );
  reg_i_a_out_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_0_CLKINV_231
    );
  a_0_OBUF : X_OBUF
    generic map(
      LOC => "PAD97"
    )
    port map (
      I => a_0_O,
      O => a(0)
    );
  alu_i_result_3_map18_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_map18,
      O => alu_i_result_3_map18_0
    );
  alu_i_result_3_map18_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_map12,
      O => alu_i_result_1_map12_0
    );
  alu_i_result_1_36 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X11Y7"
    )
    port map (
      ADR0 => reg_i_b_out(1),
      ADR1 => alu_i_zero_out_cmp_eq0006_0,
      ADR2 => alu_i_add_result_int_add0000(1),
      ADR3 => alu_i_zero_out_cmp_eq0012,
      O => alu_i_result_1_map12
    );
  datmem_data_out_0_OBUF : X_OBUF
    generic map(
      LOC => "PAD99"
    )
    port map (
      I => datmem_data_out_0_O,
      O => datmem_data_out(0)
    );
  reg_i_a_out_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_1_pack_1,
      O => result_alu_reg(1)
    );
  reg_i_a_out_1_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N90,
      O => reg_i_a_out_1_REVUSED_232
    );
  reg_i_a_out_1_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1235,
      O => reg_i_a_out_1_DYMUX_233
    );
  reg_i_a_out_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_1_SRINV_234
    );
  reg_i_a_out_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_1_CLKINV_235
    );
  a_1_OBUF : X_OBUF
    generic map(
      LOC => "PAD54"
    )
    port map (
      I => a_1_O,
      O => a(1)
    );
  reg_i_zero_out_mux0000_map64_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map64,
      O => reg_i_zero_out_mux0000_map64_0
    );
  reg_i_zero_out_mux0000_map64_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_map10,
      O => alu_i_result_3_map10_0
    );
  alu_i_result_3_22 : X_LUT4
    generic map(
      INIT => X"FF60",
      LOC => "SLICE_X15Y6"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => reg_i_b_out(3),
      ADR2 => alu_i_zero_out_cmp_eq0004_0,
      ADR3 => N1361,
      O => alu_i_result_3_map10
    );
  datmem_data_out_1_OBUF : X_OBUF
    generic map(
      LOC => "PAD52"
    )
    port map (
      I => datmem_data_out_1_O,
      O => datmem_data_out(1)
    );
  reg_i_a_out_2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_2_pack_1,
      O => result_alu_reg(2)
    );
  reg_i_a_out_2_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N88,
      O => reg_i_a_out_2_REVUSED_236
    );
  reg_i_a_out_2_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1234,
      O => reg_i_a_out_2_DYMUX_237
    );
  reg_i_a_out_2_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_2_SRINV_238
    );
  reg_i_a_out_2_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_2_CLKINV_239
    );
  a_2_OBUF : X_OBUF
    generic map(
      LOC => "PAD102"
    )
    port map (
      I => a_2_O,
      O => a(2)
    );
  datmem_data_out_2_OBUF : X_OBUF
    generic map(
      LOC => "PAD100"
    )
    port map (
      I => datmem_data_out_2_O,
      O => datmem_data_out(2)
    );
  reg_i_zero_out_mux0000_map6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map6,
      O => reg_i_zero_out_mux0000_map6_0
    );
  reg_i_zero_out_mux0000_map6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_map10,
      O => alu_i_result_4_map10_0
    );
  alu_i_result_4_22 : X_LUT4
    generic map(
      INIT => X"FF60",
      LOC => "SLICE_X19Y6"
    )
    port map (
      ADR0 => reg_i_b_out(4),
      ADR1 => reg_i_a_out(4),
      ADR2 => alu_i_zero_out_cmp_eq0004_0,
      ADR3 => N1359,
      O => alu_i_result_4_map10
    );
  a_3_OBUF : X_OBUF
    generic map(
      LOC => "PAD103"
    )
    port map (
      I => a_3_O,
      O => a(3)
    );
  reg_i_a_out_3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_3_pack_1,
      O => result_alu_reg(3)
    );
  reg_i_a_out_3_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N86,
      O => reg_i_a_out_3_REVUSED_240
    );
  reg_i_a_out_3_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X12Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1233,
      O => reg_i_a_out_3_DYMUX_241
    );
  reg_i_a_out_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_3_SRINV_242
    );
  reg_i_a_out_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_3_CLKINV_243
    );
  datmem_data_out_3_OBUF : X_OBUF
    generic map(
      LOC => "PAD104"
    )
    port map (
      I => datmem_data_out_3_O,
      O => datmem_data_out(3)
    );
  alu_i_result_4_map17_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_map17,
      O => alu_i_result_4_map17_0
    );
  alu_i_result_4_map17_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_map17,
      O => alu_i_result_3_map17_0
    );
  alu_i_result_3_48 : X_LUT4
    generic map(
      INIT => X"FFC0",
      LOC => "SLICE_X14Y8"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_a_out(2),
      ADR2 => alu_i_N3_0,
      ADR3 => alu_i_result_3_map15,
      O => alu_i_result_3_map17
    );
  b_0_OBUF : X_OBUF
    generic map(
      LOC => "PAD98"
    )
    port map (
      I => b_0_O,
      O => b(0)
    );
  reg_i_a_out_4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_4_pack_1,
      O => result_alu_reg(4)
    );
  reg_i_a_out_4_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => N84,
      O => reg_i_a_out_4_REVUSED_244
    );
  reg_i_a_out_4_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X13Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1232,
      O => reg_i_a_out_4_DYMUX_245
    );
  reg_i_a_out_4_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_4_SRINV_246
    );
  reg_i_a_out_4_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_4_CLKINV_247
    );
  a_4_OBUF : X_OBUF
    generic map(
      LOC => "PAD81"
    )
    port map (
      I => a_4_O,
      O => a(4)
    );
  datmem_data_out_4_OBUF : X_OBUF
    generic map(
      LOC => "PAD75"
    )
    port map (
      I => datmem_data_out_4_O,
      O => datmem_data_out(4)
    );
  b_1_OBUF : X_OBUF
    generic map(
      LOC => "PAD105"
    )
    port map (
      I => b_1_O,
      O => b(1)
    );
  a_5_OBUF : X_OBUF
    generic map(
      LOC => "PAD91"
    )
    port map (
      I => a_5_O,
      O => a(5)
    );
  control_i_pr_state_or0007_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0007_map7,
      O => control_i_pr_state_or0007_map7_0
    );
  control_i_pr_state_or0007_map7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1261_pack_1,
      O => N1261
    );
  control_i_pr_state_FFd7_In_SW1 : X_LUT4
    generic map(
      INIT => X"FEFF",
      LOC => "SLICE_X3Y10"
    )
    port map (
      ADR0 => prog_data_0_IBUF_0,
      ADR1 => prog_data_1_IBUF_8,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => control_i_pr_state_cmp_eq0007,
      O => N1261_pack_1
    );
  datmem_data_out_5_OBUF : X_OBUF
    generic map(
      LOC => "PAD92"
    )
    port map (
      I => datmem_data_out_5_O,
      O => datmem_data_out(5)
    );
  reg_i_zero_out_mux0000_map49_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map49,
      O => reg_i_zero_out_mux0000_map49_0
    );
  reg_i_zero_out_mux0000_map49_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0007,
      O => alu_i_xor0007_0
    );
  alu_i_Mxor_xor0007_Result1 : X_LUT4
    generic map(
      INIT => X"C33C",
      LOC => "SLICE_X18Y8"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_carry_out_3,
      ADR2 => reg_i_a_out(0),
      ADR3 => reg_i_b_out(0),
      O => alu_i_xor0007
    );
  b_2_OBUF : X_OBUF
    generic map(
      LOC => "PAD82"
    )
    port map (
      I => b_2_O,
      O => b(2)
    );
  alu_i_N10_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y1",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N10,
      O => alu_i_N10_0
    );
  alu_i_N10_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y1",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1177,
      O => N1177_0
    );
  alu_i_xor0000_or0000_SW0 : X_LUT4
    generic map(
      INIT => X"E8C0",
      LOC => "SLICE_X18Y1"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => reg_i_b_out(6),
      ADR2 => reg_i_a_out(6),
      ADR3 => reg_i_b_out(5),
      O => N1177
    );
  a_6_OBUF : X_OBUF
    generic map(
      LOC => "PAD65"
    )
    port map (
      I => a_6_O,
      O => a(6)
    );
  alu_i_xor0000_or0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X21Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0000_or0000_248,
      O => alu_i_xor0000_or0000_0
    );
  alu_i_xor0000_or0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X21Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1178_pack_1,
      O => N1178
    );
  alu_i_xor0000_or0000_SW1 : X_LUT4
    generic map(
      INIT => X"FCE8",
      LOC => "SLICE_X21Y2"
    )
    port map (
      ADR0 => reg_i_b_out(5),
      ADR1 => reg_i_a_out(6),
      ADR2 => reg_i_b_out(6),
      ADR3 => reg_i_a_out(5),
      O => N1178_pack_1
    );
  datmem_data_out_6_OBUF : X_OBUF
    generic map(
      LOC => "PAD64"
    )
    port map (
      I => datmem_data_out_6_O,
      O => datmem_data_out(6)
    );
  control_i_pr_state_FFd2_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0065,
      O => control_i_pr_state_FFd2_DXMUX_249
    );
  control_i_pr_state_FFd2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N9_pack_1,
      O => control_i_N9
    );
  control_i_pr_state_FFd2_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd2_SRINV_250
    );
  control_i_pr_state_FFd2_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd2_CLKINV_251
    );
  control_i_pr_state_cmp_eq000111 : X_LUT4
    generic map(
      INIT => X"0202",
      LOC => "SLICE_X5Y10"
    )
    port map (
      ADR0 => prog_data_2_IBUF_34,
      ADR1 => prog_data_1_IBUF_8,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => VCC,
      O => control_i_N9_pack_1
    );
  b_3_OBUF : X_OBUF
    generic map(
      LOC => "PAD50"
    )
    port map (
      I => b_3_O,
      O => b(3)
    );
  a_7_OBUF : X_OBUF
    generic map(
      LOC => "PAD47"
    )
    port map (
      I => a_7_O,
      O => a(7)
    );
  control_i_pr_state_FFd6_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_cmp_eq0063,
      O => control_i_pr_state_FFd6_DXMUX_252
    );
  control_i_pr_state_FFd6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N6_pack_1,
      O => control_i_N6
    );
  control_i_pr_state_FFd6_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_i_pr_state_FFd6_SRINV_253
    );
  control_i_pr_state_FFd6_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => control_i_pr_state_FFd6_CLKINV_254
    );
  control_i_pr_state_cmp_eq000511 : X_LUT4
    generic map(
      INIT => X"000C",
      LOC => "SLICE_X5Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_3_IBUF_33,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => prog_data_1_IBUF_8,
      O => control_i_N6_pack_1
    );
  datmem_data_out_7_OBUF : X_OBUF
    generic map(
      LOC => "PAD48"
    )
    port map (
      I => datmem_data_out_7_O,
      O => datmem_data_out(7)
    );
  N1279_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1279,
      O => N1279_0
    );
  N1279_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_N5_pack_1,
      O => control_i_N5
    );
  control_i_pr_state_cmp_eq001411 : X_LUT4
    generic map(
      INIT => X"3000",
      LOC => "SLICE_X3Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_1_IBUF_8,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => prog_data_3_IBUF_33,
      O => control_i_N5_pack_1
    );
  b_4_OBUF : X_OBUF
    generic map(
      LOC => "PAD51"
    )
    port map (
      I => b_4_O,
      O => b(4)
    );
  b_5_OBUF : X_OBUF
    generic map(
      LOC => "PAD49"
    )
    port map (
      I => b_5_O,
      O => b(5)
    );
  alu_i_zero_out_or0001_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or0001,
      O => alu_i_zero_out_or0001_0
    );
  alu_i_zero_out_or0001_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_2_pack_1,
      O => control_int(2)
    );
  control_i_pr_state_or000223 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X7Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or0002_map8,
      ADR2 => control_i_pr_state_or0002_map2_0,
      ADR3 => control_i_pr_state_or0002_map5,
      O => control_int_2_pack_1
    );
  b_6_OBUF : X_OBUF
    generic map(
      LOC => "PAD53"
    )
    port map (
      I => b_6_O,
      O => b(6)
    );
  b_7_OBUF : X_OBUF
    generic map(
      LOC => "PAD40"
    )
    port map (
      I => b_7_O,
      O => b(7)
    );
  datmem_adr_0_OBUF : X_OBUF
    generic map(
      LOC => "PAD108"
    )
    port map (
      I => datmem_adr_0_O,
      O => datmem_adr(0)
    );
  datmem_adr_1_OBUF : X_OBUF
    generic map(
      LOC => "PAD107"
    )
    port map (
      I => datmem_adr_1_O,
      O => datmem_adr(1)
    );
  datmem_adr_2_OBUF : X_OBUF
    generic map(
      LOC => "PAD41"
    )
    port map (
      I => datmem_adr_2_O,
      O => datmem_adr(2)
    );
  reg_i_a_out_mux0000_1_SW0 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X10Y6"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(1),
      ADR1 => reg_i_a_out_or0001_0,
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_a_out(1),
      O => N90
    );
  datmem_adr_3_OBUF : X_OBUF
    generic map(
      LOC => "PAD42"
    )
    port map (
      I => datmem_adr_3_O,
      O => datmem_adr(3)
    );
  datmem_adr_4_OBUF : X_OBUF
    generic map(
      LOC => "PAD85"
    )
    port map (
      I => datmem_adr_4_O,
      O => datmem_adr(4)
    );
  datmem_adr_5_OBUF : X_OBUF
    generic map(
      LOC => "PAD86"
    )
    port map (
      I => datmem_adr_5_O,
      O => datmem_adr(5)
    );
  datmem_adr_6_OBUF : X_OBUF
    generic map(
      LOC => "PAD109"
    )
    port map (
      I => datmem_adr_6_O,
      O => datmem_adr(6)
    );
  reg_i_a_out_or0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_or0000_255,
      O => reg_i_a_out_or0000_0
    );
  reg_i_a_out_or0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1330,
      O => N1330_0
    );
  reg_i_zero_out_mux0000341_SW0 : X_LUT4
    generic map(
      INIT => X"FFBF",
      LOC => "SLICE_X15Y9"
    )
    port map (
      ADR0 => alu_i_add_result_int_add0000(1),
      ADR1 => control_int_1_0,
      ADR2 => control_int(2),
      ADR3 => alu_i_N4_0,
      O => N1330
    );
  datmem_adr_7_OBUF : X_OBUF
    generic map(
      LOC => "PAD110"
    )
    port map (
      I => datmem_adr_7_O,
      O => datmem_adr(7)
    );
  nreset_int_IBUF : X_BUF
    generic map(
      LOC => "PAD94",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_int,
      O => nreset_int_INBUF
    );
  nreset_int_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD94",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_int_INBUF,
      O => nreset_int_IBUF_44
    );
  datmem_nrd_OBUF : X_OBUF
    generic map(
      LOC => "PAD57"
    )
    port map (
      I => datmem_nrd_O,
      O => datmem_nrd
    );
  N1340_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1340,
      O => N1340_0
    );
  reg_i_zero_out_mux0000341_SW1 : X_LUT4
    generic map(
      INIT => X"FCFC",
      LOC => "SLICE_X17Y9"
    )
    port map (
      ADR0 => VCC,
      ADR1 => alu_i_add_result_int_add0000(3),
      ADR2 => alu_i_add_result_int_add0000(2),
      ADR3 => VCC,
      O => N1340
    );
  datmem_nwr_OBUF : X_OBUF
    generic map(
      LOC => "PAD58"
    )
    port map (
      I => datmem_nwr_O,
      O => datmem_nwr
    );
  zflag_OBUF : X_OBUF
    generic map(
      LOC => "PAD106"
    )
    port map (
      I => zflag_O,
      O => zflag
    );
  datmem_data_in_0_IBUF : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(0),
      O => datmem_data_in_0_INBUF
    );
  reg_i_zero_out_mux0000_map73_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map73,
      O => reg_i_zero_out_mux0000_map73_0
    );
  reg_i_zero_out_mux0000_map73_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y9",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map71_pack_1,
      O => reg_i_zero_out_mux0000_map71
    );
  reg_i_zero_out_mux0000211 : X_LUT4
    generic map(
      INIT => X"153F",
      LOC => "SLICE_X14Y9"
    )
    port map (
      ADR0 => reg_i_b_out(6),
      ADR1 => reg_i_a_out(5),
      ADR2 => reg_i_b_out(5),
      ADR3 => reg_i_a_out(6),
      O => reg_i_zero_out_mux0000_map71_pack_1
    );
  datmem_data_in_1_IBUF : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(1),
      O => datmem_data_in_1_INBUF
    );
  reg_i_zero_out_mux0000_map22_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X19Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map22,
      O => reg_i_zero_out_mux0000_map22_0
    );
  reg_i_zero_out_mux000051 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X19Y5"
    )
    port map (
      ADR0 => ram_control_i_ram_data_reg(5),
      ADR1 => ram_control_i_ram_data_reg(6),
      ADR2 => ram_control_i_ram_data_reg(4),
      ADR3 => ram_control_i_ram_data_reg(7),
      O => reg_i_zero_out_mux0000_map22
    );
  datmem_data_in_2_IBUF : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(2),
      O => datmem_data_in_2_INBUF
    );
  reg_i_a_out_mux0000_3_SW0 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X10Y7"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => reg_i_a_out_or0001_0,
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_rom_data_intern(3),
      O => N86
    );
  datmem_data_in_3_IBUF : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(3),
      O => datmem_data_in_3_INBUF
    );
  reg_i_zero_out_mux0000_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map15,
      O => reg_i_zero_out_mux0000_map15_0
    );
  reg_i_zero_out_mux000038 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X18Y0"
    )
    port map (
      ADR0 => ram_control_i_ram_data_reg(1),
      ADR1 => ram_control_i_ram_data_reg(0),
      ADR2 => ram_control_i_ram_data_reg(3),
      ADR3 => ram_control_i_ram_data_reg(2),
      O => reg_i_zero_out_mux0000_map15
    );
  datmem_data_in_4_IBUF : X_BUF
    generic map(
      LOC => "PAD63",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(4),
      O => datmem_data_in_4_INBUF
    );
  datmem_data_in_5_IBUF : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(5),
      O => datmem_data_in_5_INBUF
    );
  datmem_data_in_6_IBUF : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(6),
      O => datmem_data_in_6_INBUF
    );
  reg_i_zero_out_mux0000_map56_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map56,
      O => reg_i_zero_out_mux0000_map56_0
    );
  reg_i_zero_out_mux0000174 : X_LUT4
    generic map(
      INIT => X"135F",
      LOC => "SLICE_X15Y10"
    )
    port map (
      ADR0 => reg_i_b_out(1),
      ADR1 => reg_i_a_out(2),
      ADR2 => reg_i_a_out(1),
      ADR3 => reg_i_b_out(2),
      O => reg_i_zero_out_mux0000_map56
    );
  datmem_data_in_7_IBUF : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(7),
      O => datmem_data_in_7_INBUF
    );
  reg_i_zero_out_mux0000_map130_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000_map130,
      O => reg_i_zero_out_mux0000_map130_0
    );
  reg_i_zero_out_mux0000423 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X17Y12"
    )
    port map (
      ADR0 => reg_i_b_out(5),
      ADR1 => reg_i_b_out(6),
      ADR2 => reg_i_b_out(4),
      ADR3 => reg_i_a_out(7),
      O => reg_i_zero_out_mux0000_map130
    );
  clk_IBUF : X_BUF
    generic map(
      LOC => "PAD79",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk,
      O => clk_INBUF
    );
  clk_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD79",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_INBUF,
      O => clk_IBUF1
    );
  prog_adr_0_OBUF : X_OBUF
    generic map(
      LOC => "PAD46"
    )
    port map (
      I => prog_adr_0_O,
      O => prog_adr(0)
    );
  prog_adr_1_OBUF : X_OBUF
    generic map(
      LOC => "PAD45"
    )
    port map (
      I => prog_adr_1_O,
      O => prog_adr(1)
    );
  prog_adr_2_OBUF : X_OBUF
    generic map(
      LOC => "PAD44"
    )
    port map (
      I => prog_adr_2_O,
      O => prog_adr(2)
    );
  prog_adr_3_OBUF : X_OBUF
    generic map(
      LOC => "PAD43"
    )
    port map (
      I => prog_adr_3_O,
      O => prog_adr(3)
    );
  prog_adr_4_OBUF : X_OBUF
    generic map(
      LOC => "PAD113"
    )
    port map (
      I => prog_adr_4_O,
      O => prog_adr(4)
    );
  prog_adr_5_OBUF : X_OBUF
    generic map(
      LOC => "PAD114"
    )
    port map (
      I => prog_adr_5_O,
      O => prog_adr(5)
    );
  prog_adr_6_OBUF : X_OBUF
    generic map(
      LOC => "PAD112"
    )
    port map (
      I => prog_adr_6_O,
      O => prog_adr(6)
    );
  prog_adr_7_OBUF : X_OBUF
    generic map(
      LOC => "PAD111"
    )
    port map (
      I => prog_adr_7_O,
      O => prog_adr(7)
    );
  nreset_IBUF : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset,
      O => nreset_INBUF
    );
  nreset_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_INBUF,
      O => nreset_IBUF_43
    );
  prog_data_0_IBUF : X_BUF
    generic map(
      LOC => "PAD76",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(0),
      O => prog_data_0_INBUF
    );
  prog_data_0_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD76",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_0_INBUF,
      O => prog_data_0_IFF_IFFDMUX_258
    );
  prog_data_0_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD76",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_0_INBUF,
      O => prog_data_0_IBUF_0
    );
  prog_data_0_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD76",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_0_IFF_ISR_USED_256
    );
  prog_data_0_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD76",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_0_IFF_ICLK1INV_257
    );
  prog_data_1_IBUF : X_BUF
    generic map(
      LOC => "PAD80",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(1),
      O => prog_data_1_INBUF
    );
  prog_data_1_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD80",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_INBUF,
      O => prog_data_1_IFF_IFFDMUX_261
    );
  prog_data_1_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD80",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_INBUF,
      O => prog_data_1_IBUF_8
    );
  prog_data_1_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD80",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_1_IFF_ISR_USED_259
    );
  prog_data_1_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD80",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_1_IFF_ICLK1INV_260
    );
  prog_data_2_IBUF : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(2),
      O => prog_data_2_INBUF
    );
  prog_data_2_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_2_INBUF,
      O => prog_data_2_IFF_IFFDMUX_264
    );
  prog_data_2_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_2_INBUF,
      O => prog_data_2_IBUF_34
    );
  prog_data_2_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_2_IFF_ISR_USED_262
    );
  prog_data_2_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_2_IFF_ICLK1INV_263
    );
  prog_data_3_IBUF : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(3),
      O => prog_data_3_INBUF
    );
  prog_data_3_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_3_INBUF,
      O => prog_data_3_IFF_IFFDMUX_267
    );
  prog_data_3_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_3_INBUF,
      O => prog_data_3_IBUF_33
    );
  prog_data_3_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_3_IFF_ISR_USED_265
    );
  prog_data_3_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_3_IFF_ICLK1INV_266
    );
  prog_data_4_IBUF : X_BUF
    generic map(
      LOC => "PAD84",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(4),
      O => prog_data_4_INBUF
    );
  prog_data_4_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD84",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_4_INBUF,
      O => prog_data_4_IFF_IFFDMUX_270
    );
  prog_data_4_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD84",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_4_INBUF,
      O => prog_data_4_IBUF_39
    );
  prog_data_4_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD84",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_4_IFF_ISR_USED_268
    );
  prog_data_4_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD84",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_4_IFF_ICLK1INV_269
    );
  prog_data_5_IBUF : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(5),
      O => prog_data_5_INBUF
    );
  prog_data_5_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_INBUF,
      O => prog_data_5_IFF_IFFDMUX_273
    );
  prog_data_5_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_INBUF,
      O => prog_data_5_IBUF_27
    );
  prog_data_5_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_5_IFF_ISR_USED_271
    );
  prog_data_5_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_5_IFF_ICLK1INV_272
    );
  prog_data_6_IBUF : X_BUF
    generic map(
      LOC => "PAD74",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(6),
      O => prog_data_6_INBUF
    );
  prog_data_6_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD74",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_6_INBUF,
      O => prog_data_6_IFF_IFFDMUX_276
    );
  prog_data_6_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD74",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_6_INBUF,
      O => prog_data_6_IBUF_29
    );
  prog_data_6_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD74",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_6_IFF_ISR_USED_274
    );
  prog_data_6_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD74",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_6_IFF_ICLK1INV_275
    );
  prog_data_7_IBUF : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(7),
      O => prog_data_7_INBUF
    );
  prog_data_7_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_7_INBUF,
      O => prog_data_7_IFF_IFFDMUX_279
    );
  prog_data_7_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_7_INBUF,
      O => prog_data_7_IBUF_28
    );
  prog_data_7_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_7_IFF_ISR_USED_277
    );
  prog_data_7_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => prog_data_7_IFF_ICLK1INV_278
    );
  clk_IBUF_BUFG : X_BUFGMUX
    generic map(
      LOC => "BUFGMUX3"
    )
    port map (
      I0 => clk_IBUF_BUFG_I0_INV,
      I1 => GND,
      S => clk_IBUF_BUFG_S_INVNOT,
      O => clk_IBUF_5
    );
  clk_IBUF_BUFG_SINV : X_INV
    generic map(
      LOC => "BUFGMUX3",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC1,
      O => clk_IBUF_BUFG_S_INVNOT
    );
  clk_IBUF_BUFG_I0_USED : X_BUF
    generic map(
      LOC => "BUFGMUX3",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF1,
      O => clk_IBUF_BUFG_I0_INV
    );
  N1361_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1361_F5MUX_280,
      O => N1361
    );
  N1361_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X14Y6"
    )
    port map (
      IA => N1385,
      IB => N1386,
      SEL => N1361_BXINV_281,
      O => N1361_F5MUX_280
    );
  N1361_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X14Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(2),
      O => N1361_BXINV_281
    );
  alu_i_result_3_22_SW0_F : X_LUT4
    generic map(
      INIT => X"0030",
      LOC => "SLICE_X14Y6"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N61_0,
      ADR3 => reg_i_a_out(3),
      O => N1385
    );
  N1359_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1359_F5MUX_282,
      O => N1359
    );
  N1359_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X18Y4"
    )
    port map (
      IA => N1383,
      IB => N1384,
      SEL => N1359_BXINV_283,
      O => N1359_F5MUX_282
    );
  N1359_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(2),
      O => N1359_BXINV_283
    );
  control_i_pr_state_FFd26_In_map14_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_FFd26_In_map14_F5MUX_284,
      O => control_i_pr_state_FFd26_In_map14
    );
  control_i_pr_state_FFd26_In_map14_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X3Y12"
    )
    port map (
      IA => N1387,
      IB => N1388,
      SEL => control_i_pr_state_FFd26_In_map14_BXINV_285,
      O => control_i_pr_state_FFd26_In_map14_F5MUX_284
    );
  control_i_pr_state_FFd26_In_map14_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_IBUF_8,
      O => control_i_pr_state_FFd26_In_map14_BXINV_285
    );
  alu_i_result_0_map7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_0_map7_F5MUX_286,
      O => alu_i_result_0_map7
    );
  alu_i_result_0_map7_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X10Y4"
    )
    port map (
      IA => N1391,
      IB => N1392,
      SEL => alu_i_result_0_map7_BXINV_287,
      O => alu_i_result_0_map7_F5MUX_286
    );
  alu_i_result_0_map7_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_3_0,
      O => alu_i_result_0_map7_BXINV_287
    );
  alu_i_result_2_map6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_2_map6_F5MUX_288,
      O => alu_i_result_2_map6
    );
  alu_i_result_2_map6_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X12Y10"
    )
    port map (
      IA => N1395,
      IB => N1396,
      SEL => alu_i_result_2_map6_BXINV_289,
      O => alu_i_result_2_map6_F5MUX_288
    );
  alu_i_result_2_map6_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_2_map6_BXINV_289
    );
  alu_i_result_3_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_3_map15_F5MUX_290,
      O => alu_i_result_3_map15
    );
  alu_i_result_3_map15_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X8Y11"
    )
    port map (
      IA => N1399,
      IB => N1400,
      SEL => alu_i_result_3_map15_BXINV_291,
      O => alu_i_result_3_map15_F5MUX_290
    );
  alu_i_result_3_map15_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_3_map15_BXINV_291
    );
  alu_i_result_4_map15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_4_map15_F5MUX_292,
      O => alu_i_result_4_map15
    );
  alu_i_result_4_map15_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X9Y10"
    )
    port map (
      IA => N1397,
      IB => N1398,
      SEL => alu_i_result_4_map15_BXINV_293,
      O => alu_i_result_4_map15_F5MUX_292
    );
  alu_i_result_4_map15_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X9Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_4_map15_BXINV_293
    );
  alu_i_result_5_map10_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_map10_F5MUX_294,
      O => alu_i_result_5_map10
    );
  alu_i_result_5_map10_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X13Y10"
    )
    port map (
      IA => N1403,
      IB => N1404,
      SEL => alu_i_result_5_map10_BXINV_295,
      O => alu_i_result_5_map10_F5MUX_294
    );
  alu_i_result_5_map10_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_5_map10_BXINV_295
    );
  alu_i_result_6_map10_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_map10_F5MUX_296,
      O => alu_i_result_6_map10
    );
  alu_i_result_6_map10_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X14Y2"
    )
    port map (
      IA => N1401,
      IB => N1402,
      SEL => alu_i_result_6_map10_BXINV_297,
      O => alu_i_result_6_map10_F5MUX_296
    );
  alu_i_result_6_map10_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X14Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_6_map10_BXINV_297
    );
  alu_i_result_7_map10_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_map10_F5MUX_298,
      O => alu_i_result_7_map10
    );
  alu_i_result_7_map10_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X15Y2"
    )
    port map (
      IA => N1405,
      IB => N1406,
      SEL => alu_i_result_7_map10_BXINV_299,
      O => alu_i_result_7_map10_F5MUX_298
    );
  alu_i_result_7_map10_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X15Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_4_0,
      O => alu_i_result_7_map10_BXINV_299
    );
  alu_i_result_1_map2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_1_map2_F5MUX_300,
      O => alu_i_result_1_map2
    );
  alu_i_result_1_map2_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X11Y11"
    )
    port map (
      IA => N1389,
      IB => N1390,
      SEL => alu_i_result_1_map2_BXINV_301,
      O => alu_i_result_1_map2_F5MUX_300
    );
  alu_i_result_1_map2_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_3_0,
      O => alu_i_result_1_map2_BXINV_301
    );
  alu_i_result_5_map3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_map3_F5MUX_302,
      O => alu_i_result_5_map3
    );
  alu_i_result_5_map3_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X17Y5"
    )
    port map (
      IA => N1379,
      IB => N1380,
      SEL => alu_i_result_5_map3_BXINV_303,
      O => alu_i_result_5_map3_F5MUX_302
    );
  alu_i_result_5_map3_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X17Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(2),
      O => alu_i_result_5_map3_BXINV_303
    );
  alu_i_result_6_map3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_map3_F5MUX_304,
      O => alu_i_result_6_map3
    );
  alu_i_result_6_map3_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X14Y5"
    )
    port map (
      IA => N1377,
      IB => N1378,
      SEL => alu_i_result_6_map3_BXINV_305,
      O => alu_i_result_6_map3_F5MUX_304
    );
  alu_i_result_6_map3_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X14Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(2),
      O => alu_i_result_6_map3_BXINV_305
    );
  alu_i_result_7_map3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_map3_F5MUX_306,
      O => alu_i_result_7_map3
    );
  alu_i_result_7_map3_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X18Y5"
    )
    port map (
      IA => N1381,
      IB => N1382,
      SEL => alu_i_result_7_map3_BXINV_307,
      O => alu_i_result_7_map3_F5MUX_306
    );
  alu_i_result_7_map3_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y5",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int(2),
      O => alu_i_result_7_map3_BXINV_307
    );
  N1345_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1345_F5MUX_308,
      O => N1345
    );
  N1345_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X13Y4"
    )
    port map (
      IA => N1393,
      IB => N1394,
      SEL => N1345_BXINV_309,
      O => N1345_F5MUX_308
    );
  N1345_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N71,
      O => N1345_BXINV_309
    );
  N1265_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1265_F5MUX_310,
      O => N1265
    );
  N1265_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X2Y13"
    )
    port map (
      IA => N1265_G,
      IB => N1409,
      SEL => N1265_BXINV_311,
      O => N1265_F5MUX_310
    );
  N1265_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_IBUF_27,
      O => N1265_BXINV_311
    );
  reg_i_b_out_0_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X12Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_0_F5MUX_313,
      O => reg_i_b_out_0_DXMUX_312
    );
  reg_i_b_out_0_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X12Y4"
    )
    port map (
      IA => N1367,
      IB => N1368,
      SEL => reg_i_b_out_0_BXINV_314,
      O => reg_i_b_out_0_F5MUX_313
    );
  reg_i_b_out_0_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg(0),
      O => reg_i_b_out_0_BXINV_314
    );
  reg_i_b_out_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_0_SRINV_315
    );
  reg_i_b_out_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_0_CLKINV_316
    );
  reg_i_b_out_mux0000_0_F : X_LUT4
    generic map(
      INIT => X"0CAC",
      LOC => "SLICE_X12Y4"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(0),
      ADR1 => reg_i_b_out(0),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => control_int(2),
      O => N1367
    );
  reg_i_b_out_1_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1_F5MUX_318,
      O => reg_i_b_out_1_DXMUX_317
    );
  reg_i_b_out_1_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X11Y6"
    )
    port map (
      IA => N1375,
      IB => N1376,
      SEL => reg_i_b_out_1_BXINV_319,
      O => reg_i_b_out_1_F5MUX_318
    );
  reg_i_b_out_1_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg(1),
      O => reg_i_b_out_1_BXINV_319
    );
  reg_i_b_out_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_1_SRINV_320
    );
  reg_i_b_out_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_1_CLKINV_321
    );
  reg_i_b_out_mux0000_1_F : X_LUT4
    generic map(
      INIT => X"3B08",
      LOC => "SLICE_X11Y6"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(1),
      ADR1 => reg_i_b_out_and0000,
      ADR2 => control_int(2),
      ADR3 => reg_i_b_out(1),
      O => N1375
    );
  reg_i_b_out_2_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_2_F5MUX_323,
      O => reg_i_b_out_2_DXMUX_322
    );
  reg_i_b_out_2_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X10Y8"
    )
    port map (
      IA => N1373,
      IB => N1374,
      SEL => reg_i_b_out_2_BXINV_324,
      O => reg_i_b_out_2_F5MUX_323
    );
  reg_i_b_out_2_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg(2),
      O => reg_i_b_out_2_BXINV_324
    );
  reg_i_b_out_2_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_2_SRINV_325
    );
  reg_i_b_out_2_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_2_CLKINV_326
    );
  reg_i_b_out_mux0000_2_F : X_LUT4
    generic map(
      INIT => X"0CAC",
      LOC => "SLICE_X10Y8"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(2),
      ADR1 => reg_i_b_out(2),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => control_int(2),
      O => N1373
    );
  reg_i_b_out_3_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X13Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_3_F5MUX_328,
      O => reg_i_b_out_3_DXMUX_327
    );
  reg_i_b_out_3_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X13Y6"
    )
    port map (
      IA => N1371,
      IB => N1372,
      SEL => reg_i_b_out_3_BXINV_329,
      O => reg_i_b_out_3_F5MUX_328
    );
  reg_i_b_out_3_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg(3),
      O => reg_i_b_out_3_BXINV_329
    );
  reg_i_b_out_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_3_SRINV_330
    );
  reg_i_b_out_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X13Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_3_CLKINV_331
    );
  reg_i_b_out_mux0000_3_F : X_LUT4
    generic map(
      INIT => X"0ACC",
      LOC => "SLICE_X13Y6"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(3),
      ADR1 => reg_i_b_out(3),
      ADR2 => control_int(2),
      ADR3 => reg_i_b_out_and0000,
      O => N1371
    );
  reg_i_b_out_4_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X12Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_4_F5MUX_333,
      O => reg_i_b_out_4_DXMUX_332
    );
  reg_i_b_out_4_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X12Y7"
    )
    port map (
      IA => N1369,
      IB => N1370,
      SEL => reg_i_b_out_4_BXINV_334,
      O => reg_i_b_out_4_F5MUX_333
    );
  reg_i_b_out_4_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg(4),
      O => reg_i_b_out_4_BXINV_334
    );
  reg_i_b_out_4_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_b_out_4_SRINV_335
    );
  reg_i_b_out_4_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X12Y7",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_b_out_4_CLKINV_336
    );
  reg_i_b_out_mux0000_4_F : X_LUT4
    generic map(
      INIT => X"44E4",
      LOC => "SLICE_X12Y7"
    )
    port map (
      ADR0 => reg_i_b_out_and0000,
      ADR1 => reg_i_b_out(4),
      ADR2 => reg_i_rom_data_intern(4),
      ADR3 => control_int(2),
      O => N1369
    );
  N1332_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1332,
      O => N1332_0
    );
  N1332_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000356_SW0_O_pack_1,
      O => reg_i_zero_out_mux0000356_SW0_O
    );
  reg_i_zero_out_mux0000356_SW0 : X_LUT4
    generic map(
      INIT => X"FEFF",
      LOC => "SLICE_X17Y8"
    )
    port map (
      ADR0 => alu_i_add_result_int_add0000(6),
      ADR1 => alu_i_add_result_int_add0000(4),
      ADR2 => alu_i_add_result_int_add0000(5),
      ADR3 => alu_i_N61_0,
      O => reg_i_zero_out_mux0000356_SW0_O_pack_1
    );
  N1281_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1281,
      O => N1281_0
    );
  N1281_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000500_O_pack_1,
      O => reg_i_zero_out_mux0000500_O
    );
  reg_i_zero_out_mux0000500 : X_LUT4
    generic map(
      INIT => X"8A88",
      LOC => "SLICE_X17Y10"
    )
    port map (
      ADR0 => reg_i_zero_out_mux0000_map146_0,
      ADR1 => N1251_0,
      ADR2 => reg_i_carry_out_3,
      ADR3 => alu_i_zero_out_cmp_eq0010_0,
      O => reg_i_zero_out_mux0000500_O_pack_1
    );
  N1255_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1255,
      O => N1255_0
    );
  N1255_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y6",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000565_O_pack_1,
      O => reg_i_zero_out_mux0000565_O
    );
  reg_i_zero_out_mux0000565 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X18Y6"
    )
    port map (
      ADR0 => alu_i_xor0003_0,
      ADR1 => alu_i_xor0004_0,
      ADR2 => reg_i_zero_out_mux0000_map155_0,
      ADR3 => alu_i_xor0002,
      O => reg_i_zero_out_mux0000565_O_pack_1
    );
  alu_i_xor0004_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0004,
      O => alu_i_xor0004_0
    );
  alu_i_xor0004_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X15Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N7_pack_1,
      O => alu_i_N7
    );
  alu_i_Madd_add_result_int_add0000_lut_3_Q : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X15Y8"
    )
    port map (
      ADR0 => reg_i_b_out(3),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out(3),
      O => alu_i_N7_pack_1
    );
  reg_i_a_out_or0001_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_or0001,
      O => reg_i_a_out_or0001_0
    );
  reg_i_a_out_or0001_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y8",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_or0000_pack_1,
      O => reg_i_zero_out_or0000
    );
  reg_i_zero_out_or00001 : X_LUT4
    generic map(
      INIT => X"EAD5",
      LOC => "SLICE_X11Y8"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_0_0,
      ADR2 => control_int_4_0,
      ADR3 => reg_i_N0_0,
      O => reg_i_zero_out_or0000_pack_1
    );
  reg_i_a_out_5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_5_map18_pack_1,
      O => alu_i_result_5_map18
    );
  reg_i_a_out_5_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => N312,
      O => reg_i_a_out_5_REVUSED_337
    );
  reg_i_a_out_5_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X17Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1231,
      O => reg_i_a_out_5_DYMUX_338
    );
  reg_i_a_out_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X17Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_5_SRINV_339
    );
  reg_i_a_out_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X17Y0",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_5_CLKINV_340
    );
  reg_i_a_out_6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_6_map18_pack_1,
      O => alu_i_result_6_map18
    );
  reg_i_a_out_6_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N310,
      O => reg_i_a_out_6_REVUSED_341
    );
  reg_i_a_out_6_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1230,
      O => reg_i_a_out_6_DYMUX_342
    );
  reg_i_a_out_6_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_6_SRINV_343
    );
  reg_i_a_out_6_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_6_CLKINV_344
    );
  reg_i_a_out_7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_7_map18_pack_1,
      O => alu_i_result_7_map18
    );
  reg_i_a_out_7_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => N712,
      O => reg_i_a_out_7_REVUSED_345
    );
  reg_i_a_out_7_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X18Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1229,
      O => reg_i_a_out_7_DYMUX_346
    );
  reg_i_a_out_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_a_out_7_SRINV_347
    );
  reg_i_a_out_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y2",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_a_out_7_CLKINV_348
    );
  reg_i_N0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_N0,
      O => reg_i_N0_0
    );
  reg_i_N0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000323_pack_1,
      O => control_i_pr_state_or000323_9
    );
  control_i_pr_state_or000323_1 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X6Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or0003_map5_0,
      ADR2 => control_i_pr_state_or0003_map2_0,
      ADR3 => control_i_pr_state_or0003_map8,
      O => control_i_pr_state_or000323_pack_1
    );
  pc_i_pc_int_cmp_eq0003_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_cmp_eq0003_349,
      O => pc_i_pc_int_cmp_eq0003_0
    );
  pc_i_pc_int_cmp_eq0003_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => N547_pack_1,
      O => N547
    );
  pc_i_pc_int_cmp_eq0003_SW0 : X_LUT4
    generic map(
      INIT => X"0F1F",
      LOC => "SLICE_X8Y17"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0043_0,
      ADR1 => control_i_pr_state_or0005_map7_0,
      ADR2 => control_nxt_int_3_0,
      ADR3 => control_i_pr_state_or0005_map1_0,
      O => N547_pack_1
    );
  N1291_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1291,
      O => N1291_0
    );
  N1291_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X14Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_mux0000290_O_pack_1,
      O => reg_i_zero_out_mux0000290_O
    );
  reg_i_zero_out_mux0000290 : X_LUT4
    generic map(
      INIT => X"0804",
      LOC => "SLICE_X14Y10"
    )
    port map (
      ADR0 => N224,
      ADR1 => control_int_4_0,
      ADR2 => N1257_0,
      ADR3 => control_int(2),
      O => reg_i_zero_out_mux0000290_O_pack_1
    );
  reg_i_carry_out_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux0000117_O_pack_1,
      O => reg_i_carry_out_mux0000117_O
    );
  reg_i_carry_out_REVUSED : X_BUF
    generic map(
      LOC => "SLICE_X18Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_mux0000_map0,
      O => reg_i_carry_out_REVUSED_350
    );
  reg_i_carry_out_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X18Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1228,
      O => reg_i_carry_out_DYMUX_351
    );
  reg_i_carry_out_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => reg_i_carry_out_SRINV_352
    );
  reg_i_carry_out_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X18Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => reg_i_carry_out_CLKINV_353
    );
  alu_i_xor0005_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0005,
      O => alu_i_xor0005_0
    );
  alu_i_xor0005_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_xor0006_or0000_pack_1,
      O => alu_i_xor0006_or0000
    );
  alu_i_xor0006_or00001 : X_LUT4
    generic map(
      INIT => X"FCC0",
      LOC => "SLICE_X12Y11"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_b_out(0),
      ADR2 => reg_i_carry_out_3,
      ADR3 => reg_i_a_out(0),
      O => alu_i_xor0006_or0000_pack_1
    );
  alu_i_zero_out_or0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or0000_354,
      O => alu_i_zero_out_or0000_0
    );
  alu_i_zero_out_or0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => N224_pack_1,
      O => N224
    );
  alu_i_zero_out_or0000_SW0 : X_LUT4
    generic map(
      INIT => X"0100",
      LOC => "SLICE_X9Y12"
    )
    port map (
      ADR0 => control_i_pr_state_or0003_map5_0,
      ADR1 => control_i_pr_state_or0003_map2_0,
      ADR2 => control_i_pr_state_or0003_map8,
      ADR3 => control_int_0_0,
      O => N224_pack_1
    );
  pc_i_pc_int_0_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_mux0002(0),
      O => pc_i_pc_int_0_DXMUX_355
    );
  pc_i_pc_int_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int_or0000_pack_1,
      O => pc_i_pc_int_or0000_38
    );
  pc_i_pc_int_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => pc_i_pc_int_0_SRINV_356
    );
  pc_i_pc_int_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => pc_i_pc_int_0_CLKINV_357
    );
  alu_i_zero_out_or0002_map12_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_or0002_map12,
      O => alu_i_zero_out_or0002_map12_0
    );
  alu_i_zero_out_or0002_map12_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1318_pack_1,
      O => N1318
    );
  alu_i_zero_out_or000231_SW0 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y12"
    )
    port map (
      ADR0 => control_i_pr_state_or0003_map8,
      ADR1 => control_i_pr_state_or0003_map2_0,
      ADR2 => control_i_pr_state_or000427_0,
      ADR3 => control_i_pr_state_or0003_map5_0,
      O => N1318_pack_1
    );
  control_i_pr_state_or000117_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000117_358,
      O => control_i_pr_state_or000117_0
    );
  control_i_pr_state_or000117_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0001_map2_pack_1,
      O => control_i_pr_state_or0001_map2
    );
  control_i_pr_state_or00014 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y13"
    )
    port map (
      ADR0 => control_i_pr_state_FFd8_36,
      ADR1 => control_i_pr_state_FFd12_26,
      ADR2 => control_i_pr_state_FFd13_23,
      ADR3 => control_i_pr_state_FFd9_25,
      O => control_i_pr_state_or0001_map2_pack_1
    );
  control_i_pr_state_or000223_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000223_359,
      O => control_i_pr_state_or000223_0
    );
  control_i_pr_state_or000223_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0002_map8_pack_1,
      O => control_i_pr_state_or0002_map8
    );
  control_i_pr_state_or000214 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd22_13,
      ADR1 => control_i_pr_state_FFd5_35,
      ADR2 => control_i_pr_state_FFd24_14,
      ADR3 => control_i_pr_state_FFd4_32,
      O => control_i_pr_state_or0002_map8_pack_1
    );
  control_i_pr_state_or0002231_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0002231,
      O => control_i_pr_state_or0002231_0
    );
  control_i_pr_state_or0002231_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or0002_map5_pack_1,
      O => control_i_pr_state_or0002_map5
    );
  control_i_pr_state_or00029 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd15_19,
      ADR1 => control_i_pr_state_FFd21_17,
      ADR2 => control_i_pr_state_FFd23_18,
      ADR3 => control_i_pr_state_FFd20_24,
      O => control_i_pr_state_or0002_map5_pack_1
    );
  alu_i_zero_out_cmp_eq0004_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0004,
      O => alu_i_zero_out_cmp_eq0004_0
    );
  alu_i_zero_out_cmp_eq0004_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1316_pack_1,
      O => N1316
    );
  alu_i_zero_out_cmp_eq00041_SW0 : X_LUT4
    generic map(
      INIT => X"FFFB",
      LOC => "SLICE_X13Y13"
    )
    port map (
      ADR0 => control_i_pr_state_or0002_map2_0,
      ADR1 => control_i_pr_state_or000427_0,
      ADR2 => control_i_pr_state_or0002_map5,
      ADR3 => control_i_pr_state_or0002_map8,
      O => N1316_pack_1
    );
  alu_i_zero_out_cmp_eq0006_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_zero_out_cmp_eq0006,
      O => alu_i_zero_out_cmp_eq0006_0
    );
  alu_i_zero_out_cmp_eq0006_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N22_pack_1,
      O => alu_i_N22
    );
  alu_i_carry_out421 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X8Y13"
    )
    port map (
      ADR0 => control_i_pr_state_or0003_map8,
      ADR1 => control_i_pr_state_or000223_0,
      ADR2 => control_i_pr_state_or0003_map2_0,
      ADR3 => control_i_pr_state_or0003_map5_0,
      O => alu_i_N22_pack_1
    );
  alu_i_N61_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_N61,
      O => alu_i_N61_0
    );
  alu_i_N61_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000017_pack_1,
      O => control_i_pr_state_or000017_42
    );
  control_i_pr_state_or000017_1 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X6Y10"
    )
    port map (
      ADR0 => control_i_pr_state_FFd16_10,
      ADR1 => control_i_pr_state_FFd18_11,
      ADR2 => control_i_pr_state_or0000_map6,
      ADR3 => control_i_pr_state_or0000_map2_0,
      O => control_i_pr_state_or000017_pack_1
    );
  control_i_pr_state_or000427_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_pr_state_or000427_360,
      O => control_i_pr_state_or000427_0
    );
  control_i_pr_state_or000427_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => N1249_pack_1,
      O => N1249
    );
  control_i_pr_state_or000427_SW0 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd1_40,
      ADR1 => control_i_pr_state_FFd23_18,
      ADR2 => control_i_pr_state_FFd12_26,
      ADR3 => control_i_pr_state_FFd11_7,
      O => N1249_pack_1
    );
  pc_i_pc_int_7_rt : X_LUT4
    generic map(
      INIT => X"AAAA",
      LOC => "SLICE_X9Y19"
    )
    port map (
      ADR0 => pc_i_pc_int(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => VCC,
      O => pc_i_pc_int_7_rt_227
    );
  ram_control_i_ram_data_reg_0 : X_FF
    generic map(
      LOC => "PAD62",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_0_IFF_IFFDMUX_363,
      CE => datmem_data_in_0_IFF_ICEINV_362,
      CLK => datmem_data_in_0_IFF_ICLK1INV_361,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(0)
    );
  datmem_data_in_0_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_0_INBUF,
      O => datmem_data_in_0_IFF_IFFDMUX_363
    );
  datmem_data_in_0_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_0_IFF_ICLK1INV_361
    );
  datmem_data_in_0_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_0_IFF_ICEINV_362
    );
  ram_control_i_ram_data_reg_1 : X_FF
    generic map(
      LOC => "PAD61",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_1_IFF_IFFDMUX_366,
      CE => datmem_data_in_1_IFF_ICEINV_365,
      CLK => datmem_data_in_1_IFF_ICLK1INV_364,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(1)
    );
  datmem_data_in_1_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_1_INBUF,
      O => datmem_data_in_1_IFF_IFFDMUX_366
    );
  datmem_data_in_1_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_1_IFF_ICLK1INV_364
    );
  datmem_data_in_1_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_1_IFF_ICEINV_365
    );
  ram_control_i_ram_data_reg_2 : X_FF
    generic map(
      LOC => "PAD69",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_2_IFF_IFFDMUX_369,
      CE => datmem_data_in_2_IFF_ICEINV_368,
      CLK => datmem_data_in_2_IFF_ICLK1INV_367,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(2)
    );
  datmem_data_in_2_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_2_INBUF,
      O => datmem_data_in_2_IFF_IFFDMUX_369
    );
  datmem_data_in_2_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_2_IFF_ICLK1INV_367
    );
  datmem_data_in_2_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_2_IFF_ICEINV_368
    );
  ram_control_i_ram_data_reg_3 : X_FF
    generic map(
      LOC => "PAD70",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_3_IFF_IFFDMUX_372,
      CE => datmem_data_in_3_IFF_ICEINV_371,
      CLK => datmem_data_in_3_IFF_ICLK1INV_370,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(3)
    );
  datmem_data_in_3_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_3_INBUF,
      O => datmem_data_in_3_IFF_IFFDMUX_372
    );
  datmem_data_in_3_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_3_IFF_ICLK1INV_370
    );
  datmem_data_in_3_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_3_IFF_ICEINV_371
    );
  ram_control_i_ram_data_reg_4 : X_FF
    generic map(
      LOC => "PAD63",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_4_IFF_IFFDMUX_375,
      CE => datmem_data_in_4_IFF_ICEINV_374,
      CLK => datmem_data_in_4_IFF_ICLK1INV_373,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(4)
    );
  datmem_data_in_4_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD63",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_4_INBUF,
      O => datmem_data_in_4_IFF_IFFDMUX_375
    );
  datmem_data_in_4_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD63",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_4_IFF_ICLK1INV_373
    );
  datmem_data_in_4_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD63",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_4_IFF_ICEINV_374
    );
  ram_control_i_ram_data_reg_5 : X_FF
    generic map(
      LOC => "PAD55",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_5_IFF_IFFDMUX_378,
      CE => datmem_data_in_5_IFF_ICEINV_377,
      CLK => datmem_data_in_5_IFF_ICLK1INV_376,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(5)
    );
  datmem_data_in_5_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_5_INBUF,
      O => datmem_data_in_5_IFF_IFFDMUX_378
    );
  datmem_data_in_5_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_5_IFF_ICLK1INV_376
    );
  datmem_data_in_5_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_5_IFF_ICEINV_377
    );
  ram_control_i_ram_data_reg_6 : X_FF
    generic map(
      LOC => "PAD56",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_6_IFF_IFFDMUX_381,
      CE => datmem_data_in_6_IFF_ICEINV_380,
      CLK => datmem_data_in_6_IFF_ICLK1INV_379,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(6)
    );
  datmem_data_in_6_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_6_INBUF,
      O => datmem_data_in_6_IFF_IFFDMUX_381
    );
  datmem_data_in_6_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_6_IFF_ICLK1INV_379
    );
  datmem_data_in_6_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_6_IFF_ICEINV_380
    );
  ram_control_i_ram_data_reg_7 : X_FF
    generic map(
      LOC => "PAD59",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_7_IFF_IFFDMUX_384,
      CE => datmem_data_in_7_IFF_ICEINV_383,
      CLK => datmem_data_in_7_IFF_ICLK1INV_382,
      SET => GND,
      RST => GND,
      O => ram_control_i_ram_data_reg(7)
    );
  datmem_data_in_7_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_7_INBUF,
      O => datmem_data_in_7_IFF_IFFDMUX_384
    );
  datmem_data_in_7_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_IBUF_5,
      O => datmem_data_in_7_IFF_ICLK1INV_382
    );
  datmem_data_in_7_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_ram_data_reg_or0000_0,
      O => datmem_data_in_7_IFF_ICEINV_383
    );
  alu_i_result_4_22_SW0_F : X_LUT4
    generic map(
      INIT => X"1010",
      LOC => "SLICE_X18Y4"
    )
    port map (
      ADR0 => control_int_1_0,
      ADR1 => reg_i_a_out(4),
      ADR2 => alu_i_N61_0,
      ADR3 => VCC,
      O => N1383
    );
  control_i_pr_state_FFd26_In34_F : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X3Y12"
    )
    port map (
      ADR0 => reg_i_zero_out_6,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => prog_data_3_IBUF_33,
      O => N1387
    );
  alu_i_result_0_15_F : X_LUT4
    generic map(
      INIT => X"8020",
      LOC => "SLICE_X10Y4"
    )
    port map (
      ADR0 => prog_data_0_IBUF_0,
      ADR1 => control_int(2),
      ADR2 => control_int_4_0,
      ADR3 => N224,
      O => N1391
    );
  alu_i_result_2_11_F : X_LUT4
    generic map(
      INIT => X"0101",
      LOC => "SLICE_X12Y10"
    )
    port map (
      ADR0 => control_i_pr_state_or000117_0,
      ADR1 => N1355_0,
      ADR2 => control_int_0_0,
      ADR3 => VCC,
      O => N1395
    );
  alu_i_result_3_44_F : X_LUT4
    generic map(
      INIT => X"0005",
      LOC => "SLICE_X8Y11"
    )
    port map (
      ADR0 => control_int_0_0,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_or000117_0,
      ADR3 => N1353_0,
      O => N1399
    );
  alu_i_result_4_44_F : X_LUT4
    generic map(
      INIT => X"0011",
      LOC => "SLICE_X9Y10"
    )
    port map (
      ADR0 => control_i_pr_state_or000117_0,
      ADR1 => control_int_0_0,
      ADR2 => VCC,
      ADR3 => N1351_0,
      O => N1397
    );
  alu_i_result_5_28_F : X_LUT4
    generic map(
      INIT => X"0040",
      LOC => "SLICE_X13Y10"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_N9,
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => N1316,
      O => N1403
    );
  alu_i_result_6_28_F : X_LUT4
    generic map(
      INIT => X"0400",
      LOC => "SLICE_X14Y2"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_N10_0,
      ADR2 => N1316,
      ADR3 => control_i_pr_state_or000323_9,
      O => N1401
    );
  alu_i_result_7_28_F : X_LUT4
    generic map(
      INIT => X"0020",
      LOC => "SLICE_X15Y2"
    )
    port map (
      ADR0 => control_i_pr_state_or000323_9,
      ADR1 => N1316,
      ADR2 => alu_i_N11_0,
      ADR3 => control_int_3_0,
      O => N1405
    );
  alu_i_result_1_4_F : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X11Y11"
    )
    port map (
      ADR0 => alu_i_N5,
      ADR1 => control_int_1_0,
      ADR2 => control_int_4_0,
      ADR3 => N1316,
      O => N1389
    );
  alu_i_result_5_7_F : X_LUT4
    generic map(
      INIT => X"0404",
      LOC => "SLICE_X17Y5"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => alu_i_N61_0,
      ADR2 => control_int_1_0,
      ADR3 => VCC,
      O => N1379
    );
  alu_i_result_6_7_F : X_LUT4
    generic map(
      INIT => X"0030",
      LOC => "SLICE_X14Y5"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N61_0,
      ADR3 => reg_i_a_out(6),
      O => N1377
    );
  alu_i_result_7_7_F : X_LUT4
    generic map(
      INIT => X"1010",
      LOC => "SLICE_X18Y5"
    )
    port map (
      ADR0 => reg_i_a_out(7),
      ADR1 => control_int_1_0,
      ADR2 => alu_i_N61_0,
      ADR3 => VCC,
      O => N1381
    );
  alu_i_result_0_41_SW1_F : X_LUT4
    generic map(
      INIT => X"4100",
      LOC => "SLICE_X13Y4"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => control_int_1_0,
      ADR2 => control_int(2),
      ADR3 => alu_i_N61_0,
      O => N1393
    );
  reg_i_zero_out_mux00006301 : X_LUT4
    generic map(
      INIT => X"5545",
      LOC => "SLICE_X19Y10"
    )
    port map (
      ADR0 => reg_i_zero_out_or0000,
      ADR1 => reg_i_zero_out_mux0000314_O,
      ADR2 => N1281_0,
      ADR3 => N1255_0,
      O => N1237
    );
  control_i_pr_state_FFd11_In_SW0 : X_LUT4
    generic map(
      INIT => X"AFAF",
      LOC => "SLICE_X6Y13"
    )
    port map (
      ADR0 => reg_i_zero_out_6,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_cmp_eq0009,
      ADR3 => VCC,
      O => control_i_pr_state_FFd11_In_SW0_O_pack_1
    );
  alu_i_Madd_add_result_int_add0000_lut_2_1 : X_LUT4
    generic map(
      INIT => X"33CC",
      LOC => "SLICE_X16Y9"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_a_out(2),
      ADR2 => VCC,
      ADR3 => reg_i_b_out(2),
      O => N1243
    );
  alu_i_Madd_add_result_int_add0000_lut_4_1 : X_LUT4
    generic map(
      INIT => X"33CC",
      LOC => "SLICE_X16Y10"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_a_out(4),
      ADR2 => VCC,
      ADR3 => reg_i_b_out(4),
      O => N1241
    );
  reg_i_b_out_mux0000_5_SW1 : X_LUT4
    generic map(
      INIT => X"EFE0",
      LOC => "SLICE_X16Y0"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_rom_data_intern(5),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_b_out(5),
      O => reg_i_b_out_mux0000_5_SW1_O_pack_1
    );
  reg_i_b_out_mux0000_6_SW1 : X_LUT4
    generic map(
      INIT => X"EFE0",
      LOC => "SLICE_X17Y7"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_rom_data_intern(6),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_b_out(6),
      O => reg_i_b_out_mux0000_6_SW1_O_pack_1
    );
  reg_i_b_out_mux0000_7_SW1 : X_LUT4
    generic map(
      INIT => X"FCAC",
      LOC => "SLICE_X19Y2"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_b_out(7),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_rom_data_intern(7),
      O => reg_i_b_out_mux0000_7_SW1_O_pack_1
    );
  control_i_pr_state_FFd10_In2 : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X5Y17"
    )
    port map (
      ADR0 => reg_i_carry_out_3,
      ADR1 => control_i_pr_state_FFd26_2,
      ADR2 => prog_data_7_IBUF_28,
      ADR3 => N1263_0,
      O => control_i_pr_state_cmp_eq0055_pack_1
    );
  control_i_pr_state_FFd12_In1 : X_LUT4
    generic map(
      INIT => X"0100",
      LOC => "SLICE_X4Y17"
    )
    port map (
      ADR0 => N1267_0,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => control_i_pr_state_FFd26_2,
      ADR3 => reg_i_zero_out_6,
      O => control_i_pr_state_cmp_eq0056_pack_1
    );
  control_i_pr_state_FFd14_In1 : X_LUT4
    generic map(
      INIT => X"00A0",
      LOC => "SLICE_X6Y17"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0013,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_cmp_eq0015_0,
      ADR3 => control_i_pr_state_FFd26_1_31,
      O => control_i_pr_state_cmp_eq0044_pack_1
    );
  control_i_pr_state_FFd5_In1 : X_LUT4
    generic map(
      INIT => X"2020",
      LOC => "SLICE_X7Y18"
    )
    port map (
      ADR0 => control_i_N6,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => control_i_N11,
      ADR3 => VCC,
      O => control_i_pr_state_cmp_eq0062
    );
  control_i_pr_state_FFd7_In : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X5Y11"
    )
    port map (
      ADR0 => prog_data_2_IBUF_34,
      ADR1 => control_i_pr_state_FFd26_2,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => N166_0,
      O => control_i_pr_state_cmp_eq0064
    );
  control_i_pr_state_FFd9_In : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X2Y12"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => N1265,
      ADR3 => control_i_pr_state_FFd26_2,
      O => control_i_pr_state_cmp_eq0054
    );
  control_i_pr_state_FFd1_In11_SW0 : X_LUT4
    generic map(
      INIT => X"F5FF",
      LOC => "SLICE_X7Y16"
    )
    port map (
      ADR0 => control_i_N9,
      ADR1 => VCC,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => prog_data_5_IBUF_27,
      O => N1302_pack_1
    );
  control_i_pr_state_FFd16_In1 : X_LUT4
    generic map(
      INIT => X"4000",
      LOC => "SLICE_X5Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd26_2,
      ADR1 => control_i_pr_state_cmp_eq0016,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_N5,
      O => control_i_pr_state_cmp_eq0045_pack_1
    );
  control_i_pr_state_FFd26_In11 : X_LUT4
    generic map(
      INIT => X"F4F0",
      LOC => "SLICE_X3Y14"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => N1357_0,
      ADR3 => control_i_pr_state_cmp_eq0015_0,
      O => control_i_pr_state_FFd26_In_map5_pack_1
    );
  control_i_pr_state_FFd18_In1 : X_LUT4
    generic map(
      INIT => X"00C0",
      LOC => "SLICE_X5Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_cmp_eq0016,
      ADR2 => control_i_pr_state_cmp_eq0015_0,
      ADR3 => control_i_pr_state_FFd26_2,
      O => control_i_pr_state_cmp_eq0046_pack_1
    );
  control_i_pr_state_cmp_eq00161 : X_LUT4
    generic map(
      INIT => X"4040",
      LOC => "SLICE_X4Y15"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => prog_data_5_IBUF_27,
      ADR2 => prog_data_7_IBUF_28,
      ADR3 => VCC,
      O => control_i_pr_state_cmp_eq0016_pack_1
    );
  control_i_pr_state_cmp_eq00131 : X_LUT4
    generic map(
      INIT => X"0044",
      LOC => "SLICE_X6Y14"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => VCC,
      ADR3 => prog_data_5_IBUF_27,
      O => control_i_pr_state_cmp_eq0013_pack_1
    );
  reg_i_a_out_mux0000_0_1 : X_LUT4
    generic map(
      INIT => X"AA00",
      LOC => "SLICE_X13Y5"
    )
    port map (
      ADR0 => result_alu_reg(0),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out_or0000_0,
      O => N1236
    );
  reg_i_a_out_mux0000_1_1 : X_LUT4
    generic map(
      INIT => X"AA00",
      LOC => "SLICE_X10Y10"
    )
    port map (
      ADR0 => result_alu_reg(1),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out_or0000_0,
      O => N1235
    );
  reg_i_a_out_mux0000_2_1 : X_LUT4
    generic map(
      INIT => X"AA00",
      LOC => "SLICE_X11Y9"
    )
    port map (
      ADR0 => result_alu_reg(2),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out_or0000_0,
      O => N1234
    );
  reg_i_a_out_mux0000_3_1 : X_LUT4
    generic map(
      INIT => X"8888",
      LOC => "SLICE_X12Y6"
    )
    port map (
      ADR0 => result_alu_reg(3),
      ADR1 => reg_i_a_out_or0000_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => N1233
    );
  reg_i_a_out_mux0000_4_1 : X_LUT4
    generic map(
      INIT => X"AA00",
      LOC => "SLICE_X13Y7"
    )
    port map (
      ADR0 => result_alu_reg(4),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out_or0000_0,
      O => N1232
    );
  reg_i_rom_data_intern_0 : X_SFF
    generic map(
      LOC => "PAD76",
      INIT => '0'
    )
    port map (
      I => prog_data_0_IFF_IFFDMUX_258,
      CE => VCC,
      CLK => prog_data_0_IFF_ICLK1INV_257,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_0_IFF_ISR_USED_256,
      O => reg_i_rom_data_intern(0)
    );
  reg_i_rom_data_intern_1 : X_SFF
    generic map(
      LOC => "PAD80",
      INIT => '0'
    )
    port map (
      I => prog_data_1_IFF_IFFDMUX_261,
      CE => VCC,
      CLK => prog_data_1_IFF_ICLK1INV_260,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_1_IFF_ISR_USED_259,
      O => reg_i_rom_data_intern(1)
    );
  reg_i_rom_data_intern_2 : X_SFF
    generic map(
      LOC => "PAD101",
      INIT => '0'
    )
    port map (
      I => prog_data_2_IFF_IFFDMUX_264,
      CE => VCC,
      CLK => prog_data_2_IFF_ICLK1INV_263,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_2_IFF_ISR_USED_262,
      O => reg_i_rom_data_intern(2)
    );
  reg_i_rom_data_intern_3 : X_SFF
    generic map(
      LOC => "PAD77",
      INIT => '0'
    )
    port map (
      I => prog_data_3_IFF_IFFDMUX_267,
      CE => VCC,
      CLK => prog_data_3_IFF_ICLK1INV_266,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_3_IFF_ISR_USED_265,
      O => reg_i_rom_data_intern(3)
    );
  reg_i_rom_data_intern_4 : X_SFF
    generic map(
      LOC => "PAD84",
      INIT => '0'
    )
    port map (
      I => prog_data_4_IFF_IFFDMUX_270,
      CE => VCC,
      CLK => prog_data_4_IFF_ICLK1INV_269,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_4_IFF_ISR_USED_268,
      O => reg_i_rom_data_intern(4)
    );
  reg_i_rom_data_intern_5 : X_SFF
    generic map(
      LOC => "PAD71",
      INIT => '0'
    )
    port map (
      I => prog_data_5_IFF_IFFDMUX_273,
      CE => VCC,
      CLK => prog_data_5_IFF_ICLK1INV_272,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_5_IFF_ISR_USED_271,
      O => reg_i_rom_data_intern(5)
    );
  reg_i_rom_data_intern_6 : X_SFF
    generic map(
      LOC => "PAD74",
      INIT => '0'
    )
    port map (
      I => prog_data_6_IFF_IFFDMUX_276,
      CE => VCC,
      CLK => prog_data_6_IFF_ICLK1INV_275,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_6_IFF_ISR_USED_274,
      O => reg_i_rom_data_intern(6)
    );
  reg_i_rom_data_intern_7 : X_SFF
    generic map(
      LOC => "PAD72",
      INIT => '0'
    )
    port map (
      I => prog_data_7_IFF_IFFDMUX_279,
      CE => VCC,
      CLK => prog_data_7_IFF_ICLK1INV_278,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_7_IFF_ISR_USED_277,
      O => reg_i_rom_data_intern(7)
    );
  alu_i_result_3_22_SW0_G : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X14Y6"
    )
    port map (
      ADR0 => ram_control_i_ram_data_reg(3),
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => control_int_3_0,
      O => N1386
    );
  alu_i_result_4_22_SW0_G : X_LUT4
    generic map(
      INIT => X"0400",
      LOC => "SLICE_X18Y4"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => ram_control_i_ram_data_reg(4),
      ADR2 => control_int_0_0,
      ADR3 => control_int_4_0,
      O => N1384
    );
  control_i_pr_state_FFd26_In34_G : X_LUT4
    generic map(
      INIT => X"000E",
      LOC => "SLICE_X3Y12"
    )
    port map (
      ADR0 => reg_i_carry_out_3,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => prog_data_3_IBUF_33,
      O => N1388
    );
  alu_i_result_0_15_G : X_LUT4
    generic map(
      INIT => X"0906",
      LOC => "SLICE_X10Y4"
    )
    port map (
      ADR0 => reg_i_b_out(0),
      ADR1 => reg_i_carry_out_3,
      ADR2 => reg_i_N0_0,
      ADR3 => reg_i_a_out(0),
      O => N1392
    );
  alu_i_result_2_11_G : X_LUT4
    generic map(
      INIT => X"2010",
      LOC => "SLICE_X12Y10"
    )
    port map (
      ADR0 => N224,
      ADR1 => control_int_3_0,
      ADR2 => prog_data_2_IBUF_34,
      ADR3 => control_int(2),
      O => N1396
    );
  alu_i_result_3_44_G : X_LUT4
    generic map(
      INIT => X"0084",
      LOC => "SLICE_X8Y11"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => prog_data_3_IBUF_33,
      ADR2 => N224,
      ADR3 => control_int_3_0,
      O => N1400
    );
  alu_i_result_4_44_G : X_LUT4
    generic map(
      INIT => X"0802",
      LOC => "SLICE_X9Y10"
    )
    port map (
      ADR0 => prog_data_4_IBUF_39,
      ADR1 => control_int(2),
      ADR2 => control_int_3_0,
      ADR3 => N224,
      O => N1398
    );
  alu_i_result_5_28_G : X_LUT4
    generic map(
      INIT => X"0084",
      LOC => "SLICE_X13Y10"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => prog_data_5_IBUF_27,
      ADR2 => N224,
      ADR3 => control_int_3_0,
      O => N1404
    );
  alu_i_result_6_28_G : X_LUT4
    generic map(
      INIT => X"4004",
      LOC => "SLICE_X14Y2"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => prog_data_6_IBUF_29,
      ADR2 => N224,
      ADR3 => control_int(2),
      O => N1402
    );
  alu_i_result_7_28_G : X_LUT4
    generic map(
      INIT => X"2010",
      LOC => "SLICE_X15Y2"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => control_int_3_0,
      ADR2 => prog_data_7_IBUF_28,
      ADR3 => N224,
      O => N1406
    );
  alu_i_result_1_4_G : X_LUT4
    generic map(
      INIT => X"4114",
      LOC => "SLICE_X11Y11"
    )
    port map (
      ADR0 => reg_i_N0_0,
      ADR1 => reg_i_b_out(1),
      ADR2 => reg_i_a_out(1),
      ADR3 => alu_i_xor0006_or0000,
      O => N1390
    );
  alu_i_result_5_7_G : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X17Y5"
    )
    port map (
      ADR0 => ram_control_i_ram_data_reg(5),
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => control_int_3_0,
      O => N1380
    );
  alu_i_result_6_7_G : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X14Y5"
    )
    port map (
      ADR0 => ram_control_i_ram_data_reg(6),
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => control_int_3_0,
      O => N1378
    );
  alu_i_result_7_7_G : X_LUT4
    generic map(
      INIT => X"0400",
      LOC => "SLICE_X18Y5"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_4_0,
      ADR2 => control_int_0_0,
      ADR3 => ram_control_i_ram_data_reg(7),
      O => N1382
    );
  alu_i_result_0_41_SW1_G : X_LUT4
    generic map(
      INIT => X"4908",
      LOC => "SLICE_X13Y4"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => control_int_1_0,
      ADR2 => control_int(2),
      ADR3 => alu_i_N61_0,
      O => N1394
    );
  reg_i_b_out_mux0000_0_G : X_LUT4
    generic map(
      INIT => X"FCAC",
      LOC => "SLICE_X12Y4"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(0),
      ADR1 => reg_i_b_out(0),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => control_int(2),
      O => N1368
    );
  reg_i_b_out_mux0000_1_G : X_LUT4
    generic map(
      INIT => X"FBC8",
      LOC => "SLICE_X11Y6"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(1),
      ADR1 => reg_i_b_out_and0000,
      ADR2 => control_int(2),
      ADR3 => reg_i_b_out(1),
      O => N1376
    );
  reg_i_b_out_mux0000_2_G : X_LUT4
    generic map(
      INIT => X"FCAC",
      LOC => "SLICE_X10Y8"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(2),
      ADR1 => reg_i_b_out(2),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => control_int(2),
      O => N1374
    );
  reg_i_b_out_mux0000_3_G : X_LUT4
    generic map(
      INIT => X"FACC",
      LOC => "SLICE_X13Y6"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(3),
      ADR1 => reg_i_b_out(3),
      ADR2 => control_int(2),
      ADR3 => reg_i_b_out_and0000,
      O => N1372
    );
  reg_i_b_out_mux0000_4_G : X_LUT4
    generic map(
      INIT => X"EEE4",
      LOC => "SLICE_X12Y7"
    )
    port map (
      ADR0 => reg_i_b_out_and0000,
      ADR1 => reg_i_b_out(4),
      ADR2 => reg_i_rom_data_intern(4),
      ADR3 => control_int(2),
      O => N1370
    );
  reg_i_a_out_mux0000_5_1 : X_LUT4
    generic map(
      INIT => X"A888",
      LOC => "SLICE_X17Y0"
    )
    port map (
      ADR0 => reg_i_a_out_or0000_0,
      ADR1 => alu_i_result_5_map18,
      ADR2 => alu_i_xor0002,
      ADR3 => alu_i_zero_out_cmp_eq0014_0,
      O => N1231
    );
  reg_i_a_out_mux0000_6_1 : X_LUT4
    generic map(
      INIT => X"E0A0",
      LOC => "SLICE_X16Y4"
    )
    port map (
      ADR0 => alu_i_result_6_map18,
      ADR1 => alu_i_xor0001,
      ADR2 => reg_i_a_out_or0000_0,
      ADR3 => alu_i_zero_out_cmp_eq0014_0,
      O => N1230
    );
  reg_i_a_out_mux0000_7_1 : X_LUT4
    generic map(
      INIT => X"E0A0",
      LOC => "SLICE_X18Y2"
    )
    port map (
      ADR0 => alu_i_result_7_map18,
      ADR1 => alu_i_xor0000,
      ADR2 => reg_i_a_out_or0000_0,
      ADR3 => alu_i_zero_out_cmp_eq0014_0,
      O => N1229
    );
  reg_i_carry_out_mux00001471 : X_LUT4
    generic map(
      INIT => X"00FA",
      LOC => "SLICE_X18Y10"
    )
    port map (
      ADR0 => reg_i_carry_out_mux0000117_O,
      ADR1 => VCC,
      ADR2 => reg_i_carry_out_mux0000_map26_0,
      ADR3 => reg_i_zero_out_or0000,
      O => N1228
    );
  pc_i_pc_int_or0000 : X_LUT4
    generic map(
      INIT => X"004C",
      LOC => "SLICE_X6Y19"
    )
    port map (
      ADR0 => control_nxt_int_1_0,
      ADR1 => control_nxt_int_2_0,
      ADR2 => control_nxt_int_0_0,
      ADR3 => N65_0,
      O => pc_i_pc_int_or0000_pack_1
    );
  control_i_pr_state_or00096_SW2 : X_LUT4
    generic map(
      INIT => X"F1FD",
      LOC => "SLICE_X2Y16"
    )
    port map (
      ADR0 => N1275_0,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => control_i_pr_state_cmp_eq0056,
      ADR3 => control_i_pr_state_or00096_SW1_O,
      O => N1322
    );
  ram_control_i_ram_data_reg_or00001 : X_LUT4
    generic map(
      INIT => X"30C0",
      LOC => "SLICE_X20Y5"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_1_0,
      ADR2 => N1,
      ADR3 => control_int(2),
      O => ram_control_i_ram_data_reg_or0000
    );
  alu_i_result_1_11 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X11Y12"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0006_0,
      ADR1 => alu_i_zero_out_or0002_map7_0,
      ADR2 => alu_i_zero_out_or000234_SW0_O,
      ADR3 => alu_i_zero_out_or0002_map12_0,
      O => alu_i_N1
    );
  alu_i_result_1_13 : X_LUT4
    generic map(
      INIT => X"FEFA",
      LOC => "SLICE_X11Y10"
    )
    port map (
      ADR0 => alu_i_result_1_map2,
      ADR1 => alu_i_zero_out_or0000_0,
      ADR2 => alu_i_result_1_111_SW0_O,
      ADR3 => prog_data_1_IBUF_8,
      O => alu_i_result_1_map7
    );
  alu_i_result_1_25 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X13Y9"
    )
    port map (
      ADR0 => alu_i_N22,
      ADR1 => alu_i_N71,
      ADR2 => alu_i_zero_out_cmp_eq00101_SW0_O,
      ADR3 => alu_i_N61_0,
      O => alu_i_N3
    );
  reg_i_b_out_mux0000_6_SW0 : X_LUT4
    generic map(
      INIT => X"4F40",
      LOC => "SLICE_X17Y6"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_rom_data_intern(6),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_b_out(6),
      O => N620
    );
  alu_i_result_2_13 : X_LUT4
    generic map(
      INIT => X"FFEC",
      LOC => "SLICE_X13Y11"
    )
    port map (
      ADR0 => alu_i_xor0005_0,
      ADR1 => alu_i_result_2_4_SW0_O,
      ADR2 => alu_i_zero_out_cmp_eq0014_0,
      ADR3 => alu_i_result_2_map6,
      O => alu_i_result_2_map7
    );
  control_i_pr_state_FFd11_In : X_LUT4
    generic map(
      INIT => X"4C0C",
      LOC => "SLICE_X6Y13"
    )
    port map (
      ADR0 => reg_i_carry_out_3,
      ADR1 => control_i_N12_0,
      ADR2 => control_i_pr_state_FFd11_In_SW0_O,
      ADR3 => control_i_pr_state_cmp_eq0012,
      O => control_i_pr_state_cmp_eq0043
    );
  control_i_pr_state_FFd11 : X_SFF
    generic map(
      LOC => "SLICE_X6Y13",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd11_DXMUX_50,
      CE => VCC,
      CLK => control_i_pr_state_FFd11_CLKINV_53,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd11_SRINV_52,
      O => control_i_pr_state_FFd11_7
    );
  alu_i_zero_out_cmp_eq00002_SW2 : X_LUT4
    generic map(
      INIT => X"0040",
      LOC => "SLICE_X16Y6"
    )
    port map (
      ADR0 => control_int_1_0,
      ADR1 => reg_i_zero_out_mux0000_map6_0,
      ADR2 => reg_i_zero_out_mux00005_O,
      ADR3 => control_int(2),
      O => N1310
    );
  alu_i_result_0_41 : X_LUT4
    generic map(
      INIT => X"FBC8",
      LOC => "SLICE_X11Y5"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0006_0,
      ADR1 => reg_i_b_out(0),
      ADR2 => N1345,
      ADR3 => alu_i_result_0_41_SW0_O,
      O => alu_i_result_0_map17
    );
  alu_i_result_0_17 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X12Y5"
    )
    port map (
      ADR0 => alu_i_N4_0,
      ADR1 => alu_i_zero_out_cmp_eq0004_0,
      ADR2 => alu_i_result_0_4_O,
      ADR3 => alu_i_result_0_map7,
      O => alu_i_result_0_map8
    );
  alu_i_result_4_8 : X_LUT4
    generic map(
      INIT => X"F0F8",
      LOC => "SLICE_X14Y7"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_xor0003_0,
      ADR2 => alu_i_result_4_8_SW0_O,
      ADR3 => reg_i_N0_0,
      O => alu_i_result_4_map4
    );
  alu_i_result_7_70_SW0 : X_LUT4
    generic map(
      INIT => X"2020",
      LOC => "SLICE_X20Y3"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => reg_i_N0_0,
      ADR2 => alu_i_xor0000,
      ADR3 => VCC,
      O => N1287
    );
  control_i_pr_state_or000017 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd16_10,
      ADR1 => control_i_pr_state_FFd18_11,
      ADR2 => control_i_pr_state_or0000_map6,
      ADR3 => control_i_pr_state_or0000_map2_0,
      O => control_int(4)
    );
  control_i_pr_state_or000117 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y13"
    )
    port map (
      ADR0 => control_i_pr_state_FFd11_7,
      ADR1 => control_i_pr_state_FFd10_16,
      ADR2 => control_i_pr_state_or0001_map6,
      ADR3 => control_i_pr_state_or0001_map2,
      O => control_int(3)
    );
  reg_i_carry_out_mux000092 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X14Y12"
    )
    port map (
      ADR0 => reg_i_carry_out_mux000023_O,
      ADR1 => reg_i_carry_out_mux0000_map20_0,
      ADR2 => reg_i_carry_out_3,
      ADR3 => reg_i_carry_out_mux0000_map24_0,
      O => reg_i_carry_out_mux0000_map26
    );
  alu_i_result_5_70_SW0 : X_LUT4
    generic map(
      INIT => X"0A00",
      LOC => "SLICE_X19Y4"
    )
    port map (
      ADR0 => alu_i_xor0002,
      ADR1 => VCC,
      ADR2 => reg_i_N0_0,
      ADR3 => control_int_3_0,
      O => N1285
    );
  reg_i_zero_out : X_SFF
    generic map(
      LOC => "SLICE_X19Y10",
      INIT => '0'
    )
    port map (
      I => reg_i_zero_out_DYMUX_47,
      CE => VCC,
      CLK => reg_i_zero_out_CLKINV_49,
      SET => GND,
      RST => GND,
      SSET => reg_i_zero_out_REVUSED_46,
      SRST => reg_i_zero_out_SRINV_48,
      O => reg_i_zero_out_6
    );
  reg_i_zero_out_mux0000314 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X19Y10"
    )
    port map (
      ADR0 => reg_i_zero_out_mux0000_map73_0,
      ADR1 => N1291_0,
      ADR2 => reg_i_zero_out_mux0000_map25_0,
      ADR3 => alu_i_zero_out_cmp_eq0002_0,
      O => reg_i_zero_out_mux0000314_O_pack_1
    );
  alu_i_result_1_56 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X10Y9"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => alu_i_N3_0,
      ADR2 => alu_i_result_1_44_O,
      ADR3 => alu_i_result_1_map12_0,
      O => alu_i_result_1_map19
    );
  alu_i_result_2_36 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X8Y9"
    )
    port map (
      ADR0 => alu_i_add_result_int_add0000(2),
      ADR1 => alu_i_zero_out_cmp_eq0006_0,
      ADR2 => alu_i_zero_out_cmp_eq0012,
      ADR3 => reg_i_b_out(2),
      O => alu_i_result_2_map12
    );
  alu_i_result_2_56 : X_LUT4
    generic map(
      INIT => X"FFEC",
      LOC => "SLICE_X8Y8"
    )
    port map (
      ADR0 => reg_i_a_out(1),
      ADR1 => alu_i_result_2_map12_0,
      ADR2 => alu_i_N3_0,
      ADR3 => alu_i_result_2_44_O,
      O => alu_i_result_2_map19
    );
  alu_i_result_4_53 : X_LUT4
    generic map(
      INIT => X"C8C8",
      LOC => "SLICE_X12Y9"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0006_0,
      ADR1 => reg_i_a_out(4),
      ADR2 => alu_i_zero_out_or0002,
      ADR3 => VCC,
      O => alu_i_result_4_map18
    );
  alu_i_result_5_18 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X16Y1"
    )
    port map (
      ADR0 => reg_i_a_out(4),
      ADR1 => alu_i_N3_0,
      ADR2 => alu_i_result_5_8_O,
      ADR3 => alu_i_result_5_map3,
      O => alu_i_result_5_map7
    );
  alu_i_result_6_70_SW0 : X_LUT4
    generic map(
      INIT => X"0A00",
      LOC => "SLICE_X19Y3"
    )
    port map (
      ADR0 => alu_i_xor0001,
      ADR1 => VCC,
      ADR2 => reg_i_N0_0,
      ADR3 => control_int_3_0,
      O => N1283
    );
  alu_i_result_5_37 : X_LUT4
    generic map(
      INIT => X"FFC8",
      LOC => "SLICE_X14Y3"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0006_0,
      ADR1 => reg_i_b_out(5),
      ADR2 => alu_i_result_5_36_SW0_O,
      ADR3 => alu_i_result_5_map10,
      O => alu_i_result_5_map15
    );
  alu_i_result_6_18 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X16Y5"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => alu_i_result_6_8_O,
      ADR2 => alu_i_result_6_map3,
      ADR3 => alu_i_N3_0,
      O => alu_i_result_6_map7
    );
  reg_i_carry_out_mux000075 : X_LUT4
    generic map(
      INIT => X"1100",
      LOC => "SLICE_X10Y12"
    )
    port map (
      ADR0 => control_int_4_0,
      ADR1 => control_int_3_0,
      ADR2 => VCC,
      ADR3 => control_int(2),
      O => reg_i_carry_out_mux0000_map24
    );
  ram_control_i_ce_nwr1 : X_LUT4
    generic map(
      INIT => X"BFFF",
      LOC => "SLICE_X20Y4"
    )
    port map (
      ADR0 => clk_IBUF1,
      ADR1 => control_int_1_0,
      ADR2 => N1,
      ADR3 => control_int(2),
      O => datmem_nwr_OBUF_141
    );
  alu_i_zero_out_cmp_eq00021 : X_LUT4
    generic map(
      INIT => X"5000",
      LOC => "SLICE_X9Y8"
    )
    port map (
      ADR0 => control_i_pr_state_or0002231_0,
      ADR1 => VCC,
      ADR2 => control_int_1_0,
      ADR3 => alu_i_N71,
      O => alu_i_zero_out_cmp_eq0002
    );
  alu_i_zero_out_or0000_SW1 : X_LUT4
    generic map(
      INIT => X"AFFF",
      LOC => "SLICE_X7Y11"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => VCC,
      ADR2 => reg_i_zero_out_mux0000_map81_0,
      ADR3 => reg_i_zero_out_mux0000_map88_0,
      O => N1257
    );
  reg_i_b_out_6 : X_SFF
    generic map(
      LOC => "SLICE_X17Y7",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_6_DXMUX_58,
      CE => VCC,
      CLK => reg_i_b_out_6_CLKINV_60,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_6_SRINV_59,
      O => reg_i_b_out(6)
    );
  reg_i_zero_out_mux0000547 : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X19Y8"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_zero_out_cmp_eq00141_SW0_O,
      ADR2 => reg_i_N0_0,
      ADR3 => alu_i_xor0007_0,
      O => reg_i_zero_out_mux0000_map155
    );
  reg_i_b_out_mux0000_7_Q : X_LUT4
    generic map(
      INIT => X"F0E4",
      LOC => "SLICE_X19Y2"
    )
    port map (
      ADR0 => N1287_0,
      ADR1 => N1173_0,
      ADR2 => reg_i_b_out_mux0000_7_SW1_O,
      ADR3 => alu_i_result_7_map18,
      O => reg_i_b_out_mux0000(7)
    );
  reg_i_b_out_7 : X_SFF
    generic map(
      LOC => "SLICE_X19Y2",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_7_DXMUX_61,
      CE => VCC,
      CLK => reg_i_b_out_7_CLKINV_63,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_7_SRINV_62,
      O => reg_i_b_out(7)
    );
  reg_i_zero_out_mux0000488 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X16Y7"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => reg_i_zero_out_mux0000478_O,
      ADR2 => reg_i_a_out(4),
      ADR3 => reg_i_a_out(5),
      O => reg_i_zero_out_mux0000_map146
    );
  reg_i_a_out_mux0000_4_SW0 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X13Y8"
    )
    port map (
      ADR0 => reg_i_a_out(4),
      ADR1 => reg_i_rom_data_intern(4),
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_a_out_or0001_0,
      O => N84
    );
  alu_i_result_6_37 : X_LUT4
    generic map(
      INIT => X"FEF0",
      LOC => "SLICE_X16Y3"
    )
    port map (
      ADR0 => alu_i_zero_out_cmp_eq0006_0,
      ADR1 => alu_i_result_6_36_SW0_O,
      ADR2 => alu_i_result_6_map10,
      ADR3 => reg_i_b_out(6),
      O => alu_i_result_6_map15
    );
  alu_i_result_7_18 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X18Y3"
    )
    port map (
      ADR0 => reg_i_a_out(6),
      ADR1 => alu_i_result_7_map3,
      ADR2 => alu_i_result_7_8_O,
      ADR3 => alu_i_N3_0,
      O => alu_i_result_7_map7
    );
  alu_i_result_7_37 : X_LUT4
    generic map(
      INIT => X"FAF8",
      LOC => "SLICE_X17Y3"
    )
    port map (
      ADR0 => reg_i_b_out(7),
      ADR1 => alu_i_zero_out_cmp_eq0006_0,
      ADR2 => alu_i_result_7_map10,
      ADR3 => alu_i_result_7_36_SW0_O,
      O => alu_i_result_7_map15
    );
  alu_i_Mxor_xor0003_Result1 : X_LUT4
    generic map(
      INIT => X"1E78",
      LOC => "SLICE_X18Y7"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => alu_i_temp_carry_4_or0001_4,
      ADR2 => alu_i_N8,
      ADR3 => reg_i_b_out(3),
      O => alu_i_xor0003
    );
  alu_i_result_3_8 : X_LUT4
    generic map(
      INIT => X"FF20",
      LOC => "SLICE_X15Y7"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => reg_i_N0_0,
      ADR2 => alu_i_xor0004_0,
      ADR3 => alu_i_result_3_8_SW0_O,
      O => alu_i_result_3_map4
    );
  control_i_pr_state_FFd10 : X_SFF
    generic map(
      LOC => "SLICE_X5Y17",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd10_DYMUX_64,
      CE => VCC,
      CLK => control_i_pr_state_FFd10_CLKINV_67,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd10_SRINV_66,
      O => control_i_pr_state_FFd10_16
    );
  control_i_pr_state_or000847 : X_LUT4
    generic map(
      INIT => X"FF80",
      LOC => "SLICE_X5Y17"
    )
    port map (
      ADR0 => control_i_N11,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => control_i_N6,
      ADR3 => control_i_pr_state_cmp_eq0055,
      O => control_i_pr_state_or0008_map12
    );
  control_i_pr_state_FFd12 : X_SFF
    generic map(
      LOC => "SLICE_X4Y17",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd12_DYMUX_68,
      CE => VCC,
      CLK => control_i_pr_state_FFd12_CLKINV_71,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd12_SRINV_70,
      O => control_i_pr_state_FFd12_26
    );
  control_i_pr_state_or000827_SW1 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y17"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0047_0,
      ADR1 => control_i_pr_state_cmp_eq0056,
      ADR2 => control_i_pr_state_cmp_eq0064_0,
      ADR3 => control_i_pr_state_cmp_eq0057_0,
      O => N1289
    );
  control_i_pr_state_or000323 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X4Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or0003_map5_0,
      ADR2 => control_i_pr_state_or0003_map2_0,
      ADR3 => control_i_pr_state_or0003_map8,
      O => control_int(1)
    );
  control_i_pr_state_or000515 : X_LUT4
    generic map(
      INIT => X"FF1B",
      LOC => "SLICE_X2Y18"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0016,
      ADR1 => N1278_0,
      ADR2 => N1279_0,
      ADR3 => control_i_pr_state_or00059_O,
      O => control_i_pr_state_or0005_map7
    );
  control_i_pr_state_or000427 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y14"
    )
    port map (
      ADR0 => N1249,
      ADR1 => control_i_pr_state_or0004_map9_0,
      ADR2 => control_i_pr_state_FFd9_25,
      ADR3 => control_i_pr_state_or0004_map6,
      O => control_int(0)
    );
  reg_i_zero_out_mux0000500_SW0 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X16Y12"
    )
    port map (
      ADR0 => control_int_4_0,
      ADR1 => reg_i_zero_out_mux0000500_SW0_SW1_O,
      ADR2 => alu_i_N22,
      ADR3 => control_int_3_0,
      O => N1251
    );
  control_i_pr_state_or000618 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X4Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_cmp_eq0054_0,
      ADR2 => control_i_pr_state_or0006_map2_0,
      ADR3 => control_i_pr_state_or000615_O,
      O => control_nxt_int(3)
    );
  control_i_pr_state_or000726 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X2Y17"
    )
    port map (
      ADR0 => control_i_pr_state_or0007_map7_0,
      ADR1 => control_i_pr_state_or0007_map2_0,
      ADR2 => N1253_0,
      ADR3 => control_i_pr_state_or000726_SW0_O,
      O => control_nxt_int(2)
    );
  control_i_pr_state_or000853 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y19"
    )
    port map (
      ADR0 => N1289_0,
      ADR1 => control_i_pr_state_or0008_map12_0,
      ADR2 => control_i_pr_state_or000827_SW0_O,
      ADR3 => control_i_pr_state_or0008_map11_0,
      O => control_nxt_int(1)
    );
  control_i_pr_state_or000846 : X_LUT4
    generic map(
      INIT => X"E200",
      LOC => "SLICE_X3Y17"
    )
    port map (
      ADR0 => control_i_N7_0,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => control_i_N9,
      ADR3 => control_i_N11,
      O => control_i_pr_state_or0008_map11
    );
  control_i_pr_state_or000928 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y16"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0043_0,
      ADR1 => control_i_pr_state_cmp_eq0066_0,
      ADR2 => N1322_0,
      ADR3 => control_i_pr_state_or000923_O,
      O => control_nxt_int(0)
    );
  alu_i_result_4_44_SW0 : X_LUT4
    generic map(
      INIT => X"FF7F",
      LOC => "SLICE_X8Y10"
    )
    port map (
      ADR0 => reg_i_a_out(4),
      ADR1 => reg_i_b_out(4),
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_i_pr_state_or0002231_0,
      O => N1351
    );
  reg_i_zero_out_mux0000277 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X7Y10"
    )
    port map (
      ADR0 => prog_data_4_IBUF_39,
      ADR1 => prog_data_6_IBUF_29,
      ADR2 => prog_data_7_IBUF_28,
      ADR3 => prog_data_5_IBUF_27,
      O => reg_i_zero_out_mux0000_map88
    );
  alu_i_zero_out_cmp_eq00101 : X_LUT4
    generic map(
      INIT => X"C000",
      LOC => "SLICE_X9Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_1_0,
      ADR2 => control_i_pr_state_or0002231_0,
      ADR3 => alu_i_N71,
      O => alu_i_zero_out_cmp_eq0010
    );
  alu_i_temp_carry_6_or0001 : X_LUT4
    generic map(
      INIT => X"CCF0",
      LOC => "SLICE_X20Y2"
    )
    port map (
      ADR0 => VCC,
      ADR1 => N1181_0,
      ADR2 => N1180_0,
      ADR3 => alu_i_temp_carry_4_or0001_4,
      O => alu_i_temp_carry_6_or0001_54
    );
  reg_i_zero_out_mux0000111 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X17Y4"
    )
    port map (
      ADR0 => alu_i_N11_0,
      ADR1 => alu_i_N10_0,
      ADR2 => alu_i_N9,
      ADR3 => alu_i_N8,
      O => reg_i_zero_out_mux0000_map39
    );
  reg_i_zero_out_mux000077 : X_LUT4
    generic map(
      INIT => X"EAAA",
      LOC => "SLICE_X19Y7"
    )
    port map (
      ADR0 => reg_i_zero_out_mux000077_SW0_O,
      ADR1 => alu_i_zero_out_or0001_0,
      ADR2 => reg_i_zero_out_mux0000_map22_0,
      ADR3 => reg_i_zero_out_mux0000_map15_0,
      O => reg_i_zero_out_mux0000_map25
    );
  reg_i_zero_out_mux0000408 : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X16Y13"
    )
    port map (
      ADR0 => reg_i_zero_out_mux0000403_O,
      ADR1 => reg_i_b_out(0),
      ADR2 => reg_i_b_out(1),
      ADR3 => reg_i_b_out(7),
      O => reg_i_zero_out_mux0000_map123
    );
  reg_i_zero_out_mux000098 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X14Y11"
    )
    port map (
      ADR0 => alu_i_N7,
      ADR1 => alu_i_N4_0,
      ADR2 => alu_i_N5,
      ADR3 => alu_i_N6_0,
      O => reg_i_zero_out_mux0000_map32
    );
  reg_i_b_out_mux0000_5_Q : X_LUT4
    generic map(
      INIT => X"FE02",
      LOC => "SLICE_X16Y0"
    )
    port map (
      ADR0 => N623_0,
      ADR1 => N1285_0,
      ADR2 => alu_i_result_5_map18,
      ADR3 => reg_i_b_out_mux0000_5_SW1_O,
      O => reg_i_b_out_mux0000(5)
    );
  reg_i_b_out_5 : X_SFF
    generic map(
      LOC => "SLICE_X16Y0",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_5_DXMUX_55,
      CE => VCC,
      CLK => reg_i_b_out_5_CLKINV_57,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_5_SRINV_56,
      O => reg_i_b_out(5)
    );
  reg_i_b_out_mux0000_6_Q : X_LUT4
    generic map(
      INIT => X"AAAC",
      LOC => "SLICE_X17Y7"
    )
    port map (
      ADR0 => reg_i_b_out_mux0000_6_SW1_O,
      ADR1 => N620_0,
      ADR2 => N1283_0,
      ADR3 => alu_i_result_6_map18,
      O => reg_i_b_out_mux0000(6)
    );
  pc_i_pc_int_5 : X_SFF
    generic map(
      LOC => "SLICE_X8Y19",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_5_DXMUX_101,
      CE => VCC,
      CLK => pc_i_pc_int_5_CLKINV_104,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_5_SRINV_103,
      O => pc_i_pc_int(5)
    );
  pc_i_pc_int_6 : X_SFF
    generic map(
      LOC => "SLICE_X6Y18",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_7_DYMUX_106,
      CE => VCC,
      CLK => pc_i_pc_int_7_CLKINV_108,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_7_SRINV_107,
      O => pc_i_pc_int(6)
    );
  pc_i_pc_int_mux0002_7_1 : X_LUT4
    generic map(
      INIT => X"CFC0",
      LOC => "SLICE_X6Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => pc_i_pc_int_or0000_38,
      ADR3 => pc_i_pc_int_addsub0000(7),
      O => pc_i_pc_int_mux0002(7)
    );
  pc_i_pc_int_7 : X_SFF
    generic map(
      LOC => "SLICE_X6Y18",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_7_DXMUX_105,
      CE => VCC,
      CLK => pc_i_pc_int_7_CLKINV_108,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_7_SRINV_107,
      O => pc_i_pc_int(7)
    );
  alu_i_Madd_add_result_int_add0000_lut_2_Q : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X15Y11"
    )
    port map (
      ADR0 => reg_i_b_out(2),
      ADR1 => reg_i_a_out(2),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_N6
    );
  reg_i_a_out_mux0000_7_SW0 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X17Y2"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(7),
      ADR1 => reg_i_a_out_or0001_0,
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_a_out(7),
      O => N712
    );
  control_i_pr_state_FFd15 : X_SFF
    generic map(
      LOC => "SLICE_X5Y15",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd15_DXMUX_121,
      CE => VCC,
      CLK => control_i_pr_state_FFd15_CLKINV_125,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd15_SRINV_124,
      O => control_i_pr_state_FFd15_19
    );
  control_i_pr_state_FFd25 : X_SFF
    generic map(
      LOC => "SLICE_X3Y14",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd26_DYMUX_128,
      CE => VCC,
      CLK => control_i_pr_state_FFd26_CLKINV_130,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd26_SRINV_129,
      O => control_i_pr_state_FFd25_15
    );
  control_i_pr_state_FFd26_In72 : X_LUT4
    generic map(
      INIT => X"5450",
      LOC => "SLICE_X3Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd26_2,
      ADR1 => control_i_pr_state_FFd26_In_map14,
      ADR2 => control_i_pr_state_FFd26_In_map5,
      ADR3 => control_i_pr_state_FFd26_In_map17_0,
      O => control_i_pr_state_FFd26_In
    );
  control_i_pr_state_FFd26 : X_SFF
    generic map(
      LOC => "SLICE_X3Y14",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd26_DXMUX_126,
      CE => VCC,
      CLK => control_i_pr_state_FFd26_CLKINV_130,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd26_SRINV_129,
      O => control_i_pr_state_FFd26_2
    );
  control_i_pr_state_FFd18 : X_SFF
    generic map(
      LOC => "SLICE_X5Y16",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd17_DYMUX_132,
      CE => VCC,
      CLK => control_i_pr_state_FFd17_CLKINV_135,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd17_SRINV_134,
      O => control_i_pr_state_FFd18_11
    );
  control_i_pr_state_or000723_SW0 : X_LUT4
    generic map(
      INIT => X"FFFA",
      LOC => "SLICE_X5Y16"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0057_0,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_cmp_eq0046,
      ADR3 => control_i_pr_state_cmp_eq0047_0,
      O => N1253
    );
  control_i_pr_state_FFd14 : X_SFF
    generic map(
      LOC => "SLICE_X6Y17",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd14_DYMUX_72,
      CE => VCC,
      CLK => control_i_pr_state_FFd14_CLKINV_75,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd14_SRINV_74,
      O => control_i_pr_state_FFd14_22
    );
  control_i_pr_state_or000917 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X6Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_cmp_eq0047_0,
      ADR2 => control_i_pr_state_cmp_eq0044,
      ADR3 => control_i_pr_state_FFd10_16,
      O => control_i_pr_state_or0009_map8
    );
  control_i_pr_state_FFd3 : X_SFF
    generic map(
      LOC => "SLICE_X6Y16",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd4_DYMUX_77,
      CE => VCC,
      CLK => control_i_pr_state_FFd4_CLKINV_80,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd4_SRINV_79,
      O => control_i_pr_state_FFd3_21
    );
  control_i_pr_state_FFd4_In1 : X_LUT4
    generic map(
      INIT => X"8800",
      LOC => "SLICE_X6Y16"
    )
    port map (
      ADR0 => control_i_N7_0,
      ADR1 => control_i_N11,
      ADR2 => VCC,
      ADR3 => prog_data_0_IBUF_0,
      O => control_i_pr_state_cmp_eq0061
    );
  control_i_pr_state_FFd4 : X_SFF
    generic map(
      LOC => "SLICE_X6Y16",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd4_DXMUX_76,
      CE => VCC,
      CLK => control_i_pr_state_FFd4_CLKINV_80,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd4_SRINV_79,
      O => control_i_pr_state_FFd4_32
    );
  control_i_pr_state_FFd5 : X_SFF
    generic map(
      LOC => "SLICE_X7Y18",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd5_DYMUX_81,
      CE => VCC,
      CLK => control_i_pr_state_FFd5_CLKINV_83,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd5_SRINV_82,
      O => control_i_pr_state_FFd5_35
    );
  control_i_pr_state_or000610 : X_LUT4
    generic map(
      INIT => X"0104",
      LOC => "SLICE_X7Y18"
    )
    port map (
      ADR0 => prog_data_2_IBUF_34,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => prog_data_1_IBUF_8,
      O => control_i_pr_state_or0006_map5
    );
  control_i_pr_state_FFd7 : X_SFF
    generic map(
      LOC => "SLICE_X5Y11",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd8_DYMUX_86,
      CE => VCC,
      CLK => control_i_pr_state_FFd8_CLKINV_89,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd8_SRINV_88,
      O => control_i_pr_state_FFd7_37
    );
  control_i_pr_state_FFd8_In1 : X_LUT4
    generic map(
      INIT => X"4400",
      LOC => "SLICE_X5Y11"
    )
    port map (
      ADR0 => control_i_pr_state_FFd26_1_31,
      ADR1 => control_i_pr_state_cmp_eq0007,
      ADR2 => VCC,
      ADR3 => control_i_pr_state_cmp_eq0009,
      O => control_i_pr_state_cmp_eq0053
    );
  control_i_pr_state_FFd8 : X_SFF
    generic map(
      LOC => "SLICE_X5Y11",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd8_DXMUX_84,
      CE => VCC,
      CLK => control_i_pr_state_FFd8_CLKINV_89,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd8_SRINV_88,
      O => control_i_pr_state_FFd8_36
    );
  control_i_pr_state_FFd9 : X_SFF
    generic map(
      LOC => "SLICE_X2Y12",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd9_DYMUX_90,
      CE => VCC,
      CLK => control_i_pr_state_FFd9_CLKINV_93,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd9_SRINV_92,
      O => control_i_pr_state_FFd9_25
    );
  control_i_pr_state_FFd26_In44 : X_LUT4
    generic map(
      INIT => X"2200",
      LOC => "SLICE_X2Y12"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => prog_data_7_IBUF_28,
      ADR2 => VCC,
      ADR3 => prog_data_5_IBUF_27,
      O => control_i_pr_state_FFd26_In_map17
    );
  reg_i_a_out_mux0000_0_SW0 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X12Y8"
    )
    port map (
      ADR0 => reg_i_a_out_or0001_0,
      ADR1 => reg_i_a_out_cmp_eq0009_30,
      ADR2 => reg_i_a_out(0),
      ADR3 => reg_i_rom_data_intern(0),
      O => N92
    );
  control_i_pr_state_FFd1_In1 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X7Y16"
    )
    port map (
      ADR0 => prog_data_6_IBUF_29,
      ADR1 => N1302,
      ADR2 => control_i_pr_state_FFd26_2,
      ADR3 => prog_data_7_IBUF_28,
      O => control_i_pr_state_cmp_eq0067
    );
  control_i_pr_state_FFd1 : X_SFF
    generic map(
      LOC => "SLICE_X7Y16",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd1_DXMUX_109,
      CE => VCC,
      CLK => control_i_pr_state_FFd1_CLKINV_112,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd1_SRINV_111,
      O => control_i_pr_state_FFd1_40
    );
  control_i_pr_state_or00096_SW0 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X3Y18"
    )
    port map (
      ADR0 => prog_data_7_IBUF_28,
      ADR1 => control_i_pr_state_FFd26_2,
      ADR2 => N1304,
      ADR3 => prog_data_6_IBUF_29,
      O => N1275
    );
  pc_i_pc_int_1 : X_SFF
    generic map(
      LOC => "SLICE_X4Y16",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_1_DYMUX_94,
      CE => VCC,
      CLK => pc_i_pc_int_1_CLKINV_96,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_1_SRINV_95,
      O => pc_i_pc_int(1)
    );
  control_i_pr_state_cmp_eq000311 : X_LUT4
    generic map(
      INIT => X"2200",
      LOC => "SLICE_X4Y16"
    )
    port map (
      ADR0 => prog_data_1_IBUF_8,
      ADR1 => prog_data_3_IBUF_33,
      ADR2 => VCC,
      ADR3 => prog_data_2_IBUF_34,
      O => control_i_N7
    );
  pc_i_pc_int_2 : X_SFF
    generic map(
      LOC => "SLICE_X8Y18",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_3_DYMUX_98,
      CE => VCC,
      CLK => pc_i_pc_int_3_CLKINV_100,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_3_SRINV_99,
      O => pc_i_pc_int(2)
    );
  pc_i_pc_int_mux0002_3_1 : X_LUT4
    generic map(
      INIT => X"FC30",
      LOC => "SLICE_X8Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => pc_i_pc_int_or0000_38,
      ADR2 => pc_i_pc_int_addsub0000(3),
      ADR3 => prog_data_3_IBUF_33,
      O => pc_i_pc_int_mux0002(3)
    );
  pc_i_pc_int_3 : X_SFF
    generic map(
      LOC => "SLICE_X8Y18",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_3_DXMUX_97,
      CE => VCC,
      CLK => pc_i_pc_int_3_CLKINV_100,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_3_SRINV_99,
      O => pc_i_pc_int(3)
    );
  pc_i_pc_int_4 : X_SFF
    generic map(
      LOC => "SLICE_X8Y19",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_5_DYMUX_102,
      CE => VCC,
      CLK => pc_i_pc_int_5_CLKINV_104,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_5_SRINV_103,
      O => pc_i_pc_int(4)
    );
  pc_i_pc_int_mux0002_5_1 : X_LUT4
    generic map(
      INIT => X"E4E4",
      LOC => "SLICE_X8Y19"
    )
    port map (
      ADR0 => pc_i_pc_int_or0000_38,
      ADR1 => pc_i_pc_int_addsub0000(5),
      ADR2 => prog_data_5_IBUF_27,
      ADR3 => VCC,
      O => pc_i_pc_int_mux0002(5)
    );
  control_i_pr_state_FFd21 : X_SFF
    generic map(
      LOC => "SLICE_X7Y17",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd22_DYMUX_114,
      CE => VCC,
      CLK => control_i_pr_state_FFd22_CLKINV_116,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd22_SRINV_115,
      O => control_i_pr_state_FFd21_17
    );
  control_i_pr_state_FFd22 : X_SFF
    generic map(
      LOC => "SLICE_X7Y17",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd22_DXMUX_113,
      CE => VCC,
      CLK => control_i_pr_state_FFd22_CLKINV_116,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd22_SRINV_115,
      O => control_i_pr_state_FFd22_13
    );
  control_i_pr_state_FFd23 : X_SFF
    generic map(
      LOC => "SLICE_X6Y12",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd24_DYMUX_118,
      CE => VCC,
      CLK => control_i_pr_state_FFd24_CLKINV_120,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd24_SRINV_119,
      O => control_i_pr_state_FFd23_18
    );
  control_i_pr_state_FFd24 : X_SFF
    generic map(
      LOC => "SLICE_X6Y12",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd24_DXMUX_117,
      CE => VCC,
      CLK => control_i_pr_state_FFd24_CLKINV_120,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd24_SRINV_119,
      O => control_i_pr_state_FFd24_14
    );
  control_i_pr_state_FFd16 : X_SFF
    generic map(
      LOC => "SLICE_X5Y15",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd15_DYMUX_122,
      CE => VCC,
      CLK => control_i_pr_state_FFd15_CLKINV_125,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd15_SRINV_124,
      O => control_i_pr_state_FFd16_10
    );
  control_i_pr_state_or00052 : X_LUT4
    generic map(
      INIT => X"FFEE",
      LOC => "SLICE_X5Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd18_11,
      ADR1 => control_i_pr_state_FFd16_10,
      ADR2 => VCC,
      ADR3 => control_i_pr_state_cmp_eq0045,
      O => control_i_pr_state_or0005_map1
    );
  control_i_pr_state_FFd10_In11_SW0 : X_LUT4
    generic map(
      INIT => X"5FFF",
      LOC => "SLICE_X4Y10"
    )
    port map (
      ADR0 => prog_data_5_IBUF_27,
      ADR1 => VCC,
      ADR2 => prog_data_6_IBUF_29,
      ADR3 => control_i_pr_state_cmp_eq0012,
      O => N1263
    );
  control_i_pr_state_FFd13_In1 : X_LUT4
    generic map(
      INIT => X"0080",
      LOC => "SLICE_X6Y14"
    )
    port map (
      ADR0 => control_i_N5,
      ADR1 => control_i_pr_state_cmp_eq0013,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_pr_state_FFd26_1_31,
      O => control_i_pr_state_cmp_eq0057
    );
  control_i_pr_state_FFd13 : X_SFF
    generic map(
      LOC => "SLICE_X6Y14",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd13_DXMUX_143,
      CE => VCC,
      CLK => control_i_pr_state_FFd13_CLKINV_146,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd13_SRINV_145,
      O => control_i_pr_state_FFd13_23
    );
  reg_i_zero_out_mux0000264 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X6Y11"
    )
    port map (
      ADR0 => prog_data_1_IBUF_8,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => prog_data_2_IBUF_34,
      O => reg_i_zero_out_mux0000_map81
    );
  control_i_pr_state_FFd7_In_SW0 : X_LUT4
    generic map(
      INIT => X"FCFF",
      LOC => "SLICE_X3Y11"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_1_IBUF_8,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_pr_state_cmp_eq0007,
      O => N166
    );
  control_i_pr_state_FFd17 : X_SFF
    generic map(
      LOC => "SLICE_X5Y16",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd17_DXMUX_131,
      CE => VCC,
      CLK => control_i_pr_state_FFd17_CLKINV_135,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd17_SRINV_134,
      O => control_i_pr_state_FFd17_41
    );
  control_i_pr_state_FFd19 : X_SFF
    generic map(
      LOC => "SLICE_X4Y15",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd20_DYMUX_138,
      CE => VCC,
      CLK => control_i_pr_state_FFd20_CLKINV_140,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd20_SRINV_139,
      O => control_i_pr_state_FFd19_12
    );
  control_i_pr_state_FFd20_In1 : X_LUT4
    generic map(
      INIT => X"0020",
      LOC => "SLICE_X4Y15"
    )
    port map (
      ADR0 => control_i_N5,
      ADR1 => prog_data_0_IBUF_0,
      ADR2 => control_i_pr_state_cmp_eq0016,
      ADR3 => control_i_pr_state_FFd26_1_31,
      O => control_i_pr_state_cmp_eq0047
    );
  control_i_pr_state_FFd20 : X_SFF
    generic map(
      LOC => "SLICE_X4Y15",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd20_DXMUX_136,
      CE => VCC,
      CLK => control_i_pr_state_FFd20_CLKINV_140,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd20_SRINV_139,
      O => control_i_pr_state_FFd20_24
    );
  control_i_pr_state_or000912 : X_LUT4
    generic map(
      INIT => X"3230",
      LOC => "SLICE_X3Y16"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0016,
      ADR1 => control_i_pr_state_FFd26_2,
      ADR2 => N1259,
      ADR3 => control_i_pr_state_cmp_eq0015_0,
      O => control_i_pr_state_or0009_map5
    );
  reg_i_zero_out_mux00000 : X_LUT4
    generic map(
      INIT => X"AA00",
      LOC => "SLICE_X18Y11"
    )
    port map (
      ADR0 => reg_i_zero_out_6,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_zero_out_or0000,
      O => reg_i_zero_out_mux0000_map0
    );
  control_i_pr_state_FFd10_In11_SW2 : X_LUT4
    generic map(
      INIT => X"5FFF",
      LOC => "SLICE_X4Y11"
    )
    port map (
      ADR0 => prog_data_5_IBUF_27,
      ADR1 => VCC,
      ADR2 => prog_data_6_IBUF_29,
      ADR3 => control_i_pr_state_cmp_eq0009,
      O => N1267
    );
  control_i_pr_state_or000515_SW0 : X_LUT4
    generic map(
      INIT => X"F5FF",
      LOC => "SLICE_X2Y19"
    )
    port map (
      ADR0 => control_i_pr_state_cmp_eq0015_0,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_FFd26_2,
      ADR3 => control_i_pr_state_cmp_eq0013,
      O => N1278
    );
  alu_i_temp_carry_6_or0001_SW1 : X_LUT4
    generic map(
      INIT => X"FAE8",
      LOC => "SLICE_X21Y4"
    )
    port map (
      ADR0 => reg_i_b_out(4),
      ADR1 => reg_i_a_out(3),
      ADR2 => reg_i_a_out(4),
      ADR3 => reg_i_b_out(3),
      O => N1181
    );
  control_i_pr_state_FFd26_1 : X_SFF
    generic map(
      LOC => "SLICE_X5Y13",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd26_1_DYMUX_147,
      CE => VCC,
      CLK => control_i_pr_state_FFd26_1_CLKINV_149,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd26_1_SRINV_148,
      O => control_i_pr_state_FFd26_1_31
    );
  alu_i_Madd_add_result_int_add0000_lut_7_Q : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X17Y11"
    )
    port map (
      ADR0 => reg_i_b_out(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_a_out(7),
      O => alu_i_N11
    );
  alu_i_temp_carry_4_or0001_SW0_SW1 : X_LUT4
    generic map(
      INIT => X"FEA8",
      LOC => "SLICE_X15Y4"
    )
    port map (
      ADR0 => reg_i_a_out(2),
      ADR1 => reg_i_a_out(1),
      ADR2 => reg_i_b_out(1),
      ADR3 => reg_i_b_out(2),
      O => N1300
    );
  control_i_pr_state_or000417 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd20_24,
      ADR1 => control_i_pr_state_FFd7_37,
      ADR2 => control_i_pr_state_FFd3_21,
      ADR3 => control_i_pr_state_FFd5_35,
      O => control_i_pr_state_or0004_map9
    );
  reg_i_b_out_mux0000_7_SW0 : X_LUT4
    generic map(
      INIT => X"5C0C",
      LOC => "SLICE_X16Y2"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => reg_i_b_out(7),
      ADR2 => reg_i_b_out_and0000,
      ADR3 => reg_i_rom_data_intern(7),
      O => N1173
    );
  alu_i_Madd_add_result_int_add0000_lut_0_Q : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X16Y8"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => reg_i_b_out(0),
      O => alu_i_N4
    );
  control_i_pr_state_or00034 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X5Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd7_37,
      ADR1 => control_i_pr_state_FFd6_45,
      ADR2 => control_i_pr_state_FFd12_26,
      ADR3 => control_i_pr_state_FFd10_16,
      O => control_i_pr_state_or0003_map2
    );
  alu_i_Madd_add_result_int_add0000_lut_6_1 : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X16Y11"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_a_out(6),
      ADR2 => reg_i_b_out(6),
      ADR3 => VCC,
      O => N1239
    );
  control_i_pr_state_or00064 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y14"
    )
    port map (
      ADR0 => control_i_pr_state_FFd9_25,
      ADR1 => control_i_pr_state_FFd10_16,
      ADR2 => control_i_pr_state_FFd12_26,
      ADR3 => control_i_pr_state_FFd20_24,
      O => control_i_pr_state_or0006_map2
    );
  pc_i_Madd_pc_int_addsub0000_lut_0_Q : X_LUT4
    generic map(
      INIT => X"9999",
      LOC => "SLICE_X9Y16"
    )
    port map (
      ADR0 => pc_i_pc_int(0),
      ADR1 => pc_i_pc_int_cmp_eq0003_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => pc_i_N4
    );
  reg_i_a_out_0 : X_SFF
    generic map(
      LOC => "SLICE_X13Y5",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_0_DYMUX_229,
      CE => VCC,
      CLK => reg_i_a_out_0_CLKINV_231,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_0_REVUSED_228,
      SRST => reg_i_a_out_0_SRINV_230,
      O => reg_i_a_out(0)
    );
  alu_i_result_0_64 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X13Y5"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => alu_i_N1_0,
      ADR2 => alu_i_result_0_map8_0,
      ADR3 => alu_i_result_0_map17_0,
      O => result_alu_reg_0_pack_1
    );
  alu_i_result_3_53 : X_LUT4
    generic map(
      INIT => X"AA88",
      LOC => "SLICE_X11Y7"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => alu_i_zero_out_cmp_eq0006_0,
      ADR2 => VCC,
      ADR3 => alu_i_zero_out_or0002,
      O => alu_i_result_3_map18
    );
  reg_i_a_out_1 : X_SFF
    generic map(
      LOC => "SLICE_X10Y10",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_1_DYMUX_233,
      CE => VCC,
      CLK => reg_i_a_out_1_CLKINV_235,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_1_REVUSED_232,
      SRST => reg_i_a_out_1_SRINV_234,
      O => reg_i_a_out(1)
    );
  alu_i_result_1_65 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X10Y10"
    )
    port map (
      ADR0 => alu_i_N1_0,
      ADR1 => reg_i_a_out(1),
      ADR2 => alu_i_result_1_map7_0,
      ADR3 => alu_i_result_1_map19_0,
      O => result_alu_reg_1_pack_1
    );
  reg_i_zero_out_mux0000198 : X_LUT4
    generic map(
      INIT => X"0777",
      LOC => "SLICE_X15Y6"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => reg_i_b_out(3),
      ADR2 => reg_i_b_out(4),
      ADR3 => reg_i_a_out(4),
      O => reg_i_zero_out_mux0000_map64
    );
  reg_i_a_out_2 : X_SFF
    generic map(
      LOC => "SLICE_X11Y9",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_2_DYMUX_237,
      CE => VCC,
      CLK => reg_i_a_out_2_CLKINV_239,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_2_REVUSED_236,
      SRST => reg_i_a_out_2_SRINV_238,
      O => reg_i_a_out(2)
    );
  alu_i_result_2_65 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X11Y9"
    )
    port map (
      ADR0 => reg_i_a_out(2),
      ADR1 => alu_i_N1_0,
      ADR2 => alu_i_result_2_map19_0,
      ADR3 => alu_i_result_2_map7_0,
      O => result_alu_reg_2_pack_1
    );
  reg_i_zero_out_mux000010 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X19Y6"
    )
    port map (
      ADR0 => reg_i_a_out(6),
      ADR1 => reg_i_a_out(7),
      ADR2 => reg_i_a_out(4),
      ADR3 => reg_i_a_out(5),
      O => reg_i_zero_out_mux0000_map6
    );
  reg_i_a_out_3 : X_SFF
    generic map(
      LOC => "SLICE_X12Y6",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_3_DYMUX_241,
      CE => VCC,
      CLK => reg_i_a_out_3_CLKINV_243,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_3_REVUSED_240,
      SRST => reg_i_a_out_3_SRINV_242,
      O => reg_i_a_out(3)
    );
  alu_i_result_3_64 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X12Y6"
    )
    port map (
      ADR0 => alu_i_result_3_map4_0,
      ADR1 => alu_i_result_3_map18_0,
      ADR2 => alu_i_result_3_map17_0,
      ADR3 => alu_i_result_3_map10_0,
      O => result_alu_reg_3_pack_1
    );
  alu_i_result_4_48 : X_LUT4
    generic map(
      INIT => X"FAF0",
      LOC => "SLICE_X14Y8"
    )
    port map (
      ADR0 => reg_i_a_out(3),
      ADR1 => VCC,
      ADR2 => alu_i_result_4_map15,
      ADR3 => alu_i_N3_0,
      O => alu_i_result_4_map17
    );
  reg_i_a_out_4 : X_SFF
    generic map(
      LOC => "SLICE_X13Y7",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_4_DYMUX_245,
      CE => VCC,
      CLK => reg_i_a_out_4_CLKINV_247,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_4_REVUSED_244,
      SRST => reg_i_a_out_4_SRINV_246,
      O => reg_i_a_out(4)
    );
  alu_i_result_4_64 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X13Y7"
    )
    port map (
      ADR0 => alu_i_result_4_map18_0,
      ADR1 => alu_i_result_4_map10_0,
      ADR2 => alu_i_result_4_map4_0,
      ADR3 => alu_i_result_4_map17_0,
      O => result_alu_reg_4_pack_1
    );
  control_i_pr_state_or000718 : X_LUT4
    generic map(
      INIT => X"FF01",
      LOC => "SLICE_X3Y10"
    )
    port map (
      ADR0 => control_i_pr_state_FFd26_2,
      ADR1 => N1261,
      ADR2 => prog_data_3_IBUF_33,
      ADR3 => control_i_pr_state_FFd18_11,
      O => control_i_pr_state_or0007_map7
    );
  reg_i_zero_out_mux0000161 : X_LUT4
    generic map(
      INIT => X"153F",
      LOC => "SLICE_X18Y8"
    )
    port map (
      ADR0 => reg_i_a_out(0),
      ADR1 => reg_i_b_out(7),
      ADR2 => reg_i_a_out(7),
      ADR3 => reg_i_b_out(0),
      O => reg_i_zero_out_mux0000_map49
    );
  alu_i_Madd_add_result_int_add0000_lut_6_Q : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X18Y1"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_b_out(6),
      ADR2 => reg_i_a_out(6),
      ADR3 => VCC,
      O => alu_i_N10
    );
  alu_i_zero_out_or00011 : X_LUT4
    generic map(
      INIT => X"1000",
      LOC => "SLICE_X7Y12"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_0_0,
      ADR2 => control_int(2),
      ADR3 => control_int_4_0,
      O => alu_i_zero_out_or0001
    );
  control_i_pr_state_FFd6_In1 : X_LUT4
    generic map(
      INIT => X"C000",
      LOC => "SLICE_X5Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_N11,
      ADR2 => control_i_N6,
      ADR3 => prog_data_0_IBUF_0,
      O => control_i_pr_state_cmp_eq0063
    );
  control_i_pr_state_FFd6 : X_SFF
    generic map(
      LOC => "SLICE_X5Y12",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd6_DXMUX_252,
      CE => VCC,
      CLK => control_i_pr_state_FFd6_CLKINV_254,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd6_SRINV_253,
      O => control_i_pr_state_FFd6_45
    );
  control_i_pr_state_or000515_SW1 : X_LUT4
    generic map(
      INIT => X"CCFD",
      LOC => "SLICE_X3Y19"
    )
    port map (
      ADR0 => control_i_N5,
      ADR1 => control_i_pr_state_FFd26_2,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => control_i_pr_state_cmp_eq0015_0,
      O => N1279
    );
  alu_i_xor0000_or0000 : X_LUT4
    generic map(
      INIT => X"AAF0",
      LOC => "SLICE_X21Y2"
    )
    port map (
      ADR0 => N1178,
      ADR1 => VCC,
      ADR2 => N1177_0,
      ADR3 => alu_i_temp_carry_6_or0001_0,
      O => alu_i_xor0000_or0000_248
    );
  control_i_pr_state_FFd2_In1 : X_LUT4
    generic map(
      INIT => X"A000",
      LOC => "SLICE_X5Y10"
    )
    port map (
      ADR0 => prog_data_0_IBUF_0,
      ADR1 => VCC,
      ADR2 => control_i_N9,
      ADR3 => control_i_N11,
      O => control_i_pr_state_cmp_eq0065
    );
  control_i_pr_state_FFd2 : X_SFF
    generic map(
      LOC => "SLICE_X5Y10",
      INIT => '0'
    )
    port map (
      I => control_i_pr_state_FFd2_DXMUX_249,
      CE => VCC,
      CLK => control_i_pr_state_FFd2_CLKINV_251,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_i_pr_state_FFd2_SRINV_250,
      O => control_i_pr_state_FFd2_20
    );
  reg_i_a_out_mux0000_2_SW0 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X10Y6"
    )
    port map (
      ADR0 => reg_i_a_out(2),
      ADR1 => reg_i_a_out_or0001_0,
      ADR2 => reg_i_a_out_cmp_eq0009_30,
      ADR3 => reg_i_rom_data_intern(2),
      O => N88
    );
  reg_i_a_out_or0000 : X_LUT4
    generic map(
      INIT => X"0172",
      LOC => "SLICE_X15Y9"
    )
    port map (
      ADR0 => N1318,
      ADR1 => control_int_4_0,
      ADR2 => control_int(2),
      ADR3 => control_int_3_0,
      O => reg_i_a_out_or0000_255
    );
  reg_i_zero_out_mux0000225 : X_LUT4
    generic map(
      INIT => X"8000",
      LOC => "SLICE_X14Y9"
    )
    port map (
      ADR0 => reg_i_zero_out_mux0000_map56_0,
      ADR1 => reg_i_zero_out_mux0000_map49_0,
      ADR2 => reg_i_zero_out_mux0000_map71,
      ADR3 => reg_i_zero_out_mux0000_map64_0,
      O => reg_i_zero_out_mux0000_map73
    );
  reg_i_a_out_7 : X_SFF
    generic map(
      LOC => "SLICE_X18Y2",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_7_DYMUX_346,
      CE => VCC,
      CLK => reg_i_a_out_7_CLKINV_348,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_7_REVUSED_345,
      SRST => reg_i_a_out_7_SRINV_347,
      O => reg_i_a_out(7)
    );
  alu_i_result_7_59 : X_LUT4
    generic map(
      INIT => X"FFEC",
      LOC => "SLICE_X18Y2"
    )
    port map (
      ADR0 => reg_i_a_out(7),
      ADR1 => alu_i_result_7_map7_0,
      ADR2 => alu_i_N1_0,
      ADR3 => alu_i_result_7_map15_0,
      O => alu_i_result_7_map18_pack_1
    );
  reg_i_a_out_or000111 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X6Y15"
    )
    port map (
      ADR0 => control_int_4_0,
      ADR1 => control_i_pr_state_or0002231_0,
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => control_int_0_0,
      O => reg_i_N0
    );
  pc_i_pc_int_cmp_eq0003 : X_LUT4
    generic map(
      INIT => X"0002",
      LOC => "SLICE_X8Y17"
    )
    port map (
      ADR0 => control_nxt_int_0_0,
      ADR1 => control_nxt_int_1_0,
      ADR2 => N547,
      ADR3 => control_nxt_int_2_0,
      O => pc_i_pc_int_cmp_eq0003_349
    );
  reg_i_zero_out_mux0000314_SW0_SW0 : X_LUT4
    generic map(
      INIT => X"FF80",
      LOC => "SLICE_X14Y10"
    )
    port map (
      ADR0 => reg_i_zero_out_mux0000_map39_0,
      ADR1 => reg_i_zero_out_mux0000_map32_0,
      ADR2 => alu_i_zero_out_cmp_eq0004_0,
      ADR3 => reg_i_zero_out_mux0000290_O,
      O => N1291
    );
  reg_i_b_out_2 : X_SFF
    generic map(
      LOC => "SLICE_X10Y8",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_2_DXMUX_322,
      CE => VCC,
      CLK => reg_i_b_out_2_CLKINV_326,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_2_SRINV_325,
      O => reg_i_b_out(2)
    );
  reg_i_b_out_3 : X_SFF
    generic map(
      LOC => "SLICE_X13Y6",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_3_DXMUX_327,
      CE => VCC,
      CLK => reg_i_b_out_3_CLKINV_331,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_3_SRINV_330,
      O => reg_i_b_out(3)
    );
  reg_i_b_out_4 : X_SFF
    generic map(
      LOC => "SLICE_X12Y7",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_4_DXMUX_332,
      CE => VCC,
      CLK => reg_i_b_out_4_CLKINV_336,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_4_SRINV_335,
      O => reg_i_b_out(4)
    );
  reg_i_zero_out_mux0000371_SW0 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X17Y8"
    )
    port map (
      ADR0 => N1340_0,
      ADR1 => N1330_0,
      ADR2 => reg_i_zero_out_mux0000356_SW0_O,
      ADR3 => alu_i_add_result_int_add0000(7),
      O => N1332
    );
  control_i_pr_state_FFd10_In11_SW11 : X_LUT4
    generic map(
      INIT => X"EFFF",
      LOC => "SLICE_X2Y13"
    )
    port map (
      ADR0 => prog_data_3_IBUF_33,
      ADR1 => prog_data_2_IBUF_34,
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => prog_data_1_IBUF_8,
      O => N1409
    );
  reg_i_b_out_0 : X_SFF
    generic map(
      LOC => "SLICE_X12Y4",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_0_DXMUX_312,
      CE => VCC,
      CLK => reg_i_b_out_0_CLKINV_316,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_0_SRINV_315,
      O => reg_i_b_out(0)
    );
  reg_i_b_out_1 : X_SFF
    generic map(
      LOC => "SLICE_X11Y6",
      INIT => '0'
    )
    port map (
      I => reg_i_b_out_1_DXMUX_317,
      CE => VCC,
      CLK => reg_i_b_out_1_CLKINV_321,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => reg_i_b_out_1_SRINV_320,
      O => reg_i_b_out(1)
    );
  reg_i_zero_out_mux0000603_SW0 : X_LUT4
    generic map(
      INIT => X"0103",
      LOC => "SLICE_X17Y10"
    )
    port map (
      ADR0 => reg_i_zero_out_6,
      ADR1 => N1332_0,
      ADR2 => reg_i_zero_out_mux0000500_O,
      ADR3 => alu_i_zero_out_or0002,
      O => N1281
    );
  reg_i_zero_out_mux0000524_SW0 : X_LUT4
    generic map(
      INIT => X"0500",
      LOC => "SLICE_X18Y6"
    )
    port map (
      ADR0 => alu_i_xor0000,
      ADR1 => VCC,
      ADR2 => alu_i_xor0001,
      ADR3 => reg_i_zero_out_mux0000565_O,
      O => N1255
    );
  alu_i_Mxor_xor0004_Result1 : X_LUT4
    generic map(
      INIT => X"3C5A",
      LOC => "SLICE_X15Y8"
    )
    port map (
      ADR0 => N1299_0,
      ADR1 => N1300_0,
      ADR2 => alu_i_N7,
      ADR3 => alu_i_xor0006_or0000,
      O => alu_i_xor0004
    );
  reg_i_a_out_or00012 : X_LUT4
    generic map(
      INIT => X"FCF0",
      LOC => "SLICE_X11Y8"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_4_0,
      ADR2 => reg_i_zero_out_or0000,
      ADR3 => control_int_1_0,
      O => reg_i_a_out_or0001
    );
  reg_i_a_out_5 : X_SFF
    generic map(
      LOC => "SLICE_X17Y0",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_5_DYMUX_338,
      CE => VCC,
      CLK => reg_i_a_out_5_CLKINV_340,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_5_REVUSED_337,
      SRST => reg_i_a_out_5_SRINV_339,
      O => reg_i_a_out(5)
    );
  alu_i_result_5_59 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X17Y0"
    )
    port map (
      ADR0 => reg_i_a_out(5),
      ADR1 => alu_i_result_5_map15_0,
      ADR2 => alu_i_result_5_map7_0,
      ADR3 => alu_i_N1_0,
      O => alu_i_result_5_map18_pack_1
    );
  reg_i_a_out_6 : X_SFF
    generic map(
      LOC => "SLICE_X16Y4",
      INIT => '0'
    )
    port map (
      I => reg_i_a_out_6_DYMUX_342,
      CE => VCC,
      CLK => reg_i_a_out_6_CLKINV_344,
      SET => GND,
      RST => GND,
      SSET => reg_i_a_out_6_REVUSED_341,
      SRST => reg_i_a_out_6_SRINV_343,
      O => reg_i_a_out(6)
    );
  alu_i_result_6_59 : X_LUT4
    generic map(
      INIT => X"FFEC",
      LOC => "SLICE_X16Y4"
    )
    port map (
      ADR0 => reg_i_a_out(6),
      ADR1 => alu_i_result_6_map7_0,
      ADR2 => alu_i_N1_0,
      ADR3 => alu_i_result_6_map15_0,
      O => alu_i_result_6_map18_pack_1
    );
  pc_i_pc_int_0 : X_SFF
    generic map(
      LOC => "SLICE_X6Y19",
      INIT => '0'
    )
    port map (
      I => pc_i_pc_int_0_DXMUX_355,
      CE => VCC,
      CLK => pc_i_pc_int_0_CLKINV_357,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => pc_i_pc_int_0_SRINV_356,
      O => pc_i_pc_int(0)
    );
  alu_i_zero_out_or000231 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X8Y12"
    )
    port map (
      ADR0 => control_int_4_0,
      ADR1 => control_int_3_0,
      ADR2 => control_i_pr_state_or0002231_0,
      ADR3 => N1318,
      O => alu_i_zero_out_or0002_map12
    );
  control_i_pr_state_or000117_1 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y13"
    )
    port map (
      ADR0 => control_i_pr_state_FFd11_7,
      ADR1 => control_i_pr_state_FFd10_16,
      ADR2 => control_i_pr_state_or0001_map6,
      ADR3 => control_i_pr_state_or0001_map2,
      O => control_i_pr_state_or000117_358
    );
  control_i_pr_state_or000223_1 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X9Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or0002_map2_0,
      ADR2 => control_i_pr_state_or0002_map5,
      ADR3 => control_i_pr_state_or0002_map8,
      O => control_i_pr_state_or000223_359
    );
  control_i_pr_state_or000223_2 : X_LUT4
    generic map(
      INIT => X"FFFA",
      LOC => "SLICE_X9Y14"
    )
    port map (
      ADR0 => control_i_pr_state_or0002_map2_0,
      ADR1 => VCC,
      ADR2 => control_i_pr_state_or0002_map5,
      ADR3 => control_i_pr_state_or0002_map8,
      O => control_i_pr_state_or0002231
    );
  reg_i_carry_out : X_SFF
    generic map(
      LOC => "SLICE_X18Y10",
      INIT => '0'
    )
    port map (
      I => reg_i_carry_out_DYMUX_351,
      CE => VCC,
      CLK => reg_i_carry_out_CLKINV_353,
      SET => GND,
      RST => GND,
      SSET => reg_i_carry_out_REVUSED_350,
      SRST => reg_i_carry_out_SRINV_352,
      O => reg_i_carry_out_3
    );
  reg_i_carry_out_mux0000117 : X_LUT4
    generic map(
      INIT => X"C880",
      LOC => "SLICE_X18Y10"
    )
    port map (
      ADR0 => reg_i_a_out(7),
      ADR1 => alu_i_zero_out_cmp_eq0014_0,
      ADR2 => alu_i_xor0000_or0000_0,
      ADR3 => reg_i_b_out(7),
      O => reg_i_carry_out_mux0000117_O_pack_1
    );
  alu_i_Mxor_xor0005_Result1 : X_LUT4
    generic map(
      INIT => X"566A",
      LOC => "SLICE_X12Y11"
    )
    port map (
      ADR0 => alu_i_N6_0,
      ADR1 => reg_i_a_out(1),
      ADR2 => alu_i_xor0006_or0000,
      ADR3 => reg_i_b_out(1),
      O => alu_i_xor0005
    );
  alu_i_zero_out_or0000 : X_LUT4
    generic map(
      INIT => X"0084",
      LOC => "SLICE_X9Y12"
    )
    port map (
      ADR0 => control_int(2),
      ADR1 => control_int_4_0,
      ADR2 => N224,
      ADR3 => control_int_3_0,
      O => alu_i_zero_out_or0000_354
    );
  pc_i_pc_int_mux0002_0_1 : X_LUT4
    generic map(
      INIT => X"E4B1",
      LOC => "SLICE_X6Y19"
    )
    port map (
      ADR0 => pc_i_pc_int_or0000_38,
      ADR1 => pc_i_pc_int(0),
      ADR2 => prog_data_0_IBUF_0,
      ADR3 => pc_i_pc_int_cmp_eq0003_0,
      O => pc_i_pc_int_mux0002(0)
    );
  alu_i_zero_out_cmp_eq00041 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X13Y13"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => control_int_4_0,
      ADR2 => control_i_pr_state_or000323_9,
      ADR3 => N1316,
      O => alu_i_zero_out_cmp_eq0004
    );
  alu_i_zero_out_cmp_eq00061 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X8Y13"
    )
    port map (
      ADR0 => control_int_3_0,
      ADR1 => alu_i_N22,
      ADR2 => control_int_4_0,
      ADR3 => control_int_0_0,
      O => alu_i_zero_out_cmp_eq0006
    );
  alu_i_zero_out_cmp_eq000011 : X_LUT4
    generic map(
      INIT => X"000C",
      LOC => "SLICE_X6Y10"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_pr_state_or000427_0,
      ADR2 => control_i_pr_state_or000117_0,
      ADR3 => control_i_pr_state_or000017_42,
      O => alu_i_N61
    );
  control_i_pr_state_or000427_1 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y15"
    )
    port map (
      ADR0 => control_i_pr_state_FFd9_25,
      ADR1 => control_i_pr_state_or0004_map9_0,
      ADR2 => N1249,
      ADR3 => control_i_pr_state_or0004_map6,
      O => control_i_pr_state_or000427_360
    );
  GLOBAL_LOGIC0_GND : X_ZERO
    port map (
      O => GLOBAL_LOGIC0
    );
  GLOBAL_LOGIC1_VCC : X_ONE
    port map (
      O => GLOBAL_LOGIC1
    );
  pc_i_pc_int_addsub0000_2_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"AAAA",
      LOC => "SLICE_X9Y17"
    )
    port map (
      ADR0 => pc_i_pc_int(2),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => VCC,
      O => pc_i_pc_int_addsub0000_2_F
    );
  pc_i_pc_int_addsub0000_2_G_X_LUT4 : X_LUT4
    generic map(
      INIT => X"F0F0",
      LOC => "SLICE_X9Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => pc_i_pc_int(3),
      ADR3 => VCC,
      O => pc_i_pc_int_addsub0000_2_G
    );
  pc_i_pc_int_addsub0000_4_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"F0F0",
      LOC => "SLICE_X9Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => pc_i_pc_int(4),
      ADR3 => VCC,
      O => pc_i_pc_int_addsub0000_4_F
    );
  pc_i_pc_int_addsub0000_4_G_X_LUT4 : X_LUT4
    generic map(
      INIT => X"FF00",
      LOC => "SLICE_X9Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => pc_i_pc_int(5),
      O => pc_i_pc_int_addsub0000_4_G
    );
  pc_i_pc_int_addsub0000_6_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"FF00",
      LOC => "SLICE_X9Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => pc_i_pc_int(6),
      O => pc_i_pc_int_addsub0000_6_F
    );
  cflag_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_carry_out_3,
      O => cflag_O
    );
  a_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD97",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(0),
      O => a_0_O
    );
  datmem_data_out_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(0),
      O => datmem_data_out_0_O
    );
  a_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(1),
      O => a_1_O
    );
  datmem_data_out_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD52",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(1),
      O => datmem_data_out_1_O
    );
  a_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(2),
      O => a_2_O
    );
  datmem_data_out_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(2),
      O => datmem_data_out_2_O
    );
  a_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(3),
      O => a_3_O
    );
  datmem_data_out_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(3),
      O => datmem_data_out_3_O
    );
  b_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(0),
      O => b_0_O
    );
  a_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD81",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(4),
      O => a_4_O
    );
  datmem_data_out_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD75",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(4),
      O => datmem_data_out_4_O
    );
  b_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(1),
      O => b_1_O
    );
  a_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD91",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(5),
      O => a_5_O
    );
  datmem_data_out_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD92",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(5),
      O => datmem_data_out_5_O
    );
  b_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD82",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(2),
      O => b_2_O
    );
  a_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD65",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(6),
      O => a_6_O
    );
  datmem_data_out_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD64",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(6),
      O => datmem_data_out_6_O
    );
  b_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD50",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(3),
      O => b_3_O
    );
  a_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD47",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(7),
      O => a_7_O
    );
  datmem_data_out_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD48",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out(7),
      O => datmem_data_out_7_O
    );
  b_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD51",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(4),
      O => b_4_O
    );
  b_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD49",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(5),
      O => b_5_O
    );
  b_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD53",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(6),
      O => b_6_O
    );
  b_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out(7),
      O => b_7_O
    );
  datmem_adr_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD108",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_0_IBUF_0,
      O => datmem_adr_0_O
    );
  datmem_adr_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_IBUF_8,
      O => datmem_adr_1_O
    );
  datmem_adr_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_2_IBUF_34,
      O => datmem_adr_2_O
    );
  datmem_adr_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_3_IBUF_33,
      O => datmem_adr_3_O
    );
  datmem_adr_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD85",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_4_IBUF_39,
      O => datmem_adr_4_O
    );
  datmem_adr_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD86",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_IBUF_27,
      O => datmem_adr_5_O
    );
  datmem_adr_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD109",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_6_IBUF_29,
      O => datmem_adr_6_O
    );
  datmem_adr_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD110",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_7_IBUF_28,
      O => datmem_adr_7_O
    );
  datmem_nrd_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_nrd_OBUF_142,
      O => datmem_nrd_O
    );
  datmem_nwr_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_nwr_OBUF_141,
      O => datmem_nwr_O
    );
  zflag_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_zero_out_6,
      O => zflag_O
    );
  prog_adr_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD46",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(0),
      O => prog_adr_0_O
    );
  prog_adr_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(1),
      O => prog_adr_1_O
    );
  prog_adr_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(2),
      O => prog_adr_2_O
    );
  prog_adr_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(3),
      O => prog_adr_3_O
    );
  prog_adr_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD113",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(4),
      O => prog_adr_4_O
    );
  prog_adr_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD114",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(5),
      O => prog_adr_5_O
    );
  prog_adr_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD112",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(6),
      O => prog_adr_6_O
    );
  prog_adr_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD111",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_pc_int(7),
      O => prog_adr_7_O
    );
  N1265_G_X_LUT4 : X_LUT4
    generic map(
      INIT => X"FFFF",
      LOC => "SLICE_X2Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => VCC,
      O => N1265_G
    );
  NlwBlock_processor_E_VCC : X_ONE
    port map (
      O => VCC
    );
  NlwBlock_processor_E_GND : X_ZERO
    port map (
      O => GND
    );
  NlwBlockROC : X_ROC
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end STRUCTURE;

