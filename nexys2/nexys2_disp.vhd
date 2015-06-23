--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: Seven Segment Display
--!
--! \details
--!      This package displays 12-bit data in octal on the Nexys2
--!      Seven Segment display.
--!
--!      The data to be displayed is selected by the rotary switch
--!      (swROT) in another package.
--!
--! \file
--!      nexys2_disp.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2011, 2012 Rob Doyle
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

library ieee;                                           --! IEEE Library
use ieee.std_logic_1164.all;                            --! IEEE 1164
use ieee.numeric_std.all;                               --! IEEE Std Logic Unsigned
use work.nexys2_types.all;                              --! Nexys2 Board types

--
--! NEXYS2 Seven Segment Display Entity
--

entity eNEXYS2_DISP is port (
    clk       : in  std_logic;                          --! Clock
    rst       : in  std_logic;                          --! Reset
    dispData  : in  dispDat_t;                          --! Data to be displayed
    dispSeg_L : out dispSeg_t;                          --! Segment Drivers
    dispDig_L : out dispDig_t                           --! Digit Drivers
);
end eNEXYS2_DISP;

--
--! NEXYS2 Seven Segment Display RTL
--

architecture rtl of eNEXYS2_DISP is
    
    subtype  dispVal_t is std_logic_vector(0 to  3);    --! Hex/Octal Data

    signal   currDig  : dispDig_t;                      --! Current Display Digit
    signal   nextDig  : dispDig_t;                      --! Next Display Digit
    signal   dispSeg  : dispSeg_t;                      --! Display Segment
    signal   dispVal  : dispVal_t;                      --! Display Data
   
    --!
    --! Four Digit Display Definition
    --!

    constant dispDig0 : dispDig_t := "1000";            --! Digit 0
    constant dispDig1 : dispDig_t := "0100";            --! Digit 1
    constant dispDig2 : dispDig_t := "0010";            --! Digit 2
    constant dispDig3 : dispDig_t := "0001";            --! Digit 3

    --!
    --! Seven Segment Display Definition
    --!

    constant dispSeg0 : dispSeg_t := "11111100";        --! Digit 0
    constant dispSeg1 : dispSeg_t := "01100000";        --! Digit 1
    constant dispSeg2 : dispSeg_t := "11011010";        --! Digit 2
    constant dispSeg3 : dispSeg_t := "11110010";        --! Digit 3
    constant dispSeg4 : dispSeg_t := "01100110";        --! Digit 4
    constant dispSeg5 : dispSeg_t := "10110110";        --! Digit 5
    constant dispSeg6 : dispSeg_t := "10111110";        --! Digit 6
    constant dispSeg7 : dispSeg_t := "11100000";        --! Digit 7
    constant dispSeg8 : dispSeg_t := "11111110";        --! Digit 8
    constant dispSeg9 : dispSeg_t := "11110110";        --! Digit 9
    constant dispSegA : dispSeg_t := "11101110";        --! Digit A
    constant dispSegB : dispSeg_t := "00111110";        --! Digit B
    constant dispSegC : dispSeg_t := "10011100";        --! Digit C
    constant dispSegD : dispSeg_t := "01111010";        --! Digit D
    constant dispSegE : dispSeg_t := "10011110";        --! Digit E
    constant dispSegF : dispSeg_t := "10001110";        --! Digit F
    constant dispSegN : dispSeg_t := "00000000";        --! Digit ?
     
begin

    --
    --! State Machine that walks though the four digits
    --
    
    DISP_MACHINE : process(clk, rst)
        subtype  div_t  is integer range 0 to 8191;
        variable clkDiv : div_t;
    begin
        if rst = '1' then
            clkDiv  := 0;
            currDig <= dispDig0;
        elsif rising_edge(clk) then
            if clkDiv = 8191 then
                clkDiv  := 0;
                currDig <= nextDig;
            else
                clkDiv  := clkDiv + 1;
            end if;
        end if;
    end process DISP_MACHINE;

    --
    -- Next State
    --

    with currDig select
        nextDig <= dispDig1 when dispDig0,
                   dispDig2 when dispDig1,
                   dispDig3 when dispDig2,
                   dispDig0 when dispDig3,
                   dispDig0 when others;
    
    --
    -- Select Digit Data
    -- 
    
    with currDig select
        dispVal <= dispData( 0 to  3) when dispDig0,
                   dispData( 4 to  7) when dispDig1,
                   dispData( 8 to 11) when dispDig2,
                   dispData(12 to 15) when dispDig3,
                   "1111" when others;

    --
    -- Seven Segment Decoder
    --
    
    with dispVal select
        dispSeg <= dispSeg0 when "0000",        --! 0
                   dispSeg1 when "0001",        --! 1
                   dispSeg2 when "0010",        --! 2
                   dispSeg3 when "0011",        --! 3
                   dispSeg4 when "0100",        --! 4
                   dispSeg5 when "0101",        --! 5
                   dispSeg6 when "0110",        --! 6
                   dispSeg7 when "0111",        --! 7
                   dispSeg8 when "1000",        --! 8
                   dispSeg9 when "1001",        --! 9
                   dispSegA when "1010",        --! A
                   dispSegB when "1011",        --! B
                   dispSegC when "1100",        --! C
                   dispSegD when "1101",        --! D
                   dispSegE when "1110",        --! E
                   dispSegF when "1111",        --! F
                   dispSegN when others;

    --
    -- The hardware is all negative logic
    --
    
    dispDig_L <= not(currDig);
    dispSeg_L <= not(dispSeg);
    
end rtl;
