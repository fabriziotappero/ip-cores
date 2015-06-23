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
-- Module Name:    segment7 - Behavioral 
-- Create Date:    12:52:16 11/11/2009 
-- Description:    a 7 segment LED display interface.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity segment7 is
    port ( I_CLK        : in  std_logic;

           I_CLR        : in  std_logic;
           I_OPC        : in  std_logic_vector(15 downto 0);
           I_PC         : in  std_logic_vector(15 downto 0);

           Q_7_SEGMENT : out std_logic_vector( 6 downto 0));
end segment7;

--      Signal      Loc Alt
---------------------------
--      SEG_LED(0)  V3  A
--      SEG_LED(1)  V4  B
--      SEG_LED(2)  W3  C
--      SEG_LED(3)  T4  D
--      SEG_LED(4)  T3  E
--      SEG_LED(5)  U3  F
--      SEG_LED(6)  U4  G
--
architecture Behavioral of segment7 is

function lmap(VAL: std_logic_vector( 3 downto 0))
         return std_logic_vector is
begin
    case VAL is         --      6543210
        when "0000" =>  return "0111111";   -- 0
        when "0001" =>  return "0000110";   -- 1
        when "0010" =>  return "1011011";   -- 2
        when "0011" =>  return "1001111";   -- 3
        when "0100" =>  return "1100110";   -- 4    ----A----       ----0----
        when "0101" =>  return "1101101";   -- 5    |       |       |       |
        when "0110" =>  return "1111101";   -- 6    F       B       5       1
        when "0111" =>  return "0000111";   -- 7    |       |       |       |
        when "1000" =>  return "1111111";   -- 8    +---G---+       +---6---+
        when "1001" =>  return "1101111";   -- 9    |       |       |       |
        when "1010" =>  return "1110111";   -- A    E       C       4       2
        when "1011" =>  return "1111100";   -- b    |       |       |       |
        when "1100" =>  return "0111001";   -- C    ----D----       ----3----
        when "1101" =>  return "1011110";   -- d
        when "1110" =>  return "1111001";   -- E
        when others =>  return "1110001";   -- F
    end case;
end;

signal L_CNT            : std_logic_vector(27 downto 0);
signal L_OPC            : std_logic_vector(15 downto 0);
signal L_PC             : std_logic_vector(15 downto 0);
signal L_POS            : std_logic_vector( 3 downto 0);

begin

    process(I_CLK)    -- 20 MHz
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_POS <= "0000";
                L_CNT <= X"0000000";
                Q_7_SEGMENT <= "1111111";
            else
                L_CNT <= L_CNT + X"0000001";
                if (L_CNT =  X"0C00000") then
                    Q_7_SEGMENT <= "1111111";      -- blank
                elsif (L_CNT =  X"1000000") then
                    L_CNT <= X"0000000";
                    L_POS <= L_POS + "0001";
                    case L_POS is
                        when "0000" =>  -- blank
                            Q_7_SEGMENT <= "1111111";
                        when "0001" =>
                            L_PC <= I_PC;       -- sample PC
                            L_OPC <= I_OPC;     -- sample OPC
                            Q_7_SEGMENT <= not lmap(L_PC(15 downto 12));
                        when "0010" =>
                            Q_7_SEGMENT <= not lmap(L_PC(11 downto  8));
                        when "0011" =>
                            Q_7_SEGMENT <= not lmap(L_PC( 7 downto  4));
                        when "0100" =>
                            Q_7_SEGMENT <= not lmap(L_PC( 3 downto  0));
                        when "0101" =>  -- minus
                            Q_7_SEGMENT <= "0111111";
                        when "0110" =>
                            Q_7_SEGMENT <= not lmap(L_OPC(15 downto 12));
                        when "0111" =>
                            Q_7_SEGMENT <= not lmap(L_OPC(11 downto  8));
                        when "1000" =>
                            Q_7_SEGMENT <= not lmap(L_OPC( 7 downto  4));
                        when "1001" =>
                            Q_7_SEGMENT <= not lmap(L_OPC( 3 downto  0));
                            L_POS <= "0000";
                        when others =>
                            L_POS <= "0000";
                    end case;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;

