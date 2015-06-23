------------------------------------------------
--! @file shifter2xstage.vhd
--! @brief RayTrac Arithmetic Shifter 
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC
-- Author Julian Andres Guarin
-- shifter2xstage.vhd
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
use ieee.math_real.all;
use work.arithpack.all;

entity shifter2xstage is 
	generic (
		address_width	: integer := 9;
		width			: integer := 32
	);
	port (
		data	: in std_logic_vector (width-1 downto 0);
		exp		: out std_logic_vector (2*integer(ceil(log(real(width),2.0)))-1 downto 0);
		add		: out std_logic_vector (2*address_width-1 downto 0);
		zero	: out std_logic
	);
end shifter2xstage;

architecture shifter2xstage_arch of shifter2xstage is 

	signal exp0	: std_logic_vector (integer(ceil(log(real(width),2.0)))-1 downto 0);
	signal exp1	: std_logic_vector (integer(ceil(log(real(width),2.0)))-1 downto 0);
	signal add0	: std_logic_vector (address_width-1 downto 0);
	signal add1	: std_logic_vector (address_width-1 downto 0);
	signal szero: std_logic_vector (1 downto 0);
	
	function exp0StringParam return string is
	begin
		if width rem 2 = 0 then 
			return "NO";
		else
			return "YES";
		end if; 
	end exp0StringParam;
	function exp1StringParam return string is
	begin
		if width rem 2 = 0 then 
			return "YES";
		else
			return "NO";
		end if; 
	end exp1StringParam;
	
	

begin
	zero <= szero(1) and szero(0);
	evenS:shifter
	generic map (address_width,width,exp0StringParam)
	port map (data,exp0,add0,szero(0));
	oddS:shifter
	generic map (address_width,width,exp1StringParam)
	port map (data,exp1,add1,szero(1));
	exp(integer(ceil(log(real(width),2.0)))-1 downto 0)<=exp0;
	exp(2*integer(ceil(log(real(width),2.0)))-1 downto integer(ceil(log(real(width),2.0))))<=exp1;
	add(address_width-1 downto 0)<=add0;
	add(2*address_width-1 downto address_width)<=add1;
end shifter2xstage_arch;
	