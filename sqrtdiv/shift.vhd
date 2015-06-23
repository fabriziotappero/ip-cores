------------------------------------------------
--! @file shift.vhd
--! @brief RayTrac TestBench
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC
-- Author Julian Andres Guarin
-- shift.vhd
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
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.math_real.all;


--! \brief Dado que cualquier n&uacute;mero entero A, se puede escribir 2^n * f, es importante obtener una representaci&oacute;n del valor de f en base 2. Una vez hallado este valor y evaluado en una funci&oacute;n bastara con realizar un corrimiento a la izquierda n bits del resultado, para calcular funciones como A^-1 o A^0.5.
entity shifter is 
	generic (
		address_width	: integer	:= 9;
		width			: integer	:= 32;
		--! Cuando even shifter es "YES" se hara la busqueda del primer bit con valor 1, de izquierda a derecha, pero NO de uno en uno.
		even_shifter	: string	:= "YES"	
		
	);
	port (
		data			: in std_logic_vector(width - 1 downto 0);
		exp				: out std_logic_vector(integer(ceil(log(real(width),2.0)))-1 downto 0);
		address 		: out std_logic_vector (address_width-1 downto 0);
		zero			: out std_logic
	);	
end shifter;

architecture shifter_arch of shifter is 

begin
	
	sanityLost:
	process (data)
		variable index: integer range-1 to width+address_width-1:=width+address_width-1;
		
	begin
		address<=(others=>'0');
		exp<=(others=>'0');
		
		zero<=data(0);
		
		if even_shifter="YES" then
			index:=width-1;
		else
			index:=width-2;
		end if;
		
		while index>=1 loop
			if data(index)='1' then
				zero<='0';
				exp<=CONV_STD_LOGIC_VECTOR(index, exp'high+1);
				if index>=address_width then
					address <= data (index-1 downto index-address_width);
				else
					address(address_width-1 downto address_width-index) <= data (index-1 downto 0);
					address(address_width-index-1 downto 0) <= (others =>'0');
				end if;
				exit;
			end if;
			index:=index-2; --Boost
		end loop;
		
		
		
		
	end process sanityLost;
	
	
end shifter_arch;





		