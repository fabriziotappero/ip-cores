-----------------------------------------------------------------------------
--	Filename:	gh_register_ce.vhd
--
--	Description:
--		register with clock enable
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	09/03/05  	G Huber  	Initial revision
--	2.0     	09/17/05  	h lefevre	name change to avoid conflict
--	        	          	         	  with other librarys
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gh_register_ce IS
	GENERIC (size: INTEGER := 8);
	PORT(	
		clk : IN		STD_LOGIC;
		rst : IN		STD_LOGIC; 
		CE  : IN		STD_LOGIC; -- clock enable
		D   : IN		STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q   : OUT		STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END gh_register_ce;

ARCHITECTURE a OF gh_register_ce IS


BEGIN

PROCESS (clk,rst)
BEGIN
	if (rst = '1') then
		Q <= (others =>'0');
	elsif (rising_edge (clk)) then
		if (CE = '1') then
			Q <= D;
		end if;
	end if;
END PROCESS;

END a;

