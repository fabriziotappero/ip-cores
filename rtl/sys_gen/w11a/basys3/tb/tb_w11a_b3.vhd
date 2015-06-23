-- $Id: tb_w11a_b3.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    tb_w11a_b3
-- Description:    Configuration for tb_w11a_b3 for tb_basys3
--
-- Dependencies:   sys_w11a_b3
--
-- To test:        sys_w11a_b3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-21   649   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_b3 of tb_basys3 is

  for sim
    for all : basys3_aif
      use entity work.sys_w11a_b3;
    end for;
  end for;

end tb_w11a_b3;
