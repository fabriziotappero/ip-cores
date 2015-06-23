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

ENTITY tb_rom IS
END tb_rom;

ARCHITECTURE behavior OF tb_rom IS

  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT test_rom
    PORT(
      clk : IN  STD_LOGIC;
      rst : IN  STD_LOGIC;
      led : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
  END COMPONENT;


  --Inputs
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '0';

  --Outputs
  SIGNAL led : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : TIME := 10 ns;
  
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : test_rom PORT MAP (
    clk => clk,
    rst => rst,
    led => led
    );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;


  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    rst <= '1';
    WAIT FOR 100 ns;
    rst <= '0';

    WAIT FOR clk_period*10;

    -- insert stimulus here 

    WAIT;
  END PROCESS;

END;
