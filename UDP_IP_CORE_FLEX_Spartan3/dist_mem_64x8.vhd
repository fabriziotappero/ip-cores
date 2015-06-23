--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: dist_mem_64x8.vhd
-- /___/   /\     Timestamp: Mon May 09 14:16:57 2011
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\dist_mem_64x8.ngc" "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\dist_mem_64x8.vhd" 
-- Device	: 3s200pq208-4
-- Input file	: C:/VERIFICATION PLATFORM/UDP_IP_FLEX/COREGEN/tmp/_cg/dist_mem_64x8.ngc
-- Output file	: C:/VERIFICATION PLATFORM/UDP_IP_FLEX/COREGEN/tmp/_cg/dist_mem_64x8.vhd
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
    we : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    d : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end dist_mem_64x8;

architecture STRUCTURE of dist_mem_64x8 is
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N32 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N30 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N28 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N26 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N24 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N22 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N20 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N18 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N16 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N14 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N12 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N10 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N8 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N6 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N4 : STD_LOGIC; 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N2 : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal d_3 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal qspo_4 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_qdpo : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
  d_3(7) <= d(7);
  d_3(6) <= d(6);
  d_3(5) <= d(5);
  d_3(4) <= d(4);
  d_3(3) <= d(3);
  d_3(2) <= d(2);
  d_3(1) <= d(1);
  d_3(0) <= d(0);
  qspo(7) <= qspo_4(7);
  qspo(6) <= qspo_4(6);
  qspo(5) <= qspo_4(5);
  qspo(4) <= qspo_4(4);
  qspo(3) <= qspo_4(3);
  qspo(2) <= qspo_4(2);
  qspo(1) <= qspo_4(1);
  qspo(0) <= qspo_4(0);
  VCC_0 : VCC
    port map (
      P => N1
    );
  GND_1 : GND
    port map (
      G => N0
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => a_2(5),
      I1 => we,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(0),
      Q => qspo_4(0)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(1),
      Q => qspo_4(1)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(2),
      Q => qspo_4(2)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(3),
      Q => qspo_4(3)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(4),
      Q => qspo_4(4)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(5),
      Q => qspo_4(5)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(6),
      Q => qspo_4(6)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_qspo_int_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(7),
      Q => qspo_4(7)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => a_2(5),
      I1 => we,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram1 : RAM32X1S
    generic map(
      INIT => X"00804000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(0),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N2
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram2 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(0),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N4
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram3 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(1),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N6
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram6 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(2),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N12
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram4 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(1),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N8
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram5 : RAM32X1S
    generic map(
      INIT => X"00014000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(2),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N10
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram9 : RAM32X1S
    generic map(
      INIT => X"00800000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(4),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N18
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram7 : RAM32X1S
    generic map(
      INIT => X"00001000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(3),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N14
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram8 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(3),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N16
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram12 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(5),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N24
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram10 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(4),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N20
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram11 : RAM32X1S
    generic map(
      INIT => X"00010000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(5),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N22
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram15 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(7),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N30
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram13 : RAM32X1S
    generic map(
      INIT => X"00504000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(6),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl_50,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N26
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram14 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(6),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N28
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_Mram_ram16 : RAM32X1S
    generic map(
      INIT => X"00000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      D => d_3(7),
      WCLK => clk,
      WE => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_write_ctrl1_49,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N32
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX711 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N30,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N32,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(7)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX611 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N26,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N28,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(6)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX511 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N22,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N24,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(5)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX411 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N18,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N20,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(4)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX311 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N14,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N16,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(3)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX211 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N10,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N12,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(2)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX111 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N6,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N8,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(1)
    );
  BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_inst_LPM_MUX11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => a_2(5),
      I1 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N2,
      I2 => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_N4,
      O => BU2_U0_gen_sp_ram_spram_inst_PipeRAM_1_spo_int(0)
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_qdpo(0)
    );

end STRUCTURE;

-- synthesis translate_on
