library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.normal_distribution_random_noise.all;

--by MEP 22 February 2011
--usage:
--these are functions, which means they can be on the right-hand side
--of an assignment. These functions create an I and Q sample.
--The arguments are 
--a natural number standing for the index of the sample,
--a real number that provides a way to have many samples per period,
--a real number standing for the standard deviation of the normally distributed noise added to the sample,
--a real number standing for the amplitude of the signal,
--a natural number indicating the width of the vector holding the returned value,
--a real number indicating the gain error of Q with respect to I,
--and a real number indicating the phase error of Q with respect to I
--
--create_I_sample(n_dat, freq, sgma, amplitude, return_width);
--create_Q_sample(n_dat, freq, sgma, amplitude, return_width, e1, a1);
--

package create_sample is
	
	function create_I_sample(
	n_dat : integer; 
	freq : real;
	sgma : real;
	amplitude : real;
	return_width : natural) 
	return signed;
	
	function create_Q_sample(
	n_dat : integer; 
	freq : real;
	sgma : real;
	amplitude : real;
	return_width : natural; --x1_tb'LENGTH
	e1 : real; --gain error
	a1 : real)   --phase error  
	return signed;
	
end package create_sample;


package body create_sample is
	
	function create_I_sample(
	n_dat : integer; 
	freq : real;
	sgma : real;
	amplitude : real;
	return_width : natural)  --x1_tb'LENGTH
	return signed is

	variable local_x1 : real;
	variable int_x1: integer;
	variable returned_x1 : signed(return_width downto 0);
	
	begin

		local_x1 := amplitude*sin(2.0*math_pi*(real(n_dat))*freq) + random_noise(sgma);
		--report "local_x1 inside CREATE_I_SAMPLE function is " & real'image(local_x1) & ".";
		
		--AGC scaling. Scaling factor is maximum value the signal can take. 
		local_x1 := local_x1/(1.11); 
		--report "local_x1 after AGC inside CREATE_I_SAMPLE function is " & real'image(local_x1) & ".";
		
		int_x1 := integer(trunc(local_x1*((2.0**31.0)-1.0)));  --scaled
		--report "integer version of x1 inside CREATE_I_SAMPLE function is " & integer'image(int_x1) & ".";
		
		returned_x1 := (to_signed(int_x1, return_width+1));
		
		return returned_x1;
end function; 

function create_Q_sample(
	n_dat : integer; 
	freq : real;
	sgma : real;
	amplitude : real;
	return_width : natural; --x1_tb'LENGTH
	e1 : real; --gain error
	a1 : real) 
	return signed is

	variable local_y1 : real;
	variable int_y1: integer;
	variable returned_y1 : signed(return_width downto 0);
	
	begin
		local_y1 := amplitude*(1.0 + e1)*cos(2.0*math_pi*(real(n_dat))*freq + a1) + random_noise(sgma);
		--report "local_y1 first created CREATE_Q_SAMPLE function is " & real'image(local_y1) & ".";
		
		--AGC scaling. Scaling factor is maximum value the signal can take.
		local_y1 := local_y1/(1.11); 
		--report "local_y1 after AGC inside CREATE_Q_SAMPLE function is " & real'image(local_y1) & ".";
		
		int_y1 := integer(trunc(local_y1*((2.0**31.0)-1.0)));  --scaled
		--report "integer version of y1 inside CREATE_Q_SAMPLE function is " & integer'image(int_y1) & ".";
		
		returned_y1 := (to_signed(int_y1, return_width+1));
		
		return returned_y1;
	end function;
end package body create_sample;