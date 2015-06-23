--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: dist_mem_64x8.vhd
-- /___/   /\     Timestamp: Thu Feb 04 11:02:06 2010
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\dist_mem_64x8.ngc C:\PHd_Projects\The_Felsenstein_CoProcessor\COREGEN_Design\tmp\_cg\dist_mem_64x8.vhd 
-- Device	: 3s200ft256-4
-- Input file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/dist_mem_64x8.ngc
-- Output file	: C:/PHd_Projects/The_Felsenstein_CoProcessor/COREGEN_Design/tmp/_cg/dist_mem_64x8.vhd
-- # of Entities	: 1
-- Design Name	: dist_mem_64x8
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

entity dist_mem_64x8 is
  port (
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end dist_mem_64x8;

architecture STRUCTURE of dist_mem_64x8 is
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal NlwRenamedSignal_qspo : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
  qspo(7) <= NlwRenamedSignal_qspo(0);
  qspo(6) <= NlwRenamedSignal_qspo(0);
  qspo(5) <= NlwRenamedSignal_qspo(0);
  qspo(4) <= NlwRenamedSignal_qspo(0);
  qspo(3) <= NlwRenamedSignal_qspo(0);
  qspo(2) <= NlwRenamedSignal_qspo(0);
  qspo(1) <= NlwRenamedSignal_qspo(0);
  qspo(0) <= NlwRenamedSignal_qspo(0);
  VCC_0 : VCC
    port map (
      P => N1
    );
  GND_1 : GND
    port map (
      G => N0
    );
  BU2_XST_GND : GND
    port map (
      G => NlwRenamedSignal_qspo(0)
    );

end STRUCTURE;

-- synthesis translate_on
