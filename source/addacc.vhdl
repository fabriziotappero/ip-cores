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
use IEEE.STD_LOGIC_1164.all;

entity addacc is
   port (
    clock  : in  bit;
    acc    : in  bit_vector (17 downto 0);
    result : out bit_vector (17 downto 0);
    offset : in  bit_vector (17 downto 0)
    );
end addacc;

architecture structural of addacc is
   component adder_18bit
      port (
      addend_18bit   : in  bit_vector (17 downto 0);
      augend_18bit   : in  bit_vector (17 downto 0);
      adder18_output : out bit_vector (17 downto 0)
      );
   end component;

signal result_adder01     : bit_vector (17 downto 0);
signal result_adder02     : bit_vector (17 downto 0);
signal result_adder02_reg : bit_vector (17 downto 0);

begin
adder01 : adder_18bit
  port map (
  addend_18bit     => offset,
  augend_18bit     => acc,
  adder18_output   => result_adder01
  );
adder02 : adder_18bit
  port map (
  addend_18bit     => result_adder01,
  augend_18bit     => result_adder02_reg,
  adder18_output   => result_adder02
  );
  process (clock)
  begin
	  if ((clock = '1') and clock'event) then
		  result_adder02_reg <= result_adder02;
		  result <= result_adder02;
	  end if;
  end process;
end structural; 
