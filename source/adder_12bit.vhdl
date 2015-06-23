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

entity adder_12bit is
   port (
      addend_12bit  : in  bit_vector (11 downto 0);
      augend_12bit  : in  bit_vector (11 downto 0);
      adder12_output: out bit_vector (12 downto 0)  -- 13bit output
      );
end adder_12bit;

architecture structural of adder_12bit is

   component fulladder
      port (
      addend        : in   bit;
      augend        : in   bit;
      carry_in      : in   bit;
      sum           : out  bit;
      carry         : out  bit
      );
   end component;

-- internal signal
signal over12 : bit;
signal adder12_output_int : bit_vector (11 downto 0);
signal c00 : bit;
signal c01 : bit;
signal c02 : bit;
signal c03 : bit;
signal c04 : bit;
signal c05 : bit;
signal c06 : bit;
signal c07 : bit;
signal c08 : bit;
signal c09 : bit;
signal c10 : bit;
signal c11 : bit;
signal c12 : bit;
signal ov  : bit;

begin

c00 			<= '0';
over12                  <= (addend_12bit (11) xor augend_12bit (11));
ov                      <= ((adder12_output_int (11) and over12) or 
			   (c12 and (not (over12))));
adder12_output(11 downto 00) <= adder12_output_int;
adder12_output(12)           <= ov;

fa11 : fulladder
   port map (
      addend     => addend_12bit(11),
      augend     => augend_12bit(11),
      carry_in   => c11,
      sum        => adder12_output_int(11),
      carry      => c12
      );

fa10 : fulladder
   port map (
      addend     => addend_12bit(10),
      augend     => augend_12bit(10),
      carry_in   => c10,
      sum        => adder12_output_int(10),
      carry      => c11
      );

fa09 : fulladder
   port map (
      addend     => addend_12bit(09),
      augend     => augend_12bit(09),
      carry_in   => c09,
      sum        => adder12_output_int(09),
      carry      => c10
      );

fa08 : fulladder
   port map (
      addend     => addend_12bit(08),
      augend     => augend_12bit(08),
      carry_in   => c08,
      sum        => adder12_output_int(08),
      carry      => c09
      );

fa07 : fulladder
   port map (
      addend     => addend_12bit(07),
      augend     => augend_12bit(07),
      carry_in   => c07,
      sum        => adder12_output_int(07),
      carry      => c08
      );

fa06 : fulladder
   port map (
      addend     => addend_12bit(06),
      augend     => augend_12bit(06),
      carry_in   => c06,
      sum        => adder12_output_int(06),
      carry      => c07
      );

fa05 : fulladder
   port map (
      addend     => addend_12bit(05),
      augend     => augend_12bit(05),
      carry_in   => c05,
      sum        => adder12_output_int(05),
      carry      => c06
      );

fa04 : fulladder
   port map (
      addend     => addend_12bit(04),
      augend     => augend_12bit(04),
      carry_in   => c04,
      sum        => adder12_output_int(04),
      carry      => c05
      );

fa03 : fulladder
   port map (
      addend     => addend_12bit(03),
      augend     => augend_12bit(03),
      carry_in   => c03,
      sum        => adder12_output_int(03),
      carry      => c04
      );

fa02 : fulladder
   port map (
      addend     => addend_12bit(02),
      augend     => augend_12bit(02),
      carry_in   => c02,
      sum        => adder12_output_int(02),
      carry      => c03
      );

fa01 : fulladder
   port map (
      addend     => addend_12bit(01),
      augend     => augend_12bit(01),
      carry_in   => c01,
      sum        => adder12_output_int(01),
      carry      => c02
      );

fa00 : fulladder
   port map (
      addend     => addend_12bit(00),
      augend     => augend_12bit(00),
      carry_in   => c00,
      sum        => adder12_output_int(00),
      carry      => c01
      );

end structural;
