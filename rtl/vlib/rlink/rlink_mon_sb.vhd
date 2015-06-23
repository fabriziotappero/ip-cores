-- $Id: rlink_mon_sb.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    rlink_mon_sb - sim
-- Description:    simbus wrapper for rlink monitor
--
-- Dependencies:   simbus
--                 simlib/simclkcnt
--                 rlink_mon
-- Test bench:     -
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   3.1    use simclkcnt instead of simbus global
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-22   346   3.0    renamed rritb_cpmon_sb -> rlink_mon_sb
-- 2010-05-02   287   1.0.1  use sbcntl_sbf_cpmon def
-- 2007-08-25    75   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rlinklib.all;

entity rlink_mon_sb is                  -- simbus wrap for rlink monitor
  generic (
    DWIDTH : positive :=  9;            -- data port width (8 or 9)
    ENAPIN : integer := sbcntl_sbf_rlmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RL_DI : in slv(DWIDTH-1 downto 0);  -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv(DWIDTH-1 downto 0);  -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : in slbit                  -- rlink: data hold
  );
end rlink_mon_sb;


architecture sim of rlink_mon_sb is

  signal ENA : slbit := '0';
  signal CLK_CYCLE : integer := 0;

begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  CPMON : rlink_mon
    generic map (
      DWIDTH => DWIDTH)
    port map (
      CLK       => CLK,
      CLK_CYCLE => CLK_CYCLE,
      ENA       => ENA,
      RL_DI     => RL_DI,
      RL_ENA    => RL_ENA,
      RL_BUSY   => RL_BUSY,
      RL_DO     => RL_DO,
      RL_VAL    => RL_VAL,
      RL_HOLD   => RL_HOLD
    );
  
end sim;
