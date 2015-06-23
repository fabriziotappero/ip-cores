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

entity kasumi is
  port (
  pt               : in  bit_vector ( 31 downto 0);
  ldpt             : in  bit;
  key              : in  bit_vector ( 63 downto 0);
  ldk              : in  bit;
--probe
--L_prb            : out bit_vector ( 31 downto 0);
--R_prb            : out bit_vector ( 31 downto 0);
--FL_prb           : out bit_vector ( 31 downto 0);
--ikey_prb         : out bit_vector ( 15 downto 0);
--FO_prb           : out bit_vector ( 15 downto 0);
--FI_prb           : out bit_vector ( 15 downto 0);
--st_prb           : out bit_vector (  3 downto 0);
--rnd_prb          : out bit_vector (  1 downto 0);
--even_prb         : out bit;
--probe
  ct               : out bit_vector ( 63 downto 0);
  v                : out bit;
  clk              : in  bit;
  rst              : in  bit
  );
end kasumi;

architecture phy of kasumi is

  signal ireg1     :     bit_vector ( 63 downto 0);
  signal ikey      :     bit_vector ( 15 downto 0);
  signal ipt       :     bit_vector ( 31 downto 0);
  signal iptt      :     bit_vector ( 31 downto 0);
  signal r         :     bit_vector ( 31 downto 0);
  signal l         :     bit_vector ( 31 downto 0);
  signal ir        :     bit_vector ( 31 downto 0);
  signal il        :     bit_vector ( 31 downto 0);
  signal F         :     bit_vector ( 31 downto 0);
  signal FL        :     bit_vector ( 31 downto 0);
  signal FLl       :     bit_vector ( 15 downto 0);
  signal FLr       :     bit_vector ( 15 downto 0);
  signal FL0       :     bit_vector ( 15 downto 0);
  signal FL1       :     bit_vector ( 15 downto 0);
  signal LFL       :     bit_vector ( 15 downto 0);
  signal RFL       :     bit_vector ( 15 downto 0);
  signal FO        :     bit_vector ( 15 downto 0);
  signal FI        :     bit_vector ( 15 downto 0);
  signal x7a       :     bit_vector (  6 downto 0);
  signal x9a       :     bit_vector (  8 downto 0);
  signal x7b       :     bit_vector (  6 downto 0);
  signal x9b       :     bit_vector (  8 downto 0);
  signal y7a       :     bit_vector (  6 downto 0);
  signal y9a       :     bit_vector (  8 downto 0);
  signal y7b       :     bit_vector (  6 downto 0);
  signal y9b       :     bit_vector (  8 downto 0);
  signal st        :     bit_vector (  3 downto 0); -- 16 states
  signal c3b       :     bit_vector (  2 downto 0);
  signal c3b_cr    :     bit_vector (  2 downto 0);
  signal c3b_rst   :     bit;
  signal rnd       :     bit_vector (  1 downto 0);
  signal rnd_cr    :     bit_vector (  1 downto 0);
  signal rnd_rst   :     bit;
  signal even      :     bit;
  signal vld       :     bit;
  signal ildpt     :     bit;
  signal ildpt_rst :     bit;
  signal ildptt    :     bit;

  component sbox
  port (
  x7               : in  bit_vector (  6 downto 0);
  x9               : in  bit_vector (  8 downto 0);
  y7               : out bit_vector (  6 downto 0);
  y9               : out bit_vector (  8 downto 0)
  );
  end component;

  component keyschedule
  port (
  key              : in  bit_vector ( 63 downto 0);
  st               : in  bit_vector (  3 downto 0);
  ldk              : in  bit;
  rk               : out bit_vector ( 15 downto 0);
  clk              : in  bit;
  rst              : in  bit
  );
  end component;

begin

  s1               : sbox
  port map (
  x7               => x7a,
  x9               => x9a,
  y7               => y7a,
  y9               => y9a
  );
  s2               : sbox
  port map (
  x7               => x7b,
  x9               => x9b,
  y7               => y7b,
  y9               => y9b
  );
  roundkey         : keyschedule
  port map (
  key              => key,
  st               => st,
  ldk              => ldk,
  rk               => ikey,
  clk              => clk,
  rst              => rst
  );

--probe
--L_prb            <= l;
--R_prb            <= r;
--ikey_prb         <= ikey;
--FL_prb           <= FL;
--FI_prb           <= FI;
--FO_prb           <= FO;
--st_prb           <= st;
--rnd_prb          <= rnd;
--even_prb         <= even;
--probe

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ildpt      <=  '0';
        ildptt     <=  '0';
        ipt        <= (others => '0');
--      ikey       <= (others => '0');
        iptt       <= (others => '0');
      else
        ildptt     <= ldpt;
        ildpt      <= ildptt;
        iptt       <=   pt;
        ipt        <= iptt;
--      ikey       <=  key;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        even       <= '0';
      elsif (c3b = O"7") then
        even       <= not(even);
      end if;
    end if;
  end process;

  c3b_cr(0)                            <= '0'; -- LSB always zero
  c3b_cr( 2 downto  1)                 <= ( ((c3b( 1 downto  0) and B"01") or (c3b( 1 downto  0) and c3b_cr( 1 downto  0))) or (B"01" and c3b_cr( 1 downto  0)) );

  process (clk)
  begin
    if (clk = '1' and clk'event) then
      if (c3b_rst = '1') then
        c3b        <= B"000"; 
      else
        c3b        <= ((c3b xor B"001") xor c3b_cr);
      end if;
    end if;
  end process;

  ildpt_rst        <= ((ildpt xor ildptt) and ildpt);
  c3b_rst          <= rst or ildpt_rst;

  l                <= ireg1( 63 downto 32);
  r                <= ireg1( 31 downto  0);

--0-FL-FL-FO-FI-FO-FI-FO-FI+FO-FI-FO-FI-FO-FI-FL-FL+
--1-FL-FL-FO-FI-FO-FI-FO-FI+FO-FI-FO-FI-FO-FI-FL-FL+
--2-FL-FL-FO-FI-FO-FI-FO-FI+FO-FI-FO-FI-FO-FI-FL-FL+
--3-FL-FL-FO-FI-FO-FI-FO-FI+FO-FI-FO-FI-FO-FI-FL-FL+

  st <= even & c3b;
  process (st,rst,FL,FO,FI,FL0,FL1,r)
  begin
    if (rst = '1') then
      LFL          <= (others => '0');
      RFL          <= (others => '0');
    else
      case st is
        when X"0"  => 
          LFL      <=                      FL(31 downto 16);
          RFL      <= FL0;
        when X"1" =>
          LFL      <= FL1;
          RFL      <=                      FL(15 downto  0);
        when X"2" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"3" =>
          LFL      <=                      FL(15 downto  0);
          RFL      <= FI               xor FL(15 downto  0);
        when X"4" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"5" =>
          LFL      <=                      FL(15 downto  0);
          RFL      <= FI               xor FL(15 downto  0);
        when X"6" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"7" =>
          LFL      <=                      FL(15 downto  0)  xor  r(31 downto 16); -- xor R
          RFL      <= FI               xor FL(15 downto  0)  xor  r(15 downto  0); -- xor R
        when X"8" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"9" =>
          LFL      <=                      FL(15 downto  0);
          RFL      <= FI               xor FL(15 downto  0);
        when X"a" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"b" =>
          LFL      <=                      FL(15 downto  0);
          RFL      <= FI               xor FL(15 downto  0);
        when X"c" =>
          LFL      <= FO;
          RFL      <=                      FL(15 downto  0);
        when X"d" =>
          LFL      <=                      FL(15 downto  0);
          RFL      <= FI               xor FL(15 downto  0);
        when X"e"  => 
          LFL      <=                      FL(31 downto 16);
          RFL      <= FL0;
        when X"f" =>
          LFL      <= FL1              xor  r(31 downto 16); -- xor R
          RFL      <= FL(15 downto  0) xor  r(15 downto  0); -- xor R
      end case;
    end if;
  end process;

  FLl              <= l(31 downto 16) when even = '0' else FL(31 downto 16);
  FLr              <= l(15 downto  0) when even = '0' else FL(15 downto  0);
--FL(R')           == FL(R) xor ROTL1{FL(L) and KLi1}
  FL0              <= FLr xor ((FLl(14 downto 0) and ikey(14 downto 0)) & (FLl(15) and ikey(15)));
--FL(L')           == FL(L) xor ROTL1{FL(R') or KLi2}
  FL1              <= FLl xor ((FL (14 downto 0) or  ikey(14 downto 0)) & (FL (15) or  ikey(15)));

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        FL         <= (others => '0');
      else
        FL         <= LFL & RFL;
      end if;
    end if;
  end process;

--FO               == Lj-1             xor KOij
  FO               <= FL(31 downto 16) xor ikey(15 downto  0);

--FI-function
-- L1 == R0                 R1 == S9[L0] xor ZE(R0)
-- L2 == R1 xor KIij2       R2 == S7[L1] xor TR(R1) xor KIij1
-- L3 == R2                 R3 == S9[L2] xor ZE(R2)
-- L4 == S7[L3] xor TR(R3)  R4 == R3
-- Return L4 || R4

--L0
  x9a              <= FL(31 downto 23);
--R0
  x7a              <= FL(22 downto 16);
--L2               ==         S9[L0]          xor    ZE    (R0)     xor KIi,j,2 (9 bit)
  x9b              <=         y9a(8 downto 0) xor (B"00" & x7a)     xor ikey( 8 downto 0);
--R2               == S7[L1] xor             TR(R1)                 xor KIi,j,1 (7 bit)
  x7b              <= y7a xor y9a(6 downto 0) xor          x7a      xor ikey(15 downto 9);
--R3               ==         S9[L2]          xor    ZE    (R2)
  FI( 8 downto 0)  <=         y9b(8 downto 0) xor (B"00" & x7b);
--L4               == S7[L3] xor TR(R3)
  FI(15 downto 9)  <= y7b xor  FI(6 downto 0);
--Rj               == FI(Lj-1 xor KOij, KIij) xor Rj-1

  il               <= LFL & RFL;
--R'               == Li-1
  ir               <= l;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        ireg1      <= (others => '0');
      elsif (ildpt = '1') then
        ireg1      <= ireg1( 31 downto 0) & ipt;
      elsif (c3b = O"7") then
ireg1(31 downto  0)<= ir;
ireg1(63 downto 32)<= il;
      end if;
    end if;
  end process;

  rnd_cr           <= rnd(0) & '0';
  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        rnd        <= B"00";
      elsif (st  = X"f") then
        rnd        <= ((rnd xor B"01") xor rnd_cr);
      end if;
    end if;
  end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        vld        <= '0';
      elsif ((rnd & st) = B"111111") then
        vld        <= '1';
      else
        vld        <= '0';
      end if;
    end if;
  end process;

  v                <= vld;
  ct               <= l & r;

end phy;
