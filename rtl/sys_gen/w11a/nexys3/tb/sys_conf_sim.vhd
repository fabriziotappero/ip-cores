-- $Id: sys_conf_sim.vhd 683 2015-05-17 21:54:35Z mueller $
--
-- Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_n3 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-03-14   658   1.5    add sys_conf_ibd_* definitions
-- 2015-02-15   647   1.4    drop bram and minisys options
-- 2014-12-22   619   1.3.1  add _rbmon_awidth
-- 2013-10-06   538   1.3    pll support, use clksys_vcodivide ect
-- 2013-04-21   509   1.2    add fx2 settings
-- 2011-11-25   432   1.0    Initial version (cloned from _n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=  25;
  constant sys_conf_clksys_vcomultiply : positive :=  18;   -- dcm   72 MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys   72 MHz
  constant sys_conf_clksys_gentype     : string   := "DCM";

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  constant sys_conf_hio_debounce : boolean := false;   -- no debouncers

  -- fx2 settings: petowidth=10 -> 2^10 30 MHz clocks -> ~33 usec
  constant sys_conf_fx2_petowidth  : positive := 10;
  constant sys_conf_fx2_ccwidth  : positive := 5;
    
  -- configure memory controller ---------------------------------------------
  constant sys_conf_memctl_read0delay : positive := 4;   -- for <75 MHz
  constant sys_conf_memctl_read1delay : positive := sys_conf_memctl_read0delay;
  constant sys_conf_memctl_writedelay : positive := 5;

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth : integer := 9; -- use 0 to disable rbmon
  constant sys_conf_ibmon_awidth : integer := 9; -- use 0 to disable rbmon

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : integer := 8#167777#; --   4 MByte

  constant sys_conf_cache_fmiss    : slbit   := '0';     -- cache enabled

   -- configure w11 system devices --------------------------------------------
 -- configure character and communication devices
  constant sys_conf_ibd_dl11_1 : boolean := true;  -- 2nd DL11
  constant sys_conf_ibd_pc11   : boolean := true;  -- PC11
  constant sys_conf_ibd_lp11   : boolean := true;  -- LP11

  -- configure mass storage devices
  constant sys_conf_ibd_rk11   : boolean := true;  -- RK11
  constant sys_conf_ibd_rl11   : boolean := true;  -- RL11
  constant sys_conf_ibd_rhrp   : boolean := true;  -- RHRP
  constant sys_conf_ibd_tm11   : boolean := true;  -- TM11

  -- configure other devices
  constant sys_conf_ibd_iist   : boolean := true;  -- IIST

  -- derived constants =======================================================

  constant sys_conf_clksys : integer :=
    ((100000000/sys_conf_clksys_vcodivide)*sys_conf_clksys_vcomultiply) /
    sys_conf_clksys_outdivide;
  constant sys_conf_clksys_mhz : integer := sys_conf_clksys/1000000;

end package sys_conf;
