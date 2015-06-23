-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
  PORT (A   : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        B   : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        X   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        SEL : IN  STD_LOGIC_VECTOR (5 DOWNTO 0));
END ALU;

ARCHITECTURE Behavioral OF ALU IS

  COMPONENT boole IS
    GENERIC (
      width : NATURAL := 32);
    PORT (A   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          B   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          X   : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          SEL : IN  STD_LOGIC_VECTOR (2 DOWNTO 0));
  END COMPONENT boole;

  COMPONENT shift IS
    GENERIC (
      width : NATURAL := 16);
    PORT (A   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          B   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          X   : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
          SEL : IN  STD_LOGIC_VECTOR (2 DOWNTO 0));
  END COMPONENT shift;

  COMPONENT addsub IS
    PORT (A     : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          B     : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          SUM   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
          CARRY : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
          SEL   : IN  STD_LOGIC_VECTOR (1 DOWNTO 0));
  END COMPONENT addsub;

  COMPONENT multiplier IS
    PORT (A            : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          B            : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          PRODUCT_HIGH : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
          PRODUCT_LOW  : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
  END COMPONENT multiplier;

  SIGNAL bool_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL shift_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL add_out       : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL carry_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL prod_low_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL prod_high_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
  
BEGIN

  BOOL1 : boole
    GENERIC MAP (
      width => 16)
    PORT MAP (
    A   => A,
    B   => B,
    X   => bool_out,
    SEL => SEL(2 DOWNTO 0));

  SHIFT1 : shift PORT MAP (
    A   => A,
    B   => B,
    X   => shift_out,
    SEL => SEL(2 DOWNTO 0));

  ADD1 : addsub PORT MAP (
    A     => A,
    B     => B,
    SUM   => add_out,
    CARRY => carry_out,
    SEL   => SEL(1 DOWNTO 0));

  MULT1 : multiplier PORT MAP (
    A            => A,
    B            => B,
    PRODUCT_HIGH => prod_high_out,
    PRODUCT_LOW  => prod_low_out);

  WITH SEL(5 DOWNTO 3) SELECT
    X <=
    bool_out      WHEN "000",
    shift_out     WHEN "001",
    add_out       WHEN "010",
    carry_out     WHEN "011",
    prod_low_out  WHEN "100",
    prod_high_out WHEN "101",
    X"0000"       WHEN OTHERS;

END Behavioral;

