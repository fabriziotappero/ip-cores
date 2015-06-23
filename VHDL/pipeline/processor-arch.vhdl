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


ARCHITECTURE ROFSM OF processor IS

  TYPE processor_state IS (P0, P1, P2);

  SIGNAL current_state : processor_state := P0;
  SIGNAL next_state    : processor_state := P0;

BEGIN  -- ARCHITECTURE ROFSM

  next_state_logic : PROCESS (current_state, FULL) IS
  BEGIN  -- PROCESS next_state_logic
    CASE current_state IS
      WHEN P0 =>
        IF FULL = '0' THEN
          next_state <= P0;
        ELSE
          next_state <= P1;
        END IF;
      WHEN P1 =>
        next_state <= P2;
      WHEN P2 =>
        next_state <= P1;
    END CASE;
  END PROCESS next_state_logic;

  state_register : PROCESS (CLK, RST) IS
  BEGIN  -- PROCESS next_state_logic
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        current_state <= P0;
      ELSE
        current_state <= next_state;
      END IF;
    END IF;

  END PROCESS state_register;

  output_logic : PROCESS (next_state) IS
  BEGIN  -- PROCESS next_state_logic
    CASE current_state IS
      WHEN P0 =>
        PULL <= '0';
      WHEN P1 =>
        PULL <= '1';
      WHEN P2 =>
        PULL <= '0';
    END CASE;

  END PROCESS output_logic;

END ARCHITECTURE ROFSM;
