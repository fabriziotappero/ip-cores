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
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY mux8to1 IS
  
  GENERIC (
    width : NATURAL := 1);

  PORT (
    S0  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S4  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S5  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S6  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    S7  : IN  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
    sel : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));

END mux8to1;

--ARCHITECTURE component_based OF mux4to1 IS

--BEGIN

--  MUX1 :
--  FOR i IN width - 1 DOWNTO 0 GENERATE
--    MUX : LUT6
--      GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
--      PORT MAP(I0 => S0(i),
--               I1 => S1(i),
--               I2 => S2(i),
--               I3 => S3(i),
--               I4 => sel(0),
--               I5 => sel(1),
--               O  => Y(i));
--  END GENERATE MUX1;

--END component_based;

ARCHITECTURE Behavioral OF mux8to1 IS

BEGIN  -- Behavioral

  WITH sel SELECT
    Y <=
    S0 WHEN "000",
    S1 WHEN "001",
    S2 WHEN "010",
    S3 WHEN "011",
    S4 WHEN "100",
    S5 WHEN "101",
    S6 WHEN "110",
    S7 WHEN "111";
    
END Behavioral;
