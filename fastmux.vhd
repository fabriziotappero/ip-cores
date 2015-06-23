--! @file fastmux.vhd
--! @brief Multiplexor.
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes.
-- RAYTRAC
-- Author Julian Andres Guarin
-- fastmux.vhd
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

entity fastmux is 
	generic (
		width : integer := 18
	);
	port (
		a,b:in std_logic_vector(width-1 downto 0);
		s:in std_logic;
		c: out std_logic_vector(width-1 downto 0)
	);
end entity;


--! @brief Definicion arquitectura del mux
--! @details El Mux esta descrito de manera estructural, instanciado bit por bit en la salida, multiplexores de un solo bit.
architecture fastmux_arch of fastmux is
begin

	muxgen:
	for i in 0 to width-1 generate
		c(i) <= (a(i) and not(s)) or (b(i) and s);
	end generate muxgen;



end fastmux_arch;