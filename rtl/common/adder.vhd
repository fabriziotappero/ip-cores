----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    Adder Macrofunction
-- Module Name:    adder - behavioral 
----------------------------------------------------------------------------------
-- Project Name:   16-bit uRISC Processor
----------------------------------------------------------------------------------
-- Revision: 
-- 	1.0 - File Created
-- 	2.0 - Project refactoring
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity adder is
	Generic (
		WIDTH : integer := 16 );
    Port ( 
    	sink_a   : in std_logic_vector (WIDTH-1 downto 0);
        sink_b   : in std_logic_vector (WIDTH-1 downto 0);
        src_data : out std_logic_vector (WIDTH-1 downto 0) );
end adder;

architecture behavioral of adder is	
begin
	process(sink_a, sink_b)
		variable aux : std_logic_vector(WIDTH-1 downto 0) := conv_std_logic_vector(0,WIDTH);
	begin
		aux := sink_a + sink_b;
		src_data <= aux;
	end process;

end behavioral;

