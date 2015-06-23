-- $Id: rb_mon.vhd 599 2014-10-25 13:43:56Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rb_mon - sim
-- Description:    rbus monitor (for tb's)
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-25   599   4.1.1  use writeoptint()
-- 2014-09-03   591   4.1    add burst counter; add state checker
-- 2014-08-30   589   4.0    use hex for addr; 4 bit STAT; monitor ACK=0
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-12-23   444   3.1    CLK_CYCLE now integer
-- 2011-11-19   427   3.0.1  now numeric_std clean
-- 2010-12-22   346   3.0    renamed rritb_rbmon -> rb_mon
-- 2010-06-05   301   2.1.1  renamed _rpmon -> _rbmon
-- 2010-06-03   299   2.1    new init encoding (WE=0/1 int/ext)
-- 2010-05-02   287   2.0.1  rename RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.2.1  CLK_CYCLE now 31 bits
-- 2007-12-23   105   1.2    added AP_LAM display
-- 2007-11-24    98   1.1    added RP_IINT support
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.rblib.all;

entity rb_mon is                        -- rbus monitor (for tb's)
  generic (
    DBASE : positive :=  2);            -- base for writing data values
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in integer := 0;        -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );
end rb_mon;


architecture sim of rb_mon is
  
begin

  proc_moni: process
    variable oline : line;
    variable nhold  : integer := 0;
    variable nburst : integer := 0;
    variable data : slv16 := (others=>'0');
    variable tag : string(1 to 8) := (others=>' ');
    variable err : slbit := '0';
    variable r_sel : slbit := '0';

    procedure write_data(L: inout line;
                         tag: in string;
                         data: in slv16;
                         nhold:  in integer := 0;
                         nburst: in integer := 0;
                         cond: in boolean := false;
                         ctxt: in string := " ") is
    begin
      writetimestamp(L, CLK_CYCLE, tag);
      writehex(L, RB_MREQ.addr, right, 4);
      write(L, string'("  "));
      writegen(L, data, right, 0, DBASE);
      write(L, string'("  "));
      write(L, RB_STAT, right, 4);
      writeoptint(L, "  hold=", nhold,  2);
      writeoptint(L, "  b=",    nburst, 2);
      if cond then
        write(L, ctxt);
      end if;
      writeline(output, L);
    end procedure write_data;

  begin
    
    loop 

      if ENA = '0' then                 -- if disabled
        wait until ENA='1';             -- stall process till enabled
      end if;

      wait until rising_edge(CLK);      -- check at end of clock cycle

      if RB_MREQ.aval='1' and r_sel='0' then
        nburst := 0;
      end if;

      if RB_MREQ.re='1' or RB_MREQ.we='1' then
        if RB_SRES.err = '1' then
          err := '1';
        end if;
        if RB_SRES.busy = '1' then
          nhold := nhold + 1;
        else
          data := (others=>'0');
          tag  := ": ????  ";
          if RB_MREQ.re = '1' then
            data := RB_SRES.dout;
            tag  :=  ": rbre  ";
          end if;
          if RB_MREQ.we = '1' then
            data := RB_MREQ.din;
            tag  :=  ": rbwe  ";
          end if;

          if RB_SRES.ack = '1' then
            write_data(oline, tag, data, nhold, nburst, err='1', "  ERR='1'");
          else
            write_data(oline, tag, data, nhold, nburst, true,    "  ACK='0'");
          end if;
          nburst := nburst + 1;
          nhold := 0;
        end if;
        
      else
        if nhold > 0 then
          write_data(oline, tag, data, nhold, nburst, true, "  TIMEOUT");
        end if;
        nhold := 0;
        err := '0';
      end if;

      if RB_MREQ.init = '1' then                     -- init
        write_data(oline, ": rbini ", RB_MREQ.din);
      end if;

      if unsigned(RB_LAM) /= 0 then
        write_data(oline, ": rblam ", RB_LAM, 0, 0, true, "  RB_LAM active");
      end if;

      r_sel := RB_MREQ.aval;

    end loop;
  end process proc_moni;

  proc_check: process (CLK)
    variable r_sel  : slbit := '0';
    variable r_addr : slv16 := (others=>'0');
    variable idump  : boolean := false;
    variable oline : line;
  begin

    if rising_edge(CLK) then
      idump := false;
      
      -- check that addr doesn't change after 1st aval cycle
      if r_sel='1' and RB_MREQ.addr /= r_addr then
        writetimestamp(oline, CLK_CYCLE,
          ": FAIL rb_mon: addr changed after aval; initial addr=");
        writehex(oline, r_addr, right, 4);
        writeline(output, oline);
        idump := true;
      end if;

      -- check that we,re don't come together in core select time
      --   (aval and r_sel) and not at all outside
      if RB_MREQ.aval='1' and r_sel='1' then
        if RB_MREQ.we='1' and RB_MREQ.re='1' then
          writetimestamp(oline, CLK_CYCLE,
            ": FAIL rb_mon: we and re both active");
          writeline(output, oline);
          idump := true;
        end if;
        if RB_MREQ.init='1' then
          writetimestamp(oline, CLK_CYCLE,
            ": FAIL rb_mon: init seen inside select");
          writeline(output, oline);
          idump := true;          
        end if;
      else
        if RB_MREQ.we='1' or RB_MREQ.re='1' then
          writetimestamp(oline, CLK_CYCLE,
            ": FAIL rb_mon: no select and we,re seen");
          writeline(output, oline);
          idump := true;
        end if;
      end if;
      
      -- check that init not seen when aval or select is active
      if RB_MREQ.aval='1' or r_sel='1' then
        if RB_MREQ.init='1' then
          writetimestamp(oline, CLK_CYCLE,
            ": FAIL rb_mon: init seen inside aval or select");
          writeline(output, oline);
          idump := true;          
        end if;
      end if;

      -- check that SRES isn't touched unless aval or select is active
      if RB_MREQ.aval='0' and r_sel='0' then
        if RB_SRES.dout/=x"0000" or RB_SRES.busy='1' or
           RB_SRES.ack='1' or RB_SRES.err='1' then
          writetimestamp(oline, CLK_CYCLE,
            ": FAIL rb_mon: SRES driven outside aval or select");
          writeline(output, oline);
          idump := true;
        end if;
      end if;

      -- dump rbus state in case of any error seen above
      if idump then
        write(oline, string'("   FAIL: MREQ aval="));
        write(oline, RB_MREQ.aval, right, 1);
        write(oline, string'(" re="));
        write(oline, RB_MREQ.re  , right, 1);
        write(oline, string'(" we="));
        write(oline, RB_MREQ.we  , right, 1);
        write(oline, string'(" init="));
        write(oline, RB_MREQ.init, right, 1);
        write(oline, string'(" sel="));
        write(oline, r_sel       , right, 1);
        write(oline, string'(" addr="));
        writehex(oline, RB_MREQ.addr, right, 4);
        write(oline, string'(" din="));
        writehex(oline, RB_MREQ.din,  right, 4);
        writeline(output, oline);
        
        write(oline, string'("   FAIL: SRES ack="));
        write(oline, RB_SRES.ack , right, 1);
        write(oline, string'(" busy="));
        write(oline, RB_SRES.busy, right, 1);
        write(oline, string'(" err="));
        write(oline, RB_SRES.err , right, 1);
        write(oline, string'(" dout="));
        writehex(oline, RB_SRES.dout, right, 4);
        writeline(output, oline);
      end if;

      -- keep track of select state and latch current addr
      if RB_MREQ.aval='1' and r_sel='0' then  -- if 1st cycle of aval
        r_addr := RB_MREQ.addr;                     -- latch addr
      end if;
      -- select simply aval if last cycle (assume all addr are valid)
      r_sel := RB_MREQ.aval;
    end if;
    
  end process proc_check;
  
end sim;
