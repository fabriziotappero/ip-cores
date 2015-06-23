--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: dist_mem_64x8.vhd
-- /___/   /\     Timestamp: Sat Feb 12 17:26:42 2011
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\dist_mem_64x8.ngc" "C:\VERIFICATION PLATFORM\UDP_IP_FLEX\COREGEN\tmp\_cg\dist_mem_64x8.vhd" 
-- Device	: 5vsx95tff1136-1
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
  signal a_2 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal d_3 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal qspo_4 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_gen_sp_ram_spram_inst_spo_int : STD_LOGIC_VECTOR ( 7 downto 0 ); 
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
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram8 : RAM64X1S
    generic map(
      INIT => X"0000000000000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(7),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(7)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram7 : RAM64X1S
    generic map(
      INIT => X"0000000000504000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(6),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(6)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram6 : RAM64X1S
    generic map(
      INIT => X"0000000000010000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(5),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(5)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram5 : RAM64X1S
    generic map(
      INIT => X"0000000000800000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(4),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(4)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram4 : RAM64X1S
    generic map(
      INIT => X"0000000000001000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(3),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(3)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram3 : RAM64X1S
    generic map(
      INIT => X"0000000000014000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(2),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(2)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram2 : RAM64X1S
    generic map(
      INIT => X"0000000000000000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(1),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(1)
    );
  BU2_U0_gen_sp_ram_spram_inst_Mram_ram1 : RAM64X1S
    generic map(
      INIT => X"0000000000804000"
    )
    port map (
      A0 => a_2(0),
      A1 => a_2(1),
      A2 => a_2(2),
      A3 => a_2(3),
      A4 => a_2(4),
      A5 => a_2(5),
      D => d_3(0),
      WCLK => clk,
      WE => we,
      O => BU2_U0_gen_sp_ram_spram_inst_spo_int(0)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(7),
      Q => qspo_4(7)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(6),
      Q => qspo_4(6)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(5),
      Q => qspo_4(5)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(4),
      Q => qspo_4(4)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(3),
      Q => qspo_4(3)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(2),
      Q => qspo_4(2)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(1),
      Q => qspo_4(1)
    );
  BU2_U0_gen_sp_ram_spram_inst_qspo_int_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_gen_sp_ram_spram_inst_spo_int(0),
      Q => qspo_4(0)
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_qdpo(0)
    );

end STRUCTURE;

-- synthesis translate_on
