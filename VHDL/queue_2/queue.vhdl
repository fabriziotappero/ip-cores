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

ENTITY queue IS

  GENERIC (
    w_data : NATURAL := 16);
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

END queue;

ARCHITECTURE Behavioral OF queue IS

  COMPONENT reg IS
    GENERIC (
      w_data : NATURAL := w_data);
    PORT (D   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          E   : IN  STD_LOGIC;
          CLK : IN  STD_LOGIC;
          RST : IN  STD_LOGIC;
          Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT reg;

  COMPONENT qreg IS
    GENERIC (
      w_data : NATURAL := w_data);
    PORT (D0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          D1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
          S   : IN  STD_LOGIC;
          EN  : IN  STD_LOGIC;
          CLK : IN  STD_LOGIC;
          RST : IN  STD_LOGIC;
          Q   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));
  END COMPONENT qreg;

  COMPONENT qctrl IS
    PORT (CLK   : IN  STD_LOGIC;
          RST   : IN  STD_LOGIC;
          WR    : IN  STD_LOGIC;
          SH    : IN  STD_LOGIC;
          CLEAR : IN  STD_LOGIC;
          FULL  : OUT STD_LOGIC;
          EMPTY : OUT STD_LOGIC;
          EN    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
          SEL   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
  END COMPONENT qctrl;

  TYPE q_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL en  : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL rq  : q_t;

BEGIN

  CTR1 : qctrl PORT MAP (
    CLK   => clk,
    RST   => rst,
    WR    => we,
    SH    => sh,
    EN    => en,
    CLEAR => clear,
    FULL  => full,
    EMPTY => empty,
    SEL   => sel);

  R3 : reg PORT MAP (
    D   => d,
    E   => en(3),
    CLK => clk,
    RST => rst,
    Q   => rq(2));

  R2 : qreg PORT MAP (
    D0  => rq(2),
    D1  => d,
    S   => sel(2),
    EN  => en(2),
    CLK => clk,
    RST => rst,
    Q   => rq(1));

  R1 : qreg PORT MAP (
    D0  => rq(1),
    D1  => d,
    S   => sel(1),
    EN  => en(1),
    CLK => clk,
    RST => rst,
    Q   => rq(0));

  R0 : qreg PORT MAP (
    D0  => rq(0),
    D1  => d,
    S   => sel(0),
    EN  => en(0),
    CLK => clk,
    RST => rst,
    Q   => q);

END Behavioral;
