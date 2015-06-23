--! @file
--! @brief Program Counter (PC)
--! @details The PC is reset to 0000 before the processor runs. Then the PC send the address 0000 to the RAM/ROM,	\n
--! to fetch and exectute the corresponding instruction. After the first instruction is fetched and exectuted 		\n
--! the PC sends the following address 0001 to the RAM/ROM, and so on.															\n
--! The PC is part of the conrtol unit, it counts from 0000 to 1111.																\n
--! It is called pointer; it points to a memory location where instruction is stored.										\n
--! It work as 4-bit counter.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY PC IS
PORT (ep		: in  std_logic;								--! Active high otuput enable from PC, or tri-state
		clr	: in  std_logic; 								--! Active high asynchronous clear
		clk 	: in  std_logic;								--! Falling edge clock
		cp 	: in  std_logic;								--! Active high enable PC to count
      q 		: out std_logic_vector(3 downto 0));	--! 4-bit PC output
END PC ;

ARCHITECTURE behave OF PC IS
signal count :std_logic_vector(3 downto 0);
BEGIN
process (clr,ep,cp,clk,count)
begin
	if clr = '1' then
		q <= "0000";
		count <= "0000";
	elsif cp = '1' then
 		  if falling_edge(clk) then
				if count < "1111" then count <= count + 1;
					else count <= "0000";
				end if;
		   end if; 
 	end if;
	
	if ep = '0' then 
		q <= "ZZZZ";
	else		
		q <= count;
	end if;

end process; 
END behave;

