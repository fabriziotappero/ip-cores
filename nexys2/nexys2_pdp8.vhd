--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: PDP8 Processor
--!
--! \details
--!      This 'layer' of code wraps the basic PDP8 implementation
--!      with a set of IO that is provided by the Digilent
--!      NexysII evaluation board.
--!
--!      Other implementations may wrapper the PDP8 with alternate
--!      IO implementations.
--!
--! \file
--!      nexys2_pdp8.vhd
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
use work.sd_types.all;                          --! SD Types
use work.uart_types.all;                        --! UART Types
use work.kc8e_types.all;                        --! KC8E Types
use work.kl8e_types.all;                        --! KL8E Types
use work.dk8e_types.all;                        --! DK8E Types
use work.rk8e_types.all;                        --! RK8E Types
use work.cpu_types.all;                         --! CPU Types
use work.nexys2_types.all;                      --! Nexys2 Types

--
--! NEXYS2 PDP8 Entity
--

entity eNEXYS2_PDP8 is port (
    clk       : in    std_logic;                --! Clock
    rstIN     : in    std_logic;                --! Reset Input
    sw        : in    sw_t;                     --! Switches
    led       : out   led_t;                    --! LEDs
    -- TTY1 Interfaces
    tty1RXD   : in  std_logic;                  --! TTY1 Receive Data
    tty1TXD   : out std_logic;                  --! TTY1 Transmit Data
    -- TTY2 Interfaces
    tty2RXD   : in  std_logic;                  --! TTY2 Receive Data
    tty2TXD   : out std_logic;                  --! TTY2 Transmit Data
    -- LPR Interface
    lprRXD    : in  std_logic;                  --! LPR Receive Data
    lprTXD    : out std_logic;                  --! LPR Transmit Data
    -- PTR Interface
    ptrRXD    : in  std_logic;                  --! PTR Receive Data
    ptrTXD    : out std_logic;                  --! PTR Transmit Data
    -- SD Interface
    sdCD      : in    std_logic;                --! SD Card Detect
    sdWP      : in    std_logic;                --! SD Write Protect
    sdMISO    : in    std_logic;                --! SD Data In
    sdMOSI    : out   std_logic;                --! SD Data Out
    sdSCLK    : out   std_logic;                --! SD Clock
    sdCS      : out   std_logic;                --! SD Chip Select
    -- IO Interface
    ioDATA    : inout iodata_t;                 --! IO Data
    inOEA_L   : out   std_logic;                --! Input A Output Enable
    inOEB_L   : out   std_logic;                --! Input B Output Enable
    outLEA    : out   std_logic;                --! Output A Latch Enable
    outLEB    : out   std_logic;                --! Output B Latch Enable
    -- Seven Segment Display
    dispSeg_L : out   dispSeg_t;                --! Display Segments
    dispDig_L : out   dispDig_t                 --! Display Digits
);
end eNEXYS2_PDP8;

--
--! NEXYS2 PDP8 RTL
--

architecture rtl of eNEXYS2_PDP8 is

    signal   swCPU    : swCPU_t;                  --! CPU Configuration Switches
    signal   swOPT    : swOPT_t;                  --! Option Switches
    signal   swRTC    : swRTC_t;                  --! RTC Configuration Switches
    signal   swROT    : swROT_t;                  --! Rotary Switch
    signal   swDATA   : data_t;                   --! Data Switches
    signal   swCNTL   : swCNTL_t;                 --! Control Switches
    signal   ledRUN   : std_logic;                --! Run LED
    signal   ledDATA  : data_t;                   --! Data LEDs
    signal   ledADDR  : xaddr_t;                  --! Addr LEDs
    signal   rst      : std_logic;                --! Delayed Reset
    signal   rk8eSTAT : rk8eSTAT_t;               --! RK8E Status

    --
    -- TTY Configuration
    --
    
    signal   ttyBR    : uartBR_t;                 --! Baud Rate Switches
    constant ttyHS    : uartHS_t   := uartHSnone; --! TTY set to no handshaking
    constant tty1CTS  : std_logic  := '1';        --! TTY1 Clear To Send
    signal   tty1RTS  : std_logic;                --! TTY1 Request To Send
    constant tty2CTS  : std_logic  := '1';        --! TTY2 Clear To Send
    signal   tty2RTS  : std_logic;                --! TTY2 Request To Send
    
    --
    -- LPR Configuration
    --
    
    constant lprBR    : uartBR_t   := uartBR9600; --! LPR set to 9600 Baud
    constant lprHS    : uartHS_t   := uartHSsw;   --! LPR set to SW handshaking
    constant lprDTR   : std_logic  := '1';        --! LPR Data Terminal Ready
    signal   lprDSR   : std_logic;                --! LPR Data Set Ready

    --
    -- PTR Configuration
    --

    constant ptrBR    : uartBR_t   := uartBR9600; --! PTR set to 9600 Baud
    constant ptrHS    : uartHS_t   := uartHSsw;   --! PTR set to SW handshaking
    constant ptrCTS   : std_logic  := '1';        --! PTR Clear To Send
    signal   ptrRTS   : std_logic;                --! PTR Request To Send

    --
    -- Disk Status
    --

    signal diskINFAIL : std_logic;                -- ! Disk is OK
    signal diskRWFAIL : std_logic;                -- ! Disk is OK
    signal diskSTAT   : std_logic_vector(0 to 7); --! Disk Status LEDS
    
begin

    --
    -- Disk Status
    --

    diskINFAIL <= '1' when (rk8eSTAT.sdSTAT.state = sdstateINFAIL) else '0';
    diskRWFAIL <= '1' when (rk8eSTAT.sdSTAT.state = sdstateRWFAIL) else '0';
    
    diskSTAT   <= rk8eSTAT.sdCD               &
                  rk8eSTAT.sdWP               &
                  diskINFAIL                  &
                  diskRWFAIL                  &
                  rk8eSTAT.rk05STAT(0).active &
                  rk8eSTAT.rk05STAT(1).active &
                  rk8eSTAT.rk05STAT(2).active &
                  rk8eSTAT.rk05STAT(3).active;

    --
    --! Nexys2 IO Interfaces
    --! This device holds the PDP8 reset while it reads the configuration data
    --

    iNEXYS2_IO : entity work.eNEXYS2_IO (rtl) port map (
        clk     => clk,
        rstIN   => rstIN,
        ttyBR   => ttyBR,
        swCPU   => swCPU,
        swOPT   => swOPT,
        swROT   => swROT,
        swRTC   => swRTC,
        swDATA  => swDATA,
        swCNTL  => swCNTL,
        ledRUN  => ledRUN,
        ledADDR => ledADDR,
        ledDATA => ledDATA,
        ioDATA  => ioDATA,
        inOEA_L => inOEA_L,
        inOEB_L => inOEB_L,
        outLEA  => outLEA,
        outLEB  => outLEB,
        rst     => rst
    );

    --
    --! Nexys2 Seven Segment Display.
    --! The Seven Segment Display is 'slaved' to the DATA LEDS.
    --

    iNEXYS2_DISP : entity work.eNEXYS2_DISP (rtl)  port map (
        clk       => clk,
        rst       => rst,
        dispData  => to_octal(ledDATA),
        dispSeg_L => dispSeg_L,
        dispDig_L => dispDig_L
    );

    --
    --! The PDP8 processor and peripherals
    --

    iPDP8 : entity work.ePDP8 (rtl) port map (
        -- System
        clk      => clk,
        rst      => rst,
        -- Configuration
        swCPU    => swCPU,
        swOPT    => swOPT,
        -- Real Time Clock
        swRTC    => swRTC,
        -- TTY1 Interface
        tty1BR   => ttyBR,
        tty1HS   => ttyHS,
        tty1CTS  => tty1CTS,
        tty1RTS  => tty1RTS,
        tty1RXD  => tty1RXD,
        tty1TXD  => tty1TXD,
        -- TTY2 Interface
        tty2BR   => ttyBR,
        tty2HS   => ttyHS,
        tty2CTS  => tty2CTS,
        tty2RTS  => tty2RTS,
        tty2RXD  => tty2RXD,
        tty2TXD  => tty2TXD,
        -- LPR Interface
        lprBR    => lprBR,
        lprHS    => lprHS,
        lprDTR   => lprDTR,
        lprDSR   => lprDSR,
        lprRXD   => lprRXD,
        lprTXD   => lprTXD,
        -- PTR Interface
        ptrBR    => ptrBR,
        ptrHS    => ptrHS,
        ptrCTS   => ptrCTS,
        ptrRTS   => ptrRTS,
        ptrRXD   => ptrRXD,
        ptrTXD   => ptrTXD,
        -- SD Interface
        sdCD     => sdCD,
        sdWP     => sdWP,
        sdMISO   => sdMISO,
        sdMOSI   => sdMOSI,
        sdSCLK   => sdSCLK,
        sdCS     => sdCS,
        -- RK8E Status 
        rk8eSTAT => rk8eSTAT,
        -- Switches and LEDS
        swROT    => swROT,
        swDATA   => swDATA,
        swCNTL   => swCNTL,
        ledRUN   => ledRUN,
        ledADDR  => ledADDR,
        ledDATA  => ledDATA
    );

    --
    -- Status MUX for LEDs
    --
    
    with sw(5 to 7) select
         led <= diskSTAT              when "000",
                rk8eSTAT.sdSTAT.debug when "001",
                rk8eSTAT.sdSTAT.err   when "010",
                rk8eSTAT.sdSTAT.val   when "011",
                rk8eSTAT.sdSTAT.rdCNT when "100",
                rk8eSTAT.sdSTAT.wrCNT when "101",
                diskSTAT              when others;
        
end rtl;
