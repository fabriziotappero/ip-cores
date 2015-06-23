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
    CLK      : IN  STD_LOGIC;
    RST      : IN  STD_LOGIC;
    PC_SRC   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    LD_PC    : OUT STD_LOGIC;
    LD_IR    : OUT STD_LOGIC;
    LD_DP    : OUT STD_LOGIC;
    REG_SRC  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    RFA_A    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    RFA_B    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    REG_WR   : OUT STD_LOGIC;
    LD_REG_A : OUT STD_LOGIC;
    LD_REG_B : OUT STD_LOGIC;
    LD_MAR   : OUT STD_LOGIC;
    LD_MDR   : OUT STD_LOGIC;
    MEM_WR   : OUT STD_LOGIC;
    ALU_OP   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    INT      : IN  STD_LOGIC;
    ZERO     : IN  STD_LOGIC;
    IR_IN    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0));

END ENTITY uctrl;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE controllers IS

  COMPONENT uctrl IS

    PORT (
    CLK      : IN  STD_LOGIC;
    RST      : IN  STD_LOGIC;
    PC_SRC   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    LD_PC    : OUT STD_LOGIC;
    LD_IR    : OUT STD_LOGIC;
    LD_DP    : OUT STD_LOGIC;
    REG_SRC  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    RFA_A    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    RFA_B    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    REG_WR   : OUT STD_LOGIC;
    LD_REG_A : OUT STD_LOGIC;
    LD_REG_B : OUT STD_LOGIC;
    LD_MAR   : OUT STD_LOGIC;
    LD_MDR   : OUT STD_LOGIC;
    MEM_WR   : OUT STD_LOGIC;
    ALU_OP   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    INT      : IN  STD_LOGIC;
    ZERO     : IN  STD_LOGIC;
    IR_IN    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0));

  END COMPONENT uctrl;

END PACKAGE controllers;
