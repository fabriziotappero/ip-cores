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

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY mux2to1 IS

  GENERIC (
    width : NATURAL := 16);

  PORT (
    I0 : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    I1 : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S  : IN  STD_LOGIC;
    O  : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));

END mux2to1;

--ARCHITECTURE Behavioral OF mux2to1 IS

--BEGIN

--  MUX1 :
--  FOR i IN width - 1 DOWNTO 0 GENERATE
--    MUXF7_inst : MUXF7
--      PORT MAP (O  => O(i),
--                I0 => I0(i),
--                I1 => I1(i),
--                S  => S);
--  END GENERATE MUX1;
  
--END Behavioral;

ARCHITECTURE instantiated OF mux2to1 IS

BEGIN

  MUX1 :
  FOR i IN width - 1 DOWNTO 0 GENERATE
    MUX : LUT6
      GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
      PORT MAP(I0 => I0(i),
               I1 => I1(i),
               I2 => '0',
               I3 => '0',
               I4 => S,
               I5 => '0',
               O  => O(i));
  END GENERATE MUX1;

END instantiated;
