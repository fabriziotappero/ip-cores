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
  di : in  bit_vector (  7 downto 0);
  do : out bit_vector (  7 downto 0)
  );
end sbox;

architecture phy of sbox is
begin
  with di(  7 downto 0) select
  do <=
  -- start sbox

    X"70" when X"00", X"82" when X"01", X"2c" when X"02", X"ec" when X"03", X"b3" when X"04", X"27" when X"05", X"c0" when X"06", X"e5" when X"07",
    X"e4" when X"08", X"85" when X"09", X"57" when X"0a", X"35" when X"0b", X"ea" when X"0c", X"0c" when X"0d", X"ae" when X"0e", X"41" when X"0f",
    X"23" when X"10", X"ef" when X"11", X"6b" when X"12", X"93" when X"13", X"45" when X"14", X"19" when X"15", X"a5" when X"16", X"21" when X"17",
    X"ed" when X"18", X"0e" when X"19", X"4f" when X"1a", X"4e" when X"1b", X"1d" when X"1c", X"65" when X"1d", X"92" when X"1e", X"bd" when X"1f",
    X"86" when X"20", X"b8" when X"21", X"af" when X"22", X"8f" when X"23", X"7c" when X"24", X"eb" when X"25", X"1f" when X"26", X"ce" when X"27",
    X"3e" when X"28", X"30" when X"29", X"dc" when X"2a", X"5f" when X"2b", X"5e" when X"2c", X"c5" when X"2d", X"0b" when X"2e", X"1a" when X"2f",
    X"a6" when X"30", X"e1" when X"31", X"39" when X"32", X"ca" when X"33", X"d5" when X"34", X"47" when X"35", X"5d" when X"36", X"3d" when X"37",
    X"d9" when X"38", X"01" when X"39", X"5a" when X"3a", X"d6" when X"3b", X"51" when X"3c", X"56" when X"3d", X"6c" when X"3e", X"4d" when X"3f",
    X"8b" when X"40", X"0d" when X"41", X"9a" when X"42", X"66" when X"43", X"fb" when X"44", X"cc" when X"45", X"b0" when X"46", X"2d" when X"47",
    X"74" when X"48", X"12" when X"49", X"2b" when X"4a", X"20" when X"4b", X"f0" when X"4c", X"b1" when X"4d", X"84" when X"4e", X"99" when X"4f",
    X"df" when X"50", X"4c" when X"51", X"cb" when X"52", X"c2" when X"53", X"34" when X"54", X"7e" when X"55", X"76" when X"56", X"05" when X"57",
    X"6d" when X"58", X"b7" when X"59", X"a9" when X"5a", X"31" when X"5b", X"d1" when X"5c", X"17" when X"5d", X"04" when X"5e", X"d7" when X"5f",
    X"14" when X"60", X"58" when X"61", X"3a" when X"62", X"61" when X"63", X"de" when X"64", X"1b" when X"65", X"11" when X"66", X"1c" when X"67",
    X"32" when X"68", X"0f" when X"69", X"9c" when X"6a", X"16" when X"6b", X"53" when X"6c", X"18" when X"6d", X"f2" when X"6e", X"22" when X"6f",
    X"fe" when X"70", X"44" when X"71", X"cf" when X"72", X"b2" when X"73", X"c3" when X"74", X"b5" when X"75", X"7a" when X"76", X"91" when X"77",
    X"24" when X"78", X"08" when X"79", X"e8" when X"7a", X"a8" when X"7b", X"60" when X"7c", X"fc" when X"7d", X"69" when X"7e", X"50" when X"7f",
    X"aa" when X"80", X"d0" when X"81", X"a0" when X"82", X"7d" when X"83", X"a1" when X"84", X"89" when X"85", X"62" when X"86", X"97" when X"87",
    X"54" when X"88", X"5b" when X"89", X"1e" when X"8a", X"95" when X"8b", X"e0" when X"8c", X"ff" when X"8d", X"64" when X"8e", X"d2" when X"8f",
    X"10" when X"90", X"c4" when X"91", X"00" when X"92", X"48" when X"93", X"a3" when X"94", X"f7" when X"95", X"75" when X"96", X"db" when X"97",
    X"8a" when X"98", X"03" when X"99", X"e6" when X"9a", X"da" when X"9b", X"09" when X"9c", X"3f" when X"9d", X"dd" when X"9e", X"94" when X"9f",
    X"87" when X"a0", X"5c" when X"a1", X"83" when X"a2", X"02" when X"a3", X"cd" when X"a4", X"4a" when X"a5", X"90" when X"a6", X"33" when X"a7",
    X"73" when X"a8", X"67" when X"a9", X"f6" when X"aa", X"f3" when X"ab", X"9d" when X"ac", X"7f" when X"ad", X"bf" when X"ae", X"e2" when X"af",
    X"52" when X"b0", X"9b" when X"b1", X"d8" when X"b2", X"26" when X"b3", X"c8" when X"b4", X"37" when X"b5", X"c6" when X"b6", X"3b" when X"b7",
    X"81" when X"b8", X"96" when X"b9", X"6f" when X"ba", X"4b" when X"bb", X"13" when X"bc", X"be" when X"bd", X"63" when X"be", X"2e" when X"bf",
    X"e9" when X"c0", X"79" when X"c1", X"a7" when X"c2", X"8c" when X"c3", X"9f" when X"c4", X"6e" when X"c5", X"bc" when X"c6", X"8e" when X"c7",
    X"29" when X"c8", X"f5" when X"c9", X"f9" when X"ca", X"b6" when X"cb", X"2f" when X"cc", X"fd" when X"cd", X"b4" when X"ce", X"59" when X"cf",
    X"78" when X"d0", X"98" when X"d1", X"06" when X"d2", X"6a" when X"d3", X"e7" when X"d4", X"46" when X"d5", X"71" when X"d6", X"ba" when X"d7",
    X"d4" when X"d8", X"25" when X"d9", X"ab" when X"da", X"42" when X"db", X"88" when X"dc", X"a2" when X"dd", X"8d" when X"de", X"fa" when X"df",
    X"72" when X"e0", X"07" when X"e1", X"b9" when X"e2", X"55" when X"e3", X"f8" when X"e4", X"ee" when X"e5", X"ac" when X"e6", X"0a" when X"e7",
    X"36" when X"e8", X"49" when X"e9", X"2a" when X"ea", X"68" when X"eb", X"3c" when X"ec", X"38" when X"ed", X"f1" when X"ee", X"a4" when X"ef",
    X"40" when X"f0", X"28" when X"f1", X"d3" when X"f2", X"7b" when X"f3", X"bb" when X"f4", X"c9" when X"f5", X"43" when X"f6", X"c1" when X"f7",
    X"15" when X"f8", X"e3" when X"f9", X"ad" when X"fa", X"f4" when X"fb", X"77" when X"fc", X"c7" when X"fd", X"80" when X"fe", X"9e" when X"ff";

  -- end sbox

end phy;
