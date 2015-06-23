--
-- Control de la ALU del procesador MIPS Segmentado
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
use work.records_pkg.all;

entity ALU_CONTROL is
	port(
			--Entradas
			CLK		:	in STD_LOGIC;				-- Reloj
			FUNCT		:	in STD_LOGIC_VECTOR(5 downto 0);	-- Campo de la instrucción FUNC
			ALU_OP_IN	:	in ALU_OP_INPUT;			-- Señal de control de la Unidad de Control
			--Salidas
		     	ALU_IN		:	out ALU_INPUT				-- Entrada de la ALU
	);
end ALU_CONTROL;

architecture ALU_CONTROL_ARC of ALU_CONTROL is
begin
	
	ALU_IN.Op0 <= ALU_OP_IN.Op1 and ( FUNCT(0) or FUNCT(3) );
	ALU_IN.Op1 <= (not ALU_OP_IN.Op1) or (not FUNCT(2));
	ALU_IN.Op2 <= ALU_OP_IN.Op0 or ( ALU_OP_IN.Op1 and FUNCT(1) );
	ALU_IN.Op3 <= ALU_OP_IN.Op2;

end ALU_CONTROL_ARC;
