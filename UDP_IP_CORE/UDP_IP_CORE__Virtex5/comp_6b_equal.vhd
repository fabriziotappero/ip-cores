--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: comp_6b_equal.vhd
-- /___/   /\     Timestamp: Mon Nov 30 14:23:03 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\comp_6b_equal.ngc C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\comp_6b_equal.vhd 
-- Device	: 5vsx95tff1136-1
-- Input file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/comp_6b_equal.ngc
-- Output file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/comp_6b_equal.vhd
-- # of Entities	: 1
-- Design Name	: comp_6b_equal
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

entity comp_6b_equal is
  port (
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end comp_6b_equal;

architecture STRUCTURE of comp_6b_equal is
  signal BU2_N01 : STD_LOGIC; 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o85_16 : STD_LOGIC;
 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result : STD_LOGIC; 
  signal BU2_a_ge_b : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal b_3 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
begin
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
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
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o107 : 
LUT6
    generic map(
      INIT => X"0000000080200802"
    )
    port map (
      I0 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o85_16
,
      I1 => b_3(5),
      I2 => b_3(4),
      I3 => a_2(5),
      I4 => a_2(4),
      I5 => BU2_N01,
      O => BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o107_SW0 : 
LUT4
    generic map(
      INIT => X"6FF6"
    )
    port map (
      I0 => a_2(0),
      I1 => b_3(0),
      I2 => a_2(3),
      I3 => b_3(3),
      O => BU2_N01
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o85 : 
LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => a_2(1),
      I1 => b_3(1),
      I2 => a_2(2),
      I3 => b_3(2),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o85_16

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
  BU2_XST_GND : GND
    port map (
      G => BU2_a_ge_b
    );

end STRUCTURE;

-- synthesis translate_on
