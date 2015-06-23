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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY clock IS
  PORT (clock_in     : IN  STD_LOGIC;
        clock_out    : OUT STD_LOGIC;
        clock_locked : OUT STD_LOGIC);
END clock;

ARCHITECTURE Behavioral OF clock IS

  COMPONENT clk_wiz_v3_3 IS
    PORT
      (                                 -- Clock in ports
        CLK_IN1  : IN  STD_LOGIC;
        -- Clock out ports
        CLK_OUT1 : OUT STD_LOGIC;
        -- Status and control signals
        LOCKED   : OUT STD_LOGIC
        );
  END COMPONENT clk_wiz_v3_3;

BEGIN

  CLK1 : clk_wiz_v3_3 PORT MAP (
    CLK_IN1  => clock_in,
    CLK_OUT1 => clock_out,
    LOCKED   => clock_locked);

END Behavioral;

