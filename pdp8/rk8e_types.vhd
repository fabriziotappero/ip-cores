-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Disk Controller Type Definitions
--!
--! \details
--!      This package defines some type information that is
--!      required to use the RK8E Disk Controller device.
--!
--! \file
--!      rk8e_types.vhd
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

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use work.dev_types.all;                         --! Device Types
use work.rk05_types.all;                        --! RK05 Types
use work.sd_types.all;                          --! SD Types

--
--! RK8E Disk Controller Type Definitions Package
--

package rk8e_types is
    
    --
    --! RK8E Status Type Definition
    --
    
    type rk8eSTAT_t is record
        sdCD     : std_logic;                           --! Secure Digital Card Detect
        sdWP     : std_logic;                           --! Secure Digital Write Protect
        rk05STAT : rk05STAT_tt;                         --! Array of RK05 Disk Status'
        sdSTAT   : sdSTAT_t;                            --! Secure Digital Device Status
    end record;
    
    --
    --! Device Numbers
    --

    constant rk8edevNUM : devNUM_t := o"74";            --! 674x
    
end rk8e_types;
