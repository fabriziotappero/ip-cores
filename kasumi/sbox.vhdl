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

entity sbox is
  port (
  x7               : in  bit_vector (  6 downto 0);
  x9               : in  bit_vector (  8 downto 0);
  y7               : out bit_vector (  6 downto 0);
  y9               : out bit_vector (  8 downto 0)
  );
end sbox;

architecture phy of sbox is
begin
--S7
  y7(0)            <= (x7(1) and x7(3))           xor x7(4)                       xor (x7(0) and x7(1) and x7(4)) xor x7(5)                       xor 
                      (x7(2) and x7(5))           xor 
                      (x7(3) and x7(4) and x7(5)) xor x7(6)                       xor (x7(0) and x7(6))           xor (x7(1) and x7(6))           xor 
                      (x7(3) and x7(6))           xor (x7(2) and x7(4) and x7(6)) xor (x7(1) and x7(5) and x7(6)) xor (x7(4) and x7(5) and x7(6));
  y7(1)            <= (x7(0) and x7(1))           xor (x7(0) and x7(4))           xor (x7(2) and x7(4))           xor x7(5)                       xor 
                      (x7(1) and x7(2) and x7(5)) xor (x7(0) and x7(3) and x7(5)) xor x7(6)                       xor (x7(0) and x7(2) and x7(6)) xor 
                      (x7(3) and x7(6))           xor (x7(4) and x7(5) and x7(6)) xor '1';
  y7(2)            <= x7(0)                       xor (x7(0) and x7(3))           xor (x7(2) and x7(3))           xor (x7(1) and x7(2) and x7(4)) xor 
                      (x7(0) and x7(3) and x7(4)) xor (x7(1) and x7(5))           xor (x7(0) and x7(2) and x7(5)) xor (x7(0) and x7(6))           xor 
                      (x7(0) and x7(1) and x7(6)) xor (x7(2) and x7(6))           xor (x7(4) and x7(6))           xor '1';
  y7(3)            <= x7(1)                       xor (x7(0) and x7(1) and x7(2)) xor (x7(1) and x7(4))           xor 
                      (x7(3) and x7(4))           xor (x7(0) and x7(5))           xor (x7(0) and x7(1) and x7(5)) xor (x7(2) and x7(3) and x7(5)) xor 
                      (x7(1) and x7(4) and x7(5)) xor (x7(2) and x7(6))           xor (x7(1) and x7(3) and x7(6));
  y7(4)            <= (x7(0) and x7(2))           xor x7(3)                       xor (x7(1) and x7(3))           xor (x7(1) and x7(4))           xor 
                      (x7(0) and x7(1) and x7(4)) xor (x7(2) and x7(3) and x7(4)) xor (x7(0) and x7(5))           xor (x7(1) and x7(3) and x7(5)) xor 
                      (x7(0) and x7(4) and x7(5)) xor (x7(1) and x7(6))           xor (x7(3) and x7(6))           xor (x7(0) and x7(3) and x7(6)) xor 
                      (x7(5) and x7(6))           xor '1';
  y7(5)            <= x7(2)                       xor (x7(0) and x7(2))           xor (x7(0) and x7(3))           xor (x7(1) and x7(2) and x7(3)) xor 
                      (x7(0) and x7(2) and x7(4)) xor (x7(0) and x7(5))           xor (x7(2) and x7(5))           xor (x7(4) and x7(5))           xor 
                      (x7(1) and x7(6))           xor (x7(1) and x7(2) and x7(6)) xor (x7(0) and x7(3) and x7(6)) xor (x7(3) and x7(4) and x7(6)) xor
                      (x7(2) and x7(5) and x7(6)) xor '1';
  y7(6)            <= (x7(1) and x7(2))           xor (x7(0) and x7(1) and x7(3)) xor (x7(0) and x7(4))           xor (x7(1) and x7(5))           xor 
                      (x7(3) and x7(5))           xor x7(6)                       xor (x7(0) and x7(1) and x7(6)) xor (x7(2) and x7(3) and x7(6)) xor 
                      (x7(1) and x7(4) and x7(6)) xor (x7(0) and x7(5) and x7(6));
--S7
--S9
  y9(0)            <= (x9(0) and x9(2))           xor x9(3)                       xor (x9(2) and x9(5))           xor (x9(5) and x9(6))           xor
                      (x9(0) and x9(7))           xor (x9(1) and x9(7))           xor (x9(2) and x9(7))           xor (x9(4) and x9(8))           xor
                      (x9(5) and x9(8))           xor (x9(7) and x9(8))           xor '1';
  y9(1)            <= x9(1)                       xor (x9(0) and x9(1))           xor (x9(2) and x9(3))           xor (x9(0) and x9(4))           xor
                      (x9(1) and x9(4))           xor (x9(0) and x9(5))           xor (x9(3) and x9(5))           xor x9(6)                       xor
                      (x9(1) and x9(7))           xor (x9(2) and x9(7))           xor (x9(5) and x9(8))           xor '1';
  y9(2)            <= x9(1)                       xor (x9(0) and x9(3))           xor (x9(3) and x9(4))           xor (x9(0) and x9(5))           xor
                      (x9(2) and x9(6))           xor (x9(3) and x9(6))           xor (x9(5) and x9(6))           xor (x9(4) and x9(7))           xor
                      (x9(5) and x9(7))           xor (x9(6) and x9(7))           xor x9(8)                       xor (x9(0) and x9(8))           xor
                      '1';
  y9(3)            <= x9(0)                       xor (x9(1) and x9(2))           xor (x9(0) and x9(3))           xor (x9(2) and x9(4))           xor
                      x9(5)                       xor (x9(0) and x9(6))           xor (x9(1) and x9(6))           xor (x9(4) and x9(7))           xor
                      (x9(0) and x9(8))           xor (x9(1) and x9(8))           xor (x9(7) and x9(8));
  y9(4)            <= (x9(0) and x9(1))           xor (x9(1) and x9(3))           xor x9(4)                       xor (x9(0) and x9(5))           xor
                      (x9(3) and x9(6))           xor (x9(0) and x9(7))           xor (x9(6) and x9(7))           xor (x9(1) and x9(8))           xor
                      (x9(2) and x9(8))           xor (x9(3) and x9(8));
  y9(5)            <= x9(2)                       xor (x9(1) and x9(4))           xor (x9(4) and x9(5))           xor (x9(0) and x9(6))           xor
                      (x9(1) and x9(6))           xor (x9(3) and x9(7))           xor (x9(4) and x9(7))           xor (x9(6) and x9(7))           xor
                      (x9(5) and x9(8))           xor (x9(6) and x9(8))           xor (x9(7) and x9(8))           xor '1';
  y9(6)            <= x9(0)                       xor (x9(2) and x9(3))           xor (x9(1) and x9(5))           xor (x9(2) and x9(5))           xor
                      (x9(4) and x9(5))           xor (x9(3) and x9(6))           xor (x9(4) and x9(6))           xor (x9(5) and x9(6))           xor
                      x9(7)                       xor (x9(1) and x9(8))           xor (x9(3) and x9(8))           xor (x9(5) and x9(8))           xor
                      (x9(7) and x9(8));
  y9(7)            <= (x9(0) and x9(1))           xor (x9(0) and x9(2))           xor (x9(1) and x9(2))           xor x9(3)                       xor
                      (x9(0) and x9(3))           xor (x9(2) and x9(3))           xor (x9(4) and x9(5))           xor (x9(2) and x9(6))           xor
                      (x9(3) and x9(6))           xor (x9(2) and x9(7))           xor (x9(5) and x9(7))           xor x9(8)                       xor
                      '1';
  y9(8)            <= (x9(0) and x9(1))           xor x9(2)                       xor (x9(1) and x9(2))           xor (x9(3) and x9(4))           xor
                      (x9(1) and x9(5))           xor (x9(2) and x9(5))           xor (x9(1) and x9(6))           xor (x9(4) and x9(6))           xor
                      x9(7)                       xor (x9(2) and x9(8))           xor (x9(3) and x9(8));
--S9
end phy;
