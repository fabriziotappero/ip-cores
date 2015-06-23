--
-- Test bench del procesador MIPS Segmentado
--
-- Licencia: Copyright 2008 Emmanuel Luján
--
-- 	This program is free software; you can redistribute it and/or
-- 	modify it under the terms of the GNU General Public License as
-- 	published by the Free Software Foundation; either version 2 of
-- 	the License, or (at your option) any later version. This program
-- 	is distributed in the hope that it will be useful, but WITHOUT
-- 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- 	or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
-- 	License for more details. You should have received a copy of the
-- 	GNU General Public License along with this program; if not, write
-- 	to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
-- 	Boston, MA 02110-1301 USA.
-- 
-- Autor:	Emmanuel Luján
-- Email:	info@emmanuellujan.com.ar
-- Versión:	1.0
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

entity SEGMENTED_MIPS_TB is
end SEGMENTED_MIPS_TB;

architecture SEGMENTED_MIPS_TB_ARC of SEGMENTED_MIPS_TB is

-- Declaración de componentes
	component SEGMENTED_MIPS is
		port(
			CLK 	 :	in STD_LOGIC;
			RESET	 :	in STD_LOGIC
		);
	end component SEGMENTED_MIPS;

-- Declaración de señales
	signal CLK	: STD_LOGIC;
	signal RESET	: STD_LOGIC;

begin
	MIPS_TB:
		SEGMENTED_MIPS port map(
			CLK => CLK,
			RESET => RESET
		);

	CLK_PROC:
		process
		begin
			while true loop
				CLK <= '0';
				wait for 10 ns;
				CLK <= '1';
				wait for 10 ns;
			end loop;
		end process CLK_PROC;


	RESET_PROC:
		process
		begin
			RESET<='1';
			wait for 40 ns;
			RESET<='0';
			wait;
		end process RESET_PROC;
   	
end SEGMENTED_MIPS_TB_ARC;
