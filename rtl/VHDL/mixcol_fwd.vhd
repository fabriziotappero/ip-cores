--------------------------------------------------------------------------------
-- This file is part of the project  avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
-- Mix the columns of the AES Block (encryption version)
-- A column is always a word of 32 Bit, nomatter what the blocklength is. 
--
-- For encryption the input vector is multiplied by this matrix
--
--		| 2 3 1 1 |	  a(n,0)
--		| 1 2 3 1 | x a(n,1)  
--		| 1 1 2 3 |	  a(n,2)
--		| 3 1 1 2 |	  a(n,3)
--
-- where the multiplication is defined over the GF(2^8) Galois field.
-- in this finite field addition is an XOR, multiplication by 2 is a simple
-- shift left like in  "normal" math. So the multiplication by 3 is a shiftleft
-- and XOR operation.
--			  2*a = a shl 2
--			  3*a = (a shl 2) XOR a 
-- If bit leftmost (MSB) bit is '1' the result is too big to fit in a Byte and
-- has to be XORed with the magic number "100_0110_1100", "10_0011_0110",
-- "1_0001_1011" sucessively until it fits... don't ask me where it
-- comes from - I have no clue and skipped the gory math details of the algorithm.
-- the most is taken from:	http://en.wikipedia.org/wiki/Rijndael_Galois_field
-- Or you ask the mathematician of at your disposal...
-------------------------------------------------------------------------------
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Authors and opencores.org
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--    * Neither the name of the organization nor the names of its contributors
--    may be used to endorse or promote products derived from this software without
--    specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
-------------------------------------------------------------------------------
-- version management:
-- $Author::                                         $
-- $Date::                                           $
-- $Revision::                                       $
-------------------------------------------------------------------------------




library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;


architecture fwd of mixcol
is
	signal byte0 : BYTE;
	signal byte1 : BYTE;
	signal byte2 : BYTE;
	signal byte3 : BYTE;
begin  -- architecture ARCH1

	-- Easier handling of the single cells of the column
	byte0 <= col_in(31 downto 24);
	byte1 <= col_in(23 downto 16);
	byte2 <= col_in(15 downto 8);
	byte3 <= col_in(7 downto 0);

	-- purpose: multiplies the column of the input block with the matrix
	-- type	  : combinational
	-- inputs : direction,byte0,byte1,byte2,byte3
	-- outputs: col_out
	matrix_mult : process (byte0, byte1, byte2, byte3) is
		-- temporary results for the row-col multiplication have to be 9 Bits
		-- long because the input is shifted left
		variable tmp_res0 : STD_LOGIC_VECTOR(10 downto 0);	-- result of row1*col
		variable tmp_res1 : STD_LOGIC_VECTOR(10 downto 0);	-- result of row2*col
		variable tmp_res2 : STD_LOGIC_VECTOR(10 downto 0);	-- result of row3*col
		variable tmp_res3 : STD_LOGIC_VECTOR(10 downto 0);	-- result of row4*col
	begin  -- process matrix_mult
		-- Multiply by 1st row of the encrypt matrix (2 3 1 1)
		tmp_res0 := "00" & (byte0 & '0' xor	 -- byte0*2 +
							byte1 & '0' xor '0'& byte1 xor	-- byte1*2 + byte1 +
							'0' & byte2 xor	 -- byte2*1 (expanded to 9 bit)
							'0' & byte3);	 -- byte3*1 (expanded to 9 bit)
		-- check if the 9th byte=1 and XOR with magic number to make it 8 BIT
		if tmp_res0(8) = '1' then
			tmp_res0 := tmp_res0 xor "00100011011";
		end if;

		-- Multiply by 2nd row of the encrypt matrix (1 2 3 1)
		tmp_res1 := "00" & ('0' & byte0 xor	 -- byte0*1 (expanded to 9 bit)
							byte1 & '0' xor	 -- byte1*2
							byte2 & '0' xor '0' & byte2 xor	 -- byte2*2 + byte2
							'0' & byte3);	 -- byte3*1 (expanded to 9 bit)
		-- check if the 9th byte=1 and XOR with magic number to make it 8 BIT
		if tmp_res1(8) = '1' then
			tmp_res1 := tmp_res1 xor "00100011011";
		end if;

		-- Multiply by 3rd row of the encrypt matrix  (1 1 2 3)
		tmp_res2 := "00" & ('0' & byte0 xor	 -- byte0*1 (expanded to 9 bit)
							'0' & byte1 xor	 -- byte1*1 (expanded to 9 bit)
							byte2 & '0' xor	 -- byte2*3
							byte3 & '0' xor '0' & byte3);  -- byte3*3
		-- check if the 9th byte=1 and XOR with magic number to make it 8 BIT
		if tmp_res2(8) = '1' then
			tmp_res2 := tmp_res2 xor "00100011011";
		end if;

		-- Multiply by 4th row of the encrypt matrix  (3 1 1 2)
		tmp_res3 := "00" & (byte0 & '0' xor '0' & byte0 xor	 -- byte0*3
							'0' & byte1 xor	 -- byte1*1 (expanded to 9 bit)
							'0' & byte2 xor	 -- byte2*1 (expanded to 9 bit)
							byte3 & '0');	 -- byte3*2
		-- check if the 9th byte=1 and XOR with magic number to make it 8 BIT
		if tmp_res3(8) = '1' then
			tmp_res3 := tmp_res3 xor "00100011011";
		end if;


		-- build output signal (BYTE_RANGE =7 downto 0 see util_pkg.vhd)
		col_out(31 downto 24) <= tmp_res0(BYTE_RANGE);
		col_out(23 downto 16) <= tmp_res1(BYTE_RANGE);
		col_out(15 downto 8)  <= tmp_res2(BYTE_RANGE);
		col_out(7 downto 0)	  <= tmp_res3(BYTE_RANGE);
	end process matrix_mult;

end architecture fwd;

