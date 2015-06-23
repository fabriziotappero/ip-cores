library ieee;
use ieee.std_logic_1164.all;



entity unrm1 is 
	port (
		clk,signdelta,signa,signb,zeroa,zerob	: in std_logic;
		shiftbin, shiftbout						: in std_logic_vector (4 downto 0);
		expbin,expout							: out std_logic_vector(7 downto 0);
		clk,
		