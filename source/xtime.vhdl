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

package xtime_pkg is

  function xtime_2 ( b : std_logic_vector ) return std_logic_vector;
  function xtime_4 ( c : std_logic_vector ) return std_logic_vector;
  function xtime_8 ( d : std_logic_vector ) return std_logic_vector;

end xtime_pkg;

package body xtime_pkg is

  function xtime_2   ( b : std_logic_vector ) return std_logic_vector is
     variable xtime_2_v  : std_logic_vector (07 downto 00) := ( B"0000_0000" );
     begin
        xtime_2_v := (  b(6 downto 4)                     -- 7,6,5
                     & (b(3 downto 2) xor (b(7) & b(7)))  -- 4,3
                     &  b(1)                              -- 2
                     & (b(0) xor b(7))                    -- 1
                     &  b(7));                            -- 0
     return xtime_2_v;
  end xtime_2;

  function xtime_4  ( c : std_logic_vector ) return std_logic_vector is
     variable xtime_4_v : std_logic_vector (07 downto 00) := ( B"0000_0000" );
     begin
        xtime_4_v := (  c(5)                             -- 7
                     &  c(4)                             -- 6
                     & (c(3) xor c(7))                   -- 5
                     & (c(2) xor c(7) xor c(6))          -- 4
                     & (c(1) xor c(6))                   -- 3
                     & (c(0) xor c(7))                   -- 2
                     & (c(7) xor c(6))                   -- 1
                     &  c(6));                           --
     return xtime_4_v;
  end xtime_4;

  function xtime_8  ( d : std_logic_vector ) return std_logic_vector is
     variable xtime_8_v : std_logic_vector (07 downto 00) := ( B"0000_0000" );
     begin
        xtime_8_v := (  d(4)                            -- 7
                     & (d(3) xor d(7))                  -- 6
                     & (d(2) xor d(7) xor d(6))         -- 5
                     & (d(1) xor d(6) xor d(5))         -- 4
                     & (d(0) xor d(7) xor d(5))         -- 3
                     & (d(7) xor d(6))                  -- 2
                     & (d(6) xor d(5))                  -- 1
                     &  d(5));                          -- 0
     return xtime_8_v;
  end xtime_8;

end xtime_pkg;
