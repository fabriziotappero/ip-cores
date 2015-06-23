LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity led_driver is
	port
	(
		ENABLE			: in std_logic;
		BYTE		    : in std_logic_vector(7 downto 0);
		LEDBYTE     	: out std_logic_vector(7 downto 0)
	);
end led_driver;

architecture rtl of led_driver is
begin
process(ENABLE, BYTE)
begin     
	if (ENABLE = '1')then
		LEDBYTE <= BYTE; 		
	end if; 
end process;
end rtl;

