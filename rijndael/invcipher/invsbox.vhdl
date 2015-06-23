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

entity invsbox is
  port (
  di : in  bit_vector (07 downto 00);
  do : out bit_vector (07 downto 00)
  );
end invsbox;

architecture phy of invsbox is
begin
  with di(07 downto 00) select
  do <=
  -- start invsbox
  X"52" when X"00", X"09" when X"01", X"6a" when X"02", X"d5" when X"03",
  X"30" when X"04", X"36" when X"05", X"a5" when X"06", X"38" when X"07",
  X"bf" when X"08", X"40" when X"09", X"a3" when X"0a", X"9e" when X"0b",
  X"81" when X"0c", X"f3" when X"0d", X"d7" when X"0e", X"fb" when X"0f",

  X"7c" when X"10", X"e3" when X"11", X"39" when X"12", X"82" when X"13",
  X"9b" when X"14", X"2f" when X"15", X"ff" when X"16", X"87" when X"17",
  X"34" when X"18", X"8e" when X"19", X"43" when X"1a", X"44" when X"1b",
  X"c4" when X"1c", X"de" when X"1d", X"e9" when X"1e", X"cb" when X"1f",

  X"54" when X"20", X"7b" when X"21", X"94" when X"22", X"32" when X"23",
  X"a6" when X"24", X"c2" when X"25", X"23" when X"26", X"3d" when X"27",
  X"ee" when X"28", X"4c" when X"29", X"95" when X"2a", X"0b" when X"2b",
  X"42" when X"2c", X"fa" when X"2d", X"c3" when X"2e", X"4e" when X"2f",

  X"08" when X"30", X"2e" when X"31", X"a1" when X"32", X"66" when X"33",
  X"28" when X"34", X"d9" when X"35", X"24" when X"36", X"b2" when X"37",
  X"76" when X"38", X"5b" when X"39", X"a2" when X"3a", X"49" when X"3b",
  X"6d" when X"3c", X"8b" when X"3d", X"d1" when X"3e", X"25" when X"3f",

  X"72" when X"40", X"f8" when X"41", X"f6" when X"42", X"64" when X"43",
  X"86" when X"44", X"68" when X"45", X"98" when X"46", X"16" when X"47",
  X"d4" when X"48", X"a4" when X"49", X"5c" when X"4a", X"cc" when X"4b",
  X"5d" when X"4c", X"65" when X"4d", X"b6" when X"4e", X"92" when X"4f",

  X"6c" when X"50", X"70" when X"51", X"48" when X"52", X"50" when X"53",
  X"fd" when X"54", X"ed" when X"55", X"b9" when X"56", X"da" when X"57",
  X"5e" when X"58", X"15" when X"59", X"46" when X"5a", X"57" when X"5b",
  X"a7" when X"5c", X"8d" when X"5d", X"9d" when X"5e", X"84" when X"5f",

  X"90" when X"60", X"d8" when X"61", X"ab" when X"62", X"00" when X"63",
  X"8c" when X"64", X"bc" when X"65", X"d3" when X"66", X"0a" when X"67",
  X"f7" when X"68", X"e4" when X"69", X"58" when X"6a", X"05" when X"6b",
  X"b8" when X"6c", X"b3" when X"6d", X"45" when X"6e", X"06" when X"6f",

  X"d0" when X"70", X"2c" when X"71", X"1e" when X"72", X"8f" when X"73",
  X"ca" when X"74", X"3f" when X"75", X"0f" when X"76", X"02" when X"77",
  X"c1" when X"78", X"af" when X"79", X"bd" when X"7a", X"03" when X"7b",
  X"01" when X"7c", X"13" when X"7d", X"8a" when X"7e", X"6b" when X"7f",

  X"3a" when X"80", X"91" when X"81", X"11" when X"82", X"41" when X"83",
  X"4f" when X"84", X"67" when X"85", X"dc" when X"86", X"ea" when X"87",
  X"97" when X"88", X"f2" when X"89", X"cf" when X"8a", X"ce" when X"8b",
  X"f0" when X"8c", X"b4" when X"8d", X"e6" when X"8e", X"73" when X"8f",

  X"96" when X"90", X"ac" when X"91", X"74" when X"92", X"22" when X"93",
  X"e7" when X"94", X"ad" when X"95", X"35" when X"96", X"85" when X"97",
  X"e2" when X"98", X"f9" when X"99", X"37" when X"9a", X"e8" when X"9b",
  X"1c" when X"9c", X"75" when X"9d", X"df" when X"9e", X"6e" when X"9f",

  X"47" when X"a0", X"f1" when X"a1", X"1a" when X"a2", X"71" when X"a3",
  X"1d" when X"a4", X"29" when X"a5", X"c5" when X"a6", X"89" when X"a7",
  X"6f" when X"a8", X"b7" when X"a9", X"62" when X"aa", X"0e" when X"ab",
  X"aa" when X"ac", X"18" when X"ad", X"be" when X"ae", X"1b" when X"af",

  X"fc" when X"b0", X"56" when X"b1", X"3e" when X"b2", X"4b" when X"b3",
  X"c6" when X"b4", X"d2" when X"b5", X"79" when X"b6", X"20" when X"b7",
  X"9a" when X"b8", X"db" when X"b9", X"c0" when X"ba", X"fe" when X"bb",
  X"78" when X"bc", X"cd" when X"bd", X"5a" when X"be", X"f4" when X"bf",

  X"1f" when X"c0", X"dd" when X"c1", X"a8" when X"c2", X"33" when X"c3",
  X"88" when X"c4", X"07" when X"c5", X"c7" when X"c6", X"31" when X"c7",
  X"b1" when X"c8", X"12" when X"c9", X"10" when X"ca", X"59" when X"cb",
  X"27" when X"cc", X"80" when X"cd", X"ec" when X"ce", X"5f" when X"cf",

  X"60" when X"d0", X"51" when X"d1", X"7f" when X"d2", X"a9" when X"d3",
  X"19" when X"d4", X"b5" when X"d5", X"4a" when X"d6", X"0d" when X"d7",
  X"2d" when X"d8", X"e5" when X"d9", X"7a" when X"da", X"9f" when X"db",
  X"93" when X"dc", X"c9" when X"dd", X"9c" when X"de", X"ef" when X"df",

  X"a0" when X"e0", X"e0" when X"e1", X"3b" when X"e2", X"4d" when X"e3",
  X"ae" when X"e4", X"2a" when X"e5", X"f5" when X"e6", X"b0" when X"e7",
  X"c8" when X"e8", X"eb" when X"e9", X"bb" when X"ea", X"3c" when X"eb",
  X"83" when X"ec", X"53" when X"ed", X"99" when X"ee", X"61" when X"ef",

  X"17" when X"f0", X"2b" when X"f1", X"04" when X"f2", X"7e" when X"f3",
  X"ba" when X"f4", X"77" when X"f5", X"d6" when X"f6", X"26" when X"f7",
  X"e1" when X"f8", X"69" when X"f9", X"14" when X"fa", X"63" when X"fb",
  X"55" when X"fc", X"21" when X"fd", X"0c" when X"fe", X"7d" when X"ff",

  -- end invsbox
  X"00" when others;
end phy;
