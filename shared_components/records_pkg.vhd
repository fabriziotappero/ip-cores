--
-- Registros que agrupan señales de control
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
  
package RECORDS_PKG is


	--Resgitros que aunan las salidas de la Unidad de Control
	
	type WB_CTRL_REG is
	record
		RegWrite	:	STD_LOGIC;	--Señal de habilitación de escritura
		MemtoReg	:	STD_LOGIC;	--Señal de habilitación  
    	end record;
    
	type MEM_CTRL_REG is
    	record
	      	Branch		:	STD_LOGIC;	--Señal de habilitación
		MemRead		:	STD_LOGIC;	--Señal de habilitación
		MemWrite	:	STD_LOGIC;	--Señal de habilitación
    	end record;

	type ALU_OP_INPUT is
    	record
       		Op0		:	STD_LOGIC;
       		Op1		:	STD_LOGIC;
		Op2		:	STD_LOGIC;
    	end record;
    
	type EX_CTRL_REG is
    	record
       		RegDst		:	STD_LOGIC;	--Señal de habilitación
       		ALUOp		:	ALU_OP_INPUT;
		ALUSrc		:	STD_LOGIC;	--Señal de habilitación
    	end record;
	

	--Registro que auna las entradas de la ALU 

	type ALU_INPUT is
	record
		Op0		:	STD_LOGIC;
		Op1		:	STD_LOGIC;
		Op2		:	STD_LOGIC;
		Op3		:	STD_LOGIC;
	end record;

	--Registro que auna las flags de la ALU 
    	
	type ALU_FLAGS is
    	record
       		Carry		:	STD_LOGIC;
       		Overflow	:	STD_LOGIC;
       		Zero		:	STD_LOGIC;
       		Negative	:	STD_LOGIC;
    	end record;
    	    	

end RECORDS_PKG;
