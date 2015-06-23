-- $Id: sys_conf_sim.vhd 683 2015-05-17 21:54:35Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_b3 (for simulation)
--
-- Dependencies:   -
-- Tool versions:  viv 2014.4; ghdl 0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-03-14   658   1.1    add sys_conf_ibd_* definitions
-- 2015-02-21   649   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure clocks --------------------------------------------------------
  constant sys_conf_clksys_vcodivide   : positive :=   1;
  constant sys_conf_clksys_vcomultiply : positive :=   1;   -- vco  --- MHz
  constant sys_conf_clksys_outdivide   : positive :=   1;   -- sys  100 MHz
  constant sys_conf_clksys_gentype     : string   := "MMCM";
  -- single clock design, clkser = clksys
  constant sys_conf_clkser_vcodivide   : positive := sys_conf_clksys_vcodivide;
  constant sys_conf_clkser_vcomultiply : positive := sys_conf_clksys_vcomultiply;
  constant sys_conf_clkser_outdivide   : positive := sys_conf_clksys_outdivide;
  constant sys_conf_clkser_gentype     : string   := sys_conf_clksys_gentype;

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 1-1;   -- 1 cycle/bit in sim
  constant sys_conf_hio_debounce : boolean := false;   -- no debouncers

  -- configure memory controller ---------------------------------------------
  constant sys_conf_memctl_mawidth : positive :=  4;
  constant sys_conf_memctl_nblock  : positive := 11;

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth : integer := 0; -- no rbmon to save BRAMs
  constant sys_conf_ibmon_awidth : integer := 0; -- no ibmon to save BRAMs

  -- configure w11 cpu core --------------------------------------------------
  -- sys_conf_mem_losize is highest 64 byte MMU block number
  -- the bram_memcnt uses 4*4kB memory blocks => 1 MEM block = 256 MMU blocks
  constant sys_conf_mem_losize     : integer := 256*sys_conf_memctl_nblock-1;
  
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

  constant sys_conf_clkser : integer :=
     ((100000000/sys_conf_clkser_vcodivide)*sys_conf_clkser_vcomultiply) /
    sys_conf_clkser_outdivide;
   constant sys_conf_clkser_mhz : integer := sys_conf_clkser/1000000;

end package sys_conf;
