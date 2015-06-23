--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details. 
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
----------------------------------------------------------------------------------
--
--  Author:  Andreas Habegger
--  Date of creation: 8. April 2009
--  Description:
--   	Common definitions file for the GECKO3com IP core
--
--  Target Devices:	Xilinx Spartan3 FPGA's (usage of BlockRam in the Datapath)
--  Tool versions: 	11.1
--  Dependencies:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library XilinxCoreLib;


package GECKO3COM_defines is

 -- constants
  constant SIZE_DBUS_GPIF 	: INTEGER := 16;  -- SIZE in bit
  constant SIZE_DBUS_FPGA 	: INTEGER := 32;  -- SIZE in bit
  constant SETUP_TIME     	: INTEGER := 10;  -- setuptime for FIFO value between 0 and 15
  constant BYTE				: INTEGER := 8;
	 
  constant NUMBER_OF_SW		: INTEGER := 4;
  
  
 -- types  







end GECKO3COM_defines;
