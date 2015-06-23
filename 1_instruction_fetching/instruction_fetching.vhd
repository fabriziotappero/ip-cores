--
-- Etapa Instruction Fetching (IF) del procesador MIPS Segmentado
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
use work.segm_mips_const_pkg.all;

entity INSTRUCTION_FETCHING is
	port(
		--Entradas
		CLK		: in STD_LOGIC;					-- Reloj
		RESET		: in STD_LOGIC;					-- Reset asincrónico
		PCSrc		: in STD_LOGIC;					-- Señal de habilitación del MUX_PC
		NEW_PC_ADDR_IN	: in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	-- Una de las entradas del MUX_PC
		--Salidas
		NEW_PC_ADDR_OUT	: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	--Nueva instrucción del PC
		INSTRUCTION 	: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)	--La instrucción encontrada en la Memoria de Instrucción
	);
end INSTRUCTION_FETCHING;

architecture INSTRUCTION_FETCHING_ARC of INSTRUCTION_FETCHING is	

--Declaración de componentes

	component ADDER is 
		generic (N:NATURAL := INST_SIZE);-- Tamaño de los valores sumados
		port(
			X	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN	: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component ADDER;

	component REG is 
		generic (N:NATURAL := INST_SIZE); -- N = Tamaño del registro
		port(
			CLK		: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			DATA_IN		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			DATA_OUT	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component REG;

	component IF_ID_REGISTERS is   
		port(
			CLK		: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			NEW_PC_ADDR_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			INST_REG_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			NEW_PC_ADDR_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			INST_REG_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)
		);
	end component IF_ID_REGISTERS;

	component INSTRUCTION_MEMORY is
		port(
			RESET		: in	STD_LOGIC;
  			READ_ADDR	: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
  			INST		: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)
		);
	end component INSTRUCTION_MEMORY;

--Señales
	signal PC_ADDR_AUX1	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Vieja instrucción de PC
	signal PC_ADDR_AUX2	: STD_LOGIC_VECTOR (INST_SIZE downto 0);	--Nueva instrucción de PC + Carry out
	signal PC_ADDR_AUX3	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Salida del MUX_PC  
	signal INST_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Instrucción actual
	
begin

	--Port maps
	
	myADDER :
		ADDER generic map (N => INST_SIZE)
		port map(
			X	=> PC_ADDR_AUX1,
			Y	=> PC_COUNT, --De a cuanto suma el PC (de a 4 bits)
			CIN	=> '0',
			COUT	=> PC_ADDR_AUX2(INST_SIZE),
			R	=> PC_ADDR_AUX2(INST_SIZE-1 downto 0)
		);

	MUX_PC:
		process(PCSrc,PC_ADDR_AUX2,NEW_PC_ADDR_IN)
		begin
			if( PCSrc = '0') then
				PC_ADDR_AUX3 <= PC_ADDR_AUX2(INST_SIZE-1 downto 0); 
			else
				PC_ADDR_AUX3 <= NEW_PC_ADDR_IN;
			end if;
		end process MUX_PC; 

	PC : 
		REG generic map (N => INST_SIZE)
		port map(
			CLK		=> CLK,
			RESET		=> RESET,
			DATA_IN		=> PC_ADDR_AUX3,
			DATA_OUT	=> PC_ADDR_AUX1
		);
	
	INST_MEM:
		INSTRUCTION_MEMORY port map(
			RESET		=>	RESET,
			READ_ADDR	=>	PC_ADDR_AUX1,
			INST		=> 	INST_AUX
		);
		
	IF_ID_REG:
		IF_ID_REGISTERS port map(
			CLK		=> CLK,
			RESET		=> RESET,
			NEW_PC_ADDR_IN	=> PC_ADDR_AUX2(INST_SIZE-1 downto 0),
			INST_REG_IN	=> INST_AUX,
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			INST_REG_OUT	=> INSTRUCTION
		);	

end INSTRUCTION_FETCHING_ARC;
