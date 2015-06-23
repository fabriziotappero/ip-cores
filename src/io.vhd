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
-- Module Name:    io - Behavioral 
-- Create Date:    13:59:36 11/07/2009 
-- Description:    the I/O of a CPU (uart and general purpose I/O lines).
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity io is
    port (  I_CLK       : in  std_logic;

            I_CLR       : in  std_logic;
            I_ADR_IO    : in  std_logic_vector( 7 downto 0);
            I_DIN       : in  std_logic_vector( 7 downto 0);
            I_SWITCH    : in  std_logic_vector( 7 downto 0);
            I_RD_IO     : in  std_logic;
            I_RX        : in  std_logic;
            I_WE_IO     : in  std_logic;

            Q_7_SEGMENT : out std_logic_vector( 6 downto 0);
            Q_DOUT      : out std_logic_vector( 7 downto 0);
            Q_INTVEC    : out std_logic_vector( 5 downto 0);
            Q_LEDS      : out std_logic_vector( 1 downto 0);
            Q_TX        : out std_logic);
end io;

architecture Behavioral of io is

component uart
    generic(CLOCK_FREQ  : std_logic_vector(31 downto 0);
            BAUD_RATE   : std_logic_vector(27 downto 0));
    port(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_RD        : in  std_logic;
            I_WE        : in  std_logic;
            I_RX        : in  std_logic;          
            I_TX_DATA   : in  std_logic_vector(7 downto 0);

            Q_RX_DATA   : out std_logic_vector(7 downto 0);
            Q_RX_READY  : out std_logic;
            Q_TX        : out std_logic;
            Q_TX_BUSY   : out std_logic);
end component;

signal U_RX_READY       : std_logic;
signal U_TX_BUSY        : std_logic;
signal U_RX_DATA        : std_logic_vector( 7 downto 0);

signal L_INTVEC         : std_logic_vector( 5 downto 0);
signal L_LEDS           : std_logic;
signal L_RD_UART        : std_logic;
signal L_RX_INT_ENABLED : std_logic;
signal L_TX_INT_ENABLED : std_logic;
signal L_WE_UART        : std_logic;

begin
    urt: uart
    generic map(CLOCK_FREQ  => std_logic_vector(conv_unsigned(25000000, 32)),
                BAUD_RATE   => std_logic_vector(conv_unsigned(   38400, 28)))
    port map(   I_CLK      => I_CLK,
                I_CLR      => I_CLR,
                I_RD       => L_RD_UART,
                I_WE       => L_WE_UART,
                I_TX_DATA  => I_DIN(7 downto 0),
                I_RX       => I_RX,

                Q_TX       => Q_TX,
                Q_RX_DATA  => U_RX_DATA,
                Q_RX_READY => U_RX_READY,
                Q_TX_BUSY  => U_TX_BUSY);

    -- IO read process
    --
    iord: process(I_ADR_IO, I_SWITCH,
                  U_RX_DATA, U_RX_READY, L_RX_INT_ENABLED,
                  U_TX_BUSY, L_TX_INT_ENABLED)
    begin
        -- addresses for mega8 device (use iom8.h or #define __AVR_ATmega8__).
        --
        case I_ADR_IO is
            when X"2A"  => Q_DOUT <=             -- UCSRB:
                               L_RX_INT_ENABLED  -- Rx complete int enabled.
                             & L_TX_INT_ENABLED  -- Tx complete int enabled.
                             & L_TX_INT_ENABLED  -- Tx empty int enabled.
                             & '1'               -- Rx enabled
                             & '1'               -- Tx enabled
                             & '0'               -- 8 bits/char
                             & '0'               -- Rx bit 8
                             & '0';              -- Tx bit 8
            when X"2B"  => Q_DOUT <=             -- UCSRA:
                               U_RX_READY       -- Rx complete
                             & not U_TX_BUSY    -- Tx complete
                             & not U_TX_BUSY    -- Tx ready
                             & '0'              -- frame error
                             & '0'              -- data overrun
                             & '0'              -- parity error
                             & '0'              -- double dpeed
                             & '0';             -- multiproc mode
            when X"2C"  => Q_DOUT <= U_RX_DATA; -- UDR
            when X"40"  => Q_DOUT <=            -- UCSRC
                               '1'              -- URSEL
                             & '0'              -- asynchronous
                             & "00"             -- no parity
                             & '1'              -- two stop bits
                             & "11"             -- 8 bits/char
                             & '0';             -- rising clock edge

            when X"36"  => Q_DOUT <= I_SWITCH;  -- PINB
            when others => Q_DOUT <= X"AA";
        end case;
    end process;

    -- IO write process
    --
    iowr: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_RX_INT_ENABLED  <= '0';
                L_TX_INT_ENABLED  <= '0';
            elsif (I_WE_IO = '1') then
                case I_ADR_IO is
                    when X"38"  => -- PORTB
                                   Q_7_SEGMENT <= I_DIN(6 downto 0);
                                   L_LEDS <= not L_LEDS;
                    when X"2A"  => -- UCSRB
                                   L_RX_INT_ENABLED <= I_DIN(7);
                                   L_TX_INT_ENABLED <= I_DIN(6);
                    when X"2B"  => -- UCSRA:       handled by uart
                    when X"2C"  => -- UDR:         handled by uart
                    when X"40"  => -- UCSRC/UBRRH: (ignored)
                    when others =>
                end case;
            end if;
        end if;
    end process;

    -- interrupt process
    --
    ioint: process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then
                L_INTVEC <= "000000";
            else
                case L_INTVEC is
                    when "101011" => -- vector 11 interrupt pending.
                        if (L_RX_INT_ENABLED and U_RX_READY) = '0' then
                            L_INTVEC <= "000000";
                        end if;

                    when "101100" => -- vector 12 interrupt pending.
                        if (L_TX_INT_ENABLED and not U_TX_BUSY) = '0' then
                            L_INTVEC <= "000000";
                        end if;

                    when others   =>
                        -- no interrupt is pending.
                        -- We accept a new interrupt.
                        --
                        if    (L_RX_INT_ENABLED and U_RX_READY) = '1' then
                            L_INTVEC <= "101011";            -- _VECTOR(11)
                        elsif (L_TX_INT_ENABLED and not U_TX_BUSY) = '1' then
                            L_INTVEC <= "101100";            -- _VECTOR(12)
                        else
                            L_INTVEC <= "000000";            -- no interrupt
                        end if;
                end case;
            end if;
        end if;
    end process;

    L_WE_UART <= I_WE_IO when (I_ADR_IO = X"2C") else '0'; -- write UART UDR
    L_RD_UART <= I_RD_IO when (I_ADR_IO = X"2C") else '0'; -- read  UART UDR

    Q_LEDS(1) <= L_LEDS;
    Q_LEDS(0) <= not L_LEDS;
    Q_INTVEC  <= L_INTVEC;

end Behavioral;

