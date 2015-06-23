--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Secure Digital SPI Interface
--!
--! \details
--!      This interface communicates with the Secure Digital Chip
--!      at the physical layer.
--!
--! \file
--!      sdspi.vhd
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
use work.sd_types.all;                          --! SD Types
use work.sdspi_types.all;                       --! SD SPI Types

--
--! RK8E Secure Digital SPI Interface Entity
--

entity eSDSPI is port (
    sys     : in  sys_t;                        --! Clock/Reset
    spiOP   : in  spiOP_t;                      --! Operation
    spiTXD  : in  sdBYTE_t;                     --! Transmit Data
    spiRXD  : out sdBYTE_t;                     --! Receive Data
    spiMISO : in  std_logic;                    --! Data In
    spiMOSI : out std_logic;                    --! Data Out
    spiSCLK : out std_logic;                    --! Clock
    spiCS   : out std_logic;                    --! Chip Select
    spiDONE : out std_logic                     --! Done
);
end eSDSPI;

--
--! RK8E Secure Digital SPI Interface RTL
--

architecture rtl of eSDSPI is
    type     state_t is (stateRESET,
                         stateIDLE,
                         stateTXH,
                         stateTXL,
                         stateTXM,
                         stateTXN);
    signal   state   : state_t;
    signal   bitcnt  : integer range 0 to  7;
    signal   txd     : sdBYTE_t;
    signal   rxd     : sdBYTE_t;
    signal   clkcnt  : integer range 0 to 63;
    signal   clkdiv  : integer range 0 to 63;
    constant slowDiv : integer := 63;
    constant fastDiv : integer :=  1;

begin

    SPI_STATE : process(sys)
    begin
        if sys.rst = '1' then
            spiDONE <= '0';
            txd     <= (others => '1');
            rxd     <= (others => '1');
            spiCS   <= '1';
            bitcnt  <= 0;
            clkcnt  <= 0;
            clkdiv  <= slowDiv;
            state   <= stateRESET;
        elsif rising_edge(sys.clk) then
            case state is
                when stateRESET => 
                    clkdiv  <= slowDiv;
                    state   <= stateIDLE;
                when stateIDLE =>
                    spiDONE <= '0';
                    case spiOP is
                        when spiNOP =>
                            null;
                        when spiCSL =>
                            spiCS <= '0';
                        when spiCSH =>
                            spiCS <= '1';
                        when spiFAST =>
                            clkDiv <= fastDiv;
                        when spiSLOW =>
                            clkDiv <= slowDiv;
                        when spiTR =>
                            clkcnt <= clkdiv;
                            bitcnt <= 7;
                            txd    <= spiTXD;
                            state  <= stateTXL;
                        when others =>
                            null;
                    end case;
                when stateTXL =>
                    if clkcnt = 0 then
                        clkcnt <= clkdiv;
                        rxd    <= rxd(1 to 7) & spiMISO;
                        state  <= stateTXH;
                    else
                        clkcnt <= clkcnt - 1;
                    end if;
                when stateTXH =>
                    if clkcnt = 0 then
                        if bitcnt = 0 then
                            clkcnt <= clkdiv;
                            state  <= stateTXM;
                        else
                            clkcnt <= clkdiv;
                            txd    <= txd(1 to 7) & '1';
                            bitcnt <= bitcnt - 1;
                            state  <= stateTXL;
                        end if;
                    else
                        clkcnt <= clkcnt - 1;
                    end if;
                when stateTXM => 
                    if clkcnt = 0 then
                        clkcnt <= clkdiv;
                        state  <= stateTXN;
                    else
                        clkcnt <= clkcnt - 1;
                    end if;
                when stateTXN =>
                    if clkcnt = 0 then
                        clkcnt  <= clkdiv;
                        spiDONE <= '1';
                        state   <= stateIDLE;
                    else
                        clkcnt <= clkcnt - 1;
                    end if;
                 when others =>
                    null;
            end case;
        end if;
    end process SPI_STATE;

    with state select
        spiSCLK <= '1'    when stateIDLE,
                   '0'    when stateTXL,
                   '1'    when stateTXH,
                   '1'    when stateTXN,
                   '1'    when others;

    spiMOSI <= txd(0);
    spiRXD  <= rxd;
    
end rtl;
