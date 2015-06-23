--
-- full_adder
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FULL_ADDER is 
    port(
	        X	: in	std_logic;
	        Y	: in	std_logic;
	        CIN	: in	std_logic;
	        COUT	: out	std_logic;
	        R	: out	std_logic
        );
end FULL_ADDER;

architecture FULL_ADDER_ARC of FULL_ADDER is


signal G,P,K : std_logic;

begin
	G <= X and Y;
	P <= X xor Y;
	K <= X nor Y;
	COUT <= G or ( P and CIN );
	R <= P xor CIN;    
end FULL_ADDER_ARC;
