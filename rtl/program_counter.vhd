----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    Program Counter
-- Module Name:    program_counter - behavioral 
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

entity program_counter is
	generic(
	    DATA_WIDTH : integer := 16
	);
	port (
		sink_pc  	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		clk			: in std_logic;
		enable 		: in std_logic;
		reset		: in std_logic;
		src_pc	    : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);

end program_counter;

architecture behavioral of program_counter is
begin
	process(clk,enable)
		variable counter : std_logic_vector (DATA_WIDTH-1 downto 0) := conv_std_logic_vector(0,DATA_WIDTH);
	begin			
		src_pc <= counter;	
		if(clk='1' and clk'event) then
			if(reset = '1') then
				counter := conv_std_logic_vector(0,DATA_WIDTH);
			else
				if(enable = '1') then
					counter := sink_pc;
				end if;
			end if;
		end if;
	end process;
end behavioral;
