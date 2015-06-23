----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    D-Flip-flop
-- Module Name:    dff - behavioral 
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

entity dff is
	generic( WIDTH : integer := 16 );
    port ( clk 		: in std_logic;
           enable 	: in std_logic;
           rst_n 	: in std_logic;
           sink_d 	: in std_logic_vector (WIDTH-1 downto 0);
           src_q 	: out std_logic_vector (WIDTH-1 downto 0)
    );
end dff;

architecture behavioral of dff is

begin
	process (clock,reset)
	begin
		if(reset = '0') then
			src_q <= (others => '0');
		elsif clock'event and clock = '1' then
			if(enable = '1') then
				src_q <= sink_d;
			end if;	
		end if;
	end process;

end behavioral;

