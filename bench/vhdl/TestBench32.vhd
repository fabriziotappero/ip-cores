library IEEE;
use IEEE.std_logic_1164.all;
use work.StimLog.all;

entity TestBench32 is
end TestBench32;

architecture behaviour of TestBench32 is

	signal CLK_I		: std_logic := '0';
	signal RST_I		: std_logic := '1';
	signal ACK_I		: std_logic;
	signal TAG0_O		: std_logic;
	signal CYC_O		: std_logic;
	signal STB_O		: std_logic;
	signal WE_O			: std_logic;
	signal ADR_O		: std_logic_vector(15 downto 0);
	signal ADR_O_r		: std_logic_vector(15 downto 0);
	signal DAT_I		: std_logic_vector(7 downto 0);
	signal DAT_O		: std_logic_vector(7 downto 0);
	signal ROM_D		: std_logic_vector(7 downto 0);
	signal RAM_D		: std_logic_vector(7 downto 0);
	signal CS_n			: std_logic;
	signal WE_n			: std_logic;
	signal RXD			: std_logic;
	signal RXD_IsOut	: std_logic;
	signal RXD_Out		: std_logic;
	signal TXD			: std_logic;
	signal INT0			: std_logic := '0';
	signal P0			: std_logic_vector(7 downto 0);
	signal P1			: std_logic_vector(7 downto 0);
	signal P2			: std_logic_vector(7 downto 0);
	signal P3			: std_logic_vector(7 downto 0);
	signal p3_out	: std_logic_vector(7 downto 0);

begin

	u0 : entity work.T8032
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			ACK_I => ACK_I,
			TAG0_O => TAG0_O,
			CYC_O => CYC_O,
			STB_O => STB_O,
			WE_O => WE_O,
			ADR_O => ADR_O,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			P0_in => P0,
			P1_in => P1,
			P2_in => P2,
			P3_in => P3,
			P0_out => P0,
      P1_out => P1,
      P2_out => P2,
      P3_out => P3_out,
			INT0 => INT0,
			INT1 => '1',
			T0 => '1',
			T1 => '1',
			T2 => '1',
			T2EX => '1',
			RXD => RXD,
			RXD_IsO => RXD_IsOut,
			RXD_O => RXD_Out,
			TXD => TXD);

	rom : entity work.ROM52
		port map(
			Clk	=> CLK_I,
			A => ADR_O(12 downto 0),
			D => ROM_D);

	WE_n <= WE_O nand ACK_I;
	CS_n <= '0' when ADR_O(15 downto 11) = "00000" and TAG0_O = '1' else '1';

	ram : entity work.SSRAM
		generic map(
			AddrWidth => 11)
		port map(
			Clk => CLK_I,
			CE_n => '0',
			WE_n => WE_n,
			A => ADR_O(10 downto 0),
			DIn => DAT_O,
			DOut => RAM_D);

	DAT_I <= ROM_D when TAG0_O = '0' else RAM_D when ADR_O(15 downto 11) = "00000" else "11111111";
	ACK_I <= '1' when ADR_O_r = ADR_O else '0';

	P3(0) <= RXD;
  P3(7 downto 1) <= P3_out(7 downto 1);
  
	process (CLK_I)
	begin
		if CLK_I'event and CLK_I = '1' then
			ADR_O_r <= ADR_O;
		end if;
	end process;

	as : AsyncStim
		generic map(FileName => "BASIC.txt", InterCharDelay => 5000 us, Baud => 57600, Bits => 8)
		port map(RXD);


	al : AsyncLog
		generic map(FileName => "RX_Log.txt", Baud => 57600, Bits => 8)
		port map(TXD);

	CLK_I <= not CLK_I after 45 ns;
	RST_I <= '0' after 200 ns;

	INT0 <= not INT0 after 100 us;

end;
