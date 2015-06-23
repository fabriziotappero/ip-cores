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

ENTITY startup_sim IS
END startup_sim;

ARCHITECTURE behavior OF startup_sim IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT system
    PORT(
      clock     : IN  STD_LOGIC;
      reset     : IN  STD_LOGIC;
      led_out   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      switch_in : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      pushb_in  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0)
      );
  END COMPONENT;


  --Inputs
  SIGNAL clock     : STD_LOGIC                    := '0';
  SIGNAL reset     : STD_LOGIC                    := '0';
  SIGNAL switch_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10101101";
  SIGNAL pushb_in  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10101";

  --Outputs
  SIGNAL led_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Clock period definitions
  -- 100 MHz input clock
  CONSTANT clock_period : TIME := 10 NS;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : system PORT MAP (
    clock     => clock,
    reset     => reset,
    led_out   => led_out,
    switch_in => switch_in,
    pushb_in  => pushb_in
    );

  -- Clock process definitions
  clock_process : PROCESS
  BEGIN
    clock <= '0';
    WAIT FOR clock_period/2;
    clock <= '1';
    WAIT FOR clock_period/2;
  END PROCESS;


  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- Undefined state for 2.3 clock cycles
    WAIT FOR clock_period * 23 / 10;

    -- Hold reset state for 4 clock cycles
    reset <= '1';
    WAIT FOR clock_period * 4;

    reset <= '0';
    WAIT;
  END PROCESS;

END;
