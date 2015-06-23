------------------------------------------------------------------------
-- File infomation
------------------------------------------------------------------------
-- Tobias N. Jeppe - 22-01-2013
-- Wish Bone interface
-- Implemented with standard single write cycle and single read cycle
-- 8 bit address, 8 bit in and out put data
--
------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_wb is
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
end entity uart_wb;


architecture behaviour of uart_wb is
-- Components
-- Signals
	signal we_ok			: std_logic;
	signal uart_setup_rst 	: std_logic;
	
	signal write_reg_addr_1					: std_logic;
	signal reg_addr_1_q, reg_addr_1_d		: std_logic;

	signal write_reg_addr_100 				: std_logic;
	signal reg_addr_100_q, reg_addr_100_d	: std_logic_vector(7 downto 0); --00000100 = rx_idle_line_lvl(r/w)(rst.1)|x|rx_use_parity(r/w)(rst.0)|rx_parity_type|rx_stop_bits(rw)(rst.01)|word_width
	signal write_reg_addr_101 				: std_logic;
	signal reg_addr_101_q, reg_addr_101_d	: std_logic_vector(7 downto 0); --00000101 = start_samples(4) | reg_samples(4)
	signal write_reg_addr_110 				: std_logic;
	signal reg_addr_110_q, reg_addr_110_d 	: std_logic_vector(7 downto 0); --00000110 = period low  LSB ( 7 downto 0)  (Baud / Frequenzy, min 32, max 655??)
	signal write_reg_addr_111 				: std_logic;
	signal reg_addr_111_q, reg_addr_111_d	: std_logic_vector(7 downto 0); --00000111 = period high MSB (15 downto 8)
	
	signal write_reg_addr_1000				: std_logic;
	signal reg_addr_1000_q, reg_addr_1000_d	: std_logic_vector(4 downto 0); --00001000 = xxx | rst_uart_rx | rst_uart_rx_fifo | rst_uart_tx | rst_uart_tx_fifo | rst_uart_setup
	signal write_reg_addr_1001				: std_logic;
	signal reg_addr_1001_q					: std_logic_vector(4 downto 0);-- := "11111"; --00001001 = xxx | rst_uart_rx_if_rst_wb | rst_uart_rx_fifo_if_rst_wb | rst_uart_tx_if_rst_wb | rst_uart_tx_fifo_if_rst_wb | rst_uart_setup_if_rst_wb | 
	signal reg_addr_1001_d					: std_logic_vector(4 downto 0);	
	
Begin
-------------------------
-- Combinational Logic --
-------------------------
	we_ok 			<= WE_I and CYC_I;
	ACK_O			<= STB_I;

--DAT_O	asynchronous
	with ADR_I select
		DAT_O 	<=	"0000000" & reg_addr_1_q	when "00000001",
					rx_fifo_entries_free 		when "00000010",
					tx_fifo_entries_free 		when "00000011",
					reg_addr_100_q				when "00000100",
					reg_addr_101_q				when "00000101",
					reg_addr_110_q				when "00000110",
					reg_addr_111_q				when "00000111",
					"000" & reg_addr_1000_q		when "00001000",
					"000" & reg_addr_1001_q		when "00001001",
					rx_data						when others;

	rx_enable			<= reg_addr_1_q;
	write_reg_addr_1 	<= '1' when (ADR_I = "00000001" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_1_d		<= '0' when uart_setup_rst = '1' else
							DAT_I(0);

	idle_line_lvl 		<= 	reg_addr_100_q(7);
	use_parity_bit		<= 	reg_addr_100_q(6);
	parity_type			<= 	reg_addr_100_q(5);
	stop_bits			<= 	reg_addr_100_q(4 downto 3);
	word_width			<= 	'0' & reg_addr_100_q(2 downto 0);	--the msb is missing
	write_reg_addr_100 	<= 	'1' when (ADR_I = "00000100" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_100_d 		<= 	"10001000" when uart_setup_rst = '1' else
							DAT_I;
	
	start_samples		<= 	reg_addr_101_q(7 downto 4);
	line_samples		<= 	reg_addr_101_q(3 downto 0);
	write_reg_addr_101	<=	'1' when (ADR_I = "00000101" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_101_d		<= 	"0110" & "0100" when uart_setup_rst = '1' else
							DAT_I;
	
	baud_period			<= 	reg_addr_111_q & reg_addr_110_q;
	write_reg_addr_110	<=	'1' when (ADR_I = "00000110" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_110_d		<= 	"00010000" when uart_setup_rst = '1' else
							DAT_I;
	write_reg_addr_111	<=	'1' when (ADR_I = "00000111" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_111_d		<= 	"00000000" when uart_setup_rst = '1' else
							DAT_I;

	uart_rx_rst			<= (RST_I and reg_addr_1001_q(4)) or reg_addr_1000_q(4) or master_rst;	
	uart_rx_fifo_rst	<= (RST_I and reg_addr_1001_q(3)) or reg_addr_1000_q(3) or master_rst;
	uart_tx_rst			<= (RST_I and reg_addr_1001_q(2)) or reg_addr_1000_q(2) or master_rst;
	uart_tx_fifo_rst	<= (RST_I and reg_addr_1001_q(1)) or reg_addr_1000_q(1) or master_rst;
	uart_setup_rst		<= (RST_I and reg_addr_1001_q(0)) or reg_addr_1000_q(0) or master_rst;
	write_reg_addr_1000	<=	'1' when (ADR_I = "00001000" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_1000_d		<=	"00000" when uart_setup_rst = '1' else
							DAT_I(4 downto 0);
	
	write_reg_addr_1001	<=	'1' when (ADR_I = "00001001" and we_ok = '1') or uart_setup_rst = '1' else
							'0';
	reg_addr_1001_d		<=	"11111" when uart_setup_rst = '1' else
							DAT_I(4 downto 0);
	
	--Write to tx_fifo
	write_tx_data 		<=	'1' when ADR_I = "00000000" and we_ok = '1' else '0';
	tx_data				<=	DAT_I;
	
	--Read from rx_fifo
	read_rx_data		<=	'1' when ADR_I = "00000000" and (WE_I='0' and CYC_I = '1') else '0';

--------------------
-- Register Logic --
--------------------
	register_logic : process(CLK_I, write_reg_addr_100, write_reg_addr_101, write_reg_addr_110,write_reg_addr_111,write_reg_addr_1000,write_reg_addr_1001)
	begin
		if rising_edge(CLK_I) then
			if write_reg_addr_1 = '1' then
				reg_addr_1_q <= reg_addr_1_d;
			end if;
		
			if write_reg_addr_100 = '1' then
				reg_addr_100_q <= reg_addr_100_d;
			end if;
			
			if write_reg_addr_101 = '1' then
				reg_addr_101_q <= reg_addr_101_d;
			end if;
			
			if write_reg_addr_110 = '1' then
				reg_addr_110_q <= reg_addr_110_d;
			end if;
			
			if write_reg_addr_111 = '1' then
				reg_addr_111_q <= reg_addr_111_d;
			end if;
			
			if write_reg_addr_1000 = '1' then
				reg_addr_1000_q <= reg_addr_1000_d;
			end if;
			
			if write_reg_addr_1001 = '1' then
				reg_addr_1001_q <= reg_addr_1001_d;
			end if;
		end if;
	
	end process;

end architecture behaviour;	
