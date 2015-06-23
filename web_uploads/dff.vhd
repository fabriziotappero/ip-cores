LIBRARY ieee;
USE ieee.std_logic_1164.all; 

ENTITY dff IS 
	PORT
	(
		d, clk, clrn 	:  	IN STD_LOGIC;
		q 				:  	OUT STD_LOGIC
	);

END dff;

ARCHITECTURE a_dff OF dff IS 


BEGIN

	PROCESS (clk, clrn)
	BEGIN
		IF clrn = '0' THEN q <= '0';
		ELSIF clk'event and clk = '1' THEN q <= d;
		END IF;
	END PROCESS;
	
END a_dff;
