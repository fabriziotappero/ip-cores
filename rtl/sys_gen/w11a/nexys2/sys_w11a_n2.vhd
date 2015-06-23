-- $Id: sys_w11a_n2.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2010-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_w11a_n2 - syn
-- Description:    w11a test design for nexys2
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/fx2rlink/rlink_sp1c_fx2
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 bplib/nxcramlib/nx_cram_memctl_as
--                 bplib/fx2rlink/ioleds_sp1c_fx2
--                 w11a/pdp11_hio70
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_sys_w11a_n2
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.26-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-06-04   686 14.7  131013 xc3s1200e-4 2311 6725  414 4198 ok: +TM11
-- 2015-05-14   680 14.7  131013 xc3s1200e-4 2232 6547  414 4083 ok: +RHRP
-- 2015-02-21   649 14.7  131013 xc3s1200e-4 1903 5512  382 3483 ok: +RL11
-- 2014-12-22   619 14.7  131013 xc3s1200e-4 1828 5131  366 3263 ok: +rbmon
-- 2014-12-20   614 14.7  131013 xc3s1200e-4 1714 4896  366 3125 ok: -RL11,rlv4
-- 2014-06-08   561 14.7  131013 xc3s1200e-4 1626 4821  360 3052 ok: +RL11
-- 2014-06-01   558 14.7  131013 xc3s1200e-4 1561 4597  334 2901 ok: 
-- 2013-04-20   509 13.3    O76d xc3s1200e-4 1541 4598  334 2889 ok: now + FX2 !
-- 2011-12-18   440 13.1    O40d xc3s1200e-4 1450 4439  270 2740 ok: LP+PC+DL+II
-- 2011-11-18   427 13.1    O40d xc3s1200e-4 1433 4374  242 2680 ok: LP+PC+DL+II
-- 2010-12-30   351 12.1    M53d xc3s1200e-4 1389 4368  242 2674 ok: LP+PC+DL+II
-- 2010-11-06   336 12.1    M53d xc3s1200e-4 1357 4304* 242 2618 ok: LP+PC+DL+II
-- 2010-10-24   335 12.1    M53d xc3s1200e-4 1357 4546  242 2618 ok: LP+PC+DL+II
-- 2010-10-17   333 12.1    M53d xc3s1200e-4 1350 4541  242 2617 ok: LP+PC+DL+II
-- 2010-10-16   332 12.1    M53d xc3s1200e-4 1338 4545  242 2629 ok: LP+PC+DL+II
-- 2010-06-27   310 12.1    M53d xc3s1200e-4 1337 4307  242 2630 ok: LP+PC+DL+II
-- 2010-06-26   309 11.4    L68  xc3s1200e-4 1318 4293  242 2612 ok: LP+PC+DL+II
-- 2010-06-18   306 12.1    M53d xc3s1200e-4 1319 4300  242 2624 ok: LP+PC+DL+II
-- "            306 11.4    L68  xc3s1200e-4 1319 4286  242 2618 ok: LP+PC+DL+II
-- "            306 10.1.02 K39  xc3s1200e-4 1309 4311  242 2665 ok: LP+PC+DL+II
-- "            306  9.2.02 J40  xc3s1200e-4 1316 4259  242 2656 ok: LP+PC+DL+II
-- "            306  9.1    J30  xc3s1200e-4 1311 4260  242 2643 ok: LP+PC+DL+II
-- "            306  8.2.03 I34  xc3s1200e-4 1371 4394  242 2765 ok: LP+PC+DL+II
-- 2010-06-13   305 11.4    L68  xc3s1200e-4 1318 4360  242 2629 ok: LP+PC+DL+II
-- 2010-06-12   304 11.4    L68  xc3s1200e-4 1323 4201  242 2574 ok: LP+PC+DL+II
-- 2010-06-03   300 11.4    L68  xc3s1200e-4 1318 4181  242 2572 ok: LP+PC+DL+II
-- 2010-06-03   299 11.4    L68  xc3s1200e-4 1250 4071  224 2489 ok: LP+PC+DL+II
-- 2010-05-26   296 11.4    L68  xc3s1200e-4 1284 4079  224 2492 ok: LP+PC+DL+II
--   Note: till 2010-10-24 lutm included 'route-thru', after only logic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-09   677   2.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   2.0    use pdp11_sys70 and pdp11_hio70
-- 2015-04-11   666   1.7.2  rearrange XON handling
-- 2015-02-21   649   1.7.1  use ioleds_sp1c,pdp11_(statleds,ledmux,dspmux)
-- 2015-02-15   647   1.7    drop bram and minisys options
-- 2014-12-24   620   1.6.2  relocate ibus window and hio rbus address
-- 2014-12-22   619   1.6.1  add rbus monitor rbd_rbmon
-- 2014-08-28   588   1.6    use new rlink v4 iface generics and 4 bit STAT
-- 2014-08-15   583   1.5    rb_mreq addr now 16 bit
-- 2013-04-20   509   1.4    added fx2 (cuff) support; ATOWIDTH=7
-- 2011-12-23   444   1.3    remove clksys output hack
-- 2011-12-18   440   1.2.7  use rlink_sp1c
-- 2011-11-26   433   1.2.6  use nx_cram_(dummy|memctl_as) now
-- 2011-11-23   432   1.2.5  update O_FLA_CE_N usage
-- 2011-11-19   427   1.2.4  now numeric_std clean
-- 2011-11-17   426   1.2.3  use dcm_sfs now
-- 2011-07-09   391   1.2.2  use now bp_rs232_2l4l_iob
-- 2011-07-08   390   1.2.1  use now sn_humanio
-- 2010-12-30   351   1.2    ported to rbv3
-- 2010-11-27   341   1.1.8  add DCM; new sys_conf consts for mem and clkdiv
-- 2010-11-13   338   1.1.7  add O_CLKSYS (for DCM derived system clock)
-- 2010-11-06   336   1.1.6  rename input pin CLK -> I_CLK50
-- 2010-10-23   335   1.1.5  rename RRI_LAM->RB_LAM;
-- 2010-06-26   309   1.1.4  use constants for rbus addresses (rbaddr_...)
--                           BUGFIX: resolve rbus address clash hio<->ibr
-- 2010-06-18   306   1.1.3  change proc_led sensitivity list to avoid xst warn;
--                           rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           remove pdp11_ibdr_rri
-- 2010-06-13   305   1.1.2  add CP_ADDR, wire up pdp11_core_rri->pdp11_core
-- 2010-06-12   304   1.1.1  re-do LED driver logic (show cpu modes or cpurust)
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2010-06-03   300   1.0.2  use default FAWIDTH for rri_core_serport
--                           use s3_humanio_rri
-- 2010-05-30   297   1.0.1  put MEM_ACT_(R|W) on LED 6,7
-- 2010-05-28   295   1.0    Initial version (derived from sys_w11a_s3)
------------------------------------------------------------------------------
--
-- w11a test design for nexys2
--    w11a + rlink + serport + cuff
--
-- Usage of Nexys 2 Switches, Buttons, LEDs:
--
--    SWI(7:6): no function (only connected to sn_humanio_rbus)
--       (5:4):  select DSP
--                 00 abclkdiv & abclkdiv_f
--                 01 PC
--                 10 DISPREG
--                 11 DR emulation
--       (3):    select LED display
--                 0 overall status
--                 1 DR emulation
--       (2)    0 -> int/ext RS242 port for rlink
--              1 -> use USB interface for rlink
--       (1):   1 enable XON
--       (0):   0 -> main board RS232 port
--              1 -> Pmod B/top RS232 port
--
--    LEDs if SWI(3) = 1
--      (7:0)    DR emulation; shows R0(lower 8 bits) during wait like 11/45+70
--
--    LEDs if SWI(3) = 0
--        (7)    MEM_ACT_W
--        (6)    MEM_ACT_R
--        (5)    cmdbusy (all rlink access, mostly rdma)
--      (4:0)    if cpugo=1 show cpu mode activity
--                  (4) kernel mode, pri>0
--                  (3) kernel mode, pri=0
--                  (2) kernel mode, wait
--                  (1) supervisor mode
--                  (0) user mode
--              if cpugo=0 shows cpurust
--                  (4) '1'
--                (3:0) cpurust code
--
--    DP(3:0) shows IO activity
--            if SWI(2)=0 (serport)
--                  (3):    not SER_MONI.txok       (shows tx back preasure)
--                  (2):    SER_MONI.txact          (shows tx activity)
--                  (1):    not SER_MONI.rxok       (shows rx back preasure)
--                  (0):    SER_MONI.rxact          (shows rx activity)
--            if SWI(2)=1 (fx2-usb)
--                  (3):    RB_SRES.busy            (shows rbus back preasure)
--                  (2):    RLB_TXBUSY              (shows tx back preasure)
--                  (1):    RLB_TXENA               (shows tx activity)
--                  (0):    RLB_RXVAL               (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.fx2lib.all;
use work.fx2rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.nxcramlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_n2 is                   -- top level
                                        -- implements nexys2_fusp_cuff_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n2 switches
    I_BTN : in slv4;                    -- n2 buttons
    O_LED : out slv8;                   -- n2 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_FLA_CE_N : out slbit;             -- flash ce..          (act.low)
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit;             -- fusp: rs232 tx
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end sys_w11a_n2;

architecture syn of sys_w11a_n2 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal RB_MREQ       : rb_mreq_type := rb_mreq_init;
  signal RB_SRES       : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU   : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO   : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');

  signal RLB_MONI : rlb_moni_type := rlb_moni_init;
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal FX2_MONI : fx2ctl_moni_type  := fx2ctl_moni_init;

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal GRESET  : slbit := '0';        -- general reset (from rbus)
  signal CRESET  : slbit := '0';        -- cpu reset     (from cp)
  signal BRESET  : slbit := '0';        -- bus reset     (from cp or cpu)
  signal ITIMER  : slbit := '0';

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal DM_STAT_DP : dm_stat_dp_type := dm_stat_dp_init;

  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MEM_ADDR_EXT : slv22 := (others=>'0');

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR : ib_sres_type := ib_sres_init;

  signal DISPREG : slv16 := (others=>'0');
  signal STATLEDS :  slv8 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0004: 1111 1110 1111 00xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  DCM : dcm_sfs                         -- clock generator -------------------
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce                     -- usec/msec clock divider -----------
    generic map (
      CDUWIDTH => 6,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2l4l_iob         -- serport iob/switch ----------------
    port map (
      CLK      => CLK,
      RESET    => '0',
      SEL      => SWI(0),
      RXD      => RXD,
      TXD      => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_RXD,
      O_TXD0   => O_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );

  RLINK : rlink_sp1c_fx2                -- rlink for serport + fx2 -----------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      PETOWIDTH    => sys_conf_fx2_petowidth,
      CCWIDTH      => sys_conf_fx2_ccwidth,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => sys_conf_rbmon_awidth,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      ENAXON   => SWI(1),
      ENAFX2   => SWI(2),
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      RLB_MONI => RLB_MONI,
      SER_MONI => SER_MONI,
      FX2_MONI => FX2_MONI,
      I_FX2_IFCLK    => I_FX2_IFCLK,
      O_FX2_FIFO     => O_FX2_FIFO,
      I_FX2_FLAG     => I_FX2_FLAG,
      O_FX2_SLRD_N   => O_FX2_SLRD_N,
      O_FX2_SLWR_N   => O_FX2_SLWR_N,
      O_FX2_SLOE_N   => O_FX2_SLOE_N,
      O_FX2_PKTEND_N => O_FX2_PKTEND_N,
      IO_FX2_DATA    => IO_FX2_DATA
    );

  SYS70 : pdp11_sys70                   -- 1 cpu system ----------------------
    port map (
      CLK        => CLK,
      RESET      => RESET,
      RB_MREQ    => RB_MREQ,
      RB_SRES    => RB_SRES_CPU,
      RB_STAT    => RB_STAT,
      RB_LAM_CPU => RB_LAM(0),
      GRESET     => GRESET,
      CRESET     => CRESET,
      BRESET     => BRESET,
      CP_STAT    => CP_STAT,
      EI_PRI     => EI_PRI,
      EI_VECT    => EI_VECT,
      EI_ACKM    => EI_ACKM,
      ITIMER     => ITIMER,
      IB_MREQ    => IB_MREQ,
      IB_SRES    => IB_SRES_IBDR,
      MEM_REQ    => MEM_REQ,
      MEM_WE     => MEM_WE,
      MEM_BUSY   => MEM_BUSY,
      MEM_ACK_R  => MEM_ACK_R,
      MEM_ADDR   => MEM_ADDR,
      MEM_BE     => MEM_BE,
      MEM_DI     => MEM_DI,
      MEM_DO     => MEM_DO,
      DM_STAT_DP => DM_STAT_DP
    );

  IBDR_SYS : ibdr_maxisys               -- IO system -------------------------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => GRESET,
      BRESET   => BRESET,
      ITIMER   => ITIMER,
      CPUSUSP  => CP_STAT.cpususp,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES_IBDR,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => DISPREG
    );
    
  MEM_ADDR_EXT <= "00" & MEM_ADDR;    -- just use lower 4 MB (of 16 MB)

  SRAM_CTL: nx_cram_memctl_as           -- memory controller -----------------
    generic map (
      READ0DELAY => sys_conf_memctl_read0delay,
      READ1DELAY => sys_conf_memctl_read1delay,
      WRITEDELAY => sys_conf_memctl_writedelay)
    port map (
      CLK         => CLK,
      RESET       => GRESET,
      REQ         => MEM_REQ,
      WE          => MEM_WE,
      BUSY        => MEM_BUSY,
      ACK_R       => MEM_ACK_R,
      ACK_W       => open,
      ACT_R       => MEM_ACT_R,
      ACT_W       => MEM_ACT_W,
      ADDR        => MEM_ADDR_EXT,
      BE          => MEM_BE,
      DI          => MEM_DI,
      DO          => MEM_DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  O_FLA_CE_N  <= '1';                   -- keep Flash memory disabled
    
  LED_IO : ioleds_sp1c_fx2              -- hio leds from serport or fx2 ------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      RESET    => GRESET,
      ENAFX2   => SWI(2),
      RB_SRES  => RB_SRES,
      RLB_MONI => RLB_MONI,
      SER_MONI => SER_MONI,
      IOLEDS   => DSP_DP
    );

  ABCLKDIV <= SER_MONI.abclkdiv(11 downto 0) & '0' & SER_MONI.abclkdiv_f;

  HIO70 : pdp11_hio70                   -- hio from sys70 --------------------
    generic map (
      LWIDTH => LED'length,
      DCWIDTH => 2)
    port map (
      SEL_LED    => SWI(3),
      SEL_DSP    => SWI(5 downto 4),
      MEM_ACT_R  => MEM_ACT_R,
      MEM_ACT_W  => MEM_ACT_W,
      CP_STAT    => CP_STAT,
      DM_STAT_DP => DM_STAT_DP,
      ABCLKDIV   => ABCLKDIV,
      DISPREG    => DISPREG,
      LED        => LED,
      DSP_DAT    => DSP_DAT
    );

  HIO : sn_humanio_rbus                 -- hio manager -----------------------
    generic map (
      DEBOUNCE => sys_conf_hio_debounce,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RB_SRES_OR : rb_sres_or_2             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES
    );
 
end syn;
