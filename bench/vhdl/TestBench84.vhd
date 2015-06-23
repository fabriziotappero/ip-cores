library IEEE;
use IEEE.std_logic_1164.all;

entity TestBench84 is
end TestBench84;

architecture behaviour of TestBench84 is

	signal Clk		: std_logic := '0';
	signal Reset_n	: std_logic := '0';
	signal T0CKI	: std_logic := '0';
	signal INT		: std_logic := '0';
	signal Port_A	: std_logic_vector(7 downto 0);
	signal Port_B	: std_logic_vector(7 downto 0);

begin

	p1 : entity work.P16F84 port map (Clk, Reset_n, T0CKI, INT, Port_A, Port_B);

	Clk <= not Clk after 50 ns;
	Reset_n <= '1' after 200 ns;
	INT <= not INT after 20 us;

end;
