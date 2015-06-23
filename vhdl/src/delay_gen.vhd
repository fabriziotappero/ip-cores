----------
--! @file
--! @brief This is a positive edge triggered D-flip flop.
----------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY delay_gen IS
    generic (delay_width : integer);
    port (clk	 	: in  std_logic;					--! Rising edge clock
    	  clr  		: in  std_logic;					--! Active high asynchronous reset
          delay_in  	: in  std_logic_vector(delay_width-1 downto 0);		--! Delay input port variable bit-width
          delay_out 	: out std_logic_vector(delay_width-1 downto 0));	--! Delay output port variable bit-width
END ENTITY delay_gen;

ARCHITECTURE behave OF delay_gen IS
BEGIN
    process (clr, clk)
      begin    
        if clr = '1' then
          delay_out <= (others => '0');
        elsif rising_edge(clk) then
          delay_out <= delay_in;
        end if;
      end process;
END ARCHITECTURE behave;

