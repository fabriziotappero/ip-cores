-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_soc_memory is
end entity tb_soc_memory;

architecture testbench of tb_soc_memory is

	-- Clock signal:
	signal clk : std_logic;
	constant clk_period : time := 10 ns;

	-- Reset signal:
	signal reset : std_logic := '1';

	-- Wishbone signals:
	signal wb_adr_in  : std_logic_vector(31 downto 0);
	signal wb_dat_in  : std_logic_vector(31 downto 0);
	signal wb_dat_out : std_logic_vector(31 downto 0);
	signal wb_cyc_in  : std_logic := '0';
	signal wb_stb_in  : std_logic := '0';
	signal wb_sel_in  : std_logic_vector(3 downto 0) := (others => '1');
	signal wb_we_in   : std_logic := '0';
	signal wb_ack_out : std_logic;

begin

	uut: entity work.pp_soc_memory
		port map(
			clk => clk,
			reset => reset,
			wb_adr_in => wb_adr_in,
			wb_dat_in => wb_dat_in,
			wb_dat_out => wb_dat_out,
			wb_cyc_in => wb_cyc_in,
			wb_stb_in => wb_stb_in,
			wb_sel_in => wb_sel_in,
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
		wait for clk_period;
		reset <= '0';

		-- Write 32 bit of data to address 0:
		wb_adr_in <= x"00000000";
		wb_dat_in <= x"deadbeef";
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wb_we_in <= '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wb_cyc_in <= '0';
		wait for clk_period;

		-- Write a block write of two 32-bit words at address 0 and 1:
		wb_adr_in <= x"00000000";
		wb_dat_in <= x"feedbeef";
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wb_adr_in <= x"00000004";
		wb_dat_in <= x"f00dd00d";
		wait for clk_period;
		wb_stb_in <= '1';
		wait for clk_period;
		wb_stb_in <= '0';
		wb_cyc_in <= '0';
	
		-- Read address 4:
		wait for clk_period;
		wb_we_in <= '0';
		wb_adr_in <= x"00000000";
		wb_cyc_in <= '1';
		wb_stb_in <= '1';
		wait for clk_period;

		-- TODO: Make this testbench automatic.

		wait;
	end process stimulus;

end architecture testbench;
