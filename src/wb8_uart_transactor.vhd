-- UART transactor
--
-- Author:  Federico Aglietti, www.ipdesign.eu
-- Version: 2.0
-- Date:    30.08.2009
-- WishBone 8-bit bus compliant
--
-- Author:   Sebastian Witt
-- Date:     03.02.2008
-- Version:  1.0
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the
-- Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
-- Boston, MA  02111-1307  USA
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

use std.textio.all;
use work.uart_package.all;
use work.txt_util.all;

entity uart_transactor is
    generic (
                stim_file    : string := "./uart_stim.dat";    -- Stimulus input file
                log_file     : string := "./uart_log.txt"      -- Log file
            );
end uart_transactor;

architecture tb of uart_transactor is
    file stimulus : TEXT open read_mode is stim_file;           -- Open stimulus file for read
    file log      : TEXT open write_mode is log_file;           -- Open log file for write

    -- The DUT
    component uart_16750 is
    port (
        CLK         : in std_logic;                             -- Clock
        RST         : in std_logic;                             -- Reset
        BAUDCE      : in std_logic;                             -- Baudrate generator clock enable
        WB_CYC      : in std_logic;                             -- Chip select
        WB_STB      : in std_logic;                             -- Chip select
        WB_WE       : in std_logic;                             -- Write/NotRead to/from UART
        WB_ADR      : in std_logic_vector(31 downto 0);         -- Address input
        WB_DIN      : in std_logic_vector(7 downto 0);          -- Data bus input
        WB_DOUT     : out std_logic_vector(7 downto 0);         -- Data bus output
        WB_ACK      : out std_logic;                            -- Transaction ACK
        INT         : out std_logic;                            -- Interrupt output
        OUT1N       : out std_logic;                            -- Output 1
        OUT2N       : out std_logic;                            -- Output 2
        RCLK        : in std_logic;                             -- Receiver clock (16x baudrate)
        BAUDOUTN    : out std_logic;                            -- Baudrate generator output (16x baudrate)
        RTSN        : out std_logic;                            -- RTS output
        DTRN        : out std_logic;                            -- DTR output
        CTSN        : in std_logic;                             -- CTS input
        DSRN        : in std_logic;                             -- DSR input
        DCDN        : in std_logic;                             -- DCD input
        RIN         : in std_logic;                             -- RI input
        SIN         : in std_logic;                             -- Receiver input
        SOUT        : out std_logic                             -- Transmitter output
    );
    end component;
    component slib_clock_div is
        generic (
            RATIO       : integer := 18     -- Clock divider ratio
        );
        port (
            CLK         : in std_logic;     -- Clock
            RST         : in std_logic;     -- Reset
            CE          : in std_logic;     -- Clock enable input
            Q           : out std_logic     -- New clock enable output
        );
    end component;


    -- DUT signals
    signal clk, rst                 : std_logic;
    signal uart_if_in               : uart_in_t;
    signal uart_if_out              : uart_out_t;    
    signal int                      : std_logic;
    signal baudce, rclk, baudoutn   : std_logic;
    signal out1n, out2n, rtsn, dtrn, ctsn, dsrn, dcdn, rin, sin, sout : std_logic;

    constant cycle : time := 30 ns;

begin
    -- Main clock
    CLOCK: process
    begin
        clk <= '0';
        wait for cycle/2;
        clk <= '1';
        wait for cycle/2;
    end process;

    -- Baudrate generator clock enable
    BGCE: slib_clock_div generic map (RATIO => 18) port map (clk, rst, '1', baudce);

    rclk <= baudoutn;
    
    DUT: uart_16750 port map (  CLK     => CLK,
                                RST     => RST,
                                BAUDCE  => BAUDCE,
                                WB_CYC  => uart_if_in.WB_CYC,
                                WB_STB  => uart_if_in.WB_STB,
                                WB_WE   => uart_if_in.WB_WE,
                                WB_ADR  => uart_if_in.WB_ADR,
                                WB_DIN  => uart_if_in.WB_DIN,
                                WB_DOUT => uart_if_out.WB_DOUT,
                                WB_ACK  => uart_if_out.WB_ACK,
                                INT     => int,
                                OUT1N   => out1n,
                                OUT2N   => out2n,
                                RCLK    => rclk,
                                BAUDOUTN=> baudoutn,
                                RTSN    => rtsn,
                                DTRN    => dtrn,
                                CTSN    => ctsn,
                                DSRN    => dsrn,
                                DCDN    => dcdn,
                                RIN     => rin,
                                SIN     => sin,
                                SOUT    => sout
                             );

    -- Main transaction process
    TRANPROC: process
        variable s          : string(1 to 100);
        variable address    : std_logic_vector(2 downto 0);
        variable data       : std_logic_vector(7 downto 0);
        variable data2      : std_logic_vector(7 downto 0);
    begin
        -- Default values
        rst  <= '1';
        ctsn <= '1';
        dsrn <= '1';
        dcdn <= '1';
        rin  <= '1';
        sin  <= '1';
        uart_if_in.WB_ADR <= (others => '0');
        uart_if_in.WB_DIN <= (others => '0');
        uart_if_in.WB_CYC <= '0';
        uart_if_in.WB_STB <= '0';
        uart_if_in.WB_WE  <= '0';



        wait until falling_edge(clk);

        -- Get commands from stimulus file
        while not endfile(stimulus) loop
            str_read(stimulus, s);                                  -- Read line into string

            if (s(1 to 4) = "#SET") then                            -- Set values
                                                                    -- Format: RSTN CTSN DSRN DCDN RIN
                rst          <= to_std_logic(s(6));
                --CTSN         <= to_std_logic(s(8));
                --DSRN         <= to_std_logic(s(10));
                --DCDN         <= to_std_logic(s(12));
                --RIN          <= to_std_logic(s(14));
            elsif (s(1 to 5) = "#WAIT") then                        -- Wait n cycles
                wait for integer'value(s(7 to 12))*cycle;
            elsif (s(1 to 3) = "#RD") then                          -- Read from UART and compare
                address := to_std_logic_vector(s(5 to 7));
                data := to_std_logic_vector(s(9 to 16));
                uart_read (clk,uart_if_in, uart_if_out, address, data2, log);
                if (not compare(data, data2)) then
                    print (log, time'image(now) & ": " & "Failed: Expected 0x" & hstr(data) & " got 0x" & hstr(data2));
                    assert FALSE report time'image(now) & ": " & "Failed: Expected 0x" & hstr(data) & " got 0x" & hstr(data2) severity failure;
                end if;
            elsif (s(1 to 3) = "#WR") then                          -- Write to LPC
                address := to_std_logic_vector(s(5 to 7));
                data := to_std_logic_vector(s(9 to 16));
                uart_write (clk, uart_if_in, uart_if_out, address, data, log);
            elsif (s(1 to 4) = "#LOG") then                         -- Write message to log
                print (log, time'image(now) & ": " & s(6 to 80));
            elsif (s(1 to 4) = "#CUO") then                         -- Check UART outputs INT OUT1N OUT2N RTSN DTRN
                data2(4 downto 0) := to_std_logic_vector(s(6 to 10));
                data(4 downto 0) := INT & OUT1N & OUT2N & RTSN & DTRN;
                if (not compare(data(3 downto 0), data2(3 downto 0))) then
                    print (log, time'image(now) & ": " & "UART outputs failed: Expected " &
                    str(data2(4 downto 0)) & " got " & str(data(4 downto 0)));
                else
                    print (log, time'image(now) & ": " & "UART outputs: " & str(data(4 downto 0)));
                end if;
            elsif (s(1 to 4) = "#END") then -- Sim end
                print (log, "*** Simulation END ***");
		assert FALSE report "*** Simulation END ***" severity failure;
            else
                print ("log, Unknown command: " & s);
            end if;
        end loop;

        wait;
    end process;

end tb;

