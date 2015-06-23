-- $Id: tb_nx_cram_memctl_as.vhd 433 2011-11-27 22:04:39Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_nx_cram_memctl_as
-- Description:    Configuration tb_nx_cram_memctl_as for tb_nx_cram_memctl
--
-- Dependencies:   tbd_nx_cram_memctl_as
-- To test:        nx_cram_memctl_as
--
-- Verified (with tb_nx_cram_memctl_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-05-30   297  -     0.26  11.4   L68   xc3s1200e  ok
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.1    renamed from tb_n2_cram_memctl_as
-- 2010-05-30   297   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_nx_cram_memctl_as of tb_nx_cram_memctl is

  for sim
    for all :tbd_nx_cram_memctl
      use entity work.tbd_nx_cram_memctl_as;
    end for;
  end for;

end tb_nx_cram_memctl_as;
