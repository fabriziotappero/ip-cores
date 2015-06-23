-- $Id: rbd_timer.vhd 593 2014-09-14 22:21:33Z mueller $
--
-- Copyright 2010-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rbd_timer - syn
-- Description:    rbus dev: usec precision timer
--
-- Dependencies:   -
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-29   351 12.1    M53d xc3s1000-4    19   63    -   34 s  7.6
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-15   583   4.0    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.0.1  now numeric_std clean
-- 2010-12-29   351   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--    0         time        r/w/-  Timer register
--                                 w: if > 0 timer is running
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

entity rbd_timer is                     -- rbus dev: usec precision timer
  generic (
    RB_ADDR : slv16 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DONE : out slbit;                   -- 1 cycle pulse when expired
    BUSY : out slbit                    -- timer running
  );
end entity rbd_timer;


architecture syn of rbd_timer is

  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    timer : slv16;                      -- timer value
    timer_act : slbit;                  -- timer active flag
    timer_end : slbit;                  -- timer done flag
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    (others=>'0'),                      -- timer
    '0','0'                             -- timer_act,timer_end
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_USEC, RB_MREQ)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_dout := (others=>'0');
            
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr=RB_ADDR then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := RB_MREQ.re or RB_MREQ.we;

      if RB_MREQ.we = '1' then 
        n.timer     := RB_MREQ.din;
        n.timer_act := '1';
      end if;
      if RB_MREQ.re = '1' then
        irb_dout := r.timer;
      end if;
    end if;

    -- timer logic
    --   count down when active and 'on-the-usec'
    n.timer_end := '0';                 -- ensure end is 1 cycle pulse
    if CE_USEC = '1' then               -- if at usec
      if r.timer_act = '1' then           -- if timer active 
        if unsigned(r.timer) = 0 then       -- if timer at end
          n.timer_act := '0';               -- mark unactive
          n.timer_end := '1';               -- send end marker
        else                              -- else: timer not at end
          n.timer := slv(unsigned(r.timer) - 1);  -- decrement
        end if;
      end if;
    end if;
    
    N_REGS <= n;

    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= '0';
    RB_SRES.busy <= '0';

    DONE <= r.timer_end;
    BUSY <= r.timer_act;

  end process proc_next;

end syn;
