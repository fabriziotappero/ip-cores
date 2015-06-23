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

ENTITY gpio_out IS
  GENERIC(
    w_data : NATURAL RANGE 1 TO 32 := 16;
    w_port : NATURAL RANGE 1 TO 32 := 16);
  PORT (rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        ena      : IN  STD_LOGIC;
        we       : IN  STD_LOGIC;
        D        : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        Q        : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        port_out : OUT STD_LOGIC_VECTOR(w_port - 1 DOWNTO 0));
END ENTITY gpio_out;

ARCHITECTURE Behavioral OF gpio_out IS

  SIGNAL output : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0)
    := STD_LOGIC_VECTOR(to_unsigned(0, w_data));

BEGIN  -- ARCHITECTURE Behavioral

  -- purpose: Simple input GPIO
  -- type   : sequential
  -- inputs : clk, rst, ena, port_in
  -- outputs: D
  WRITE_PORT : PROCESS (clk) IS
  BEGIN  -- PROCESS PORT_IN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        output <= STD_LOGIC_VECTOR(to_unsigned(16#7FFFFFFF#, w_data));
      ELSIF ena = '1' AND we = '1' THEN
        output <= D;
      END IF;
    END IF;
  END PROCESS WRITE_PORT;

  port_out <= output(w_port - 1 DOWNTO 0);
  Q        <= output;

END ARCHITECTURE Behavioral;
