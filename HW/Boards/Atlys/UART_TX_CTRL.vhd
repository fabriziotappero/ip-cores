----------------------------------------------------------------------------
--	UART_TX_CTRL.vhd -- UART Data Transfer Component
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This component may be used to transfer data over a UART device. It will
-- serialize a byte of data and transmit it over a TXD line. The serialized
-- data has the following characteristics:
--         *115200 Baud Rate
--         *8 data bits, LSB first
--         *1 stop bit
--         *no parity
--         				
-- Port Descriptions:
--
--    SEND - Used to trigger a send operation. The upper layer logic should 
--           set this signal high for a single clock cycle to trigger a 
--           send. When this signal is set high DATA must be valid . Should 
--           not be asserted unless READY is high.
--    DATA - The parallel data to be sent. Must be valid the clock cycle
--           that SEND has gone high.
--    CLK  - A 100 MHz clock is expected
--   READY - This signal goes low once a send operation has begun and
--           remains low until it has completed and the module is ready to
--           send another byte.
-- UART_TX - This signal should be routed to the appropriate TX pin of the 
--           external UART device.
--   
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011(SamB): Created using Xilinx Tools 13.2
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity UART_TX_CTRL is
    Port ( SEND : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           READY : out  STD_LOGIC;
           UART_TX : out  STD_LOGIC);
end UART_TX_CTRL;

architecture Behavioral of UART_TX_CTRL is

type TX_STATE_TYPE is (RDY, LOAD_BIT, SEND_BIT);
-- 00101000101100 for 25 MHz 00000110110010
constant BIT_TMR_MAX : std_logic_vector(13 downto 0) := "00000110110010";
--434 = (round(50MHz / 115200)) - 1
constant BIT_INDEX_MAX : natural := 10;

--Counter that keeps track of the number of clock cycles the current bit has been held stable over the
--UART TX line. It is used to signal when the ne
signal bitTmr : std_logic_vector(13 downto 0) := (others => '0');

--combinatorial logic that goes high when bitTmr has counted to the proper value to ensure
--a 9600 baud rate
signal bitDone : std_logic;

--Contains the index of the next bit in txData that needs to be transferred 
signal bitIndex : natural;

--a register that holds the current data being sent over the UART TX line
signal txBit : std_logic := '1';

--A register that contains the whole data packet to be sent, including start and stop bits. 
signal txData : std_logic_vector(9 downto 0);

signal txState : TX_STATE_TYPE := RDY;

begin

--Next state logic
next_txState_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		case txState is 
		when RDY =>
			if (SEND = '1') then
				txState <= LOAD_BIT;
			end if;
		when LOAD_BIT =>
			txState <= SEND_BIT;
		when SEND_BIT =>
			if (bitDone = '1') then
				if (bitIndex = BIT_INDEX_MAX) then
					txState <= RDY;
				else
					txState <= LOAD_BIT;
				end if;
			end if;
		when others=> --should never be reached
			txState <= RDY;
		end case;
	end if;
end process;

bit_timing_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then
			bitTmr <= (others => '0');
		else
			if (bitDone = '1') then
				bitTmr <= (others => '0');
			else
				bitTmr <= bitTmr + 1;
			end if;
		end if;
	end if;
end process;

bitDone <= '1' when (bitTmr = BIT_TMR_MAX) else
				'0';

bit_counting_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then
			bitIndex <= 0;
		elsif (txState = LOAD_BIT) then
			bitIndex <= bitIndex + 1;
		end if;
	end if;
end process;

tx_data_latch_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (SEND = '1') then
			txData <= '1' & DATA & '0';
		end if;
	end if;
end process;

tx_bit_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then
			txBit <= '1';
		elsif (txState = LOAD_BIT) then
			txBit <= txData(bitIndex);
		end if;
	end if;
end process;

UART_TX <= txBit;
READY <= '1' when (txState = RDY) else
			'0';

end Behavioral;

