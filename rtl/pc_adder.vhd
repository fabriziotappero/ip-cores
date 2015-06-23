----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    Program Counter Adder
-- Module Name:    pc_adder - behavioral 
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

entity pc_adder is
	generic (
	    DATA_WIDTH : integer := 16;
	    INC_PLUS : integer := 1
	);
	port (
		sink_pc : in std_logic_vector(DATA_WIDTH-1 downto 0);
		src_pc : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);

end pc_adder;

architecture behavioral of pc_adder is
begin
	process(sink_pc)
		variable counter : std_logic_vector(DATA_WIDTH-1 downto 0) := conv_std_logic_vector(0,DATA_WIDTH); -- verify if it is necessary
	begin
		counter := sink_pc + INC_PLUS;					
		src_pc <= counter;
	end process;
end behavioral;
