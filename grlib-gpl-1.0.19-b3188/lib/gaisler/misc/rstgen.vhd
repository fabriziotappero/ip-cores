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
-- Entity: 	rstgen
-- File:	rstgen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Reset generation with glitch filter
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rstgen is
  generic (acthigh : integer := 0; syncrst : integer := 0;
	   scanen : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic;
    testrst   : in  std_ulogic := '0';
    testen    : in  std_ulogic := '0'
  );
end;

architecture rtl of rstgen is
signal r : std_logic_vector(4 downto 0);
signal rst, rstoutl, arst : std_ulogic;
begin

  rst <= not rstin when acthigh = 1 else rstin;
  rstoutraw <= rst;
  arst <= testrst when (scanen = 1) and (testen = '1') else rst;
  async : if syncrst = 0 generate
    reg1 : process (clk, arst) begin
      if rising_edge(clk) then 
        r <= r(3 downto 0) & clklock; 
        rstoutl <= r(4) and r(3) and r(2);
      end if;
      if (arst = '0') then r <= "00000"; rstoutl <= '0'; end if;
    end process;
    rstout <= (rstoutl and rst) when scanen = 1 else rstoutl;
  end generate;

  sync : if syncrst = 1 generate
    reg1 : process (clk) begin
      if rising_edge(clk) then 
        r <= (r(3 downto 0) & clklock) and (rst & rst & rst & rst & rst); 
        rstoutl <= r(4) and r(3) and r(2);
      end if;
    end process;
    rstout <= rstoutl and rst;
  end generate;


end;

