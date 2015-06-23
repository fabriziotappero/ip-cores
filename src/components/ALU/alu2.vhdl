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

-- Clocked ALU
-- To make the clock cycle shorter, the result between the operation output and
-- the selection multiplexer is clocked.

ENTITY alu IS
  GENERIC(
    w_data : NATURAL RANGE 1 TO 32 := 16);
  PORT(
    clk : IN  STD_LOGIC;
    op  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    A   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    B   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

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

  SIGNAL R_INC  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_DEC  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_ZERO : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_ONE  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_B    : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_A    : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_ADD  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_SUB  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_AND  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_OR   : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_XOR  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_NOT  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_SLL  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL R_SRL  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);


BEGIN  -- ARCHITECTURE Behavioral

  PROCESS (CLK)
  BEGIN
    IF rising_edge(CLK) THEN

      R_INC  <= alu_inc(A);
      R_DEC  <= alu_dec(A);
      R_ZERO <= ZERO;
      R_ONE  <= ONE;
      R_B    <= B;
      R_A    <= A;
      R_ADD  <= alu_add(A, B);
      R_SUB  <= alu_sub(A, B);
      R_AND  <= A AND B;
      R_OR   <= A OR B;
      R_XOR  <= A XOR B;
      R_NOT  <= NOT A;
      R_SLL  <= shift_left(A);
      R_SRL  <= shift_right(A);

    END IF;
  END PROCESS;

  WITH op SELECT
    y <=
    R_INC  WHEN "0000",
    R_DEC  WHEN "0001",
    R_ZERO WHEN "0010",                 -- Place holder
    R_ONE  WHEN "0011",                 -- Place holder
    R_B    WHEN "0100",
    R_A    WHEN "0101",                 -- Place holder
    R_A    WHEN "0110",                 -- Place holder
    R_ADD  WHEN "0111",
    R_SUB  WHEN "1000",
    R_A    WHEN "1001",                 -- Place holder
    R_AND  WHEN "1010",
    R_OR   WHEN "1011",
    R_XOR  WHEN "1100",
    R_NOT  WHEN "1101",
    R_SLL  WHEN "1110",
    R_SRL  WHEN "1111",
    R_A    WHEN OTHERS;

END ARCHITECTURE Behavioral;
