-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      UART Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use and UART-based Serial Interface device.
--!
--!      The UART-based devices are:
--!      -# KL8E Serial Interface (TTY1 and TTY2)
--!      -# PR8E Serial Line Printer (LPR)
--!      -# PR8E Interface to Serial Paper Tape Reader
--!
--! \file
--!      uart_types.vhd
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

library ieee;
use ieee.std_logic_1164.all;
    
--
--! Type definitions required for UARTS
--

package uart_types is

    --
    -- Baud Rate Select
    --
    
    subtype  uartBR_t     is std_logic_vector(0 to 3);       	--! Baud Rate Configuration type
    constant uartBR1200   : uartBR_t := "0000";                 --! 1200 Baud
    constant uartBR2400   : uartBR_t := "0001";                 --! 2400 Baud
    constant uartBR4800   : uartBR_t := "0010";                 --! 4800 Baud
    constant uartBR9600   : uartBR_t := "0011";                 --! 9600 Baud
    constant uartBR19200  : uartBR_t := "0100";                 --! 19200 Baud
    constant uartBR38400  : uartBR_t := "0101";                 --! 38400 Baud
    constant uartBR57600  : uartBR_t := "0110";                 --! 57600 Baud
    constant uartBR115200 : uartBR_t := "0111";                 --! 115200 Baud

    --
    -- Handshaking Select
    --

    subtype  uartHS_t     is std_logic_vector(0 to 1);          --! Handshaking type
    constant uartHSnone   : uartHS_t := "00";                   --! No handshaking
    constant uartHShw     : uartHS_t := "01";                   --! Hardware handshaking
    constant uartHSsw     : uartHS_t := "10";                   --! Software (XON/XOFF) handshaking
    constant uartHSres    : uartHS_t := "11";                   --! Reserved

    --
    -- ASCII Constants
    --

    subtype  ascii_t    is std_logic_vector(0 to 7);
    
    constant xon        : ascii_t := x"11";                     --! XON (^Q)
    constant xoff       : ascii_t := x"13";                     --! XON (^S)
  
end uart_types;
