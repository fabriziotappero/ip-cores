-----------------------------------------------------------------------------
--	Filename:	gh_counter_integer_down.vhd
--
--	Description:
--		an integer down counter
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	--------	-----------
--	1.0      	10/15/05  	G Huber 	Initial revision
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gh_counter_integer_down IS	
	generic(max_count : integer := 8);
	PORT(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		LOAD     : in STD_LOGIC; -- load D
		CE       : IN STD_LOGIC; -- count enable
		D        : in integer RANGE 0 TO max_count;
		Q        : out integer RANGE 0 TO max_count
		);
END gh_counter_integer_down;

ARCHITECTURE a OF gh_counter_integer_down IS

	signal iQ : integer RANGE 0 TO max_count;

BEGIN

	Q <= iQ;
	
process (clk,rst)
begin 
	if (rst = '1') then
		iQ <= 0;
	elsif (rising_edge(clk))  then 
		if (LOAD = '1') then
			iQ <= D;  
		elsif (CE = '1') then
			if (iQ = 0) then
				iQ <= max_count;
			else 
				iQ <= iQ - 1;
			end if;
		end if;
	end if;
end process;
		
END a;

