-- $Id: simbus.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Package Name:   simbus
-- Description:    Global signals for support control in test benches
--
-- Dependencies:   -
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   2.0    remove global clock cycle signal
-- 2010-04-24   282   1.1    add SB_(VAL|ADDR|DATA)
-- 2008-03-24   129   1.0.1  use 31 bits for SB_CLKCYCLE
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package simbus is
  
  signal SB_CLKSTOP : slbit := '0';             -- global clock stop
  signal SB_CNTL : slv16 := (others=>'0');      -- global signals tb -> uut
  signal SB_STAT : slv16 := (others=>'0');      -- global signals uut -> tb
  signal SB_VAL : slbit := '0';                 -- init bcast valid
  signal SB_ADDR : slv8 := (others=>'0');       -- init bcast address
  signal SB_DATA : slv16 := (others=>'0');      -- init bcast data

  -- Note: SB_CNTL, SB_VAL, SB_ADDR, SB_DATA can have weak ('L','H') and
  --       strong ('0','1') drivers. Therefore always remove strenght before
  --       using, e.g. with to_x01()
  
end package simbus;
