-----------------------------------------------------------------------------
--	Filename:	gh_edge_det.vhd
--
--	Description:
--		an edge detector - 
--		   finds the rising edge and falling edge
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions  
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	----------	--------	-----------
--	1.0      	09/10/05  	G Huber 	Initial revision
--	2.0     	09/17/05  	h lefevre	name change to avoid conflict
--	        	          	         	  with other libraries
--	2.1      	05/21/06  	S A Dodd 	fix typo's
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity gh_edge_det is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		D   : in STD_LOGIC;
		re  : out STD_LOGIC; -- rising edge (need sync source at D)
		fe  : out STD_LOGIC; -- falling edge (need sync source at D)
		sre : out STD_LOGIC; -- sync'd rising edge
		sfe : out STD_LOGIC  -- sync'd falling edge
		);
end gh_edge_det;


architecture a of gh_edge_det is

	signal Q0, Q1 : std_logic;

begin

	re <= D and (not Q0);
	fe <= (not D) and Q0;
	sre <= Q0 and (not Q1);
	sfe <= (not Q0) and Q1;
	
process(clk,rst)
begin
	if (rst = '1') then 
		Q0 <= '0';
		Q1 <= '0';
	elsif (rising_edge(clk)) then
		Q0 <= D;
		Q1 <= Q0;
	end if;
end process;

end a;
