library IEEE;
use IEEE.std_logic_1164.all;
use work.StimLog.all;

entity TestBench1200 is
end TestBench1200;

architecture behaviour of TestBench1200 is

	signal Clk		: std_logic := '0';
	signal Reset_n	: std_logic := '0';
	signal Port_B	: std_logic_vector(7 downto 0);
	signal Port_D	: std_logic_vector(7 downto 0);

begin

	p1 : entity work.A90S1200 port map (Clk, Reset_n, '1', '1', Port_B, Port_D);

	as : AsyncStim generic map(FileName => "../../../rtl/vhdl/AX8.vhd", InterCharDelay => 200 us, Baud => 115200, Bits => 8)
				port map(Port_D(0));

	al : AsyncLog generic map(FileName => "RX_Log.txt", Baud => 115200, Bits => 8)
				port map(Port_D(1));

	Clk <= not Clk after 50 ns;
	Reset_n <= '1' after 200 ns;

end;
