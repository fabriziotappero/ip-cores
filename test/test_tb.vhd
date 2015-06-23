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
-- Module Name:    alu - Behavioral 
-- Create Date:    16:47:24 12/29/2009 
-- Description:    arithmetic logic unit of a CPU
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
end testbench;
 
architecture Behavioral of testbench is

component avr_fpga
    port (  I_CLK_100   : in  std_logic;
            I_SWITCH    : in  std_logic_vector(9 downto 0);
            I_RX        : in  std_logic;

            Q_7_SEGMENT : out std_logic_vector(6 downto 0);
            Q_LEDS      : out std_logic_vector(3 downto 0);
            Q_TX        : out std_logic);
end component;

signal L_CLK_100            : std_logic;
signal L_LEDS               : std_logic_vector(3 downto 0);
signal L_7_SEGMENT          : std_logic_vector(6 downto 0);
signal L_RX                 : std_logic;
signal L_SWITCH             : std_logic_vector(9 downto 0);
signal L_TX                 : std_logic;

signal	L_CLK_COUNT         : integer := 0;

begin

    fpga: avr_fpga
    port map(   I_CLK_100   => L_CLK_100,
                I_SWITCH    => L_SWITCH,
                I_RX        => L_RX,

                Q_LEDS      => L_LEDS,
                Q_7_SEGMENT => L_7_SEGMENT,
                Q_TX        => L_TX);

    process -- clock process for CLK_100,
    begin
        clock_loop : loop
            L_CLK_100 <= transport '0';
            wait for 5 ns;

            L_CLK_100 <= transport '1';
            wait for 5 ns;
        end loop clock_loop;
    end process;

    process(L_CLK_100)
    begin
        if (rising_edge(L_CLK_100)) then
            case L_CLK_COUNT is
                when 0 => L_SWITCH <= "0011100000";   L_RX <= '0';
                when 2 => L_SWITCH(9 downto 8) <= "11";
                when others =>
            end case;
            L_CLK_COUNT <= L_CLK_COUNT + 1;
        end if;
    end process;
end Behavioral;

