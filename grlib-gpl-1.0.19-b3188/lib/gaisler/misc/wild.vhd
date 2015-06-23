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
-- Design unit  : WildCard Package (package declaration)
--
-- File name    : wild.vhd
--
-- Purpose      : WildCard Package
--
-- Library      : gaisler
--
-- Authors      : Mr Sandi Alexander Habinc
--                Gaisler Research
--
-- Contact      : mailto:support@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--------------------------------------------------------------------------------
-- Version  Author   Date           Changes
--
-- 0.1      SH        1 Jan 2008    New version
--------------------------------------------------------------------------------
library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  grlib;
use      grlib.amba.all;

package Wild is
   -----------------------------------------------------------------------------
   --  Name Key:
   --  =========
   --  _AS       : Address Strobe
   --  _DS       : Data Strobe
   --  _WR       : Write Select
   --  _CS       : Chip Select
   --  _OE       : Output Enable
   --  _n        : Active low signals (must be last part of name)
   --
   --  Name                  Width  Dir*   Description
   --  ====================  =====  ====   =====================================
   --  Addr_Data              32     I     Shared address/data bus input
   --  AS_n                    1     I     Address strobe
   --  DS_n                    1     I     Data strobe
   --  WR_n                    1     I     Write select
   --  CS_n                    1     I     PE chip select
   --  Reg_n                   1     I     Register mode select
   --  Ack_n                   1     O     Acknowledge strobe
   --  Addr_Data              32     O     Shared address/data bus output
   --  Addr_Data_OE_n          1     O     Address/data bus output enable
   --  Int_Req_n               1     O     Interrupt request
   --  DMA_0_Data_OK_n         1     O     DMA channel 0 data OK flag
   --  DMA_0_Burst_OK_n        1     O     DMA channel 0 burst OK flag
   --  DMA_1_Data_OK_n         1     O     DMA channel 1 data OK flag
   --  DMA_1_Burst_OK_n        1     O     DMA channel 1 burst OK flag
   --  Reg_Data_OK_n           1     O     Register space data OK flag
   --  Reg_Burst_OK_n          1     O     Register space burst OK flag
   --  Force_K_Clk_n           1     O     Forces K_Clk to run when active
   -----------------------------------------------------------------------------
   type LAD_In_Type is record
      Addr_Data:        Std_Logic_Vector(31 downto 0);   -- Shared address/data bus
      AS_n:             Std_Logic;                       -- Address strobe
      DS_n:             Std_Logic;                       -- Data strobe
      WR_n:             Std_Logic;                       -- Write select
      CS_n:             Std_Logic;                       -- Chip select
      Reg_n:            Std_Logic;                       -- Register select
   end record;

   type LAD_Out_Type is record
      Addr_Data:        Std_Logic_Vector(31 downto 0);   -- Shared address/data bus output
      Addr_Data_OE_n:   Std_Logic_Vector(31 downto 0);   -- Address/data bus output enable
      Ack_n:            Std_Logic;                       -- Acknowledge strobe
      Int_Req_n:        Std_Logic;                       -- Interrupt request
      DMA_0_Data_OK_n:  Std_Logic;                       -- DMA chan 0 data OK flag
      DMA_0_Burst_OK:   Std_Logic;                       -- DMA chan 0 burst OK flag
      DMA_1_Data_OK_n:  Std_Logic;                       -- DMA chan 1 data OK flag
      DMA_1_Burst_OK:   Std_Logic;                       -- DMA chan 1 burst OK flag
      Reg_Data_OK_n:    Std_Logic;                       -- Reg space data OK flag
      Reg_Burst_OK:     Std_Logic;                       -- Reg space burst OK flag
      Force_K_Clk_n:    Std_Logic;                       -- K_Clk forced-run select
      Reserved:         Std_Logic;                       -- Reserved for future use
   end record;

   component Wild2AHB is
   generic (
      hindex:     in    Integer := 0;
      burst:      in    Integer := 0;
      syncrst:    in    Integer := 0);
   port (
      rstkn:      in    Std_ULogic;
      clkk:       in    Std_ULogic;

      rstfn:      in    Std_ULogic;
      clkf:       in    Std_ULogic;

      ahbmi:      in    AHB_Mst_In_Type;
      ahbmo:      out   AHB_Mst_Out_Type;

      ladi:       in    LAD_In_Type;
      lado:       out   LAD_Out_Type);
   end component;

end package Wild; --==========================================================--
