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

ENTITY memory_pipeline IS

END ENTITY memory_pipeline;

ARCHITECTURE Structural OF memory_pipeline IS

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

  COMPONENT adder IS

    PORT (
      ADDEND : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      SUM    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

  END COMPONENT adder;

  COMPONENT pipeline_reg IS

    PORT (
      D   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      CLK : IN  STD_LOGIC;
      EN  : IN  STD_LOGIC);

  END COMPONENT pipeline_reg;

  COMPONENT memory IS

    PORT (
      CLK     : IN  STD_LOGIC;
      ADDRESS : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      Q       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

  END COMPONENT memory;

  COMPONENT memory_controller IS

    PORT (
      RST  : IN  STD_LOGIC;
      CLK  : IN  STD_LOGIC;
      SEL  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      EN0  : OUT STD_LOGIC;
      EN1  : OUT STD_LOGIC;
      FULL : OUT STD_LOGIC;
      PULL : IN  STD_LOGIC);

  END COMPONENT memory_controller;

  COMPONENT memory_processor IS

    PORT (
      CLK  : IN  STD_LOGIC;
      RST  : IN  STD_LOGIC;
      INST : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      FULL : IN  STD_LOGIC;
      PULL : OUT STD_LOGIC);

  END COMPONENT memory_processor;

  -- Driving signals
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RST : STD_LOGIC;

  -- Data signals
  SIGNAL address : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL pc      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL inc     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL mem_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL ir      : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Control signals
  SIGNAL SEL  : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL EN0  : STD_LOGIC;
  SIGNAL EN1  : STD_LOGIC;
  SIGNAL FULL : STD_LOGIC;
  SIGNAL PULL : STD_LOGIC;

BEGIN  -- ARCHITECTURE Structural

  CLK1 : clock PORT MAP (
    CLK => CLK);

  RST1 : reset PORT MAP (
    RST => RST);

  M1 : multiplexer PORT MAP (
    SEL => SEL,
    S0  => X"00",
    S1  => pc,
    S2  => inc,
    S3  => X"00",
    Y   => address);

  -- Program counter register
  R0 : pipeline_reg PORT MAP (
    D   => address,
    Q   => pc,
    CLK => CLK,
    EN  => EN0);

  -- Increment
  I1 : adder PORT MAP (
    ADDEND => pc,
    SUM    => inc);

  -- Memory
  MEM1 : memory PORT MAP (
    CLK     => CLK,
    ADDRESS => address,
    Q       => mem_out);

  -- Output register
  R2 : pipeline_reg PORT MAP (
    D   => mem_out,
    Q   => ir,
    CLK => CLK,
    EN  => EN1);

  -- Controller
  CTRL1 : memory_controller PORT MAP (
    RST  => RST,
    CLK  => CLK,
    SEL  => SEL,
    EN0  => EN0,
    EN1  => EN1,
    FULL => FULL,
    PULL => PULL);

  -- Processor
  CTRL2 : memory_processor PORT MAP (
    CLK  => CLK,
    RST  => RST,
    INST => ir,
    FULL => FULL,
    PULL => PULL);
END ARCHITECTURE Structural;
