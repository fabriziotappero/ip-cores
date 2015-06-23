-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      LS8E Printer Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the LS8E Printer Interface device.
--!
--! \file
--!      ls8e_types.vhd
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
use work.dev_types.all;
    
--
--! Type definitions required for LS8E.
--

package ls8e_types is

    --!
    --! LPR Device Numbers
    --!

    constant prndevNUM  : devNUM_t := o"66";            --! 666x
   
    --!
    --! Printer IOTs
    --!  There don't seem to be mnemonics for LS8E IOTs.
    --!  Numbers will be used to avoid any confustion.
    
    constant opLS0      : devOP_t := o"0";              --! 6xx0 : Set Printer Flag
    constant opLS1      : devOP_t := o"1";              --! 6xx1 : Skip On Printer Flag
    constant opLS2      : devOP_t := o"2";              --! 6xx2 : Clear Printer Flag
    constant opLS3      : devOP_t := o"3";              --! 6xx3 : (LE8 Only)
    constant opLS4      : devOP_t := o"4";              --! 6xx4 : Load Printer Buffer
    constant opLS5      : devOP_t := o"5";              --! 6xx5 : Set/Clear Interrupt Enable
    constant opLS6      : devOP_t := o"6";              --! 6xx6 : Load Printer Buffer Sequence
    constant opLS7      : devOP_t := o"7";              --! 6xx7 : (LE8 Only)
    
end ls8e_types;
