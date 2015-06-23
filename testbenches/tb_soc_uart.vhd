-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;

entity tb_soc_uart is
end entity tb_soc_uart;

architecture testbench of tb_soc_uart is

	-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;

	-- Reset signal:
	signal reset : std_logic := '1';

	-- UART ports:
	signal txd : std_logic;
	signal rxd : std_logic := '1';

	-- interrupt signals:
	signal irq_send_buffer_empty : std_logic;
	signal irq_data_received : std_logic;

	-- Wishbone ports:
	signal wb_adr_in  : std_logic_vector(1 downto 0) := (others => '0');
	signal wb_dat_in  : std_logic_vector(7 downto 0) := (others => '0');
	signal wb_dat_out : std_logic_vector(7 downto 0);
	signal wb_we_in   : std_logic := '0';
	signal wb_cyc_in  : std_logic := '0';
	signal wb_stb_in  : std_logic := '0';
	signal wb_ack_out : std_logic;

begin

	uut: entity work.pp_soc_uart
		port map(
			clk => clk,
			reset => reset,
			txd => txd,
			rxd => rxd,
			irq_send_buffer_empty => irq_send_buffer_empty,
			irq_data_received => irq_data_received,
			wb_adr_in => wb_adr_in,
			wb_dat_in => wb_dat_in,
			wb_dat_out => wb_dat_out,
			wb_we_in => wb_we_in,
			wb_cyc_in => wb_cyc_in,
			wb_stb_in => wb_stb_in,
			wb_ack_out => wb_ack_out
		);

	-- Set up an internal loopback:
	rxd <= txd;

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

		-- Write a 'P' (for Potato the Processor) to the UART:
		wb_adr_in <= b"00";
		wb_dat_in <= x"50";
		wb_we_in <= '1';
		wb_cyc_in <= '1';
		wb_stb_in <= '1';

		wait until wb_ack_out = '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wait for clk_period;

		-- Write an 'o':
		wb_dat_in <= x"6f";
		wb_stb_in <= '1';
		wait until wb_ack_out = '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wait for clk_period;

		wait;
	end process stimulus;

end architecture testbench;
