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
  addr             : in  bit_vector (  5 downto 0);
  k                : out bit_vector ( 31 downto 0)
  );
end romk;
 
architecture phy of romk is
begin
  with addr (  5 downto 0) select
  k                <= X"428a2f98" when B"000000",
		      X"71374491" when B"000001",
		      X"b5c0fbcf" when B"000010",
		      X"e9b5dba5" when B"000011",
		      X"3956c25b" when B"000100",
		      X"59f111f1" when B"000101",
		      X"923f82a4" when B"000110",
		      X"ab1c5ed5" when B"000111",
 
		      X"d807aa98" when B"001000",
		      X"12835b01" when B"001001",
		      X"243185be" when B"001010",
		      X"550c7dc3" when B"001011",
		      X"72be5d74" when B"001100",
		      X"80deb1fe" when B"001101",
		      X"9bdc06a7" when B"001110",
		      X"c19bf174" when B"001111",
 
		      X"e49b69c1" when B"010000",
		      X"efbe4786" when B"010001",
		      X"0fc19dc6" when B"010010",
		      X"240ca1cc" when B"010011",
		      X"2de92c6f" when B"010100",
		      X"4a7484aa" when B"010101",
		      X"5cb0a9dc" when B"010110",
		      X"76f988da" when B"010111",
 
		      X"983e5152" when B"011000",
		      X"a831c66d" when B"011001",
		      X"b00327c8" when B"011010",
		      X"bf597fc7" when B"011011",
		      X"c6e00bf3" when B"011100",
		      X"d5a79147" when B"011101",
		      X"06ca6351" when B"011110",
		      X"14292967" when B"011111",
 
		      X"27b70a85" when B"100000",
		      X"2e1b2138" when B"100001",
		      X"4d2c6dfc" when B"100010",
		      X"53380d13" when B"100011",
		      X"650a7354" when B"100100",
		      X"766a0abb" when B"100101",
		      X"81c2c92e" when B"100110",
		      X"92722c85" when B"100111",
 
		      X"a2bfe8a1" when B"101000",
		      X"a81a664b" when B"101001",
		      X"c24b8b70" when B"101010",
		      X"c76c51a3" when B"101011",
		      X"d192e819" when B"101100",
		      X"d6990624" when B"101101",
		      X"f40e3585" when B"101110",
		      X"106aa070" when B"101111",
 
		      X"19a4c116" when B"110000",
		      X"1e376c08" when B"110001",
		      X"2748774c" when B"110010",
		      X"34b0bcb5" when B"110011",
		      X"391c0cb3" when B"110100",
		      X"4ed8aa4a" when B"110101",
		      X"5b9cca4f" when B"110110",
		      X"682e6ff3" when B"110111",
 
		      X"748f82ee" when B"111000",
		      X"78a5636f" when B"111001",
		      X"84c87814" when B"111010",
		      X"8cc70208" when B"111011",
		      X"90befffa" when B"111100",
		      X"a4506ceb" when B"111101",
		      X"bef9a3f7" when B"111110",
		      X"c67178f2" when B"111111";
end phy;