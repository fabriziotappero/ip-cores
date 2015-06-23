--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: comp_eq_8ones.vhd
-- /___/   /\     Timestamp: Fri Sep 18 13:56:38 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\comp_eq_8ones.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\comp_eq_8ones.vhd" 
-- Device	: 4vsx55ff1148-12
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/comp_eq_8ones.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/comp_eq_8ones.vhd
-- # of Entities	: 1
-- Design Name	: comp_eq_8ones
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

entity comp_eq_8ones is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end comp_eq_8ones;

architecture STRUCTURE of comp_eq_8ones is
  signal BU2_N01 : STD_LOGIC; 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o9_13 : STD_LOGIC;
 
  signal BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result : STD_LOGIC; 
  signal BU2_a_ge_b : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
begin
  a_2(7) <= a(7);
  a_2(6) <= a(6);
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o11 : 
LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o9_13
,
      I1 => a_2(3),
      I2 => a_2(2),
      I3 => BU2_N01,
      O => BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o11_SW0 : 
LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => a_2(1),
      I1 => a_2(0),
      O => BU2_N01
    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o9 : 
LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => a_2(7),
      I1 => a_2(6),
      I2 => a_2(5),
      I3 => a_2(4),
      O => 
BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_i_use_carry_plus_luts_lut_and_i_gate_bit_tier_gen_1_i_tier_loop_tiles_0_i_tile_o9_13

    );
  BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_gen_output_reg_output_reg_fd_output_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_structure_logic_gen_nonpipelined_a_equal_notequal_b_i_a_eq_ne_b_temp_result,
      R => sclr,
      Q => qa_eq_b
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_a_ge_b
    );

end STRUCTURE;

-- synthesis translate_on
