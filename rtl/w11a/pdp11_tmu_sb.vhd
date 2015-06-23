-- $Id: pdp11_tmu_sb.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2009- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_tmu - sim
-- Description:    pdp11: trace and monitor unit; simbus wrapper
--
-- Dependencies:   simbus
-- Test bench:     -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2009-05-10   214   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.pdp11.all;

entity pdp11_tmu_sb is                  -- trace and mon. unit; simbus wrapper
  generic (
    ENAPIN : integer := 13);            -- SB_CNTL signal to use for enable
  port (
    CLK : in slbit;                     -- clock
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    DM_STAT_SY : in dm_stat_sy_type     -- debug and monitor status - system
  );
end pdp11_tmu_sb;


architecture sim of pdp11_tmu_sb is

  signal ENA : slbit := '0';
  
begin

  assert ENAPIN>=SB_CNTL'low and ENAPIN<=SB_CNTL'high
    report "assert(ENAPIN in SB_CNTL'range)" severity failure;

  ENA <= to_x01(SB_CNTL(ENAPIN));
  
  CPMON : pdp11_tmu
    port map (
      CLK        => CLK,
      ENA        => ENA,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
  
end sim;
