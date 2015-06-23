--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0221
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
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--
--	0146	: First release
--	0221	: Removed tristate

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AX_UART is
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		UDR_Sel		: in std_logic;
		USR_Sel		: in std_logic;
		UCR_Sel		: in std_logic;
		UBRR_Sel	: in std_logic;
		Rd			: in std_logic;
		Wr			: in std_logic;
		TXC_Clr		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		UDR			: out std_logic_vector(7 downto 0);
		USR			: out std_logic_vector(7 downto 3);
		UCR			: out std_logic_vector(7 downto 0);
		UBRR		: out std_logic_vector(7 downto 0);
		RXD			: in std_logic;
		TXD			: out std_logic;
		Int_RX		: out std_logic;
		Int_TR		: out std_logic;
		Int_TC		: out std_logic
	);
end AX_UART;

architecture rtl of AX_UART is

	signal	UDR_i			: std_logic_vector(7 downto 0);	-- UART I/O Data Register
	signal	USR_i			: std_logic_vector(7 downto 3);	-- UART Status Register
	signal	UCR_i			: std_logic_vector(7 downto 0);	-- UART Control Register
	signal	UBRR_i			: std_logic_vector(7 downto 0);	-- UART Baud Rate Register

	signal	Baud16			: std_logic;

	signal	Bit_Phase		: unsigned(3 downto 0);
	signal	RX_Filtered		: std_logic;
	signal	RX_ShiftReg		: std_logic_vector(8 downto 0);
	signal	RX_Bit_Cnt		: integer range 0 to 11;
	signal	Overflow_t		: std_logic;

	signal	TX_Tick			: std_logic;
	signal	TX_Data			: std_logic_vector(7 downto 0);
	signal	TX_ShiftReg		: std_logic_vector(8 downto 0);
	signal	TX_Bit_Cnt		: integer range 0 to 11;

begin

	-- Registers
	UDR <= UDR_i;
	USR <= USR_i;
	UCR <= UCR_i;
	UBRR <= UBRR_i;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			UCR_i(7 downto 2) <= "000000";
			UCR_i(0) <= '0';
			UBRR_i <= "00000000";
		elsif Clk'event and Clk = '1' then
			if UCR_Sel = '1' and Wr = '1' then
				UCR_i(7 downto 2) <= Data_In(7 downto 2);
				UCR_i(0) <= Data_In(0);
			end if;
			if UBRR_Sel = '1' and Wr = '1' then
				UBRR_i <= Data_In;
			end if;
		end if;
	end process;

	-- Baud x 16 clock generator
	process (Clk, Reset_n)
		variable Baud_Cnt : unsigned(7 downto 0);
	begin
		if Reset_n = '0' then
			Baud_Cnt := "00000000";
			Baud16 <= '0';
		elsif Clk'event and Clk='1' then
			if Baud_Cnt = "00000000" then
				Baud_Cnt := unsigned(UBRR_i);
				Baud16 <= '1';
			else
				Baud_Cnt := Baud_Cnt - 1;
				Baud16 <= '0';
			end if;
		end if;
	end process;

	-- Input filter
	process (Clk, Reset_n)
		variable Samples : std_logic_vector(1 downto 0);
	begin
		if Reset_n = '0' then
			Samples := "11";
			RX_Filtered <= '1';
		elsif Clk'event and Clk = '1' then
			if Baud16 = '1' then
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
	Int_RX <= USR_i(7) and UCR_i(7);
	process (Clk, Reset_n)
	begin
		if Reset_n = '0' then
			USR_i(7) <= '0';
			USR_i(4) <= '0';
			USR_i(3) <= '0';
			UCR_i(1) <= '1';
			UDR_i <= "00000000";
			Overflow_t <= '0';
			Bit_Phase <= "0000";
			RX_ShiftReg(8 downto 0) <= "000000000";
			RX_Bit_Cnt <= 0;
		elsif Clk'event and Clk = '1' then
			if UDR_Sel = '1' and Rd = '1' then
				USR_i(7) <= '0';
				USR_i(3) <= Overflow_t;
			end if;
			if Baud16 = '1' then
				if RX_Bit_Cnt = 0 and (RX_Filtered = '1' or Bit_Phase = "0111") then
					Bit_Phase <= "0000";
				else
					Bit_Phase <= Bit_Phase + 1;
				end if;
				if RX_Bit_Cnt = 0 then
					if Bit_Phase = "0111" then
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					end if;
				elsif Bit_Phase = "1111" then
					RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					if (UCR_i(2) = '0' and RX_Bit_Cnt = 9) or
						(UCR_i(2) = '1' and RX_Bit_Cnt = 10) then -- Stop bit
						RX_Bit_Cnt <= 0;
						if UCR_i(4) = '1' then
							USR_i(7) <= '1'; -- UART Receive complete
							USR_i(4) <= not RX_Filtered; -- Framing error
							Overflow_t <= USR_i(7);
							if USR_i(7) = '0' or (UDR_Sel = '1' and Rd = '1') then
								Overflow_t <= '0';
								USR_i(3) <= '0';
								UDR_i <= RX_ShiftReg(7 downto 0);
								UCR_i(1) <= RX_ShiftReg(8);
							end if;
						end if;
					else
						RX_ShiftReg(7 downto 0) <= RX_ShiftReg(8 downto 1);
						if UCR_i(2) = '1' then	-- CHR9
							RX_ShiftReg(8) <= RX_Filtered;
						else
							RX_ShiftReg(7) <= RX_Filtered;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Transmit bit tick
	process (Clk, Reset_n)
		variable TX_Cnt : unsigned(3 downto 0);
	begin
		if Reset_n = '0' then
			TX_Cnt := "0000";
			TX_Tick <= '0';
		elsif Clk'event and Clk = '1' then
			TX_Tick <= '0';
			if Baud16 = '1' then
				if TX_Cnt = "1111" then
					TX_Tick <= '1';
				end if;
				TX_Cnt := TX_Cnt + 1;
			end if;
		end if;
	end process;

	-- Transmit state machine
	Int_TR <= USR_i(5) and UCR_i(5);
	Int_TC <= USR_i(6) and UCR_i(6);
	process (Clk, Reset_n)
	begin
		if Reset_n = '0' then
			USR_i(6) <= '0';
			USR_i(5) <= '1';
			TX_Bit_Cnt <= 0;
			TX_ShiftReg <= (others => '0');
				TX_Data <= (others => '0');
			TXD <= '1';
		elsif Clk'event and Clk = '1' then
			if TXC_Clr = '1' or (USR_Sel = '1' and Wr = '1' and Data_In(6) = '1') then
				USR_i(6) <= '0';
			end if;
			if UDR_Sel = '1' and Wr = '1' and UCR_i(3) = '1' then
				USR_i(5) <= '0';
				TX_Data <= Data_In;
			end if;
			if TX_Tick = '1' then
				case TX_Bit_Cnt is
				when 0 =>
					if USR_i(5) = '0' then
						TX_Bit_Cnt <= 1;
					end if;
					TXD <= '1';
				when 1 => -- Start bit
					TX_ShiftReg(7 downto 0) <= TX_Data;
					TX_ShiftReg(8) <= UCR_i(0);
					USR_i(5) <= '1';
					TXD <= '0';
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
				when others =>
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
					if UCR_i(2) = '1' then	-- CHR9
						if TX_Bit_Cnt = 10 then
							TX_Bit_Cnt <= 0;
							USR_i(6) <= '1';
						end if;
					else
						if TX_Bit_Cnt = 9 then
							TX_Bit_Cnt <= 0;
							USR_i(6) <= '1';
						end if;
					end if;
					TXD <= TX_ShiftReg(0);
					TX_ShiftReg(7 downto 0) <= TX_ShiftReg(8 downto 1);
				end case;
			end if;
		end if;
	end process;

end;
