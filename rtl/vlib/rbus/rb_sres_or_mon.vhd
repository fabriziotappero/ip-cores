-- $Id: rb_sres_or_mon.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    rb_sres_or_mon - sim
-- Description:    rbus result or monitor
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-23   347   3.0    rename rritb_sres_or_mon->rb_sres_or_mon
-- 2010-10-28   336   1.0.1  log errors only if now>0ns (drop startup glitches)
-- 2010-06-26   309   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity rb_sres_or_mon is                -- rbus result or monitor
  port (
    RB_SRES_1  :  in rb_sres_type;                 -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type;                 -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init  -- rb_sres input 4
  );
end rb_sres_or_mon;

architecture sim of rb_sres_or_mon is
  
begin

  proc_comb : process (RB_SRES_1, RB_SRES_2, RB_SRES_3, RB_SRES_4)
    constant dzero : slv16 := (others=>'0');
    variable oline : line;
    variable nack  : integer := 0;
    variable nbusy : integer := 0;
    variable nerr  : integer := 0;
    variable ndout : integer := 0;
  begin

    nack  := 0;
    nbusy := 0;
    nerr  := 0;
    ndout := 0;
    
    if RB_SRES_1.ack  /= '0' then nack  := nack  + 1;  end if;
    if RB_SRES_2.ack  /= '0' then nack  := nack  + 1;  end if;
    if RB_SRES_3.ack  /= '0' then nack  := nack  + 1;  end if;
    if RB_SRES_4.ack  /= '0' then nack  := nack  + 1;  end if;

    if RB_SRES_1.busy /= '0' then nbusy := nbusy + 1;  end if;
    if RB_SRES_2.busy /= '0' then nbusy := nbusy + 1;  end if;
    if RB_SRES_3.busy /= '0' then nbusy := nbusy + 1;  end if;
    if RB_SRES_4.busy /= '0' then nbusy := nbusy + 1;  end if;

    if RB_SRES_1.err  /= '0' then nerr  := nerr  + 1;  end if;
    if RB_SRES_2.err  /= '0' then nerr  := nerr  + 1;  end if;
    if RB_SRES_3.err  /= '0' then nerr  := nerr  + 1;  end if;
    if RB_SRES_4.err  /= '0' then nerr  := nerr  + 1;  end if;

    if RB_SRES_1.dout /= dzero then ndout := ndout + 1;  end if;
    if RB_SRES_2.dout /= dzero then ndout := ndout + 1;  end if;
    if RB_SRES_3.dout /= dzero then ndout := ndout + 1;  end if;
    if RB_SRES_4.dout /= dzero then ndout := ndout + 1;  end if;

    if now > 0 ns and (nack>1 or nbusy>1 or nerr>1 or ndout>1) then
      write(oline, now, right, 12);
      if nack > 1 then
        write(oline, string'(" #ack="));
        write(oline, nack);
      end if;
      if nbusy > 1 then
        write(oline, string'(" #busy="));
        write(oline, nbusy);
      end if;
      if nerr > 1 then
        write(oline, string'(" #err="));
        write(oline, nerr);
      end if;
      if ndout > 1 then
        write(oline, string'(" #dout="));
        write(oline, ndout);
      end if;
      write(oline, string'(" FAIL in "));
      write(oline, rb_sres_or_mon'path_name);
      writeline(output, oline);
    end if;
    
  end process proc_comb;
  
end sim;
