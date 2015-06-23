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
-- BlockSize   == 1024 bits
-- WordSize    ==   64 bits
-- MDigestSize ==  512 bits
-- Security    ==  256 bits
--
-- SHLnx  = (x<<n)
-- SHRnx  = (x>>n)
-- ROTRnx = (x>>n) or (x<<w-n)
-- ROTLnx = (x<<n) or (x>>w-n)
--
-- f0 = ((x and y) xor (not(x) and z))              --   Ch(x,y,z)
-- f1 = ((x and y) xor (x and z)  xor (y and z)     --  Maj(x,y,z)
-- f2 = ROTR 28(x) xor ROTR 34(x) xor ROTR 39(x)    --   Sigma0(x)
-- f3 = ROTR 14(x) xor ROTR 18(x) xor ROTR 41(x)    --   Sigma1(x)
-- f4 = ROTR  1(x) xor ROTR  8(x) xor SHR   7(x)    --   Tetha0(x)
-- f5 = ROTR 19(x) xor ROTR 61(x) xor SHR   6(x)    --   Tetha1(x)
--
-- h0 = 0x6a09e667f3bcc908
-- h1 = 0xbb67ae8584caa73b
-- h2 = 0x3c6ef372fe94f82b
-- h3 = 0xa54ff53a5f1d36f1
-- h4 = 0x510e527fade682d1
-- h5 = 0x9b05688c2b3e6c1f
-- h6 = 0x1f83d9abfb41bd6b
-- h7 = 0x5be0cd19137e2179
--
-- k[0-63] looks like better implemented in ROM file
--         with 64 bit in each contants it would take
--         64 x 64 bit storage which equal to
--            4096 bit ROM
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
-- for t 0 step 1 to 79 do
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
-- 0 64 128 192 256 320 384 448 512 576 640 704 768 832 896 960 1024
--    0   1   2   3   4   5   6   7   8   9   a   b   c   d   e    f

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha512 is
  port(
  m                : in  bit_vector ( 63 downto 0); -- 32 bit data path require 16 clock to load all 512 bits of each block
  init             : in  bit;                       --    initial message
  ld               : in  bit;                       --    load signal
  md               : out bit_vector ( 63 downto 0); --    5 clock after active valid signal is the message hash result
--probe
--a_prb            : out bit_vector ( 63 downto 0);
--b_prb            : out bit_vector ( 63 downto 0);
--c_prb            : out bit_vector ( 63 downto 0);
--d_prb            : out bit_vector ( 63 downto 0);
--e_prb            : out bit_vector ( 63 downto 0);
--f_prb            : out bit_vector ( 63 downto 0);
--g_prb            : out bit_vector ( 63 downto 0);
--h_prb            : out bit_vector ( 63 downto 0);
--k_prb            : out bit_vector ( 63 downto 0);
--w_prb            : out bit_vector ( 63 downto 0);
--ctr2p            : out bit_vector (  3 downto 0);
--ctr3p            : out bit_vector (  7 downto 0);
--probe
  v                : out bit;                       --    hash output valid signal one clock advance
  clk              : in  bit;                       --    master clock signal
  rst              : in  bit                        --    master reset signal
  );
end sha512;

architecture phy of sha512 is

  component c4b
    port (
    cnt            : out bit_vector (  3 downto 0);
    clk            : in  bit;
    rst            : in  bit
    );
  end component;

  component c8b
    port (
    cnt            : out bit_vector (  7 downto 0);
    clk            : in  bit;
    rst            : in  bit
    );
  end component;

  component romk
    port (
    addr           : in  bit_vector (  6 downto 0);
    k              : out bit_vector ( 63 downto 0)
    );
  end component;

  signal   ih      :     bit_vector ( 63 downto 0);
  signal   h0      :     bit_vector ( 63 downto 0);
  signal   h1      :     bit_vector ( 63 downto 0);
  signal   h2      :     bit_vector ( 63 downto 0);
  signal   h3      :     bit_vector ( 63 downto 0);
  signal   h4      :     bit_vector ( 63 downto 0);
  signal   h5      :     bit_vector ( 63 downto 0);
  signal   h6      :     bit_vector ( 63 downto 0);
  signal   h7      :     bit_vector ( 63 downto 0);

  signal   k       :     bit_vector ( 63 downto 0);

  signal   im      :     bit_vector ( 63 downto 0);
  signal   iw      :     bit_vector ( 63 downto 0);
  signal   w       :     bit_vector ( 63 downto 0); -- current working register
  signal   w0      :     bit_vector(1023 downto 0); -- working register 1

  signal   a       :     bit_vector ( 63 downto 0); -- a register
  signal   b       :     bit_vector ( 63 downto 0); -- b register
  signal   c       :     bit_vector ( 63 downto 0); -- c register
  signal   d       :     bit_vector ( 63 downto 0); -- d register
  signal   e       :     bit_vector ( 63 downto 0); -- e register
  signal   f       :     bit_vector ( 63 downto 0); -- f register
  signal   g       :     bit_vector ( 63 downto 0); -- g register
  signal   h       :     bit_vector ( 63 downto 0); -- h register

  signal   f0      :     bit_vector ( 63 downto 0); 
  signal   f1      :     bit_vector ( 63 downto 0); 
  signal   f2      :     bit_vector ( 63 downto 0); 
  signal   f3      :     bit_vector ( 63 downto 0); 
  signal   f4      :     bit_vector ( 63 downto 0); 
  signal   f5      :     bit_vector ( 63 downto 0); 

  signal   ctr2    :     bit_vector (  3 downto 0); --  4  bit counter (zero to  16)
  signal   ctr2_rst:     bit;
  signal   ctr3    :     bit_vector (  7 downto 0); --  8  bit counter (zero to 255)
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
  ct3              : c8b
  port map (
  cnt              => ctr3,
  clk              => clk,
  rst              => ctr3_rst
  );
  rom0             : romk
  port map (
  addr             => ctr3(  6 downto 0),
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
--f2               == ROTR 28(x)  xor ROTR 34(x) xor ROTR 39(x)           -- f2(a)
  f2               <= (a ( 27 downto   0) & a ( 63 downto  28)) xor
		      (a ( 33 downto   0) & a ( 63 downto  34)) xor
		      (a ( 38 downto   0) & a ( 63 downto  39));
--f3               == ROTR 14(x)  xor ROTR 18(x) xor ROTR 41(x)           -- f3(e)
  f3               <= (e ( 13 downto   0) & e ( 63 downto  14)) xor
		      (e ( 17 downto   0) & e ( 63 downto  18)) xor
		      (e ( 40 downto   0) & e ( 63 downto  41));
--f4               == ROTR  1(x)  xor ROTR  8(x) xor SHR   7(x)           -- w0(959 downto 896)
  f4               <= (w0(           896) & w0(959 downto 897)) xor
                      (w0(903 downto 896) & w0(959 downto 904)) xor
                      (B"0000000"         & w0(959 downto 903));
--f5               == ROTR 19(x)  xor ROTR 61(x) xor SHR   6(x)           -- w0(127 downto  64)
  f5               <= (w0( 82 downto  64) & w0(127 downto  83)) xor
                      (w0(124 downto  64) & w0(127 downto 125)) xor
		      (B"000000"          & w0(127 downto  70));

  with ctr2(  2 downto 0) select
  ih               <= h0                                      when B"000",
                      h1                                      when B"001",
                      h2                                      when B"010",
                      h3                                      when B"011",
                      h4                                      when B"100",
                      h5                                      when B"101",
                      h6                                      when B"110",
                      h7                                      when B"111";

--W                == f5(W(  1)) + W(  6)             + f4(W(  14)) + W(  15);             16 <= t <=  79
--iw               <= f5         + w0(447 downto 384) + f4          + w0(1023 downto 960); -- FIXME this adder is very costly and NOT A PORTABLE CODE
  iw               <= to_bitvector(std_logic_vector( unsigned(to_stdlogicvector(f5)) + unsigned(to_stdlogicvector(w0(447 downto 384))) + unsigned(to_stdlogicvector(f4)) + unsigned(to_stdlogicvector(w0(1023 downto 960))) ));

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
--    if    (rst = '1') then -- not to reset scratch register 
--      w          <= (others => '0')         ;
--      w0         <= (others => '0')         ;
      if (nld = '1') then                                                 -- 0 <= t <= 15 first 512 bit block
        w          <=                      im ;
  w0(1023 downto 0)<= (w0(959 downto  0) & im);
      else
        w          <=  iw                     ; 
  w0(1023 downto 0)<= (w0(959 downto  0) & iw); 
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
      elsif (ctr3 = X"4f") then
        vld        <=  '1';
      else
        vld        <=  '0';
      end if;
    end if;
  end process;

  ild_rst          <= (ild xor ld) and ld;
--ctr2_rst         <=  ild_rst     or rst or vld or (ctr2 = X"7");        -- set to count to  7 (  8 clock)
  ctr2_rst         <=  ild_rst     or rst or vld or not(ctr2(3) or not(ctr2(2)) or not(ctr2(1)) or not(ctr2(0)));
--ctr3_rst         <=  ild_rst     or rst or (ctr3 = X"4f");              -- set to count to 79 ( 80 clock) 0100 1111
  ctr3_rst         <=  ild_rst     or rst or not(ctr3(7) or not(ctr3(6)) or ctr3(5) or ctr3(4) or not(ctr3(3)) or not(ctr3(2)) or not(ctr3(1)) or not(ctr3(0)));

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (init = '1')  or (rst = '1') then
        h0         <= X"6a09e667f3bcc908";
        h1         <= X"bb67ae8584caa73b";
        h2         <= X"3c6ef372fe94f82b";
        h3         <= X"a54ff53a5f1d36f1";
        h4         <= X"510e527fade682d1";
        h5         <= X"9b05688c2b3e6c1f";
        h6         <= X"1f83d9abfb41bd6b";
        h7         <= X"5be0cd19137e2179";
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
