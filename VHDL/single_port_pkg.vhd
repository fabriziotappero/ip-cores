----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous RAM simulation model                ----
----                                                              ----
---- This file is part of the single_port project                 ----
----                                                              ----
---- Description                                                  ----
---- Package file for single_port memory and testbench            ----
----                                                              ----
---- Authors:                                                     ----
---- - Robert Paley, rpaley_yid@yahoo.com                         ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
---- References:                                                  ----
----   1. The Designer's Guide to VHDL by Peter Ashenden          ----
----      ISBN: 1-55860-270-4 (pbk.)                              ----
----   2. Writing Testbenches - Functional Verification of HDL    ----
----      models by Janick Bergeron | ISBN: 0-7923-7766-4         ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2005/10/25 18:26:52  mgeng
-- PAGENUM constant removed because the address bus width provides this information
--
-- Revision 1.2  2005/10/12 19:39:27  mgeng
-- Buses unconstrained, LGPL header added
--
-- Revision 1.1.1.1  2003/01/14 21:48:11  rpaley_yid
-- initial checkin 
--
-- Revision 1.1  2003/01/14 17:48:44  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 17:58:49  Default
-- Initial revision
--
LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.NUMERIC_STD.ALL;

PACKAGE single_port_pkg IS 
  -- Address bus type for internal memory
  SUBTYPE addr_typ IS NATURAL;
  -- Operations testbench can do.
  TYPE do_typ IS ( init , read , write , dealloc , end_test );

  TYPE to_srv_typ IS RECORD -- Record passed from test case to test bench
    do    : do_typ;
    addr  : INTEGER;
    data  : INTEGER;
    event : BOOLEAN;
  END RECORD to_srv_typ;
END PACKAGE single_port_pkg;

PACKAGE BODY single_port_pkg IS
END PACKAGE BODY single_port_pkg;
