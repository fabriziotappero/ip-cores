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
-- Entity: 	nuhosp3
-- File:	nuhosp3.vhd
-- Author:	Jiri Gaisler - Gaisler Reserch
-- Description:	
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;

entity nuhosp3 is
  generic (
    hindex : integer := 0;
    haddr  : integer := 0;
    hmask  : integer := 16#fff#;
    ioaddr : integer := 16#200#;
    iomask : integer := 16#fff#
    ); 
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    nui    : in  nuhosp3_in_type;
    nuo    : out nuhosp3_out_type
  );
end;

architecture rtl of nuhosp3 is

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_NUHOSP3, 0, 0, 0),
  4 => ahb_membar(haddr, '1', '1', hmask),
  5 => ahb_membar(ioaddr, '0', '0', iomask),
  others => zero32);

type fstate is (idle, read1, read2, leadout);

type reg_type is record
  hwrite : std_ulogic;
  hready : std_ulogic;
  hsel   : std_ulogic;
  haddr   : std_logic_vector(31 downto 0);
  hmbsel : std_logic_vector(0 to 1);
  ws      : std_logic_vector(2 downto 0);
  flash_a : std_logic_vector(20 downto 0);
  flash_wd  : std_logic_vector(15 downto 0);
  flash_oen : std_ulogic;
  flash_wen : std_ulogic;
  flash_cen : std_ulogic;
  flash_rd  : std_logic_vector(31 downto 0);
  flash_state : fstate;
  smsc_wd  : std_logic_vector(31 downto 0);
  smsc_ncs : std_ulogic;
end record;

constant romws : std_logic_vector(2 downto 0) := "011";

signal r, c : reg_type;
begin

  comb : process (ahbsi, r, rst, nui)
  variable v : reg_type;
  begin
    v := r; 

    if ahbsi.hready = '1' then 
      v.hsel := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.hready := not v.hsel;
      v.hwrite := ahbsi.hwrite;
      v.haddr := ahbsi.haddr; 
      v.hmbsel := ahbsi.hmbsel(0 to 1);
    end if;

    v.flash_rd(15 downto 0) := nui.flash_d;
    case r.flash_state is
      when idle =>
        v.flash_wen := '1'; v.flash_oen := '1';
	if (r.hsel = '1') then
	  v.flash_cen := not r.hmbsel(0); 
	  v.smsc_ncs := not r.hmbsel(1); 
	  v.flash_state := read1; 
	  v.flash_oen := r.hwrite; v.flash_a := r.haddr(20 downto 0);
	  v.flash_wd := ahbsi.hwdata(31 downto 16);
	  v.smsc_wd := ahbsi.hwdata(31 downto 0);
	end if;
      when read1 =>
	v.flash_state := read2; v.ws := romws; v.flash_wen := not r.hwrite;
 	v.flash_rd(31 downto 16) := r.flash_rd(15 downto 0);
      when read2 =>
        v.ws := r.ws - 1;
	if r.ws = "000" then
	  if (r.flash_a(0) = '0') and (r.hwrite = '0') then
	    v.flash_state := read1; v.flash_a(0) := '1';
	  else
	    v.hready := '1'; v.flash_state := leadout; v.flash_oen := '1'; 
	    v.flash_wen := '1'; v.flash_cen := '1'; v.smsc_ncs := '1';
	  end if;
	end if;
      when leadout =>
	v.flash_state := idle; 
    end case;

    if rst = '0' then v.hready := '1'; v.flash_state := idle; end if;

    c <= v; 

    nuo.flash_oen <= r.flash_oen;
    nuo.flash_wen <= r.flash_wen;
    nuo.flash_cen <= r.flash_cen;
    nuo.flash_a   <= r.flash_a;
    nuo.flash_d   <= r.flash_wd;
    nuo.smsc_ncs  <= r.smsc_ncs;
    nuo.smsc_nbe  <= (others => r.flash_wen);
    nuo.smsc_ben  <= r.flash_wen;
    nuo.smsc_data <= r.smsc_wd;
    nuo.smsc_addr <= r.flash_a(14 downto 0);
    ahbso.hready  <= r.hready; 
    ahbso.hrdata  <= r.flash_rd;

  end process;

  nuo.smsc_resetn <= rst;
  nuo.smsc_nwr <= '1';
  nuo.smsc_nrd <= '1';
  nuo.smsc_wnr <= '1';
  nuo.smsc_cycle <= '1';
  nuo.smsc_aen <= '1';
  nuo.smsc_lclk <= '1';
  nuo.smsc_rdyrtn <= '1';
  nuo.smsc_nads <= '0';

  nuo.lcd_en <= '0';
  nuo.lcd_ben <= '1';
  nuo.lcd_backl <= '1';

  ahbso.hresp   <= "00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '0';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  reg : process (clk, rst)
  begin
    if rising_edge(clk ) then r <= c; end if;
    if rst = '0' then 
      r.flash_cen <= '1'; r.smsc_ncs <= '1'; r.flash_wen <= '1';
     end if;
  end process;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("huhosp3" & tost(hindex) &
    ": Nuhorizons Spartan3 board interface");
-- pragma translate_on
end;
