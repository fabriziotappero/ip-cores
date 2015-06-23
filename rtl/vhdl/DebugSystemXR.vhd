-- 6502, Monitor ROM, external SRAM interface and two 16450 UARTs
-- that can be synthesized and used with
-- the NoICE debugger that can be found at
-- http://www.noicedebugger.com/

library IEEE;
use IEEE.std_logic_1164.all;

entity DebugSystemXR is
	port(
		Reset_n		: in std_logic;
		Clk			: in std_logic;
		NMI_n		: in std_logic;
		OE_n		: out std_logic;
		WE_n		: out std_logic;
		RAMCS_n		: out std_logic;
		ROMCS_n		: out std_logic;
		PGM_n		: out std_logic;
		A			: out std_logic_vector(16 downto 0);
		D			: inout std_logic_vector(7 downto 0);
		RXD0		: in std_logic;
		CTS0		: in std_logic;
		DSR0		: in std_logic;
		RI0			: in std_logic;
		DCD0		: in std_logic;
		RXD1		: in std_logic;
		CTS1		: in std_logic;
		DSR1		: in std_logic;
		RI1			: in std_logic;
		DCD1		: in std_logic;
		TXD0		: out std_logic;
		RTS0		: out std_logic;
		DTR0		: out std_logic;
		TXD1		: out std_logic;
		RTS1		: out std_logic;
		DTR1		: out std_logic
	);
end entity DebugSystemXR;

architecture struct of DebugSystemXR is

	signal Res_n_s		: std_logic;
	signal Rd_n			: std_logic;
	signal Wr_n			: std_logic;
	signal R_W_n		: std_logic;
	signal A_i			: std_logic_vector(23 downto 0);
	signal D_i			: std_logic_vector(7 downto 0);
	signal ROM_D		: std_logic_vector(7 downto 0);
	signal UART0_D		: std_logic_vector(7 downto 0);
	signal UART1_D		: std_logic_vector(7 downto 0);
	signal CPU_D		: std_logic_vector(7 downto 0);

	signal Rdy			: std_logic;

	signal IOWR_n		: std_logic;
	signal RAMCS_n_i	: std_logic;
	signal UART0CS_n	: std_logic;
	signal UART1CS_n	: std_logic;

	signal BaudOut0		: std_logic;
	signal BaudOut1		: std_logic;

begin

	Rd_n <= not R_W_n or not Rdy;
	Wr_n <= R_W_n or not Rdy;
	OE_n <= not R_W_n;
	WE_n <= Wr_n;
	RAMCS_n <= RAMCS_n_i;
	ROMCS_n <= '1';
	PGM_n <= '1';
	A(14 downto 0) <= A_i(14 downto 0);
	A(16 downto 15) <= "00";
	D <= D_i when R_W_n = '0' else "ZZZZZZZZ";

	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			Res_n_s <= '0';
			Rdy <= '0';
		elsif Clk'event and Clk = '1' then
			Res_n_s <= '1';
			Rdy <= not Rdy;
		end if;
	end process;

	RAMCS_n_i <= A_i(15);
	UART0CS_n <= '0' when A_i(15 downto 3) = "1000000000000" else '1';
	UART1CS_n <= '0' when A_i(15 downto 3) = "1000000010000" else '1';

	CPU_D <=
		D when RAMCS_n_i = '0' else
		UART0_D when UART0CS_n = '0' else
		UART1_D when UART1CS_n = '0' else
		ROM_D;

	u0 : entity work.T65
		port map(
			Mode => "00",
			Res_n => Res_n_s,
			Clk => Clk,
			Rdy => Rdy,
			Abort_n => '1',
			IRQ_n => '1',
			NMI_n => NMI_n,
			SO_n => '1',
			R_W_n => R_W_n,
			Sync => open,
			EF => open,
			MF => open,
			XF => open,
			ML_n => open,
			VP_n => open,
			VDA => open,
			VPA => open,
			A => A_i,
			DI => CPU_D,
			DO => D_i);

	u1 : entity work.Mon65XR
		port map(
			Clk => Clk,
			A => A_i(9 downto 0),
			D => ROM_D);

	u3 : entity work.T16450
		port map(
			MR_n => Res_n_s,
			XIn => Clk,
			RClk => BaudOut0,
			CS_n => UART0CS_n,
			Rd_n => Rd_n,
			Wr_n => Wr_n,
			A => A_i(2 downto 0),
			D_In => D_i,
			D_Out => UART0_D,
			SIn => RXD0,
			CTS_n => CTS0,
			DSR_n => DSR0,
			RI_n => RI0,
			DCD_n => DCD0,
			SOut => TXD0,
			RTS_n => RTS0,
			DTR_n => DTR0,
			OUT1_n => open,
			OUT2_n => open,
			BaudOut => BaudOut0,
			Intr => open);

	u4 : entity work.T16450
		port map(
			MR_n => Res_n_s,
			XIn => Clk,
			RClk => BaudOut1,
			CS_n => UART1CS_n,
			Rd_n => Rd_n,
			Wr_n => Wr_n,
			A => A_i(2 downto 0),
			D_In => D_i,
			D_Out => UART1_D,
			SIn => RXD1,
			CTS_n => CTS1,
			DSR_n => DSR1,
			RI_n => RI1,
			DCD_n => DCD1,
			SOut => TXD1,
			RTS_n => RTS1,
			DTR_n => DTR1,
			OUT1_n => open,
			OUT2_n => open,
			BaudOut => BaudOut1,
			Intr => open);

end;
