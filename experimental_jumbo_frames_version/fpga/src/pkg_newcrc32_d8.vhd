library ieee;
use ieee.std_logic_1164.all;
package pkg_newcrc32_d8 is
  -- CRC update for 32-bit CRC and 8-bit data (LSB first)
  -- The CRC polynomial exponents: [0, 1, 2, 4, 5, 7, 8, 10, 11, 12, 16, 22, 23, 26, 32]
  function newcrc32_d8(
    din : std_logic_vector(7 downto 0);
    crc : std_logic_vector(31 downto 0))
    return std_logic_vector;
end pkg_newcrc32_d8;

package body pkg_newcrc32_d8 is
  function newcrc32_d8(
    din : std_logic_vector(7 downto 0);
    crc : std_logic_vector(31 downto 0))
    return std_logic_vector is
    variable c, n : std_logic_vector(31 downto 0);
    variable d    : std_logic_vector(7 downto 0);
  begin
    c     := crc;
    d     := din;
    n(0)  := c(24) xor c(30) xor d(1) xor d(7);
    n(1)  := c(24) xor c(25) xor c(30) xor c(31) xor d(0) xor d(1) xor d(6) xor d(7);
    n(2)  := c(24) xor c(25) xor c(26) xor c(30) xor c(31) xor d(0) xor d(1) xor d(5) xor d(6) xor d(7);
    n(3)  := c(25) xor c(26) xor c(27) xor c(31) xor d(0) xor d(4) xor d(5) xor d(6);
    n(4)  := c(24) xor c(26) xor c(27) xor c(28) xor c(30) xor d(1) xor d(3) xor d(4) xor d(5) xor d(7);
    n(5)  := c(24) xor c(25) xor c(27) xor c(28) xor c(29) xor c(30) xor c(31) xor d(0) xor d(1) xor d(2) xor d(3) xor d(4) xor d(6) xor d(7);
    n(6)  := c(25) xor c(26) xor c(28) xor c(29) xor c(30) xor c(31) xor d(0) xor d(1) xor d(2) xor d(3) xor d(5) xor d(6);
    n(7)  := c(24) xor c(26) xor c(27) xor c(29) xor c(31) xor d(0) xor d(2) xor d(4) xor d(5) xor d(7);
    n(8)  := c(0) xor c(24) xor c(25) xor c(27) xor c(28) xor d(3) xor d(4) xor d(6) xor d(7);
    n(9)  := c(1) xor c(25) xor c(26) xor c(28) xor c(29) xor d(2) xor d(3) xor d(5) xor d(6);
    n(10) := c(2) xor c(24) xor c(26) xor c(27) xor c(29) xor d(2) xor d(4) xor d(5) xor d(7);
    n(11) := c(3) xor c(24) xor c(25) xor c(27) xor c(28) xor d(3) xor d(4) xor d(6) xor d(7);
    n(12) := c(4) xor c(24) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30) xor d(1) xor d(2) xor d(3) xor d(5) xor d(6) xor d(7);
    n(13) := c(5) xor c(25) xor c(26) xor c(27) xor c(29) xor c(30) xor c(31) xor d(0) xor d(1) xor d(2) xor d(4) xor d(5) xor d(6);
    n(14) := c(6) xor c(26) xor c(27) xor c(28) xor c(30) xor c(31) xor d(0) xor d(1) xor d(3) xor d(4) xor d(5);
    n(15) := c(7) xor c(27) xor c(28) xor c(29) xor c(31) xor d(0) xor d(2) xor d(3) xor d(4);
    n(16) := c(8) xor c(24) xor c(28) xor c(29) xor d(2) xor d(3) xor d(7);
    n(17) := c(9) xor c(25) xor c(29) xor c(30) xor d(1) xor d(2) xor d(6);
    n(18) := c(10) xor c(26) xor c(30) xor c(31) xor d(0) xor d(1) xor d(5);
    n(19) := c(11) xor c(27) xor c(31) xor d(0) xor d(4);
    n(20) := c(12) xor c(28) xor d(3);
    n(21) := c(13) xor c(29) xor d(2);
    n(22) := c(14) xor c(24) xor d(7);
    n(23) := c(15) xor c(24) xor c(25) xor c(30) xor d(1) xor d(6) xor d(7);
    n(24) := c(16) xor c(25) xor c(26) xor c(31) xor d(0) xor d(5) xor d(6);
    n(25) := c(17) xor c(26) xor c(27) xor d(4) xor d(5);
    n(26) := c(18) xor c(24) xor c(27) xor c(28) xor c(30) xor d(1) xor d(3) xor d(4) xor d(7);
    n(27) := c(19) xor c(25) xor c(28) xor c(29) xor c(31) xor d(0) xor d(2) xor d(3) xor d(6);
    n(28) := c(20) xor c(26) xor c(29) xor c(30) xor d(1) xor d(2) xor d(5);
    n(29) := c(21) xor c(27) xor c(30) xor c(31) xor d(0) xor d(1) xor d(4);
    n(30) := c(22) xor c(28) xor c(31) xor d(0) xor d(3);
    n(31) := c(23) xor c(29) xor d(2);
    return n;
  end newcrc32_d8;
end pkg_newcrc32_d8;

