-- $Id: tbd_rlink_direct.vhd 594 2014-09-21 12:29:33Z mueller $
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
-- Module Name:    tbd_rlink_direct - syn
-- Description:    Wrapper for rlink_core to avoid records. It has a port
--                 interface which will not be modified by xst synthesis
--                 (no records, no generic port).
--
-- Dependencies:   rlink_core
--                 rbus/rb_mon
--                 rlink/rlink_mon
--
-- To test:        rlink_core
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2007-11-24    92  8.1.03 I27  xc3s1000-4   143  309    0  166 s 7.64
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4   148  320    0    - t 8.34
-- 2007-10-27    92  9.1    J30  xc3s1000-4   148  315    0    - t 8.34
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4   153  302    0  162 s 7.65
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4   138  306    0    - s 7.64
--
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-19   594   4.0    now rlink v4.0 iface, 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2010-12-25   348   3.0.2  drop RL_FLUSH, add RL_MONI for rlink_core
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-05   343   3.0    rri->rlink renames; port to rbus V3 protocol;
-- 2010-05-02   287   2.2.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.2    add CP_FLUSH for rri_core, add CE_USEC
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-11-25    98   1.1    added RP_IINT support; use entity rather arch
--                           name to switch core/serport
-- 2007-07-02    63   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;

entity tbd_rlink_direct is              -- rlink_core only tb design
                                        -- generic: ATOWIDTH=5; ITOWIDTH=6
                                        -- implements tbd_rlink_gen
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : out slbit;                -- rlink: data busy
    RL_DO : out slv9;                   -- rlink: data out
    RL_VAL : out slbit;                 -- rlink: data valid
    RL_HOLD : in slbit;                 -- rlink: data hold
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv16;           -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end entity tbd_rlink_direct;


architecture syn of tbd_rlink_direct is

  signal RL_MONI : rl_moni_type := rl_moni_init;
  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;

begin

  RB_MREQ_aval <= RB_MREQ.aval;
  RB_MREQ_re   <= RB_MREQ.re;
  RB_MREQ_we   <= RB_MREQ.we;
  RB_MREQ_initt<= RB_MREQ.init;
  RB_MREQ_addr <= RB_MREQ.addr;
  RB_MREQ_din  <= RB_MREQ.din;

  RB_SRES.ack  <= RB_SRES_ack;
  RB_SRES.busy <= RB_SRES_busy;
  RB_SRES.err  <= RB_SRES_err;
  RB_SRES.dout <= RB_SRES_dout;

  UUT : rlink_core
    generic map (
      BTOWIDTH =>  5,
      RTAWIDTH =>  11,
      SYSID    => x"76543210",
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon)
    port map (
      CLK      => CLK,
      CE_INT   => CE_INT,
      RESET    => RESET,
      RL_DI    => RL_DI,
      RL_ENA   => RL_ENA,
      RL_BUSY  => RL_BUSY,
      RL_DO    => RL_DO,
      RL_VAL   => RL_VAL,
      RL_HOLD  => RL_HOLD,
      RL_MONI  => RL_MONI,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );

  TXRXACT <= '0';
    
end syn;
