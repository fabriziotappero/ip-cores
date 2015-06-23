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

entity key is
  port (
  st : in  bit_vector ( 7 downto 0);
  Nk : in  bit_vector ( 3 downto 0);
  key: out bit_vector (31 downto 0)  -- 32 bit key output
  );
end key;

architecture phy of key is
signal keya : bit_vector (31 downto 0);
signal keyb : bit_vector (31 downto 0);
signal keyc : bit_vector (31 downto 0);
begin

  with Nk(3 downto 0) select
  key <=
  keya        when X"4",
  keyb        when X"6",
  keyc        when X"8",
  X"00000000" when others;

  with st(7 downto 0) select
  keya <=
  X"2b7e1516" when X"00", -- 0
  X"28aed2a6" when X"01", -- 1
  X"abf71588" when X"02", -- 2
  X"09cf4f3c" when X"03", -- 3
  X"a0fafe17" when X"04", -- 4
  X"88542cb1" when X"05", -- 5
  X"23a33939" when X"06", -- 6
  X"2a6c7605" when X"07", -- 7
  X"f2c295f2" when X"08", -- 8
  X"7a96b943" when X"09", -- 9
  X"5935807a" when X"0a", -- 0
  X"7359f67f" when X"0b", -- 1
  X"3d80477d" when X"0c", -- 2
  X"4716fe3e" when X"0d", -- 3
  X"1e237e44" when X"0e", -- 4
  X"6d7a883b" when X"0f", -- 5
  X"ef44a541" when X"10", -- 6
  X"a8525b7f" when X"11", -- 7
  X"b671253b" when X"12", -- 8
  X"db0bad00" when X"13", -- 9
  X"d4d1c6f8" when X"14", -- 0
  X"7c839d87" when X"15", -- 1
  X"caf2b8bc" when X"16", -- 2
  X"11f915bc" when X"17", -- 3
  X"6d88a37a" when X"18", -- 4
  X"110b3efd" when X"19", -- 5
  X"dbf98641" when X"1a", -- 6
  X"ca0093fd" when X"1b", -- 7
  X"4e54f70e" when X"1c", -- 8
  X"5f5fc9f3" when X"1d", -- 9
  X"84a64fb2" when X"1e", -- 0
  X"4ea6dc4f" when X"1f", -- 1
  X"ead27321" when X"20", -- 2
  X"b58dbad2" when X"21", -- 3
  X"312bf560" when X"22", -- 4
  X"7f8d292f" when X"23", -- 5
  X"ac7766f3" when X"24", -- 6
  X"19fadc21" when X"25", -- 7
  X"28d12941" when X"26", -- 8
  X"575c006e" when X"27", -- 9
  X"d014f9a8" when X"28", -- 0
  X"c9ee2589" when X"29", -- 1
  X"e13f0cc8" when X"2a", -- 2
  X"b6630ca6" when X"2b", -- 3
  X"00000000" when others;

  with st(7 downto 0) select
  keyb <=
  X"8e73b0f7" when X"00",
  X"da0e6452" when X"01",
  X"c810f32b" when X"02",
  X"809079e5" when X"03",
  X"62f8ead2" when X"04",
  X"522c6b7b" when X"05",
  X"fe0c91f7" when X"06",
  X"2402f5a5" when X"07",
  X"ec12068e" when X"08",
  X"6c827f6b" when X"09",
  X"0e7a95b9" when X"0a",
  X"5c56fec2" when X"0b",
  X"4db7b4bd" when X"0c",
  X"69b54118" when X"0d",
  X"85a74796" when X"0e",
  X"e92538fd" when X"0f",
  X"e75fad44" when X"10",
  X"bb095386" when X"11",
  X"485af057" when X"12",
  X"21efb14f" when X"13",
  X"a448f6d9" when X"14",
  X"4d6dce24" when X"15",
  X"aa326360" when X"16",
  X"113b30e6" when X"17",
  X"a25e7ed5" when X"18",
  X"83b1cf9a" when X"19",
  X"27f93943" when X"1a",
  X"6a94f767" when X"1b",
  X"c0a69407" when X"1c",
  X"d19da4e1" when X"1d",
  X"ec1786eb" when X"1e",
  X"6fa64971" when X"1f",
  X"485f7032" when X"20",
  X"22cb8755" when X"21",
  X"e26d1352" when X"22",
  X"33f0b7b3" when X"23",
  X"40beeb28" when X"24",
  X"2f18a259" when X"25",
  X"6747d26b" when X"26",
  X"458c553e" when X"27",
  X"a7e1466c" when X"28",
  X"9411f1df" when X"29",
  X"821f750a" when X"2a",
  X"ad07d753" when X"2b",
  X"ca400538" when X"2c",
  X"8fcc5006" when X"2d",
  X"282d166a" when X"2e",
  X"bc3ce7b5" when X"2f",
  X"e98ba06f" when X"30",
  X"448c773c" when X"31",
  X"8ecc7204" when X"32",
  X"01002202" when X"33",
  X"00000000" when others;

  with st(7 downto 0) select
  keyc <=
  X"603deb10" when X"00",
  X"15ca71be" when X"01",
  X"2b73aef0" when X"02",
  X"857d7781" when X"03",
  X"1f352c07" when X"04",
  X"3b6108d7" when X"05",
  X"2d9810a3" when X"06",
  X"0914dff4" when X"07",
  X"9ba35411" when X"08",
  X"8e6925af" when X"09",
  X"a51a8b5f" when X"0a",
  X"2067fcde" when X"0b",
  X"a8b09c1a" when X"0c",
  X"93d194cd" when X"0d",
  X"be49846e" when X"0e",
  X"b75d5b9a" when X"0f",
  X"d59aecb8" when X"10",
  X"5bf3c917" when X"11",
  X"fee94248" when X"12",
  X"de8ebe96" when X"13",
  X"b5a9328a" when X"14",
  X"2678a647" when X"15",
  X"98312229" when X"16",
  X"2f6c79b3" when X"17",
  X"812c81ad" when X"18",
  X"dadf48ba" when X"19",
  X"24360af2" when X"1a",
  X"fab8b464" when X"1b",
  X"98c5bfc9" when X"1c",
  X"bebd198e" when X"1d",
  X"268c3ba7" when X"1e",
  X"09e04214" when X"1f",
  X"68007bac" when X"20",
  X"b2df3316" when X"21",
  X"96e939e4" when X"22",
  X"6c518d80" when X"23",
  X"c814e204" when X"24",
  X"76a9fb8a" when X"25",
  X"5025c02d" when X"26",
  X"59c58239" when X"27",
  X"de136967" when X"28",
  X"6ccc5a71" when X"29",
  X"fa256395" when X"2a",
  X"9674ee15" when X"2b",
  X"5886ca5d" when X"2c",
  X"2e2f31d7" when X"2d",
  X"7e0af1fa" when X"2e",
  X"27cf73c3" when X"2f",
  X"749c47ab" when X"30",
  X"18501dda" when X"31",
  X"e2757e4f" when X"32",
  X"7401905a" when X"33",
  X"cafaaae3" when X"34",
  X"e4d59b34" when X"35",
  X"9adf6ace" when X"36",
  X"bd10190d" when X"37",
  X"fe4890d1" when X"38",
  X"e6188d0b" when X"39",
  X"046df344" when X"3a",
  X"706c631e" when X"3b",
  X"00000000" when others;

end phy;
