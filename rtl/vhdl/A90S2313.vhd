--
-- 90S2313 compatible microcontroller core
--
-- Version : 0224
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/ax8/
--
-- Limitations :
--
-- File history :
--
--	0146	: First release
--	0220	: Changed to synchronous ROM
--	0220b	: Changed reset
--	0221	: Changed to configurable buses
--	0224	: Fixed timer interrupt enables

--Registers:												Comments:
--$3F SREG Status Register									Implemented in the AX8 core
--$3D SPL Stack Pointer Low									Implemented in the AX8 core
--$3B GIMSK General Interrupt Mask register
--$3A GIFR General Interrupt Flag Register
--$39 TIMSK Timer/Counter Interrupt Mask register
--$38 TIFR Timer/Counter Interrupt Flag register
--$35 MCUCR MCU General Control Register					No power down
--$33 TCCR0 Timer/Counter 0 Control Register
--$32 TCNT0 Timer/Counter 0 (8-bit)
--$2F TCCR1A Timer/Counter 1 Control Register A
--$2E TCCR1B Timer/Counter 1 Control Register B
--$2D TCNT1H Timer/Counter 1 High Byte
--$2C TCNT1L Timer/Counter 1 Low Byte
--$2B OCR1AH Output Compare Register 1 High Byte
--$2A OCR1AL Output Compare Register 1 Low Byte
--$25 ICR1H T/C 1 Input Capture Register High Byte
--$24 ICR1L T/C 1 Input Capture Register Low Byte
--$21 WDTCR Watchdog Timer Control Register					Not implemented
--$1E EEAR EEPROM Address Register							Not implemented
--$1D EEDR EEPROM Data Register								Not implemented
--$1C EECR EEPROM Control Register							Not implemented
--$18 PORTB Data Register, Port B							No pullup
--$17 DDRB Data Direction Register, Port B
--$16 PINB Input Pins, Port B
--$12 PORTD Data Register, Port D							No pullup
--$11 DDRD Data Direction Register, Port D
--$10 PIND Input Pins, Port D
--$0C UDR UART I/O Data Register
--$0B USR UART Status Register
--$0A UCR UART Control Register
--$09 UBRR UART Baud Rate Register
--$08 ACSR Analog Comparator Control and Status Register	Not implemented

library IEEE;
use IEEE.std_logic_1164.all;
use work.AX_Pack.all;

entity A90S2313 is
	generic(
		SyncReset : boolean := true;
		TriState : boolean := false
	);
	port(
		Clk		: in std_logic;
		Reset_n	: in std_logic;
		INT0	: in std_logic;
		INT1	: in std_logic;
		T0		: in std_logic;
		T1		: in std_logic;
		ICP		: in std_logic;
		RXD		: in std_logic;
		TXD		: out std_logic;
		OC		: out std_logic;
		Port_B	: inout std_logic_vector(7 downto 0);
		Port_D	: inout std_logic_vector(7 downto 0)
	);
end A90S2313;

architecture rtl of A90S2313 is

	constant	ROMAddressWidth		: integer := 10;
	constant	RAMAddressWidth		: integer := 7;
	constant	BigISet				: boolean := true;

	component ROM2313
		port(
			Clk	: in std_logic;
			A	: in std_logic_vector(ROMAddressWidth - 1 downto 0);
			D	: out std_logic_vector(15 downto 0)
		);
	end component;

	signal	Reset_s_n	: std_logic;
	signal	ROM_Addr	: std_logic_vector(ROMAddressWidth - 1 downto 0);
	signal	ROM_Data	: std_logic_vector(15 downto 0);
	signal	SREG		: std_logic_vector(7 downto 0);
	signal	SP			: std_logic_vector(15 downto 0);
	signal	IO_Rd		: std_logic;
	signal	IO_Wr		: std_logic;
	signal	IO_Addr		: std_logic_vector(5 downto 0);
	signal	IO_WData	: std_logic_vector(7 downto 0);
	signal	IO_RData	: std_logic_vector(7 downto 0);
	signal	TCCR0_Sel	: std_logic;
	signal	TCNT0_Sel	: std_logic;
	signal	TCCR1_Sel	: std_logic;
	signal	TCNT1_Sel	: std_logic;
	signal	OCR1_Sel	: std_logic;
	signal	ICR1_Sel	: std_logic;
	signal	UDR_Sel		: std_logic;
	signal	USR_Sel		: std_logic;
	signal	UCR_Sel		: std_logic;
	signal	UBRR_Sel	: std_logic;
	signal	PORTB_Sel	: std_logic;
	signal	DDRB_Sel	: std_logic;
	signal	PINB_Sel	: std_logic;
	signal	PORTD_Sel	: std_logic;
	signal	DDRD_Sel	: std_logic;
	signal	PIND_Sel	: std_logic;
	signal	Sleep_En	: std_logic;
	signal	ISC0		: std_logic_vector(1 downto 0);
	signal	ISC1		: std_logic_vector(1 downto 0);
	signal	Int_ET		: std_logic_vector(1 downto 0);
	signal	Int_En		: std_logic_vector(1 downto 0);
	signal	Int0_r		: std_logic_vector(1 downto 0);
	signal	Int1_r		: std_logic_vector(1 downto 0);
	signal	TC_Trig		: std_logic;
	signal	TO_Trig		: std_logic;
	signal	OC_Trig		: std_logic;
	signal	IC_Trig		: std_logic;
	signal	TOIE0		: std_logic;
	signal	TICIE1		: std_logic;
	signal	OCIE1		: std_logic;
	signal	TOIE1		: std_logic;
	signal	TOV0		: std_logic;
	signal	ICF1		: std_logic;
	signal	OCF1		: std_logic;
	signal	TOV1		: std_logic;
	signal	Int_Trig	: std_logic_vector(15 downto 1);
	signal	Int_Acc		: std_logic_vector(15 downto 1);
	signal	TCCR0		: std_logic_vector(2 downto 0);
	signal	TCNT0		: std_logic_vector(7 downto 0);
	signal	COM			: std_logic_vector(1 downto 0);
	signal	PWM			: std_logic_vector(1 downto 0);
	signal	CRBH		: std_logic_vector(1 downto 0);
	signal	CRBL		: std_logic_vector(3 downto 0);
	signal	TCNT1		: std_logic_vector(15 downto 0);
	signal	IC			: std_logic_vector(15 downto 0);
	signal	OCR			: std_logic_vector(15 downto 0);
	signal	Tmp			: std_logic_vector(15 downto 0);
	signal	UDR			: std_logic_vector(7 downto 0);
	signal	USR			: std_logic_vector(7 downto 3);
	signal	UCR			: std_logic_vector(7 downto 0);
	signal	UBRR		: std_logic_vector(7 downto 0);
	signal	DirB		: std_logic_vector(7 downto 0);
	signal	Port_InB	: std_logic_vector(7 downto 0);
	signal	Port_OutB	: std_logic_vector(7 downto 0);
	signal	DirD		: std_logic_vector(7 downto 0);
	signal	Port_InD	: std_logic_vector(7 downto 0);
	signal	Port_OutD	: std_logic_vector(7 downto 0);

begin

	-- Synchronise reset
	process (Reset_n, Clk)
		variable Reset_v : std_logic;
	begin
		if Reset_n = '0' then
			if SyncReset then
				Reset_s_n <= '0';
				Reset_v := '0';
			end if;
		elsif Clk'event and Clk = '1' then
			if SyncReset then
				Reset_s_n <= Reset_v;
				Reset_v := '1';
			end if;
		end if;
	end process;

	g_reset : if not SyncReset generate
		Reset_s_n <= Reset_n;
	end generate;

	-- Registers/Interrupts
	process (Reset_s_n, Clk)
	begin
		if Reset_s_n = '0' then
			Sleep_En <= '0';
			ISC0 <= "00";
			ISC1 <= "00";
			Int_ET <= "00";
			Int_En <= "00";
			Int0_r <= "11";
			Int1_r <= "11";
			TOIE0 <= '0';
			TICIE1 <= '0';
			OCIE1 <= '0';
			TOIE1 <= '0';
			TOV0 <= '0';
			ICF1 <= '0';
			OCF1 <= '0';
			TOV1 <= '0';
		elsif Clk'event and Clk = '1' then
			Int0_r(0) <= INT0;
			Int0_r(1) <= Int0_r(0);
			Int1_r(0) <= INT1;
			Int1_r(1) <= Int1_r(0);
			if IO_Wr = '1' and IO_Addr = "110101" then	-- $35 MCUCR
				Sleep_En <= IO_WData(5);
				ISC0 <= IO_WData(1 downto 0);
				ISC1 <= IO_WData(3 downto 2);
			end if;
			if IO_Wr = '1' and IO_Addr = "111011" then	-- $3B GIMSK
				Int_En <= IO_WData(7 downto 6);
			end if;
			if IO_Wr = '1' and IO_Addr = "111001" then	-- $39 TIMSK
				TOIE0 <= IO_WData(1);
				TICIE1 <= IO_WData(3);
				OCIE1 <= IO_WData(6);
				TOIE1 <= IO_WData(7);
			end if;
			if IO_Wr = '1' and IO_Addr = "111000" then	-- $38 TIFR
				if IO_WData(1) = '1' then
					TOV0 <= '0';
				end if;
				if IO_WData(3) = '1' then
					ICF1 <= '0';
				end if;
				if IO_WData(6) = '1' then
					OCF1 <= '0';
				end if;
				if IO_WData(7) = '1' then
					TOV1 <= '0';
				end if;
			end if;
			if Int_Acc(3) = '1' then
				ICF1 <= '0';
			end if;
			if Int_Acc(4) = '1' then
				OCF1 <= '0';
			end if;
			if Int_Acc(5) = '1' then
				TOV1 <= '0';
			end if;
			if Int_Acc(6) = '1' then
				TOV0 <= '0';
			end if;
			if TC_Trig = '1' then
				TOV0 <= '1';
			end if;
			if IC_Trig = '1' then
				ICF1 <= '1';
			end if;
			if OC_Trig = '1' then
				OCF1 <= '1';
			end if;
			if TO_Trig = '1' then
				TOV1 <= '1';
			end if;
			if Int_Acc(1) = '1' then
				Int_ET(0) <= '0';
			end if;
			if (ISC0 = "10" and Int0_r = "10") or (ISC0 = "11" and Int0_r = "01") then
				Int_ET(0) <= '1';
			end if;
			if Int_Acc(2) = '1' then
				Int_ET(1) <= '0';
			end if;
			if (ISC1 = "10" and Int1_r = "10") or (ISC1 = "11" and Int1_r = "01") then
				Int_ET(1) <= '1';
			end if;
		end if;
	end process;

	Int_Trig(1) <= '0' when Int_En(0) = '0' else not Int0_r(1) when ISC0 = "00" else Int_ET(0);
	Int_Trig(2) <= '0' when Int_En(1) = '0' else not Int1_r(1) when ISC1 = "00" else Int_ET(1);
	Int_Trig(3) <= '1' when TICIE1 = '1' and ICF1 = '1' else '0';
	Int_Trig(4) <= '1' when OCIE1 = '1' and OCF1 = '1' else '0';
	Int_Trig(5) <= '1' when TOIE1 = '1' and TOV1 = '1' else '0';
	Int_Trig(6) <= '1' when TOIE0 = '1' and TOV0 = '1' else '0';
	Int_Trig(15 downto 10) <= (others => '0');

	rom : ROM2313 port map(
			Clk => Clk,
			A => ROM_Addr,
			D => ROM_Data);

	ax : AX8
		generic map(
			ROMAddressWidth => ROMAddressWidth,
			RAMAddressWidth => RAMAddressWidth,
			BigIset => BigIset)
		port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			ROM_Addr => ROM_Addr,
			ROM_Data => ROM_Data,
			Sleep_En => Sleep_En,
			Int_Trig => Int_Trig,
			Int_Acc => Int_Acc,
			SREG => SREG,
			SP => SP,
			IO_Rd => IO_Rd,
			IO_Wr => IO_Wr,
			IO_Addr => IO_Addr,
			IO_RData => IO_RData,
			IO_WData => IO_WData);

	TCCR0_Sel <= '1' when IO_Addr = "110011" else '0';	-- $33 TCCR0
	TCNT0_Sel <= '1' when IO_Addr = "110010" else '0';	-- $32 TCNT0
	tc0 : AX_TC8 port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			T => T0,
			TCCR_Sel => TCCR0_Sel,
			TCNT_Sel => TCNT0_Sel,
			Wr => IO_Wr,
			Data_In => IO_WData,
			TCCR => TCCR0,
			TCNT => TCNT0,
			Int  => TC_Trig);

	TCCR1_Sel <= '1' when IO_Addr(5 downto 1) = "10111" else '0';	-- $2E TCCR1
	TCNT1_Sel <= '1' when IO_Addr(5 downto 1) = "10110" else '0';	-- $2C TCNT1
	OCR1_Sel <= '1' when IO_Addr(5 downto 1) = "10101" else '0';	-- $2A OCR1
	ICR1_Sel <= '1' when IO_Addr(5 downto 1) = "10100" else '0';	-- $24 ICR1
	tc1 : AX_TC16 port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			T => T1,
			ICP => ICP,
			TCCR_Sel => TCCR1_Sel,
			TCNT_Sel => TCNT1_Sel,
			OCR_Sel => OCR1_Sel,
			ICR_Sel => ICR1_Sel,
			A0 => IO_Addr(0),
			Rd => IO_Rd,
			Wr => IO_Wr,
			Data_In => IO_WData,
			COM => COM,
			PWM => PWM,
			CRBH => CRBH,
			CRBL => CRBL,
			TCNT => TCNT1,
			IC => IC,
			OCR => OCR,
			Tmp => Tmp,
			OC => OC,
			Int_TO => TO_Trig,
			Int_OC => OC_Trig,
			Int_IC => IC_Trig);

	UDR_Sel <= '1' when IO_Addr = "001100" else '0';
	USR_Sel <= '1' when IO_Addr = "001011" else '0';
	UCR_Sel <= '1' when IO_Addr = "001010" else '0';
	UBRR_Sel <= '1' when IO_Addr = "001001" else '0';
	uart : AX_UART port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			UDR_Sel => UDR_Sel,
			USR_Sel => USR_Sel,
			UCR_Sel => UCR_Sel,
			UBRR_Sel => UBRR_Sel,
			Rd => IO_Rd,
			Wr => IO_Wr,
			TXC_Clr => Int_Acc(9),
			Data_In => IO_WData,
			UDR => UDR,
			USR => USR,
			UCR => UCR,
			UBRR => UBRR,
			RXD => RXD,
			TXD => TXD,
			Int_RX => Int_Trig(7),
			Int_TR => Int_Trig(8),
			Int_TC => Int_Trig(9));

	PINB_Sel <= '1' when IO_Addr = "010101" else '0';
	DDRB_Sel <= '1' when IO_Addr = "010111" else '0';
	PORTB_Sel <= '1' when IO_Addr = "011000" else '0';
	PIND_Sel <= '1' when IO_Addr = "010000" else '0';
	DDRD_Sel <= '1' when IO_Addr = "010001" else '0';
	PORTD_Sel <= '1' when IO_Addr = "010010" else '0';
	portb : AX_Port port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			PORT_Sel => PORTB_Sel,
			DDR_Sel => DDRB_Sel,
			PIN_Sel => PINB_Sel,
			Wr => IO_Wr,
			Data_In => IO_WData,
			Dir => DirB,
			Port_Input => Port_InB,
			Port_Output => Port_OutB,
			IOPort  => Port_B);
	portd : AX_Port port map(
			Clk => Clk,
			Reset_n => Reset_s_n,
			PORT_Sel => PORTD_Sel,
			DDR_Sel => DDRD_Sel,
			PIN_Sel => PIND_Sel,
			Wr => IO_Wr,
			Data_In => IO_WData,
			Dir => DirD,
			Port_Input => Port_InD,
			Port_Output => Port_OutD,
			IOPort  => Port_D);

	gNoTri : if not TriState generate
		with IO_Addr select
			IO_RData <= SREG when "111111",
				SP(7 downto 0) when "111101",
				SP(15 downto 8) when "111110",
				"00" & Sleep_En & "0" & ISC1 & ISC0 when "110101",
				Int_En & "000000" when "111011",
				TOIE1 & OCIE1 & "00" & TICIE1 & "0" & TOIE0 & "0" when "111001",
				TOV1 & OCF1 & "00" & ICF1 & "0" & TOV0 & "0" when "111000",
				UDR when "001100",
				USR & "000" when "001011",
				UCR(7 downto 1) & "0" when "001010",
				UBRR when "001001",
				"00000" & TCCR0 when "110011",
				TCNT0 when "110010",
				COM & "0000" & PWM when "101111",
				CRBH & "00" & CRBL when "101110",
				TCNT1(7 downto 0) when "101100",
				OCR(7 downto 0) when "101010",
				IC(7 downto 0) when "101000",
				Tmp(15 downto 8) when "101101" | "101001" | "101011",
				Port_InB when "010101",
				DirB when "010111",
				Port_OutB when "011000",
				Port_InD when "010000",
				DirD when "010001",
				Port_OutD when "010010",
				"--------" when others;
	end generate;
	gTri : if TriState generate
		IO_RData <= SREG when IO_Addr = "111111" else "ZZZZZZZZ";
		IO_RData <= SP(7 downto 0) when IO_Addr = "111101" and BigIset else "ZZZZZZZZ";
		IO_RData <= SP(15 downto 8) when IO_Addr = "111110" and BigIset else "ZZZZZZZZ";

		IO_RData <= "00" & Sleep_En & "0" & ISC1 & ISC0 when IO_Addr = "110101" else "ZZZZZZZZ";
		IO_RData <= Int_En & "000000" when IO_Rd = '1' and IO_Addr = "111011" else "ZZZZZZZZ";
		IO_RData <= TOIE1 & OCIE1 & "00" & TICIE1 & "0" & TOIE0 & "0" when IO_Addr = "111001" else "ZZZZZZZZ";
		IO_RData <= TOV1 & OCF1 & "00" & ICF1 & "0" & TOV0 & "0" when IO_Addr = "111000" else "ZZZZZZZZ";

		IO_RData <= UDR when UDR_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= USR & "000" when USR_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= UCR(7 downto 1) & "0" when UCR_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= UBRR when UBRR_Sel = '1' else "ZZZZZZZZ";

		IO_RData <= "00000" & TCCR0 when TCCR0_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= TCNT0 when TCNT0_Sel = '1' else "ZZZZZZZZ";

		IO_RData <= COM & "0000" & PWM when TCCR1_Sel = '1' and IO_Addr(0) = '1' else "ZZZZZZZZ";
		IO_RData <= CRBH & "00" & CRBL when TCCR1_Sel = '1' and IO_Addr(0) = '0' else "ZZZZZZZZ";
		IO_RData <= TCNT1(7 downto 0) when TCNT1_Sel = '1' and IO_Addr(0) = '0' else "ZZZZZZZZ";
		IO_RData <= OCR(7 downto 0) when OCR1_Sel = '1' and IO_Addr(0) = '0' else "ZZZZZZZZ";
		IO_RData <= IC(7 downto 0) when ICR1_Sel = '1' and IO_Addr(0) = '0' else "ZZZZZZZZ";
		IO_RData <= Tmp(15 downto 8) when (TCNT1_Sel = '1' or ICR1_Sel = '1' or OCR1_Sel = '1') and IO_Addr(0) = '1' else "ZZZZZZZZ";

		IO_RData <= Port_InB when PINB_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= DirB when DDRB_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= Port_OutB when PORTB_Sel = '1' else "ZZZZZZZZ";

		IO_RData <= Port_InD when PIND_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= DirD when DDRD_Sel = '1' else "ZZZZZZZZ";
		IO_RData <= Port_OutD when PORTD_Sel = '1' else "ZZZZZZZZ";
	end generate;

end;
