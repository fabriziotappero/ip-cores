--! @file clock_gen.vhd
--! @brief Test bench clock generator.
--! @author Julian Andres Guarin Reyes.
-- RAYTRAC
-- Author Julian Andres Guarin
-- clockgen.vhd
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
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>.
--! Libreria de definicion de senales y tipos estandares, comportamiento de operadores aritmeticos y logicos.
library ieee;
--! Paquete de definicion estandard de logica. 
use ieee.std_logic_1164.all;
use work.arithpack.all;

entity clock_gen is
	generic	(tclk : time := tclk);
	port	(clk,rst : out std_logic);
end entity clock_gen;

architecture clock_gen_arch of clock_gen is


begin

	--! Processo de reset, se mantendr&acute; en 0 durante 1 ns, seguido por 1 en 52 ns y finalmente en 0 y se deja ah&iacute;.
	resetproc: process
	begin
		rst<= not(rstMasterValue);
		wait for 1 ns;
		rst<= rstMasterValue;
		wait for 52 ns;
		rst<= not(rstMasterValue);
		wait;
	end process resetproc;
	
	--! Proceso de clock, el valor inicial es 1. Inmediatamente baja a 0 y a partir de ah&iacute; con una frecuencia de 50 MHz se genera una se&ntilde;al de clock.	
	clockproc: process
	begin
		
		clk<='1';
		clock_loop:
		loop
			wait for tclk2;
			clk<='0';
			wait for tclk2;
			clk <= '1';
		end loop clock_loop;
	end process clockproc;
	
end clock_gen_arch;
	
	
		


