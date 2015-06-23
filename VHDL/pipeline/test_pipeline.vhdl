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

ENTITY test_pipeline IS

END ENTITY test_pipeline;

ARCHITECTURE Structural OF test_pipeline IS

  COMPONENT pipeline_controller IS

    PORT (
    CLK  : IN  STD_LOGIC;
    RST  : IN  STD_LOGIC;
    SUM  : OUT STD_LOGIC;
    EN   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    FULL : OUT STD_LOGIC;
    PULL : IN  STD_LOGIC);

  END COMPONENT pipeline_controller;

  COMPONENT pipeline_reg IS

    PORT (
      D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      CLK : IN  STD_LOGIC;
      EN  : IN  STD_LOGIC);

  END COMPONENT pipeline_reg;

  COMPONENT processor IS

    PORT (
      CLK  : IN  STD_LOGIC;
      RST  : IN  STD_LOGIC;
      FULL : IN  STD_LOGIC;
      PULL : OUT STD_LOGIC;
      D_IN : IN  STD_LOGIC_VECTOR(7 DOWNTO 0));

  END COMPONENT processor;

  SIGNAL clock : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';

  SIGNAL D0 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Q0 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL D1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Q1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL D2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Q2 : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL EN : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  SIGNAL SUM : STD_LOGIC;

  SIGNAL FULL : STD_LOGIC;
  SIGNAL PULL : STD_LOGIC;

BEGIN  -- ARCHITECTURE Structural

  -- purpose: Clock generator
  --          This is simulation only
  -- type   : combinational
  -- inputs : 
  -- outputs: clock
  PROCESS IS
  BEGIN  -- PROCESS
    WAIT FOR 10 NS;
    clock <= '1';

    WAIT FOR 10 NS;
    clock <= '0';

  END PROCESS;

  -- purpose: Reset generator
  --          This is simulation only
  -- type   : combinational
  -- inputs : 
  -- outputs: RST
  PROCESS IS
  BEGIN  -- PROCESS
    WAIT FOR 17 NS;
    reset <= '1';

    WAIT FOR 31 NS;
    reset <= '0';

    WAIT;
  END PROCESS;

  -- End of simulation part

  -- Start of structural part

  -- purpose: Incrementing circuit
  -- type   : combinational
  -- inputs : Q0 (output from first pipeline register)
  -- outputs: D0 (input to first pipeline register)
  PROCESS (Q0, SUM) IS
  BEGIN  -- PROCESS
    IF SUM = '0' THEN
      D0 <= "00000000";
    ELSE
      IF Q0 = "11111111" THEN
        D0 <= "00000000";
      ELSE
        D0 <= STD_LOGIC_VECTOR(UNSIGNED(Q0) + 1);
      END IF;
    END IF;
  END PROCESS;

  -- Pipeline registers
  R0 : pipeline_reg PORT MAP (
    D   => D0,
    Q   => Q0,
    CLK => clock,
    EN  => EN(0));

  R1 : pipeline_reg PORT MAP (
    D   => D1,
    Q   => Q1,
    CLK => clock,
    EN  => EN(1));

  R2 : pipeline_reg PORT MAP (
    D   => D2,
    Q   => Q2,
    CLK => clock,
    EN  => EN(2));

  -- Interconnect pipeline registers
  D1 <= Q0;
  D2 <= Q1;

  CTRL : pipeline_controller PORT MAP (
    CLK  => clock,
    RST  => reset,
    SUM  => SUM,
    EN   => EN,
    FULL => FULL,
    PULL => PULL);

  PR1 : processor PORT MAP (
    CLK  => clock,
    RST  => reset,
    FULL => FULL,
    PULL => PULL,
    D_IN => Q2);

END ARCHITECTURE Structural;
