--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      PR8E Paper Tape Reader (PTR)
--!
--! \details
--!      This device provides a PR8E register set compatible
--!      interface to a serial Decitek 762 Paper Tape Reader (PTR).
--!
--!      What follows is specific to the Decitek 762 PTR:
--!
--!      There is bi-directional serial interface between the PR8E
--!      controller and the PTR.  The PR8E sends command to the PTR
--!      and the PTR responds with data.
--!
--!      The interface operates as follows:
--!      -# The PR8E sends a 'Single Step Right' command (ASCII
--!         character 'R') to PTR which advances the paper tape one
--!         character.
--!      -# The PTR responds by sending the character that was read
--!         back from the paper tape to the PR8E.
--!
--! \note
--!      The DEC PR8E Paper Tape Reader interface is fundamentally
--!      incompatible with many inexpensive serial Paper Tape
--!      Readers.   The inexpensive paper tape readers simply
--!      stream bytes into the interface.  Some may add a XON/XOFF
--!      interface.
--!
--!      A compatible Paper Tape Reader must send one character and
--!      wait for the interface to command the Paper Tape reader
--!      to send the next character.
--!
--! \file
--!      pr8e.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use work.uart_types.all;                        --! UART Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! PR8E Serial Paper Tape Reader Entity
--

entity ePR8E is port (
    sys       : in  sys_t;                      --! Clock/Reset
    uartBR    : in  uartBR_t;                   --! Baud Rate Select
    uartHS    : in  uartHS_t;                   --! Handshaking Select
    ptrdevNUM : in  devNUM_t;                   --! PTR IOT Device
    ptpdevNUM : in  devNUM_t;                   --! PTP IOT Device
    cpu       : in  cpu_t;                      --! CPU Input
    dev       : out dev_t;                      --! Device Output
    cts       : in  std_logic;                  --! CTS In
    rts       : out std_logic;                  --! RTS Out
    rxd       : in  std_logic;                  --! Serial Data In
    txd       : out std_logic                   --! Serial Data Out
);
end ePR8E;

--
--! PR8E Serial Paper Tape Reader RTL
--

architecture rtl of ePR8E is
    signal   clkBR     : std_logic;             --! 16x Baud Rate Clock Enable
    -- PR8E Registers
    signal   ieCLR     : std_logic;             --! Clear Interrupt Enable Register
    signal   ieSET     : std_logic;             --! Set Interrupt Enable Register
    signal   ieREG     : std_logic;             --! Interrupt Enable Register
    signal   flagCLR   : std_logic;             --! Clear Flag Register
    signal   flagREG   : std_logic;             --! Flag REG
    signal   dataREG   : data_t;                --! Received Data Register
    -- RX signals
    signal   rxIntr    : std_logic;             --! UART Receiver has data
    signal   rxData    : ascii_t;               --! UART Receiver Data
    -- TX signals
    signal   start     : std_logic;             --! Start
    signal   lastStart : std_logic;             --! Last start
    signal   loadUART  : std_logic;             --! Load Transmitter UART
    constant ascii_R   : ascii_t := x"52";      --! The letter 'R' in ascii

begin

    --
    --! PR8E Bus Interface
    --!
    --! \details
    --!     The Bus Interface decodes the individual PR8E IOT instructions.
    --!     The various operations: Enable Interrupts, Disable Interrupts,
    --!     Clear Flag are decoded and provided to the synchronous process
    --!     that maintains the PR8E register state.
    --!
    --! \note
    --!     The Bus Interface is totally asynchronous.  The dev.ack,
    --!     dev.skip, and dev.devc signals are combinationally derived from
    --!     CPU output bus signals.  These signals will be sampled by the
    --!     CPU on the device bus input on the next clock cycle.
    --

    PR8E_BUSINTF : process(cpu.buss, ptrdevNUM, ptpdevNUM, flagREG, ieREG, dataREG)
    begin

        dev     <= nulldev;
        ieSET   <= '0';
        ieCLR   <= '0';
        flagCLR <= '0';
        start   <= '0';

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.lxdar = '1' then

            --
            -- Reader IOTs
            --

            if cpu.buss.addr(3 to 8) = ptrdevNUM then

                case cpu.buss.addr(9 to 11) is

                    --
                    -- IOT 6xx0: RPE - Set Reader/Punch Interrupt Enable
                    --  Sets the Reader/Punch interrupt enable flip-flop
                    --  so that an interrupt request will be generated
                    --  when the reader or punch flag is set.

                    when opRPE =>
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= '0';
                        ieSET    <= '1';

                    --
                    -- IOT 6xx1: RSF - Skip on Reader Flag
                    --  This senses the reader flag.  If the reader flag
                    --  is set, then the next instructon is skipped.
                    --

                    when opRSF =>
                        dev.ack  <= '1';
                        dev.devc <= devWR;
                        dev.skip <= flagREG;

                    --
                    --IOT 6xx2: RRB - Read Reader Buffer.
                    -- ORs the contents of the reader buffer into
                    -- AC(4 to 11) and clears the reader flag.
                    --

                    when opRRB =>
                        dev.ack  <= '1';
                        dev.devc <= devRD;
                        dev.skip <= '0';
                        flagCLR  <= '1';

                    --
                    -- IOT 6xx4: RFC - Reader Fetch Character.
                    --  Clears the reader flag.  Loads one character
                    --  into the RB from tape and sets the reader flag.
                    --

                    when opRFC =>
                        dev.ack  <= '1';
                        dev.devc <= devRD;
                        dev.skip <= '0';
                        flagCLR  <= '1';
                        start    <= '1';

                    --
                    -- IOT 6xx6: RRC - Read reader character and fetch next char
                    --  The content of the reader buffer is ORed into the AC.
                    --  The flag is immediately cleared, and a new character is
                    --  read from tape into the reader buffer.  The flags is
                    --  then set.
                    --  This is a microprogrammed combination of RRB (6012) and
                    --  RFC (6014).
                    --

                    when opRCC =>
                        dev.ack  <= '1';
                        dev.devc <= devRD;
                        dev.skip <= '0';
                        flagCLR  <= '1';
                        start    <= '1';

                    --
                    -- Everything else
                    --

                    when others =>
                        null;

                end case;

            --
            -- Punch IOTs
            --

            elsif cpu.buss.addr(3 to 8) = ptpdevNUM then

                --
                -- IOT 6xx0: PCE - Clear Reader/Punch Interrupt Enable
                --  Clears the read/punch interrupt enable flip-flop
                --  so that interrupts cannot be generated.
                --

                if cpu.buss.addr(9 to 11) = opPCE then
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    ieCLR    <= '1';
                end if;

            end if;
        end if;

        dev.intr <= flagREG and ieREG;
        dev.data <= dataREG;

    end process PR8E_BUSINTF;

    --
    --! This process maintains the PR8E Registers
    --!
    --! -# The Reader Flag is cleared by initialize or CAF (IOCLR)
    --! -# The Interupt Enable is set by initialize or CAF (IOCLR)
    --

    REG_PR8E : process(sys)
    begin
        if sys.rst = '1' then

            ieREG   <= '1';
            flagREG <= '0';
            dataREG <= (others => '0');

        elsif rising_edge(sys.clk) then

            if cpu.buss.ioclr = '1' then

                ieREG   <= '1';
                flagREG <= '0';
                dataREG <= (others => '0');

            else

                --
                -- Update Interrupt Enable Register
                --

                if ieCLR = '1' then
                    ieREG <= '0';
                elsif ieSET = '1' then
                    ieREG <= '1';
                end if;

                --
                -- Update Flag Register
                --

                if flagCLR = '1' then
                    flagREG <= '0';
                elsif rxIntr = '1' then
                    flagREG <= '1';
                end if;

                --
                -- Update Data Register
                --

                if rxIntr = '1' then
                    dataREG <= "0000" & rxData;
                end if;

                --
                -- Send Command to get next character
                --

                if start = '1' and lastStart = '0' then
                    loadUART <= '1';
                end if;
                lastStart <= start;

            end if;
        end if;
    end process REG_PR8E;

    --
    --! UART Baud Rate Generator
    --

    iUART_BRG : entity work.eUART_BRG port map (
        sys    => sys,
        uartBR => uartBR,
        clkBR  => clkBR
    );

    --
    --! The UART Receiver is used for receiving the data from
    --! the PTR.
    --

    iUART_RX : entity work.eUART_RX port map (
        sys   => sys,
        clkBR => clkBR,
        rxd   => rxd,
        intr  => rxIntr,
        data  => rxData
    );

    --
    --! The UART Transmitter sends commands to the PTR.
    --!
    --! \note
    --! -# this UART is hardwired to send the "Single Step
    --!    Right" command to the PTR, and
    --! -# the "intr" response is ignored because the PTR
    --!    should respond with the charcter that was read
    --!    from the paper tape.  The UART_RX will catch that
    --!    event.
    --

    iUART_TX : entity work.eUART_TX port map (
        sys   => sys,
        clkBR => clkBR,
        data  => ascii_R,
        load  => loadUART,
        intr  => open,
        txd   => txd
    );

end rtl;
