----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       Aart Mulder
-- 
-- Create Date:    17:41:32 07/11/2012 
-- Design Name: 
-- Module Name:    counter - Behavioral 
-- Project Name:   CCITT4
-- Note:           
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
	Generic (
		COUNTER_WIDTH_G      : integer := 8;    -- Width of the counter
		START_VALUE_G        : integer := 1;    -- Start value of the counter/The value loaded on an overflow
		MAX_VALUE_G          : integer := 255;  -- Value where the counter overflows(Maximum)
		ASYNCHRONOUS_RESET_G : boolean := true; -- Set to true to let the reset be processed on the clock
		OVERFLOW_G           : boolean := true  -- Let the counter overflow
	);
	Port ( 
		reset_i : in  STD_LOGIC;
		clk_i : in  STD_LOGIC;
		en_i : in  STD_LOGIC;
		cnt_o : out  UNSIGNED (COUNTER_WIDTH_G-1 downto 0) := to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
		overflow_o : out STD_LOGIC := '0'  -- High on an overflow, i.e. when START_VALUE_G has been loaded
	);
end counter;

architecture Behavioral of counter is
	--The signal "cnt" is used because an output can't be read and configuring the output
	--as buffer is not desired. Though the synthesiser will create a warning/info.
	signal cnt : UNSIGNED (COUNTER_WIDTH_G-1 downto 0) := to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
begin
	counter_process : process(reset_i, clk_i)
	begin
		if reset_i = '1' and ASYNCHRONOUS_RESET_G then
			cnt <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
			cnt_o <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
			overflow_o <= '0';
		elsif clk_i'event and clk_i = '1' then
			overflow_o <= '0';
			if reset_i = '1' then
				cnt <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
				cnt_o <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
				overflow_o <= '0';
			elsif en_i = '1' then
				if cnt >= to_unsigned(MAX_VALUE_G, COUNTER_WIDTH_G) and OVERFLOW_G then
					cnt <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
					cnt_o <= to_unsigned(START_VALUE_G, COUNTER_WIDTH_G);
					overflow_o <= '1';
				elsif cnt >= to_unsigned(MAX_VALUE_G, COUNTER_WIDTH_G) and not OVERFLOW_G then
					cnt <= cnt;
					cnt_o <= cnt;
					overflow_o <= '0';
				else
					cnt <= cnt + 1;
					cnt_o <= cnt + 1;
				end if;
			end if;
		end if;
	end process counter_process;
end Behavioral;

