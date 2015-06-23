
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mac_crc_16 is
	port (crc_clk: in std_logic;
	      crc_rst : in std_logic;
	      crc_en : in std_logic;
	      crc_bit_input: in std_logic;
	      crc_16_output : out std_logic_vector(15 downto 0));
end mac_crc_16;

architecture rtl of mac_crc_16 is
	signal g_reg_s : std_logic_vector(15 downto 0);
begin

	crc_check: process(crc_clk, crc_rst, crc_bit_input)
		variable g_reg_v: std_logic_vector(0 to 15) := (others =>'0');
		
		variable s1: std_logic := '0';
		variable s2: std_logic := '0';
		variable s3: std_logic := '0';
	begin
		if rising_edge(crc_clk) then
			if crc_rst = '1' then
				g_reg_v := (others=>'0');
				
				s1 := '0';
				s2 := '0';
				s3 := '0';

			elsif crc_en = '1' then
				s1 := crc_bit_input xor g_reg_v(0);
				s2 := s1 xor g_reg_v(11);
				s3 := s1 xor g_reg_v(4);
			
				g_reg_v := g_reg_v(1 to 15) & s1;
				g_reg_v(10) := s2; 	
				g_reg_v(3) := s3;	
			end if;
		
		end if;
	
		g_reg_s <= g_reg_v;
	
	end process;
	
	crc_16_output <= g_reg_s;
	
end rtl;

