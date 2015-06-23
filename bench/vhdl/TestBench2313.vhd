library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.StimLog.all;

entity TestBench2313 is
end TestBench2313;

architecture behaviour of TestBench2313 is

	signal	Clk		: std_logic := '0';
	signal	Reset_n	: std_logic := '0';
	signal	RXD		: std_logic;
	signal	TXD		: std_logic;
	signal	OC		: std_logic;
	signal	Port_B	: std_logic_vector(7 downto 0);
	signal	Port_D	: std_logic_vector(7 downto 0);

	signal	KeyboardClk		: std_logic;
	signal	KeyboardData	: unsigned(7 downto 0);

begin

	p1 : entity work.A90S2313 port map(Clk, Reset_n, KeyboardClk, '1', '1', '1', '1', RXD, TXD, OC, Port_B, Port_D);

	as : AsyncStim generic map(FileName => "../../../rtl/vhdl/AX8.vhd", InterCharDelay => 0 us, Baud => 57600, Bits => 8)
				port map(RXD);

	al : AsyncLog generic map(FileName => "RX_Log.txt", Baud => 57600, Bits => 8)
				port map(TXD);

	Clk <= not Clk after 50 ns;
	Reset_n <= '1' after 200 ns;

	-- Generate AT keyboard signals
	process
	begin
		Port_D(3) <= '1';
		KeyboardClk <= '1';
		KeyboardData <= "00000110";
		loop
			wait for 400 us;
			for i in 0 to 10 loop
				if i = 0 then
					Port_D(3) <= '0';
				elsif i = 9 then
					Port_D(3) <= not KeyboardData(0) xor
								KeyboardData(1) xor
								KeyboardData(2) xor
								KeyboardData(3) xor
								KeyboardData(4) xor
								KeyboardData(5) xor
								KeyboardData(6) xor
								KeyboardData(7);
				elsif i = 10 then
					Port_D(3) <= '1';
				else
					Port_D(3) <= KeyboardData(i - 1);
				end if;
				wait for 20 us;
				KeyboardClk <= '0';
				wait for 20 us;
				KeyboardClk <= '1';
			end loop;
			KeyboardData <= KeyboardData + 1;
		end loop;
	end process;

end;
