--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: comp_11b_equal.vhd
-- /___/   /\     Timestamp: Thu Feb 04 11:01:48 2010
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\comp_11b_equal.ngc C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\comp_11b_equal.vhd 
-- Device	: 3s200ft256-4
-- Input file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/comp_11b_equal.ngc
-- Output file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/comp_11b_equal.vhd
-- # of Entities	: 1
-- Design Name	: comp_11b_equal
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

entity comp_11b_equal is
  port (
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 10 downto 0 ) 
  );
end comp_11b_equal;

architecture STRUCTURE of comp_11b_equal is
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and0000120_34 : STD_LOGIC;
 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000093_33 : STD_LOGIC;
 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000053_32 : STD_LOGIC;
 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000026_31 : STD_LOGIC;
 
  signal BU2_N01 : STD_LOGIC; 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result : STD_LOGIC; 
  signal BU2_N1 : STD_LOGIC; 
  signal BU2_a_ge_b : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal b_3 : STD_LOGIC_VECTOR ( 10 downto 0 ); 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_async_o : STD_LOGIC_VECTOR ( 1 downto 1 ); 
begin
  a_2(10) <= a(10);
  a_2(9) <= a(9);
  a_2(8) <= a(8);
  a_2(7) <= a(7);
  a_2(6) <= a(6);
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
  b_3(10) <= b(10);
  b_3(9) <= b(9);
  b_3(8) <= b(8);
  b_3(7) <= b(7);
  b_3(6) <= b(6);
  b_3(5) <= b(5);
  b_3(4) <= b(4);
  b_3(3) <= b(3);
  b_3(2) <= b(2);
  b_3(1) <= b(1);
  b_3(0) <= b(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and0000136 : 
LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000026_31
,
      I1 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000053_32
,
      I2 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000093_33
,
      I3 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and0000120_34
,
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o(0)

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and0000120 : 
LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => a_2(6),
      I1 => b_3(6),
      I2 => a_2(7),
      I3 => b_3(7),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and0000120_34

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000093 : 
LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => a_2(4),
      I1 => b_3(4),
      I2 => a_2(5),
      I3 => b_3(5),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000093_33

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000053 : 
LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => a_2(2),
      I1 => b_3(2),
      I2 => a_2(3),
      I3 => b_3(3),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000053_32

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000026 : 
LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => a_2(0),
      I1 => b_3(0),
      I2 => a_2(1),
      I3 => b_3(1),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_0_and000026_31

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_1_and0000 : 
LUT3
    generic map(
      INIT => X"09"
    )
    port map (
      I0 => b_3(9),
      I1 => a_2(9),
      I2 => BU2_N01,
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o(1)

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o_1_and0000_SW0 : 
LUT4
    generic map(
      INIT => X"6FF6"
    )
    port map (
      I0 => a_2(10),
      I1 => b_3(10),
      I2 => a_2(8),
      I3 => b_3(8),
      O => BU2_N01
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_opt_carry_tile_and_or_carry_muxs_0_i_mux : 
MUXCY
    port map (
      CI => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_async_o(1)
,
      DI => BU2_a_ge_b,
      S => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o(0)
,
      O => BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_opt_carry_tile_and_or_carry_muxs_1_i_mux : 
MUXCY
    port map (
      CI => BU2_N1,
      DI => BU2_a_ge_b,
      S => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_lut_o(1)
,
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_async_o(1)

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_gen_output_reg_output_reg_fd_output_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result,
      Q => qa_eq_b
    );
  BU2_XST_VCC : VCC
    port map (
      P => BU2_N1
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_a_ge_b
    );

end STRUCTURE;

-- synthesis translate_on
