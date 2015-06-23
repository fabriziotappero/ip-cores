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

entity sbox is
  port (
  di : in  bit_vector (07 downto 00);
  do : out bit_vector (07 downto 00)
  );
end sbox;

architecture phy of sbox is
begin
  with di(07 downto 00) select
  do <=
  -- start sbox
  X"63" when X"00", X"7c" when X"01", X"77" when X"02", X"7b" when X"03",
  X"f2" when X"04", X"6b" when X"05", X"6f" when X"06", X"c5" when X"07",
  X"30" when X"08", X"01" when X"09", X"67" when X"0a", X"2b" when X"0b",
  X"fe" when X"0c", X"d7" when X"0d", X"ab" when X"0e", X"76" when X"0f",

  X"ca" when X"10", X"82" when X"11", X"c9" when X"12", X"7d" when X"13",
  X"fa" when X"14", X"59" when X"15", X"47" when X"16", X"f0" when X"17",
  X"ad" when X"18", X"d4" when X"19", X"a2" when X"1a", X"af" when X"1b",
  X"9c" when X"1c", X"a4" when X"1d", X"72" when X"1e", X"c0" when X"1f",

  X"b7" when X"20", X"fd" when X"21", X"93" when X"22", X"26" when X"23",
  X"36" when X"24", X"3f" when X"25", X"f7" when X"26", X"cc" when X"27",
  X"34" when X"28", X"a5" when X"29", X"e5" when X"2a", X"f1" when X"2b",
  X"71" when X"2c", X"d8" when X"2d", X"31" when X"2e", X"15" when X"2f",

  X"04" when X"30", X"c7" when X"31", X"23" when X"32", X"c3" when X"33",
  X"18" when X"34", X"96" when X"35", X"05" when X"36", X"9a" when X"37",
  X"07" when X"38", X"12" when X"39", X"80" when X"3a", X"e2" when X"3b",
  X"eb" when X"3c", X"27" when X"3d", X"b2" when X"3e", X"75" when X"3f",

  X"09" when X"40", X"83" when X"41", X"2c" when X"42", X"1a" when X"43",
  X"1b" when X"44", X"6e" when X"45", X"5a" when X"46", X"a0" when X"47",
  X"52" when X"48", X"3b" when X"49", X"d6" when X"4a", X"b3" when X"4b",
  X"29" when X"4c", X"e3" when X"4d", X"2f" when X"4e", X"84" when X"4f",

  X"53" when X"50", X"d1" when X"51", X"00" when X"52", X"ed" when X"53",
  X"20" when X"54", X"fc" when X"55", X"b1" when X"56", X"5b" when X"57",
  X"6a" when X"58", X"cb" when X"59", X"be" when X"5a", X"39" when X"5b",
  X"4a" when X"5c", X"4c" when X"5d", X"58" when X"5e", X"cf" when X"5f",

  X"d0" when X"60", X"ef" when X"61", X"aa" when X"62", X"fb" when X"63",
  X"43" when X"64", X"4d" when X"65", X"33" when X"66", X"85" when X"67",
  X"45" when X"68", X"f9" when X"69", X"02" when X"6a", X"7f" when X"6b",
  X"50" when X"6c", X"3c" when X"6d", X"9f" when X"6e", X"a8" when X"6f",

  X"51" when X"70", X"a3" when X"71", X"40" when X"72", X"8f" when X"73",
  X"92" when X"74", X"9d" when X"75", X"38" when X"76", X"f5" when X"77",
  X"bc" when X"78", X"b6" when X"79", X"da" when X"7a", X"21" when X"7b",
  X"10" when X"7c", X"ff" when X"7d", X"f3" when X"7e", X"d2" when X"7f",

  X"cd" when X"80", X"0c" when X"81", X"13" when X"82", X"ec" when X"83",
  X"5f" when X"84", X"97" when X"85", X"44" when X"86", X"17" when X"87",
  X"c4" when X"88", X"a7" when X"89", X"7e" when X"8a", X"3d" when X"8b",
  X"64" when X"8c", X"5d" when X"8d", X"19" when X"8e", X"73" when X"8f",

  X"60" when X"90", X"81" when X"91", X"4f" when X"92", X"dc" when X"93",
  X"22" when X"94", X"2a" when X"95", X"90" when X"96", X"88" when X"97",
  X"46" when X"98", X"ee" when X"99", X"b8" when X"9a", X"14" when X"9b",
  X"de" when X"9c", X"5e" when X"9d", X"0b" when X"9e", X"db" when X"9f",

  X"e0" when X"a0", X"32" when X"a1", X"3a" when X"a2", X"0a" when X"a3",
  X"49" when X"a4", X"06" when X"a5", X"24" when X"a6", X"5c" when X"a7",
  X"c2" when X"a8", X"d3" when X"a9", X"ac" when X"aa", X"62" when X"ab",
  X"91" when X"ac", X"95" when X"ad", X"e4" when X"ae", X"79" when X"af",

  X"e7" when X"b0", X"c8" when X"b1", X"37" when X"b2", X"6d" when X"b3",
  X"8d" when X"b4", X"d5" when X"b5", X"4e" when X"b6", X"a9" when X"b7",
  X"6c" when X"b8", X"56" when X"b9", X"f4" when X"ba", X"ea" when X"bb",
  X"65" when X"bc", X"7a" when X"bd", X"ae" when X"be", X"08" when X"bf",

  X"ba" when X"c0", X"78" when X"c1", X"25" when X"c2", X"2e" when X"c3",
  X"1c" when X"c4", X"a6" when X"c5", X"b4" when X"c6", X"c6" when X"c7",
  X"e8" when X"c8", X"dd" when X"c9", X"74" when X"ca", X"1f" when X"cb",
  X"4b" when X"cc", X"bd" when X"cd", X"8b" when X"ce", X"8a" when X"cf",

  X"70" when X"d0", X"3e" when X"d1", X"b5" when X"d2", X"66" when X"d3",
  X"48" when X"d4", X"03" when X"d5", X"f6" when X"d6", X"0e" when X"d7",
  X"61" when X"d8", X"35" when X"d9", X"57" when X"da", X"b9" when X"db",
  X"86" when X"dc", X"c1" when X"dd", X"1d" when X"de", X"9e" when X"df",

  X"e1" when X"e0", X"f8" when X"e1", X"98" when X"e2", X"11" when X"e3",
  X"69" when X"e4", X"d9" when X"e5", X"8e" when X"e6", X"94" when X"e7",
  X"9b" when X"e8", X"1e" when X"e9", X"87" when X"ea", X"e9" when X"eb",
  X"ce" when X"ec", X"55" when X"ed", X"28" when X"ee", X"df" when X"ef",

  X"8c" when X"f0", X"a1" when X"f1", X"89" when X"f2", X"0d" when X"f3",
  X"bf" when X"f4", X"e6" when X"f5", X"42" when X"f6", X"68" when X"f7",
  X"41" when X"f8", X"99" when X"f9", X"2d" when X"fa", X"0f" when X"fb",
  X"b0" when X"fc", X"54" when X"fd", X"bb" when X"fe", X"16" when X"ff",

  -- end sbox
  X"00" when others;
end phy;
