--------------------------------------------------------------------------------
-- Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: J.40
--  \   \         Application: netgen
--  /   /         Filename: processor_E_backan.vhd
-- /___/   /\     Timestamp: Sun Jul 13 18:03:01 2008
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -sim -ofmt vhdl -rpw 100 -w -s 4 -a -dir ../../backanno processor_E_out.ncd processor_E_backan.vhd 
-- Device	: 3s50tq144-4 (PRODUCTION 1.39 2007-10-19)
-- Input file	: processor_E_out.ncd
-- Output file	: /home/praktikum/pr06/processor/backanno/processor_E_backan.vhd
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

architecture STRUCTURE of processor_E is
  signal control_i_nx28711z4_0 : STD_LOGIC; 
  signal control_i_nx24721z2_0 : STD_LOGIC; 
  signal flagz_alu_control_0 : STD_LOGIC; 
  signal nx56395z1_0 : STD_LOGIC; 
  signal nx6954z1_0 : STD_LOGIC; 
  signal rst_int_0 : STD_LOGIC; 
  signal clk_int : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_0_0 : STD_LOGIC; 
  signal alu_i_nx51436z3 : STD_LOGIC; 
  signal alu_i_nx51436z4 : STD_LOGIC; 
  signal alu_i_nx51436z2_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_1_0 : STD_LOGIC; 
  signal alu_i_nx18369z1_0 : STD_LOGIC; 
  signal alu_i_nx18369z2_0 : STD_LOGIC; 
  signal alu_i_nx18369z3_0 : STD_LOGIC; 
  signal alu_i_nx18369z4_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_5_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_2_0 : STD_LOGIC; 
  signal alu_i_nx49743z41_0 : STD_LOGIC; 
  signal alu_i_nx17372z6_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_3_0 : STD_LOGIC; 
  signal alu_i_nx20363z19 : STD_LOGIC; 
  signal alu_i_nx20363z20 : STD_LOGIC; 
  signal alu_i_nx20363z18_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_4_0 : STD_LOGIC; 
  signal alu_i_nx13384z1_0 : STD_LOGIC; 
  signal alu_i_nx13384z3_0 : STD_LOGIC; 
  signal alu_i_nx13384z4_0 : STD_LOGIC; 
  signal alu_i_nx13384z5_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_6_0 : STD_LOGIC; 
  signal reg_i_a_out_1n1ss1_7_0 : STD_LOGIC; 
  signal nx17594z1_0 : STD_LOGIC; 
  signal nreset_int_int : STD_LOGIC; 
  signal zero_alu_reg_0 : STD_LOGIC; 
  signal nx38625z1_0 : STD_LOGIC; 
  signal nreset_int_int_int : STD_LOGIC; 
  signal carry_alu_reg : STD_LOGIC; 
  signal GLOBAL_LOGIC1 : STD_LOGIC; 
  signal control_i_nx27714z2_0 : STD_LOGIC; 
  signal control_i_nx51041z2 : STD_LOGIC; 
  signal control_i_nx50044z2_0 : STD_LOGIC; 
  signal control_i_nx51041z4_0 : STD_LOGIC; 
  signal control_i_nx25718z3_0 : STD_LOGIC; 
  signal flagc_alu_control : STD_LOGIC; 
  signal cflag_dup0 : STD_LOGIC; 
  signal alu_i_nx51436z1_0 : STD_LOGIC; 
  signal alu_i_nx51436z5_0 : STD_LOGIC; 
  signal control_i_nx2739z1_0 : STD_LOGIC; 
  signal control_i_nx28711z3_0 : STD_LOGIC; 
  signal control_i_nx32699z3_0 : STD_LOGIC; 
  signal control_i_nx28711z2 : STD_LOGIC; 
  signal control_i_nx32699z2_0 : STD_LOGIC; 
  signal control_i_nx27714z3_0 : STD_LOGIC; 
  signal control_i_nx32699z4 : STD_LOGIC; 
  signal control_i_nx45059z2_0 : STD_LOGIC; 
  signal control_i_nx44062z2_0 : STD_LOGIC; 
  signal control_i_nx47053z2_0 : STD_LOGIC; 
  signal control_i_nx46056z2_0 : STD_LOGIC; 
  signal control_i_nx49047z2_0 : STD_LOGIC; 
  signal control_i_nx48050z2_0 : STD_LOGIC; 
  signal control_i_nx27714z5_0 : STD_LOGIC; 
  signal control_i_nx27714z6 : STD_LOGIC; 
  signal alu_i_nx20363z16 : STD_LOGIC; 
  signal alu_i_nx20363z17 : STD_LOGIC; 
  signal alu_i_nx14381z3_0 : STD_LOGIC; 
  signal alu_i_nx20363z15_0 : STD_LOGIC; 
  signal alu_i_nx20363z4 : STD_LOGIC; 
  signal alu_i_nx20363z5_0 : STD_LOGIC; 
  signal alu_i_nx20363z3_0 : STD_LOGIC; 
  signal alu_i_nx17372z5 : STD_LOGIC; 
  signal alu_i_nx17372z7 : STD_LOGIC; 
  signal alu_i_nx17372z4_0 : STD_LOGIC; 
  signal alu_i_nx20363z6 : STD_LOGIC; 
  signal alu_i_nx20363z7 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_1_0 : STD_LOGIC; 
  signal alu_i_nx17372z2_0 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_0_0 : STD_LOGIC; 
  signal alu_i_nx13384z6_0 : STD_LOGIC; 
  signal alu_i_nx19366z9_0 : STD_LOGIC; 
  signal alu_i_nx49743z17_0 : STD_LOGIC; 
  signal alu_i_nx49743z20_0 : STD_LOGIC; 
  signal alu_i_nx20363z1_0 : STD_LOGIC; 
  signal alu_i_nx20363z37_0 : STD_LOGIC; 
  signal alu_i_nx49743z40_0 : STD_LOGIC; 
  signal alu_i_nx49743z18_0 : STD_LOGIC; 
  signal alu_i_nx20363z2 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_7_0 : STD_LOGIC; 
  signal ram_control_i_n_clk : STD_LOGIC; 
  signal ram_control_i_p_clk : STD_LOGIC; 
  signal alu_i_nx20363z10 : STD_LOGIC; 
  signal alu_i_nx20363z14_0 : STD_LOGIC; 
  signal alu_i_nx14381z1_0 : STD_LOGIC; 
  signal alu_i_nx16375z2_0 : STD_LOGIC; 
  signal alu_i_nx13384z7_0 : STD_LOGIC; 
  signal alu_i_nx13384z8 : STD_LOGIC; 
  signal control_i_nx25718z2 : STD_LOGIC; 
  signal alu_i_nx49743z19_0 : STD_LOGIC; 
  signal alu_i_nx49743z36_0 : STD_LOGIC; 
  signal alu_i_nx49743z37 : STD_LOGIC; 
  signal alu_i_nx49743z35_0 : STD_LOGIC; 
  signal alu_i_nx20363z11_0 : STD_LOGIC; 
  signal alu_i_nx20363z12_0 : STD_LOGIC; 
  signal alu_i_nx20363z13_0 : STD_LOGIC; 
  signal alu_i_nx20363z9_0 : STD_LOGIC; 
  signal alu_i_nx19366z1_0 : STD_LOGIC; 
  signal alu_i_nx18369z6_0 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_6_0 : STD_LOGIC; 
  signal control_i_nx42068z2_0 : STD_LOGIC; 
  signal alu_i_nx18369z5 : STD_LOGIC; 
  signal alu_i_nx18369z7 : STD_LOGIC; 
  signal alu_i_nx14381z6_0 : STD_LOGIC; 
  signal alu_i_nx13384z2 : STD_LOGIC; 
  signal alu_i_nx15378z1_0 : STD_LOGIC; 
  signal alu_i_nx15378z3_0 : STD_LOGIC; 
  signal alu_i_nx17372z1_0 : STD_LOGIC; 
  signal alu_i_nx16375z1_0 : STD_LOGIC; 
  signal alu_i_nx16375z8_0 : STD_LOGIC; 
  signal alu_i_nx16375z5 : STD_LOGIC; 
  signal alu_i_nx16375z6 : STD_LOGIC; 
  signal alu_i_nx16375z4_0 : STD_LOGIC; 
  signal alu_i_nx14381z2_0 : STD_LOGIC; 
  signal alu_i_nx16375z3_0 : STD_LOGIC; 
  signal alu_i_nx19366z4_0 : STD_LOGIC; 
  signal control_i_nx42068z3_0 : STD_LOGIC; 
  signal alu_i_nx19366z3_0 : STD_LOGIC; 
  signal alu_i_nx19366z5_0 : STD_LOGIC; 
  signal alu_i_nx19366z8 : STD_LOGIC; 
  signal alu_i_nx19366z2_0 : STD_LOGIC; 
  signal pc_i_rtlc3_PS4_n64 : STD_LOGIC; 
  signal nx62171z14_0 : STD_LOGIC; 
  signal control_i_nx2739z2 : STD_LOGIC; 
  signal control_i_nx27714z4 : STD_LOGIC; 
  signal control_nxt_int_fsm_1_0 : STD_LOGIC; 
  signal nx62171z8_0 : STD_LOGIC; 
  signal nx62171z11_0 : STD_LOGIC; 
  signal nx62171z10_0 : STD_LOGIC; 
  signal nx62171z13_0 : STD_LOGIC; 
  signal nx62171z12_0 : STD_LOGIC; 
  signal alu_i_nx14381z4_0 : STD_LOGIC; 
  signal alu_i_nx19366z6 : STD_LOGIC; 
  signal alu_i_nx19366z7 : STD_LOGIC; 
  signal nx53939z1_0 : STD_LOGIC; 
  signal alu_i_nx49743z2 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_3_0 : STD_LOGIC; 
  signal alu_i_nx49743z1_0 : STD_LOGIC; 
  signal alu_i_nx49743z39_0 : STD_LOGIC; 
  signal alu_i_nx15378z6_0 : STD_LOGIC; 
  signal alu_i_nx15378z5 : STD_LOGIC; 
  signal alu_i_nx14381z5 : STD_LOGIC; 
  signal alu_i_nx49743z26_0 : STD_LOGIC; 
  signal alu_i_nx17372z3_0 : STD_LOGIC; 
  signal alu_i_nx49743z13_0 : STD_LOGIC; 
  signal alu_i_nx15378z2_0 : STD_LOGIC; 
  signal alu_i_nx15378z4_0 : STD_LOGIC; 
  signal alu_i_nx49743z14_0 : STD_LOGIC; 
  signal alu_i_nx49743z22 : STD_LOGIC; 
  signal alu_i_nx49743z23_0 : STD_LOGIC; 
  signal alu_i_nx49743z29 : STD_LOGIC; 
  signal alu_i_nx49743z28_0 : STD_LOGIC; 
  signal alu_i_nx49743z31 : STD_LOGIC; 
  signal alu_i_nx49743z30_0 : STD_LOGIC; 
  signal alu_i_nx49743z25_0 : STD_LOGIC; 
  signal alu_i_nx14381z7 : STD_LOGIC; 
  signal alu_i_nx49743z46 : STD_LOGIC; 
  signal alu_i_nx49743z45_0 : STD_LOGIC; 
  signal alu_i_nx49743z34 : STD_LOGIC; 
  signal alu_i_nx49743z33_0 : STD_LOGIC; 
  signal alu_i_nx49743z43 : STD_LOGIC; 
  signal alu_i_nx49743z42_0 : STD_LOGIC; 
  signal alu_i_nx16375z7 : STD_LOGIC; 
  signal GLOBAL_LOGIC0 : STD_LOGIC; 
  signal alu_i_ix20363z63367_O : STD_LOGIC; 
  signal alu_i_ix20363z63365_O : STD_LOGIC; 
  signal alu_i_ix20363z63363_O : STD_LOGIC; 
  signal alu_i_nx15378z7 : STD_LOGIC; 
  signal alu_i_nx49743z16 : STD_LOGIC; 
  signal alu_i_nx49743z15_0 : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63346_O : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63344_O : STD_LOGIC; 
  signal zflag_dup0 : STD_LOGIC; 
  signal alu_i_nx20363z8_0 : STD_LOGIC; 
  signal alu_i_ix49743z63345_O : STD_LOGIC; 
  signal control_i_nx51041z3_0 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_f6_1 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_f6_0 : STD_LOGIC; 
  signal alu_i_nx20363z36 : STD_LOGIC; 
  signal alu_i_nx51436z6 : STD_LOGIC; 
  signal control_i_nx28711z4 : STD_LOGIC; 
  signal control_i_nx24721z2 : STD_LOGIC; 
  signal datmem_nrd_O : STD_LOGIC; 
  signal nx56395z1 : STD_LOGIC; 
  signal nx6954z1 : STD_LOGIC; 
  signal datmem_data_out_0_O : STD_LOGIC; 
  signal datmem_data_out_0_OUTPUT_OTCLK1INV_0 : STD_LOGIC; 
  signal alu_i_nx51436z2 : STD_LOGIC; 
  signal alu_i_nx51436z3_pack_1 : STD_LOGIC; 
  signal datmem_data_out_1_O : STD_LOGIC; 
  signal datmem_data_out_1_OUTPUT_OTCLK1INV_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_DXMUX_2 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_FXMUX_3 : STD_LOGIC; 
  signal result_alu_reg_5_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_SRINV_4 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_CLKINV_5 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_CEINV_6 : STD_LOGIC; 
  signal datmem_data_out_2_O : STD_LOGIC; 
  signal datmem_data_out_2_OUTPUT_OTCLK1INV_7 : STD_LOGIC; 
  signal alu_i_nx49743z41 : STD_LOGIC; 
  signal alu_i_nx17372z6 : STD_LOGIC; 
  signal datmem_data_out_3_O : STD_LOGIC; 
  signal datmem_data_out_3_OUTPUT_OTCLK1INV_8 : STD_LOGIC; 
  signal alu_i_nx20363z18 : STD_LOGIC; 
  signal alu_i_nx20363z19_pack_1 : STD_LOGIC; 
  signal datmem_data_out_4_O : STD_LOGIC; 
  signal datmem_data_out_4_OUTPUT_OTCLK1INV_9 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_DXMUX_10 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_FXMUX_11 : STD_LOGIC; 
  signal result_alu_reg_0_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_SRINV_12 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_CLKINV_13 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_CEINV_14 : STD_LOGIC; 
  signal datmem_data_out_5_O : STD_LOGIC; 
  signal datmem_data_out_5_OUTPUT_OTCLK1INV_15 : STD_LOGIC; 
  signal datmem_data_out_6_O : STD_LOGIC; 
  signal datmem_data_out_6_OUTPUT_OTCLK1INV_16 : STD_LOGIC; 
  signal datmem_nwr_O : STD_LOGIC; 
  signal datmem_data_out_7_O : STD_LOGIC; 
  signal datmem_data_out_7_OUTPUT_OTCLK1INV_17 : STD_LOGIC; 
  signal datmem_data_in_0_INBUF : STD_LOGIC; 
  signal datmem_data_in_1_INBUF : STD_LOGIC; 
  signal datmem_data_in_2_INBUF : STD_LOGIC; 
  signal nreset_INBUF : STD_LOGIC; 
  signal a_0_O : STD_LOGIC; 
  signal a_0_OUTPUT_OTCLK1INV_18 : STD_LOGIC; 
  signal zflag_O : STD_LOGIC; 
  signal zflag_OUTPUT_OTCLK1INV_19 : STD_LOGIC; 
  signal datmem_data_in_3_INBUF : STD_LOGIC; 
  signal a_1_O : STD_LOGIC; 
  signal a_1_OUTPUT_OTCLK1INV_20 : STD_LOGIC; 
  signal datmem_data_in_4_INBUF : STD_LOGIC; 
  signal a_2_O : STD_LOGIC; 
  signal a_2_OUTPUT_OTCLK1INV_21 : STD_LOGIC; 
  signal datmem_data_in_5_INBUF : STD_LOGIC; 
  signal a_3_O : STD_LOGIC; 
  signal a_3_OUTPUT_OTCLK1INV_22 : STD_LOGIC; 
  signal datmem_data_in_6_INBUF : STD_LOGIC; 
  signal a_4_O : STD_LOGIC; 
  signal a_4_OUTPUT_OTCLK1INV_23 : STD_LOGIC; 
  signal b_0_O : STD_LOGIC; 
  signal b_0_OUTPUT_OTCLK1INV_24 : STD_LOGIC; 
  signal datmem_data_in_7_INBUF : STD_LOGIC; 
  signal a_5_O : STD_LOGIC; 
  signal a_5_OUTPUT_OTCLK1INV_25 : STD_LOGIC; 
  signal b_1_O : STD_LOGIC; 
  signal b_1_OUTPUT_OTCLK1INV_26 : STD_LOGIC; 
  signal a_6_O : STD_LOGIC; 
  signal a_6_OUTPUT_OTCLK1INV_27 : STD_LOGIC; 
  signal b_2_O : STD_LOGIC; 
  signal b_2_OUTPUT_OTCLK1INV_28 : STD_LOGIC; 
  signal a_7_O : STD_LOGIC; 
  signal a_7_OUTPUT_OTCLK1INV_29 : STD_LOGIC; 
  signal b_3_O : STD_LOGIC; 
  signal b_3_OUTPUT_OTCLK1INV_30 : STD_LOGIC; 
  signal b_4_O : STD_LOGIC; 
  signal b_4_OUTPUT_OTCLK1INV_31 : STD_LOGIC; 
  signal b_5_O : STD_LOGIC; 
  signal b_5_OUTPUT_OTCLK1INV_32 : STD_LOGIC; 
  signal b_6_O : STD_LOGIC; 
  signal b_6_OUTPUT_OTCLK1INV_33 : STD_LOGIC; 
  signal nreset_int_INBUF : STD_LOGIC; 
  signal b_7_O : STD_LOGIC; 
  signal b_7_OUTPUT_OTCLK1INV_34 : STD_LOGIC; 
  signal datmem_adr_0_O : STD_LOGIC; 
  signal datmem_adr_1_O : STD_LOGIC; 
  signal datmem_adr_2_O : STD_LOGIC; 
  signal datmem_adr_3_O : STD_LOGIC; 
  signal datmem_adr_4_O : STD_LOGIC; 
  signal datmem_adr_5_O : STD_LOGIC; 
  signal datmem_adr_6_O : STD_LOGIC; 
  signal cflag_O : STD_LOGIC; 
  signal cflag_OUTPUT_OTCLK1INV_35 : STD_LOGIC; 
  signal datmem_adr_7_O : STD_LOGIC; 
  signal clk_ibuf_BUFG_S_INVNOT : STD_LOGIC; 
  signal clk_ibuf_BUFG_I0_INV : STD_LOGIC; 
  signal control_int_fsm_18_DXMUX_36 : STD_LOGIC; 
  signal control_i_nx24721z1 : STD_LOGIC; 
  signal control_int_fsm_18_DYMUX_37 : STD_LOGIC; 
  signal control_i_nx50044z1 : STD_LOGIC; 
  signal control_int_fsm_18_SRINV_38 : STD_LOGIC; 
  signal control_int_fsm_18_CLKINV_39 : STD_LOGIC; 
  signal b_dup0_1_DXMUX_40 : STD_LOGIC; 
  signal b_dup0_1_FXMUX_41 : STD_LOGIC; 
  signal b_dup0_1_DYMUX_42 : STD_LOGIC; 
  signal b_dup0_1_GYMUX_43 : STD_LOGIC; 
  signal b_dup0_1_SRINV_44 : STD_LOGIC; 
  signal b_dup0_1_CLKINV_45 : STD_LOGIC; 
  signal b_dup0_1_CEINV_46 : STD_LOGIC; 
  signal b_dup0_3_DXMUX_47 : STD_LOGIC; 
  signal b_dup0_3_FXMUX_48 : STD_LOGIC; 
  signal b_dup0_3_DYMUX_49 : STD_LOGIC; 
  signal b_dup0_3_GYMUX_50 : STD_LOGIC; 
  signal b_dup0_3_SRINV_51 : STD_LOGIC; 
  signal b_dup0_3_CLKINV_52 : STD_LOGIC; 
  signal b_dup0_3_CEINV_53 : STD_LOGIC; 
  signal b_dup0_5_DXMUX_54 : STD_LOGIC; 
  signal b_dup0_5_FXMUX_55 : STD_LOGIC; 
  signal b_dup0_5_DYMUX_56 : STD_LOGIC; 
  signal b_dup0_5_GYMUX_57 : STD_LOGIC; 
  signal b_dup0_5_SRINV_58 : STD_LOGIC; 
  signal b_dup0_5_CLKINV_59 : STD_LOGIC; 
  signal b_dup0_5_CEINV_60 : STD_LOGIC; 
  signal b_dup0_7_DXMUX_61 : STD_LOGIC; 
  signal b_dup0_7_FXMUX_62 : STD_LOGIC; 
  signal b_dup0_7_DYMUX_63 : STD_LOGIC; 
  signal b_dup0_7_GYMUX_64 : STD_LOGIC; 
  signal b_dup0_7_SRINV_65 : STD_LOGIC; 
  signal b_dup0_7_CLKINV_66 : STD_LOGIC; 
  signal b_dup0_7_CEINV_67 : STD_LOGIC; 
  signal control_i_nx2739z1 : STD_LOGIC; 
  signal cflag_dup0_DYMUX_68 : STD_LOGIC; 
  signal cflag_dup0_GYMUX_69 : STD_LOGIC; 
  signal carry_alu_reg_pack_1 : STD_LOGIC; 
  signal cflag_dup0_SRINV_70 : STD_LOGIC; 
  signal cflag_dup0_CLKINV_71 : STD_LOGIC; 
  signal cflag_dup0_CEINV_72 : STD_LOGIC; 
  signal control_int_fsm_23_DXMUX_73 : STD_LOGIC; 
  signal control_i_nx30705z1 : STD_LOGIC; 
  signal control_int_fsm_23_DYMUX_74 : STD_LOGIC; 
  signal control_i_nx28711z1 : STD_LOGIC; 
  signal control_int_fsm_23_SRINV_75 : STD_LOGIC; 
  signal control_int_fsm_23_CLKINV_76 : STD_LOGIC; 
  signal control_int_fsm_25_DXMUX_77 : STD_LOGIC; 
  signal control_i_nx32699z1 : STD_LOGIC; 
  signal control_int_fsm_25_DYMUX_78 : STD_LOGIC; 
  signal control_i_nx31702z1 : STD_LOGIC; 
  signal control_int_fsm_25_SRINV_79 : STD_LOGIC; 
  signal control_int_fsm_25_CLKINV_80 : STD_LOGIC; 
  signal control_int_fsm_0_DYMUX_81 : STD_LOGIC; 
  signal control_i_nx42068z1 : STD_LOGIC; 
  signal control_int_fsm_0_SRINV_82 : STD_LOGIC; 
  signal control_int_fsm_0_CLKINV_83 : STD_LOGIC; 
  signal control_int_fsm_3_DXMUX_84 : STD_LOGIC; 
  signal control_i_nx45059z1 : STD_LOGIC; 
  signal control_int_fsm_3_DYMUX_85 : STD_LOGIC; 
  signal control_i_nx44062z1 : STD_LOGIC; 
  signal control_int_fsm_3_SRINV_86 : STD_LOGIC; 
  signal control_int_fsm_3_CLKINV_87 : STD_LOGIC; 
  signal control_int_fsm_5_DXMUX_88 : STD_LOGIC; 
  signal control_i_nx47053z1 : STD_LOGIC; 
  signal control_int_fsm_5_DYMUX_89 : STD_LOGIC; 
  signal control_i_nx46056z1 : STD_LOGIC; 
  signal control_int_fsm_5_SRINV_90 : STD_LOGIC; 
  signal control_int_fsm_5_CLKINV_91 : STD_LOGIC; 
  signal control_int_fsm_7_DXMUX_92 : STD_LOGIC; 
  signal control_i_nx49047z1 : STD_LOGIC; 
  signal control_int_fsm_7_DYMUX_93 : STD_LOGIC; 
  signal control_i_nx48050z1 : STD_LOGIC; 
  signal control_int_fsm_7_SRINV_94 : STD_LOGIC; 
  signal control_int_fsm_7_CLKINV_95 : STD_LOGIC; 
  signal control_int_fsm_20_DXMUX_96 : STD_LOGIC; 
  signal control_i_nx27714z1 : STD_LOGIC; 
  signal control_i_nx27714z6_pack_1 : STD_LOGIC; 
  signal control_int_fsm_20_SRINV_97 : STD_LOGIC; 
  signal control_int_fsm_20_CLKINV_98 : STD_LOGIC; 
  signal alu_i_nx14381z3 : STD_LOGIC; 
  signal alu_i_nx20363z15 : STD_LOGIC; 
  signal alu_i_nx20363z3 : STD_LOGIC; 
  signal alu_i_nx20363z4_pack_1 : STD_LOGIC; 
  signal alu_i_nx17372z4 : STD_LOGIC; 
  signal alu_i_nx17372z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx20363z5 : STD_LOGIC; 
  signal alu_i_nx20363z6_pack_1 : STD_LOGIC; 
  signal alu_i_nx20363z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx17372z2 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_4_pack_1 : STD_LOGIC; 
  signal alu_i_nx13384z6 : STD_LOGIC; 
  signal alu_i_nx19366z9 : STD_LOGIC; 
  signal alu_i_nx49743z17 : STD_LOGIC; 
  signal alu_i_nx49743z20 : STD_LOGIC; 
  signal control_i_nx44062z2 : STD_LOGIC; 
  signal alu_i_nx20363z1 : STD_LOGIC; 
  signal alu_i_nx20363z37 : STD_LOGIC; 
  signal alu_i_nx49743z40 : STD_LOGIC; 
  signal alu_i_nx49743z18 : STD_LOGIC; 
  signal alu_i_nx20363z2_pack_1 : STD_LOGIC; 
  signal datmem_nrd_dup0 : STD_LOGIC; 
  signal nx17594z1 : STD_LOGIC; 
  signal alu_i_nx14381z1 : STD_LOGIC; 
  signal alu_i_nx16375z2 : STD_LOGIC; 
  signal alu_i_nx13384z5 : STD_LOGIC; 
  signal alu_i_nx13384z8_pack_1 : STD_LOGIC; 
  signal control_i_nx32699z2 : STD_LOGIC; 
  signal control_i_nx49047z2 : STD_LOGIC; 
  signal control_int_fsm_19_DXMUX_99 : STD_LOGIC; 
  signal control_i_nx25718z1 : STD_LOGIC; 
  signal control_i_nx25718z2_pack_1 : STD_LOGIC; 
  signal control_int_fsm_19_SRINV_100 : STD_LOGIC; 
  signal control_int_fsm_19_CLKINV_101 : STD_LOGIC; 
  signal alu_i_nx49743z19 : STD_LOGIC; 
  signal control_i_nx51041z4 : STD_LOGIC; 
  signal alu_i_nx49743z35 : STD_LOGIC; 
  signal alu_i_nx49743z37_pack_1 : STD_LOGIC; 
  signal alu_i_nx20363z9 : STD_LOGIC; 
  signal alu_i_nx20363z10_pack_1 : STD_LOGIC; 
  signal alu_i_nx18369z6 : STD_LOGIC; 
  signal control_i_nx48050z2 : STD_LOGIC; 
  signal control_i_nx42068z2 : STD_LOGIC; 
  signal alu_i_nx18369z4 : STD_LOGIC; 
  signal alu_i_nx18369z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx14381z6 : STD_LOGIC; 
  signal alu_i_nx13384z7 : STD_LOGIC; 
  signal alu_i_nx18369z2 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_5_pack_1 : STD_LOGIC; 
  signal alu_i_nx15378z1 : STD_LOGIC; 
  signal alu_i_nx13384z1 : STD_LOGIC; 
  signal control_i_nx47053z2 : STD_LOGIC; 
  signal control_i_nx25718z3 : STD_LOGIC; 
  signal alu_i_nx15378z3 : STD_LOGIC; 
  signal alu_i_nx18369z3 : STD_LOGIC; 
  signal alu_i_nx18369z1 : STD_LOGIC; 
  signal alu_i_nx17372z1 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_DXMUX_102 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_FXMUX_103 : STD_LOGIC; 
  signal result_alu_reg_3_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_SRINV_104 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_CLKINV_105 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_CEINV_106 : STD_LOGIC; 
  signal alu_i_nx20363z11 : STD_LOGIC; 
  signal datmem_nwr_dup0 : STD_LOGIC; 
  signal control_i_nx46056z2 : STD_LOGIC; 
  signal control_i_nx45059z2 : STD_LOGIC; 
  signal alu_i_nx16375z4 : STD_LOGIC; 
  signal alu_i_nx16375z5_pack_1 : STD_LOGIC; 
  signal alu_i_nx14381z2 : STD_LOGIC; 
  signal alu_i_nx13384z3 : STD_LOGIC; 
  signal alu_i_nx16375z3 : STD_LOGIC; 
  signal alu_i_nx19366z4 : STD_LOGIC; 
  signal control_i_nx42068z3 : STD_LOGIC; 
  signal control_i_nx50044z2 : STD_LOGIC; 
  signal control_int_fsm_22_DXMUX_107 : STD_LOGIC; 
  signal control_i_nx29708z1 : STD_LOGIC; 
  signal control_i_nx28711z2_pack_1 : STD_LOGIC; 
  signal control_int_fsm_22_SRINV_108 : STD_LOGIC; 
  signal control_int_fsm_22_CLKINV_109 : STD_LOGIC; 
  signal alu_i_nx19366z2 : STD_LOGIC; 
  signal alu_i_nx19366z8_pack_1 : STD_LOGIC; 
  signal nx62171z14 : STD_LOGIC; 
  signal control_i_nx28711z3 : STD_LOGIC; 
  signal control_int_fsm_1_DXMUX_110 : STD_LOGIC; 
  signal control_int_fsm_1_FXMUX_111 : STD_LOGIC; 
  signal control_i_nx2739z2_pack_1 : STD_LOGIC; 
  signal control_int_fsm_1_SRINV_112 : STD_LOGIC; 
  signal control_int_fsm_1_CLKINV_113 : STD_LOGIC; 
  signal nx62171z8 : STD_LOGIC; 
  signal nx62171z9 : STD_LOGIC; 
  signal nx62171z11 : STD_LOGIC; 
  signal nx62171z10 : STD_LOGIC; 
  signal nx62171z13 : STD_LOGIC; 
  signal nx62171z12 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_DXMUX_114 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_FXMUX_115 : STD_LOGIC; 
  signal result_alu_reg_1_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_SRINV_116 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_CLKINV_117 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_CEINV_118 : STD_LOGIC; 
  signal alu_i_nx19366z3 : STD_LOGIC; 
  signal alu_i_nx19366z1 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_DXMUX_119 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_FXMUX_120 : STD_LOGIC; 
  signal result_alu_reg_6_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_SRINV_121 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_CLKINV_122 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_CEINV_123 : STD_LOGIC; 
  signal ram_control_i_n_clk_DYMUX_124 : STD_LOGIC; 
  signal ram_control_i_n_clk_SRINV_125 : STD_LOGIC; 
  signal ram_control_i_n_clk_CLKINVNOT : STD_LOGIC; 
  signal control_i_nx32699z3 : STD_LOGIC; 
  signal control_i_nx32699z4_pack_1 : STD_LOGIC; 
  signal control_int_fsm_11_DXMUX_126 : STD_LOGIC; 
  signal control_int_fsm_11_DYMUX_127 : STD_LOGIC; 
  signal control_int_fsm_11_SRINV_128 : STD_LOGIC; 
  signal control_int_fsm_11_CLKINV_129 : STD_LOGIC; 
  signal alu_i_nx19366z5 : STD_LOGIC; 
  signal alu_i_nx19366z6_pack_1 : STD_LOGIC; 
  signal nx53939z1 : STD_LOGIC; 
  signal pc_i_rtlc3_PS4_n64_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z1 : STD_LOGIC; 
  signal alu_i_nx49743z2_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z39 : STD_LOGIC; 
  signal alu_i_nx15378z6 : STD_LOGIC; 
  signal alu_i_nx49743z36 : STD_LOGIC; 
  signal control_int_fsm_13_DXMUX_130 : STD_LOGIC; 
  signal control_int_fsm_13_DYMUX_131 : STD_LOGIC; 
  signal control_int_fsm_13_SRINV_132 : STD_LOGIC; 
  signal control_int_fsm_13_CLKINV_133 : STD_LOGIC; 
  signal alu_i_nx16375z8 : STD_LOGIC; 
  signal alu_i_nx49743z26 : STD_LOGIC; 
  signal alu_i_nx17372z3 : STD_LOGIC; 
  signal alu_i_nx49743z13 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_DXMUX_134 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_FXMUX_135 : STD_LOGIC; 
  signal result_alu_reg_2_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_SRINV_136 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_CLKINV_137 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_CEINV_138 : STD_LOGIC; 
  signal alu_i_nx49743z14 : STD_LOGIC; 
  signal control_int_fsm_15_DXMUX_139 : STD_LOGIC; 
  signal control_int_fsm_15_DYMUX_140 : STD_LOGIC; 
  signal control_int_fsm_15_SRINV_141 : STD_LOGIC; 
  signal control_int_fsm_15_CLKINV_142 : STD_LOGIC; 
  signal flagz_alu_control : STD_LOGIC; 
  signal alu_i_nx49743z22_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z28 : STD_LOGIC; 
  signal alu_i_nx49743z29_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z30 : STD_LOGIC; 
  signal alu_i_nx49743z31_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z25 : STD_LOGIC; 
  signal control_int_fsm_17_DXMUX_143 : STD_LOGIC; 
  signal control_int_fsm_17_DYMUX_144 : STD_LOGIC; 
  signal control_int_fsm_17_SRINV_145 : STD_LOGIC; 
  signal control_int_fsm_17_CLKINV_146 : STD_LOGIC; 
  signal alu_i_nx14381z4 : STD_LOGIC; 
  signal alu_i_nx14381z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z45 : STD_LOGIC; 
  signal alu_i_nx49743z46_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z33 : STD_LOGIC; 
  signal alu_i_nx49743z34_pack_1 : STD_LOGIC; 
  signal alu_i_nx49743z42 : STD_LOGIC; 
  signal alu_i_nx49743z43_pack_1 : STD_LOGIC; 
  signal alu_i_nx16375z1 : STD_LOGIC; 
  signal alu_i_nx16375z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx20363z14 : STD_LOGIC; 
  signal control_i_nx27714z3 : STD_LOGIC; 
  signal alu_i_nx13384z2_XORF_147 : STD_LOGIC; 
  signal alu_i_nx13384z2_CYINIT_148 : STD_LOGIC; 
  signal alu_i_nx13384z2_CY0F_149 : STD_LOGIC; 
  signal alu_i_nx13384z2_CYSELF_150 : STD_LOGIC; 
  signal alu_i_nx20363z28 : STD_LOGIC; 
  signal alu_i_nx13384z2_XORG_151 : STD_LOGIC; 
  signal alu_i_nx13384z2_CYMUXG_152 : STD_LOGIC; 
  signal alu_i_ix20363z63368_O : STD_LOGIC; 
  signal alu_i_nx13384z2_CY0G_153 : STD_LOGIC; 
  signal alu_i_nx13384z2_CYSELG_154 : STD_LOGIC; 
  signal alu_i_nx20363z29 : STD_LOGIC; 
  signal alu_i_nx15378z5_XORF_155 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYINIT_156 : STD_LOGIC; 
  signal alu_i_nx15378z5_CY0F_157 : STD_LOGIC; 
  signal alu_i_nx20363z30 : STD_LOGIC; 
  signal alu_i_nx15378z5_XORG_158 : STD_LOGIC; 
  signal alu_i_ix20363z63366_O : STD_LOGIC; 
  signal alu_i_nx15378z5_CYSELF_159 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYMUXFAST_160 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYAND_161 : STD_LOGIC; 
  signal alu_i_nx15378z5_FASTCARRY_162 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYMUXG2_163 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYMUXF2_164 : STD_LOGIC; 
  signal alu_i_nx15378z5_CY0G_165 : STD_LOGIC; 
  signal alu_i_nx15378z5_CYSELG_166 : STD_LOGIC; 
  signal alu_i_nx20363z31 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_DXMUX_167 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_FXMUX_168 : STD_LOGIC; 
  signal result_alu_reg_4_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_SRINV_169 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_CLKINV_170 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_CEINV_171 : STD_LOGIC; 
  signal alu_i_nx17372z5_XORF_172 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYINIT_173 : STD_LOGIC; 
  signal alu_i_nx17372z5_CY0F_174 : STD_LOGIC; 
  signal alu_i_nx20363z32 : STD_LOGIC; 
  signal alu_i_nx17372z5_XORG_175 : STD_LOGIC; 
  signal alu_i_ix20363z63364_O : STD_LOGIC; 
  signal alu_i_nx17372z5_CYSELF_176 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYMUXFAST_177 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYAND_178 : STD_LOGIC; 
  signal alu_i_nx17372z5_FASTCARRY_179 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYMUXG2_180 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYMUXF2_181 : STD_LOGIC; 
  signal alu_i_nx17372z5_CY0G_182 : STD_LOGIC; 
  signal alu_i_nx17372z5_CYSELG_183 : STD_LOGIC; 
  signal alu_i_nx20363z33 : STD_LOGIC; 
  signal alu_i_nx15378z4 : STD_LOGIC; 
  signal alu_i_nx15378z7_pack_1 : STD_LOGIC; 
  signal alu_i_nx19366z7_XORF_184 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYINIT_185 : STD_LOGIC; 
  signal alu_i_nx19366z7_CY0F_186 : STD_LOGIC; 
  signal alu_i_nx20363z34 : STD_LOGIC; 
  signal alu_i_nx19366z7_XORG_187 : STD_LOGIC; 
  signal alu_i_ix20363z63362_O : STD_LOGIC; 
  signal alu_i_nx19366z7_CYSELF_188 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYMUXFAST_189 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYAND_190 : STD_LOGIC; 
  signal alu_i_nx19366z7_FASTCARRY_191 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYMUXG2_192 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYMUXF2_193 : STD_LOGIC; 
  signal alu_i_nx19366z7_CY0G_194 : STD_LOGIC; 
  signal alu_i_nx19366z7_CYSELG_195 : STD_LOGIC; 
  signal alu_i_nx20363z35 : STD_LOGIC; 
  signal alu_i_nx49743z15 : STD_LOGIC; 
  signal alu_i_nx49743z16_pack_1 : STD_LOGIC; 
  signal prog_adr_dup0_0_DXMUX_196 : STD_LOGIC; 
  signal prog_adr_dup0_0_FXMUX_197 : STD_LOGIC; 
  signal prog_adr_dup0_0_XORF_198 : STD_LOGIC; 
  signal prog_adr_dup0_0_CYINIT_199 : STD_LOGIC; 
  signal prog_adr_dup0_0_CY0F_200 : STD_LOGIC; 
  signal prog_adr_dup0_0_CYSELF_201 : STD_LOGIC; 
  signal prog_adr_dup0_0_F : STD_LOGIC; 
  signal prog_adr_dup0_0_DYMUX_202 : STD_LOGIC; 
  signal prog_adr_dup0_0_GYMUX_203 : STD_LOGIC; 
  signal prog_adr_dup0_0_XORG_204 : STD_LOGIC; 
  signal prog_adr_dup0_0_CYMUXG_205 : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63347_O : STD_LOGIC; 
  signal prog_adr_dup0_0_CY0G_206 : STD_LOGIC; 
  signal prog_adr_dup0_0_CYSELG_207 : STD_LOGIC; 
  signal nx52942z1 : STD_LOGIC; 
  signal prog_adr_dup0_0_SRINV_208 : STD_LOGIC; 
  signal prog_adr_dup0_0_CLKINV_209 : STD_LOGIC; 
  signal prog_adr_dup0_2_DXMUX_210 : STD_LOGIC; 
  signal prog_adr_dup0_2_FXMUX_211 : STD_LOGIC; 
  signal prog_adr_dup0_2_XORF_212 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYINIT_213 : STD_LOGIC; 
  signal prog_adr_dup0_2_CY0F_214 : STD_LOGIC; 
  signal prog_adr_dup0_2_F : STD_LOGIC; 
  signal prog_adr_dup0_2_DYMUX_215 : STD_LOGIC; 
  signal prog_adr_dup0_2_GYMUX_216 : STD_LOGIC; 
  signal prog_adr_dup0_2_XORG_217 : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63345_O : STD_LOGIC; 
  signal prog_adr_dup0_2_CYSELF_218 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYMUXFAST_219 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYAND_220 : STD_LOGIC; 
  signal prog_adr_dup0_2_FASTCARRY_221 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYMUXG2_222 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYMUXF2_223 : STD_LOGIC; 
  signal prog_adr_dup0_2_CY0G_224 : STD_LOGIC; 
  signal prog_adr_dup0_2_CYSELG_225 : STD_LOGIC; 
  signal prog_adr_dup0_2_G : STD_LOGIC; 
  signal prog_adr_dup0_2_SRINV_226 : STD_LOGIC; 
  signal prog_adr_dup0_2_CLKINV_227 : STD_LOGIC; 
  signal prog_adr_dup0_4_DXMUX_228 : STD_LOGIC; 
  signal prog_adr_dup0_4_FXMUX_229 : STD_LOGIC; 
  signal prog_adr_dup0_4_XORF_230 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYINIT_231 : STD_LOGIC; 
  signal prog_adr_dup0_4_CY0F_232 : STD_LOGIC; 
  signal prog_adr_dup0_4_F : STD_LOGIC; 
  signal prog_adr_dup0_4_DYMUX_233 : STD_LOGIC; 
  signal prog_adr_dup0_4_GYMUX_234 : STD_LOGIC; 
  signal prog_adr_dup0_4_XORG_235 : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63343_O : STD_LOGIC; 
  signal prog_adr_dup0_4_CYSELF_236 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYMUXFAST_237 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYAND_238 : STD_LOGIC; 
  signal prog_adr_dup0_4_FASTCARRY_239 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYMUXG2_240 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYMUXF2_241 : STD_LOGIC; 
  signal prog_adr_dup0_4_CY0G_242 : STD_LOGIC; 
  signal prog_adr_dup0_4_CYSELG_243 : STD_LOGIC; 
  signal prog_adr_dup0_4_G : STD_LOGIC; 
  signal prog_adr_dup0_4_SRINV_244 : STD_LOGIC; 
  signal prog_adr_dup0_4_CLKINV_245 : STD_LOGIC; 
  signal alu_i_nx15378z2 : STD_LOGIC; 
  signal alu_i_result_int_0n8ss1_2_pack_1 : STD_LOGIC; 
  signal prog_adr_dup0_6_DXMUX_246 : STD_LOGIC; 
  signal prog_adr_dup0_6_FXMUX_247 : STD_LOGIC; 
  signal prog_adr_dup0_6_XORF_248 : STD_LOGIC; 
  signal prog_adr_dup0_6_CYINIT_249 : STD_LOGIC; 
  signal prog_adr_dup0_6_CY0F_250 : STD_LOGIC; 
  signal prog_adr_dup0_6_CYSELF_251 : STD_LOGIC; 
  signal prog_adr_dup0_6_F : STD_LOGIC; 
  signal prog_adr_dup0_6_DYMUX_252 : STD_LOGIC; 
  signal prog_adr_dup0_6_GYMUX_253 : STD_LOGIC; 
  signal prog_adr_dup0_6_XORG_254 : STD_LOGIC; 
  signal pc_i_ix5_modgen_add_0_ix62171z63341_O : STD_LOGIC; 
  signal nx62171z15 : STD_LOGIC; 
  signal prog_adr_dup0_6_SRINV_255 : STD_LOGIC; 
  signal prog_adr_dup0_6_CLKINV_256 : STD_LOGIC; 
  signal control_i_nx27714z2 : STD_LOGIC; 
  signal control_i_nx27714z4_pack_1 : STD_LOGIC; 
  signal alu_i_ix49743z63350_O_CYINIT_257 : STD_LOGIC; 
  signal alu_i_ix49743z63350_O_CYSELF_258 : STD_LOGIC; 
  signal alu_i_ix49743z1581_O : STD_LOGIC; 
  signal alu_i_ix49743z63350_O_CYMUXG_259 : STD_LOGIC; 
  signal alu_i_ix49743z63351_O : STD_LOGIC; 
  signal alu_i_ix49743z63350_O_LOGIC_ONE_260 : STD_LOGIC; 
  signal alu_i_ix49743z63350_O_CYSELG_261 : STD_LOGIC; 
  signal alu_i_ix49743z1360_O : STD_LOGIC; 
  signal alu_i_ix49743z1595_O : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYSELF_262 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYMUXFAST_263 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYAND_264 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_FASTCARRY_265 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYMUXG2_266 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYMUXF2_267 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_LOGIC_ONE_268 : STD_LOGIC; 
  signal alu_i_ix49743z63348_O_CYSELG_269 : STD_LOGIC; 
  signal alu_i_ix49743z1342_O : STD_LOGIC; 
  signal datmem_data_out_dup0_7_DXMUX_270 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_FXMUX_271 : STD_LOGIC; 
  signal result_alu_reg_7_pack_1 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_SRINV_272 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_CLKINV_273 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_CEINV_274 : STD_LOGIC; 
  signal alu_i_ix49743z1340_O : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYSELF_275 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYMUXFAST_276 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYAND_277 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_FASTCARRY_278 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYMUXG2_279 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYMUXF2_280 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_LOGIC_ONE_281 : STD_LOGIC; 
  signal alu_i_ix49743z63346_O_CYSELG_282 : STD_LOGIC; 
  signal alu_i_ix49743z1394_O : STD_LOGIC; 
  signal zflag_dup0_LOGIC_ONE_283 : STD_LOGIC; 
  signal zflag_dup0_CYINIT_284 : STD_LOGIC; 
  signal zflag_dup0_CYSELF_285 : STD_LOGIC; 
  signal alu_i_ix49743z4435_O : STD_LOGIC; 
  signal zflag_dup0_DYMUX_286 : STD_LOGIC; 
  signal zflag_dup0_GYMUX_287 : STD_LOGIC; 
  signal zero_alu_reg : STD_LOGIC; 
  signal zflag_dup0_SRINV_288 : STD_LOGIC; 
  signal zflag_dup0_CLKINV_289 : STD_LOGIC; 
  signal zflag_dup0_CEINV_290 : STD_LOGIC; 
  signal control_int_fsm_9_DXMUX_291 : STD_LOGIC; 
  signal control_i_nx51041z1 : STD_LOGIC; 
  signal control_i_nx51041z2_pack_1 : STD_LOGIC; 
  signal control_int_fsm_9_SRINV_292 : STD_LOGIC; 
  signal control_int_fsm_9_CLKINV_293 : STD_LOGIC; 
  signal control_i_nxt_state_2n8ss1_0_F5MUX_294 : STD_LOGIC; 
  signal control_i_nxt_state_2n8ss1_0_F : STD_LOGIC; 
  signal control_i_nxt_state_2n8ss1_0_BXINV_295 : STD_LOGIC; 
  signal control_i_nxt_state_2n8ss1_0_F6MUX_296 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_l3_2 : STD_LOGIC; 
  signal control_i_nxt_state_2n8ss1_0_BYINV_297 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_f6_0_F5MUX_298 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_l3_1 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_f6_0_BXINV_299 : STD_LOGIC; 
  signal control_i_nxt_state_mux_2i1_nx_mx8_l3_0 : STD_LOGIC; 
  signal control_i_nx51041z3 : STD_LOGIC; 
  signal prog_adr_0_O : STD_LOGIC; 
  signal prog_adr_0_OUTPUT_OTCLK1INV_300 : STD_LOGIC; 
  signal nx38625z1 : STD_LOGIC; 
  signal prog_adr_1_O : STD_LOGIC; 
  signal prog_adr_1_OUTPUT_OTCLK1INV_301 : STD_LOGIC; 
  signal ram_control_i_p_clk_DYMUX_302 : STD_LOGIC; 
  signal ram_control_i_p_clk_CLKINV_303 : STD_LOGIC; 
  signal prog_adr_2_O : STD_LOGIC; 
  signal prog_adr_2_OUTPUT_OTCLK1INV_304 : STD_LOGIC; 
  signal prog_adr_3_O : STD_LOGIC; 
  signal prog_adr_3_OUTPUT_OTCLK1INV_305 : STD_LOGIC; 
  signal alu_i_nx20363z8 : STD_LOGIC; 
  signal alu_i_nx20363z36_pack_1 : STD_LOGIC; 
  signal prog_data_0_INBUF : STD_LOGIC; 
  signal prog_data_0_IFF_ISR_USED_306 : STD_LOGIC; 
  signal prog_data_0_IFF_ICLK1INV_307 : STD_LOGIC; 
  signal prog_data_0_IFF_IFFDMUX_308 : STD_LOGIC; 
  signal clk_INBUF : STD_LOGIC; 
  signal alu_i_nx20363z12 : STD_LOGIC; 
  signal prog_adr_4_O : STD_LOGIC; 
  signal prog_adr_4_OUTPUT_OTCLK1INV_309 : STD_LOGIC; 
  signal alu_i_nx20363z13 : STD_LOGIC; 
  signal prog_data_1_INBUF : STD_LOGIC; 
  signal prog_data_1_IFF_ISR_USED_310 : STD_LOGIC; 
  signal prog_data_1_IFF_ICLK1INV_311 : STD_LOGIC; 
  signal prog_data_1_IFF_IFFDMUX_312 : STD_LOGIC; 
  signal rst_int : STD_LOGIC; 
  signal prog_adr_5_O : STD_LOGIC; 
  signal prog_adr_5_OUTPUT_OTCLK1INV_313 : STD_LOGIC; 
  signal prog_data_2_INBUF : STD_LOGIC; 
  signal control_i_nx27714z5 : STD_LOGIC; 
  signal prog_adr_6_O : STD_LOGIC; 
  signal prog_adr_6_OUTPUT_OTCLK1INV_314 : STD_LOGIC; 
  signal alu_i_nx51436z5 : STD_LOGIC; 
  signal alu_i_nx51436z6_pack_1 : STD_LOGIC; 
  signal prog_data_3_INBUF : STD_LOGIC; 
  signal prog_data_3_IFF_ISR_USED_315 : STD_LOGIC; 
  signal prog_data_3_IFF_ICLK1INV_316 : STD_LOGIC; 
  signal prog_data_3_IFF_IFFDMUX_317 : STD_LOGIC; 
  signal alu_i_nx51436z1 : STD_LOGIC; 
  signal flagc_alu_control_pack_1 : STD_LOGIC; 
  signal prog_adr_7_O : STD_LOGIC; 
  signal prog_adr_7_OUTPUT_OTCLK1INV_318 : STD_LOGIC; 
  signal prog_data_4_INBUF : STD_LOGIC; 
  signal prog_data_4_IFF_ISR_USED_319 : STD_LOGIC; 
  signal prog_data_4_IFF_ICLK1INV_320 : STD_LOGIC; 
  signal prog_data_4_IFF_IFFDMUX_321 : STD_LOGIC; 
  signal alu_i_nx13384z4 : STD_LOGIC; 
  signal alu_i_nx20363z16_pack_1 : STD_LOGIC; 
  signal prog_data_5_INBUF : STD_LOGIC; 
  signal prog_data_5_IFF_ISR_USED_322 : STD_LOGIC; 
  signal prog_data_5_IFF_ICLK1INV_323 : STD_LOGIC; 
  signal prog_data_5_IFF_IFFDMUX_324 : STD_LOGIC; 
  signal prog_data_6_INBUF : STD_LOGIC; 
  signal prog_data_6_IFF_ISR_USED_325 : STD_LOGIC; 
  signal prog_data_6_IFF_ICLK1INV_326 : STD_LOGIC; 
  signal prog_data_6_IFF_IFFDMUX_327 : STD_LOGIC; 
  signal alu_i_nx49743z23 : STD_LOGIC; 
  signal alu_i_nx20363z17_pack_1 : STD_LOGIC; 
  signal prog_data_7_INBUF : STD_LOGIC; 
  signal prog_data_7_IFF_ISR_USED_328 : STD_LOGIC; 
  signal prog_data_7_IFF_ICLK1INV_329 : STD_LOGIC; 
  signal prog_data_7_IFF_IFFDMUX_330 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_ICLK1INV_331 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_ICEINV_332 : STD_LOGIC; 
  signal datmem_data_in_0_IFF_IFFDMUX_333 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_ICLK1INV_334 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_ICEINV_335 : STD_LOGIC; 
  signal datmem_data_in_1_IFF_IFFDMUX_336 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_ICLK1INV_337 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_ICEINV_338 : STD_LOGIC; 
  signal datmem_data_in_2_IFF_IFFDMUX_339 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_ICLK1INV_340 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_ICEINV_341 : STD_LOGIC; 
  signal datmem_data_in_3_IFF_IFFDMUX_342 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_ICLK1INV_343 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_ICEINV_344 : STD_LOGIC; 
  signal datmem_data_in_4_IFF_IFFDMUX_345 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_ICLK1INV_346 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_ICEINV_347 : STD_LOGIC; 
  signal datmem_data_in_5_IFF_IFFDMUX_348 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_ICLK1INV_349 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_ICEINV_350 : STD_LOGIC; 
  signal datmem_data_in_6_IFF_IFFDMUX_351 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_ICLK1INV_352 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_ICEINV_353 : STD_LOGIC; 
  signal datmem_data_in_7_IFF_IFFDMUX_354 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_repl2 : STD_LOGIC; 
  signal datmem_data_out_0_OUTPUT_OFF_OSR_USED_355 : STD_LOGIC; 
  signal datmem_data_out_0_OUTPUT_OFF_OCEINV_356 : STD_LOGIC; 
  signal datmem_data_out_0_OUTPUT_OFF_O1INV_357 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_repl2 : STD_LOGIC; 
  signal datmem_data_out_1_OUTPUT_OFF_OSR_USED_358 : STD_LOGIC; 
  signal datmem_data_out_1_OUTPUT_OFF_OCEINV_359 : STD_LOGIC; 
  signal datmem_data_out_1_OUTPUT_OFF_O1INV_360 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_repl2 : STD_LOGIC; 
  signal datmem_data_out_2_OUTPUT_OFF_OSR_USED_361 : STD_LOGIC; 
  signal datmem_data_out_2_OUTPUT_OFF_OCEINV_362 : STD_LOGIC; 
  signal datmem_data_out_2_OUTPUT_OFF_O1INV_363 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_repl2 : STD_LOGIC; 
  signal datmem_data_out_3_OUTPUT_OFF_OSR_USED_364 : STD_LOGIC; 
  signal datmem_data_out_3_OUTPUT_OFF_OCEINV_365 : STD_LOGIC; 
  signal datmem_data_out_3_OUTPUT_OFF_O1INV_366 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_repl2 : STD_LOGIC; 
  signal datmem_data_out_4_OUTPUT_OFF_OSR_USED_367 : STD_LOGIC; 
  signal datmem_data_out_4_OUTPUT_OFF_OCEINV_368 : STD_LOGIC; 
  signal datmem_data_out_4_OUTPUT_OFF_O1INV_369 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_repl2 : STD_LOGIC; 
  signal datmem_data_out_5_OUTPUT_OFF_OSR_USED_370 : STD_LOGIC; 
  signal datmem_data_out_5_OUTPUT_OFF_OCEINV_371 : STD_LOGIC; 
  signal datmem_data_out_5_OUTPUT_OFF_O1INV_372 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_repl2 : STD_LOGIC; 
  signal datmem_data_out_6_OUTPUT_OFF_OSR_USED_373 : STD_LOGIC; 
  signal datmem_data_out_6_OUTPUT_OFF_OCEINV_374 : STD_LOGIC; 
  signal datmem_data_out_6_OUTPUT_OFF_O1INV_375 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_repl2 : STD_LOGIC; 
  signal datmem_data_out_7_OUTPUT_OFF_OSR_USED_376 : STD_LOGIC; 
  signal datmem_data_out_7_OUTPUT_OFF_OCEINV_377 : STD_LOGIC; 
  signal datmem_data_out_7_OUTPUT_OFF_O1INV_378 : STD_LOGIC; 
  signal datmem_data_out_dup0_0_repl1 : STD_LOGIC; 
  signal a_0_OUTPUT_OFF_OSR_USED_379 : STD_LOGIC; 
  signal a_0_OUTPUT_OFF_OCEINV_380 : STD_LOGIC; 
  signal a_0_OUTPUT_OFF_O1INV_381 : STD_LOGIC; 
  signal zflag_dup0_repl2 : STD_LOGIC; 
  signal zflag_OUTPUT_OFF_OSR_USED_382 : STD_LOGIC; 
  signal zflag_OUTPUT_OFF_OCEINV_383 : STD_LOGIC; 
  signal zflag_OUTPUT_OFF_O1INV_384 : STD_LOGIC; 
  signal datmem_data_out_dup0_1_repl1 : STD_LOGIC; 
  signal a_1_OUTPUT_OFF_OSR_USED_385 : STD_LOGIC; 
  signal a_1_OUTPUT_OFF_OCEINV_386 : STD_LOGIC; 
  signal a_1_OUTPUT_OFF_O1INV_387 : STD_LOGIC; 
  signal datmem_data_out_dup0_2_repl1 : STD_LOGIC; 
  signal a_2_OUTPUT_OFF_OSR_USED_388 : STD_LOGIC; 
  signal a_2_OUTPUT_OFF_OCEINV_389 : STD_LOGIC; 
  signal a_2_OUTPUT_OFF_O1INV_390 : STD_LOGIC; 
  signal datmem_data_out_dup0_3_repl1 : STD_LOGIC; 
  signal a_3_OUTPUT_OFF_OSR_USED_391 : STD_LOGIC; 
  signal a_3_OUTPUT_OFF_OCEINV_392 : STD_LOGIC; 
  signal a_3_OUTPUT_OFF_O1INV_393 : STD_LOGIC; 
  signal datmem_data_out_dup0_4_repl1 : STD_LOGIC; 
  signal a_4_OUTPUT_OFF_OSR_USED_394 : STD_LOGIC; 
  signal a_4_OUTPUT_OFF_OCEINV_395 : STD_LOGIC; 
  signal a_4_OUTPUT_OFF_O1INV_396 : STD_LOGIC; 
  signal b_dup0_0_repl1 : STD_LOGIC; 
  signal b_0_OUTPUT_OFF_OSR_USED_397 : STD_LOGIC; 
  signal b_0_OUTPUT_OFF_OCEINV_398 : STD_LOGIC; 
  signal b_0_OUTPUT_OFF_O1INV_399 : STD_LOGIC; 
  signal datmem_data_out_dup0_5_repl1 : STD_LOGIC; 
  signal a_5_OUTPUT_OFF_OSR_USED_400 : STD_LOGIC; 
  signal a_5_OUTPUT_OFF_OCEINV_401 : STD_LOGIC; 
  signal a_5_OUTPUT_OFF_O1INV_402 : STD_LOGIC; 
  signal b_dup0_1_repl1 : STD_LOGIC; 
  signal b_1_OUTPUT_OFF_OSR_USED_403 : STD_LOGIC; 
  signal b_1_OUTPUT_OFF_OCEINV_404 : STD_LOGIC; 
  signal b_1_OUTPUT_OFF_O1INV_405 : STD_LOGIC; 
  signal datmem_data_out_dup0_6_repl1 : STD_LOGIC; 
  signal a_6_OUTPUT_OFF_OSR_USED_406 : STD_LOGIC; 
  signal a_6_OUTPUT_OFF_OCEINV_407 : STD_LOGIC; 
  signal a_6_OUTPUT_OFF_O1INV_408 : STD_LOGIC; 
  signal b_dup0_2_repl1 : STD_LOGIC; 
  signal b_2_OUTPUT_OFF_OSR_USED_409 : STD_LOGIC; 
  signal b_2_OUTPUT_OFF_OCEINV_410 : STD_LOGIC; 
  signal b_2_OUTPUT_OFF_O1INV_411 : STD_LOGIC; 
  signal datmem_data_out_dup0_7_repl1 : STD_LOGIC; 
  signal a_7_OUTPUT_OFF_OSR_USED_412 : STD_LOGIC; 
  signal a_7_OUTPUT_OFF_OCEINV_413 : STD_LOGIC; 
  signal a_7_OUTPUT_OFF_O1INV_414 : STD_LOGIC; 
  signal b_dup0_3_repl1 : STD_LOGIC; 
  signal b_3_OUTPUT_OFF_OSR_USED_415 : STD_LOGIC; 
  signal b_3_OUTPUT_OFF_OCEINV_416 : STD_LOGIC; 
  signal b_3_OUTPUT_OFF_O1INV_417 : STD_LOGIC; 
  signal b_dup0_4_repl1 : STD_LOGIC; 
  signal b_4_OUTPUT_OFF_OSR_USED_418 : STD_LOGIC; 
  signal b_4_OUTPUT_OFF_OCEINV_419 : STD_LOGIC; 
  signal b_4_OUTPUT_OFF_O1INV_420 : STD_LOGIC; 
  signal b_dup0_5_repl1 : STD_LOGIC; 
  signal b_5_OUTPUT_OFF_OSR_USED_421 : STD_LOGIC; 
  signal b_5_OUTPUT_OFF_OCEINV_422 : STD_LOGIC; 
  signal b_5_OUTPUT_OFF_O1INV_423 : STD_LOGIC; 
  signal b_dup0_6_repl1 : STD_LOGIC; 
  signal b_6_OUTPUT_OFF_OSR_USED_424 : STD_LOGIC; 
  signal b_6_OUTPUT_OFF_OCEINV_425 : STD_LOGIC; 
  signal b_6_OUTPUT_OFF_O1INV_426 : STD_LOGIC; 
  signal b_dup0_7_repl1 : STD_LOGIC; 
  signal b_7_OUTPUT_OFF_OSR_USED_427 : STD_LOGIC; 
  signal b_7_OUTPUT_OFF_OCEINV_428 : STD_LOGIC; 
  signal b_7_OUTPUT_OFF_O1INV_429 : STD_LOGIC; 
  signal cflag_dup0_repl2 : STD_LOGIC; 
  signal cflag_OUTPUT_OFF_OSR_USED_430 : STD_LOGIC; 
  signal cflag_OUTPUT_OFF_OCEINV_431 : STD_LOGIC; 
  signal cflag_OUTPUT_OFF_O1INV_432 : STD_LOGIC; 
  signal prog_adr_dup0_0_repl2 : STD_LOGIC; 
  signal prog_adr_0_OUTPUT_OFF_OSR_USED_433 : STD_LOGIC; 
  signal prog_adr_0_OUTPUT_OFF_O1INV_434 : STD_LOGIC; 
  signal prog_adr_dup0_1_repl2 : STD_LOGIC; 
  signal prog_adr_1_OUTPUT_OFF_OSR_USED_435 : STD_LOGIC; 
  signal prog_adr_1_OUTPUT_OFF_O1INV_436 : STD_LOGIC; 
  signal prog_adr_dup0_2_repl1 : STD_LOGIC; 
  signal prog_adr_2_OUTPUT_OFF_OSR_USED_437 : STD_LOGIC; 
  signal prog_adr_2_OUTPUT_OFF_O1INV_438 : STD_LOGIC; 
  signal prog_adr_dup0_3_repl1 : STD_LOGIC; 
  signal prog_adr_3_OUTPUT_OFF_OSR_USED_439 : STD_LOGIC; 
  signal prog_adr_3_OUTPUT_OFF_O1INV_440 : STD_LOGIC; 
  signal prog_adr_dup0_4_repl1 : STD_LOGIC; 
  signal prog_adr_4_OUTPUT_OFF_OSR_USED_441 : STD_LOGIC; 
  signal prog_adr_4_OUTPUT_OFF_O1INV_442 : STD_LOGIC; 
  signal prog_adr_dup0_5_repl1 : STD_LOGIC; 
  signal prog_adr_5_OUTPUT_OFF_OSR_USED_443 : STD_LOGIC; 
  signal prog_adr_5_OUTPUT_OFF_O1INV_444 : STD_LOGIC; 
  signal prog_data_2_IFF_ISR_USED_445 : STD_LOGIC; 
  signal prog_data_2_IFF_ICLK1INV_446 : STD_LOGIC; 
  signal prog_data_2_IFF_IFFDMUX_447 : STD_LOGIC; 
  signal prog_adr_dup0_6_repl1 : STD_LOGIC; 
  signal prog_adr_6_OUTPUT_OFF_OSR_USED_448 : STD_LOGIC; 
  signal prog_adr_6_OUTPUT_OFF_O1INV_449 : STD_LOGIC; 
  signal prog_adr_dup0_7_repl1 : STD_LOGIC; 
  signal prog_adr_7_OUTPUT_OFF_OSR_USED_450 : STD_LOGIC; 
  signal prog_adr_7_OUTPUT_OFF_O1INV_451 : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal prog_data_int : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal control_int_fsm : STD_LOGIC_VECTOR ( 25 downto 0 ); 
  signal datmem_data_out_dup0 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal b_dup0 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal reg_i_rom_data_intern : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal result_alu_reg : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal ram_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal control_i_nxt_state_2n8ss1 : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal alu_i_result_int_0n8ss1 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal prog_adr_dup0 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal reg_i_a_out_1n1ss1 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal reg_i_b_out_1n1ss1 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal control_nxt_int_fsm : STD_LOGIC_VECTOR ( 1 downto 1 ); 
begin
  control_i_nx28711z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx28711z4,
      O => control_i_nx28711z4_0
    );
  control_i_nx28711z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx24721z2,
      O => control_i_nx24721z2_0
    );
  control_i_ix24721z1329 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X2Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_int(2),
      ADR2 => VCC,
      ADR3 => prog_data_int(3),
      O => control_i_nx24721z2
    );
  datmem_nrd_obuf : X_OBUF
    generic map(
      LOC => "PAD94"
    )
    port map (
      I => datmem_nrd_O,
      O => datmem_nrd
    );
  nx56395z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx56395z1,
      O => nx56395z1_0
    );
  nx56395z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx6954z1,
      O => nx6954z1_0
    );
  ix6954z1568 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X7Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(16),
      ADR2 => control_int_fsm(14),
      ADR3 => flagz_alu_control_0,
      O => nx6954z1
    );
  datmem_data_out_obuf_0_Q : X_OBUF
    generic map(
      LOC => "PAD98"
    )
    port map (
      I => datmem_data_out_0_O,
      O => datmem_data_out(0)
    );
  datmem_data_out_0_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_0_OUTPUT_OTCLK1INV_0
    );
  alu_i_nx51436z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx51436z2,
      O => alu_i_nx51436z2_0
    );
  alu_i_nx51436z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx51436z3_pack_1,
      O => alu_i_nx51436z3
    );
  alu_i_ix51436z1325 : X_LUT4
    generic map(
      INIT => X"55FF",
      LOC => "SLICE_X10Y16"
    )
    port map (
      ADR0 => datmem_data_out_dup0(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => b_dup0(7),
      O => alu_i_nx51436z3_pack_1
    );
  datmem_data_out_obuf_1_Q : X_OBUF
    generic map(
      LOC => "PAD99"
    )
    port map (
      I => datmem_data_out_1_O,
      O => datmem_data_out(1)
    );
  datmem_data_out_1_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_1_OUTPUT_OTCLK1INV_1
    );
  datmem_data_out_dup0_5_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_5_FXMUX_3,
      O => datmem_data_out_dup0_5_DXMUX_2
    );
  datmem_data_out_dup0_5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_5_FXMUX_3,
      O => reg_i_a_out_1n1ss1_5_0
    );
  datmem_data_out_dup0_5_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(5),
      O => datmem_data_out_dup0_5_FXMUX_3
    );
  datmem_data_out_dup0_5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_5_pack_1,
      O => result_alu_reg(5)
    );
  datmem_data_out_dup0_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_5_SRINV_4
    );
  datmem_data_out_dup0_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_5_CLKINV_5
    );
  datmem_data_out_dup0_5_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_5_CEINV_6
    );
  datmem_data_out_obuf_2_Q : X_OBUF
    generic map(
      LOC => "PAD45"
    )
    port map (
      I => datmem_data_out_2_O,
      O => datmem_data_out(2)
    );
  datmem_data_out_2_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_2_OUTPUT_OTCLK1INV_7
    );
  alu_i_nx49743z41_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z41,
      O => alu_i_nx49743z41_0
    );
  alu_i_nx49743z41_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z6,
      O => alu_i_nx17372z6_0
    );
  alu_i_ix17372z53193 : X_LUT4
    generic map(
      INIT => X"E680",
      LOC => "SLICE_X12Y16"
    )
    port map (
      ADR0 => b_dup0(4),
      ADR1 => datmem_data_out_dup0(4),
      ADR2 => control_int_fsm(3),
      ADR3 => control_int_fsm(4),
      O => alu_i_nx17372z6
    );
  datmem_data_out_obuf_3_Q : X_OBUF
    generic map(
      LOC => "PAD44"
    )
    port map (
      I => datmem_data_out_3_O,
      O => datmem_data_out(3)
    );
  datmem_data_out_3_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_3_OUTPUT_OTCLK1INV_8
    );
  alu_i_nx20363z18_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z18,
      O => alu_i_nx20363z18_0
    );
  alu_i_nx20363z18_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z19_pack_1,
      O => alu_i_nx20363z19
    );
  alu_i_ix20363z1348 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X10Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(7),
      ADR2 => VCC,
      ADR3 => b_dup0(7),
      O => alu_i_nx20363z19_pack_1
    );
  datmem_data_out_obuf_4_Q : X_OBUF
    generic map(
      LOC => "PAD43"
    )
    port map (
      I => datmem_data_out_4_O,
      O => datmem_data_out(4)
    );
  datmem_data_out_4_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_4_OUTPUT_OTCLK1INV_9
    );
  datmem_data_out_dup0_0_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_0_FXMUX_11,
      O => datmem_data_out_dup0_0_DXMUX_10
    );
  datmem_data_out_dup0_0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_0_FXMUX_11,
      O => reg_i_a_out_1n1ss1_0_0
    );
  datmem_data_out_dup0_0_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(0),
      O => datmem_data_out_dup0_0_FXMUX_11
    );
  datmem_data_out_dup0_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_0_pack_1,
      O => result_alu_reg(0)
    );
  datmem_data_out_dup0_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_0_SRINV_12
    );
  datmem_data_out_dup0_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_0_CLKINV_13
    );
  datmem_data_out_dup0_0_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X7Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_0_CEINV_14
    );
  datmem_data_out_obuf_5_Q : X_OBUF
    generic map(
      LOC => "PAD42"
    )
    port map (
      I => datmem_data_out_5_O,
      O => datmem_data_out(5)
    );
  datmem_data_out_5_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_5_OUTPUT_OTCLK1INV_15
    );
  datmem_data_out_obuf_6_Q : X_OBUF
    generic map(
      LOC => "PAD41"
    )
    port map (
      I => datmem_data_out_6_O,
      O => datmem_data_out(6)
    );
  datmem_data_out_6_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_6_OUTPUT_OTCLK1INV_16
    );
  datmem_nwr_obuf : X_OBUF
    generic map(
      LOC => "PAD97"
    )
    port map (
      I => datmem_nwr_O,
      O => datmem_nwr
    );
  datmem_data_out_obuf_7_Q : X_OBUF
    generic map(
      LOC => "PAD40"
    )
    port map (
      I => datmem_data_out_7_O,
      O => datmem_data_out(7)
    );
  datmem_data_out_7_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_7_OUTPUT_OTCLK1INV_17
    );
  datmem_data_in_ibuf_0_Q : X_BUF
    generic map(
      LOC => "PAD23",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(0),
      O => datmem_data_in_0_INBUF
    );
  datmem_data_in_ibuf_1_Q : X_BUF
    generic map(
      LOC => "PAD20",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(1),
      O => datmem_data_in_1_INBUF
    );
  datmem_data_in_ibuf_2_Q : X_BUF
    generic map(
      LOC => "PAD113",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(2),
      O => datmem_data_in_2_INBUF
    );
  nreset_ibuf : X_BUF
    generic map(
      LOC => "PAD114",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset,
      O => nreset_INBUF
    );
  nreset_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD114",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_INBUF,
      O => nreset_int_int
    );
  a_obuf_0_Q : X_OBUF
    generic map(
      LOC => "PAD107"
    )
    port map (
      I => a_0_O,
      O => a(0)
    );
  a_0_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_0_OUTPUT_OTCLK1INV_18
    );
  zflag_obuf : X_OBUF
    generic map(
      LOC => "PAD39"
    )
    port map (
      I => zflag_O,
      O => zflag
    );
  zflag_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => zflag_OUTPUT_OTCLK1INV_19
    );
  datmem_data_in_ibuf_3_Q : X_BUF
    generic map(
      LOC => "PAD108",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(3),
      O => datmem_data_in_3_INBUF
    );
  a_obuf_1_Q : X_OBUF
    generic map(
      LOC => "PAD106"
    )
    port map (
      I => a_1_O,
      O => a(1)
    );
  a_1_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_1_OUTPUT_OTCLK1INV_20
    );
  datmem_data_in_ibuf_4_Q : X_BUF
    generic map(
      LOC => "PAD109",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(4),
      O => datmem_data_in_4_INBUF
    );
  a_obuf_2_Q : X_OBUF
    generic map(
      LOC => "PAD105"
    )
    port map (
      I => a_2_O,
      O => a(2)
    );
  a_2_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_2_OUTPUT_OTCLK1INV_21
    );
  datmem_data_in_ibuf_5_Q : X_BUF
    generic map(
      LOC => "PAD110",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(5),
      O => datmem_data_in_5_INBUF
    );
  a_obuf_3_Q : X_OBUF
    generic map(
      LOC => "PAD104"
    )
    port map (
      I => a_3_O,
      O => a(3)
    );
  a_3_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_3_OUTPUT_OTCLK1INV_22
    );
  datmem_data_in_ibuf_6_Q : X_BUF
    generic map(
      LOC => "PAD111",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(6),
      O => datmem_data_in_6_INBUF
    );
  a_obuf_4_Q : X_OBUF
    generic map(
      LOC => "PAD103"
    )
    port map (
      I => a_4_O,
      O => a(4)
    );
  a_4_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_4_OUTPUT_OTCLK1INV_23
    );
  b_obuf_0_Q : X_OBUF
    generic map(
      LOC => "PAD56"
    )
    port map (
      I => b_0_O,
      O => b(0)
    );
  b_0_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_0_OUTPUT_OTCLK1INV_24
    );
  datmem_data_in_ibuf_7_Q : X_BUF
    generic map(
      LOC => "PAD112",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in(7),
      O => datmem_data_in_7_INBUF
    );
  a_obuf_5_Q : X_OBUF
    generic map(
      LOC => "PAD102"
    )
    port map (
      I => a_5_O,
      O => a(5)
    );
  a_5_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_5_OUTPUT_OTCLK1INV_25
    );
  b_obuf_1_Q : X_OBUF
    generic map(
      LOC => "PAD59"
    )
    port map (
      I => b_1_O,
      O => b(1)
    );
  b_1_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_1_OUTPUT_OTCLK1INV_26
    );
  a_obuf_6_Q : X_OBUF
    generic map(
      LOC => "PAD101"
    )
    port map (
      I => a_6_O,
      O => a(6)
    );
  a_6_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_6_OUTPUT_OTCLK1INV_27
    );
  b_obuf_2_Q : X_OBUF
    generic map(
      LOC => "PAD62"
    )
    port map (
      I => b_2_O,
      O => b(2)
    );
  b_2_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_2_OUTPUT_OTCLK1INV_28
    );
  a_obuf_7_Q : X_OBUF
    generic map(
      LOC => "PAD100"
    )
    port map (
      I => a_7_O,
      O => a(7)
    );
  a_7_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => a_7_OUTPUT_OTCLK1INV_29
    );
  b_obuf_3_Q : X_OBUF
    generic map(
      LOC => "PAD61"
    )
    port map (
      I => b_3_O,
      O => b(3)
    );
  b_3_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_3_OUTPUT_OTCLK1INV_30
    );
  b_obuf_4_Q : X_OBUF
    generic map(
      LOC => "PAD54"
    )
    port map (
      I => b_4_O,
      O => b(4)
    );
  b_4_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_4_OUTPUT_OTCLK1INV_31
    );
  b_obuf_5_Q : X_OBUF
    generic map(
      LOC => "PAD55"
    )
    port map (
      I => b_5_O,
      O => b(5)
    );
  b_5_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_5_OUTPUT_OTCLK1INV_32
    );
  b_obuf_6_Q : X_OBUF
    generic map(
      LOC => "PAD57"
    )
    port map (
      I => b_6_O,
      O => b(6)
    );
  b_6_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_6_OUTPUT_OTCLK1INV_33
    );
  nreset_int_ibuf : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_int,
      O => nreset_int_INBUF
    );
  nreset_int_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD77",
      PATHPULSE => 757 ps
    )
    port map (
      I => nreset_int_INBUF,
      O => nreset_int_int_int
    );
  b_obuf_7_Q : X_OBUF
    generic map(
      LOC => "PAD58"
    )
    port map (
      I => b_7_O,
      O => b(7)
    );
  b_7_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_7_OUTPUT_OTCLK1INV_34
    );
  datmem_adr_obuf_0_Q : X_OBUF
    generic map(
      LOC => "PAD35"
    )
    port map (
      I => datmem_adr_0_O,
      O => datmem_adr(0)
    );
  datmem_adr_obuf_1_Q : X_OBUF
    generic map(
      LOC => "PAD36"
    )
    port map (
      I => datmem_adr_1_O,
      O => datmem_adr(1)
    );
  datmem_adr_obuf_2_Q : X_OBUF
    generic map(
      LOC => "PAD37"
    )
    port map (
      I => datmem_adr_2_O,
      O => datmem_adr(2)
    );
  datmem_adr_obuf_3_Q : X_OBUF
    generic map(
      LOC => "PAD32"
    )
    port map (
      I => datmem_adr_3_O,
      O => datmem_adr(3)
    );
  datmem_adr_obuf_4_Q : X_OBUF
    generic map(
      LOC => "PAD31"
    )
    port map (
      I => datmem_adr_4_O,
      O => datmem_adr(4)
    );
  datmem_adr_obuf_5_Q : X_OBUF
    generic map(
      LOC => "PAD24"
    )
    port map (
      I => datmem_adr_5_O,
      O => datmem_adr(5)
    );
  datmem_adr_obuf_6_Q : X_OBUF
    generic map(
      LOC => "PAD30"
    )
    port map (
      I => datmem_adr_6_O,
      O => datmem_adr(6)
    );
  cflag_obuf : X_OBUF
    generic map(
      LOC => "PAD93"
    )
    port map (
      I => cflag_O,
      O => cflag
    );
  cflag_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => cflag_OUTPUT_OTCLK1INV_35
    );
  datmem_adr_obuf_7_Q : X_OBUF
    generic map(
      LOC => "PAD29"
    )
    port map (
      I => datmem_adr_7_O,
      O => datmem_adr(7)
    );
  clk_ibuf_BUFG : X_BUFGMUX
    generic map(
      LOC => "BUFGMUX6"
    )
    port map (
      I0 => clk_ibuf_BUFG_I0_INV,
      I1 => GND,
      S => clk_ibuf_BUFG_S_INVNOT,
      O => clk_int
    );
  clk_ibuf_BUFG_SINV : X_INV
    generic map(
      LOC => "BUFGMUX6",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC1,
      O => clk_ibuf_BUFG_S_INVNOT
    );
  clk_ibuf_BUFG_I0_USED : X_BUF
    generic map(
      LOC => "BUFGMUX6",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_INBUF,
      O => clk_ibuf_BUFG_I0_INV
    );
  control_int_fsm_18_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx24721z1,
      O => control_int_fsm_18_DXMUX_36
    );
  control_int_fsm_18_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx50044z1,
      O => control_int_fsm_18_DYMUX_37
    );
  control_int_fsm_18_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_18_SRINV_38
    );
  control_int_fsm_18_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_18_CLKINV_39
    );
  control_i_ix50044z1315 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X5Y23"
    )
    port map (
      ADR0 => control_i_nx50044z2_0,
      ADR1 => control_i_nx51041z2,
      ADR2 => control_i_nx24721z2_0,
      ADR3 => control_i_nx51041z4_0,
      O => control_i_nx50044z1
    );
  b_dup0_1_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_1_FXMUX_41,
      O => b_dup0_1_DXMUX_40
    );
  b_dup0_1_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(1),
      O => b_dup0_1_FXMUX_41
    );
  b_dup0_1_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_1_GYMUX_43,
      O => b_dup0_1_DYMUX_42
    );
  b_dup0_1_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(0),
      O => b_dup0_1_GYMUX_43
    );
  b_dup0_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_dup0_1_SRINV_44
    );
  b_dup0_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_dup0_1_CLKINV_45
    );
  b_dup0_1_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_dup0_1_CEINV_46
    );
  b_dup0_3_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_3_FXMUX_48,
      O => b_dup0_3_DXMUX_47
    );
  b_dup0_3_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(3),
      O => b_dup0_3_FXMUX_48
    );
  b_dup0_3_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_3_GYMUX_50,
      O => b_dup0_3_DYMUX_49
    );
  b_dup0_3_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(2),
      O => b_dup0_3_GYMUX_50
    );
  b_dup0_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_dup0_3_SRINV_51
    );
  b_dup0_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_dup0_3_CLKINV_52
    );
  b_dup0_3_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_dup0_3_CEINV_53
    );
  b_dup0_5_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_5_FXMUX_55,
      O => b_dup0_5_DXMUX_54
    );
  b_dup0_5_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(5),
      O => b_dup0_5_FXMUX_55
    );
  b_dup0_5_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_5_GYMUX_57,
      O => b_dup0_5_DYMUX_56
    );
  b_dup0_5_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(4),
      O => b_dup0_5_GYMUX_57
    );
  b_dup0_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_dup0_5_SRINV_58
    );
  b_dup0_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_dup0_5_CLKINV_59
    );
  b_dup0_5_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_dup0_5_CEINV_60
    );
  b_dup0_7_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_7_FXMUX_62,
      O => b_dup0_7_DXMUX_61
    );
  b_dup0_7_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(7),
      O => b_dup0_7_FXMUX_62
    );
  b_dup0_7_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_7_GYMUX_64,
      O => b_dup0_7_DYMUX_63
    );
  b_dup0_7_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_b_out_1n1ss1(6),
      O => b_dup0_7_GYMUX_64
    );
  b_dup0_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_dup0_7_SRINV_65
    );
  b_dup0_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => b_dup0_7_CLKINV_66
    );
  b_dup0_7_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_dup0_7_CEINV_67
    );
  cflag_dup0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx2739z1,
      O => control_i_nx2739z1_0
    );
  cflag_dup0_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => cflag_dup0_GYMUX_69,
      O => cflag_dup0_DYMUX_68
    );
  cflag_dup0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => cflag_dup0_GYMUX_69,
      O => carry_alu_reg
    );
  cflag_dup0_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => carry_alu_reg_pack_1,
      O => cflag_dup0_GYMUX_69
    );
  cflag_dup0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => cflag_dup0_SRINV_70
    );
  cflag_dup0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => cflag_dup0_CLKINV_71
    );
  cflag_dup0_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx6954z1_0,
      O => cflag_dup0_CEINV_72
    );
  control_int_fsm_23_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx30705z1,
      O => control_int_fsm_23_DXMUX_73
    );
  control_int_fsm_23_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx28711z1,
      O => control_int_fsm_23_DYMUX_74
    );
  control_int_fsm_23_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_23_SRINV_75
    );
  control_int_fsm_23_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_23_CLKINV_76
    );
  control_i_ix28711z1315 : X_LUT4
    generic map(
      INIT => X"0003",
      LOC => "SLICE_X2Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_i_nx28711z2,
      ADR2 => prog_data_int(1),
      ADR3 => control_i_nx28711z4_0,
      O => control_i_nx28711z1
    );
  control_int_fsm_25_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx32699z1,
      O => control_int_fsm_25_DXMUX_77
    );
  control_int_fsm_25_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx31702z1,
      O => control_int_fsm_25_DYMUX_78
    );
  control_int_fsm_25_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_25_SRINV_79
    );
  control_int_fsm_25_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_25_CLKINV_80
    );
  control_i_ix31702z1316 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X2Y19"
    )
    port map (
      ADR0 => control_i_nx28711z3_0,
      ADR1 => control_i_nx32699z3_0,
      ADR2 => prog_data_int(1),
      ADR3 => control_i_nx28711z4_0,
      O => control_i_nx31702z1
    );
  control_int_fsm_0_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx42068z1,
      O => control_int_fsm_0_DYMUX_81
    );
  control_int_fsm_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_0_SRINV_82
    );
  control_int_fsm_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_0_CLKINV_83
    );
  control_int_fsm_3_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx45059z1,
      O => control_int_fsm_3_DXMUX_84
    );
  control_int_fsm_3_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx44062z1,
      O => control_int_fsm_3_DYMUX_85
    );
  control_int_fsm_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_3_SRINV_86
    );
  control_int_fsm_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_3_CLKINV_87
    );
  control_i_ix44062z1316 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X3Y22"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => control_i_nx44062z2_0,
      ADR2 => control_i_nx32699z3_0,
      ADR3 => prog_data_int(7),
      O => control_i_nx44062z1
    );
  control_int_fsm_5_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx47053z1,
      O => control_int_fsm_5_DXMUX_88
    );
  control_int_fsm_5_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx46056z1,
      O => control_int_fsm_5_DYMUX_89
    );
  control_int_fsm_5_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_5_SRINV_90
    );
  control_int_fsm_5_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_5_CLKINV_91
    );
  control_i_ix46056z1316 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X6Y22"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => control_i_nx46056z2_0,
      ADR2 => prog_data_int(7),
      ADR3 => control_i_nx32699z3_0,
      O => control_i_nx46056z1
    );
  control_int_fsm_7_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx49047z1,
      O => control_int_fsm_7_DXMUX_92
    );
  control_int_fsm_7_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx48050z1,
      O => control_int_fsm_7_DYMUX_93
    );
  control_int_fsm_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_7_SRINV_94
    );
  control_int_fsm_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_7_CLKINV_95
    );
  control_i_ix48050z1316 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X3Y20"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => control_i_nx48050z2_0,
      ADR2 => control_i_nx32699z3_0,
      ADR3 => prog_data_int(7),
      O => control_i_nx48050z1
    );
  control_int_fsm_20_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z1,
      O => control_int_fsm_20_DXMUX_96
    );
  control_int_fsm_20_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z6_pack_1,
      O => control_i_nx27714z6
    );
  control_int_fsm_20_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_20_SRINV_97
    );
  control_int_fsm_20_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_20_CLKINV_98
    );
  alu_i_nx14381z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z3,
      O => alu_i_nx14381z3_0
    );
  alu_i_nx14381z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z15,
      O => alu_i_nx20363z15_0
    );
  alu_i_ix20363z61426 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X6Y18"
    )
    port map (
      ADR0 => datmem_data_out_dup0(6),
      ADR1 => alu_i_nx20363z17,
      ADR2 => ram_data_reg(7),
      ADR3 => alu_i_nx20363z16,
      O => alu_i_nx20363z15
    );
  alu_i_nx20363z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z3,
      O => alu_i_nx20363z3_0
    );
  alu_i_nx20363z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z4_pack_1,
      O => alu_i_nx20363z4
    );
  alu_i_ix20363z1551 : X_LUT4
    generic map(
      INIT => X"FCC0",
      LOC => "SLICE_X12Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => alu_i_nx20363z5_0,
      ADR2 => datmem_data_out_dup0(3),
      ADR3 => b_dup0(3),
      O => alu_i_nx20363z4_pack_1
    );
  alu_i_nx17372z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z4,
      O => alu_i_nx17372z4_0
    );
  alu_i_nx17372z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z7_pack_1,
      O => alu_i_nx17372z7
    );
  alu_i_ix17372z1546 : X_LUT4
    generic map(
      INIT => X"AAA0",
      LOC => "SLICE_X13Y19"
    )
    port map (
      ADR0 => control_int_fsm(5),
      ADR1 => VCC,
      ADR2 => b_dup0(4),
      ADR3 => datmem_data_out_dup0(4),
      O => alu_i_nx17372z7_pack_1
    );
  alu_i_nx20363z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z5,
      O => alu_i_nx20363z5_0
    );
  alu_i_nx20363z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z6_pack_1,
      O => alu_i_nx20363z6
    );
  alu_i_ix20363z1553 : X_LUT4
    generic map(
      INIT => X"FCC0",
      LOC => "SLICE_X12Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => b_dup0(1),
      ADR2 => datmem_data_out_dup0(1),
      ADR3 => alu_i_nx20363z7,
      O => alu_i_nx20363z6_pack_1
    );
  alu_i_result_int_0n8ss1_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1(1),
      O => alu_i_result_int_0n8ss1_1_0
    );
  alu_i_result_int_0n8ss1_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z7_pack_1,
      O => alu_i_nx20363z7
    );
  alu_i_ix20363z1554 : X_LUT4
    generic map(
      INIT => X"EE88",
      LOC => "SLICE_X11Y12"
    )
    port map (
      ADR0 => datmem_data_out_dup0(0),
      ADR1 => b_dup0(0),
      ADR2 => VCC,
      ADR3 => cflag_dup0,
      O => alu_i_nx20363z7_pack_1
    );
  alu_i_nx17372z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z2,
      O => alu_i_nx17372z2_0
    );
  alu_i_nx17372z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1_4_pack_1,
      O => alu_i_result_int_0n8ss1(4)
    );
  alu_i_ix17372z1467 : X_LUT4
    generic map(
      INIT => X"C33C",
      LOC => "SLICE_X13Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => alu_i_nx20363z4,
      ADR2 => b_dup0(4),
      ADR3 => datmem_data_out_dup0(4),
      O => alu_i_result_int_0n8ss1_4_pack_1
    );
  alu_i_result_int_0n8ss1_0_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1(0),
      O => alu_i_result_int_0n8ss1_0_0
    );
  alu_i_result_int_0n8ss1_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z6,
      O => alu_i_nx13384z6_0
    );
  alu_i_ix13384z1327 : X_LUT4
    generic map(
      INIT => X"0FFF",
      LOC => "SLICE_X10Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => b_dup0(0),
      ADR3 => datmem_data_out_dup0(0),
      O => alu_i_nx13384z6
    );
  alu_i_nx19366z9_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z9,
      O => alu_i_nx19366z9_0
    );
  alu_i_nx19366z9_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z17,
      O => alu_i_nx49743z17_0
    );
  alu_i_ix49743z34100 : X_LUT4
    generic map(
      INIT => X"7FFF",
      LOC => "SLICE_X7Y21"
    )
    port map (
      ADR0 => datmem_data_out_dup0(7),
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => datmem_data_out_dup0(4),
      O => alu_i_nx49743z17
    );
  alu_i_nx49743z20_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z20,
      O => alu_i_nx49743z20_0
    );
  alu_i_nx49743z20_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx44062z2,
      O => control_i_nx44062z2_0
    );
  control_i_ix44062z1319 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X2Y23"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(2),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(0),
      O => control_i_nx44062z2
    );
  alu_i_nx20363z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z1,
      O => alu_i_nx20363z1_0
    );
  alu_i_nx20363z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z37,
      O => alu_i_nx20363z37_0
    );
  alu_i_ix20363z1397 : X_LUT4
    generic map(
      INIT => X"00CC",
      LOC => "SLICE_X10Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(2),
      ADR2 => VCC,
      ADR3 => datmem_data_out_dup0(7),
      O => alu_i_nx20363z37
    );
  alu_i_nx49743z40_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z40,
      O => alu_i_nx49743z40_0
    );
  alu_i_nx49743z40_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z18,
      O => alu_i_nx49743z18_0
    );
  alu_i_ix49743z34101 : X_LUT4
    generic map(
      INIT => X"7FFF",
      LOC => "SLICE_X9Y16"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => datmem_data_out_dup0(0),
      ADR2 => datmem_data_out_dup0(2),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx49743z18
    );
  alu_i_result_int_0n8ss1_7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1(7),
      O => alu_i_result_int_0n8ss1_7_0
    );
  alu_i_result_int_0n8ss1_7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z2_pack_1,
      O => alu_i_nx20363z2
    );
  alu_i_ix20363z1549 : X_LUT4
    generic map(
      INIT => X"FAA0",
      LOC => "SLICE_X11Y21"
    )
    port map (
      ADR0 => alu_i_nx20363z3_0,
      ADR1 => VCC,
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => b_dup0(5),
      O => alu_i_nx20363z2_pack_1
    );
  datmem_nrd_dup0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1,
      O => nx17594z1_0
    );
  ix17594z1328 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X3Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(24),
      ADR2 => VCC,
      ADR3 => control_int_fsm(23),
      O => nx17594z1
    );
  alu_i_nx14381z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z1,
      O => alu_i_nx14381z1_0
    );
  alu_i_nx14381z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z2,
      O => alu_i_nx16375z2_0
    );
  alu_i_ix16375z61892 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X9Y15"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => alu_i_nx20363z10,
      ADR2 => datmem_data_out_dup0(3),
      ADR3 => prog_data_int(3),
      O => alu_i_nx16375z2
    );
  alu_i_nx13384z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z5,
      O => alu_i_nx13384z5_0
    );
  alu_i_nx13384z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z8_pack_1,
      O => alu_i_nx13384z8
    );
  alu_i_ix13384z34642 : X_LUT4
    generic map(
      INIT => X"8228",
      LOC => "SLICE_X7Y13"
    )
    port map (
      ADR0 => control_int_fsm(9),
      ADR1 => cflag_dup0,
      ADR2 => b_dup0(0),
      ADR3 => datmem_data_out_dup0(0),
      O => alu_i_nx13384z8_pack_1
    );
  control_i_nx32699z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx32699z2,
      O => control_i_nx32699z2_0
    );
  control_i_nx32699z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx49047z2,
      O => control_i_nx49047z2_0
    );
  control_i_ix49047z1347 : X_LUT4
    generic map(
      INIT => X"0200",
      LOC => "SLICE_X3Y21"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(2),
      ADR3 => prog_data_int(0),
      O => control_i_nx49047z2
    );
  control_int_fsm_19_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx25718z1,
      O => control_int_fsm_19_DXMUX_99
    );
  control_int_fsm_19_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx25718z2_pack_1,
      O => control_i_nx25718z2
    );
  control_int_fsm_19_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_19_SRINV_100
    );
  control_int_fsm_19_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_19_CLKINV_101
    );
  control_i_ix25718z1531 : X_LUT4
    generic map(
      INIT => X"CACA",
      LOC => "SLICE_X5Y19"
    )
    port map (
      ADR0 => cflag_dup0,
      ADR1 => carry_alu_reg,
      ADR2 => flagc_alu_control,
      ADR3 => VCC,
      O => control_i_nx25718z2_pack_1
    );
  alu_i_nx49743z19_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z19,
      O => alu_i_nx49743z19_0
    );
  alu_i_nx49743z19_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx51041z4,
      O => control_i_nx51041z4_0
    );
  control_i_ix51041z1568 : X_LUT4
    generic map(
      INIT => X"FFDD",
      LOC => "SLICE_X7Y22"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => prog_data_int(7),
      ADR2 => VCC,
      ADR3 => prog_data_int(5),
      O => control_i_nx51041z4
    );
  alu_i_nx49743z35_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z35,
      O => alu_i_nx49743z35_0
    );
  alu_i_nx49743z35_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y11",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z37_pack_1,
      O => alu_i_nx49743z37
    );
  alu_i_ix49743z33066 : X_LUT4
    generic map(
      INIT => X"6FF6",
      LOC => "SLICE_X12Y11"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => b_dup0(3),
      ADR2 => datmem_data_out_dup0(4),
      ADR3 => b_dup0(4),
      O => alu_i_nx49743z37_pack_1
    );
  alu_i_nx20363z9_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z9,
      O => alu_i_nx20363z9_0
    );
  alu_i_nx20363z9_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z10_pack_1,
      O => alu_i_nx20363z10
    );
  alu_i_ix20363z1579 : X_LUT4
    generic map(
      INIT => X"FEFE",
      LOC => "SLICE_X4Y19"
    )
    port map (
      ADR0 => alu_i_nx20363z13_0,
      ADR1 => alu_i_nx20363z12_0,
      ADR2 => alu_i_nx20363z11_0,
      ADR3 => VCC,
      O => alu_i_nx20363z10_pack_1
    );
  alu_i_nx18369z6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z6,
      O => alu_i_nx18369z6_0
    );
  alu_i_nx18369z6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1(6),
      O => alu_i_result_int_0n8ss1_6_0
    );
  alu_i_ix19366z9115 : X_LUT4
    generic map(
      INIT => X"366C",
      LOC => "SLICE_X13Y20"
    )
    port map (
      ADR0 => alu_i_nx20363z3_0,
      ADR1 => alu_i_nx19366z1_0,
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => b_dup0(5),
      O => alu_i_result_int_0n8ss1(6)
    );
  control_i_nx48050z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx48050z2,
      O => control_i_nx48050z2_0
    );
  control_i_nx48050z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx42068z2,
      O => control_i_nx42068z2_0
    );
  control_i_ix42068z62487 : X_LUT4
    generic map(
      INIT => X"FFF1",
      LOC => "SLICE_X1Y23"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(3),
      ADR3 => prog_data_int(2),
      O => control_i_nx42068z2
    );
  alu_i_nx18369z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z4,
      O => alu_i_nx18369z4_0
    );
  alu_i_nx18369z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z7_pack_1,
      O => alu_i_nx18369z7
    );
  alu_i_ix18369z1546 : X_LUT4
    generic map(
      INIT => X"CCC0",
      LOC => "SLICE_X12Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(5),
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => b_dup0(5),
      O => alu_i_nx18369z7_pack_1
    );
  alu_i_nx14381z6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z6,
      O => alu_i_nx14381z6_0
    );
  alu_i_nx14381z6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z7,
      O => alu_i_nx13384z7_0
    );
  alu_i_ix13384z60425 : X_LUT4
    generic map(
      INIT => X"FA48",
      LOC => "SLICE_X6Y14"
    )
    port map (
      ADR0 => b_dup0(0),
      ADR1 => control_int_fsm(4),
      ADR2 => datmem_data_out_dup0(0),
      ADR3 => control_int_fsm(5),
      O => alu_i_nx13384z7
    );
  alu_i_nx18369z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z2,
      O => alu_i_nx18369z2_0
    );
  alu_i_nx18369z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1_5_pack_1,
      O => alu_i_result_int_0n8ss1(5)
    );
  alu_i_ix18369z1467 : X_LUT4
    generic map(
      INIT => X"9966",
      LOC => "SLICE_X12Y20"
    )
    port map (
      ADR0 => b_dup0(5),
      ADR1 => datmem_data_out_dup0(5),
      ADR2 => VCC,
      ADR3 => alu_i_nx20363z3_0,
      O => alu_i_result_int_0n8ss1_5_pack_1
    );
  alu_i_nx15378z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z1,
      O => alu_i_nx15378z1_0
    );
  alu_i_nx15378z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z1,
      O => alu_i_nx13384z1_0
    );
  alu_i_ix13384z61411 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X9Y14"
    )
    port map (
      ADR0 => datmem_data_out_dup0(0),
      ADR1 => alu_i_nx13384z2,
      ADR2 => control_int_fsm(8),
      ADR3 => alu_i_nx20363z10,
      O => alu_i_nx13384z1
    );
  control_i_nx47053z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx47053z2,
      O => control_i_nx47053z2_0
    );
  control_i_nx47053z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx25718z3,
      O => control_i_nx25718z3_0
    );
  control_i_ix25718z1299 : X_LUT4
    generic map(
      INIT => X"FFEF",
      LOC => "SLICE_X6Y23"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(2),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(0),
      O => control_i_nx25718z3
    );
  alu_i_nx15378z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z3,
      O => alu_i_nx15378z3_0
    );
  alu_i_nx15378z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z3,
      O => alu_i_nx18369z3_0
    );
  alu_i_ix18369z61414 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X6Y16"
    )
    port map (
      ADR0 => datmem_data_out_dup0(4),
      ADR1 => alu_i_nx20363z17,
      ADR2 => ram_data_reg(5),
      ADR3 => alu_i_nx20363z16,
      O => alu_i_nx18369z3
    );
  alu_i_nx18369z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx18369z1,
      O => alu_i_nx18369z1_0
    );
  alu_i_nx18369z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z1,
      O => alu_i_nx17372z1_0
    );
  alu_i_ix17372z61891 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X9Y18"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => alu_i_nx20363z10,
      ADR2 => datmem_data_out_dup0(4),
      ADR3 => prog_data_int(4),
      O => alu_i_nx17372z1
    );
  datmem_data_out_dup0_3_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_3_FXMUX_103,
      O => datmem_data_out_dup0_3_DXMUX_102
    );
  datmem_data_out_dup0_3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_3_FXMUX_103,
      O => reg_i_a_out_1n1ss1_3_0
    );
  datmem_data_out_dup0_3_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(3),
      O => datmem_data_out_dup0_3_FXMUX_103
    );
  datmem_data_out_dup0_3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_3_pack_1,
      O => result_alu_reg(3)
    );
  datmem_data_out_dup0_3_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_3_SRINV_104
    );
  datmem_data_out_dup0_3_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_3_CLKINV_105
    );
  datmem_data_out_dup0_3_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_3_CEINV_106
    );
  alu_i_nx20363z11_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z11,
      O => alu_i_nx20363z11_0
    );
  ix48421z1529 : X_LUT4
    generic map(
      INIT => X"99FF",
      LOC => "SLICE_X2Y16"
    )
    port map (
      ADR0 => ram_control_i_p_clk,
      ADR1 => ram_control_i_n_clk,
      ADR2 => VCC,
      ADR3 => control_int_fsm(25),
      O => datmem_nwr_dup0
    );
  control_i_nx46056z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx46056z2,
      O => control_i_nx46056z2_0
    );
  control_i_nx46056z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx45059z2,
      O => control_i_nx45059z2_0
    );
  control_i_ix45059z2339 : X_LUT4
    generic map(
      INIT => X"0020",
      LOC => "SLICE_X3Y23"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(2),
      ADR3 => prog_data_int(3),
      O => control_i_nx45059z2
    );
  alu_i_nx16375z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z4,
      O => alu_i_nx16375z4_0
    );
  alu_i_nx16375z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z5_pack_1,
      O => alu_i_nx16375z5
    );
  alu_i_ix16375z1333 : X_LUT4
    generic map(
      INIT => X"EEEE",
      LOC => "SLICE_X8Y13"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => b_dup0(3),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_nx16375z5_pack_1
    );
  alu_i_nx14381z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z2,
      O => alu_i_nx14381z2_0
    );
  alu_i_nx14381z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z3,
      O => alu_i_nx13384z3_0
    );
  alu_i_ix13384z56037 : X_LUT4
    generic map(
      INIT => X"C0EA",
      LOC => "SLICE_X9Y12"
    )
    port map (
      ADR0 => control_int_fsm(2),
      ADR1 => cflag_dup0,
      ADR2 => control_int_fsm(7),
      ADR3 => datmem_data_out_dup0(0),
      O => alu_i_nx13384z3
    );
  alu_i_nx16375z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z3,
      O => alu_i_nx16375z3_0
    );
  alu_i_nx16375z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z4,
      O => alu_i_nx19366z4_0
    );
  alu_i_ix19366z61415 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X7Y19"
    )
    port map (
      ADR0 => alu_i_nx20363z16,
      ADR1 => ram_data_reg(6),
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => alu_i_nx20363z17,
      O => alu_i_nx19366z4
    );
  control_i_nx42068z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx42068z3,
      O => control_i_nx42068z3_0
    );
  control_i_nx42068z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx50044z2,
      O => control_i_nx50044z2_0
    );
  control_i_ix50044z1329 : X_LUT4
    generic map(
      INIT => X"EEEE",
      LOC => "SLICE_X1Y22"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => VCC,
      ADR3 => VCC,
      O => control_i_nx50044z2
    );
  control_int_fsm_22_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx29708z1,
      O => control_int_fsm_22_DXMUX_107
    );
  control_int_fsm_22_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx28711z2_pack_1,
      O => control_i_nx28711z2
    );
  control_int_fsm_22_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_22_SRINV_108
    );
  control_int_fsm_22_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_22_CLKINV_109
    );
  alu_i_nx19366z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z2,
      O => alu_i_nx19366z2_0
    );
  alu_i_nx19366z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z8_pack_1,
      O => alu_i_nx19366z8
    );
  alu_i_ix19366z53195 : X_LUT4
    generic map(
      INIT => X"BC80",
      LOC => "SLICE_X9Y21"
    )
    port map (
      ADR0 => control_int_fsm(3),
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => b_dup0(6),
      ADR3 => control_int_fsm(4),
      O => alu_i_nx19366z8_pack_1
    );
  nx62171z14_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z14,
      O => nx62171z14_0
    );
  nx62171z14_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx28711z3,
      O => control_i_nx28711z3_0
    );
  control_i_ix28711z1329 : X_LUT4
    generic map(
      INIT => X"F5F5",
      LOC => "SLICE_X17Y17"
    )
    port map (
      ADR0 => prog_data_int(7),
      ADR1 => VCC,
      ADR2 => prog_data_int(6),
      ADR3 => VCC,
      O => control_i_nx28711z3
    );
  control_int_fsm_1_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm_1_FXMUX_111,
      O => control_int_fsm_1_DXMUX_110
    );
  control_int_fsm_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm_1_FXMUX_111,
      O => control_nxt_int_fsm_1_0
    );
  control_int_fsm_1_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_nxt_int_fsm(1),
      O => control_int_fsm_1_FXMUX_111
    );
  control_int_fsm_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx2739z2_pack_1,
      O => control_i_nx2739z2
    );
  control_int_fsm_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_1_SRINV_112
    );
  control_int_fsm_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_1_CLKINV_113
    );
  nx62171z8_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z8,
      O => nx62171z8_0
    );
  ix62171z1540 : X_LUT4
    generic map(
      INIT => X"FC0C",
      LOC => "SLICE_X17Y14"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_adr_dup0(1),
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => prog_data_int(1),
      O => nx62171z9
    );
  nx62171z11_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z11,
      O => nx62171z11_0
    );
  nx62171z11_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z10,
      O => nx62171z10_0
    );
  ix62171z1541 : X_LUT4
    generic map(
      INIT => X"CFC0",
      LOC => "SLICE_X17Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_int(2),
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => prog_adr_dup0(2),
      O => nx62171z10
    );
  nx62171z13_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z13,
      O => nx62171z13_0
    );
  nx62171z13_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X17Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z12,
      O => nx62171z12_0
    );
  ix62171z1543 : X_LUT4
    generic map(
      INIT => X"BB88",
      LOC => "SLICE_X17Y16"
    )
    port map (
      ADR0 => prog_data_int(4),
      ADR1 => pc_i_rtlc3_PS4_n64,
      ADR2 => VCC,
      ADR3 => prog_adr_dup0(4),
      O => nx62171z12
    );
  datmem_data_out_dup0_1_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_1_FXMUX_115,
      O => datmem_data_out_dup0_1_DXMUX_114
    );
  datmem_data_out_dup0_1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_1_FXMUX_115,
      O => reg_i_a_out_1n1ss1_1_0
    );
  datmem_data_out_dup0_1_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(1),
      O => datmem_data_out_dup0_1_FXMUX_115
    );
  datmem_data_out_dup0_1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_1_pack_1,
      O => result_alu_reg(1)
    );
  datmem_data_out_dup0_1_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_1_SRINV_116
    );
  datmem_data_out_dup0_1_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_1_CLKINV_117
    );
  datmem_data_out_dup0_1_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X6Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_1_CEINV_118
    );
  alu_i_nx19366z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z3,
      O => alu_i_nx19366z3_0
    );
  alu_i_nx19366z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z1,
      O => alu_i_nx19366z1_0
    );
  alu_i_ix19366z1322 : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X8Y21"
    )
    port map (
      ADR0 => datmem_data_out_dup0(6),
      ADR1 => b_dup0(6),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_nx19366z1
    );
  datmem_data_out_dup0_6_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_6_FXMUX_120,
      O => datmem_data_out_dup0_6_DXMUX_119
    );
  datmem_data_out_dup0_6_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_6_FXMUX_120,
      O => reg_i_a_out_1n1ss1_6_0
    );
  datmem_data_out_dup0_6_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(6),
      O => datmem_data_out_dup0_6_FXMUX_120
    );
  datmem_data_out_dup0_6_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_6_pack_1,
      O => result_alu_reg(6)
    );
  datmem_data_out_dup0_6_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_6_SRINV_121
    );
  datmem_data_out_dup0_6_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_6_CLKINV_122
    );
  datmem_data_out_dup0_6_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_6_CEINV_123
    );
  ram_control_i_n_clk_DYMUX : X_INV
    generic map(
      LOC => "SLICE_X3Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_n_clk,
      O => ram_control_i_n_clk_DYMUX_124
    );
  ram_control_i_n_clk_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X3Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => ram_control_i_n_clk_SRINV_125
    );
  ram_control_i_n_clk_CLKINV : X_INV
    generic map(
      LOC => "SLICE_X3Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => ram_control_i_n_clk_CLKINVNOT
    );
  control_i_nx32699z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx32699z3,
      O => control_i_nx32699z3_0
    );
  control_i_nx32699z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx32699z4_pack_1,
      O => control_i_nx32699z4
    );
  control_i_ix32699z1315 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X5Y21"
    )
    port map (
      ADR0 => control_int_fsm(18),
      ADR1 => control_int_fsm(19),
      ADR2 => control_int_fsm(21),
      ADR3 => control_int_fsm(20),
      O => control_i_nx32699z4_pack_1
    );
  control_int_fsm_11_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(19),
      O => control_int_fsm_11_DXMUX_126
    );
  control_int_fsm_11_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(18),
      O => control_int_fsm_11_DYMUX_127
    );
  control_int_fsm_11_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_11_SRINV_128
    );
  control_int_fsm_11_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_11_CLKINV_129
    );
  alu_i_nx19366z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z5,
      O => alu_i_nx19366z5_0
    );
  alu_i_nx19366z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z6_pack_1,
      O => alu_i_nx19366z6
    );
  alu_i_ix19366z1335 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X11Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => b_dup0(6),
      ADR2 => VCC,
      ADR3 => datmem_data_out_dup0(6),
      O => alu_i_nx19366z6_pack_1
    );
  nx53939z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx53939z1,
      O => nx53939z1_0
    );
  nx53939z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_rtlc3_PS4_n64_pack_1,
      O => pc_i_rtlc3_PS4_n64
    );
  ix62171z1577 : X_LUT4
    generic map(
      INIT => X"FEFE",
      LOC => "SLICE_X6Y19"
    )
    port map (
      ADR0 => control_int_fsm(20),
      ADR1 => control_int_fsm(19),
      ADR2 => control_int_fsm(18),
      ADR3 => VCC,
      O => pc_i_rtlc3_PS4_n64_pack_1
    );
  alu_i_nx49743z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z1,
      O => alu_i_nx49743z1_0
    );
  alu_i_nx49743z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z2_pack_1,
      O => alu_i_nx49743z2
    );
  alu_i_ix49743z1315 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X13Y13"
    )
    port map (
      ADR0 => alu_i_result_int_0n8ss1(2),
      ADR1 => alu_i_result_int_0n8ss1_3_0,
      ADR2 => alu_i_result_int_0n8ss1(4),
      ADR3 => alu_i_result_int_0n8ss1_1_0,
      O => alu_i_nx49743z2_pack_1
    );
  alu_i_nx49743z39_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z39,
      O => alu_i_nx49743z39_0
    );
  alu_i_nx49743z39_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z6,
      O => alu_i_nx15378z6_0
    );
  alu_i_ix15378z53193 : X_LUT4
    generic map(
      INIT => X"E828",
      LOC => "SLICE_X11Y14"
    )
    port map (
      ADR0 => control_int_fsm(4),
      ADR1 => datmem_data_out_dup0(2),
      ADR2 => b_dup0(2),
      ADR3 => control_int_fsm(3),
      O => alu_i_nx15378z6
    );
  alu_i_nx49743z36_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y10",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z36,
      O => alu_i_nx49743z36_0
    );
  alu_i_ix49743z1403 : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X12Y10"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(2),
      ADR2 => b_dup0(2),
      ADR3 => VCC,
      O => alu_i_nx49743z36
    );
  control_int_fsm_13_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(21),
      O => control_int_fsm_13_DXMUX_130
    );
  control_int_fsm_13_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X5Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(20),
      O => control_int_fsm_13_DYMUX_131
    );
  control_int_fsm_13_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_13_SRINV_132
    );
  control_int_fsm_13_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X5Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_13_CLKINV_133
    );
  alu_i_result_int_0n8ss1_3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1(3),
      O => alu_i_result_int_0n8ss1_3_0
    );
  alu_i_result_int_0n8ss1_3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z8,
      O => alu_i_nx16375z8_0
    );
  alu_i_ix16375z34642 : X_LUT4
    generic map(
      INIT => X"9600",
      LOC => "SLICE_X13Y12"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => b_dup0(3),
      ADR2 => alu_i_nx20363z5_0,
      ADR3 => control_int_fsm(9),
      O => alu_i_nx16375z8
    );
  alu_i_nx49743z26_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z26,
      O => alu_i_nx49743z26_0
    );
  alu_i_ix49743z1341 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X12Y14"
    )
    port map (
      ADR0 => alu_i_nx16375z6,
      ADR1 => alu_i_nx14381z5,
      ADR2 => alu_i_nx17372z5,
      ADR3 => alu_i_nx15378z5,
      O => alu_i_nx49743z26
    );
  alu_i_nx17372z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z3,
      O => alu_i_nx17372z3_0
    );
  alu_i_nx17372z3_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z13,
      O => alu_i_nx49743z13_0
    );
  alu_i_ix49743z1327 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X6Y17"
    )
    port map (
      ADR0 => ram_data_reg(6),
      ADR1 => ram_data_reg(4),
      ADR2 => ram_data_reg(5),
      ADR3 => ram_data_reg(7),
      O => alu_i_nx49743z13
    );
  datmem_data_out_dup0_2_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_2_FXMUX_135,
      O => datmem_data_out_dup0_2_DXMUX_134
    );
  datmem_data_out_dup0_2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_2_FXMUX_135,
      O => reg_i_a_out_1n1ss1_2_0
    );
  datmem_data_out_dup0_2_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(2),
      O => datmem_data_out_dup0_2_FXMUX_135
    );
  datmem_data_out_dup0_2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_2_pack_1,
      O => result_alu_reg(2)
    );
  datmem_data_out_dup0_2_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_2_SRINV_136
    );
  datmem_data_out_dup0_2_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_2_CLKINV_137
    );
  datmem_data_out_dup0_2_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X10Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_2_CEINV_138
    );
  alu_i_nx49743z14_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z14,
      O => alu_i_nx49743z14_0
    );
  alu_i_ix49743z1328 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y18"
    )
    port map (
      ADR0 => ram_data_reg(1),
      ADR1 => ram_data_reg(3),
      ADR2 => ram_data_reg(2),
      ADR3 => ram_data_reg(0),
      O => alu_i_nx49743z14
    );
  control_int_fsm_15_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(23),
      O => control_int_fsm_15_DXMUX_139
    );
  control_int_fsm_15_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(22),
      O => control_int_fsm_15_DYMUX_140
    );
  control_int_fsm_15_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_15_SRINV_141
    );
  control_int_fsm_15_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_15_CLKINV_142
    );
  flagz_alu_control_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control,
      O => flagz_alu_control_0
    );
  flagz_alu_control_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z22_pack_1,
      O => alu_i_nx49743z22
    );
  alu_i_ix49743z1337 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y15"
    )
    port map (
      ADR0 => alu_i_nx49743z23_0,
      ADR1 => control_int_fsm(5),
      ADR2 => control_int_fsm(4),
      ADR3 => control_int_fsm(3),
      O => alu_i_nx49743z22_pack_1
    );
  alu_i_nx49743z28_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z28,
      O => alu_i_nx49743z28_0
    );
  alu_i_nx49743z28_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z29_pack_1,
      O => alu_i_nx49743z29
    );
  alu_i_ix49743z1361 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X10Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(5),
      ADR2 => VCC,
      ADR3 => b_dup0(5),
      O => alu_i_nx49743z29_pack_1
    );
  alu_i_nx49743z30_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z30,
      O => alu_i_nx49743z30_0
    );
  alu_i_nx49743z30_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y13",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z31_pack_1,
      O => alu_i_nx49743z31
    );
  alu_i_ix49743z1347 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y13"
    )
    port map (
      ADR0 => b_dup0(2),
      ADR1 => datmem_data_out_dup0(2),
      ADR2 => b_dup0(1),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx49743z31_pack_1
    );
  alu_i_nx49743z25_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z25,
      O => alu_i_nx49743z25_0
    );
  alu_i_ix49743z1339 : X_LUT4
    generic map(
      INIT => X"FFEF",
      LOC => "SLICE_X12Y17"
    )
    port map (
      ADR0 => alu_i_nx20363z20,
      ADR1 => alu_i_nx18369z5,
      ADR2 => control_int_fsm(8),
      ADR3 => alu_i_nx19366z7,
      O => alu_i_nx49743z25
    );
  control_int_fsm_17_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(25),
      O => control_int_fsm_17_DXMUX_143
    );
  control_int_fsm_17_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_int_fsm(24),
      O => control_int_fsm_17_DYMUX_144
    );
  control_int_fsm_17_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_17_SRINV_145
    );
  control_int_fsm_17_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_17_CLKINV_146
    );
  alu_i_nx14381z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z4,
      O => alu_i_nx14381z4_0
    );
  alu_i_nx14381z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx14381z7_pack_1,
      O => alu_i_nx14381z7
    );
  alu_i_ix14381z1546 : X_LUT4
    generic map(
      INIT => X"EE00",
      LOC => "SLICE_X6Y15"
    )
    port map (
      ADR0 => datmem_data_out_dup0(1),
      ADR1 => b_dup0(1),
      ADR2 => VCC,
      ADR3 => control_int_fsm(5),
      O => alu_i_nx14381z7_pack_1
    );
  alu_i_nx49743z45_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z45,
      O => alu_i_nx49743z45_0
    );
  alu_i_nx49743z45_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z46_pack_1,
      O => alu_i_nx49743z46
    );
  alu_i_ix49743z1365 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y17"
    )
    port map (
      ADR0 => datmem_data_out_dup0(4),
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => datmem_data_out_dup0(3),
      ADR3 => datmem_data_out_dup0(5),
      O => alu_i_nx49743z46_pack_1
    );
  alu_i_nx49743z33_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z33,
      O => alu_i_nx49743z33_0
    );
  alu_i_nx49743z33_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z34_pack_1,
      O => alu_i_nx49743z34
    );
  alu_i_ix49743z1358 : X_LUT4
    generic map(
      INIT => X"0FF0",
      LOC => "SLICE_X11Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => b_dup0(5),
      O => alu_i_nx49743z34_pack_1
    );
  alu_i_nx49743z42_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z42,
      O => alu_i_nx49743z42_0
    );
  alu_i_nx49743z42_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z43_pack_1,
      O => alu_i_nx49743z43
    );
  alu_i_ix49743z61939 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X11Y17"
    )
    port map (
      ADR0 => b_dup0(6),
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => b_dup0(5),
      O => alu_i_nx49743z43_pack_1
    );
  alu_i_nx16375z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z1,
      O => alu_i_nx16375z1_0
    );
  alu_i_nx16375z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx16375z7_pack_1,
      O => alu_i_nx16375z7
    );
  alu_i_ix16375z53193 : X_LUT4
    generic map(
      INIT => X"B8C0",
      LOC => "SLICE_X8Y12"
    )
    port map (
      ADR0 => control_int_fsm(3),
      ADR1 => b_dup0(3),
      ADR2 => control_int_fsm(4),
      ADR3 => datmem_data_out_dup0(3),
      O => alu_i_nx16375z7_pack_1
    );
  alu_i_nx20363z14_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z14,
      O => alu_i_nx20363z14_0
    );
  alu_i_nx20363z14_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z3,
      O => control_i_nx27714z3_0
    );
  control_i_ix27714z1314 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X5Y17"
    )
    port map (
      ADR0 => control_int_fsm(23),
      ADR1 => control_int_fsm(24),
      ADR2 => control_int_fsm(22),
      ADR3 => control_int_fsm(25),
      O => control_i_nx27714z3
    );
  alu_i_nx13384z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z2_XORF_147,
      O => alu_i_nx13384z2
    );
  alu_i_nx13384z2_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X13Y14"
    )
    port map (
      I0 => alu_i_nx13384z2_CYINIT_148,
      I1 => alu_i_nx20363z28,
      O => alu_i_nx13384z2_XORF_147
    );
  alu_i_nx13384z2_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X13Y14"
    )
    port map (
      IA => alu_i_nx13384z2_CY0F_149,
      IB => alu_i_nx13384z2_CYINIT_148,
      SEL => alu_i_nx13384z2_CYSELF_150,
      O => alu_i_ix20363z63368_O
    );
  alu_i_nx13384z2_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC0,
      O => alu_i_nx13384z2_CYINIT_148
    );
  alu_i_nx13384z2_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(0),
      O => alu_i_nx13384z2_CY0F_149
    );
  alu_i_nx13384z2_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z28,
      O => alu_i_nx13384z2_CYSELF_150
    );
  alu_i_nx13384z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z2_XORG_151,
      O => alu_i_nx14381z5
    );
  alu_i_nx13384z2_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X13Y14"
    )
    port map (
      I0 => alu_i_ix20363z63368_O,
      I1 => alu_i_nx20363z29,
      O => alu_i_nx13384z2_XORG_151
    );
  alu_i_nx13384z2_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z2_CYMUXG_152,
      O => alu_i_ix20363z63367_O
    );
  alu_i_nx13384z2_CYMUXG : X_MUX2
    generic map(
      LOC => "SLICE_X13Y14"
    )
    port map (
      IA => alu_i_nx13384z2_CY0G_153,
      IB => alu_i_ix20363z63368_O,
      SEL => alu_i_nx13384z2_CYSELG_154,
      O => alu_i_nx13384z2_CYMUXG_152
    );
  alu_i_nx13384z2_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(1),
      O => alu_i_nx13384z2_CY0G_153
    );
  alu_i_nx13384z2_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X13Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z29,
      O => alu_i_nx13384z2_CYSELG_154
    );
  alu_i_ix20363z1350 : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X13Y14"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(1),
      ADR2 => b_dup0(1),
      ADR3 => VCC,
      O => alu_i_nx20363z29
    );
  alu_i_nx15378z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z5_XORF_155,
      O => alu_i_nx15378z5
    );
  alu_i_nx15378z5_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      I0 => alu_i_nx15378z5_CYINIT_156,
      I1 => alu_i_nx20363z30,
      O => alu_i_nx15378z5_XORF_155
    );
  alu_i_nx15378z5_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      IA => alu_i_nx15378z5_CY0F_157,
      IB => alu_i_nx15378z5_CYINIT_156,
      SEL => alu_i_nx15378z5_CYSELF_159,
      O => alu_i_ix20363z63366_O
    );
  alu_i_nx15378z5_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      IA => alu_i_nx15378z5_CY0F_157,
      IB => alu_i_nx15378z5_CY0F_157,
      SEL => alu_i_nx15378z5_CYSELF_159,
      O => alu_i_nx15378z5_CYMUXF2_164
    );
  alu_i_nx15378z5_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63367_O,
      O => alu_i_nx15378z5_CYINIT_156
    );
  alu_i_nx15378z5_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(2),
      O => alu_i_nx15378z5_CY0F_157
    );
  alu_i_nx15378z5_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z30,
      O => alu_i_nx15378z5_CYSELF_159
    );
  alu_i_nx15378z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z5_XORG_158,
      O => alu_i_nx16375z6
    );
  alu_i_nx15378z5_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      I0 => alu_i_ix20363z63366_O,
      I1 => alu_i_nx20363z31,
      O => alu_i_nx15378z5_XORG_158
    );
  alu_i_nx15378z5_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z5_CYMUXFAST_160,
      O => alu_i_ix20363z63365_O
    );
  alu_i_nx15378z5_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63367_O,
      O => alu_i_nx15378z5_FASTCARRY_162
    );
  alu_i_nx15378z5_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      I0 => alu_i_nx15378z5_CYSELG_166,
      I1 => alu_i_nx15378z5_CYSELF_159,
      O => alu_i_nx15378z5_CYAND_161
    );
  alu_i_nx15378z5_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      IA => alu_i_nx15378z5_CYMUXG2_163,
      IB => alu_i_nx15378z5_FASTCARRY_162,
      SEL => alu_i_nx15378z5_CYAND_161,
      O => alu_i_nx15378z5_CYMUXFAST_160
    );
  alu_i_nx15378z5_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y15"
    )
    port map (
      IA => alu_i_nx15378z5_CY0G_165,
      IB => alu_i_nx15378z5_CYMUXF2_164,
      SEL => alu_i_nx15378z5_CYSELG_166,
      O => alu_i_nx15378z5_CYMUXG2_163
    );
  alu_i_nx15378z5_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(3),
      O => alu_i_nx15378z5_CY0G_165
    );
  alu_i_nx15378z5_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X13Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z31,
      O => alu_i_nx15378z5_CYSELG_166
    );
  alu_i_ix20363z1352 : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X13Y15"
    )
    port map (
      ADR0 => b_dup0(3),
      ADR1 => datmem_data_out_dup0(3),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_nx20363z31
    );
  datmem_data_out_dup0_4_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_4_FXMUX_168,
      O => datmem_data_out_dup0_4_DXMUX_167
    );
  datmem_data_out_dup0_4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_4_FXMUX_168,
      O => reg_i_a_out_1n1ss1_4_0
    );
  datmem_data_out_dup0_4_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(4),
      O => datmem_data_out_dup0_4_FXMUX_168
    );
  datmem_data_out_dup0_4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_4_pack_1,
      O => result_alu_reg(4)
    );
  datmem_data_out_dup0_4_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_4_SRINV_169
    );
  datmem_data_out_dup0_4_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_4_CLKINV_170
    );
  datmem_data_out_dup0_4_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X11Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_4_CEINV_171
    );
  alu_i_nx17372z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z5_XORF_172,
      O => alu_i_nx17372z5
    );
  alu_i_nx17372z5_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      I0 => alu_i_nx17372z5_CYINIT_173,
      I1 => alu_i_nx20363z32,
      O => alu_i_nx17372z5_XORF_172
    );
  alu_i_nx17372z5_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      IA => alu_i_nx17372z5_CY0F_174,
      IB => alu_i_nx17372z5_CYINIT_173,
      SEL => alu_i_nx17372z5_CYSELF_176,
      O => alu_i_ix20363z63364_O
    );
  alu_i_nx17372z5_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      IA => alu_i_nx17372z5_CY0F_174,
      IB => alu_i_nx17372z5_CY0F_174,
      SEL => alu_i_nx17372z5_CYSELF_176,
      O => alu_i_nx17372z5_CYMUXF2_181
    );
  alu_i_nx17372z5_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63365_O,
      O => alu_i_nx17372z5_CYINIT_173
    );
  alu_i_nx17372z5_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(4),
      O => alu_i_nx17372z5_CY0F_174
    );
  alu_i_nx17372z5_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z32,
      O => alu_i_nx17372z5_CYSELF_176
    );
  alu_i_nx17372z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z5_XORG_175,
      O => alu_i_nx18369z5
    );
  alu_i_nx17372z5_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      I0 => alu_i_ix20363z63364_O,
      I1 => alu_i_nx20363z33,
      O => alu_i_nx17372z5_XORG_175
    );
  alu_i_nx17372z5_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx17372z5_CYMUXFAST_177,
      O => alu_i_ix20363z63363_O
    );
  alu_i_nx17372z5_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63365_O,
      O => alu_i_nx17372z5_FASTCARRY_179
    );
  alu_i_nx17372z5_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      I0 => alu_i_nx17372z5_CYSELG_183,
      I1 => alu_i_nx17372z5_CYSELF_176,
      O => alu_i_nx17372z5_CYAND_178
    );
  alu_i_nx17372z5_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      IA => alu_i_nx17372z5_CYMUXG2_180,
      IB => alu_i_nx17372z5_FASTCARRY_179,
      SEL => alu_i_nx17372z5_CYAND_178,
      O => alu_i_nx17372z5_CYMUXFAST_177
    );
  alu_i_nx17372z5_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y16"
    )
    port map (
      IA => alu_i_nx17372z5_CY0G_182,
      IB => alu_i_nx17372z5_CYMUXF2_181,
      SEL => alu_i_nx17372z5_CYSELG_183,
      O => alu_i_nx17372z5_CYMUXG2_180
    );
  alu_i_nx17372z5_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(5),
      O => alu_i_nx17372z5_CY0G_182
    );
  alu_i_nx17372z5_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X13Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z33,
      O => alu_i_nx17372z5_CYSELG_183
    );
  alu_i_ix20363z1354 : X_LUT4
    generic map(
      INIT => X"33CC",
      LOC => "SLICE_X13Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(5),
      ADR2 => VCC,
      ADR3 => b_dup0(5),
      O => alu_i_nx20363z33
    );
  alu_i_nx15378z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z4,
      O => alu_i_nx15378z4_0
    );
  alu_i_nx15378z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z7_pack_1,
      O => alu_i_nx15378z7
    );
  alu_i_ix15378z1546 : X_LUT4
    generic map(
      INIT => X"FA00",
      LOC => "SLICE_X10Y15"
    )
    port map (
      ADR0 => b_dup0(2),
      ADR1 => VCC,
      ADR2 => datmem_data_out_dup0(2),
      ADR3 => control_int_fsm(5),
      O => alu_i_nx15378z7_pack_1
    );
  alu_i_nx19366z7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z7_XORF_184,
      O => alu_i_nx19366z7
    );
  alu_i_nx19366z7_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      I0 => alu_i_nx19366z7_CYINIT_185,
      I1 => alu_i_nx20363z34,
      O => alu_i_nx19366z7_XORF_184
    );
  alu_i_nx19366z7_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      IA => alu_i_nx19366z7_CY0F_186,
      IB => alu_i_nx19366z7_CYINIT_185,
      SEL => alu_i_nx19366z7_CYSELF_188,
      O => alu_i_ix20363z63362_O
    );
  alu_i_nx19366z7_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      IA => alu_i_nx19366z7_CY0F_186,
      IB => alu_i_nx19366z7_CY0F_186,
      SEL => alu_i_nx19366z7_CYSELF_188,
      O => alu_i_nx19366z7_CYMUXF2_193
    );
  alu_i_nx19366z7_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63363_O,
      O => alu_i_nx19366z7_CYINIT_185
    );
  alu_i_nx19366z7_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(6),
      O => alu_i_nx19366z7_CY0F_186
    );
  alu_i_nx19366z7_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z34,
      O => alu_i_nx19366z7_CYSELF_188
    );
  alu_i_nx19366z7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z7_XORG_187,
      O => alu_i_nx20363z20
    );
  alu_i_nx19366z7_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      I0 => alu_i_ix20363z63362_O,
      I1 => alu_i_nx20363z35,
      O => alu_i_nx19366z7_XORG_187
    );
  alu_i_nx19366z7_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx19366z7_CYMUXFAST_189,
      O => alu_i_nx51436z4
    );
  alu_i_nx19366z7_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix20363z63363_O,
      O => alu_i_nx19366z7_FASTCARRY_191
    );
  alu_i_nx19366z7_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      I0 => alu_i_nx19366z7_CYSELG_195,
      I1 => alu_i_nx19366z7_CYSELF_188,
      O => alu_i_nx19366z7_CYAND_190
    );
  alu_i_nx19366z7_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      IA => alu_i_nx19366z7_CYMUXG2_192,
      IB => alu_i_nx19366z7_FASTCARRY_191,
      SEL => alu_i_nx19366z7_CYAND_190,
      O => alu_i_nx19366z7_CYMUXFAST_189
    );
  alu_i_nx19366z7_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X13Y17"
    )
    port map (
      IA => alu_i_nx19366z7_CY0G_194,
      IB => alu_i_nx19366z7_CYMUXF2_193,
      SEL => alu_i_nx19366z7_CYSELG_195,
      O => alu_i_nx19366z7_CYMUXG2_192
    );
  alu_i_nx19366z7_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0(7),
      O => alu_i_nx19366z7_CY0G_194
    );
  alu_i_nx19366z7_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X13Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z35,
      O => alu_i_nx19366z7_CYSELG_195
    );
  alu_i_ix20363z1356 : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X13Y17"
    )
    port map (
      ADR0 => datmem_data_out_dup0(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => b_dup0(7),
      O => alu_i_nx20363z35
    );
  alu_i_nx49743z15_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z15,
      O => alu_i_nx49743z15_0
    );
  alu_i_nx49743z15_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z16_pack_1,
      O => alu_i_nx49743z16
    );
  alu_i_ix49743z1585 : X_LUT4
    generic map(
      INIT => X"EFEF",
      LOC => "SLICE_X6Y21"
    )
    port map (
      ADR0 => alu_i_nx49743z17_0,
      ADR1 => alu_i_nx49743z18_0,
      ADR2 => control_int_fsm(2),
      ADR3 => VCC,
      O => alu_i_nx49743z16_pack_1
    );
  prog_adr_dup0_0_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_FXMUX_197,
      O => prog_adr_dup0_0_DXMUX_196
    );
  prog_adr_dup0_0_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_XORF_198,
      O => prog_adr_dup0_0_FXMUX_197
    );
  prog_adr_dup0_0_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y14"
    )
    port map (
      I0 => prog_adr_dup0_0_CYINIT_199,
      I1 => prog_adr_dup0_0_F,
      O => prog_adr_dup0_0_XORF_198
    );
  prog_adr_dup0_0_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y14"
    )
    port map (
      IA => prog_adr_dup0_0_CY0F_200,
      IB => prog_adr_dup0_0_CYINIT_199,
      SEL => prog_adr_dup0_0_CYSELF_201,
      O => pc_i_ix5_modgen_add_0_ix62171z63347_O
    );
  prog_adr_dup0_0_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC0,
      O => prog_adr_dup0_0_CYINIT_199
    );
  prog_adr_dup0_0_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z8_0,
      O => prog_adr_dup0_0_CY0F_200
    );
  prog_adr_dup0_0_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_F,
      O => prog_adr_dup0_0_CYSELF_201
    );
  prog_adr_dup0_0_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_GYMUX_203,
      O => prog_adr_dup0_0_DYMUX_202
    );
  prog_adr_dup0_0_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_XORG_204,
      O => prog_adr_dup0_0_GYMUX_203
    );
  prog_adr_dup0_0_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y14"
    )
    port map (
      I0 => pc_i_ix5_modgen_add_0_ix62171z63347_O,
      I1 => nx52942z1,
      O => prog_adr_dup0_0_XORG_204
    );
  prog_adr_dup0_0_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_CYMUXG_205,
      O => pc_i_ix5_modgen_add_0_ix62171z63346_O
    );
  prog_adr_dup0_0_CYMUXG : X_MUX2
    generic map(
      LOC => "SLICE_X16Y14"
    )
    port map (
      IA => prog_adr_dup0_0_CY0G_206,
      IB => pc_i_ix5_modgen_add_0_ix62171z63347_O,
      SEL => prog_adr_dup0_0_CYSELG_207,
      O => prog_adr_dup0_0_CYMUXG_205
    );
  prog_adr_dup0_0_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z9,
      O => prog_adr_dup0_0_CY0G_206
    );
  prog_adr_dup0_0_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx52942z1,
      O => prog_adr_dup0_0_CYSELG_207
    );
  prog_adr_dup0_0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_dup0_0_SRINV_208
    );
  prog_adr_dup0_0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_dup0_0_CLKINV_209
    );
  ix52942z55045 : X_LUT4
    generic map(
      INIT => X"DE12",
      LOC => "SLICE_X16Y14"
    )
    port map (
      ADR0 => control_nxt_int_fsm_1_0,
      ADR1 => pc_i_rtlc3_PS4_n64,
      ADR2 => prog_adr_dup0(1),
      ADR3 => prog_data_int(1),
      O => nx52942z1
    );
  prog_adr_dup0_2_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_FXMUX_211,
      O => prog_adr_dup0_2_DXMUX_210
    );
  prog_adr_dup0_2_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_XORF_212,
      O => prog_adr_dup0_2_FXMUX_211
    );
  prog_adr_dup0_2_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      I0 => prog_adr_dup0_2_CYINIT_213,
      I1 => prog_adr_dup0_2_F,
      O => prog_adr_dup0_2_XORF_212
    );
  prog_adr_dup0_2_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      IA => prog_adr_dup0_2_CY0F_214,
      IB => prog_adr_dup0_2_CYINIT_213,
      SEL => prog_adr_dup0_2_CYSELF_218,
      O => pc_i_ix5_modgen_add_0_ix62171z63345_O
    );
  prog_adr_dup0_2_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      IA => prog_adr_dup0_2_CY0F_214,
      IB => prog_adr_dup0_2_CY0F_214,
      SEL => prog_adr_dup0_2_CYSELF_218,
      O => prog_adr_dup0_2_CYMUXF2_223
    );
  prog_adr_dup0_2_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_ix5_modgen_add_0_ix62171z63346_O,
      O => prog_adr_dup0_2_CYINIT_213
    );
  prog_adr_dup0_2_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z10_0,
      O => prog_adr_dup0_2_CY0F_214
    );
  prog_adr_dup0_2_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_F,
      O => prog_adr_dup0_2_CYSELF_218
    );
  prog_adr_dup0_2_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_GYMUX_216,
      O => prog_adr_dup0_2_DYMUX_215
    );
  prog_adr_dup0_2_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_XORG_217,
      O => prog_adr_dup0_2_GYMUX_216
    );
  prog_adr_dup0_2_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      I0 => pc_i_ix5_modgen_add_0_ix62171z63345_O,
      I1 => prog_adr_dup0_2_G,
      O => prog_adr_dup0_2_XORG_217
    );
  prog_adr_dup0_2_COUTUSED : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_CYMUXFAST_219,
      O => pc_i_ix5_modgen_add_0_ix62171z63344_O
    );
  prog_adr_dup0_2_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_ix5_modgen_add_0_ix62171z63346_O,
      O => prog_adr_dup0_2_FASTCARRY_221
    );
  prog_adr_dup0_2_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      I0 => prog_adr_dup0_2_CYSELG_225,
      I1 => prog_adr_dup0_2_CYSELF_218,
      O => prog_adr_dup0_2_CYAND_220
    );
  prog_adr_dup0_2_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      IA => prog_adr_dup0_2_CYMUXG2_222,
      IB => prog_adr_dup0_2_FASTCARRY_221,
      SEL => prog_adr_dup0_2_CYAND_220,
      O => prog_adr_dup0_2_CYMUXFAST_219
    );
  prog_adr_dup0_2_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y15"
    )
    port map (
      IA => prog_adr_dup0_2_CY0G_224,
      IB => prog_adr_dup0_2_CYMUXF2_223,
      SEL => prog_adr_dup0_2_CYSELG_225,
      O => prog_adr_dup0_2_CYMUXG2_222
    );
  prog_adr_dup0_2_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z11_0,
      O => prog_adr_dup0_2_CY0G_224
    );
  prog_adr_dup0_2_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_G,
      O => prog_adr_dup0_2_CYSELG_225
    );
  prog_adr_dup0_2_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_dup0_2_SRINV_226
    );
  prog_adr_dup0_2_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_dup0_2_CLKINV_227
    );
  prog_adr_dup0_4_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_FXMUX_229,
      O => prog_adr_dup0_4_DXMUX_228
    );
  prog_adr_dup0_4_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_XORF_230,
      O => prog_adr_dup0_4_FXMUX_229
    );
  prog_adr_dup0_4_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      I0 => prog_adr_dup0_4_CYINIT_231,
      I1 => prog_adr_dup0_4_F,
      O => prog_adr_dup0_4_XORF_230
    );
  prog_adr_dup0_4_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      IA => prog_adr_dup0_4_CY0F_232,
      IB => prog_adr_dup0_4_CYINIT_231,
      SEL => prog_adr_dup0_4_CYSELF_236,
      O => pc_i_ix5_modgen_add_0_ix62171z63343_O
    );
  prog_adr_dup0_4_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      IA => prog_adr_dup0_4_CY0F_232,
      IB => prog_adr_dup0_4_CY0F_232,
      SEL => prog_adr_dup0_4_CYSELF_236,
      O => prog_adr_dup0_4_CYMUXF2_241
    );
  prog_adr_dup0_4_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_ix5_modgen_add_0_ix62171z63344_O,
      O => prog_adr_dup0_4_CYINIT_231
    );
  prog_adr_dup0_4_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z12_0,
      O => prog_adr_dup0_4_CY0F_232
    );
  prog_adr_dup0_4_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_F,
      O => prog_adr_dup0_4_CYSELF_236
    );
  prog_adr_dup0_4_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_GYMUX_234,
      O => prog_adr_dup0_4_DYMUX_233
    );
  prog_adr_dup0_4_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_XORG_235,
      O => prog_adr_dup0_4_GYMUX_234
    );
  prog_adr_dup0_4_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      I0 => pc_i_ix5_modgen_add_0_ix62171z63343_O,
      I1 => prog_adr_dup0_4_G,
      O => prog_adr_dup0_4_XORG_235
    );
  prog_adr_dup0_4_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => pc_i_ix5_modgen_add_0_ix62171z63344_O,
      O => prog_adr_dup0_4_FASTCARRY_239
    );
  prog_adr_dup0_4_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      I0 => prog_adr_dup0_4_CYSELG_243,
      I1 => prog_adr_dup0_4_CYSELF_236,
      O => prog_adr_dup0_4_CYAND_238
    );
  prog_adr_dup0_4_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      IA => prog_adr_dup0_4_CYMUXG2_240,
      IB => prog_adr_dup0_4_FASTCARRY_239,
      SEL => prog_adr_dup0_4_CYAND_238,
      O => prog_adr_dup0_4_CYMUXFAST_237
    );
  prog_adr_dup0_4_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X16Y16"
    )
    port map (
      IA => prog_adr_dup0_4_CY0G_242,
      IB => prog_adr_dup0_4_CYMUXF2_241,
      SEL => prog_adr_dup0_4_CYSELG_243,
      O => prog_adr_dup0_4_CYMUXG2_240
    );
  prog_adr_dup0_4_CY0G : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z13_0,
      O => prog_adr_dup0_4_CY0G_242
    );
  prog_adr_dup0_4_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_G,
      O => prog_adr_dup0_4_CYSELG_243
    );
  prog_adr_dup0_4_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_dup0_4_SRINV_244
    );
  prog_adr_dup0_4_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_dup0_4_CLKINV_245
    );
  alu_i_nx15378z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx15378z2,
      O => alu_i_nx15378z2_0
    );
  alu_i_nx15378z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X12Y12",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_result_int_0n8ss1_2_pack_1,
      O => alu_i_result_int_0n8ss1(2)
    );
  alu_i_ix15378z1467 : X_LUT4
    generic map(
      INIT => X"9696",
      LOC => "SLICE_X12Y12"
    )
    port map (
      ADR0 => datmem_data_out_dup0(2),
      ADR1 => b_dup0(2),
      ADR2 => alu_i_nx20363z6,
      ADR3 => VCC,
      O => alu_i_result_int_0n8ss1_2_pack_1
    );
  prog_adr_dup0_6_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_FXMUX_247,
      O => prog_adr_dup0_6_DXMUX_246
    );
  prog_adr_dup0_6_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_XORF_248,
      O => prog_adr_dup0_6_FXMUX_247
    );
  prog_adr_dup0_6_XORF : X_XOR2
    generic map(
      LOC => "SLICE_X16Y17"
    )
    port map (
      I0 => prog_adr_dup0_6_CYINIT_249,
      I1 => prog_adr_dup0_6_F,
      O => prog_adr_dup0_6_XORF_248
    );
  prog_adr_dup0_6_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X16Y17"
    )
    port map (
      IA => prog_adr_dup0_6_CY0F_250,
      IB => prog_adr_dup0_6_CYINIT_249,
      SEL => prog_adr_dup0_6_CYSELF_251,
      O => pc_i_ix5_modgen_add_0_ix62171z63341_O
    );
  prog_adr_dup0_6_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_CYMUXFAST_237,
      O => prog_adr_dup0_6_CYINIT_249
    );
  prog_adr_dup0_6_CY0F : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx62171z14_0,
      O => prog_adr_dup0_6_CY0F_250
    );
  prog_adr_dup0_6_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_F,
      O => prog_adr_dup0_6_CYSELF_251
    );
  prog_adr_dup0_6_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_GYMUX_253,
      O => prog_adr_dup0_6_DYMUX_252
    );
  prog_adr_dup0_6_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_XORG_254,
      O => prog_adr_dup0_6_GYMUX_253
    );
  prog_adr_dup0_6_XORG : X_XOR2
    generic map(
      LOC => "SLICE_X16Y17"
    )
    port map (
      I0 => pc_i_ix5_modgen_add_0_ix62171z63341_O,
      I1 => nx62171z15,
      O => prog_adr_dup0_6_XORG_254
    );
  prog_adr_dup0_6_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_dup0_6_SRINV_255
    );
  prog_adr_dup0_6_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X16Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_dup0_6_CLKINV_256
    );
  ix62171z1546 : X_LUT4
    generic map(
      INIT => X"AFA0",
      LOC => "SLICE_X16Y17"
    )
    port map (
      ADR0 => prog_data_int(7),
      ADR1 => VCC,
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => prog_adr_dup0(7),
      O => nx62171z15
    );
  control_i_nx27714z2_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z2,
      O => control_i_nx27714z2_0
    );
  control_i_nx27714z2_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X2Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z4_pack_1,
      O => control_i_nx27714z4
    );
  control_i_ix27714z1328 : X_LUT4
    generic map(
      INIT => X"F0FF",
      LOC => "SLICE_X2Y21"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => prog_data_int(7),
      ADR3 => prog_data_int(6),
      O => control_i_nx27714z4_pack_1
    );
  alu_i_ix49743z63350_O_LOGIC_ONE : X_ONE
    generic map(
      LOC => "SLICE_X8Y14"
    )
    port map (
      O => alu_i_ix49743z63350_O_LOGIC_ONE_260
    );
  alu_i_ix49743z63350_O_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X8Y14"
    )
    port map (
      IA => alu_i_ix49743z63350_O_LOGIC_ONE_260,
      IB => alu_i_ix49743z63350_O_CYINIT_257,
      SEL => alu_i_ix49743z63350_O_CYSELF_258,
      O => alu_i_ix49743z63351_O
    );
  alu_i_ix49743z63350_O_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X8Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => GLOBAL_LOGIC0,
      O => alu_i_ix49743z63350_O_CYINIT_257
    );
  alu_i_ix49743z63350_O_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X8Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1581_O,
      O => alu_i_ix49743z63350_O_CYSELF_258
    );
  alu_i_ix49743z63350_O_CYMUXG : X_MUX2
    generic map(
      LOC => "SLICE_X8Y14"
    )
    port map (
      IA => alu_i_ix49743z63350_O_LOGIC_ONE_260,
      IB => alu_i_ix49743z63351_O,
      SEL => alu_i_ix49743z63350_O_CYSELG_261,
      O => alu_i_ix49743z63350_O_CYMUXG_259
    );
  alu_i_ix49743z63350_O_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X8Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1360_O,
      O => alu_i_ix49743z63350_O_CYSELG_261
    );
  alu_i_ix49743z63348_O_LOGIC_ONE : X_ONE
    generic map(
      LOC => "SLICE_X8Y15"
    )
    port map (
      O => alu_i_ix49743z63348_O_LOGIC_ONE_268
    );
  alu_i_ix49743z63348_O_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X8Y15"
    )
    port map (
      IA => alu_i_ix49743z63348_O_LOGIC_ONE_268,
      IB => alu_i_ix49743z63348_O_LOGIC_ONE_268,
      SEL => alu_i_ix49743z63348_O_CYSELF_262,
      O => alu_i_ix49743z63348_O_CYMUXF2_267
    );
  alu_i_ix49743z63348_O_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X8Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1595_O,
      O => alu_i_ix49743z63348_O_CYSELF_262
    );
  alu_i_ix49743z63348_O_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X8Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z63350_O_CYMUXG_259,
      O => alu_i_ix49743z63348_O_FASTCARRY_265
    );
  alu_i_ix49743z63348_O_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X8Y15"
    )
    port map (
      I0 => alu_i_ix49743z63348_O_CYSELG_269,
      I1 => alu_i_ix49743z63348_O_CYSELF_262,
      O => alu_i_ix49743z63348_O_CYAND_264
    );
  alu_i_ix49743z63348_O_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X8Y15"
    )
    port map (
      IA => alu_i_ix49743z63348_O_CYMUXG2_266,
      IB => alu_i_ix49743z63348_O_FASTCARRY_265,
      SEL => alu_i_ix49743z63348_O_CYAND_264,
      O => alu_i_ix49743z63348_O_CYMUXFAST_263
    );
  alu_i_ix49743z63348_O_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X8Y15"
    )
    port map (
      IA => alu_i_ix49743z63348_O_LOGIC_ONE_268,
      IB => alu_i_ix49743z63348_O_CYMUXF2_267,
      SEL => alu_i_ix49743z63348_O_CYSELG_269,
      O => alu_i_ix49743z63348_O_CYMUXG2_266
    );
  alu_i_ix49743z63348_O_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X8Y15",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1342_O,
      O => alu_i_ix49743z63348_O_CYSELG_269
    );
  datmem_data_out_dup0_7_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_7_FXMUX_271,
      O => datmem_data_out_dup0_7_DXMUX_270
    );
  datmem_data_out_dup0_7_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_7_FXMUX_271,
      O => reg_i_a_out_1n1ss1_7_0
    );
  datmem_data_out_dup0_7_FXMUX : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1(7),
      O => datmem_data_out_dup0_7_FXMUX_271
    );
  datmem_data_out_dup0_7_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => result_alu_reg_7_pack_1,
      O => result_alu_reg(7)
    );
  datmem_data_out_dup0_7_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_dup0_7_SRINV_272
    );
  datmem_data_out_dup0_7_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_out_dup0_7_CLKINV_273
    );
  datmem_data_out_dup0_7_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X9Y19",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_dup0_7_CEINV_274
    );
  alu_i_ix49743z63346_O_LOGIC_ONE : X_ONE
    generic map(
      LOC => "SLICE_X8Y16"
    )
    port map (
      O => alu_i_ix49743z63346_O_LOGIC_ONE_281
    );
  alu_i_ix49743z63346_O_CYMUXF2 : X_MUX2
    generic map(
      LOC => "SLICE_X8Y16"
    )
    port map (
      IA => alu_i_ix49743z63346_O_LOGIC_ONE_281,
      IB => alu_i_ix49743z63346_O_LOGIC_ONE_281,
      SEL => alu_i_ix49743z63346_O_CYSELF_275,
      O => alu_i_ix49743z63346_O_CYMUXF2_280
    );
  alu_i_ix49743z63346_O_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X8Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1340_O,
      O => alu_i_ix49743z63346_O_CYSELF_275
    );
  alu_i_ix49743z63346_O_FASTCARRY : X_BUF
    generic map(
      LOC => "SLICE_X8Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z63348_O_CYMUXFAST_263,
      O => alu_i_ix49743z63346_O_FASTCARRY_278
    );
  alu_i_ix49743z63346_O_CYAND : X_AND2
    generic map(
      LOC => "SLICE_X8Y16"
    )
    port map (
      I0 => alu_i_ix49743z63346_O_CYSELG_282,
      I1 => alu_i_ix49743z63346_O_CYSELF_275,
      O => alu_i_ix49743z63346_O_CYAND_277
    );
  alu_i_ix49743z63346_O_CYMUXFAST : X_MUX2
    generic map(
      LOC => "SLICE_X8Y16"
    )
    port map (
      IA => alu_i_ix49743z63346_O_CYMUXG2_279,
      IB => alu_i_ix49743z63346_O_FASTCARRY_278,
      SEL => alu_i_ix49743z63346_O_CYAND_277,
      O => alu_i_ix49743z63346_O_CYMUXFAST_276
    );
  alu_i_ix49743z63346_O_CYMUXG2 : X_MUX2
    generic map(
      LOC => "SLICE_X8Y16"
    )
    port map (
      IA => alu_i_ix49743z63346_O_LOGIC_ONE_281,
      IB => alu_i_ix49743z63346_O_CYMUXF2_280,
      SEL => alu_i_ix49743z63346_O_CYSELG_282,
      O => alu_i_ix49743z63346_O_CYMUXG2_279
    );
  alu_i_ix49743z63346_O_CYSELG : X_BUF
    generic map(
      LOC => "SLICE_X8Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z1394_O,
      O => alu_i_ix49743z63346_O_CYSELG_282
    );
  zflag_dup0_LOGIC_ONE : X_ONE
    generic map(
      LOC => "SLICE_X8Y17"
    )
    port map (
      O => zflag_dup0_LOGIC_ONE_283
    );
  zflag_dup0_CYMUXF : X_MUX2
    generic map(
      LOC => "SLICE_X8Y17"
    )
    port map (
      IA => zflag_dup0_LOGIC_ONE_283,
      IB => zflag_dup0_CYINIT_284,
      SEL => zflag_dup0_CYSELF_285,
      O => alu_i_ix49743z63345_O
    );
  zflag_dup0_CYINIT : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z63346_O_CYMUXFAST_276,
      O => zflag_dup0_CYINIT_284
    );
  zflag_dup0_CYSELF : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_ix49743z4435_O,
      O => zflag_dup0_CYSELF_285
    );
  zflag_dup0_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => zflag_dup0_GYMUX_287,
      O => zflag_dup0_DYMUX_286
    );
  zflag_dup0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => zflag_dup0_GYMUX_287,
      O => zero_alu_reg_0
    );
  zflag_dup0_GYMUX : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => zero_alu_reg,
      O => zflag_dup0_GYMUX_287
    );
  zflag_dup0_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => zflag_dup0_SRINV_288
    );
  zflag_dup0_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => zflag_dup0_CLKINV_289
    );
  zflag_dup0_CEINV : X_BUF
    generic map(
      LOC => "SLICE_X8Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx56395z1_0,
      O => zflag_dup0_CEINV_290
    );
  alu_i_ix49743z1060 : X_LUT4
    generic map(
      INIT => X"AABA",
      LOC => "SLICE_X8Y17"
    )
    port map (
      ADR0 => alu_i_ix49743z63345_O,
      ADR1 => alu_i_nx49743z1_0,
      ADR2 => control_int_fsm(9),
      ADR3 => alu_i_result_int_0n8ss1_7_0,
      O => zero_alu_reg
    );
  control_int_fsm_9_DXMUX : X_BUF
    generic map(
      LOC => "SLICE_X4Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx51041z1,
      O => control_int_fsm_9_DXMUX_291
    );
  control_int_fsm_9_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx51041z2_pack_1,
      O => control_i_nx51041z2
    );
  control_int_fsm_9_SRINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => control_int_fsm_9_SRINV_292
    );
  control_int_fsm_9_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X4Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => control_int_fsm_9_CLKINV_293
    );
  control_i_nxt_state_2n8ss1_0_F5USED : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nxt_state_2n8ss1_0_F5MUX_294,
      O => control_i_nxt_state_mux_2i1_nx_mx8_f6_1
    );
  control_i_nxt_state_2n8ss1_0_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X0Y22"
    )
    port map (
      IA => control_i_nxt_state_mux_2i1_nx_mx8_l3_2,
      IB => control_i_nxt_state_2n8ss1_0_F,
      SEL => control_i_nxt_state_2n8ss1_0_BXINV_295,
      O => control_i_nxt_state_2n8ss1_0_F5MUX_294
    );
  control_i_nxt_state_2n8ss1_0_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(6),
      O => control_i_nxt_state_2n8ss1_0_BXINV_295
    );
  control_i_nxt_state_2n8ss1_0_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nxt_state_2n8ss1_0_F6MUX_296,
      O => control_i_nxt_state_2n8ss1(0)
    );
  control_i_nxt_state_2n8ss1_0_F6MUX : X_MUX2
    generic map(
      LOC => "SLICE_X0Y22"
    )
    port map (
      IA => control_i_nxt_state_mux_2i1_nx_mx8_f6_0,
      IB => control_i_nxt_state_mux_2i1_nx_mx8_f6_1,
      SEL => control_i_nxt_state_2n8ss1_0_BYINV_297,
      O => control_i_nxt_state_2n8ss1_0_F6MUX_296
    );
  control_i_nxt_state_2n8ss1_0_BYINV : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(7),
      O => control_i_nxt_state_2n8ss1_0_BYINV_297
    );
  control_i_ix42068z1525 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X0Y22"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_int(5),
      ADR2 => control_i_nx42068z3_0,
      ADR3 => control_i_nx28711z4_0,
      O => control_i_nxt_state_mux_2i1_nx_mx8_l3_2
    );
  control_i_nxt_state_mux_2i1_nx_mx8_f6_0_F5USED : X_BUF
    generic map(
      LOC => "SLICE_X0Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nxt_state_mux_2i1_nx_mx8_f6_0_F5MUX_298,
      O => control_i_nxt_state_mux_2i1_nx_mx8_f6_0
    );
  control_i_nxt_state_mux_2i1_nx_mx8_f6_0_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X0Y23"
    )
    port map (
      IA => control_i_nxt_state_mux_2i1_nx_mx8_l3_0,
      IB => control_i_nxt_state_mux_2i1_nx_mx8_l3_1,
      SEL => control_i_nxt_state_mux_2i1_nx_mx8_f6_0_BXINV_299,
      O => control_i_nxt_state_mux_2i1_nx_mx8_f6_0_F5MUX_298
    );
  control_i_nxt_state_mux_2i1_nx_mx8_f6_0_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X0Y23",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(6),
      O => control_i_nxt_state_mux_2i1_nx_mx8_f6_0_BXINV_299
    );
  control_i_nx51041z3_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X5Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx51041z3,
      O => control_i_nx51041z3_0
    );
  control_i_ix51041z1330 : X_LUT4
    generic map(
      INIT => X"FFF0",
      LOC => "SLICE_X5Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => control_int_fsm(21),
      ADR3 => control_int_fsm(20),
      O => control_i_nx51041z3
    );
  prog_adr_obuf_0_Q : X_OBUF
    generic map(
      LOC => "PAD53"
    )
    port map (
      I => prog_adr_0_O,
      O => prog_adr(0)
    );
  prog_adr_0_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD53",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_0_OUTPUT_OTCLK1INV_300
    );
  nx38625z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X6Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1,
      O => nx38625z1_0
    );
  ix38625z1328 : X_LUT4
    generic map(
      INIT => X"FFCC",
      LOC => "SLICE_X6Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(14),
      ADR2 => VCC,
      ADR3 => control_int_fsm(16),
      O => nx38625z1
    );
  prog_adr_obuf_1_Q : X_OBUF
    generic map(
      LOC => "PAD52"
    )
    port map (
      I => prog_adr_1_O,
      O => prog_adr(1)
    );
  prog_adr_1_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD52",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_1_OUTPUT_OTCLK1INV_301
    );
  ram_control_i_p_clk_DYMUX : X_BUF
    generic map(
      LOC => "SLICE_X2Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => ram_control_i_n_clk,
      O => ram_control_i_p_clk_DYMUX_302
    );
  ram_control_i_p_clk_CLKINV : X_BUF
    generic map(
      LOC => "SLICE_X2Y17",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => ram_control_i_p_clk_CLKINV_303
    );
  prog_adr_obuf_2_Q : X_OBUF
    generic map(
      LOC => "PAD51"
    )
    port map (
      I => prog_adr_2_O,
      O => prog_adr(2)
    );
  prog_adr_2_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD51",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_2_OUTPUT_OTCLK1INV_304
    );
  prog_adr_obuf_3_Q : X_OBUF
    generic map(
      LOC => "PAD50"
    )
    port map (
      I => prog_adr_3_O,
      O => prog_adr(3)
    );
  prog_adr_3_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD50",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_3_OUTPUT_OTCLK1INV_305
    );
  alu_i_nx20363z8_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z8,
      O => alu_i_nx20363z8_0
    );
  alu_i_nx20363z8_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X8Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z36_pack_1,
      O => alu_i_nx20363z36
    );
  alu_i_ix20363z53223 : X_LUT4
    generic map(
      INIT => X"B8C0",
      LOC => "SLICE_X8Y18"
    )
    port map (
      ADR0 => control_int_fsm(3),
      ADR1 => datmem_data_out_dup0(7),
      ADR2 => control_int_fsm(4),
      ADR3 => b_dup0(7),
      O => alu_i_nx20363z36_pack_1
    );
  prog_data_ibuf_0_Q : X_BUF
    generic map(
      LOC => "PAD117",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(0),
      O => prog_data_0_INBUF
    );
  prog_data_0_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD117",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_0_INBUF,
      O => prog_data_0_IFF_IFFDMUX_308
    );
  prog_data_0_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD117",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_0_INBUF,
      O => prog_data_int(0)
    );
  prog_data_0_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD117",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_0_IFF_ISR_USED_306
    );
  prog_data_0_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD117",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_0_IFF_ICLK1INV_307
    );
  clk_ibuf_IBUFG : X_BUF
    generic map(
      LOC => "PAD15",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk,
      O => clk_INBUF
    );
  alu_i_nx20363z12_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y18",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z12,
      O => alu_i_nx20363z12_0
    );
  alu_i_ix20363z1325 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y18"
    )
    port map (
      ADR0 => control_int_fsm(19),
      ADR1 => control_int_fsm(18),
      ADR2 => control_int_fsm(17),
      ADR3 => control_int_fsm(12),
      O => alu_i_nx20363z12
    );
  prog_adr_obuf_4_Q : X_OBUF
    generic map(
      LOC => "PAD49"
    )
    port map (
      I => prog_adr_4_O,
      O => prog_adr(4)
    );
  prog_adr_4_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD49",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_4_OUTPUT_OTCLK1INV_309
    );
  alu_i_nx20363z13_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y22",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z13,
      O => alu_i_nx20363z13_0
    );
  alu_i_ix20363z1326 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y22"
    )
    port map (
      ADR0 => control_int_fsm(11),
      ADR1 => control_int_fsm(10),
      ADR2 => control_int_fsm(1),
      ADR3 => control_int_fsm(0),
      O => alu_i_nx20363z13
    );
  prog_data_ibuf_1_Q : X_BUF
    generic map(
      LOC => "PAD116",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(1),
      O => prog_data_1_INBUF
    );
  prog_data_1_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD116",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_INBUF,
      O => prog_data_1_IFF_IFFDMUX_312
    );
  prog_data_1_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD116",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_1_INBUF,
      O => prog_data_int(1)
    );
  prog_data_1_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD116",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_1_IFF_ISR_USED_310
    );
  prog_data_1_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD116",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_1_IFF_ICLK1INV_311
    );
  rst_int_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X13Y4",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int,
      O => rst_int_0
    );
  ix44771z1321 : X_LUT4
    generic map(
      INIT => X"33FF",
      LOC => "SLICE_X13Y4"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nreset_int_int_int,
      ADR2 => VCC,
      ADR3 => nreset_int_int,
      O => rst_int
    );
  prog_adr_obuf_5_Q : X_OBUF
    generic map(
      LOC => "PAD48"
    )
    port map (
      I => prog_adr_5_O,
      O => prog_adr(5)
    );
  prog_adr_5_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD48",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_5_OUTPUT_OTCLK1INV_313
    );
  prog_data_ibuf_2_Q : X_BUF
    generic map(
      LOC => "PAD118",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(2),
      O => prog_data_2_INBUF
    );
  control_i_nx27714z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X9Y20",
      PATHPULSE => 757 ps
    )
    port map (
      I => control_i_nx27714z5,
      O => control_i_nx27714z5_0
    );
  control_i_ix27714z1534 : X_LUT4
    generic map(
      INIT => X"CCAA",
      LOC => "SLICE_X9Y20"
    )
    port map (
      ADR0 => zflag_dup0,
      ADR1 => zero_alu_reg_0,
      ADR2 => VCC,
      ADR3 => flagz_alu_control_0,
      O => control_i_nx27714z5
    );
  prog_adr_obuf_6_Q : X_OBUF
    generic map(
      LOC => "PAD47"
    )
    port map (
      I => prog_adr_6_O,
      O => prog_adr(6)
    );
  prog_adr_6_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD47",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_6_OUTPUT_OTCLK1INV_314
    );
  alu_i_nx51436z5_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx51436z5,
      O => alu_i_nx51436z5_0
    );
  alu_i_nx51436z5_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X10Y21",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx51436z6_pack_1,
      O => alu_i_nx51436z6
    );
  alu_i_ix51436z1322 : X_LUT4
    generic map(
      INIT => X"0055",
      LOC => "SLICE_X10Y21"
    )
    port map (
      ADR0 => b_dup0(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => datmem_data_out_dup0(7),
      O => alu_i_nx51436z6_pack_1
    );
  prog_data_ibuf_3_Q : X_BUF
    generic map(
      LOC => "PAD119",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(3),
      O => prog_data_3_INBUF
    );
  prog_data_3_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD119",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_3_INBUF,
      O => prog_data_3_IFF_IFFDMUX_317
    );
  prog_data_3_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD119",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_3_INBUF,
      O => prog_data_int(3)
    );
  prog_data_3_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD119",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_3_IFF_ISR_USED_315
    );
  prog_data_3_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD119",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_3_IFF_ICLK1INV_316
    );
  alu_i_nx51436z1_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx51436z1,
      O => alu_i_nx51436z1_0
    );
  alu_i_nx51436z1_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X4Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagc_alu_control_pack_1,
      O => flagc_alu_control
    );
  alu_i_ix51436z1314 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y16"
    )
    port map (
      ADR0 => control_int_fsm(9),
      ADR1 => control_int_fsm(7),
      ADR2 => control_int_fsm(6),
      ADR3 => control_int_fsm(8),
      O => flagc_alu_control_pack_1
    );
  prog_adr_obuf_7_Q : X_OBUF
    generic map(
      LOC => "PAD46"
    )
    port map (
      I => prog_adr_7_O,
      O => prog_adr(7)
    );
  prog_adr_7_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD46",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_adr_7_OUTPUT_OTCLK1INV_318
    );
  prog_data_ibuf_4_Q : X_BUF
    generic map(
      LOC => "PAD120",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(4),
      O => prog_data_4_INBUF
    );
  prog_data_4_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD120",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_4_INBUF,
      O => prog_data_4_IFF_IFFDMUX_321
    );
  prog_data_4_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD120",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_4_INBUF,
      O => prog_data_int(4)
    );
  prog_data_4_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD120",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_4_IFF_ISR_USED_319
    );
  prog_data_4_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD120",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_4_IFF_ICLK1INV_320
    );
  alu_i_nx13384z4_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx13384z4,
      O => alu_i_nx13384z4_0
    );
  alu_i_nx13384z4_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y14",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z16_pack_1,
      O => alu_i_nx20363z16
    );
  alu_i_ix20363z1345 : X_LUT4
    generic map(
      INIT => X"EEEE",
      LOC => "SLICE_X7Y14"
    )
    port map (
      ADR0 => control_int_fsm(16),
      ADR1 => control_int_fsm(15),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_nx20363z16_pack_1
    );
  prog_data_ibuf_5_Q : X_BUF
    generic map(
      LOC => "PAD121",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(5),
      O => prog_data_5_INBUF
    );
  prog_data_5_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD121",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_INBUF,
      O => prog_data_5_IFF_IFFDMUX_324
    );
  prog_data_5_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD121",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_5_INBUF,
      O => prog_data_int(5)
    );
  prog_data_5_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD121",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_5_IFF_ISR_USED_322
    );
  prog_data_5_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD121",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_5_IFF_ICLK1INV_323
    );
  prog_data_ibuf_6_Q : X_BUF
    generic map(
      LOC => "PAD124",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(6),
      O => prog_data_6_INBUF
    );
  prog_data_6_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD124",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_6_INBUF,
      O => prog_data_6_IFF_IFFDMUX_327
    );
  prog_data_6_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD124",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_6_INBUF,
      O => prog_data_int(6)
    );
  prog_data_6_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD124",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_6_IFF_ISR_USED_325
    );
  prog_data_6_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD124",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_6_IFF_ICLK1INV_326
    );
  alu_i_nx49743z23_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx49743z23,
      O => alu_i_nx49743z23_0
    );
  alu_i_nx49743z23_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X7Y16",
      PATHPULSE => 757 ps
    )
    port map (
      I => alu_i_nx20363z17_pack_1,
      O => alu_i_nx20363z17
    );
  alu_i_ix20363z1346 : X_LUT4
    generic map(
      INIT => X"FFF0",
      LOC => "SLICE_X7Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => control_int_fsm(7),
      ADR3 => control_int_fsm(6),
      O => alu_i_nx20363z17_pack_1
    );
  prog_data_ibuf_7_Q : X_BUF
    generic map(
      LOC => "PAD123",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data(7),
      O => prog_data_7_INBUF
    );
  prog_data_7_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD123",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_7_INBUF,
      O => prog_data_7_IFF_IFFDMUX_330
    );
  prog_data_7_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD123",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_7_INBUF,
      O => prog_data_int(7)
    );
  prog_data_7_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD123",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_7_IFF_ISR_USED_328
    );
  prog_data_7_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD123",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_7_IFF_ICLK1INV_329
    );
  ram_control_i_reg_ram_data_reg_0_Q : X_FF
    generic map(
      LOC => "PAD23",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_0_IFF_IFFDMUX_333,
      CE => datmem_data_in_0_IFF_ICEINV_332,
      CLK => datmem_data_in_0_IFF_ICLK1INV_331,
      SET => GND,
      RST => GND,
      O => ram_data_reg(0)
    );
  datmem_data_in_0_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD23",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_0_INBUF,
      O => datmem_data_in_0_IFF_IFFDMUX_333
    );
  datmem_data_in_0_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD23",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_0_IFF_ICLK1INV_331
    );
  datmem_data_in_0_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD23",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_0_IFF_ICEINV_332
    );
  ram_control_i_reg_ram_data_reg_1_Q : X_FF
    generic map(
      LOC => "PAD20",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_1_IFF_IFFDMUX_336,
      CE => datmem_data_in_1_IFF_ICEINV_335,
      CLK => datmem_data_in_1_IFF_ICLK1INV_334,
      SET => GND,
      RST => GND,
      O => ram_data_reg(1)
    );
  datmem_data_in_1_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD20",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_1_INBUF,
      O => datmem_data_in_1_IFF_IFFDMUX_336
    );
  datmem_data_in_1_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD20",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_1_IFF_ICLK1INV_334
    );
  datmem_data_in_1_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD20",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_1_IFF_ICEINV_335
    );
  ram_control_i_reg_ram_data_reg_2_Q : X_FF
    generic map(
      LOC => "PAD113",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_2_IFF_IFFDMUX_339,
      CE => datmem_data_in_2_IFF_ICEINV_338,
      CLK => datmem_data_in_2_IFF_ICLK1INV_337,
      SET => GND,
      RST => GND,
      O => ram_data_reg(2)
    );
  datmem_data_in_2_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD113",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_2_INBUF,
      O => datmem_data_in_2_IFF_IFFDMUX_339
    );
  datmem_data_in_2_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD113",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_2_IFF_ICLK1INV_337
    );
  datmem_data_in_2_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD113",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_2_IFF_ICEINV_338
    );
  ram_control_i_reg_ram_data_reg_3_Q : X_FF
    generic map(
      LOC => "PAD108",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_3_IFF_IFFDMUX_342,
      CE => datmem_data_in_3_IFF_ICEINV_341,
      CLK => datmem_data_in_3_IFF_ICLK1INV_340,
      SET => GND,
      RST => GND,
      O => ram_data_reg(3)
    );
  datmem_data_in_3_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD108",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_3_INBUF,
      O => datmem_data_in_3_IFF_IFFDMUX_342
    );
  datmem_data_in_3_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD108",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_3_IFF_ICLK1INV_340
    );
  datmem_data_in_3_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD108",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_3_IFF_ICEINV_341
    );
  ram_control_i_reg_ram_data_reg_4_Q : X_FF
    generic map(
      LOC => "PAD109",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_4_IFF_IFFDMUX_345,
      CE => datmem_data_in_4_IFF_ICEINV_344,
      CLK => datmem_data_in_4_IFF_ICLK1INV_343,
      SET => GND,
      RST => GND,
      O => ram_data_reg(4)
    );
  datmem_data_in_4_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD109",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_4_INBUF,
      O => datmem_data_in_4_IFF_IFFDMUX_345
    );
  datmem_data_in_4_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD109",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_4_IFF_ICLK1INV_343
    );
  datmem_data_in_4_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD109",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_4_IFF_ICEINV_344
    );
  ram_control_i_reg_ram_data_reg_5_Q : X_FF
    generic map(
      LOC => "PAD110",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_5_IFF_IFFDMUX_348,
      CE => datmem_data_in_5_IFF_ICEINV_347,
      CLK => datmem_data_in_5_IFF_ICLK1INV_346,
      SET => GND,
      RST => GND,
      O => ram_data_reg(5)
    );
  datmem_data_in_5_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD110",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_5_INBUF,
      O => datmem_data_in_5_IFF_IFFDMUX_348
    );
  datmem_data_in_5_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD110",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_5_IFF_ICLK1INV_346
    );
  datmem_data_in_5_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD110",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_5_IFF_ICEINV_347
    );
  ram_control_i_reg_ram_data_reg_6_Q : X_FF
    generic map(
      LOC => "PAD111",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_6_IFF_IFFDMUX_351,
      CE => datmem_data_in_6_IFF_ICEINV_350,
      CLK => datmem_data_in_6_IFF_ICLK1INV_349,
      SET => GND,
      RST => GND,
      O => ram_data_reg(6)
    );
  datmem_data_in_6_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD111",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_6_INBUF,
      O => datmem_data_in_6_IFF_IFFDMUX_351
    );
  datmem_data_in_6_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD111",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_6_IFF_ICLK1INV_349
    );
  datmem_data_in_6_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD111",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_6_IFF_ICEINV_350
    );
  ram_control_i_reg_ram_data_reg_7_Q : X_FF
    generic map(
      LOC => "PAD112",
      INIT => '0'
    )
    port map (
      I => datmem_data_in_7_IFF_IFFDMUX_354,
      CE => datmem_data_in_7_IFF_ICEINV_353,
      CLK => datmem_data_in_7_IFF_ICLK1INV_352,
      SET => GND,
      RST => GND,
      O => ram_data_reg(7)
    );
  datmem_data_in_7_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD112",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_in_7_INBUF,
      O => datmem_data_in_7_IFF_IFFDMUX_354
    );
  datmem_data_in_7_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD112",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => datmem_data_in_7_IFF_ICLK1INV_352
    );
  datmem_data_in_7_IFF_ICEINV : X_BUF
    generic map(
      LOC => "PAD112",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx17594z1_0,
      O => datmem_data_in_7_IFF_ICEINV_353
    );
  alu_i_ix49743z1360 : X_LUT4
    generic map(
      INIT => X"FFFB",
      LOC => "SLICE_X8Y14"
    )
    port map (
      ADR0 => control_int_fsm(21),
      ADR1 => zflag_dup0,
      ADR2 => control_int_fsm(15),
      ADR3 => alu_i_nx49743z22,
      O => alu_i_ix49743z1360_O
    );
  alu_i_ix49743z1342 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y15"
    )
    port map (
      ADR0 => alu_i_nx49743z28_0,
      ADR1 => datmem_data_out_dup0(0),
      ADR2 => alu_i_nx49743z30_0,
      ADR3 => b_dup0(0),
      O => alu_i_ix49743z1342_O
    );
  alu_i_ix49743z1394 : X_LUT4
    generic map(
      INIT => X"EFFF",
      LOC => "SLICE_X8Y16"
    )
    port map (
      ADR0 => alu_i_nx49743z41_0,
      ADR1 => alu_i_nx49743z42_0,
      ADR2 => alu_i_nx49743z40_0,
      ADR3 => alu_i_nx49743z39_0,
      O => alu_i_ix49743z1394_O
    );
  control_i_ix42068z58621 : X_LUT4
    generic map(
      INIT => X"FB77",
      LOC => "SLICE_X0Y23"
    )
    port map (
      ADR0 => prog_data_int(2),
      ADR1 => prog_data_int(5),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(3),
      O => control_i_nxt_state_mux_2i1_nx_mx8_l3_0
    );
  datmem_data_out_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_0_repl2,
      O => datmem_data_out_0_O
    );
  datmem_data_out_0_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_0_OUTPUT_OFF_OSR_USED_355
    );
  datmem_data_out_0_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_0_OUTPUT_OFF_OCEINV_356
    );
  datmem_data_out_0_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD98",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_0_0,
      O => datmem_data_out_0_OUTPUT_OFF_O1INV_357
    );
  datmem_data_out_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_1_repl2,
      O => datmem_data_out_1_O
    );
  datmem_data_out_1_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_1_OUTPUT_OFF_OSR_USED_358
    );
  datmem_data_out_1_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_1_OUTPUT_OFF_OCEINV_359
    );
  datmem_data_out_1_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD99",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_1_0,
      O => datmem_data_out_1_OUTPUT_OFF_O1INV_360
    );
  datmem_data_out_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_2_repl2,
      O => datmem_data_out_2_O
    );
  datmem_data_out_2_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_2_OUTPUT_OFF_OSR_USED_361
    );
  datmem_data_out_2_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_2_OUTPUT_OFF_OCEINV_362
    );
  datmem_data_out_2_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD45",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_2_0,
      O => datmem_data_out_2_OUTPUT_OFF_O1INV_363
    );
  datmem_data_out_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_3_repl2,
      O => datmem_data_out_3_O
    );
  datmem_data_out_3_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_3_OUTPUT_OFF_OSR_USED_364
    );
  datmem_data_out_3_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_3_OUTPUT_OFF_OCEINV_365
    );
  datmem_data_out_3_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD44",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_3_0,
      O => datmem_data_out_3_OUTPUT_OFF_O1INV_366
    );
  datmem_data_out_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_4_repl2,
      O => datmem_data_out_4_O
    );
  datmem_data_out_4_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_4_OUTPUT_OFF_OSR_USED_367
    );
  datmem_data_out_4_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_4_OUTPUT_OFF_OCEINV_368
    );
  datmem_data_out_4_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD43",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_4_0,
      O => datmem_data_out_4_OUTPUT_OFF_O1INV_369
    );
  datmem_data_out_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_5_repl2,
      O => datmem_data_out_5_O
    );
  datmem_data_out_5_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_5_OUTPUT_OFF_OSR_USED_370
    );
  datmem_data_out_5_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_5_OUTPUT_OFF_OCEINV_371
    );
  datmem_data_out_5_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD42",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_5_0,
      O => datmem_data_out_5_OUTPUT_OFF_O1INV_372
    );
  datmem_data_out_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_6_repl2,
      O => datmem_data_out_6_O
    );
  datmem_data_out_6_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_6_OUTPUT_OFF_OSR_USED_373
    );
  datmem_data_out_6_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_6_OUTPUT_OFF_OCEINV_374
    );
  datmem_data_out_6_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD41",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_6_0,
      O => datmem_data_out_6_OUTPUT_OFF_O1INV_375
    );
  datmem_data_out_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_7_repl2,
      O => datmem_data_out_7_O
    );
  datmem_data_out_7_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => datmem_data_out_7_OUTPUT_OFF_OSR_USED_376
    );
  datmem_data_out_7_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => datmem_data_out_7_OUTPUT_OFF_OCEINV_377
    );
  datmem_data_out_7_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD40",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_7_0,
      O => datmem_data_out_7_OUTPUT_OFF_O1INV_378
    );
  a_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_0_repl1,
      O => a_0_O
    );
  a_0_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_0_OUTPUT_OFF_OSR_USED_379
    );
  a_0_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_0_OUTPUT_OFF_OCEINV_380
    );
  a_0_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD107",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_0_0,
      O => a_0_OUTPUT_OFF_O1INV_381
    );
  zflag_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => zflag_dup0_repl2,
      O => zflag_O
    );
  zflag_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => zflag_OUTPUT_OFF_OSR_USED_382
    );
  zflag_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx56395z1_0,
      O => zflag_OUTPUT_OFF_OCEINV_383
    );
  zflag_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD39",
      PATHPULSE => 757 ps
    )
    port map (
      I => zero_alu_reg_0,
      O => zflag_OUTPUT_OFF_O1INV_384
    );
  a_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_1_repl1,
      O => a_1_O
    );
  a_1_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_1_OUTPUT_OFF_OSR_USED_385
    );
  a_1_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_1_OUTPUT_OFF_OCEINV_386
    );
  a_1_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD106",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_1_0,
      O => a_1_OUTPUT_OFF_O1INV_387
    );
  a_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_2_repl1,
      O => a_2_O
    );
  a_2_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_2_OUTPUT_OFF_OSR_USED_388
    );
  a_2_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_2_OUTPUT_OFF_OCEINV_389
    );
  a_2_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD105",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_2_0,
      O => a_2_OUTPUT_OFF_O1INV_390
    );
  a_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_3_repl1,
      O => a_3_O
    );
  a_3_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_3_OUTPUT_OFF_OSR_USED_391
    );
  a_3_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_3_OUTPUT_OFF_OCEINV_392
    );
  a_3_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD104",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_3_0,
      O => a_3_OUTPUT_OFF_O1INV_393
    );
  a_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_4_repl1,
      O => a_4_O
    );
  a_4_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_4_OUTPUT_OFF_OSR_USED_394
    );
  a_4_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_4_OUTPUT_OFF_OCEINV_395
    );
  a_4_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD103",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_4_0,
      O => a_4_OUTPUT_OFF_O1INV_396
    );
  b_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_0_repl1,
      O => b_0_O
    );
  b_0_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_0_OUTPUT_OFF_OSR_USED_397
    );
  b_0_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_0_OUTPUT_OFF_OCEINV_398
    );
  b_0_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD56",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_1_GYMUX_43,
      O => b_0_OUTPUT_OFF_O1INV_399
    );
  a_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_5_repl1,
      O => a_5_O
    );
  a_5_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_5_OUTPUT_OFF_OSR_USED_400
    );
  a_5_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_5_OUTPUT_OFF_OCEINV_401
    );
  a_5_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD102",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_5_0,
      O => a_5_OUTPUT_OFF_O1INV_402
    );
  b_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_1_repl1,
      O => b_1_O
    );
  b_1_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_1_OUTPUT_OFF_OSR_USED_403
    );
  b_1_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_1_OUTPUT_OFF_OCEINV_404
    );
  b_1_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD59",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_1_FXMUX_41,
      O => b_1_OUTPUT_OFF_O1INV_405
    );
  a_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_6_repl1,
      O => a_6_O
    );
  a_6_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_6_OUTPUT_OFF_OSR_USED_406
    );
  a_6_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_6_OUTPUT_OFF_OCEINV_407
    );
  a_6_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD101",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_6_0,
      O => a_6_OUTPUT_OFF_O1INV_408
    );
  b_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_2_repl1,
      O => b_2_O
    );
  b_2_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_2_OUTPUT_OFF_OSR_USED_409
    );
  b_2_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_2_OUTPUT_OFF_OCEINV_410
    );
  b_2_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD62",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_3_GYMUX_50,
      O => b_2_OUTPUT_OFF_O1INV_411
    );
  a_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_data_out_dup0_7_repl1,
      O => a_7_O
    );
  a_7_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => a_7_OUTPUT_OFF_OSR_USED_412
    );
  a_7_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => flagz_alu_control_0,
      O => a_7_OUTPUT_OFF_OCEINV_413
    );
  a_7_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD100",
      PATHPULSE => 757 ps
    )
    port map (
      I => reg_i_a_out_1n1ss1_7_0,
      O => a_7_OUTPUT_OFF_O1INV_414
    );
  b_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_3_repl1,
      O => b_3_O
    );
  b_3_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_3_OUTPUT_OFF_OSR_USED_415
    );
  b_3_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_3_OUTPUT_OFF_OCEINV_416
    );
  b_3_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD61",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_3_FXMUX_48,
      O => b_3_OUTPUT_OFF_O1INV_417
    );
  b_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_4_repl1,
      O => b_4_O
    );
  b_4_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_4_OUTPUT_OFF_OSR_USED_418
    );
  b_4_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_4_OUTPUT_OFF_OCEINV_419
    );
  b_4_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD54",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_5_GYMUX_57,
      O => b_4_OUTPUT_OFF_O1INV_420
    );
  b_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_5_repl1,
      O => b_5_O
    );
  b_5_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_5_OUTPUT_OFF_OSR_USED_421
    );
  b_5_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_5_OUTPUT_OFF_OCEINV_422
    );
  b_5_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD55",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_5_FXMUX_55,
      O => b_5_OUTPUT_OFF_O1INV_423
    );
  b_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_6_repl1,
      O => b_6_O
    );
  b_6_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_6_OUTPUT_OFF_OSR_USED_424
    );
  b_6_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_6_OUTPUT_OFF_OCEINV_425
    );
  b_6_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD57",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_7_GYMUX_64,
      O => b_6_OUTPUT_OFF_O1INV_426
    );
  reg_i_reg_a_out_0_repl1 : X_SFF
    generic map(
      LOC => "PAD107",
      INIT => '0'
    )
    port map (
      I => a_0_OUTPUT_OFF_O1INV_381,
      CE => a_0_OUTPUT_OFF_OCEINV_380,
      CLK => a_0_OUTPUT_OTCLK1INV_18,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_0_OUTPUT_OFF_OSR_USED_379,
      O => datmem_data_out_dup0_0_repl1
    );
  reg_i_reg_zero_out_repl2 : X_SFF
    generic map(
      LOC => "PAD39",
      INIT => '0'
    )
    port map (
      I => zflag_OUTPUT_OFF_O1INV_384,
      CE => zflag_OUTPUT_OFF_OCEINV_383,
      CLK => zflag_OUTPUT_OTCLK1INV_19,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => zflag_OUTPUT_OFF_OSR_USED_382,
      O => zflag_dup0_repl2
    );
  reg_i_reg_a_out_1_repl1 : X_SFF
    generic map(
      LOC => "PAD106",
      INIT => '0'
    )
    port map (
      I => a_1_OUTPUT_OFF_O1INV_387,
      CE => a_1_OUTPUT_OFF_OCEINV_386,
      CLK => a_1_OUTPUT_OTCLK1INV_20,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_1_OUTPUT_OFF_OSR_USED_385,
      O => datmem_data_out_dup0_1_repl1
    );
  reg_i_reg_a_out_1_repl2 : X_SFF
    generic map(
      LOC => "PAD99",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_1_OUTPUT_OFF_O1INV_360,
      CE => datmem_data_out_1_OUTPUT_OFF_OCEINV_359,
      CLK => datmem_data_out_1_OUTPUT_OTCLK1INV_1,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_1_OUTPUT_OFF_OSR_USED_358,
      O => datmem_data_out_dup0_1_repl2
    );
  alu_i_ix18369z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X11Y19"
    )
    port map (
      ADR0 => alu_i_nx18369z4_0,
      ADR1 => alu_i_nx18369z1_0,
      ADR2 => alu_i_nx18369z3_0,
      ADR3 => alu_i_nx18369z2_0,
      O => result_alu_reg_5_pack_1
    );
  ix18424z1530 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X11Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(13),
      ADR2 => reg_i_rom_data_intern(5),
      ADR3 => result_alu_reg(5),
      O => reg_i_a_out_1n1ss1(5)
    );
  reg_i_reg_a_out_5_Q : X_SFF
    generic map(
      LOC => "SLICE_X11Y19",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_5_DXMUX_2,
      CE => datmem_data_out_dup0_5_CEINV_6,
      CLK => datmem_data_out_dup0_5_CLKINV_5,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_5_SRINV_4,
      O => datmem_data_out_dup0(5)
    );
  reg_i_reg_a_out_2_repl2 : X_SFF
    generic map(
      LOC => "PAD45",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_2_OUTPUT_OFF_O1INV_363,
      CE => datmem_data_out_2_OUTPUT_OFF_OCEINV_362,
      CLK => datmem_data_out_2_OUTPUT_OTCLK1INV_7,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_2_OUTPUT_OFF_OSR_USED_361,
      O => datmem_data_out_dup0_2_repl2
    );
  alu_i_ix49743z61937 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X12Y16"
    )
    port map (
      ADR0 => b_dup0(4),
      ADR1 => datmem_data_out_dup0(4),
      ADR2 => datmem_data_out_dup0(3),
      ADR3 => b_dup0(3),
      O => alu_i_nx49743z41
    );
  reg_i_reg_a_out_3_repl2 : X_SFF
    generic map(
      LOC => "PAD44",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_3_OUTPUT_OFF_O1INV_366,
      CE => datmem_data_out_3_OUTPUT_OFF_OCEINV_365,
      CLK => datmem_data_out_3_OUTPUT_OTCLK1INV_8,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_3_OUTPUT_OFF_OSR_USED_364,
      O => datmem_data_out_dup0_3_repl2
    );
  alu_i_ix20363z61429 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X10Y18"
    )
    port map (
      ADR0 => control_int_fsm(8),
      ADR1 => control_int_fsm(5),
      ADR2 => alu_i_nx20363z20,
      ADR3 => alu_i_nx20363z19,
      O => alu_i_nx20363z18
    );
  reg_i_reg_a_out_2_repl1 : X_SFF
    generic map(
      LOC => "PAD105",
      INIT => '0'
    )
    port map (
      I => a_2_OUTPUT_OFF_O1INV_390,
      CE => a_2_OUTPUT_OFF_OCEINV_389,
      CLK => a_2_OUTPUT_OTCLK1INV_21,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_2_OUTPUT_OFF_OSR_USED_388,
      O => datmem_data_out_dup0_2_repl1
    );
  reg_i_reg_a_out_3_repl1 : X_SFF
    generic map(
      LOC => "PAD104",
      INIT => '0'
    )
    port map (
      I => a_3_OUTPUT_OFF_O1INV_393,
      CE => a_3_OUTPUT_OFF_OCEINV_392,
      CLK => a_3_OUTPUT_OTCLK1INV_22,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_3_OUTPUT_OFF_OSR_USED_391,
      O => datmem_data_out_dup0_3_repl1
    );
  reg_i_reg_a_out_4_repl1 : X_SFF
    generic map(
      LOC => "PAD103",
      INIT => '0'
    )
    port map (
      I => a_4_OUTPUT_OFF_O1INV_396,
      CE => a_4_OUTPUT_OFF_OCEINV_395,
      CLK => a_4_OUTPUT_OTCLK1INV_23,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_4_OUTPUT_OFF_OSR_USED_394,
      O => datmem_data_out_dup0_4_repl1
    );
  reg_i_reg_b_out_0_repl1 : X_SFF
    generic map(
      LOC => "PAD56",
      INIT => '0'
    )
    port map (
      I => b_0_OUTPUT_OFF_O1INV_399,
      CE => b_0_OUTPUT_OFF_OCEINV_398,
      CLK => b_0_OUTPUT_OTCLK1INV_24,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_0_OUTPUT_OFF_OSR_USED_397,
      O => b_dup0_0_repl1
    );
  reg_i_reg_a_out_5_repl1 : X_SFF
    generic map(
      LOC => "PAD102",
      INIT => '0'
    )
    port map (
      I => a_5_OUTPUT_OFF_O1INV_402,
      CE => a_5_OUTPUT_OFF_OCEINV_401,
      CLK => a_5_OUTPUT_OTCLK1INV_25,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_5_OUTPUT_OFF_OSR_USED_400,
      O => datmem_data_out_dup0_5_repl1
    );
  reg_i_reg_a_out_4_repl2 : X_SFF
    generic map(
      LOC => "PAD43",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_4_OUTPUT_OFF_O1INV_369,
      CE => datmem_data_out_4_OUTPUT_OFF_OCEINV_368,
      CLK => datmem_data_out_4_OUTPUT_OTCLK1INV_9,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_4_OUTPUT_OFF_OSR_USED_367,
      O => datmem_data_out_dup0_4_repl2
    );
  alu_i_ix13384z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y12"
    )
    port map (
      ADR0 => alu_i_nx13384z5_0,
      ADR1 => alu_i_nx13384z1_0,
      ADR2 => alu_i_nx13384z4_0,
      ADR3 => alu_i_nx13384z3_0,
      O => result_alu_reg_0_pack_1
    );
  ix23409z1530 : X_LUT4
    generic map(
      INIT => X"CACA",
      LOC => "SLICE_X7Y12"
    )
    port map (
      ADR0 => result_alu_reg(0),
      ADR1 => reg_i_rom_data_intern(0),
      ADR2 => control_int_fsm(13),
      ADR3 => VCC,
      O => reg_i_a_out_1n1ss1(0)
    );
  reg_i_reg_a_out_0_Q : X_SFF
    generic map(
      LOC => "SLICE_X7Y12",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_0_DXMUX_10,
      CE => datmem_data_out_dup0_0_CEINV_14,
      CLK => datmem_data_out_dup0_0_CLKINV_13,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_0_SRINV_12,
      O => datmem_data_out_dup0(0)
    );
  reg_i_reg_a_out_5_repl2 : X_SFF
    generic map(
      LOC => "PAD42",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_5_OUTPUT_OFF_O1INV_372,
      CE => datmem_data_out_5_OUTPUT_OFF_OCEINV_371,
      CLK => datmem_data_out_5_OUTPUT_OTCLK1INV_15,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_5_OUTPUT_OFF_OSR_USED_370,
      O => datmem_data_out_dup0_5_repl2
    );
  reg_i_reg_a_out_6_repl2 : X_SFF
    generic map(
      LOC => "PAD41",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_6_OUTPUT_OFF_O1INV_375,
      CE => datmem_data_out_6_OUTPUT_OFF_OCEINV_374,
      CLK => datmem_data_out_6_OUTPUT_OTCLK1INV_16,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_6_OUTPUT_OFF_OSR_USED_373,
      O => datmem_data_out_dup0_6_repl2
    );
  reg_i_reg_a_out_7_repl2 : X_SFF
    generic map(
      LOC => "PAD40",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_7_OUTPUT_OFF_O1INV_378,
      CE => datmem_data_out_7_OUTPUT_OFF_OCEINV_377,
      CLK => datmem_data_out_7_OUTPUT_OTCLK1INV_17,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_7_OUTPUT_OFF_OSR_USED_376,
      O => datmem_data_out_dup0_7_repl2
    );
  control_i_reg_pr_state_8_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y23",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_18_DYMUX_37,
      CE => VCC,
      CLK => control_int_fsm_18_CLKINV_39,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_18_SRINV_38,
      O => control_int_fsm(8)
    );
  control_i_ix24721z5410 : X_LUT4
    generic map(
      INIT => X"0400",
      LOC => "SLICE_X5Y23"
    )
    port map (
      ADR0 => control_i_nx27714z2_0,
      ADR1 => prog_data_int(1),
      ADR2 => control_i_nx24721z2_0,
      ADR3 => prog_data_int(0),
      O => control_i_nx24721z1
    );
  control_i_reg_pr_state_18_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y23",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_18_DXMUX_36,
      CE => VCC,
      CLK => control_int_fsm_18_CLKINV_39,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_18_SRINV_38,
      O => control_int_fsm(18)
    );
  reg_i_reg_b_out_0_Q : X_SFF
    generic map(
      LOC => "SLICE_X6Y13",
      INIT => '0'
    )
    port map (
      I => b_dup0_1_DYMUX_42,
      CE => b_dup0_1_CEINV_46,
      CLK => b_dup0_1_CLKINV_45,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_1_SRINV_44,
      O => b_dup0(0)
    );
  ix44607z1530 : X_LUT4
    generic map(
      INIT => X"FC30",
      LOC => "SLICE_X6Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(16),
      ADR2 => reg_i_rom_data_intern(1),
      ADR3 => result_alu_reg(1),
      O => reg_i_b_out_1n1ss1(1)
    );
  reg_i_reg_b_out_1_Q : X_SFF
    generic map(
      LOC => "SLICE_X6Y13",
      INIT => '0'
    )
    port map (
      I => b_dup0_1_DXMUX_40,
      CE => b_dup0_1_CEINV_46,
      CLK => b_dup0_1_CLKINV_45,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_1_SRINV_44,
      O => b_dup0(1)
    );
  reg_i_reg_b_out_2_Q : X_SFF
    generic map(
      LOC => "SLICE_X10Y12",
      INIT => '0'
    )
    port map (
      I => b_dup0_3_DYMUX_49,
      CE => b_dup0_3_CEINV_53,
      CLK => b_dup0_3_CLKINV_52,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_3_SRINV_51,
      O => b_dup0(2)
    );
  ix42613z1530 : X_LUT4
    generic map(
      INIT => X"ACAC",
      LOC => "SLICE_X10Y12"
    )
    port map (
      ADR0 => result_alu_reg(3),
      ADR1 => reg_i_rom_data_intern(3),
      ADR2 => control_int_fsm(16),
      ADR3 => VCC,
      O => reg_i_b_out_1n1ss1(3)
    );
  reg_i_reg_b_out_1_repl1 : X_SFF
    generic map(
      LOC => "PAD59",
      INIT => '0'
    )
    port map (
      I => b_1_OUTPUT_OFF_O1INV_405,
      CE => b_1_OUTPUT_OFF_OCEINV_404,
      CLK => b_1_OUTPUT_OTCLK1INV_26,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_1_OUTPUT_OFF_OSR_USED_403,
      O => b_dup0_1_repl1
    );
  reg_i_reg_a_out_6_repl1 : X_SFF
    generic map(
      LOC => "PAD101",
      INIT => '0'
    )
    port map (
      I => a_6_OUTPUT_OFF_O1INV_408,
      CE => a_6_OUTPUT_OFF_OCEINV_407,
      CLK => a_6_OUTPUT_OTCLK1INV_27,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_6_OUTPUT_OFF_OSR_USED_406,
      O => datmem_data_out_dup0_6_repl1
    );
  reg_i_reg_b_out_2_repl1 : X_SFF
    generic map(
      LOC => "PAD62",
      INIT => '0'
    )
    port map (
      I => b_2_OUTPUT_OFF_O1INV_411,
      CE => b_2_OUTPUT_OFF_OCEINV_410,
      CLK => b_2_OUTPUT_OTCLK1INV_28,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_2_OUTPUT_OFF_OSR_USED_409,
      O => b_dup0_2_repl1
    );
  reg_i_reg_a_out_7_repl1 : X_SFF
    generic map(
      LOC => "PAD100",
      INIT => '0'
    )
    port map (
      I => a_7_OUTPUT_OFF_O1INV_414,
      CE => a_7_OUTPUT_OFF_OCEINV_413,
      CLK => a_7_OUTPUT_OTCLK1INV_29,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => a_7_OUTPUT_OFF_OSR_USED_412,
      O => datmem_data_out_dup0_7_repl1
    );
  reg_i_reg_b_out_3_repl1 : X_SFF
    generic map(
      LOC => "PAD61",
      INIT => '0'
    )
    port map (
      I => b_3_OUTPUT_OFF_O1INV_417,
      CE => b_3_OUTPUT_OFF_OCEINV_416,
      CLK => b_3_OUTPUT_OTCLK1INV_30,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_3_OUTPUT_OFF_OSR_USED_415,
      O => b_dup0_3_repl1
    );
  reg_i_reg_b_out_4_repl1 : X_SFF
    generic map(
      LOC => "PAD54",
      INIT => '0'
    )
    port map (
      I => b_4_OUTPUT_OFF_O1INV_420,
      CE => b_4_OUTPUT_OFF_OCEINV_419,
      CLK => b_4_OUTPUT_OTCLK1INV_31,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_4_OUTPUT_OFF_OSR_USED_418,
      O => b_dup0_4_repl1
    );
  reg_i_reg_b_out_5_repl1 : X_SFF
    generic map(
      LOC => "PAD55",
      INIT => '0'
    )
    port map (
      I => b_5_OUTPUT_OFF_O1INV_423,
      CE => b_5_OUTPUT_OFF_OCEINV_422,
      CLK => b_5_OUTPUT_OTCLK1INV_32,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_5_OUTPUT_OFF_OSR_USED_421,
      O => b_dup0_5_repl1
    );
  reg_i_reg_b_out_6_repl1 : X_SFF
    generic map(
      LOC => "PAD57",
      INIT => '0'
    )
    port map (
      I => b_6_OUTPUT_OFF_O1INV_426,
      CE => b_6_OUTPUT_OFF_OCEINV_425,
      CLK => b_6_OUTPUT_OTCLK1INV_33,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_6_OUTPUT_OFF_OSR_USED_424,
      O => b_dup0_6_repl1
    );
  alu_i_ix19366z1328 : X_LUT4
    generic map(
      INIT => X"3030",
      LOC => "SLICE_X7Y21"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => control_int_fsm(2),
      ADR3 => VCC,
      O => alu_i_nx19366z9
    );
  alu_i_ix49743z1334 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X2Y23"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(2),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(0),
      O => alu_i_nx49743z20
    );
  alu_i_ix20363z1322 : X_LUT4
    generic map(
      INIT => X"55AA",
      LOC => "SLICE_X10Y20"
    )
    port map (
      ADR0 => b_dup0(7),
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => datmem_data_out_dup0(7),
      O => alu_i_nx20363z1
    );
  alu_i_ix49743z1367 : X_LUT4
    generic map(
      INIT => X"0FFF",
      LOC => "SLICE_X9Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => b_dup0(1),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx49743z40
    );
  alu_i_ix20363z9115 : X_LUT4
    generic map(
      INIT => X"366C",
      LOC => "SLICE_X11Y21"
    )
    port map (
      ADR0 => datmem_data_out_dup0(6),
      ADR1 => alu_i_nx20363z1_0,
      ADR2 => b_dup0(6),
      ADR3 => alu_i_nx20363z2,
      O => alu_i_result_int_0n8ss1(7)
    );
  ix47250z63041 : X_LUT4
    generic map(
      INIT => X"AB57",
      LOC => "SLICE_X3Y17"
    )
    port map (
      ADR0 => ram_control_i_n_clk,
      ADR1 => control_int_fsm(24),
      ADR2 => control_int_fsm(23),
      ADR3 => ram_control_i_p_clk,
      O => datmem_nrd_dup0
    );
  alu_i_ix14381z61891 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X9Y15"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => alu_i_nx20363z10,
      ADR2 => prog_data_int(1),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx14381z1
    );
  alu_i_ix13384z1305 : X_LUT4
    generic map(
      INIT => X"FFF2",
      LOC => "SLICE_X7Y13"
    )
    port map (
      ADR0 => control_int_fsm(3),
      ADR1 => alu_i_nx13384z6_0,
      ADR2 => alu_i_nx13384z7_0,
      ADR3 => alu_i_nx13384z8,
      O => alu_i_nx13384z5
    );
  reg_i_reg_b_out_3_Q : X_SFF
    generic map(
      LOC => "SLICE_X10Y12",
      INIT => '0'
    )
    port map (
      I => b_dup0_3_DXMUX_47,
      CE => b_dup0_3_CEINV_53,
      CLK => b_dup0_3_CLKINV_52,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_3_SRINV_51,
      O => b_dup0(3)
    );
  reg_i_reg_b_out_4_Q : X_SFF
    generic map(
      LOC => "SLICE_X10Y19",
      INIT => '0'
    )
    port map (
      I => b_dup0_5_DYMUX_56,
      CE => b_dup0_5_CEINV_60,
      CLK => b_dup0_5_CLKINV_59,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_5_SRINV_58,
      O => b_dup0(4)
    );
  ix40619z1530 : X_LUT4
    generic map(
      INIT => X"ACAC",
      LOC => "SLICE_X10Y19"
    )
    port map (
      ADR0 => result_alu_reg(5),
      ADR1 => reg_i_rom_data_intern(5),
      ADR2 => control_int_fsm(16),
      ADR3 => VCC,
      O => reg_i_b_out_1n1ss1(5)
    );
  reg_i_reg_b_out_5_Q : X_SFF
    generic map(
      LOC => "SLICE_X10Y19",
      INIT => '0'
    )
    port map (
      I => b_dup0_5_DXMUX_54,
      CE => b_dup0_5_CEINV_60,
      CLK => b_dup0_5_CLKINV_59,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_5_SRINV_58,
      O => b_dup0(5)
    );
  reg_i_reg_b_out_6_Q : X_SFF
    generic map(
      LOC => "SLICE_X8Y19",
      INIT => '0'
    )
    port map (
      I => b_dup0_7_DYMUX_63,
      CE => b_dup0_7_CEINV_67,
      CLK => b_dup0_7_CLKINV_66,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_7_SRINV_65,
      O => b_dup0(6)
    );
  ix38625z1531 : X_LUT4
    generic map(
      INIT => X"AACC",
      LOC => "SLICE_X8Y19"
    )
    port map (
      ADR0 => result_alu_reg(7),
      ADR1 => reg_i_rom_data_intern(7),
      ADR2 => VCC,
      ADR3 => control_int_fsm(16),
      O => reg_i_b_out_1n1ss1(7)
    );
  reg_i_reg_b_out_7_Q : X_SFF
    generic map(
      LOC => "SLICE_X8Y19",
      INIT => '0'
    )
    port map (
      I => b_dup0_7_DXMUX_61,
      CE => b_dup0_7_CEINV_67,
      CLK => b_dup0_7_CLKINV_66,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_dup0_7_SRINV_65,
      O => b_dup0(7)
    );
  alu_i_ix51436z544 : X_LUT4
    generic map(
      INIT => X"FFF4",
      LOC => "SLICE_X5Y16"
    )
    port map (
      ADR0 => alu_i_nx51436z5_0,
      ADR1 => control_int_fsm(9),
      ADR2 => alu_i_nx51436z1_0,
      ADR3 => alu_i_nx51436z2_0,
      O => carry_alu_reg_pack_1
    );
  reg_i_reg_carry_out : X_SFF
    generic map(
      LOC => "SLICE_X5Y16",
      INIT => '0'
    )
    port map (
      I => cflag_dup0_DYMUX_68,
      CE => cflag_dup0_CEINV_72,
      CLK => cflag_dup0_CLKINV_71,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => cflag_dup0_SRINV_70,
      O => cflag_dup0
    );
  control_i_ix2739z2360 : X_LUT4
    generic map(
      INIT => X"0213",
      LOC => "SLICE_X5Y16"
    )
    port map (
      ADR0 => flagc_alu_control,
      ADR1 => control_i_nx25718z3_0,
      ADR2 => carry_alu_reg,
      ADR3 => cflag_dup0,
      O => control_i_nx2739z1
    );
  control_i_reg_pr_state_21_Q : X_SFF
    generic map(
      LOC => "SLICE_X2Y18",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_23_DYMUX_74,
      CE => VCC,
      CLK => control_int_fsm_23_CLKINV_76,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_23_SRINV_75,
      O => control_int_fsm(21)
    );
  control_i_ix30705z1315 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X2Y18"
    )
    port map (
      ADR0 => control_i_nx28711z3_0,
      ADR1 => control_i_nx32699z3_0,
      ADR2 => prog_data_int(1),
      ADR3 => control_i_nx28711z4_0,
      O => control_i_nx30705z1
    );
  control_i_reg_pr_state_23_Q : X_SFF
    generic map(
      LOC => "SLICE_X2Y18",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_23_DXMUX_73,
      CE => VCC,
      CLK => control_int_fsm_23_CLKINV_76,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_23_SRINV_75,
      O => control_int_fsm(23)
    );
  control_i_reg_pr_state_24_Q : X_SFF
    generic map(
      LOC => "SLICE_X2Y19",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_25_DYMUX_78,
      CE => VCC,
      CLK => control_int_fsm_25_CLKINV_80,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_25_SRINV_79,
      O => control_int_fsm(24)
    );
  control_i_ix32699z1330 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X2Y19"
    )
    port map (
      ADR0 => control_i_nx32699z2_0,
      ADR1 => control_i_nx32699z3_0,
      ADR2 => prog_data_int(7),
      ADR3 => prog_data_int(6),
      O => control_i_nx32699z1
    );
  control_i_reg_pr_state_25_Q : X_SFF
    generic map(
      LOC => "SLICE_X2Y19",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_25_DXMUX_77,
      CE => VCC,
      CLK => control_int_fsm_25_CLKINV_80,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_25_SRINV_79,
      O => control_int_fsm(25)
    );
  control_i_reg_pr_state_0_Q : X_SFF
    generic map(
      LOC => "SLICE_X2Y22",
      INIT => '1'
    )
    port map (
      I => control_int_fsm_0_DYMUX_81,
      CE => VCC,
      CLK => control_int_fsm_0_CLKINV_83,
      SET => GND,
      RST => GND,
      SSET => control_int_fsm_0_SRINV_82,
      SRST => GND,
      O => control_int_fsm(0)
    );
  control_i_reg_pr_state_2_Q : X_SFF
    generic map(
      LOC => "SLICE_X3Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_3_DYMUX_85,
      CE => VCC,
      CLK => control_int_fsm_3_CLKINV_87,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_3_SRINV_86,
      O => control_int_fsm(2)
    );
  control_i_ix45059z1316 : X_LUT4
    generic map(
      INIT => X"0100",
      LOC => "SLICE_X3Y22"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => prog_data_int(7),
      ADR2 => control_i_nx32699z3_0,
      ADR3 => control_i_nx45059z2_0,
      O => control_i_nx45059z1
    );
  control_i_reg_pr_state_3_Q : X_SFF
    generic map(
      LOC => "SLICE_X3Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_3_DXMUX_84,
      CE => VCC,
      CLK => control_int_fsm_3_CLKINV_87,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_3_SRINV_86,
      O => control_int_fsm(3)
    );
  control_i_reg_pr_state_4_Q : X_SFF
    generic map(
      LOC => "SLICE_X6Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_5_DYMUX_89,
      CE => VCC,
      CLK => control_int_fsm_5_CLKINV_91,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_5_SRINV_90,
      O => control_int_fsm(4)
    );
  control_i_ix47053z1316 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X6Y22"
    )
    port map (
      ADR0 => prog_data_int(7),
      ADR1 => control_i_nx47053z2_0,
      ADR2 => control_i_nx32699z3_0,
      ADR3 => prog_data_int(6),
      O => control_i_nx47053z1
    );
  control_i_reg_pr_state_5_Q : X_SFF
    generic map(
      LOC => "SLICE_X6Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_5_DXMUX_88,
      CE => VCC,
      CLK => control_int_fsm_5_CLKINV_91,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_5_SRINV_90,
      O => control_int_fsm(5)
    );
  control_i_reg_pr_state_6_Q : X_SFF
    generic map(
      LOC => "SLICE_X3Y20",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_7_DYMUX_93,
      CE => VCC,
      CLK => control_int_fsm_7_CLKINV_95,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_7_SRINV_94,
      O => control_int_fsm(6)
    );
  control_i_ix49047z1316 : X_LUT4
    generic map(
      INIT => X"0100",
      LOC => "SLICE_X3Y20"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => prog_data_int(7),
      ADR2 => control_i_nx32699z3_0,
      ADR3 => control_i_nx49047z2_0,
      O => control_i_nx49047z1
    );
  control_i_reg_pr_state_7_Q : X_SFF
    generic map(
      LOC => "SLICE_X3Y20",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_7_DXMUX_92,
      CE => VCC,
      CLK => control_int_fsm_7_CLKINV_95,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_7_SRINV_94,
      O => control_int_fsm(7)
    );
  control_i_ix27714z1378 : X_LUT4
    generic map(
      INIT => X"0008",
      LOC => "SLICE_X4Y21"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => control_i_nx27714z5_0,
      ADR2 => control_i_nx27714z6,
      ADR3 => control_i_nx27714z2_0,
      O => control_i_nx27714z1
    );
  pc_i_reg_pc_int_1_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y14",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_0_DYMUX_202,
      CE => VCC,
      CLK => prog_adr_dup0_0_CLKINV_209,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_0_SRINV_208,
      O => prog_adr_dup0(1)
    );
  pc_i_reg_pc_int_0_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y14",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_0_DXMUX_196,
      CE => VCC,
      CLK => prog_adr_dup0_0_CLKINV_209,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_0_SRINV_208,
      O => prog_adr_dup0(0)
    );
  pc_i_reg_pc_int_3_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y15",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_2_DYMUX_215,
      CE => VCC,
      CLK => prog_adr_dup0_2_CLKINV_227,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_2_SRINV_226,
      O => prog_adr_dup0(3)
    );
  pc_i_reg_pc_int_2_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y15",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_2_DXMUX_210,
      CE => VCC,
      CLK => prog_adr_dup0_2_CLKINV_227,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_2_SRINV_226,
      O => prog_adr_dup0(2)
    );
  control_i_reg_pr_state_20_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y21",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_20_DXMUX_96,
      CE => VCC,
      CLK => control_int_fsm_20_CLKINV_98,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_20_SRINV_97,
      O => control_int_fsm(20)
    );
  alu_i_ix14381z61414 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X6Y18"
    )
    port map (
      ADR0 => alu_i_nx20363z17,
      ADR1 => datmem_data_out_dup0(0),
      ADR2 => alu_i_nx20363z16,
      ADR3 => ram_data_reg(1),
      O => alu_i_nx14381z3
    );
  alu_i_ix20363z1550 : X_LUT4
    generic map(
      INIT => X"E8E8",
      LOC => "SLICE_X12Y19"
    )
    port map (
      ADR0 => datmem_data_out_dup0(4),
      ADR1 => b_dup0(4),
      ADR2 => alu_i_nx20363z4,
      ADR3 => VCC,
      O => alu_i_nx20363z3
    );
  alu_i_ix17372z1311 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X13Y19"
    )
    port map (
      ADR0 => control_int_fsm(8),
      ADR1 => alu_i_nx17372z6_0,
      ADR2 => alu_i_nx17372z7,
      ADR3 => alu_i_nx17372z5,
      O => alu_i_nx17372z4
    );
  alu_i_ix20363z1552 : X_LUT4
    generic map(
      INIT => X"E8E8",
      LOC => "SLICE_X12Y13"
    )
    port map (
      ADR0 => datmem_data_out_dup0(2),
      ADR1 => b_dup0(2),
      ADR2 => alu_i_nx20363z6,
      ADR3 => VCC,
      O => alu_i_nx20363z5
    );
  alu_i_ix14381z1467 : X_LUT4
    generic map(
      INIT => X"A55A",
      LOC => "SLICE_X11Y12"
    )
    port map (
      ADR0 => b_dup0(1),
      ADR1 => VCC,
      ADR2 => alu_i_nx20363z7,
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_result_int_0n8ss1(1)
    );
  alu_i_ix17372z57716 : X_LUT4
    generic map(
      INIT => X"C0EA",
      LOC => "SLICE_X13Y18"
    )
    port map (
      ADR0 => control_int_fsm(2),
      ADR1 => control_int_fsm(9),
      ADR2 => alu_i_result_int_0n8ss1(4),
      ADR3 => datmem_data_out_dup0(4),
      O => alu_i_nx17372z2
    );
  alu_i_ix49743z1466 : X_LUT4
    generic map(
      INIT => X"A55A",
      LOC => "SLICE_X10Y13"
    )
    port map (
      ADR0 => cflag_dup0,
      ADR1 => VCC,
      ADR2 => b_dup0(0),
      ADR3 => datmem_data_out_dup0(0),
      O => alu_i_result_int_0n8ss1(0)
    );
  alu_i_ix14381z53193 : X_LUT4
    generic map(
      INIT => X"ACC0",
      LOC => "SLICE_X6Y14"
    )
    port map (
      ADR0 => control_int_fsm(3),
      ADR1 => control_int_fsm(4),
      ADR2 => b_dup0(1),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx14381z6
    );
  alu_i_ix18369z57716 : X_LUT4
    generic map(
      INIT => X"A0EC",
      LOC => "SLICE_X12Y20"
    )
    port map (
      ADR0 => control_int_fsm(9),
      ADR1 => control_int_fsm(2),
      ADR2 => alu_i_result_int_0n8ss1(5),
      ADR3 => datmem_data_out_dup0(5),
      O => alu_i_nx18369z2
    );
  alu_i_ix15378z61891 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X9Y14"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => prog_data_int(2),
      ADR2 => alu_i_nx20363z10,
      ADR3 => datmem_data_out_dup0(2),
      O => alu_i_nx15378z1
    );
  control_i_ix47053z17699 : X_LUT4
    generic map(
      INIT => X"4000",
      LOC => "SLICE_X6Y23"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(2),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(0),
      O => control_i_nx47053z2
    );
  alu_i_ix15378z61414 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X6Y16"
    )
    port map (
      ADR0 => alu_i_nx20363z16,
      ADR1 => alu_i_nx20363z17,
      ADR2 => ram_data_reg(2),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx15378z3
    );
  alu_i_ix18369z61891 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X9Y18"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => alu_i_nx20363z10,
      ADR2 => prog_data_int(5),
      ADR3 => datmem_data_out_dup0(5),
      O => alu_i_nx18369z1
    );
  alu_i_ix16375z1302 : X_LUT4
    generic map(
      INIT => X"FDFC",
      LOC => "SLICE_X11Y13"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => alu_i_nx16375z1_0,
      ADR2 => alu_i_nx16375z8_0,
      ADR3 => control_int_fsm(2),
      O => result_alu_reg_3_pack_1
    );
  ix20418z1530 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X11Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(13),
      ADR2 => reg_i_rom_data_intern(3),
      ADR3 => result_alu_reg(3),
      O => reg_i_a_out_1n1ss1(3)
    );
  reg_i_reg_a_out_3_Q : X_SFF
    generic map(
      LOC => "SLICE_X11Y13",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_3_DXMUX_102,
      CE => datmem_data_out_dup0_3_CEINV_106,
      CLK => datmem_data_out_dup0_3_CLKINV_105,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_3_SRINV_104,
      O => datmem_data_out_dup0(3)
    );
  alu_i_ix20363z1324 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X2Y16"
    )
    port map (
      ADR0 => control_int_fsm(22),
      ADR1 => control_int_fsm(21),
      ADR2 => control_int_fsm(20),
      ADR3 => control_int_fsm(25),
      O => alu_i_nx20363z11
    );
  control_i_ix32699z1306 : X_LUT4
    generic map(
      INIT => X"FFDF",
      LOC => "SLICE_X3Y21"
    )
    port map (
      ADR0 => prog_data_int(3),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(2),
      ADR3 => prog_data_int(0),
      O => control_i_nx32699z2
    );
  control_i_ix25718z1318 : X_LUT4
    generic map(
      INIT => X"1100",
      LOC => "SLICE_X5Y19"
    )
    port map (
      ADR0 => control_i_nx27714z2_0,
      ADR1 => control_i_nx25718z3_0,
      ADR2 => VCC,
      ADR3 => control_i_nx25718z2,
      O => control_i_nx25718z1
    );
  control_i_reg_pr_state_19_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y19",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_19_DXMUX_99,
      CE => VCC,
      CLK => control_int_fsm_19_CLKINV_101,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_19_SRINV_100,
      O => control_int_fsm(19)
    );
  alu_i_ix49743z1333 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y22"
    )
    port map (
      ADR0 => prog_data_int(6),
      ADR1 => prog_data_int(7),
      ADR2 => prog_data_int(4),
      ADR3 => prog_data_int(5),
      O => alu_i_nx49743z19
    );
  alu_i_ix49743z1343 : X_LUT4
    generic map(
      INIT => X"FFBE",
      LOC => "SLICE_X12Y11"
    )
    port map (
      ADR0 => alu_i_nx49743z36_0,
      ADR1 => b_dup0(1),
      ADR2 => datmem_data_out_dup0(1),
      ADR3 => alu_i_nx49743z37,
      O => alu_i_nx49743z35
    );
  alu_i_ix20363z61900 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X4Y19"
    )
    port map (
      ADR0 => prog_data_int(7),
      ADR1 => datmem_data_out_dup0(7),
      ADR2 => alu_i_nx20363z10,
      ADR3 => alu_i_nx20363z14_0,
      O => alu_i_nx20363z9
    );
  alu_i_ix18369z53193 : X_LUT4
    generic map(
      INIT => X"E848",
      LOC => "SLICE_X13Y20"
    )
    port map (
      ADR0 => b_dup0(5),
      ADR1 => control_int_fsm(4),
      ADR2 => datmem_data_out_dup0(5),
      ADR3 => control_int_fsm(3),
      O => alu_i_nx18369z6
    );
  control_i_ix48050z1331 : X_LUT4
    generic map(
      INIT => X"0010",
      LOC => "SLICE_X1Y23"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(3),
      ADR3 => prog_data_int(2),
      O => control_i_nx48050z2
    );
  alu_i_ix18369z1311 : X_LUT4
    generic map(
      INIT => X"FEEE",
      LOC => "SLICE_X12Y18"
    )
    port map (
      ADR0 => alu_i_nx18369z7,
      ADR1 => alu_i_nx18369z6_0,
      ADR2 => alu_i_nx18369z5,
      ADR3 => control_int_fsm(8),
      O => alu_i_nx18369z4
    );
  reg_i_reg_b_out_7_repl1 : X_SFF
    generic map(
      LOC => "PAD58",
      INIT => '0'
    )
    port map (
      I => b_7_OUTPUT_OFF_O1INV_429,
      CE => b_7_OUTPUT_OFF_OCEINV_428,
      CLK => b_7_OUTPUT_OTCLK1INV_34,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => b_7_OUTPUT_OFF_OSR_USED_427,
      O => b_dup0_7_repl1
    );
  b_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_7_repl1,
      O => b_7_O
    );
  b_7_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => b_7_OUTPUT_OFF_OSR_USED_427
    );
  b_7_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx38625z1_0,
      O => b_7_OUTPUT_OFF_OCEINV_428
    );
  b_7_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD58",
      PATHPULSE => 757 ps
    )
    port map (
      I => b_dup0_7_FXMUX_62,
      O => b_7_OUTPUT_OFF_O1INV_429
    );
  reg_i_reg_carry_out_repl2 : X_SFF
    generic map(
      LOC => "PAD93",
      INIT => '0'
    )
    port map (
      I => cflag_OUTPUT_OFF_O1INV_432,
      CE => cflag_OUTPUT_OFF_OCEINV_431,
      CLK => cflag_OUTPUT_OTCLK1INV_35,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => cflag_OUTPUT_OFF_OSR_USED_430,
      O => cflag_dup0_repl2
    );
  cflag_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => cflag_dup0_repl2,
      O => cflag_O
    );
  cflag_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => cflag_OUTPUT_OFF_OSR_USED_430
    );
  cflag_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => nx6954z1_0,
      O => cflag_OUTPUT_OFF_OCEINV_431
    );
  cflag_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 757 ps
    )
    port map (
      I => carry_alu_reg,
      O => cflag_OUTPUT_OFF_O1INV_432
    );
  ix45604z1530 : X_LUT4
    generic map(
      INIT => X"CCF0",
      LOC => "SLICE_X6Y13"
    )
    port map (
      ADR0 => VCC,
      ADR1 => result_alu_reg(0),
      ADR2 => reg_i_rom_data_intern(0),
      ADR3 => control_int_fsm(16),
      O => reg_i_b_out_1n1ss1(0)
    );
  ix43610z1530 : X_LUT4
    generic map(
      INIT => X"FC30",
      LOC => "SLICE_X10Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(16),
      ADR2 => reg_i_rom_data_intern(2),
      ADR3 => result_alu_reg(2),
      O => reg_i_b_out_1n1ss1(2)
    );
  ix41616z1530 : X_LUT4
    generic map(
      INIT => X"CACA",
      LOC => "SLICE_X10Y19"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(4),
      ADR1 => result_alu_reg(4),
      ADR2 => control_int_fsm(16),
      ADR3 => VCC,
      O => reg_i_b_out_1n1ss1(4)
    );
  ix39622z1530 : X_LUT4
    generic map(
      INIT => X"FC0C",
      LOC => "SLICE_X8Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_rom_data_intern(6),
      ADR2 => control_int_fsm(16),
      ADR3 => result_alu_reg(6),
      O => reg_i_b_out_1n1ss1(6)
    );
  control_i_ix42068z1316 : X_LUT4
    generic map(
      INIT => X"0044",
      LOC => "SLICE_X2Y22"
    )
    port map (
      ADR0 => control_i_nx32699z4,
      ADR1 => control_i_nxt_state_2n8ss1(0),
      ADR2 => VCC,
      ADR3 => control_i_nx27714z3_0,
      O => control_i_nx42068z1
    );
  control_i_ix27714z1573 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X4Y21"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_data_int(2),
      ADR2 => prog_data_int(1),
      ADR3 => prog_data_int(3),
      O => control_i_nx27714z6_pack_1
    );
  control_i_ix28711z1313 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X3Y18"
    )
    port map (
      ADR0 => control_i_nx27714z3_0,
      ADR1 => control_i_nx32699z4,
      ADR2 => prog_data_int(5),
      ADR3 => control_i_nx28711z3_0,
      O => control_i_nx28711z2_pack_1
    );
  control_i_ix2739z1311 : X_LUT4
    generic map(
      INIT => X"FFFD",
      LOC => "SLICE_X4Y20"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => control_i_nx24721z2_0,
      ADR2 => prog_data_int(1),
      ADR3 => control_i_nx27714z5_0,
      O => control_i_nx2739z2_pack_1
    );
  alu_i_ix49743z1581 : X_LUT4
    generic map(
      INIT => X"00EF",
      LOC => "SLICE_X8Y14"
    )
    port map (
      ADR0 => alu_i_nx49743z13_0,
      ADR1 => alu_i_nx49743z14_0,
      ADR2 => control_int_fsm(15),
      ADR3 => alu_i_nx49743z15_0,
      O => alu_i_ix49743z1581_O
    );
  control_i_ix51041z1313 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X4Y23"
    )
    port map (
      ADR0 => control_i_nx27714z3_0,
      ADR1 => control_int_fsm(19),
      ADR2 => control_int_fsm(18),
      ADR3 => control_i_nx51041z3_0,
      O => control_i_nx51041z2_pack_1
    );
  control_i_ix42068z1521 : X_LUT4
    generic map(
      INIT => X"B8B8",
      LOC => "SLICE_X0Y23"
    )
    port map (
      ADR0 => control_i_nx42068z2_0,
      ADR1 => prog_data_int(5),
      ADR2 => control_i_nx27714z6,
      ADR3 => VCC,
      O => control_i_nxt_state_mux_2i1_nx_mx8_l3_1
    );
  prog_adr_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD53",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_repl2,
      O => prog_adr_0_O
    );
  prog_adr_0_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD53",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_0_OUTPUT_OFF_OSR_USED_433
    );
  prog_adr_0_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD53",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_FXMUX_197,
      O => prog_adr_0_OUTPUT_OFF_O1INV_434
    );
  prog_adr_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD52",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_1_repl2,
      O => prog_adr_1_O
    );
  prog_adr_1_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD52",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_1_OUTPUT_OFF_OSR_USED_435
    );
  prog_adr_1_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD52",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_0_GYMUX_203,
      O => prog_adr_1_OUTPUT_OFF_O1INV_436
    );
  prog_adr_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD51",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_repl1,
      O => prog_adr_2_O
    );
  prog_adr_2_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD51",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_2_OUTPUT_OFF_OSR_USED_437
    );
  prog_adr_2_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD51",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_FXMUX_211,
      O => prog_adr_2_OUTPUT_OFF_O1INV_438
    );
  prog_adr_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD50",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_3_repl1,
      O => prog_adr_3_O
    );
  prog_adr_3_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD50",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_3_OUTPUT_OFF_OSR_USED_439
    );
  prog_adr_3_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD50",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_2_GYMUX_216,
      O => prog_adr_3_OUTPUT_OFF_O1INV_440
    );
  reg_i_reg_rom_data_intern_0_Q : X_SFF
    generic map(
      LOC => "PAD117",
      INIT => '0'
    )
    port map (
      I => prog_data_0_IFF_IFFDMUX_308,
      CE => VCC,
      CLK => prog_data_0_IFF_ICLK1INV_307,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_0_IFF_ISR_USED_306,
      O => reg_i_rom_data_intern(0)
    );
  prog_adr_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD49",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_repl1,
      O => prog_adr_4_O
    );
  prog_adr_4_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD49",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_4_OUTPUT_OFF_OSR_USED_441
    );
  prog_adr_4_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD49",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_FXMUX_229,
      O => prog_adr_4_OUTPUT_OFF_O1INV_442
    );
  reg_i_reg_rom_data_intern_1_Q : X_SFF
    generic map(
      LOC => "PAD116",
      INIT => '0'
    )
    port map (
      I => prog_data_1_IFF_IFFDMUX_312,
      CE => VCC,
      CLK => prog_data_1_IFF_ICLK1INV_311,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_1_IFF_ISR_USED_310,
      O => reg_i_rom_data_intern(1)
    );
  prog_adr_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD48",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_5_repl1,
      O => prog_adr_5_O
    );
  prog_adr_5_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD48",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_5_OUTPUT_OFF_OSR_USED_443
    );
  prog_adr_5_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD48",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_4_GYMUX_234,
      O => prog_adr_5_OUTPUT_OFF_O1INV_444
    );
  reg_i_reg_rom_data_intern_2_Q : X_SFF
    generic map(
      LOC => "PAD118",
      INIT => '0'
    )
    port map (
      I => prog_data_2_IFF_IFFDMUX_447,
      CE => VCC,
      CLK => prog_data_2_IFF_ICLK1INV_446,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_2_IFF_ISR_USED_445,
      O => reg_i_rom_data_intern(2)
    );
  prog_data_2_IFF_IFFDMUX : X_BUF
    generic map(
      LOC => "PAD118",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_2_INBUF,
      O => prog_data_2_IFF_IFFDMUX_447
    );
  prog_data_2_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD118",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_2_INBUF,
      O => prog_data_int(2)
    );
  prog_data_2_IFF_ISR_USED : X_BUF
    generic map(
      LOC => "PAD118",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_data_2_IFF_ISR_USED_445
    );
  prog_data_2_IFF_ICLK1INV : X_BUF
    generic map(
      LOC => "PAD118",
      PATHPULSE => 757 ps
    )
    port map (
      I => clk_int,
      O => prog_data_2_IFF_ICLK1INV_446
    );
  prog_adr_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD47",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_repl1,
      O => prog_adr_6_O
    );
  prog_adr_6_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD47",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_6_OUTPUT_OFF_OSR_USED_448
    );
  prog_adr_6_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD47",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_FXMUX_247,
      O => prog_adr_6_OUTPUT_OFF_O1INV_449
    );
  reg_i_reg_rom_data_intern_3_Q : X_SFF
    generic map(
      LOC => "PAD119",
      INIT => '0'
    )
    port map (
      I => prog_data_3_IFF_IFFDMUX_317,
      CE => VCC,
      CLK => prog_data_3_IFF_ICLK1INV_316,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_3_IFF_ISR_USED_315,
      O => reg_i_rom_data_intern(3)
    );
  prog_adr_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD46",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_7_repl1,
      O => prog_adr_7_O
    );
  prog_adr_7_OUTPUT_OFF_OSR_USED : X_BUF
    generic map(
      LOC => "PAD46",
      PATHPULSE => 757 ps
    )
    port map (
      I => rst_int_0,
      O => prog_adr_7_OUTPUT_OFF_OSR_USED_450
    );
  prog_adr_7_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD46",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_adr_dup0_6_GYMUX_253,
      O => prog_adr_7_OUTPUT_OFF_O1INV_451
    );
  reg_i_reg_rom_data_intern_4_Q : X_SFF
    generic map(
      LOC => "PAD120",
      INIT => '0'
    )
    port map (
      I => prog_data_4_IFF_IFFDMUX_321,
      CE => VCC,
      CLK => prog_data_4_IFF_ICLK1INV_320,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_4_IFF_ISR_USED_319,
      O => reg_i_rom_data_intern(4)
    );
  reg_i_reg_rom_data_intern_5_Q : X_SFF
    generic map(
      LOC => "PAD121",
      INIT => '0'
    )
    port map (
      I => prog_data_5_IFF_IFFDMUX_324,
      CE => VCC,
      CLK => prog_data_5_IFF_ICLK1INV_323,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_5_IFF_ISR_USED_322,
      O => reg_i_rom_data_intern(5)
    );
  reg_i_reg_rom_data_intern_6_Q : X_SFF
    generic map(
      LOC => "PAD124",
      INIT => '0'
    )
    port map (
      I => prog_data_6_IFF_IFFDMUX_327,
      CE => VCC,
      CLK => prog_data_6_IFF_ICLK1INV_326,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_6_IFF_ISR_USED_325,
      O => reg_i_rom_data_intern(6)
    );
  reg_i_reg_rom_data_intern_7_Q : X_SFF
    generic map(
      LOC => "PAD123",
      INIT => '0'
    )
    port map (
      I => prog_data_7_IFF_IFFDMUX_330,
      CE => VCC,
      CLK => prog_data_7_IFF_ICLK1INV_329,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_data_7_IFF_ISR_USED_328,
      O => reg_i_rom_data_intern(7)
    );
  control_i_ix28711z1444 : X_LUT4
    generic map(
      INIT => X"77FF",
      LOC => "SLICE_X2Y20"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(2),
      ADR2 => VCC,
      ADR3 => prog_data_int(3),
      O => control_i_nx28711z4
    );
  ix56395z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y17"
    )
    port map (
      ADR0 => control_int_fsm(14),
      ADR1 => control_int_fsm(16),
      ADR2 => control_int_fsm(21),
      ADR3 => flagz_alu_control_0,
      O => nx56395z1
    );
  reg_i_reg_a_out_0_repl2 : X_SFF
    generic map(
      LOC => "PAD98",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_0_OUTPUT_OFF_O1INV_357,
      CE => datmem_data_out_0_OUTPUT_OFF_OCEINV_356,
      CLK => datmem_data_out_0_OUTPUT_OTCLK1INV_0,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_0_OUTPUT_OFF_OSR_USED_355,
      O => datmem_data_out_dup0_0_repl2
    );
  alu_i_ix51436z54063 : X_LUT4
    generic map(
      INIT => X"F222",
      LOC => "SLICE_X10Y16"
    )
    port map (
      ADR0 => control_int_fsm(9),
      ADR1 => alu_i_nx51436z3,
      ADR2 => alu_i_nx51436z4,
      ADR3 => control_int_fsm(8),
      O => alu_i_nx51436z2
    );
  pc_i_reg_pc_int_0_repl2 : X_SFF
    generic map(
      LOC => "PAD53",
      INIT => '0'
    )
    port map (
      I => prog_adr_0_OUTPUT_OFF_O1INV_434,
      CE => VCC,
      CLK => prog_adr_0_OUTPUT_OTCLK1INV_300,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_0_OUTPUT_OFF_OSR_USED_433,
      O => prog_adr_dup0_0_repl2
    );
  pc_i_reg_pc_int_1_repl2 : X_SFF
    generic map(
      LOC => "PAD52",
      INIT => '0'
    )
    port map (
      I => prog_adr_1_OUTPUT_OFF_O1INV_436,
      CE => VCC,
      CLK => prog_adr_1_OUTPUT_OTCLK1INV_301,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_1_OUTPUT_OFF_OSR_USED_435,
      O => prog_adr_dup0_1_repl2
    );
  ram_control_i_reg_p_clk : X_FF
    generic map(
      LOC => "SLICE_X2Y17",
      INIT => '0'
    )
    port map (
      I => ram_control_i_p_clk_DYMUX_302,
      CE => VCC,
      CLK => ram_control_i_p_clk_CLKINV_303,
      SET => GND,
      RST => GND,
      O => ram_control_i_p_clk
    );
  pc_i_reg_pc_int_2_repl1 : X_SFF
    generic map(
      LOC => "PAD51",
      INIT => '0'
    )
    port map (
      I => prog_adr_2_OUTPUT_OFF_O1INV_438,
      CE => VCC,
      CLK => prog_adr_2_OUTPUT_OTCLK1INV_304,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_2_OUTPUT_OFF_OSR_USED_437,
      O => prog_adr_dup0_2_repl1
    );
  pc_i_reg_pc_int_3_repl1 : X_SFF
    generic map(
      LOC => "PAD50",
      INIT => '0'
    )
    port map (
      I => prog_adr_3_OUTPUT_OFF_O1INV_440,
      CE => VCC,
      CLK => prog_adr_3_OUTPUT_OTCLK1INV_305,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_3_OUTPUT_OFF_OSR_USED_439,
      O => prog_adr_dup0_3_repl1
    );
  alu_i_ix20363z1321 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y18"
    )
    port map (
      ADR0 => alu_i_nx20363z36,
      ADR1 => alu_i_nx20363z9_0,
      ADR2 => alu_i_nx20363z18_0,
      ADR3 => alu_i_nx20363z15_0,
      O => alu_i_nx20363z8
    );
  control_i_ix46056z1379 : X_LUT4
    generic map(
      INIT => X"0040",
      LOC => "SLICE_X3Y23"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(2),
      ADR3 => prog_data_int(3),
      O => control_i_nx46056z2
    );
  alu_i_ix16375z61414 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X8Y13"
    )
    port map (
      ADR0 => alu_i_nx16375z6,
      ADR1 => control_int_fsm(5),
      ADR2 => alu_i_nx16375z5,
      ADR3 => control_int_fsm(8),
      O => alu_i_nx16375z4
    );
  alu_i_ix14381z57716 : X_LUT4
    generic map(
      INIT => X"C0EA",
      LOC => "SLICE_X9Y12"
    )
    port map (
      ADR0 => control_int_fsm(2),
      ADR1 => alu_i_result_int_0n8ss1_1_0,
      ADR2 => control_int_fsm(9),
      ADR3 => datmem_data_out_dup0(1),
      O => alu_i_nx14381z2
    );
  alu_i_ix16375z61413 : X_LUT4
    generic map(
      INIT => X"F888",
      LOC => "SLICE_X7Y19"
    )
    port map (
      ADR0 => alu_i_nx20363z16,
      ADR1 => ram_data_reg(3),
      ADR2 => alu_i_nx20363z17,
      ADR3 => datmem_data_out_dup0(2),
      O => alu_i_nx16375z3
    );
  control_i_ix42068z32035 : X_LUT4
    generic map(
      INIT => X"4FFF",
      LOC => "SLICE_X1Y22"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => prog_data_int(1),
      ADR2 => prog_data_int(3),
      ADR3 => prog_data_int(2),
      O => control_i_nx42068z3
    );
  control_i_ix29708z1318 : X_LUT4
    generic map(
      INIT => X"0404",
      LOC => "SLICE_X3Y18"
    )
    port map (
      ADR0 => control_i_nx28711z4_0,
      ADR1 => prog_data_int(1),
      ADR2 => control_i_nx28711z2,
      ADR3 => VCC,
      O => control_i_nx29708z1
    );
  control_i_reg_pr_state_22_Q : X_SFF
    generic map(
      LOC => "SLICE_X3Y18",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_22_DXMUX_107,
      CE => VCC,
      CLK => control_int_fsm_22_CLKINV_109,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_22_SRINV_108,
      O => control_int_fsm(22)
    );
  alu_i_ix19366z1315 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y21"
    )
    port map (
      ADR0 => alu_i_nx19366z4_0,
      ADR1 => alu_i_nx19366z8,
      ADR2 => alu_i_nx19366z3_0,
      ADR3 => alu_i_nx19366z5_0,
      O => alu_i_nx19366z2
    );
  ix62171z1545 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X17Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => pc_i_rtlc3_PS4_n64,
      ADR2 => prog_data_int(6),
      ADR3 => prog_adr_dup0(6),
      O => nx62171z14
    );
  control_i_ix2739z1383 : X_LUT4
    generic map(
      INIT => X"1011",
      LOC => "SLICE_X4Y20"
    )
    port map (
      ADR0 => control_i_nx27714z4,
      ADR1 => control_i_nx32699z3_0,
      ADR2 => control_i_nx2739z1_0,
      ADR3 => control_i_nx2739z2,
      O => control_nxt_int_fsm(1)
    );
  control_i_reg_pr_state_1_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y20",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_1_DXMUX_110,
      CE => VCC,
      CLK => control_int_fsm_1_CLKINV_113,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_1_SRINV_112,
      O => control_int_fsm(1)
    );
  ix62171z1538 : X_LUT4
    generic map(
      INIT => X"CACA",
      LOC => "SLICE_X17Y14"
    )
    port map (
      ADR0 => prog_adr_dup0(0),
      ADR1 => prog_data_int(0),
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => VCC,
      O => nx62171z8
    );
  ix62171z1542 : X_LUT4
    generic map(
      INIT => X"FA0A",
      LOC => "SLICE_X17Y15"
    )
    port map (
      ADR0 => prog_adr_dup0(3),
      ADR1 => VCC,
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => prog_data_int(3),
      O => nx62171z11
    );
  ix62171z1544 : X_LUT4
    generic map(
      INIT => X"FC0C",
      LOC => "SLICE_X17Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => prog_adr_dup0(5),
      ADR2 => pc_i_rtlc3_PS4_n64,
      ADR3 => prog_data_int(5),
      O => nx62171z13
    );
  alu_i_ix14381z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X6Y12"
    )
    port map (
      ADR0 => alu_i_nx14381z1_0,
      ADR1 => alu_i_nx14381z2_0,
      ADR2 => alu_i_nx14381z3_0,
      ADR3 => alu_i_nx14381z4_0,
      O => result_alu_reg_1_pack_1
    );
  ix22412z1530 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X6Y12"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(13),
      ADR2 => reg_i_rom_data_intern(1),
      ADR3 => result_alu_reg(1),
      O => reg_i_a_out_1n1ss1(1)
    );
  reg_i_reg_a_out_1_Q : X_SFF
    generic map(
      LOC => "SLICE_X6Y12",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_1_DXMUX_114,
      CE => datmem_data_out_dup0_1_CEINV_118,
      CLK => datmem_data_out_dup0_1_CLKINV_117,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_1_SRINV_116,
      O => datmem_data_out_dup0(1)
    );
  alu_i_ix19366z61894 : X_LUT4
    generic map(
      INIT => X"ECA0",
      LOC => "SLICE_X8Y21"
    )
    port map (
      ADR0 => datmem_data_out_dup0(6),
      ADR1 => alu_i_nx20363z14_0,
      ADR2 => alu_i_nx20363z10,
      ADR3 => prog_data_int(6),
      O => alu_i_nx19366z3
    );
  alu_i_ix19366z1306 : X_LUT4
    generic map(
      INIT => X"FEEE",
      LOC => "SLICE_X8Y20"
    )
    port map (
      ADR0 => alu_i_nx19366z9_0,
      ADR1 => alu_i_nx19366z2_0,
      ADR2 => alu_i_result_int_0n8ss1_6_0,
      ADR3 => control_int_fsm(9),
      O => result_alu_reg_6_pack_1
    );
  ix17427z1530 : X_LUT4
    generic map(
      INIT => X"CFC0",
      LOC => "SLICE_X8Y20"
    )
    port map (
      ADR0 => VCC,
      ADR1 => reg_i_rom_data_intern(6),
      ADR2 => control_int_fsm(13),
      ADR3 => result_alu_reg(6),
      O => reg_i_a_out_1n1ss1(6)
    );
  reg_i_reg_a_out_6_Q : X_SFF
    generic map(
      LOC => "SLICE_X8Y20",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_6_DXMUX_119,
      CE => datmem_data_out_dup0_6_CEINV_123,
      CLK => datmem_data_out_dup0_6_CLKINV_122,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_6_SRINV_121,
      O => datmem_data_out_dup0(6)
    );
  ram_control_i_reg_n_clk : X_SFF
    generic map(
      LOC => "SLICE_X3Y16",
      INIT => '0'
    )
    port map (
      I => ram_control_i_n_clk_DYMUX_124,
      CE => VCC,
      CLK => ram_control_i_n_clk_CLKINVNOT,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => ram_control_i_n_clk_SRINV_125,
      O => ram_control_i_n_clk
    );
  control_i_ix32699z1569 : X_LUT4
    generic map(
      INIT => X"FFDD",
      LOC => "SLICE_X5Y21"
    )
    port map (
      ADR0 => prog_data_int(5),
      ADR1 => control_i_nx32699z4,
      ADR2 => VCC,
      ADR3 => control_i_nx27714z3_0,
      O => control_i_nx32699z3
    );
  control_i_reg_pr_state_10_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_11_DYMUX_127,
      CE => VCC,
      CLK => control_int_fsm_11_CLKINV_129,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_11_SRINV_128,
      O => control_int_fsm(10)
    );
  control_i_reg_pr_state_11_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y22",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_11_DXMUX_126,
      CE => VCC,
      CLK => control_int_fsm_11_CLKINV_129,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_11_SRINV_128,
      O => control_int_fsm(11)
    );
  alu_i_ix19366z61416 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X11Y16"
    )
    port map (
      ADR0 => control_int_fsm(8),
      ADR1 => alu_i_nx19366z6,
      ADR2 => control_int_fsm(5),
      ADR3 => alu_i_nx19366z7,
      O => alu_i_nx19366z5
    );
  ix53939z59380 : X_LUT4
    generic map(
      INIT => X"B88B",
      LOC => "SLICE_X6Y19"
    )
    port map (
      ADR0 => prog_data_int(0),
      ADR1 => pc_i_rtlc3_PS4_n64,
      ADR2 => control_nxt_int_fsm_1_0,
      ADR3 => prog_adr_dup0(0),
      O => nx53939z1
    );
  alu_i_ix49743z1313 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X13Y13"
    )
    port map (
      ADR0 => alu_i_nx49743z2,
      ADR1 => alu_i_result_int_0n8ss1_6_0,
      ADR2 => alu_i_result_int_0n8ss1_0_0,
      ADR3 => alu_i_result_int_0n8ss1(5),
      O => alu_i_nx49743z1
    );
  alu_i_ix49743z1366 : X_LUT4
    generic map(
      INIT => X"33FF",
      LOC => "SLICE_X11Y14"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(2),
      ADR2 => VCC,
      ADR3 => b_dup0(2),
      O => alu_i_nx49743z39
    );
  reg_i_reg_a_out_4_Q : X_SFF
    generic map(
      LOC => "SLICE_X11Y18",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_4_DXMUX_167,
      CE => datmem_data_out_dup0_4_CEINV_171,
      CLK => datmem_data_out_dup0_4_CLKINV_170,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_4_SRINV_169,
      O => datmem_data_out_dup0(4)
    );
  alu_i_ix20363z1353 : X_LUT4
    generic map(
      INIT => X"33CC",
      LOC => "SLICE_X13Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(4),
      ADR2 => VCC,
      ADR3 => b_dup0(4),
      O => alu_i_nx20363z32
    );
  alu_i_ix15378z1311 : X_LUT4
    generic map(
      INIT => X"FEFC",
      LOC => "SLICE_X10Y15"
    )
    port map (
      ADR0 => alu_i_nx15378z5,
      ADR1 => alu_i_nx15378z6_0,
      ADR2 => alu_i_nx15378z7,
      ADR3 => control_int_fsm(8),
      O => alu_i_nx15378z4
    );
  alu_i_ix20363z1355 : X_LUT4
    generic map(
      INIT => X"6666",
      LOC => "SLICE_X13Y17"
    )
    port map (
      ADR0 => b_dup0(6),
      ADR1 => datmem_data_out_dup0(6),
      ADR2 => VCC,
      ADR3 => VCC,
      O => alu_i_nx20363z34
    );
  alu_i_ix49743z14446 : X_LUT4
    generic map(
      INIT => X"0F4F",
      LOC => "SLICE_X6Y21"
    )
    port map (
      ADR0 => alu_i_nx49743z19_0,
      ADR1 => control_int_fsm(21),
      ADR2 => alu_i_nx49743z16,
      ADR3 => alu_i_nx49743z20_0,
      O => alu_i_nx49743z15
    );
  control_i_reg_pr_state_12_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y18",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_13_DYMUX_131,
      CE => VCC,
      CLK => control_int_fsm_13_CLKINV_133,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_13_SRINV_132,
      O => control_int_fsm(12)
    );
  control_i_reg_pr_state_13_Q : X_SFF
    generic map(
      LOC => "SLICE_X5Y18",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_13_DXMUX_130,
      CE => VCC,
      CLK => control_int_fsm_13_CLKINV_133,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_13_SRINV_132,
      O => control_int_fsm(13)
    );
  alu_i_ix49743z1468 : X_LUT4
    generic map(
      INIT => X"9696",
      LOC => "SLICE_X13Y12"
    )
    port map (
      ADR0 => datmem_data_out_dup0(3),
      ADR1 => b_dup0(3),
      ADR2 => alu_i_nx20363z5_0,
      ADR3 => VCC,
      O => alu_i_result_int_0n8ss1(3)
    );
  alu_i_ix17372z61414 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X6Y17"
    )
    port map (
      ADR0 => alu_i_nx20363z16,
      ADR1 => datmem_data_out_dup0(3),
      ADR2 => alu_i_nx20363z17,
      ADR3 => ram_data_reg(4),
      O => alu_i_nx17372z3
    );
  alu_i_ix15378z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X10Y14"
    )
    port map (
      ADR0 => alu_i_nx15378z4_0,
      ADR1 => alu_i_nx15378z1_0,
      ADR2 => alu_i_nx15378z3_0,
      ADR3 => alu_i_nx15378z2_0,
      O => result_alu_reg_2_pack_1
    );
  ix21415z1530 : X_LUT4
    generic map(
      INIT => X"AFA0",
      LOC => "SLICE_X10Y14"
    )
    port map (
      ADR0 => reg_i_rom_data_intern(2),
      ADR1 => VCC,
      ADR2 => control_int_fsm(13),
      ADR3 => result_alu_reg(2),
      O => reg_i_a_out_1n1ss1(2)
    );
  reg_i_reg_a_out_2_Q : X_SFF
    generic map(
      LOC => "SLICE_X10Y14",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_2_DXMUX_134,
      CE => datmem_data_out_dup0_2_CEINV_138,
      CLK => datmem_data_out_dup0_2_CLKINV_137,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_2_SRINV_136,
      O => datmem_data_out_dup0(2)
    );
  control_i_reg_pr_state_14_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y15",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_15_DYMUX_140,
      CE => VCC,
      CLK => control_int_fsm_15_CLKINV_142,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_15_SRINV_141,
      O => control_int_fsm(14)
    );
  control_i_reg_pr_state_15_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y15",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_15_DXMUX_139,
      CE => VCC,
      CLK => control_int_fsm_15_CLKINV_142,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_15_SRINV_141,
      O => control_int_fsm(15)
    );
  alu_i_ix4072z1568 : X_LUT4
    generic map(
      INIT => X"FFFC",
      LOC => "SLICE_X7Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(15),
      ADR2 => control_int_fsm(13),
      ADR3 => alu_i_nx49743z22,
      O => flagz_alu_control
    );
  alu_i_ix49743z1376 : X_LUT4
    generic map(
      INIT => X"FEFF",
      LOC => "SLICE_X10Y17"
    )
    port map (
      ADR0 => alu_i_nx20363z19,
      ADR1 => alu_i_nx19366z6,
      ADR2 => alu_i_nx49743z29,
      ADR3 => control_int_fsm(5),
      O => alu_i_nx49743z28
    );
  alu_i_ix49743z1346 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X9Y13"
    )
    port map (
      ADR0 => b_dup0(4),
      ADR1 => alu_i_nx16375z5,
      ADR2 => alu_i_nx49743z31,
      ADR3 => datmem_data_out_dup0(4),
      O => alu_i_nx49743z30
    );
  control_i_reg_pr_state_16_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y17",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_17_DYMUX_144,
      CE => VCC,
      CLK => control_int_fsm_17_CLKINV_146,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_17_SRINV_145,
      O => control_int_fsm(16)
    );
  control_i_reg_pr_state_17_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y17",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_17_DXMUX_143,
      CE => VCC,
      CLK => control_int_fsm_17_CLKINV_146,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_17_SRINV_145,
      O => control_int_fsm(17)
    );
  alu_i_ix14381z1311 : X_LUT4
    generic map(
      INIT => X"FEFA",
      LOC => "SLICE_X6Y15"
    )
    port map (
      ADR0 => alu_i_nx14381z6_0,
      ADR1 => alu_i_nx14381z5,
      ADR2 => alu_i_nx14381z7,
      ADR3 => control_int_fsm(8),
      O => alu_i_nx14381z4
    );
  alu_i_ix49743z1420 : X_LUT4
    generic map(
      INIT => X"0001",
      LOC => "SLICE_X9Y17"
    )
    port map (
      ADR0 => datmem_data_out_dup0(0),
      ADR1 => datmem_data_out_dup0(1),
      ADR2 => datmem_data_out_dup0(2),
      ADR3 => alu_i_nx49743z46,
      O => alu_i_nx49743z45
    );
  alu_i_ix49743z1348 : X_LUT4
    generic map(
      INIT => X"FEFF",
      LOC => "SLICE_X11Y20"
    )
    port map (
      ADR0 => alu_i_nx20363z1_0,
      ADR1 => alu_i_nx19366z1_0,
      ADR2 => alu_i_nx49743z34,
      ADR3 => control_int_fsm(4),
      O => alu_i_nx49743z33
    );
  alu_i_ix49743z1233 : X_LUT4
    generic map(
      INIT => X"BFFF",
      LOC => "SLICE_X11Y17"
    )
    port map (
      ADR0 => alu_i_nx49743z43,
      ADR1 => control_int_fsm(3),
      ADR2 => alu_i_nx51436z3,
      ADR3 => alu_i_nx13384z6_0,
      O => alu_i_nx49743z42
    );
  alu_i_ix16375z1313 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X8Y12"
    )
    port map (
      ADR0 => alu_i_nx16375z2_0,
      ADR1 => alu_i_nx16375z4_0,
      ADR2 => alu_i_nx16375z7,
      ADR3 => alu_i_nx16375z3_0,
      O => alu_i_nx16375z1
    );
  alu_i_ix20363z1327 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X5Y17"
    )
    port map (
      ADR0 => control_int_fsm(23),
      ADR1 => control_int_fsm(24),
      ADR2 => control_int_fsm(14),
      ADR3 => control_int_fsm(13),
      O => alu_i_nx20363z14
    );
  alu_i_ix20363z1349 : X_LUT4
    generic map(
      INIT => X"5A5A",
      LOC => "SLICE_X13Y14"
    )
    port map (
      ADR0 => datmem_data_out_dup0(0),
      ADR1 => VCC,
      ADR2 => b_dup0(0),
      ADR3 => VCC,
      O => alu_i_nx20363z28
    );
  alu_i_ix20363z1351 : X_LUT4
    generic map(
      INIT => X"3C3C",
      LOC => "SLICE_X13Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => datmem_data_out_dup0(2),
      ADR2 => b_dup0(2),
      ADR3 => VCC,
      O => alu_i_nx20363z30
    );
  alu_i_ix17372z1312 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X11Y18"
    )
    port map (
      ADR0 => alu_i_nx17372z1_0,
      ADR1 => alu_i_nx17372z4_0,
      ADR2 => alu_i_nx17372z3_0,
      ADR3 => alu_i_nx17372z2_0,
      O => result_alu_reg_4_pack_1
    );
  ix19421z1530 : X_LUT4
    generic map(
      INIT => X"FC30",
      LOC => "SLICE_X11Y18"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(13),
      ADR2 => result_alu_reg(4),
      ADR3 => reg_i_rom_data_intern(4),
      O => reg_i_a_out_1n1ss1(4)
    );
  alu_i_ix51436z1087 : X_LUT4
    generic map(
      INIT => X"F1F7",
      LOC => "SLICE_X10Y21"
    )
    port map (
      ADR0 => alu_i_nx20363z2,
      ADR1 => b_dup0(6),
      ADR2 => alu_i_nx51436z6,
      ADR3 => datmem_data_out_dup0(6),
      O => alu_i_nx51436z5
    );
  alu_i_ix51436z42511 : X_LUT4
    generic map(
      INIT => X"C0EA",
      LOC => "SLICE_X4Y16"
    )
    port map (
      ADR0 => cflag_dup0,
      ADR1 => alu_i_nx20363z17,
      ADR2 => datmem_data_out_dup0(7),
      ADR3 => flagc_alu_control,
      O => alu_i_nx51436z1
    );
  pc_i_reg_pc_int_7_repl1 : X_SFF
    generic map(
      LOC => "PAD46",
      INIT => '0'
    )
    port map (
      I => prog_adr_7_OUTPUT_OFF_O1INV_451,
      CE => VCC,
      CLK => prog_adr_7_OUTPUT_OTCLK1INV_318,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_7_OUTPUT_OFF_OSR_USED_450,
      O => prog_adr_dup0_7_repl1
    );
  alu_i_ix13384z61894 : X_LUT4
    generic map(
      INIT => X"EAC0",
      LOC => "SLICE_X7Y14"
    )
    port map (
      ADR0 => alu_i_nx20363z14_0,
      ADR1 => ram_data_reg(0),
      ADR2 => alu_i_nx20363z16,
      ADR3 => prog_data_int(0),
      O => alu_i_nx13384z4
    );
  pc_i_reg_pc_int_5_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y16",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_4_DYMUX_233,
      CE => VCC,
      CLK => prog_adr_dup0_4_CLKINV_245,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_4_SRINV_244,
      O => prog_adr_dup0(5)
    );
  pc_i_reg_pc_int_4_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y16",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_4_DXMUX_228,
      CE => VCC,
      CLK => prog_adr_dup0_4_CLKINV_245,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_4_SRINV_244,
      O => prog_adr_dup0(4)
    );
  alu_i_ix15378z57716 : X_LUT4
    generic map(
      INIT => X"CE0A",
      LOC => "SLICE_X12Y12"
    )
    port map (
      ADR0 => control_int_fsm(2),
      ADR1 => control_int_fsm(9),
      ADR2 => datmem_data_out_dup0(2),
      ADR3 => alu_i_result_int_0n8ss1(2),
      O => alu_i_nx15378z2
    );
  pc_i_reg_pc_int_7_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y17",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_6_DYMUX_252,
      CE => VCC,
      CLK => prog_adr_dup0_6_CLKINV_256,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_6_SRINV_255,
      O => prog_adr_dup0(7)
    );
  pc_i_reg_pc_int_6_Q : X_SFF
    generic map(
      LOC => "SLICE_X16Y17",
      INIT => '0'
    )
    port map (
      I => prog_adr_dup0_6_DXMUX_246,
      CE => VCC,
      CLK => prog_adr_dup0_6_CLKINV_256,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_dup0_6_SRINV_255,
      O => prog_adr_dup0(6)
    );
  control_i_ix27714z1312 : X_LUT4
    generic map(
      INIT => X"FFFD",
      LOC => "SLICE_X2Y21"
    )
    port map (
      ADR0 => prog_data_int(5),
      ADR1 => control_i_nx27714z4,
      ADR2 => control_i_nx32699z4,
      ADR3 => control_i_nx27714z3_0,
      O => control_i_nx27714z2
    );
  alu_i_ix49743z1595 : X_LUT4
    generic map(
      INIT => X"FEFE",
      LOC => "SLICE_X8Y15"
    )
    port map (
      ADR0 => alu_i_nx49743z26_0,
      ADR1 => alu_i_nx13384z2,
      ADR2 => alu_i_nx49743z25_0,
      ADR3 => VCC,
      O => alu_i_ix49743z1595_O
    );
  alu_i_ix20363z1306 : X_LUT4
    generic map(
      INIT => X"FFF8",
      LOC => "SLICE_X9Y19"
    )
    port map (
      ADR0 => control_int_fsm(9),
      ADR1 => alu_i_result_int_0n8ss1_7_0,
      ADR2 => alu_i_nx20363z37_0,
      ADR3 => alu_i_nx20363z8_0,
      O => result_alu_reg_7_pack_1
    );
  ix16430z1530 : X_LUT4
    generic map(
      INIT => X"F3C0",
      LOC => "SLICE_X9Y19"
    )
    port map (
      ADR0 => VCC,
      ADR1 => control_int_fsm(13),
      ADR2 => reg_i_rom_data_intern(7),
      ADR3 => result_alu_reg(7),
      O => reg_i_a_out_1n1ss1(7)
    );
  reg_i_reg_a_out_7_Q : X_SFF
    generic map(
      LOC => "SLICE_X9Y19",
      INIT => '0'
    )
    port map (
      I => datmem_data_out_dup0_7_DXMUX_270,
      CE => datmem_data_out_dup0_7_CEINV_274,
      CLK => datmem_data_out_dup0_7_CLKINV_273,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => datmem_data_out_dup0_7_SRINV_272,
      O => datmem_data_out_dup0(7)
    );
  alu_i_ix49743z1340 : X_LUT4
    generic map(
      INIT => X"EFFE",
      LOC => "SLICE_X8Y16"
    )
    port map (
      ADR0 => alu_i_nx49743z35_0,
      ADR1 => alu_i_nx49743z33_0,
      ADR2 => b_dup0(0),
      ADR3 => datmem_data_out_dup0(0),
      O => alu_i_ix49743z1340_O
    );
  reg_i_reg_zero_out : X_SFF
    generic map(
      LOC => "SLICE_X8Y17",
      INIT => '0'
    )
    port map (
      I => zflag_dup0_DYMUX_286,
      CE => zflag_dup0_CEINV_290,
      CLK => zflag_dup0_CLKINV_289,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => zflag_dup0_SRINV_288,
      O => zflag_dup0
    );
  alu_i_ix49743z4435 : X_LUT4
    generic map(
      INIT => X"51FF",
      LOC => "SLICE_X8Y17"
    )
    port map (
      ADR0 => control_int_fsm(6),
      ADR1 => control_int_fsm(7),
      ADR2 => cflag_dup0,
      ADR3 => alu_i_nx49743z45_0,
      O => alu_i_ix49743z4435_O
    );
  control_i_ix51041z1316 : X_LUT4
    generic map(
      INIT => X"0100",
      LOC => "SLICE_X4Y23"
    )
    port map (
      ADR0 => control_i_nx51041z4_0,
      ADR1 => control_i_nx27714z6,
      ADR2 => control_i_nx51041z2,
      ADR3 => prog_data_int(0),
      O => control_i_nx51041z1
    );
  control_i_reg_pr_state_9_Q : X_SFF
    generic map(
      LOC => "SLICE_X4Y23",
      INIT => '0'
    )
    port map (
      I => control_int_fsm_9_DXMUX_291,
      CE => VCC,
      CLK => control_int_fsm_9_CLKINV_293,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => control_int_fsm_9_SRINV_292,
      O => control_int_fsm(9)
    );
  pc_i_reg_pc_int_4_repl1 : X_SFF
    generic map(
      LOC => "PAD49",
      INIT => '0'
    )
    port map (
      I => prog_adr_4_OUTPUT_OFF_O1INV_442,
      CE => VCC,
      CLK => prog_adr_4_OUTPUT_OTCLK1INV_309,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_4_OUTPUT_OFF_OSR_USED_441,
      O => prog_adr_dup0_4_repl1
    );
  pc_i_reg_pc_int_5_repl1 : X_SFF
    generic map(
      LOC => "PAD48",
      INIT => '0'
    )
    port map (
      I => prog_adr_5_OUTPUT_OFF_O1INV_444,
      CE => VCC,
      CLK => prog_adr_5_OUTPUT_OTCLK1INV_313,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_5_OUTPUT_OFF_OSR_USED_443,
      O => prog_adr_dup0_5_repl1
    );
  pc_i_reg_pc_int_6_repl1 : X_SFF
    generic map(
      LOC => "PAD47",
      INIT => '0'
    )
    port map (
      I => prog_adr_6_OUTPUT_OFF_O1INV_449,
      CE => VCC,
      CLK => prog_adr_6_OUTPUT_OTCLK1INV_314,
      SET => GND,
      RST => GND,
      SSET => GND,
      SRST => prog_adr_6_OUTPUT_OFF_OSR_USED_448,
      O => prog_adr_dup0_6_repl1
    );
  alu_i_ix49743z1338 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X7Y16"
    )
    port map (
      ADR0 => control_int_fsm(8),
      ADR1 => control_int_fsm(2),
      ADR2 => alu_i_nx20363z17,
      ADR3 => control_int_fsm(9),
      O => alu_i_nx49743z23
    );
  GLOBAL_LOGIC1_VCC : X_ONE
    port map (
      O => GLOBAL_LOGIC1
    );
  GLOBAL_LOGIC0_GND : X_ZERO
    port map (
      O => GLOBAL_LOGIC0
    );
  datmem_nrd_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD94",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_nrd_dup0,
      O => datmem_nrd_O
    );
  datmem_nwr_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD97",
      PATHPULSE => 757 ps
    )
    port map (
      I => datmem_nwr_dup0,
      O => datmem_nwr_O
    );
  datmem_adr_0_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD35",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(0),
      O => datmem_adr_0_O
    );
  datmem_adr_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD36",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(1),
      O => datmem_adr_1_O
    );
  datmem_adr_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD37",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(2),
      O => datmem_adr_2_O
    );
  datmem_adr_3_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD32",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(3),
      O => datmem_adr_3_O
    );
  datmem_adr_4_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD31",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(4),
      O => datmem_adr_4_O
    );
  datmem_adr_5_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD24",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(5),
      O => datmem_adr_5_O
    );
  datmem_adr_6_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD30",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(6),
      O => datmem_adr_6_O
    );
  datmem_adr_7_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD29",
      PATHPULSE => 757 ps
    )
    port map (
      I => prog_data_int(7),
      O => datmem_adr_7_O
    );
  prog_adr_dup0_0_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"FF00",
      LOC => "SLICE_X16Y14"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nx62171z8_0,
      ADR2 => VCC,
      ADR3 => nx53939z1_0,
      O => prog_adr_dup0_0_F
    );
  prog_adr_dup0_2_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"AAAA",
      LOC => "SLICE_X16Y15"
    )
    port map (
      ADR0 => nx62171z10_0,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => VCC,
      O => prog_adr_dup0_2_F
    );
  prog_adr_dup0_2_G_X_LUT4 : X_LUT4
    generic map(
      INIT => X"CCCC",
      LOC => "SLICE_X16Y15"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nx62171z11_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => prog_adr_dup0_2_G
    );
  prog_adr_dup0_4_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"CCCC",
      LOC => "SLICE_X16Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nx62171z12_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => prog_adr_dup0_4_F
    );
  prog_adr_dup0_4_G_X_LUT4 : X_LUT4
    generic map(
      INIT => X"CCCC",
      LOC => "SLICE_X16Y16"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nx62171z13_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => prog_adr_dup0_4_G
    );
  prog_adr_dup0_6_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"CCCC",
      LOC => "SLICE_X16Y17"
    )
    port map (
      ADR0 => VCC,
      ADR1 => nx62171z14_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => prog_adr_dup0_6_F
    );
  control_i_nxt_state_2n8ss1_0_F_X_LUT4 : X_LUT4
    generic map(
      INIT => X"FFFF",
      LOC => "SLICE_X0Y22"
    )
    port map (
      ADR0 => VCC,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => VCC,
      O => control_i_nxt_state_2n8ss1_0_F
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
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end STRUCTURE;

