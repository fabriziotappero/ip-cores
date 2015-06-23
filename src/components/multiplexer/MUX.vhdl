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

PACKAGE mux_parts IS

  COMPONENT mux2to1 IS
    
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);

    PORT (
      SEL : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
      S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  END COMPONENT mux2to1;

  COMPONENT mux4to1 IS
    
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);

    PORT (
      SEL : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  END COMPONENT mux4to1;

  COMPONENT mux8to1 IS
    
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);

    PORT (
      SEL : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S4  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S5  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S6  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S7  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  END COMPONENT mux8to1;

  COMPONENT mux16to1 IS
    
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16);

    PORT (
      SEL : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S4  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S5  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S6  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S7  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S8  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S9  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S10 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S11 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S12 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S13 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S14 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      S15 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
      Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

  END COMPONENT mux16to1;

END mux_parts;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux2to1 IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    SEL : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END mux2to1;

ARCHITECTURE Behavioral OF mux2to1 IS

BEGIN  -- Behavioral

  WITH SEL SELECT
    Y <=
    S0 WHEN "0",
    S1 WHEN "1",
    S0 WHEN OTHERS;

END Behavioral;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux4to1 IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    SEL : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END mux4to1;

ARCHITECTURE Behavioral OF mux4to1 IS

BEGIN  -- Behavioral

  WITH SEL SELECT
    Y <=
    S0 WHEN "00",
    S1 WHEN "01",
    S2 WHEN "10",
    S3 WHEN "11",
    S0 WHEN OTHERS;

END Behavioral;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux8to1 IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    SEL : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S4  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S5  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S6  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S7  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END mux8to1;

ARCHITECTURE Behavioral OF mux8to1 IS

BEGIN  -- Behavioral

  WITH SEL SELECT
    Y <=
    S0 WHEN "000",
    S1 WHEN "001",
    S2 WHEN "010",
    S3 WHEN "011",
    S4 WHEN "100",
    S5 WHEN "101",
    S6 WHEN "110",
    S7 WHEN "111",
    S0 WHEN OTHERS;

END Behavioral;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux16to1 IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    SEL : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S4  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S5  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S6  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S7  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S8  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S9  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S10 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S11 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S12 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S13 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S14 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S15 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END mux16to1;

ARCHITECTURE Behavioral OF mux16to1 IS

BEGIN  -- Behavioral

  WITH SEL SELECT
    Y <=
    S0  WHEN "0000",
    S1  WHEN "0001",
    S2  WHEN "0010",
    S3  WHEN "0011",
    S4  WHEN "0100",
    S5  WHEN "0101",
    S6  WHEN "0110",
    S7  WHEN "0111",
    S8  WHEN "1000",
    S9  WHEN "1001",
    S10 WHEN "1010",
    S11 WHEN "1011",
    S12 WHEN "1100",
    S13 WHEN "1101",
    S14 WHEN "1110",
    S15 WHEN "1111",
    S0  WHEN OTHERS;

END Behavioral;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.mux_parts.ALL;

ENTITY mux32to1 IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
    S0  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S2  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S3  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S4  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S5  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S6  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S7  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S8  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S9  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S10 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S11 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S12 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S13 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S14 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S15 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S16 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S17 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S18 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S19 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S20 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S21 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S22 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S23 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S24 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S25 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S26 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S27 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S28 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S29 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S30 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    S31 : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    Y   : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END mux32to1;

ARCHITECTURE Behavioral OF mux32to1 IS

  SIGNAL M1_Y : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL M2_Y : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL sub_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL out_sel : STD_LOGIC_VECTOR(0 DOWNTO 0);
  
BEGIN  -- Behavioral

  sub_sel <= SEL(3 DOWNTO 0);
  out_sel <= SEL(4 DOWNTO 4);

  M1 : mux16to1
    GENERIC MAP (
      w_data => w_data)
    PORT MAP (
      SEL => sub_sel,
      S0  => S0,
      S1  => S1,
      S2  => S2,
      S3  => S3,
      S4  => S4,
      S5  => S5,
      S6  => S6,
      S7  => S7,
      S8  => S8,
      S9  => S9,
      S10 => S10,
      S11 => S11,
      S12 => S12,
      S13 => S13,
      S14 => S14,
      S15 => S15,
      Y   => M1_Y);

  M2 : mux16to1
    GENERIC MAP (
      w_data => w_data)
    PORT MAP (
      SEL => sub_sel,
      S0  => S16,
      S1  => S17,
      S2  => S18,
      S3  => S19,
      S4  => S20,
      S5  => S21,
      S6  => S22,
      S7  => S23,
      S8  => S24,
      S9  => S25,
      S10 => S26,
      S11 => S27,
      S12 => S28,
      S13 => S29,
      S14 => S30,
      S15 => S31,
      Y   => M2_Y);

  M3 : mux2to1
    GENERIC MAP (
      w_data => w_data)
    PORT MAP (
      SEL => out_sel,
      S0  => M1_Y,
      S1  => M2_Y,
      Y   => Y);

END Behavioral;
