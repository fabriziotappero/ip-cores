--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: mant_lut_MEM.vhd
-- /___/   /\     Timestamp: Tue Jul 14 11:57:57 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\mant_lut_MEM.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\mant_lut_MEM.vhd" 
-- Device	: 5vsx95tff1136-1
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/mant_lut_MEM.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/mant_lut_MEM.vhd
-- # of Entities	: 1
-- Design Name	: mant_lut_MEM
-- Xilinx	: C:\Xilinx\10.1\ISE
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


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity mant_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 ) 
  );
end mant_lut_MEM;

architecture STRUCTURE of mant_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 11 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 26 downto 0 ); 
  signal BU2_doutb : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  addra_2(11) <= addra(11);
  addra_2(10) <= addra(10);
  addra_2(9) <= addra(9);
  addra_2(8) <= addra(8);
  addra_2(7) <= addra(7);
  addra_2(6) <= addra(6);
  addra_2(5) <= addra(5);
  addra_2(4) <= addra(4);
  addra_2(3) <= addra(3);
  addra_2(2) <= addra(2);
  addra_2(1) <= addra(1);
  addra_2(0) <= addra(0);
  douta(26) <= douta_3(26);
  douta(25) <= douta_3(25);
  douta(24) <= douta_3(24);
  douta(23) <= douta_3(23);
  douta(22) <= douta_3(22);
  douta(21) <= douta_3(21);
  douta(20) <= douta_3(20);
  douta(19) <= douta_3(19);
  douta(18) <= douta_3(18);
  douta(17) <= douta_3(17);
  douta(16) <= douta_3(16);
  douta(15) <= douta_3(15);
  douta(14) <= douta_3(14);
  douta(13) <= douta_3(13);
  douta(12) <= douta_3(12);
  douta(11) <= douta_3(11);
  douta(10) <= douta_3(10);
  douta(9) <= douta_3(9);
  douta(8) <= douta_3(8);
  douta(7) <= douta_3(7);
  douta(6) <= douta_3(6);
  douta(5) <= douta_3(5);
  douta(4) <= douta_3(4);
  douta(3) <= douta_3(3);
  douta(2) <= douta_3(2);
  douta(1) <= douta_3(1);
  douta(0) <= douta_3(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP : RAMB36_EXP
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_7E => X"948B837A71685E544A40352B201409FDF1E4D8CBBEB1A39587796A5B4C3D2D1D",
      INIT_7F => X"18181716151413110F0D0A070401FEFAF6F2EDE8E3DED9D3CDC7C0B9B2ABA39C",
      INITP_00 => X"949C00E4B4B31FC76969380392D2CC036B3F248E35306531A86C6C68BC5A61FE",
      INITP_01 => X"F807E39992D5552D998F000079CC96A56A5939C3FFE0E664B5552DB38E0003B5",
      INITP_02 => X"00E001F071C63336492D6AD5556AD6924D999C71E1FC0000FC1E38CF6A926C71",
      INITP_03 => X"2D249333339C787C03FFFF01F0F1C673264925AD5AAAAA54A5B6C9999C61C3F0",
      INITP_04 => X"39CCE6666CC9B64925B4B4A56A5529FFFFFFE07C38E31999364B6B5AAD554AA5",
      INITP_05 => X"4B6DB649932666667319C638E1C3C3E0F80FF80007FF00007F80FC1E1E1C71C7",
      INITP_06 => X"E3C71C718C673339B33264D924924B696B5AD4A955AAAAAAAAAAB55AB52B4A5A",
      INITP_07 => X"6D926CD9B333333198C639C71C3878783E07E01FF80000000001FFC07F07C1E1",
      INITP_08 => X"CCC999B364DB24924B69696B5AD4A956AAD5555555555AAB54A95AD6969692DB",
      INITP_09 => X"3870F0F07C1F80FE007FFF00000007FFF007F81F81E0F0F0E1C71C718C633999",
      INITP_0A => X"666666666633399CC6339CE718E71C638E3871C39326664CE6663318C639C71C",
      INITP_0B => X"4A95A95AD4A5296B4B5A5A5B4B692DB4924B6C924936C9364D9366CD99332666",
      INITP_0C => X"52B52A54AB54AA556AA9555AAAAA555555555555555AAAAA5556AA955AAD52A5",
      INITP_0D => X"66CC99B326CD9364D936C936DB6492492DB6925B49692D2D2D2D694A5AD6A52B",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      INIT_00 => X"34967AE0C8311C8977E6D7493DB2A81F2D1F130900F8F2EDD2CBC7C484810100",
      INIT_01 => X"1EA1E6EDB5408C9A69FB4E6239D12A4521BF1F3F21C5294F37DF4974600D7BAA",
      INIT_02 => X"B14CC9276687896C31D75FC7113D493706B647BA0D42584F28E17BF75391AF5D",
      INIT_03 => X"97FC446E796635E679ED447C96916E2DCE50B4FA212A14E08E1D8EE013291FF8",
      INIT_04 => X"0C9D1F92F74C93CBF40E191503E1B17223C65ADF55BC145D97C2DEEBE9D87113",
      INIT_05 => X"81E9428DC9F615252619FDD39A52FB96229F0D6DBE0134596F776F593400BE6C",
      INIT_06 => X"8DC5EE09161403E5B87C32DA73FD79E74697D90D3248514A3512E09F50F2860B",
      INIT_07 => X"0C0DFFE4BA823CE8851596086DC30B45708D9C9D8F734910C974109E1E8FF247",
      INIT_08 => X"EB4DA7FB488DCC04345E819CB1BEC5C5BDAE997C592EFCC30779DD337BB4DFFD",
      INIT_09 => X"5F9FD7093458758C9BA3A59F938066451DEEB87B37EC9B42E27C0E9A1E9C1382",
      INIT_0A => X"4A6478848A8A82745E4220F6C58E500BBF6D13B34CDE69ED6BE151BA1C77CB19",
      INIT_0B => X"1002EDD2B0875721E4A15605AD4FEA7E0B92128BFD68CD2B83D31D609CD20129",
      INIT_0C => X"14DB9B5407B359F89022AD31AF26970164C11766AFF12C618FB7D8F205121817",
      INIT_0D => X"B850E26DF270E859C32785DC2C76B9F62C5C85A8C4DAE9F1F3EEE3D1B8997447",
      INIT_0E => X"5AC1217BCF1C63A3DD103D64849EB1BDC4C4BDB09C82623B0DD99F5E17C9751A",
      INIT_0F => X"578AB6DCFB1528343A3A342714FADAB488551BDC9649F69D3DD76BF87FFF79ED",
      INIT_10 => X"0A05FAEAD2B591673701C48138E89236D46BFC870C8A0274DF44A3FC4E9ADF1E",
      INIT_11 => X"E6C6A47F562BFDCB965E24E6A56019CF8231DD872DD0700DA73DD161EF790008",
      INIT_12 => X"79BCFB3871A8DB0C39638BAFD0EE0921364857636C7174737069605343301B02",
      INIT_13 => X"EA8E2ECB65FC9021AF3AC247C948C43DB32696036DD43899F752AAFF509FEB33",
      INIT_14 => X"636565615A514434220DF4D9BA99754E23F6C6935D24E7A86621D98E40EF9B44",
      INIT_15 => X"0C6DCA247BD02170BB044A8DCD0A447BAFE10F3A6388ABCBE701182C3D4B565E",
      INIT_16 => X"0FCB853CF0A150FBA449EC8C29C35AEE800E9A23A92CAC29A31B8F006FDB44AA",
      INIT_17 => X"91A9BED0E0EDF7FE020302FEF6ECE0D0BDA88F74563512EBC2956634FFC78D4F",
      INIT_18 => X"BA2C9B0872D93D9FFE59B2095CADFB468ED3165592CC04386A98C4EE14375876",
      INIT_19 => X"AF7A4309CC8C4A04BC7124D4802AD27618B753ED8317A837C24BD154D452CC44",
      INIT_1A => X"96B9DAF7122B405363717B83888B8B8882796E604F3C250CF0D2B08D663C10E1",
      INIT_1B => X"930D84F96BDA47B0187CDE3D99F34A9EEF3E8AD41A5E9FDE1A5389BDEE1C4770",
      INIT_1C => X"CA9A6631F9BE8040FDB76F24D68633DD852ACC6C09A33BD062F17E0890159716",
      INIT_1D => X"5E82A3C2DFF910243645525C63686A696660584C3E2E1B05EDD2B494714B22F7",
      INIT_1E => X"70E85ED040AD1880E649A90762BB1164B5034F98DE2263A1DD164D81B2E10D37",
      INIT_1F => X"24EEB67B3EFEBB762EE49748F6A14AF09435D47009A034C655E26BF378FA79F6",
      INIT_20 => X"9AB6CFE6FA0B1A2731383D3F3F3C372F251809F7E2CBB1957655310BE2B68858",
      INIT_21 => X"F25FC82F94F656B30D65BB0E5FADF84188CC0E4C89C3FA2F6292BFEA12385B7C",
      INIT_22 => X"4D09C2782CDE8E3AE48C32D57513AE47DE7203921FA930B538B835B0299F1384",
      INIT_23 => X"C9D4DBE0E3E3E1DCD5CCC0B2A18E7860452808E6C29B724618E7B47E460CCF8F",
      INIT_24 => X"C3EF19436B92B8DC00224362819EBAD5EF071F354ABADF01213F5A72899CAEBD",
      INIT_25 => X"D02274C3125FABF64088D0165B9FE12363A2E01C5892CB03396FA3D608386896",
      INIT_26 => X"1C940B80F568DA4BBB2996036ED840A80E73D7399BFB5AB81571CB247CD3297D",
      INIT_27 => X"B452EE8923BB53E97E12A537C757E572FE89129A22A82CB032B434B331AD29A3",
      INIT_28 => X"A86A2BEBAA6724DF9A530AC1772BDF9142F2A04EFAA650F8A047EC9134D67616",
      INIT_29 => X"04EAD0B5987A5B3B1AF8D4B08A633B12E8BC90623303D2A06C3802CB935A20E4",
      INIT_2A => X"D6E1EBF4FB02070B0E1010100F0C0803FDF6EEE5DACEC2B4A59483715D48331C",
      INIT_2B => X"2E5C8AB6E10B345C83A8CDF01234547390ADC9E3FD152C42576B7E8FA0AFBDCA",
      INIT_2C => X"1668B80857A4F03C86CF175DA3E82B6EAFEF2E6CA9E5205991C9FF34689BCDFE",
      INIT_2D => X"9D1286F869DA49B72490FB64CD359B0165C82B8CEC4AA80560BB146DC41A6FC3",
      INIT_2E => X"D067FD9226B94ADB6BF987139E28B23AC046CB4FD253D453D24FCB46C039B128",
      INIT_2F => X"BB742CE3994E02B56617C77523CF7A24CE761DC3680CAF50F1912FCD69049F38",
      INIT_30 => X"6A451FF8CFA67C5024F6C798673502CE99632CF4BB814609CC8E4E0ECC894601",
      INIT_31 => X"EBE7E2DCD5CDC4BAAEA2958777675643301B06EFD7BFA58A6E523415F5D4B28F",
      INIT_32 => X"4864819CB6CEE6FD13283C4E6071808F9DA9B5C0C9D2D9DFE5E9ECEFF0F0EFEE",
      INIT_33 => X"8DCB07437DB7F0275D93C7FA2D5E8FBEEC1A46729CC5EE143B6084A7C9EA0A2A",
      INIT_34 => X"C72482DD3892EA4299EE4497EA3C8CDC2B78C5115CA5EE367CC2064A8DCE0F4E",
      INIT_35 => X"007EFA76F06AE35AD147BC2FA21484F463D13DA9147EE64EB51A7FE346A80868",
      INIT_36 => X"44E17E19B34CE47B12A73BCE61F28212A02EBA45D059E269F075FA7D00810282",
      INIT_37 => X"9E5A16D08942F9B0651ACD8031E29140EE9A46F19B44EC9238DD8124C66707A6",
      INIT_38 => X"19F4CEA77F572D02D6AA7C4E1EEEBC8A5722EDB780480ED4995D20E2A36423E1",
      INIT_39 => X"BFB8B1A99F958A7E7163544433210EFAE6D0BAA28A70563A1E01E2C3A382603D",
      INIT_3A => X"9BB3C9DFF4081B2D3E4E5E6C7986919CA6AEB6BDC3C8CBCED0D2D2D1CFCDC9C4",
      INIT_3B => X"B7ED225588BAEB1B4A78A5D1FC275079A0C7ED1236587A9CBCDBF916334E6982",
      INIT_3C => X"1E71C31465B403509DE8337DC60E559CE12568ABEC2D6DACEA26629ED8114981",
      INIT_3D => X"D94AB92795026DD842AB137AE046AA0E70D23393F250AD0964BF1871C91F75CA",
      INIT_3E => X"F3800C9822AC34BC43C94ED256D85ADA5AD856D34FCA45BE36AE259A0F83F668",
      INIT_3F => X"741EC76F16BD6206AA4DEE8F2FCE6C0AA642DC760FA73ED469FE9124B546D665",
      INIT_40 => X"682EF3B87B3EFFC0803FFDBA7732EDA65F17CE853AEEA25406B76716C4721ECA",
      INIT_41 => X"D6B89A7A593816F3CEAA845D360DE4BA8F633609DAAB7B4A18E5B17C4710D9A1",
      INIT_42 => X"C9C6C4C0BBB5AFA89F968C8176695C4E3E2E1E0CF9E6D1BCA68F775F452B0FF3",
      INIT_43 => X"49627A92A9BED4E8FB0E1F30404F5D6A76828D97A0A8AFB6BBC0C4C7C9CACACA",
      INIT_44 => X"5F94C7FA2C5D8DBCEB1946729DC7F01940688EB3D7FB1D3F60809FBEDBF8142F",
      INIT_45 => X"1564B3004D99E42F78C1094F96DB1F63A6E82969A8E724619DD8134C85BDF42A",
      INIT_46 => X"72DC46AE157CE247AB0E71D23393F251AE0B67C21C75CE257CD2277CCF2274C5",
      INIT_47 => X"8005880B8D0E8E0E8C0A87037EF872EB63DA50C63BAF22940576E554C2309C08",
      INIT_48 => X"48E68420BC58F28C24BC53EA7F14A83ACC5EEE7E0D9C28B541CC56DF68EF76FC",
      INIT_49 => X"D08840F6AC6216C97C2EDE8E3EEC9A47F49F4AF39C44EC9238DC8024C66808A8",
      INIT_4A => X"22F4C596653401CE9A6630FAC48C531AE0A4692CEFB17232F2B06E2BE8A35E18",
      INIT_4B => X"46311C05EED6BDA4896E523518F9DABA9A7856320FEAC49E785027FED3A87C50",
      INIT_4C => X"43484B4E505051504F4D4A46423D37302920180E03F8ECDED0C2B2A292806E5A",
      INIT_4D => X"223F5B7792ACC4DDF40C22374C5F728496A6B6C6D4E2EEFA06101A222A32383E",
      INIT_4E => X"EA205488BCEE205182B1E00E3B6893BEE8123A6289B0D5FA1E416485A6C6E604",
      INIT_4F => X"A2F03E8AD6216BB4FD458CD2185DA2E5286AAAEB2A69A7E4215D98D20C447CB4",
      INIT_50 => X"53BA1E84E74AAD0E6FD02F8EEB48A5005BB60E68BF166CC2176BBE1162B40454",
      INIT_51 => X"0482FF7CF872ED66DF58CE45BB30A4188BFD6EDF4FBE2C9A0773DE49B31C84EC",
      INIT_52 => X"BC51E67A0EA032C454E474028F1CA834BE48D25AE268EE74F97C008204850685",
      INIT_53 => X"C0176EC3196EC2176BBF1265B80A5CADFE4F9FEF3F8EDD2C7AC81562AEFB4725",
      INIT_54 => X"2E90F254B51676D63695F452B00E6CC92682DE3A95F04BA5FF58B20A63BB126A",
      INIT_55 => X"2A980572DE4BB7228EF863CD36A00972DA42AA1178DE44AA1075DA3EA20669CC",
      INIT_56 => X"B730A9229A11880076EC62D84DC236AA1E920477EA5CCD3EB020900070DE4EBC",
      INIT_57 => X"DA5EE266E96CEE71F374F676F777F776F674F271EE6CE966E25ED954CF4AC43E",
      INIT_58 => X"9424B342D05EEC7A079420AC38C44ED964EE77008A129A22AA31B83EC44AD055",
      INIT_59 => X"EA8520B953EC851EB64EE67D14AA40D66C01962ABE52E5780B9D2FC152E37404",
      INIT_5A => X"E0852AD07418BC6003A649EB8D2ED07011B151F0902ECD6B09A643E07C18B450",
      INIT_5B => X"7728D88837E69544F2A04DFAA75400AC5702AD5701AB54FEA64EF69E46EC933A",
      INIT_5C => X"B46F2AE49F5912CC853EF6AE651CD48A40F6AC6116CB7F33E69A4DFFB26315C6",
      INIT_5D => X"995F24EAAF7438FCC0834608CB8D4E10D1925212D291500FCD8B4906C3803CF8",
      INIT_5E => X"2AFACA9A6A3908D7A573400EDBA874400CD7A26C3701CA945D26EEB67E450CD2",
      INIT_5F => X"68441EF9D3AD86603811E9C19870461DF3C99E74481DF1C5996C3F12E4B68758",
      INIT_60 => X"5A3F2409EED2B6997C5F422406E8C9AA8A6B4B2A0AE9C8A684623F1CF9D5B28D",
      INIT_61 => X"FFEFDECDBCAB998774624E3B2814FFEAD5C0AA947E685039220AF2D9C0A78E74",
      INIT_62 => X"5C564F49423B332B231A1208FFF5EBE1D6CBC0B4A89C8F827567594B3C2D1E0F",
      INIT_63 => X"73777B7E828487898B8D8E8F90909090908F8E8C8A888683807C7975706C6661",
      INIT_64 => X"475563717E8B98A4B0BCC7D2DDE8F2FC050E17202830383F464D53595F646A6E",
      INIT_65 => X"DCF40C233A51687E94AAC0D4E9FE1226394C5F728496A8B9CADBEBFB0B1B2A39",
      INIT_66 => X"33557798B9DAFA1B3B5A7A98B7D6F4112F4C6985A1BDD9F40F2A445E7891AAC3",
      INIT_67 => X"507CA7D2FD28527CA6CFF8214A729AC1E80F365C82A8CEF3173C6084A8CBEE10",
      INIT_68 => X"356AA0D4093D71A5D80C3E71A3D50738699ACAFA2A5989B8E61442709DCAF724",
      INIT_69 => X"E52463A1E01D5B98D6124F8BC7023E78B3EE28619BD40D457EB6ED245C92C9FF",
      INIT_6A => X"62ABF33B83CB12599FE62C71B7FC4185CA0E5194D81A5D9FE12263A4E52565A5",
      INIT_6B => X"B00254A5F74898E93988D82776C51361AFFC4996E32F7BC6125DA8F23C86D019",
      INIT_6C => X"D02C87E23C97F14BA4FD56AF075FB70E66BC1369BF156ABF1468BD1164B80B5D",
      INIT_6D => X"C62B8FF357BB1E82E447A90B6DCE2F90F050B0106FCE2D8BEA47A5025FBC1874",
      INIT_6E => X"93016FDC4AB72390FC67D33EA9137EE852BB248DF65EC62E95FC63C93096FB61",
      INIT_6F => X"3BB229A0168C0277EC61D64ABE32A6198CFE71E354C637A81989F969D848B625",
      INIT_70 => X"BF40C03FBF3EBD3BB937B532B02CA925A11D99148F0984FE77F16AE35BD44CC4",
      INIT_71 => X"23AC35BE46CE56DE65EC73F97F058B10951A9E22A62AAD30B336B83ABC3DBE3F",
      INIT_72 => X"68FA8C1DAF40D061F18111A02FBE4DDB69F784119E2BB743CF5AE670FB851099",
      INIT_73 => X"912CC661FB952EC861FA922AC25AF28920B64CE2780EA338CC61F5891CB043D5",
      INIT_74 => X"A043E78A2DD07214B658F99A3BDB7C1BBB5AFA9837D57311AF4CE98522BE5AF5",
      INIT_75 => X"9743F09C47F39E49F39D48F19B44ED963EE68E36DD842BD1771DC3680EB257FB",
      INIT_76 => X"792EE3984C00B4671ACD8032E59648F9AA5B0CBC6C1CCB7A29D88634E2903DEA",
      INIT_77 => X"4806C3803DFAB6722EEAA5601BD58F4903BC752EE79F570FC67E35EBA2580EC4",
      INIT_78 => X"06CD92581DE3A76C30F4B87C3F02C587490BCD8E4F10D1915111D1904F0ECC8A",
      INIT_79 => X"B6855321EFBC8A5723F0BC88541FEAB5804A14DEA8713A03CC945C24EBB27940",
      INIT_7A => X"593007DDB3895F340ADEB3875B2F03D6A97C4E21F3C496673809D9A9794918E7",
      INIT_7B => X"F2D1B08F6D4C2A07E5C29F7B583410EBC7A27D57320CE6BF98714A23FBD3AB82",
      INIT_7C => X"836A51381F05ECD2B79D82674B3014F8DBBFA285674A2C0DEFD0B19273533313",
      INIT_7D => X"0DFDECDBCAB9A79583715E4B382411FDE9D4BFAA95806A543E2711FAE2CBB39B",
      INITP_0E => X"C7878F1E3C71E38E38E38E39C738C739CE739CC673198CCE6663333333333266",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 9,
      READ_WIDTH_B => 9,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      INITP_0F => X"0003FFFFFFFE00007FFE001FFC01FF00FF01FC0FE07E0FC1F07C1F0F8783C3C3"
    )
    port map (
      ENAU => BU2_N1,
      ENAL => BU2_N1,
      ENBU => BU2_doutb(0),
      ENBL => BU2_doutb(0),
      SSRAU => BU2_doutb(0),
      SSRAL => BU2_doutb(0),
      SSRBU => BU2_doutb(0),
      SSRBL => BU2_doutb(0),
      CLKAU => clka,
      CLKAL => clka,
      CLKBU => BU2_doutb(0),
      CLKBL => BU2_doutb(0),
      REGCLKAU => clka,
      REGCLKAL => clka,
      REGCLKBU => BU2_doutb(0),
      REGCLKBL => BU2_doutb(0),
      REGCEAU => BU2_doutb(0),
      REGCEAL => BU2_doutb(0),
      REGCEBU => BU2_doutb(0),
      REGCEBL => BU2_doutb(0),
      CASCADEINLATA => BU2_doutb(0),
      CASCADEINLATB => BU2_doutb(0),
      CASCADEINREGA => BU2_doutb(0),
      CASCADEINREGB => BU2_doutb(0),
      CASCADEOUTLATA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED,
      CASCADEOUTLATB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED,
      CASCADEOUTREGA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED,
      CASCADEOUTREGB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED,
      DIA(31) => BU2_doutb(0),
      DIA(30) => BU2_doutb(0),
      DIA(29) => BU2_doutb(0),
      DIA(28) => BU2_doutb(0),
      DIA(27) => BU2_doutb(0),
      DIA(26) => BU2_doutb(0),
      DIA(25) => BU2_doutb(0),
      DIA(24) => BU2_doutb(0),
      DIA(23) => BU2_doutb(0),
      DIA(22) => BU2_doutb(0),
      DIA(21) => BU2_doutb(0),
      DIA(20) => BU2_doutb(0),
      DIA(19) => BU2_doutb(0),
      DIA(18) => BU2_doutb(0),
      DIA(17) => BU2_doutb(0),
      DIA(16) => BU2_doutb(0),
      DIA(15) => BU2_doutb(0),
      DIA(14) => BU2_doutb(0),
      DIA(13) => BU2_doutb(0),
      DIA(12) => BU2_doutb(0),
      DIA(11) => BU2_doutb(0),
      DIA(10) => BU2_doutb(0),
      DIA(9) => BU2_doutb(0),
      DIA(8) => BU2_doutb(0),
      DIA(7) => BU2_doutb(0),
      DIA(6) => BU2_doutb(0),
      DIA(5) => BU2_doutb(0),
      DIA(4) => BU2_doutb(0),
      DIA(3) => BU2_doutb(0),
      DIA(2) => BU2_doutb(0),
      DIA(1) => BU2_doutb(0),
      DIA(0) => BU2_doutb(0),
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIB(31) => BU2_doutb(0),
      DIB(30) => BU2_doutb(0),
      DIB(29) => BU2_doutb(0),
      DIB(28) => BU2_doutb(0),
      DIB(27) => BU2_doutb(0),
      DIB(26) => BU2_doutb(0),
      DIB(25) => BU2_doutb(0),
      DIB(24) => BU2_doutb(0),
      DIB(23) => BU2_doutb(0),
      DIB(22) => BU2_doutb(0),
      DIB(21) => BU2_doutb(0),
      DIB(20) => BU2_doutb(0),
      DIB(19) => BU2_doutb(0),
      DIB(18) => BU2_doutb(0),
      DIB(17) => BU2_doutb(0),
      DIB(16) => BU2_doutb(0),
      DIB(15) => BU2_doutb(0),
      DIB(14) => BU2_doutb(0),
      DIB(13) => BU2_doutb(0),
      DIB(12) => BU2_doutb(0),
      DIB(11) => BU2_doutb(0),
      DIB(10) => BU2_doutb(0),
      DIB(9) => BU2_doutb(0),
      DIB(8) => BU2_doutb(0),
      DIB(7) => BU2_doutb(0),
      DIB(6) => BU2_doutb(0),
      DIB(5) => BU2_doutb(0),
      DIB(4) => BU2_doutb(0),
      DIB(3) => BU2_doutb(0),
      DIB(2) => BU2_doutb(0),
      DIB(1) => BU2_doutb(0),
      DIB(0) => BU2_doutb(0),
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      ADDRAL(15) => BU2_doutb(0),
      ADDRAL(14) => addra_2(11),
      ADDRAL(13) => addra_2(10),
      ADDRAL(12) => addra_2(9),
      ADDRAL(11) => addra_2(8),
      ADDRAL(10) => addra_2(7),
      ADDRAL(9) => addra_2(6),
      ADDRAL(8) => addra_2(5),
      ADDRAL(7) => addra_2(4),
      ADDRAL(6) => addra_2(3),
      ADDRAL(5) => addra_2(2),
      ADDRAL(4) => addra_2(1),
      ADDRAL(3) => addra_2(0),
      ADDRAL(2) => BU2_doutb(0),
      ADDRAL(1) => BU2_doutb(0),
      ADDRAL(0) => BU2_doutb(0),
      ADDRAU(14) => addra_2(11),
      ADDRAU(13) => addra_2(10),
      ADDRAU(12) => addra_2(9),
      ADDRAU(11) => addra_2(8),
      ADDRAU(10) => addra_2(7),
      ADDRAU(9) => addra_2(6),
      ADDRAU(8) => addra_2(5),
      ADDRAU(7) => addra_2(4),
      ADDRAU(6) => addra_2(3),
      ADDRAU(5) => addra_2(2),
      ADDRAU(4) => addra_2(1),
      ADDRAU(3) => addra_2(0),
      ADDRAU(2) => BU2_doutb(0),
      ADDRAU(1) => BU2_doutb(0),
      ADDRAU(0) => BU2_doutb(0),
      ADDRBL(15) => BU2_doutb(0),
      ADDRBL(14) => BU2_doutb(0),
      ADDRBL(13) => BU2_doutb(0),
      ADDRBL(12) => BU2_doutb(0),
      ADDRBL(11) => BU2_doutb(0),
      ADDRBL(10) => BU2_doutb(0),
      ADDRBL(9) => BU2_doutb(0),
      ADDRBL(8) => BU2_doutb(0),
      ADDRBL(7) => BU2_doutb(0),
      ADDRBL(6) => BU2_doutb(0),
      ADDRBL(5) => BU2_doutb(0),
      ADDRBL(4) => BU2_doutb(0),
      ADDRBL(3) => BU2_doutb(0),
      ADDRBL(2) => BU2_doutb(0),
      ADDRBL(1) => BU2_doutb(0),
      ADDRBL(0) => BU2_doutb(0),
      ADDRBU(14) => BU2_doutb(0),
      ADDRBU(13) => BU2_doutb(0),
      ADDRBU(12) => BU2_doutb(0),
      ADDRBU(11) => BU2_doutb(0),
      ADDRBU(10) => BU2_doutb(0),
      ADDRBU(9) => BU2_doutb(0),
      ADDRBU(8) => BU2_doutb(0),
      ADDRBU(7) => BU2_doutb(0),
      ADDRBU(6) => BU2_doutb(0),
      ADDRBU(5) => BU2_doutb(0),
      ADDRBU(4) => BU2_doutb(0),
      ADDRBU(3) => BU2_doutb(0),
      ADDRBU(2) => BU2_doutb(0),
      ADDRBU(1) => BU2_doutb(0),
      ADDRBU(0) => BU2_doutb(0),
      WEAU(3) => BU2_doutb(0),
      WEAU(2) => BU2_doutb(0),
      WEAU(1) => BU2_doutb(0),
      WEAU(0) => BU2_doutb(0),
      WEAL(3) => BU2_doutb(0),
      WEAL(2) => BU2_doutb(0),
      WEAL(1) => BU2_doutb(0),
      WEAL(0) => BU2_doutb(0),
      WEBU(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED,
      WEBU(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED,
      WEBU(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED,
      WEBU(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED,
      WEBU(3) => BU2_doutb(0),
      WEBU(2) => BU2_doutb(0),
      WEBU(1) => BU2_doutb(0),
      WEBU(0) => BU2_doutb(0),
      WEBL(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED,
      WEBL(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED,
      WEBL(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED,
      WEBL(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED,
      WEBL(3) => BU2_doutb(0),
      WEBL(2) => BU2_doutb(0),
      WEBL(1) => BU2_doutb(0),
      WEBL(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED,
      DOA(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED,
      DOA(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED,
      DOA(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED,
      DOA(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED,
      DOA(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED,
      DOA(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED,
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED,
      DOA(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED,
      DOA(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED,
      DOA(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED,
      DOA(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED,
      DOA(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED,
      DOA(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED,
      DOA(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED,
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED,
      DOA(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED,
      DOA(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED,
      DOA(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED,
      DOA(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED,
      DOA(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED,
      DOA(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED,
      DOA(7) => douta_3(7),
      DOA(6) => douta_3(6),
      DOA(5) => douta_3(5),
      DOA(4) => douta_3(4),
      DOA(3) => douta_3(3),
      DOA(2) => douta_3(2),
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => douta_3(8),
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED,
      DOB(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED,
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED,
      DOB(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED,
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED
    );
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP : RAMB36_EXP
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_7E => X"36322E2A26221E1A16120E0A0602FEFAF6F2EEEAE6E2DEDAD6D2CECAC6C2BEBA",
      INIT_7F => X"B7B3AFABA7A39F9B97938F8B87837E7A76726E6A66625E5A56524E4A46423E3A",
      INITP_00 => X"C66663333399999CCCCCC66666673332AAAA55555555555500000000FFFFFFFF",
      INITP_01 => X"1E0F0783C1E1F0F87C3E1E0F0787C3E1E0F0F8783C1E1E0F0F8783C3C1E1F0CC",
      INITP_02 => X"FF801FF003FE007FC01FF803FE007FC01FF003FE00FF803FE00FFC01E0F0783C",
      INITP_03 => X"3FF003FF003FF003FF003FF007FE007FE007FC00FFC01FF801FF003FE007FC00",
      INITP_04 => X"FFF800003FFFFE00001FFFFF000007FE007FE003FF003FF003FF003FF003FF00",
      INITP_05 => X"FFF000007FFFFE000007FFFFE00000FFFFFC00001FFFFF000003FFFFE00000FF",
      INITP_06 => X"000007FFFFF000003FFFFF800000FFFFFC000007FFFFE000007FFFFE000003FF",
      INITP_07 => X"FFFFE000001FFFFFE000001FFFFFC000003FFFFF800000FFFFFF000001FFFFFC",
      INITP_08 => X"03FFFFFE000000FFFFFF8000007FFFFFC000003FFFFFE000001FFFFFE000001F",
      INITP_09 => X"00FFFFFF8000001FFFFFF8000001FFFFFF0000003FFFFFE000000FFFFFF80000",
      INITP_0A => X"0000000000000FFFFFFFFFFFFFC0000000000001FFFFFF8000001FFFFFFC0000",
      INITP_0B => X"FFFFFFFFE00000000000001FFFFFFFFFFFFFC0000000000000FFFFFFFFFFFFFE",
      INITP_0C => X"01FFFFFFFFFFFFFF800000000000003FFFFFFFFFFFFFE00000000000001FFFFF",
      INITP_0D => X"0000000FFFFFFFFFFFFFFE000000000000003FFFFFFFFFFFFFF8000000000000",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      INIT_00 => X"848C939AA1A8AFB5BBC0C6CBD0D5D9DEC4CBD2D9DFE4E9EDE3EAF0F5F3F9FBFE",
      INIT_01 => X"060E151D242C333A41474E555B61686E74797F858A8F959A9FA3A8ADB1B6BABE",
      INIT_02 => X"676D72787E83898E94999EA3A9AEB3B8BDC1C6CBD0D4D9DDE2E6EAEEF3F7FBFE",
      INIT_03 => X"8E959DA5ACB4BBC2CAD1D8DFE6EDF4FB02090F161D232A30363D43494F555B61",
      INIT_04 => X"3CC146CA4FD458DD61E66BEF74F87C0185098E12961A9F23A72BAF33B73B7E86",
      INIT_05 => X"94199F25AA30B63BC146CB51D65CE166EC71F67B00860B90159A1FA429AE32B7",
      INIT_06 => X"CE55DB62E96FF67C02890F951CA228AE35BB41C74DD359DF65EB71F77D02880E",
      INIT_07 => X"EC74FB820A9119A027AF36BD44CB53DA61E86FF67D048B12981FA62DB43AC148",
      INIT_08 => X"763BFFC3874B0FD4985C20E4A86C30F4B87C4004C88C4F13AF37BE46CE55DD64",
      INIT_09 => X"E9AE7237FCC085490ED2975B20E4A96D32F6BA7F4307CC905419DDA1662AEEB2",
      INIT_0A => X"4E13D89D6227ECB1763B00C58A4F14D99D6227ECB1753AFFC4884D12D79B6025",
      INIT_0B => X"A66B30F6BB81460CD1965C21E6AC7136FCC1864B10D69B6025EAB0753AFFC489",
      INIT_0C => X"F0B57B4107CD93581EE4AA7035FBC1874C12D89D6328EEB4793F04CA90551BE0",
      INIT_0D => X"2CF3B97F450CD2985E25EBB1773D03C990561CE2A86E34FAC0864C12D89E642A",
      INIT_0E => X"5C23EAB0773E04CB91581FE5AC7239FFC68C5319E0A66D33FAC0864D13D9A066",
      INIT_0F => X"7F460DD49B632AF1B87F460DD49A6128EFB67D440BD2985F26EDB47A4108CF95",
      INIT_10 => X"965D24ECB37B420AD1996027EFB67D450CD39A6229F0B87F460DD49B632AF1B8",
      INIT_11 => X"4F3317FBDFC3A78B6F53371AFEE2C6AA8E7255391D01E5C9AC9074583B1F03CE",
      INIT_12 => X"CEB2967B5F43270BEFD3B79B7F63482C10F4D8BCA084684C3014F8DCC0A4886C",
      INIT_13 => X"472B10F4D8BCA185694E3216FADFC3A78B7054381C00E5C9AD9175593E2206EA",
      INIT_14 => X"BA9E83674C3015F9DEC2A68B6F54381D01E5CAAE93775B402409EDD1B69A7E63",
      INIT_15 => X"270BF0D5B99E83674C3115FADEC3A88C71553A1F03E8CCB1957A5F43280CF1D5",
      INIT_16 => X"8E72573C2106EBCFB4997E63482C11F6DBC0A4896E53371C01E6CAAF94785D42",
      INIT_17 => X"EFD4B99E83684D3217FCE1C6AB90755A3F2409EED3B89D81664B3015FADFC4A9",
      INIT_18 => X"4A3015FADFC4AA8F74593E2409EED3B89D82684D3217FCE1C6AB90755B40250A",
      INIT_19 => X"A0866B51361B01E6CBB1967B61462B11F6DBC1A68B71563B2006EBD0B59B8065",
      INIT_1A => X"F1D6BCA1876D52381D03E8CEB3997E64492F14FADFC5AA90755A40250BF0D6BB",
      INIT_1B => X"3C2207EDD3B89E846A4F351B00E6CCB1977D62482E13F9DEC4AA8F755A40260B",
      INIT_1C => X"81674D3319FFE5CBB0967C62482E14F9DFC5AB91775C42280EF3D9BFA58B7056",
      INIT_1D => X"C2A88E745A40260CF2D8BEA48A70563C2208EED4BAA0866C52381E04EAD0B69B",
      INIT_1E => X"FDE3C9AF967C62482E15FBE1C7AD947A60462C12F8DFC5AB91775D43290FF6DC",
      INIT_1F => X"3319FFE6CCB2997F664C3219FFE5CCB2987F654B3218FEE4CBB1977D644A3016",
      INIT_20 => X"634A3017FDE4CBB1987E654B3218FFE5CCB2997F654C3219FFE6CCB3997F664C",
      INIT_21 => X"8F765C432A10F7DEC5AB92795F462C13FAE0C7AE947B61482F15FCE2C9B0967D",
      INIT_22 => X"B69D836A51381F06ECD3BAA1886F553C230AF1D7BEA58C725940270DF4DBC2A8",
      INIT_23 => X"D7BEA58C735A41280FF6DDC4AB927960472E15FCE3CAB1987F654C331A01E8CF",
      INIT_24 => X"FAEDE1D5C8BCAFA3978A7E7165584C3F33271A0E01EAD1B89F866D543B2209F0",
      INIT_25 => X"867A6D6155483C2F23170AFEF2E5D9CDC0B4A79B8F82766A5D5144382C1F1306",
      INIT_26 => X"1003F7EBDED2C6BAADA195897C7064574B3F32261A0D01F5E9DCD0C4B7AB9F92",
      INIT_27 => X"978B7E72665A4E4135291D1104F8ECE0D3C7BBAFA3968A7E7265594D4134281C",
      INIT_28 => X"1C1004F7EBDFD3C7BBAFA3968A7E72665A4D4135291D1104F8ECE0D4C8BBAFA3",
      INIT_29 => X"9F92867A6E62564A3E32261A0E02F6EADDD1C5B9ADA195897D7165584C403428",
      INIT_2A => X"1F1307FBEFE3D7CBBFB3A79B8F83776B5F53473B2F23170BFFF3E7DBCFC3B7AB",
      INIT_2B => X"9D9185796D62564A3E32261A0E02F6EADED2C6BAAEA3978B7F73675B4F43372B",
      INIT_2C => X"190D01F6EADED2C6BAAEA3978B7F73675B4F44382C201408FCF0E4D9CDC1B5A9",
      INIT_2D => X"93877B6F64584C4035291D1105FAEEE2D6CABFB3A79B8F84786C6054483D3125",
      INIT_2E => X"0AFFF3E7DCD0C4B8ADA1958A7E72665B4F43372C201408FDF1E5D9CEC2B6AA9F",
      INIT_2F => X"8074695D51463A2E23170B00F4E8DDD1C5BAAEA2978B7F74685C5145392E2216",
      INIT_30 => X"F3E8DCD0C5B9AEA2978B7F74685D51453A2E23170B00F4E9DDD1C6BAAEA3978C",
      INIT_31 => X"64594D42362B1F1408FDF1E6DACFC3B8ACA195897E72675B5044392D21160AFF",
      INIT_32 => X"D4C8BDB1A69A8F83786D61564A3F33281C1105FAEEE3D7CCC0B5A99E92877B70",
      INIT_33 => X"41352A1F1308FCF1E6DACFC3B8ADA1968A7F74685D51463B2F24180D01F6EBDF",
      INIT_34 => X"ACA1958A7F73685D51463B2F24190D02F7EBE0D5C9BEB2A79C90857A6E63584C",
      INIT_35 => X"150AFEF3E8DDD1C6BBB0A4998E83776C61554A3F34281D1206FBF0E4D9CEC3B7",
      INIT_36 => X"7C71665B4F44392E23170C01F6EADFD4C9BEB2A79C91857A6F64584D42372C20",
      INIT_37 => X"E1D6CBC0B5AA9E93887D72675C50453A2F24190D02F7ECE1D6CABFB4A99E9387",
      INIT_38 => X"45392E23180D02F7ECE1D6CBC0B4A99E93887D72675C51453A2F24190E03F8EC",
      INIT_39 => X"A69B90857A6F64594E43382D22170C00F5EADFD4C9BEB3A89D92877C71665B50",
      INIT_3A => X"05FAEFE4D9CFC4B9AEA3988D82776C61564B40352A1F1409FEF3E8DDD2C7BCB1",
      INIT_3B => X"63584D42372C21170C01F6EBE0D5CABFB4A99E94897E73685D52473C31261B10",
      INIT_3C => X"BFB4A99E93887E73685D52473C32271C1106FBF0E5DBD0C5BAAFA4998E84796E",
      INIT_3D => X"180E03F8EDE3D8CDC2B7ADA2978C81776C61564B40362B20150A00F5EADFD4C9",
      INIT_3E => X"70665B50463B30251B1005FAF0E5DACFC5BAAFA49A8F84796F64594E44392E23",
      INIT_3F => X"C7BCB1A79C91877C71675C51473C31271C1106FCF1E6DCD1C6BBB1A69B91867B",
      INIT_40 => X"1B1106FBF1E6DBD1C6BCB1A69C91867C71675C51473C31271C1107FCF1E7DCD1",
      INIT_41 => X"6E63594E44392F24190F04FAEFE5DACFC5BAB0A59A90857B70655B50463B3026",
      INIT_42 => X"BFB4AA9F958A80756B60564B41362C21170C02F7ECE2D7CDC2B8ADA3988E8378",
      INIT_43 => X"0E04F9EFE4DACFC5BAB0A69B91867C71675C52473D32281D1308FEF3E9DED4C9",
      INIT_44 => X"5C51473C32281D1308FEF4E9DFD4CAC0B5ABA0968B81776C62574D42382D2319",
      INIT_45 => X"A89D93897E74695F554A40362B21170C02F7EDE3D8CEC4B9AFA49A90857B7066",
      INIT_46 => X"F2E7DDD3C9BEB4AA9F958B80766C61574D43382E24190F05FAF0E6DBD1C7BCB2",
      INIT_47 => X"3A30261C1107FDF3E8DED4CABFB5ABA0968C82776D63594E443A2F251B1106FC",
      INIT_48 => X"81776D63584E443A30251B1107FDF2E8DED4C9BFB5ABA1968C82786D63594F44",
      INIT_49 => X"C6BCB2A89E948A7F756B61574D42382E241A1005FBF1E7DDD3C8BEB4AAA0968B",
      INIT_4A => X"0A00F6ECE2D8CEC3B9AFA59B91877D73685E544A40362C22170D03F9EFE5DBD1",
      INIT_4B => X"4C42382E241A1006FCF2E8DED4C9BFB5ABA1978D83796F655B51473C32281E14",
      INIT_4C => X"8D83796F655B51473D33291F150B01F7EDE3D9CFC5BAB0A69C92887E746A6056",
      INIT_4D => X"CCC2B8AEA49A90867C72685E544A40362C22180E04FAF0E6DDD3C9BFB5ABA197",
      INIT_4E => X"09FFF5EBE1D7CEC4BAB0A69C92887E746A61574D43392F251B1107FDF3E9DFD6",
      INIT_4F => X"453B31271D140A00F6ECE2D8CFC5BBB1A79D938980766C62584E443A31271D13",
      INIT_50 => X"7F756C62584E443B31271D130900F6ECE2D8CFC5BBB1A79D948A80766C62594F",
      INIT_51 => X"B8AEA49B91877D746A60564D43392F261C1208FEF5EBE1D7CEC4BAB0A69D9389",
      INIT_52 => X"EFE6DCD2C9BFB5ABA2988E857B71675E544A40372D23191006FCF3E9DFD5CCC2",
      INIT_53 => X"928E89847F7A75716C67625D58544F4A45403B36322D28231E1915100B0601F9",
      INIT_54 => X"2D28231E1915100B0601FCF8F3EEE9E4E0DBD6D1CCC7C3BEB9B4AFABA6A19C97",
      INIT_55 => X"C6C1BDB8B3AEA9A5A09B96918D88837E7975706B66615D58534E4945403B3631",
      INIT_56 => X"5F5A55514C47423E39342F2A26211C17130E0904FFFBF6F1ECE8E3DED9D4D0CB",
      INIT_57 => X"F7F2EDE9E4DFDAD6D1CCC7C3BEB9B4B0ABA6A19D98938E8A85807B77726D6864",
      INIT_58 => X"8E8A85807B77726D69645F5A56514C47433E3935302B26221D18130F0A0500FC",
      INIT_59 => X"25201C17120D0904FFFBF6F1EDE8E3DEDAD5D0CCC7C2BDB9B4AFABA6A19C9893",
      INIT_5A => X"BBB6B2ADA8A49F9A96918C87837E7975706B67625D59544F4B46413C38332E2A",
      INIT_5B => X"504C47423E3934302B26221D18140F0A0601FCF8F3EEEAE5E0DCD7D2CEC9C4C0",
      INIT_5C => X"E5E0DCD7D2CEC9C4C0BBB6B2ADA9A49F9B96918D88837F7A75716C67635E5A55",
      INIT_5D => X"7974706B66625D58544F4B46413D38342F2A26211C18130F0A0501FCF7F3EEE9",
      INIT_5E => X"0C0703FEFAF5F1ECE7E3DEDAD5D0CCC7C3BEB9B5B0ACA7A29E9994908B87827D",
      INIT_5F => X"9F9A96918C88837F7A76716C68635F5A55514C48433F3A35312C28231E1A1511",
      INIT_60 => X"312C28231E1A15110C0803FFFAF5F1ECE8E3DFDAD6D1CCC8C3BFBAB6B1ACA8A3",
      INIT_61 => X"C2BDB9B4B0ABA7A29E9995908C87827E7975706C67635E5A55514C47433E3A35",
      INIT_62 => X"534E4A45413C38332F2A26211C18130F0A0601FDF8F4EFEBE6E2DDD9D4D0CBC7",
      INIT_63 => X"E3DEDAD5D1CCC8C3BFBAB6B1ADA8A49F9B96928D8984807B77726E6965605C57",
      INIT_64 => X"726E6965605C57534E4A45413C38332F2B26221D1914100B0702FEF9F5F0ECE7",
      INIT_65 => X"01FCF8F4EFEBE6E2DDD9D4D0CBC7C3BEBAB5B1ACA8A39F9A96918D8884807B77",
      INIT_66 => X"8F8B86827D7974706C67635E5A55514D48443F3B36322D2925201C17130E0A05",
      INIT_67 => X"1D18140F0B0702FEF9F5F0ECE8E3DFDAD6D2CDC9C4C0BBB7B3AEAAA5A19C9894",
      INIT_68 => X"AAA5A19C98948F8B86827E7975706C68635F5A56524D4944403C37332E2A2521",
      INIT_69 => X"36322D2924201C17130F0A0601FDF9F4F0EBE7E3DEDAD6D1CDC8C4C0BBB7B2AE",
      INIT_6A => X"C2BDB9B5B0ACA8A39F9A96928D8985807C78736F6A66625D5955504C47433F3A",
      INIT_6B => X"4D4944403B37332E2A26211D1914100C0703FFFAF6F2EDE9E5E0DCD7D3CFCAC6",
      INIT_6C => X"D7D3CFCAC6C2BDB9B5B0ACA8A49F9B97928E8A85817D7874706B67635E5A5651",
      INIT_6D => X"615D5954504C48433F3B36322E2925211C1814100B0703FEFAF6F1EDE9E4E0DC",
      INIT_6E => X"EBE7E2DEDAD5D1CDC8C4C0BCB7B3AFAAA6A29E9995918C88847F7B77736E6A66",
      INIT_6F => X"746F6B67635E5A56514D4945403C38342F2B27221E1A16110D090400FCF8F3EF",
      INIT_70 => X"FCF8F3EFEBE7E2DEDAD6D1CDC9C5C0BCB8B4AFABA7A39E9A96918D8985807C78",
      INIT_71 => X"847F7B77736E6A66625D5955514D4844403C37332F2B26221E1A15110D090400",
      INIT_72 => X"0B0602FEFAF6F1EDE9E5E1DCD8D4D0CBC7C3BFBBB6B2AEAAA5A19D9994908C88",
      INIT_73 => X"918D8985807C7874706B67635F5B56524E4A46413D3935312C2824201C17130F",
      INIT_74 => X"17130F0B0702FEFAF6F2EDE9E5E1DDD9D4D0CCC8C4BFBBB7B3AFAAA6A29E9A95",
      INIT_75 => X"9D9994908C8884807B77736F6B67625E5A56524E4945413D3935302C2824201B",
      INIT_76 => X"221E1915110D090501FCF8F4F0ECE8E3DFDBD7D3CFCBC6C2BEBAB6B2ADA9A5A1",
      INIT_77 => X"A6A29E9A96918D8985817D7975706C6864605C58534F4B47433F3B36322E2A26",
      INIT_78 => X"2A26221E1A15110D090501FDF9F5F0ECE8E4E0DCD8D4CFCBC7C3BFBBB7B3AEAA",
      INIT_79 => X"ADA9A5A19D9995918D8884807C7874706C68645F5B57534F4B47433F3A36322E",
      INIT_7A => X"302C2824201C1814100B0703FFFBF7F3EFEBE7E3DEDAD6D2CECAC6C2BEBAB6B1",
      INIT_7B => X"B2AEAAA6A29E9A96928E8A86827E7A75716D6965615D5955514D4945403C3834",
      INIT_7C => X"34302C2824201C1814100C080400FCF7F3EFEBE7E3DFDBD7D3CFCBC7C3BFBBB7",
      INIT_7D => X"B6B1ADA9A5A19D9995918D8985817D7975716D6965615D5955514D4844403C38",
      INITP_0E => X"00000000007FFFFFFFFFFFFFFC000000000000001FFFFFFFFFFFFFFF00000000",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 9,
      READ_WIDTH_B => 9,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      INITP_0F => X"000000000003FFFFFFFFFFFFFFFC000000000000000FFFFFFFFFFFFFFFE00000"
    )
    port map (
      ENAU => BU2_N1,
      ENAL => BU2_N1,
      ENBU => BU2_doutb(0),
      ENBL => BU2_doutb(0),
      SSRAU => BU2_doutb(0),
      SSRAL => BU2_doutb(0),
      SSRBU => BU2_doutb(0),
      SSRBL => BU2_doutb(0),
      CLKAU => clka,
      CLKAL => clka,
      CLKBU => BU2_doutb(0),
      CLKBL => BU2_doutb(0),
      REGCLKAU => clka,
      REGCLKAL => clka,
      REGCLKBU => BU2_doutb(0),
      REGCLKBL => BU2_doutb(0),
      REGCEAU => BU2_doutb(0),
      REGCEAL => BU2_doutb(0),
      REGCEBU => BU2_doutb(0),
      REGCEBL => BU2_doutb(0),
      CASCADEINLATA => BU2_doutb(0),
      CASCADEINLATB => BU2_doutb(0),
      CASCADEINREGA => BU2_doutb(0),
      CASCADEINREGB => BU2_doutb(0),
      CASCADEOUTLATA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED,
      CASCADEOUTLATB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED,
      CASCADEOUTREGA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED,
      CASCADEOUTREGB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED,
      DIA(31) => BU2_doutb(0),
      DIA(30) => BU2_doutb(0),
      DIA(29) => BU2_doutb(0),
      DIA(28) => BU2_doutb(0),
      DIA(27) => BU2_doutb(0),
      DIA(26) => BU2_doutb(0),
      DIA(25) => BU2_doutb(0),
      DIA(24) => BU2_doutb(0),
      DIA(23) => BU2_doutb(0),
      DIA(22) => BU2_doutb(0),
      DIA(21) => BU2_doutb(0),
      DIA(20) => BU2_doutb(0),
      DIA(19) => BU2_doutb(0),
      DIA(18) => BU2_doutb(0),
      DIA(17) => BU2_doutb(0),
      DIA(16) => BU2_doutb(0),
      DIA(15) => BU2_doutb(0),
      DIA(14) => BU2_doutb(0),
      DIA(13) => BU2_doutb(0),
      DIA(12) => BU2_doutb(0),
      DIA(11) => BU2_doutb(0),
      DIA(10) => BU2_doutb(0),
      DIA(9) => BU2_doutb(0),
      DIA(8) => BU2_doutb(0),
      DIA(7) => BU2_doutb(0),
      DIA(6) => BU2_doutb(0),
      DIA(5) => BU2_doutb(0),
      DIA(4) => BU2_doutb(0),
      DIA(3) => BU2_doutb(0),
      DIA(2) => BU2_doutb(0),
      DIA(1) => BU2_doutb(0),
      DIA(0) => BU2_doutb(0),
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIB(31) => BU2_doutb(0),
      DIB(30) => BU2_doutb(0),
      DIB(29) => BU2_doutb(0),
      DIB(28) => BU2_doutb(0),
      DIB(27) => BU2_doutb(0),
      DIB(26) => BU2_doutb(0),
      DIB(25) => BU2_doutb(0),
      DIB(24) => BU2_doutb(0),
      DIB(23) => BU2_doutb(0),
      DIB(22) => BU2_doutb(0),
      DIB(21) => BU2_doutb(0),
      DIB(20) => BU2_doutb(0),
      DIB(19) => BU2_doutb(0),
      DIB(18) => BU2_doutb(0),
      DIB(17) => BU2_doutb(0),
      DIB(16) => BU2_doutb(0),
      DIB(15) => BU2_doutb(0),
      DIB(14) => BU2_doutb(0),
      DIB(13) => BU2_doutb(0),
      DIB(12) => BU2_doutb(0),
      DIB(11) => BU2_doutb(0),
      DIB(10) => BU2_doutb(0),
      DIB(9) => BU2_doutb(0),
      DIB(8) => BU2_doutb(0),
      DIB(7) => BU2_doutb(0),
      DIB(6) => BU2_doutb(0),
      DIB(5) => BU2_doutb(0),
      DIB(4) => BU2_doutb(0),
      DIB(3) => BU2_doutb(0),
      DIB(2) => BU2_doutb(0),
      DIB(1) => BU2_doutb(0),
      DIB(0) => BU2_doutb(0),
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      ADDRAL(15) => BU2_doutb(0),
      ADDRAL(14) => addra_2(11),
      ADDRAL(13) => addra_2(10),
      ADDRAL(12) => addra_2(9),
      ADDRAL(11) => addra_2(8),
      ADDRAL(10) => addra_2(7),
      ADDRAL(9) => addra_2(6),
      ADDRAL(8) => addra_2(5),
      ADDRAL(7) => addra_2(4),
      ADDRAL(6) => addra_2(3),
      ADDRAL(5) => addra_2(2),
      ADDRAL(4) => addra_2(1),
      ADDRAL(3) => addra_2(0),
      ADDRAL(2) => BU2_doutb(0),
      ADDRAL(1) => BU2_doutb(0),
      ADDRAL(0) => BU2_doutb(0),
      ADDRAU(14) => addra_2(11),
      ADDRAU(13) => addra_2(10),
      ADDRAU(12) => addra_2(9),
      ADDRAU(11) => addra_2(8),
      ADDRAU(10) => addra_2(7),
      ADDRAU(9) => addra_2(6),
      ADDRAU(8) => addra_2(5),
      ADDRAU(7) => addra_2(4),
      ADDRAU(6) => addra_2(3),
      ADDRAU(5) => addra_2(2),
      ADDRAU(4) => addra_2(1),
      ADDRAU(3) => addra_2(0),
      ADDRAU(2) => BU2_doutb(0),
      ADDRAU(1) => BU2_doutb(0),
      ADDRAU(0) => BU2_doutb(0),
      ADDRBL(15) => BU2_doutb(0),
      ADDRBL(14) => BU2_doutb(0),
      ADDRBL(13) => BU2_doutb(0),
      ADDRBL(12) => BU2_doutb(0),
      ADDRBL(11) => BU2_doutb(0),
      ADDRBL(10) => BU2_doutb(0),
      ADDRBL(9) => BU2_doutb(0),
      ADDRBL(8) => BU2_doutb(0),
      ADDRBL(7) => BU2_doutb(0),
      ADDRBL(6) => BU2_doutb(0),
      ADDRBL(5) => BU2_doutb(0),
      ADDRBL(4) => BU2_doutb(0),
      ADDRBL(3) => BU2_doutb(0),
      ADDRBL(2) => BU2_doutb(0),
      ADDRBL(1) => BU2_doutb(0),
      ADDRBL(0) => BU2_doutb(0),
      ADDRBU(14) => BU2_doutb(0),
      ADDRBU(13) => BU2_doutb(0),
      ADDRBU(12) => BU2_doutb(0),
      ADDRBU(11) => BU2_doutb(0),
      ADDRBU(10) => BU2_doutb(0),
      ADDRBU(9) => BU2_doutb(0),
      ADDRBU(8) => BU2_doutb(0),
      ADDRBU(7) => BU2_doutb(0),
      ADDRBU(6) => BU2_doutb(0),
      ADDRBU(5) => BU2_doutb(0),
      ADDRBU(4) => BU2_doutb(0),
      ADDRBU(3) => BU2_doutb(0),
      ADDRBU(2) => BU2_doutb(0),
      ADDRBU(1) => BU2_doutb(0),
      ADDRBU(0) => BU2_doutb(0),
      WEAU(3) => BU2_doutb(0),
      WEAU(2) => BU2_doutb(0),
      WEAU(1) => BU2_doutb(0),
      WEAU(0) => BU2_doutb(0),
      WEAL(3) => BU2_doutb(0),
      WEAL(2) => BU2_doutb(0),
      WEAL(1) => BU2_doutb(0),
      WEAL(0) => BU2_doutb(0),
      WEBU(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED,
      WEBU(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED,
      WEBU(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED,
      WEBU(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED,
      WEBU(3) => BU2_doutb(0),
      WEBU(2) => BU2_doutb(0),
      WEBU(1) => BU2_doutb(0),
      WEBU(0) => BU2_doutb(0),
      WEBL(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED,
      WEBL(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED,
      WEBL(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED,
      WEBL(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED,
      WEBL(3) => BU2_doutb(0),
      WEBL(2) => BU2_doutb(0),
      WEBL(1) => BU2_doutb(0),
      WEBL(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED,
      DOA(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED,
      DOA(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED,
      DOA(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED,
      DOA(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED,
      DOA(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED,
      DOA(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED,
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED,
      DOA(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED,
      DOA(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED,
      DOA(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED,
      DOA(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED,
      DOA(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED,
      DOA(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED,
      DOA(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED,
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED,
      DOA(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED,
      DOA(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED,
      DOA(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED,
      DOA(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED,
      DOA(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED,
      DOA(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED,
      DOA(7) => douta_3(16),
      DOA(6) => douta_3(15),
      DOA(5) => douta_3(14),
      DOA(4) => douta_3(13),
      DOA(3) => douta_3(12),
      DOA(2) => douta_3(11),
      DOA(1) => douta_3(10),
      DOA(0) => douta_3(9),
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => douta_3(17),
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED,
      DOB(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED,
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED,
      DOB(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED,
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED
    );
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP : RAMB36_EXP
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_7E => X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCB",
      INIT_7F => X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
      INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000",
      INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_08 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_09 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_0A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_0B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_0C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_0D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      INIT_00 => X"FEFCFAF8F6F4F2F0EEECEAE8E6E4E2E0DDD9D5D1CDC9C5C1BBB3ABA397876F3F",
      INIT_01 => X"1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100",
      INIT_02 => X"2F2E2E2D2D2C2C2B2B2A2A29292828272726262525242423232222212120201F",
      INIT_03 => X"3E3E3D3D3C3C3B3B3A3A3939383837373736363535343433333232313130302F",
      INIT_04 => X"4746464646454545454444444443434343434242424241414141404040403F3F",
      INIT_05 => X"4E4E4E4E4D4D4D4D4C4C4C4C4B4B4B4B4A4A4A4A4A4949494948484848474747",
      INIT_06 => X"5656555555555454545454535353535252525251515151505050504F4F4F4F4F",
      INIT_07 => X"5D5D5D5D5D5C5C5C5C5B5B5B5B5A5A5A5A595959595958585858575757575656",
      INIT_08 => X"6262626262626261616161616161616060606060606060605F5F5F5F5E5E5E5E",
      INIT_09 => X"6666666665656565656565656564646464646464646463636363636363636262",
      INIT_0A => X"6A6A696969696969696969686868686868686867676767676767676766666666",
      INIT_0B => X"6D6D6D6D6D6D6D6D6C6C6C6C6C6C6C6C6B6B6B6B6B6B6B6B6B6A6A6A6A6A6A6A",
      INIT_0C => X"717171717170707070707070706F6F6F6F6F6F6F6F6F6E6E6E6E6E6E6E6E6E6D",
      INIT_0D => X"7574747474747474747473737373737373737372727272727272727271717171",
      INIT_0E => X"7878787878787877777777777777777676767676767676767575757575757575",
      INIT_0F => X"7C7C7C7B7B7B7B7B7B7B7B7B7A7A7A7A7A7A7A7A7A7979797979797979797878",
      INIT_10 => X"7F7F7F7F7F7F7F7F7E7E7E7E7E7E7E7E7E7D7D7D7D7D7D7D7D7D7C7C7C7C7C7C",
      INIT_11 => X"818181818181818181818181808080808080808080808080808080808080807F",
      INIT_12 => X"8383838383838383828282828282828282828282828282828282818181818181",
      INIT_13 => X"8585858484848484848484848484848484848484848483838383838383838383",
      INIT_14 => X"8686868686868686868686868686868686858585858585858585858585858585",
      INIT_15 => X"8888888888888888888888878787878787878787878787878787878787878686",
      INIT_16 => X"8A8A8A8A8A8A8989898989898989898989898989898989898988888888888888",
      INIT_17 => X"8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8A8A8A8A8A8A8A8A8A8A8A8A8A",
      INIT_18 => X"8D8D8D8D8D8D8D8D8D8D8D8D8D8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C",
      INIT_19 => X"8F8F8F8F8F8F8F8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8D8D8D8D8D8D",
      INIT_1A => X"909090909090909090909090909090909090908F8F8F8F8F8F8F8F8F8F8F8F8F",
      INIT_1B => X"9292929292929292929292929291919191919191919191919191919191919191",
      INIT_1C => X"9494949494939393939393939393939393939393939393939392929292929292",
      INIT_1D => X"9595959595959595959595959595959595959494949494949494949494949494",
      INIT_1E => X"9797979797979797979796969696969696969696969696969696969696969595",
      INIT_1F => X"9999989898989898989898989898989898989898989897979797979797979797",
      INIT_20 => X"9A9A9A9A9A9A9A9A9A9A9A9A9A9A999999999999999999999999999999999999",
      INIT_21 => X"9C9C9C9C9C9C9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9A9A9A9A9A9A",
      INIT_22 => X"9D9D9D9D9D9D9D9D9D9D9D9D9D9D9D9D9D9D9C9C9C9C9C9C9C9C9C9C9C9C9C9C",
      INIT_23 => X"9F9F9F9F9F9F9F9F9F9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9E9D9D",
      INIT_24 => X"A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A09F9F9F9F9F9F9F9F9F9F9F",
      INIT_25 => X"A1A1A1A1A1A1A1A1A1A1A1A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0",
      INIT_26 => X"A2A2A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1",
      INIT_27 => X"A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2",
      INIT_28 => X"A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A2A2A2A2A2A2A2A2",
      INIT_29 => X"A4A4A4A4A4A4A4A4A4A4A4A4A4A4A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3A3",
      INIT_2A => X"A5A5A5A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4",
      INIT_2B => X"A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5",
      INIT_2C => X"A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A5A5A5A5A5A5A5A5",
      INIT_2D => X"A7A7A7A7A7A7A7A7A7A7A7A7A7A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6",
      INIT_2E => X"A8A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7",
      INIT_2F => X"A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8A8",
      INIT_30 => X"A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A8A8A8A8A8A8A8A8A8A8",
      INIT_31 => X"AAAAAAAAAAAAAAAAAAA9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9",
      INIT_32 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
      INIT_33 => X"ABABABABABABABABABABABABABABABABABABABABABABABABABABABABABAAAAAA",
      INIT_34 => X"ACACACACACACACACACACACACACACACACABABABABABABABABABABABABABABABAB",
      INIT_35 => X"ADADACACACACACACACACACACACACACACACACACACACACACACACACACACACACACAC",
      INIT_36 => X"ADADADADADADADADADADADADADADADADADADADADADADADADADADADADADADADAD",
      INIT_37 => X"AEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEADADADADADADADADADADAD",
      INIT_38 => X"AFAFAFAFAFAFAFAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAE",
      INIT_39 => X"AFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAF",
      INIT_3A => X"B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0AFAFAFAFAFAFAFAF",
      INIT_3B => X"B1B1B1B1B1B1B1B1B1B1B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0B0",
      INIT_3C => X"B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1",
      INIT_3D => X"B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B1B1B1B1B1",
      INIT_3E => X"B3B3B3B3B3B3B3B3B3B3B3B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2",
      INIT_3F => X"B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3",
      INIT_40 => X"B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B3B3B3B3B3",
      INIT_41 => X"B5B5B5B5B5B5B5B5B5B5B5B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4B4",
      INIT_42 => X"B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5",
      INIT_43 => X"B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B5B5B5B5B5B5",
      INIT_44 => X"B7B7B7B7B7B7B7B7B7B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6B6",
      INIT_45 => X"B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7",
      INIT_46 => X"B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B7B7B7B7B7B7B7B7",
      INIT_47 => X"B9B9B9B9B9B9B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8B8",
      INIT_48 => X"B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9",
      INIT_49 => X"BABABABABABABABABABABABABABABABABABABABAB9B9B9B9B9B9B9B9B9B9B9B9",
      INIT_4A => X"BBBBBABABABABABABABABABABABABABABABABABABABABABABABABABABABABABA",
      INIT_4B => X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
      INIT_4C => X"BCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
      INIT_4D => X"BCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBC",
      INIT_4E => X"BDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBCBCBCBCBC",
      INIT_4F => X"BEBEBEBEBEBEBEBEBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBD",
      INIT_50 => X"BEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBEBE",
      INIT_51 => X"BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBEBEBEBEBEBEBEBEBEBEBEBEBE",
      INIT_52 => X"BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF",
      INIT_53 => X"C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0BF",
      INIT_54 => X"C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0",
      INIT_55 => X"C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0",
      INIT_56 => X"C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C0C0C0C0C0C0C0C0C0C0C0C0",
      INIT_57 => X"C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1",
      INIT_58 => X"C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1",
      INIT_59 => X"C2C2C2C2C2C2C2C2C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1",
      INIT_5A => X"C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2",
      INIT_5B => X"C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2",
      INIT_5C => X"C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2",
      INIT_5D => X"C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C2C2C2C2C2",
      INIT_5E => X"C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3",
      INIT_5F => X"C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3",
      INIT_60 => X"C4C4C4C4C4C4C4C4C4C4C4C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3",
      INIT_61 => X"C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4",
      INIT_62 => X"C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4",
      INIT_63 => X"C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4C4",
      INIT_64 => X"C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C4C4C4C4C4C4",
      INIT_65 => X"C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5",
      INIT_66 => X"C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5",
      INIT_67 => X"C6C6C6C6C6C6C6C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5",
      INIT_68 => X"C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6",
      INIT_69 => X"C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6",
      INIT_6A => X"C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6",
      INIT_6B => X"C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C6C6C6C6C6C6C6C6C6C6C6C6C6C6",
      INIT_6C => X"C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7",
      INIT_6D => X"C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7",
      INIT_6E => X"C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7",
      INIT_6F => X"C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C7C7C7C7",
      INIT_70 => X"C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8",
      INIT_71 => X"C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8",
      INIT_72 => X"C9C9C9C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8",
      INIT_73 => X"C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9",
      INIT_74 => X"C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9",
      INIT_75 => X"C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9",
      INIT_76 => X"CACACACACACACACACAC9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9C9",
      INIT_77 => X"CACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACA",
      INIT_78 => X"CACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACA",
      INIT_79 => X"CACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACA",
      INIT_7A => X"CBCBCBCBCBCBCBCBCBCBCBCBCACACACACACACACACACACACACACACACACACACACA",
      INIT_7B => X"CBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCB",
      INIT_7C => X"CBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCB",
      INIT_7D => X"CBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCB",
      INITP_0E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 9,
      READ_WIDTH_B => 9,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      INITP_0F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    )
    port map (
      ENAU => BU2_N1,
      ENAL => BU2_N1,
      ENBU => BU2_doutb(0),
      ENBL => BU2_doutb(0),
      SSRAU => BU2_doutb(0),
      SSRAL => BU2_doutb(0),
      SSRBU => BU2_doutb(0),
      SSRBL => BU2_doutb(0),
      CLKAU => clka,
      CLKAL => clka,
      CLKBU => BU2_doutb(0),
      CLKBL => BU2_doutb(0),
      REGCLKAU => clka,
      REGCLKAL => clka,
      REGCLKBU => BU2_doutb(0),
      REGCLKBL => BU2_doutb(0),
      REGCEAU => BU2_doutb(0),
      REGCEAL => BU2_doutb(0),
      REGCEBU => BU2_doutb(0),
      REGCEBL => BU2_doutb(0),
      CASCADEINLATA => BU2_doutb(0),
      CASCADEINLATB => BU2_doutb(0),
      CASCADEINREGA => BU2_doutb(0),
      CASCADEINREGB => BU2_doutb(0),
      CASCADEOUTLATA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED,
      CASCADEOUTLATB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED,
      CASCADEOUTREGA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED,
      CASCADEOUTREGB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED,
      DIA(31) => BU2_doutb(0),
      DIA(30) => BU2_doutb(0),
      DIA(29) => BU2_doutb(0),
      DIA(28) => BU2_doutb(0),
      DIA(27) => BU2_doutb(0),
      DIA(26) => BU2_doutb(0),
      DIA(25) => BU2_doutb(0),
      DIA(24) => BU2_doutb(0),
      DIA(23) => BU2_doutb(0),
      DIA(22) => BU2_doutb(0),
      DIA(21) => BU2_doutb(0),
      DIA(20) => BU2_doutb(0),
      DIA(19) => BU2_doutb(0),
      DIA(18) => BU2_doutb(0),
      DIA(17) => BU2_doutb(0),
      DIA(16) => BU2_doutb(0),
      DIA(15) => BU2_doutb(0),
      DIA(14) => BU2_doutb(0),
      DIA(13) => BU2_doutb(0),
      DIA(12) => BU2_doutb(0),
      DIA(11) => BU2_doutb(0),
      DIA(10) => BU2_doutb(0),
      DIA(9) => BU2_doutb(0),
      DIA(8) => BU2_doutb(0),
      DIA(7) => BU2_doutb(0),
      DIA(6) => BU2_doutb(0),
      DIA(5) => BU2_doutb(0),
      DIA(4) => BU2_doutb(0),
      DIA(3) => BU2_doutb(0),
      DIA(2) => BU2_doutb(0),
      DIA(1) => BU2_doutb(0),
      DIA(0) => BU2_doutb(0),
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIB(31) => BU2_doutb(0),
      DIB(30) => BU2_doutb(0),
      DIB(29) => BU2_doutb(0),
      DIB(28) => BU2_doutb(0),
      DIB(27) => BU2_doutb(0),
      DIB(26) => BU2_doutb(0),
      DIB(25) => BU2_doutb(0),
      DIB(24) => BU2_doutb(0),
      DIB(23) => BU2_doutb(0),
      DIB(22) => BU2_doutb(0),
      DIB(21) => BU2_doutb(0),
      DIB(20) => BU2_doutb(0),
      DIB(19) => BU2_doutb(0),
      DIB(18) => BU2_doutb(0),
      DIB(17) => BU2_doutb(0),
      DIB(16) => BU2_doutb(0),
      DIB(15) => BU2_doutb(0),
      DIB(14) => BU2_doutb(0),
      DIB(13) => BU2_doutb(0),
      DIB(12) => BU2_doutb(0),
      DIB(11) => BU2_doutb(0),
      DIB(10) => BU2_doutb(0),
      DIB(9) => BU2_doutb(0),
      DIB(8) => BU2_doutb(0),
      DIB(7) => BU2_doutb(0),
      DIB(6) => BU2_doutb(0),
      DIB(5) => BU2_doutb(0),
      DIB(4) => BU2_doutb(0),
      DIB(3) => BU2_doutb(0),
      DIB(2) => BU2_doutb(0),
      DIB(1) => BU2_doutb(0),
      DIB(0) => BU2_doutb(0),
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      ADDRAL(15) => BU2_doutb(0),
      ADDRAL(14) => addra_2(11),
      ADDRAL(13) => addra_2(10),
      ADDRAL(12) => addra_2(9),
      ADDRAL(11) => addra_2(8),
      ADDRAL(10) => addra_2(7),
      ADDRAL(9) => addra_2(6),
      ADDRAL(8) => addra_2(5),
      ADDRAL(7) => addra_2(4),
      ADDRAL(6) => addra_2(3),
      ADDRAL(5) => addra_2(2),
      ADDRAL(4) => addra_2(1),
      ADDRAL(3) => addra_2(0),
      ADDRAL(2) => BU2_doutb(0),
      ADDRAL(1) => BU2_doutb(0),
      ADDRAL(0) => BU2_doutb(0),
      ADDRAU(14) => addra_2(11),
      ADDRAU(13) => addra_2(10),
      ADDRAU(12) => addra_2(9),
      ADDRAU(11) => addra_2(8),
      ADDRAU(10) => addra_2(7),
      ADDRAU(9) => addra_2(6),
      ADDRAU(8) => addra_2(5),
      ADDRAU(7) => addra_2(4),
      ADDRAU(6) => addra_2(3),
      ADDRAU(5) => addra_2(2),
      ADDRAU(4) => addra_2(1),
      ADDRAU(3) => addra_2(0),
      ADDRAU(2) => BU2_doutb(0),
      ADDRAU(1) => BU2_doutb(0),
      ADDRAU(0) => BU2_doutb(0),
      ADDRBL(15) => BU2_doutb(0),
      ADDRBL(14) => BU2_doutb(0),
      ADDRBL(13) => BU2_doutb(0),
      ADDRBL(12) => BU2_doutb(0),
      ADDRBL(11) => BU2_doutb(0),
      ADDRBL(10) => BU2_doutb(0),
      ADDRBL(9) => BU2_doutb(0),
      ADDRBL(8) => BU2_doutb(0),
      ADDRBL(7) => BU2_doutb(0),
      ADDRBL(6) => BU2_doutb(0),
      ADDRBL(5) => BU2_doutb(0),
      ADDRBL(4) => BU2_doutb(0),
      ADDRBL(3) => BU2_doutb(0),
      ADDRBL(2) => BU2_doutb(0),
      ADDRBL(1) => BU2_doutb(0),
      ADDRBL(0) => BU2_doutb(0),
      ADDRBU(14) => BU2_doutb(0),
      ADDRBU(13) => BU2_doutb(0),
      ADDRBU(12) => BU2_doutb(0),
      ADDRBU(11) => BU2_doutb(0),
      ADDRBU(10) => BU2_doutb(0),
      ADDRBU(9) => BU2_doutb(0),
      ADDRBU(8) => BU2_doutb(0),
      ADDRBU(7) => BU2_doutb(0),
      ADDRBU(6) => BU2_doutb(0),
      ADDRBU(5) => BU2_doutb(0),
      ADDRBU(4) => BU2_doutb(0),
      ADDRBU(3) => BU2_doutb(0),
      ADDRBU(2) => BU2_doutb(0),
      ADDRBU(1) => BU2_doutb(0),
      ADDRBU(0) => BU2_doutb(0),
      WEAU(3) => BU2_doutb(0),
      WEAU(2) => BU2_doutb(0),
      WEAU(1) => BU2_doutb(0),
      WEAU(0) => BU2_doutb(0),
      WEAL(3) => BU2_doutb(0),
      WEAL(2) => BU2_doutb(0),
      WEAL(1) => BU2_doutb(0),
      WEAL(0) => BU2_doutb(0),
      WEBU(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED,
      WEBU(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED,
      WEBU(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED,
      WEBU(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED,
      WEBU(3) => BU2_doutb(0),
      WEBU(2) => BU2_doutb(0),
      WEBU(1) => BU2_doutb(0),
      WEBU(0) => BU2_doutb(0),
      WEBL(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED,
      WEBL(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED,
      WEBL(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED,
      WEBL(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED,
      WEBL(3) => BU2_doutb(0),
      WEBL(2) => BU2_doutb(0),
      WEBL(1) => BU2_doutb(0),
      WEBL(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED,
      DOA(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_29_UNCONNECTED,
      DOA(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_28_UNCONNECTED,
      DOA(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_27_UNCONNECTED,
      DOA(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_26_UNCONNECTED,
      DOA(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_25_UNCONNECTED,
      DOA(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_24_UNCONNECTED,
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED,
      DOA(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_22_UNCONNECTED,
      DOA(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_21_UNCONNECTED,
      DOA(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_20_UNCONNECTED,
      DOA(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_19_UNCONNECTED,
      DOA(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_18_UNCONNECTED,
      DOA(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_17_UNCONNECTED,
      DOA(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_16_UNCONNECTED,
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_14_UNCONNECTED,
      DOA(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_13_UNCONNECTED,
      DOA(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_12_UNCONNECTED,
      DOA(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_11_UNCONNECTED,
      DOA(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_10_UNCONNECTED,
      DOA(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_9_UNCONNECTED,
      DOA(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_8_UNCONNECTED,
      DOA(7) => douta_3(25),
      DOA(6) => douta_3(24),
      DOA(5) => douta_3(23),
      DOA(4) => douta_3(22),
      DOA(3) => douta_3(21),
      DOA(2) => douta_3(20),
      DOA(1) => douta_3(19),
      DOA(0) => douta_3(18),
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => douta_3(26),
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED,
      DOB(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED,
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED,
      DOB(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED,
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_2_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED
    );
  BU2_XST_VCC : VCC
    port map (
      P => BU2_N1
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_doutb(0)
    );

end STRUCTURE;

-- synthesis translate_on
