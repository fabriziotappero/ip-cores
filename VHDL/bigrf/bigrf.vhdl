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

ENTITY bigrf IS
  
  GENERIC (
    bus_width : NATURAL := 16);

  PORT (
    clock       : IN  STD_LOGIC;
    port_a_in   : IN  STD_LOGIC_VECTOR(bus_width - 1 DOWNTO 0);
    port_a_addr : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    port_a_wr   : IN  STD_LOGIC;
    port_b_in   : IN  STD_LOGIC_VECTOR(bus_width - 1 DOWNTO 0);
    port_b_addr : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    port_b_wr   : IN  STD_LOGIC;
    port_c_out  : OUT STD_LOGIC_VECTOR(bus_width - 1 DOWNTO 0);
    port_c_addr : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    port_d_out  : OUT STD_LOGIC_VECTOR(bus_width - 1 DOWNTO 0);
    port_d_addr : IN  STD_LOGIC_VECTOR(3 DOWNTO 0));

END bigrf;

ARCHITECTURE Behavioral OF bigrf IS

  TYPE reg_t IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(bus_width - 1 DOWNTO 0);

  SIGNAL reg_l : reg_t;
  SIGNAL reg_r : reg_t;
  
BEGIN  -- Behavioral

  -- purpose: Four-port register file
  -- type   : sequential
  -- inputs : clock, port_n_in, port_n_addr, port_n_wr
  -- outputs: port_c_out,port_d_out
  RF1 : PROCESS (clock)
  BEGIN  -- PROCESS RF1
    IF rising_edge(clock) THEN          -- rising clock edge
      -- Outputs
      port_c_out <= reg_l(to_integer(UNSIGNED(port_c_addr)));
      port_d_out <= reg_r(to_integer(UNSIGNED(port_d_addr)));

      -- Inputs
      -- If port A and port B have the same address, then there has to be a
      -- choice to which port has preference
      IF port_a_wr = '1' AND port_b_wr = '0' THEN
        reg_r(to_integer(UNSIGNED(port_a_addr))) <= port_a_in;
        reg_l(to_integer(UNSIGNED(port_a_addr))) <= port_a_in;
        
        reg_r(to_integer(UNSIGNED(port_b_addr))) <= reg_r(to_integer(UNSIGNED(port_b_addr)));
        reg_l(to_integer(UNSIGNED(port_b_addr))) <= reg_l(to_integer(UNSIGNED(port_b_addr)));
      ELSIF port_a_wr = '0' AND port_b_wr = '1' THEN
        reg_r(to_integer(UNSIGNED(port_a_addr))) <= reg_r(to_integer(UNSIGNED(port_a_addr)));
        reg_l(to_integer(UNSIGNED(port_a_addr))) <= reg_l(to_integer(UNSIGNED(port_a_addr)));

        reg_r(to_integer(UNSIGNED(port_b_addr))) <= port_b_in;
        reg_l(to_integer(UNSIGNED(port_b_addr))) <= port_b_in;
      ELSIF port_a_wr = '1' AND port_b_wr = '1' THEN
        IF port_a_addr = port_b_addr THEN
          reg_r(to_integer(UNSIGNED(port_a_addr))) <= port_b_in;
          reg_l(to_integer(UNSIGNED(port_a_addr))) <= port_b_in;
          reg_r(to_integer(UNSIGNED(port_b_addr))) <= port_b_in;
          reg_l(to_integer(UNSIGNED(port_b_addr))) <= port_b_in;
        ELSE
          reg(to_integer(UNSIGNED(port_a_addr))) <= port_a_in;
          reg(to_integer(UNSIGNED(port_b_addr))) <= port_b_in;
        END IF;
      ELSE
        reg(to_integer(UNSIGNED(port_a_addr))) <= reg(to_integer(UNSIGNED(port_a_addr)));
        reg(to_integer(UNSIGNED(port_b_addr))) <= reg(to_integer(UNSIGNED(port_b_addr)));
      END IF;
    END IF;
  END PROCESS RF1;

END Behavioral;
