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

entity phase_detector is
   port (
   clock        : in  bit;
   signal_input : in  bit_vector (07 downto 0);
   signal_nco   : in  bit_vector (07 downto 0);
   phase_output : out bit_vector (07 downto 0)
   );
end phase_detector;

architecture structural of phase_detector is
   component mult_8bit
   port (
   mult_01    : in  bit_vector (07 downto 00);
   mult_02    : in  bit_vector (07 downto 00);
   result_mult: out bit_vector (15 downto 00)
   );
   end component;
   
   signal output_mult  : bit_vector (15 downto 0);

   begin

phase_mult: mult_8bit
   port map (
   mult_01     (07 downto 0)  => signal_input,
   mult_02     (07 downto 0)  => signal_nco,
   result_mult (15 downto 0)  => output_mult
   );

   process (clock)
   
   begin

   if ((clock = '1') and clock'event) then

	phase_output <= output_mult(15 downto 8);

   end if;

   end process;
   
end structural;
