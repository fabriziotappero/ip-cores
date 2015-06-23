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
-- Create Date:    16:15:54 12/26/2009 
-- Description:    the status register of a CPU.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity status_reg is
    port (  I_CLK       : in  std_logic;

            I_COND      : in  std_logic_vector ( 3 downto 0);
            I_DIN       : in  std_logic_vector ( 7 downto 0);
            I_FLAGS     : in  std_logic_vector ( 7 downto 0);
            I_WE_F      : in  std_logic;
            I_WE_SR     : in  std_logic;

            Q           : out std_logic_vector ( 7 downto 0);
            Q_CC        : out std_logic);
end status_reg;

architecture Behavioral of status_reg is

signal L                : std_logic_vector ( 7 downto 0);
begin

    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_WE_F = '1') then          -- write flags (from ALU)
                L <= I_FLAGS;
            elsif (I_WE_SR = '1') then      -- write I/O
                L <= I_DIN;
            end if;
        end if;
    end process;

    cond: process(I_COND, L)
    begin
        case I_COND(2 downto 0) is
            when "000"  => Q_CC <= L(0) xor I_COND(3);
            when "001"  => Q_CC <= L(1) xor I_COND(3);
            when "010"  => Q_CC <= L(2) xor I_COND(3);
            when "011"  => Q_CC <= L(3) xor I_COND(3);
            when "100"  => Q_CC <= L(4) xor I_COND(3);
            when "101"  => Q_CC <= L(5) xor I_COND(3);
            when "110"  => Q_CC <= L(6) xor I_COND(3);
            when others => Q_CC <= L(7) xor I_COND(3);
        end case;
    end process;

    Q <= L;

end Behavioral;

