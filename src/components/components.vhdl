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
USE IEEE.numeric_std.ALL;

PACKAGE components IS

  COMPONENT data_reg
    GENERIC(
      w_data      : NATURAL RANGE 1 TO 32 := 16;
      reset_value : NATURAL               := 0);
    PORT (RST : IN  STD_LOGIC;
          CLK : IN  STD_LOGIC;
          ENA : IN  STD_LOGIC;
          D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT data_reg_2 IS

    GENERIC (
      w_data      : NATURAL := 16;
      reset_value : NATURAL := 0);

    PORT (
      CLK : IN  STD_LOGIC;
      D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  END COMPONENT data_reg_2;

  COMPONENT queue IS
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);
    PORT (
      rst   : IN  STD_LOGIC;
      clk   : IN  STD_LOGIC;
      we    : IN  STD_LOGIC;
      sh    : IN  STD_LOGIC;
      clear : IN  STD_LOGIC;
      full  : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      d     : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      q     : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT queue;

  COMPONENT regf IS
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16;
      w_addr : NATURAL               := 4);
    PORT (clk : IN  STD_LOGIC;
          we  : IN  STD_LOGIC;
          a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
          a2  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
          d   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT alu IS
    GENERIC(
      w_data : NATURAL RANGE 1 TO 32 := 16);
    PORT(
      clk : IN  STD_LOGIC;
      op  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      A   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      B   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT incr
    GENERIC(
      w_data : NATURAL RANGE 1 TO 32 := 16);
    PORT(
      A : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT memory IS
    GENERIC(
      w_data : NATURAL RANGE 1 TO 32 := 16);
    PORT(clk : IN  STD_LOGIC;
         A1  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
         B1  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
         we  : IN  STD_LOGIC;
         D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
         A   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
         B   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT gpio_in
    GENERIC(
      w_data : NATURAL RANGE 1 TO 32 := 16;
      w_port : NATURAL RANGE 1 TO 32 := 16);
    PORT (rst     : IN  STD_LOGIC;
          clk     : IN  STD_LOGIC;
          ena     : IN  STD_LOGIC;
          Q       : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          port_in : IN  STD_LOGIC_VECTOR(w_port - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT gpio_out
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
  END COMPONENT;

  COMPONENT decoder
    PORT (
      clk     : IN  STD_LOGIC;
      ena     : IN  STD_LOGIC;
      a1      : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
      gpio_1  : OUT STD_LOGIC;
      gpio_2  : OUT STD_LOGIC;
      gpio_3  : OUT STD_LOGIC;
      bus_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
  END COMPONENT;

  COMPONENT zerof
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);
    PORT (
      A    : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      zero : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT clock_gen
    PORT (
      CLK_IN    : IN  STD_LOGIC;
      RESET     : IN  STD_LOGIC;
      CLK_VALID : OUT STD_LOGIC;
      CLK_OUT   : OUT STD_LOGIC
      );
  END COMPONENT;

  COMPONENT sync_reset
    PORT (
      async_rst : IN  STD_LOGIC;
      clk       : IN  STD_LOGIC;
      clk_valid : IN  STD_LOGIC;
      rst       : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT control
  END COMPONENT;

END components;
