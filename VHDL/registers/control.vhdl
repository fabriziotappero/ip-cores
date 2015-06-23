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

ENTITY uctrl IS

  PORT (
    CLK    : IN  STD_LOGIC;
    RST    : IN  STD_LOGIC;
    RF_SEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    A1     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    A2     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    LO_EN  : OUT STD_LOGIC;
    RO_EN  : OUT STD_LOGIC;
    OPCODE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    WR     : OUT STD_LOGIC);

END ENTITY uctrl;

ARCHITECTURE Mealy OF uctrl IS

  TYPE state IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);

  SIGNAL CURR_STATE : state;
  SIGNAL NEXT_STATE : state;

BEGIN  -- ARCHITECTURE Mealy

  -- Next state logic
  PROCESS (CURR_STATE)
  BEGIN
    CASE CURR_STATE IS
      WHEN S0 =>
        NEXT_STATE <= S1;
      WHEN S1 =>
        NEXT_STATE <= S2;
      WHEN S2 =>
        NEXT_STATE <= S3;
      WHEN S3 =>
        NEXT_STATE <= S4;
      WHEN S4 =>
        NEXT_STATE <= S5;
      WHEN S5 =>
        NEXT_STATE <= S6;
      WHEN S6 =>
        NEXT_STATE <= S7;
      WHEN S7 =>
        NEXT_STATE <= S8;
      WHEN S8 =>
        NEXT_STATE <= S9;
      WHEN S9 =>
        NEXT_STATE <= S9;
    END CASE;
  END PROCESS;

  -- State logic
  PROCESS (CLK, RST)
  BEGIN
    IF rising_edge(CLK) THEN
      IF RST = '0' THEN
        CURR_STATE <= NEXT_STATE;
      ELSE
        CURR_STATE <= S0;
      END IF;
    END IF;
  END PROCESS;

  -- Output logic
  PROCESS (CURR_STATE)
  BEGIN
    RF_SEL <= "00";

    CASE CURR_STATE IS
      WHEN S0 =>
        A1     <= "00";
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "00";
        WR     <= '0';
      WHEN S1 =>
        A1     <= "00"; -- LD REG 0 with 0
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "00";
        WR     <= '1';
      WHEN S2 =>
        A1     <= "01"; -- LD REG 1 with 0
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "00";
        WR     <= '1';
      WHEN S3 =>
        A1     <= "00";
        A2     <= "00";
        LO_EN  <= '1'; -- LD Left op with REG 0
        RO_EN  <= '0';
        OPCODE <= "00"; 
        WR     <= '0';
      WHEN S4 =>
        A1     <= "00"; -- Store result in REG 0
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "10";
        WR     <= '1';
      WHEN S5 =>
        A1     <= "01";
        A2     <= "00";
        LO_EN  <= '1'; -- LD Left op with REG 1
        RO_EN  <= '0';
        OPCODE <= "00";
        WR     <= '0';
      WHEN S6 =>
        A1     <= "01"; -- Store result in REG 1
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "10";
        WR     <= '1';
      WHEN S7 =>
        A1     <= "00";
        A2     <= "01";
        LO_EN  <= '1';
        RO_EN  <= '1';
        OPCODE <= "00";
        WR     <= '0';
      WHEN S8 =>
        A1     <= "00";
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "01";
        WR     <= '1';
      WHEN S9 =>
        A1     <= "00";
        A2     <= "00";
        LO_EN  <= '0';
        RO_EN  <= '0';
        OPCODE <= "00";
        WR     <= '0';
    END CASE;
  END PROCESS;

END ARCHITECTURE Mealy;
