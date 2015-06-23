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
-- KeyExpansion(byte key[4*Nk], word w[Nb*(Nr+1)], Nk)
-- begin
--    word temp
--    i = 0
--    while (i < Nk)
--      w[i] = word(key[4*i], key[4*i+1], key[4*i+2], key[4*i+3])
--      i    = i + 1
--    end while
--    i = Nk
--    while (i < Nb * (Nr+1))
--      temp = w[i-1]
--      if (i mod Nk = 0)
--        temp = SubWord(RotWord(temp)) xor Rcon[i/Nk]
--      else if (Nk > 6 and i mod Nk = 4)
--        temp = SubWord(temp)
--      end if
--      w[i] = w[i-Nk] xor temp
--      i    = i + 1
--    end while
-- end
-- Nk (Number of Key), Nb (Number of Block), Nr (Number of Round)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity keyexpansion is
  port (
  key : in  bit_vector (31 downto 00);      -- source key
  w   : out bit_vector (31 downto 00);      -- expanded keys
  Nk  : in  bit_vector (03 downto 00);      -- 128,192,256 => 4,6,8 (0100,0110,1000)
  ld  : in  bit;                            -- 'ld' must active for Nk clock to load keys.
  v   : out bit;                            -- output valid signal
  clk : in  bit;                            -- clock signal
  rst : in  bit                             -- reset signal, its wise to reset before any action.
  );
end keyexpansion;

architecture phy of keyexpansion is

  constant Rc  : bit_vector (79 downto 00) := ( X"01020408_10204080_1B36");
  signal Rcs   : bit_vector (79 downto 00) := ( X"01020408_10204080_1B36");
  signal int   : bit_vector (255 downto 0); -- 256 bit internal register
  signal cnt   : bit_vector (03 downto 00); --   4 bit counter start from 1 not 0
  signal cnts  : bit_vector (05 downto 00); --   6 bit counter start from 1 not 0
  signal Rcon  : bit_vector (07 downto 00); -- round constant
  signal rot   : bit;                       -- RotWord signal
  signal crst  : bit;                       -- reset counter
  signal rsts  : bit;                       -- reset state counter
  signal mod4  : bit;                       -- modulo 4 (used in case of 256bit key)
  signal Nk8s  : bit;                       -- Nk 8 signal
  signal ldi1  : bit;                       -- delayed load signal
  signal ldrs  : bit;                       -- reset signal from load
  signal vld   : bit;                       -- valid signal
  signal vrst1 : bit;                       -- reset valid signal for 128bit key
  signal vrst2 : bit;                       -- reset valid signal for 192bit key
  signal vrst3 : bit;                       -- reset valid signal for 256bit key
  signal rstsc : bit;                       -- reset state counter from reset valid signal
  signal sai   : bit_vector (07 downto 00); -- SubWord input signal
  signal sbi   : bit_vector (07 downto 00); -- SubWord input signal
  signal sci   : bit_vector (07 downto 00); -- SubWord input signal
  signal sdi   : bit_vector (07 downto 00); -- SubWord input signal
  signal sao   : bit_vector (07 downto 00); -- SubWord output signal
  signal sbo   : bit_vector (07 downto 00); -- SubWord output signal
  signal sco   : bit_vector (07 downto 00); -- SubWord output signal
  signal sdo   : bit_vector (07 downto 00); -- SubWord output signal
  signal wi1   : bit_vector (31 downto 00); -- w[i] state signal
  signal wiNk  : bit_vector (31 downto 00); -- w[i-Nk] state signal
  signal temp  : bit_vector (31 downto 00); -- SubWord,RotWord,Rcon signal
  signal tmp   : bit_vector (31 downto 00); -- SubWord,RotWord,Rcon signal

--For SubWord
  component sbox
    port (
    di : in  bit_vector (07 downto 00);
    do : out bit_vector (07 downto 00)
    );
  end component;
--For each round counter
  component c4b
    port (
    cnt : out bit_vector (03 downto 00);
    clk : in  bit;
    rst : in  bit
    );
  end component;
--For all iteration in keyexpansion
  component c6b
    port (
    cnt : out bit_vector (05 downto 00);
    clk : in  bit;
    rst : in  bit
    );
  end component;

begin

sboxa : sbox
  port map (
    di => sai,
    do => sao
    );
sboxb : sbox
  port map (
    di => sbi,
    do => sbo
    );
sboxc : sbox
  port map (
    di => sci,
    do => sco
    );
sboxd : sbox
  port map (
    di => sdi,
    do => sdo
    );
ctr1  : c4b
  port map (
    cnt => cnt,
    clk => clk,
    rst => crst
    );
ctr2  : c6b
  port map (
    cnt => cnts,
    clk => clk,
    rst => rsts
    );

--Special cases for Nk=8
  mod4             <= not(cnt(3) or not(cnt(2)) or cnt(1) or cnt(0));
  Nk8s             <= mod4 and not(not(Nk(3)) or Nk(2) or Nk(1) or Nk(0));

--RotWord detection
  rot              <= not( (Nk(3) xor cnt(3)) or (Nk(2) xor cnt(2)) or
                           (Nk(1) xor cnt(1)) or (Nk(0) xor cnt(0))   );

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      ldi1 <= ld;
    end if;
  end process;
  ldrs             <= ld xor ldi1; -- reset signal from load

--Keyexpansion need 4*(Nr+1) clock to do all calculation with
--Nr = 10 when Nk = 4 (128 bit) this would generate 44(101100) 32bit keys
--Nr = 12 when Nk = 6 (192 bit) this would generate 52(110100) 32bit keys
--Nr = 14 when Nk = 8 (256 bit) this would generate 60(111100) 32bit keys

  vrst1 <= not( not(cnts(5)) or cnts(4) or not(cnts(3)) or not(cnts(2)) or cnts(1) or cnts(0));     -- 44(101100)
  vrst2 <= not( not(cnts(5)) or not(cnts(4)) or cnts(3) or not(cnts(2)) or cnts(1) or cnts(0));     -- 52(110100)
  vrst3 <= not( not(cnts(5)) or not(cnts(4)) or not(cnts(3)) or not(cnts(2)) or cnts(1) or cnts(0));-- 60(111100)

  with Nk(03 downto 00) select
  rstsc <= vrst1 when B"0100", -- Nk 4(0100)
	   vrst2 when B"0110", -- Nk 6(0110)
	   vrst3 when B"1000", -- Nk 8(1000)
	   vrst1 when  others; -- default

--Setting up counter inline with Nk periode.
--For each round
  crst             <= rst or rot or ldrs;
--For the state
  rsts             <= rst or (ldrs and ld) or rstsc;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        vld <= '0';
      elsif (((ldrs and ld) or (rstsc and vld)) = '1') then -- (ldrs and ld) is start signal (rstsc and vld) is end signal
        vld <= not(vld);
      end if;
    end if;
  end process;

  v <= vld; -- valid key expansion output signal

--Round constant calculation
--Rcon sequence: 01 02 04 08 10 20 40 80 1b 36
  Rcon(07 downto 00)<= Rcs (79 downto 72);
  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then -- default reset
        Rcs  <= Rc;
      elsif (rot = '1') then -- shift one byte
        Rcs (79 downto 08)<= Rcs (71 downto 00);
	Rcs (07 downto 00)<= (others => '0');
      end if;
    end if;
  end process;

  with Nk(03 downto 00) select
  wiNk <= int(127 downto  96) when B"0100", -- Nk 4(0100)
          int(191 downto 160) when B"0110", -- Nk 6(0110)
          int(255 downto 224) when B"1000", -- Nk 8(1000)
          int(127 downto  96) when  others; -- default

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        int(255 downto 00) <= (others => '0');
      elsif (ld = '1') then
        int(255 downto 00) <= int(223 downto 00) & key(31 downto 00);
      else
        int(255 downto 00) <= int(223 downto 00) & (wiNk xor temp);
      end if;
    end if;
  end process;

  wi1( 31 downto 00) <= int( 31 downto 00); -- first fifo

  sai(07 downto 00)<= wi1(31 downto 24);    -- SubWord
  sbi(07 downto 00)<= wi1(23 downto 16);    -- SubWord
  sci(07 downto 00)<= wi1(15 downto 08);    -- SubWord
  sdi(07 downto 00)<= wi1(07 downto 00);    -- SubWord

  tmp <=  sao            & sbo & sco & sdo when Nk8s='1' else -- special cases for Nk 8
         (sbo xor Rcon ) & sco & sdo & sao;                   -- others do: RotWord xor Rcon

  temp <= tmp when (rot='1' or Nk8s='1') else wi1;

  w  ( 31 downto 00) <= int( 31 downto 00) when vld = '1' else (others => '0'); -- key expansion result

end phy;
