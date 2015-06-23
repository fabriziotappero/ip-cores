--! @file
--! @brief Memory Address Register (MAR)
--! @details It is part of the processor memory. During a computer run, the address in the PC is latched into the MAR. \n
--! A bit later, the MAR applies this 4-bit address to the RAM, where a read operation is performed.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY MAR IS
 port (CLK		: in  std_logic;								--! Rising edge clock
		CLR		: in  std_logic;								--! Active high asynchronous clear
		Lm 		: in  std_logic;								--! Active low load MAR
 	   D 		  	: in  std_logic_vector(3 downto 0);		--! MAR 4-bit address input
	   Q 		  	: out std_logic_vector(3 downto 0));	--! MAR 4-bit address output
END MAR ;

ARCHITECTURE behave OF MAR IS
BEGIN
process (CLR,CLK,Lm,D)
begin
if CLR = '1' then
	Q <= "0000";
elsif lm = '0' then
	if rising_edge(CLK) then
		Q <= D;
	end if;
end if;
end process;
END behave;
