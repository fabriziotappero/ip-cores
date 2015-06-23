-----------------------------------------------------------------------------
--	Filename:	gh_shift_reg_se_sl.vhd
--
--	Description:
--		a shift register with async reset and count enable
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


ENTITY gh_shift_reg_se_sl IS
	GENERIC (size: INTEGER := 16); 
	PORT(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		srst     : IN STD_logic:='0';
		SE       : IN STD_logic; -- shift enable
		D        : IN STD_LOGIC;
		Q        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END entity ;

ARCHITECTURE a OF gh_shift_reg_se_sl IS

	signal iQ :  STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	
BEGIN
 
	Q <= iQ;

process(clk,rst)
begin
	if (rst = '1') then 
		iQ <= (others => '0');
	elsif (rising_edge(clk)) then 
		if (srst = '1') then
			iQ <= (others => '0');
		elsif (SE = '1') then
			iQ(size-1) <= D;
			iQ(size-2 downto 0) <= iQ(size-1 downto 1);
		end if;
	end if;
end process;


END a;

