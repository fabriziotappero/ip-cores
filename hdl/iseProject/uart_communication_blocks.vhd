--! @file
--! @brief Top level for interconnection between communication blocks: serial_transmitter, serial_receiver, baud_generator
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_communication_blocks is
    Port ( rst : in  STD_LOGIC;															--! Global reset
           clk : in  STD_LOGIC;															--! Global clock
			  cycle_wait_baud : in std_logic_vector((nBitsLarge-1) downto 0);	--! Number of cycles to wait in order to generate desired baud
           byte_tx : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);				--! Byte to transmit
           byte_rx : out  STD_LOGIC_VECTOR ((nBits-1) downto 0);				--! Byte to receive
           data_sent_tx : out  STD_LOGIC;												--! Indicate that byte has been sent
           data_received_rx : out  STD_LOGIC;										--! Indicate that we got a byte
			  serial_out : out std_logic;													--! Uart serial out
			  serial_in : in std_logic;													--! Uart serial in
           start_tx : in  STD_LOGIC);													--! Initiate transmission
end uart_communication_blocks;

--! @brief Top level for interconnection between communication blocks: serial_transmitter, serial_receiver, baud_generator
--! @details Declare used components for instantiation
architecture Behavioral of uart_communication_blocks is

-- Declare components...
component baud_generator is
    Port ( rst : in STD_LOGIC;														--! Reset Input
			  clk : in  STD_LOGIC;														--! Clock input
           cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Number of cycles to wait for baud generation
			  baud_oversample : out std_logic;										--! Oversample(8x) version of baud (Used on serial_receiver)
           baud : out  STD_LOGIC);													--! Baud generation output (Used on serial_transmitter)
end component;

component serial_transmitter is
     Port ( rst : in  STD_LOGIC;												--! Reset input
           baudClk : in  STD_LOGIC;											--! Baud rate clock input
           data_byte : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);	--! Byte to be sent
			  data_sent : out STD_LOGIC;										--! Indicate that byte has been sent
           serial_out : out  STD_LOGIC);									--! Uart serial output
end component;

component serial_receiver is
    Port ( 
			  rst : in STD_LOGIC;													--! Reset input		  
			  baudOverSampleClk : in  STD_LOGIC;								--! Baud oversampled 8x (Best way to detect start bit)
           serial_in : in  STD_LOGIC;											--! Uart serial input
           data_ready : out  STD_LOGIC;										--! Data received and ready to be read
           data_byte : out  STD_LOGIC_VECTOR ((nBits-1) downto 0));	--! Data byte received
end component;
signal baud_tick : std_logic;
signal baud_tick_oversample : std_logic;
begin
	--! Instantiate baud generator
	uBaudGen : baud_generator port map (
		rst => rst,
		clk => clk,
		cycle_wait => cycle_wait_baud,
		baud_oversample => baud_tick_oversample,
		baud => baud_tick		
	);
	
	--! Instantiate serial_transmitter
	uTransmitter : serial_transmitter port map (
		rst => not start_tx,
		baudClk => baud_tick,
		data_byte => byte_tx,
		data_sent => data_sent_tx,
		serial_out => serial_out 
	);
	
	--! Instantiate serial_receiver
	uReceiver : serial_receiver port map(
		rst => rst,		
		baudOverSampleClk => baud_tick_oversample,
		serial_in => serial_in,
		data_ready => data_received_rx,
		data_byte => byte_rx
	);

end Behavioral;

