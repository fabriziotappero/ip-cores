-- $Id: rb_mon_sb.vhd 589 2014-08-30 12:43:16Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rb_mon_sb - sim
-- Description:    simbus wrapper for rbus monitor (for tb's)
--
-- Dependencies:   simbus
--                 simlib/simclkcnt
--                 rb_mon
-- Test bench:     -
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-28   588   4.0    use new rlink v4 iface and 4 bit STAT
-- 2011-12-23   444   3.1    use simclkcnt instead of simbus global
-- 2010-12-22   346   3.0    renamed rritb_rbmon_sb -> rb_mon_sb
-- 2010-06-05   301   2.0.2  renamed _rpmon -> _rbmon
-- 2010-05-02   287   2.0.1  rename RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
--                           use sbcntl_sbf_cpmon def
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-12-23   105   1.2    added AP_LAM display
-- 2007-11-24    98   1.1    added RP_IINT support
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rblib.all;

entity rb_mon_sb is                     -- simbus wrapper for rbus monitor
  generic (
    DBASE : positive :=  2;             -- base for writing data values
    ENAPIN : integer := sbcntl_sbf_rbmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );
end rb_mon_sb;


architecture sim of rb_mon_sb is

  signal ENA : slbit := '0';
  signal CLK_CYCLE : integer := 0;
  
begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  RBMON : rb_mon
    generic map (
      DBASE => DBASE)
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      ENA       => ENA,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES,
      RB_LAM    => RB_LAM,
      RB_STAT   => RB_STAT
    );
  
end sim;
