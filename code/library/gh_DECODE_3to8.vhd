-----------------------------------------------------------------------------
--	Filename:	gh_DECODE_3to8.vhd
--
--	Description:
--		a 3 to 8 decoder	 
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date      	Author   	Comment
--	-------- 	----------	---------	-----------
--	1.0      	09/17/05  	G Huber  	Initial revision
--	1.1     	05/05/06  	G Huber  	fix typo
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gh_decode_3to8 IS
	PORT(	
		A   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- address
		G1  : IN  STD_LOGIC; -- enable positive
		G2n : IN  STD_LOGIC; -- enable negative
		G3n : IN  STD_LOGIC; -- enable negative
		Y   : out STD_LOGIC_VECTOR(7 downto 0)
		);
END gh_decode_3to8 ;

ARCHITECTURE a OF gh_decode_3to8 IS	  


BEGIN

	Y <= x"00" when (G3n = '1') else
	     x"00" when (G2n = '1') else
	     x"00" when (G1 = '0') else
	     x"80" when (A= o"7") else
	     x"40" when (A= o"6") else
	     x"20" when (A= o"5") else
	     x"10" when (A= o"4") else
	     x"08" when (A= o"3") else
	     x"04" when (A= o"2") else
	     x"02" when (A= o"1") else
	     x"01";-- when (A= o"0")


END a;

