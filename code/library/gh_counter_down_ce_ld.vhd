-----------------------------------------------------------------------------
--	Filename:	gh_Counter_down_ce_ld.vhd
--
--	Description:
--		Binary up/down counter with load, and count enable
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author   	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	09/24/05  	S A Dodd	Initial revision
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY gh_counter_down_ce_ld IS
	GENERIC (size: INTEGER :=8);
	PORT(
		CLK   : IN	STD_LOGIC;
		rst   : IN	STD_LOGIC;
		LOAD  : IN	STD_LOGIC;
		CE    : IN	STD_LOGIC;
		D     : IN  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q     : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END gh_counter_down_ce_ld;

ARCHITECTURE a OF gh_counter_down_ce_ld IS 

	signal iQ  : STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	
BEGIN
	      
	Q <= iQ;

PROCESS (CLK,rst)
BEGIN
	if (rst = '1') then 
		iQ <= (others => '0');
	elsif (rising_edge(CLK)) then
		if (LOAD = '1') then 
			iQ <= D;
		elsif (CE = '1') then
			iQ <= (iQ - "01");
		end if;			
	end if;
END PROCESS;

END a;
