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

ENTITY tty_in IS
  PORT (
    reset    : IN  STD_LOGIC;
    clock    : IN  STD_LOGIC;
    rd       : IN  STD_LOGIC;
    wr       : IN  STD_LOGIC;
    data_in  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    address  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
    rx       : IN  STD_LOGIC);
END tty_in;

ARCHITECTURE Behavioral OF tty_in IS

  SIGNAL data   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL status : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL shifter : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL count   : INTEGER RANGE 0 TO 9;

BEGIN

  -- purpose: Serially read in data
  -- type   : sequential
  -- inputs : clock, reset
  -- outputs: 
  serial_input : PROCESS (clock, reset)
  BEGIN  -- PROCESS read
    IF reset = '0' THEN                 -- asynchronous reset (active low)
      data    <= X"00";
      status  <= X"00";
      shifter <= "0000000000";
      count   <= 0;
    ELSIF rising_edge(clock) THEN       -- rising clock edge

      IF count = 9 THEN

        data    <= shifter(8 DOWNTO 1);
        status  <= X"01";
        count   <= 0;
        shifter <= rx & shifter(9 DOWNTO 1);

      ELSE

        IF address = "111111100000000" AND rd = '1' THEN
          status <= X"00";
        ELSE
          status <= status;
        END IF;

        data    <= data;
        count   <= count + 1;
        shifter <= rx & shifter(9 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS serial_input;

  data_out <= status & data;

END Behavioral;

