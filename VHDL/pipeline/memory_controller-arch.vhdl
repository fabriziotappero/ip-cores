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


ARCHITECTURE mealy OF memory_controller IS

  TYPE state IS (S0, S1, S2);

  SIGNAL next_state    : state;
  SIGNAL current_state : state;

BEGIN  -- ARCHITECTURE mealy

  -- Next state logic
  PROCESS (current_state)
  BEGIN
    CASE current_state IS
      WHEN S0 =>
        next_state <= S1;
      WHEN S1 =>
        next_state <= S2;
      WHEN S2 =>
        next_state <= S2;
    END CASE;
  END PROCESS;

  -- State register logic
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

  -- Output signal logic
  PROCESS (current_state, RST, PULL)
  BEGIN
    CASE current_state IS
      WHEN S0 =>
        IF RST = '1' THEN
          SEL  <= "00";
          EN0  <= '0';
          EN1  <= '0';
          FULL <= '0';
        ELSE
          SEL  <= "00";
          EN0  <= '1';
          EN1  <= '0';
          FULL <= '0';
        END IF;
      WHEN S1 =>
        SEL  <= "10";
        EN0  <= '1';
        EN1  <= '1';
        FULL <= '0';
      WHEN S2 =>
        IF PULL = '0' THEN
          SEL  <= "01";
          EN0  <= '0';
          EN1  <= '0';
          FULL <= '1';
        ELSE
          SEL  <= "10";
          EN0  <= '1';
          EN1  <= '1';
          FULL <= '1';
        END IF;
    END CASE;
  END PROCESS;

END ARCHITECTURE mealy;
