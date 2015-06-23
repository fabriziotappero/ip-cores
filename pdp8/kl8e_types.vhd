-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E Serial Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the KL8E Serial Interface device.
--!
--! \file
--!      kl8e_types.vhd
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

library ieee;
use ieee.std_logic_1164.all;
use work.uart_types.all;                        --! UART Types
use work.dev_types.all;                         --! Device Types
    
--
--! Type definitions required for KL8E.
--

package kl8e_types is

    --!
    --! TTY Device Numbers
    --!

    constant tty1devNUM : devNUM_t := o"03";    --! 603x, 604x
    constant tty2devNUM : devNUM_t := o"40";    --! 640x, 641x
    constant lprdevNUM  : devNUM_t := o"65";    --! 665x, 666x
   
    --!
    --! Keyboard IOTs 
    --!
    
    constant opKCF      : devOP_t := o"0";      --! 6xx0 : Clear Keyboard Flag
    constant opKSF      : devOP_t := o"1";      --! 6xx1 : Skip On Keyboard Flag
    constant opKCC      : devOP_t := o"2";      --! 6xx2 : Clear Keyboard Flag, Clear AC
    constant opKRS      : devOP_t := o"4";      --! 6xx4 : OR Keyboard Character into AC
    constant opKIE      : devOP_t := o"5";      --! 6xx5 : Set/Clr Interrupt Enable
    constant opKRB      : devOP_t := o"6";      --! 6xx6 : Get Keyboard Character into AC, Clear Keyboard Flag

    --!
    --! Teleprinter IOTs
    --!
    
    constant opTFL      : devOP_t := o"0";      --! 6xx0: Set Tramsmit Flag
    constant opSPF      : devOP_t := o"0";      --! 6xx0: Set Printer Flag
    constant opTSF      : devOP_t := o"1";      --! 6xx1: Skip On Transmit Flag
    constant opTCF      : devOP_t := o"2";      --! 6xx2: Clear Transmit flag, but not the AC
    constant opTPC      : devOP_t := o"4";      --! 6xx4: Load AC into transmit buffer, but don't clear flag
    constant opTSK      : devOP_t := o"5";      --! 6xx5: Skip on keyboard/printer interrupt request
    constant opTLS      : devOP_t := o"6";      --! 6xx6: Load AC into transmit buffer and clear the flag
    
end kl8e_types;
