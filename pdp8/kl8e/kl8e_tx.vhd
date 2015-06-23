--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E UART Transmitter
--!
--! \details
--!      The UART Transmitter is hard configured for:
--!      - 8 data bits
--!      - no parity
--!      - 1 stop bit
--!
--! \note
--!      The TTY data is transmitted with 7 bits of data and mark
--!      parity where the the parity is generated in the software
--!      and is sent as the MSB of data.
--!
--!      From the point-of-view of the UART this is just 8-bit
--!      data with no parity.
--!
--!      From the point-of-view of your terminal emulator, the
--!      data is 7 bits with mark parity (or 7 bits of data with
--!      two stop bits). 
--!
--!      This seemingly odd behaviour is is traceable to the
--!      operation of the old teletypes which were mark parity.
--!
--! \file
--!      kl8e_tx.vhd
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
use work.kl8e_types.all;                        --! KL8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! KL8E UART Transmitter Entity
--

entity eKL8E_TX is port (
    sys    : in  sys_t;                         --! Clock/Reset
    intEN  : in  std_logic;                     --! Interrupt Enable
    clkBR  : in  std_logic;                     --! Clock Enable (for Baud Rate)
    devNUM : in  devNUM_t;                      --! IOT Device
    cpu    : in  cpu_t;                         --! CPU Output
    dev    : out dev_t;                         --! Device Output
    txd    : out std_logic                      --! Serial Data Out
);
end eKL8E_TX;

--
--! KL8E UART Transmitter RTL
--

architecture rtl of eKL8E_TX is

    signal tirCLR   : std_logic;                --! Teleprinter Interrupt Request Clear
    signal tirSET   : std_logic;                --! Teleprinter Interrupt Request Set
    signal tirREG   : std_logic;                --! Teleprinter Interrupt Request
    signal loadUART : std_logic;                --! Load Transmitter Buffer
    signal intr     : std_logic;                --! UART Interrupt
    signal data     : ascii_t;                  --! UART Data

begin

    --
    --! Bus Interface
    --

    KL8E_BUSINTF : process(cpu.buss, tirREG, intEN, devNUM)
    begin

        tirSET   <= '0';
        tirCLR   <= '0';
        loadUART <= '0';
        dev      <= nulldev;

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.addr(3 to 8) = devNUM and cpu.buss.lxdar = '1' then

            case cpu.buss.addr(9 to 11) is

                --
                -- IOT 6xx0: TFL - Teleprinter Flag Set
                --

                when opTFL =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    tirSET   <= '1';
                    tirCLR   <= '0';
                    loadUART <= '0';

                --
                -- IOT 6xx1: TSF - Teleprinter Skip if Flag
                --

                when opTSF =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= tirREG;
                    tirSET   <= '0';
                    tirCLR   <= '0';
                    loadUART <= '0';

                --
                -- IOT 6xx2: TCF - Teleprinter Clear Flag
                --

                when opTCF =>
                    dev.ack  <= '1';
                    dev.devc <= devWRCLR;
                    dev.skip <= '0';
                    tirSET   <= '0';
                    tirCLR   <= '1';
                    loadUART <= '0';

                --
                -- IOT 6xx4: TPC - Teleprinter Print Character
                --

                when opTPC =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    tirSET   <= '0';
                    tirCLR   <= '0';
                    loadUART <= '1';

                --
                -- IOT 6xx5: TSK: Teleprinter Skip
                -- 

                when opTSK =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= intEN;
                    tirSET   <= '0';
                    tirCLR   <= '0';
                    loadUART <= '0';

                --
                -- IOT 6xx6: TLS: Teleprinter Load and Start
                --

                when opTLS =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    tirSET   <= '0';
                    tirCLR   <= '1';
                    loadUART <= '1';

                --
                -- IOT 6xx3 and 6xx7:
                --

                when others =>
                    null;

            end case;
        end if;

        dev.intr <= tirREG and intEN;

    end process KL8E_BUSINTF;

    --
    --! UART Data
    --
    
    data <= cpu.buss.data(4 to 11);
    
    --
    --! UART Transmitter
    --

    iUART_TX : entity work.eUART_TX port map (
        sys   => sys,
        clkBR => clkBR,
        data  => data,
        load  => loadUART,
        intr  => intr,
        txd   => txd
    );

    --
    --! Teleprinter Interrupt Request Flip-Flop
    --!
    --! The CAF instruction (IOCLR) should clear the transmit
    --! interupt flag.
    --

    KL8E_TIR : process(sys)
    begin
        if sys.rst = '1' then
            tirREG  <= '0';
        elsif rising_edge(sys.clk) then
            if cpu.buss.ioclr = '1' or tirCLR = '1' then
                tirREG <= '0';
            elsif tirSET = '1' or intr = '1'then
                tirREG <= '1';
            end if;
        end if;
    end process KL8E_TIR;

end rtl;
