-----------------------------------------------------------------------
-- File:  PCK_CRC8_D8.vhd                              
-- Date:  Sun Dec 31 07:41:19 2000                                                      
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
--   * polynomial: (0 1 2 5 7 8)
--   * data width: 8
--                                                                     
-- Info: jand@easics.be (Jan Decaluwe)                           
--       http://www.easics.com                                  
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package PCK_CRC8_D8 is

  -- polynomial: (0 1 2 5 7 8)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC8_D8
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(7 downto 0) )
    return std_logic_vector;

end PCK_CRC8_D8;

library IEEE;
use IEEE.std_logic_1164.all;

package body PCK_CRC8_D8 is

  -- polynomial: (0 1 2 5 7 8)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC8_D8  
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(7 downto 0) )
    return std_logic_vector is

    variable D: std_logic_vector(7 downto 0);
    variable C: std_logic_vector(7 downto 0);
    variable NewCRC: std_logic_vector(7 downto 0);

  begin

    D := Data;
    C := CRC;

    NewCRC(0) := D(6) xor D(4) xor D(2) xor D(1) xor D(0) xor C(0) xor 
                 C(1) xor C(2) xor C(4) xor C(6);
    NewCRC(1) := D(7) xor D(6) xor D(5) xor D(4) xor D(3) xor D(0) xor 
                 C(0) xor C(3) xor C(4) xor C(5) xor C(6) xor C(7);
    NewCRC(2) := D(7) xor D(5) xor D(2) xor D(0) xor C(0) xor C(2) xor 
                 C(5) xor C(7);
    NewCRC(3) := D(6) xor D(3) xor D(1) xor C(1) xor C(3) xor C(6);
    NewCRC(4) := D(7) xor D(4) xor D(2) xor C(2) xor C(4) xor C(7);
    NewCRC(5) := D(6) xor D(5) xor D(4) xor D(3) xor D(2) xor D(1) xor 
                 D(0) xor C(0) xor C(1) xor C(2) xor C(3) xor C(4) xor 
                 C(5) xor C(6);
    NewCRC(6) := D(7) xor D(6) xor D(5) xor D(4) xor D(3) xor D(2) xor 
                 D(1) xor C(1) xor C(2) xor C(3) xor C(4) xor C(5) xor 
                 C(6) xor C(7);
    NewCRC(7) := D(7) xor D(5) xor D(3) xor D(1) xor D(0) xor C(0) xor 
                 C(1) xor C(3) xor C(5) xor C(7);

    return NewCRC;

  end nextCRC8_D8;

end PCK_CRC8_D8;

