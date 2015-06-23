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

ENTITY ct IS
  PORT (reset       : IN  STD_LOGIC;
        clock       : IN  STD_LOGIC;
        ir_in       : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        reg_a       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        reg_b       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        op_sel      : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        reg_input   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        reg_write   : OUT STD_LOGIC;
        pc_input    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        addr_source : OUT STD_LOGIC;
        wr          : OUT STD_LOGIC;
        rd          : OUT STD_LOGIC;
        zero        : IN  STD_LOGIC;
        n_zero      : IN  STD_LOGIC);
END ct;

ARCHITECTURE Behavioral OF ct IS

  TYPE ctr_state IS (one, two, three, four, five, six, seven, eight);

  SIGNAL ir : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL cr_reg_a       : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL cr_reg_b       : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL cr_op_sel      : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL cr_reg_input   : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL cr_reg_write   : STD_LOGIC;
  SIGNAL cr_pc_input    : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL cr_addr_source : STD_LOGIC;
  SIGNAL cr_wr          : STD_LOGIC;
  SIGNAL cr_rd          : STD_LOGIC;
  SIGNAL cr_state       : ctr_state;

  SIGNAL nx_reg_a       : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL nx_reg_b       : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL nx_op_sel      : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL nx_reg_input   : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL nx_reg_write   : STD_LOGIC;
  SIGNAL nx_pc_input    : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL nx_addr_source : STD_LOGIC;
  SIGNAL nx_wr          : STD_LOGIC;
  SIGNAL nx_rd          : STD_LOGIC;
  SIGNAL nx_state       : ctr_state;
  
BEGIN

  -- purpose: This is the state controller register
  -- type   : sequential
  -- inputs : clock, reset, zero,n_zero, next_state
  -- outputs: cr_reg_a,cr_reg_b,cr_op_sel,cr_reg_input,cr_reg_write,cr_pc_input,cr_addr_source,cr_wr,cr_rd
  control_out : PROCESS (clock, reset)
  BEGIN  -- PROCESS control_out
    IF reset = '0' THEN                 -- asynchronous reset (active low)
      cr_reg_a       <= "0000";
      cr_reg_b       <= "0000";
      cr_op_sel      <= "0000";
      cr_reg_input   <= "00";
      cr_reg_write   <= '0';
      cr_pc_input    <= "00";
      cr_addr_source <= '0';
      cr_state       <= one;
    ELSIF rising_edge(clock) THEN       -- rising clock edge
      cr_reg_a       <= nx_reg_a;
      cr_reg_b       <= nx_reg_b;
      cr_op_sel      <= nx_op_sel;
      cr_reg_input   <= nx_reg_input;
      cr_reg_write   <= nx_reg_write;
      cr_pc_input    <= nx_pc_input;
      cr_addr_source <= nx_addr_source;
      cr_state       <= nx_state;
    END IF;
  END PROCESS control_out;

  -- purpose: Compute the next state and outputs from the current state
  -- type   : combinational
  -- inputs : state, zero, n_zero
  -- outputs: nx_reg_a,nx_reg_b,nx_op_sel,nx_reg_input,nx_reg_write,nx_pc_inpue,nx_addr_source,nx_state
  next_control : PROCESS (cr_state, zero, n_zero)
  BEGIN  -- PROCESS next_control
    nx_reg_a       <= "0000";
    nx_reg_b       <= "0000";
    nx_op_sel      <= "0000";
    nx_reg_input   <= "00";
    nx_reg_write   <= '0';
    nx_pc_input    <= "00";
    nx_addr_source <= '0';
    nx_state       <= one;

    CASE cr_state IS
      WHEN one =>
        nx_state <= two;
      WHEN two =>
        nx_state <= three;
      WHEN three =>
        nx_state <= four;
      WHEN four =>
        nx_state <= five;
      WHEN five =>
        nx_state <= six;
      WHEN six =>
        nx_state <= seven;
      WHEN seven =>
        nx_state <= one;
      WHEN eight =>
        nx_state <= one;
    END CASE;
  END PROCESS next_control;

  reg_a       <= cr_reg_a;
  reg_b       <= cr_reg_b;
  op_sel      <= cr_op_sel;
  reg_input   <= cr_reg_input;
  reg_write   <= cr_reg_write;
  pc_input    <= cr_pc_input;
  addr_source <= cr_addr_source;
  wr          <= cr_wr;
  rd          <= cr_rd;

END Behavioral;

