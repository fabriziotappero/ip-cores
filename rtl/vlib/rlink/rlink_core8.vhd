-- $Id: rlink_core8.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_core8 - syn
-- Description:    rlink core with 8bit interface (core+b2c/c2b+rlmon+rbmon)
--
-- Dependencies:   rlink_core
--                 comlib/byte2cdata
--                 comlib/cdata2byte
--                 rlink_mon_sb    [sim only, for 8bit level]
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-12-05   596 14.7  131013 xc6slx16-2   352  492   24  176 s  7.0 ver 4.0
-- 2011-12-09   437 13.1    O40d xc3s1000-4   184  403    0  244 s  9.1
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   4.1    add ESCXON,ESCFILL in signals, for cdata2byte
-- 2014-10-12   596   4.0    now rlink v4 iface, 4 bit STAT
-- 2011-12-09   437   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_core8 is                   -- rlink core with 8bit interface
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive :=  12;         -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RLBMON: integer := -1;       -- SB_CNTL for rlbmon (-1=none)
    ENAPIN_RBMON : integer := -1);      -- SB_CNTL for rbmon  (-1=none)
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rlink ato time unit clock enable
    RESET  : in slbit;                  -- reset
    ESCXON : in slbit;                  -- enable xon/xoff escaping
    ESCFILL : in slbit;                 -- enable fill escaping
    RLB_DI : in slv8;                   -- rlink 8b: data in
    RLB_ENA : in slbit;                 -- rlink 8b: data enable
    RLB_BUSY : out slbit;               -- rlink 8b: data busy
    RLB_DO : out slv8;                  -- rlink 8b: data out
    RLB_VAL : out slbit;                -- rlink 8b: data valid
    RLB_HOLD : in slbit;                -- rlink 8b: data hold
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );
end entity rlink_core8;  


architecture syn of rlink_core8 is

  signal RL_DI   : slv9 := (others=>'0');
  signal RL_ENA  : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO   : slv9 := (others=>'0');
  signal RL_VAL  : slbit := '0';
  signal RL_HOLD : slbit := '0';
  signal RLB_BUSY_L : slbit := '0';
  signal RLB_DO_L   : slv8  := (others=>'0');
  signal RLB_VAL_L  : slbit := '0';

begin

  RL : rlink_core
    generic map (
      BTOWIDTH => BTOWIDTH,
      RTAWIDTH => RTAWIDTH,
      SYSID    => SYSID,
      ENAPIN_RLMON => ENAPIN_RLMON,
      ENAPIN_RBMON => ENAPIN_RBMON)
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

-- RLB -> RL converter (DI handling) -------------
  B2CD : byte2cdata                     -- byte stream -> 9bit comma,data
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RLB_DI,
      ENA   => RLB_ENA,
      ERR   => '0',
      BUSY  => RLB_BUSY_L,
      DO    => RL_DI,
      VAL   => RL_ENA,
      HOLD  => RL_BUSY
    );

-- RL -> RLB converter (DO handling) -------------
  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
    port map (
      CLK     => CLK,
      RESET   => RESET,
      ESCXON  => ESCXON,
      ESCFILL => ESCFILL,
      DI      => RL_DO,
      ENA     => RL_VAL,
      BUSY    => RL_HOLD,
      DO      => RLB_DO_L,
      VAL     => RLB_VAL_L,
      HOLD    => RLB_HOLD
    );

  RLB_BUSY <= RLB_BUSY_L;
  RLB_DO   <= RLB_DO_L;
  RLB_VAL  <= RLB_VAL_L;
  
-- synthesis translate_off

  RLBMON: if ENAPIN_RLBMON >= 0  generate
    MON : rlink_mon_sb
      generic map (
        DWIDTH => RLB_DI'length,
        ENAPIN => ENAPIN_RLBMON)
      port map (
        CLK     => CLK,
        RL_DI   => RLB_DI,
        RL_ENA  => RLB_ENA,
        RL_BUSY => RLB_BUSY_L,
        RL_DO   => RLB_DO_L,
        RL_VAL  => RLB_VAL_L,
        RL_HOLD => RLB_HOLD
      );
  end generate RLBMON;

-- synthesis translate_on

end syn;
