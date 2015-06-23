----------
--! @file
--! @brief This is the supporting package. \b "JUST EDIT THIS FILE"
----------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package fir_pkg is

	type int_vector is array (natural range <>) of integer;
	
	constant coeff : int_vector := (-51,25,128,77,-203,-372,70,1122,2047,2047,1122,70,-372,-203,77,128,25,-51); --! Filter coefficients defined in the fir_pkg.vhd
	-- Q 12, N 18
	constant quantization 	: positive := 12; --! Filter quantization bit-width
	constant order       	: natural  := coeff'length;
	constant width_out	: natural  := 15;

	-- Global signals for internal debugging
	signal g_multi_add   : std_logic_vector((order-1)*width_out-1 downto 0);
	signal g_add_delay   : std_logic_vector((order-2)*width_out-1 downto 0);
	signal g_delay_add   : std_logic_vector((order-1)*width_out-1 downto 0);
	signal g_multi_delay : std_logic_vector(width_out-1 downto 0);
	
	function binary_width (
		x : natural)
	return natural;
	
	function EOp (
		M : positive
		)
	return natural;	
	
	function EOn (
		M : positive
		)
	return natural;	
		
end fir_pkg;

package body fir_pkg is
		
	function binary_width (
		x : natural)
	return natural is
		variable y 	: integer;
		variable count 	: natural;
		begin
		
		y := abs(x);
		count := 0;
		while y > 0 loop
			y := y/2;
			count := count + 1;
		end loop;
		
		return count;
		
		end function;

	function EOp (
		M : positive
		)
	return natural is
		begin
			if (M mod 2) = 0 then
				return M/2-1;
			else
				return M/2;
			end if;
		end function;
		
	function EOn (
		M : positive
		)
	return natural is
		begin
			if (M mod 2) = 0 then
				return M/2-1;
			else
				return M/2-1;
			end if;
		end function;
		
end fir_pkg;
