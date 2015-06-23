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
use ieee.std_logic_unsigned.all;

entity sboxq is
  port (
  di : in  bit_vector (07 downto 00);
  do : out bit_vector (07 downto 00)
  );
end sboxq;

architecture phy of sboxq is
begin
  with di(07 downto 00) select
  do <=
  -- start sboxq

X"25" when X"00", X"24" when X"01", X"73" when X"02", X"67" when X"03",
X"d7" when X"04", X"ae" when X"05", X"5c" when X"06", X"30" when X"07",
X"a4" when X"08", X"ee" when X"09", X"6e" when X"0a", X"cb" when X"0b",
X"7d" when X"0c", X"b5" when X"0d", X"82" when X"0e", X"db" when X"0f",

X"e4" when X"10", X"8e" when X"11", X"48" when X"12", X"49" when X"13",
X"4f" when X"14", X"5d" when X"15", X"6a" when X"16", X"78" when X"17",
X"70" when X"18", X"88" when X"19", X"e8" when X"1a", X"5f" when X"1b",
X"5e" when X"1c", X"84" when X"1d", X"65" when X"1e", X"e2" when X"1f",

X"d8" when X"20", X"e9" when X"21", X"cc" when X"22", X"ed" when X"23",
X"40" when X"24", X"2f" when X"25", X"11" when X"26", X"28" when X"27",
X"57" when X"28", X"d2" when X"29", X"ac" when X"2a", X"e3" when X"2b",
X"4a" when X"2c", X"15" when X"2d", X"1b" when X"2e", X"b9" when X"2f",

X"b2" when X"30", X"80" when X"31", X"85" when X"32", X"a6" when X"33",
X"2e" when X"34", X"02" when X"35", X"47" when X"36", X"29" when X"37",
X"07" when X"38", X"4b" when X"39", X"0e" when X"3a", X"c1" when X"3b",
X"51" when X"3c", X"aa" when X"3d", X"89" when X"3e", X"d4" when X"3f",

X"ca" when X"40", X"01" when X"41", X"46" when X"42", X"b3" when X"43",
X"ef" when X"44", X"dd" when X"45", X"44" when X"46", X"7b" when X"47",
X"c2" when X"48", X"7f" when X"49", X"be" when X"4a", X"c3" when X"4b",
X"9f" when X"4c", X"20" when X"4d", X"4c" when X"4e", X"64" when X"4f",

X"83" when X"50", X"a2" when X"51", X"68" when X"52", X"42" when X"53",
X"13" when X"54", X"b4" when X"55", X"41" when X"56", X"cd" when X"57",
X"ba" when X"58", X"c6" when X"59", X"bb" when X"5a", X"6d" when X"5b",
X"4d" when X"5c", X"71" when X"5d", X"21" when X"5e", X"f4" when X"5f",

X"8d" when X"60", X"b0" when X"61", X"e5" when X"62", X"93" when X"63",
X"fe" when X"64", X"8f" when X"65", X"e6" when X"66", X"cf" when X"67",
X"43" when X"68", X"45" when X"69", X"31" when X"6a", X"22" when X"6b",
X"37" when X"6c", X"36" when X"6d", X"96" when X"6e", X"fa" when X"6f",

X"bc" when X"70", X"0f" when X"71", X"08" when X"72", X"52" when X"73",
X"1d" when X"74", X"55" when X"75", X"1a" when X"76", X"c5" when X"77",
X"4e" when X"78", X"23" when X"79", X"69" when X"7a", X"7a" when X"7b",
X"92" when X"7c", X"ff" when X"7d", X"5b" when X"7e", X"5a" when X"7f",

X"eb" when X"80", X"9a" when X"81", X"1c" when X"82", X"a9" when X"83",
X"d1" when X"84", X"7e" when X"85", X"0d" when X"86", X"fc" when X"87",
X"50" when X"88", X"8a" when X"89", X"b6" when X"8a", X"62" when X"8b",
X"f5" when X"8c", X"0a" when X"8d", X"f8" when X"8e", X"dc" when X"8f",

X"03" when X"90", X"3c" when X"91", X"0c" when X"92", X"39" when X"93",
X"f1" when X"94", X"b8" when X"95", X"f3" when X"96", X"3d" when X"97",
X"f2" when X"98", X"d5" when X"99", X"97" when X"9a", X"66" when X"9b",
X"81" when X"9c", X"32" when X"9d", X"a0" when X"9e", X"00" when X"9f",

X"06" when X"a0", X"ce" when X"a1", X"f6" when X"a2", X"ea" when X"a3",
X"b7" when X"a4", X"17" when X"a5", X"f7" when X"a6", X"8c" when X"a7",
X"79" when X"a8", X"d6" when X"a9", X"a7" when X"aa", X"bf" when X"ab",
X"8b" when X"ac", X"3f" when X"ad", X"1f" when X"ae", X"53" when X"af",

X"63" when X"b0", X"75" when X"b1", X"35" when X"b2", X"2c" when X"b3",
X"60" when X"b4", X"fd" when X"b5", X"27" when X"b6", X"d3" when X"b7",
X"94" when X"b8", X"a5" when X"b9", X"7c" when X"ba", X"a1" when X"bb",
X"05" when X"bc", X"58" when X"bd", X"2d" when X"be", X"bd" when X"bf",

X"d9" when X"c0", X"c7" when X"c1", X"af" when X"c2", X"6b" when X"c3",
X"54" when X"c4", X"0b" when X"c5", X"e0" when X"c6", X"38" when X"c7",
X"04" when X"c8", X"c8" when X"c9", X"9d" when X"ca", X"e7" when X"cb",
X"14" when X"cc", X"b1" when X"cd", X"87" when X"ce", X"9c" when X"cf",

X"df" when X"d0", X"6f" when X"d1", X"f9" when X"d2", X"da" when X"d3",
X"2a" when X"d4", X"c4" when X"d5", X"59" when X"d6", X"16" when X"d7",
X"74" when X"d8", X"91" when X"d9", X"ab" when X"da", X"26" when X"db",
X"61" when X"dc", X"76" when X"dd", X"34" when X"de", X"2b" when X"df",

X"ad" when X"e0", X"99" when X"e1", X"fb" when X"e2", X"72" when X"e3",
X"ec" when X"e4", X"33" when X"e5", X"12" when X"e6", X"de" when X"e7",
X"98" when X"e8", X"3b" when X"e9", X"c0" when X"ea", X"9b" when X"eb",
X"3e" when X"ec", X"18" when X"ed", X"10" when X"ee", X"3a" when X"ef",

X"56" when X"f0", X"e1" when X"f1", X"77" when X"f2", X"c9" when X"f3",
X"1e" when X"f4", X"9e" when X"f5", X"95" when X"f6", X"a3" when X"f7",
X"90" when X"f8", X"19" when X"f9", X"a8" when X"fa", X"6c" when X"fb",
X"09" when X"fc", X"d0" when X"fd", X"f0" when X"fe", X"86" when X"ff",

  -- end sboxq
  X"00" when others;
end phy;
