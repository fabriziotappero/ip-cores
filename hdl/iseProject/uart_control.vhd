--! @file
--! @brief Uart control unit
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_control is
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
           rx_data_ready : in  std_logic);										--! Signal comming from serial_receiver
end uart_control;

--! @brief Uart control unit
--! @details Configure, commands, the uart_communication_blocks
architecture Behavioral of uart_control is
signal config_clk : std_logic_vector((nBitsLarge-1) downto 0);
signal config_baud : std_logic_vector((nBitsLarge-1) downto 0);
signal received_byte : std_logic_vector((nBits-1) downto 0);
signal byte_to_transmit : std_logic_vector((nBits-1) downto 0);

signal sigDivRst : std_logic;
signal sigDivDone : std_logic;
signal sigDivQuotient : std_logic_vector((nBitsLarge-1) downto 0);
signal sigDivNumerator : std_logic_vector((nBitsLarge-1) downto 0);
signal sigDivDividend : std_logic_vector((nBitsLarge-1) downto 0);

-- Signals used to control the configuration
signal startConfigBaud : std_logic;
signal startConfigClk : std_logic;
signal startDataSend : std_logic;
signal commBlocksInitiated : std_logic;
signal startReadReg : std_logic;
signal alreadyConfBaud : std_logic;
signal alreadyConfClk : std_logic;

-- Divisor component
component divisor is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;			  
           quotient : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
			  reminder : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           numerator : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           divident : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           done : out  STD_LOGIC);
end component;

begin
	--! Instantiate block for calculate division
	uDiv : divisor port map (
		rst => sigDivRst,
		clk => clk,
		quotient => sigDivQuotient,
		reminder => open,	-- Indicates that this port will not be connected to anything
		numerator => sigDivNumerator,
		divident => sigDivDividend,
		done => sigDivDone
	);
	
	-- Process to handle the of writting the registers
	process (clk)
	begin
		-- On the wishbone specification we should handle the reset synchronously
		if rising_edge(clk) then
			if rst = '1' then
				config_clk <= (others => '0');
				config_baud <= (others => '0');
				byte_to_transmit <= (others => '0');
				startConfigBaud <= '0';
				startConfigClk <= '0';
				startDataSend <= '0';					
				alreadyConfClk <= '0';
				alreadyConfBaud <= '0';
			elsif (WE and start) = '1'	then				
				case reg_addr is
					when "00" =>
						config_clk <= DAT_I;						
						startConfigClk <= '1';
						startDataSend <= '0';
						startConfigBaud <= '0';
						alreadyConfClk <= '1';
					when "01" =>
						config_baud <= DAT_I;
						startConfigBaud <= '1';						
						startDataSend <= '0';
						startConfigClk <= '0';
						alreadyConfBaud <= '1';
					when "10" =>
						byte_to_transmit <= DAT_I((nBits-1) downto 0);
						startConfigBaud <= '0';
						startConfigClk <= '0';
						startDataSend <= '1';
					when others =>
						startConfigBaud <= '0';
						startConfigClk <= '0';
						startDataSend <= '0';
				end case;
			else
				startDataSend <= '0';
			end if;
		end if;
	end process;
	
	-- Process to handle the reading of registers
	process (clk)
	begin
		-- On the wishbone specification we should handle the reset synchronously
		if rising_edge(clk) then
			if rst = '1' then
				DAT_O <= (others => 'Z');
				startReadReg <= '0';
			elsif ((WE = '0') and (start = '1')) then
				startReadReg <= '1';
				case reg_addr is
					when "00" =>
						DAT_O <= config_clk;
					when "01" =>						
						DAT_O <= config_baud;
					when "10" =>						
						DAT_O <= conv_std_logic_vector(0, (nBitsLarge-nBits)) & byte_to_transmit;
					when "11" =>
						DAT_O <= conv_std_logic_vector(0, (nBitsLarge-nBits)) & received_byte;
					when others =>
						null;
				end case;			
			end if;
		end if;
	end process;
	
	-- Process that stores the data that comes from the serial receiver block
	process (rx_data_ready)
	begin
		if rising_edge(rx_data_ready) then
			received_byte <= data_byte_rx;
		else
			received_byte <= received_byte;
		end if;
	end process;
	
	-- Process to send data over the serial transmitter
	process (clk)	
	variable sendDataStates : sendByte;
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				sendDataStates := idle;
			else								
				case sendDataStates is
					when idle =>
						if commBlocksInitiated = '1' and startDataSend = '1' then
							sendDataStates := prepare_byte;
						end if;
					
					when prepare_byte =>
						data_byte_tx <= byte_to_transmit;						
						tx_start <= '0';
						sendDataStates := start_sending;
					
					when start_sending =>
						tx_start <= '1';
						sendDataStates := wait_completion;
					
					when wait_completion =>
						if tx_data_sent = '1' then
							sendDataStates := idle;
						end if;
				end case;								
			end if;
		end if;
	end process;
	
	-- Process to send the ACK signal, remember that optimally this ACK should be as fast as possible
	-- to avoid locking the bus, on this case if you send a more bytes then you can transmit the ideal
	-- is to create an error flag to indicate overrun.
	-- On this case on any attempt of reading or writting on registers we will be lock on 1 cycle
	process (clk, rst, startConfigBaud, startConfigClk, startDataSend, startReadReg )	
	variable joinSignal : std_logic_vector(3 downto 0);
	variable cont_steps : integer range 0 to 3;
	begin		
		if rising_edge(clk) then
			if rst = '1' then
				done <= '1';
				cont_steps := 0;
			else
				joinSignal := startConfigBaud & startConfigClk & startDataSend & startReadReg;
				if (joinSignal = "0000") then
					done <= '1';
				else										
					case cont_steps is 
						when 0 =>
							if start = '1' then
								done <= '0';
							end if;													
						when others =>
							done <= '1';
					end case;
					
					if cont_steps < 2 then
						cont_steps := cont_steps + 1;
					else
						cont_steps := 0;
					end if;
				end if;				
			end if;
		end if;				
	end process;
	
	-- Process to calculate the amount of cycles to wait (clock_speed / desired_baud), and initiate the board
	process (alreadyConfClk,alreadyConfBaud, clk)
	variable cont_steps : integer range 0 to 3;
	begin
		if (alreadyConfClk and alreadyConfBaud) = '0' then
			sigDivRst <= '1';
			cont_steps := 0;
			baud_wait <= (others => '0');
			commBlocksInitiated <= '0';
		elsif rising_edge(clk) then
			if cont_steps < 3 then
				cont_steps := cont_steps + 1;
			else
				cont_steps := 3;
			end if;
			
			case cont_steps is
				when 1 =>
					sigDivNumerator <= config_clk;
					sigDivDividend <= config_baud;
					sigDivRst <= '1';				
				when 2 =>
					sigDivRst <= '0';
				when others =>
					null;
			end case;
			
			-- Enable the communication block when the baud is calculated
			if sigDivDone = '1' then
				rst_comm_blocks <= '0';
				baud_wait <= sigDivQuotient;
				commBlocksInitiated <= '1';
			else
				baud_wait <= (others => '0');
				rst_comm_blocks <= '1';
				commBlocksInitiated <= '0';
			end if;
		end if;
	end process;

end Behavioral;

