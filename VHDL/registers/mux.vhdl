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
USE ieee.std_logic_1164.ALL;

ENTITY multiplexer IS
  
  PORT (
    SEL : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END ENTITY multiplexer;

ARCHITECTURE Descriptive OF multiplexer IS

BEGIN  -- ARCHITECTURE Descriptive

  WITH SEL SELECT
    Y <=
    S0 WHEN "00",
    S1 WHEN "01",
    S2 WHEN "10",
    S3 WHEN "11",
    S0 WHEN OTHERS;

END ARCHITECTURE Descriptive;
