-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      RK8E Secure Digital Interface Type Definitions
--!
--! \details
--!      This package contains all the type information that is
--!      required to use the Secure Digital Disk Interface
--!
--! \file
--!      sd_types.vhd
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
use work.cpu_types.all;                                 --! CPU types

--
--! RK8E Secure Digital Interface Type Definition Package
--

package sd_types is

    --
    --! Types
    --

    subtype  sdBYTE_t     is std_logic_vector(0 to  7); --! Byte
    type     sdCMD_t      is array (0 to 5) of sdBYTE_t;--! SD Commands
    subtype  sdLEN_t      is std_logic;                 --! Read/Write Length
    subtype  sdDISKaddr_t is std_logic_vector(0 to 31); --! SD Sector Address
    subtype  sdCCRC_t     is std_logic_vector(0 to  6); --! Command CRC
    subtype  sdDCRC_t     is std_logic_vector(0 to 15); --! Data CRC
    type     sdOP_t       is (sdopNOP,                  --! SD NOP
                              sdopABORT,                --! Abort Read or Write
                              sdopRD,                   --! Read SD disk
                              sdopWR);                  --! Write SD disk
    type     sdSTATE_t    is (sdstateINIT,              --! SD Initializing
                              sdstateREADY,             --! SD Ready for commands
                              sdstateREAD,              --! SD Reading
                              sdstateWRITE,             --! SD Writing
                              sdstateDONE,              --! SD Done
                              sdstateINFAIL,            --! SD Initialization Failed
                              sdstateRWFAIL);           --! SD Read/Write Failed
    type sdSTAT_t         is record
        state             : sdSTATE_t;                  --! SD Status
        err               : sdBYTE_t;                   --! Error Status
        val               : sdBYTE_t;                   --! Value Status
        rdCNT             : sdBYTE_t;                   --! Read Count Status
        wrCNT             : sdBYTE_t;                   --! Write Count Status
        debug             : sdBYTE_t;                   --! Debug State
    end record;
        
    --
    --! Functions
    --
    
    function crc7 (indat : sdBYTE_t; crc : sdCCRC_t) return sdCCRC_t;
    function crc16(indat : sdBYTE_t; crc : sdDCRC_t) return sdDCRC_t;

end sd_types;

--
--! RK8E Secure Digital Interface Type Definition Package Body
--

package body sd_types is

    --
    --! CRC7: Used for Command CRC
    --
    
    function crc7(indat : sdBYTE_t; crc : sdCCRC_t) return sdCCRC_t is
        variable outdat : sdCCRC_t;
    begin
        outdat( 0) := crc( 4) xor   crc( 1) xor   crc( 0) xor indat( 4) xor indat( 1) xor indat( 0);
        outdat( 1) := crc( 5) xor   crc( 2) xor   crc( 1) xor indat( 5) xor indat( 2) xor indat( 1);
        outdat( 2) := crc( 6) xor   crc( 3) xor   crc( 2) xor indat( 6) xor indat( 3) xor indat( 2);
        outdat( 3) := crc( 4) xor   crc( 3) xor indat( 7) xor indat( 4) xor indat( 3);
        outdat( 4) := crc( 5) xor   crc( 1) xor indat( 5) xor indat( 1);
        outdat( 5) := crc( 6) xor   crc( 2) xor indat( 6) xor indat( 2);
        outdat( 6) := crc( 3) xor   crc( 0) xor indat( 7) xor indat( 3) xor indat( 0);
        return outdat;
    end crc7;

    --
    --! CRC16: Used for Data CRC
    --
    
    function crc16(indat : sdBYTE_t; crc : sdDCRC_t) return sdDCRC_t is
        variable outdat : sdDCRC_t;
    begin
        outdat( 0) := crc( 8) xor   crc( 4) xor   crc( 0) xor indat( 4) xor indat( 0);
        outdat( 1) := crc( 9) xor   crc( 5) xor   crc( 1) xor indat( 5) xor indat( 1);
        outdat( 2) := crc(10) xor   crc( 6) xor   crc( 2) xor indat( 6) xor indat( 2);
        outdat( 3) := crc(11) xor   crc( 7) xor   crc( 3) xor   crc( 0) xor indat( 7) xor indat( 3) xor indat( 0);
        outdat( 4) := crc(12) xor   crc( 1) xor indat( 1);
        outdat( 5) := crc(13) xor   crc( 2) xor indat( 2);
        outdat( 6) := crc(14) xor   crc( 3) xor indat( 3);
        outdat( 7) := crc(15) xor   crc( 4) xor   crc( 0) xor indat( 3) xor indat( 0);
        outdat( 8) := crc( 5) xor   crc( 1) xor   crc( 0) xor indat( 5) xor indat( 1) xor indat( 0);
        outdat( 9) := crc( 6) xor   crc( 2) xor   crc( 1) xor indat( 6) xor indat( 2) xor indat( 1);
        outdat(10) := crc( 7) xor   crc( 3) xor   crc( 2) xor indat( 7) xor indat( 3) xor indat( 2);
        outdat(11) := crc( 3) xor indat( 3);
        outdat(12) := crc( 4) xor   crc( 0) xor indat( 4) xor indat( 0);
        outdat(13) := crc( 5) xor   crc( 1) xor indat( 5) xor indat( 1);
        outdat(14) := crc( 6) xor   crc( 2) xor indat( 6) xor indat( 2);
        outdat(15) := crc( 7) xor   crc( 3) xor indat( 7) xor indat( 3);
        return outdat;
    end crc16;
    
end package body;
 
