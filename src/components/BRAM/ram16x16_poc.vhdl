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
USE work.mux_parts.ALL;

-- Proof of concept

ENTITY ram16kx16 IS
  
  PORT (
    clk : IN  STD_LOGIC;
    we  : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);   -- Data port address
    a2  : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);   -- Instruction port address
    d1  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);   -- Data port input
    q1  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);   -- Data port output
    q2  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  -- Instruction port output
END ram16kx16;

ARCHITECTURE structural OF ram16kx16 IS

  COMPONENT RAM1kx16 IS
    
    PORT (
      clk : IN  STD_LOGIC;
      we  : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);   -- Data port address
      a2  : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);   -- Instruction port address
      d1  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);   -- Data port input
      q1  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);   -- Data port output
      q2  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  -- Instruction port output

  END COMPONENT RAM1kx16;

  SIGNAL data_address  : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL data_select   : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL instr_address : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL instr_select  : STD_LOGIC_VECTOR(2 DOWNTO 0);

  SIGNAL wr_sel : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL ds0 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds5 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds6 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ds7 : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL is0 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is5 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is6 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL is7 : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN  -- structural

  data_address <= a1(10 DOWNTO 0);
  data_select  <= a1(13 DOWNTO 11);

  instr_address <= a2(10 DOWNTO 0);
  instr_select  <= a2(13 DOWNTO 11);

  WITH data_select SELECT
    wr_sel <=
    "00000001" WHEN "000",
    "00000010" WHEN "001",
    "00000100" WHEN "010",
    "00001000" WHEN "011",
    "00010000" WHEN "100",
    "00100000" WHEN "101",
    "01000000" WHEN "110",
    "10000000" WHEN "111";

  M1 : mux8to1
    PORT MAP (
      SEL => data_select,
      S0  => ds0,
      S1  => ds1,
      S2  => ds2,
      S3  => ds3,
      S4  => ds4,
      S5  => ds5,
      S6  => ds6,
      S7  => ds7,
      Y   => q1);

  M2 : mux8to1
    PORT MAP (
      SEL => instr_select,
      S0  => is0,
      S1  => is1,
      S2  => is2,
      S3  => is3,
      S4  => is4,
      S5  => is5,
      S6  => is6,
      S7  => is7,
      Y   => q2);

  R0 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(0),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds0,
      q2  => is0);

  R1 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(1),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds1,
      q2  => is1);

  R2 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(2),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds2,
      q2  => is2);

  R3 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(3),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds3,
      q2  => is3);

  R4 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(4),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds4,
      q2  => is4);

  R5 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(5),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds5,
      q2  => is5);

  R6 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(6),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds6,
      q2  => is6);

  R7 : RAM1kx16
    PORT MAP (
      clk => clk,
      we  => wr_sel(7),
      a1  => data_address,
      a2  => instr_address,
      d1  => d1,
      q1  => ds7,
      q2  => is7);

END structural;

