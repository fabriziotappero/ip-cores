--!
--! PDP-8 Processor
--!
--! \brief
--!      PDP-8 System
--!
--! \details
--!      
--!
--! \file
--!      pdp8.vhd
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
--! PDP8 System Entity
--

entity ePDP8 is port (
    -- System
    clk        : in  std_logic;                 --! Clock
    rst        : in  std_logic;                 --! Reset
    -- Configuration
    swCPU      : in  swCPU_t;                   --! CPU Configuration
    swOPT      : in  swOPT_t;                   --! Configuration Options
    -- Real Time Clock
    swRTC      : in  swRTC_t;                   --! RTC Configuration
    -- TTY1 Interfaces
    tty1BR     : in  uartBR_t;                  --! TTY1 Baud Rate
    tty1HS     : in  uartHS_t;                  --! TTY1 Handshaking
    tty1CTS    : in  std_logic;                 --! TTY1 Clear To Send
    tty1RTS    : out std_logic;                 --! TTY1 Request To Send
    tty1RXD    : in  std_logic;                 --! TTY1 Receive Data
    tty1TXD    : out std_logic;                 --! TTY1 Transmit Data
    -- TTY2 Interfaces
    tty2BR     : in  uartBR_t;                  --! TTY2 Baud Rate
    tty2HS     : in  uartHS_t;                  --! TTY2 Handshaking
    tty2CTS    : in  std_logic;                 --! TTY2 Clear To Send
    tty2RTS    : out std_logic;                 --! TTY2 Request To Send
    tty2RXD    : in  std_logic;                 --! TTY2 Receive Data
    tty2TXD    : out std_logic;                 --! TTY2 Transmit Data
    -- LPR Interface
    lprBR      : in  uartBR_t;                  --! LPR Baud Rate
    lprHS      : in  uartHS_t;                  --! LPR Handshaking
    lprDTR     : in  std_logic;                 --! LPR Clear To Send
    lprDSR     : out std_logic;                 --! LPR Request To Send
    lprRXD     : in  std_logic;                 --! LPR Receive Data
    lprTXD     : out std_logic;                 --! LPR Transmit Data
    -- PTR Interface
    ptrBR      : in  uartBR_t;                  --! PTR Baud Rate
    ptrHS      : in  uartHS_t;                  --! PTR Handshaking
    ptrCTS     : in  std_logic;                 --! PTR Clear To Send
    ptrRTS     : out std_logic;                 --! PTR Request To Send
    ptrRXD     : in  std_logic;                 --! PTR Receive Data
    ptrTXD     : out std_logic;                 --! PTR Transmit Data
    -- SD Interface
    sdCD       : in  std_logic;                 --! SD Card Detect
    sdWP       : in  std_logic;                 --! SD Write Protect
    sdMISO     : in  std_logic;                 --! SD Data In
    sdMOSI     : out std_logic;                 --! SD Data Out
    sdSCLK     : out std_logic;                 --! SD Clock
    sdCS       : out std_logic;                 --! SD Chip Select
    -- RK8E Status 
    rk8eSTAT   : out rk8eSTAT_t;                --! RK8E Status
    -- Switches and LEDS
    swROT      : in  swROT_t;                   --! Rotary Switch
    swDATA     : in  swDATA_t;                  --! Data Switches
    swCNTL     : in  swCNTL_t;                  --! Control Switches
    ledRUN     : out std_logic;                 --! RUN LED
    ledADDR    : out xaddr_t;                   --! Addr LEDS
    ledDATA    : out data_t                     --! Data LEDS
);
end ePDP8;

--
--! PDP8 System RTL
--

architecture rtl of ePDP8 is
  
    signal  disk     : sys_t;                   --! Clock/Reset
    signal  sys      : sys_t;                   --! Clock/Reset
    signal  cpu      : cpu_t;                   --! CPU info
    signal  rk8eINIT : std_logic;               --! RK8E is initializing
    
    --
    -- Devices
    --

    signal  cpuDEV   : dev_t;                   --! PDP8 Output Device
    signal  tty1DEV  : dev_t;                   --! TTY1 DEV
    signal  tty2DEV  : dev_t;                   --! TTY2 DEV
    signal  lprDEV   : dev_t;                   --! LPR DEV
    signal  ptrDEV   : dev_t;                   --! PTR DEV
    signal  panelDEV : dev_t;                   --! PANEL DEV
    signal  diskDEV  : dev_t;                   --! Disk DEV
    signal  ramDEV   : dev_t;                   --! RAM DEV
    signal  mmapDEV  : dev_t;                   --! MMAP DEV
    signal  postDEV  : dev_t;                   --! POST DEV
    signal  romDEV   : dev_t;                   --! ROM DEV
    signal  rtcDEV   : dev_t;                   --! RTC DEV
    signal  xramDEV  : dev_t;                   --! XRAM DEV

begin

    --
    -- Hold CPU in reset while reset asserted and while RK8E is initializing
    --

    sys.rst  <= rst or rk8eINIT;
    sys.clk  <= clk;

    --
    -- Fixup Clocks and Resets
    --

    disk.rst <= rst;
    disk.clk <= clk;

    --
    --! BUSMON (Bus Monitor)
    --
    
    -- synthesis translate_off
    iBUSMON : entity work.eBUSMON (rtl) port map (
        sys       => sys,
        cpu       => cpu
    );
    -- synthesis translate_on

    --
    -- Currently Unused
    --
    
    mmapDEV <= nullDEV;
    postDEV <= nullDEV;
    romDEV  <= nullDEV;
    xramDEV <= nullDEV;
    lprDEV  <= nullDEV;
    ptrDEV  <= nullDEV;
    
    --
    --! Virtual BUS Mux
    --

    iBUSMUX : entity work.eBUSMUX (rtl) port map (
        sys       => sys,
        cpu       => cpu,
        ramDEV    => ramDEV,
        diskDEV   => diskDEV,
        tty1DEV   => tty1DEV,
        tty2DEV   => tty2DEV,
        lprDEV    => lprDEV,
        ptrDEV    => ptrDEV,
        rtcDEV    => rtcDEV,
        xramDEV   => xramDEV,
        romDEV    => romDEV,
        panelDEV  => panelDEV,
        postDEV   => postDEV,
        mmapDEV   => mmapDEV,
        cpuDEV    => cpuDEV
    );

    --
    --! KL8E: TTY1 Interface
    --

    iTTY1 : entity work.eKL8E (rtl) port map (
        sys       => sys,
        uartBR    => tty1BR,
        uartHS    => tty1HS,
        devNUM    => tty1devNUM,
        cpu       => cpu,
        dev       => tty1DEV,
        cts       => tty1CTS,
        rts       => tty1RTS,
        rxd       => tty1RXD,
        txd       => tty1TXD
    );

    --
    --! KL8E: TTY2 Interface
    --

    iTTY2 : entity work.eKL8E (rtl) port map (
        sys       => sys,
        uartBR    => tty2BR,
        uartHS    => tty2HS,
        devNUM    => tty2devNUM,
        cpu       => cpu,
        dev       => tty2DEV,
        cts       => tty2CTS,
        rts       => tty2RTS,
        rxd       => tty2RXD,
        txd       => tty2TXD
    );

    --
    --! LS8E: LPR Printer Interface
    --

--    iLPR : entity work.eLS8E (rtl) port map (
--        sys       => sys,
--        uartBR    => lprBR,
--        uartHS    => lprHS,
--        devNUM    => lprdevNUM,
--        cpu       => cpu,
--        dev       => lprDEV,
--        dtr       => lprDTR,
--        dsr       => lprDSR,
--        rxd       => lprRXD,
--        txd       => lprTXD
--    );
    
    --
    --! PR8E: PTR Paper Tape Reader Interface
    --

--    iPR8E : entity work.ePR8E (rtl) port map (
--        sys       => sys,
--        uartBR    => ptrBR,
--        uartHS    => ptrHS,
--        ptrdevNUM => ptrdevNUM,
--        ptpdevNUM => ptpdevNUM,
--        cpu       => cpu,
--        dev       => ptrDEV,
--        cts       => ptrCTS,
--        rts       => ptrRTS,
--        rxd       => ptrRXD,
--        txd       => ptrTXD
--    );

    --
    --! DK8E: Real Time Clock
    --
    
    iRTC : entity work.eDK8E (rtl) port map (
        sys       => sys,
        swRTC     => swRTC,
        devNUM    => rtcdevNUM,
        cpu       => cpu,
        dev       => rtcDEV,
        schmittIN => ('0', '0', '0'),
        clkTRIG   => open
    );
    
    --
    --! KC8E: Front Panel
    --

    iPANEL : entity work.eKC8E (rtl) port map (
        sys       => sys,
        cpu       => cpu,
        swROT     => swROT,
        swDATA    => swDATA,
        ledRUN    => ledRUN,
        ledADDR   => ledADDR,
        ledDATA   => ledDATA,
        dev       => panelDev
    );

    --
    --! CPU
    --

    iCPU : entity work.eCPU (rtl) port map (
        sys       => sys,
        swCPU     => swCPU,
        swOPT     => swOPT,
        swCNTL    => swCNTL,
        swDATA    => swDATA,
        dev       => cpuDEV,
        cpu       => cpu
    );

    --
    --! Main Memory : 32K x 12 RAM
    -- 
    
    iRAM : entity work.eMS8C (rtl) port map (
        sys       => sys,
        cpu       => cpu,
        dev       => ramDEV
    );

    --
    --! RK8E: Disk Interface
    --
    
    iDISK : entity work.eRK8E (rtl) port map (
        sys      => disk,
        rk05INH  => ('0', '0', '0', '0'),  -- Write Inhibit
        rk05MNT  => ('1', '1', '1', '1'),  -- Device Mounted
        devNUM   => rk8edevNUM,
        cpu      => cpu,
        dev      => diskDEV,
        sdCD     => sdCD,
        sdWP     => sdWP,
        sdMISO   => sdMISO,
        sdMOSI   => sdMOSI,
        sdSCLK   => sdSCLK,
        sdCS     => sdCS,
        rk8eINIT => rk8eINIT,
        rk8eSTAT => rk8eSTAT
    );

end rtl;
