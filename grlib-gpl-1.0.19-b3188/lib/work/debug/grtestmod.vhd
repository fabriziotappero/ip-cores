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
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.sim.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.devices.all;

use std.textio.all;

entity grtestmod is
  generic (halt : integer := 0);
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    errorn	: in std_ulogic;
    address 	: in std_logic_vector(21 downto 2);
    data	: inout std_logic_vector(31 downto 0);
    iosn        : in std_ulogic;
    oen         : in std_ulogic;
    writen  	: in std_ulogic; 		
    brdyn  	: out  std_ulogic := '1'
 );

end;

architecture sim of grtestmod is
subtype msgtype is string(1 to 40);
constant ntests : integer := 2;
type msgarr is array (0 to ntests) of msgtype;
constant msg : msgarr := (
    "*** Starting GRLIB system test ***      ", -- 0
    "Test completed OK, halting simulation   ", -- 1
    "Test FAILED                             "  -- 2
);

signal ior, iow : std_ulogic;

begin

  ior <= iosn or oen;
  iow <= iosn or writen;

  data <= (others => 'Z');

  log : process(ior, iow, clk)
  variable errno, errcnt, subtest, vendorid, deviceid : integer;
  variable addr : std_logic_vector(21 downto 2);
  variable ldata : std_logic_vector(31 downto 0);
  begin
    if rising_edge(clk) then
      addr := to_X01(address);
      ldata := to_X01(data);
    end if;
    if falling_edge (ior) then
      brdyn <= '1', '0' after 100 ns;
    elsif rising_edge (ior) then
      brdyn <= '1';
    elsif falling_edge(iow) then
      brdyn <= '1', '0' after 100 ns;
    elsif rising_edge(iow) then
      brdyn <= '1';
--      addr := to_X01(address);
      case addr(7 downto 2) is
      when "000000" =>
        vendorid := conv_integer(ldata(31 downto 24));
        deviceid := conv_integer(ldata(23 downto 12));
	print(iptable(vendorid).device_table(deviceid));
      when "000001" =>
        errno := conv_integer(ldata(15 downto 0));
	if  (halt = 0) then
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity failure;
	else
	  assert false
	  report "test failed, error (" & tost(errno) & ")"
	  severity warning;
	end if;
      when "000010" =>
        subtest := conv_integer(ldata(7 downto 0));
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
  end process;
end;

-- pragma translate_on
