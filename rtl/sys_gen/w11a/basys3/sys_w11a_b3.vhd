-- $Id: sys_w11a_b3.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_w11a_b3 - syn
-- Description:    w11a test design for basys3
--
-- Dependencies:   vlib/xlib/s7_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 vlib/rlink/rlink_sp1c
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_bram_memctl
--                 vlib/rlink/ioleds_sp1c
--                 w11a/pdp11_hio70
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_sys_w11a_b3
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4; ghdl 0.31
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2015-06-04   686 2014.4  xc7a35t-1    1919  4372   162  47.5  1408 +TM11 17%
-- 2015-05-14   680 2014.4  xc7a35t-1    1837  4304   162  47.5  1354 +RHRP 17%
-- 2015-02-21   649 2014.4  xc7a35t-1    1637  3767   146  47.5  1195  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-09   677   2.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   2.0    use pdp11_sys70 and pdp11_hio70
-- 2015-04-11   666   1.1.1  rearrange XON handling
-- 2015-02-21   649   1.1    use ioleds_sp1c,pdp11_(statleds,ledmux,dspmux)
-- 2015-02-08   644   1.0    Initial version (derived from sys_w11a_n4)
------------------------------------------------------------------------------
--
-- w11a test design for basys3
--    w11a + rlink + serport
--
-- Usage of Basys 3 Switches, Buttons, LEDs
--
--    SWI(15:6): no function (only connected to sn_humanio_rbus)
--    SWI(5:4):  select DSP
--                 00 abclkdiv & abclkdiv_f
--                 01 PC
--                 10 DISPREG
--                 11 DR emulation
--    SWI(3):    select LED display
--                 0 overall status
--                 1 DR emulation
--    SWI(2):    unused-reserved (USB port select)
--    SWI(1):    1 enable XON
--    SWI(0):    unused-reserved (serial port select)
--    
--    LEDs if SWI(3) = 1
--      (15:0)   DR emulation; shows R0 during wait like 11/45+70
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
--    DSP(7:4)  shows abclkdiv & abclkdiv_f or PS depending on SWI(4)
--    DSP(3:0)  shows DISPREG
--    DP(3:0)   shows IO activity
--                  (3)  not SER_MONI.txok       (shows tx back preasure)
--                  (2)  SER_MONI.txact          (shows tx activity)
--                  (1)  not SER_MONI.rxok       (shows rx back preasure)
--                  (0)  SER_MONI.rxact          (shows rx activity)
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
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_b3 is                   -- top level
                                        -- implements basys3_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv16;                   -- b3 switches
    I_BTN : in slv5;                    -- b3 buttons
    O_LED : out slv16;                  -- b3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end sys_w11a_b3;

architecture syn of sys_w11a_b3 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal RB_MREQ       : rb_mreq_type := rb_mreq_init;
  signal RB_SRES       : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU   : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO   : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

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

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DISPREG :  slv16 := (others=>'0');
  signal STATLEDS :  slv8 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');
    
  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/0004: 1111 1110 1111 00xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  GEN_CLKSYS : s7_cmt_sfs               -- clock generator -------------------
    generic map (
      VCO_DIVIDE     => sys_conf_clksys_vcodivide,
      VCO_MULTIPLY   => sys_conf_clksys_vcomultiply,
      OUT_DIVIDE     => sys_conf_clksys_outdivide,
      CLKIN_PERIOD   => 10.0,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      GEN_TYPE       => sys_conf_clksys_gentype)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce                     -- usec/msec clock divider -----------
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob         -- serport iob ----------------------
    port map (
      CLK      => CLK,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  RLINK : rlink_sp1c                    -- rlink for serport -----------------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
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
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => '0',
      RTS_N    => open,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
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
  
  BRAM_CTL: pdp11_bram_memctl           -- memory controller -----------------
    generic map (
      MAWIDTH => sys_conf_memctl_mawidth,
      NBLOCK  => sys_conf_memctl_nblock)
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
      ADDR        => MEM_ADDR,
      BE          => MEM_BE,
      DI          => MEM_DI,
      DO          => MEM_DO
    );

  LED_IO : ioleds_sp1c                  -- hio leds from serport -------------
    port map (
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
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  2,
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
