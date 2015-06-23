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

LIBRARY UNISIM;
USE UNISIM.vcomponents.ALL;

ENTITY RAM4kx16 IS
  
  PORT (
    CLK   : IN  STD_LOGIC;
    ADDRA : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
    DINA  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    WEA   : IN  STD_LOGIC;
    DOUTA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    ADDRB : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
    DOUTB : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));

END RAM4kx16;

ARCHITECTURE Behavioral OF RAM4kx16 IS

  COMPONENT RAM2kx16
    PORT (
      CLK   : IN  STD_LOGIC;
      ADDRA : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
      DINA  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      WEA   : IN  STD_LOGIC;
      DOUTA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      ADDRB : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
      DOUTB : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
  END COMPONENT;

  TYPE connect_t IS ARRAY (0 TO 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL conn_a : connect_t;
  SIGNAL conn_b : connect_t;

BEGIN  -- Behavioral

  RAM_GEN : FOR I IN 0 TO 1 GENERATE
    RAMI : RAM2kx16
      PORT MAP (
        CLK   => CLK ,
        ADDRA => ADDRA(10 DOWNTO 0),
        DINA  => DINA,
        WEA   => WEA,
        DOUTA => conn_a(I),
        ADDRB => ADDRB(10 DOWNTO 0),
        DOUTB => conn_b(I));
  END GENERATE RAM_GEN;

  BUS1: PROCESS (ADDRA(14 DOWNTO 11), conn_a)
  BEGIN  -- PROCESS BUS1
     DOUTA <= conn_a(to_integer(unsigned(ADDRA(14 DOWNTO 11))));
  END PROCESS BUS1;

  BUS2: PROCESS (ADDRB(14 DOWNTO 11), conn_b)
  BEGIN  -- PROCESS BUS1
     DOUTB <= conn_b(to_integer(unsigned(ADDRB(14 DOWNTO 11))));
  END PROCESS BUS2;

END Behavioral;
