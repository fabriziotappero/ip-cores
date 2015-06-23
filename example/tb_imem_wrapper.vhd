-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

entity tb_imem_wrapper is
end entity tb_imem_wrapper;

architecture testbench of tb_imem_wrapper is

	-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;

	-- Reset signal:
	signal reset : std_logic := '1';
	
	-- Wishbone signals:
	signal wb_adr_in : std_logic_vector(10 downto 0);
	signal wb_dat_out : std_logic_vector(31 downto 0);
	signal wb_cyc_in : std_logic := '0';
	signal wb_stb_in : std_logic := '0';
	signal wb_ack_out : std_logic;

begin

	uut: entity work.imem_wrapper
		port map(
			clk => clk,
			reset => reset,
			wb_adr_in => wb_adr_in,
			wb_dat_out => wb_dat_out,
			wb_cyc_in => wb_cyc_in,
			wb_stb_in => wb_stb_in,
			wb_ack_out => wb_ack_out
		);

	clock: process
	begin
		clk <= '1';
		wait for clk_period;
		clk <= '0';
		wait for clk_period;
	end process clock;

	stimulus: process
	begin
		wait for clk_period * 2;
		reset <= '0';
		wait for clk_period;

		-- Read an instruction:
		wb_adr_in <= (others => '0');
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wait for clk_period;
		wait until wb_ack_out = '1';
		wait for clk_period;
		wb_cyc_in <= '0';
		wb_stb_in <= '0';

		-- TODO: Make testbench automated.

		wait;
	end process stimulus;

end architecture testbench;
