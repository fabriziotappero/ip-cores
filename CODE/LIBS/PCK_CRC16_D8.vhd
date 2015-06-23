-----------------------------------------------------------------------
-- File:  PCK_CRC16_D8.vhd                              
-- Date:  Wed Feb  7 08:06:05 2001                                                      
--                                                                     
-- Copyright (C) 1999 Easics NV.                 
-- This source file may be used and distributed without restriction    
-- provided that this copyright statement is not removed from the file 
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose: VHDL package containing a synthesizable CRC function
--   * polynomial: (0 5 12 16)
--   * data width: 8
--                                                                     
-- Info: jand@easics.be (Jan Decaluwe)                           
--       http://www.easics.com                                  
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package PCK_CRC16_D8 is

  -- polynomial: (0 5 12 16)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC16_D8
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(15 downto 0) )
    return std_logic_vector;

end PCK_CRC16_D8;

library IEEE;
use IEEE.std_logic_1164.all;

package body PCK_CRC16_D8 is

  -- polynomial: (0 5 12 16)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC16_D8  
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(15 downto 0) )
    return std_logic_vector is

    variable D: std_logic_vector(7 downto 0);
    variable C: std_logic_vector(15 downto 0);
    variable NewCRC: std_logic_vector(15 downto 0);

  begin

    D := Data;
    C := CRC;

    NewCRC(0) := D(4) xor D(0) xor C(8) xor C(12);
    NewCRC(1) := D(5) xor D(1) xor C(9) xor C(13);
    NewCRC(2) := D(6) xor D(2) xor C(10) xor C(14);
    NewCRC(3) := D(7) xor D(3) xor C(11) xor C(15);
    NewCRC(4) := D(4) xor C(12);
    NewCRC(5) := D(5) xor D(4) xor D(0) xor C(8) xor C(12) xor C(13);
    NewCRC(6) := D(6) xor D(5) xor D(1) xor C(9) xor C(13) xor C(14);
    NewCRC(7) := D(7) xor D(6) xor D(2) xor C(10) xor C(14) xor C(15);
    NewCRC(8) := D(7) xor D(3) xor C(0) xor C(11) xor C(15);
    NewCRC(9) := D(4) xor C(1) xor C(12);
    NewCRC(10) := D(5) xor C(2) xor C(13);
    NewCRC(11) := D(6) xor C(3) xor C(14);
    NewCRC(12) := D(7) xor D(4) xor D(0) xor C(4) xor C(8) xor C(12) xor 
                  C(15);
    NewCRC(13) := D(5) xor D(1) xor C(5) xor C(9) xor C(13);
    NewCRC(14) := D(6) xor D(2) xor C(6) xor C(10) xor C(14);
    NewCRC(15) := D(7) xor D(3) xor C(7) xor C(11) xor C(15);

    return NewCRC;

  end nextCRC16_D8;

end PCK_CRC16_D8;

