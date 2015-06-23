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
-- MaxMessage  <= 2^64 bits
-- BlockSize   ==  512 bits
-- WordSize    ==   32 bits
-- MDigestSize ==  256 bits
-- Security    ==  128 bits
--
-- SHLnx  = (x<<n)
-- SHRnx  = (x>>n)
-- ROTRnx = (x>>n) or (x<<w-n)
-- ROTLnx = (x<<n) or (x>>w-n)
--
-- f0 = ((x and y) xor (not(x) and z))              --   Ch(x,y,z)
-- f1 = ((x and y) xor (x and z)  xor (y and z)     --  Maj(x,y,z)
-- f2 = ROTR  2(x) xor ROTR 13(x) xor ROTR 22(x)    --   Sigma0(x)
-- f3 = ROTR  6(x) xor ROTR 11(x) xor ROTR 25(x)    --   Sigma1(x)
-- f4 = ROTR  7(x) xor ROTR 18(x) xor SHR   3(x)    --   Tetha0(x)
-- f5 = ROTR 17(x) xor ROTR 19(x) xor SHR  10(x)    --   Tetha1(x)
--
-- h0 = 0x6a09e667
-- h1 = 0xbb67ae85
-- h2 = 0x3c6ef372
-- h3 = 0xa54ff53a
-- h4 = 0x510e527f
-- h5 = 0x9b05688c
-- h6 = 0x1f83d9ab
-- h7 = 0x5be0cd19
--
-- k[0-63] looks like better implemented in ROM file
--         with 32 bit in each contants it would take
--         64 x 32 bit storage which equal to
--            2048 bit ROM
--
-- Step 1
-- W(t) = M(t)                                                  0 <= t <=  15 -- we need 16x32 (512) bit registers
-- W(t) = f5(W(t-2)) + W(t-7) + f4(W(t-15)) + W(t-16);         16 <= t <=  79
-- W    = f5(W(  1)) + W(  6) + f4(W(  14)) + W(  15);         16 <= t <=  79
--
-- Step 2
-- a = h0; b = h1; c = h2; d = h3; e = h4; f = h5; g = h6; h = h7;
--
-- Step 3
-- for t 0 step 1 to 63 do
-- T1= h + f3(e) + f0(e, f, g) + k(t) + W(t)
-- T2=     f2(a) + f1(a, b, c)
-- h = g
-- g = f
-- f = e
-- e = d + T1
-- d = c
-- c = b
-- b = a
-- a = T1 + T2
--
-- Step 4
-- H0 = a + h0;
-- H1 = b + h1;
-- H2 = c + h2;
-- H3 = d + h3;
-- H4 = e + H4;
-- H5 = f + H5;
-- H6 = g + H6;
-- H7 = h + H7;
--
--  31 63 95 127 159 191 223 255 287 319 351 383 415 447 479 511
-- 0 32 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512
--    0  1  2   3   4   5   6   7   8   9   a   b   c   d   e   f

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha256 is
  port(
  m                : in  bit_vector ( 31 downto 0); -- 32 bit data path require 16 clock to load all 512 bits of each block
  init             : in  bit;                       --    initial message
  ld               : in  bit;                       --    load signal
  md               : out bit_vector ( 31 downto 0); --    5 clock after active valid signal is the message hash result
--probe
--a_prb            : out bit_vector ( 31 downto 0);
--b_prb            : out bit_vector ( 31 downto 0);
--c_prb            : out bit_vector ( 31 downto 0);
--d_prb            : out bit_vector ( 31 downto 0);
--e_prb            : out bit_vector ( 31 downto 0);
--f_prb            : out bit_vector ( 31 downto 0);
--g_prb            : out bit_vector ( 31 downto 0);
--h_prb            : out bit_vector ( 31 downto 0);
--k_prb            : out bit_vector ( 31 downto 0);
--w_prb            : out bit_vector ( 31 downto 0);
--ctr2p            : out bit_vector (  3 downto 0);
--ctr3p            : out bit_vector (  5 downto 0);
--sc_pr            : out bit_vector (  1 downto 0);
--probe
  v                : out bit;                       --    hash output valid signal one clock advance
  clk              : in  bit;                       --    master clock signal
  rst              : in  bit                        --    master reset signal
  );
end sha256;

architecture phy of sha256 is

  component c4b
    port (
    cnt            : out bit_vector (  3 downto 0);
    clk            : in  bit;
    rst            : in  bit
    );
  end component;

  component c6b
    port (
    cnt            : out bit_vector (  5 downto 0);
    clk            : in  bit;
    rst            : in  bit
    );
  end component;

  component romk
    port (
    addr           : in  bit_vector (  5 downto 0);
    k              : out bit_vector ( 31 downto 0)
    );
  end component;

  signal   ih      :     bit_vector ( 31 downto 0);
  signal   h0      :     bit_vector ( 31 downto 0);
  signal   h1      :     bit_vector ( 31 downto 0);
  signal   h2      :     bit_vector ( 31 downto 0);
  signal   h3      :     bit_vector ( 31 downto 0);
  signal   h4      :     bit_vector ( 31 downto 0);
  signal   h5      :     bit_vector ( 31 downto 0);
  signal   h6      :     bit_vector ( 31 downto 0);
  signal   h7      :     bit_vector ( 31 downto 0);

  signal   k       :     bit_vector ( 31 downto 0);

  signal   im      :     bit_vector ( 31 downto 0);
  signal   iw      :     bit_vector ( 31 downto 0);
  signal   w       :     bit_vector ( 31 downto 0); -- current working register
  signal   w0      :     bit_vector (511 downto 0); -- working register 1

  signal   a       :     bit_vector ( 31 downto 0); -- a register
  signal   b       :     bit_vector ( 31 downto 0); -- b register
  signal   c       :     bit_vector ( 31 downto 0); -- c register
  signal   d       :     bit_vector ( 31 downto 0); -- d register
  signal   e       :     bit_vector ( 31 downto 0); -- e register
  signal   f       :     bit_vector ( 31 downto 0); -- f register
  signal   g       :     bit_vector ( 31 downto 0); -- g register
  signal   h       :     bit_vector ( 31 downto 0); -- h register

  signal   f0      :     bit_vector ( 31 downto 0); 
  signal   f1      :     bit_vector ( 31 downto 0); 
  signal   f2      :     bit_vector ( 31 downto 0); 
  signal   f3      :     bit_vector ( 31 downto 0); 
  signal   f4      :     bit_vector ( 31 downto 0); 
  signal   f5      :     bit_vector ( 31 downto 0); 

  signal   ctr2    :     bit_vector (  3 downto 0); --  4  bit counter (zero to  16)
  signal   ctr2_rst:     bit;
  signal   ctr3    :     bit_vector (  5 downto 0); --  6  bit counter (zero to  64)
  signal   ctr3_rst:     bit;

  signal   vld     :     bit;
  signal   nld     :     bit;
  signal   ild     :     bit;
  signal   ild_rst :     bit;

begin

  ct2              : c4b
  port map (
  cnt              => ctr2,
  clk              => clk,
  rst              => ctr2_rst
  );
  ct3              : c6b
  port map (
  cnt              => ctr3,
  clk              => clk,
  rst              => ctr3_rst
  );
  rom0             : romk
  port map (
  addr             => ctr3,
  k                => k
  );

--probe signal
--a_prb            <= a;
--b_prb            <= b;
--c_prb            <= c;
--d_prb            <= d;
--e_prb            <= e;
--f_prb            <= e;
--g_prb            <= e;
--h_prb            <= e;
--k_prb            <= k;
--w_prb            <= w;
--ctr2p            <= ctr2;
--ctr3p            <= ctr3;
--probe signal

--persistent connection

--f0               == ((x and y) xor (not(x) and z))                      -- f0(e, f, g)
  f0               <= ((e and f) xor (not(e) and g));
--f1               == ((x and y) xor (x and z) xor (y and z)              -- f1(a, b, c)
  f1               <= ((a and b) xor (a and c) xor (b and c));
--f2               == ROTR  2(x)  xor ROTR 13(x) xor ROTR 22(x)           -- f2(a)
  f2               <= (a (  1 downto   0) & a ( 31 downto   2)) xor
		      (a ( 12 downto   0) & a ( 31 downto  13)) xor
		      (a ( 21 downto   0) & a ( 31 downto  22));
--f3               == ROTR  6(x)  xor ROTR 11(x) xor ROTR 25(x)           -- f3(e)
  f3               <= (e (  5 downto   0) & e ( 31 downto   6)) xor
		      (e ( 10 downto   0) & e ( 31 downto  11)) xor
		      (e ( 24 downto   0) & e ( 31 downto  25));
--f4               == ROTR  7(x)  xor ROTR 18(x) xor SHR   3(x)           -- w0(479 downto 448)
  f4               <= (w0(454 downto 448) & w0(479 downto 455)) xor
                      (w0(465 downto 448) & w0(479 downto 466)) xor
                      (B"000"             & w0(479 downto 451));
--f5               == ROTR 17(x)  xor ROTR 19(x) xor SHR  10(x)           -- w0( 63 downto  32)
  f5               <= (w0( 48 downto  32) & w0( 63 downto  49)) xor
                      (w0( 50 downto  32) & w0( 63 downto  51)) xor
		      (B"0000000000"      & w0( 63 downto  42));

  with ctr2( 2 downto 0) select -- omit bit 4
  ih               <= h0                                      when B"000",
                      h1                                      when B"001",
                      h2                                      when B"010",
                      h3                                      when B"011",
                      h4                                      when B"100",
                      h5                                      when B"101",
                      h6                                      when B"110",
                      h7                                      when B"111";

--W                == f5(W(  1)) + W(  6)             + f4(W(  14)) + W(  15);             16 <= t <=  79
--iw               <= f5         + w0(223 downto 192) + f4          + w0(511 downto 480); -- FIXME this adder is very costly and NOT A PORTABLE CODE
  iw               <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(f5)) + unsigned(to_stdlogicvector(w0(223 downto 192))) + unsigned(to_stdlogicvector(f4)) + unsigned(to_stdlogicvector(w0(511 downto 480))) ));

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if    (rst = '1') then
        w          <= (others => '0');
        w0         <= (others => '0');
      elsif (nld = '1') then                                              -- 0 <= t <= 15 first 512 bit block
        w          <=              im;
  w0(511 downto 0) <= (w0(479 downto  0) & im);
      else
        w          <=  iw( 31 downto   0)                      ; 
  w0(511 downto 0) <= (w0(479 downto   0) & iw( 31 downto   0)); 
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ild        <=  '0';
	nld        <=  '0';
	im         <= (others => '0');
      else
        ild        <=  nld;
	nld        <=   ld;
	im         <=    m;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if ((ild_rst or rst) = '1') then
        vld        <=  '0';
      elsif (ctr3 = B"111111") then
        vld        <=  '1';
      else
        vld        <=  '0';
      end if;
    end if;
  end process;

  ild_rst          <= (ild xor ld) and ld;
--ctr2_rst         <=  ild_rst     or rst or vld or (ctr2 = B"0111");     -- set to count to  7 (  8 clock)
  ctr2_rst         <=  ild_rst     or rst or vld or not(ctr2(3) or not(ctr2(2)) or not(ctr2(1)) or not(ctr2(0)));
  ctr3_rst         <=  ild_rst     or rst;-- (ctr3 = B"010011");          -- set to count to 63 ( 64 clock)

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (init = '1')  or (rst = '1') then
        h0         <= X"6a09e667";
        h1         <= X"bb67ae85";
        h2         <= X"3c6ef372";
        h3         <= X"a54ff53a";
        h4         <= X"510e527f";
        h5         <= X"9b05688c";
        h6         <= X"1f83d9ab";
        h7         <= X"5be0cd19";
      elsif (vld = '1') then -- FIXME this adder is very costly and NOT A PORTABLE CODE
        h0         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(a)) + unsigned(to_stdlogicvector(h0)) ));
        h1         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(b)) + unsigned(to_stdlogicvector(h1)) ));
        h2         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(c)) + unsigned(to_stdlogicvector(h2)) ));
        h3         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(d)) + unsigned(to_stdlogicvector(h3)) ));
        h4         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(e)) + unsigned(to_stdlogicvector(h4)) ));
        h5         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(f)) + unsigned(to_stdlogicvector(h5)) ));
        h6         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(g)) + unsigned(to_stdlogicvector(h6)) ));
        h7         <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(h)) + unsigned(to_stdlogicvector(h7)) ));
--      h0         <=      a + h0;
--      h1         <=      b + h1;
--      h2         <=      c + h2;
--      h3         <=      d + h3;
--      h4         <=      e + h4;
--      h5         <=      f + h5;
--      h6         <=      g + h6;
--      h7         <=      h + h7;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if ((ild_rst or rst) = '1') then
        a          <= h0;
        b          <= h1;
        c          <= h2;
        d          <= h3;
        e          <= h4;
        f          <= h5;
        g          <= h6;
        h          <= h7;
       else -- FIXME this adder is very costly and NOT A PORTABLE CODE
--      T1         == h + f3(e) + f0(e, f, g) + k(t) + W(t)
--      T2         ==     f2(a) + f1(a, b, c)
        h          <=  g;
        g          <=  f;
        f          <=  e;
--	e          <=  d +          T1        ;
--      e          <=  d + h + f3 + f0 + k + w;
        e          <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(d)) + unsigned(to_stdlogicvector(h)) + unsigned(to_stdlogicvector(f3)) + unsigned(to_stdlogicvector(f0)) + unsigned(to_stdlogicvector(k)) + unsigned(to_stdlogicvector(w)) ));
        d          <=  c;
        c          <=  b;
        b          <=  a;
--	a          <=             T1           +    T2  ;
--      a          <=      h + f3 + f0 + k + w + f2 + f1;
        a          <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(h)) + unsigned(to_stdlogicvector(f3)) + unsigned(to_stdlogicvector(f0)) + unsigned(to_stdlogicvector(k)) + unsigned(to_stdlogicvector(w))  + unsigned(to_stdlogicvector(f2)) + unsigned(to_stdlogicvector(f1)) ));
      end if;
    end if;
  end process;

  md               <=  ih;
  v                <=  vld;

end phy;
