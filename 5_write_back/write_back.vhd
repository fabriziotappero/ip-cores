--
-- Etapa Write back (WB) del procesador MIPS Segmentado
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

entity WRITE_BACK is
port( 
	--Entradas
	RESET			: in STD_LOGIC;					--Reset
	WB			: in WB_CTRL_REG;				--Señales de control para esta etapa
	READ_DATA		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
	ADDRESS			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
	WRITE_REG		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros		
	--Salidas hacia la etapas ID, sin sincronización
	RegWrite		: out STD_LOGIC;				--WB_OUT.RegWrite
	WRITE_REG_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros
	WRITE_DATA		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)	--Este dato representa a READ_DATA o a ADDRESS, según lo decida WB_OUT.MemtoReg
);
end WRITE_BACK;

architecture WRITE_BACK_ARC of WRITE_BACK is 
begin

	MUX_WB: 
		process(RESET,WB.RegWrite,WRITE_REG,WB.MemtoReg,ADDRESS,READ_DATA)
		begin
			if( RESET = '1') then
				RegWrite <= '0';
				WRITE_REG_OUT <= "00000"; 
				WRITE_DATA <= ZERO32b; 
			else
				RegWrite <= WB.RegWrite;
				WRITE_REG_OUT <= WRITE_REG;
			 	if( WB.MemtoReg = '0') then
			 		WRITE_DATA <= ADDRESS; 
			 	else
			 		WRITE_DATA <= READ_DATA;
			 	end if;
			end if;
		 end process MUX_WB;
		 
end WRITE_BACK_ARC;
