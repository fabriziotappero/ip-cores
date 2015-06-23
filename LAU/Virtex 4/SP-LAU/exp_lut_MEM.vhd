--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: exp_lut_MEM.vhd
-- /___/   /\     Timestamp: Fri Sep 18 13:18:00 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\exp_lut_MEM.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\exp_lut_MEM.vhd" 
-- Device	: 4vsx55ff1148-12
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/exp_lut_MEM.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/exp_lut_MEM.vhd
-- # of Entities	: 1
-- Design Name	: exp_lut_MEM
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

entity exp_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 8 downto 0 ) 
  );
end exp_lut_MEM;

architecture STRUCTURE of exp_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_CASCADEOUTA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_CASCADEOUTB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 6 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal BU2_doutb : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  addra_2(6) <= addra(6);
  addra_2(5) <= addra(5);
  addra_2(4) <= addra(4);
  addra_2(3) <= addra(3);
  addra_2(2) <= addra(2);
  addra_2(1) <= addra(1);
  addra_2(0) <= addra(0);
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
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP : RAMB16
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      SRVAL_A => X"000000000",
      INIT_00 => X"0100010101010100010001010101010101000101010101020100010101010103",
      INIT_01 => X"0100010101010000010001010101000101000101010100020100010101010003",
      INIT_02 => X"0100010101000100010001010100010101000101010001020100010101000103",
      INIT_03 => X"0100010101000000010001010100000101000101010000020100010101000003",
      INIT_04 => X"0100010100010100010001010001010101000101000101020100010100010103",
      INIT_05 => X"0100010100010000010001010001000101000101000100020100010100010003",
      INIT_06 => X"0100010100000100010001010000010101000101000001020100010100000103",
      INIT_07 => X"0100010100000000010001010000000101000101000000020100010100000003",
      INIT_08 => X"0100010001010100010001000101010101000100010101020100010001010103",
      INIT_09 => X"0100010001010000010001000101000101000100010100020100010001010003",
      INIT_0A => X"0100010001000100010001000100010101000100010001020100010001000103",
      INIT_0B => X"0100010001000000010001000100000101000100010000020100010001000003",
      INIT_0C => X"0100010000010100010001000001010101000100000101020100010000010103",
      INIT_0D => X"0100010000010000010001000001000101000100000100020100010000010003",
      INIT_0E => X"0100010000000100010001000000010101000100000001020100010000000103",
      INIT_0F => X"0100010000000000010001000000000101000100000000020100010000000003",
      INIT_10 => X"0100000101010000010000010101000201000001010101000100000101010102",
      INIT_11 => X"0100000101000000010000010100000201000001010001000100000101000102",
      INIT_12 => X"0100000100010000010000010001000201000001000101000100000100010102",
      INIT_13 => X"0100000100000000010000010000000201000001000001000100000100000102",
      INIT_14 => X"0100000001010000010000000101000201000000010101000100000001010102",
      INIT_15 => X"0100000001000000010000000100000201000000010001000100000001000102",
      INIT_16 => X"0100000000010000010000000001000201000000000101000100000000010102",
      INIT_17 => X"0100000000000000010000000000000201000000000001000100000000000102",
      INIT_18 => X"0001010101000000000101010100010000010101010100000001010101010100",
      INIT_19 => X"0001010100000000000101010000010000010101000100000001010100010100",
      INIT_1A => X"0001010001000000000101000100010000010100010100000001010001010100",
      INIT_1B => X"0001010000000000000101000000010000010100000100000001010000010100",
      INIT_1C => X"0001000100000000000100010001000000010001010000000001000101010000",
      INIT_1D => X"0001000000000000000100000001000000010000010000000001000001010000",
      INIT_1E => X"0000010000000000000001000100000000000101000000000000010101000000",
      INIT_1F => X"0000000000000000010101000000000000000000000000000000000100000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_FILE => "NONE",
      INVERT_CLK_DOA_REG => FALSE,
      INVERT_CLK_DOB_REG => FALSE,
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      SIM_COLLISION_CHECK => "ALL",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 36,
      WRITE_WIDTH_B => 36,
      SRVAL_B => X"000000000"
    )
    port map (
      CASCADEINA => BU2_doutb(0),
      CASCADEINB => BU2_doutb(0),
      CLKA => clka,
      CLKB => clka,
      ENA => BU2_N1,
      REGCEA => BU2_doutb(0),
      REGCEB => BU2_doutb(0),
      ENB => BU2_N1,
      SSRA => BU2_doutb(0),
      SSRB => BU2_doutb(0),
      CASCADEOUTA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_CASCADEOUTA_UNCONNECTED,
      CASCADEOUTB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_CASCADEOUTB_UNCONNECTED,
      ADDRA(14) => BU2_doutb(0),
      ADDRA(13) => BU2_doutb(0),
      ADDRA(12) => addra_2(6),
      ADDRA(11) => addra_2(5),
      ADDRA(10) => addra_2(4),
      ADDRA(9) => addra_2(3),
      ADDRA(8) => addra_2(2),
      ADDRA(7) => addra_2(1),
      ADDRA(6) => addra_2(0),
      ADDRA(5) => BU2_doutb(0),
      ADDRA(4) => BU2_doutb(0),
      ADDRA(3) => BU2_doutb(0),
      ADDRA(2) => BU2_doutb(0),
      ADDRA(1) => BU2_doutb(0),
      ADDRA(0) => BU2_doutb(0),
      ADDRB(14) => BU2_doutb(0),
      ADDRB(13) => BU2_doutb(0),
      ADDRB(12) => addra_2(6),
      ADDRB(11) => addra_2(5),
      ADDRB(10) => addra_2(4),
      ADDRB(9) => addra_2(3),
      ADDRB(8) => addra_2(2),
      ADDRB(7) => addra_2(1),
      ADDRB(6) => addra_2(0),
      ADDRB(5) => BU2_N1,
      ADDRB(4) => BU2_doutb(0),
      ADDRB(3) => BU2_doutb(0),
      ADDRB(2) => BU2_doutb(0),
      ADDRB(1) => BU2_doutb(0),
      ADDRB(0) => BU2_doutb(0),
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
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      WEA(3) => BU2_doutb(0),
      WEA(2) => BU2_doutb(0),
      WEA(1) => BU2_doutb(0),
      WEA(0) => BU2_doutb(0),
      WEB(3) => BU2_doutb(0),
      WEB(2) => BU2_doutb(0),
      WEB(1) => BU2_doutb(0),
      WEB(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_30_UNCONNECTED,
      DOA(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_29_UNCONNECTED,
      DOA(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_28_UNCONNECTED,
      DOA(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_27_UNCONNECTED,
      DOA(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_26_UNCONNECTED,
      DOA(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_25_UNCONNECTED,
      DOA(24) => douta_3(4),
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_23_UNCONNECTED,
      DOA(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_22_UNCONNECTED,
      DOA(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_21_UNCONNECTED,
      DOA(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_20_UNCONNECTED,
      DOA(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_19_UNCONNECTED,
      DOA(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_18_UNCONNECTED,
      DOA(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_17_UNCONNECTED,
      DOA(16) => douta_3(3),
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_14_UNCONNECTED,
      DOA(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_13_UNCONNECTED,
      DOA(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_12_UNCONNECTED,
      DOA(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_11_UNCONNECTED,
      DOA(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_10_UNCONNECTED,
      DOA(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_9_UNCONNECTED,
      DOA(8) => douta_3(2),
      DOA(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_7_UNCONNECTED,
      DOA(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_6_UNCONNECTED,
      DOA(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_5_UNCONNECTED,
      DOA(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_4_UNCONNECTED,
      DOA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_3_UNCONNECTED,
      DOA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOA_2_UNCONNECTED,
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_25_UNCONNECTED,
      DOB(24) => douta_3(8),
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_17_UNCONNECTED,
      DOB(16) => douta_3(7),
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_9_UNCONNECTED,
      DOB(8) => douta_3(6),
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOB_1_UNCONNECTED,
      DOB(0) => douta_3(5),
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPA_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_WIDE_PRIM_SP_DOPB_0_UNCONNECTED
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
