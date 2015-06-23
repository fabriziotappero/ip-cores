------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: Test Bench
--!
--! \details
--!      Test Bench.
--!
--! \file
--!      nexys2_testbench.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2012 Rob Doyle
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


library ieee;                                                   --! IEEE Library
use ieee.std_logic_1164.all;                                    --! IEEE 1164
use ieee.std_logic_textio.all;                                  --! IEEE Std Logic TextIO
use std.textio.all;                                             --! TEXTIO
use work.uart_types.all;                                        --! UART Types
use work.dk8e_types.all;                                        --! DK8E Types
use work.kc8e_types.all;                                        --! KC8E Types
use work.cpu_types.all;                                         --! CPU Types
use work.nexys2_types.all;                                      --! Nexys2 Types

--
--! NEXYS2 Test Bench Entity
--

entity NEXYS2_TESTBENCH is
end NEXYS2_TESTBENCH;

--
--! NEXYS2 Test Bench Behav
--

architecture behav of NEXYS2_TESTBENCH is

    --
    -- PDP8 Pins
    --
    
    signal clk            : std_logic           := '0';
    signal rst            : std_logic           := '0';
    signal sw             : sw_t                := ('0', '0', '0', '0', '0', '0', '0', '0');
    signal led            : led_t;
    -- TTY1 Interfaces
    signal tty1RXD        : std_logic           := '1';
    signal tty1TXD        : std_logic           := '1';
    -- TTY2 Interfaces
    signal tty2RXD        : std_logic           := '1';
    signal tty2TXD        : std_logic           := '1';
    -- LPR Interfaces
    signal lprDTR         : std_logic           := '1';
    signal lprDSR         : std_logic           := '1';
    signal lprRXD         : std_logic           := '1';
    signal lprTXD         : std_logic           := '1';
    -- PTR Interfaces
    signal ptrRXD         : std_logic           := '1';
    signal ptrTXD         : std_logic           := '1';
    -- SD Interface
    signal sdCD           : std_logic           := '0';         --! SD Card Detect
    signal sdWP           : std_logic           := '0';         --! SD Write Protect
    signal sdMISO         : std_logic;                          --! SD Data In
    signal sdMOSI         : std_logic;                          --! SD Data Out
    signal sdSCLK         : std_logic;                          --! SD Clock
    signal sdCS           : std_logic;                          --! SD Chip Select
    -- IO Interface
    signal ioDATA         : iodata_t;
    signal inOEA_L        : std_logic;
    signal inOEB_L        : std_logic;
    signal outLEA         : std_logic;
    signal outLEB         : std_logic;
    --
    signal inDATAa        : iodata_t;
    signal inDATAb        : iodata_t;
    signal outDATA        : iodata_t;
    signal swCNTL         : swCNTL_t;
    signal swDATA         : data_t;
    signal ledRUN         : std_logic;
    signal ledADDR        : xaddr_t;
    signal ledDATA        : data_t;
    signal dispSeg_L      : dispSeg_t;
    signal dispDig_L      : dispDig_t;
    signal ttyBR          : uartBR_t;
    signal swCPU          : swCPU_t;
    signal swOPT          : swOPT_t;
    signal swROT          : swROT_t;
    signal swRTC          : swRTC_t;

    --
    -- UART
    --

    constant bitTIME      : time := 8680.5 ns;
    --constant bitTIME      : time := 1.0 / 115200.0;
    
begin
  
    UUT : entity work.eNEXYS2_PDP8 (rtl) port map (
        clk        => clk,
        rstIN      => rst,
        sw         => sw,
        led        => led,
        -- TTY1 Interfaces
        tty1RXD     => tty1RXD,
        tty1TXD     => tty1TXD,
        -- TTY2 Interfaces
        tty2RXD     => tty2RXD,
        tty2TXD     => tty2TXD,
        -- LPR Interfaces
        lprRXD      => lprRXD,
        lprTXD      => lprTXD,
        -- PTR Interfaces
        ptrRXD      => ptrRXD,
        ptrTXD      => ptrTXD,
        -- SD Interface
        sdCD       => sdCD,
        sdWP       => sdWP,
        sdMISO     => sdMISO,
        sdMOSI     => sdMOSI,
        sdSCLK     => sdSCLK,
        sdCS       => sdCS,
        -- IO Interface
        ioDATA     => ioDATA,
        inOEA_L    => inOEA_L,
        inOEB_L    => inOEB_L, 
        outLEA     => outLEA,
        outLEB     => outLEB,
        -- Seven Segment Display
        dispSeg_L  => dispSeg_L,
        dispDig_L  => dispDig_L
    );

    --
    -- SD Card Simulator
    --
    
    iSDSIM : entity work.eSDSIM (behav) port map (
        clk    => clk,
        rst    => rst,
        sdCD   => sdCD,
        sdWP   => sdWP,
        sdMISO => sdMISO,
        sdMOSI => sdMOSI,
        sdSCLK => sdSCLK,
        sdCS   => sdCS
    );

    --
    -- UART Simulator
    --
    
    eUARTSIM : entity work.eUARTSIM  (behav) port map (
        rst     => rst,
        bitTIME => bitTIME,
        TXD     => tty1RXD
    );
          
    --
    -- Reset Signal
    --
    
    rst <= '1', '0' after 80 ns;
    
    --
    --! Clock Generator
    --
    
    CLKGEN : process
    begin
        wait for 10 ns;
        clk <= not(clk);
    end process CLKGEN;
    
    --
    -- Switches
    --

    ttyBR            <= uartBR115200;
    swCPU            <= swPDP8A;
    swOPT.KE8        <= '1';
    swOPT.KM8E       <= '1';
    swOPT.TSD        <= '0';
    swOPT.SP0        <= '0';
    swOPT.SP1        <= '0';
    swOPT.SP2        <= '0';
    swOPT.SP3        <= '0';
    swOPT.STARTUP    <= '1';
    swROT            <= dispAC;
    swRTC            <= clkDK8EA1;
    
    swCNTL.boot      <= '0';   
    swCNTL.lock      <= '0';
    swCNTL.loadADDR  <= '0';
    swCNTL.loadEXTD  <= '0';
    swCNTL.clear     <= '0';
    swCNTL.cont      <= '0';   -- not(ledRUN) after 200 nS;
    swCNTL.exam      <= '0';
    swCNTL.halt      <= '0';
    swCNTL.step      <= '0';
    swDATA           <= o"0000";
    swCNTL.dep       <= '0';
    
         
    --
    -- Input Mux
    --

    inDATAa <= ttyBR(0)     & ttyBR(1)     & ttyBR(2)          & ttyBR(3)              & swCPU(0)              & swCPU(1)          &
               swCPU(2)     & swCPU(3)     & swOPT.KE8         & swOPT.KM8E            & swOPT.TSD             & swOPT.SP0         &
               swOPT.SP1    & swOPT.SP2    & swOPT.SP3         & swOPT.STARTUP         & swRTC(0)              & swRTC(1)          &
               swRTC(2)     & '0'          & '0'               & '0'                   & '0'                   & swCNTL.lock;

    inDATAb <= swROT(0)     & swROT(1)     & swROT(2)          & SWCNTL.dep            & swCNTL.step           & swCNTL.halt       &
               swCNTL.exam  & swCNTL.cont  & not(swCNTL.clear) & swDATA(11)            & swDATA(10)            & swDATA(9)         &
               swDATA(8)    & swDATA(7)    & swDATA(6)         & swDATA(5)             & swDATA(4)             & swDATA(3)         &
               swDATA(2)    & swDATA(1)    & swDATA(0)         & not(swCNTL.loadEXTD)  & not(swCNTL.loadADDR)  & not(swCNTL.boot);
    
    outDATA <= ioDATA;
    
    ioDATA  <= not(inDATAa) when inOEA_L = '0' else
               not(inDATAb) when inOEB_L = '0' else
               (others => 'Z');

    --
    --! Output IO Latches
    --

    IOSIM : process(clk, rst)
    begin
        if rst = '1' then
            ledRUN  <= '0';
            ledADDR <= (others => '0');
            ledDATA <= (others => '0');
        elsif rising_edge(clk) then
            if outLEA = '1' then
                ledDATA(11) <= outDATA( 0);
                ledDATA(10) <= outDATA( 1);
                ledDATA( 9) <= outDATA( 2);
                ledDATA( 8) <= outDATA( 3);
                ledDATA( 7) <= outDATA( 4);
                ledDATA( 6) <= outDATA( 5);
                ledDATA( 5) <= outDATA( 6);
                ledDATA( 4) <= outDATA( 7);
                ledDATA( 3) <= outDATA( 8);
                ledDATA( 2) <= outDATA( 9);
                ledDATA( 1) <= outDATA(10);
                ledDATA( 0) <= outDATA(11);
            elsif outLEB = '1' then
                ledRUN      <= outDATA( 0);
                ledADDR(14) <= outDATA( 1);
                ledADDR(13) <= outDATA( 2);
                ledADDR(12) <= outDATA( 3);
                ledADDR(11) <= outDATA( 4);
                ledADDR(10) <= outDATA( 5);
                ledADDR( 9) <= outDATA( 6);
                ledADDR( 8) <= outDATA( 7);
                ledADDR( 7) <= outDATA( 8);
                ledADDR( 6) <= outDATA( 9);
                ledADDR( 5) <= outDATA(10);
                ledADDR( 4) <= outDATA(11);
                ledADDR( 3) <= outDATA(12);
                ledADDR( 2) <= outDATA(13);
                ledADDR( 1) <= outDATA(14);
                ledADDR( 0) <= outDATA(15);
            end if;
            if outLEA = '1' and outLEB = '1' then
                assert false report "Both outLEA and outLEB asserted at the same time" severity failure;     
            end if;
            if inOEA_L = '0' and inOEB_L = '0' then
                assert false report "Both inOEA_L and inOEB_L asserted at the same time" severity failure;
            end if;
        end if;
    end process IOSIM;

end behav;
