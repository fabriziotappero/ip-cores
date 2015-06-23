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
USE work.ram_parts.ALL;
USE work.mux_parts.ALL;

ENTITY tb_prod_cons IS
END ENTITY tb_prod_cons;

ARCHITECTURE Structural OF tb_prod_cons IS

  COMPONENT queue IS
    GENERIC (
      w_data : NATURAL := 16);
    PORT (
      rst   : IN  STD_LOGIC;
      clk   : IN  STD_LOGIC;
      we    : IN  STD_LOGIC;
      sh    : IN  STD_LOGIC;
      full  : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      d     : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      q     : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT queue;

  SIGNAL clock : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';

  SIGNAL PC      : INTEGER RANGE 0 TO 1023 := 0;
  SIGNAL address : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL IR      : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ENA     : STD_LOGIC;

  SIGNAL QF  : STD_LOGIC;
  SIGNAL NQF : STD_LOGIC;

  SIGNAL get : STD_LOGIC;
  SIGNAL c3  : INTEGER RANGE 0 TO 2;

BEGIN  -- ARCHITECTURE Structural

  -- Clock generator 50 MHz
  CLK1 : PROCESS IS
  BEGIN  -- PROCESS CLK1
    WAIT FOR 10 NS;
    clock <= '1';
    WAIT FOR 10 NS;
    clock <= '0';
  END PROCESS CLK1;

  -- Reset signaal
  RST1 : PROCESS IS
  BEGIN  -- PROCESS RST1
    WAIT FOR 65 NS;
    reset <= '1';
    WAIT FOR 120 NS;
    reset <= '0';
    WAIT;
  END PROCESS RST1;

  -- Programma teller met synchrone reset
  PC_CTR : PROCESS (clock, reset) IS
  BEGIN  -- PROCESS PC_CTR
    IF rising_edge(clock) THEN          -- rising clock edge
      IF reset = '1' THEN
        PC <= 0;
      ELSE
        IF ENA = '1' THEN
          IF PC < 1023 THEN
            PC <= PC + 1;
          ELSE
            PC <= 0;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS PC_CTR;

  address <= STD_LOGIC_VECTOR(TO_UNSIGNED(PC, 10));

  RAM1 : generic_ram
    GENERIC MAP (
      filename => "random_data.txt")
    PORT MAP (
      clk => clock,
      we  => '0',
      a1  => address(9 DOWNTO 0),
      a2  => "0000000000",
      d1  => X"0000",
      q1  => IR,
      q2  => OPEN);

  queue1 : queue
    PORT MAP (
      rst   => reset,
      clk   => clock,
      we    => ENA,
      sh    => get,
      full  => QF,
      empty => OPEN,
      d     => IR,
      q     => OPEN);

  ENA <= NOT QF;

  -- Consumer
  -- Generate a shift every three clockcycles
  -- Programma teller met synchrone reset
  GET_CTR : PROCESS (clock, reset) IS
  BEGIN  -- PROCESS GET_CTR
    IF rising_edge(clock) THEN          -- rising clock edge
      
      get <= '0';

      IF reset = '1' THEN

        C3 <= 0;

      ELSE

        IF c3 = 0 THEN
          c3 <= 1;
        ELSE
          c3 <= 0;
        END IF;

        IF C3 = 1 THEN
          get <= '1';
        END IF;

      END IF;
    END IF;
  END PROCESS GET_CTR;

END ARCHITECTURE Structural;
