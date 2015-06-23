-- $Id: tb_tst_rlink_s3.vhd 442 2011-12-23 10:03:28Z mueller $
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
-- Module Name:    tb_tst_rlink_s3
-- Description:    Configuration for tb_tst_rlink_s3 for tb_s3board_fusp
--
-- Dependencies:   sys_tst_rlink_s3
--
-- To test:        sys_tst_rlink_s3
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-12-22   442  -     0.29  13.1   O40d  xc3s1000   u:ok 
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-22   442   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_s3 of tb_s3board_fusp is

  for sim
    for all : s3board_fusp_aif
      use entity work.sys_tst_rlink_s3;
    end for;
  end for;

end tb_tst_rlink_s3;
