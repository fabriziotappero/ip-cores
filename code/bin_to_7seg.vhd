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


-- seven segment display mapping from 8 bit no
 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity bin_to_7seg is
    Port ( din : in std_logic_vector(3 downto 0);
           dis_out : out std_logic_vector(7 downto 0));
end bin_to_7seg;

architecture Behavioral of bin_to_7seg is

begin


dis_out <= 	"00000010" when din = "0000" else
			"10011110" when din = "0001" else
			"00100100" when din = "0010" else
			"00001100" when din = "0011" else
			"10011000" when din = "0100" else
			"01001000" when din = "0101" else
			"01000000" when din = "0110" else
			"00011110" when din = "0111" else
			"00000000" when din = "1000" else
			"00011000" when din = "1001" else
			"00010000" when din = "1010" else
			"11000000" when din = "1011" else
			"01100010" when din = "1100" else
			"10000100" when din = "1101" else
			"01100000" when din = "1110" else
			"01110000";


end Behavioral;
