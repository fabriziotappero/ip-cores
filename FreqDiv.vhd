library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity FreqDiv is
    Port ( Clk : in  STD_LOGIC;
           Clk2 : out  STD_LOGIC);
end FreqDiv;
architecture Behavioral of FreqDiv is
signal counter : STD_LOGIC_VECTOR (19 downto 0);
begin
Clk2 <= counter(19);
process (Clk) begin
	if (rising_edge(Clk)) then
		counter <= counter + 1;
	end if;
end process;
end Behavioral;