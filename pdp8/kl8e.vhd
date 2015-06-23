--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E Serial Interface
--!
--! \file
--!      kl8e.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011 Rob Doyle
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
use work.uart_types.all;                        --! UART Types
use work.kl8e_types.all;                        --! KL8E types
use work.cpu_types.all;                         --! CPU types

--
--! KL8E Serial Interface Entity
--

entity eKL8E is port (
    sys    : in  sys_t;                         --! Clock/Reset
    uartBR : in  uartBR_t;                      --! Baud Rate Select
    uartHS : in  uartHS_t;                      --! Handshake Select
    devNUM : in  devNUM_t;                      --! Device Number
    cpu    : in  cpu_t;                         --! CPU Output
    dev    : out dev_t;                         --! Device Output
    cts    : in  std_logic;                     --! CTS Input
    rts    : out std_logic;                     --! RTS Output
    rxd    : in  std_logic;                     --! Serial Data In
    txd    : out std_logic                      --! Serial Data Out
);
end eKL8E;

--
--! KL8E Serial Interface RTL
--

architecture rtl of eKL8E is

    signal clkBR    : std_logic;                --! Baud Rate Generator Clock Enable
    signal intEN    : std_logic;                --! Interrupt Enable
    signal rxDEV    : dev_t;                    --! RX DEV
    signal txDEV    : dev_t;                    --! TX DEV
    signal rxdevNUM : devNUM_t;                 --! Receiver Device Number
    signal txdevNUM : devNUM_t;                 --! Transmitter Device Number
    
begin

    --
    -- Create the Device Numbers
    --

    rxdevNUM <= devNUM;
    txdevNUM <= std_logic_vector(unsigned(devNUM) + "1");
    
    --
    --! Baud Rate Generator
    --

    iKL8E_BRG : entity work.eUART_BRG port map (
        sys    => sys,
        uartBR => uartBR,
        clkBR  => clkBR
    );

    --
    --! Receiver UART Device
    --
    
    iKL8E_RX : entity work.eKL8E_RX port map (
        sys    => sys,
        intEN  => intEN,
        clkBR  => clkBR,
        devNUM => rxdevNUM,
        cpu    => cpu,
        dev    => rxDEV,
        rxd    => rxd
    );

    --
    --! Transmitter UART Device
    --
    
    iKL8E_TX : entity work.eKL8E_TX port map (
        sys    => sys,
        intEN  => intEN,
        clkBR  => clkBR,
        devNUM => txdevNUM,
        cpu    => cpu,
        dev    => txDEV,
        txd    => txd
    );

    --
    --! This process implements a Bus Multiplexer that multiplexes
    --! the bus between the UART Receiver and the UART Transmitter.
    --
    
    KL8E_BUSMUX : process (txDev, txDev.dma, rxDev, rxDev.dma)
    begin

        if txDEV.ack = '1' then
            dev <= txDEV;
        elsif rxDEV.ack = '1' then
            dev <= rxDEV;
        else
            dev <= nullDEV;
        end if;
        
        dev.intr <= txDEV.intr or rxDEV.intr;
        
    end process KL8E_BUSMUX;
 
end rtl;
