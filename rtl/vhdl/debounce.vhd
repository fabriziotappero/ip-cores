----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yann Vernier
-- 
-- Create Date:    23:05:04 09/08/2009 
-- Design Name: 
-- Module Name:    debounce - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Debounces an input signal (for instance, a switch).
--          Output will only change after input has stayed one value between two enabled clock edges.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    Port ( clk : in  STD_LOGIC;
           clken : in  STD_LOGIC;
           input : in  STD_LOGIC;
           output : inout  STD_LOGIC);
end debounce;

-- Concept: input values are asynchronously connected to SR latches.
-- Those are synchronously reset, so if both are set, the input is unstable.
-- On Spartan 3 FPGAs, this architecture probably requires at least three slices,
-- due to separate RS lines for flip-flops. The output register may share, though.
architecture Behavioral of debounce is
	-- 00->no input value observed (reset), 10 or 01 -> steady value, 11->value changed
	signal inputv : std_logic_vector(0 to 1) := "00";
	signal next_output : std_logic;
begin
	-- our two asynch latches must agree for an update to occur
	-- the tricky part of the code was convincing the synthesizer we only need one LUT3
	-- to implement this consensus function (inputv must agree to alter output).
	with inputv select
		next_output <= '0' when "10",
										'1' when "01",
										output when others;
	process (clk, input)
	begin
		-- input='0' for asynch set of input(0), synch reset
		if input='0' then
			inputv(0) <= '1';
		elsif clken='1' and rising_edge(clk) then
			inputv(0) <= '0';
		end if;
		-- same for 1
		if input='1' then
			inputv(1) <= '1';
		elsif clken='1' and rising_edge(clk) then
			inputv(1) <= '0';
		end if;
		-- finally, on enabled clocks, update output
		if clken='1' and rising_edge(clk) then
			output <= next_output;
		end if;
	end process;
end Behavioral;
