--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

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
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

-- simple one bit analog output
-- is outputting frequency in responce to count no
-- so it repressent amount of error with frequency

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity d_a is
  port (
   clk : in std_logic;
   data_in : in std_logic_vector (15 downto 0);
   an_out : out std_logic;
   reset: in std_logic
  );
end d_a;

architecture d_a_arch of d_a is
  signal  d_a_Accumulator : std_logic_vector(8 downto 0);
begin
  process(clk)
  begin
    if (clk'event and clk = '1') then
	    	if (reset = '0') then
			d_a_Accumulator <= "000000000";
		else      
	   	  	d_a_Accumulator  <=  ("0" & d_a_Accumulator(7 downto 0)) + ("0" & data_in(7 downto 0));
		end if;
    end if;
  end process;

  an_out <= d_a_Accumulator(8);
end d_a_arch;

