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

entity snow is
  port (
  key              : in  bit_vector ( 31 downto 0);
  IV               : in  bit_vector ( 31 downto 0);
  n                : in  bit_vector ( 31 downto 0);
  zt               : out bit_vector ( 31 downto 0);
  ld               : in  bit;
  init             : in  bit;
  shift            : in  bit;
  clk              : in  bit;
  rst              : in  bit
  );
end snow;

architecture phy of snow is

  signal lsfr      :     bit_vector (511 downto 0);
  signal s0        :     bit_vector ( 31 downto 0);
  signal s1        :     bit_vector ( 31 downto 0);
  signal s2        :     bit_vector ( 31 downto 0);
  signal s3        :     bit_vector ( 31 downto 0);
  signal s4        :     bit_vector ( 31 downto 0);
  signal s5        :     bit_vector ( 31 downto 0);
  signal s6        :     bit_vector ( 31 downto 0);
  signal s7        :     bit_vector ( 31 downto 0);
  signal s8        :     bit_vector ( 31 downto 0);
  signal s9        :     bit_vector ( 31 downto 0);
  signal sa        :     bit_vector ( 31 downto 0);
  signal sb        :     bit_vector ( 31 downto 0);
  signal sc        :     bit_vector ( 31 downto 0);
  signal sd        :     bit_vector ( 31 downto 0);
  signal se        :     bit_vector ( 31 downto 0);
  signal sf        :     bit_vector ( 31 downto 0);

  signal v         :     bit_vector ( 31 downto 0);

  signal ss1i      :     bit_vector ( 31 downto 0); -- S1
  signal ss1o      :     bit_vector ( 31 downto 0); -- S1
  signal ss2i      :     bit_vector ( 31 downto 0); -- S2
  signal ss2o      :     bit_vector ( 31 downto 0); -- S2

  signal F         :     bit_vector ( 31 downto 0); -- F  = (sf +) xor R2
  signal r         :     bit_vector ( 31 downto 0); -- r  = R2 + (R3 xor s5)
  signal R1        :     bit_vector ( 31 downto 0); -- R1 = r
  signal R2        :     bit_vector ( 31 downto 0); -- R2 = S1(R1)
  signal R3        :     bit_vector ( 31 downto 0); -- R3 = S2(R2)

  signal mli       :     bit_vector (  7 downto 0);
  signal mlo       :     bit_vector ( 31 downto 0);
  signal dvi       :     bit_vector (  7 downto 0);
  signal dvo       :     bit_vector ( 31 downto 0);

  signal ivma      :     bit_vector (127 downto 0) := X"ffffffffffffffff0000000000000000";
  signal ivmb      :     bit_vector (127 downto 0) := X"0000000000000000ffffffff00000000";
  signal ivmc      :     bit_vector (127 downto 0) := X"000000000000000000000000ffffffff";

  component sboxs1
  port (
  w                :     bit_vector ( 31 downto 0);
  r                :     bit_vector ( 31 downto 0)
  );
  end component;

  component sboxs2
  port (
  w                :     bit_vector ( 31 downto 0);
  r                :     bit_vector ( 31 downto 0)
  );
  end component;

  component mula
  port (
  c                :     bit_vector (  7 downto 0);
  w                :     bit_vector ( 31 downto 0)
  );
  end component;

  component diva
  port (
  c                :     bit_vector (  7 downto 0);
  w                :     bit_vector ( 31 downto 0)
  );
  end component;

begin

  ss1              : sboxs1
  port map (
  w                => ss1i,
  r                => ss1o
  );
  ss2              : sboxs2
  port map (
  w                => ss2i,
  r                => ss2o
  );
  ml               : mula
  port map (
  c                => mli,
  w                => mlo
  );
  dv               : diva
  port map (
  c                => dvi,
  w                => dvo
  );
--persistent connection
  s0               <= lsfr(511 downto 480);
  s1               <= lsfr(479 downto 448);
  s2               <= lsfr(447 downto 416);
  s3               <= lsfr(415 downto 384);
  s4               <= lsfr(383 downto 352);
  s5               <= lsfr(351 downto 320);
  s6               <= lsfr(319 downto 288);
  s7               <= lsfr(287 downto 256);
  s8               <= lsfr(255 downto 224);
  s9               <= lsfr(223 downto 192);
  sa               <= lsfr(191 downto 160);
  sb               <= lsfr(159 downto 128);
  sc               <= lsfr(127 downto  96);
  sd               <= lsfr( 95 downto  64);
  se               <= lsfr( 63 downto  32);
  sf               <= lsfr( 31 downto   0);
--persistent connection

--FSM-Network
  F                <= (sf + R1) xor R2 ; -- CAVEATS: THIS LINE IS NOT PORTABLE CODE
  r                <=  R2 + (R3 xor s5); -- CAVEATS: THIS LINE IS NOT PORTABLE CODE
  R1               <= r;
  ss1i             <= R1;
  R2               <= ss1o;
  ss2i             <= R2;
  R3               <= ss2o;
--FSM-Network
  
  mli              <= s0(31 downto 24);
  dvi              <= sb( 7 downto  0);
--v                == (S0,1||S0,2||S0,3||0x00)  xor MULa(S0,0) xor S2 xor (0x00||S11,0||S11,1||S11,2) xor DIVa(S11,3)
  v                <= (s0(23 downto 0) & X"00") xor mlo        xor s2 xor (X"00" & sb(31 downto 8))   xor dvo xor F when init = '1' else
                      (s0(23 downto 0) & X"00") xor mlo        xor s2 xor (X"00" & sb(31 downto 8))   xor dvo;

  process (clk)
  begin
    if((clk = '1') and clk'event) then
      if (rst = '1') then
        lsfr       <= (others => '0');
        ivma       <= X"ffffffffffffffff0000000000000000";
        ivmb       <= X"0000000000000000ffffffff00000000";
        ivmc       <= X"000000000000000000000000ffffffff";
      elsif (ld   = '1') then
        ivma(127 downto   0) <= ivma( 95 downto   0) & ivma(127 downto  96);   -- IV mask a
        ivmb(127 downto   0) <= ivmb( 95 downto   0) & ivmb(127 downto  96);   -- IV mask b
        ivmc(127 downto   0) <= ivmc( 95 downto   0) & ivmc(127 downto  96);   -- IV mask c
--rotate in each block
        lsfr(127 downto   0) <= lsfr( 95 downto   0) & lsfr(127 downto  96);   -- sc...sf
        lsfr(255 downto 128) <= lsfr(223 downto 128) & lsfr(255 downto 224);   -- s8...sb
        lsfr(383 downto 256) <= lsfr(351 downto 256) & lsfr(383 downto 352);   -- s4...s7
        lsfr(511 downto 384) <= lsfr(479 downto 384) & lsfr(511 downto 448);   -- s0...s3
--key
	lsfr(127 downto  96) <= key;                                           -- sc == key
	lsfr(255 downto 224) <= key xor X"ffffffff";                           -- s8 == key xor 1
	lsfr(383 downto 352) <= key;                                           -- s4 == key
	lsfr(511 downto 448) <= key xor X"ffffffff";                           -- s0 == key xor 1
--special cases for IV, the sequences is quite peculiar: sf, sc, and sa, s9
        lsfr( 31 downto   0) <= IV and ivma(127 downto  96);                   -- first 2 clock go to sf then sc
        lsfr(255 downto 224) <= IV and ivmb(127 downto  96);                   -- next  1 clock go to sa
        lsfr(191 downto 160) <= IV and ivmc(127 downto  96);                   -- last  1 clock go to s9
      elsif (shift = '1') then
        lsfr       <= lsfr(479 downto   0) & v; 
      end if;
    end if;
  end process;

  zt               <= F xor s0;

end phy;
