----------------------------------------------------------------------------------
-- Creation Date: 13:07:48 27/03/2011 
-- Module Name: RS232/UART Interface - Testbench
-- Used TAB of 4 Spaces
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is

	----------------------------------------------
	-- Constants
	----------------------------------------------
	constant MAIN_CLK_PER	:	time := 20 ns;		-- 50 MHz
	constant MAIN_CLK     : integer := 50;
	constant BAUD_RATE		:	integer := 9600;	-- Bits per Second
	constant RST_LVL		:	std_logic := '1';	-- Active Level of Reset

	----------------------------------------------
	-- Signal Declaration
	----------------------------------------------
	-- Clock and reset Signals
	signal clk_50m					:	std_logic := '0';
	signal rst						:	std_logic;
	-- Transceiver Interface
	signal data_from_transceiver	:	std_logic;
	signal data_to_transceiver		:	std_logic;
	-- Configuration signals
	signal par_en					:	std_logic;
	-- uPC Interface
	signal tx_req					:	std_logic;
	signal tx_end					:	std_logic;
	signal tx_data					:	std_logic_vector(7 downto 0) := x"5A";
	signal rx_ready					:	std_logic;
	signal rx_data					:	std_logic_vector(7 downto 0);

	-- Testbench Signals
	signal uart_clk					:	std_logic := '0';
begin

	----------------------------------------------
	-- Components Instantiation
	----------------------------------------------
	uut:entity work.uart
	generic map(
		CLK_FREQ	=> MAIN_CLK,				-- Main frequency (MHz)
		SER_FREQ	=> BAUD_RATE				-- Baud rate (bps)
	)
	port map(
		-- Control
		clk			=> clk_50m,					-- Main clock
		rst			=> rst,						-- Main reset
		-- External Interface
		rx			=> data_from_transceiver,	-- RS232 received serial data
		tx			=> data_to_transceiver,		-- RS232 transmitted serial data
		-- RS232/UART Configuration
		par_en		=> par_en,					-- Parity bit enable
		-- uPC Interface
		tx_req		=> '1',					-- Request SEND of data
		tx_end		=> tx_end,					-- Data SENDED
		tx_data		=> tx_data,					-- Data to transmit
		rx_ready	=> rx_ready,				-- Received data ready to uPC read
		rx_data		=> rx_data					-- Received data 
	);

	----------------------------------------------
	-- Main Signals Generation
	----------------------------------------------
	-- Main Clock generation
	main_clock_generation:process
	begin
		wait for MAIN_CLK_PER/2;
		clk_50m		<= not clk_50m;
	end process;

	-- UART Clock generation
	uart_clock_generation:process
	begin
		wait for (MAIN_CLK_PER*5208)/2;
		uart_clk	<= not uart_clk;
	end process;

	-- Reset generation
	rst	<=	RST_LVL, not RST_LVL after MAIN_CLK_PER*5;
   data_from_transceiver <= data_to_transceiver;
end Behavioral;

