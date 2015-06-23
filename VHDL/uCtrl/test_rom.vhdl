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
-- USE work.rom_parts.ALL;

ENTITY test_rom IS
  
  PORT (
    clk : IN  STD_LOGIC;
    rst : IN  STD_LOGIC;
    led : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END test_rom;

--ARCHITECTURE Behavioral OF test_rom IS

--  SIGNAL address : STD_LOGIC_VECTOR(5 DOWNTO 0);

--BEGIN  -- Behavioral

--  ROM1 : rom_in_pr
--    GENERIC MAP (
--      w_data => 8,
--      w_addr => 6)
--    PORT MAP (
--      clk => clk,
--      a1  => address,
--      q1  => led);

--  -- purpose: Count up
--  -- type   : sequential
--  -- inputs : clk, rst
--  -- outputs: address
--  CTR : PROCESS (clk, rst)
--    VARIABLE cval : NATURAL := 0;
--  BEGIN  -- PROCESS CTR
--    IF rising_edge(clk) THEN
--      IF rst = '1' THEN
--        address <= STD_LOGIC_VECTOR(to_unsigned(0, 6));
--      ELSE
--        cval := to_integer(UNSIGNED(address));

--        IF cval = 63 THEN
--          cval := 0;
--        ELSE
--          cval := cval + 1;
--        END IF;

--        address <= STD_LOGIC_VECTOR(to_unsigned(cval, 6));
--      END IF;
--    END IF;
--  END PROCESS CTR;

--END Behavioral;

--ARCHITECTURE Behavioral OF test_rom IS

--  SIGNAL address : STD_LOGIC_VECTOR(5 DOWNTO 0);

--BEGIN  -- Behavioral

--  ROM1 : rom_out_pr
--    GENERIC MAP (
--      w_data => 8,
--      w_addr => 6)
--    PORT MAP (
--      clk => clk,
--      a1  => address,
--      q1  => led);

--  -- purpose: Count up
--  -- type   : sequential
--  -- inputs : clk, rst
--  -- outputs: address
--  CTR : PROCESS (clk, rst)
--    VARIABLE cval : NATURAL := 0;
--  BEGIN  -- PROCESS CTR
--    IF rising_edge(clk) THEN
--      IF rst = '1' THEN
--        address <= STD_LOGIC_VECTOR(to_unsigned(0, 6));
--      ELSE
--        cval := to_integer(UNSIGNED(address));

--        IF cval = 63 THEN
--          cval := 0;
--        ELSE
--          cval := cval + 1;
--        END IF;

--        address <= STD_LOGIC_VECTOR(to_unsigned(cval, 6));
--      END IF;
--    END IF;
--  END PROCESS CTR;

--END Behavioral;

--ARCHITECTURE Behavioral OF test_rom IS

--  SIGNAL address   : STD_LOGIC_VECTOR(5 DOWNTO 0);
--  SIGNAL increment : STD_LOGIC_VECTOR(5 DOWNTO 0);

--BEGIN  -- Behavioral

--  ROM1 : rom_db_pr
--    GENERIC MAP (
--      w_data => 8,
--      w_addr => 6)
--    PORT MAP (
--      clk => clk,
--      a1  => address,
--      q1  => led);

--  -- purpose: Count up
--  -- type   : sequential
--  -- inputs : clk, rst
--  -- outputs: address
--  CTR : PROCESS (clk, rst)
--    VARIABLE cval : NATURAL := 0;
--  BEGIN  -- PROCESS CTR
--    IF rising_edge(clk) THEN
--      IF rst = '1' THEN
--        address <= "000000";
--      ELSE
--        address <= increment;
--      END IF;
--    END IF;
--  END PROCESS CTR;

--  -- purpose: Increment the ingoing value
--  -- type   : combinational
--  -- inputs : address
--  -- outputs: increment
--  INC1: PROCESS (address)
--  BEGIN  -- PROCESS INC1
--    increment <= STD_LOGIC_VECTOR(UNSIGNED(address) + to_unsigned(1, 6));
--  END PROCESS INC1;

--END Behavioral;

ARCHITECTURE Behavioral OF test_rom IS

  SIGNAL ctr   : NATURAL RANGE 0 TO 255 := 0;
  SIGNAL out_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
BEGIN  -- Behavioral

  CTR1 : PROCESS (clk, rst)
  BEGIN  -- PROCESS CTR1
    IF rising_edge(clk) THEN
      IF rst = '1' THEN                 -- asynchronous reset (active low)
        ctr <= 0;
      ELSE

        IF ctr = 255 THEN
          ctr <= 0;
        ELSE
          ctr <= ctr + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS CTR1;

  --LOOKUP1 : PROCESS (clk, rst)
  --BEGIN  -- PROCESS LOOKUP1
  --  IF rising_edge(clk) THEN
  --    IF rst = '1' THEN                 -- asynchronous reset (active low)
  --      out_v <= "00000000";
  --    ELSE

  --      CASE ctr IS
  --        WHEN 0 =>
  --          out_v <= "00000000";
  --        WHEN 1 =>
  --          out_v <= "00000001";
  --        WHEN 2 =>
  --          out_v <= "00000010";
  --        WHEN 3 =>
  --          out_v <= "00000100";
  --        WHEN 4 =>
  --          out_v <= "00001000";
  --        WHEN 5 =>
  --          out_v <= "00010000";
  --        WHEN 6 =>
  --          out_v <= "00100000";
  --        WHEN 7 =>
  --          out_v <= "01000000";
  --        WHEN 8 =>
  --          out_v <= "10000000";
  --        WHEN OTHERS =>
  --          out_v <= "11111111";
  --      END CASE;

  --    END IF;
  --  END IF;
  --END PROCESS LOOKUP1;

  --led <= out_v;

  led <= STD_LOGIC_VECTOR(to_unsigned(ctr, 8));

END Behavioral;
