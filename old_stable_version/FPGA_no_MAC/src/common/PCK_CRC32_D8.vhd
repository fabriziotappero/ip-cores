--------------------------------------------------------------------------------
-- Copyright (C) 1999-2008 Easics NV.
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose : synthesizable CRC function
--   * polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
--   * data width: 8
--
-- Info : tools@easics.be
--        http://www.easics.com
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package PCK_CRC32_D8 is
  -- polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC32_D8
    (Data: std_logic_vector(7 downto 0);
     crc:  std_logic_vector(31 downto 0))
    return std_logic_vector;
end PCK_CRC32_D8;


package body PCK_CRC32_D8 is

  -- polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC32_D8
    (Data: std_logic_vector(7 downto 0);
     crc:  std_logic_vector(31 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(7 downto 0);
    variable c:      std_logic_vector(31 downto 0);
    variable newcrc: std_logic_vector(31 downto 0);

  begin
    d := Data;
    c := crc;

    newcrc(0) := d(6) xor d(0) xor c(24) xor c(30);
    newcrc(1) := d(7) xor d(6) xor d(1) xor d(0) xor c(24) xor c(25) xor c(30) xor c(31);
    newcrc(2) := d(7) xor d(6) xor d(2) xor d(1) xor d(0) xor c(24) xor c(25) xor c(26) xor c(30) xor c(31);
    newcrc(3) := d(7) xor d(3) xor d(2) xor d(1) xor c(25) xor c(26) xor c(27) xor c(31);
    newcrc(4) := d(6) xor d(4) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(28) xor c(30);
    newcrc(5) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(1) xor d(0) xor c(24) xor c(25) xor c(27) xor c(28) xor c(29) xor c(30) xor c(31);
    newcrc(6) := d(7) xor d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30) xor c(31);
    newcrc(7) := d(7) xor d(5) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(29) xor c(31);
    newcrc(8) := d(4) xor d(3) xor d(1) xor d(0) xor c(0) xor c(24) xor c(25) xor c(27) xor c(28);
    newcrc(9) := d(5) xor d(4) xor d(2) xor d(1) xor c(1) xor c(25) xor c(26) xor c(28) xor c(29);
    newcrc(10) := d(5) xor d(3) xor d(2) xor d(0) xor c(2) xor c(24) xor c(26) xor c(27) xor c(29);
    newcrc(11) := d(4) xor d(3) xor d(1) xor d(0) xor c(3) xor c(24) xor c(25) xor c(27) xor c(28);
    newcrc(12) := d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor d(0) xor c(4) xor c(24) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30);
    newcrc(13) := d(7) xor d(6) xor d(5) xor d(3) xor d(2) xor d(1) xor c(5) xor c(25) xor c(26) xor c(27) xor c(29) xor c(30) xor c(31);
    newcrc(14) := d(7) xor d(6) xor d(4) xor d(3) xor d(2) xor c(6) xor c(26) xor c(27) xor c(28) xor c(30) xor c(31);
    newcrc(15) := d(7) xor d(5) xor d(4) xor d(3) xor c(7) xor c(27) xor c(28) xor c(29) xor c(31);
    newcrc(16) := d(5) xor d(4) xor d(0) xor c(8) xor c(24) xor c(28) xor c(29);
    newcrc(17) := d(6) xor d(5) xor d(1) xor c(9) xor c(25) xor c(29) xor c(30);
    newcrc(18) := d(7) xor d(6) xor d(2) xor c(10) xor c(26) xor c(30) xor c(31);
    newcrc(19) := d(7) xor d(3) xor c(11) xor c(27) xor c(31);
    newcrc(20) := d(4) xor c(12) xor c(28);
    newcrc(21) := d(5) xor c(13) xor c(29);
    newcrc(22) := d(0) xor c(14) xor c(24);
    newcrc(23) := d(6) xor d(1) xor d(0) xor c(15) xor c(24) xor c(25) xor c(30);
    newcrc(24) := d(7) xor d(2) xor d(1) xor c(16) xor c(25) xor c(26) xor c(31);
    newcrc(25) := d(3) xor d(2) xor c(17) xor c(26) xor c(27);
    newcrc(26) := d(6) xor d(4) xor d(3) xor d(0) xor c(18) xor c(24) xor c(27) xor c(28) xor c(30);
    newcrc(27) := d(7) xor d(5) xor d(4) xor d(1) xor c(19) xor c(25) xor c(28) xor c(29) xor c(31);
    newcrc(28) := d(6) xor d(5) xor d(2) xor c(20) xor c(26) xor c(29) xor c(30);
    newcrc(29) := d(7) xor d(6) xor d(3) xor c(21) xor c(27) xor c(30) xor c(31);
    newcrc(30) := d(7) xor d(4) xor c(22) xor c(28) xor c(31);
    newcrc(31) := d(5) xor c(23) xor c(29);
    return newcrc;
  end nextCRC32_D8;

end PCK_CRC32_D8;
