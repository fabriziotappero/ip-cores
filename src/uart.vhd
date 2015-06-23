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
-- Module Name:    uart_baudgen - Behavioral 
-- Create Date:    14:34:27 11/07/2009 
-- Description:    a UART and a fixed baud rate generator.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart is
    generic(CLOCK_FREQ  : std_logic_vector(31 downto 0);
            BAUD_RATE   : std_logic_vector(27 downto 0));
    port(   I_CLK     : in  std_logic;
            I_CLR     : in  std_logic;
 
            I_RD        : in  std_logic;
            I_WE        : in  std_logic;
 
            I_TX_DATA   : in  std_logic_vector(7 downto 0);
            I_RX        : in  std_logic;

            Q_TX        : out std_logic;
            Q_RX_DATA   : out std_logic_vector(7 downto 0);
            Q_RX_READY  : out std_logic;
            Q_TX_BUSY   : out std_logic);
end uart;
 
architecture Behavioral of uart is
 
component baudgen
    generic(CLOCK_FREQ  : std_logic_vector(31 downto 0);
            BAUD_RATE   : std_logic_vector(27 downto 0));
    port(   I_CLK       : in  std_logic;

            I_CLR       : in  std_logic;

            Q_CE_1      : out std_logic;
            Q_CE_16     : out std_logic);
end component;
 
signal B_CE_1           : std_logic;
signal B_CE_16          : std_logic;

component uart_rx
    port(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_CE_16     : in  std_logic;
            I_RX        : in  std_logic;

            Q_DATA      : out std_logic_vector(7 downto 0);
            Q_FLAG      : out std_logic);
end component;

signal R_RX_FLAG        : std_logic;

component uart_tx
    port(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_CE_1      : in  std_logic;
            I_DATA      : in  std_logic_vector(7 downto 0);
            I_FLAG      : in  std_logic;

            Q_TX_N      : out std_logic;
            Q_BUSY      : out std_logic);
end component;

signal L_RX_OLD_FLAG    : std_logic;
signal L_RX_READY       : std_logic;
signal L_TX_FLAG        : std_logic;
signal L_TX_DATA        : std_logic_vector(7 downto 0);
 
begin
 
    Q_RX_READY <= L_RX_READY;
 
    baud: baudgen
    generic map(CLOCK_FREQ  => CLOCK_FREQ,
                BAUD_RATE   => BAUD_RATE)
    port map(   I_CLK       => I_CLK,

                I_CLR       => I_CLR,
                Q_CE_1      => B_CE_1,
                Q_CE_16     => B_CE_16);
 
    rx: uart_rx
    port map(   I_CLK   => I_CLK,
                I_CLR   => I_CLR,
                I_CE_16 => B_CE_16,
                I_RX    => I_RX,

                Q_DATA  => Q_RX_DATA,
                Q_FLAG  => R_RX_FLAG);

    tx: uart_tx
    port map(   I_CLK   => I_CLK,
                I_CLR   => I_CLR,
                I_CE_1  => B_CE_1,
                I_DATA  => L_TX_DATA,
                I_FLAG  => L_TX_FLAG,

                Q_TX_N  => Q_TX,
                Q_BUSY  => Q_TX_BUSY);
 
    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_RX_OLD_FLAG <= R_RX_FLAG;
                L_RX_READY <= '0';
                L_TX_FLAG <= '0';
                L_TX_DATA <= X"33";
            else
                if (I_RD = '1') then          -- read Rx data
                    L_RX_READY    <= '0';
                end if;
 
                if (I_WE = '1') then          -- write Tx data
                    L_TX_FLAG  <= not L_TX_FLAG;
                    L_TX_DATA <= I_TX_DATA;
                end if;
 
                if (L_RX_OLD_FLAG /= R_RX_FLAG) then
                    L_RX_OLD_FLAG <= R_RX_FLAG;
                    L_RX_READY <= '1';
                end if;
            end if;
        end if;
    end process;
 
end Behavioral;

