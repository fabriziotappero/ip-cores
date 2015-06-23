--! @file
--! @brief Accumulator (AC)
--! @details is a buffer register that stores intermediate amswers during a computer run. 
--! It is connected directly to the W-bus (3-state) and Adder-Subtractor/ALU (2-state).

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY AC IS
 port (d 		: in  std_logic_vector(7 downto 0);		--! 8-bit input data to AC from W-bus
       q_alu	: out std_logic_vector(7 downto 0);		--! 8-bit output data to AC from W-bus
		 q_data  : out std_logic_vector(7 downto 0);		--! 8-bit output data to Adder-Subtractor block
       clk		: in  std_logic;								--! Rising edge clock
		 ea		: in  std_logic;								--! Active high enable AC control input signal
		 clr		: in  std_logic;								--! Active high asynchronous clear
		 la 		: in  std_logic);								--! Active low load AC control input signal
END AC ;

ARCHITECTURE behave OF AC IS
BEGIN
process (clr,clk,la,ea,d)
begin
 if clr = '1' then
    q_alu <= (others => '0');
	q_data <= (others => '0');
 elsif rising_edge(clk) then
 	if la = '0' then
		q_alu <= d; q_data <= d;
	end if;
 end if;
end process;
END behave;

