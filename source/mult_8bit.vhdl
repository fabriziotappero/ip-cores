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

entity mult_8bit is
   port (
   mult_01     : in  bit_vector (07 downto 0);
   mult_02     : in  bit_vector (07 downto 0);
   result_mult : out bit_vector (15 downto 0)
   );
end mult_8bit;

architecture structural of mult_8bit is
   component adder_16bit
     port (
     addend_16bit   : in  bit_vector (15 downto 0);
     augend_16bit   : in  bit_vector (15 downto 0);
     adder16_output : out bit_vector (16 downto 0)
     );
   end component;
   
   component adder_16bit_u
     port (
     addend_16bit   : in  bit_vector (15 downto 0);
     augend_16bit   : in  bit_vector (15 downto 0);
     adder16_output : out bit_vector (15 downto 0)
     );
   end component;
   
   component adder_15bit
     port (
     addend_15bit   : in  bit_vector (14 downto 0);
     augend_15bit   : in  bit_vector (14 downto 0);
     adder15_output : out bit_vector (15 downto 0)
     );
   end component;
   
   component adder_14bit
     port (
     addend_14bit   : in  bit_vector (13 downto 0);
     augend_14bit   : in  bit_vector (13 downto 0);
     adder14_output : out bit_vector (14 downto 0)
     );
   end component;
   
   component adder_13bit
     port (
     addend_13bit   : in  bit_vector (12 downto 0);
     augend_13bit   : in  bit_vector (12 downto 0);
     adder13_output : out bit_vector (13 downto 0)
     );
   end component;
   
   component adder_12bit
     port (
     addend_12bit   : in  bit_vector (11 downto 0);
     augend_12bit   : in  bit_vector (11 downto 0);
     adder12_output : out bit_vector (12 downto 0)
     );
   end component;
   
   component adder_11bit
     port (
     addend_11bit   : in  bit_vector (10 downto 0);
     augend_11bit   : in  bit_vector (10 downto 0);
     adder11_output : out bit_vector (11 downto 0)
     );
   end component;
   
   component adder_10bit
     port (
     addend_10bit   : in  bit_vector (09 downto 0);
     augend_10bit   : in  bit_vector (09 downto 0);
     adder10_output : out bit_vector (10 downto 0)
     );
   end component;
   
   component adder_09bit
     port (
     addend_09bit   : in  bit_vector (08 downto 0);
     augend_09bit   : in  bit_vector (08 downto 0);
     adder09_output : out bit_vector (09 downto 0)
     );
   end component;
   
   signal input_phase    : bit_vector (07 downto 0);
   signal signal_nco     : bit_vector (07 downto 0);
   
   signal sum_part01     : bit_vector (08 downto 0);
   signal sum_part01_z   : bit_vector (08 downto 0);
   signal sum_part02     : bit_vector (09 downto 0);
   signal sum_part03     : bit_vector (10 downto 0);
   signal sum_part04     : bit_vector (11 downto 0);
   signal sum_part05     : bit_vector (12 downto 0);
   signal sum_part06     : bit_vector (13 downto 0);
   signal sum_part07     : bit_vector (14 downto 0);
   signal sum_part08_t   : bit_vector (15 downto 0);
   signal sum_part08_o   : bit_vector (15 downto 0);
   signal sum_part08_a   : bit_vector (15 downto 0);
   signal sum_part08     : bit_vector (15 downto 0);

   signal adder_stage_01 : bit_vector (09 downto 0);
   signal adder_stage_02 : bit_vector (10 downto 0);
   signal adder_stage_03 : bit_vector (11 downto 0);
   signal adder_stage_04 : bit_vector (12 downto 0);
   signal adder_stage_05 : bit_vector (13 downto 0);
   signal adder_stage_06 : bit_vector (14 downto 0);
   signal adder_stage_07 : bit_vector (15 downto 0);
   signal adder_stage_08 : bit_vector (16 downto 0);

   begin

   sum_part01_z (00) <= '0';
   sum_part01_z (01) <= '0';
   sum_part01_z (02) <= '0';
   sum_part01_z (03) <= '0';
   sum_part01_z (04) <= '0';
   sum_part01_z (05) <= '0';
   sum_part01_z (06) <= '0';
   sum_part01_z (07) <= '0';
   sum_part01_z (08) <= '0';
   
   sum_part01(00) <= signal_nco(0) and input_phase(0);
   sum_part01(01) <= signal_nco(0) and input_phase(1);
   sum_part01(02) <= signal_nco(0) and input_phase(2);
   sum_part01(03) <= signal_nco(0) and input_phase(3);
   sum_part01(04) <= signal_nco(0) and input_phase(4);
   sum_part01(05) <= signal_nco(0) and input_phase(5);
   sum_part01(06) <= signal_nco(0) and input_phase(6);
   sum_part01(07) <= signal_nco(0) and input_phase(7);
   sum_part01(08) <= signal_nco(0) and input_phase(7);
   
   sum_part02(00) <= '0';
   sum_part02(01) <= signal_nco(1) and input_phase(0);
   sum_part02(02) <= signal_nco(1) and input_phase(1);
   sum_part02(03) <= signal_nco(1) and input_phase(2);
   sum_part02(04) <= signal_nco(1) and input_phase(3);
   sum_part02(05) <= signal_nco(1) and input_phase(4);
   sum_part02(06) <= signal_nco(1) and input_phase(5);
   sum_part02(07) <= signal_nco(1) and input_phase(6);
   sum_part02(08) <= signal_nco(1) and input_phase(7);
   sum_part02(09) <= signal_nco(1) and input_phase(7);
   
   sum_part03(00) <= '0';
   sum_part03(01) <= '0';
   sum_part03(02) <= signal_nco(2) and input_phase(0);
   sum_part03(03) <= signal_nco(2) and input_phase(1);
   sum_part03(04) <= signal_nco(2) and input_phase(2);
   sum_part03(05) <= signal_nco(2) and input_phase(3);
   sum_part03(06) <= signal_nco(2) and input_phase(4);
   sum_part03(07) <= signal_nco(2) and input_phase(5);
   sum_part03(08) <= signal_nco(2) and input_phase(6);
   sum_part03(09) <= signal_nco(2) and input_phase(7);
   sum_part03(10) <= signal_nco(2) and input_phase(7);
   
   sum_part04(00) <= '0';
   sum_part04(01) <= '0';
   sum_part04(02) <= '0';
   sum_part04(03) <= signal_nco(3) and input_phase(0);
   sum_part04(04) <= signal_nco(3) and input_phase(1);
   sum_part04(05) <= signal_nco(3) and input_phase(2);
   sum_part04(06) <= signal_nco(3) and input_phase(3);
   sum_part04(07) <= signal_nco(3) and input_phase(4);
   sum_part04(08) <= signal_nco(3) and input_phase(5);
   sum_part04(09) <= signal_nco(3) and input_phase(6);
   sum_part04(10) <= signal_nco(3) and input_phase(7);
   sum_part04(11) <= signal_nco(3) and input_phase(7);
   
   sum_part05(00) <= '0';
   sum_part05(01) <= '0';
   sum_part05(02) <= '0';
   sum_part05(03) <= '0';
   sum_part05(04) <= signal_nco(4) and input_phase(0);
   sum_part05(05) <= signal_nco(4) and input_phase(1);
   sum_part05(06) <= signal_nco(4) and input_phase(2);
   sum_part05(07) <= signal_nco(4) and input_phase(3);
   sum_part05(08) <= signal_nco(4) and input_phase(4);
   sum_part05(09) <= signal_nco(4) and input_phase(5);
   sum_part05(10) <= signal_nco(4) and input_phase(6);
   sum_part05(11) <= signal_nco(4) and input_phase(7);
   sum_part05(12) <= signal_nco(4) and input_phase(7);
   
   sum_part06(00) <= '0';
   sum_part06(01) <= '0';
   sum_part06(02) <= '0';
   sum_part06(03) <= '0';
   sum_part06(04) <= '0';
   sum_part06(05) <= signal_nco(5) and input_phase(0);
   sum_part06(06) <= signal_nco(5) and input_phase(1);
   sum_part06(07) <= signal_nco(5) and input_phase(2);
   sum_part06(08) <= signal_nco(5) and input_phase(3);
   sum_part06(09) <= signal_nco(5) and input_phase(4);
   sum_part06(10) <= signal_nco(5) and input_phase(5);
   sum_part06(11) <= signal_nco(5) and input_phase(6);
   sum_part06(12) <= signal_nco(5) and input_phase(7);
   sum_part06(13) <= signal_nco(5) and input_phase(7);
   
   sum_part07(00) <= '0';
   sum_part07(01) <= '0';
   sum_part07(02) <= '0';
   sum_part07(03) <= '0';
   sum_part07(04) <= '0';
   sum_part07(05) <= '0';
   sum_part07(06) <= signal_nco(6) and input_phase(0);
   sum_part07(07) <= signal_nco(6) and input_phase(1);
   sum_part07(08) <= signal_nco(6) and input_phase(2);
   sum_part07(09) <= signal_nco(6) and input_phase(3);
   sum_part07(10) <= signal_nco(6) and input_phase(4);
   sum_part07(11) <= signal_nco(6) and input_phase(5);
   sum_part07(12) <= signal_nco(6) and input_phase(6);
   sum_part07(13) <= signal_nco(6) and input_phase(7);
   sum_part07(14) <= signal_nco(6) and input_phase(7);
   
   sum_part08(00) <= '0';
   sum_part08(01) <= '0';
   sum_part08(02) <= '0';
   sum_part08(03) <= '0';
   sum_part08(04) <= '0';
   sum_part08(05) <= '0';
   sum_part08(06) <= '0';
   sum_part08(07) <= signal_nco(7) and input_phase(0);
   sum_part08(08) <= signal_nco(7) and input_phase(1);
   sum_part08(09) <= signal_nco(7) and input_phase(2);
   sum_part08(10) <= signal_nco(7) and input_phase(3);
   sum_part08(11) <= signal_nco(7) and input_phase(4);
   sum_part08(12) <= signal_nco(7) and input_phase(5);
   sum_part08(13) <= signal_nco(7) and input_phase(6);
   sum_part08(14) <= signal_nco(7) and input_phase(7);
   sum_part08(15) <= signal_nco(7) and input_phase(7);

   sum_part08_t (00) <= (not (sum_part08 (00)));
   sum_part08_t (01) <= (not (sum_part08 (01)));
   sum_part08_t (02) <= (not (sum_part08 (02)));
   sum_part08_t (03) <= (not (sum_part08 (03)));
   sum_part08_t (04) <= (not (sum_part08 (04)));
   sum_part08_t (05) <= (not (sum_part08 (05)));
   sum_part08_t (06) <= (not (sum_part08 (06)));
   sum_part08_t (07) <= (not (sum_part08 (07)));
   sum_part08_t (08) <= (not (sum_part08 (08)));
   sum_part08_t (09) <= (not (sum_part08 (09)));
   sum_part08_t (10) <= (not (sum_part08 (10)));
   sum_part08_t (11) <= (not (sum_part08 (11)));
   sum_part08_t (12) <= (not (sum_part08 (12)));
   sum_part08_t (13) <= (not (sum_part08 (13)));
   sum_part08_t (14) <= (not (sum_part08 (14)));
   sum_part08_t (15) <= (not (sum_part08 (15)));

   sum_part08_o (00) <= '1';
   sum_part08_o (01) <= '0';
   sum_part08_o (02) <= '0';
   sum_part08_o (03) <= '0';
   sum_part08_o (04) <= '0';
   sum_part08_o (05) <= '0';
   sum_part08_o (06) <= '0';
   sum_part08_o (07) <= '0';
   sum_part08_o (08) <= '0';
   sum_part08_o (09) <= '0';
   sum_part08_o (10) <= '0';
   sum_part08_o (11) <= '0';
   sum_part08_o (12) <= '0';
   sum_part08_o (13) <= '0';
   sum_part08_o (14) <= '0';
   sum_part08_o (15) <= '0';

stage_01 : adder_09bit
   port map (
   addend_09bit   (08 downto 0)  => sum_part01_z,
   augend_09bit   (08 downto 0)  => sum_part01,
   adder09_output (09 downto 0)  => adder_stage_01
   );

stage_02 : adder_10bit
   port map (
   addend_10bit   (09 downto 0)  => adder_stage_01,
   augend_10bit   (09 downto 0)  => sum_part02,
   adder10_output (10 downto 0)  => adder_stage_02
   );

stage_03 : adder_11bit
   port map (
   addend_11bit   (10 downto 0)  => adder_stage_02,
   augend_11bit   (10 downto 0)  => sum_part03,
   adder11_output (11 downto 0)  => adder_stage_03
   );

stage_04 : adder_12bit
   port map (
   addend_12bit   (11 downto 0)  => adder_stage_03,
   augend_12bit   (11 downto 0)  => sum_part04,
   adder12_output (12 downto 0)  => adder_stage_04
   );

stage_05 : adder_13bit
   port map (
   addend_13bit   (12 downto 0)  => adder_stage_04,
   augend_13bit   (12 downto 0)  => sum_part05,
   adder13_output (13 downto 0)  => adder_stage_05
   );

stage_06 : adder_14bit
   port map (
   addend_14bit   (13 downto 0)  => adder_stage_05,
   augend_14bit   (13 downto 0)  => sum_part06,
   adder14_output (14 downto 0)  => adder_stage_06
   );

stage_07 : adder_15bit
   port map (
   addend_15bit   (14 downto 0)  => adder_stage_06,
   augend_15bit   (14 downto 0)  => sum_part07,
   adder15_output (15 downto 0)  => adder_stage_07
   );

stage_08_a : adder_16bit_u
   port map (
   addend_16bit   (15 downto 0)  => sum_part08_t,
   augend_16bit   (15 downto 0)  => sum_part08_o,
   adder16_output (15 downto 0)  => sum_part08_a
   );

stage_08 : adder_16bit
   port map (
   addend_16bit   (15 downto 0)  => adder_stage_07,
   augend_16bit   (15 downto 0)  => sum_part08_a,
   adder16_output (16 downto 0)  => adder_stage_08
   );

   input_phase <= mult_01;
   signal_nco  <= mult_02;
   result_mult <= adder_stage_08(15 downto 0);

end structural;
