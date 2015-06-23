--! @file rca_logic_block.vhd
--! @author Julian Andres Guarin
--! @brief Bloque de l&oacute;gica Carry Look Ahead. 
-- rca_logic_block.vhd
-- This file is part of raytrac.
-- 
--     raytrac is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
-- 
--     raytrac is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>.library ieee;

-- Check out arithpack.vhd to understand in general terms what this file describes,
-- or checkout this file to check in detailed way what this file intends to.
--! Libreria de definicion de senales y tipos estandares, comportamiento de operadores aritmeticos y logicos.\n Signal and types definition library. This library also defines 
library ieee;
--! Paquete de definicion estandard de logica. Standard logic definition pack.
use ieee.std_logic_1164.all;


--! Entidad generadora del Bloque de Ripple Carry Adder. 

--! En una suma A+B para cada par de bits Ai, Bi, se genera un carry out Couti, este Couti en un bloque generador de carry Ripple Carry, depende del cálculo de los Carry Out anteriores, Couti-1, Couti-2,...., Cout0. Lo que hace el Ripple Carry Adder Logic Block, es calcular secuencialmente los valores de todos los Couti, usando las señales de propagación y generación, Pi y Gi, y los Carry Out anteriores. Comparado con el Carry Look Ahead, empleará el doble del tiempo, pero usará muchas menos elementos lógicos en una FPGA o muchos menos transistores en un procesos de fabricación CMOS. En síntesis se sacrifica desempeño por ahorro de recursos. 

entity rca_logic_block is
	generic (
		width : integer := 8 --! Tama&ntilde;o estandar del bloque Ripple Carry Adder.
	);
	port (
		p,g: in std_logic_vector(width-1 downto 0); --! Se&ntilde;ales de Propagacin y Generaci&oacute;n del carry.
		cin : in std_logic;						--! Señ\&ntilde;al de entrada Carry In.
		
		c : out std_logic_vector(width downto 1)	--! Se&ntilde;ales Carry Out Calculadas. 
	);
end rca_logic_block;


--! Arquitectura del bloque Ripple Carry Adder.

--! El bloque de logica de Ripple Carry Adder, se sintetiza a partir de un c&oacute;digo comportamental.
--! Para cada Couti, se instancia una funci&oacute;n combinatoria. 


architecture rca_logic_block_arch of rca_logic_block is

	

begin
	--! El siguiente proceso instancia funciones combinatorias para CADA UNO de los valores de Couti a calcular. En TODO momemnto se utiliza el resultado de los Cout antrerioes a Couti, optimizando en uso de recursos. 

	--! La razon principal para realizar la instanciación de las funciones combinatorias necesarias con un process en vez de un generate, radica en utilizar un conjunto de variables que afecte unicamente al proceso comportamental descrito y no a la arquitectura entera. 
	
	rcaProc:		-- rcaProc instancia funciones combinatorias en sCarry(i) haciendo uso de los resultados intermedios obtenidos
				-- en sCarry(i-1), por lo que se crea un delay path en el calculo del Cout del circuito
	process (p,g,cin)
		variable i:			integer range 0 to 2*width;
		variable sCarry:	std_logic_vector(width downto 1);
	begin
		
		sCarry(width downto 1) := g(width-1 downto 0);
		sCarry(1) := sCarry(1) or (p(0) and cin);
		 
		for i in 1 to width-1 loop
			sCarry(i+1) := sCarry(i+1) or (p(i) and sCarry(i));
		end loop;

		c <= sCarry;  
		

	end process rcaProc;
end rca_logic_block_arch;
