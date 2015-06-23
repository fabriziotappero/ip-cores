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
-- Package: 	actel_components
-- File:	actel_components.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Actel RAM and pad component declarations
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package actel_components is

-- Proasic & Proasicplus rams

  component RAM256x9SST port(
    DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_logic;
    WPE, RPE, DOS : out std_logic;
    WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
    RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
    WCLKS, RCLKS : in std_logic;
    DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_logic;
    WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_logic);
  end component;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM256x9SST is
    port(
  DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_ulogic;
  WPE, RPE, DOS : out std_ulogic;
  WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_ulogic;
  RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_ulogic;
  WCLKS, RCLKS : in std_ulogic;
  DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_ulogic;
  WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_ulogic);
end;

architecture rtl of RAM256x9SST is
  signal d, q : std_logic_vector(8 downto 0);
  signal wa, ra : std_logic_vector(7 downto 0);
  signal wen, ren : std_ulogic;
  type dregtype is array (0 to 2**8 - 1) 
	of std_logic_vector(8 downto 0);

begin
  wen <= not (WBLKB or WRB); ren <= not (RBLKB or RDB);
  wa  <= WADDR7 & WADDR6 & WADDR5 & WADDR4 & WADDR3 & WADDR2 & WADDR1 & WADDR0;
  ra  <= RADDR7 & RADDR6 & RADDR5 & RADDR4 & RADDR3 & RADDR2 & RADDR1 & RADDR0;
  d   <= DI8 & DI7 & DI6 & DI5 & DI4 & DI3 & DI2 & DI1 & DI0;

  rp : process(WCLKS, RCLKS)
  variable rfd : dregtype;
  begin
    if rising_edge(RCLKS) then
      if (ren = '1') and not is_x(ra) then
   	q <= rfd(to_integer(unsigned(ra))); 
      end if;
    end if;
    if rising_edge(WCLKS) then
      if (wen = '1') and not is_x(wa) then
   	rfd(to_integer(unsigned(wa))) := d; 
      end if;
    end if;
  end process;

  DO8 <= q(8); DO7 <= q(7); DO6 <= q(6); DO5 <= q(5); DO4 <= q(4);
  DO3 <= q(3); DO2 <= q(2); DO1 <= q(1); DO0 <= q(0);
  
end;
