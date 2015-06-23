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

ENTITY queue IS
  
  PORT (
    data_in  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clock    : IN  STD_LOGIC;
    wr       : IN  STD_LOGIC;
    sh       : IN  STD_LOGIC;
    reset    : IN  STD_LOGIC);

END queue;

ARCHITECTURE Behavioral OF queue IS

  -- Datapath declarations

  TYPE queue_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL queue : queue_t;

  -- Control path declarations

  SUBTYPE cntr_t IS INTEGER RANGE 0 TO 4;

  SIGNAL i      : cntr_t := 0;
  SIGNAL i_next : cntr_t := 0;

BEGIN  -- Behavioral

  -- Datapath

  -- Control path
  -- purpose: Control the queue
  -- type   : sequential
  -- inputs : clock, reset, wr
  -- outputs: 
  control : PROCESS (clock, reset)
  BEGIN  -- PROCESS control
    IF rising_edge(clock) THEN          -- rising clock edge
      IF reset = '1' THEN               -- synchronous reset (active high)
        i <= 0;
      ELSE
        i <= i_next;
      END IF;
    END IF;
  END PROCESS control;

  -- purpose: Implement the queue
  -- type   : sequential
  -- inputs : clock, reset, wr, sh
  -- outputs: out
  data: PROCESS (clock, reset)
  BEGIN  -- PROCESS data
    IF rising_edge(clock) THEN  -- rising clock edge
      CASE i IS
        WHEN 0 =>
          IF wr = '1' AND sh = '0' THEN
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= data_in;
            i_next   <= 1;
          ELSIF wr = '0' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 0;
          ELSIF wr = '1' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 0;
          ELSE    
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 0;
          END IF;
        WHEN 1 =>
          IF wr = '1' AND sh = '0' THEN
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= data_in;
            queue(0) <= queue(0);
            i_next   <= 2;
          ELSIF wr = '0' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 0;
          ELSIF wr = '1' AND sh = '1' THEN
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= data_in;
            i_next   <= 1;
          ELSE    
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 1;
          END IF;
        WHEN 2 =>
          IF wr = '1' AND sh = '0' THEN
            queue(3) <= queue(3);
            queue(2) <= data_in;
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 3;
          ELSIF wr = '0' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 1;
          ELSIF wr = '1' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= data_in;
            queue(0) <= queue(1);
            i_next   <= 2;
          ELSE    
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 2;
          END IF;
        WHEN 3 =>
          IF wr = '1' AND sh = '0' THEN
            queue(3) <= data_in;
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 4;
          ELSIF wr = '0' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 2;
          ELSIF wr = '1' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= data_in;
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 3;
          ELSE    
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 3;
          END IF;
        WHEN 4 =>
          IF wr = '1' AND sh = '0' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 4;
          ELSIF wr = '0' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 3;
          ELSIF wr = '1' AND sh = '1' THEN
            queue(3) <= data_in;
            queue(2) <= queue(3);
            queue(1) <= queue(2);
            queue(0) <= queue(1);
            i_next   <= 4;
          ELSE    
            queue(3) <= queue(3);
            queue(2) <= queue(2);
            queue(1) <= queue(1);
            queue(0) <= queue(0);
            i_next   <= 4;
          END IF;
      END CASE;
    END IF;
  END PROCESS data;

  data_out <= queue(0);

END Behavioral;
