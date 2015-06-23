-----------------------------------------------------------------------------
--	Filename:	gh_jkff.vhd
--
--	Description:
--		a JK Flip-Flop
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions  
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	--------	-----------
--	1.0      	09/03/05  	G Huber 	Initial revision
--	2.0     	10/06/05  	G Huber 	name change to avoid conflict
--	        	          	         	  with other libraries
--	2.1      	05/21/06  	S A Dodd 	fix typo's
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY gh_jkff IS
	PORT(
		clk  : IN STD_logic;
		rst : IN STD_logic;
		J,K  : IN STD_logic;
		Q    : OUT STD_LOGIC
		);
END gh_jkff;

ARCHITECTURE a OF gh_jkff IS

	signal iQ :  STD_LOGIC;
	
BEGIN
 
	Q <= iQ;

process(clk,rst)
begin
	if (rst = '1') then 
		iQ <= '0';
	elsif (rising_edge(clk)) then 
		if ((J = '1') and (K = '1')) then
			iQ <= not iQ;
		elsif (J = '1') then
			iQ <= '1';
		elsif (K = '1') then
			iQ <= '0';
		end if;
	end if;
end process;


END a;

