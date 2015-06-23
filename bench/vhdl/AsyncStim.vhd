--
-- Asynchronous serial generator with input from binary file
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

entity AsyncStim is
	generic(
		FileName		: string;
		Baud			: integer;
		InterCharDelay	: time := 0 ns;
		Bits			: integer := 8;		-- Data bits
		Parity			: boolean := false;	-- Enable Parity
		P_Odd_Even_n	: boolean := false	-- false => Even Parity, true => Odd Parity
	);
	port(
		TXD				: out std_logic
	);
end AsyncStim;

architecture behaviour of AsyncStim is

	signal	TX_ShiftReg		: std_logic_vector(Bits - 1 downto 0);
	signal	TX_Bit_Cnt		: integer range 0 to 15 := 0;
	signal	ParTmp			: boolean;

begin

	process
		type ChFile is file of character;
		file InFile				: ChFile open read_mode is FileName;
		variable Inited			: boolean := false;
		variable CharTmp		: character;
		variable IntTmp			: integer;
	begin
		if not Inited then
			Inited := true;
			TXD <= '1';
		end if;
		wait for 1000000000 ns / Baud;
		TX_Bit_Cnt <= TX_Bit_Cnt + 1;
		case TX_Bit_Cnt is
		when 0 =>
			TXD <= '1';
			wait for InterCharDelay;
		when 1 => -- Start bit
			read(InFile, CharTmp);
			IntTmp := character'pos(CharTmp);
			TX_ShiftReg(Bits - 1 downto 0) <= std_logic_vector(to_unsigned(IntTmp, Bits));
			TXD <= '0';
			ParTmp <= P_Odd_Even_n;
		when others =>
			TXD <= TX_ShiftReg(0);
			ParTmp <= ParTmp xor (TX_ShiftReg(0) = '1');
			TX_ShiftReg(Bits - 2 downto 0) <= TX_ShiftReg(Bits - 1 downto 1);
			if (TX_Bit_Cnt = Bits + 1 and not Parity) or
				(TX_Bit_Cnt = Bits + 2 and Parity) then -- Stop bit
				TX_Bit_Cnt <= 0;
			end if;
			if Parity and TX_Bit_Cnt = Bits + 2 then
				if ParTmp then
					TXD <= '1';
				else
					TXD <= '0';
				end if;
			end if;
		end case;
	end process;

end;
