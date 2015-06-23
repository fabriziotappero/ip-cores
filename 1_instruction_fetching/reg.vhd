--
-- Registro concencional para implementación del Program Counter (PC)
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


entity REG is 
	generic (N: NATURAL); -- N = tam. dir.    
	port(
		CLK		: in	STD_LOGIC;			-- Reloj			
		RESET		: in	STD_LOGIC;			-- Reset asincrónico
		DATA_IN		: in	STD_LOGIC_VECTOR(N-1 downto 0);	-- Datos de entrada
		DATA_OUT	: out	STD_LOGIC_VECTOR(N-1 downto 0)	-- Datos de salida
	);
end REG;

architecture REG_ARC of REG is        
begin
	SYNC_REG:
		process(CLK,RESET,DATA_IN)
		begin
			if(RESET = '1') then
				DATA_OUT <= (others => '0');
			elsif rising_edge(CLK) then
				DATA_OUT <= DATA_IN;
			end if;
		end process; 
end REG_ARC;
