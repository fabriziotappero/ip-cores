-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      PDP8 Device Type Definitions
--!
--! \details
--!      This package contains information that is required for any
--!      device.  All devices should use this package.
--!
--! \file
--!      dev_types.vhd
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

--
--! PDP8 Device Type Definitions Package
--

package dev_types is

    --
    --! Types
    --

    subtype  devADDR_t  is std_logic_vector( 0 to 11);          --! Device addresses
    subtype  devNUM_t   is std_logic_vector( 0 to  5);          --! IOT Device Number
    subtype  devOP_t    is std_logic_vector( 0 to  2);          --! IOT OP Code
    
end dev_types;
