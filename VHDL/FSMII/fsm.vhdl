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

ENTITY FSM IS
END ENTITY FSM;

ARCHITECTURE Descriptive OF FSM IS

  TYPE fsm_state IS (S0, S1, S2, S3, S0a);
  TYPE direction IS (FORWARD, BACKWARD);

  SIGNAL state_reg : fsm_state := S0;

  -- Driving signals
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RST : STD_LOGIC;

  -- Combinational signals
  SIGNAL T0 : STD_LOGIC;
  SIGNAL T1 : STD_LOGIC;
  SIGNAL T2 : STD_LOGIC;
  SIGNAL T3 : STD_LOGIC;

  SIGNAL F01 : STD_LOGIC;
  SIGNAL F12 : STD_LOGIC;
  SIGNAL F23 : STD_LOGIC;

  SIGNAL B32 : STD_LOGIC;
  SIGNAL B21 : STD_LOGIC;
  SIGNAL B10 : STD_LOGIC;

  SIGNAL LS0 : STD_LOGIC;

  SIGNAL next_state : fsm_state := S0;
  SIGNAL flow       : direction := FORWARD;
  SIGNAL flow_in    : direction := FORWARD;

BEGIN  -- ARCHITECTURE Descriptive

  -- Driving signals for simulation
  C1 : PROCESS IS
  BEGIN  -- PROCESS C1
    CLK <= '0';
    WAIT FOR 100 NS;
    CLK <= '1';
    WAIT FOR 100 NS;
  END PROCESS C1;

  R1 : PROCESS IS
  BEGIN  -- PROCESS R1
    RST <= '0';
    WAIT FOR 30 NS;
    RST <= '1';
    WAIT FOR 600 NS;
    RST <= '0';
    WAIT;
  END PROCESS R1;

  -- Sequential part of FSM
  SEQ : PROCESS (clk, rst) IS
  BEGIN  -- PROCESS SEQ
    IF rising_edge(CLK) THEN            -- rising clock edge
      IF RST = '1' THEN
        state_reg <= S0;
        flow      <= FORWARD;
      ELSE
        state_reg <= next_state;

        IF flow = FORWARD AND flow_in = FORWARD THEN
          flow <= FORWARD;
        ELSE
          flow <= BACKWARD;
        END IF;
        
      END IF;
    END IF;
  END PROCESS SEQ;

  -- Combinational part of the FSM
  PROCESS (state_reg, flow, next_state) IS
  BEGIN  -- PROCESS

    T0 <= '0';
    T1 <= '0';
    T2 <= '0';
    T3 <= '0';

    F01 <= '0';
    F12 <= '0';
    F23 <= '0';

    B32 <= '0';
    B21 <= '0';
    B10 <= '0';

    LS0 <= '0';

    CASE state_reg IS
      WHEN S0 =>
        T0 <= '1';

        IF flow = FORWARD THEN
          next_state <= S1;
        ELSE
          next_state <= S0;
        END IF;

        IF state_reg = S0 AND next_state = S1 THEN
          F01 <= '1';
        END IF;

      WHEN S0a =>
        T0 <= '1';
        next_state <= S0;
        LS0 <= '1';
        
      WHEN S1 =>
        T1 <= '1';

        IF flow = FORWARD THEN
          next_state <= S2;
        ELSE
          next_state <= S0a;
        END IF;

        IF state_reg = S1 AND next_state = S2 THEN
          F12 <= '1';
        ELSIF state_reg = S1 AND next_state = S0a THEN
          B10 <= '1';
        END IF;

      WHEN S2 =>
        T2 <= '1';

        IF flow = FORWARD THEN
          next_state <= S3;
        ELSE
          next_state <= S1;
        END IF;

        IF state_reg = S2 AND next_state = S3 THEN
          F23 <= '1';
        ELSIF state_reg = S2 AND next_state = S1 THEN
          B21 <= '1';
        END IF;

      WHEN S3 =>
        T3         <= '1';
        next_state <= S2;

        IF flow = FORWARD THEN
          flow_in <= BACKWARD;
        END IF;

        IF state_reg = S3 AND next_state = S2 THEN
          B32 <= '1';
        END IF;
    END CASE;
  END PROCESS;

END ARCHITECTURE Descriptive;
