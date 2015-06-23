-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      PR8E Paper Tape Reader Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the PR8E Paper Tape Reader Interface
--!      device.
--!
--! \file
--!      pr8e_types.vhd
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

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use work.dev_types.all;                         --! Device Types
    
--
--! Type definitions required for PR8E.
--

package pr8e_types is

    --
    --  Device Numbers
    --

    constant ptrdevNUM  : devNUM_t := o"01";    --! 601x
    constant ptpdevNUM  : devNUM_t := o"02";    --! 602x
   
    --
    -- Paper Tape Reader IOTs
    --  The RPE IOT is common to the reader and punch
    --
   
    constant opRPE      : devOP_t := o"0";      --! 6xx0 : Set Interupt for Reader and Punch
    constant opRSF      : devOP_t := o"1";      --! 6xx1 : Skip On Reader Flag
    constant opRRB      : devOP_t := o"2";      --! 6xx2 : Read Reader Buffer and Clear Flag
    constant opRFC      : devOP_t := o"4";      --! 6xx4 : Clear Flag and Buffer and Fetch Character
    constant opRCC      : devOP_t := o"6";      --! 6xx6 : Read Reader Buffer, and Clear Flag, and Fetch Character

    --
    -- Paper Tape Punch IOTs
    --  The PCE IOT is common to the reader and punch
    --

    constant opPCE      : devOP_t := o"0";      --! 6xx0 : Clear Interupt for Reader and Punch
    constant opPSF      : devOP_t := o"1";      --! 6xx1 : Skip on Punch Flag
    constant opPCF      : devOP_t := o"2";      --! 6xx2 : Clear Flag and Buffer
    constant opPPC      : devOP_t := o"4";      --! 6xx4 : Load Buffer and Punch Character
    constant opPLS      : devOP_t := o"6";      --! 6xx6 : Clear Flag and Buffer, Load Buffer and Punch Character
   
end pr8e_types;
