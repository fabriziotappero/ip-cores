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
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.shaPkg.all;

entity romk is
  port (
  addr  : in  integer range 0 to STMAX-1;
  k     : out std_logic_vector (0 to WW-1)
  );
end romk;

architecture phy of romk is
begin
  with addr select
  k        <= X"428a2f98" when 0,
		      X"71374491" when 1,
		      X"b5c0fbcf" when 2,
		      X"e9b5dba5" when 3,
		      X"3956c25b" when 4,
		      X"59f111f1" when 5,
		      X"923f82a4" when 6,
		      X"ab1c5ed5" when 7,

		      X"d807aa98" when 8,
		      X"12835b01" when 9,
		      X"243185be" when 10,
		      X"550c7dc3" when 11,
		      X"72be5d74" when 12,
		      X"80deb1fe" when 13,
		      X"9bdc06a7" when 14,
		      X"c19bf174" when 15,

		      X"e49b69c1" when 16,
		      X"efbe4786" when 17,
		      X"0fc19dc6" when 18,
		      X"240ca1cc" when 19,
		      X"2de92c6f" when 20,
		      X"4a7484aa" when 21,
		      X"5cb0a9dc" when 22,
		      X"76f988da" when 23,

		      X"983e5152" when 24,
		      X"a831c66d" when 25,
		      X"b00327c8" when 26,
		      X"bf597fc7" when 27,
		      X"c6e00bf3" when 28,
		      X"d5a79147" when 29,
		      X"06ca6351" when 30,
		      X"14292967" when 31,

		      X"27b70a85" when 32,
		      X"2e1b2138" when 33,
		      X"4d2c6dfc" when 34,
		      X"53380d13" when 35,
		      X"650a7354" when 36,
		      X"766a0abb" when 37,
		      X"81c2c92e" when 38,
		      X"92722c85" when 39,
		      
		      X"a2bfe8a1" when 40,
		      X"a81a664b" when 41,
		      X"c24b8b70" when 42,
		      X"c76c51a3" when 43,
		      X"d192e819" when 44,
		      X"d6990624" when 45,
		      X"f40e3585" when 46,
		      X"106aa070" when 47,

		      X"19a4c116" when 48,
		      X"1e376c08" when 49,
		      X"2748774c" when 50,
		      X"34b0bcb5" when 51,
		      X"391c0cb3" when 52,
		      X"4ed8aa4a" when 53,
		      X"5b9cca4f" when 54,
		      X"682e6ff3" when 55,

		      X"748f82ee" when 56,
		      X"78a5636f" when 57,
		      X"84c87814" when 58,
		      X"8cc70208" when 59,
		      X"90befffa" when 60,
		      X"a4506ceb" when 61,
		      X"bef9a3f7" when 62,
		      X"c67178f2" when 63,
			  
			  X"00000000" when others;
end phy;
