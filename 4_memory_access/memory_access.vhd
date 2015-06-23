--
-- Etapa Memory Access (MEM) del procesador MIPS Segmentado
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

entity MEMORY_ACCESS is
	port( 
		--Entradas
		CLK			: in STD_LOGIC;					--Reloj
		RESET			: in STD_LOGIC;					--Reset asincrónico
		WB_IN			: in WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
		MEM			: in MEM_CTRL_REG;				--Estas señales serán usadas en esta etapa
		FLAG_ZERO		: in STD_LOGIC;					--Flag Zero de la ALU
		NEW_PC_ADDR		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección de pc hacia la etapa de IF
		ADDRESS_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Salida de la ALU (ALU Result), dirección de la memoria de datos
		WRITE_DATA		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Datos a ser escritos en la memoria de datos
		WRITE_REG_IN		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--WriteRegister de los registros de la etapa de ID
		--Salidas hacia la etapa WB, sincronizadas por registros
		WB_OUT			: out WB_CTRL_REG;				--Estas señales se postergarán hasta la etapa WB
		READ_DATA		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Datos leidos de la memoria de datos
		ADDRESS_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Resultado de la ALU
		WRITE_REG_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--WriteRegister de los registros de la etapa de ID
		--Salidas hacia la etapas IF, sin sincronización
		NEW_PC_ADDR_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección de pc hacia la etapa de IF
		PCSrc			: out STD_LOGIC					--Señal de habilitación del mux de la etapa de IF
	);
end MEMORY_ACCESS;

architecture MEMORY_ACCESS_ARC of MEMORY_ACCESS is

-- Declaración de componentes
	
	component DATA_MEMORY is
		generic (N :NATURAL :=INST_SIZE; M :NATURAL :=NUM_ADDR); -- N = tam. dir. ; M = tamaño de la memoria
		port(
			RESET		:	in  STD_LOGIC;				--Reset asincrónico
			ADDR		:	in  STD_LOGIC_VECTOR (N-1 downto 0);	--Dirección a ser leida o escrita
			WRITE_DATA	:	in  STD_LOGIC_VECTOR (N-1 downto 0);	--Datos a ser escritos
			MemRead		:	in  STD_LOGIC;				--Señal de hailitación para lectura
			MemWrite	:	in  STD_LOGIC;				--Señal de hailitación para escritura
			READ_DATA	:	out STD_LOGIC_VECTOR (N-1 downto 0)	--Datos leidos

		);
	end component DATA_MEMORY;

	component MEM_WB_REGISTERS is
	 	port(
			--Entradas
			CLK		: in STD_LOGIC;
			RESET		: in STD_LOGIC;
			WB		: in WB_CTRL_REG;
			READ_DATA	: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			ADDRESS		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			WRITE_REG	: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
			--Salidas
			WB_OUT		: out WB_CTRL_REG;
			READ_DATA_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			ADDRESS_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			WRITE_REG_OUT	: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)
		);
	end component MEM_WB_REGISTERS;
	 
	 
--Declaración de señales
	signal READ_DATA_AUX : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
 
begin

	OUT_MEM:	
		process(RESET,FLAG_ZERO,MEM.Branch,NEW_PC_ADDR)
		begin
			if( RESET = '1') then
				PCSrc <= '0';
				NEW_PC_ADDR_OUT <= ZERO32b;
			else
				PCSrc <= FLAG_ZERO and MEM.Branch;
				NEW_PC_ADDR_OUT <= NEW_PC_ADDR;
			end if;
		end process OUT_MEM;

	DAT_MEM:
		DATA_MEMORY generic map (N=>INST_SIZE, M=>NUM_ADDR)
	 	port map(
			RESET		=> RESET,
			ADDR		=> ADDRESS_IN,
			WRITE_DATA	=> WRITE_DATA,
			MemRead		=> MEM.MemRead,
			MemWrite	=> MEM.MemWrite,
			READ_DATA	=> READ_DATA_AUX

		);
	
	MEM_WB_REGS:
		MEM_WB_REGISTERS port map(
			--Entradas
			CLK			=> CLK,
			RESET			=> RESET,
			WB			=> WB_IN,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS			=> ADDRESS_IN,
			WRITE_REG		=> WRITE_REG_IN,
			--Salidas
			WB_OUT			=> WB_OUT,
			READ_DATA_OUT		=> READ_DATA,
			ADDRESS_OUT		=> ADDRESS_OUT,	
			WRITE_REG_OUT		=> WRITE_REG_OUT 
		);


end MEMORY_ACCESS_ARC;
