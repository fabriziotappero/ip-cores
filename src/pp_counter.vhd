-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 -2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pp_counter is
	generic(
		COUNTER_WIDTH : natural := 64;
		COUNTER_STEP  : natural :=  1
	);
	port(
		clk   : in std_logic;
		reset : in std_logic;
		
		count     : out std_logic_vector(COUNTER_WIDTH - 1 downto 0);
		increment : in std_logic
	);
end entity pp_counter;

architecture behaviour of pp_counter is
	signal current_count : std_logic_vector(COUNTER_WIDTH - 1 downto 0);
begin

	count <= current_count;

	counter: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				current_count <= (others => '0');
			elsif increment = '1' then
				current_count <= std_logic_vector(unsigned(current_count) + COUNTER_STEP);
			end if;
		end if;
	end process counter;

end architecture behaviour;
