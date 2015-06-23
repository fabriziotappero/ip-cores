--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      LS8E Serial Printer
--!
--! \details
--!      This device provides a LS8E register set compatible
--!      interface to a serial printer.
--!
--!
--! \note
--!      The design information for this device is taken from
--!      the LS8E Engineering Specificaton number LS8-E-2
--!
--! \file
--!      ls8e.vhd
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
use work.ls8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! LS8E Serial Printer Entity
--

entity eLS8E is port (
    sys    : in  sys_t;                         --! Clock/Reset
    uartBR : in  uartBR_t;                      --! Baud Rate Select
    uartHS : in  uartHS_t;                      --! Handshaking Select
    devNUM : in  devNUM_t;                      --! IOT Device
    cpu    : in  cpu_t;                         --! CPU Input
    dev    : out dev_t;                         --! Device Output
    dtr    : in  std_logic;                     --! Data Terminal Ready
    dsr    : out std_logic;                     --! Data Set Ready
    rxd    : in  std_logic;                     --! Serial Data In
    txd    : out std_logic                      --! Serial Data Out
);
end eLS8E;

--
--! LS8E Serial Printer RTL
--

architecture rtl of eLS8E is
    -- State
    type     state_t   is (stateIdle, stateBuffered, stateWaiting);
    signal   state     : state_t;               --! Transmitter State
    signal   clkBR     : std_logic;             --! 16x Baud Rate Clock Enable
    -- PR8E Registers
    signal   ieSET     : std_logic;             --! Set/Clear Interrupt Enable Register
    signal   ieREG     : std_logic;             --! Interrupt Enable Register
    signal   flagCLR   : std_logic;             --! Clear Flag Register
    signal   flagSET   : std_logic;             --! Set Flag Register
    signal   flagREG   : std_logic;             --! Flag REG
    signal   busyREG   : std_logic;             --! Printer status
    -- RX signals
    signal   rxIntr    : std_logic;             --! UART Receiver has data
    signal   rxData    : ascii_t;               --! UART Receiver Buffer
    -- TX signals
    signal   txIntr    : std_logic;             --! UART Transmitter has sent data
    signal   txData    : ascii_t;               --! UART Transmitter Buffer
    -- Misc
    signal   start     : std_logic;             --! Start
    signal   loadUART  : std_logic;             --! Load Transmitter UART
    signal   DTRd      : std_logic_vector(0 to 1);  --! DTR demet

begin

    --
    --! LE8E Bus Interface
    --!
    --! \details
    --!     The Bus Interface decodes the individual LS8E IOT instructions.
    --!     The various operations: Enable Interrupts, Disable Interrupts,
    --!     Set Flag, and Clear Flag are decoded and provided to the
    --!     synchronous process that maintains the PR8E register state.
    --!
    --! \note
    --!     The Bus Interface is totally asynchronous.  The dev.ack,
    --!     dev.skip, and dev.devc signals are combinationally derived from
    --!     CPU output bus signals.  These signals will be sampled by the
    --!     CPU on the device bus input on the next clock cycle.
    --

    LS8E_BUSINTF : process(cpu.buss, devNUM, flagREG, ieREG)
    begin

        dev     <= nulldev;
        ieSET   <= '0';
        flagSET <= '0';
        flagCLR <= '0';
        start   <= '0';

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.addr(3 to 8) = devNUM and cpu.buss.lxdar = '1' then

            --
            -- Printer IOTs
            --

            case cpu.buss.addr(9 to 11) is

                --
                -- IOT 6xx0: Set Printer Flag
                --  Sets the Printer interrupt enable flip-flop
                --  so that an interrupt request will be generated
                --  when the printer flag is set.
                --

                when opLS0 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    flagSET  <= '1';

                --
                -- IOT 6xx1: Skip on Printer Flag
                --  This senses the printer flag.  If the flag
                --  is set, then the next instructon is skipped.
                --

                when opLS1 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= flagREG;

                --
                -- IOT 6xx2: Clear Printer Flag
                --

                when opLS2 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    flagCLR  <= '1';

                --
                -- IOT 6xx4: Load Printer Buffer
                --  Transfers AC(5:11) to the output buffer and
                --  later outputs the buffer content to the
                --  printer.  The Printer Flag is not cleared.
                --

                when opLS4 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    start    <= '1';

                --
                -- IOT 6xx5: Set/Clear Interrupt Enable
                --  Enable interrupts if AC(11) is set.
                --  Disable interrupts if AC(11) is cleared.
                --

                when opLS5 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    ieSET    <= '1';

                --
                -- IOT 6xx6: Load Printer Buffer Sequence
                --  Transfers AC(5:11) to the output buffer and
                --  later outputs the buffer content to the
                --  printer.  The Printer Flag is cleared.
                --

                when opLS6 =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    flagCLR  <= '1';
                    start    <= '1';

                --
                -- Everything else
                --

                when others =>
                    null;

            end case;
        end if;

        dev.intr <= flagREG and ieREG;
        dev.data <= o"0000";

    end process;

    --
    --! This process maintains the LS8E Registers
    --!
    --! -# The Printer Flag is cleared by initialize or CAF (IOCLR)
    --! -# The Interupt Enable is set by initialize or CAF (IOCLR)
    --

    REG_LS8E : process(sys)
    begin
        if sys.rst = '1' then

            ieREG    <= '1';
            flagREG  <= '0';
            loadUART <= '0';
            txData   <= (others => '0');
            state    <= stateIdle;

        elsif rising_edge(sys.clk) then

            if cpu.buss.ioclr = '1' then

                ieREG   <= '1';
                flagREG <= '0';
                
            else

                --
                -- Update Interrupt Enable Register
                --

                if ieSET = '1' then
                    ieREG <= cpu.buss.data(11);
                end if;

                --
                -- Update Flag Register
                --

                if flagCLR = '1' then
                    flagREG <= '0';
                elsif flagSET = '1' or txIntr = '1' then
                    flagREG <= '1';
                end if;

                --
                -- Send character
                --

                case state is

                    --
                    -- stateIdle:
                    -- Wait for print IOT.  Buffer character to print.
                    --

                    when stateIdle =>
                        if start = '1' then
                            txData <= cpu.buss.data(4 to 11);
                            state  <= stateBuffered;
                        end if;

                    --
                    -- stateBuffered:
                    -- Wait for printer to be not busy.  Load UART
                    --
                        
                    when stateBuffered =>
                        if busyREG = '0' then
                            loadUART <= '1';
                            state    <= stateWaiting;
                        end if;

                    --
                    -- stateWaiting:
                    -- Wait for IOT to finish.
                    --
                        
                    when stateWaiting =>
                        if start = '0' then
                            state <= stateIdle;
                        end if;
                        
                    --
                    -- Everything Else
                    --
                        
                    when others =>
                        null;
                        
                end case;

            end if;
        end if;
    end process REG_LS8E;

    --
    --! This process keeps track of the printer status.
    --! The printer status can be controlled by hardware (DTR)
    --! signal or by software (XON/XOFF) protocol.
    --

    REG_BUSY : process(sys)
    begin
        if sys.rst = '1' then

            busyREG <= '0';
            DTRd    <= (others => '0');

        elsif rising_edge(sys.clk) then

            if cpu.buss.ioclr = '1' then

                busyREG   <= '0';

            else

                --
                -- Synchronize DTR
                --
              
                DTRd(0) <= dtr;
                DTRd(1) <= DTRd(0);

                case uartHS is

                    --
                    -- No Handskaking
                    --

                    when uartHSnone =>
                        busyREG <= '0';

                    --
                    -- Hardware Handshaking
                    --

                    when uartHShw =>
                        busyREG <= DTRd(1);

                    --
                    -- Software (XON/XOFF) handshaking
                    --

                    when uartHSsw =>
                        if rxIntr = '1' then
                            if rxdata = xon then
                                busyREG <= '1';
                            elsif rxdata = xoff then
                                busyREG <= '0';
                            end if;
                        end if;

                    --
                    -- Everythig Else
                    --

                    when others =>
                        null;

                end case;
            end if;
        end if;
    end process REG_BUSY;

    --
    --! UART Baud Rate Generator
    --

    iUART_BRG : entity work.eUART_BRG port map (
        sys    => sys,
        uartBR => uartBR,
        clkBR  => clkBR
    );

    --
    --! The UART Receiver is used for ACK/NAK handshaking
    --

    iUART_RX : entity work.eUART_RX port map (
        sys   => sys,
        clkBR => clkBR,
        rxd   => rxd,
        intr  => rxIntr,
        data  => rxData
    );

    --
    --! The UART Transmitter sends data to the printer
    --

    iUART_TX : entity work.eUART_TX port map (
        sys   => sys,
        clkBR => clkBR,
        data  => txData,
        load  => loadUART,
        intr  => txIntr,
        txd   => txd
    );

end rtl;
