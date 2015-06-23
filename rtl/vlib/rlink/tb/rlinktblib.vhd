-- $Id: rlinktblib.vhd 595 2014-09-28 08:47:45Z mueller $
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
-- Package Name:   rlinktblib
-- Description:    rlink test environment components
--
-- Dependencies:   -
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-28   588   4.0    now full rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-12-23   444   3.1    new clock iface for tbcore_rlink; drop .._dcm
-- 2010-12-29   351   3.0.1  add rbtba_aif;
-- 2010-12-24   347   3.0    rename rritblib->rlinktblib, CP_*->RL_*;
--                           many rri->rlink renames; drop rbus parts;
-- 2010-11-13   338   2.5.2  add rritb_core_dcm
-- 2010-06-26   309   2.5.1  add rritb_sres_or_mon
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-05   301   2.1.2  renamed _rpmon -> _rbmon
-- 2010-05-02   287   2.1.1  rename CE_XSEC->CE_INT,RP_STAT->RB_STAT
--                           drop RP_IINT signal from interfaces
--                           add sbcntl_sbf_(cp|rp)mon defs
-- 2010-04-24   282   2.1    add rritb_core
-- 2008-08-24   162   2.0    all with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.1.5  CLK_CYCLE now 31 bits
-- 2007-12-23   105   1.1.4  add AP_LAM  for rritb_rpmon(_sb)
-- 2007-11-24    98   1.1.3  add RP_IINT for rritb_rpmon(_sb)
-- 2007-09-01    78   1.1.2  add rricp_rp
-- 2007-08-25    75   1.1.1  add rritb_cpmon_sb, rritb_rpmon_sb
-- 2007-08-16    74   1.1    remove rritb_tt* component; some interface changes
-- 2007-08-03    71   1.0.2  use rrirp_acif; change generics for rritb_[cr]pmon
-- 2007-07-22    68   1.0.1  add rritb_cpmon rritb_rpmon monitors
-- 2007-07-15    66   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.rlinklib.all;

package rlinktblib is

type rlink_tba_cntl_type is record      -- rlink_tba control
  cmd : slv3;                           -- command code
  ena : slbit;                          -- command enable
  addr : slv16;                         -- address
  cnt : slv16;                          -- block size
  eop : slbit;                          -- end packet after current command
end record rlink_tba_cntl_type;

constant rlink_tba_cntl_init : rlink_tba_cntl_type := (
           (others=>'0'),               -- cmd
           '0',                         -- ena
           (others=>'0'),               -- addr
           (others=>'0'),               -- cnt
           '0');                        -- eop
           
type rlink_tba_stat_type is record      -- rlink_tba status
  busy : slbit;                         -- command busy
  ack : slbit;                          -- command acknowledge
  err : slbit;                          -- command error flag
  stat : slv8;                          -- status flags
  braddr : slv16;                       -- block read address  (for wblk)
  bre : slbit;                          -- block read enable   (for wblk)
  bwaddr : slv16;                       -- block write address (for rblk)
  bwe : slbit;                          -- block write enable  (for rblk)
  dcnt : slv16;                         -- block done count
  apend : slbit;                        -- attn pending (from stat)
  ano : slbit;                          -- attn notify seen
  apat : slv16;                         -- attn pattern
end record rlink_tba_stat_type;

constant rlink_tba_stat_init : rlink_tba_stat_type := (
           '0','0','0',                 -- busy, ack, err
           (others=>'0'),               -- stat
           (others=>'0'),               -- braddr
           '0',                         -- bre
           (others=>'0'),               -- bwaddr
           '0',                         -- bwe
           (others=>'0'),               -- dcnt
           '0','0',                     -- apend, ano
           (others=>'0')                -- apat
         );

component rlink_tba is                  -- rlink test bench adapter
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    CNTL : in rlink_tba_cntl_type;      -- control port
    DI : in slv16;                      -- input data
    STAT : out rlink_tba_stat_type;     -- status port
    DO : out slv16;                     -- output data
    RL_DI : out slv9;                   -- rlink: data in
    RL_ENA : out slbit;                 -- rlink: data enable
    RL_BUSY : in slbit;                 -- rlink: data busy
    RL_DO : in slv9;                    -- rlink: data out
    RL_VAL : in slbit;                  -- rlink: data valid
    RL_HOLD : out slbit                 -- rlink: data hold
  );
end component;

component rbtba_aif is                  -- rbus tba, abstract interface
                                        -- no generics, no records
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit := '0';           -- reset
    RB_MREQ_aval : in slbit;            -- rbus: request - aval
    RB_MREQ_re : in slbit;              -- rbus: request - re
    RB_MREQ_we : in slbit;              -- rbus: request - we
    RB_MREQ_initt : in slbit;           -- rbus: request - init; avoid name coll
    RB_MREQ_addr : in slv16;            -- rbus: request - addr
    RB_MREQ_din : in slv16;             -- rbus: request - din
    RB_SRES_ack : out slbit;            -- rbus: response - ack
    RB_SRES_busy : out slbit;           -- rbus: response - busy
    RB_SRES_err : out slbit;            -- rbus: response - err
    RB_SRES_dout : out slv16;           -- rbus: response - dout
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4                  -- rbus: status flags
  );
end component;

component tbcore_rlink is               -- core of vhpi_cext based test bench
  port (
    CLK : in slbit;                     -- control interface clock
    CLK_STOP : out slbit;               -- clock stop trigger
    RX_DATA : out slv8;                 -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end component;

-- FIXME after this point !!

component rricp_rp is                   -- rri comm->reg port aif forwarder
                                        -- implements rricp_aif, uses rrirp_aif
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit :='0';            -- reset
    RL_DI : in slv9;                    -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : out slbit;                -- rlink: data busy
    RL_DO : out slv9;                   -- rlink: data out
    RL_VAL : out slbit;                 -- rlink: data valid
    RL_HOLD : in slbit := '0'           -- rlink: data hold
  );
end component;

end package rlinktblib;
