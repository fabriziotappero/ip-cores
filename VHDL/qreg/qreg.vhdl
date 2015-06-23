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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY qreg IS
  GENERIC (
    w_data : NATURAL := 16);
  PORT (D0  : IN  STD_LOGIC_VECTOR(w_data -1 DOWNTO 0);
        D1  : IN  STD_LOGIC_VECTOR(w_data -1 DOWNTO 0);
        S   : IN  STD_LOGIC;
        EN  : IN  STD_LOGIC;
        CLK : IN  STD_LOGIC;
        RST : IN  STD_LOGIC;
        Q   : OUT STD_LOGIC_VECTOR(w_data -1 DOWNTO 0));
END qreg;

ARCHITECTURE Behavioral_2 OF qreg IS

BEGIN

  -- purpose: Register with multiplexed input
  -- type   : sequential
  -- inputs : CLK,D0,D1,S,EN
  -- outputs: Q
  qreg : PROCESS (CLK)
  BEGIN  -- PROCESS qreg
    IF rising_edge(CLK) THEN            -- rising clock edge
      IF RST = '1' THEN
        Q <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data));
      ELSE
        IF EN = '1' THEN
          IF S = '0' THEN
            Q <= D0;
          ELSE
            Q <= D1;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS qreg;

END Behavioral_2;
