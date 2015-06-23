--
-- Memoria de datos del procesador MIPS Segmentado
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

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.segm_mips_const_pkg.all;


entity DATA_MEMORY is
	generic (N :NATURAL; M :NATURAL); -- N = tam. dir. M = tamaño de la memoria
	port(
		RESET		:	in  STD_LOGIC;				--Reset asincrónico
		ADDR		:	in  STD_LOGIC_VECTOR (N-1 downto 0);	--Dirección a ser leida o escrita
		WRITE_DATA	:	in  STD_LOGIC_VECTOR (N-1 downto 0);	--Datos a ser escritos
		MemRead		:	in  STD_LOGIC;				--Señal de habilitación para lectura
		MemWrite	:	in  STD_LOGIC;				--Señal de habilitación para escritura
		READ_DATA	:	out STD_LOGIC_VECTOR (N-1 downto 0)	--Datos leidos
	);
end DATA_MEMORY;


architecture DATA_MEMORY_ARC of DATA_MEMORY is
  
	type MEM_T is array (M-1 downto 0) of STD_LOGIC_VECTOR (N-1 downto 0);
	signal MEM : MEM_T;
  
begin

	MEM_PROC:
		process(RESET,MemWrite,MemRead,WRITE_DATA,MEM,ADDR)
		begin	
			if (RESET = '1') then -- Reset Asincrónico
				for i in 0 to M-1 loop
					MEM(i) <= (others => '1');
				end loop;
			 -- Ejecuto las ordenes de la unidad de control:
			elsif MemWrite='1' then -- O bien escribo en la memoria
				MEM(to_integer(unsigned( ADDR(9 downto 0) ))) <= WRITE_DATA;
			elsif MemRead='1' then -- O bien leo de ella
			    	READ_DATA <= MEM(to_integer(unsigned( ADDR(9 downto 0) )));
			end if;
		end process MEM_PROC;

end DATA_MEMORY_ARC;
