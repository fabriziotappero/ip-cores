--! @file
--! @brief Output Register (O)
--! @details This buffer is used to transfer the answer to the probelm being solved to the outside world.	\n
--! At high Ea and low Lo at next clock edge the content of the AC is loaded into the O register.				

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY O IS
port (d 		: in  std_logic_vector(7 downto 0);		--! 8-bit O input from W-bus
      q 		: out std_logic_vector(7 downto 0);		--! 8-bit O output
	  clk		: in  std_logic;								--! Rising edge clock
	  clr		: in  std_logic;								--! Active high asynchronous clear
	  lo 		: in  std_logic);								--! Active low load O content into output 					 
END O ;

ARCHITECTURE behave OF O IS
BEGIN
process (clr,clk,lo,d)
begin
 if clr = '1' then 
    q <= (others => '0');
 elsif lo = '0' then
 	if rising_edge(clk) then
       q <= d;
    end if;
 end if;
end process;
END behave;

