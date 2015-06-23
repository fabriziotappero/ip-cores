-- $Id: tb_tst_rlink_n3.vhd 435 2011-12-04 20:15:25Z mueller $
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
-- Module Name:    tb_tst_rlink_n3
-- Description:    Configuration for tb_tst_rlink_n3 for tb_nexys3_fusp
--
-- Dependencies:   sys_tst_rlink_n3
--
-- To test:        sys_tst_rlink_n3
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-11-xx   xxx  -     0.29  13.1   O40d  xc6slx16-2 u:???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_n3 of tb_nexys3_fusp is

  for sim
    for all : nexys3_fusp_aif
      use entity work.sys_tst_rlink_n3;
    end for;
  end for;

end tb_tst_rlink_n3;
