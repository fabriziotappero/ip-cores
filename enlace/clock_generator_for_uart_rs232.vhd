--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    10:07:16 10/20/06
-- Design Name:    
-- Module Name:    clock_generator_for_uart_rs232 - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
-- This is a clock generator useful for the RS232 UART
-- The uart_clock must have a frequency of eight times faster than the desired baud rate
-- This clock generator obtains the uart_clock from a 50 MHz clock input
-- Below are some values for the constant "divide_by", which allow to obtain some of the RS232 standard
-- baud rates. Put the desired value in the definition of the constant or adapt this value if
-- you need another baud rate or if your clock input frequency is other than 50 MHz.
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

entity clock_generator_for_uart_rs232 is
    Port ( clk : in std_logic;
	 		  reset : in std_logic;
           uart_clk : out std_logic);
end clock_generator_for_uart_rs232;

architecture Behavioral of clock_generator_for_uart_rs232 is

constant divide_by: integer := 651;

-- For 1200 bps, divide_by = 5208;
-- For 2400 bps, divide_by = 2604;
-- For 4800 bps, divide_by = 1302;
-- For 9600 bps, divide_by = 651;
-- For 19200 bps, divide_by = 325;
-- For 38400 bps, divide_by = 163;
-- For 57600 bps, divide_by = 108;
-- For 115200 bps, divide_by = 54;
-- For 230400 bps, divide_by = 27;
-- For 460800 bps, divide_by = 13;
-- For 921600 bps, divide_by = 7;
-- For 1 Mbps, divide_by = 6;

-- At the higher frequencies, the resulting frequency of the clock output has less accuracy, so maybe
-- there will be some problems with bit snchronization. If this is the case, it is recommended to obtain
-- the needed frequency through another tupe of circuit, like a DLL or PLL

signal count: integer range 0 to ((divide_by / 2) - 1);
signal clk_out: std_logic;

begin

uart_clk <= clk_out;

process (clk, reset, count, clk_out)
begin
	if reset = '1' then
		clk_out <='0';
		count <= 0;
 	elsif
		clk='1' and clk'event then
			if count = ((divide_by / 2) - 1) then
				clk_out <= not clk_out;
				count <= 0;
			else count <= count+1;
			end if;
	end if;
end process;


end Behavioral;
