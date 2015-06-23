--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: wraddr_lut_mem.vhd
-- /___/   /\     Timestamp: Mon May 09 14:17:18 2011
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\wraddr_lut_mem.ngc" "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\wraddr_lut_mem.vhd" 
-- Device	: 3s200pq208-4
-- Input file	: C:/VERIFICATION PLATFORM/UDP_IP_FLEX/COREGEN/tmp/_cg/wraddr_lut_mem.ngc
-- Output file	: C:/VERIFICATION PLATFORM/UDP_IP_FLEX/COREGEN/tmp/_cg/wraddr_lut_mem.vhd
-- # of Entities	: 1
-- Design Name	: wraddr_lut_mem
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

entity wraddr_lut_mem is
  port (
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end wraddr_lut_mem;

architecture STRUCTURE of wraddr_lut_mem is
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000311 : STD_LOGIC; 
  signal BU2_N35 : STD_LOGIC; 
  signal BU2_N34 : STD_LOGIC; 
  signal BU2_N33 : STD_LOGIC; 
  signal BU2_N32 : STD_LOGIC; 
  signal BU2_N31 : STD_LOGIC; 
  signal BU2_N30 : STD_LOGIC; 
  signal BU2_N29 : STD_LOGIC; 
  signal BU2_N28 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000031 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f51 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00002_22 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00001_21 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f5_20 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005_18 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_17 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021_16 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011_15 : STD_LOGIC; 
  signal BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f6_14 : STD_LOGIC; 
  signal a_2 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal qspo_3 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal BU2_qdpo : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  a_2(5) <= a(5);
  a_2(4) <= a(4);
  a_2(3) <= a(3);
  a_2(2) <= a(2);
  a_2(1) <= a(1);
  a_2(0) <= a(0);
  qspo(5) <= qspo_3(5);
  qspo(4) <= qspo_3(4);
  qspo(3) <= qspo_3(3);
  qspo(2) <= qspo_3(2);
  qspo(1) <= qspo_3(1);
  qspo(0) <= qspo_3(0);
  VCC_0 : VCC
    port map (
      P => N1
    );
  GND_1 : GND
    port map (
      G => N0
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000311_f5 : MUXF5
    port map (
      I0 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000311,
      I1 => BU2_qdpo(0),
      S => a_2(5),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000031
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00003111 : LUT4
    generic map(
      INIT => X"101C"
    )
    port map (
      I0 => a_2(4),
      I1 => a_2(1),
      I2 => a_2(2),
      I3 => a_2(3),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000311
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011_G : LUT4
    generic map(
      INIT => X"0B3D"
    )
    port map (
      I0 => a_2(1),
      I1 => a_2(4),
      I2 => a_2(5),
      I3 => a_2(3),
      O => BU2_N35
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011_F : LUT4
    generic map(
      INIT => X"5351"
    )
    port map (
      I0 => a_2(5),
      I1 => a_2(1),
      I2 => a_2(4),
      I3 => a_2(3),
      O => BU2_N34
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011 : MUXF5
    port map (
      I0 => BU2_N34,
      I1 => BU2_N35,
      S => a_2(2),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011_15
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_G : LUT4
    generic map(
      INIT => X"0B2C"
    )
    port map (
      I0 => a_2(1),
      I1 => a_2(4),
      I2 => a_2(5),
      I3 => a_2(3),
      O => BU2_N33
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_F : LUT3
    generic map(
      INIT => X"26"
    )
    port map (
      I0 => a_2(4),
      I1 => a_2(5),
      I2 => a_2(1),
      O => BU2_N32
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004 : MUXF5
    port map (
      I0 => BU2_N32,
      I1 => BU2_N33,
      S => a_2(2),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_17
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005_G : LUT4
    generic map(
      INIT => X"1656"
    )
    port map (
      I0 => a_2(5),
      I1 => a_2(3),
      I2 => a_2(4),
      I3 => a_2(1),
      O => BU2_N31
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005_F : LUT4
    generic map(
      INIT => X"1528"
    )
    port map (
      I0 => a_2(5),
      I1 => a_2(3),
      I2 => a_2(1),
      I3 => a_2(4),
      O => BU2_N30
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005 : MUXF5
    port map (
      I0 => BU2_N30,
      I1 => BU2_N31,
      S => a_2(2),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005_18
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021_G : LUT4
    generic map(
      INIT => X"1656"
    )
    port map (
      I0 => a_2(5),
      I1 => a_2(3),
      I2 => a_2(4),
      I3 => a_2(2),
      O => BU2_N29
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021_F : LUT4
    generic map(
      INIT => X"1653"
    )
    port map (
      I0 => a_2(5),
      I1 => a_2(2),
      I2 => a_2(4),
      I3 => a_2(3),
      O => BU2_N28
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021 : MUXF5
    port map (
      I0 => BU2_N28,
      I1 => BU2_N29,
      S => a_2(1),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021_16
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_3 : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000031,
      S => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_17,
      Q => qspo_3(3)
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f6 : MUXF6
    port map (
      I0 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f51,
      I1 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f5_20,
      S => a_2(5),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f6_14
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f5_0 : MUXF5
    port map (
      I0 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00002_22,
      I1 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00001_21,
      S => a_2(4),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f51
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00003 : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => a_2(3),
      I1 => a_2(2),
      I2 => a_2(0),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00002_22
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00002 : LUT4
    generic map(
      INIT => X"9DDF"
    )
    port map (
      I0 => a_2(3),
      I1 => a_2(0),
      I2 => a_2(2),
      I3 => a_2(1),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00001_21
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f5 : MUXF5
    port map (
      I0 => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000,
      I1 => BU2_qdpo(0),
      S => a_2(4),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f5_20
    );
  BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00001 : LUT4
    generic map(
      INIT => X"544E"
    )
    port map (
      I0 => a_2(3),
      I1 => a_2(0),
      I2 => a_2(2),
      I3 => a_2(1),
      O => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00005_18,
      Q => qspo_3(5)
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom00004_17,
      Q => qspo_3(4)
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000021_16,
      Q => qspo_3(2)
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom000011_15,
      Q => qspo_3(1)
    );
  BU2_U0_gen_rom_rom_inst_qspo_int_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_rom_rom_inst_Mrom_spo_int_rom0000_f6_14,
      Q => qspo_3(0)
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_qdpo(0)
    );

end STRUCTURE;

-- synthesis translate_on
