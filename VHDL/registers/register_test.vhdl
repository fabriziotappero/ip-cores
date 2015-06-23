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

ENTITY register_test IS

END ENTITY register_test;

ARCHITECTURE Structural OF register_test IS

  -- Component declarations
  COMPONENT reset IS

    PORT (
      RST : OUT STD_LOGIC);

  END COMPONENT reset;

  COMPONENT clock IS

    PORT (
      CLK : OUT STD_LOGIC);

  END COMPONENT clock;

  COMPONENT multiplexer IS

    PORT (
      SEL : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      S0  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S1  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S2  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S3  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

  END COMPONENT multiplexer;

  COMPONENT rf IS

    PORT (
      CLK : IN  STD_LOGIC;
      D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q1  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q2  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      A1  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      A2  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      WR  : IN  STD_LOGIC);

  END COMPONENT rf;

  COMPONENT pipeline_reg IS

    PORT (
      D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      CLK : IN  STD_LOGIC;
      EN  : IN  STD_LOGIC);

  END COMPONENT pipeline_reg;

  COMPONENT ALU IS

    PORT (
      I1 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      I2 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      R1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      F1 : IN  STD_LOGIC_VECTOR(1 DOWNTO 0));

  END COMPONENT ALU;

  COMPONENT uctrl IS

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

  END COMPONENT uctrl;

  -- Signal declarations
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RST : STD_LOGIC;

  SIGNAL RESULT : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL LO     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL RO     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL ILO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL IRO    : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL A1     : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL A2     : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL WR     : STD_LOGIC;
  SIGNAL LO_EN  : STD_LOGIC;
  SIGNAL RO_EN  : STD_LOGIC;
  SIGNAL OPCODE : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN  -- ARCHITECTURE Structural

  CLK1 : clock PORT MAP (
    CLK => CLK);

  RST1 : reset PORT MAP (
    RST => RST);

  RF1 : rf PORT MAP (
    CLK => CLK,
    D   => RESULT,
    Q1  => LO,
    Q2  => RO,
    A1  => A1,
    A2  => A2,
    WR  => WR);

  PR1 : pipeline_reg PORT MAP (
    D   => LO,
    Q   => ILO,
    CLK => CLK,
    EN  => LO_EN);

  PR2 : pipeline_reg PORT MAP (
    D   => RO,
    Q   => IRO,
    CLK => CLK,
    EN  => RO_EN);

  ALU1 : ALU PORT MAP (
    I1 => ILO,
    I2 => IRO,
    R1 => RESULT,
    F1 => OPCODE);

  CTRL1 : uctrl PORT MAP (
    CLK    => CLK,
    RST    => RST,
    RF_SEL => OPEN,
    A1     => A1,
    A2     => A2,
    LO_EN  => LO_EN,
    RO_EN  => RO_EN,
    OPCODE => OPCODE,
    WR     => WR);

END ARCHITECTURE Structural;
