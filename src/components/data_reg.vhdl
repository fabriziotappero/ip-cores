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
USE ieee.numeric_std.ALL;

ENTITY data_reg IS
  
  GENERIC (
    w_data      : NATURAL := 16;
    reset_value : NATURAL := 0);

  PORT (
    RST : IN  STD_LOGIC;
    CLK : IN  STD_LOGIC;
    ENA : IN  STD_LOGIC;
    D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END ENTITY data_reg;

ARCHITECTURE Behavioral OF data_reg IS

BEGIN  -- ARCHITECTURE Behavioral

  -- purpose: Data register with synchronous reset
  -- type   : sequential
  -- inputs : CLK, RST, ENA, D
  -- outputs: Q
  DREG : PROCESS (CLK) IS
  BEGIN  -- PROCESS DREG
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        Q <= STD_LOGIC_VECTOR(to_unsigned(reset_value, w_data));
      ELSE
        IF ENA = '1' THEN
          Q <= D;
        END IF;
      END IF;
    END IF;
  END PROCESS DREG;

END ARCHITECTURE Behavioral;

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_reg_2 IS
  
  GENERIC (
    w_data      : NATURAL := 16;
    reset_value : NATURAL := 0);

  PORT (
    CLK : IN  STD_LOGIC;
    D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END ENTITY data_reg_2;

ARCHITECTURE Behavioral OF data_reg_2 IS

BEGIN  -- ARCHITECTURE Behavioral

  -- purpose: Data register with synchronous reset
  -- type   : sequential
  -- inputs : CLK, RST, ENA, D
  -- outputs: Q
  DREG : PROCESS (CLK) IS
  BEGIN  -- PROCESS DREG
    IF rising_edge(CLK) THEN
          Q <= D;
    END IF;
  END PROCESS DREG;

END ARCHITECTURE Behavioral;
