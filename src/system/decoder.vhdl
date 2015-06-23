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

-- The decoder is a special component. It must map the desired IO addresses to
-- the different IO components and also select the output bus.
-- Its output are enable signals for IO devices, and a value to select the
-- input for the output bus multiplexer.
-- Current mapping:
-- Address space is X"0000" to X"7FFF"
-- Boot program is  X"7FF0" to X"7FFF"
-- gpio_1 is        X"7FD0" to X"7FD3"
-- gpio_2 is        X"7FD4" to X"7FD7"
-- gpio_3 is        X"7FD8" to X"7FDB"
-- IO ports are mapped to input 0 to 6 of the multiplexer, and memory is mapped
-- to input 7
-- Change: instead of decoding the MAR register, the decoder will take its
-- input now from the register file B output and register its outputs at the
-- same as the MAR.

ENTITY decoder IS
  PORT (
    clk     : IN  STD_LOGIC;
    ena     : IN  STD_LOGIC;
    a1      : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
    gpio_1  : OUT STD_LOGIC;
    gpio_2  : OUT STD_LOGIC;
    gpio_3  : OUT STD_LOGIC;
    bus_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY decoder;

ARCHITECTURE Behavioral OF decoder IS

BEGIN  -- Behavioral

  PROCESS (CLK)
  BEGIN

    IF rising_edge(CLK) THEN

      gpio_1  <= '0';
      gpio_2  <= '0';
      gpio_3  <= '0';
      bus_sel <= "111";

      IF ena = '1' THEN

        CASE a1 IS
          WHEN "111" & X"FE0" =>
            gpio_1  <= '1';
            bus_sel <= "000";
          WHEN "111" & X"FE1" =>
            gpio_2  <= '1';
            bus_sel <= "001";
          WHEN "111" & X"FE2" =>
            gpio_3  <= '1';
            bus_sel <= "010";
          WHEN OTHERS =>
            NULL;
        END CASE;
        
      END IF;
      
    END IF;
    
  END PROCESS;

END Behavioral;
