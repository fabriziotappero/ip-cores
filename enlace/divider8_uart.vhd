------------------------------------------------------------------
--  divider8_uart.vhd -- 
-- This circuit generates a clock signal with a frequency 8 times slower
-- than the input clock frequency.
-- The use of a counter to generate the output clock makes the first period of the output clock only 7 times slower, because
-- the first time, the counter counts from 0 to 3 (3 cycles) and the following times it counts from 3 to 3 (4 cycles)
-- This is not important, since the UART detects the rising edges of this output clock and
-- there are always 8 input clock cycles between two consecutive output clock rising edges.

------------------------------------------------------------------
-- Luis Jacobo Alvarez Ruiz de Ojeda
-- Dpto. Tecnologia Electronica
-- University of Vigo
-- 18, October, 2006 
------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divider8_uart is
    Port ( clk_in : in std_logic;
           clk_out_8_times_slow : out std_logic;
			  reset: in std_logic
			  );
end divider8_uart;

architecture Behavioral of divider8_uart is
signal count: integer range 0 to 3;
signal clk_out_aux: std_logic;

begin

clk_out_8_times_slow <= clk_out_aux;

process (reset, clk_in, count, clk_out_aux)
begin
	if reset = '1' then 	clk_out_aux <='0';
								count <= 0;
 	elsif (clk_in='1' and clk_in'event) then
			if count = 3 then clk_out_aux <= not clk_out_aux;
							      count <= 0;
			else count <= count+1;
			end if;
	end if;
end process;

end Behavioral;
