-- ------------------------------------------------------------------------
-- Copyright (C) 2010 Arif Endro Nugroho
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- End Of License.
-- ------------------------------------------------------------------------

entity romk is
  port (
  addr             : in  bit_vector (  6 downto 0);
  k                : out bit_vector ( 63 downto 0)
  );
end romk;

architecture phy of romk is
begin
  with addr (  6 downto 0) select
  k                <= X"428a2f98d728ae22" when B"0000000",
		      X"7137449123ef65cd" when B"0000001",
		      X"b5c0fbcfec4d3b2f" when B"0000010",
		      X"e9b5dba58189dbbc" when B"0000011",
		      X"3956c25bf348b538" when B"0000100",
		      X"59f111f1b605d019" when B"0000101",
		      X"923f82a4af194f9b" when B"0000110",
		      X"ab1c5ed5da6d8118" when B"0000111",

		      X"d807aa98a3030242" when B"0001000",
		      X"12835b0145706fbe" when B"0001001",
		      X"243185be4ee4b28c" when B"0001010",
		      X"550c7dc3d5ffb4e2" when B"0001011",
		      X"72be5d74f27b896f" when B"0001100",
		      X"80deb1fe3b1696b1" when B"0001101",
		      X"9bdc06a725c71235" when B"0001110",
		      X"c19bf174cf692694" when B"0001111",

		      X"e49b69c19ef14ad2" when B"0010000",
		      X"efbe4786384f25e3" when B"0010001",
		      X"0fc19dc68b8cd5b5" when B"0010010",
		      X"240ca1cc77ac9c65" when B"0010011",
		      X"2de92c6f592b0275" when B"0010100",
		      X"4a7484aa6ea6e483" when B"0010101",
		      X"5cb0a9dcbd41fbd4" when B"0010110",
		      X"76f988da831153b5" when B"0010111",

		      X"983e5152ee66dfab" when B"0011000",
		      X"a831c66d2db43210" when B"0011001",
		      X"b00327c898fb213f" when B"0011010",
		      X"bf597fc7beef0ee4" when B"0011011",
		      X"c6e00bf33da88fc2" when B"0011100",
		      X"d5a79147930aa725" when B"0011101",
		      X"06ca6351e003826f" when B"0011110",
		      X"142929670a0e6e70" when B"0011111",

		      X"27b70a8546d22ffc" when B"0100000",
		      X"2e1b21385c26c926" when B"0100001",
		      X"4d2c6dfc5ac42aed" when B"0100010",
		      X"53380d139d95b3df" when B"0100011",
		      X"650a73548baf63de" when B"0100100",
		      X"766a0abb3c77b2a8" when B"0100101",
		      X"81c2c92e47edaee6" when B"0100110",
		      X"92722c851482353b" when B"0100111",

		      X"a2bfe8a14cf10364" when B"0101000",
		      X"a81a664bbc423001" when B"0101001",
		      X"c24b8b70d0f89791" when B"0101010",
		      X"c76c51a30654be30" when B"0101011",
		      X"d192e819d6ef5218" when B"0101100",
		      X"d69906245565a910" when B"0101101",
		      X"f40e35855771202a" when B"0101110",
		      X"106aa07032bbd1b8" when B"0101111",

		      X"19a4c116b8d2d0c8" when B"0110000",
		      X"1e376c085141ab53" when B"0110001",
		      X"2748774cdf8eeb99" when B"0110010",
		      X"34b0bcb5e19b48a8" when B"0110011",
		      X"391c0cb3c5c95a63" when B"0110100",
		      X"4ed8aa4ae3418acb" when B"0110101",
		      X"5b9cca4f7763e373" when B"0110110",
		      X"682e6ff3d6b2b8a3" when B"0110111",

		      X"748f82ee5defb2fc" when B"0111000",
		      X"78a5636f43172f60" when B"0111001",
		      X"84c87814a1f0ab72" when B"0111010",
		      X"8cc702081a6439ec" when B"0111011",
		      X"90befffa23631e28" when B"0111100",
		      X"a4506cebde82bde9" when B"0111101",
		      X"bef9a3f7b2c67915" when B"0111110",
		      X"c67178f2e372532b" when B"0111111",

		      X"ca273eceea26619c" when B"1000000",
		      X"d186b8c721c0c207" when B"1000001",
		      X"eada7dd6cde0eb1e" when B"1000010",
		      X"f57d4f7fee6ed178" when B"1000011",
		      X"06f067aa72176fba" when B"1000100",
		      X"0a637dc5a2c898a6" when B"1000101",
		      X"113f9804bef90dae" when B"1000110",
		      X"1b710b35131c471b" when B"1000111",

		      X"28db77f523047d84" when B"1001000",
		      X"32caab7b40c72493" when B"1001001",
		      X"3c9ebe0a15c9bebc" when B"1001010",
		      X"431d67c49c100d4c" when B"1001011",
		      X"4cc5d4becb3e42b6" when B"1001100",
		      X"597f299cfc657e2a" when B"1001101",
		      X"5fcb6fab3ad6faec" when B"1001110",
		      X"6c44198c4a475817" when B"1001111",

		      X"0000000000000000" when others; -- maximum address is 128

end phy;
