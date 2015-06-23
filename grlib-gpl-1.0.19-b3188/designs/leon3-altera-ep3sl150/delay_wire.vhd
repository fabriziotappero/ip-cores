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
-- Delayed bidirectional wire 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity delay_wire is
  generic(
    data_width  : integer := 1;
    delay_atob  : real := 0.0;
    delay_btoa  : real := 0.0
  );
  port(
    a : inout std_logic_vector(data_width-1 downto 0);
    b : inout std_logic_vector(data_width-1 downto 0)
  );
end delay_wire;

architecture rtl of delay_wire is

signal a_dly,b_dly : std_logic_vector(data_width-1 downto 0) := (others => 'Z');
constant zvector : std_logic_vector(data_width-1 downto 0) := (others => 'Z');

begin
  
  process(a)
  begin
    if a'event then
      if b_dly = zvector then
        a_dly <= transport a after delay_atob*1 ns;
      else
        a_dly <= (others => 'Z');
      end if;
    end if;
  end process;
  
  process(b)
  begin
    if b'event then
      if a_dly = zvector then
        b_dly <= transport b after delay_btoa*1 ns;
      else
        b_dly <= (others => 'Z');
      end if;
    end if;
  end process;

  a <= b_dly; b <= a_dly;

end;
