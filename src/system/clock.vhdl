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
USE work.components.ALL;

ENTITY clock_gen IS
  PORT (
    CLK_IN    : IN  STD_LOGIC;
    RESET     : IN  STD_LOGIC;
    CLK_VALID : OUT STD_LOGIC;
    CLK_OUT   : OUT STD_LOGIC
    );
END ENTITY clock_gen;

ARCHITECTURE Behavioral OF clock_gen IS

  COMPONENT clock_core_gen IS
    PORT (
      CLK_IN1   : IN  STD_LOGIC;
      CLK_OUT1  : OUT STD_LOGIC;
      RESET     : IN  STD_LOGIC;
      CLK_VALID : OUT STD_LOGIC
      );
  END COMPONENT clock_core_gen;

BEGIN  -- Behavioral

  MC : clock_core_gen PORT MAP (
    CLK_IN1   => CLK_IN,
    CLK_OUT1  => CLK_OUT,
    RESET     => RESET,
    CLK_VALID => CLK_VALID);

END Behavioral;
