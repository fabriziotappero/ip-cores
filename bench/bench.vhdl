-- ------------------------------------------------------------------------
-- Copyright (C) 2004 Arif Endro Nugroho
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bench is
port (
    clock               : in  bit;
    reset               : in  bit;
    output_fm           : out bit_vector (11 downto 0);
    output_fmTri        : out bit_vector (11 downto 0)
    );
end bench;

architecture structural of bench is
  component fm
  port (
    CLK              : in  bit;
    RESET            : in  bit;
    FMIN             : in  bit_vector (07 downto 0);
    DMOUT            : out bit_vector (11 downto 0)
    );
  end component;
  
  component input_fm
  port (
    clock            : in  bit;
    clear            : in  bit;
    test_signal_fm   : out bit_vector (07 downto 0);
    test_signal_fmTri: out bit_vector (07 downto 0)
    );
  end component;

  signal test_signal_fm : bit_vector (07 downto 0);
  signal test_signal_fmTri : bit_vector (07 downto 0);

  begin

 myinput : input_fm
   port map (
    clock            => clock,
    clear            => reset,
    test_signal_fm   => test_signal_fm,
    test_signal_fmTri=> test_signal_fmTri
    );

  myfm : fm
   port map (
    CLK                  => clock,
    RESET                => reset,
    FMIN                 => test_signal_fm,
    DMOUT (11 downto 0)  => output_fm
    );

  myfmTri : fm
   port map (
    CLK                  => clock,
    RESET                => reset,
    FMIN                 => test_signal_fmTri,
    DMOUT (11 downto 0)  => output_fmTri
    );


end structural;
