--
-- Banco de registros del procesador MIPS Segmentado
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


entity REGISTERS is 
    port(
		--Entradas
	        CLK 		: in	STD_LOGIC;				--Reloj
		RESET		: in	STD_LOGIC;				--Reset asincrónico
	        RW		: in	STD_LOGIC;				--Señal de habilitación de escritura (RegWrite)	
	        RS_ADDR 	: in  	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rs
	        RT_ADDR 	: in  	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rt
	        RD_ADDR 	: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--Dirección del registro Rd
	        WRITE_DATA	: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos a ser escritos
		--Salidas
	        RS 		: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Datos leidos de la dir. Rs
	        RT 		: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)	--Datos leidos de la dir. Rt
        );
end REGISTERS;

architecture REGISTERS_ARC of REGISTERS is
  
  -- Tipo para almacenar los registros
  type REGS_T is array (NUM_REG-1 downto 0) of STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);

  -- Esta es la señal que contiene los registros. El acceso es de la
  -- siguiente manera: regs(i) acceso al registro i, donde i es
  -- un entero. Para convertir del tipo STD_LOGIC_VECTOR a entero se
  -- hace de la siguiente manera: to_integer(unsigned(slv)), donde
  -- slv es un elemento de tipo STD_LOGIC_VECTOR
  signal REGISTROS 	: REGS_T;
  
begin

  REG_ASIG:
	  process(CLK,RESET,RW,WRITE_DATA,RD_ADDR)
	  begin
		if  RESET='1' then
				for i in 0 to NUM_REG-1 loop
					REGISTROS(i) <= (others => '0');
				end loop;
				--Los resgitros son completados de esta manera para 
				--la prueba del algoritmo "Restoring", ya que no se
				--ha implementado la instrucción LLI
				REGISTROS(0) <= "00000000000000000000000000000000";
				REGISTROS(1) <= "00000000000000000000000000000001";
				REGISTROS(2) <= "00000000000000000000000000000010";
				REGISTROS(3) <= "00000000000000000000000000000011";
				REGISTROS(4) <= "00000000000000000000000000000100";
				--REGISTROS(5) <= "00000000000000000000000000000101";
				REGISTROS(5) <= "00000000000000000000000000000001";
				--REGISTROS(6) <= "00000000000000000000000000000110";
				REGISTROS(6) <= "00000000000000000000000000000000";
				--REGISTROS(7) <= "00000000000000000000000000000111";
				REGISTROS(7) <= "00000000000000000000000000100000";
				--REGISTROS(8) <= "00000000000000000000000000001000";
				REGISTROS(8) <= "00000000000000000000000000000000";
				REGISTROS(9) <= "00000000000000000000000000001001";
				--REGISTROS(10) <= "00000000000000000000000000001010";
				REGISTROS(10) <= "00000000000000000000000000010011";
				--REGISTROS(11) <= "00000000000000000000000000001011";
				REGISTROS(11) <= "00000000000000000000000000011010";
				--REGISTROS(12) <= "00000000000000000000000000001100";
				REGISTROS(12) <= "00000000000000000000000000000000";
				REGISTROS(13) <= "00000000000000000000000000001101";
				REGISTROS(14) <= "00000000000000000000000000001110";
				REGISTROS(15) <= "00000000000000000000000000001111";
				REGISTROS(16) <= "00000000000000000000000000010000";
				REGISTROS(17) <= "00000000000000000000000000010001";
				REGISTROS(18) <= "00000000000000000000000000010010";
				REGISTROS(19) <= "00000000000000000000000000010011";
				REGISTROS(20) <= "00000000000000000000000000010100";
				REGISTROS(21) <= "00000000000000000000000000010101";
				REGISTROS(22) <= "00000000000000000000000000010110";
				REGISTROS(23) <= "00000000000000000000000000010111";
				REGISTROS(24) <= "00000000000000000000000000011000";
				REGISTROS(25) <= "00000000000000000000000000011001";
				REGISTROS(26) <= "00000000000000000000000000011010";
				REGISTROS(27) <= "00000000000000000000000000011011";
				REGISTROS(28) <= "00000000000000000000000000011100";
				REGISTROS(29) <= "00000000000000000000000000011101";
				REGISTROS(30) <= "00000000000000000000000000011110";
				REGISTROS(31) <= "00000000000000000000000000011111";
		elsif rising_edge(CLK) then
			if  RW='1' then
				REGISTROS(to_integer(unsigned(RD_ADDR)))<=WRITE_DATA;
			end if;
		end if;
	  end process  REG_ASIG;

  RS <= (others=>'0') when RS_ADDR="00000"
         else REGISTROS(to_integer(unsigned(RS_ADDR)));
  RT <= (others=>'0') when RT_ADDR="00000"
         else REGISTROS(to_integer(unsigned(RT_ADDR)));

end REGISTERS_ARC;
