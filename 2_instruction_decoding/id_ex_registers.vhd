--
-- Registros de sinctonización entre las etapas ID y EX
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


entity ID_EX_REGISTERS is 
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
		RT_OUT 				: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);-- Datos leidos de la dir. Rt
		--Salidas de la Unidad de Control
		WB_OUT				: out	WB_CTRL_REG;				-- Estas señales se postergarán hasta la etapa WB
		M_OUT				: out	MEM_CTRL_REG;				-- Estas señales se postergarán hasta la etapa MEM
		EX_OUT				: out	EX_CTRL_REG				-- Estas señales se postergarán hasta la etapa EX
	);
end ID_EX_REGISTERS;

architecture ID_EX_REGISTERS_ARC of ID_EX_REGISTERS is
begin
	SYNC_ID_EX:
	  process(CLK,RESET,NEW_PC_ADDR_IN,OFFSET_IN,RT_ADDR_IN,RD_ADDR_IN,RS_IN,RT_IN,WB_IN,M_IN,EX_IN)
	  begin
		if RESET = '1' then
				NEW_PC_ADDR_OUT		<= (others => '0');
				OFFSET_OUT		<= (others => '0');
				RT_ADDR_OUT		<= (others => '0');
				RD_ADDR_OUT		<= (others => '0');
				RS_OUT	 		<= (others => '0');
				RT_OUT 			<= (others => '0');
				WB_OUT			<= ('0','0');
				M_OUT			<= ('0','0','0');
				EX_OUT			<= ('0',('0','0','0'),'0');
		elsif rising_edge(CLK) then
				NEW_PC_ADDR_OUT		<= NEW_PC_ADDR_IN;
				OFFSET_OUT		<= OFFSET_IN;
				RT_ADDR_OUT		<= RT_ADDR_IN;
				RD_ADDR_OUT		<= RD_ADDR_IN;	
				RS_OUT	 		<= RS_IN;
				RT_OUT 			<= RT_IN;
				WB_OUT			<= WB_IN;
				M_OUT			<= M_IN;
				EX_OUT			<= EX_IN;
		end if;
	  end process;

end ID_EX_REGISTERS_ARC;
