-- $Id: tb_w11a_n4.vhd 644 2015-02-08 22:56:54Z mueller $
--
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_w11a_n4
-- Description:    Configuration for tb_w11a_n4 for tb_nexys4_cram
--
-- Dependencies:   sys_w11a_n4
--
-- To test:        sys_w11a_n4
--
-- Verified (with (#1) ../../tb/tb_rritba_pdp11core_stim.dat
--                (#2) ../../tb/tb_pdp11_core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-11-25   295  -     -.--  -            -          -:-- 
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-06   643   1.1    use tb_nexys4_cram now
-- 2013-09-22   432   1.0    Initial version (cloned from _n3)
------------------------------------------------------------------------------

configuration tb_w11a_n4 of tb_nexys4_cram is

  for sim
    for all : nexys4_cram_aif
      use entity work.sys_w11a_n4;
    end for;
  end for;

end tb_w11a_n4;
