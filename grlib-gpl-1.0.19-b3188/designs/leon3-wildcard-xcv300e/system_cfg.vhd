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
-- Design unit  : System_Config (configuration declaration)
--
-- File name    : system_cfg.vhd
--
-- Purpose      : System configuration for co-simulation of host and WildCard
--
-- Library      : System
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
--============================================================================--
library SYSTEM;
library PE_Lib;
library Work;

configuration System_Config of System is
   for Structure
      for U_Host: Host
         use entity SYSTEM.Host(Validate);
      end for;

      for U_WILDCARD: WILDCARD
         use entity SYSTEM.WILDCARD(Standard);
         for Standard
            for U_PE: PE
               use entity PE_Lib.PE(Wrapper);
               for Wrapper
                  for FPGA: WildFpga
                     use entity Work.WildFpga(Rtl)
                        generic map (
                           fabtech => 1,
                           memtech => 1,
                           padtech => 1,
                           clktech => 1,
                           netlist => 1);
                  end for;
               end for;
            end for;
            for U_Left_Mem: Memory_Bank
               use entity SYSTEM.Memory_Bank( Static )
                  generic map(MEM_SIZE => 2**19);
            end for;
            for U_Right_Mem: Memory_Bank
               use entity SYSTEM.Memory_Bank( Static )
                  generic map(MEM_SIZE => 2**19);
            end for;
         end for;
      end for;
   end for;
end configuration System_Config; --===========================================--