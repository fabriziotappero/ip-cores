-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2009, 2010 Dr. Juergen Sauermann
-- 
--  This code is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This code is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this code (see the file named COPYING).
--  If not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Module Name:    Register - Behavioral 
-- Create Date:    12:37:55 10/28/2009 
-- Description:    a register pair of a CPU.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_16 is
    port (  I_CLK       : in  std_logic;

            I_D         : in  std_logic_vector (15 downto 0);
            I_WE        : in  std_logic_vector ( 1 downto 0);

            Q           : out std_logic_vector (15 downto 0));
end reg_16;

architecture Behavioral of reg_16 is

signal L                : std_logic_vector (15 downto 0) := X"7777";
begin

    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_WE(1) = '1') then 
                L(15 downto 8) <= I_D(15 downto 8);
            end if;
            if (I_WE(0) = '1') then 
                L( 7 downto 0) <= I_D( 7 downto 0);
            end if;
        end if;
    end process;

    Q <= L;

end Behavioral;

