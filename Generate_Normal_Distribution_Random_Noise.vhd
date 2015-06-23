library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.random_int.all;

--by MEP 22 February 2011
--usage:
--this is a function, which means it can be on the right-hand side
--of an assignment. It returns a mean-zero random number from a
--normal distribution. The argument is a real number that indicates
--the standard deviation desired. 
--
--random_noise(sigma);
--

package normal_distribution_random_noise is

	function random_noise ( 
	sigma : real)
	return real;

end package normal_distribution_random_noise;


package body normal_distribution_random_noise is

	function random_noise ( 
	sigma : real
	)
	return real is
	
		--variables
		variable u_noise: real; --uniform distribution noise
		variable n_noise: real := 0.0; --normal distribution noise
		variable seed1 : positive;
		variable seed2 : positive; 
	
	begin

		--obtain a uniformly distributed random number
		uniform(seed1, seed2, u_noise);
		--report "Random uniform noise is " & real'image(u_noise) & ".";
		
		for normal_count in 0 to 12 loop
		--Turn the uniform distributed number 
		--into a normally distributed number
		--by using the central limit theorem.
		--Make it mean zero and make it have
		--the range of the uniform numbers
		--that it is composed from. 
		n_noise := n_noise + u_noise;
		end loop;
		
		n_noise := n_noise - (0.5)*(real(12)); --normal distribution with a mean of zero
		--report "Random normal noise is " & real'image(n_noise) & ".";
		n_noise := n_noise/(real(12));
		--report "Random normal noise using range of uniform is " & real'image(n_noise) & ".";
		n_noise := sigma*n_noise;
		
		return n_noise;
	end function random_noise;
end package body normal_distribution_random_noise;
	