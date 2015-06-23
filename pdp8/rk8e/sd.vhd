--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Secure Digital Interface
--!
--! \details
--!      The SD Interface reads or writes a 256 word (512 byte)
--!      sector to the SD device.  This interfaces uses a
--!      SPI interface (implemented independantly) to communicate
--!      with the SD device.
--!
--!      The RK8E controller has a LEN bit in the Command Register
--!      which causes the controller to perform a 128 word (256 byte)
--!      disk operation.   This eventually drives the sdLEN pin
--!      of this entity.
--!
--!      Section 11.14.7.11 of the External Bus Options Maintenance
--!      Manual Volume 3 says the following:
--!
--! \code
--!      If the RK8-E has been instructed to write 128 words,
--!      128th word is asserted after 128 words (half block)
--!      have been transferred.   The 128th word ends data
--!      transfer operations and the disk reads or writes zeros
--!      until the full block of data (256 words) has been read
--!      or written.
--! \endcode
--!
--!      It is fortunate that the controller works as described
--!      above because interactions between the controller and
--!      the SD disk are always 256 words (512 bytes).  The SD
--!      device cannot support 128 word (256 byte) transfers.
--!
--! \file
--!      sd.vhd
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
use ieee.numeric_std.all;                       --! IEEE Numeric Std
use work.cpu_types.all;                         --! CPU Types
use work.sdspi_types.all;                       --! SPI Types
use work.sd_types.all;                          --! SD Types

--
--! RK8E Secure Digital Interface Entity
--

entity eSD is port (
    sys        : in  sys_t;                     --! Clock/Reset
    ioclr      : in  std_logic;                 --! IOCLR
    -- PDP8 Interface
    dmaDIN     : in  data_t;                    --! DMA Data Into Disk
    dmaDOUT    : out data_t;                    --! DMA Data Out of Disk
    dmaADDR    : out addr_t;                    --! DMA Address
    dmaRD      : out std_logic;                 --! DMA Read
    dmaWR      : out std_logic;                 --! DMA Write
    dmaREQ     : out std_logic;                 --! DMA Request
    dmaGNT     : in  std_logic;                 --! DMA Grant
    -- Interface to SD Hardware
    sdMISO     : in  std_logic;                 --! SD Data In
    sdMOSI     : out std_logic;                 --! SD Data Out
    sdSCLK     : out std_logic;                 --! SD Clock
    sdCS       : out std_logic;                 --! SD Chip Select
    -- RK8E Interface
    sdOP       : in  sdOP_t;                    --! SD OP
    sdMEMaddr  : in  addr_t;                    --! Memory Address
    sdDISKaddr : in  sdDISKaddr_t;              --! Disk Address
    sdLEN      : in  sdLEN_t;                   --! Sector Length
    sdSTAT     : out sdSTAT_t                   --! Status
);
end eSD;

--
--! RK8E Secure Digital Interface RTL
--

architecture rtl of eSD is

    --
    -- Sending leading 0xff just sends clocks with data parked.
    --

    constant sdCMD0   : sdCMD_t := (x"40", x"00", x"00", x"00", x"00", x"95");
    constant sdCMD8   : sdCMD_t := (x"48", x"00", x"00", x"01", x"aa", x"87");
    constant sdCMD13  : sdCMD_t := (x"4d", x"00", x"00", x"00", x"00", x"ff");
    constant sdACMD41 : sdCMD_t := (x"69", x"40", x"00", x"00", x"00", x"ff");
    constant sdCMD55  : sdCMD_t := (x"77", x"00", x"00", x"00", x"00", x"ff");
    constant sdCMD58  : sdCMD_t := (x"7a", x"00", x"00", x"00", x"00", x"ff");

    type state_t is (stateRESET,
                     -- Init States
                     stateINIT00,
                     stateINIT01,
                     stateINIT02,
                     stateINIT03,
                     stateINIT04,
                     stateINIT05,
                     stateINIT06,
                     stateINIT07,
                     stateINIT08,
                     stateINIT09,
                     stateINIT10,
                     stateINIT11,
                     stateINIT12,
                     stateINIT13,
                     stateINIT14,
                     stateINIT15,
                     stateINIT16,
                     stateINIT17,
                     -- Read States
                     stateREAD00,
                     stateREAD01,
                     stateREAD02,
                     stateREAD03,
                     stateREAD04,
                     stateREAD05,
                     stateREAD06,
                     stateREAD07,
                     stateREAD08,
                     stateREAD09,
                     -- Write States
                     stateWRITE00,
                     stateWRITE01,
                     stateWRITE02,
                     stateWRITE03,
                     stateWRITE04,
                     stateWRITE05,
                     stateWRITE06,
                     stateWRITE07,
                     stateWRITE08,
                     stateWRITE09,
                     stateWRITE10,
                     stateWRITE11,
                     stateWRITE12,
                     stateWRITE13,
                     stateWRITE14,
                     stateWRITE15,
                     stateWRITE16,
                     -- Other States
                     stateFINI,
                     stateIDLE,
                     stateDONE,
                     stateINFAIL,
                     stateRWFAIL);
    signal   state   : state_t;                 --! Current State
    signal   spiOP   : spiOP_t;                 --! SPI Op
    signal   spiRXD  : sdBYTE_t;                --! SPI Received Data
    signal   spiTXD  : sdBYTE_t;                --! SPI Transmit Data
    signal   spiDONE : std_logic;               --! Asserted when SPI is done
    signal   bytecnt : integer range 0 to 65535;--! Byte Counter
    signal   sdCMD17 : sdCMD_t;                 --! CMD17
    signal   sdCMD24 : sdCMD_t;                 --! CMD24
    signal   memADDR : addr_t;                  --! Memory Address
    signal   memBUF  : std_logic_vector(0 to 3);--! Memory Buffer
    signal   memREQ  : std_logic;               --! DMA Request
    signal   abort   : std_logic;               --! Abort this command
    signal   timeout : integer range 0 to 499999;--! Timeout
    signal   rdCNT   : sdBYTE_t;                --! Read Counter
    signal   wrCNT   : sdBYTE_t;                --! Write Counter
    signal   err     : sdBYTE_t;                --! Error State
    signal   val     : sdBYTE_t;                --! Error Value
    signal   sdSTATE : sdSTATE_t;               --! State
    constant nCR     : integer := 8;            --! NCR from SD Spec
    constant nAC     : integer := 1023;         --! NAC from SD Spec
    constant nWR     : integer := 20;           --! NWR from SD Spec

begin

    --!
    --! SD_STATE:
    --! This process assumes a 50 MHz clock
    --

    SD_STATE : process(sys)
    begin

        if sys.rst = '1' then
            err     <= (others => '0');
            val     <= (others => '0');
            rdCNT   <= (others => '0');
            wrCNT   <= (others => '0');
            spiOP   <= spiNOP;
            bytecnt <= 0;
            dmaRD   <= '0';
            dmaWR   <= '0';
            memREQ  <= '0';
            memBUF  <= (others => '0');
            memADDR <= (others => '0');
            dmaDOUT <= (others => '0');
            spiTXD  <= (others => '0');
            sdCMD17 <= (x"51", x"00", x"00", x"00", x"00", x"ff");
            sdCMD24 <= (x"58", x"00", x"00", x"00", x"00", x"ff");
            abort   <= '0';
            bytecnt <= 0;
            dmaRD   <= '0';
            dmaWR   <= '0';
            memREQ  <= '0';
            spiOP   <= spiNOP;
            timeout <= 499999;
            sdSTATE <= sdstateINIT;
            state   <= stateRESET;
        elsif rising_edge(sys.clk) then

            dmaRD   <= '0';
            dmaWR   <= '0';
            spiOP   <= spiNOP;
            
            if sdOP = sdopABORT and state /= stateIDLE then
                abort <= '1';
            end if;

            case state is

                --
                -- stateRESET:
                --

                when stateRESET =>
                    timeout <= timeout - 1;
                    bytecnt <= 0;
                    state   <= stateINIT00;

                --
                -- stateINIT00
                --  Send 8x8 clocks cycles
                --

                when stateINIT00 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = nCR then
                            bytecnt <= 0;
                            spiOP   <= spiCSL;
                            state   <= stateINIT01;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT01:
                --  Send GO_IDLE_STATE command (CMD0)
                --

                when stateINIT01 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateINIT02;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD0(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT02:
                --  Read R1 Response from CMD0
                --  Response should be x"01"
                --

                when stateINIT02 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    state   <= stateRESET;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                if spiRXD = x"01" then
                                    state <= stateINIT03;
                                else
                                    state <= stateRESET;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateINIT03:
                --  Send 8 clock cycles
                --

                when stateINIT03 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        spiOP   <= spiCSL;
                        bytecnt <= 0;
                        state   <= stateINIT04;
                    end if;

                --
                -- stateINIT04:
                --   Send SEND_IF_COND (CMD8)
                --

                when stateINIT04 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateINIT05;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD8(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT05
                --  Read first byte R1 of R7 Response
                --  Response should be x"01" for V2.00 initialization or
                --  x"05" for V1.00 initialization.
                --

                when stateINIT05 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"01";
                                    state   <= stateINFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                bytecnt   <= 0;
                                if spiRXD = x"01" then
                                    state <= stateINIT06;
                                elsif spiRXD <= x"05" then
                                    err   <= x"02";
                                    state <= stateINFAIL;
                                else
                                    spiOP <= spiCSH;
                                    err   <= x"03";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateINIT06
                --  Read 32-bit Response to CMD8
                --  Response should be x"00_00_01_aa"
                --    x"01" - Voltage
                --    x"55" - Pattern
                --

                when stateINIT06 =>
                    timeout <= timeout - 1;
                    case bytecnt is
                        when 0 =>
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 1;
                         when 1 =>
                            if spiDONE = '1' then
                                if spiRXD = x"00" then
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= 2;
                                else
                                    err   <= x"04";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                         when 2 =>
                            if spiDONE = '1' then
                                if spiRXD = x"00" then
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= 3;
                                else
                                    err   <= x"05";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                         when 3 =>
                            if spiDONE = '1' then
                                if spiRXD = x"01" then
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= 4;
                                else
                                    err   <= x"06";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                         when 4 =>
                            if spiDONE = '1' then
                                if spiRXD = x"aa" then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    state   <= stateINIT07;
                                else
                                    err   <= x"07";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                         when others =>
                            null;
                    end case;

                --
                -- stateINIT07:
                --  Send 8 clock cycles
                --

                when stateINIT07 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        spiOP   <= spiCSL;
                        bytecnt <= 0;
                        state   <= stateINIT08;
                    end if;

                --
                -- stateINIT08:
                --   Send APP_CMD (CMD55)
                --

                when stateINIT08 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateINIT09;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD55(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT09:
                --  Read R1 response from CMD55.
                --  Response should be x"01"
                --

                when stateINIT09 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"08";
                                    state   <= stateINFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                if spiRXD = x"01" then
                                    state <= stateINIT10;
                                else
                                    state <= stateINIT07;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateINIT10:
                --  Send 8 clock cycles
                --

                when stateINIT10 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        spiOP   <= spiCSL;
                        bytecnt <= 0;
                        state   <= stateINIT11;
                    end if;

                --
                -- stateINIT11:
                --  Send SD_SEND_OP_COND (ACMD41)
                --

                when stateINIT11 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0  then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateINIT12;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdACMD41(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT12:
                --  Read R1 response from ACMD41.
                --  Response should be x"00"
                --

                when stateINIT12 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"09";
                                    state   <= stateINFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                if spiRXD = x"00" then
                                    state <= stateINIT13;
                                else
                                    state <= stateINIT07;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateINIT13
                --  Send 8 clock cycles
                --

                when stateINIT13 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        spiOP   <= spiCSL;
                        bytecnt <= 0;
                        state   <= stateINIT14;
                    end if;

                --
                -- stateINIT14:
                --  Send READ_OCR (CMD58)
                --

                when stateINIT14 =>
                    timeout <= timeout - 1;
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateINIT15;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD58(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateINIT15
                --  Read first byte of R3 response to CMD58
                --  Response should be x"00"
                --

                when stateINIT15 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"0a";
                                    state   <= stateINFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                bytecnt    <= 0;
                                if spiRXD = x"00" then
                                    state <= stateINIT16;
                                else
                                    spiOP <= spiCSH;
                                    err   <= x"0b";
                                    state <= stateINFAIL;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateINIT16
                --  Response should be "e0_ff_80_00"
                --  Read 32-bit OCR response to CMD58
                --

                when stateINIT16 =>
                    timeout <= timeout - 1;
                    case bytecnt is
                        when 0 =>
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 1;
                         when 1 =>
                            if spiDONE = '1' then
                                spiOP      <= spiTR;
                                spiTXD     <= x"ff";
                                bytecnt    <= 2;
                            end if;
                         when 2 =>
                            if spiDONE = '1' then
                                spiOP      <= spiTR;
                                spiTXD     <= x"ff";
                                bytecnt    <= 3;
                            end if;
                         when 3 =>
                            if spiDONE = '1' then
                                spiOP      <= spiTR;
                                spiTXD     <= x"ff";
                                bytecnt    <= 4;
                            end if;
                         when 4 =>
                            if spiDONE = '1' then
                                spiOP      <= spiCSH;
                                bytecnt    <= 0;
                                state      <= stateINIT17;
                            end if;
                         when others =>
                            null;
                    end case;

                --
                -- stateINIT17:
                --  Send 8 clock cycles
                --

                when stateINIT17 =>
                    timeout <= timeout - 1;
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        bytecnt <= 0;
--                      spiOP   <= spiFAST;
                        state   <= stateIDLE;
                    end if;

                --
                -- stateIDLE:
                --  Wait for a command to process.
                --  Once the SD card is initialized, it waits in this state
                --  for either a read (sdopRD) or a write (sdopWR) command.
                --

                when stateIDLE =>
                    abort   <= '0';
                    sdSTATE <= sdstateREADY;
                    case sdOP is
                        when sdopNOP =>
                            state <= stateIDLE;
                        when sdopRD =>
                            rdCNT <= std_logic_vector(unsigned(rdCNT) + 1);
                            state <= stateREAD00;
                        when sdopWR =>
                            wrCNT <= std_logic_vector(unsigned(wrCNT) + 1);
                            state <= stateWRITE00;
                        when others =>
                            state <= stateIDLE;
                    end case;

                --
                -- stateREAD00:
                --  Setup Read Single Block (CMD17)
                --

                when stateREAD00 =>
                    sdSTATE    <= sdstateREAD;
                    memADDR    <= sdMEMaddr;
                    sdCMD17(0) <= x"51";
                    sdCMD17(1) <= sdDISKaddr( 0 to  7);
                    sdCMD17(2) <= sdDISKaddr( 8 to 15);
                    sdCMD17(3) <= sdDISKaddr(16 to 23);
                    sdCMD17(4) <= sdDISKaddr(24 to 31);
                    sdCMD17(5) <= x"ff";
                    bytecnt    <= 0;
                    spiOP      <= spiCSL;
                    state      <= stateREAD01;

                --
                -- stateREAD01:
                --  Send Read Single Block (CMD17)
                --

                when stateREAD01 =>
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateREAD02;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD17(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateREAD02:
                --  Read R1 response from CMD17
                --  Response should be x"00"
                --

                when stateREAD02 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"0c";
                                    state   <= stateRWFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                bytecnt <= 0;
                                if spiRXD = x"00" then
                                    state <= stateREAD03;
                                else
                                    spiOP <= spiCSH;
                                    err   <= x"0d";
                                    state <= stateRWFAIL;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateREAD03:
                --  Find 'Read Start token' which should be x"fe"
                --

                when stateREAD03 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nAC then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"0e";
                                    state   <= stateRWFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                bytecnt <= 0;
                                if spiRXD = x"fe" then
                                    state <= stateREAD04;
                                else
                                    spiOP <= spiCSH;
                                    err   <= x"0f";
                                    val   <= spiRXD;
                                    state <= stateRWFAIL;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateREAD04:
                --  Acquire DMA.  Setup for loop.
                --

                when stateREAD04 =>
                    memREQ <= '1';
                    if dmaGNT = '1' then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 0;
                        state   <= stateREAD05;
                    end if;

                --
                -- stateREAD05:
                --  Read LSBYTE of data from disk (even addresses)
                --  Loop destination
                --

                when stateREAD05 =>
                    if spiDONE = '1' then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= bytecnt + 1;
                        dmaDOUT(4 to 11) <= spiRXD(0 to 7);
                        state <= stateREAD06;
                    end if;

                --
                -- stateREAD06:
                --  Read MSBYTE of data from disk (odd addresses).
                --  Discard the top four bits forming a 12-bit word
                --  from the two bytes.
                --

                when stateREAD06 =>
                    if spiDONE = '1' then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        dmaDOUT(0 to  3) <= spiRXD(4 to 7);
                        state <= stateREAD07;
                    end if;

                --
                -- stateREAD07:
                --  Write disk data to memory.
                --  If memREQ is not asserted, we are reading the second
                --  128 words of a 128 word read.  Notice no DMA occurs
                --  to memory and the bits are dropped.
                --

                when stateREAD07 =>
                    if memREQ = '1' then
                        dmaWR <= '1';
                    end if;
                    state <= stateREAD08;

                --
                -- stateREAD08:
                --  This state checks the loop conditions:
                --  1.  An abort command causes the loop to terminate immediately.
                --  2.  If sdLEN is asserted (128 word read) at byte 255, then
                --      the memory write DMA request is dropped.  The DMA address
                --      stops incrementing.  The state machine continues to read
                --      all 256 words (512 bytes).
                --  3.  At word 256 (byte 512), the loop terminates.
                --

                when stateREAD08 =>
                    if abort = '1' then
                        memREQ  <= '0';
                        spiOP   <= spiCSH;
                        bytecnt <= 0;
                        state   <= stateFINI;
                    elsif bytecnt = 511 then
                        memREQ  <= '0';
                        memADDR <= std_logic_vector(unsigned(memADDR) + 1);
                        bytecnt <= 0;
                        state   <= stateREAD09;
                    elsif bytecnt >= 255 and sdLEN = '1' then
                        memREQ  <= '0';
                        bytecnt <= bytecnt + 1;
                        state   <= stateREAD05;
                    else
                        memADDR <= std_logic_vector(unsigned(memADDR) + 1);
                        bytecnt <= bytecnt + 1;
                        state   <= stateREAD05;
                    end if;

                --
                -- stateREAD09:
                --  Read 2 bytes of CRC which is required for the SD Card.
                --

                when stateREAD09 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if bytecnt = 1 then
                                spiOP   <= spiTR;
                                spiTXD  <= x"ff";
                                bytecnt <= 2;
                            elsif bytecnt = 2 then
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                state   <= stateFINI;
                            end if;
                        end if;
                    end if;

                --
                -- stateWRITE00:
                --  Setup Write Single Block (CMD24)
                --

                when stateWRITE00 =>
                    sdSTATE    <= sdstateWRITE;
                    memADDR    <= sdMEMaddr;
                    sdCMD24(0) <= x"58";
                    sdCMD24(1) <= sdDISKaddr( 0 to  7);
                    sdCMD24(2) <= sdDISKaddr( 8 to 15);
                    sdCMD24(3) <= sdDISKaddr(16 to 23);
                    sdCMD24(4) <= sdDISKaddr(24 to 31);
                    sdCMD24(5) <= x"ff";
                    bytecnt    <= 0;
                    spiOP      <= spiCSL;
                    state      <= stateWRITE01;

                --
                -- stateWRITE01:
                --  Send Write Single Block (CMD24)
                --

                when stateWRITE01 =>
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            bytecnt <= 0;
                            state   <= stateWRITE02;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD24(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateWRITE02:
                --  Read R1 response from CMD24
                --  Response should be x"00"
                --

                when stateWRITE02 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    else
                        if spiDONE = '1' then
                            if spiRXD = x"ff" then
                                if bytecnt = nCR then
                                    spiOP   <= spiCSH;
                                    bytecnt <= 0;
                                    err     <= x"10";
                                    state   <= stateRWFAIL;
                                else
                                    spiOP   <= spiTR;
                                    spiTXD  <= x"ff";
                                    bytecnt <= bytecnt + 1;
                                end if;
                            else
                                bytecnt <= 0;
                                if spiRXD = x"00" then
                                    state <= stateWRITE03;
                                else
                                    spiOP <= spiCSH;
                                    val   <= spiRXD;
                                    err   <= x"11";
                                    state <= stateRWFAIL;
                                end if;
                            end if;
                        end if;
                    end if;

                --
                -- stateWRITE03:
                --  Send 8 clock cycles
                --

                when stateWRITE03 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        bytecnt <= 0;
                        state   <= stateWRITE04;
                    end if;

                --
                -- stateWRITE04:
                --  Send "Write Start Token".  The write start token is x"fe"
                --

                when stateWRITE04 =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"fe";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        bytecnt <= 0;
                        state   <= stateWRITE05;
                    end if;

                --
                -- stateWRITE05:
                --  Start a DMA Read Address Cycle
                --

                when stateWRITE05 =>
                    memREQ <= '1';
                    if dmaGNT = '1' then
                        state <= stateWRITE06;
                    end if;

                --
                -- stateWRITE06:
                --  Loop destination
                --  This is the data phase of the read cycle.
                --  If memREQ is not asserted, we are writing the second
                --  128 words of a 128 word write.  Notice no DMA occurs.
                --

                when stateWRITE06 =>
                    if memREQ = '1' then
                        dmaRD <= '1';
                    end if;
                    state <= stateWRITE07;

                --
                -- stateWRITE07:
                --  Write LSBYTE of data to disk (even addresses)
                --   This state has two modes:
                --    If memREQ is asserted we are operating normally.
                --    If memREQ is negated we are writing the last 128
                --     words of a 128 word operation.  Therefore we
                --     write zeros.  See file header.
                --

                when stateWRITE07 =>
                    spiOP  <= spiTR;
                    if memREQ = '1' then
                        memBUF <= dmaDIN(0 to 3);
                        spiTXD <= dmaDIN(4 to 11);
                    else
                        memBUF <= b"0000";
                        spiTXD <= b"0000_0000";
                    end if;
                    state  <= stateWRITE08;

                --
                -- stateWRITE08:
                --  Write MSBYTE of data to disk (odd addresses)
                --  Note:  The top 4 bits of the MSBYTE are zero.
                --

                when stateWRITE08 =>
                    if spiDONE = '1' then
                        spiOP   <= spiTR;
                        spiTXD  <= b"0000" & memBUF;
                        bytecnt <= bytecnt + 1;
                        state   <= stateWRITE09;
                    end if;

                --
                -- stateWRITE09:
                --  This is the addr phase of the read cycle.
                --

                when stateWRITE09 =>
                    if spiDONE = '1' then
                        if abort = '1' then
                            memREQ  <= '0';
                            spiOP   <= spiCSH;
                            bytecnt <= 0;
                            state   <= stateFINI;
                        elsif bytecnt = 511 then
                            memREQ  <= '0';
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 0;
                            memADDR <= std_logic_vector(unsigned(memADDR) + 1);
                            state   <= stateWRITE10;
                        elsif (bytecnt = 255 and sdLEN = '1') then
                            memREQ  <= '0';
                            spiOP   <= spiCSH;
                            bytecnt <= bytecnt + 1;
                            state   <= stateWRITE06;
                        else
                            bytecnt <= bytecnt + 1;
                            memADDR <= std_logic_vector(unsigned(memADDR) + 1);
                            state   <= stateWRITE06;
                        end if;
                    end if;

                --
                -- stateWRITE10:
                --  Write CRC bytes
                --

                when stateWRITE10 =>
                    if spiDONE = '1' then
                        if bytecnt = 0 then
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 1;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 0;
                            state   <= stateWRITE11;
                        end if;
                    end if;

                --
                -- stateWRITE11:
                --  Read Data Response.  The response is is one byte long
                --   and has the following format:
                --
                --   xxx0sss1
                --
                --    Where x is don't-care and sss is a 3-bit status field.
                --     010 is accepted,
                --     101 is rejected due to CRC error and
                --     110 is rejected due to write error.
                --

                when stateWRITE11 =>
                    if spiDONE = '1' then
                        if spiRXD(3 to 7) = b"0_010_1" then
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 0;
                            state   <= stateWRITE12;
                        else
                            spiOP   <= spiCSH;
                            val     <= spiRXD;
                            err     <= x"12";
                            bytecnt <= 0;
                            state   <= stateRWFAIL;
                        end if;
                    end if;

                --
                -- stateWRITE12:
                --  Wait for busy token to clear.   The disk reports
                --  all zeros while the write is occurring.
                --

                when stateWRITE12 =>
                    if spiDONE = '1' then
                        if spiRXD = x"00" then
                            if bytecnt = 65535 then
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                err     <= x"13";
                                state   <= stateRWFAIL;
                            else
                                spiOP   <= spiTR;
                                spiTXD  <= x"ff";
                                bytecnt <= bytecnt + 1;
                            end if;
                        else
                            bytecnt <= 0;
                            state   <= stateWRITE13;
                        end if;
                    end if;

                --
                -- stateWRITE13:
                --  Send "Send Status" Command (CMD13)
                --

                when stateWRITE13 =>
                    if spiDONE = '1' or bytecnt = 0 then
                        if bytecnt = 6 then
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 0;
                            state   <= stateWRITE14;
                        else
                            spiOP   <= spiTR;
                            spiTXD  <= sdCMD13(bytecnt);
                            bytecnt <= bytecnt + 1;
                        end if;
                    end if;

                --
                -- stateWRITE14:
                --  Check first byte of CMD13 response
                --  Status:
                --   Bit 0: Zero
                --   Bit 1: Parameter Error
                --   Bit 2: Address Error
                --   Bit 3: Erase Sequence Error
                --   Bit 4: COM CRC Error
                --   Bit 5: Illegal Command
                --   Bit 6: Erase Reset
                --   Bit 7: Idle State
                --

                when stateWRITE14 =>
                    if spiDONE = '1' then
                        if spiRXD = x"ff" then
                            if bytecnt = nCR then
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                err     <= x"14";
                                state   <= stateRWFAIL;
                            else
                                spiOP   <= spiTR;
                                spiTXD  <= x"ff";
                                bytecnt <= bytecnt + 1;
                            end if;
                        else
                            if spiRXD = x"00" or spiRXD = x"01" then
                                spiOP   <= spiTR;
                                spiTXD  <= x"ff";
                                bytecnt <= 0;
                                state   <= stateWRITE15;
                            else
                                spiOP   <= spiCSH;
                                bytecnt <= 0;
                                val     <= spiRXD;
                                err     <= x"15";
                                state   <= stateRWFAIL;
                            end if;
                        end if;
                    end if;

                --
                -- stateWRITE15:
                --  Check second byte of CMD13 response
                --  Status:
                --   Bit 0: Out of range
                --   Bit 1: Erase Param
                --   Bit 2: WP Violation
                --   Bit 3: ECC Error
                --   Bit 4: CC Error
                --   Bit 5: Error
                --   Bit 6: WP Erase Skip
                --   Bit 7: Card is locked
                --

                when stateWRITE15 =>
                    if spiDONE = '1' then
                        if spiRXD = x"00" then
                            spiOP   <= spiTR;
                            spiTXD  <= x"ff";
                            bytecnt <= 1;
                            state   <= stateWRITE16;
                        else
                            spiOP   <= spiCSH;
                            bytecnt <= 0;
                            val     <= spiRXD;
                            err     <= x"16";
                            state   <= stateRWFAIL;
                        end if;
                    end if;

                --
                -- stateWRITE16:
                --  Send 8 clock cycles.   Pull CS High.
                --

                when stateWRITE16 =>
                    if spiDONE = '1' then
                        spiOP   <= spiCSH;
                        bytecnt <= 0;
                        state   <= stateFINI;
                    end if;

                --
                -- stateFINI:
                --  Send 8 clock cycles
                --

                when stateFINI =>
                    if bytecnt = 0 then
                        spiOP   <= spiTR;
                        spiTXD  <= x"ff";
                        bytecnt <= 1;
                    elsif spiDONE = '1' then
                        bytecnt <= 0;
                        state   <= stateDONE;
                    end if;

                --
                -- stateDONE:
                --

                when stateDONE =>
                    sdSTATE <= sdstateDONE;
                    state   <= stateIDLE;

                --
                -- stateINFAIL:
                --  Initialization failed somehow.
                --

                when stateINFAIL =>
                    sdSTATE <= sdstateINFAIL;
                    state   <= stateINFAIL;

                --
                -- stateRWFAIL:
                --  Read or Write failed somehow.
                --

                when stateRWFAIL =>
                    sdSTATE <= sdstateRWFAIL;
                    state   <= stateRWFAIL;

            end case;
            
            if timeout = 0 then
                state  <= stateINFAIL;
            end if;

        end if;
    end process SD_STATE;

    --
    --! SDSPI Instance
    --

    iSDSPI : entity work.eSDSPI (rtl) port map (
        sys     => sys,
        spiOP   => spiOP,
        spiTXD  => spiTXD,
        spiRXD  => spiRXD,
        spiMISO => sdMISO,
        spiMOSI => sdMOSI,
        spiSCLK => sdSCLK,
        spiCS   => sdCS,
        spiDONE => spiDONE
    );

    with state select
        sdSTAT.debug <= -- Initialization
                        b"0000_0000" when stateINIT00,
                        b"0000_0001" when stateINIT01,
                        b"0000_0010" when stateINIT02,
                        b"0000_0011" when stateINIT03,
                        b"0000_0100" when stateINIT04,
                        b"0000_0101" when stateINIT05,
                        b"0000_0110" when stateINIT06,
                        b"0000_0111" when stateINIT07,
                        b"0000_1000" when stateINIT08,
                        b"0000_1001" when stateINIT09,
                        b"0000_1010" when stateINIT10,
                        b"0000_1011" when stateINIT11,
                        b"0000_1100" when stateINIT12,
                        b"0000_1101" when stateINIT13,
                        b"0000_1110" when stateINIT14,
                        b"0000_1111" when stateINIT15,
                        b"0001_0000" when stateINIT16,
                        b"0001_0001" when stateINIT17,
                        -- Read states
                        b"0010_0000" when stateREAD00,
                        b"0010_0001" when stateREAD01,
                        b"0010_0010" when stateREAD02,
                        b"0010_0011" when stateREAD03,
                        b"0010_0100" when stateREAD04,
                        b"0010_0101" when stateREAD05,
                        b"0010_0110" when stateREAD06,
                        b"0010_0110" when stateREAD07,
                        b"0010_0110" when stateREAD08,
                        b"0010_0110" when stateREAD09,
                        -- Write states
                        b"0011_0000" when stateWRITE00,
                        b"0011_0001" when stateWRITE01,
                        b"0011_0010" when stateWRITE02,
                        b"0011_0011" when stateWRITE03,
                        b"0011_0100" when stateWRITE04,
                        b"0011_0101" when stateWRITE05,
                        b"0011_0110" when stateWRITE06,
                        b"0011_0111" when stateWRITE07,
                        b"0011_1000" when stateWRITE08,
                        b"0011_1001" when stateWRITE09,
                        b"0011_1010" when stateWRITE10,
                        b"0011_1010" when stateWRITE11,
                        b"0011_1010" when stateWRITE12,
                        b"0011_1010" when stateWRITE13,
                        b"0011_1010" when stateWRITE14,
                        b"0011_1010" when stateWRITE15,
                        b"0011_1010" when stateWRITE16,
                        -- Other states
                        b"1111_0000" when stateRESET,
                        b"1111_0001" when stateIDLE,
                        b"1111_0010" when stateINFAIL,
                        b"1111_0011" when stateRWFAIL,
                        b"1111_0100" when others;
    
    dmaADDR       <= memADDR;
    dmaREQ        <= memREQ;
    sdSTAT.err    <= err;
    sdSTAT.val    <= val;
    sdSTAT.rdCNT  <= rdCNT;
    sdSTAT.wrCNT  <= wrCNT;
    sdSTAT.state  <= sdSTATE;
    
end rtl;
