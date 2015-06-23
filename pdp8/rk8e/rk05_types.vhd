-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK05 Disk Simulation Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the RK05 Disk Drive simulator package.
--!
--! \file
--!      rk05_types.vhd
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sd_types.all;
use work.cpu_types.all;

--
--! RK05 Disk Simulation Type Definitions Package
--

package rk05_types is
    
    subtype  rk05CYL_t    is std_logic_vector(0 to 7);  --! RK05 Cylinder Number
    subtype  rk05SECT_t   is std_logic_vector(0 to 3);  --! RK05 Sector Number
    subtype  rk05HEAD_t   is std_logic;                 --! RK05 Head Number
    subtype  rk05DRIVE_t  is std_logic_vector(0 to 1);  --! RK05 Drive Number
    subtype  rk05WRINH_t  is std_logic;                 --! Write Inhibit
    subtype  rk05MNT_t    is std_logic;                 --! Mounted
    subtype  rk05LEN_t    is std_logic;                 --! 128/256 word access
    subtype  rk05RECAL_t  is std_logic;                 --! Recalibrate
    subtype  rk05drvNUM_t is integer range -1 to 3;     --! Drive Array Index

    constant DRIVE0       : rk05drvNUM_t := 0;          --! Drive 0 Index
    constant DRIVE1       : rk05drvNUM_t := 1;          --! Drive 1 Index
    constant DRIVE2       : rk05drvNUM_t := 2;          --! Drive 2 Index
    constant DRIVE3       : rk05drvNUM_t := 3;          --! Drive 3 Index
    constant DRIVENULL    : rk05drvNUM_t := -1;         --! Drive 4 (not valid)
    
    --!
    --! RK05 Op
    --!

    type rk05OP_t    is (rk05opNOP,
                         rk05opCLR,
                         rk05opRECAL,
                         rk05opSEEK,
                         rk05opWRPROT,
                         rk05opREAD,
                         rk05opWRITE);
    
    --!
    --! RK05 State
    --!
    
    type rk05STATE_t is (rk05stIDLE,
                         rk05stBUSY,
                         rk05stDONE);

    --!
    --! RK05 Status
    --!
    
    type rk05STAT_t  is record
        active       : std_logic;                       --! Disk Activity (one-shot)
        state        : rk05STATE_t;                     --! Controller State
        mounted      : rk05MNT_t;                       --! Mounted
        recal        : rk05RECAL_t;                     --! Recalibrate
        wrinh        : rk05WRINH_t;                     --! Write Inhibit
        sdOP         : sdOP_t;                          --! OP
        sdLEN        : sdLEN_t;                         --! 128/256 word access
        sdMEMaddr    : addr_t;                          --! Memory Address
        sdDISKaddr   : sdDISKaddr_t;                    --! Linear Disk Address
    end record;

    --!
    --! Disk Array Types
    --!
    
    type rk05OP_tt   is array(0 to 3) of rk05OP_t;      --! Array of RK05 OPs
    type rk05STAT_tt is array(0 to 3) of rk05STAT_t;    --! Array of RK05 Status

end rk05_types;
