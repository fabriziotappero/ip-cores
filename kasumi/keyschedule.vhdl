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

entity keyschedule is
  port (
  key              : in  bit_vector ( 63 downto 0);
  st               : in  bit_vector (  3 downto 0);
  ldk              : in  bit;
--probe
--keyreg1_prb      : out bit_vector (127 downto 0);
--keyreg2_prb      : out bit_vector (127 downto 0);
--probe
  rk               : out bit_vector ( 15 downto 0);
  clk              : in  bit;
  rst              : in  bit
  );
end keyschedule;

architecture phy of keyschedule is
  signal keyreg1   :     bit_vector (127 downto 0);
  signal keyreg2   :     bit_vector (127 downto 0);
  signal   k1      :     bit_vector ( 15 downto 0);
  signal   k2      :     bit_vector ( 15 downto 0);
  signal   k3      :     bit_vector ( 15 downto 0);
  signal   k4      :     bit_vector ( 15 downto 0);
  signal   k5      :     bit_vector ( 15 downto 0);
  signal   k6      :     bit_vector ( 15 downto 0);
  signal   k7      :     bit_vector ( 15 downto 0);
  signal   k8      :     bit_vector ( 15 downto 0);
  signal   c1      :     bit_vector ( 15 downto 0);
  signal   c2      :     bit_vector ( 15 downto 0);
  signal   c3      :     bit_vector ( 15 downto 0);
  signal   c4      :     bit_vector ( 15 downto 0);
  signal   c5      :     bit_vector ( 15 downto 0);
  signal   c6      :     bit_vector ( 15 downto 0);
  signal   c7      :     bit_vector ( 15 downto 0);
  signal   c8      :     bit_vector ( 15 downto 0);
--constant c1      :     bit_vector ( 15 downto 0) := X"0123";
--constant c2      :     bit_vector ( 15 downto 0) := X"4567";
--constant c3      :     bit_vector ( 15 downto 0) := X"89ab";
--constant c4      :     bit_vector ( 15 downto 0) := X"cdef";
--constant c5      :     bit_vector ( 15 downto 0) := X"fedc";
--constant c6      :     bit_vector ( 15 downto 0) := X"ba98";
--constant c7      :     bit_vector ( 15 downto 0) := X"7654";
--constant c8      :     bit_vector ( 15 downto 0) := X"3210";
  signal ikey      :     bit_vector ( 15 downto 0);
--signal st        :     bit_vector (  2 downto 0);
--signal ldk       :     bit;

begin

--probe
--keyreg1_prb      <= keyreg1;
--keyreg2_prb      <= keyreg2;
--probe

--process (clk)
--begin
--if ((clk = '1') and clk'event) then
--  if (rst = '1') then
--    rk           <= (others => '0');
--  else
      rk               <= ikey;
--  end if;
--end if;
--end process;

  process (clk)
  begin
    if ((clk = '1') and clk'event) then
      if (rst = '1') then
        keyreg1    <= (others => '0');
        keyreg2    <= X"0123456789abcdeffedcba9876543210";
      elsif (ldk  = '1') then
        keyreg1    <= keyreg1( 63 downto 0) & key;
        keyreg2    <= X"0123456789abcdeffedcba9876543210";
      elsif (st = X"f") then
        keyreg1    <= keyreg1( 95 downto 0) & keyreg1(127 downto  96);
        keyreg2    <= keyreg2( 95 downto 0) & keyreg2(127 downto  96);
      end if;
    end if;
  end process;

  k1               <= keyreg1(127 downto 112);
  k2               <= keyreg1(111 downto  96);
  k3               <= keyreg1( 95 downto  80);
  k4               <= keyreg1( 79 downto  64);
  k5               <= keyreg1( 63 downto  48);
  k6               <= keyreg1( 47 downto  32);
  k7               <= keyreg1( 31 downto  16);
  k8               <= keyreg1( 15 downto   0);

  c1               <= keyreg2(127 downto 112);
  c2               <= keyreg2(111 downto  96);
  c3               <= keyreg2( 95 downto  80);
  c4               <= keyreg2( 79 downto  64);
  c5               <= keyreg2( 63 downto  48);
  c6               <= keyreg2( 47 downto  32);
  c7               <= keyreg2( 31 downto  16);
  c8               <= keyreg2( 15 downto   0);

  process (st,rst,k1,k2,k3,k4,k5,k6,k7,k8,c1,c3,c4,c5,c6,c8)
  begin
    if (rst = '1') then
      ikey         <= (others => '0');
    else
      case st is
        when X"0"  =>                                                     --KLi,1
          ikey     <= k1(14 downto 0) & k1(15);
        when X"1" =>                                                      --KLi,2
          ikey     <= k3 xor c3;
        when X"2" =>                                                      --KOi,1
          ikey     <= k2(10 downto 0) & k2(15 downto 11);
        when X"3" =>                                                      --KIi,1
          ikey     <= k5 xor c5;
        when X"4" =>                                                      --KOi,2
          ikey     <= k6( 7 downto 0) & k6(15 downto  8);
        when X"5" =>                                                      --KIi,2
          ikey     <= k4 xor c4;
        when X"6" =>                                                      --KOi,3
          ikey     <= k7( 2 downto 0) & k7(15 downto  3);
        when X"7" =>                                                      --KIi,3
          ikey     <= k8 xor c8;
        when X"8" =>                                                      --KOi,1
          ikey     <= k3(10 downto 0) & k3(15 downto 11);
        when X"9" =>                                                      --KIi,1
          ikey     <= k6 xor c6;
        when X"a" =>                                                      --KOi,2
          ikey     <= k7( 7 downto 0) & k7(15 downto  8);
        when X"b" =>                                                      --KIi,2
          ikey     <= k5 xor c5;
        when X"c" =>                                                      --KOi,3
          ikey     <= k8( 2 downto 0) & k8(15 downto  3);
        when X"d" =>                                                      --KIi,3
          ikey     <= k1 xor c1;
        when X"e"  =>                                                     --KLi,1
          ikey     <= k2(14 downto 0) & k2(15);
        when X"f" =>                                                      --KLi,2
          ikey     <= k4 xor c4;
      end case;
    end if;
  end process;

end phy;

