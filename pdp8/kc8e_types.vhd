-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KC8E Front Panel Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the KC8E Front Panel device.
--!
--! \file
--!      kc8e_types.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009 Rob Doyle
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
--! Type definitions required for KC8E front panel
--

package kc8e_types is

    --!
    --! Types
    --!
  
    subtype  swROT_t    is std_logic_vector(0 to 2);            --! Rotary Switch type
  
    --!
    --! Switch Register IOTs
    --!
    
    constant insWSR     : devADDR_t := o"6246";                 --! Write Switch Register
    constant insOSR     : devADDR_t := o"7404";                 --! OR Switch Register into AC
    constant insLAS     : devADDR_t := o"7604";                 --! Load Switch Register into AC

    --!
    --! Front Panel Rotary Switch
    --!

    constant dispPC     : swROT_t := "000";                     --! Display PC
    constant dispAC     : swROT_t := "001";                     --! Display AC
    constant dispIR     : swROT_t := "010";                     --! Display IR
    constant dispMA     : swROT_t := "011";                     --! Display MA
    constant dispMD     : swROT_t := "100";                     --! Display MD
    constant dispMQ     : swROT_t := "101";                     --! Display MQ
    constant dispST     : swROT_t := "110";                     --! Display ST
    constant dispSC     : swROT_t := "111";                     --! Display SC
    
end kc8e_types;
