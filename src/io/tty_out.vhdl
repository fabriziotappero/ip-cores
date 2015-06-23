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


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.system_package.ALL;

ENTITY tty_out IS
  PORT (
    reset    : IN  STD_LOGIC;
    clock    : IN  STD_LOGIC;
    rd       : IN  STD_LOGIC;
    wr       : IN  STD_LOGIC;
    data_in  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    address  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
    tx       : OUT STD_LOGIC);
END tty_out;

ARCHITECTURE Behavioral OF tty_out IS

  SIGNAL data   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL status : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

  -- purpose: Base system for serial out state machine
  -- type   : sequential
  -- inputs : clock, reset
  -- outputs: 
  main : PROCESS (clock, reset)
  BEGIN  -- PROCESS main
    IF reset = '0' THEN                 -- asynchronous reset (active low)
      data   <= X"00";
      status <= X"00";
      tx     <= '0';
    ELSIF rising_edge(clock) THEN       -- rising clock edge

    END IF;
  END PROCESS main;
END Behavioral;

