--
-- Etapa Instruction Decoding (ID) del procesador MIPS Segmentado
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
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity INSTRUCTION_DECODING is
	port(
			CLK			:	in	STD_LOGIC;				--Reloj
			RESET			:	in	STD_LOGIC;				--Reset asincrónico
			--Entradas de la etapa de Búsqueda de la Instrucción (IF)
			INSTRUCTION		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Instrucción
			NEW_PC_ADDR_IN		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Nueva dirección del PC
			--Entradas de la etapa de Post Escritura (WB)	  
			RegWrite		:	in	STD_LOGIC;				--Señal de habilitación de escritura (RegWrite)		 
			WRITE_DATA		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos a ser escritos
			WRITE_REG 		:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rd
			--Salidas de la etapa de Búsqueda de la Instrucción (IF)
			NEW_PC_ADDR_OUT		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Nueva dirección del PC
			--Salidas generadas a partir de la instrucción
			OFFSET			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Offset de la instrucción  [15-0]
			RT_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro RT [20-16]
			RD_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro RD [15-11]
			--Salidas del Banco de Registros
			RS	 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos leidos de la dir. Rs
			RT 			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos leidos de la dir. Rt
			--Salidas de la Unidad de Control
			WB_CR			:	out	WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
			MEM_CR			:	out	MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
			EX_CR			:	out	EX_CTRL_REG				--Estas señales se postergarán hasta la etapa EX     
	);
end INSTRUCTION_DECODING;

architecture INSTRUCTION_DECODING_ARC of INSTRUCTION_DECODING is	

--Declaración de componentes

	component REGISTERS is 
	port(
		CLK 		:	in	STD_LOGIC;				--Reloj
		RESET		:	in	STD_LOGIC;				--Reset asincrónico
		RW		:	in	STD_LOGIC;				--Señal de habilitación de escritura (RegWrite)	
		RS_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rs
		RT_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rt
		RD_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rd
		WRITE_DATA	:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos a ser escritos
		RS 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos leidos de la dir. Rs
		RT 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)	--Datos leidos de la dir. Rt    
	);
	end component REGISTERS;


	component CONTROL_UNIT is
	port( 
		OP			:	in	STD_LOGIC_VECTOR (5 downto 0); 		--Código de operación
		RegWrite		:	out	STD_LOGIC; 				--Señal de habilitación de escritura (RegWrite)
		MemtoReg		:	out	STD_LOGIC;  				--Señal de habilitación  (MemToReg)
		Brach			:	out	STD_LOGIC; 				--Señal de habilitación  (Branch)
		MemRead			:	out	STD_LOGIC; 				--Señal de habilitación  (MemRead)
		MemWrite		:	out	STD_LOGIC; 				--Señal de habilitación  (MemWrite)
		RegDst			:	out	STD_LOGIC; 				--Señal de habilitación  (RegDst)
		ALUSrc			:	out	STD_LOGIC;				--Señal de habilitación  (ALUSrc)
	  	ALUOp0			:	out	STD_LOGIC; 				--Señal de habilitación  (ALUOp)
		ALUOp1			:	out	STD_LOGIC; 				--Señal de habilitación  (ALUOp)
		ALUOp2			:	out	STD_LOGIC 				--Señal de habilitación  (ALUOp2)
	);
	end component CONTROL_UNIT;


	component ID_EX_REGISTERS is     
	port(
		--Entradas

		CLK				: in	STD_LOGIC;				-- Reloj
		RESET				: in	STD_LOGIC;				-- Reset asincrónico
      		--Salidas de la etapa de Búsqueda de la Instrucción (IF)
		NEW_PC_ADDR_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Nueva dirección del PC
		--Salidas generadas a partir de la instrucción
		OFFSET_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Offset de la instrucción  [15-0]
		RT_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);-- Dirección del registro RT [20-16]
		RD_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);-- Dirección del registro RD [15-11]
		--Salidas del Banco de Registros
		RS_IN	 			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Datos leidos de la dir. Rs
		RT_IN 				: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Datos leidos de la dir. Rt
		--Salidas de la Unidad de Control
		WB_IN				: in	WB_CTRL_REG;				-- Señales de control para la etapa WB
		M_IN				: in	MEM_CTRL_REG;				-- Señales de control para la etapa MEM
		EX_IN				: in	EX_CTRL_REG;				-- Señales de control para la etapa EX
      
		--Salidas
	
		--Salidas de la etapa de Búsqueda de la Instrucción (IF)
		NEW_PC_ADDR_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Nueva dirección del PC
		--Salidas generadas a partir de la instrucción
		OFFSET_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Offset de la instrucción  [15-0]
		RT_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);-- Dirección del registro RT [20-16]
		RD_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);-- Dirección del registro RD [15-11]
		--Salidas del Banco de Registros
		RS_OUT	 			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Datos leidos de la dir. Rs
		RT_OUT				: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Datos leidos de la dir. Rt
		--Salidas de la Unidad de Control
		WB_OUT				: out	WB_CTRL_REG;				-- Estas señales se postergarán hasta la etapa WB
		M_OUT				: out	MEM_CTRL_REG;				-- Estas señales se postergarán hasta la etapa MEM
		EX_OUT				: out	EX_CTRL_REG				-- Estas señales se postergarán hasta la etapa EX
	);
	end component ID_EX_REGISTERS;

--Declaración de señales

	-- Buses de datos auxiliares para comunicar las distintas salidas
	-- que los componentes generan y dárselas a los registros de 
	-- sincronización de etapas.
	signal OFFSET_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal RS_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal RT_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal WB_AUX		: WB_CTRL_REG;
	signal MEM_AUX		: MEM_CTRL_REG;
	signal EX_AUX		: EX_CTRL_REG;

--Alias
	-- Se encuentran comentados debido a que GHDL no soporta su uso.

	--alias OP_A		: STD_LOGIC_VECTOR (5 downto 0) is INSTRUCTION(INST_SIZE-1 downto 26);
	--alias RS_ADDR_A	: STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0) is INSTRUCTION(25 downto 21);
	--alias RT_ADDR_A	: STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0) is INSTRUCTION(20 downto 16);
	--alias RD_ADDR_A	: STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0) is INSTRUCTION(15 downto 11);
	--alias OFFSET_A	: STD_LOGIC_VECTOR (15 downto 0) is INSTRUCTION(15 downto 0);
		
begin

	--Port maps
	REGS: 
		REGISTERS port map(
			CLK 		=> CLK,
			RESET		=> RESET,
			RW		=> RegWrite,
			RS_ADDR 	=> INSTRUCTION(25 downto 21),--RS_ADDR_A,
			RT_ADDR 	=> INSTRUCTION(20 downto 16),--RT_ADDR_A,
			RD_ADDR 	=> WRITE_REG,
			WRITE_DATA	=> WRITE_DATA,
			RS 		=> RS_AUX,
			RT 		=> RT_AUX
		);
        
	CTRL : 
		CONTROL_UNIT port map(
			--Entrada 	
			OP		=> INSTRUCTION(INST_SIZE-1 downto 26),--OP_A,
			--Salidas
			RegWrite	=> WB_AUX.RegWrite,
			MemtoReg	=> WB_AUX.MemtoReg,
			Brach		=> MEM_AUX.Branch,
			MemRead		=> MEM_AUX.MemRead,
			MemWrite	=> MEM_AUX.MemWrite,
			RegDst		=> EX_AUX.RegDst,
			ALUSrc		=> EX_AUX.ALUSrc,
		  	ALUOp0		=> EX_AUX.ALUOp.Op0,
			ALUOp1		=> EX_AUX.ALUOp.Op1,
			ALUOp2		=> EX_AUX.ALUOp.Op2
		);
	
	--Se hace una extensión de signo
	--OFFSET_AUX	<= ZERO16b & OFFSET_A
	--			when OFFSET_A(15) = '0'
	--				else ONE16b & OFFSET_A;


	OFFSET_AUX	<=  ZERO16b & INSTRUCTION(15 downto 0)
				when INSTRUCTION(15) = '0'
					else  ONE16b & INSTRUCTION(15 downto 0);


	ID_EX_REGS:
		ID_EX_REGISTERS port map(
			--Entradas
			CLK			=> CLK,
			RESET			=> RESET,
			NEW_PC_ADDR_IN		=> NEW_PC_ADDR_IN,
			OFFSET_IN		=> OFFSET_AUX,
			RT_ADDR_IN		=> INSTRUCTION(20 downto 16),--RT_ADDR_A,
			RD_ADDR_IN		=> INSTRUCTION(15 downto 11),--RD_ADDR_A,
			RS_IN			=> RS_AUX,
			RT_IN			=> RT_AUX,
			WB_IN			=> WB_AUX,
			M_IN			=> MEM_AUX,
			EX_IN			=> EX_AUX,
			--Salidas
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			OFFSET_OUT	=> OFFSET,
			RT_ADDR_OUT	=> RT_ADDR,
			RD_ADDR_OUT	=> RD_ADDR,
			RS_OUT		=> RS,
			RT_OUT		=> RT,
			WB_OUT		=> WB_CR,
			M_OUT		=> MEM_CR,
			EX_OUT		=> EX_CR
		);	

end INSTRUCTION_DECODING_ARC;
