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


ARCHITECTURE mealy OF memory_processor IS

  TYPE state IS (S0, S1, S2, S3);

  SIGNAL current_state : state;
  SIGNAL next_state    : state;

BEGIN  -- ARCHITECTURE mealy

  -- Mealy machine input combinational logic: next state
  PROCESS (current_state, FULL)
  BEGIN
    CASE current_state IS
      WHEN S0 =>
        IF FULL = '0' THEN
          next_state <= S0;
        ELSE
          next_state <= S1;
        END IF;
      WHEN S1 =>
        next_state <= S2;
      WHEN S2 =>
        next_state <= S3;
      WHEN S3 =>
        next_state <= S3;
    END CASE;
  END PROCESS;

  -- Mealy machine sequential state logic
  PROCESS (CLK, RST)
  BEGIN
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        current_state <= S0;
      ELSE
        current_state <= next_state;
      END IF;
    END IF;
  END PROCESS;

  -- Mealy machine output combinational logic
  PROCESS (current_state, FULL)
  BEGIN
    CASE current_state IS
      WHEN S0 =>
        IF full = '0' THEN
          PULL <= '0';
        ELSE
          PULL <= '1';
        END IF;
      WHEN S1 =>
        PULL <= '0';
      WHEN S2 =>
        PULL <= '0';
      WHEN S3 =>
        PULL <= '0';
    END CASE;
  END PROCESS;

END ARCHITECTURE mealy;
