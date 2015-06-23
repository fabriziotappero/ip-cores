-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;

entity tb_soc_gpio is
end entity tb_soc_gpio;

architecture testbench of tb_soc_gpio is

	-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;

	-- Reset signal:
	signal reset : std_logic := '1';

	-- GPIOs:
	signal gpio : std_logic_vector(31 downto 0);

	-- Wishbone bus:
	signal wb_adr_in  : std_logic_vector( 1 downto 0) := (others => '0');
	signal wb_dat_in  : std_logic_vector(31 downto 0) := (others => '0');
	signal wb_dat_out : std_logic_vector(31 downto 0);
	signal wb_cyc_in  : std_logic := '0';
	signal wb_stb_in  : std_logic := '0';
	signal wb_we_in   : std_logic := '0';
	signal wb_ack_out : std_logic;
begin

	uut: entity work.pp_soc_gpio
		generic map(
			NUM_GPIOS => 32
		) port map(
			clk => clk,
			reset => reset,
			gpio => gpio,
			wb_adr_in => wb_adr_in,
			wb_dat_in => wb_dat_in,
			wb_dat_out => wb_dat_out,
			wb_cyc_in => wb_cyc_in,
			wb_stb_in => wb_stb_in,
			wb_we_in => wb_we_in,
			wb_ack_out => wb_ack_out
		);

	clock: process
	begin
		clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
		wait for clk_period / 2;
	end process clock;

	stimulus: process
	begin
		wait for clk_period * 2;
		reset <= '0';

		-- Set the upper half of the GPIOs as inputs, the rest as outputs:
		wb_dat_in <= x"0000ffff";
		wb_adr_in <= b"10";
		wb_we_in <= '1';
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wait until wb_ack_out = '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wb_cyc_in <= '0';
		wb_we_in <= '0';
		wait for clk_period;

		-- Set the outputs to aa, see if the upper half gets ignored correctly:
		wb_dat_in <= x"aaaaaaaa";
		wb_adr_in <= b"01";
		wb_we_in <= '1';
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wait until wb_ack_out = '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wb_cyc_in <= '0';
		wb_we_in <= '0';
		wait for clk_period;

		wait;
	end process stimulus;

end architecture testbench;
