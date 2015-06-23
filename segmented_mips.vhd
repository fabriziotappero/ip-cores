--
-- Entidad Segmented MIPS (Top Level) del procesador MIPS Segmentado
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


entity SEGMENTED_MIPS is
	port(
		CLK 	: in STD_LOGIC;
		RESET	: in STD_LOGIC
	);
end SEGMENTED_MIPS;

architecture SEGMENTED_MIPS_ARC of SEGMENTED_MIPS is	

	--Declaración de componentes
		component INSTRUCTION_FETCHING is
		 port(
			--Entradas
			CLK		:	in STD_LOGIC;					-- Reloj
			RESET		:	in STD_LOGIC;					-- Reset asincrónico
			PCSrc		:	in STD_LOGIC;					-- Señal de habilitación del MUX_PC
			NEW_PC_ADDR_IN	:	in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	-- Una de las entradas del MUX_PC
			--Salidas
			NEW_PC_ADDR_OUT	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	--Nueva instrucción del PC
			INSTRUCTION 	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)	--La instrucción encontrada en la Memoria de Instrucción
		 );
		end component INSTRUCTION_FETCHING;
	
		component INSTRUCTION_DECODING is
		port(
			CLK			:	in	STD_LOGIC;				--Reloj
			RESET			:	in	STD_LOGIC;				--Reset asincrónico asincrónico
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
		end component INSTRUCTION_DECODING;
	
		component EXECUTION is
		port( 
			--Entradas
     			CLK			:	in STD_LOGIC;					--Reloj
			RESET			:	in STD_LOGIC;					--Reset asincrónico
     			WB_CR			:	in WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
			MEM_CR			:	in MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
			EX_CR			:	in EX_CTRL_REG;					--Estas señales se usarán en esta etapa 	     	
			NEW_PC_ADDR_IN		:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Nueva dirección del PC
			RS	 		:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Datos leidos de la dir. Rs
		    	RT 			:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Datos leidos de la dir. Rt
			OFFSET			:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Offset de la instrucción  [15-0]
			RT_ADDR			:	in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--Dirección del registro RT [20-16]
			RD_ADDR			:	in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--Dirección del registro RD [15-11]			 				
					     	      
			--Salidas
			WB_CR_OUT		:	out WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
			MEM_CR_OUT		:	out MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
			NEW_PC_ADDR_OUT		:	out STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Nueva dirección del PC
			ALU_FLAGS_OUT		:	out ALU_FLAGS;					--Las flags de la ALU
			ALU_RES_OUT		:	out STD_LOGIC_vector(INST_SIZE-1 downto 0);	--El resultado generado por la ALU
			RT_OUT			:	out STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
			RT_RD_ADDR_OUT		:	out STD_LOGIC_vector (ADDR_SIZE-1 downto 0)	--Se postergará hasta la etapa WB
					
		);
		end component EXECUTION;
		
		component MEMORY_ACCESS is
		port( 
				--Entradas
				CLK			: in STD_LOGIC;
				RESET			: in STD_LOGIC;					--Reset asincrónico
				WB_IN			: in WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
				MEM			: in MEM_CTRL_REG;				--Estas señales serán usadas en esta etapa
				FLAG_ZERO		: in STD_LOGIC;					--Flag Zero de la ALU
				NEW_PC_ADDR		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Nueva dirección de pc hacia la etapa de IF
				ADDRESS_IN		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Salida de la ALU (ALU Result), dirección de la memoria de datos
				WRITE_DATA		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Datos a ser escritos en la memoria de datos
				WRITE_REG_IN		: in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--WriteRegister de los registros de la etapa de ID
				--Salidas hacia la etapa WB, sincronizadas por registros
				WB_OUT			: out WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
				READ_DATA		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Datos leidos de la memoria de datos
				ADDRESS_OUT		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Resultado de la ALU
				WRITE_REG_OUT		: out STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--WriteRegister de los registros de la etapa de ID
				--Salidas hacia la etapas IF, sin sincronización
				NEW_PC_ADDR_OUT		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Nueva dirección de pc hacia la etapa de IF
				PCSrc			: out STD_LOGIC					--Señal de habilitación del mux de la etapa de IF
			);
		end component MEMORY_ACCESS;
	
		component WRITE_BACK is
		port( 
				--Entradas
				RESET			: in STD_LOGIC;					--Reset asincrónico
				WB			: in WB_CTRL_REG;				--Señalesde control para esta etapa
				READ_DATA		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
				ADDRESS			: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
				WRITE_REG		: in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros		
				--Salidas hacia la etapas ID, sin sincronización
				RegWrite		: out STD_LOGIC;				--WB_OUT.RegWrite
				WRITE_REG_OUT		: out STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros
				WRITE_DATA		: out STD_LOGIC_vector (INST_SIZE-1 downto 0)	--Este dato representa a READ_DATA o a ADDRESS, según lo decida WB_OUT.MemtoReg
		);
		end component WRITE_BACK;
	
	--Declaración de señales
	
		-- Buses de datos, representan los datos que se pasan entre las etapas
		
		-- MEM/IF
		signal PCSrc_AUX		: STD_LOGIC;
		signal NEW_PC_ADDR_AUX4		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- IF/ID
		signal NEW_PC_ADDR_AUX1		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal INSTRUCTION_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- WB/ID
		signal RegWrite_AUX		: STD_LOGIC;
		signal WRITE_REG_AUX2		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal WRITE_DATA_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- ID/EX
		signal NEW_PC_ADDR_AUX2		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal OFFSET_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_ADDR_AUX		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal RD_ADDR_AUX 		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal RS_AUX	 		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_AUX1 			: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal WB_CR_AUX1		: WB_CTRL_REG;
		signal MEM_CR_AUX1		: MEM_CTRL_REG;
		signal EX_CR_AUX		: EX_CTRL_REG;
		-- EX/MEM
		signal WB_CR_AUX2		: WB_CTRL_REG;
		signal MEM_CR_AUX2		: MEM_CTRL_REG;
		signal NEW_PC_ADDR_AUX3		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal ALU_FLAGS_AUX		: ALU_FLAGS;
		signal ALU_RES_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_AUX2			: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_RD_ADDR_AUX		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		--MEM/WB
		signal WB_CR_AUX3		: WB_CTRL_REG;
		signal READ_DATA_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal ADDRESS_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal WRITE_REG_AUX1		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	
	 
begin

	--Port maps
			
	INST_FETCH:
		INSTRUCTION_FETCHING port map(
			--Entradas
			CLK		=> CLK,
			RESET		=> RESET,
			PCSrc		=> PCSrc_AUX,
			NEW_PC_ADDR_IN	=> NEW_PC_ADDR_AUX4,
			--Salidas
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_AUX1,
			INSTRUCTION	=> INSTRUCTION_AUX
		);	

	INST_DECOD:
		INSTRUCTION_DECODING port map(
			--Entradas
			CLK		=> CLK,
			RESET		=> RESET,
			INSTRUCTION	=> INSTRUCTION_AUX,
			NEW_PC_ADDR_IN	=> NEW_PC_ADDR_AUX1,
			RegWrite	=> RegWrite_AUX,  
			WRITE_DATA	=> WRITE_DATA_AUX, 
			WRITE_REG 	=> WRITE_REG_AUX2,
			--Salidas
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_AUX2,
			OFFSET		=> OFFSET_AUX,
			RT_ADDR		=> RT_ADDR_AUX,
			RD_ADDR		=> RD_ADDR_AUX,
			RS 		=> RS_AUX,
			RT 		=> RT_AUX1,
			WB_CR		=> WB_CR_AUX1,
			MEM_CR		=> MEM_CR_AUX1,
			EX_CR		=> EX_CR_AUX
		);

	EXE:
		EXECUTION port map( 
			--Entradas
			CLK			=> CLK,
			RESET			=> RESET,
			WB_CR			=> WB_CR_AUX1,
			MEM_CR			=> MEM_CR_AUX1,
			EX_CR			=> EX_CR_AUX, 	     	
			NEW_PC_ADDR_IN		=> NEW_PC_ADDR_AUX2,
			RS	 		=> RS_AUX,
		    	RT 			=> RT_AUX1,
			OFFSET			=> OFFSET_AUX,
			RT_ADDR			=> RT_ADDR_AUX,
			RD_ADDR			=> RD_ADDR_AUX,			 				
			--Salidas
			WB_CR_OUT		=> WB_CR_AUX2,
			MEM_CR_OUT		=> MEM_CR_AUX2,
			NEW_PC_ADDR_OUT		=> NEW_PC_ADDR_AUX3,
			ALU_FLAGS_OUT		=> ALU_FLAGS_AUX,
			ALU_RES_OUT		=> ALU_RES_AUX,
			RT_OUT			=> RT_AUX2,
			RT_RD_ADDR_OUT		=> RT_RD_ADDR_AUX
		);

	MEM_ACC:
		MEMORY_ACCESS port map( 
			--Entradas
			CLK			=> CLK,
			RESET			=> RESET,
			WB_IN			=> WB_CR_AUX2,
			MEM			=> MEM_CR_AUX2,
			FLAG_ZERO		=> ALU_FLAGS_AUX.Zero,
			NEW_PC_ADDR		=> NEW_PC_ADDR_AUX3,
			ADDRESS_IN		=> ALU_RES_AUX,
			WRITE_DATA		=> RT_AUX2,
			WRITE_REG_IN		=> RT_RD_ADDR_AUX,
			--Salidas hacia la etapa WB, sincronizadas por registros
			WB_OUT			=> WB_CR_AUX3,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS_OUT		=> ADDRESS_AUX,
			WRITE_REG_OUT		=> WRITE_REG_AUX1,
			--Salidas hacia la etapas IF, sin sincronización
			NEW_PC_ADDR_OUT		=> NEW_PC_ADDR_AUX4,
			PCSrc			=> PCSrc_AUX	
		);

	WR_BK:
		WRITE_BACK port map( 
			--Entradas			
			RESET			=> RESET,
			WB			=> WB_CR_AUX3,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS			=> ADDRESS_AUX,
			WRITE_REG		=> WRITE_REG_AUX1,
			--Salidas hacia la etapas ID, sin sincronización
			RegWrite		=> RegWrite_AUX,
			WRITE_REG_OUT		=> WRITE_REG_AUX2,
			WRITE_DATA		=> WRITE_DATA_AUX
		);


end SEGMENTED_MIPS_ARC;			
