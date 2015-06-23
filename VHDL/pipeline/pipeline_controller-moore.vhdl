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


ARCHITECTURE moore OF pipeline_controller IS

  TYPE pl_state IS (S0, S1, S2, S3, S4, S5);

  SIGNAL next_state   : pl_state := S0;
  SIGNAL pl_state_reg : pl_state := S0;

BEGIN  -- ARCHITECTURE moore

-- purpose: compute next state from current state
  -- type   : combinational
  -- inputs : pl_state_reg
  -- outputs: next_state
  next_state_logic : PROCESS (pl_state_reg, PULL) IS
  BEGIN  -- PROCESS next_state_logic
    CASE pl_state_reg IS
      WHEN S0 =>
        next_state <= S1;
      WHEN S1 =>
        next_state <= S2;
      WHEN S2 =>
        next_state <= S3;
      WHEN S3 =>
        next_state <= S4;
      WHEN S4 =>
        IF PULL = '0' THEN
          next_state <= S4;
        ELSE
          next_state <= S5;
        END IF;
      WHEN S5 =>
        next_state <= S4;
    END CASE;
  END PROCESS next_state_logic;

  -- purpose: State register
  -- type   : sequential
  -- inputs : CLK, RST, next_state
  -- outputs: pl_state_reg
  state_register : PROCESS (CLK, RST) IS
  BEGIN  -- PROCESS state_register
    IF rising_edge(CLK) THEN            -- rising clock edge
      IF RST = '1' THEN
        pl_state_reg <= S0;
      ELSE
        pl_state_reg <= next_state;
      END IF;
    END IF;
  END PROCESS state_register;

  -- purpose: compute outputs based on state
  -- type   : combinational
  -- inputs : pl_state_reg
  -- outputs: EN(0),EN(1),EN(2)
  output_logic : PROCESS (pl_state_reg) IS
  BEGIN  -- PROCESS output_logic
    CASE pl_state_reg IS
      WHEN S0 =>                        -- Reset state
        SUM   <= '0';
        EN(0) <= '0';
        EN(1) <= '0';
        EN(2) <= '0';
        FULL  <= '0';
      WHEN S1 =>  -- Load first register with initial value
        SUM   <= '0';
        EN(0) <= '1';
        EN(1) <= '0';
        EN(2) <= '0';
        FULL  <= '0';
      WHEN S2 =>  -- Start increment and fill second stage
        SUM   <= '1';
        EN(0) <= '1';
        EN(1) <= '1';
        EN(2) <= '0';
        FULL  <= '0';
      WHEN S3 =>                        -- Fill last stage
        SUM   <= '1';
        EN(0) <= '1';
        EN(1) <= '1';
        EN(2) <= '1';
        FULL  <= '0';
      WHEN S4 =>                        -- Pipeline full
        SUM   <= '0';
        EN(0) <= '0';
        EN(1) <= '0';
        EN(2) <= '0';
        FULL  <= '1';
      WHEN S5 =>                        -- Execute pull request
        SUM   <= '1';
        EN(0) <= '1';
        EN(1) <= '1';
        EN(2) <= '1';
        FULL  <= '1';
    END CASE;
  END PROCESS output_logic;

END ARCHITECTURE moore;
