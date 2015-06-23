--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E UART Receiver
--!
--! \details
--!      This device handles KL8E Receive operations.
--!
--!      The UART Receiver is hard configured for:
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
--!      kl8e_rx.vhd
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
--! KL8E UART Receiver Entity
--

entity eKL8E_RX is port (
    sys    : in  sys_t;                         --! Clock/Reset
    intEN  : out std_logic;                     --! Interrupt Enable
    clkBR  : in  std_logic;                     --! Clock Enable (for Baud Rate)
    devNUM : in  devNUM_t;                      --! IOT Device
    cpu    : in  cpu_t;                         --! CPU Input
    dev    : out dev_t;                         --! Device Output
    rxd    : in  std_logic                      --! Serial Data In
);
end eKL8E_RX;

--
--! KL8E UART Receiver RTL
--

architecture rtl of eKL8E_RX is
    signal kirCLR : std_logic;                  --! KBD Interrupt Request Clear
    signal kirREG : std_logic;                  --! KBD Interrupt Request
    signal kieMUX : std_logic;                  --! KBD Interrupt Enable MUX
    signal kieREG : std_logic;                  --! KBD Interrupt Enable REG
    signal datREG : ascii_t;                    --! KBD Received Data
    signal intr   : std_logic;                  --! UART Interrupt
    signal data   : ascii_t;                    --! UART Data

begin

    --
    --! Bus Interface
    --

    KL8E_BUSINTF : process(cpu.buss, kirREG, datREG, kieREG, devNUM)
    begin

        kirCLR  <= '0';
        kieMUX  <= kieREG;
        dev     <= nulldev;

        if cpu.buss.addr(0 to 2) = opIOT and cpu.buss.addr(3 to 8) = devNUM and cpu.buss.lxdar = '1' then

            case cpu.buss.addr(9 to 11) is

                --
                -- IOT 6xx0: KCF - Clear Keyboard Flag
                --

                when opKCF =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    kirCLR   <= '1';

                --
                -- IOT 6xx1: KSF - Skip on Keyboard Flag
                --

                when opKSF =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= kirREG;
                    kirCLR   <= '0';

                --
                -- IOT 6xx2: KCC - Clear Keyboard Flag, Clear AC
                --

                when opKCC =>
                    dev.ack  <= '1';
                    dev.devc <= devWRCLR;
                    dev.skip <= '0';
                    kirCLR   <= '1';

                --
                -- IOT 6xx4: KRS - Read Keyboard Buffer Status
                --

                when opKRS =>
                    dev.ack  <= '1';
                    dev.devc <= devRD;
                    dev.skip <= '0';
                    kirCLR   <= '0';

                --
                -- IOT 6xx5: KIE - Set/Clear Interrupt Enable
                --

                when opKIE =>
                    dev.ack  <= '1';
                    dev.devc <= devWR;
                    dev.skip <= '0';
                    kirCLR   <= '0';
                    kieMUX   <= cpu.buss.data(11);

                --
                -- IOT 6xx6: KRB - Read Keyboard Buffer Dynamic
                -- Clear Keyboard Flag, Clear AC, OR Keyboard Character into
                -- AC. This is a microprogrammed combination of KCC (6xx2) and
                -- KRS (6xx4).
                --

                when opKRB =>
                    dev.ack  <= '1';
                    dev.devc <= devRDCLR;
                    dev.skip <= '0';
                    kirCLR   <= '1';

                --
                -- IOT 6xx3 and 6xx7:
                --

                when others =>
                    null;

            end case;
        end if;

        dev.intr <= kirREG and kieREG;
        dev.data <= "0000" & datREG(0 to 7);

    end process KL8E_BUSINTF;

    --
    --! UART Receiver
    --

    iUART_RX : entity work.eUART_RX port map (
        sys   => sys,
        clkBR => clkBR,
        rxd   => rxd,
        intr  => intr,
        data  => data
    );

    --
    --! Keyboard Interrupt Enable Flip-Flop
    --!
    --! The CAF instruction (IOCLR) should enable interupts
    --!

    KL8E_KIE : process(sys)
    begin
        if sys.rst = '1' then
            kieREG <= '1';
        elsif rising_edge(sys.clk) then
            if cpu.buss.ioclr = '1' then
                kieREG <= '1';
            else
                kieREG <= kieMUX;
            end if;
        end if;
    end process KL8E_KIE;

    --
    --! Keyboard Interrupt Request Flip-Flop
    --!
    --! The CAF instruction (IOCLR) should clear the receive
    --! interupt flag.

    KL8E_KIR : process(sys)
    begin
        if sys.rst = '1' then
            kirREG <= '0';
        elsif rising_edge(sys.clk) then
            if cpu.buss.ioclr = '1' or kirCLR = '1' then
                kirREG <= '0';
            elsif intr = '1' then
                kirREG <= '1';
            end if;
        end if;
    end process KL8E_KIR;

    --
    --! UART Data Buffer
    --

    KL8E_BUF : process(sys)
    begin
        if sys.rst = '1' then
            datREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            if intr = '1' then
                datREG <= data;
            end if;
        end if;
    end process KL8E_BUF;

    intEN <= kieREG;

end rtl;
