-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      DK8E Real Time Clock Type Definitions
--!
--! \details
--!      This package defines some type information that is
--!      required to use the DK8E Real Time Clock device.
--!
--! \file
--!      dk8e_types.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2012 Rob Doyle
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

library ieee;                                   		--! IEEE Library
use ieee.std_logic_1164.all;                    		--! IEEE 1164
use work.dev_types.all;                                         --! Dev Types

--
--! DK8E Real Time Clock Device Type Package
--

package dk8e_types is

    --!
    --! Types
    --!
  
    subtype  swRTC_t    is std_logic_vector(0 to 2);            --! RTC configuration type
    subtype  schmitt_t  is std_logic_vector(0 to 2);            --! Schmitt Trigger Inputs type
    
    --!
    --! Real Time Device Number
    --!

    constant rtcdevNUM  : devNUM_t := o"13";                    --! 613x
  
    --!
    --! Real Time Clock IOTs DK8-EA/DK8-EC
    --!
    
  --constant opCLEI     : devOP_t := o"1";                      --! Enable Interrupt
  --constant opCLDI     : devOP_t := o"1";                      --! Disable Interrupt
  --constant opCLSK     : devOP_t := o"3";                      --! Skip on Clock Flag

    --!
    --! Real Time Clock IOTs DK8-EP
    --!

    constant opCLZE     : devOP_t := o"0";                      --! Clear Clock Enable Register
    constant opCLSK     : devOP_t := o"1";                      --! Skip on Clock Interrupt
    constant opCLDE     : devOP_t := o"2";                      --! Set Clock Enable Register
    constant opCLAB     : devOP_t := o"3";                      --! AC to Clock Buffer
    constant opCLEN     : devOP_t := o"4";                      --! Load Clock Enable Register
    constant opCLSA     : devOP_t := o"5";                      --! Clock Status to AC
    constant opCLBA     : devOP_t := o"6";                      --! Clock Buffer to AC
    constant opCLCA     : devOP_t := o"7";                      --! Clock Counter to AC
    
    --!
    --! Real Time Clock Configuation
    --!

    constant clkDK8EA1  : swRTC_t := "000";                     --! DK8-EA, 100Hz (50Hz Power)
    constant clkDK8EA2  : swRTC_t := "001";                     --! DK8-EA, 120Hz (60Hz Power)
    constant clkDK8EC1  : swRTC_t := "010";                     --! DK8-EC, 1  Hz
    constant clkDK8EC2  : swRTC_t := "011";                     --! DK8-EC, 50 Hz
    constant clkDK8EC3  : swRTC_t := "100";                     --! DK8-EC, 500Hz
    constant clkDK8EC4  : swRTC_t := "101";                     --! DK8-EC, 5KHz 
    constant clkDK8EP   : swRTC_t := "110";                     --! DK8-EP, VAR
    constant clkDK8ES   : swRTC_t := "111";                     --! DK8-ES, VAR
    
end dk8e_types;
