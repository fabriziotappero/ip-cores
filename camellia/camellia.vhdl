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

-- 128  64  0 
--    Ln  Rn
--
-- L_{r} = R_{r-1} xor F(L_{r-1}, k_r)
-- R_{r} = L_{r-1}

-- because P-function working in 64 bit field, then the minimum block is 64.
entity camellia is
  port (
  pt               : in  bit_vector ( 63 downto 0);
  key              : in  bit_vector ( 63 downto 0);
  Nk               : in  bit_vector (  3 downto 0);
  ldpt             : in  bit;
  ct               : out bit_vector ( 63 downto 0);
--probe
--r_prb            : out bit_vector ( 63 downto 0);
--l_prb            : out bit_vector ( 63 downto 0);
--s_prb            : out bit_vector ( 63 downto 0);
--z_prb            : out bit_vector ( 63 downto 0);
--fla_prb          : out bit_vector ( 63 downto 0);
--ir_prb           : out bit_vector ( 63 downto 0);
--il_prb           : out bit_vector ( 63 downto 0);
--rc_prb           : out bit_vector (  2 downto 0);
--probe
  v                : out bit;
  clk              : in  bit;
  rst              : in  bit
  );
end camellia;

architecture phy of camellia is

  signal ireg1     :     bit_vector (127 downto 0);
  signal ikey      :     bit_vector ( 63 downto 0);
  signal ipt       :     bit_vector ( 63 downto 0);
  signal iptt      :     bit_vector ( 63 downto 0);
  signal f         :     bit_vector ( 63 downto 0);
  signal l         :     bit_vector ( 63 downto 0);
  signal r         :     bit_vector ( 63 downto 0);
  signal ri        :     bit_vector ( 63 downto 0);
  signal il        :     bit_vector ( 63 downto 0);
  signal ir        :     bit_vector ( 63 downto 0);
  signal fl1       :     bit_vector ( 63 downto 0);
  signal fl1i      :     bit_vector ( 63 downto 0);
  signal fl2       :     bit_vector ( 63 downto 0);
  signal flx       :     bit_vector ( 31 downto 0);
  signal fla       :     bit_vector ( 63 downto 0);
  signal flb       :     bit_vector ( 63 downto 0);
  signal s1i       :     bit_vector (  7 downto 0);
  signal s2i       :     bit_vector (  7 downto 0);
  signal s2t       :     bit_vector (  7 downto 0);
  signal s3i       :     bit_vector (  7 downto 0);
  signal s4i       :     bit_vector (  7 downto 0);
  signal s5i       :     bit_vector (  7 downto 0);
  signal s5t       :     bit_vector (  7 downto 0);
  signal s6i       :     bit_vector (  7 downto 0);
  signal s7i       :     bit_vector (  7 downto 0);
  signal s8i       :     bit_vector (  7 downto 0);
  signal s1o       :     bit_vector (  7 downto 0);
  signal s2o       :     bit_vector (  7 downto 0);
  signal s3o       :     bit_vector (  7 downto 0);
  signal s4o       :     bit_vector (  7 downto 0);
  signal s5o       :     bit_vector (  7 downto 0);
  signal s6o       :     bit_vector (  7 downto 0);
  signal s7o       :     bit_vector (  7 downto 0);
  signal s8o       :     bit_vector (  7 downto 0);
  signal z1        :     bit_vector (  7 downto 0);
  signal z2        :     bit_vector (  7 downto 0);
  signal z3        :     bit_vector (  7 downto 0);
  signal z4        :     bit_vector (  7 downto 0);
  signal z5        :     bit_vector (  7 downto 0);
  signal z6        :     bit_vector (  7 downto 0);
  signal z7        :     bit_vector (  7 downto 0);
  signal z8        :     bit_vector (  7 downto 0);
  signal c2b       :     bit_vector (  1 downto 0);
  signal c2b_cr    :     bit_vector (  1 downto 0);
  signal c3b       :     bit_vector (  2 downto 0);
  signal c3b_cr    :     bit_vector (  2 downto 0);
  signal c3b_rst   :     bit;
  signal c2b_rst   :     bit;
  signal rc        :     bit;
  signal vld4      :     bit;
  signal vld8      :     bit;
  signal ildpt     :     bit;
  signal ildptt    :     bit;
  signal ildpt_rst :     bit;

  component sbox
    port (
    di             : in  bit_vector (  7 downto 0);
    do             : out bit_vector (  7 downto 0)
    );
  end component;

begin

  sb1 : sbox
  port map (
    di             => s1i,
    do             => s1o
    );
  sb2 : sbox
  port map (
    di             => s2i,
    do             => s2o
    );
  sb3 : sbox
  port map (
    di             => s3i,
    do             => s3o
    );
  sb4 : sbox
  port map (
    di             => s4i,
    do             => s4o
    );
  sb5 : sbox
  port map (
    di             => s5i,
    do             => s5o
    );
  sb6 : sbox
  port map (
    di             => s6i,
    do             => s6o
    );
  sb7 : sbox
  port map (
    di             => s7i,
    do             => s7o
    );
  sb8 : sbox
  port map (
    di             => s8i,
    do             => s8o
    );

--probe
--r_prb            <=   r;
--l_prb            <=   l;
--fla_prb          <= fla;
--ir_prb           <=  ir;
--il_prb           <=  il;
--rc_prb           <= c3b;
--s_prb            <= s8i & s7i & s6i & s5i & s4i & s3i & s2i & s1i;
--z_prb            <= z1  & z2  & z3  & z4  & z5  & z6  & z7  & z8 ;
--probe

  c3b_cr(0)            <= '0'; -- LSB always zero
  c3b_cr( 2 downto  1) <= ( ((c3b( 1 downto  0) and B"01") or (c3b( 1 downto  0) and c3b_cr( 1 downto  0))) or (B"01" and c3b_cr( 1 downto  0)) );

  process (clk)
  begin
    if (clk = '1' and clk'event) then
      if (c3b_rst = '1') then
        c3b <= B"000"; 
      else
        c3b <= ((c3b xor B"001") xor c3b_cr);
      end if;
    end if;
  end process;

  c2b_cr(0)            <= '0'; -- LSB always zero
  c2b_cr(1)            <= c2b(0);

  process (clk)
  begin
    if (clk = '1' and clk'event) then
      if (c2b_rst = '1') then
        c2b <= B"00"; 
      elsif (rc = '1') then
        c2b <= ((c2b xor B"01") xor c2b_cr);
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ildpt      <=  '0';
        ildptt     <=  '0';
        ipt        <= (others => '0');
        ikey       <= (others => '0');
        fl1i       <= (others => '0');
        iptt       <= (others => '0');
        ri         <= (others => '0');
      else
        ildptt     <= ldpt;
        ildpt      <= ildptt;
        fl1i       <=  fl1;
        iptt       <=   pt;
        ipt        <= iptt;
        ikey       <=  key;
        ri         <=    r;
      end if;
    end if;
  end process;

  rc               <= not(not(c3b(2)) or not(c3b(1)) or not(c3b(0))); -- B"111" -- count until 7 ( 8 clock cycle)
  ildpt_rst        <= ((ildpt xor ildptt) and ildpt);
  c3b_rst          <= rst or ildpt_rst or rc ;
  c2b_rst          <= rst or ildpt_rst;

--L_{r}            == R_{r-1} xor F(L_{r-1}, kr)
--R_{r}            == L_{r-1}

  l                <= ireg1(127 downto 64)      ;
  r                <= ireg1( 63 downto  0)      ;

  s1i              <=   l  (  7 downto   0) xor ikey( 7 downto  0);
  s2t              <=   l  ( 15 downto   8) xor ikey(15 downto  8);
  s2i              <= s2t(6 downto 0) & s2t(7);
  s3i              <=   l  ( 23 downto  16) xor ikey(23 downto 16);
  s4i              <=   l  ( 31 downto  24) xor ikey(31 downto 24);-- SBOX4(ROTL1x)
  s5t              <=   l  ( 39 downto  32) xor ikey(39 downto 32);
  s5i              <= s5t(6 downto 0) & s5t(7);
  s6i              <=   l  ( 47 downto  40) xor ikey(47 downto 40);
  s7i              <=   l  ( 55 downto  48) xor ikey(55 downto 48);-- SBOX4(ROTL1x)
  s8i              <=   l  ( 63 downto  56) xor ikey(63 downto 56);

--S-function

  z8               <= s1o;                                   -- SBOX1  
  z7               <= s2o;                                   -- SBOX4(ROTL1x)
  z6               <= s3o(0) & s3o(7 downto 1);              -- SBOX3 ROTR1
  z5               <= s4o(6 downto 0) & s4o(7);              -- SBOX2 ROTL1  
  z4               <= s5o;                                   -- SBOX4(ROTL1x)
  z3               <= s6o(0) & s6o(7 downto 1);              -- SBOX3 ROTR1
  z2               <= s7o(6 downto 0) & s7o(7);              -- SBOX2 ROTL1  
  z1               <= s8o;                                   -- SBOX1

--P-function
--z'1              == z1  xor z3  xor z4  xor z6  xor z7  xor z8
--z'2              == z1  xor z2  xor z4  xor z5  xor z7  xor z8
--z'3              == z1  xor z2  xor z3  xor z5  xor z6  xor z8
--z'4              == z2  xor z3  xor z4  xor z5  xor z6  xor z7
--z'5              == z1  xor z2  xor z6  xor z7  xor z8
--z'6              == z2  xor z3  xor z5  xor z7  xor z8
--z'7              == z3  xor z4  xor z5  xor z6  xor z8
--z'8              == z1  xor z4  xor z5  xor z6  xor z7

  f (63 downto 56) <= z1  xor z3  xor z4  xor z6  xor z7  xor z8 ;
  f (55 downto 48) <= z1  xor z2  xor z4  xor z5  xor z7  xor z8 ;
  f (47 downto 40) <= z1  xor z2  xor z3  xor z5  xor z6  xor z8 ;
  f (39 downto 32) <= z2  xor z3  xor z4  xor z5  xor z6  xor z7 ;
  f (31 downto 24) <= z1  xor z2  xor z6  xor z7  xor z8         ;
  f (23 downto 16) <= z2  xor z3  xor z5  xor z7  xor z8         ;
  f (15 downto  8) <= z3  xor z4  xor z5  xor z6  xor z8         ;
  f ( 7 downto  0) <= z1  xor z4  xor z5  xor z6  xor z7         ;

--F-function

  fla              <= r xor f;

--FL1-function
--Xi(64) == XL(32) & XR(32)
--Ki(64) == KL(32) & KR(32)
--Yr(32) == ((XL and Kl) <<< 1) xor XR
--Yl(32) == ( Yr or  Kr)        xor XL
--Yi(64) == Yl(32) & Yr(32)
  fl1(31 downto  0)<=  ((( l (62 downto 32) and ikey(62 downto 32)) & ( l (63) and ikey(63))) xor  l (31 downto  0));
--fl1(31 downto  0)<= ((((fla(62 downto 32) and ikey(62 downto 32)) & (fla(63) and ikey(32))) xor fla(31 downto  0)) or ikey(31 downto  0)) xor fla(63 downto 32);
  fl1(63 downto 32)<=    (fl1(31 downto  0) or  ikey(31 downto  0)) xor l (63 downto 32);

  il               <= fla when rc  = '0' else fl1i;

--FL2-function
--Yi(64) == YL(32) & YR(32)
--Ki(64) == KL(32) & KR(32)
--Xl(32) == ( Yr or  Kr)        xor YL
--Xr(32) == ((Xl and Kl) <<< 1) xor YR
--Xi(64) == Xl(32) & Xr(32)
  fl2(63 downto 32)<=  ((ri(31 downto  0) or ikey(31 downto  0)) xor ri(63 downto 32));
  flx(31 downto  0)<= (((ri(31 downto  0) or ikey(31 downto  0)) xor ri(63 downto 32)) and ikey(63 downto 32));
  fl2(31 downto  0)<=  ((   flx(30 downto  0) & flx(31)   )      xor ri(31 downto  0));

  ir               <= l  when rc  = '0' else fl2;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ireg1(127 downto  0) <= (others => '0') ;
      elsif (ildpt = '1') then
        ireg1(127 downto  0) <= ireg1( 63 downto  0) & (ipt xor ikey);    -- initial round 2 clock
      else
        ireg1( 63 downto  0) <= ir              ;
        ireg1(127 downto 64) <= il              ; 
      end if;
    end if;
  end process;

-- this valid signal for Nk=4   2 round (8 clock) plus the next 6-7 (the last two clock of its round) approx: 24 clock for each block
  vld4             <=  not(not(c2b(1)) or     c2b(0) ) and (not(not(c3b(2)) or not(c3b(1)) or not(c3b(0))) or not(not(c3b(2)) or not(c3b(1)) or c3b(0)));
-- this valid signal for Nk=6/8 3 round (8 clock) plus the next 6-7 (the last two clock of its round) aprrox: 32 clock for each block
  vld8             <=  not(not(c2b(1)) or not(c2b(0))) and (not(not(c3b(2)) or not(c3b(1)) or not(c3b(0))) or not(not(c3b(2)) or not(c3b(1)) or c3b(0)));
  ct               <= r xor ikey                ; 
  v                <= vld4 when (not(Nk(3) or not(Nk(2)) or Nk(1) or Nk(0)) = '1') else vld8;

end phy;
