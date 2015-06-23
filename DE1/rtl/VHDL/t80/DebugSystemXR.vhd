-- Z80, Monitor ROM, external SRAM interface and two 16450 UARTs
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

	signal M1_n			: std_logic;
	signal MREQ_n		: std_logic;
	signal IORQ_n		: std_logic;
	signal RD_n			: std_logic;
	signal WR_n			: std_logic;
	signal RFSH_n		: std_logic;
	signal HALT_n		: std_logic;
	signal WAIT_n		: std_logic;
	signal INT_n		: std_logic;
	signal RESET_s		: std_logic;
	signal BUSRQ_n		: std_logic;
	signal BUSAK_n		: std_logic;
	signal A_i			: std_logic_vector(15 downto 0);
	signal D_i			: std_logic_vector(7 downto 0);
	signal ROM_D		: std_logic_vector(7 downto 0);
	signal UART0_D		: std_logic_vector(7 downto 0);
	signal UART1_D		: std_logic_vector(7 downto 0);
	signal CPU_D		: std_logic_vector(7 downto 0);

	signal Mirror		: std_logic;

	signal IOWR_n		: std_logic;
	signal RAMCS_n_i	: std_logic;
	signal UART0CS_n	: std_logic;
	signal UART1CS_n	: std_logic;

	signal BaudOut0		: std_logic;
	signal BaudOut1		: std_logic;

begin

	Wait_n <= '1';
	BusRq_n <= '1';
	INT_n <= '1';

	OE_n <= RD_n;
	WE_n <= WR_n;
	RAMCS_n <= RAMCS_n_i;
	ROMCS_n <= '1';
	PGM_n <= '1';
	A(14 downto 0) <= A_i(14 downto 0);
	A(16 downto 15) <= "00";
	D <= D_i when WR_n = '0' else "ZZZZZZZZ";

	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			Reset_s <= '0';
			Mirror <= '0';
		elsif Clk'event and Clk = '1' then
			Reset_s <= '1';
			if IORQ_n = '0' and A_i(7 downto 4) = "1111" then
				Mirror <= D_i(0);
			end if;
		end if;
	end process;

	IOWR_n <= WR_n or IORQ_n;
	RAMCS_n_i <= (not Mirror and not A_i(15)) or MREQ_n;
	UART0CS_n <= '0' when IORQ_n = '0' and A_i(7 downto 3) = "00000" else '1';
	UART1CS_n <= '0' when IORQ_n = '0' and A_i(7 downto 3) = "10000" else '1';

	CPU_D <=
		D when RAMCS_n_i = '0' else
		UART0_D when UART0CS_n = '0' else
		UART1_D when UART1CS_n = '0' else
		ROM_D;

	u0 : entity work.T80s
			generic map(Mode => 1, T2Write => 1, IOWait => 0)
			port map(
				RESET_n => RESET_s,
				CLK_n => Clk,
				WAIT_n => WAIT_n,
				INT_n => INT_n,
				NMI_n => NMI_n,
				BUSRQ_n => BUSRQ_n,
				M1_n => M1_n,
				MREQ_n => MREQ_n,
				IORQ_n => IORQ_n,
				RD_n => RD_n,
				WR_n => WR_n,
				RFSH_n => RFSH_n,
				HALT_n => HALT_n,
				BUSAK_n => BUSAK_n,
				A => A_i,
				DI => CPU_D,
				DO => D_i);

	u1 : entity work.MonZ80
			port map(
				Clk => Clk,
				A => A_i(10 downto 0),
				D => ROM_D);

	u3 : entity work.T16450
			port map(
				MR_n => Reset_s,
				XIn => Clk,
				RClk => BaudOut0,
				CS_n => UART0CS_n,
				Rd_n => RD_n,
				Wr_n => IOWR_n,
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
				MR_n => Reset_s,
				XIn => Clk,
				RClk => BaudOut1,
				CS_n => UART1CS_n,
				Rd_n => RD_n,
				Wr_n => IOWR_n,
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
