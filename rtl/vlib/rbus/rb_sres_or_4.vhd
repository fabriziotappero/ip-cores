-- $Id: rb_sres_or_4.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2008-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rb_sres_or_4 - syn
-- Description:    rbus result or, 4 input
--
-- Dependencies:   rb_sres_or_mon    [sim only]
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.114.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-04   343   1.1.1  use now rb_sres_or_mon
-- 2010-06-26   309   1.1    add rritb_sres_or_mon
-- 2008-08-22   161   1.0.1  renamed rri_rbres_ -> rb_sres_
-- 2008-01-20   113   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity rb_sres_or_4 is                  -- rbus result or, 4 input
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type := rb_sres_init; -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init; -- rb_sres input 4
    RB_SRES_OR : out rb_sres_type       -- rb_sres or'ed output
  );
end rb_sres_or_4;

architecture syn of rb_sres_or_4 is
  
begin

  proc_comb : process (RB_SRES_1, RB_SRES_2, RB_SRES_3, RB_SRES_4)
  begin

    RB_SRES_OR.ack  <= RB_SRES_1.ack or
                       RB_SRES_2.ack or
                       RB_SRES_3.ack or
                       RB_SRES_4.ack;
    RB_SRES_OR.busy <= RB_SRES_1.busy or
                       RB_SRES_2.busy or
                       RB_SRES_3.busy or
                       RB_SRES_4.busy;
    RB_SRES_OR.err  <= RB_SRES_1.err or
                       RB_SRES_2.err or
                       RB_SRES_3.err or
                       RB_SRES_4.err;
    RB_SRES_OR.dout <= RB_SRES_1.dout or
                       RB_SRES_2.dout or
                       RB_SRES_3.dout or
                       RB_SRES_4.dout;
    
  end process proc_comb;
  
-- synthesis translate_off
  ORMON : rb_sres_or_mon
    port map (
      RB_SRES_1 => RB_SRES_1,
      RB_SRES_2 => RB_SRES_2,
      RB_SRES_3 => RB_SRES_3,
      RB_SRES_4 => RB_SRES_4
    );
-- synthesis translate_on

end syn;
