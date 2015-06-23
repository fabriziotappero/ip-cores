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

library IEEE;
use IEEE.std_logic_1164.all;

entity product_code is
   port (
     clock   : in  bit; 
     start   : in  bit;
     rxin    : in  bit_vector (07 downto 00);
     y0d     : out bit;
     y1d     : out bit;
     y2d     : out bit;
     y3d     : out bit
     );
end product_code;

architecture structural of product_code is

   component ser2par8bit
      port (
         clock : in  bit;
         clear : in  bit;
         start : in  bit;
         rxin  : in  bit_vector (07 downto 00);
         y0    : out bit_vector (07 downto 00);
         y1    : out bit_vector (07 downto 00);
         y2    : out bit_vector (07 downto 00);
         y3    : out bit_vector (07 downto 00);
         r0    : out bit_vector (07 downto 00);
         r1    : out bit_vector (07 downto 00);
         c0    : out bit_vector (07 downto 00);
         c1    : out bit_vector (07 downto 00)
	 );
   end component;

   component ext_val
      port (
         ext_a_i : in  bit_vector (07 downto 00);
         ext_b_i : in  bit_vector (07 downto 00);
         ext_r_o : out bit_vector (07 downto 00)
	 );
   end component;

   component adder_08bit
      port (
         addend_08bit   : in  bit_vector (07 downto 00);
         augend_08bit   : in  bit_vector (07 downto 00);
         adder08_output : out bit_vector (08 downto 00)
	 );
   end component;

   signal y0e : bit_vector (07 downto 00);
   signal y1e : bit_vector (07 downto 00);
   signal y2e : bit_vector (07 downto 00);
   signal y3e : bit_vector (07 downto 00);

   signal y0 : bit_vector (07 downto 00);
   signal y1 : bit_vector (07 downto 00);
   signal y2 : bit_vector (07 downto 00);
   signal y3 : bit_vector (07 downto 00);
   signal r0 : bit_vector (07 downto 00);
   signal r1 : bit_vector (07 downto 00);
   signal c0 : bit_vector (07 downto 00);
   signal c1 : bit_vector (07 downto 00);

   signal ext_b_c_0_b : bit_vector (08 downto 00);
   signal ext_b_c_1_b : bit_vector (08 downto 00);
   signal ext_b_c_2_b : bit_vector (08 downto 00);
   signal ext_b_c_3_b : bit_vector (08 downto 00);

   signal augend_sum_c_0 : bit_vector (07 downto 00);
   signal augend_sum_c_1 : bit_vector (07 downto 00);
   signal augend_sum_c_2 : bit_vector (07 downto 00);
   signal augend_sum_c_3 : bit_vector (07 downto 00);

   signal ext_r_r_0 : bit_vector (07 downto 00);
   signal ext_r_r_1 : bit_vector (07 downto 00);
   signal ext_r_r_2 : bit_vector (07 downto 00);
   signal ext_r_r_3 : bit_vector (07 downto 00);

   signal ext_b_r_0_b : bit_vector (08 downto 00);
   signal ext_b_r_1_b : bit_vector (08 downto 00);
   signal ext_b_r_2_b : bit_vector (08 downto 00);
   signal ext_b_r_3_b : bit_vector (08 downto 00);

   signal ext_b_r_0 : bit_vector (07 downto 00);
   signal ext_b_r_1 : bit_vector (07 downto 00);
   signal ext_b_r_2 : bit_vector (07 downto 00);
   signal ext_b_r_3 : bit_vector (07 downto 00);

   signal ext_r_c_0 : bit_vector (07 downto 00);
   signal ext_r_c_1 : bit_vector (07 downto 00);
   signal ext_r_c_2 : bit_vector (07 downto 00);
   signal ext_r_c_3 : bit_vector (07 downto 00);

   signal ext_b_c_0 : bit_vector (07 downto 00);
   signal ext_b_c_1 : bit_vector (07 downto 00);
   signal ext_b_c_2 : bit_vector (07 downto 00);
   signal ext_b_c_3 : bit_vector (07 downto 00);

   signal y0p_b : bit_vector (08 downto 00);
   signal y1p_b : bit_vector (08 downto 00);
   signal y2p_b : bit_vector (08 downto 00);
   signal y3p_b : bit_vector (08 downto 00);

   signal y0p : bit;
   signal y1p : bit;
   signal y2p : bit;
   signal y3p : bit;

   constant gnd : bit := '0';

begin

ext_b_c_0 (07 downto 00) <= ext_b_c_0_b (07 downto 00);
ext_b_c_1 (07 downto 00) <= ext_b_c_1_b (07 downto 00);
ext_b_c_2 (07 downto 00) <= ext_b_c_2_b (07 downto 00);
ext_b_c_3 (07 downto 00) <= ext_b_c_3_b (07 downto 00);

ext_b_r_0 (07 downto 00) <= ext_b_r_0_b (07 downto 00);
ext_b_r_1 (07 downto 00) <= ext_b_r_1_b (07 downto 00);
ext_b_r_2 (07 downto 00) <= ext_b_r_2_b (07 downto 00);
ext_b_r_3 (07 downto 00) <= ext_b_r_3_b (07 downto 00);

first : ser2par8bit
   port map (
      clock => clock,
      clear => gnd,
      start => start,
      rxin  => rxin,
      y0    => y0,
      y1    => y1,
      y2    => y2,
      y3    => y3,
      r0    => r0,
      r1    => r1,
      c0    => c0,
      c1    => c1
      );

sum_r_0 : adder_08bit
   port map (
      addend_08bit   => y0,
      augend_08bit   => y0e,
      adder08_output => ext_b_r_1_b
      );

sum_r_1 : adder_08bit
   port map (
      addend_08bit   => y1,
      augend_08bit   => y1e,
      adder08_output => ext_b_r_0_b
      );

sum_r_2 : adder_08bit
   port map (
      addend_08bit   => y2,
      augend_08bit   => y2e,
      adder08_output => ext_b_r_3_b
      );

sum_r_3 : adder_08bit
   port map (
      addend_08bit   => y3,
      augend_08bit   => y3e,
      adder08_output => ext_b_r_2_b
      );

sum_c_0 : adder_08bit
   port map (
      addend_08bit   => y0,
      augend_08bit   => augend_sum_c_0,
      adder08_output => ext_b_c_2_b
      );

sum_c_1 : adder_08bit
   port map (
      addend_08bit   => y1,
      augend_08bit   => augend_sum_c_1,
      adder08_output => ext_b_c_3_b
      );

sum_c_2 : adder_08bit
   port map (
      addend_08bit   => y2,
      augend_08bit   => augend_sum_c_2,
      adder08_output => ext_b_c_0_b
      );

sum_c_3 : adder_08bit
   port map (
      addend_08bit   => y3,
      augend_08bit   => augend_sum_c_3,
      adder08_output => ext_b_c_1_b
      );

sum_p_0 : adder_08bit
   port map (
      addend_08bit   => ext_b_r_1,
      augend_08bit   => ext_r_r_0,
      adder08_output => y0p_b
      );

sum_p_1 : adder_08bit
   port map (
      addend_08bit   => ext_b_r_0,
      augend_08bit   => ext_r_r_1,
      adder08_output => y1p_b
      );

sum_p_2 : adder_08bit
   port map (
      addend_08bit   => ext_b_r_3,
      augend_08bit   => ext_r_r_2,
      adder08_output => y2p_b
      );

sum_p_3 : adder_08bit
   port map (
      addend_08bit   => ext_b_r_2,
      augend_08bit   => ext_r_r_3,
      adder08_output => y3p_b
      );

row0 : ext_val
   port map (
      ext_a_i => r0,
      ext_b_i => ext_b_r_0,
      ext_r_o => ext_r_r_0
      );

row1 : ext_val
   port map (
      ext_a_i => r0,
      ext_b_i => ext_b_r_1,
      ext_r_o => ext_r_r_1
      );

row2 : ext_val
   port map (
      ext_a_i => r1,
      ext_b_i => ext_b_r_2,
      ext_r_o => ext_r_r_2
      );

row3 : ext_val
   port map (
      ext_a_i => r1,
      ext_b_i => ext_b_r_3,
      ext_r_o => ext_r_r_3
      );

col0 : ext_val
   port map (
      ext_a_i => c0,
      ext_b_i => ext_b_c_0,
      ext_r_o => ext_r_c_0
      );

col1 : ext_val
   port map (
      ext_a_i => c1,
      ext_b_i => ext_b_c_1,
      ext_r_o => ext_r_c_1
      );

col2 : ext_val
   port map (
      ext_a_i => c0,
      ext_b_i => ext_b_c_2,
      ext_r_o => ext_r_c_2
      );

col3 : ext_val
   port map (
      ext_a_i => c1,
      ext_b_i => ext_b_c_3,
      ext_r_o => ext_r_c_3
      );

process (start)
begin
   if (start = '1' and start'event) then

      y0p <= y0p_b (08);
      y1p <= y1p_b (08);
      y2p <= y2p_b (08);
      y3p <= y3p_b (08);

   end if;
end process;

process (start)
begin
   if (start = '0' and start'event) then

      y0d <= y0p;
      y1d <= y1p;
      y2d <= y2p;
      y3d <= y3p;

   end if;
end process;

process (clock, start)
begin

   if (clock = '0' and clock'event) then

      if (start = '1') then
         y0e <= ( others => '0' );
         y1e <= ( others => '0' );
         y2e <= ( others => '0' );
         y3e <= ( others => '0' );

         augend_sum_c_0 <= ( others => '0' );
         augend_sum_c_1 <= ( others => '0' );
         augend_sum_c_2 <= ( others => '0' );
         augend_sum_c_3 <= ( others => '0' );
      else
         y0e <= ext_r_c_0;
         y1e <= ext_r_c_1;
         y2e <= ext_r_c_2;
         y3e <= ext_r_c_3;
	 
         augend_sum_c_0 <= ext_r_r_0;
         augend_sum_c_1 <= ext_r_r_1;
         augend_sum_c_2 <= ext_r_r_2;
         augend_sum_c_3 <= ext_r_r_3;
      end if;

   end if;
end process;

end structural;
