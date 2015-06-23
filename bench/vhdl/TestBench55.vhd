library IEEE;
use IEEE.std_logic_1164.all;
use work.StimLog.all;

entity TestBench55 is
end TestBench55;

architecture behaviour of TestBench55 is

	signal Clk		: std_logic := '0';
	signal Reset_n	: std_logic := '0';
	signal T0CKI	: std_logic := '0';
	signal Port_A	: std_logic_vector(7 downto 0);
	signal Port_B	: std_logic_vector(7 downto 0);
	signal Port_C	: std_logic_vector(7 downto 0);

begin

	p1 : entity work.P16C55 port map (Clk, Reset_n, T0CKI, Port_A, Port_B, Port_C);

	as : AsyncStim generic map(FileName => "../../../rtl/vhdl/PPX16.vhd", InterCharDelay => 300 us, Baud => 48000, Bits => 8)
				port map(Port_A(1));

	al : AsyncLog generic map(FileName => "RX_Log.txt", Baud => 48000, Bits => 8)
				port map(Port_A(0));

	Clk <= not Clk after 50 ns;
	Reset_n <= '1' after 200 ns;

end;
