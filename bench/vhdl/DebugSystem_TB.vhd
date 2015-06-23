library IEEE;
use IEEE.std_logic_1164.all;
use work.StimLog.all;

entity DebugSystem_TB is
end entity DebugSystem_TB;

architecture behaviour of DebugSystem_TB is

	signal Reset_n		: std_logic;
	signal Clk			: std_logic := '0';
	signal NMI_n		: std_logic := '1';

	signal TXD0			: std_logic;
	signal RTS0			: std_logic;
	signal DTR0			: std_logic;
	signal RXD0			: std_logic;
	signal CTS0			: std_logic := '0';
	signal DSR0			: std_logic := '0';
	signal RI0			: std_logic := '1';
	signal DCD0			: std_logic := '0';

	signal TXD1			: std_logic;
	signal RTS1			: std_logic;
	signal DTR1			: std_logic;
	signal RXD1			: std_logic;
	signal CTS1			: std_logic := '0';
	signal DSR1			: std_logic := '0';
	signal RI1			: std_logic := '1';
	signal DCD1			: std_logic := '0';

begin

	ni : entity work.DebugSystem
		port map(
			Reset_n => Reset_n,
			Clk => Clk,
			NMI_n => NMI_n,
			RXD0 => RXD0,
			CTS0 => CTS0,
			DSR0 => DSR0,
			RI0 => RI0,
			DCD0 => DCD0,
			RXD1 => RXD1,
			CTS1 => CTS1,
			DSR1 => DSR1,
			RI1 => RI1,
			DCD1 => DCD1,
			TXD0 => TXD0,
			RTS0 => RTS0,
			DTR0 => DTR0,
			TXD1 => TXD1,
			RTS1 => RTS1,
			DTR1 => DTR1);

	as0 : AsyncStim generic map(FileName => "../../../bench/vhdl/ROM80.vhd", InterCharDelay => 0 us, Baud => 115200, Bits => 8)
				port map(RXD0);

	al0 : AsyncLog generic map(FileName => "RX_Log0.txt", Baud => 115200, Bits => 8)
				port map(TXD0);

	as1 : AsyncStim generic map(FileName => "RX_Cmd1.txt", InterCharDelay => 0 us, Baud => 115200, Bits => 8)
				port map(RXD1);

	al1 : AsyncLog generic map(FileName => "RX_Log1.txt", Baud => 115200, Bits => 8)
				port map(TXD1);

	Reset_n <= '0', '1' after 1 us;

	-- 18 MHz clock
	Clk <= not Clk after 27 ns;

end;
