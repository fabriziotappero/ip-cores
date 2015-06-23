-- Copyright (c) 2010 Antonio de la Piedra
 
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

-- A VHDL model of the IEEE 802.15.4 physical layer.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rz_enc is
	Port( rz_encoder_input: in std_logic_vector(9 downto 0);
			rz_output: out std_logic);
end rz_enc;

architecture Behavioral of rz_enc is

begin
	rz_output <= '1' when signed(rz_encoder_input) > 0 else '0';
end Behavioral;

