-- $Id: sys_conf1_sim.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   sys_conf
-- Description:    Definitions for sys_tst_serloop1_n2 (for test bench)
--
-- Dependencies:   -
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-16   439   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- in simulation a usec is shortened to 10 cycles (0.2 usec) and a msec
  -- to 50 cycles (1 usec). This affects the pulse generators (usec) and
  -- mainly the autobauder. A break will be detected after 128 msec periods,
  -- this in simulation after 128 usec or 6400 cycles. This is compatible with
  -- bitrates of 115200 baud or higher (115200 <-> 8.68 usec <-> 521 cycles)
  
  constant sys_conf_clkdiv_usecdiv : integer :=   10; -- default usec 
  constant sys_conf_clkdiv_msecdiv : integer :=    5; -- shortened !
  constant sys_conf_hio_debounce : boolean := false;  -- no debouncers
  constant sys_conf_uart_cdinit : integer := 1-1;     -- 1 cycle/bit in sim
  
end package sys_conf;
