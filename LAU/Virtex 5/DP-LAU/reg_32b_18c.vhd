--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: reg_32b_18c.vhd
-- /___/   /\     Timestamp: Wed Jun 24 18:00:33 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_32b_18c.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_32b_18c.vhd" 
-- Device	: 5vsx95tff1136-2
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/reg_32b_18c.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/reg_32b_18c.vhd
-- # of Entities	: 1
-- Design Name	: reg_32b_18c
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

entity reg_32b_18c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end reg_32b_18c;

architecture STRUCTURE of reg_32b_18c is
  signal BU2_sset : STD_LOGIC; 
  signal BU2_sinit : STD_LOGIC; 
  signal BU2_ainit : STD_LOGIC; 
  signal BU2_aclr : STD_LOGIC; 
  signal BU2_ce : STD_LOGIC; 
  signal BU2_aset : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_31_130 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_30_129 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_29_128 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_28_127 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_27_126 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_26_125 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_25_124 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_24_123 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_23_122 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_22_121 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_21_120 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_20_119 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_19_118 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_18_117 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_17_116 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_16_115 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_15_114 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_14_113 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_13_112 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_12_111 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_11_110 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_10_109 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_9_108 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_8_107 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_7_106 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_6_105 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_5_104 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_4_103 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_3_102 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_2_101 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_1_100 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_16_0_99 : STD_LOGIC; 
  signal BU2_U0_N1 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_31_97 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_30_96 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_29_95 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_28_94 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_27_93 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_26_92 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_25_91 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_24_90 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_23_89 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_22_88 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_21_87 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_20_86 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_19_85 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_18_84 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_17_83 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_16_82 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_15_81 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_14_80 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_13_79 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_12_78 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_11_77 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_10_76 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_9_75 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_8_74 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_7_73 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_6_72 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_5_71 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_4_70 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_3_69 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_2_68 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_1_67 : STD_LOGIC; 
  signal BU2_U0_srl_sig_16_0_66 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_31_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_30_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_29_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_28_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_27_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_26_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_25_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_24_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_23_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_22_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_21_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_20_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_19_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_18_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_17_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_16_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_15_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_14_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_13_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_12_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_11_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_10_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_9_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_8_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_7_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_6_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_5_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_4_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_3_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_2_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_1_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_16_0_Q15_UNCONNECTED : STD_LOGIC; 
  signal d_2 : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal q_3 : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal BU2_a : STD_LOGIC_VECTOR ( 3 downto 0 ); 
begin
  d_2(31) <= d(31);
  d_2(30) <= d(30);
  d_2(29) <= d(29);
  d_2(28) <= d(28);
  d_2(27) <= d(27);
  d_2(26) <= d(26);
  d_2(25) <= d(25);
  d_2(24) <= d(24);
  d_2(23) <= d(23);
  d_2(22) <= d(22);
  d_2(21) <= d(21);
  d_2(20) <= d(20);
  d_2(19) <= d(19);
  d_2(18) <= d(18);
  d_2(17) <= d(17);
  d_2(16) <= d(16);
  d_2(15) <= d(15);
  d_2(14) <= d(14);
  d_2(13) <= d(13);
  d_2(12) <= d(12);
  d_2(11) <= d(11);
  d_2(10) <= d(10);
  d_2(9) <= d(9);
  d_2(8) <= d(8);
  d_2(7) <= d(7);
  d_2(6) <= d(6);
  d_2(5) <= d(5);
  d_2(4) <= d(4);
  d_2(3) <= d(3);
  d_2(2) <= d(2);
  d_2(1) <= d(1);
  d_2(0) <= d(0);
  q(31) <= q_3(31);
  q(30) <= q_3(30);
  q(29) <= q_3(29);
  q(28) <= q_3(28);
  q(27) <= q_3(27);
  q(26) <= q_3(26);
  q(25) <= q_3(25);
  q(24) <= q_3(24);
  q(23) <= q_3(23);
  q(22) <= q_3(22);
  q(21) <= q_3(21);
  q(20) <= q_3(20);
  q(19) <= q_3(19);
  q(18) <= q_3(18);
  q(17) <= q_3(17);
  q(16) <= q_3(16);
  q(15) <= q_3(15);
  q(14) <= q_3(14);
  q(13) <= q_3(13);
  q(12) <= q_3(12);
  q(11) <= q_3(11);
  q(10) <= q_3(10);
  q(9) <= q_3(9);
  q(8) <= q_3(8);
  q(7) <= q_3(7);
  q(6) <= q_3(6);
  q(5) <= q_3(5);
  q(4) <= q_3(4);
  q(3) <= q_3(3);
  q(2) <= q_3(2);
  q(1) <= q_3(1);
  q(0) <= q_3(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_srl_sig_16_31 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_31_130,
      Q => BU2_U0_srl_sig_16_31_97
    );
  BU2_U0_Mshreg_srl_sig_16_31 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(31),
      Q => BU2_U0_Mshreg_srl_sig_16_31_130,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_31_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_30 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_30_129,
      Q => BU2_U0_srl_sig_16_30_96
    );
  BU2_U0_Mshreg_srl_sig_16_30 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(30),
      Q => BU2_U0_Mshreg_srl_sig_16_30_129,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_30_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_29 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_29_128,
      Q => BU2_U0_srl_sig_16_29_95
    );
  BU2_U0_Mshreg_srl_sig_16_29 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(29),
      Q => BU2_U0_Mshreg_srl_sig_16_29_128,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_29_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_28 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_28_127,
      Q => BU2_U0_srl_sig_16_28_94
    );
  BU2_U0_Mshreg_srl_sig_16_28 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(28),
      Q => BU2_U0_Mshreg_srl_sig_16_28_127,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_28_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_27 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_27_126,
      Q => BU2_U0_srl_sig_16_27_93
    );
  BU2_U0_Mshreg_srl_sig_16_27 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(27),
      Q => BU2_U0_Mshreg_srl_sig_16_27_126,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_27_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_26 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_26_125,
      Q => BU2_U0_srl_sig_16_26_92
    );
  BU2_U0_Mshreg_srl_sig_16_26 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(26),
      Q => BU2_U0_Mshreg_srl_sig_16_26_125,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_26_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_25 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_25_124,
      Q => BU2_U0_srl_sig_16_25_91
    );
  BU2_U0_Mshreg_srl_sig_16_25 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(25),
      Q => BU2_U0_Mshreg_srl_sig_16_25_124,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_25_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_24 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_24_123,
      Q => BU2_U0_srl_sig_16_24_90
    );
  BU2_U0_Mshreg_srl_sig_16_24 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(24),
      Q => BU2_U0_Mshreg_srl_sig_16_24_123,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_24_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_23 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_23_122,
      Q => BU2_U0_srl_sig_16_23_89
    );
  BU2_U0_Mshreg_srl_sig_16_23 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(23),
      Q => BU2_U0_Mshreg_srl_sig_16_23_122,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_23_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_22 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_22_121,
      Q => BU2_U0_srl_sig_16_22_88
    );
  BU2_U0_Mshreg_srl_sig_16_22 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(22),
      Q => BU2_U0_Mshreg_srl_sig_16_22_121,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_22_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_21 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_21_120,
      Q => BU2_U0_srl_sig_16_21_87
    );
  BU2_U0_Mshreg_srl_sig_16_21 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(21),
      Q => BU2_U0_Mshreg_srl_sig_16_21_120,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_21_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_20 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_20_119,
      Q => BU2_U0_srl_sig_16_20_86
    );
  BU2_U0_Mshreg_srl_sig_16_20 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(20),
      Q => BU2_U0_Mshreg_srl_sig_16_20_119,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_20_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_19 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_19_118,
      Q => BU2_U0_srl_sig_16_19_85
    );
  BU2_U0_Mshreg_srl_sig_16_19 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(19),
      Q => BU2_U0_Mshreg_srl_sig_16_19_118,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_19_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_18 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_18_117,
      Q => BU2_U0_srl_sig_16_18_84
    );
  BU2_U0_Mshreg_srl_sig_16_18 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(18),
      Q => BU2_U0_Mshreg_srl_sig_16_18_117,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_18_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_17 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_17_116,
      Q => BU2_U0_srl_sig_16_17_83
    );
  BU2_U0_Mshreg_srl_sig_16_17 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(17),
      Q => BU2_U0_Mshreg_srl_sig_16_17_116,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_17_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_16 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_16_115,
      Q => BU2_U0_srl_sig_16_16_82
    );
  BU2_U0_Mshreg_srl_sig_16_16 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(16),
      Q => BU2_U0_Mshreg_srl_sig_16_16_115,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_16_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_15 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_15_114,
      Q => BU2_U0_srl_sig_16_15_81
    );
  BU2_U0_Mshreg_srl_sig_16_15 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(15),
      Q => BU2_U0_Mshreg_srl_sig_16_15_114,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_15_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_14 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_14_113,
      Q => BU2_U0_srl_sig_16_14_80
    );
  BU2_U0_Mshreg_srl_sig_16_14 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(14),
      Q => BU2_U0_Mshreg_srl_sig_16_14_113,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_14_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_13 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_13_112,
      Q => BU2_U0_srl_sig_16_13_79
    );
  BU2_U0_Mshreg_srl_sig_16_13 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(13),
      Q => BU2_U0_Mshreg_srl_sig_16_13_112,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_13_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_12 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_12_111,
      Q => BU2_U0_srl_sig_16_12_78
    );
  BU2_U0_Mshreg_srl_sig_16_12 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(12),
      Q => BU2_U0_Mshreg_srl_sig_16_12_111,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_12_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_11 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_11_110,
      Q => BU2_U0_srl_sig_16_11_77
    );
  BU2_U0_Mshreg_srl_sig_16_11 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(11),
      Q => BU2_U0_Mshreg_srl_sig_16_11_110,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_11_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_10 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_10_109,
      Q => BU2_U0_srl_sig_16_10_76
    );
  BU2_U0_Mshreg_srl_sig_16_10 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(10),
      Q => BU2_U0_Mshreg_srl_sig_16_10_109,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_10_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_9_108,
      Q => BU2_U0_srl_sig_16_9_75
    );
  BU2_U0_Mshreg_srl_sig_16_9 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(9),
      Q => BU2_U0_Mshreg_srl_sig_16_9_108,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_9_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_8_107,
      Q => BU2_U0_srl_sig_16_8_74
    );
  BU2_U0_Mshreg_srl_sig_16_8 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(8),
      Q => BU2_U0_Mshreg_srl_sig_16_8_107,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_8_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_7_106,
      Q => BU2_U0_srl_sig_16_7_73
    );
  BU2_U0_Mshreg_srl_sig_16_7 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(7),
      Q => BU2_U0_Mshreg_srl_sig_16_7_106,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_7_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_6_105,
      Q => BU2_U0_srl_sig_16_6_72
    );
  BU2_U0_Mshreg_srl_sig_16_6 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(6),
      Q => BU2_U0_Mshreg_srl_sig_16_6_105,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_6_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_5_104,
      Q => BU2_U0_srl_sig_16_5_71
    );
  BU2_U0_Mshreg_srl_sig_16_5 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(5),
      Q => BU2_U0_Mshreg_srl_sig_16_5_104,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_5_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_4_103,
      Q => BU2_U0_srl_sig_16_4_70
    );
  BU2_U0_Mshreg_srl_sig_16_4 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(4),
      Q => BU2_U0_Mshreg_srl_sig_16_4_103,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_4_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_3_102,
      Q => BU2_U0_srl_sig_16_3_69
    );
  BU2_U0_Mshreg_srl_sig_16_3 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(3),
      Q => BU2_U0_Mshreg_srl_sig_16_3_102,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_3_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_2_101,
      Q => BU2_U0_srl_sig_16_2_68
    );
  BU2_U0_Mshreg_srl_sig_16_2 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(2),
      Q => BU2_U0_Mshreg_srl_sig_16_2_101,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_2_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_1_100,
      Q => BU2_U0_srl_sig_16_1_67
    );
  BU2_U0_Mshreg_srl_sig_16_1 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(1),
      Q => BU2_U0_Mshreg_srl_sig_16_1_100,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_1_Q15_UNCONNECTED
    );
  BU2_U0_srl_sig_16_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_N1,
      D => BU2_U0_Mshreg_srl_sig_16_0_99,
      Q => BU2_U0_srl_sig_16_0_66
    );
  BU2_U0_Mshreg_srl_sig_16_0 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CE => BU2_U0_N1,
      CLK => clk,
      D => d_2(0),
      Q => BU2_U0_Mshreg_srl_sig_16_0_99,
      Q15 => NLW_BU2_U0_Mshreg_srl_sig_16_0_Q15_UNCONNECTED
    );
  BU2_U0_XST_VCC : VCC
    port map (
      P => BU2_U0_N1
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_32 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_31_97,
      R => sclr,
      Q => q_3(31)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_31 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_30_96,
      R => sclr,
      Q => q_3(30)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_30 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_29_95,
      R => sclr,
      Q => q_3(29)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_29 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_28_94,
      R => sclr,
      Q => q_3(28)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_28 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_27_93,
      R => sclr,
      Q => q_3(27)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_27 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_26_92,
      R => sclr,
      Q => q_3(26)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_26 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_25_91,
      R => sclr,
      Q => q_3(25)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_25 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_24_90,
      R => sclr,
      Q => q_3(24)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_24 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_23_89,
      R => sclr,
      Q => q_3(23)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_23 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_22_88,
      R => sclr,
      Q => q_3(22)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_22 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_21_87,
      R => sclr,
      Q => q_3(21)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_21 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_20_86,
      R => sclr,
      Q => q_3(20)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_20 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_19_85,
      R => sclr,
      Q => q_3(19)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_19 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_18_84,
      R => sclr,
      Q => q_3(18)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_18 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_17_83,
      R => sclr,
      Q => q_3(17)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_17 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_16_82,
      R => sclr,
      Q => q_3(16)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_16 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_15_81,
      R => sclr,
      Q => q_3(15)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_15 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_14_80,
      R => sclr,
      Q => q_3(14)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_14 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_13_79,
      R => sclr,
      Q => q_3(13)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_13 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_12_78,
      R => sclr,
      Q => q_3(12)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_12 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_11_77,
      R => sclr,
      Q => q_3(11)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_11 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_10_76,
      R => sclr,
      Q => q_3(10)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_10 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_9_75,
      R => sclr,
      Q => q_3(9)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_9 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_8_74,
      R => sclr,
      Q => q_3(8)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_8 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_7_73,
      R => sclr,
      Q => q_3(7)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_7 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_6_72,
      R => sclr,
      Q => q_3(6)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_6 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_5_71,
      R => sclr,
      Q => q_3(5)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_5 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_4_70,
      R => sclr,
      Q => q_3(4)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_3_69,
      R => sclr,
      Q => q_3(3)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_2_68,
      R => sclr,
      Q => q_3(2)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_1_67,
      R => sclr,
      Q => q_3(1)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_16_0_66,
      R => sclr,
      Q => q_3(0)
    );

end STRUCTURE;

-- synthesis translate_on
