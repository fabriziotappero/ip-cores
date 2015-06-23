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

ENTITY reset IS
  
  PORT (
    RST : OUT STD_LOGIC);

END ENTITY reset;

ARCHITECTURE Behavioral OF reset IS

BEGIN  -- ARCHITECTURE Behavioral

    -- purpose: Reset generator
  --          This is simulation only
  -- type   : combinational
  -- inputs : 
  -- outputs: RST
  PROCESS IS
  BEGIN  -- PROCESS
    WAIT FOR 21 NS;
    RST <= '1';

    WAIT FOR 31 NS;
    RST <= '0';

    WAIT;
  END PROCESS;


END ARCHITECTURE Behavioral;
