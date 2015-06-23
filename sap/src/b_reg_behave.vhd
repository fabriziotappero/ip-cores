--! @file
--! @brief B register (B)
--! @details It is another buffer register. It is used in arithmetic operations.		\n
--! Its input connected to the W-bus, it transfer the data in when Lb is low. 		\n
--! Its output connected to ALU B input.			

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY B_Reg IS
port (d 		: in  std_logic_vector(7 downto 0);		--! 8-bit B input from W-bus
      q 		: out std_logic_vector(7 downto 0);		--! 8-bit B output to Adder-Subtractor
	  clk		: in  std_logic;								--! Rising edge clock
	  clr		: in  std_logic;								--! Active high asynchronous clear
	  lb 		: in  std_logic);								--! Active low load B content into output 									 
END B_Reg ;

ARCHITECTURE behave OF B_Reg IS
BEGIN
process (clr,clk,lb)
begin
 if clr = '1' then 
    q <= (others => '0');
 elsif lb = '0' then
 	if rising_edge(clk) then
       q <= d;
    end if;
 end if;
end process;
END behave;

