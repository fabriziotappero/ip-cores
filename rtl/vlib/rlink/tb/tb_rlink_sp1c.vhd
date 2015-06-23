-- $Id: tb_rlink_sp1c.vhd 442 2011-12-23 10:03:28Z mueller $
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
-- Module Name:    tb_rlink_sp1c
-- Description:    Configuration for tb_rlink_sp1c for tb_rlink.
--
-- Dependencies:   tbd_rlink_gen
--
-- To test:        rlink_sp1c
--
-- Target Devices: generic
--
-- Verified (with tb_rlink_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-10-12    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok (Test 15 fails)
-- 2007-10-12    88  -     0.26  -            -          c:ok (Test 15 fails)
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-22   442   3.2    renamed and retargeted to tbd_rlink_sp1c
-- 2010-12-05   343   3.0    rri->rlink renames
-- 2007-11-25    98   1.0.1  use entity rather arch name to switch core/serport
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_rlink_sp1c of tb_rlink is

  for sim
    for all : tbd_rlink_gen
      use entity work.tbd_rlink_sp1c;
    end for;
  end for;

end tb_rlink_sp1c;
