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

ENTITY test_queue IS
END test_queue;

ARCHITECTURE behavior OF test_queue IS

  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT queue
    GENERIC (
      w_data : NATURAL := 16);
    PORT(
      d    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      q    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      clk  : IN  STD_LOGIC;
      we   : IN  STD_LOGIC;
      sh   : IN  STD_LOGIC;
      full : OUT STD_LOGIC;
      rst  : IN  STD_LOGIC
      );
  END COMPONENT;


  --Inputs
  SIGNAL data_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL clock   : STD_LOGIC                    := '0';
  SIGNAL wr      : STD_LOGIC                    := '0';
  SIGNAL sh      : STD_LOGIC                    := '0';
  SIGNAL reset   : STD_LOGIC                    := '0';

  --Outputs
  SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL full     : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clock_period : TIME := 5.2 ns;
  
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : queue
    GENERIC MAP (
      w_data => 8)
    PORT MAP (
      d    => data_in,
      q    => data_out,
      clk  => clock,
      we   => wr,
      sh   => sh,
      full => full,
      rst  => reset
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

    reset <= '1';
    WAIT FOR 10 * clock_period;
    reset <= '0';

    WAIT FOR clock_period*10;

    wr <= '1';

    data_in <= X"00";
    WAIT FOR clock_period;

    data_in <= X"11";
    WAIT FOR clock_period;

    data_in <= X"22";
    WAIT FOR clock_period;

    data_in <= X"33";
    WAIT FOR clock_period;

    data_in <= X"44";
    WAIT FOR clock_period;

    data_in <= X"55";
    WAIT FOR clock_period;

    data_in <= X"66";
    WAIT FOR clock_period;

    data_in <= X"77";
    WAIT FOR clock_period;

    wr <= '0';
    WAIT FOR clock_period;

    data_in <= X"00";
    sh      <= '1';
    WAIT FOR clock_period * 8;

    data_in <= X"11";
    wr      <= '1';
    sh      <= '1';
    WAIT FOR clock_period;

    data_in <= X"22";
    wr      <= '1';
    sh      <= '0';
    WAIT FOR clock_period;

    data_in <= X"33";
    wr      <= '1';
    sh      <= '0';
    WAIT FOR clock_period;

    data_in <= X"33";
    wr      <= '1';
    sh      <= '1';
    WAIT FOR clock_period;

    WAIT FOR clock_period * 8;

    WAIT;
  END PROCESS;

END;
