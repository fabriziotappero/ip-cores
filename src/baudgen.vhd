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
-- Module Name:    baudgen - Behavioral 
-- Create Date:    13:51:24 11/07/2009 
-- Description:    fixed baud rate generator
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baudgen is
    generic(clock_freq  : std_logic_vector(31 downto 0);
	        baud_rate   : std_logic_vector(27 downto 0));
    port(   I_CLK       : in  std_logic;

            I_CLR       : in  std_logic;
            Q_CE_1      : out std_logic;    -- baud x  1 clock enable
            Q_CE_16     : out std_logic);   -- baud x 16 clock enable
end baudgen;

 
architecture Behavioral of baudgen is
 
constant BAUD_16        : std_logic_vector(31 downto 0) := baud_rate & "0000";
constant LIMIT          : std_logic_vector(31 downto 0) := clock_freq - BAUD_16;
 
signal L_CE_16          : std_logic;
signal L_CNT_16         : std_logic_vector( 3 downto 0);
signal L_COUNTER        : std_logic_vector(31 downto 0);
 
begin
 
    baud16: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_COUNTER <= X"00000000";
            elsif (L_COUNTER >= LIMIT) then
                L_COUNTER <= L_COUNTER - LIMIT;
            else
                L_COUNTER <= L_COUNTER + BAUD_16;
            end if;
        end if;
    end process;
 
    baud1: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_CNT_16 <= "0000";
            elsif (L_CE_16 = '1') then
                L_CNT_16 <= L_CNT_16 + "0001";
            end if;
        end if;
    end process;

    L_CE_16 <= '1' when (L_COUNTER >= LIMIT) else '0';
    Q_CE_16 <= L_CE_16;
    Q_CE_1 <= L_CE_16 when L_CNT_16 = "1111" else '0';

end behavioral;
 
