
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
use IEEE.NUMERIC_STD.ALL;

entity round_f is
	port(v_in : in std_logic_vector(31 downto 0);
	     last_val : in std_logic_vector(31 downto 0);
             v_out : out std_logic_vector(31 downto 0));
end round_f;

architecture Behavioral of round_f is

	signal op_1_s : std_logic_vector(31 downto 0);
	signal op_2_s : std_logic_vector(31 downto 0);
	signal op_3_s : std_logic_vector(31 downto 0);
	signal op_4_s : std_logic_vector(31 downto 0);

begin

	op_1_s <= (v_in(27 downto 0) & "0000");
	op_2_s <= "00000"& v_in(31 downto 5);
	op_3_s <= op_1_s xor op_2_s;
	op_4_s <= std_logic_vector(unsigned(op_3_s ) + unsigned(v_in));
	v_out <= op_4_s xor last_val;

end Behavioral;

