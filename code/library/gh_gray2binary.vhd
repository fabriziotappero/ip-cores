-----------------------------------------------------------------------------
--	Filename:	gh_gray2binary.vhd
--
--	Description:
--		a gray code to binary converter
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

ENTITY gh_gray2binary IS
	GENERIC (size: INTEGER := 8);
	PORT(	
		G   : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);	-- gray code in
		B   : out STD_LOGIC_VECTOR(size-1 DOWNTO 0) -- binary value out
		);
END entity;

ARCHITECTURE a OF gh_gray2binary IS

	signal iB  : STD_LOGIC_VECTOR(size-1 DOWNTO 0);

BEGIN
	
	B <= iB;
	
process	(G,iB) is
begin
	for j in 0 to size-2 loop
		iB(j) <= G(j) xor iB(j+1);
	end loop;
	iB(size-1) <= G(size-1);
end process;
		
END a;

