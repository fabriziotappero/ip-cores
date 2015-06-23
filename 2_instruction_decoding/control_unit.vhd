--
-- Unidad de control del procesador MIPS Segmentado
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

library work;
use work.segm_mips_const_pkg.all;


entity CONTROL_UNIT is
	port( 
	
		OP			: in	STD_LOGIC_VECTOR (5 downto 0); 		--Código de operación

		RegWrite		: out	STD_LOGIC; 				--Señal de habilitación de escritura (RegWrite)
		MemtoReg		: out	STD_LOGIC;  				--Señal de habilitación  (MemToReg)
		Brach			: out	STD_LOGIC; 				--Señal de habilitación  (Branch)
		MemRead			: out	STD_LOGIC; 				--Señal de habilitación  (MemRead)
		MemWrite		: out	STD_LOGIC; 				--Señal de habilitación  (MemWrite)
		RegDst			: out	STD_LOGIC; 				--Señal de habilitación  (RegDst)
		ALUSrc			: out	STD_LOGIC;				--Señal de habilitación  (ALUSrc)
		ALUOp0			: out	STD_LOGIC; 				--Señal de habilitación  (ALUOp0)
		ALUOp1			: out	STD_LOGIC; 				--Señal de habilitación  (ALUOp1)
		ALUOp2			: out	STD_LOGIC 				--Señal de habilitación  (ALUOp2)

	);
end CONTROL_UNIT;


architecture CONTROL_UNIT_ARC of CONTROL_UNIT is  

--Decaración de señales
	signal R_TYPE		: STD_LOGIC;
	signal LW		: STD_LOGIC;
	signal SW		: STD_LOGIC;
	signal BEQ		: STD_LOGIC;
	signal LUI		: STD_LOGIC;
	
begin	

	R_TYPE		<=	not OP(5) and not OP(4) and not OP(3) and 
				not OP(2) and not OP(1) and not OP(0);
		
	LW		<=	OP(5) and not OP(4) and not OP(3) and 
				not OP(2) and    OP(1) and     OP(0);
		
	SW		<=	OP(5) and not OP(4) and 	OP(3) and 
				not OP(2) and     OP(1) and     OP(0);

	BEQ		<=	not OP(5) and not OP(4) and not OP(3) and 
				    OP(2) and not OP(1) and not OP(0);

	LUI		<=	not OP(5) and not OP(4) and OP(3) and 
				OP(2) and  OP(1) and OP(0);
	
	RegWrite	<= R_TYPE or LW or LUI;		
	MemtoReg	<= LW;		
	Brach		<= BEQ;	
	MemRead		<= LW or LUI;
	MemWrite	<= SW;
	RegDst		<= R_TYPE;
	ALUSrc		<= LW or SW or LUI;
	ALUOp0		<= BEQ;
	ALUOp1		<= R_TYPE;
	ALUOp2		<= LUI;
			
end CONTROL_UNIT_ARC;
