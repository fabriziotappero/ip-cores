
----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Entity: 	ahbrom
-- File:	ahbrom.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	AHB rom. 0/1-waitstate read
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity ahbrom is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    pipe    : integer := 0;
    tech    : integer := 0;
    kbytes  : integer := 1);
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;

architecture rtl of ahbrom is
constant abits : integer := 9;
constant bytes : integer := 336;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),
  4 => ahb_membar(haddr, '1', '1', hmask), others => zero32);

signal romdata : std_logic_vector(31 downto 0);
signal addr : std_logic_vector(abits-1 downto 2);
signal hsel, hready : std_ulogic;

begin

  ahbso.hresp   <= "00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '1';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  reg : process (clk)
  begin
    if rising_edge(clk) then 
      addr <= ahbsi.haddr(abits-1 downto 2);
    end if;
  end process;

  p0 : if pipe = 0 generate
    ahbso.hrdata  <= romdata;
    ahbso.hready  <= '1';
  end generate;

  p1 : if pipe = 1 generate
    reg2 : process (clk)
    begin
      if rising_edge(clk) then
	hsel <= ahbsi.hsel(hindex) and ahbsi.htrans(1);
	hready <= ahbsi.hready;
	ahbso.hready <=  (not rst) or (hsel and hready) or
	  (ahbsi.hsel(hindex) and not ahbsi.htrans(1) and ahbsi.hready);
	ahbso.hrdata  <= romdata;
      end if;
    end process;
  end generate;

  comb : process (addr)
  begin
    case conv_integer(addr) is
    when 16#00000# => romdata <= X"81D82000";
    when 16#00001# => romdata <= X"03000004";
    when 16#00002# => romdata <= X"821060E0";
    when 16#00003# => romdata <= X"81884000";
    when 16#00004# => romdata <= X"81900000";
    when 16#00005# => romdata <= X"81980000";
    when 16#00006# => romdata <= X"81800000";
    when 16#00007# => romdata <= X"01000000";
    when 16#00008# => romdata <= X"03002040";
    when 16#00009# => romdata <= X"8210600F";
    when 16#0000A# => romdata <= X"C2A00040";
    when 16#0000B# => romdata <= X"87444000";
    when 16#0000C# => romdata <= X"8608E01F";
    when 16#0000D# => romdata <= X"88100000";
    when 16#0000E# => romdata <= X"8A100000";
    when 16#0000F# => romdata <= X"8C100000";
    when 16#00010# => romdata <= X"8E100000";
    when 16#00011# => romdata <= X"A0100000";
    when 16#00012# => romdata <= X"A2100000";
    when 16#00013# => romdata <= X"A4100000";
    when 16#00014# => romdata <= X"A6100000";
    when 16#00015# => romdata <= X"A8100000";
    when 16#00016# => romdata <= X"AA100000";
    when 16#00017# => romdata <= X"AC100000";
    when 16#00018# => romdata <= X"AE100000";
    when 16#00019# => romdata <= X"90100000";
    when 16#0001A# => romdata <= X"92100000";
    when 16#0001B# => romdata <= X"94100000";
    when 16#0001C# => romdata <= X"96100000";
    when 16#0001D# => romdata <= X"98100000";
    when 16#0001E# => romdata <= X"9A100000";
    when 16#0001F# => romdata <= X"9C100000";
    when 16#00020# => romdata <= X"9E100000";
    when 16#00021# => romdata <= X"86A0E001";
    when 16#00022# => romdata <= X"16BFFFEF";
    when 16#00023# => romdata <= X"81E00000";
    when 16#00024# => romdata <= X"82102002";
    when 16#00025# => romdata <= X"81904000";
    when 16#00026# => romdata <= X"03000004";
    when 16#00027# => romdata <= X"821060E0";
    when 16#00028# => romdata <= X"81884000";
    when 16#00029# => romdata <= X"01000000";
    when 16#0002A# => romdata <= X"01000000";
    when 16#0002B# => romdata <= X"01000000";
    when 16#0002C# => romdata <= X"87444000";
    when 16#0002D# => romdata <= X"8730E01C";
    when 16#0002E# => romdata <= X"8688E00F";
    when 16#0002F# => romdata <= X"12800015";
    when 16#00030# => romdata <= X"03200000";
    when 16#00031# => romdata <= X"84102233";
    when 16#00032# => romdata <= X"C4204000";
    when 16#00033# => romdata <= X"0539A81B";
    when 16#00034# => romdata <= X"8410A260";
    when 16#00035# => romdata <= X"C4206004";
    when 16#00036# => romdata <= X"050003FC";
    when 16#00037# => romdata <= X"C4206008";
    when 16#00038# => romdata <= X"82103860";
    when 16#00039# => romdata <= X"C4004000";
    when 16#0003A# => romdata <= X"8530A00C";
    when 16#0003B# => romdata <= X"03000004";
    when 16#0003C# => romdata <= X"82106009";
    when 16#0003D# => romdata <= X"80A04002";
    when 16#0003E# => romdata <= X"12800006";
    when 16#0003F# => romdata <= X"033FFC00";
    when 16#00040# => romdata <= X"82106100";
    when 16#00041# => romdata <= X"0539A81B";
    when 16#00042# => romdata <= X"8410A260";
    when 16#00043# => romdata <= X"C4204000";
    when 16#00044# => romdata <= X"3D1003FF";
    when 16#00045# => romdata <= X"BC17A3E0";
    when 16#00046# => romdata <= X"9C27A060";
    when 16#00047# => romdata <= X"03100000";
    when 16#00048# => romdata <= X"81C04000";
    when 16#00049# => romdata <= X"01000000";
    when 16#0004A# => romdata <= X"01000000";
    when 16#0004B# => romdata <= X"01000000";
    when 16#0004C# => romdata <= X"01000000";
    when 16#0004D# => romdata <= X"01000000";
    when 16#0004E# => romdata <= X"01000000";
    when 16#0004F# => romdata <= X"01000000";
    when 16#00050# => romdata <= X"00000000";
    when 16#00051# => romdata <= X"00000000";
    when 16#00052# => romdata <= X"00000000";
    when 16#00053# => romdata <= X"00000000";
    when 16#00054# => romdata <= X"00000000";
    when others => romdata <= (others => '-');
    end case;
  end process;
  -- pragma translate_off
  bootmsg : report_version 
  generic map ("ahbrom" & tost(hindex) &
  ": 32-bit AHB ROM Module,  " & tost(bytes/4) & " words, " & tost(abits-2) & " address bits" );
  -- pragma translate_on
  end;
