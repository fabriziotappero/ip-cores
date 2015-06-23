-- $Id: sys_conf.vhd 683 2015-05-17 21:54:35Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Description:    Definitions for sys_w11a_s3 (for synthesis)
--
-- Dependencies:   -
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-03-14   658   1.2    add sys_conf_ibd_* definitions
-- 2014-12-22   619   1.1.2  add _rbmon_awidth
-- 2010-05-05   288   1.1.1  add sys_conf_hio_debounce
-- 2008-02-23   118   1.1    add memory config
-- 2007-09-23    84   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package sys_conf is

  -- configure rlink and hio interfaces --------------------------------------
  constant sys_conf_ser2rri_cdinit : integer := 434-1;   -- 50000000/115200
  constant sys_conf_hio_debounce : boolean := true;    -- instantiate debouncers

  -- configure debug and monitoring units ------------------------------------
  constant sys_conf_rbmon_awidth : integer := 9; -- use 0 to disable rbmon
  constant sys_conf_ibmon_awidth : integer := 9; -- use 0 to disable ibmon

  -- configure w11 cpu core --------------------------------------------------
  constant sys_conf_mem_losize     : integer := 8#037777#; --   1 MByte
  
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

end package sys_conf;
