

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

entity key_schedule is
            port (clk : in std_logic;
		  rst : in std_logic;
		  enc : in std_logic; -- (0, enc) (1, dec)
		  val : in std_logic_vector(1 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  subkey : out std_logic_vector(31 downto 0));
end key_schedule;

architecture Behavioral of key_schedule is

	type key_t is array (0 to 3) of unsigned(31 downto 0);    
	
	signal k : key_t;
	signal sum_s : unsigned(31 downto 0);
	signal sum_delay_s : unsigned(31 downto 0);

	signal key_0_s : unsigned(31 downto 0);
	signal key_1_s : unsigned(31 downto 0);

	signal delta_s : unsigned(31 downto 0);
	
begin

	delta_s <= X"9E3779B9";

	k(3) <= unsigned(key(127 downto 96));
   k(2) <= unsigned(key(95 downto 64));
   k(1) <= unsigned(key(63 downto 32));
   k(0) <= unsigned(key(31 downto 0));
		
	gen_key : process(clk, rst, val, enc, k, sum_s, delta_s)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				if enc = '1' then
					sum_s <= X"8dde6e40";
				else
					sum_s <= (others => '0');
				end if;
				subkey <= (others => '0');
			else
				if val = "00" then
					if enc = '1' then
						subkey <= std_logic_vector(sum_s + k(to_integer(("00000000000" & sum_s(31 downto 11)) and x"00000003")));			
						sum_s <= sum_s - delta_s;
					else
						subkey <= std_logic_vector(sum_s + k(to_integer(sum_s and x"00000003")));
						sum_s <= sum_s + delta_s;
					end if;
				elsif val = "10" then
					if enc = '1' then
						subkey <= std_logic_vector(sum_s + k(to_integer(sum_s and x"00000003")));	
					else
						subkey <= std_logic_vector(sum_s + k(to_integer(("00000000000" & sum_s(31 downto 11)) and x"00000003")));			
					end if;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;



