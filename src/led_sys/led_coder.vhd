------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


--                   bit 0,A
--                 ----------
--                |          |
--                |          |
--             5,F|          |  1,B
--                |    6,G   |
--                 ----------
--                |          |
--                |          |
--             4,E|          |  2,C
--                |    3,D   |
--                 ----------  
--                              # 7,H



library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity led_coder is
  port (
    led_data_i : in  std_logic_vector(7 downto 0);
    hi_seg     : out std_logic_vector(7 downto 0);
    lo_seg     : out std_logic_vector(7 downto 0)
    );
end led_coder;

architecture rtl of led_coder is
signal r_led_data : std_logic_vector(7 downto 0);
signal decoded_lo,decoded_hi : std_logic_vector(7 downto 0);  

begin  -- rtl
hi_seg <= decoded_hi;
lo_seg <= decoded_lo;
  
  -- purpose: binary to led segments decoder
  -- type   : combinational
  -- inputs : nibble,reset
  -- outputs: 
  decode_nibble_lo: process (led_data_i)
  begin  -- process decode_nibble
      case led_data_i(3 downto 0) is--HGFEDCBA
        when "0000" => decoded_lo <= "00111111";  -- 0
        when "0001" => decoded_lo <= "00000110";  -- 1
        when "0010" => decoded_lo <= "01011011";  -- 2
        when "0011" => decoded_lo <= "01001111";  -- 3
        when "0100" => decoded_lo <= "01100110";  -- 4
        when "0101" => decoded_lo <= "01101101";  -- 5
        when "0110" => decoded_lo <= "01111101";  -- 6
        when "0111" => decoded_lo <= "00000111";  -- 7
        when "1000" => decoded_lo <= "01111111";  -- 8
        when "1001" => decoded_lo <= "01101111";  -- 9
        when "1010" => decoded_lo <= "01110111";  -- a
        when "1011" => decoded_lo <= "01111100";  -- b
        when "1100" => decoded_lo <= "00111001";  -- c
        when "1101" => decoded_lo <= "01011110";  -- d
        when "1110" => decoded_lo <= "01111001";  -- e
        when others => decoded_lo <= "01110001";  -- f
      end case;
  end process decode_nibble_lo;

  decode_nibble_hi: process (led_data_i)
  begin  -- process decode_nibble
      case led_data_i(7 downto 4) is--HGFEDCBA
        when "0000" => decoded_hi <= "00111111";  -- 0
        when "0001" => decoded_hi <= "00000110";  -- 1
        when "0010" => decoded_hi <= "01011011";  -- 2
        when "0011" => decoded_hi <= "01001111";  -- 3
        when "0100" => decoded_hi <= "01100110";  -- 4
        when "0101" => decoded_hi <= "01101101";  -- 5
        when "0110" => decoded_hi <= "01111101";  -- 6
        when "0111" => decoded_hi <= "00000111";  -- 7
        when "1000" => decoded_hi <= "01111111";  -- 8
        when "1001" => decoded_hi <= "01101111";  -- 9
        when "1010" => decoded_hi <= "01110111";  -- a
        when "1011" => decoded_hi <= "01111100";  -- b
        when "1100" => decoded_hi <= "00111001";  -- c
        when "1101" => decoded_hi <= "01011110";  -- d
        when "1110" => decoded_hi <= "01111001";  -- e
        when others => decoded_hi <= "01110001";  -- f
      end case;
  end process decode_nibble_hi;


end rtl;
