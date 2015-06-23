--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: reg_32b_18c.vhd
-- /___/   /\     Timestamp: Fri Sep 18 15:02:34 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_32b_18c.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\reg_32b_18c.vhd" 
-- Device	: 4vsx55ff1148-12
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
  signal BU2_U0_Mshreg_srl_sig_22_31_1_163 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_31_0_162 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_30_1_161 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_30_0_160 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_29_1_159 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_29_0_158 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_28_1_157 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_28_0_156 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_27_1_155 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_27_0_154 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_26_1_153 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_26_0_152 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_25_1_151 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_25_0_150 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_24_1_149 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_24_0_148 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_23_1_147 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_23_0_146 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_22_1_145 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_22_0_144 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_21_1_143 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_21_0_142 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_20_1_141 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_20_0_140 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_19_1_139 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_19_0_138 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_18_1_137 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_18_0_136 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_17_1_135 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_17_0_134 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_16_1_133 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_16_0_132 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_15_1_131 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_15_0_130 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_14_1_129 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_14_0_128 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_13_1_127 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_13_0_126 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_12_1_125 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_12_0_124 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_11_1_123 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_11_0_122 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_10_1_121 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_10_0_120 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_9_1_119 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_9_0_118 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_8_1_117 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_8_0_116 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_7_1_115 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_7_0_114 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_6_1_113 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_6_0_112 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_5_1_111 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_5_0_110 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_4_1_109 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_4_0_108 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_3_1_107 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_3_0_106 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_2_1_105 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_2_0_104 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_1_1_103 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_1_0_102 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_0_1_101 : STD_LOGIC; 
  signal BU2_U0_Mshreg_srl_sig_22_0_0_100 : STD_LOGIC; 
  signal BU2_U0_N1 : STD_LOGIC; 
  signal BU2_U0_N0 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_31_97 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_30_96 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_29_95 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_28_94 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_27_93 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_26_92 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_25_91 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_24_90 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_23_89 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_22_88 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_21_87 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_20_86 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_19_85 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_18_84 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_17_83 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_16_82 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_15_81 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_14_80 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_13_79 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_12_78 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_11_77 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_10_76 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_9_75 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_8_74 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_7_73 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_6_72 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_5_71 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_4_70 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_3_69 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_2_68 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_1_67 : STD_LOGIC; 
  signal BU2_U0_srl_sig_22_0_66 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_31_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_30_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_29_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_28_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_27_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_26_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_25_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_24_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_23_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_22_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_21_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_20_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_19_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_18_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_17_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_16_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_15_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_14_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_13_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_12_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_11_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_10_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_9_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_8_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_7_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_6_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_5_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_4_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_3_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_2_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_1_0_Q_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_Mshreg_srl_sig_22_0_0_Q_UNCONNECTED : STD_LOGIC; 
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
  BU2_U0_srl_sig_22_31 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_31_1_163,
      Q => BU2_U0_srl_sig_22_31_97
    );
  BU2_U0_Mshreg_srl_sig_22_31_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_31_0_162,
      Q => BU2_U0_Mshreg_srl_sig_22_31_1_163
    );
  BU2_U0_Mshreg_srl_sig_22_31_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(31),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_31_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_31_0_162
    );
  BU2_U0_srl_sig_22_30 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_30_1_161,
      Q => BU2_U0_srl_sig_22_30_96
    );
  BU2_U0_Mshreg_srl_sig_22_30_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_30_0_160,
      Q => BU2_U0_Mshreg_srl_sig_22_30_1_161
    );
  BU2_U0_Mshreg_srl_sig_22_30_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(30),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_30_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_30_0_160
    );
  BU2_U0_srl_sig_22_29 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_29_1_159,
      Q => BU2_U0_srl_sig_22_29_95
    );
  BU2_U0_Mshreg_srl_sig_22_29_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_29_0_158,
      Q => BU2_U0_Mshreg_srl_sig_22_29_1_159
    );
  BU2_U0_Mshreg_srl_sig_22_29_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(29),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_29_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_29_0_158
    );
  BU2_U0_srl_sig_22_28 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_28_1_157,
      Q => BU2_U0_srl_sig_22_28_94
    );
  BU2_U0_Mshreg_srl_sig_22_28_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_28_0_156,
      Q => BU2_U0_Mshreg_srl_sig_22_28_1_157
    );
  BU2_U0_Mshreg_srl_sig_22_28_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(28),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_28_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_28_0_156
    );
  BU2_U0_srl_sig_22_27 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_27_1_155,
      Q => BU2_U0_srl_sig_22_27_93
    );
  BU2_U0_Mshreg_srl_sig_22_27_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_27_0_154,
      Q => BU2_U0_Mshreg_srl_sig_22_27_1_155
    );
  BU2_U0_Mshreg_srl_sig_22_27_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(27),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_27_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_27_0_154
    );
  BU2_U0_srl_sig_22_26 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_26_1_153,
      Q => BU2_U0_srl_sig_22_26_92
    );
  BU2_U0_Mshreg_srl_sig_22_26_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_26_0_152,
      Q => BU2_U0_Mshreg_srl_sig_22_26_1_153
    );
  BU2_U0_Mshreg_srl_sig_22_26_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(26),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_26_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_26_0_152
    );
  BU2_U0_srl_sig_22_25 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_25_1_151,
      Q => BU2_U0_srl_sig_22_25_91
    );
  BU2_U0_Mshreg_srl_sig_22_25_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_25_0_150,
      Q => BU2_U0_Mshreg_srl_sig_22_25_1_151
    );
  BU2_U0_Mshreg_srl_sig_22_25_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(25),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_25_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_25_0_150
    );
  BU2_U0_srl_sig_22_24 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_24_1_149,
      Q => BU2_U0_srl_sig_22_24_90
    );
  BU2_U0_Mshreg_srl_sig_22_24_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_24_0_148,
      Q => BU2_U0_Mshreg_srl_sig_22_24_1_149
    );
  BU2_U0_Mshreg_srl_sig_22_24_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(24),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_24_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_24_0_148
    );
  BU2_U0_srl_sig_22_23 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_23_1_147,
      Q => BU2_U0_srl_sig_22_23_89
    );
  BU2_U0_Mshreg_srl_sig_22_23_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_23_0_146,
      Q => BU2_U0_Mshreg_srl_sig_22_23_1_147
    );
  BU2_U0_Mshreg_srl_sig_22_23_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(23),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_23_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_23_0_146
    );
  BU2_U0_srl_sig_22_22 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_22_1_145,
      Q => BU2_U0_srl_sig_22_22_88
    );
  BU2_U0_Mshreg_srl_sig_22_22_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_22_0_144,
      Q => BU2_U0_Mshreg_srl_sig_22_22_1_145
    );
  BU2_U0_Mshreg_srl_sig_22_22_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(22),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_22_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_22_0_144
    );
  BU2_U0_srl_sig_22_21 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_21_1_143,
      Q => BU2_U0_srl_sig_22_21_87
    );
  BU2_U0_Mshreg_srl_sig_22_21_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_21_0_142,
      Q => BU2_U0_Mshreg_srl_sig_22_21_1_143
    );
  BU2_U0_Mshreg_srl_sig_22_21_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(21),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_21_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_21_0_142
    );
  BU2_U0_srl_sig_22_20 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_20_1_141,
      Q => BU2_U0_srl_sig_22_20_86
    );
  BU2_U0_Mshreg_srl_sig_22_20_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_20_0_140,
      Q => BU2_U0_Mshreg_srl_sig_22_20_1_141
    );
  BU2_U0_Mshreg_srl_sig_22_20_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(20),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_20_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_20_0_140
    );
  BU2_U0_srl_sig_22_19 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_19_1_139,
      Q => BU2_U0_srl_sig_22_19_85
    );
  BU2_U0_Mshreg_srl_sig_22_19_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_19_0_138,
      Q => BU2_U0_Mshreg_srl_sig_22_19_1_139
    );
  BU2_U0_Mshreg_srl_sig_22_19_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(19),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_19_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_19_0_138
    );
  BU2_U0_srl_sig_22_18 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_18_1_137,
      Q => BU2_U0_srl_sig_22_18_84
    );
  BU2_U0_Mshreg_srl_sig_22_18_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_18_0_136,
      Q => BU2_U0_Mshreg_srl_sig_22_18_1_137
    );
  BU2_U0_Mshreg_srl_sig_22_18_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(18),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_18_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_18_0_136
    );
  BU2_U0_srl_sig_22_17 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_17_1_135,
      Q => BU2_U0_srl_sig_22_17_83
    );
  BU2_U0_Mshreg_srl_sig_22_17_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_17_0_134,
      Q => BU2_U0_Mshreg_srl_sig_22_17_1_135
    );
  BU2_U0_Mshreg_srl_sig_22_17_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(17),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_17_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_17_0_134
    );
  BU2_U0_srl_sig_22_16 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_16_1_133,
      Q => BU2_U0_srl_sig_22_16_82
    );
  BU2_U0_Mshreg_srl_sig_22_16_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_16_0_132,
      Q => BU2_U0_Mshreg_srl_sig_22_16_1_133
    );
  BU2_U0_Mshreg_srl_sig_22_16_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(16),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_16_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_16_0_132
    );
  BU2_U0_srl_sig_22_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_15_1_131,
      Q => BU2_U0_srl_sig_22_15_81
    );
  BU2_U0_Mshreg_srl_sig_22_15_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_15_0_130,
      Q => BU2_U0_Mshreg_srl_sig_22_15_1_131
    );
  BU2_U0_Mshreg_srl_sig_22_15_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(15),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_15_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_15_0_130
    );
  BU2_U0_srl_sig_22_14 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_14_1_129,
      Q => BU2_U0_srl_sig_22_14_80
    );
  BU2_U0_Mshreg_srl_sig_22_14_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_14_0_128,
      Q => BU2_U0_Mshreg_srl_sig_22_14_1_129
    );
  BU2_U0_Mshreg_srl_sig_22_14_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(14),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_14_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_14_0_128
    );
  BU2_U0_srl_sig_22_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_13_1_127,
      Q => BU2_U0_srl_sig_22_13_79
    );
  BU2_U0_Mshreg_srl_sig_22_13_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_13_0_126,
      Q => BU2_U0_Mshreg_srl_sig_22_13_1_127
    );
  BU2_U0_Mshreg_srl_sig_22_13_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(13),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_13_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_13_0_126
    );
  BU2_U0_srl_sig_22_12 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_12_1_125,
      Q => BU2_U0_srl_sig_22_12_78
    );
  BU2_U0_Mshreg_srl_sig_22_12_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_12_0_124,
      Q => BU2_U0_Mshreg_srl_sig_22_12_1_125
    );
  BU2_U0_Mshreg_srl_sig_22_12_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(12),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_12_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_12_0_124
    );
  BU2_U0_srl_sig_22_11 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_11_1_123,
      Q => BU2_U0_srl_sig_22_11_77
    );
  BU2_U0_Mshreg_srl_sig_22_11_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_11_0_122,
      Q => BU2_U0_Mshreg_srl_sig_22_11_1_123
    );
  BU2_U0_Mshreg_srl_sig_22_11_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(11),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_11_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_11_0_122
    );
  BU2_U0_srl_sig_22_10 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_10_1_121,
      Q => BU2_U0_srl_sig_22_10_76
    );
  BU2_U0_Mshreg_srl_sig_22_10_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_10_0_120,
      Q => BU2_U0_Mshreg_srl_sig_22_10_1_121
    );
  BU2_U0_Mshreg_srl_sig_22_10_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(10),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_10_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_10_0_120
    );
  BU2_U0_srl_sig_22_9 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_9_1_119,
      Q => BU2_U0_srl_sig_22_9_75
    );
  BU2_U0_Mshreg_srl_sig_22_9_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_9_0_118,
      Q => BU2_U0_Mshreg_srl_sig_22_9_1_119
    );
  BU2_U0_Mshreg_srl_sig_22_9_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(9),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_9_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_9_0_118
    );
  BU2_U0_srl_sig_22_8 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_8_1_117,
      Q => BU2_U0_srl_sig_22_8_74
    );
  BU2_U0_Mshreg_srl_sig_22_8_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_8_0_116,
      Q => BU2_U0_Mshreg_srl_sig_22_8_1_117
    );
  BU2_U0_Mshreg_srl_sig_22_8_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(8),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_8_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_8_0_116
    );
  BU2_U0_srl_sig_22_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_7_1_115,
      Q => BU2_U0_srl_sig_22_7_73
    );
  BU2_U0_Mshreg_srl_sig_22_7_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_7_0_114,
      Q => BU2_U0_Mshreg_srl_sig_22_7_1_115
    );
  BU2_U0_Mshreg_srl_sig_22_7_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(7),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_7_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_7_0_114
    );
  BU2_U0_srl_sig_22_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_6_1_113,
      Q => BU2_U0_srl_sig_22_6_72
    );
  BU2_U0_Mshreg_srl_sig_22_6_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_6_0_112,
      Q => BU2_U0_Mshreg_srl_sig_22_6_1_113
    );
  BU2_U0_Mshreg_srl_sig_22_6_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(6),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_6_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_6_0_112
    );
  BU2_U0_srl_sig_22_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_5_1_111,
      Q => BU2_U0_srl_sig_22_5_71
    );
  BU2_U0_Mshreg_srl_sig_22_5_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_5_0_110,
      Q => BU2_U0_Mshreg_srl_sig_22_5_1_111
    );
  BU2_U0_Mshreg_srl_sig_22_5_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(5),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_5_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_5_0_110
    );
  BU2_U0_srl_sig_22_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_4_1_109,
      Q => BU2_U0_srl_sig_22_4_70
    );
  BU2_U0_Mshreg_srl_sig_22_4_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_4_0_108,
      Q => BU2_U0_Mshreg_srl_sig_22_4_1_109
    );
  BU2_U0_Mshreg_srl_sig_22_4_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(4),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_4_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_4_0_108
    );
  BU2_U0_srl_sig_22_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_3_1_107,
      Q => BU2_U0_srl_sig_22_3_69
    );
  BU2_U0_Mshreg_srl_sig_22_3_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_3_0_106,
      Q => BU2_U0_Mshreg_srl_sig_22_3_1_107
    );
  BU2_U0_Mshreg_srl_sig_22_3_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(3),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_3_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_3_0_106
    );
  BU2_U0_srl_sig_22_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_2_1_105,
      Q => BU2_U0_srl_sig_22_2_68
    );
  BU2_U0_Mshreg_srl_sig_22_2_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_2_0_104,
      Q => BU2_U0_Mshreg_srl_sig_22_2_1_105
    );
  BU2_U0_Mshreg_srl_sig_22_2_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(2),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_2_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_2_0_104
    );
  BU2_U0_srl_sig_22_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_1_1_103,
      Q => BU2_U0_srl_sig_22_1_67
    );
  BU2_U0_Mshreg_srl_sig_22_1_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_1_0_102,
      Q => BU2_U0_Mshreg_srl_sig_22_1_1_103
    );
  BU2_U0_Mshreg_srl_sig_22_1_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(1),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_1_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_1_0_102
    );
  BU2_U0_srl_sig_22_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_Mshreg_srl_sig_22_0_1_101,
      Q => BU2_U0_srl_sig_22_0_66
    );
  BU2_U0_Mshreg_srl_sig_22_0_1 : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N0,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N0,
      CLK => clk,
      D => BU2_U0_Mshreg_srl_sig_22_0_0_100,
      Q => BU2_U0_Mshreg_srl_sig_22_0_1_101
    );
  BU2_U0_Mshreg_srl_sig_22_0_0 : SRLC16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => BU2_U0_N1,
      A1 => BU2_U0_N1,
      A2 => BU2_U0_N1,
      A3 => BU2_U0_N1,
      CLK => clk,
      D => d_2(0),
      Q => NLW_BU2_U0_Mshreg_srl_sig_22_0_0_Q_UNCONNECTED,
      Q15 => BU2_U0_Mshreg_srl_sig_22_0_0_100
    );
  BU2_U0_XST_VCC : VCC
    port map (
      P => BU2_U0_N1
    );
  BU2_U0_XST_GND : GND
    port map (
      G => BU2_U0_N0
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_32 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_31_97,
      R => sclr,
      Q => q_3(31)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_31 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_30_96,
      R => sclr,
      Q => q_3(30)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_30 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_29_95,
      R => sclr,
      Q => q_3(29)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_29 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_28_94,
      R => sclr,
      Q => q_3(28)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_28 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_27_93,
      R => sclr,
      Q => q_3(27)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_27 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_26_92,
      R => sclr,
      Q => q_3(26)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_26 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_25_91,
      R => sclr,
      Q => q_3(25)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_25 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_24_90,
      R => sclr,
      Q => q_3(24)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_24 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_23_89,
      R => sclr,
      Q => q_3(23)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_23 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_22_88,
      R => sclr,
      Q => q_3(22)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_22 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_21_87,
      R => sclr,
      Q => q_3(21)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_21 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_20_86,
      R => sclr,
      Q => q_3(20)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_20 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_19_85,
      R => sclr,
      Q => q_3(19)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_19 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_18_84,
      R => sclr,
      Q => q_3(18)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_18 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_17_83,
      R => sclr,
      Q => q_3(17)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_17 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_16_82,
      R => sclr,
      Q => q_3(16)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_16 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_15_81,
      R => sclr,
      Q => q_3(15)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_15 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_14_80,
      R => sclr,
      Q => q_3(14)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_14 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_13_79,
      R => sclr,
      Q => q_3(13)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_13 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_12_78,
      R => sclr,
      Q => q_3(12)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_12 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_11_77,
      R => sclr,
      Q => q_3(11)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_11 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_10_76,
      R => sclr,
      Q => q_3(10)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_10 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_9_75,
      R => sclr,
      Q => q_3(9)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_9 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_8_74,
      R => sclr,
      Q => q_3(8)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_8 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_7_73,
      R => sclr,
      Q => q_3(7)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_7 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_6_72,
      R => sclr,
      Q => q_3(6)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_6 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_5_71,
      R => sclr,
      Q => q_3(5)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_5 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_4_70,
      R => sclr,
      Q => q_3(4)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_3_69,
      R => sclr,
      Q => q_3(3)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_2_68,
      R => sclr,
      Q => q_3(2)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_1_67,
      R => sclr,
      Q => q_3(1)
    );
  BU2_U0_gen_output_regs_output_regs_fd_output_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_srl_sig_22_0_66,
      R => sclr,
      Q => q_3(0)
    );

end STRUCTURE;

-- synthesis translate_on
