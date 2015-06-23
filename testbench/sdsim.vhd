------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      SD Sim Testbench
--!
--! \details
--!      Test Bench.
--!
--! \file
--!      sdsim.vhd
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


library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use ieee.numeric_std.all;                       --! IEEE Numeric Standard
use ieee.std_logic_textio.all;                  --! IEEE Std Logic TextIO
use std.textio.all;                             --! TEXTIO

--
--! SDSIM Test Entity
--

entity eSDSIM is port (
    -- System
    clk        : in  std_logic;                 --! Clock
    rst        : in  std_logic;                 --! Reset
    -- SD Interface
    sdCD       : out std_logic;                 --! SD Card Detect
    sdWP       : out std_logic;                 --! SD Write Protect
    sdMISO     : out std_logic;                 --! SD Data In
    sdMOSI     : in  std_logic;                 --! SD Data Out
    sdSCLK     : in  std_logic;                 --! SD Clock
    sdCS       : in  std_logic                  --! SD Chip Select
);
end eSDSIM;

--
--! SDSIM Test Bench Behav
--

architecture behav of eSDSIM is

    --
    -- SPI Simulation
    --

    subtype sdCMD_t       is std_logic_vector(0 to 55);
    signal  spiRX         : sdCMD_t;
    signal  spiTX         : sdCMD_t;
    type    state_t       is (stateRESET, stateRSP,
                              stateREAD0, stateREAD1, stateREAD2,
                              stateWRITE0, stateWRITE1, stateWRITE2, stateWRITE3, stateWRITE4);
    signal  state         : state_t;
    signal  bitcnt        : integer range 0 to 55;
    signal  bytecnt       : integer range 0 to 511;
    signal  index         : integer range 0 to 4194303;

    --
    -- Disk Registers
    --

    subtype byte_t        is std_logic_vector(0 to 7);
    type    image_t       is array(0 to 3325951) of byte_t;
    file    OUTFILE       : text is out "STD_OUTPUT";
    type    imageFILE_t   is file of character;
    file    imageFILE     : imageFILE_t;
    shared variable image : image_t;
    shared variable size  : integer := 0;


begin

    sdCD <= '0';
    sdWP <= '0';
     
    --
    --! SD Interface
    --

    SDSIM : process(clk, rst)
        variable clkstat : std_logic_vector(0 to 1);
    begin
        if rst = '1' then
            spiRX  <= (others => '1');
            spiTX  <= (others => '1');
            state  <= stateRESET;
            index  <= 0;
        elsif rising_edge(clk) then
            clkstat(0 to 1) := clkstat(1) & sdSCLK;

            if sdCS = '1' then
                spiRX <= (others => '1');
            elsif clkstat = "01" then
                spiRX <= spiRX(1 to 55) & sdMOSI;
            end if;
            
            case state is
                when stateRESET =>

                    --
                    -- CMD0:
                    --
                    
                    if spiRX(0 to 7) = x"40" then
                        if clkstat = "10" then
                            bitcnt <= 15;
                            spiTX  <= x"ff_01_ff_ff_ff_ff_ff";
                            state  <= stateRSP;
                        end if;

                    --
                    -- CMD8:
                    --
                        
                    elsif spiRX(0 to 7) = x"48" then
                        if clkstat = "10" then
                            bitcnt <= 55;
                            spiTX  <= x"ff_01_00_00_01_aa_ff";
                            state  <= stateRSP;
                        end if;
                        
                    --
                    -- CMD13:
                    --  Send Status
                    --
                        
                    elsif spiRX(0 to 7) = x"4d" then
                        if clkstat = "10" then
                            bitcnt <= 39;
                            spiTX  <= x"ff_ff_00_00_ff_ff_ff";
                            state  <= stateRSP;
                        end if;
                         
                        
                    --
                    -- CMD17:
                    --  Read Single
                    --
                        
                    elsif spiRX(0 to 7) = x"51" then
                        if clkstat = "10" then
                            bitcnt <= 47;
                            spiTX  <= x"ff_ff_00_ff_ff_fe_ff";
                            index  <= to_integer(unsigned(spiRX(27 to 39))) * 512;
                            state  <= stateREAD0;
                        end if;

                    --
                    -- CMD24:
                    --  Write Single
                    --
                        
                    elsif spiRX(0 to 7) = x"58" then
                        if clkstat = "10" then
                            bitcnt <= 47;
                            spiTX  <= x"ff_ff_00_ff_ff_fe_ff";
                            index  <= to_integer(unsigned(spiRX(27 to 39))) * 512;
                            state  <= stateWRITE0;
                        end if;
                        
                    --
                    -- ACMD41:
                    --
                        
                    elsif spiRX(0 to 7) = x"69" then
                        if clkstat = "10" then
                            bitcnt <= 23;
                            spiTX  <= x"ff_00_ff_ff_ff_ff_ff";
                            state  <= stateRSP;
                        end if;

                    --
                    -- CMD55:
                    --
                        
                    elsif spiRX(8 to 15) = x"77" then
                        if clkstat = "10" then
                            bitcnt <= 15;
                            spiTX  <= x"ff_01_ff_ff_ff_ff_ff";
                            state  <= stateRSP;
                        end if;

                    --
                    -- CMD58:
                    --
                        
                    elsif spiRX(0 to 7) = x"7a" then
                        if clkstat = "10" then
                            bitcnt <= 55;
                            spiTX  <= x"ff_00_e0_ff_80_00_ff";
                            state  <= stateRSP;
                        end if;
                    end if;

                --
                -- Send Response:
                --
                    
                when stateRSP =>
                    if bitcnt = 0 then
                        state <= stateRESET;
                    else
                        if clkstat = "10" then
                            bitcnt <= bitcnt - 1;
                            spiTX  <= spiTX(1 to 55) & '1';
                        end if;
                    end if;

                --
                -- stateREAD0:
                --
                    
                when stateREAD0 =>
                    if clkstat = "10" then
                        if bitcnt = 0 then
                            bitcnt  <= 7;
                            bytecnt <= 0;
                            spiTX   <= image(index) & x"00_00_00_00_00_00";
                            index   <= index + 1;
                            state   <= stateREAD1;
                        else
                            bitcnt  <= bitcnt - 1;
                            spiTX   <= spiTX(1 to 55) & '1';
                        end if;
                    end if;

                --
                -- stateREAD1
                --

                when stateREAD1 =>
                    if clkstat = "10" then
                        if sdCS = '1' then
                            spiTX <= x"ff_ff_ff_ff_ff_ff_ff";
                            state <= stateRESET;
                        elsif bitcnt = 0 then
                            if bytecnt = 511 then
                                bitcnt  <= 15;
                                spiTX   <= x"ff_ff_ff_ff_ff_ff_ff";
                                state   <= stateREAD2;
                            else
                                bitcnt  <= 7;
                                spiTX   <= image(index) & x"00_00_00_00_00_00";
                                index   <= index + 1;
                                bytecnt <= bytecnt + 1;
                            end if;
                        else
                            bitcnt <= bitcnt - 1;
                            spiTX  <= spiTX(1 to 55) & '1';
                        end if;
                    end if;
                    
                --
                -- stateREAD2:
                --  Send 2 CRC bytes
                --
                    
                when stateREAD2 => 
                    if clkstat = "10" then
                        if bitcnt = 0 then
                            state <= stateRESET;
                        else
                            bitcnt <= bitcnt - 1;
                            spiTX  <= spiTX(1 to 55) & '1';
                        end if;
                    end if;

                --
                -- stateWRITE0:
                --
                    
                when stateWRITE0 => 
                    if clkstat = "10" then
                        if bitcnt = 0 then
                            bitcnt  <= 7;
                            bytecnt <= 0;
                            image(index) := spiRX(48 to 55);
                            spiTX   <= x"ff_ff_ff_ff_ff_ff_ff";
                            index   <= index + 1;
                            state   <= stateWRITE1;
                        else
                            bitcnt  <= bitcnt - 1;
                            spiTX   <= spiTX(1 to 55) & '1';
                        end if;
                    end if;

                --
                -- stateWRITE1
                --

                when stateWRITE1 =>
                    if clkstat = "10" then
                        if sdCS = '1' then
                            spiTX <= x"ff_ff_ff_ff_ff_ff_ff";
                            state <= stateRESET;
                        elsif bitcnt = 0 then
                            if bytecnt = 511 then
                                bitcnt <= 55;
                                spiTX  <= x"ff_05_00_00_00_00_ff";
                                state  <= stateWRITE2;
                            else
                                bitcnt  <= 7;
                                image(index) := spiRX(48 to 55);
                                spiTX   <= x"ff_ff_ff_ff_ff_ff_ff";
                                index   <= index + 1;
                                bytecnt <= bytecnt + 1;
                            end if;
                        else
                            bitcnt <= bitcnt - 1;
                            spiTX  <= spiTX(1 to 55) & '1';
                        end if;
                    end if;
   
                --
                -- stateWRITE2:
                --  Write 2 CRC bytes plus some busy (zero) tokens
                --
                    
                when stateWRITE2 => 
                    if clkstat = "10" then
                        if bitcnt = 0 or sdCS = '1' then
                            --bitcnt  <= 15;
                            --bytecnt <= 0;
                            --spiTX   <= x"00_ff_ff_ff_ff_ff_ff";
                            state   <= stateRESET;
                        else
                            bitcnt <= bitcnt - 1;
                            spiTX  <= spiTX(1 to 55) & '1';
                        end if;
                    end if;
                    
                when others =>
                    null;
            end case;
                
        end if;
    end process SDSIM;
    sdMISO <= spiTX(0);

    --
    --! This process reads the disk file
    --
    
    DISKSIM : process
        variable c    : character;
        variable lin  : line;
    begin
        write(lin, string'("Reading Disk Image..."));
        writeline(OUTFILE, lin);
        --file_open(imageFILE, "multos8.rk05", read_mode);
        --file_open(imageFILE, "diag-games-kermit.rk05", read_mode);
        file_open(imageFILE, "advent.rk05", read_mode);
        while not endfile(imageFILE) loop
            read(imageFILE, c);
            image(size) := std_logic_vector(to_unsigned(character'pos(c), 8));
            size := size + 1;
        end loop;
        write(lin, string'("Done Reading Disk Image."));
        writeline(OUTFILE, lin);
        write(lin, string'("Read "));
        write(lin, size);
        write(lin, string'(" bytes"));
        writeline(OUTFILE, lin);
        wait;
    end process DISKSIM;
    
end behav;
