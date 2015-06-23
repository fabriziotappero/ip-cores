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

-- clock devider routine

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_div is
    Port ( reset: in std_logic;
    		 in_clk : in std_logic;
           out1 : out std_logic;
           out2 : out std_logic);
end clock_div;

architecture Behavioral of clock_div is

signal ct: std_logic_vector(19 downto 0);
--signal ct: std_logic_vector(1 downto 0);

begin

	process(reset,in_clk)
	begin
		if reset = '0' then
			ct <= "00000000000000000000";
--			ct <= "00";
		elsif in_clk'event and in_clk = '1' then
			ct <= ct + "00000000000000000001";
--			ct <= ct + "01";
		end if;
	end process;
-- Using this value we can adjust different clock speed
-- Fast Clock
out1 <= ct(5);
-- Slow clock
out2 <= ct(19);

--out1 <= ct(0);
--out2 <= ct(1);

end Behavioral;
