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
USE work.ram_parts.ALL;

-- Test bench for instatiating a memory and initialising
-- it from a file.

ENTITY tb_generic_ram IS
END ENTITY tb_generic_ram;

ARCHITECTURE Structural OF tb_generic_ram IS

  CONSTANT w_addr : INTEGER := 12;

  SIGNAL clock  : STD_LOGIC                             := '0';
  SIGNAL we     : STD_LOGIC                             := '0';
  SIGNAL data_a : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL inst_a : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
  SIGNAL data_i : STD_LOGIC_VECTOR(15 DOWNTO 0)         := (OTHERS => '0');
  SIGNAL data_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL inst_o : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL ctr_a : NATURAL RANGE 0 TO (2**w_addr - 1);

BEGIN  -- ARCHITECTURE Structural

  RAM1 : generic_ram
    GENERIC MAP (
      filename => "test_data.txt",
      w_addr   => 12)
    PORT MAP (
      clk => clock,
      we  => we,
      a1  => data_a,
      a2  => inst_a,
      d1  => data_i,
      q1  => data_o,
      q2  => inst_o);

  CTR1 : PROCESS (clock) IS
  BEGIN  -- PROCESS CTR1
    IF rising_edge(clock) THEN          -- rising clock edge
      IF ctr_a = 4095 THEN
        ctr_a <= 0;
      ELSE
        ctr_a <= ctr_a + 1;
      END IF;
    END IF;
  END PROCESS CTR1;

  inst_a <= STD_LOGIC_VECTOR(to_unsigned(ctr_a, w_addr));

  CLK1 : PROCESS IS
  BEGIN  -- PROCESS CLK1
    clock <= '0';
    WAIT FOR 10 NS;
    clock <= '1';
    WAIT FOR 10 NS;
  END PROCESS CLK1;

END ARCHITECTURE Structural;
