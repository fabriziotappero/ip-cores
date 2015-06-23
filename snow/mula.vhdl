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

entity mula is
  port (
  c                : in  bit_vector (  7 downto 0);
  w                : out bit_vector ( 31 downto 0)
  );
end mula;

architecture phy of mula is
begin
with c select
w <=

X"00000000" when X"00", X"e19fcf13" when X"01", X"6b973726" when X"02", X"8a08f835" when X"03",
X"d6876e4c" when X"04", X"3718a15f" when X"05", X"bd10596a" when X"06", X"5c8f9679" when X"07",
X"05a7dc98" when X"08", X"e438138b" when X"09", X"6e30ebbe" when X"0a", X"8faf24ad" when X"0b",
X"d320b2d4" when X"0c", X"32bf7dc7" when X"0d", X"b8b785f2" when X"0e", X"59284ae1" when X"0f",

X"0ae71199" when X"10", X"eb78de8a" when X"11", X"617026bf" when X"12", X"80efe9ac" when X"13",
X"dc607fd5" when X"14", X"3dffb0c6" when X"15", X"b7f748f3" when X"16", X"566887e0" when X"17",
X"0f40cd01" when X"18", X"eedf0212" when X"19", X"64d7fa27" when X"1a", X"85483534" when X"1b",
X"d9c7a34d" when X"1c", X"38586c5e" when X"1d", X"b250946b" when X"1e", X"53cf5b78" when X"1f",

X"1467229b" when X"20", X"f5f8ed88" when X"21", X"7ff015bd" when X"22", X"9e6fdaae" when X"23",
X"c2e04cd7" when X"24", X"237f83c4" when X"25", X"a9777bf1" when X"26", X"48e8b4e2" when X"27",
X"11c0fe03" when X"28", X"f05f3110" when X"29", X"7a57c925" when X"2a", X"9bc80636" when X"2b",
X"c747904f" when X"2c", X"26d85f5c" when X"2d", X"acd0a769" when X"2e", X"4d4f687a" when X"2f",

X"1e803302" when X"30", X"ff1ffc11" when X"31", X"75170424" when X"32", X"9488cb37" when X"33",
X"c8075d4e" when X"34", X"2998925d" when X"35", X"a3906a68" when X"36", X"420fa57b" when X"37",
X"1b27ef9a" when X"38", X"fab82089" when X"39", X"70b0d8bc" when X"3a", X"912f17af" when X"3b",
X"cda081d6" when X"3c", X"2c3f4ec5" when X"3d", X"a637b6f0" when X"3e", X"47a879e3" when X"3f",

X"28ce449f" when X"40", X"c9518b8c" when X"41", X"435973b9" when X"42", X"a2c6bcaa" when X"43",
X"fe492ad3" when X"44", X"1fd6e5c0" when X"45", X"95de1df5" when X"46", X"7441d2e6" when X"47",
X"2d699807" when X"48", X"ccf65714" when X"49", X"46feaf21" when X"4a", X"a7616032" when X"4b",
X"fbeef64b" when X"4c", X"1a713958" when X"4d", X"9079c16d" when X"4e", X"71e60e7e" when X"4f",

X"22295506" when X"50", X"c3b69a15" when X"51", X"49be6220" when X"52", X"a821ad33" when X"53",
X"f4ae3b4a" when X"54", X"1531f459" when X"55", X"9f390c6c" when X"56", X"7ea6c37f" when X"57",
X"278e899e" when X"58", X"c611468d" when X"59", X"4c19beb8" when X"5a", X"ad8671ab" when X"5b",
X"f109e7d2" when X"5c", X"109628c1" when X"5d", X"9a9ed0f4" when X"5e", X"7b011fe7" when X"5f",

X"3ca96604" when X"60", X"dd36a917" when X"61", X"573e5122" when X"62", X"b6a19e31" when X"63",
X"ea2e0848" when X"64", X"0bb1c75b" when X"65", X"81b93f6e" when X"66", X"6026f07d" when X"67",
X"390eba9c" when X"68", X"d891758f" when X"69", X"52998dba" when X"6a", X"b30642a9" when X"6b",
X"ef89d4d0" when X"6c", X"0e161bc3" when X"6d", X"841ee3f6" when X"6e", X"65812ce5" when X"6f",

X"364e779d" when X"70", X"d7d1b88e" when X"71", X"5dd940bb" when X"72", X"bc468fa8" when X"73",
X"e0c919d1" when X"74", X"0156d6c2" when X"75", X"8b5e2ef7" when X"76", X"6ac1e1e4" when X"77",
X"33e9ab05" when X"78", X"d2766416" when X"79", X"587e9c23" when X"7a", X"b9e15330" when X"7b",
X"e56ec549" when X"7c", X"04f10a5a" when X"7d", X"8ef9f26f" when X"7e", X"6f663d7c" when X"7f",

X"50358897" when X"80", X"b1aa4784" when X"81", X"3ba2bfb1" when X"82", X"da3d70a2" when X"83",
X"86b2e6db" when X"84", X"672d29c8" when X"85", X"ed25d1fd" when X"86", X"0cba1eee" when X"87",
X"5592540f" when X"88", X"b40d9b1c" when X"89", X"3e056329" when X"8a", X"df9aac3a" when X"8b",
X"83153a43" when X"8c", X"628af550" when X"8d", X"e8820d65" when X"8e", X"091dc276" when X"8f",

X"5ad2990e" when X"90", X"bb4d561d" when X"91", X"3145ae28" when X"92", X"d0da613b" when X"93",
X"8c55f742" when X"94", X"6dca3851" when X"95", X"e7c2c064" when X"96", X"065d0f77" when X"97",
X"5f754596" when X"98", X"beea8a85" when X"99", X"34e272b0" when X"9a", X"d57dbda3" when X"9b",
X"89f22bda" when X"9c", X"686de4c9" when X"9d", X"e2651cfc" when X"9e", X"03fad3ef" when X"9f",

X"4452aa0c" when X"a0", X"a5cd651f" when X"a1", X"2fc59d2a" when X"a2", X"ce5a5239" when X"a3",
X"92d5c440" when X"a4", X"734a0b53" when X"a5", X"f942f366" when X"a6", X"18dd3c75" when X"a7",
X"41f57694" when X"a8", X"a06ab987" when X"a9", X"2a6241b2" when X"aa", X"cbfd8ea1" when X"ab",
X"977218d8" when X"ac", X"76edd7cb" when X"ad", X"fce52ffe" when X"ae", X"1d7ae0ed" when X"af",

X"4eb5bb95" when X"b0", X"af2a7486" when X"b1", X"25228cb3" when X"b2", X"c4bd43a0" when X"b3",
X"9832d5d9" when X"b4", X"79ad1aca" when X"b5", X"f3a5e2ff" when X"b6", X"123a2dec" when X"b7",
X"4b12670d" when X"b8", X"aa8da81e" when X"b9", X"2085502b" when X"ba", X"c11a9f38" when X"bb",
X"9d950941" when X"bc", X"7c0ac652" when X"bd", X"f6023e67" when X"be", X"179df174" when X"bf",

X"78fbcc08" when X"c0", X"9964031b" when X"c1", X"136cfb2e" when X"c2", X"f2f3343d" when X"c3",
X"ae7ca244" when X"c4", X"4fe36d57" when X"c5", X"c5eb9562" when X"c6", X"24745a71" when X"c7",
X"7d5c1090" when X"c8", X"9cc3df83" when X"c9", X"16cb27b6" when X"ca", X"f754e8a5" when X"cb",
X"abdb7edc" when X"cc", X"4a44b1cf" when X"cd", X"c04c49fa" when X"ce", X"21d386e9" when X"cf",

X"721cdd91" when X"d0", X"93831282" when X"d1", X"198beab7" when X"d2", X"f81425a4" when X"d3",
X"a49bb3dd" when X"d4", X"45047cce" when X"d5", X"cf0c84fb" when X"d6", X"2e934be8" when X"d7",
X"77bb0109" when X"d8", X"9624ce1a" when X"d9", X"1c2c362f" when X"da", X"fdb3f93c" when X"db",
X"a13c6f45" when X"dc", X"40a3a056" when X"dd", X"caab5863" when X"de", X"2b349770" when X"df",

X"6c9cee93" when X"e0", X"8d032180" when X"e1", X"070bd9b5" when X"e2", X"e69416a6" when X"e3",
X"ba1b80df" when X"e4", X"5b844fcc" when X"e5", X"d18cb7f9" when X"e6", X"301378ea" when X"e7",
X"693b320b" when X"e8", X"88a4fd18" when X"e9", X"02ac052d" when X"ea", X"e333ca3e" when X"eb",
X"bfbc5c47" when X"ec", X"5e239354" when X"ed", X"d42b6b61" when X"ee", X"35b4a472" when X"ef",

X"667bff0a" when X"f0", X"87e43019" when X"f1", X"0decc82c" when X"f2", X"ec73073f" when X"f3",
X"b0fc9146" when X"f4", X"51635e55" when X"f5", X"db6ba660" when X"f6", X"3af46973" when X"f7",
X"63dc2392" when X"f8", X"8243ec81" when X"f9", X"084b14b4" when X"fa", X"e9d4dba7" when X"fb",
X"b55b4dde" when X"fc", X"54c482cd" when X"fd", X"decc7af8" when X"fe", X"3f53b5eb" when X"ff",

X"00000000" when others;
end phy;
