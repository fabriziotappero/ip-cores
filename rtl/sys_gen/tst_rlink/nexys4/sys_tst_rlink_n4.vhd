-- $Id: sys_tst_rlink_n4.vhd 672 2015-05-02 21:58:28Z mueller $
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
-- Module Name:    sys_tst_rlink_n4 - syn
-- Description:    rlink tester design for nexys4
--
-- Dependencies:   vlib/xlib/s7_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_4line_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rlink/rlink_sp1c
--                 rbd_tst_rlink
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_tst_rlink_n4
--
-- Target Devices: generic
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2015-01-31   640 2014.4  xc7a100t-1    990  1360    64     0   495  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.4.1  rearrange XON handling
-- 2015-02-06   643   1.4    factor out memory
-- 2015-02-01   641   1.3.1  separate I_BTNRST_N; autobaud on msb of display
-- 2015-01-31   640   1.3    drop fusp iface; use new sn_hio
-- 2014-11-09   603   1.2    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.1    rb_mreq addr now 16 bit
-- 2013-09-28   535   1.0    Initial version (derived from sys_tst_rlink_n3)
------------------------------------------------------------------------------
-- Usage of Nexys 4 Switches, Buttons, LEDs:
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

entity sys_tst_rlink_n4 is              -- top level
                                        -- implements nexys4_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4 switches
    I_BTN : in slv5;                    -- n4 buttons
    I_BTNRST_N : in slbit;              -- n4 reset button
    O_LED : out slv16;                  -- n4 leds
    O_RGBLED0 : out slv3;               -- n4 rgb-led 0
    O_RGBLED1 : out slv3;               -- n4 rgb-led 1
    O_ANO_N : out slv8;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end sys_tst_rlink_n4;

architecture syn of sys_tst_rlink_n4 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');
  signal DSP_DAT : slv32 := (others=>'0');
  signal DSP_DP  : slv8  := (others=>'0');

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

  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/4: 1111 1110 1111 0xxx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  RESET <= '0';                         -- so far not used
  
  GEN_CLKSYS : s7_cmt_sfs
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
      CDUWIDTH => 8,                    -- good up to 254 MHz
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_4line_iob
    port map (
      CLK     => CLK,
      RXD     => RXD,
      TXD     => TXD,
      CTS_N   => CTS_N,
      RTS_N   => RTS_N,
      I_RXD   => I_RXD,
      O_TXD   => O_TXD,
      I_CTS_N => I_CTS_N,
      O_RTS_N => O_RTS_N
    );

  HIO : sn_humanio_rbus
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  3,
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
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
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

  DSP_DAT(31 downto 20) <= SER_MONI.abclkdiv(11 downto 0);
  DSP_DAT(19)           <= '0';
  DSP_DAT(18 downto 16) <= SER_MONI.abclkdiv_f;
  DSP_DP(7 downto 4)    <= "0010";

  DSP_DAT(15 downto 0)  <= (others=>'0');

  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;

  LED(15 downto 8) <= SWI(15 downto 8);
  LED(7) <= SER_MONI.abact;
  LED(6 downto 2)  <= (others=>'0');
  LED(1) <= STAT(1);
  LED(0) <= STAT(0);
   
  -- setup unused outputs in nexys4
  O_RGBLED0 <= (others=>'0');
  O_RGBLED1 <= (others=>not I_BTNRST_N);

end syn;
