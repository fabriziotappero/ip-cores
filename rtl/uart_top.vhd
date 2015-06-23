library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_top is
	generic(address_width : integer := 3);
	port(	clk, master_rst		: in std_logic;
			
			RST_I				: in std_logic;
			ADR_I 				: in std_logic_vector(7 downto 0);
			DAT_I				: in std_logic_vector(7 downto 0);
			WE_I				: in std_logic;
			STB_I				: in std_logic;
			CYC_I				: in std_logic;
			DAT_O				: out std_logic_vector(7 downto 0);
			ACK_O				: out std_logic;
			
			rx					: in std_logic;
			tx					: out std_logic;
			
			rx_fifo_empty		: out std_logic;
			rx_fifo_full		: out std_logic;
			tx_fifo_empty		: out std_logic;
			tx_fifo_full		: out std_logic;			
			parity_error		: out std_logic;
			stop_bit_error		: out std_logic;
			transmitting		: out std_logic);
end entity uart_top;



architecture behaviour of uart_top is
	component uart_wb is
	port(	--WB interface
			CLK_I					: in std_logic;
			master_rst				: in std_logic;
			RST_I					: in std_logic;
			ADR_I 					: in std_logic_vector(7 downto 0);
			DAT_I					: in std_logic_vector(7 downto 0);
			WE_I					: in std_logic;
			STB_I					: in std_logic;
			CYC_I					: in std_logic;
			
			DAT_O					: out std_logic_vector(7 downto 0);
			ACK_O					: out std_logic;
			
			--uart controll
			word_width				: out std_logic_vector(3 downto 0);
			baud_period				: out std_logic_vector(15 downto 0);
			use_parity_bit			: out std_logic;
			parity_type				: out std_logic;
			stop_bits				: out std_logic_vector(1 downto 0);
			idle_line_lvl			: out std_logic;
			rx_enable				: out std_logic;					--rx specific
			start_samples			: out std_logic_vector(3 downto 0);	--rx specific
			line_samples			: out std_logic_vector(3 downto 0);	--rx specific
			uart_rx_rst				: out std_logic;
			uart_rx_fifo_rst		: out std_logic;
			uart_tx_rst				: out std_logic;
			uart_tx_fifo_rst		: out std_logic;
			
			--FIFO control/data
			tx_fifo_entries_free 	: in std_logic_vector (7 downto 0);
			write_tx_data			: out std_logic;
			tx_data					: out std_logic_vector(7 downto 0);
			
			read_rx_data			: out std_logic;
			rx_data					: in std_logic_vector(7 downto 0);
			rx_fifo_entries_free 	: in std_logic_vector (7 downto 0));
	end component;

	component tx_func is
	port(	clk, reset : in std_logic;
			data : in std_logic_vector(7 downto 0);
			transmit_data : in std_logic;
			
			word_width : in std_logic_vector(3 downto 0);
			baud_period : in std_logic_vector(15 downto 0);
			use_parity_bit, parity_type : in std_logic;
			stop_bits : in std_logic_vector(1 downto 0);
			idle_line_lvl : in std_logic;

			tx : out std_logic;
			sending : out std_logic);
	end component;

	component rx_func is
	port(	clk, reset, rx_enable : in std_logic;
			rx : in std_logic;
			
			word_width : in std_logic_vector(3 downto 0);
			baud_period : in std_logic_vector(15 downto 0);
			use_parity_bit, parity_type : in std_logic;
			stop_bits : in std_logic_vector(1 downto 0);
			idle_line_lvl : in std_logic;
			
			start_samples : in std_logic_vector(3 downto 0);	--How many correct samples should give a start bit
			line_samples : in std_logic_vector(3 downto 0);		--How many samples should tip the internal rx value
			
			data 		: out std_logic_vector(7 downto 0);
			data_ready 	: out std_logic;
			parity_error :	out std_logic;
			stop_bit_error : out std_logic);
	end component;

	component rx_fifo is
	generic(address_width : integer := 3);
	port(	clk, reset		: in std_logic;

			read_rx_data	: in  std_logic;
			rx_data 		: out std_logic_vector(7 downto 0);
			rx_fifo_full 	: out std_logic;
			rx_fifo_empty 	: out std_logic;
			rx_fifo_entries_free : out std_logic_vector(7 downto 0);

			rx_func_data		: in std_logic_vector(7 downto 0);
			rx_func_data_ready 	: in std_logic);
	end component;

	component tx_fifo is
	generic(address_width : integer := 3);
	port(	clk, reset		: in std_logic;

			write_tx_data	: in std_logic;
			tx_data 		: in std_logic_vector(7 downto 0);
			tx_fifo_full 	: out std_logic;
			tx_fifo_empty 	: out std_logic;
			tx_fifo_entries_free : out std_logic_vector(7 downto 0);

			tx_func_data		: out std_logic_vector(7 downto 0);
			tx_func_apply_data 	: out std_logic;
			tx_func_sending		: in std_logic);
	end component;

	signal word_width : std_logic_vector(3 downto 0);
	signal baud_period : std_logic_vector(15 downto 0);
	signal start_samples, line_samples : std_logic_vector(3 downto 0);
	signal use_parity_bit, parity_type, idle_line_lvl : std_logic;
	signal uart_rx_rst, uart_tx_rst, uart_rx_fifo_rst, uart_tx_fifo_rst : std_logic;
	signal rx_fifo_entries_free, tx_fifo_entries_free : std_logic_vector(7 downto 0);
	signal read_rx_data, write_tx_data : std_logic;
	signal tx_data, rx_data : std_logic_vector(7 downto 0);
	signal sending : std_logic;
	signal stop_bits : std_logic_vector(1 downto 0);
	signal rx_func_data, tx_func_data : std_logic_vector(7 downto 0);
	signal rx_func_data_ready, tx_func_apply_data : std_logic;
	signal rx_enable: std_logic;

begin
	transmitting <= sending;

	wishBoneInterFace : uart_wb port map (clk, master_rst, RST_I,ADR_I,DAT_I,WE_I,STB_I,CYC_I,DAT_O,ACK_O,word_width,baud_period,use_parity_bit,parity_type,stop_bits,idle_line_lvl,rx_enable,start_samples,line_samples,uart_rx_rst,uart_rx_fifo_rst,uart_tx_rst,uart_tx_fifo_rst,tx_fifo_entries_free,write_tx_data,tx_data,read_rx_data,rx_data,rx_fifo_entries_free);

	UartRx : rx_func port map (clk, uart_rx_rst, rx_enable, rx, word_width, baud_period, use_parity_bit, parity_type, stop_bits, idle_line_lvl, start_samples, line_samples, rx_func_data, rx_func_data_ready,parity_error,stop_bit_error);

	UartTx : tx_func port map(clk, uart_tx_rst, tx_func_data, tx_func_apply_data,word_width,baud_period,use_parity_bit, parity_type,stop_bits,idle_line_lvl,tx,sending);

	RxFifo : rx_fifo generic map(address_width) port map(clk, uart_rx_fifo_rst, read_rx_data, rx_data, rx_fifo_full, rx_fifo_empty, rx_fifo_entries_free, rx_func_data, rx_func_data_ready);
	
	TxFifo : tx_fifo generic map(address_width) port map(clk, uart_tx_fifo_rst, write_tx_data,tx_data,tx_fifo_full,tx_fifo_empty,tx_fifo_entries_free,tx_func_data,tx_func_apply_data,sending);

end architecture behaviour;	