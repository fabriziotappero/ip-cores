--
-- Registros de sincronización entre las etapas EX y MEM del procesador MIPS Segmentado
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

entity EX_MEM_REGISTERS is 
    port(
		--Entradas
		CLK		:	in STD_LOGIC;					--Reloj
		RESET		:	in STD_LOGIC;					--Reset asincrónico
		WB_CR_IN	:	in WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
		MEM_CR_IN	:	in MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
		NEW_PC_ADDR_IN	:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
		ALU_FLAGS_IN	:	in ALU_FLAGS;					--Las flags de la ALU
		ALU_RES_IN	:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--El resultado generado por la ALU
		RT_IN		:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
		RT_RD_ADDR_IN	:	in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Se postergará hasta la etapa WB)	
		 						     	      
		--Salidas
		WB_CR_OUT	:	out WB_CTRL_REG; 				--Estas señales se postergarán hasta la etapa WB
		MEM_CR_OUT	:	out MEM_CTRL_REG;				--Estas señales se postergarán hasta la etapa MEM
		NEW_PC_ADDR_OUT	:	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Nueva dirección del PC
		ALU_FLAGS_OUT	:	out ALU_FLAGS;					--Las flags de la ALU
		ALU_RES_OUT	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	--El resultado generado por la ALU
		RT_OUT		:	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Entrará como Write Data en la etapa MEM
		RT_RD_ADDR_OUT	:	out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)	--Se postergará hasta la etapa WB)	
	        
        );
end EX_MEM_REGISTERS;

architecture EX_MEM_REGISTERS_ARC of EX_MEM_REGISTERS is        
begin 

	SYNC_EX_MEM:
	  process(CLK,RESET,WB_CR_IN,MEM_CR_IN,NEW_PC_ADDR_IN,ALU_FLAGS_IN,ALU_RES_IN,RT_IN,RT_RD_ADDR_IN)
	  begin
		if RESET = '1' then
	    		WB_CR_OUT	<= ('0','0');
			MEM_CR_OUT	<= ('0','0','0');
			NEW_PC_ADDR_OUT	<= ZERO32b;
			ALU_FLAGS_OUT	<= ('0','0','0','0');
			ALU_RES_OUT	<= ZERO32b;
			RT_OUT		<= ZERO32b;
			RT_RD_ADDR_OUT	<= "00000";
		elsif rising_edge(CLK) then
	    		WB_CR_OUT	<= WB_CR_IN;
			MEM_CR_OUT	<= MEM_CR_IN;
			NEW_PC_ADDR_OUT	<= NEW_PC_ADDR_IN;
			ALU_FLAGS_OUT	<= ALU_FLAGS_IN;
			ALU_RES_OUT	<= ALU_RES_IN;
			RT_OUT		<= RT_IN;
			RT_RD_ADDR_OUT	<= RT_RD_ADDR_IN;
		end if;
	  end process; 

end EX_MEM_REGISTERS_ARC;
