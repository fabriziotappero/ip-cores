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

ENTITY decoder IS
  PORT (address : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
        device  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        bussel  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END decoder;

ARCHITECTURE Behavioral OF decoder IS

BEGIN

  -- purpose: Decode the address to control devices
  -- type   : combinational
  -- inputs : address
  -- outputs: 
  decode : PROCESS (address)
  BEGIN  -- PROCESS decode

    CASE address IS
      WHEN "111111111110000" =>
        device <= "00000001";
        bussel <= "00000001";
      WHEN "111111111110001" =>
        device <= "00000010";
        bussel <= "00000010";
      WHEN "111111111110010" =>
        device <= "00000100";
        bussel <= "00000100";
      WHEN "111111111110011" =>
        device <= "00001000";
        bussel <= "00001000";
      WHEN OTHERS =>
        device <= "00000000";
        bussel <= "00010000";
    END CASE;
  END PROCESS decode;

END Behavioral;

