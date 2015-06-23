--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: reg_1b_1c.vhd
-- /___/   /\     Timestamp: Mon Jun 22 17:44:50 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_1b_1c.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_1b_1c.vhd" 
-- Device	: 5vsx95tff1136-2
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/reg_1b_1c.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/reg_1b_1c.vhd
-- # of Entities	: 1
-- Design Name	: reg_1b_1c
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

entity reg_1b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 0 downto 0 ) 
  );
end reg_1b_1c;

architecture STRUCTURE of reg_1b_1c is
  signal BU2_sset : STD_LOGIC; 
  signal BU2_sinit : STD_LOGIC; 
  signal BU2_ainit : STD_LOGIC; 
  signal BU2_aclr : STD_LOGIC; 
  signal BU2_ce : STD_LOGIC; 
  signal BU2_aset : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal d_2 : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal q_3 : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal BU2_a : STD_LOGIC_VECTOR ( 3 downto 0 ); 
begin
  d_2(0) <= d(0);
  q(0) <= q_3(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => d_2(0),
      R => sclr,
      Q => q_3(0)
    );

end STRUCTURE;

-- synthesis translate_on
