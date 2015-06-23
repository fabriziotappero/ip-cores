-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;

--! @brief Simple UART module.
--! The following registers are defined:
--! 0 - Transmit data register (write-only)
--! 1 - Receive data register (read-only)
--! 2 - Status register; (read-only)
--!     - Bit 0: data in receive buffer
--!     - Bit 1: no data in transmit buffer
--!     - Bit 2: receive buffer full
--!     - Bit 3: transmit buffer full
--! 3 - Control register, currently unused.
entity pp_soc_uart is
	generic(
		FIFO_DEPTH : natural := 64;        --! Depth of the input and output FIFOs.
		SAMPLE_CLK_DIVISOR : natural := 54 --! Divisor used to obtain the sample clock, f_clk / (16 * baudrate).
	);
	port(
		clk : in std_logic;
		reset : in std_logic;

		-- UART ports:
		txd : out std_logic;
		rxd : in  std_logic;

		-- Interrupt signals:
		irq_send_buffer_empty : out std_logic;
		irq_data_received     : out std_logic;

		-- Wishbone ports:
		wb_adr_in  : in  std_logic_vector(1 downto 0);
		wb_dat_in  : in  std_logic_vector(7 downto 0);
		wb_dat_out : out std_logic_vector(7 downto 0);
		wb_we_in   : in  std_logic;
		wb_cyc_in  : in  std_logic;
		wb_stb_in  : in  std_logic;
		wb_ack_out : out std_logic 
	);
end entity pp_soc_uart;

architecture behaviour of pp_soc_uart is

	subtype bitnumber is natural range 0 to 7;

	-- UART sample clock signals:
	signal sample_clk : std_logic;

	subtype sample_clk_counter_type is natural range 0 to SAMPLE_CLK_DIVISOR - 1;
	signal sample_clk_counter : sample_clk_counter_type := 0;

	-- UART receive process signals:
	type rx_state_type is (IDLE, RECEIVE, STOPBIT);
	signal rx_state : rx_state_type;
	signal rx_byte : std_logic_vector(7 downto 0);
	signal rx_current_bit : bitnumber;

	subtype rx_sample_counter_type is natural range 0 to 15;
	signal rx_sample_counter : rx_sample_counter_type;
	signal rx_sample_value   : rx_sample_counter_type;

	-- UART transmit process signals:
	type tx_state_type is (IDLE, TRANSMIT, STOPBIT);
	signal tx_state : tx_state_type;
	signal tx_byte : std_logic_vector(7 downto 0);
	signal tx_current_bit : bitnumber;

	-- UART transmit clock:
	subtype uart_tx_counter_type is natural range 0 to 15;
	signal uart_tx_counter : uart_tx_counter_type := 0;
	signal uart_tx_clk : std_logic;

	-- Buffer signals:
	signal send_buffer_full, send_buffer_empty   : std_logic;
	signal recv_buffer_full, recv_buffer_empty   : std_logic;
	signal send_buffer_input, send_buffer_output : std_logic_vector(7 downto 0);
	signal recv_buffer_input, recv_buffer_output : std_logic_vector(7 downto 0);
	signal send_buffer_push, send_buffer_pop     : std_logic := '0';
	signal recv_buffer_push, recv_buffer_pop     : std_logic := '0';

	-- Wishbone signals:
	type wb_state_type is (IDLE, WRITE_ACK, READ_ACK);
	signal wb_state : wb_state_type;

	signal wb_ack : std_logic; --! Wishbone acknowledge signal

begin

	irq_send_buffer_empty <= send_buffer_empty;
	irq_data_received <= not recv_buffer_empty;

	---------- UART receive ----------

	recv_buffer_input <= rx_byte;

	uart_receive: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rx_state <= IDLE;
			else
				case rx_state is
					when IDLE =>
						if sample_clk = '1' and rxd = '0' then
							rx_sample_value <= rx_sample_counter;
							rx_current_bit <= 0;
							rx_state <= RECEIVE;
						end if;
					when RECEIVE =>
						if sample_clk = '1' and rx_sample_counter = rx_sample_value then
							if rx_current_bit /= 7 then
								rx_byte(rx_current_bit) <= rxd;
								rx_current_bit <= rx_current_bit + 1;
							else
								rx_byte(rx_current_bit) <= rxd;
								rx_state <= STOPBIT;

								if recv_buffer_full = '0' then
									recv_buffer_push <= '1';
								end if;
							end if;
						end if;
					when STOPBIT =>
						recv_buffer_push <= '0';

						if sample_clk = '1' and rx_sample_counter = rx_sample_value then
							rx_state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process uart_receive;

	sample_counter: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rx_sample_counter <= 0;
			elsif sample_clk = '1' then
				if rx_sample_counter = 15 then
					rx_sample_counter <= 0;
				else
					rx_sample_counter <= rx_sample_counter + 1;
				end if;
			end if;
		end if;
	end process sample_counter;

	---------- UART transmit ----------

	tx_byte <= send_buffer_output;

	uart_transmit: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				txd <= '1';
				tx_state <= IDLE;
				send_buffer_pop <= '0';
				tx_current_bit <= 0;
			else
				case tx_state is
					when IDLE =>
						if send_buffer_empty = '0' and uart_tx_clk = '1' then
							txd <= '0';
							send_buffer_pop <= '1';
							tx_current_bit <= 0;
							tx_state <= TRANSMIT;
						elsif uart_tx_clk = '1' then
							txd <= '1';
						end if;
					when TRANSMIT =>
						if send_buffer_pop = '1' then
							send_buffer_pop <= '0';
						elsif uart_tx_clk = '1' and tx_current_bit = 7 then
							txd <= tx_byte(tx_current_bit);
							tx_state <= STOPBIT;
						elsif uart_tx_clk = '1' then
							txd <= tx_byte(tx_current_bit);
							tx_current_bit <= tx_current_bit + 1;
						end if;
					when STOPBIT =>
						if uart_tx_clk = '1' then
							txd <= '1';
							tx_state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process uart_transmit;

	uart_tx_clock_generator: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				uart_tx_counter <= 0;
				uart_tx_clk <= '0';
			else
				if sample_clk = '1' then
					if uart_tx_counter = 15 then
						uart_tx_counter <= 0;
						uart_tx_clk <= '1';
					else
						uart_tx_counter <= uart_tx_counter + 1;
						uart_tx_clk <= '0';
					end if;
				else
					uart_tx_clk <= '0';
				end if;
			end if;
		end if;
	end process uart_tx_clock_generator;

	---------- Sample clock generator ----------

	sample_clock_generator: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				sample_clk_counter <= 0;
				sample_clk <= '0';
			else
				if sample_clk_counter = SAMPLE_CLK_DIVISOR - 1 then
					sample_clk_counter <= 0;
					sample_clk <= '1';
				else
					sample_clk_counter <= sample_clk_counter + 1;
					sample_clk <= '0';
				end if;
			end if;
		end if;
	end process sample_clock_generator;

	---------- Data Buffers ----------

	send_buffer: entity work.pp_fifo
		generic map(
			DEPTH => FIFO_DEPTH,
			WIDTH => 8
		) port map(
			clk => clk,
			reset => reset,
			full => send_buffer_full,
			empty => send_buffer_empty,
			data_in => send_buffer_input,
			data_out => send_buffer_output,
			push => send_buffer_push,
			pop => send_buffer_pop
		);

	recv_buffer: entity work.pp_fifo
		generic map(
			DEPTH => FIFO_DEPTH,
			WIDTH => 8
		) port map(
			clk => clk,
			reset => reset,
			full => recv_buffer_full,
			empty => recv_buffer_empty,
			data_in => recv_buffer_input,
			data_out => recv_buffer_output,
			push => recv_buffer_push,
			pop => recv_buffer_pop
		);

	---------- Wishbone Interface ---------- 

	wb_ack_out <= wb_ack and wb_cyc_in and wb_stb_in;

	wishbone: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				wb_ack <= '0';
				wb_state <= IDLE;
				send_buffer_push <= '0';
			else
				case wb_state is
					when IDLE =>
						if wb_cyc_in = '1' and wb_stb_in = '1' then
							if wb_we_in = '1' then -- Write to register
								if wb_adr_in = b"00" then
									send_buffer_input <= wb_dat_in;
									send_buffer_push <= '1';
									wb_ack <= '1';
									wb_state <= WRITE_ACK;
								else -- Invalid write, just ack and ignore
									wb_ack <= '1';
									wb_state <= WRITE_ACK;
								end if;
							else -- Read from register
								if wb_adr_in = b"01" then
									recv_buffer_pop <= '1';
									wb_state <= READ_ACK;
								elsif wb_adr_in = b"10" then
									wb_dat_out <= x"0" & send_buffer_full & recv_buffer_full & send_buffer_empty & not recv_buffer_empty;
									wb_ack <= '1';
									wb_state <= READ_ACK;
								else
									wb_dat_out <= (others => '0');
									wb_ack <= '1';
									wb_state <= READ_ACK;
								end if;
							end if;
						end if;
					when WRITE_ACK =>
						send_buffer_push <= '0';

						if wb_stb_in = '0' then
							wb_ack <= '0';
							wb_state <= IDLE;
						end if;
					when READ_ACK =>
						if recv_buffer_pop = '1' then
							wb_ack <= '1';
							recv_buffer_pop <= '0';
							wb_dat_out <= recv_buffer_output;
						end if;

						if wb_stb_in = '0' then
							wb_ack <= '0';
							wb_state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process wishbone;

end architecture behaviour;
