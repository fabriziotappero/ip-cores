--
-- Registros de sinctonización entre las etapas IF e ID
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

library work;
use work.segm_mips_const_pkg.all;


entity IF_ID_REGISTERS is 
    port(
	        CLK		: in	STD_LOGIC;			-- Reloj
		RESET		: in	STD_LOGIC;			-- Reset asincrónico
	        NEW_PC_ADDR_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	-- Salida del sumador
	        INST_REG_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	-- Salida de la Memoria de Instrucción
	        NEW_PC_ADDR_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	-- Salida del sumador sincronizada
	        INST_REG_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)	-- Salida de la Memoria de Instrucción sincronizada
        );
end IF_ID_REGISTERS;

architecture IF_ID_REGISTERS_ARC of IF_ID_REGISTERS is        
begin
	SYNC_IF_ID:	
		process(CLK,RESET,NEW_PC_ADDR_IN,INST_REG_IN)
		begin
			if RESET = '1' then
				NEW_PC_ADDR_OUT	<= (others => '0');
				INST_REG_OUT	<= (others => '0');
			elsif rising_edge(CLK) then
				NEW_PC_ADDR_OUT	<= NEW_PC_ADDR_IN;
				INST_REG_OUT<= INST_REG_IN;
			end if;
		end process; 
end IF_ID_REGISTERS_ARC;
