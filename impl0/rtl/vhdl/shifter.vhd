--------------------------------------------------------------
-- shifter.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: combinational shifter 
--
-- dependency: none
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--Opsel-----|--shifter Operation--
--000-------|--sll----------------
--001-------|--slr----------------
--010-------|--sal----------------
--011-------|--sar----------------
--100-------|--rol----------------
--101-------|--ror----------------
--110-------|--rcl----------------
--111-------|--rcr----------------

entity shifter is
   port
   (
      a : in std_logic_vector(15 downto 0);
      b : in std_logic_vector(3 downto 0);
      c_in : in std_logic;
      opsel : in std_logic_vector(2 downto 0);
      result : out std_logic_vector(15 downto 0);
      c_out : out std_logic;
      ofl_out : out std_logic
   );                             
end shifter;

architecture dataflow of shifter is 
   signal shltemp, shrtemp, saltemp, sartemp, roltemp, 
          rortemp, rcltemp, rcrtemp, carry_result : std_logic_vector(16 downto 0);
begin
   ShiftLogicalLeft: process(a , b, c_in) is
   begin
      case b is
         when "0000" => shltemp <= c_in & a(15 downto 0);
         when "0001" => shltemp <= a(15) & a(14 downto 0) & "0";
         when "0010" => shltemp <= a(14) & a(13 downto 0) & "00";
         when "0011" => shltemp <= a(13) & a(12 downto 0) & "000";
         when "0100" => shltemp <= a(12) & a(11 downto 0) & "0000";
         when "0101" => shltemp <= a(11) & a(10 downto 0) & "00000";
         when "0110" => shltemp <= a(10) & a(09 downto 0) & "000000";
         when "0111" => shltemp <= a(09) & a(08 downto 0) & "0000000";
         when "1000" => shltemp <= a(08) & a(07 downto 0) & "00000000";
         when "1001" => shltemp <= a(07) & a(06 downto 0) & "000000000";
         when "1010" => shltemp <= a(06) & a(05 downto 0) & "0000000000";
         when "1011" => shltemp <= a(05) & a(04 downto 0) & "00000000000";
         when "1100" => shltemp <= a(04) & a(03 downto 0) & "000000000000";
         when "1101" => shltemp <= a(03) & a(02 downto 0) & "0000000000000";
         when "1110" => shltemp <= a(02) & a(01 downto 0) & "00000000000000";
         when "1111" => shltemp <= a(01) & a(00)          & "000000000000000";
         when others => shltemp <= (others => '0');
      end case;
   end process; 
   
   ShiftLogicalRight: process(a, b, c_in) is
   begin
      case b is
         when "0000" => shrtemp <= c_in & a(15 downto 0); 
         when "0001" => shrtemp <= a(00) & "0"               & a(15 downto 01);
         when "0010" => shrtemp <= a(01) & "00"              & a(15 downto 02);
         when "0011" => shrtemp <= a(02) & "000"             & a(15 downto 03);
         when "0100" => shrtemp <= a(03) & "0000"            & a(15 downto 04);
         when "0101" => shrtemp <= a(04) & "00000"           & a(15 downto 05);
         when "0110" => shrtemp <= a(05) & "000000"          & a(15 downto 06);
         when "0111" => shrtemp <= a(06) & "0000000"         & a(15 downto 07);
         when "1000" => shrtemp <= a(07) & "00000000"        & a(15 downto 08);
         when "1001" => shrtemp <= a(08) & "000000000"       & a(15 downto 09);
         when "1010" => shrtemp <= a(09) & "0000000000"      & a(15 downto 10);
         when "1011" => shrtemp <= a(10) & "00000000000"     & a(15 downto 11);
         when "1100" => shrtemp <= a(11) & "000000000000"    & a(15 downto 12);
         when "1101" => shrtemp <= a(12) & "0000000000000"   & a(15 downto 13);
         when "1110" => shrtemp <= a(13) & "00000000000000"  & a(15 downto 14);
         when "1111" => shrtemp <= a(14) & "000000000000000" & a(15);
         when others => shrtemp <= (others => '0');
      end case;
   end process;
   
   ShiftArithmaticLeft: saltemp <= shltemp;
   
   ShiftArithmaticRight: process(a, b, c_in) is
      variable s : std_logic;
   begin
         s := a(15);
      case b is   
         when "0000" => sartemp <= c_in & a(15 downto 0); 
         when "0001" => sartemp <= a(00) & s                                                         & a(15 downto 01);
         when "0010" => sartemp <= a(01) & s & s                                                     & a(15 downto 02);
         when "0011" => sartemp <= a(02) & s & s & s                                                 & a(15 downto 03);
         when "0100" => sartemp <= a(03) & s & s & s & s                                             & a(15 downto 04);
         when "0101" => sartemp <= a(04) & s & s & s & s & s                                         & a(15 downto 05);
         when "0110" => sartemp <= a(05) & s & s & s & s & s & s                                     & a(15 downto 06);
         when "0111" => sartemp <= a(06) & s & s & s & s & s & s & s                                 & a(15 downto 07);
         when "1000" => sartemp <= a(07) & s & s & s & s & s & s & s & s                             & a(15 downto 08);
         when "1001" => sartemp <= a(08) & s & s & s & s & s & s & s & s & s                         & a(15 downto 09);
         when "1010" => sartemp <= a(09) & s & s & s & s & s & s & s & s & s & s                     & a(15 downto 10);
         when "1011" => sartemp <= a(10) & s & s & s & s & s & s & s & s & s & s & s                 & a(15 downto 11);
         when "1100" => sartemp <= a(11) & s & s & s & s & s & s & s & s & s & s & s & s             & a(15 downto 12);
         when "1101" => sartemp <= a(12) & s & s & s & s & s & s & s & s & s & s & s & s & s         & a(15 downto 13);
         when "1110" => sartemp <= a(13) & s & s & s & s & s & s & s & s & s & s & s & s & s & s     & a(15 downto 14);
         when "1111" => sartemp <= a(14) & s & s & s & s & s & s & s & s & s & s & s & s & s & s & s & a(15);
         when others => sartemp <= (others => '0');
      end case;
   end process;
   
   RotateLeft: process(a, b, c_in) is
   begin
      case b is
         when "0000" => roltemp <= c_in & a(15 downto 0);
         when "0001" => roltemp <= a(15) & a(14 downto 0) & a(15);
         when "0010" => roltemp <= a(14) & a(13 downto 0) & a(15 downto 14);
         when "0011" => roltemp <= a(13) & a(12 downto 0) & a(15 downto 13);
         when "0100" => roltemp <= a(12) & a(11 downto 0) & a(15 downto 12);
         when "0101" => roltemp <= a(11) & a(10 downto 0) & a(15 downto 11);
         when "0110" => roltemp <= a(10) & a(09 downto 0) & a(15 downto 10);
         when "0111" => roltemp <= a(09) & a(08 downto 0) & a(15 downto 09);
         when "1000" => roltemp <= a(08) & a(07 downto 0) & a(15 downto 08);
         when "1001" => roltemp <= a(07) & a(06 downto 0) & a(15 downto 07);
         when "1010" => roltemp <= a(06) & a(05 downto 0) & a(15 downto 06);
         when "1011" => roltemp <= a(05) & a(04 downto 0) & a(15 downto 05);
         when "1100" => roltemp <= a(04) & a(03 downto 0) & a(15 downto 04);
         when "1101" => roltemp <= a(03) & a(02 downto 0) & a(15 downto 03);
         when "1110" => roltemp <= a(02) & a(01 downto 0) & a(15 downto 02);
         when "1111" => roltemp <= a(01) & a(00)          & a(15 downto 01);
         when others => roltemp <= (others => '0');
      end case;
   end process;  

   RotateRight: process(a, b, c_in) is
   begin
      case b is
         when "0000" => rortemp <= c_in & a(15 downto 0);
         when "0001" => rortemp <= a(00) & a(00) & a(15 downto 1);
         when "0010" => rortemp <= a(01) & a(01 downto 0) & a(15 downto 02);
         when "0011" => rortemp <= a(02) & a(02 downto 0) & a(15 downto 03);
         when "0100" => rortemp <= a(03) & a(03 downto 0) & a(15 downto 04);
         when "0101" => rortemp <= a(04) & a(04 downto 0) & a(15 downto 05);
         when "0110" => rortemp <= a(05) & a(05 downto 0) & a(15 downto 06);
         when "0111" => rortemp <= a(06) & a(06 downto 0) & a(15 downto 07);
         when "1000" => rortemp <= a(07) & a(07 downto 0) & a(15 downto 08);
         when "1001" => rortemp <= a(08) & a(08 downto 0) & a(15 downto 09);
         when "1010" => rortemp <= a(09) & a(09 downto 0) & a(15 downto 10);
         when "1011" => rortemp <= a(10) & a(10 downto 0) & a(15 downto 11);
         when "1100" => rortemp <= a(11) & a(11 downto 0) & a(15 downto 12);
         when "1101" => rortemp <= a(12) & a(12 downto 0) & a(15 downto 13);
         when "1110" => rortemp <= a(13) & a(13 downto 0) & a(15 downto 14);
         when "1111" => rortemp <= a(14) & a(14 downto 0) & a(15);
         when others => rortemp <= (others => '0');
      end case;
   end process;

   RotateCarryLeft: process(a, b, c_in) is
   begin
      case b is
         when "0000" => rcltemp <= c_in & a(15 downto 0);
         when "0001" => rcltemp <= a(15) & a(14 downto 0) & c_in;
         when "0010" => rcltemp <= a(14) & a(13 downto 0) & c_in & a(15);
         when "0011" => rcltemp <= a(13) & a(12 downto 0) & c_in & a(15 downto 14);
         when "0100" => rcltemp <= a(12) & a(11 downto 0) & c_in & a(15 downto 13);
         when "0101" => rcltemp <= a(11) & a(10 downto 0) & c_in & a(15 downto 12);
         when "0110" => rcltemp <= a(10) & a(09 downto 0) & c_in & a(15 downto 11);
         when "0111" => rcltemp <= a(09) & a(08 downto 0) & c_in & a(15 downto 10);
         when "1000" => rcltemp <= a(08) & a(07 downto 0) & c_in & a(15 downto 09);
         when "1001" => rcltemp <= a(07) & a(06 downto 0) & c_in & a(15 downto 08);
         when "1010" => rcltemp <= a(06) & a(05 downto 0) & c_in & a(15 downto 07);
         when "1011" => rcltemp <= a(05) & a(04 downto 0) & c_in & a(15 downto 06);
         when "1100" => rcltemp <= a(04) & a(03 downto 0) & c_in & a(15 downto 05);
         when "1101" => rcltemp <= a(03) & a(02 downto 0) & c_in & a(15 downto 04);
         when "1110" => rcltemp <= a(02) & a(01 downto 0) & c_in & a(15 downto 03);
         when "1111" => rcltemp <= a(01) & a(00) & c_in & a(15 downto 02);
         when others => rcltemp <= (others => '0');
      end case;
   end process;

   RotateCarryRight: process(a, b, c_in) is
   begin
      case b is
         when "0000" => rcrtemp <= c_in & a(15 downto 0);
         when "0001" => rcrtemp <= a(00) & c_in & a(15 downto 1);
         when "0010" => rcrtemp <= a(01) & a(0) & c_in & a(15 downto 2);
         when "0011" => rcrtemp <= a(02) & a(01 downto 0) & c_in & a(15 downto 03);
         when "0100" => rcrtemp <= a(03) & a(02 downto 0) & c_in & a(15 downto 04);
         when "0101" => rcrtemp <= a(04) & a(03 downto 0) & c_in & a(15 downto 05);
         when "0110" => rcrtemp <= a(05) & a(04 downto 0) & c_in & a(15 downto 06);
         when "0111" => rcrtemp <= a(06) & a(05 downto 0) & c_in & a(15 downto 07);
         when "1000" => rcrtemp <= a(07) & a(06 downto 0) & c_in & a(15 downto 08);
         when "1001" => rcrtemp <= a(08) & a(07 downto 0) & c_in & a(15 downto 09);
         when "1010" => rcrtemp <= a(09) & a(08 downto 0) & c_in & a(15 downto 10);
         when "1011" => rcrtemp <= a(10) & a(09 downto 0) & c_in & a(15 downto 11);
         when "1100" => rcrtemp <= a(11) & a(10 downto 0) & c_in & a(15 downto 12);
         when "1101" => rcrtemp <= a(12) & a(11 downto 0) & c_in & a(15 downto 13);
         when "1110" => rcrtemp <= a(13) & a(12 downto 0) & c_in & a(15 downto 14);
         when "1111" => rcrtemp <= a(14) & a(13 downto 0) & c_in & a(15);
         when others => rcrtemp <= (others => '0');
      end case;
   end process;

   with opsel select
      carry_result <= shltemp when "000",
                      shrtemp when "001",
                      saltemp when "010",
                      sartemp when "011",
                      roltemp when "100",
                      rortemp when "101",
                      rcltemp when "110",
                      rcrtemp when "111",
                      (others => '0') when others;

   result <= carry_result(15 downto 0);

   c_out <= carry_result(16);

   -- overflow is defined for 1-bit shift/rotates 
   process(carry_result, opsel, a) is begin
      case opsel is
        when "000" => -- sll
           ofl_out <= carry_result(15) xor carry_result(16); 
        when "001" => -- slr
           ofl_out <= a(15);
        when "010" => -- sal
           ofl_out <= carry_result(15) xor carry_result(16);
        when "011" => -- sar
           ofl_out <= '0';
        when "100" => -- rol
           ofl_out <= carry_result(15) xor carry_result(16);
        when "101" => -- ror
           ofl_out <= carry_result(15) xor carry_result(14);                  
        when "110" => -- rcl
           ofl_out <= carry_result(15) xor carry_result(16);
        when "111" => -- rcr
           ofl_out <= carry_result(15) xor carry_result(14); 
        when others =>
           ofl_out <= '0';
      end case;   
   end process;

end dataflow;
