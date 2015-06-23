
-- Copyright (c) 2013 Antonio de la Piedra

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rc_gen is
	port(clk : in std_logic;
	     rst : in std_logic;
		  enc : in std_logic; -- 0 (enc), 1 (dec)
		  rc_out : out std_logic_vector(7 downto 0));
end rc_gen;

architecture Behavioral of rc_gen is
	signal rc_s : std_logic_vector(7 downto 0);
begin

	pr_gen: process(clk, rst, enc)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				if enc = '0' then
					rc_s <= X"80";
				else
					rc_s <= X"D4";
				end if;
			else
				if enc = '0' then
					if ((rc_s and X"80") = X"00") then
						rc_s <= rc_s(6 downto 0) & '0';
					else
						rc_s <= (rc_s(6 downto 0) & '0') xor X"1B";
					end if;
				else
					if ((rc_s and X"01") = X"00") then
						rc_s <= '0' & rc_s(7 downto 1);
					else
						rc_s <= ('0' & rc_s(7 downto 1)) xor X"8D";
					end if;				
				end if;
			end if;
		end if;		
	end process;

	rc_out <= rc_s;

end Behavioral;

