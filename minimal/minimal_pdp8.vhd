--!
--! PDP-8 Processor
--!
--! \brief
--!      Minimal System
--!
--! \details
--!      Eve
--!
--! \file
--!      minimal_pdp8.vhd
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
use work.dk8e_types.all;                        --! DK8E Types
use work.kc8e_types.all;                        --! KC8E Types
use work.kl8e_types.all;                        --! KL8E Types
use work.rk8e_types.all;                        --! RK8E Types
use work.ls8e_types.all;                        --! LS8E Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types

--
--! Minimal PDP8 System Entity
--

entity eMINIMAL_PDP8 is port (
    -- System
    clk        : in  std_logic;                 --! Clock
    rst        : in  std_logic;                 --! Reset Button
    -- TTY1 Interfaces
    tty1RXD    : in  std_logic;                 --! TTY1 Receive Data
    tty1TXD    : out std_logic;                 --! TTY1 Transmit Data
    -- SD Interface
    sdMISO     : in  std_logic;                 --! SD Data In
    sdMOSI     : out std_logic;                 --! SD Data Out
    sdSCLK     : out std_logic;                 --! SD Clock
    sdCS       : out std_logic                  --! SD Chip Select

);
end eMINIMAL_PDP8;    

--
--! Minimal PDP8 System RTL
--

architecture rtl of eMINIMAL_PDP8 is

    signal swCNTL : swCNTL_t;
    signal swDATA : swDATA_t;
    signal swOPT  : swOPT_t;
         
begin

    --
    -- Options
    -- Setting the 'STARTUP' bit will cause the PDP8 to
    -- boot to the address in the switch register which
    -- is set to 0023 below
    --
    
    swOPT.KE8       <= '1'; 
    swOPT.KM8E      <= '1';
    swOPT.TSD       <= '1';
    swOPT.STARTUP   <= '1';

    --
    -- Front Panel Control Switches
    --
    
    swCNTL.boot     <= '0';
    swCNTL.lock     <= '0';
    swCNTL.loadADDR <= '0';
    swCNTL.loadEXTD <= '0';
    swCNTL.clear    <= '0';
    swCNTL.cont     <= '0';
    swCNTL.exam     <= '0';
    swCNTL.halt     <= '0';
    swCNTL.step     <= '0';
    swCNTL.dep      <= '0';

    --
    -- Front Panel Data Switches
    --

    swDATA          <= o"0023";

    --
    -- PDP8 Processor
    --
    
    iPDP8 : entity work.ePDP8 (rtl) port map (
        -- System
        clk      => clk,                        --! 50 MHz Clock
        rst      => rst,                        --! Reset Button
        -- CPU Configuration
        swCPU    => swPDP8A,                    --! CPU Configured to emulate PDP8A
        swOPT    => swOPT,                      --! Enable Options
        -- Real Time Clock Configuration
        swRTC    => clkDK8EC2,                  --! RTC 50 Hz interrupt
        -- TTY1 Interfaces
        tty1BR   => uartBR9600,                 --! TTY1 is 9600 Baud
        tty1HS   => uartHSnone,                 --! TTY1 has no flow control
        tty1CTS  => '1',                        --! TTY1 doesn't need CTS
        tty1RTS  => open,                       --! TTY1 doesn't need RTS
        tty1RXD  => tty1RXD,                    --! TTY1 RXD (to RS-232 interface)
        tty1TXD  => tty1TXD,                    --! TTY1 TXD (to RS-232 interface)
        -- TTY2 Interfaces
        tty2BR   => uartBR9600,                 --! TTY2 is 9600 Baud
        tty2HS   => uartHSnone,                 --! TTY2 has no flow control
        tty2CTS  => '1',                        --! TTY2 doesn't need CTS
        tty2RTS  => open,                       --! TTY2 doesn't need RTS
        tty2RXD  => '1',                        --! TTY2 RXD (tied off)
        tty2TXD  => open,                       --! TTY2 TXD (tied off)
        -- LPR Interface
        lprBR    => uartBR9600,                 --! LPR is 9600 Baud
        lprHS    => uartHSnone,                 --! LPR has no flow control
        lprDTR   => '1',                        --! LPR doesn't need DTR
        lprDSR   => open,                       --! LPR doesn't need DSR
        lprRXD   => '1',                        --! LPR RXD (tied off)
        lprTXD   => open,                       --! LPR TXD (tied off)
        -- Paper Tape Reader Interface
        ptrBR    => uartBR9600,                 --! PTR is 9600 Baud
        ptrHS    => uartHSnone,                 --! PTR has no flow control
        ptrCTS   => '1',                        --! PTR doesn't need CTS
        ptrRTS   => open,                       --! PTR doesn't need RTS
        ptrRXD   => '1',                        --! PTR RXD (tied off)
        ptrTXD   => open,                       --! PTR TXD (tied off)
        -- Secure Digital Disk Interface
        sdCD     => '0',                        --! SD Card Detect
        sdWP     => '0',                        --! SD Write Protect
        sdMISO   => sdMISO,                     --! SD Data In
        sdMOSI   => sdMOSI,                     --! SD Data Out
        sdSCLK   => sdSCLK,                     --! SD Clock
        sdCS     => sdCS,                       --! SD Chip Select
        -- Status
        rk8eSTAT => open,                       --! Disk Status (Ignore)
        -- Switches and LEDS
        swROT    => dispAC,                     --! Data LEDS display PC
        swDATA   => swDATA,                     --! RK8E Boot Loader Address
        swCNTL   => swCNTL,                     --! Switches
        ledRUN   => open,                       --! Run LED
        ledADDR  => open,                       --! Addressxs LEDS
        ledDATA  => open                        --! Data LEDS
    );
    
end rtl;
