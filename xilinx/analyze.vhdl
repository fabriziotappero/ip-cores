-- ------------------------------------------------------------------------
-- Copyright (C) 2005 Arif Endro Nugroho
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity analyze is
   port (
      clear   : in  bit;
      start   : in  bit;
      match   : in  bit_vector (3 downto 0);
      col_0   : out integer;
      col_1   : out integer;
      col_2   : out integer;
      col_3   : out integer;
      result  : out integer
      );
end analyze;

architecture analyzer of analyze is

signal col_0_int  : integer range 0 to 19999;
signal col_1_int  : integer range 0 to 19999;
signal col_2_int  : integer range 0 to 19999;
signal col_3_int  : integer range 0 to 19999;
signal result_int : integer range 0 to 19999;

begin

process (start,clear)
begin

if (clear = '1') then
   col_0_int  <= 0;
   col_1_int  <= 0;
   col_2_int  <= 0;
   col_3_int  <= 0;
   result_int <= 0;
-- sample at rising edge then show the result at falling edge.
elsif (start = '1' and start'event) then
   if (match(0) = '0') then
      if (col_0_int < 19999) then
         col_0_int <= col_0_int + 1;
      else
         col_0_int <= 0;
      end if;
   end if;
   if (match(1) = '0') then
      if (col_1_int < 19999) then
         col_1_int <= col_1_int + 1;
      else
         col_1_int <= 0;
      end if;
   end if;
   if (match(2) = '0') then
      if (col_2_int < 19999) then
         col_2_int <= col_2_int + 1;
      else
         col_2_int <= 0;
      end if;
   end if;
   if (match(3) = '0') then
      if (col_3_int < 19999) then
         col_3_int <= col_3_int + 1;
      else
         col_3_int <= 0;
      end if;
   end if;
end if;

result_int <= col_0_int + col_1_int + col_2_int + col_3_int;

end process;

result   <= result_int;
col_0    <= col_0_int;
col_1    <= col_1_int;
col_2    <= col_2_int;
col_3    <= col_3_int;

end analyzer;
