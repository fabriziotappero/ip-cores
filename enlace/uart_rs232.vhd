--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    17:27:44 10/18/06
-- Design Name:    
-- Module Name:    uart_rs232 - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:

-- TRANSMITTER:
-- The transmitter_busy signal keeps activated during the whole transmitting process of a data (start bit, 8 data bits, parity bit and stop bit)
-- The activation of "send_data" during one "clk" clock cycle orders this circuit to capture the character present
-- at the "data_in" inputs and to send it through the RS232 TXD line
-- The activation of the "send_done" signal during one "clk" clock cycle indicates that the character has been sent

-- RECEIVER:
-- The error flags for the received data (start_error, discrepancy_error and stop_error) keep activated only one clock cycle except the parity error flag, that holds its state
-- until a new data is received.
-- The receiver_busy signal keeps activated during the whole receiving process of a data (start bit, 8 data bits, parity bit and stop bit)

-- The activation of "new_data" during one clock cycle indicates the arriving of a new character.

-- BOTH TRANSMITTER AND RECEIVER
-- The uart_clock must have a frequency of eight times faster than the desired baud rate
-- The parity can be selected through the signal even_odd (0: odd/impar; 1: even/par)

-- CLOCK DIVIDER
-- The use of a counter to generate the output clock makes the first period of the output clock only 7 times slower, because
-- the first time, the counter counts from 0 to 3 (3 cycles) and the following times it counts from 3 to 3 (4 cycles)
-- This is not important, since the UART detects the rising edges of this output clock and
-- there are always 8 input clock cycles between two consecutive output clock rising edges.
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rs232 is
    Port ( clk : in std_logic; -- global clock
           reset : in std_logic; -- global reset
--           uart_clk : in std_logic; -- this clock must have a frequency of each times faster than the desired baud rate
           send_data : in std_logic; -- this signal orders to send the data present at the data_in inputs through the TXD line
           data_in : in std_logic_vector(7 downto 0); -- data to be sent
		 even_odd: in std_logic; -- it selects the desired parity (0: odd/impar; 1: even/par)
		 rxd : in std_logic; -- The RS232 RXD line
           txd : out std_logic; -- The RS232 TXD line
           transmitter_busy : out std_logic; -- it indicates that the transmitter is busy sending one character
           send_done : out std_logic; -- it indicates that the character has been sent
           data_out : out std_logic_vector(7 downto 0); -- The data received, in parallel
           parity_error : out std_logic; -- it indicates a parity error in the received data
           start_error : out std_logic; -- it indicates an error in the start bit (false start) of the received data. The receiver will wait for a new complete start bit
           stop_error : out std_logic; -- it indicates an error in the stop bit of the received data (though the data could have been received correctly and it is presented at the outputs).
			  discrepancy_error: out std_logic;  -- it indicates an error because the three samples of the same bit of the data being currently received have different values.
           receiver_busy : out std_logic; -- it indicates that the receiver is busy receiving one character
           new_data : out std_logic -- it indicates that the receiving process has ended and a new character is available
			  );
end uart_rs232;

architecture Behavioral of uart_rs232 is

-- Component declaration

-- RS232 transmitter declaration
	COMPONENT rs232_transmitter
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		send_clk : IN std_logic;
		send_data : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		even_odd : IN std_logic;          
		txd : OUT std_logic;
		busy : OUT std_logic;
		send_done : OUT std_logic
		);
	END COMPONENT;

-- RS232 receiver declaration
	COMPONENT rs232_receiver
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		receive_clk : IN std_logic;
		even_odd : IN std_logic;
		rxd : IN std_logic;          
		data_out : OUT std_logic_vector(7 downto 0);
		parity_error : OUT std_logic;
		start_error : OUT std_logic;
		stop_error : OUT std_logic;
		discrepancy_error : OUT std_logic;
		busy : OUT std_logic;
		new_data : OUT std_logic
		);
	END COMPONENT;

-- Clock divider for transmitter declaration
	COMPONENT divider8_uart
	PORT(
		clk_in : IN std_logic;
		reset : IN std_logic;          
		clk_out_8_times_slow : OUT std_logic
		);
	END COMPONENT;

-- Divisor de clock de la placa 50 Mhz
	COMPONENT clock_generator_for_uart_rs232
    Port ( clk : in std_logic;
	 	 reset : in std_logic;
           uart_clk : out std_logic);
	END COMPONENT;

-- Signals declaration

-- Transmitter
signal send_clk: std_logic;
-- Receiver
signal receive_clk: std_logic;

-- el clk en función de la velocidad
signal uart_clk: std_logic;

-- discriminadorde pulso
signal Q1, Q2, Q3 : std_logic;
signal Ssend_data : std_logic;

begin

-- Signals assignment
receive_clk <= uart_clk;

-- Component instantiation

-- RS232 transmitter instantiation
	Inst_rs232_transmitter: rs232_transmitter PORT MAP(
		clk => clk,
		reset => reset,
		send_clk => send_clk,
		send_data => Ssend_data,
		data_in => data_in,
		even_odd => even_odd,
		txd => txd,
		busy => transmitter_busy,
		send_done => send_done
	);

-- RS232 receiver instantiation
	Inst_rs232_receiver: rs232_receiver PORT MAP(
		clk => clk,
		reset => reset,
		receive_clk => receive_clk,
		even_odd => even_odd,
		rxd => rxd,
		data_out => data_out,
		parity_error => parity_error,
		start_error => start_error,
		stop_error => stop_error,
		discrepancy_error => discrepancy_error,
		busy => receiver_busy,
		new_data => new_data
	);

-- Clock divider for transmitter instantiation
	Inst_divider8_uart: divider8_uart PORT MAP(
		clk_in => uart_clk,
		clk_out_8_times_slow => send_clk,
		reset => reset 
	);

-- Clock divider desde el clock general
	Inst_clock_generator: clock_generator_for_uart_rs232 PORT MAP(
		clk => clk,
		uart_clk => uart_clk,
		reset => reset 
	);

-- Descripción Pulso 
process(clk)
begin
   if (clk'event and clk = '1') then
      if (reset = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0'; 
      else
         Q1 <= send_data;
         Q2 <= Q1;
         Q3 <= Q2;
      end if;
   end if;
end process;
Ssend_data <= Q1 and Q2 and (not Q3);

end Behavioral;
