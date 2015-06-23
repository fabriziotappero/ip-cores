------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	ahbrep
-- File:	ahbrep.vhd
-- Author:	Jiri Gaisler - Gaisler Reserch
-- Description:	Test report module with AHB interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.sim.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.devices.all;
use grlib.amba.all;

use std.textio.all;

entity ahbrep is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    halt    : integer := 1); 
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;

architecture rtl of ahbrep is

constant abits : integer := 31;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRTESTMOD, 0, 0, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  others => zero32);


type reg_type is record
  hwrite : std_ulogic;
  hsel   : std_ulogic;
  haddr  : std_logic_vector(31 downto 0);
  htrans : std_logic_vector(1 downto 0);
end record;

signal r, rin : reg_type;

begin

  ahbso.hresp   <= "00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '1';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;
  ahbso.hready  <= '1';

  log : process(clk, ahbsi )
  variable errno, errcnt, subtest, vendorid, deviceid : integer;
  variable addr : std_logic_vector(21 downto 2);
  variable v : reg_type;
  begin
  if falling_edge(clk) then
    if (ahbsi.hready = '1') then
      v.haddr := ahbsi.haddr; v.hsel := ahbsi.hsel(hindex);
      v.hwrite := ahbsi.hwrite; v.htrans := ahbsi.htrans;
    end if;
    if (r.hsel and r.htrans(1) and r.hwrite and rst) = '1' then
      case r.haddr(7 downto 2) is
      when "000000" =>
        vendorid := conv_integer(ahbsi.hwdata(31 downto 24));
        deviceid := conv_integer(ahbsi.hwdata(23 downto 12));
	print(iptable(vendorid).device_table(deviceid));
      when "000001" =>
        errno := conv_integer(ahbsi.hwdata(15 downto 0));
	if  (halt = 1) then
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity failure;
	else
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity warning;
	end if;
      when "000010" =>
        subtest := conv_integer(ahbsi.hwdata(7 downto 0));
	if vendorid = VENDOR_GAISLER then
	  case deviceid is
	  when GAISLER_LEON3 => leon3_subtest(subtest);
	  when GAISLER_FTMCTRL => mctrl_subtest(subtest);
	  when GAISLER_GPTIMER => gptimer_subtest(subtest);
	  when GAISLER_LEON3DSU => dsu3_subtest(subtest);
	  when GAISLER_SPW => spw_subtest(subtest);
          when GAISLER_SPICTRL => spictrl_subtest(subtest); 
          when GAISLER_I2CMST => i2cmst_subtest(subtest);
          when GAISLER_UHCI => uhc_subtest(subtest);
          when GAISLER_EHCI => ehc_subtest(subtest);
          when GAISLER_IRQMP => irqmp_subtest(subtest);
          when GAISLER_SPIMCTRL => spimctrl_subtest(subtest);
          when GAISLER_SVGACTRL => svgactrl_subtest(subtest);
          when others =>
            print ("  subtest " & tost(subtest));
	  end case;
	elsif vendorid = VENDOR_ESA then
	  case deviceid is
	  when ESA_LEON2 => leon3_subtest(subtest);
	  when ESA_MCTRL => mctrl_subtest(subtest);
	  when ESA_TIMER => gptimer_subtest(subtest);
	  when others =>
            print ("subtest " & tost(subtest));
	  end case;
	else
          print ("subtest " & tost(subtest));
	end if;
      when "000100" =>
        print ("");
        print ("**** GRLIB system test starting ****");
	errcnt := 0;
      when "000101" =>
	if errcnt = 0 then
          print ("Test passed, halting with IU error mode");
	elsif errcnt = 1 then
          print ("1 error detected, halting with IU error mode");
	else
          print (tost(errcnt) & " errors detected, halting with IU error mode");
        end if;
        print ("");
      when others =>
      end case;
    end if;
  end if;
  rin <= v;
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("testmod" & tost(hindex) & ": Test report module");
-- pragma translate_on
end;
