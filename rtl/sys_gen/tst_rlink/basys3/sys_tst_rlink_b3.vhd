-- $Id: sys_tst_rlink_b3.vhd 672 2015-05-02 21:58:28Z mueller $
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
-- Module Name:    sys_tst_rlink_b3 - syn
-- Description:    rlink tester design for basys3
--
-- Dependencies:   vlib/xlib/s6_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rlink/rlink_sp1c
--                 rbd_tst_rlink
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_tst_rlink_b3
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2015-01-30   636 2014.4  xc7a35t-1     946  1319    64   4.5   476  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.0.1  rearrange XON handling
-- 2015-01-16   636   1.0    Initial version (derived from sys_tst_rlink_n3)
------------------------------------------------------------------------------
-- Usage of Basys 3 Switches, Buttons, LEDs:
--
--    SWI(7:2): no function (only connected to sn_humanio_rbus)
--    SWI(1):   1 enable XON
--    SWI(0):   -unused-
--
--    LED(7):   SER_MONI.abact
--    LED(6:2): no function (only connected to sn_humanio_rbus)
--    LED(0):   timer 0 busy 
--    LED(1):   timer 1 busy 
--
--    DSP:      SER_MONI.clkdiv         (from auto bauder)
--    DP(3):    not SER_MONI.txok       (shows tx back preasure)
--    DP(2):    SER_MONI.txact          (shows tx activity)
--    DP(1):    not SER_MONI.rxok       (shows rx back preasure)
--    DP(0):    SER_MONI.rxact          (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_rlink_b3 is              -- top level
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
end sys_tst_rlink_b3;

architecture syn of sys_tst_rlink_b3 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;
  signal RB_SRES_TST : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal STAT    : slv8  := (others=>'0');

  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/4: 1111 1110 1111 00xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  RESET <= '0';                         -- so far not used
  
  GEN_CLKSYS : s6_cmt_sfs
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

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK      => CLK,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  HIO : sn_humanio_rbus
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
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

  RLINK : rlink_sp1c
    generic map (
      BTOWIDTH     => 6,
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,
      OFAWIDTH     => 5,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 15,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,
      RBMON_RBADDR => x"ffe8")
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

  RBDTST : entity work.rbd_tst_rlink
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_USEC     => CE_USEC,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TST,
      RB_LAM      => RB_LAM,
      RB_STAT     => RB_STAT,
      RB_SRES_TOP => RB_SRES,
      RXSD        => RXD,
      RXACT       => SER_MONI.rxact,
      STAT        => STAT
    );

  RB_SRES_OR1 : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_HIO,
      RB_SRES_2  => RB_SRES_TST,
      RB_SRES_OR => RB_SRES
    );

  DSP_DAT   <= SER_MONI.abclkdiv;

  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;

  LED(15 downto 8) <= SWI(15 downto 8);
  LED(7) <= SER_MONI.abact;
  LED(6 downto 2) <= (others=>'0');
  LED(1) <= STAT(1);
  LED(0) <= STAT(0);
  
end syn;
