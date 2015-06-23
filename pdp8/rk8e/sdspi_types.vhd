--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Secure Digital SPI Interface Types
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the SPI layer of the Secure Digital
--!      Disk Interface protocol.
--!
--! \file
--!      sdspi_types.vhd
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

library ieee;                                           --! IEEE Library
use ieee.std_logic_1164.all;                            --! IEEE 1164

--
--! RK8E Secure Digital Interface SPI Interface Type Package
--

package sdspi_types is

    --!
    --! Types
    --!
  
    type     spiOP_t    is (spiNOP,                     --! NOP
                            spiCSL,                     --! Set CS Low
                            spiCSH,                     --! Set CS High
                            spiFAST,                    --! Go Fast
                            spiSLOW,                    --! Go Slow
                            spiTR);                     --! Transmit/Receive Byte

end sdspi_types;
