--
-- Asynchronous serial input with binary file log
--
-- Version : 0146
--
-- Copyright (c) 2001 Daniel Wallner (jesus@opencores.org)
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AsyncLog is
	generic(
		FileName		: string;
		Baud			: integer;
		Bits			: integer := 8;		-- Data bits
		Parity			: boolean := false;	-- Enable Parity
		P_Odd_Even_n	: boolean := false	-- false => Even Parity, true => Odd Parity
	);
	port(
		RXD				: in std_logic
	);
end AsyncLog;

architecture behaviour of AsyncLog is

	function to_char(
		constant Byte : std_logic_vector(7 downto 0)
	) return character is
	begin
		return character'val(to_integer(unsigned(Byte)));
	end function;

	signal	Baud16			: std_logic := '0';

	-- Receive signals
	signal	Bit_Phase		: unsigned(3 downto 0) := "0000";
	signal	RX_ShiftReg		: std_logic_vector(Bits - 1 downto 0) := (others => '0');
	signal	RX_Bit_Cnt		: integer := 0;
	signal	ParTmp			: boolean;

begin

	Baud16 <= not Baud16 after 1000000000 ns / 32 / Baud;

	process (Baud16)
		type ChFile is file of character;
		file OutFile : ChFile open write_mode is FileName;
	begin
		if Baud16'event and Baud16 = '1' then
			if RX_Bit_Cnt = 0 and (RXD = '1' or Bit_Phase = "0111") then
				Bit_Phase <= "0000";
			else
				Bit_Phase <= Bit_Phase + 1;
			end if;
			if RX_Bit_Cnt = 0 then
				if Bit_Phase = "0111" then
					RX_Bit_Cnt <= RX_Bit_Cnt + 1;
				end if;
				ParTmp <= false;
			elsif Bit_Phase = "1111" then
				RX_Bit_Cnt <= RX_Bit_Cnt + 1;
				if (RX_Bit_Cnt = Bits + 1 and not Parity) or
					(RX_Bit_Cnt = Bits + 2 and Parity) then -- Stop bit
					RX_Bit_Cnt <= 0;
					assert RXD = '1'
						report "Framing error"
						severity error;
					write(OutFile, to_char(RX_ShiftReg(7 downto 0)));
				elsif RX_Bit_Cnt = Bits + 1 and Parity then -- Parity bit
					assert ParTmp xor (RXD = '1') = P_Odd_Even_n
						report "Parity error"
						severity error;
				else
					ParTmp <= ParTmp xor (RXD = '1');
					RX_ShiftReg(Bits - 2 downto 0) <= RX_ShiftReg(Bits - 1 downto 1);
					RX_ShiftReg(Bits - 1) <= RXD;
				end if;
			end if;
		end if;
	end process;

end;

