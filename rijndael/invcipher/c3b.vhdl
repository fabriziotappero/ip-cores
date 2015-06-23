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

entity c3b is
  port (
  cnt : out bit_vector (02 downto 00);
  clk : in  bit;
  rst : in  bit
  );
end c3b;

architecture phy of c3b is
  signal sum : bit_vector (02 downto 00) := B"111"; -- sum
  signal cr  : bit_vector (02 downto 00) := B"000"; -- carry
  begin
    cr(0)            <= '0'; -- LSB always zero
    cr(02 downto 01) <= ( ((sum(01 downto 00) and B"01") or (sum(01 downto 00) and cr(01 downto 00))) or (B"01" and cr(01 downto 00)) );
    process (clk)
    begin
      if (clk = '1' and clk'event) then
        if (rst = '1') then
          sum <= B"000"; -- we start counting from 0
        else
          sum <= ((sum xor B"001") xor cr); -- sum = ((addend xor augend) xor carry)
        end if;
      end if;
    end process;
    cnt <= sum;
end phy;
