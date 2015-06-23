-----------------------------------------------------------------------------
--	Filename:	gh_shift_reg_PL_sl.vhd
--
--	Description:
--		a shift register with Parallel Load	
--		   will shift left (MSB to LSB)
--
--	Copyright (c) 2006 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	--------	-----------
--	1.0      	02/11/06  	G Huber 	Initial revision
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY gh_shift_reg_PL_sl IS
	GENERIC (size: INTEGER := 16);
	PORT(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		LOAD     : IN STD_LOGIC;  -- load data
		SE       : IN STD_LOGIC;  -- shift enable
		D        : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END entity;

ARCHITECTURE a OF gh_shift_reg_PL_sl IS

	signal iQ :  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	
BEGIN
 
	Q <= iQ;
	

process(clk,rst)
begin
	if (rst = '1') then 
		iQ <= (others => '0');
	elsif (rising_edge(clk)) then
		if (LOAD = '1') then 
			iQ <= D;
		elsif (SE = '1') then -- shift left
			iQ(size-1 downto 0) <=  '0' & iQ(size-1 downto 1);
		else
			iQ <= iQ;
		end if;
	end if;
end process;


END a;

