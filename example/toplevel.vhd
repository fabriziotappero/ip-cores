-- Practical Test Application for the Potato Processor
-- (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
	port(
		clk       : in std_logic; -- System clock, 100 MHz
		reset_n   : in std_logic; -- CPU reset signal, active low

		-- External interrupt input:
		external_interrupt : in std_logic;

		-- GPIO pins, must be inout to use with the GPIO module:
		switches : inout std_logic_vector(15 downto 0);
		leds     : inout std_logic_vector(15 downto 0);

		-- UART1 (host) pins:
		uart_txd : out std_logic;
		uart_rxd : in  std_logic
	);
end entity toplevel;

architecture behaviour of toplevel is
	signal system_clk : std_logic;
	signal timer_clk : std_logic;

	-- Active high reset signal:
	signal reset : std_logic;

	-- IRQs:
	signal irq   : std_logic_vector(7 downto 0);
	signal uart_irq_rts, uart_irq_recv : std_logic;
	signal timer_irq : std_logic;

	-- Processor wishbone interface:
	signal p_adr_out : std_logic_vector(31 downto 0);
	signal p_dat_out : std_logic_vector(31 downto 0);
	signal p_dat_in  : std_logic_vector(31 downto 0);
	signal p_sel_out : std_logic_vector( 3 downto 0);
	signal p_we_out  : std_logic;
	signal p_cyc_out, p_stb_out : std_logic;
	signal p_ack_in  : std_logic;

	-- Instruction memory wishbone interface:
	signal imem_adr_in  : std_logic_vector(12 downto 0);
	signal imem_dat_out : std_logic_vector(31 downto 0);
	signal imem_cyc_in, imem_stb_in : std_logic;
	signal imem_ack_out : std_logic;

	-- Data memory wishbone interface:
	signal dmem_adr_in  : std_logic_vector(12 downto 0);
	signal dmem_dat_in  : std_logic_vector(31 downto 0);
	signal dmem_dat_out : std_logic_vector(31 downto 0);
	signal dmem_sel_in  : std_logic_vector( 3 downto 0);
	signal dmem_we_in   : std_logic;
	signal dmem_cyc_in, dmem_stb_in : std_logic;
	signal dmem_ack_out : std_logic;

	-- GPIO module I (switches) wishbone interface:
	signal gpio1_adr_in  : std_logic_vector(1 downto 0);
	signal gpio1_dat_in  : std_logic_vector(31 downto 0);
	signal gpio1_dat_out : std_logic_vector(31 downto 0);
	signal gpio1_we_in   : std_logic;
	signal gpio1_cyc_in, gpio1_stb_in : std_logic;
	signal gpio1_ack_out : std_logic;

	-- GPIO module II (LEDs) wishbone interface:
	signal gpio2_adr_in  : std_logic_vector(1 downto 0);
	signal gpio2_dat_in  : std_logic_vector(31 downto 0);
	signal gpio2_dat_out : std_logic_vector(31 downto 0);
	signal gpio2_we_in   : std_logic;
	signal gpio2_cyc_in, gpio2_stb_in : std_logic;
	signal gpio2_ack_out : std_logic;

	-- UART module wishbone interface:
	signal uart_adr_in  : std_logic_vector(1 downto 0);
	signal uart_dat_in  : std_logic_vector(7 downto 0);
	signal uart_dat_out : std_logic_vector(7 downto 0);
	signal uart_we_in   : std_logic;
	signal uart_cyc_in, uart_stb_in : std_logic;
	signal uart_ack_out : std_logic;

	-- Timer module wishbone interface:
	signal timer_adr_in  : std_logic_vector(1 downto 0);
	signal timer_dat_in  : std_logic_vector(31 downto 0);
	signal timer_dat_out : std_logic_vector(31 downto 0);
	signal timer_we_in   : std_logic;
	signal timer_cyc_in, timer_stb_in : std_logic;
	signal timer_ack_out : std_logic;

	-- Dummy module interface:
	signal dummy_dat_in  : std_logic_vector(31 downto 0);
	signal dummy_dat_out : std_logic_vector(31 downto 0);
	signal dummy_we_in   : std_logic;
	signal dummy_cyc_in, dummy_stb_in : std_logic;
	signal dummy_ack_out : std_logic;

	-- Address decoder signals:
	type ad_state_type is (IDLE, BUSY);
	signal ad_state : ad_state_type;

	type module_name is (
			MODULE_IMEM, MODULE_DMEM,	-- Memory modules
			MODULE_GPIO1, MODULE_GPIO2,	-- GPIO modules
			MODULE_UART,	-- UART module
			MODULE_TIMER,	-- Timer module
			MODULE_DUMMY,	-- Dummy module, used for invalid addresses
			MODULE_NONE		-- Boring no-module mode
		);
	signal active_module : module_name;

begin

	reset <= not reset_n;
	irq <= (
			0 => external_interrupt,
			1 => uart_irq_rts, 2 => uart_irq_recv,
			5 => timer_irq, others => '0'
		);

	clkgen: entity work.clock_generator
		port map(
			clk => clk,
			system_clk => system_clk,
			timer_clk => timer_clk
		);

	processor: entity work.pp_potato
		port map(
			clk => system_clk,
			reset => reset,
			irq => irq,
			fromhost_data => (others => '0'),
			fromhost_updated => '0',
			tohost_data => open,
			tohost_updated => open,
			wb_adr_out => p_adr_out,
			wb_dat_out => p_dat_out,
			wb_dat_in => p_dat_in,
			wb_sel_out => p_sel_out,
			wb_we_out => p_we_out,
			wb_cyc_out => p_cyc_out,
			wb_stb_out => p_stb_out,
			wb_ack_in => p_ack_in
		);

	imem: entity work.imem_wrapper
		port map(
			clk => system_clk,
			reset => reset,
			wb_adr_in => imem_adr_in,
			wb_dat_out => imem_dat_out,
			wb_cyc_in => imem_cyc_in,
			wb_stb_in => imem_stb_in,
			wb_ack_out => imem_ack_out
		);

	dmem: entity work.pp_soc_memory
		generic map(
			MEMORY_SIZE => 8192
		) port map(
			clk => system_clk,
			reset => reset,
			wb_adr_in => dmem_adr_in,
			wb_dat_in => dmem_dat_in,
			wb_dat_out => dmem_dat_out,
			wb_sel_in => dmem_sel_in,
			wb_we_in => dmem_we_in,
			wb_cyc_in => dmem_cyc_in,
			wb_stb_in => dmem_stb_in,
			wb_ack_out => dmem_ack_out
		);

	gpio1: entity work.pp_soc_gpio
		generic map(
			NUM_GPIOS => 16
		) port map(
			clk => system_clk,
			reset => reset,
			gpio => switches,
			wb_adr_in => gpio1_adr_in,
			wb_dat_in => gpio1_dat_in,
			wb_dat_out => gpio1_dat_out,
			wb_cyc_in => gpio1_cyc_in,
			wb_stb_in => gpio1_stb_in,
			wb_we_in => gpio1_we_in,
			wb_ack_out => gpio1_ack_out
		);

	gpio2: entity work.pp_soc_gpio
		generic map(
			NUM_GPIOS => 16
		) port map(
			clk => system_clk,
			reset => reset,
			gpio => leds,
			wb_adr_in => gpio2_adr_in,
			wb_dat_in => gpio2_dat_in,
			wb_dat_out => gpio2_dat_out,
			wb_cyc_in => gpio2_cyc_in,
			wb_stb_in => gpio2_stb_in,
			wb_we_in => gpio2_we_in,
			wb_ack_out => gpio2_ack_out
		);

	uart1: entity work.pp_soc_uart
		generic map(
			FIFO_DEPTH => 64,
			SAMPLE_CLK_DIVISOR => 27 -- For 50 MHz
			--SAMPLE_CLK_DIVISOR => 33 -- For 60 MHz
		) port map(
			clk => system_clk,
			reset => reset,
			txd => uart_txd,
			rxd => uart_rxd,
			irq_send_buffer_empty => uart_irq_rts,
			irq_data_received => uart_irq_recv,
			wb_adr_in => uart_adr_in,
			wb_dat_in => uart_dat_in,
			wb_dat_out => uart_dat_out,
			wb_cyc_in => uart_cyc_in,
			wb_stb_in => uart_stb_in,
			wb_we_in => uart_we_in,
			wb_ack_out => uart_ack_out
		);

	timer1: entity work.pp_soc_timer
		port map(
			clk => system_clk,
			reset => reset,
			irq => timer_irq,
			wb_adr_in => timer_adr_in,
			wb_dat_in => timer_dat_in,
			wb_dat_out => timer_dat_out,
			wb_cyc_in => timer_cyc_in,
			wb_stb_in => timer_stb_in,
			wb_we_in => timer_we_in,
			wb_ack_out => timer_ack_out
		);

	dummy: entity work.pp_soc_dummy
		port map(
			clk => system_clk,
			reset => reset,
			wb_dat_in => dummy_dat_in,
			wb_dat_out => dummy_dat_out,
			wb_cyc_in => dummy_cyc_in,
			wb_stb_in => dummy_stb_in,
			wb_we_in => dummy_we_in,
			wb_ack_out => dummy_ack_out
		);

	imem_cyc_in <= p_cyc_out when active_module = MODULE_IMEM else '0';
	dmem_cyc_in <= p_cyc_out when active_module = MODULE_DMEM else '0';
	gpio1_cyc_in <= p_cyc_out when active_module = MODULE_GPIO1 else '0';
	gpio2_cyc_in <= p_cyc_out when active_module = MODULE_GPIO2 else '0';
	uart_cyc_in <= p_cyc_out when active_module = MODULE_UART else '0';
	timer_cyc_in <= p_cyc_out when active_module = MODULE_TIMER else '0';
	dummy_cyc_in <= p_cyc_out when active_module = MODULE_DUMMY else '0';

	imem_stb_in <= p_stb_out when active_module = MODULE_IMEM else '0';
	dmem_stb_in <= p_stb_out when active_module = MODULE_DMEM else '0';
	gpio1_stb_in <= p_stb_out when active_module = MODULE_GPIO1 else '0';
	gpio2_stb_in <= p_stb_out when active_module = MODULE_GPIO2 else '0';
	uart_stb_in <= p_stb_out when active_module = MODULE_UART else '0';
	timer_stb_in <= p_stb_out when active_module = MODULE_TIMER else '0';
	dummy_stb_in <= p_stb_out when active_module = MODULE_DUMMY else '0';

	imem_adr_in <= p_adr_out(12 downto 0);
	dmem_adr_in <= p_adr_out(12 downto 0);
	gpio1_adr_in <= p_adr_out(3 downto 2);
	gpio2_adr_in <= p_adr_out(3 downto 2);
	uart_adr_in <=  p_adr_out(3 downto 2);
	timer_adr_in <= p_adr_out(3 downto 2);

	dmem_dat_in <= p_dat_out;
	gpio1_dat_in <= p_dat_out;
	gpio2_dat_in <= p_dat_out;
	uart_dat_in <= p_dat_out(7 downto 0);
	timer_dat_in <= p_dat_out;
	dummy_dat_in <= p_dat_out;

	dmem_sel_in <= p_sel_out;

	gpio1_we_in <= p_we_out;
	gpio2_we_in <= p_we_out;
	dmem_we_in <= p_we_out;
	uart_we_in <= p_we_out;
	timer_we_in <= p_we_out;
	dummy_we_in <= p_we_out;

	address_decoder: process(system_clk)
	begin
		if rising_edge(system_clk) then
			if reset = '1' then
				ad_state <= IDLE;
				active_module <= MODULE_NONE;
			else
				case ad_state is
					when IDLE =>
						if p_cyc_out = '1' then
							if p_adr_out(31 downto 13) = b"0000000000000000000" then
								active_module <= MODULE_IMEM;
								ad_state <= BUSY;
							elsif p_adr_out(31 downto 13) = b"0000000000000000001" then -- 0x2000
								active_module <= MODULE_DMEM;
								ad_state <= BUSY;
							elsif p_adr_out(31 downto 11) = b"000000000000000001000" then -- 0x4000
								active_module <= MODULE_GPIO1;
								ad_state <= BUSY;
							elsif p_adr_out(31 downto 11) = b"000000000000000001001" then -- 0x4800
								active_module <= MODULE_GPIO2;
								ad_state <= BUSY;
							elsif p_adr_out(31 downto 11) = b"000000000000000001010" then -- 0x5000
								active_module <= MODULE_UART;
								ad_state <= BUSY;
							elsif p_adr_out(31 downto 11) = b"000000000000000001011" then -- 0x5800
								active_module <= MODULE_TIMER;
								ad_state <= BUSY;
							else
								active_module <= MODULE_DUMMY;
								ad_state <= BUSY;
							end if;
						else
							active_module <= MODULE_NONE;
						end if;
					when BUSY =>
						if p_cyc_out = '0' then
							active_module <= MODULE_NONE;
							ad_state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process address_decoder;

	module_mux: process(active_module, imem_ack_out, imem_dat_out, dmem_ack_out, dmem_dat_out,
		gpio1_ack_out, gpio1_dat_out, gpio2_ack_out, gpio2_dat_out, uart_ack_out, uart_dat_out,
		timer_ack_out, timer_dat_out, dummy_ack_out, dummy_dat_out)
	begin
		case active_module is
			when MODULE_IMEM =>
				p_ack_in <= imem_ack_out;
				p_dat_in <= imem_dat_out;
			when MODULE_DMEM =>
				p_ack_in <= dmem_ack_out;
				p_dat_in <= dmem_dat_out;
			when MODULE_GPIO1 =>
				p_ack_in <= gpio1_ack_out;
				p_dat_in <= gpio1_dat_out;
			when MODULE_GPIO2 =>
				p_ack_in <= gpio2_ack_out;
				p_dat_in <= gpio2_dat_out;
			when MODULE_UART =>
				p_ack_in <= uart_ack_out;
				p_dat_in <= (31 downto 8 => '0') & uart_dat_out;
			when MODULE_TIMER =>
				p_ack_in <= timer_ack_out;
				p_dat_in <= timer_dat_out;
			when MODULE_DUMMY =>
				p_ack_in <= dummy_ack_out;
				p_dat_in <= dummy_dat_out;
			when MODULE_NONE =>
				p_ack_in <= '0';
				p_dat_in <= (others => '0');
		end case;
	end process module_mux;

end architecture behaviour;
