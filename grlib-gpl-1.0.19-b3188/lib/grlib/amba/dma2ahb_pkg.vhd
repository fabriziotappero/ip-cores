------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
--============================================================================--
-- Design unit  : DMA2AHB_Package (package declaration)
--
-- File name    : dma2ahb_pkg.vhd
--
-- Purpose      : Interface package for AMBA AHB master interface with DMA input
--
-- Reference    : AMBA(TM) Specification (Rev 2.0), ARM IHI 0011A,
--                13th May 1999, issue A, first release, ARM Limited
--                The document can be retrieved from http://www.arm.com
--                AMBA is a trademark of ARM Limited.
--                ARM is a registered trademark of ARM Limited.
--
-- Note         : Naming convention according to AMBA(TM) Specification:
--                Signal names are in upper case, except for the following:
--                   A lower case 'n' in the name indicates that the signal
--                   is active low.
--                   Constant names are in upper case.
--                The least significant bit of an array is located to the right,
--                carrying the index number zero.
--
-- Limitations  : See DMA2AHB VHDL core
--
-- Library      : gaisler
--
-- Authors      : Mr Sandi Habinc
--                Gaisler Research AB
--                Forsta Langgantan 19
--                SE-413 27 Göteborg
--                Sweden
--
-- Contact      : mailto:sandi@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--
--------------------------------------------------------------------------------
-- Version  Author   Date           Changes
--
-- 1.4      SH        1 Jul 2005    Support for fixed length incrementing bursts
--                                  Support for record types
-- 1.5      SH        1 Sep 2005    New library gaisler
-- 1.6      SH       20 Sep 2005    Added transparent HSIZE support
-- 1.7      SH        6 Dec 2007    Added syncrst generic
--------------------------------------------------------------------------------
library  ieee;
use      ieee.std_logic_1164.all;

library  grlib;
use      grlib.amba.all;

package DMA2AHB_Package is
   -----------------------------------------------------------------------------
   -- Direct Memory Access to AMBA AHB Master Interface Types
   -----------------------------------------------------------------------------
   type DMA_In_Type is record
      Reset:            Std_Logic;
      Address:          Std_Logic_Vector(32-1 downto 0);
      Data:             Std_Logic_Vector(32-1 downto 0);
      Request:          Std_Logic;                       -- access requested
      Burst:            Std_Logic;                       -- burst requested
      Beat:             Std_Logic_Vector(1 downto 0);    -- incrementing beat
      Size:             Std_Logic_Vector(1 downto 0);    -- size
      Store:            Std_Logic;                       -- data write requested
      Lock:             Std_Logic;                       -- locked Transfer
   end record;

   type DMA_Out_Type is record
      Grant:            Std_Logic;                       -- access accepted
      OKAY:             Std_Logic;                       -- write access ready
      Ready:            Std_Logic;                       -- read data ready
      Retry:            Std_Logic;                       -- retry
      Fault:            Std_Logic;                       -- error occured
      Data:             Std_Logic_Vector(32-1 downto 0);
   end record;

   -- constants for HBURST definition (used with dma_in_type.Beat)
   constant HINCR:      Std_Logic_Vector(1 downto 0) := "00";
   constant HINCR4:     Std_Logic_Vector(1 downto 0) := "01";
   constant HINCR8:     Std_Logic_Vector(1 downto 0) := "10";
   constant HINCR16:    Std_Logic_Vector(1 downto 0) := "11";

   -- constants for HSIZE definition (used with dma_in_type.Size)
   constant HSIZE8:     Std_Logic_Vector(1 downto 0) := "00";
   constant HSIZE16:    Std_Logic_Vector(1 downto 0) := "01";
   constant HSIZE32:    Std_Logic_Vector(1 downto 0) := "10";

   -----------------------------------------------------------------------------
   -- Direct Memory Access to AMBA AHB Master Interface
   -----------------------------------------------------------------------------
   component DMA2AHB is
      generic(
         hindex:        in    Integer := 0;
         vendorid:      in    Integer := 0;
         deviceid:      in    Integer := 0;
         version:       in    Integer := 0;
         syncrst:       in    Integer := 1;
         boundary:      in    Integer := 1);
      port(
         -- AMBA AHB system signals
         HCLK:          in    Std_ULogic;
         HRESETn:       in    Std_ULogic;

         -- Direct Memory Access Interface
         DMAIn:         in    DMA_In_Type;
         DMAOut:        out   DMA_OUt_Type;

         -- AMBA AHB Master Interface
         AHBIn:         in    AHB_Mst_In_Type;
         AHBOut:        out   AHB_Mst_Out_Type);
   end component DMA2AHB;
end package DMA2AHB_Package; --===============================================--
