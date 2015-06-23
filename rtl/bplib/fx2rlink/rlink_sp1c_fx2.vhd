-- $Id: rlink_sp1c_fx2.vhd 672 2015-05-02 21:58:28Z mueller $
--
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_sp1c_fx2 - syn
-- Description:    rlink_core8 + serport_1clock + fx2 combo
--
-- Dependencies:   rlinklib/rlink_core8
--                 serport/serport_1clock
--                 rlinklib/rlink_rlbmux
--                 fx2lib/fx2_2fifoctl_ic
--                 rbus/rbd_rbmon
--                 rbus/rb_sres_or_2
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2015-05-02   672 14.7  131013 xc6slx16-2   618  875   90  340 s  7.2   -   -
-- 2013-04-20   509 13.3    O76d xc3s1200e-4  441  903  128  637 s  8.7   -   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-02   672   1.3    add rbd_rbmon (optional via generics)
-- 2015-04-11   666   1.2    drop ENAESC, rearrange XON handling
-- 2014-08-28   588   1.1    use new rlink v4 iface generics and 4 bit STAT
-- 2013-04-20   509   1.0    Initial version (derived from rlink_sp1c)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.serportlib.all;
use work.fx2lib.all;

entity rlink_sp1c_fx2 is                -- rlink_core8+serport_1clk+fx2_ic combo
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive := 12;          -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    IFAWIDTH : natural :=  5;           -- ser input fifo addr width  (0=none)
    OFAWIDTH : natural :=  5;           -- ser output fifo addr width (0=none)
    PETOWIDTH : positive := 10;         -- fx2 packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- fx2 chunk counter width
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RLBMON: integer := -1;       -- SB_CNTL for rlbmon (-1=none)
    ENAPIN_RBMON : integer := -1;       -- SB_CNTL for rbmon  (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RBMON_AWIDTH : natural := 0;        -- rbmon: buffer size, (0=none)
    RBMON_RBADDR : slv16 := slv(to_unsigned(16#ffe8#,16))); -- rbmon: base addr
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ato time unit clock enable
    RESET  : in slbit;                  -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAFX2 : in slbit;                  -- enable fx2 usage
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    RLB_MONI : out rlb_moni_type;       -- rlink 8b: monitor port
    SER_MONI : out serport_moni_type;   -- ser: monitor port
    FX2_MONI : out fx2ctl_moni_type;    -- fx2: monitor port
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end entity rlink_sp1c_fx2;


architecture syn of rlink_sp1c_fx2 is

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';

  signal SER_RXDATA : slv8 := (others=>'0');
  signal SER_RXVAL  : slbit := '0';
  signal SER_RXHOLD : slbit := '0';
  signal SER_TXDATA : slv8 := (others=>'0');
  signal SER_TXENA  : slbit := '0';
  signal SER_TXBUSY : slbit := '0';

  signal FX2_RXDATA   : slv8 := (others=>'0');
  signal FX2_RXVAL    : slbit := '0';
  signal FX2_RXHOLD   : slbit := '0';
  signal FX2_RXAEMPTY : slbit := '0';
  signal FX2_TXDATA   : slv8 := (others=>'0');
  signal FX2_TXENA    : slbit := '0';
  signal FX2_TXBUSY   : slbit := '0';
  signal FX2_TXAFULL  : slbit := '0';

  signal RB_MREQ_M     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES_M     : rb_sres_type := rb_sres_init;
  signal RB_SRES_RBMON : rb_sres_type := rb_sres_init;

begin
  
  CORE : rlink_core8                    -- rlink master ----------------------
    generic map (
      BTOWIDTH     => BTOWIDTH,
      RTAWIDTH     => RTAWIDTH,
      SYSID        => SYSID,
      ENAPIN_RLMON => ENAPIN_RLMON,
      ENAPIN_RLBMON=> ENAPIN_RLBMON,
      ENAPIN_RBMON => ENAPIN_RBMON)
    port map (
      CLK        => CLK,
      CE_INT     => CE_INT,
      RESET      => RESET,
      ESCXON     => ENAXON,
      ESCFILL    => '0',                -- not used in FX2 enabled boards
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      RL_MONI    => RL_MONI,
      RB_MREQ    => RB_MREQ_M,
      RB_SRES    => RB_SRES_M,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );
  
  SERPORT : serport_1clock              -- serport interface -----------------
    generic map (
      CDWIDTH   => CDWIDTH,
      CDINIT    => CDINIT,
      RXFAWIDTH => IFAWIDTH,
      TXFAWIDTH => OFAWIDTH)
    port map (
      CLK      => CLK,
      CE_MSEC  => CE_MSEC,
      RESET    => RESET,
      ENAXON   => ENAXON,
      ENAESC   => '0',                  -- escaping now in rlink_core8
      RXDATA   => SER_RXDATA,
      RXVAL    => SER_RXVAL,
      RXHOLD   => SER_RXHOLD,
      TXDATA   => SER_TXDATA,
      TXENA    => SER_TXENA,
      TXBUSY   => SER_TXBUSY,
      MONI     => SER_MONI,
      RXSD     => RXSD,
      TXSD     => TXSD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );
  
  RLBMUX : rlink_rlbmux                 -- rlink control mux -----------------
    port map (
      SEL       => ENAFX2,
      RLB_DI    => RLB_DI,
      RLB_ENA   => RLB_ENA,
      RLB_BUSY  => RLB_BUSY,
      RLB_DO    => RLB_DO,
      RLB_VAL   => RLB_VAL,
      RLB_HOLD  => RLB_HOLD,
      P0_RXDATA => SER_RXDATA,
      P0_RXVAL  => SER_RXVAL,
      P0_RXHOLD => SER_RXHOLD,
      P0_TXDATA => SER_TXDATA,
      P0_TXENA  => SER_TXENA,
      P0_TXBUSY => SER_TXBUSY,
      P1_RXDATA => FX2_RXDATA,
      P1_RXVAL  => FX2_RXVAL,
      P1_RXHOLD => FX2_RXHOLD,
      P1_TXDATA => FX2_TXDATA,
      P1_TXENA  => FX2_TXENA,
      P1_TXBUSY => FX2_TXBUSY
    );

  RLB_MONI.rxval  <= RLB_VAL;
  RLB_MONI.rxhold <= RLB_HOLD;
  RLB_MONI.txena  <= RLB_ENA;
  RLB_MONI.txbusy <= RLB_BUSY;

  FX2CNTL : fx2_2fifoctl_ic             -- FX2 interface ---------------------
    generic map (
      RXFAWIDTH  => 5,
      TXFAWIDTH  => 5,
      PETOWIDTH  => PETOWIDTH,
      CCWIDTH    => CCWIDTH,
      RXAEMPTY_THRES => 1,
      TXAFULL_THRES  => 1)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RXDATA   => FX2_RXDATA,
      RXVAL    => FX2_RXVAL,
      RXHOLD   => FX2_RXHOLD,
      RXAEMPTY => FX2_RXAEMPTY,
      TXDATA   => FX2_TXDATA,
      TXENA    => FX2_TXENA,
      TXBUSY   => FX2_TXBUSY,
      TXAFULL  => FX2_TXAFULL,
      MONI           => FX2_MONI,
      I_FX2_IFCLK    => I_FX2_IFCLK,
      O_FX2_FIFO     => O_FX2_FIFO,
      I_FX2_FLAG     => I_FX2_FLAG,
      O_FX2_SLRD_N   => O_FX2_SLRD_N,
      O_FX2_SLWR_N   => O_FX2_SLWR_N,
      O_FX2_SLOE_N   => O_FX2_SLOE_N,
      O_FX2_PKTEND_N => O_FX2_PKTEND_N,
      IO_FX2_DATA    => IO_FX2_DATA
    );

  RBMON : if RBMON_AWIDTH > 0 generate  -- rbus monitor --------------
  begin
    I0 : rbd_rbmon
      generic map (
        RB_ADDR => RBMON_RBADDR,
        AWIDTH  => RBMON_AWIDTH)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        RB_MREQ     => RB_MREQ_M,
        RB_SRES     => RB_SRES_RBMON,
        RB_SRES_SUM => RB_SRES_M
      );
  end generate RBMON;

  RB_SRES_OR : rb_sres_or_2             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES,
      RB_SRES_2  => RB_SRES_RBMON,
      RB_SRES_OR => RB_SRES_M
    );

  RB_MREQ         <= RB_MREQ_M;         -- setup output signals
  
end syn;
