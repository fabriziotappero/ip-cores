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

ENTITY shift IS
  GENERIC (
    width : NATURAL := 16);
  PORT (A   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
        B   : IN  STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
        X   : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
        SEL : IN  STD_LOGIC_VECTOR (2 DOWNTO 0));
END shift;

ARCHITECTURE Behavioral OF shift IS

BEGIN

  WITH SEL SELECT
    X <=
    A(0) & A(width - 1 DOWNTO 1)         WHEN "000",
    '0' & A(width - 1 DOWNTO 1)          WHEN "001",
    A(width - 2 DOWNTO 0) & A(width - 1) WHEN "010",
    A(width - 2 DOWNTO 0) & '0'          WHEN "011",
    A(width - 1) & A(width - 1 DOWNTO 1) WHEN "100",
    X"0000"                              WHEN OTHERS;


END Behavioral;

