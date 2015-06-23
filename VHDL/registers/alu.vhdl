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

ENTITY ALU IS
  
  PORT (
    I1 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    I2 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    R1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    F1 : IN  STD_LOGIC_VECTOR(1 DOWNTO 0));

END ENTITY ALU;

ARCHITECTURE Behavioral OF ALU IS

BEGIN  -- ARCHITECTURE Behavioral

  PROCESS (I1, I2, F1)
  BEGIN
    CASE F1 IS
      WHEN "00" =>
        R1 <= "00000000";
      WHEN "01" =>
        R1 <= STD_LOGIC_VECTOR(UNSIGNED(I1) + UNSIGNED(I2));
      WHEN "10" =>
        R1 <= STD_LOGIC_VECTOR(UNSIGNED(I1) + 1);
      WHEN "11" =>
        R1 <= "11111111";
      WHEN OTHERS
        => NULL;
    END CASE;
      
  END PROCESS;

END ARCHITECTURE Behavioral;
