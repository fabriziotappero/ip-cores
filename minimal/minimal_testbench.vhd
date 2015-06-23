------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      Minimal Test Bench
--!
--! \details
--!      Test Bench.
--!
--! \file
--!      minimal_testbench.vhd
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

--
--! MINIMAL Test Bench Entity
--

entity MINIMAL_TESTBENCH is
end MINIMAL_TESTBENCH;

--
--! MINIMAL Test Bench Behav
--

architecture behav of MINIMAL_TESTBENCH is

    --
    -- PDP8 Pins
    --
    
    signal clk            : std_logic           := '0';
    signal rst            : std_logic           := '0';
    -- TTY1 Interfaces
    signal tty1RXD        : std_logic           := '1';
    signal tty1TXD        : std_logic;
    -- SD Interface
    signal sdCD           : std_logic           := '0';         --! SD Card Detect
    signal sdWP           : std_logic           := '0';         --! SD Write Protect
    signal sdMISO         : std_logic;                          --! SD Data In
    signal sdMOSI         : std_logic;                          --! SD Data Out
    signal sdSCLK         : std_logic;                          --! SD Clock
    signal sdCS           : std_logic;                          --! SD Chip Select

    --
    -- UART
    --

    constant bitTIME      : time := 8680.5 ns;
    
begin

    eMINIMAL_PDP8 : entity work.eMINIMAL_PDP8 (rtl) port map (
        -- System
        clk     => clk,
        rst     => rst,
        -- TTY1 Interfaces
        tty1RXD => tty1RXD,
        tty1TXD => tty1TXD,
        -- SD Interface
        sdMISO  => sdMISO,
        sdMOSI  => sdMOSI,
        sdSCLK  => sdSCLK,
        sdCS    => sdCS
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
    
end behav;
