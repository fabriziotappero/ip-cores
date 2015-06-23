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
USE IEEE.NUMERIC_STD.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY registers IS
  
  GENERIC (
    w_data : NATURAL := 16;
    w_regn : NATURAL := 5);

  PORT (
    reset    : IN  STD_LOGIC;
    clock    : IN  STD_LOGIC;
    reg_a    : IN  STD_LOGIC_VECTOR(w_regn - 1 DOWNTO 0);
    reg_b    : IN  STD_LOGIC_VECTOR(w_regn - 1 DOWNTO 0);
    we       : IN  STD_LOGIC;
    reg_data : IN  UNSIGNED(w_data - 1 DOWNTO 0);
    a_out    : OUT UNSIGNED(w_data - 1 DOWNTO 0);
    b_out    : OUT UNSIGNED(w_data - 1 DOWNTO 0));

END registers;

ARCHITECTURE Behavioral OF registers IS

  TYPE   register_array IS ARRAY(0 TO (2**w_regn) - 1) OF UNSIGNED(w_data - 1 DOWNTO 0);
  SIGNAL register_file : register_array;

BEGIN  -- Behavioral

-- purpose: This is the writing to the register file
-- type   : sequential
-- inputs : clock, reg_c
-- outputs: register_file
  reg : PROCESS (clock)
  BEGIN  -- PROCESS reg
    IF rising_edge(clock) THEN          -- rising clock edge

      IF we = '1' THEN
        register_file(to_integer(UNSIGNED(reg_a))) <= reg_data;
      END IF;
      
    END IF;
  END PROCESS reg;

-- purpose: Get contents of registers onto intermediate buses
-- type   : combinational
-- inputs : reg_a,reg_b
-- outputs: a_out,b_bout
  reg_outputs : PROCESS (reg_a, reg_b, register_file)
  BEGIN  -- PROCESS reg_outputs
    a_out <= register_file(to_integer(UNSIGNED(reg_a)));
    b_out <= register_file(to_integer(UNSIGNED(reg_b)));
  END PROCESS reg_outputs;

END Behavioral;
