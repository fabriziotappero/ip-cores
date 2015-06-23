-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.pp_constants.all;
use work.pp_utilities.all;

--! @brief Testbench providing a full SoC architecture connected with a Wishbone bus.
entity tb_soc is
	generic(
		IMEM_SIZE : natural := 2048; --! Size of the instruction memory in bytes.
		DMEM_SIZE : natural := 2048; --! Size of the data memory in bytes.
		IMEM_FILENAME : string := "imem_testfile.hex"; --! File containing the contents of instruction memory.
		DMEM_FILENAME : string := "dmem_testfile.hex"  --! File containing the contents of data memory.
	);
end entity tb_soc;

architecture testbench of tb_soc is

	-- Clock signals:
	signal clk : std_logic;
	constant clk_period : time := 10 ns;

	-- Reset:
	signal reset : std_logic := '1';

	-- Interrupts:
	signal irq : std_logic_vector(7 downto 0) := (others => '0');

	-- HTIF:
	signal fromhost_data, tohost_data : std_logic_vector(31 downto 0);
	signal fromhost_updated : std_logic := '0';
	signal tohost_updated : std_logic;

	-- Instruction memory signals:
	signal imem_adr_in : std_logic_vector(log2(IMEM_SIZE) - 1 downto 0);
	signal imem_dat_in : std_logic_vector(31 downto 0);
	signal imem_dat_out : std_logic_vector(31 downto 0);
	signal imem_cyc_in : std_logic;
	signal imem_stb_in : std_logic;
	signal imem_sel_in : std_logic_vector(3 downto 0);
	signal imem_we_in : std_logic;
	signal imem_ack_out : std_logic;
	
	-- Data memory signals:
	signal dmem_adr_in  : std_logic_vector(log2(DMEM_SIZE) - 1 downto 0);
	signal dmem_dat_in  : std_logic_vector(31 downto 0);
	signal dmem_dat_out : std_logic_vector(31 downto 0);
	signal dmem_cyc_in  : std_logic;
	signal dmem_stb_in  : std_logic;
	signal dmem_sel_in  : std_logic_vector(3 downto 0);
	signal dmem_we_in   : std_logic;
	signal dmem_ack_out : std_logic;

	-- Processor signals:
	signal p_adr_out : std_logic_vector(31 downto 0);
	signal p_dat_out : std_logic_vector(31 downto 0);
	signal p_dat_in  : std_logic_vector(31 downto 0);
	signal p_cyc_out : std_logic;
	signal p_stb_out : std_logic;
	signal p_sel_out : std_logic_vector(3 downto 0);
	signal p_we_out  : std_logic;
	signal p_ack_in  : std_logic;

	-- Arbitrated wishbone signals:
	signal wb_adr : std_logic_vector(31 downto 0);
	signal wb_dat : std_logic_vector(31 downto 0);
	signal wb_sel : std_logic_vector( 3 downto 0);
	signal wb_cyc : std_logic;
	signal wb_stb : std_logic;
	signal wb_we  : std_logic;

	-- Initialization "module" signals:
	signal init_adr_out : std_logic_vector(31 downto 0) := (others => '0');
	signal init_dat_out : std_logic_vector(31 downto 0) := (others => '0');
	signal init_cyc_out : std_logic := '0';
	signal init_stb_out : std_logic := '0';
	signal init_we_out  : std_logic := '1'; 

	-- Processor reset signals:
	signal processor_reset : std_logic := '1';

	-- Simulation control:
	signal initialized  : boolean := false;
	signal simulation_finished : boolean := false;

begin

	processor: entity work.pp_potato
		port map(
			clk => clk,
			reset => processor_reset,
			irq => irq,
			fromhost_data => fromhost_data,
			fromhost_updated => fromhost_updated,
			tohost_data => tohost_data,
			tohost_updated => tohost_updated,
			wb_adr_out => p_adr_out,
			wb_sel_out => p_sel_out,
			wb_cyc_out => p_cyc_out,
			wb_stb_out => p_stb_out,
			wb_we_out => p_we_out,
			wb_dat_out => p_dat_out,
			wb_dat_in => p_dat_in,
			wb_ack_in => p_ack_in
		);

	imem: entity work.pp_soc_memory
		generic map(
			MEMORY_SIZE => IMEM_SIZE
		) port map(
			clk => clk,
			reset => reset,
			wb_adr_in => imem_adr_in,
			wb_dat_in => imem_dat_in,
			wb_dat_out => imem_dat_out,
			wb_cyc_in => imem_cyc_in,
			wb_stb_in => imem_stb_in,
			wb_sel_in => imem_sel_in,
			wb_we_in => imem_we_in,
			wb_ack_out => imem_ack_out
		);

	dmem: entity work.pp_soc_memory
		generic map(
			MEMORY_SIZE => DMEM_SIZE
		) port map(
			clk => clk,
			reset => reset,
			wb_adr_in => dmem_adr_in,
			wb_dat_in => dmem_dat_in,
			wb_dat_out => dmem_dat_out,
			wb_cyc_in => dmem_cyc_in,
			wb_stb_in => dmem_stb_in,
			wb_sel_in => dmem_sel_in,
			wb_we_in => dmem_we_in,
			wb_ack_out => dmem_ack_out
		);

	imem_adr_in <= wb_adr(imem_adr_in'range);
	imem_dat_in <= wb_dat;
	imem_we_in <= wb_we;
	imem_sel_in <= wb_sel;
	dmem_adr_in <= wb_adr(dmem_adr_in'range);
	dmem_dat_in <= wb_dat;
	dmem_we_in <= wb_we;
	dmem_sel_in <= wb_sel;

	address_decoder: process(wb_adr, imem_dat_out, imem_ack_out, dmem_dat_out, dmem_ack_out,
		wb_cyc, wb_stb)
	begin
		if to_integer(unsigned(wb_adr)) < IMEM_SIZE then
			p_dat_in <= imem_dat_out;
			p_ack_in <= imem_ack_out;
			imem_cyc_in <= wb_cyc;
			imem_stb_in <= wb_stb;
			dmem_cyc_in <= '0';
			dmem_stb_in <= '0';
		else
			p_dat_in <= dmem_dat_out;
			p_ack_in <= dmem_ack_out;
			dmem_cyc_in <= wb_cyc;
			dmem_stb_in <= wb_stb;
			imem_cyc_in <= '0';
			imem_stb_in <= '0';
		end if;
	end process address_decoder;

	arbiter: process(initialized, init_adr_out, init_dat_out, init_cyc_out, init_stb_out, init_we_out,
		p_adr_out, p_dat_out, p_cyc_out, p_stb_out, p_we_out, p_sel_out)
	begin
		if not initialized then
			wb_adr <= init_adr_out;
			wb_dat <= init_dat_out;
			wb_cyc <= init_cyc_out;
			wb_stb <= init_stb_out;
			wb_we <= init_we_out;
			wb_sel <= x"f";
		else
			wb_adr <= p_adr_out;
			wb_dat <= p_dat_out;
			wb_cyc <= p_cyc_out;
			wb_stb <= p_stb_out;
			wb_we <= p_we_out;
			wb_sel <= p_sel_out;
		end if;
	end process arbiter;

	initializer: process
		file imem_file : text open READ_MODE is IMEM_FILENAME;
		file dmem_file : text open READ_MODE is DMEM_FILENAME;
		variable input_line  : line;
		variable input_index : natural;
		variable input_value : std_logic_vector(31 downto 0);
		variable temp : std_logic_vector(31 downto 0);
		
		constant DMEM_START : natural := IMEM_SIZE;
	begin
		if not initialized then
			-- Read the instruction memory file:
			for i in 0 to IMEM_SIZE loop
				exit when endfile(imem_file);
				
				readline(imem_file, input_line);
				hread(input_line, input_value);

				init_adr_out <= std_logic_vector(to_unsigned(i * 4, init_adr_out'length));
				init_dat_out <= input_value;
				init_cyc_out <= '1';
				init_stb_out <= '1';
				wait until imem_ack_out = '1';
				wait for clk_period;
				init_stb_out <= '0';
				wait until imem_ack_out = '0';
				wait for clk_period;
			end loop;

			init_cyc_out <= '0';
			init_stb_out <= '0';
			wait for clk_period;

			-- Read the data memory file:
			for i in 0 to DMEM_SIZE loop
				exit when endfile(dmem_file);
				
				readline(dmem_file, input_line);
				hread(input_line, input_value);


				-- Swap endianness, TODO: prevent this, fix scripts/extract_hex.sh
				temp(7 downto 0) := input_value(31 downto 24);
				temp(15 downto 8) := input_value(23 downto 16);
				temp(23 downto 16) := input_value(15 downto 8);
				temp(31 downto 24) := input_value(7 downto 0);

				input_value := temp;

				init_adr_out <= std_logic_vector(to_unsigned(DMEM_START + (i * 4), init_adr_out'length));
				init_dat_out <= input_value;
				init_cyc_out <= '1';
				init_stb_out <= '1';
				wait until dmem_ack_out = '1';
				wait for clk_period;
				init_stb_out <= '0';
				wait until dmem_ack_out = '0';
				wait for clk_period;
			end loop;

			init_cyc_out <= '0';
			init_stb_out <= '0';
			wait for clk_period;

			initialized <= true;
			wait;
		end if;
	end process initializer;

	clock: process
	begin
		clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
		wait for clk_period / 2;
		
		if simulation_finished then
			wait;
		end if;
	end process clock;

	stimulus: process
	begin
		wait for clk_period * 2;
		reset <= '0';

		wait until initialized;
		processor_reset <= '0';

		wait until tohost_updated = '1';
		wait for clk_period; -- Let the signal "settle", because of stupid clock edges
		if tohost_data = x"00000001" then
			report "Success!" severity NOTE;
		else
			report "Failure in test " & integer'image(to_integer(shift_right(unsigned(tohost_data), 1))) & "!" severity NOTE;
		end if;

		simulation_finished <= true;
		wait;
	end process stimulus;

end architecture testbench;
