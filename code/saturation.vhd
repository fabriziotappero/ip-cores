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

-- A.9 saturation.vhd
-- saturation circuit
-- important for avoiding adverse effect of truncation

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity saturation is
    Port ( d_in : in std_logic_vector(15 downto 0);
           d_out : out std_logic_vector(15 downto 0));
end saturation;

architecture Behavioral of saturation is
	signal sel:std_logic_vector(1 downto 0);
begin

		sel(1) <= not(d_in(12) xor d_in(13)xor d_in(14) xor d_in(15));
		sel(0) <= d_in(15);

		with sel select
		d_out <= d_in when "11"|"10",
			    "0001000000000000" when "00",
			    "1111000000000000" when "01",
			    "0000000000000000" when others;

end Behavioral;
