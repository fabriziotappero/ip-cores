-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------
-- File        hibiv2_pkg.vhdl
-- Design
-- Description Package for  Hibi2 wrapper, its sub-blocks, and hibiv2_top_level
-- 
--              This pkg should not be edited when system changes.
--              Make necessary changes in system_pkg, not here.
--              
-- Author :   	Erno salminen
-- e-mail       : erno.salminen@tut.fi
-- Date :   	01.08.2003
-- Project :	in the jungle

-- Modified :
-- 04.08.03     ES Name changed HIBIPackage -> hibiv2_package
-- 18.09.03     ES Major changes in pkg usage
--                 hibi_pkg now uses system_pkg, not other way round anymore
--
-- 07.11.03     ES stuff moved to hibiv2_array_pkg, use of system_pkg removed
-- 10.11.03     ES name changed package -> pkg
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


package hibiv2_pkg is          
  -----------------------------------------------------------------------------
  -- Do not edit below this point
  -----------------------------------------------------------------------------
  
  -- Commands
  constant comm_width_c        : integer := 3;   -- width of the command bus

  constant idle_c            : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 0, comm_width_c);
  constant w_cfg_c           : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 1, comm_width_c);
  constant w_data_c          : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 2, comm_width_c);
  constant w_msg_c           : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 3, comm_width_c);

  constant r_data_c         : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 4, comm_width_c);
  constant r_cfg_c          : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 5, comm_width_c);
  constant multicast_data_c : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 6, comm_width_c);
  constant multicast_msg_c  : std_logic_vector ( comm_width_c-1 downto 0) := conv_std_logic_vector ( 7, comm_width_c);



  
end hibiv2_pkg;  

 

