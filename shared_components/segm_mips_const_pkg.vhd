--
-- Este paquete contiene las constantes que se utilizan en el procesador MIPS Segmentado
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package SEGM_MIPS_CONST_PKG is

	--Constantes
	
	constant INST_SIZE	: INTEGER := 32;		-- Tamaño de una instrucción en bits
	constant ADDR_SIZE	: INTEGER := 5;			-- Tamaño de una dirección
	constant NUM_REG	: INTEGER := 32;		-- Cantidad de registros en el banco de registros
	--constant NUM_ADDR	: INTEGER := 1073741824;	-- Cantidad de direcciones de la memoria, cada una de N bits (2 exp 30)
	constant NUM_ADDR	: INTEGER := 1024;		-- Cantidad de direcciones de la memoria, cada una de N bits (reducida)
	
	constant PC_COUNT	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000100";	--De a cuanto suma el PC (de a 4 bits)

	constant ZERO32b	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000000";	
	constant ZERO16b	: STD_LOGIC_VECTOR(15 downto 0) :=  "0000000000000000";
	constant ONE32b		: STD_LOGIC_VECTOR(31 downto 0) :=  "11111111111111111111111111111111";	
	constant ONE16b		: STD_LOGIC_VECTOR(15 downto 0) :=  "1111111111111111";	

end SEGM_MIPS_CONST_PKG;
