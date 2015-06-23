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


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;

ENTITY alu IS
  GENERIC(
    w_data : NATURAL RANGE 1 TO 32 := 16);
  PORT(
    op : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    A  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    B  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  FUNCTION alu_add (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    SIGNAL B : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION alu_add(
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    SIGNAL B : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN  -- alu_add
    RETURN STD_LOGIC_VECTOR(UNSIGNED(A) + UNSIGNED(B));
  END alu_add;

  FUNCTION alu_sub (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    SIGNAL B : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION alu_sub(
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    SIGNAL B : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN  -- alu_sub
    RETURN STD_LOGIC_VECTOR(UNSIGNED(A) - UNSIGNED(B));
  END alu_sub;

  FUNCTION alu_inc (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION alu_inc (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(UNSIGNED(A) + 1);
  END alu_inc;

  FUNCTION alu_dec (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION alu_dec (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(UNSIGNED(A) - 1);
  END alu_dec;

  FUNCTION shift_left (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION shift_left (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(shift_left(UNSIGNED(A), 1));
  END shift_left;

  FUNCTION shift_right (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

  FUNCTION shift_right (
    SIGNAL A : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(shift_right(UNSIGNED(A), 1));
  END shift_right;

END ENTITY alu;

ARCHITECTURE Behavioral OF alu IS

  CONSTANT ZERO : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0)
    := STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data));
  CONSTANT ONE : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0)
    := STD_LOGIC_VECTOR(TO_UNSIGNED(1, w_data));

BEGIN  -- ARCHITECTURE Behavioral

  WITH op SELECT
    y <=
    alu_inc(A)     WHEN "0000",
    alu_dec(A)     WHEN "0001",
    ZERO           WHEN "0010",         -- Place holder
    ONE            WHEN "0011",         -- Place holder
    B WHEN "0100",
    A WHEN "0101",                      -- Place holder
    A WHEN "0110",                      -- Place holder
    alu_add(A, B)  WHEN "0111",
    alu_sub(A, B)  WHEN "1000",
    A WHEN "1001",                      -- Place holder
    A AND B        WHEN "1010",
    A OR B         WHEN "1011",
    A XOR B        WHEN "1100",
    NOT A          WHEN "1101",
    shift_left(A)  WHEN "1110",
    shift_right(A) WHEN "1111",
    A WHEN OTHERS;

END ARCHITECTURE Behavioral;
