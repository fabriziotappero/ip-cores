------------------------------------------------
--! @file RLshifter.vhd
--! @brief RayTrac Arithmetic Shifter 
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC
-- Author Julian Andres Guarin
-- RLshifter.vhd
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
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;




entity RLshifter is
	generic (
		shiftFunction	: string  := "SQUARE_ROOT"; 
		mantissa_width	: integer := 18;
		iwidth			: integer := 32;
		owidth			: integer := 16
		
	);
	port (
		exp		: in std_logic_vector (integer(ceil(log(real(iwidth),2.0)))-1 downto 0);
		mantis	: in std_logic_vector (mantissa_width-1 downto 0);
		result	: out std_logic_vector (owidth-1 downto 0)
	);
end RLshifter;


architecture RLshifter_arch of RLshifter is
begin

	inverse:
	process (mantis,exp)
		variable expi : integer ;
	begin
		expi:= conv_integer(exp(exp'high downto 1)); --! Por qu'e hasta 1 y no hasta 0!? Porque el corrimiento de la raiz cuadrada es 2^(N/2)  
		
		for i in owidth-1 downto 0 loop

			result(i)<='0';			

			if shiftFunction="INVERSION" then 			
				if i<=owidth-1-expi and i>=owidth-expi-mantissa_width then
					result(i)<=mantis(mantissa_width-owidth+expi+i);
				end if;
			end if;				

			if shiftFunction="SQUARE_ROOT" then 
				if i<=expi then 
					result(i)<=mantis(mantissa_width-1-expi+i);					
				end if;
			end if;								

		end loop;

	end process inverse;

end RLshifter_arch; 

