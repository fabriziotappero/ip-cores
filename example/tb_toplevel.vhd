-- Practical Test Application for the Potato Processor
-- (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

entity tb_toplevel is
end entity tb_toplevel;

architecture testbench of tb_toplevel is

	signal clk : std_logic;
	constant clk_period : time := 10 ns;
	
	signal reset_n            : std_logic := '0';
	signal external_interrupt : std_logic := '0';
	
	signal switches : std_logic_vector(15 downto 0);
	signal leds : std_logic_vector(15 downto 0);

	signal uart_rxd : std_logic := '1';
	signal uart_txd : std_logic;

begin

	switches <= x"a0a0";

	uut: entity work.toplevel
		port map(
			clk => clk,
			reset_n => reset_n,
			external_interrupt => external_interrupt,
			switches => switches,
			leds => leds,
			uart_rxd => uart_rxd,
			uart_txd => uart_txd
		);

	clock: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clock;

	stimulus: process
	begin
		wait for clk_period * 125;
		reset_n <= '0';
		wait for clk_period * 3;
		reset_n <= '1';

		wait;
	end process stimulus;

end architecture testbench;
