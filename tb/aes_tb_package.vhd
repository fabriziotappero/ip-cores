--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : aes_tb_package.vhd                                        *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: Test Bench package containing ascii to binary             *
--              conversion functions and vice versa for the               *
--              TB aes_tester to do text based tests.                     *
--                                                                        *
-- Revision History                                                       *
-- |-----------|-------------|---------|---------------------------------|*
-- |   Name    |    Date     | Version |          Revision details       |*
-- |-----------|-------------|---------|---------------------------------|*
-- | Hemanth   | 15-Dec-2004 | 1.1.1.1 |            Uploaded             |*
-- |-----------|-------------|---------|---------------------------------|*
--                                                                        *                                   *
--*************************************************************************
--                                                                        *
-- Copyright (C) 2004 Author                                              *
--                                                                        *
-- This source file may be used and distributed without                   *
-- restriction provided that this copyright statement is not              *
-- removed from the file and that any derivative work contains            *
-- the original copyright notice and the associated disclaimer.           *
--                                                                        *
-- This source file is free software; you can redistribute it             *
-- and/or modify it under the terms of the GNU Lesser General             *
-- Public License as published by the Free Software Foundation;           *
-- either version 2.1 of the License, or (at your option) any             *
-- later version.                                                         *
--                                                                        *
-- This source is distributed in the hope that it will be                 *
-- useful, but WITHOUT ANY WARRANTY; without even the implied             *
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                *
-- PURPOSE.  See the GNU Lesser General Public License for more           *
-- details.                                                               *
--                                                                        *
-- You should have received a copy of the GNU Lesser General              *
-- Public License along with this source; if not, download it             *
-- from http://www.opencores.org/lgpl.shtml                               *
--                                                                        *
--*************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package aes_tb_package is
function ascii_2_std_logic_vector(ch: character) return std_logic_vector;
function std_logic_vector_2_ascii(vec: std_logic_vector(7 downto 0)) return character;

end package aes_tb_package;

package body aes_tb_package is

function ascii_2_std_logic_vector(ch: character) return std_logic_vector is
variable out_vector: std_logic_vector(7 downto 0);
begin
  case ch is
    when 'a' => out_vector := conv_std_logic_vector(97,8);
    when 'b' => out_vector := conv_std_logic_vector(98,8);
    when 'c' => out_vector := conv_std_logic_vector(99,8);
    when 'd' => out_vector := conv_std_logic_vector(100,8);
    when 'e' => out_vector := conv_std_logic_vector(101,8);
    when 'f' => out_vector := conv_std_logic_vector(102,8);
    when 'g' => out_vector := conv_std_logic_vector(103,8);
    when 'h' => out_vector := conv_std_logic_vector(104,8);
    when 'i' => out_vector := conv_std_logic_vector(105,8);
    when 'j' => out_vector := conv_std_logic_vector(106,8);
    when 'k' => out_vector := conv_std_logic_vector(107,8);
    when 'l' => out_vector := conv_std_logic_vector(108,8);
    when 'm' => out_vector := conv_std_logic_vector(109,8);
    when 'n' => out_vector := conv_std_logic_vector(110,8);
    when 'o' => out_vector := conv_std_logic_vector(111,8);
    when 'p' => out_vector := conv_std_logic_vector(112,8);
    when 'q' => out_vector := conv_std_logic_vector(113,8);
    when 'r' => out_vector := conv_std_logic_vector(114,8);
    when 's' => out_vector := conv_std_logic_vector(115,8);
    when 't' => out_vector := conv_std_logic_vector(116,8);
    when 'u' => out_vector := conv_std_logic_vector(117,8);
    when 'v' => out_vector := conv_std_logic_vector(118,8);
    when 'w' => out_vector := conv_std_logic_vector(119,8);
    when 'x' => out_vector := conv_std_logic_vector(120,8);
    when 'y' => out_vector := conv_std_logic_vector(121,8);
    when 'z' => out_vector := conv_std_logic_vector(122,8);
                                  
    when 'A' => out_vector := conv_std_logic_vector(65,8);
    when 'B' => out_vector := conv_std_logic_vector(66,8);
    when 'C' => out_vector := conv_std_logic_vector(67,8);
    when 'D' => out_vector := conv_std_logic_vector(68,8);
    when 'E' => out_vector := conv_std_logic_vector(69,8);
    when 'F' => out_vector := conv_std_logic_vector(70,8);
    when 'G' => out_vector := conv_std_logic_vector(71,8);
    when 'H' => out_vector := conv_std_logic_vector(72,8);
    when 'I' => out_vector := conv_std_logic_vector(73,8);
    when 'J' => out_vector := conv_std_logic_vector(74,8);
    when 'K' => out_vector := conv_std_logic_vector(75,8);
    when 'L' => out_vector := conv_std_logic_vector(76,8);
    when 'M' => out_vector := conv_std_logic_vector(77,8);
    when 'N' => out_vector := conv_std_logic_vector(78,8);
    when 'O' => out_vector := conv_std_logic_vector(79,8);
    when 'P' => out_vector := conv_std_logic_vector(80,8);
    when 'Q' => out_vector := conv_std_logic_vector(81,8);
    when 'R' => out_vector := conv_std_logic_vector(82,8);
    when 'S' => out_vector := conv_std_logic_vector(83,8);
    when 'T' => out_vector := conv_std_logic_vector(84,8);
    when 'U' => out_vector := conv_std_logic_vector(85,8);
    when 'V' => out_vector := conv_std_logic_vector(86,8);
    when 'W' => out_vector := conv_std_logic_vector(87,8);
    when 'X' => out_vector := conv_std_logic_vector(88,8);
    when 'Y' => out_vector := conv_std_logic_vector(89,8);
    when 'Z' => out_vector := conv_std_logic_vector(90,8);
                                 
    when '0' => out_vector := conv_std_logic_vector(48,8);
    when '1' => out_vector := conv_std_logic_vector(49,8);
    when '2' => out_vector := conv_std_logic_vector(50,8);
    when '3' => out_vector := conv_std_logic_vector(51,8);
    when '4' => out_vector := conv_std_logic_vector(52,8);
    when '5' => out_vector := conv_std_logic_vector(53,8);
    when '6' => out_vector := conv_std_logic_vector(54,8);
    when '7' => out_vector := conv_std_logic_vector(55,8);
    when '8' => out_vector := conv_std_logic_vector(56,8);
    when '9' => out_vector := conv_std_logic_vector(57,8);
    
    when ' ' => out_vector := conv_std_logic_vector(32,8);
    when '!' => out_vector := conv_std_logic_vector(33,8);
    --when '\"' => out_vector := conv_std_logic_vector(34,8);
    when '#' => out_vector := conv_std_logic_vector(35,8);
    when '$' => out_vector := conv_std_logic_vector(36,8);
    when '%' => out_vector := conv_std_logic_vector(37,8);
    when '&' => out_vector := conv_std_logic_vector(38,8);
    when ''' => out_vector := conv_std_logic_vector(39,8);
    when '(' => out_vector := conv_std_logic_vector(40,8);
    when ')' => out_vector := conv_std_logic_vector(41,8);
    when '*' => out_vector := conv_std_logic_vector(42,8);
    when '+' => out_vector := conv_std_logic_vector(43,8);
    when ',' => out_vector := conv_std_logic_vector(44,8);
    when '-' => out_vector := conv_std_logic_vector(45,8);
    when '.' => out_vector := conv_std_logic_vector(46,8);
    when '/' => out_vector := conv_std_logic_vector(47,8);
    when ':' => out_vector := conv_std_logic_vector(58,8);
    when ';' => out_vector := conv_std_logic_vector(59,8);
    when '<' => out_vector := conv_std_logic_vector(60,8);
    when '=' => out_vector := conv_std_logic_vector(61,8);
    when '>' => out_vector := conv_std_logic_vector(62,8);
    when '?' => out_vector := conv_std_logic_vector(63,8);
    when '@' => out_vector := conv_std_logic_vector(64,8);
    when '[' => out_vector := conv_std_logic_vector(91,8);
    when '\' => out_vector := conv_std_logic_vector(92,8);
    when ']' => out_vector := conv_std_logic_vector(93,8);
    when '^' => out_vector := conv_std_logic_vector(94,8);
    when '_' => out_vector := conv_std_logic_vector(95,8);
    when '`' => out_vector := conv_std_logic_vector(96,8);
    when '{' => out_vector := conv_std_logic_vector(123,8);
    when '|' => out_vector := conv_std_logic_vector(124,8);
    when '}' => out_vector := conv_std_logic_vector(125,8);
    when '~' => out_vector := conv_std_logic_vector(126,8);
        
    when others => null;
  end case;  
  return  out_vector;
end function  ascii_2_std_logic_vector;

function std_logic_vector_2_ascii(vec: std_logic_vector(7 downto 0)) return character is
variable out_char: character;
begin
  case vec is
    when "01100001" => out_char := 'a';
    when "01100010" => out_char := 'b';
    when "01100011" => out_char := 'c';
    when "01100100" => out_char := 'd';
    when "01100101" => out_char := 'e';
    when "01100110" => out_char := 'f';
    when "01100111" => out_char := 'g';
    when "01101000" => out_char := 'h';
    when "01101001" => out_char := 'i';
    when "01101010" => out_char := 'j';
    when "01101011" => out_char := 'k';
    when "01101100" => out_char := 'l';
    when "01101101" => out_char := 'm';
    when "01101110" => out_char := 'n';
    when "01101111" => out_char := 'o';
    when "01110000" => out_char := 'p';
    when "01110001" => out_char := 'q';
    when "01110010" => out_char := 'r';
    when "01110011" => out_char := 's';
    when "01110100" => out_char := 't';
    when "01110101" => out_char := 'u';
    when "01110110" => out_char := 'v';
    when "01110111" => out_char := 'w';
    when "01111000" => out_char := 'x';
    when "01111001" => out_char := 'y';
    when "01111010" => out_char := 'z';
                                  
    when "01000001" => out_char := 'A';
    when "01000010" => out_char := 'B';
    when "01000011" => out_char := 'C';
    when "01000100" => out_char := 'D';
    when "01000101" => out_char := 'E';
    when "01000110" => out_char := 'F';
    when "01000111" => out_char := 'G';
    when "01001000" => out_char := 'H';
    when "01001001" => out_char := 'I';
    when "01001010" => out_char := 'J';
    when "01001011" => out_char := 'K';
    when "01001100" => out_char := 'L';
    when "01001101" => out_char := 'M';
    when "01001110" => out_char := 'N';
    when "01001111" => out_char := 'O';
    when "01010000" => out_char := 'P';
    when "01010001" => out_char := 'Q';
    when "01010010" => out_char := 'R';
    when "01010011" => out_char := 'S';
    when "01010100" => out_char := 'T';
    when "01010101" => out_char := 'U';
    when "01010110" => out_char := 'V';
    when "01010111" => out_char := 'W';
    when "01011000" => out_char := 'X';
    when "01011001" => out_char := 'Y';
    when "01011010" => out_char := 'Z';
                                 
    when "00110000" => out_char := '0';
    when "00110001" => out_char := '1';
    when "00110010" => out_char := '2';
    when "00110011" => out_char := '3';
    when "00110100" => out_char := '4';
    when "00110101" => out_char := '5';
    when "00110110" => out_char := '6';
    when "00110111" => out_char := '7';
    when "00111000" => out_char := '8';
    when "00111001" => out_char := '9';
    
    when "00100000" => out_char := ' ';
    when "00100001" => out_char := '!';
    --when "00100010" => out_vector := '\"';
    when "00100011" => out_char := '#';
    when "00100100" => out_char := '$';
    when "00100101" => out_char := '%';
    when "00100110" => out_char := '&';
    when "00100111" => out_char := ''';
    when "00101000" => out_char := '(';
    when "00101001" => out_char := ')';
    when "00101010" => out_char := '*';
    when "00101011" => out_char := '+';
    when "00101100" => out_char := ',';
    when "00101101" => out_char := '-';
    when "00101110" => out_char := '.';
    when "00101111" => out_char := '/';
    when "00111010" => out_char := ':';
    when "00111011" => out_char := ';';
    when "00111100" => out_char := '<';
    when "00111101" => out_char := '=';
    when "00111110" => out_char := '>';
    when "00111111" => out_char := '?';
    when "01000000" => out_char := '@';
    when "01011011" => out_char := '[';
    when "01011100" => out_char := '\';
    when "01011101" => out_char := ']';
    when "01011110" => out_char := '^';
    when "01011111" => out_char := '_';
    when "01100000" => out_char := '`';
    when "01111011" => out_char := '{';
    when "01111100" => out_char := '|';
    when "01111101" => out_char := '}';
    when "01111110" => out_char := '~';
        
    when others => null;
  end case;  
  return  out_char;
end function  std_logic_vector_2_ascii;

end package body aes_tb_package;