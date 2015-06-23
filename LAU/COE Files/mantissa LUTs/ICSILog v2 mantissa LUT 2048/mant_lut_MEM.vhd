--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: mant_lut_MEM.vhd
-- /___/   /\     Timestamp: Fri Jul 24 14:35:16 2009
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
    addra : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 ) 
  );
end mant_lut_MEM;

architecture STRUCTURE of mant_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
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
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
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
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 26 downto 0 ); 
  signal BU2_doutb : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
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
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_1_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP : RAMB36_EXP
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_7E => X"CC34CC2CCC24CC1CCC14CC0CCC04CBFCCBF4CBECCBE4CBDCCBD4CBCCCBC4CBBC",
      INIT_7F => X"CCB5CCADCCA5CC9DCC95CC8DCC85CC7CCC74CC6CCC64CC5CCC54CC4CCC44CC3C",
      INITP_00 => X"EEEBBBBBBBBBAEEEEEEEEEEEFBBBBBBBFFFFFFFFFAAAAAAAFFFFFFFF55555555",
      INITP_01 => X"BFAFAFEBEBFAFAFABEBEBFAFAFEBEBEBFAFAFABEBEBEAFAFAFABEBEBEBFAFAEE",
      INITP_02 => X"FFEABFFAABFFAAFFEAAFFAABFFAAFFEAAFFAABFEAAFFEABFFAAFFEABFAFAFEBE",
      INITP_03 => X"BFFAABFFAABFFAABFFAABFFAABFFAABFEAAFFEAAFFEAAFFAABFFAABFFAAFFEAA",
      INITP_04 => X"FFFAAAAABFFFFEAAAAAFFFFFAAAAAFFEAABFFAABFFAABFFAABFFAABFFAABFFAA",
      INITP_05 => X"FFFAAAAABFFFFFAAAAABFFFFEAAAAAFFFFFEAAAAAFFFFFAAAAABFFFFEAAAAAFF",
      INITP_06 => X"AAAAAFFFFFFAAAAABFFFFFEAAAAAFFFFFEAAAAAFFFFFFAAAAABFFFFFAAAAABFF",
      INITP_07 => X"FFFFFAAAAAAFFFFFEAAAAABFFFFFEAAAAABFFFFFEAAAAAFFFFFFAAAAABFFFFFE",
      INITP_08 => X"ABFFFFFFAAAAAAFFFFFFAAAAAABFFFFFEAAAAABFFFFFEAAAAABFFFFFFAAAAAAF",
      INITP_09 => X"AAFFFFFFEAAAAAAFFFFFFAAAAAABFFFFFFAAAAAABFFFFFEAAAAAAFFFFFFEAAAA",
      INITP_0A => X"AAAAAAAAAAAAAFFFFFFFFFFFFFEAAAAAAAAAAAABFFFFFFEAAAAAAFFFFFFEAAAA",
      INITP_0B => X"FFFFFFFFFAAAAAAAAAAAAABFFFFFFFFFFFFFEAAAAAAAAAAAAAFFFFFFFFFFFFFE",
      INITP_0C => X"AAFFFFFFFFFFFFFFAAAAAAAAAAAAAABFFFFFFFFFFFFFEAAAAAAAAAAAAAAFFFFF",
      INITP_0D => X"AAAAAAAFFFFFFFFFFFFFFFAAAAAAAAAAAAAABFFFFFFFFFFFFFFAAAAAAAAAAAAA",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      INIT_00 => X"FD88F997F5A5F1B2EDBEE9C9E5D3E1DBDBC7D3D5CBE1C3EBB7E7A7F38FF75FFC",
      INIT_01 => X"1E0A1C191A28183616441451125E106B0E760C820A8D089706A104AA02B300BC",
      INIT_02 => X"2EEA2DF52D002C0B2B162A21292B2835273F26492552245B2364226C2175207D",
      INIT_03 => X"3E123D213C303B3F3A4D395C386A37783685359334A033AD32B931C630D22FDE",
      INIT_04 => X"46FE46084611451B4524442D4436433F43474250425841614169407140793F02",
      INIT_05 => X"4E574E624D6D4D784C834C8E4B994BA44AAE4AB949C349CD48D748E147EB47F5",
      INIT_06 => X"5692559F55AC54B954C653D253DF52EB52F852045110511C502850344F404F4B",
      INIT_07 => X"5DB05DBF5CCE5CDC5BEB5BF95B085A165A2459325940584E585C576957775684",
      INIT_08 => X"625962E1626961F1617A6102618A6112609A602260AA60315F735F825E925EA1",
      INIT_09 => X"66CC665565DE656765F065796502648B6414649D642563AE633763BF634862D0",
      INIT_0A => X"6A3169BB694569CF695968E3686C68F6688068096793671D67A6673066B96642",
      INIT_0B => X"6D886D136D9E6D296CB46C3E6CC96C546BDE6B696BF36B7D6B086A926A1C6AA7",
      INIT_0C => X"71D2715E70EA70767001708D70186FA46F2F6FBA6F466ED16E5C6EE76E726DFD",
      INIT_0D => X"7510749C742974B5744173CE735A73E6737372FF728B721772A3722F71BB7147",
      INIT_0E => X"784078CD785A77E877757702778F771C76A9763676C3765075DD756975F67583",
      INIT_0F => X"7C637BF17B7F7B0D7B9B7B297AB77A457AD37A6079EE797C790A7997792578B2",
      INIT_10 => X"7F797F087F977F267EB57E447ED27E617DF07D7E7D0D7D9B7D2A7CB87C467CD4",
      INIT_11 => X"8141810981D181998161812980F080B880808047800F80D7809E8066802D7FEA",
      INIT_12 => X"83C083898351831982E182A98271823A820282CA8292825A822281EA81B2817A",
      INIT_13 => X"8539850284CA8493845B842484ED84B5847D8446840E83D7839F8367833083F8",
      INIT_14 => X"86AC8675863E860786D086998662862A85F385BC8585854E851685DF85A88570",
      INIT_15 => X"881988E288AC8875883E880787D1879A8763872C87F587BF87888751871A86E3",
      INIT_16 => X"8A808A4A8A1389DD89A78970893A890489CD89978960892A88F388BD8886884F",
      INIT_17 => X"8BE18BAB8B758B3F8B0A8BD48B9D8B678B318AFB8AC58A8F8A598A238AEC8AB6",
      INIT_18 => X"8D3D8D078DD28D9C8D678D318CFB8CC68C908C5A8C248CEF8CB98C838C4D8C17",
      INIT_19 => X"8F938F5E8F298EF38EBE8E898E538E1E8EE98EB38E7E8E488E138DDE8DA88D73",
      INIT_1A => X"90E490AF907A9045901090DB90A69071903C90078FD28F9D8F688F338FFD8FC8",
      INIT_1B => X"922F92FA92C69291925C922891F391BE918A9155912091EC91B79182914D9118",
      INIT_1C => X"94749440940C93D893A3936F933B930793D2939E93699335930192CC92989263",
      INIT_1D => X"95B59581954D951995E595B1957D9549951594E194AD94799445941194DD94A9",
      INIT_1E => X"97F097BC97899755972296EE96BA96879653961F96EC96B896849650961C95E9",
      INIT_1F => X"992698F398BF988C9859982598F298BF988B9858982597F197BE978A97579723",
      INIT_20 => X"9A579A249AF19ABE9A8B9A589A2599F299BF998C9959992699F299BF998C9959",
      INIT_21 => X"9C829C509C1D9BEB9BB89B859B539B209BED9BBA9B889B559B229AEF9ABC9A89",
      INIT_22 => X"9DA99D779D459D129DE09DAE9D7B9D499D169CE49CB19C7F9C4C9C1A9CE79CB5",
      INIT_23 => X"9FCB9F999F679F359F039ED19E9F9E6D9E3B9E089ED69EA49E729E409E0E9DDB",
      INIT_24 => X"A0F4A0DBA0C2A0A9A090A077A05FA046A02DA0149FF69FC49F939F619F2F9FFD",
      INIT_25 => X"A180A167A14EA136A11DA104A0EBA0D3A0BAA0A1A088A070A057A03EA025A00C",
      INIT_26 => X"A209A1F1A1D8A1C0A1A7A18FA176A15DA145A12CA114A1FBA1E2A1CAA1B1A198",
      INIT_27 => X"A291A278A260A248A22FA217A2FEA2E6A2CDA2B5A29CA284A26BA253A23AA222",
      INIT_28 => X"A316A3FEA3E5A3CDA3B5A39CA384A36CA354A33BA323A30BA2F2A2DAA2C2A2A9",
      INIT_29 => X"A498A480A468A450A438A420A408A3F0A3D7A3BFA3A7A38FA377A35EA346A32E",
      INIT_2A => X"A519A501A4E9A4D1A4B9A4A1A489A471A459A441A429A411A4F9A4E1A4C9A4B1",
      INIT_2B => X"A597A57FA567A550A538A520A508A5F0A5D8A5C0A5A9A591A579A561A549A531",
      INIT_2C => X"A613A6FBA6E4A6CCA6B4A69DA685A66DA655A63EA626A60EA5F6A5DFA5C7A5AF",
      INIT_2D => X"A78DA775A75EA746A72FA717A700A6E8A6D0A6B9A6A1A689A672A65AA642A62B",
      INIT_2E => X"A805A7EDA7D6A7BEA7A7A78FA778A760A749A732A71AA703A7EBA7D4A7BCA7A4",
      INIT_2F => X"A87AA863A84BA834A81DA806A8EEA8D7A8C0A8A8A891A87AA862A84BA833A81C",
      INIT_30 => X"A9EDA9D6A9BFA9A8A991A97AA962A94BA934A91DA906A8EEA8D7A8C0A8A9A891",
      INIT_31 => X"AA5FAA48AA31AA1AAA03A9ECA9D4A9BDA9A6A98FA978A961A94AA933A91CA905",
      INIT_32 => X"AACEAAB7AAA0AA89AA72AA5BAA44AA2EAA17AA00AAE9AAD2AABBAAA4AA8DAA76",
      INIT_33 => X"AB3BAB24AB0EABF7ABE0ABC9ABB2AB9CAB85AB6EAB57AB40AB29AB13AAFCAAE5",
      INIT_34 => X"ACA6AC90AC79AC62AC4CAC35AC1EAC08ABF1ABDAABC4ABADAB96AB7FAB69AB52",
      INIT_35 => X"AD0FACF9ACE2ACCCACB5AC9FAC88AC72AC5BAC44AC2EAC17AC01ACEAACD3ACBD",
      INIT_36 => X"AD77AD60AD4AAD33AD1DAD07ADF0ADDAADC3ADADAD96AD80AD69AD53AD3CAD26",
      INIT_37 => X"AEDCAEC5AEAFAE99AE83AE6CAE56AE40AE29AE13ADFDADE6ADD0ADBAADA3AD8D",
      INIT_38 => X"AF3FAF29AF13AEFDAEE6AED0AEBAAEA4AE8EAE77AE61AE4BAE35AE1FAE08AEF2",
      INIT_39 => X"AFA0AF8AAF74AF5EAF48AF32AF1CAF06AFF0AFDAAFC4AFAEAF98AF81AF6BAF55",
      INIT_3A => X"B000B0EAB0D4B0BEB0A8B092B07CB066B050B03AB024B00EAFF8AFE2AFCCAFB6",
      INIT_3B => X"B15DB148B132B11CB106B0F0B0DBB0C5B0AFB099B083B06DB057B042B02CB016",
      INIT_3C => X"B1B9B1A3B18EB178B162B14DB137B121B10CB1F6B1E0B1CAB1B5B19FB189B173",
      INIT_3D => X"B213B2FDB2E8B2D2B2BDB2A7B292B27CB266B251B23BB225B210B1FAB1E4B1CF",
      INIT_3E => X"B36BB356B340B32BB315B300B2EAB2D5B2BFB2AAB294B27FB269B254B23EB229",
      INIT_3F => X"B3C1B3ACB397B381B36CB357B341B32CB316B301B3ECB3D6B3C1B3ABB396B381",
      INIT_40 => X"B416B401B4EBB4D6B4C1B4ACB496B481B46CB457B441B42CB417B401B3ECB3D7",
      INIT_41 => X"B569B554B53EB529B514B4FFB4EAB4D5B4BFB4AAB495B480B46BB456B440B42B",
      INIT_42 => X"B5BAB5A5B590B57BB566B551B53BB526B511B5FCB5E7B5D2B5BDB5A8B593B57E",
      INIT_43 => X"B609B6F4B6DFB6CAB6B5B6A0B68BB676B661B64DB638B623B60EB5F9B5E4B5CF",
      INIT_44 => X"B756B742B72DB718B703B6EEB6DAB6C5B6B0B69BB686B671B65CB648B633B61E",
      INIT_45 => X"B7A2B78EB779B764B750B73BB726B711B7FDB7E8B7D3B7BEB7AAB795B780B76B",
      INIT_46 => X"B8EDB8D8B8C3B8AFB89AB886B871B85CB848B833B81EB80AB7F5B7E0B7CCB7B7",
      INIT_47 => X"B935B921B90CB8F8B8E3B8CFB8BAB8A6B891B87DB868B853B83FB82AB816B801",
      INIT_48 => X"B97CB968B953B93FB92AB916B902B9EDB9D9B9C4B9B0B99BB987B973B95EB94A",
      INIT_49 => X"BAC1BAADBA99BA84BA70BA5CBA48BA33BA1FBA0BB9F6B9E2B9CEB9B9B9A5B990",
      INIT_4A => X"BB05BAF1BADDBAC8BAB4BAA0BA8CBA78BA63BA4FBA3BBA27BA12BAFEBAEABAD6",
      INIT_4B => X"BB47BB33BB1FBB0BBBF7BBE3BBCFBBBABBA6BB92BB7EBB6ABB56BB42BB2DBB19",
      INIT_4C => X"BC88BC74BC60BC4CBC38BC24BC10BBFCBBE8BBD4BBBFBBABBB97BB83BB6FBB5B",
      INIT_4D => X"BCC7BCB3BC9FBC8BBC77BC63BC4FBC3BBC27BC13BCFFBCEBBCD8BCC4BCB0BC9C",
      INIT_4E => X"BD04BDF0BDDCBDC9BDB5BDA1BD8DBD79BD65BD52BD3EBD2ABD16BD02BCEEBCDA",
      INIT_4F => X"BE40BE2CBE18BE05BDF1BDDDBDCABDB6BDA2BD8EBD7BBD67BD53BD3FBD2CBD18",
      INIT_50 => X"BE7ABE67BE53BE3FBE2CBE18BE05BEF1BEDDBECABEB6BEA2BE8FBE7BBE67BE54",
      INIT_51 => X"BFB3BFA0BF8CBF79BF65BF52BF3EBF2ABF17BF03BEF0BEDCBEC9BEB5BEA1BE8E",
      INIT_52 => X"BFEBBFD7BFC4BFB0BF9DBF89BF76BF62BF4FBF3CBF28BF15BF01BFEEBFDABFC7",
      INIT_53 => X"C090C086C07DC073C069C060C056C04CC043C039C02FC026C01CC012C008BFFE",
      INIT_54 => X"C02AC021C017C00DC004C0FAC0F0C0E7C0DDC0D4C0CAC0C0C0B7C0ADC0A3C09A",
      INIT_55 => X"C0C4C0BAC0B1C0A7C09DC094C08AC081C077C06DC064C05AC051C047C03DC034",
      INIT_56 => X"C15CC153C149C140C136C12DC123C11AC110C107C0FDC0F4C0EAC0E0C0D7C0CD",
      INIT_57 => X"C1F5C1EBC1E2C1D8C1CFC1C5C1BCC1B2C1A9C19FC196C18CC183C179C170C166",
      INIT_58 => X"C18CC182C179C170C166C15DC153C14AC140C137C12DC124C11AC111C108C1FE",
      INIT_59 => X"C223C219C210C206C1FDC1F4C1EAC1E1C1D7C1CEC1C5C1BBC1B2C1A8C19FC195",
      INIT_5A => X"C2B9C2AFC2A6C29DC293C28AC280C277C26EC264C25BC252C248C23FC235C22C",
      INIT_5B => X"C24EC245C23BC232C229C21FC216C20DC203C2FAC2F1C2E7C2DEC2D5C2CBC2C2",
      INIT_5C => X"C2E3C2D9C2D0C2C7C2BDC2B4C2ABC2A2C298C28FC286C27CC273C26AC261C257",
      INIT_5D => X"C376C36DC364C35BC352C348C33FC336C32DC323C31AC311C308C2FEC2F5C2EC",
      INIT_5E => X"C30AC301C3F7C3EEC3E5C3DCC3D3C3C9C3C0C3B7C3AEC3A5C39BC392C389C380",
      INIT_5F => X"C39CC393C38AC381C378C36FC366C35CC353C34AC341C338C32FC325C31CC313",
      INIT_60 => X"C42EC425C41CC413C40AC401C3F8C3EFC3E5C3DCC3D3C3CAC3C1C3B8C3AFC3A6",
      INIT_61 => X"C4C0C4B7C4AEC4A5C49BC492C489C480C477C46EC465C45CC453C44AC441C438",
      INIT_62 => X"C450C447C43EC435C42CC423C41AC411C408C4FFC4F6C4EDC4E4C4DBC4D2C4C9",
      INIT_63 => X"C4E0C4D7C4CFC4C6C4BDC4B4C4ABC4A2C499C490C487C47EC474C46BC462C459",
      INIT_64 => X"C570C567C55EC555C54CC543C53AC531C528C51FC516C50DC504C4FBC4F2C4E9",
      INIT_65 => X"C5FFC5F6C5EDC5E4C5DBC5D2C5C9C5C0C5B7C5AEC5A6C59DC594C58BC582C579",
      INIT_66 => X"C58DC584C57BC572C569C561C558C54FC546C53DC534C52BC522C519C511C508",
      INIT_67 => X"C61AC612C609C600C5F7C5EEC5E5C5DDC5D4C5CBC5C2C5B9C5B0C5A7C59FC596",
      INIT_68 => X"C6A7C69FC696C68DC684C67BC673C66AC661C658C64FC647C63EC635C62CC623",
      INIT_69 => X"C634C62BC622C619C611C608C6FFC6F6C6EEC6E5C6DCC6D3C6CBC6C2C6B9C6B0",
      INIT_6A => X"C6C0C6B7C6AEC6A5C69DC694C68BC682C67AC671C668C65FC657C64EC645C63D",
      INIT_6B => X"C74BC742C739C731C728C71FC717C70EC705C6FCC6F4C6EBC6E2C6DAC6D1C6C8",
      INIT_6C => X"C7D5C7CDC7C4C7BBC7B3C7AAC7A1C799C790C787C77FC776C76DC765C75CC753",
      INIT_6D => X"C75FC757C74EC745C73DC734C72CC723C71AC712C709C700C7F8C7EFC7E7C7DE",
      INIT_6E => X"C7E9C7E0C7D8C7CFC7C6C7BEC7B5C7ADC7A4C79BC793C78AC782C779C770C768",
      INIT_6F => X"C871C869C860C858C84FC847C83EC836C82DC825C81CC813C80BC802C7FAC7F1",
      INIT_70 => X"C8FAC8F1C8E9C8E0C8D8C8CFC8C7C8BEC8B6C8ADC8A5C89CC894C88BC883C87A",
      INIT_71 => X"C881C879C871C868C860C857C84FC846C83EC835C82DC824C81CC813C80BC802",
      INIT_72 => X"C909C900C8F8C8EFC8E7C8DEC8D6C8CEC8C5C8BDC8B4C8ACC8A3C89BC892C88A",
      INIT_73 => X"C98FC987C97EC976C96EC965C95DC954C94CC944C93BC933C92AC922C919C911",
      INIT_74 => X"C915C90DC904C9FCC9F4C9EBC9E3C9DBC9D2C9CAC9C2C9B9C9B1C9A8C9A0C998",
      INIT_75 => X"C99BC992C98AC982C979C971C969C960C958C950C947C93FC937C92EC926C91E",
      INIT_76 => X"CA20CA17CA0FCA07C9FEC9F6C9EEC9E6C9DDC9D5C9CDC9C4C9BCC9B4C9ABC9A3",
      INIT_77 => X"CAA4CA9CCA94CA8BCA83CA7BCA72CA6ACA62CA5ACA51CA49CA41CA39CA30CA28",
      INIT_78 => X"CA28CA20CA18CA0FCA07CAFFCAF7CAEECAE6CADECAD6CACDCAC5CABDCAB5CAAC",
      INIT_79 => X"CAABCAA3CA9BCA93CA8BCA82CA7ACA72CA6ACA61CA59CA51CA49CA41CA38CA30",
      INIT_7A => X"CB2ECB26CB1ECB16CB0DCB05CAFDCAF5CAEDCAE5CADCCAD4CACCCAC4CABCCAB4",
      INIT_7B => X"CBB0CBA8CBA0CB98CB90CB88CB80CB77CB6FCB67CB5FCB57CB4FCB47CB3ECB36",
      INIT_7C => X"CB32CB2ACB22CB1ACB12CB0ACB02CBFACBF1CBE9CBE1CBD9CBD1CBC9CBC1CBB9",
      INIT_7D => X"CBB4CBABCBA3CB9BCB93CB8BCB83CB7BCB73CB6BCB63CB5BCB53CB4BCB42CB3A",
      INITP_0E => X"AAAAAAAAAAFFFFFFFFFFFFFFFEAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFAAAAAAAA",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 18,
      READ_WIDTH_B => 18,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18,
      INITP_0F => X"AAAAAAAAAAABFFFFFFFFFFFFFFFEAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFEAAAAA"
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
      ADDRAL(14) => addra_2(10),
      ADDRAL(13) => addra_2(9),
      ADDRAL(12) => addra_2(8),
      ADDRAL(11) => addra_2(7),
      ADDRAL(10) => addra_2(6),
      ADDRAL(9) => addra_2(5),
      ADDRAL(8) => addra_2(4),
      ADDRAL(7) => addra_2(3),
      ADDRAL(6) => addra_2(2),
      ADDRAL(5) => addra_2(1),
      ADDRAL(4) => addra_2(0),
      ADDRAL(3) => BU2_doutb(0),
      ADDRAL(2) => BU2_doutb(0),
      ADDRAL(1) => BU2_doutb(0),
      ADDRAL(0) => BU2_doutb(0),
      ADDRAU(14) => addra_2(10),
      ADDRAU(13) => addra_2(9),
      ADDRAU(12) => addra_2(8),
      ADDRAU(11) => addra_2(7),
      ADDRAU(10) => addra_2(6),
      ADDRAU(9) => addra_2(5),
      ADDRAU(8) => addra_2(4),
      ADDRAU(7) => addra_2(3),
      ADDRAU(6) => addra_2(2),
      ADDRAU(5) => addra_2(1),
      ADDRAU(4) => addra_2(0),
      ADDRAU(3) => BU2_doutb(0),
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
      DOA(15) => douta_3(25),
      DOA(14) => douta_3(24),
      DOA(13) => douta_3(23),
      DOA(12) => douta_3(22),
      DOA(11) => douta_3(21),
      DOA(10) => douta_3(20),
      DOA(9) => douta_3(19),
      DOA(8) => douta_3(18),
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
      DOPA(1) => douta_3(26),
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
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP : RAMB18
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_A => X"00000",
      INIT_B => X"00000",
      INITP_00 => X"3E6523E65B00CACFE4B603691E25301415F505393C9EA0A1088B7B047E9E01FC",
      INITP_01 => X"36D552461FF0CCB54B6707039B5A5263F3E334AB4CE001CDADAD8E00E24BE253",
      INITP_02 => X"B24A55A954B6D998E3C01F00F8E736494AAAAB5B66E71C30007992AAA4C7000E",
      INITP_03 => X"D2D4AAAAD4B6D9319C381FFFFF078E6366DA52AAAAD6924CC6387E0003F0E319",
      INITP_04 => X"6CCCE38F0FF0003FC1C39CCCD925AD5AAA95296D93339C787F8003F838E33326",
      INITP_05 => X"E1C639CCE6664CD924D24B4B5A956AA95555AAA54AD69692492655AAA956B492",
      SRVAL_A => X"00000",
      INIT_00 => X"E771029B3AE08C3FF8B77B4413E6BE9AF5BD8C623E2007F3C6AE9C8F0E050200",
      INIT_01 => X"4DDDF392B7649751935BA97ED9BA220F837CFAFE88972B44E204ACD888BD76B3",
      INIT_02 => X"37E9619FA26AF74A623FE14975661C97D6DAA33183997413779E8A3AAEE7E346",
      INIT_03 => X"8E732094CFD19A2A819E832EA0D9D89E2A7D96761C88BAB270F53F4F25C1234A",
      INIT_04 => X"0071C70120230AD6861A93EF30555E4B1DD26BE94A8FB9C6B78C44E1C28A1970",
      INIT_05 => X"8A601CBD43AFFF354F4F34FDAC3FB815587F8B7C510CAB2E97E4162C2706CA73",
      INIT_06 => X"05283221F6B152D94598D0EEF1DAAA5EF978DE295A706C4D13BF51C824658C98",
      INIT_07 => X"71CA092F3B2E08C86FFC70CA0B3240340ECF760477D11238443710CF74FF71C8",
      INIT_08 => X"D69241E47B0583F45AB2FF3F7299B485887344FD9D2391E520434C3C12D074FF",
      INIT_09 => X"3C7CB1D9F5050901EDCDA16925D478109B1A8DF44F9DE016405D6F746D5A3A0E",
      INIT_0A => X"BD7726C960EC6CE048A5F63B75A2C4DAE5E3D6BD98672AE28D2DC048C43498F0",
      INIT_0B => X"9DC8E7FB0300F2D8B38246FFAC4DE36EED61C92677BCF625485F6B6B5F4825F7",
      INIT_0C => X"15A62CA7177CD62568A0CEF007131309F3D2A66E2CDE8520B136B01E81D92667",
      INIT_0D => X"503F23FCCA8E46F4972FBD3FB62385DC28699FCAEA000A0AFEE7C699621FD178",
      INIT_0E => X"70B3EC1A3E57666A63523710E0A45E0DB24CDC60DA4AAE08589CD6062A445357",
      INIT_0F => X"8A199E198AF04C9EE522557E9CAFB9B8AD97774D18D98F3BDC740082FA67CA22",
      INIT_10 => X"A97C4504BA65069D2AAD2695FA55A5EC285B83A1B5BEBEB49F805724E69E4CF0",
      INIT_11 => X"CFDEE3DFD1B9986C37F8AF5C009A29AF2B9E0664B903447BA8CBE4F3F8F3E4CC",
      INIT_12 => X"7A1CB951E473FD82037EF567D43DA0FF59AEFF4A91D310487BAAA7F0306693B6",
      INIT_13 => X"83BCEF1E496E8FACC3D6E5EEF4F4EFE6D8C6AF93724D23F4C0884B0AC37828D3",
      INIT_14 => X"F7C2894B09C27727D2791BB952E77702890B890276E651B81A77D02474BE0546",
      INIT_15 => X"45A0F64896DE23639FD609386187A8C4DCF0FE090F100E06FAE9D4BB9D7A5328",
      INIT_16 => X"D8BFA2805A3001CE975B1BD78E41EF993FE07E16AA3AC54CCF4DC73CAD1A82E6",
      INIT_17 => X"1888F45CBF1E79D02270BA00417EB7EB1C487093B2CDE3F6040D12141009FDEC",
      INIT_18 => X"695F513F280EEFCCA67A4B18E0A46420D88C3BE68D30CE68FE901EA82DAE2BA4",
      INIT_19 => X"2CA51A8BF861C62784DC3081CE165A9AD60E42729EC5E908233A4D5C676E706F",
      INIT_1A => X"BFB8AD9F8C765B3C1AF3C99A6831F7B87630E59644EE9334D26B00921FA82EAF",
      INIT_1B => X"7CF366D43FA60A69C41C6FBF0B5397D7134B80B0DC05294A678094A6B2BCC1C2",
      INIT_1C => X"BCAD9A846A4C2A04DBAE7D480FD3934E07BB6B18C06506A33DD264F27C028402",
      INIT_1D => X"D23BA10361BB1265B4FF478BCB084176A7D4FE2447658097AAB9C5CDD1D1CEC7",
      INIT_1E => X"12F0CBA3774713DCA16321DB9245F4A048EC8C2AC358EA78038A0D8C0880F565",
      INIT_1F => X"CA1B6AB4FB3F7FBBF4295B89B4DAFE1E3A5267788690979A99958D827260492F",
      INIT_20 => X"470AC9843CF1A24FF9A043E27E17AC3DCB55DC60E05CD54ABC2A94FB5FBF1B74",
      INIT_21 => X"D606345E84A8C7E4FC1224323E454A4A4842382B1B07EFD5B69570471BEBB881",
      INIT_22 => X"BD5AF38A1CAC38C147C948C33BB0218FFA61C42582DC3285D42069AEF02F6AA1",
      INIT_23 => X"434A4E4E4B453C2E1E0CF5DBBE9D795228FAC9945D22E3A25D14C97A27D2791C",
      INIT_24 => X"AC1C87F054B61671C91E70BF0A5297D917528ABFF01E4A7196B6D4EF061A2B39",
      INIT_25 => X"3C10E2B07C4408CA8944FCB26412BE660CAE4CE88016A836C24BD052D14DC53A",
      INIT_26 => X"30699ED1002C567C9EBEDBF40B1E2E3C464C50514E4840342512FEE5CAAB8964",
      INIT_27 => X"CA64FC9021B03BC348CA4AC63FB52898046ED5399AF751A8FD4E9CE83074B6F5",
      INIT_28 => X"433E352A1C0AF6DEC4A786643D14E8B8865119DEA05E1AD2883BEB9841E88B2C",
      INIT_29 => X"EC9843ED953CE08426C76604A03CD5DA0630587C9CBAD6EE041625323B424546",
      INIT_2A => X"613C15ECC3986B3E0EDDAB77420CD49A5F23E5A66523E09A540CC3782CDE8F3E",
      INIT_2B => X"1C242A303436373735322D2720170C01F4E5D5C4B19D8770583E2306E8C8A785",
      INIT_2C => X"386CA0D202315F8BB6E0082F54789BBCDCFA18334E667E94A8BCCEDEEDFB0712",
      INIT_2D => X"CF308FEC49A4FD56AC0256A9FA4A99E6327DC60E559ADE2061A1DF1C5892CA02",
      INIT_2E => X"FC87119A21A72CAF31B232B02CA8229A1187FC6FE152C12F9C0770D940A60A6E",
      INIT_2F => X"D68C40F3A45504B25E09B35B02A84DF09232D2700CA741DA71079C2FC152E16F",
      INIT_30 => X"77563410EBC59E754B20F3C596653400CC966028EEB3773AFBBB7A37F3AE671F",
      INIT_31 => X"F5FD03080C0F10100F0D0904FEF7EEE4D9CCBEAF9F8D7A66513A2208EED2B596",
      INIT_32 => X"6898C6F31F4A749CC3E90D30537393B1CEEA051E364D62778A9CACBBC9D6E2EC",
      INIT_33 => X"E63D92E73A8DDE2D7CC91560AAF2397FC4074A8BCA094682BDF72F669CD10437",
      INIT_34 => X"84027EFA74ED64DB50C437A91A89F764D03AA30B72D83C9F0162C2207DD9348D",
      INIT_35 => X"59FD9F40E1801EBA56F08921B84DE174069727B542CE59E36CF379FE81048505",
      INIT_36 => X"784109D0965A1DDFA0601FDC98540EC67E34EA9E5103B36311BE6A15BE670EB4",
      INIT_37 => X"F7E4D1BCA790785F452A0DF0D1B1906E4A2600D9B2885E3306D8AA7A4816E3AE",
      INIT_38 => X"E7F90A1A2836424D5760686F74797C7E807F7E7C78746E675F564C4034261808",
      INIT_39 => X"5E94C8FB2D5E8EBDEB18436D97BFE60C31557799B9D9F714304B647D95ABC0D4",
      INIT_3A => X"6DC61D73C81C6FC11262B0FE4A96E02971B8FE4387CA0B4C8BC906427DB7F028",
      INIT_3B => X"27A21C940C82F86CE052C333A2107DE954BD268DF459BE2183E444A3015DB914",
      INIT_3C => X"9D3AD6700AA23AD065F98D1FB040CF5DEA75008A129A20A62AAE30B131B02EAB",
      INIT_3D => X"E2A05D18D38D46FEB46A1FD28536E79645F29E4AF49D45EC9238DC7E20C16100",
      INIT_3E => X"05E4C19E7A552E07DEB58B5F3305D7A7764512DFAA743E06CD93581DE0A26323",
      INIT_3F => X"181715120E0903FCF4EBE1D6CABDAFA08F7E6C5945301A03EBD1B79C80634525",
      INIT_FILE => "NONE",
      READ_WIDTH_A => 9,
      READ_WIDTH_B => 9,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INITP_06 => X"AAB54AD6B4B496DB24D9333673319CE38E3C783C0FC03FFFC00FFFF00FC0F0F0",
      INITP_07 => X"01FFFF007F03E0F0F1E38E38C67319999B326C9B6DA4B694A52B54AA95555555",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      SRVAL_B => X"00000"
    )
    port map (
      CLKA => clka,
      CLKB => BU2_doutb(0),
      ENA => BU2_N1,
      ENB => BU2_doutb(0),
      REGCEA => BU2_doutb(0),
      REGCEB => BU2_doutb(0),
      SSRA => BU2_doutb(0),
      SSRB => BU2_doutb(0),
      ADDRA(13) => addra_2(10),
      ADDRA(12) => addra_2(9),
      ADDRA(11) => addra_2(8),
      ADDRA(10) => addra_2(7),
      ADDRA(9) => addra_2(6),
      ADDRA(8) => addra_2(5),
      ADDRA(7) => addra_2(4),
      ADDRA(6) => addra_2(3),
      ADDRA(5) => addra_2(2),
      ADDRA(4) => addra_2(1),
      ADDRA(3) => addra_2(0),
      ADDRA(2) => BU2_doutb(0),
      ADDRA(1) => BU2_doutb(0),
      ADDRA(0) => BU2_doutb(0),
      ADDRB(13) => BU2_doutb(0),
      ADDRB(12) => BU2_doutb(0),
      ADDRB(11) => BU2_doutb(0),
      ADDRB(10) => BU2_doutb(0),
      ADDRB(9) => BU2_doutb(0),
      ADDRB(8) => BU2_doutb(0),
      ADDRB(7) => BU2_doutb(0),
      ADDRB(6) => BU2_doutb(0),
      ADDRB(5) => BU2_doutb(0),
      ADDRB(4) => BU2_doutb(0),
      ADDRB(3) => BU2_doutb(0),
      ADDRB(2) => BU2_doutb(0),
      ADDRB(1) => BU2_doutb(0),
      ADDRB(0) => BU2_doutb(0),
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
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_14_UNCONNECTED,
      DOA(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_13_UNCONNECTED,
      DOA(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_12_UNCONNECTED,
      DOA(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_11_UNCONNECTED,
      DOA(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_10_UNCONNECTED,
      DOA(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_9_UNCONNECTED,
      DOA(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOA_8_UNCONNECTED,
      DOA(7) => douta_3(7),
      DOA(6) => douta_3(6),
      DOA(5) => douta_3(5),
      DOA(4) => douta_3(4),
      DOA(3) => douta_3(3),
      DOA(2) => douta_3(2),
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOB_0_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => douta_3(8),
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM18_SP_DOPB_0_UNCONNECTED,
      WEA(1) => BU2_doutb(0),
      WEA(0) => BU2_doutb(0),
      WEB(1) => BU2_doutb(0),
      WEB(0) => BU2_doutb(0)
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
