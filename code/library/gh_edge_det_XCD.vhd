-----------------------------------------------------------------------------
--	Filename:	gh_edge_det_XCD.vhd
--
--	Description:
--		an edge detector, for crossing clock domains - 
--		   finds the rising edge and falling edge for a pulse crossing clock domains
--
--	Copyright (c) 2006, 2008 by George Huber 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions  
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	----------	--------	-----------
--	1.0        	09/16/06  	S A Dodd 	Initial revision
--	2.0     	04/12/08  	hlefevre	mod to double register between clocks
--	        	          	        	   output time remains the same
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity gh_edge_det_XCD is
	port(
		iclk : in STD_LOGIC;  -- clock for input data signal
		oclk : in STD_LOGIC;  -- clock for output data pulse
		rst  : in STD_LOGIC;
		D    : in STD_LOGIC;
		re   : out STD_LOGIC; -- rising edge 
		fe   : out STD_LOGIC  -- falling edge 
		);
end entity;


architecture a of gh_edge_det_XCD is

	signal iQ  : std_logic;
	signal jkR, jkF : std_logic;
	signal irQ0, rQ0, rQ1 : std_logic;
	signal ifQ0, fQ0, fQ1 : std_logic;

begin

process(iclk,rst)
begin
	if (rst = '1') then 
		iQ <= '0';
		jkR <= '0';
		jkF <= '0';
	elsif (rising_edge(iclk)) then
		iQ <= D;
		if ((D = '1') and (iQ = '0')) then
			jkR <= '1';
		elsif (rQ1 = '1') then
			jkR <= '0';
		else
			jkR <= jkR;
		end if;
		if ((D = '0') and (iQ = '1')) then
			jkF <= '1';
		elsif (fQ1 = '1') then
			jkF <= '0';
		else
			jkF <= jkF;
		end if;
	end if;
end process;

	re <= (not rQ1) and rQ0;
	fe <= (not fQ1) and fQ0;

process(oclk,rst)
begin
	if (rst = '1') then 
		irQ0 <= '0';
		rQ0 <= '0'; 
		rQ1 <= '0';
		---------------
		ifQ0 <= '0';
		fQ0 <= '0';
		fQ1 <= '0';
	elsif (rising_edge(oclk)) then
		irQ0 <= jkR;
		rQ0 <= irQ0;
		rQ1 <= rQ0;
		---------------
		ifQ0 <= jkF;
		fQ0 <= ifQ0;
		fQ1 <= fQ0;
	end if;
end process;


end a;
