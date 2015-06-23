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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY test_clock IS
END test_clock;

ARCHITECTURE behavior OF test_clock IS

  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT clock
    PORT(
      clock_in     : IN  STD_LOGIC;
      clock_out    : OUT STD_LOGIC;
      clock_locked : OUT STD_LOGIC
      );
  END COMPONENT;


  --Inputs
  SIGNAL clock_in : STD_LOGIC := '0';

  --Outputs
  SIGNAL clock_out    : STD_LOGIC;
  SIGNAL clock_locked : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clock_in_period     : TIME := 10 ns;
  CONSTANT clock_out_period    : TIME := 10 ns;
  CONSTANT clock_locked_period : TIME := 10 ns;
  
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : clock PORT MAP (
    clock_in     => clock_in,
    clock_out    => clock_out,
    clock_locked => clock_locked
    );

  -- Clock process definitions
  clock_in_process : PROCESS
  BEGIN
    clock_in <= '0';
    WAIT FOR clock_in_period/2;
    clock_in <= '1';
    WAIT FOR clock_in_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;

    WAIT FOR clock_in_period*10;

    -- insert stimulus here 

    WAIT;
  END PROCESS;

END;
