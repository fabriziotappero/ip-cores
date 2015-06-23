library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  



architecture IQGainPhaseCorrection_signed of IQGainPhaseCorrection is

	--signal declarations

	--phase error estimate accumulator
	signal reg_1:signed(width-1 downto 0) := (others => '0');

	--gain error estimate accumulator
	signal reg_2:signed(width-1 downto 0) := (0 => '1', others => '0');
	
	--Phase Offset Adjustment Applied to y1
	signal y2:signed(width-1 downto 0) := (others => '0');

	--Gain and Phase Adjustment Applied	to y1
	signal y3:signed(2*width-1 downto 0) := (others => '0');	
	
	signal x1y2:signed(2*width-1 downto 0):= (others => '0');
	signal mu_1:signed(width-1 downto 0):= (others => '0');
	signal x1x1y3y3:signed(width-1 downto 0):= (others => '0');
	signal mu_2:signed(width-1 downto 0):= (others => '0');
	
	signal reg_1x1:signed(2*width-1 downto 0):= (others => '0');
	
	signal y3y3: signed(4*width-1 downto 0):= (others => '0');
	signal x1x1: signed(2*width-1 downto 0):= (others => '0');
	
begin

    correction : process (clk) is	
		begin
		
   		if clk'event and clk = '1' then
		
		--phase error estimate, step size set to 0.000244
		--which is achieved with an arithmetic shift right by 12.
		
		--multiply current I sample by phase error estimate.
		reg_1x1 <= reg_1 * x1; --clock 0   
		
		--Our phase-adjusted Q vector
		--is our current Q vector minus 
		--a tiny bit of I vector. 
		y2 <= y1 - reg_1x1(2*width-1 downto width); --clock 1
		
		--Multiply our current I vector
		--by our phase adjusted Q vector.
		x1y2 <= x1 * y2; --clock 2
		
		--Multiply this result by 0.000244. 
		--This applies the step size.
		mu_1 <= shift_right(x1y2(2*width-1 downto width),12);	  --clock 3
		
		--Update the phase error estimate.
		reg_1 <= reg_1 + mu_1; 	 --clock 4
		
		--Output phase error estimate.
		phase_error <= reg_1;  --update phase error estimate.	 --clock 5
		
		
		--gain error estimate, step size set to 0.000122
		--which is achieved with a shift right by 13.
		y3 <= y2 * reg_2;	   --clock 0	   
		x1x1 <= x1 * x1;	 --clock 0	  
		y3y3 <= y3 * y3;  --clock 1		  
		
		x1x1y3y3 <= (x1x1(2*width-1 downto width)) - (y3y3(4*width-1 downto 3*width));   --clock 2
		mu_2 <= shift_right(x1x1y3y3, 13);	 --clock 3
		reg_2 <= reg_2 + mu_2; 	 --clock 4
		gain_error <= reg_2;   --update gain error estimate.  --clock 5
		
		end if;
		
	end process;	

end IQGainPhaseCorrection_signed;	
