-- $Id: ib_sres_or_mon.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    ib_sres_or_mon - sim
-- Description:    ibus result or monitor
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-10-28   336   1.0.1  log errors only if now>0ns (drop startup glitches)
-- 2010-10-23   335   1.0    Initial version (derived from rritb_sres_or_mon)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------

entity ib_sres_or_mon is                -- ibus result or monitor
  port (
    IB_SRES_1  :  in ib_sres_type;                 -- ib_sres input 1
    IB_SRES_2  :  in ib_sres_type;                 -- ib_sres input 2
    IB_SRES_3  :  in ib_sres_type := ib_sres_init; -- ib_sres input 3
    IB_SRES_4  :  in ib_sres_type := ib_sres_init  -- ib_sres input 4
  );
end ib_sres_or_mon;

architecture sim of ib_sres_or_mon is
  
begin

  proc_comb : process (IB_SRES_1, IB_SRES_2, IB_SRES_3, IB_SRES_4)
    constant dzero : slv16 := (others=>'0');
    variable oline : line;
    variable nack  : integer := 0;
    variable nbusy : integer := 0;
    variable ndout : integer := 0;
  begin

    nack  := 0;
    nbusy := 0;
    ndout := 0;
    
    if IB_SRES_1.ack  /= '0' then nack  := nack  + 1;  end if;
    if IB_SRES_2.ack  /= '0' then nack  := nack  + 1;  end if;
    if IB_SRES_3.ack  /= '0' then nack  := nack  + 1;  end if;
    if IB_SRES_4.ack  /= '0' then nack  := nack  + 1;  end if;

    if IB_SRES_1.busy /= '0' then nbusy := nbusy + 1;  end if;
    if IB_SRES_2.busy /= '0' then nbusy := nbusy + 1;  end if;
    if IB_SRES_3.busy /= '0' then nbusy := nbusy + 1;  end if;
    if IB_SRES_4.busy /= '0' then nbusy := nbusy + 1;  end if;

    if IB_SRES_1.dout /= dzero then ndout := ndout + 1;  end if;
    if IB_SRES_2.dout /= dzero then ndout := ndout + 1;  end if;
    if IB_SRES_3.dout /= dzero then ndout := ndout + 1;  end if;
    if IB_SRES_4.dout /= dzero then ndout := ndout + 1;  end if;

    if now > 0 ns and (nack>1 or nbusy>1 or ndout>1) then
      write(oline, now, right, 12);
      if nack > 1 then
        write(oline, string'(" #ack="));
        write(oline, nack);
      end if;
      if nbusy > 1 then
        write(oline, string'(" #busy="));
        write(oline, nbusy);
      end if;
      if ndout > 1 then
        write(oline, string'(" #dout="));
        write(oline, ndout);
      end if;
      write(oline, string'(" FAIL in "));
      write(oline, ib_sres_or_mon'path_name);
      writeline(output, oline);
    end if;
    
  end process proc_comb;
  
end sim;
