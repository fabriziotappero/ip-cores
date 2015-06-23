-----------------------------------------------------------------------------
--	Filename:	gh_binary2gray.vhd
--
--	Description:
--		a binary to gray code converter
--
--	Copyright (c) 2006 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	--------	-----------
--	1.0      	12/26/06  	G Huber 	Initial revision
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gh_binary2gray IS
	GENERIC (size: INTEGER := 8);
	PORT(	
		B   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);	-- binary value in
		G   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0) -- gray code out
		);
END entity;

ARCHITECTURE a OF gh_binary2gray IS

BEGIN

process	(B) is
begin
	for j in 0 to size-2 loop
		G(j) <= B(j) xor B(j+1);
	end loop;
	G(size-1) <= B(size-1);
end process;
		
END a;

