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

entity smap is
  port (
  lsfr             : in  bit_vector (511 downto 0);
  s0               : out bit_vector ( 31 downto 0);
  s1               : out bit_vector ( 31 downto 0);
  s2               : out bit_vector ( 31 downto 0);
  s3               : out bit_vector ( 31 downto 0);
  s4               : out bit_vector ( 31 downto 0);
  s5               : out bit_vector ( 31 downto 0);
  s6               : out bit_vector ( 31 downto 0);
  s7               : out bit_vector ( 31 downto 0);
  s8               : out bit_vector ( 31 downto 0);
  s9               : out bit_vector ( 31 downto 0);
  sa               : out bit_vector ( 31 downto 0);
  sb               : out bit_vector ( 31 downto 0);
  sc               : out bit_vector ( 31 downto 0);
  sd               : out bit_vector ( 31 downto 0);
  se               : out bit_vector ( 31 downto 0);
  sf               : out bit_vector ( 31 downto 0)
  );
end smap;

architecture phy of smap is
begin

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

end phy;
