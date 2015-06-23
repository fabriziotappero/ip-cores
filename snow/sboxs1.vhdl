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

entity sboxs1 is
  port (
  w                : in  bit_vector ( 31 downto 0);
  r                : out bit_vector ( 31 downto 0)
  );
end sboxs1;

architecture phy of sboxs1 is
  signal w0        :     bit_vector (  7 downto 0);
  signal w1        :     bit_vector (  7 downto 0);
  signal w2        :     bit_vector (  7 downto 0);
  signal w3        :     bit_vector (  7 downto 0);
  signal r0        :     bit_vector (  7 downto 0);
  signal r1        :     bit_vector (  7 downto 0);
  signal r2        :     bit_vector (  7 downto 0);
  signal r3        :     bit_vector (  7 downto 0);
  signal sr0i      :     bit_vector (  7 downto 0);
  signal sr1i      :     bit_vector (  7 downto 0);
  signal sr2i      :     bit_vector (  7 downto 0);
  signal sr3i      :     bit_vector (  7 downto 0);
  signal sr0o      :     bit_vector (  7 downto 0);
  signal sr1o      :     bit_vector (  7 downto 0);
  signal sr2o      :     bit_vector (  7 downto 0);
  signal sr3o      :     bit_vector (  7 downto 0);
  signal mlx0vi    :     bit_vector (  7 downto 0);
  signal mlx0ci    :     bit_vector (  7 downto 0);
  signal mlx0wo    :     bit_vector (  7 downto 0);
  signal mlx1vi    :     bit_vector (  7 downto 0);
  signal mlx1ci    :     bit_vector (  7 downto 0);
  signal mlx1wo    :     bit_vector (  7 downto 0);
  signal mlx2vi    :     bit_vector (  7 downto 0);
  signal mlx2ci    :     bit_vector (  7 downto 0);
  signal mlx2wo    :     bit_vector (  7 downto 0);
  signal mlx3vi    :     bit_vector (  7 downto 0);
  signal mlx3ci    :     bit_vector (  7 downto 0);
  signal mlx3wo    :     bit_vector (  7 downto 0);
  component sboxr
  port (
  di               : in  bit_vector (  7 downto 0);
  do               : out bit_vector (  7 downto 0)
  );
  end component;
  component mulx
  port (
  V                : in  bit_vector (  7 downto 0);
  c                : in  bit_vector (  7 downto 0);
  w                : out bit_Vector (  7 downto 0)
  );
  end component;
begin
  sr0              : sboxr
  port map (
  di               => sr0i,
  do               => sr0o
  );
  sr1              : sboxr
  port map (
  di               => sr1i,
  do               => sr1o
  );
  sr2              : sboxr
  port map (
  di               => sr2i,
  do               => sr2o
  );
  sr3              : sboxr
  port map (
  di               => sr3i,
  do               => sr3o
  );
  mlx0             : mulx
  port map (
  V                => mlx0vi,
  c                => mlx0ci,
  w                => mlx0wo
  );
  mlx1             : mulx
  port map (
  V                => mlx1vi,
  c                => mlx1ci,
  w                => mlx1wo
  );
  mlx2             : mulx
  port map (
  V                => mlx2vi,
  c                => mlx2ci,
  w                => mlx2wo
  );
  mlx3             : mulx
  port map (
  V                => mlx3vi,
  c                => mlx3ci,
  w                => mlx3wo
  );
--persistent connection
  w0               <= w ( 31 downto 24);
  w1               <= w ( 23 downto 16);
  w2               <= w ( 15 downto  8);
  w3               <= w (  7 downto  0);
  sr0i             <= w0;
  sr1i             <= w1;
  sr2i             <= w2;
  sr3i             <= w3;
  mlx0vi           <= sr0o; --SR(w0)
  mlx1vi           <= sr1o; --SR(w1)
  mlx2vi           <= sr2o; --SR(w2)
  mlx3vi           <= sr3o; --SR(w3)
  mlx0ci           <= X"1b";
  mlx1ci           <= X"1b";
  mlx2ci           <= X"1b";
  mlx3ci           <= X"1b";
  r0               <= mlx0wo xor sr1o xor sr2o xor mlx3wo xor sr3o;
  r1               <= mlx0wo xor sr0o xor mlx1wo xor sr2o xor sr3o;
  r2               <= sr0o xor mlx1wo xor sr1o xor mlx2wo xor sr3o;
  r3               <= sr0o xor sr1o xor mlx2wo xor sr2o xor mlx3wo;
  r ( 31 downto 24)<= r0;
  r ( 23 downto 16)<= r1;
  r ( 15 downto  8)<= r2;
  r (  7 downto  0)<= r3;
--persistent connection
end phy;
