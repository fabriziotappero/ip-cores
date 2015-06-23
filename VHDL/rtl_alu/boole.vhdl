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
USE IEEE.numeric_std.ALL;

ENTITY boole IS
  
  PORT (
    A   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    B   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    X   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    SEL : IN  STD_LOGIC_VECTOR(3 DOWNTO 0));

END boole;

ARCHITECTURE dataflow OF boole IS

  SIGNAL product : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN  -- dataflow

  product <= STD_LOGIC_VECTOR(UNSIGNED(A) * UNSIGNED(B));
  
  WITH SEL SELECT
    X <=
    A        WHEN "0000",
    NOT A    WHEN "0001",
    B        WHEN "0010",
    NOT B    WHEN "0011",
    A AND B  WHEN "0100",
    A OR B   WHEN "0101",
    A NAND B WHEN "0110",
    A NOR B  WHEN "0111",
    A XOR B  WHEN "1000",
    A XNOR B WHEN "1001",
    STD_LOGIC_VECTOR(unsigned(A) + unsigned(B)) WHEN "1010",
    STD_LOGIC_VECTOR(unsigned(A) - unsigned(B)) WHEN "1011",
    product(15 DOWNTO 0) WHEN "1100",
    product(31 DOWNTO 16) WHEN "1101",
    A(0) & A(15 DOWNTO 1) WHEN "1110",
    A(14 DOWNTO 0) & A(15) WHEN "1111";

END dataflow;
