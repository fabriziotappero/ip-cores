--
-- 16450 compatible UART with synchronous bus interface
-- RClk/BaudOut is XIn enable instead of actual clock
--
-- Version : 0249b
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
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
--	http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--
-- 0208 : First release
--
-- 0249 : Fixed interrupt and baud rate bugs found by Andy Dyer
--        Added modem status and break detection
--        Added support for 1.5 and 2 stop bits
--
-- 0249b : Fixed loopback break generation bugs found by Andy Dyer
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T16450 is
	port(
		MR_n		: in std_logic;
		XIn			: in std_logic;
		RClk		: in std_logic;
		CS_n		: in std_logic;
		Rd_n		: in std_logic;
		Wr_n		: in std_logic;
		A			: in std_logic_vector(2 downto 0);
		D_In		: in std_logic_vector(7 downto 0);
		D_Out		: out std_logic_vector(7 downto 0);
		SIn			: in std_logic;
		CTS_n		: in std_logic;
		DSR_n		: in std_logic;
		RI_n		: in std_logic;
		DCD_n		: in std_logic;
		SOut		: out std_logic;
		RTS_n		: out std_logic;
		DTR_n		: out std_logic;
		OUT1_n		: out std_logic;
		OUT2_n		: out std_logic;
		BaudOut		: out std_logic;
		Intr		: out std_logic
	);
end T16450;

architecture rtl of T16450 is

	signal	RBR				: std_logic_vector(7 downto 0);	-- Reciever Buffer Register
	signal	THR				: std_logic_vector(7 downto 0);	-- Transmitter Holding Register
	signal	IER				: std_logic_vector(7 downto 0);	-- Interrupt Enable Register
	signal	IIR				: std_logic_vector(7 downto 0);	-- Interrupt Ident. Register
	signal	LCR				: std_logic_vector(7 downto 0);	-- Line Control Register
	signal	MCR				: std_logic_vector(7 downto 0);	-- MODEM Control Register
	signal	LSR				: std_logic_vector(7 downto 0);	-- Line Status Register
	signal	MSR				: std_logic_vector(7 downto 0);	-- MODEM Status Register
	signal	SCR				: std_logic_vector(7 downto 0);	-- Scratch Register
	signal	DLL				: std_logic_vector(7 downto 0);	-- Divisor Latch (LS)
	signal	DLM				: std_logic_vector(7 downto 0);	-- Divisor Latch (MS)

	signal	DM0				: std_logic_vector(7 downto 0);
	signal	DM1				: std_logic_vector(7 downto 0);

	signal	MSR_In			: std_logic_vector(3 downto 0);

	signal	Bit_Phase		: unsigned(3 downto 0);
	signal	Brk_Cnt			: unsigned(3 downto 0);
	signal	RX_Filtered		: std_logic;
	signal	RX_ShiftReg		: std_logic_vector(7 downto 0);
	signal	RX_Bit_Cnt		: integer range 0 to 11;
	signal	RX_Parity		: std_logic;
	signal	RXD				: std_logic;

	signal	TX_Tick			: std_logic;
	signal	TX_ShiftReg		: std_logic_vector(7 downto 0);
	signal	TX_Bit_Cnt		: integer range 0 to 11;
	signal	TX_Parity		: std_logic;
	signal	TX_Next_Is_Stop	: std_logic;
	signal	TX_Stop_Bit		: std_logic;
	signal	TXD				: std_logic;

begin

	DTR_n <= MCR(4) or not MCR(0);
	RTS_n <= MCR(4) or not MCR(1);
	OUT1_n <= MCR(4) or not MCR(2);
	OUT2_n <= MCR(4) or not MCR(3);
	SOut <= MCR(4) or (TXD and not LCR(6));
	RXD <= SIn when MCR(4) = '0' else (TXD and not LCR(6));

	Intr <= not IIR(0);

	-- Registers
	DM0 <= DLL when LCR(7) = '1' else RBR;
	DM1 <= DLM when LCR(7) = '1' else IER;
	with A select
		D_Out <=
			DM0 when "000",
			DM1 when "001",
			IIR when "010",
			LCR when "011",
			MCR when "100",
			LSR when "101",
			MSR when "110",
			SCR when others;
	process (MR_n, XIn)
	begin
		if MR_n = '0' then
			THR <= "00000000";
			IER <= "00000000";
			LCR <= "00000000";
			MCR <= "00000000";
			MSR(3 downto 0) <= "0000";
			SCR <= "00000000"; -- ??
			DLL <= "00000000"; -- ??
			DLM <= "00000000"; -- ??
		elsif XIn'event and XIn = '1' then
			if Wr_n = '0' and CS_n = '0' then
				case A is
				when "000" =>
					if LCR(7) = '1' then
						DLL <= D_In;
					else
						THR <= D_In;
					end if;
				when "001" =>
					if LCR(7) = '1' then
						DLM <= D_In;
					else
						IER(3 downto 0) <= D_In(3 downto 0);
					end if;
				when "011" =>
					LCR <= D_In;
				when "100" =>
					MCR <= D_In;
				when "111" =>
					SCR <= D_In;
				when others =>
				end case;
			end if;
			if Rd_n = '0' and CS_n = '0' and A = "110" then
				MSR(3 downto 0) <= "0000";
			end if;
			if MSR(4) /= MSR_In(0) then
				MSR(0) <= '1';
			end if;
			if MSR(5) /= MSR_In(1) then
				MSR(1) <= '1';
			end if;
			if MSR(6) = '0' and MSR_In(2) = '1' then
				MSR(2) <= '1';
			end if;
			if MSR(7) /= MSR_In(3) then
				MSR(3) <= '1';
			end if;
		end if;
	end process;
	process (XIn)
	begin
		if XIn'event and XIn = '1' then
			if MCR(4) = '0' then
				MSR(4) <= MSR_In(0);
				MSR(5) <= MSR_In(1);
				MSR(6) <= MSR_In(2);
				MSR(7) <= MSR_In(3);
			else
				MSR(4) <= MCR(1);
				MSR(5) <= MCR(0);
				MSR(6) <= MCR(2);
				MSR(7) <= MCR(3);
			end if;
			MSR_In(0) <= CTS_n;
			MSR_In(1) <= DSR_n;
			MSR_In(2) <= RI_n;
			MSR_In(3) <= DCD_n;
		end if;
	end process;

	IIR(7 downto 3) <= "00000";
	IIR(2 downto 0) <=
		"110" when IER(2) = '1' and LSR(4 downto 1) /= "0000" else
		"100" when (IER(0) and LSR(0)) = '1' else
		"010" when (IER(1) and LSR(5)) = '1' else
		"000" when IER(3) = '1' and ((MCR(4) = '0' and MSR(3 downto 0) /= "0000") or
									(MCR(4) = '1' and MCR(3 downto 0) /= "0000")) else
		"001";

	-- Baud x 16 clock generator
	process (MR_n, XIn)
		variable Baud_Cnt : unsigned(15 downto 0);
	begin
		if MR_n = '0' then
			Baud_Cnt := "0000000000000000";
			BaudOut <= '0';
		elsif XIn'event and XIn = '1' then
			if Baud_Cnt(15 downto 1) = "000000000000000" or (Wr_n = '0' and CS_n = '0' and A(2 downto 1) = "00" and LCR(7) = '1') then
				Baud_Cnt(15 downto 8) := unsigned(DLM);
				Baud_Cnt(7 downto 0) := unsigned(DLL);
				BaudOut <= '1';
			else
				Baud_Cnt := Baud_Cnt - 1;
				BaudOut <= '0';
			end if;
		end if;
	end process;

	-- Input filter
	process (MR_n, XIn)
		variable Samples : std_logic_vector(1 downto 0);
	begin
		if MR_n = '0' then
			Samples := "11";
			RX_Filtered <= '1';
		elsif XIn'event and XIn = '1' then
			if RClk = '1' then
				Samples(1) := Samples(0);
				Samples(0) := RXD;
			end if;
			if Samples = "00" then
				RX_Filtered <= '0';
			end if;
			if Samples = "11" then
				RX_Filtered <= '1';
			end if;
		end if;
	end process;

	-- Receive state machine
	process (MR_n, XIn)
	begin
		if MR_n = '0' then
			RBR <= "00000000";
			LSR(4 downto 0) <= "00000";
			Bit_Phase <= "0000";
			Brk_Cnt <= "0000";
			RX_ShiftReg(7 downto 0) <= "00000000";
			RX_Bit_Cnt <= 0;
			RX_Parity <= '0';
		elsif XIn'event and XIn = '1' then
			if A = "000" and LCR(7) = '0' and Rd_n = '0' and CS_n = '0' then
				LSR(0) <= '0';	-- DR
			end if;
			if A = "101" and Rd_n = '0' and CS_n = '0' then
				LSR(4) <= '0';	-- BI
				LSR(3) <= '0';	-- FE
				LSR(2) <= '0';	-- PE
				LSR(1) <= '0';	-- OE
			end if;
			if RClk = '1' then
				if RX_Bit_Cnt = 0 and (RX_Filtered = '1' or Bit_Phase = "0111") then
					Bit_Phase <= "0000";
				else
					Bit_Phase <= Bit_Phase + 1;
				end if;
				if Bit_Phase = "1111" then
					if RX_Filtered = '1' then
						Brk_Cnt <= "0000";
					else
						Brk_Cnt <= Brk_Cnt + 1;
					end if;
					if Brk_Cnt = "1100" then
						LSR(4) <= '1';	-- BI
					end if;
				end if;
				if RX_Bit_Cnt = 0 then
					if Bit_Phase = "0111" then
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
						RX_Parity <= not LCR(4);	-- EPS
					end if;
				elsif Bit_Phase = "1111" then
					RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					if RX_Bit_Cnt = 10 then -- Parity stop bit
						RX_Bit_Cnt <= 0;
						LSR(0) <= '1'; -- UART Receive complete
						LSR(3) <= not RX_Filtered; -- Framing error
					elsif (RX_Bit_Cnt = 9 and LCR(1 downto 0) = "11") or
						(RX_Bit_Cnt = 8 and LCR(1 downto 0) = "10") or
						(RX_Bit_Cnt = 7 and LCR(1 downto 0) = "01") or
						(RX_Bit_Cnt = 6 and LCR(1 downto 0) = "00") then -- Stop bit/Parity
						RX_Bit_Cnt <= 0;
						if LCR(3) = '1' then	-- PEN
							RX_Bit_Cnt <= 10;
							if LCR(5) = '1' then	-- Stick parity
								if RX_Filtered = LCR(4) then
									LSR(2) <= '1';
								end if;
							else
								if RX_Filtered /= RX_Parity then
									LSR(2) <= '1';
								end if;
							end if;
						else
							LSR(0) <= '1'; -- UART Receive complete
							LSR(3) <= not RX_Filtered; -- Framing error
						end if;
						RBR <= RX_ShiftReg(7 downto 0);
						LSR(1) <= LSR(0);
						if A = "101" and Rd_n = '0' and CS_n = '0' then
							LSR(1) <= '0';
						end if;
					else
						RX_ShiftReg(6 downto 0) <= RX_ShiftReg(7 downto 1);
						RX_ShiftReg(7) <= RX_Filtered;
						if LCR(1 downto 0) = "10" then
							RX_ShiftReg(7) <= '0';
							RX_ShiftReg(6) <= RX_Filtered;
						end if;
						if LCR(1 downto 0) = "01" then
							RX_ShiftReg(7) <= '0';
							RX_ShiftReg(6) <= '0';
							RX_ShiftReg(5) <= RX_Filtered;
						end if;
						if LCR(1 downto 0) = "00" then
							RX_ShiftReg(7) <= '0';
							RX_ShiftReg(6) <= '0';
							RX_ShiftReg(5) <= '0';
							RX_ShiftReg(4) <= RX_Filtered;
						end if;
						RX_Parity <= RX_Filtered xor RX_Parity;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Transmit bit tick
	process (MR_n, XIn)
		variable TX_Cnt : unsigned(4 downto 0);
	begin
		if MR_n = '0' then
			TX_Cnt := "00000";
			TX_Tick <= '0';
		elsif XIn'event and XIn = '1' then
			TX_Tick <= '0';
			if RClk = '1' then
				TX_Cnt := TX_Cnt + 1;
				if LCR(2) = '1' and TX_Stop_Bit = '1' then
					if LCR(1 downto 0) = "00" then
						if TX_Cnt = "10111" then
							TX_Tick <= '1';
							TX_Cnt(3 downto 0) := "0000";
						end if;
					else
						if TX_Cnt = "11111" then
							TX_Tick <= '1';
							TX_Cnt(3 downto 0) := "0000";
						end if;
					end if;
				else
					TX_Cnt(4) := '1';
					if TX_Cnt(3 downto 0) = "1111" then
						TX_Tick <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Transmit state machine
	process (MR_n, XIn)
	begin
		if MR_n = '0' then
			LSR(7 downto 5) <= "011";
			TX_Bit_Cnt <= 0;
			TX_ShiftReg <= (others => '0');
			TXD <= '1';
			TX_Parity <= '0';
			TX_Next_Is_Stop <= '0';
			TX_Stop_Bit <= '0';
		elsif XIn'event and XIn = '1' then
			if TX_Tick = '1' then
				TX_Next_Is_Stop <= '0';
				TX_Stop_Bit <= TX_Next_Is_Stop;
				case TX_Bit_Cnt is
				when 0 =>
					if LSR(5) <= '0' then	-- THRE
						TX_Bit_Cnt <= 1;
					end if;
					TXD <= '1';
				when 1 => -- Start bit
					TX_ShiftReg(7 downto 0) <= THR;
					LSR(5) <= '1';	-- THRE
					TXD <= '0';
					TX_Parity <= not LCR(4);	-- EPS
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
				when 10 => -- Parity bit
					TXD <= TX_Parity;
					if LCR(5) = '1' then	-- Stick parity
						TXD <= not LCR(4);
					end if;
					TX_Bit_Cnt <= 0;
					TX_Next_Is_Stop <= '1';
				when others =>
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
					if (TX_Bit_Cnt = 9 and LCR(1 downto 0) = "11") or
						(TX_Bit_Cnt = 8 and LCR(1 downto 0) = "10") or
						(TX_Bit_Cnt = 7 and LCR(1 downto 0) = "01") or
						(TX_Bit_Cnt = 6 and LCR(1 downto 0) = "00") then
						TX_Bit_Cnt <= 0;
						if LCR(3) = '1' then	-- PEN
							TX_Bit_Cnt <= 10;
						else
							TX_Next_Is_Stop <= '1';
						end if;
						LSR(6) <= '1';	-- TEMT
					end if;
					TXD <= TX_ShiftReg(0);
					TX_ShiftReg(6 downto 0) <= TX_ShiftReg(7 downto 1);
					TX_Parity <= TX_ShiftReg(0) xor TX_Parity;
				end case;
			end if;
			if Wr_n = '0' and CS_n = '0' and A = "000" and LCR(7) = '0' then
				LSR(5) <= '0';	-- THRE
				LSR(6) <= '0';	-- TEMT
			end if;
		end if;
	end process;

end;
