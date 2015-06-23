library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BinaryDisplay is
	port (
			LED : out std_logic
	);
end BinaryDisplay;

architecture Behavioral of BinaryDisplay is

begin

LED <= '1';
end Behavioral;

