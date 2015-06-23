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
--
-- InvCipher (byte in[4*Nb], byte out[4*Nb], word w[Nb*(Nr+1)])
-- begin
--   byte state[4,Nb]
--   state = in
--
--   AddRoundKey(state, w[Nr*Nb, (Nr+1)*Nb-1])
--
--   for round = Nr-1 step -1 downto 1
--     InvShiftRows(state)
--     InvSubBytes(state)
--     AddRoundKey(state, w[round*Nb, (round+1)*Nb-1])
--     InvMixColumns(state)
--   end for
--
--   InvShiftRows(state)
--   InvSubBytes(state)
--   AddRoundKey(state, w[0, Nb-1])
--
--   out = state
-- end
--
--
-- EqInvCipher (byte in[4*Nb], byte out[4*Nb], word dw[Nb*(Nr+1)])
-- begin
--   byte state[4,Nb]
--   state = in
--
--   AddRoundKey(state, dw[Nr*Nb, (Nr+1)*Nb-1])
--
--   for round = Nr-1 step -1 downto 1
--     InvSubBytes(state)
--     InvShiftRows(state)
--     InvMixColumns(state)
--     AddRoundKey(state, dw[round*Nb, (round+1)*Nb-1])
--   end for
--
--   InvSubBytes(state)
--   InvShiftRows(state)
--   AddRoundKey(state, dw[0, Nb-1])
--
--   out = state
-- end
--
-- for i = 0 step 1 to (Nr+1)*Nb-1
--   dw[i] = w[i]
-- end for
--
-- for round = 1 step 1 to Nr-1
--   InvMixColumns(dw[round*Nb, (round+1)*Nb-1]);
-- end for

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity invcipher is
  port (
  ct               : in  bit_vector ( 31 downto 0); -- cipher text
  key              : in  bit_vector ( 31 downto 0); -- source key
  Nk               : in  bit_vector (  3 downto 0); --
  ldct             : in  bit;                       -- load cipher text
  pt               : out bit_vector ( 31 downto 0); -- plain text
  v                : out bit;                       -- valid plain text output
  clk              : in  bit;                       -- master clock
  rst              : in  bit                        -- master reset
  );
end invcipher;

architecture phy of invcipher is

  component invsbox
    port (
    di             : in  bit_vector (  7 downto 0);
    do             : out bit_vector (  7 downto 0)
    );
  end component;

  component c2b
    port (
    cnt            : out bit_vector (  1 downto 0);
    clk            : in  bit;
    rst            : in  bit
    );
  end component;

  component xtime_2
    port (
    x2i            : in  bit_vector (  7 downto 0);
    x2o            : out bit_vector (  7 downto 0)
    );
  end component;

  component xtime_4
    port (
    x4i            : in  bit_vector (  7 downto 0);
    x4o            : out bit_vector (  7 downto 0)
    );
  end component;

  signal ireg1     :     bit_vector (127 downto 0); -- 128 bit internal register 1
  signal ireg2     :     bit_vector (127 downto 0); -- 128 bit internal register 2
  signal ct2b      :     bit_vector (  1 downto 0); --   2 bit counter
  signal wsb1      :     bit_vector ( 31 downto 0); -- SubBytes
  signal wsb2      :     bit_vector ( 31 downto 0); -- SubBytes
  signal wsr       :     bit_vector ( 31 downto 0); -- ShiftRows
  signal wmc       :     bit_vector ( 31 downto 0); -- MixColumns
  signal iwmc      :     bit_vector ( 31 downto 0); -- InvMixColumns
  signal ssm       :     bit_vector ( 31 downto 0); -- SubBytes, ShiftRows, MixColumns
  signal ikey      :     bit_vector ( 31 downto 0); -- internal round key
  signal rnd       :     bit_vector (  3 downto 0); -- current round number
  signal rnd_cr    :     bit_vector (  3 downto 0); -- currend round number carry
  signal ict       :     bit_vector ( 31 downto 0); -- internal cipher text
  signal s1i       :     bit_vector (  7 downto 0); --  Input SubBytes 1
  signal s2i       :     bit_vector (  7 downto 0); --  Input SubBytes 2
  signal s3i       :     bit_vector (  7 downto 0); --  Input SubBytes 3
  signal s4i       :     bit_vector (  7 downto 0); --  Input SubBytes 4
  signal s1o       :     bit_vector (  7 downto 0); -- Output SubBytes 1
  signal s2o       :     bit_vector (  7 downto 0); -- Output SubBytes 2
  signal s3o       :     bit_vector (  7 downto 0); -- Output SubBytes 3
  signal s4o       :     bit_vector (  7 downto 0); -- Output SubBytes 4
  signal x2ai      :     bit_vector (  7 downto 0); --  Input xtime 2  a
  signal x2bi      :     bit_vector (  7 downto 0); --  Input xtime 2  b
  signal x2ci      :     bit_vector (  7 downto 0); --  Input xtime 2  c
  signal x2di      :     bit_vector (  7 downto 0); --  Input xtime 2  d
  signal x2ao      :     bit_vector (  7 downto 0); -- Output xtime 2  a
  signal x2bo      :     bit_vector (  7 downto 0); -- Output xtime 2  b
  signal x2co      :     bit_vector (  7 downto 0); -- Output xtime 2  c
  signal x2do      :     bit_vector (  7 downto 0); -- Output xtime 2  d
  signal x4ai      :     bit_vector (  7 downto 0); --  Input xtime 4  a
  signal x4bi      :     bit_vector (  7 downto 0); --  Input xtime 4  b
  signal x4ci      :     bit_vector (  7 downto 0); --  Input xtime 4  c
  signal x4di      :     bit_vector (  7 downto 0); --  Input xtime 4  d
  signal x4ao      :     bit_vector (  7 downto 0); -- Output xtime 4  a
  signal x4bo      :     bit_vector (  7 downto 0); -- Output xtime 4  b
  signal x4co      :     bit_vector (  7 downto 0); -- Output xtime 4  c
  signal x4do      :     bit_vector (  7 downto 0); -- Output xtime 4  d
  signal ct2b_rst  :     bit;                       -- reset for internal block operation
  signal swp       :     bit;                       -- swap internal register
  signal swp1      :     bit;                       -- swap internal register
  signal vld       :     bit;                       -- final round
  signal vld1      :     bit;                       -- final round
  signal ildct     :     bit;                       -- internal load cipher text
  signal ildct_rst :     bit;                       -- internal load cipher text reset

begin

  sb1 : invsbox
  port map (
    di => s1i,
    do => s1o
    );
  sb2 : invsbox
  port map (
    di => s2i,
    do => s2o
    );
  sb3 : invsbox
  port map (
    di => s3i,
    do => s3o
    );
  sb4 : invsbox
  port map (
    di => s4i,
    do => s4o
    );
  ctr1 : c2b
  port map (
    cnt => ct2b,
    clk => clk,
    rst => ct2b_rst
    );
  x2a : xtime_2
  port map (
    x2i => x2ai,
    x2o => x2ao
    );
  x2b : xtime_2
  port map (
    x2i => x2bi,
    x2o => x2bo
    );
  x2c : xtime_2
  port map (
    x2i => x2ci,
    x2o => x2co
    );
  x2d : xtime_2
  port map (
    x2i => x2di,
    x2o => x2do
    );
  x4a : xtime_4
  port map (
    x4i => x4ai,
    x4o => x4ao
    );
  x4b : xtime_4
  port map (
    x4i => x4bi,
    x4o => x4bo
    );
  x4c : xtime_4
  port map (
    x4i => x4ci,
    x4o => x4co
    );
  x4d : xtime_4
  port map (
    x4i => x4di,
    x4o => x4do
    );

--   7  39  71 103 |   7  39  71 103 |   7  39  71 103
--  15  47  79 111 |  47  79 111  15 | 111  15  47  79
--  23  55  87 119 |  87 119  23  55 |  87 119  23  55
--  31  63  95 127 | 127  31  63  95 |  63  95 127  31
 
  with ct2b(  1 downto 0) select
  wsb1 <= ireg1( 63 downto  56) & ireg1( 87 downto  80) & ireg1(111 downto 104) & ireg1(  7 downto   0) when B"10", -- 1st column
          ireg1( 95 downto  88) & ireg1(119 downto 112) & ireg1( 15 downto   8) & ireg1( 39 downto  32) when B"01", -- 4th column
          ireg1(127 downto 120) & ireg1( 23 downto  16) & ireg1( 47 downto  40) & ireg1( 71 downto  64) when B"00", -- 3rd column
          ireg1( 31 downto  24) & ireg1( 55 downto  48) & ireg1( 79 downto  72) & ireg1(103 downto  96) when B"11"; -- 2nd column
  with ct2b(  1 downto 0) select
  wsb2 <= ireg2( 63 downto  56) & ireg2( 87 downto  80) & ireg2(111 downto 104) & ireg2(  7 downto   0) when B"10", -- 1st column
          ireg2( 95 downto  88) & ireg2(119 downto 112) & ireg2( 15 downto   8) & ireg2( 39 downto  32) when B"01", -- 4th column
          ireg2(127 downto 120) & ireg2( 23 downto  16) & ireg2( 47 downto  40) & ireg2( 71 downto  64) when B"00", -- 3rd column
          ireg2( 31 downto  24) & ireg2( 55 downto  48) & ireg2( 79 downto  72) & ireg2(103 downto  96) when B"11"; -- 2nd column
  
--SubBytes
  s1i(  7 downto 0) <= wsb1( 31 downto 24) when swp = '1' else wsb2( 31 downto  24);
  s2i(  7 downto 0) <= wsb1( 23 downto 16) when swp = '1' else wsb2( 23 downto  16);
  s3i(  7 downto 0) <= wsb1( 15 downto  8) when swp = '1' else wsb2( 15 downto   8);
  s4i(  7 downto 0) <= wsb1(  7 downto  0) when swp = '1' else wsb2(  7 downto   0);

--ShiftRows
  wsr <= s1o & s2o & s3o & s4o;

--MixColumns -- addroundkey first
  x2ai <= wsr( 31 downto  24) xor ikey( 31 downto  24);
  x2bi <= wsr( 23 downto  16) xor ikey( 23 downto  16);
  x2ci <= wsr( 15 downto   8) xor ikey( 15 downto   8);
  x2di <= wsr(  7 downto   0) xor ikey(  7 downto   0);

  wmc( 31 downto  24) <= x2ao xor x2bo xor x2bi xor x2ci xor x2di;
  wmc( 23 downto  16) <= x2ai xor x2bo xor x2co xor x2ci xor x2di;
  wmc( 15 downto   8) <= x2ai xor x2bi xor x2co xor x2do xor x2di;
  wmc(  7 downto   0) <= x2ao xor x2ai xor x2bi xor x2ci xor x2do;

--InvMixColumns
  x4ai <= wmc( 31 downto  24);
  x4bi <= wmc( 23 downto  16);
  x4ci <= wmc( 15 downto   8);
  x4di <= wmc(  7 downto   0);

  iwmc( 31 downto  24) <= x4ao xor x4ai xor x4co ;
  iwmc( 23 downto  16) <= x4bo xor x4bi xor x4do ;
  iwmc( 15 downto   8) <= x4co xor x4ci xor x4ao ;
  iwmc(  7 downto   0) <= x4do xor x4di xor x4bo ;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      ildct <= ldct;
    end if;
  end process;
  
  ildct_rst <= ((ildct xor ldct) and ldct);
  ct2b_rst  <= rst or ildct_rst;

  rnd_cr(0)          <= '0'; -- LSB always zero
  rnd_cr(3 downto 1) <= ( ((rnd(2 downto 0) and B"001") or (rnd(2 downto 0) and rnd_cr(2 downto 0))) or (B"001" and rnd_cr(2 downto 0)) );

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if ((ildct_rst or rst) = '1') then
        swp <= '0';
        rnd <= B"0000";
      elsif (not(not(ct2b(1)) or not(ct2b(0))) = '1') then
        swp <= not(swp);
        rnd <= ((rnd xor B"0001") xor rnd_cr);
      end if;
    end if;
  end process;

  vld  <= (not(Nk(3) or not(Nk(2)) or Nk(1) or Nk(0))      and      not(not(rnd(3)) or rnd(2) or not(rnd(1)) or rnd(0))) or    -- Nk 0100 (10 round)
	  (not(Nk(3) or not(Nk(2)) or not(Nk(1)) or Nk(0)) and      not(not(rnd(3)) or not(rnd(2)) or rnd(1) or rnd(0))) or    -- Nk 0110 (12 round)
	  (not(not(Nk(3)) or Nk(2) or Nk(1) or Nk(0))      and not(not(rnd(3)) or not(rnd(2)) or not(rnd(1)) or rnd(0)));      -- Nk 1000 (14 round)

  ikey <= key;
  ssm  <= iwmc when vld = '0' else wsr xor ikey;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ireg1(127 downto 0) <= (others => '0');
        ireg2(127 downto 0) <= (others => '0');
      elsif (ildct = '1') then
        ireg1(127 downto 0) <= ireg1( 95 downto 0) & (ict xor ikey); -- initial round
      elsif (  swp = '0') then
        ireg1(127 downto 0) <= ireg1( 95 downto 0) & (ssm);
      else
        ireg2(127 downto 0) <= ireg2( 95 downto 0) & (ssm);
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      swp1 <= swp;
      vld1 <= vld;
      ict  <= ct;
    end if;
  end process;

  pt  <= ireg1( 31 downto 0) when swp1 = '0' else ireg2( 31 downto 0);
  v   <= vld1;

end phy;
