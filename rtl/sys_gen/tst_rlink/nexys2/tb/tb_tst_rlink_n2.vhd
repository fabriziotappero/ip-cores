-- $Id: tb_tst_rlink_n2.vhd 437 2011-12-09 19:38:07Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_tst_rlink_n2
-- Description:    Configuration for tb_tst_rlink_n2 for tb_nexys2_fusp
--
-- Dependencies:   sys_tst_rlink_n2
--
-- To test:        sys_tst_rlink_n2
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-12-xx   xxx  -     0.29  12.1   M53d  xc3s1200e  u:???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-29   351   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_n2 of tb_nexys2_fusp is

  for sim
    for all : nexys2_fusp_aif
      use entity work.sys_tst_rlink_n2;
    end for;
  end for;

end tb_tst_rlink_n2;
