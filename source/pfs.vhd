--+-----------------------------------------+
--|  pfs                                    |
--+-----------------------------------------+

library ieee;
use ieee.std_logic_1164.all;

entity pfs is
port (
   clk       	: in std_logic;
   a       	: in std_logic;
   y       	: out std_logic

);   
end pfs;

architecture rtl of pfs is

	signal a_s	: std_logic;
	
begin

	SYNCP: process( clk, a )
	begin
	
        if ( rising_edge(clk) ) then
			a_s <= a;
		end if;
        
	end process SYNCP;

	y <= a and (not a_s);
	
end rtl;

