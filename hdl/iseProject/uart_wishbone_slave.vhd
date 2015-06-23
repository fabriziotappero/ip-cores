--! @file
--! @brief Top wishbone slave for the uart (Connects uart_control and uart_communication_blocks)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_wishbone_slave is
    Port ( RST_I : in  STD_LOGIC;								--! Reset Input
           CLK_I : in  STD_LOGIC;								--! Clock Input
           ADR_I0 : in  STD_LOGIC_VECTOR (1 downto 0);	--! Address input
           DAT_I0 : in  STD_LOGIC_VECTOR (31 downto 0);	--! Data Input 0
           DAT_O0 : out  STD_LOGIC_VECTOR (31 downto 0);	--! Data Output 0
           WE_I : in  STD_LOGIC;									--! Write enable input
           STB_I : in  STD_LOGIC;								--! Strobe input (Works like a chip select)
           ACK_O : out  STD_LOGIC;								--! Ack output
			  
			  -- NON-WISHBONE Signals
			  serial_in : in std_logic;							--! Uart serial input
			  data_Avaible : out std_logic;						--! Flag to indicate data avaible					
			  serial_out : out std_logic
			  );
end uart_wishbone_slave;

--! @brief Top uart_wishbone_slave architecture
--! @details Connect the control unit and the communication blocks
architecture Behavioral of uart_wishbone_slave is
component uart_control is
   Port ( rst : in  std_logic;														--! Global reset
           clk : in  std_logic;														--! Global clock
			  WE	: in std_logic;														--! Write enable
           reg_addr : in  std_logic_vector (1 downto 0);			  			--! Register address
			  start : in std_logic;														--! Start (Strobe)
			  done : out std_logic;														--! Done (ACK)
           DAT_I : in  std_logic_vector ((nBitsLarge-1) downto 0);		--! Data Input (Wishbone)
           DAT_O : out  std_logic_vector ((nBitsLarge-1) downto 0);		--! Data output (Wishbone)
			  baud_wait : out std_logic_vector ((nBitsLarge-1) downto 0);	--! Signal to control the baud rate frequency
			  data_byte_tx : out std_logic_vector((nBits-1) downto 0);	  	--! 1 Byte to be send to serial_transmitter
			  data_byte_rx : in std_logic_vector((nBits-1) downto 0);     	--! 1 Byte to be received by serial_receiver
           tx_data_sent : in  std_logic;										  	--! Signal comming from serial_transmitter
			  tx_start : out std_logic;												--! Signal to start sending serial data...
			  rst_comm_blocks : out std_logic;										--! Reset Communication blocks			  
           rx_data_ready : in  std_logic);			
end component;

component uart_communication_blocks is
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
end component;
signal baud_wait : std_logic_vector((nBitsLarge-1) downto 0);
signal tx_data_sent : std_logic;
signal tx_start : std_logic;
signal rst_comm_blocks : std_logic;
signal rx_data_ready : std_logic;
signal data_byte_tx : std_logic_vector(7 downto 0);
signal data_byte_rx : std_logic_vector(7 downto 0);
begin
	--! Instantiate uart_control
	uUartControl : uart_control port map (
		rst => RST_I,
		clk => CLK_I,
		WE	=> WE_I,
		reg_addr => ADR_I0,
		start => STB_I,
		done => ACK_O,
		DAT_I => DAT_I0,
		DAT_O => DAT_O0,
		baud_wait => baud_wait,
		data_byte_tx => data_byte_tx,
		data_byte_rx => data_byte_rx,
		tx_data_sent => tx_data_sent,
		rst_comm_blocks => rst_comm_blocks,
		tx_start => tx_start,
		rx_data_ready => rx_data_ready
	);
	
	--! Instantiate uart_communication_blocks
	uUartCommunicationBlocks : uart_communication_blocks port map (
		rst => rst_comm_blocks,
		clk => CLK_I,
		cycle_wait_baud => baud_wait,
		byte_tx => data_byte_tx,
		byte_rx => data_byte_rx,
		data_sent_tx => tx_data_sent,
		data_received_rx => rx_data_ready,
		serial_out => serial_out,
		serial_in => serial_in,
		start_tx => tx_start
	);
	
	data_Avaible <= rx_data_ready;

end Behavioral;

