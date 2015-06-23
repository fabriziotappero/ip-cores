-----------------------------------------------------------------------------
--	Filename:	gh_parity_gen_Serial.vhd
--
--	Description:
--		a Serial parity bit generator
--
--	Copyright (c) 2005 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	--------	-----------
--	1.0      	10/15/05  	S A Dodd	Initial revision
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gh_parity_gen_Serial IS
	PORT(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		srst     : in STD_LOGIC;
		SD       : in STD_LOGIC; -- sample data pulse
		D        : in STD_LOGIC; -- data
		Q        : out STD_LOGIC -- parity 
		);
END gh_parity_gen_Serial;

ARCHITECTURE a OF gh_parity_gen_Serial IS

	signal parity  : std_logic;

BEGIN

	Q <= parity;
	
process (clk,rst)
begin
	if (rst = '1') then 
		parity <= '0';
	elsif (rising_edge(clk)) then
		if (srst = '1') then -- need to clear before start of data word
			parity <= '0';
		elsif (SD = '1') then -- sample data bit for parity generation
			parity <= (parity xor D);
		end if;
	end if;
end process;
		
END a;

