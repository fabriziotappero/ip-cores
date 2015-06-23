------------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
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
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.sim.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.tech.all;

use std.textio.all;

use work.config.all;	-- configuration

entity testmod is
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    errorn	: in std_ulogic;
    address 	: in std_logic_vector(21 downto 2);
    data	: inout std_logic_vector(31 downto 0);
    cb          : inout std_logic_vector(7 downto 0);
    romsn       : in std_logic_vector(1 downto 0);
    ramsn       : in std_logic_vector(3 downto 0);
    iosn        : in std_ulogic;
    oen         : in std_ulogic;
    rwen        : in std_logic_vector(3 downto 0);
    writen  	: in std_ulogic; 		
    brdyn  	: out  std_ulogic
 );

end;

architecture sim of testmod is
subtype msgtype is string(1 to 40);
constant ntests : integer := 11;
type msgarr is array (0 to ntests) of msgtype;
constant msg : msgarr := (
    "*** Starting GRLIB system test ***      ", -- 0
    "Test completed OK, halting simulation   ", -- 1
    "Test FAILED                             ", -- 2
    "Leon3 register file                     ", -- 3
    "Leon3 multiplier                        ", -- 4
    "Leon3 divider                           ", -- 5
    "Leon3 cache system                      ", -- 6
    "APB uart                                ", -- 7
    "FT sram controller                      ", -- 8
    "GPIO port                               ", -- 9
    "Cache memory                            ", -- 10
    "Interrupt controller                    "  -- 11
);

signal ior, iow : std_ulogic;

begin

  ior <= iosn or oen;
  iow <= iosn or writen;

  data <= (others => 'Z');
  cb   <= (others => 'Z');

  log : process(ior, iow)
  variable a, d, d2 : integer;
  begin
    brdyn <= '0';
    if rising_edge(iow) then
      a := conv_integer(address(7 downto 2));
      d := conv_integer(data(7 downto 0));
      d2 := conv_integer(data(15 downto 8));
      if (d >= 0) and (d <= ntests) then
	if a = 0 then
	  print(msg(d));
	else
	  print(msg(d) & "failed (" & tost(d2) & ")");
	end if;
      end if;
    end if;
  end process;
end;

