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

entity diva is
  port (
  c                : in  bit_vector (  7 downto 0);
  w                : out bit_vector ( 31 downto 0)
  );
end diva;

architecture phy of diva is
begin
with c select
w <=

X"00000000" when X"00", X"180f40cd" when X"01", X"301e8033" when X"02", X"2811c0fe" when X"03",
X"603ca966" when X"04", X"7833e9ab" when X"05", X"50222955" when X"06", X"482d6998" when X"07",
X"c078fbcc" when X"08", X"d877bb01" when X"09", X"f0667bff" when X"0a", X"e8693b32" when X"0b",
X"a04452aa" when X"0c", X"b84b1267" when X"0d", X"905ad299" when X"0e", X"88559254" when X"0f",

X"29f05f31" when X"10", X"31ff1ffc" when X"11", X"19eedf02" when X"12", X"01e19fcf" when X"13",
X"49ccf657" when X"14", X"51c3b69a" when X"15", X"79d27664" when X"16", X"61dd36a9" when X"17",
X"e988a4fd" when X"18", X"f187e430" when X"19", X"d99624ce" when X"1a", X"c1996403" when X"1b",
X"89b40d9b" when X"1c", X"91bb4d56" when X"1d", X"b9aa8da8" when X"1e", X"a1a5cd65" when X"1f",

X"5249be62" when X"20", X"4a46feaf" when X"21", X"62573e51" when X"22", X"7a587e9c" when X"23",
X"32751704" when X"24", X"2a7a57c9" when X"25", X"026b9737" when X"26", X"1a64d7fa" when X"27",
X"923145ae" when X"28", X"8a3e0563" when X"29", X"a22fc59d" when X"2a", X"ba208550" when X"2b",
X"f20decc8" when X"2c", X"ea02ac05" when X"2d", X"c2136cfb" when X"2e", X"da1c2c36" when X"2f",

X"7bb9e153" when X"30", X"63b6a19e" when X"31", X"4ba76160" when X"32", X"53a821ad" when X"33",
X"1b854835" when X"34", X"038a08f8" when X"35", X"2b9bc806" when X"36", X"339488cb" when X"37",
X"bbc11a9f" when X"38", X"a3ce5a52" when X"39", X"8bdf9aac" when X"3a", X"93d0da61" when X"3b",
X"dbfdb3f9" when X"3c", X"c3f2f334" when X"3d", X"ebe333ca" when X"3e", X"f3ec7307" when X"3f",

X"a492d5c4" when X"40", X"bc9d9509" when X"41", X"948c55f7" when X"42", X"8c83153a" when X"43",
X"c4ae7ca2" when X"44", X"dca13c6f" when X"45", X"f4b0fc91" when X"46", X"ecbfbc5c" when X"47",
X"64ea2e08" when X"48", X"7ce56ec5" when X"49", X"54f4ae3b" when X"4a", X"4cfbeef6" when X"4b",
X"04d6876e" when X"4c", X"1cd9c7a3" when X"4d", X"34c8075d" when X"4e", X"2cc74790" when X"4f",

X"8d628af5" when X"50", X"956dca38" when X"51", X"bd7c0ac6" when X"52", X"a5734a0b" when X"53",
X"ed5e2393" when X"54", X"f551635e" when X"55", X"dd40a3a0" when X"56", X"c54fe36d" when X"57",
X"4d1a7139" when X"58", X"551531f4" when X"59", X"7d04f10a" when X"5a", X"650bb1c7" when X"5b",
X"2d26d85f" when X"5c", X"35299892" when X"5d", X"1d38586c" when X"5e", X"053718a1" when X"5f",

X"f6db6ba6" when X"60", X"eed42b6b" when X"61", X"c6c5eb95" when X"62", X"decaab58" when X"63",
X"96e7c2c0" when X"64", X"8ee8820d" when X"65", X"a6f942f3" when X"66", X"bef6023e" when X"67",
X"36a3906a" when X"68", X"2eacd0a7" when X"69", X"06bd1059" when X"6a", X"1eb25094" when X"6b",
X"569f390c" when X"6c", X"4e9079c1" when X"6d", X"6681b93f" when X"6e", X"7e8ef9f2" when X"6f",

X"df2b3497" when X"70", X"c724745a" when X"71", X"ef35b4a4" when X"72", X"f73af469" when X"73",
X"bf179df1" when X"74", X"a718dd3c" when X"75", X"8f091dc2" when X"76", X"97065d0f" when X"77",
X"1f53cf5b" when X"78", X"075c8f96" when X"79", X"2f4d4f68" when X"7a", X"37420fa5" when X"7b",
X"7f6f663d" when X"7c", X"676026f0" when X"7d", X"4f71e60e" when X"7e", X"577ea6c3" when X"7f",

X"e18d0321" when X"80", X"f98243ec" when X"81", X"d1938312" when X"82", X"c99cc3df" when X"83",
X"81b1aa47" when X"84", X"99beea8a" when X"85", X"b1af2a74" when X"86", X"a9a06ab9" when X"87",
X"21f5f8ed" when X"88", X"39fab820" when X"89", X"11eb78de" when X"8a", X"09e43813" when X"8b",
X"41c9518b" when X"8c", X"59c61146" when X"8d", X"71d7d1b8" when X"8e", X"69d89175" when X"8f",

X"c87d5c10" when X"90", X"d0721cdd" when X"91", X"f863dc23" when X"92", X"e06c9cee" when X"93",
X"a841f576" when X"94", X"b04eb5bb" when X"95", X"985f7545" when X"96", X"80503588" when X"97",
X"0805a7dc" when X"98", X"100ae711" when X"99", X"381b27ef" when X"9a", X"20146722" when X"9b",
X"68390eba" when X"9c", X"70364e77" when X"9d", X"58278e89" when X"9e", X"4028ce44" when X"9f",

X"b3c4bd43" when X"a0", X"abcbfd8e" when X"a1", X"83da3d70" when X"a2", X"9bd57dbd" when X"a3",
X"d3f81425" when X"a4", X"cbf754e8" when X"a5", X"e3e69416" when X"a6", X"fbe9d4db" when X"a7",
X"73bc468f" when X"a8", X"6bb30642" when X"a9", X"43a2c6bc" when X"aa", X"5bad8671" when X"ab",
X"1380efe9" when X"ac", X"0b8faf24" when X"ad", X"239e6fda" when X"ae", X"3b912f17" when X"af",

X"9a34e272" when X"b0", X"823ba2bf" when X"b1", X"aa2a6241" when X"b2", X"b225228c" when X"b3",
X"fa084b14" when X"b4", X"e2070bd9" when X"b5", X"ca16cb27" when X"b6", X"d2198bea" when X"b7",
X"5a4c19be" when X"b8", X"42435973" when X"b9", X"6a52998d" when X"ba", X"725dd940" when X"bb",
X"3a70b0d8" when X"bc", X"227ff015" when X"bd", X"0a6e30eb" when X"be", X"12617026" when X"bf",

X"451fd6e5" when X"c0", X"5d109628" when X"c1", X"750156d6" when X"c2", X"6d0e161b" when X"c3",
X"25237f83" when X"c4", X"3d2c3f4e" when X"c5", X"153dffb0" when X"c6", X"0d32bf7d" when X"c7",
X"85672d29" when X"c8", X"9d686de4" when X"c9", X"b579ad1a" when X"ca", X"ad76edd7" when X"cb",
X"e55b844f" when X"cc", X"fd54c482" when X"cd", X"d545047c" when X"ce", X"cd4a44b1" when X"cf",

X"6cef89d4" when X"d0", X"74e0c919" when X"d1", X"5cf109e7" when X"d2", X"44fe492a" when X"d3",
X"0cd320b2" when X"d4", X"14dc607f" when X"d5", X"3ccda081" when X"d6", X"24c2e04c" when X"d7",
X"ac977218" when X"d8", X"b49832d5" when X"d9", X"9c89f22b" when X"da", X"8486b2e6" when X"db",
X"ccabdb7e" when X"dc", X"d4a49bb3" when X"dd", X"fcb55b4d" when X"de", X"e4ba1b80" when X"df",

X"17566887" when X"e0", X"0f59284a" when X"e1", X"2748e8b4" when X"e2", X"3f47a879" when X"e3",
X"776ac1e1" when X"e4", X"6f65812c" when X"e5", X"477441d2" when X"e6", X"5f7b011f" when X"e7",
X"d72e934b" when X"e8", X"cf21d386" when X"e9", X"e7301378" when X"ea", X"ff3f53b5" when X"eb",
X"b7123a2d" when X"ec", X"af1d7ae0" when X"ed", X"870cba1e" when X"ee", X"9f03fad3" when X"ef",

X"3ea637b6" when X"f0", X"26a9777b" when X"f1", X"0eb8b785" when X"f2", X"16b7f748" when X"f3",
X"5e9a9ed0" when X"f4", X"4695de1d" when X"f5", X"6e841ee3" when X"f6", X"768b5e2e" when X"f7",
X"fedecc7a" when X"f8", X"e6d18cb7" when X"f9", X"cec04c49" when X"fa", X"d6cf0c84" when X"fb",
X"9ee2651c" when X"fc", X"86ed25d1" when X"fd", X"aefce52f" when X"fe", X"b6f3a5e2" when X"ff",

X"00000000" when others;
end phy;
