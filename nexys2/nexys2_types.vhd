-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: Type Definitions
--!
--! \details
--!      
--!
--! \file
--!      nexys2_types.vhd
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
use ieee.numeric_std.all;
use work.cpu_types.all;
    
--
--! NEXYS2 Type Definition Package
--

package nexys2_types is
  
    subtype  dispSeg_t  is std_logic_vector(0 to  7);           --! Display Segment Driver
    subtype  dispDig_t  is std_logic_vector(0 to  3);           --! Display Digit Drivers
    subtype  dispDat_t  is std_logic_vector(0 to 15);           --! Display Data type
    subtype  iodata_t   is std_logic_vector(0 to 23);           --! IO Bus
    subtype  led_t      is std_logic_vector(0 to  7);           --! LEDs
    subtype  btn_t      is std_logic_vector(0 to  3);           --! Push Buttons
    subtype  sw_t       is std_logic_vector(0 to  7);           --! Switches

    function to_octal(indat : data_t) return dispDat_t;
    
end nexys2_types;

--
--! NEXYS2 Type Definition Package Body
--

package body nexys2_types is

    --
    -- Function to convert data from octal to dispDat_t
    --
    
    function to_octal(indat : data_t) return dispDat_t is
    begin
        return '0' & indat(0 to 2) & '0' & indat(3 to 5) &
               '0' & indat(6 to 8) & '0' & indat(9 to 11);
    end to_octal;
    
end package body;
