library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;


architecture IQGainPhaseCorrection_integer of IQGainPhaseCorrection is

	--signal declarations

	
	
begin

    correction : process (clk) is
	
	variable x1_real : real := 0.0;
	variable y1_real : real := 0.0;
	variable reg_1x1 : real := 0.0;
	variable y2      : real := 0.0;
	variable mu_1    : real := 0.000244;
	variable mu_2    : real := 0.000122;
	variable x1y2    : real := 0.0;
	variable reg_1   : real := 0.0;
	variable reg_2   : real := 1.0;
	variable y3      : real := 0.0;
	
	
		begin
		
   		if clk'event and clk = '1' then
			   --get I and Q, and convert them back to real values. 
			   x1_real := real(to_integer(x1));
			   x1_real := x1_real / ((2.0**31.0)-1.0);
			   y1_real := real(to_integer(y1));
			   y1_real := y1_real / ((2.0**31.0)-1.0);
			   
			   
			   --phase error estimate, step size set to 0.000244
			   --which is achieved with an arithmetic shift right by 12.
			   y2 := y1_real - reg_1 * x1_real;
			   
			   reg_1 := reg_1 + mu_1*x1_real*y2;
			   
			   --phase_error <= reg_1;
			   
			   
			   --gain error estimate, step size set to 0.000122
			   --which is achieved with a shift right by 13.
			   y3 := y2 * reg_2;
			   
			   reg_2 := reg_2 + mu_2 * ((x1_real * x1_real) - (y3*y3));
		
		
		end if;
		  
	end process;	

end IQGainPhaseCorrection_integer;	




