-- $Id: sys_tst_rlink_cuff_atlys.vhd 638 2015-01-25 22:01:38Z mueller $
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
-- Module Name:    sys_tst_rlink_cuff_atlys - syn
-- Description:    rlink tester design for atlys with fx2 interface
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/bpgen/sn_humanio_demu_rbus
--                 bplib/fx2lib/fx2_2fifoctl_ic   [sys_conf_fx2_type="ic2"]
--                 bplib/fx2lib/fx2_3fifoctl_ic   [sys_conf_fx2_type="ic3"]
--                 tst_rlink_cuff
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ctl/MHz
-- 2013-01-06   472 13.3    O76d xc6slx45     ???  ???? ??? ???? p ??.? ic2/100
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-25   638   1.1.2  retire fx2_2fifoctl_as
-- 2014-12-24   620   1.1.1  relocate hio rbus address
-- 2014-08-15   583   1.1    rb_mreq addr now 16 bit
-- 2013-01-06   472   1.0    Initial version; derived from sys_tst_rlink_cuff_n3
--                           and sys_tst_fx2loop_atlys
------------------------------------------------------------------------------
-- Usage of Atlys Switches, Buttons, LEDs:
--
--    SWI(7:3)  no function (only connected to sn_humanio_demu_rbus)
--       (2)    0 -> int/ext RS242 port for rlink
--              1 -> use USB interface for rlink
--       (1)    1 enable XON
--       (0)    0 -> main board RS232 port  - implemented in bp_rs232_2l4l_iob
--              1 -> Pmod B/top RS232 port  /
--
--    LED(7)    SER_MONI.abact
--       (6:2)  no function (only connected to sn_humanio_demu_rbus)
--       (0)    timer 0 busy 
--       (1)    timer 1 busy 
--
--    DSP:      SER_MONI.clkdiv         (from auto bauder)
--    for SWI(2)='0' (serport)
--    DP(3)     not SER_MONI.txok       (shows tx back preasure)
--      (2)     SER_MONI.txact          (shows tx activity)
--      (1)     not SER_MONI.rxok       (shows rx back preasure)
--      (0)     SER_MONI.rxact          (shows rx activity)
--    for SWI(2)='1' (fx2)
--    DP(3)     FX2_TX2BUSY             (shows tx2 back preasure)
--      (2)     FX2_TX2ENA(stretched)   (shows tx2 activity)
--      (1)     FX2_TXENA(streched)     (shows tx activity)
--      (0)     FX2_RXVAL(stretched)    (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.rblib.all;
use work.fx2lib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_rlink_cuff_atlys is      -- top level
                                        -- implements atlys_fusp_cuff_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_USB_RXD : in slbit;               -- USB UART receive data (board view)
    O_USB_TXD : out slbit;              -- USB UART transmit data (board view)
    I_HIO_SWI : in slv8;                -- atlys hio switches
    I_HIO_BTN : in slv6;                -- atlys hio buttons
    O_HIO_LED: out slv8;                -- atlys hio leds
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
end sys_tst_rlink_cuff_atlys;

architecture syn of sys_tst_rlink_cuff_atlys is
  
  signal CLK :   slbit := '0';
  signal RESET : slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';
  
  signal RXSD  : slbit := '0';
  signal TXSD  : slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');
  
  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;

  signal FX2_RXDATA   : slv8 := (others=>'0');
  signal FX2_RXVAL    : slbit := '0';
  signal FX2_RXHOLD   : slbit := '0';
  signal FX2_RXAEMPTY : slbit := '0';
  signal FX2_TXDATA   : slv8 := (others=>'0');
  signal FX2_TXENA    : slbit := '0';
  signal FX2_TXBUSY   : slbit := '0';
  signal FX2_TXAFULL  : slbit := '0';
  signal FX2_TX2DATA  : slv8 := (others=>'0');
  signal FX2_TX2ENA   : slbit := '0';
  signal FX2_TX2BUSY  : slbit := '0';
  signal FX2_TX2AFULL : slbit := '0';
  signal FX2_MONI  : fx2ctl_moni_type := fx2ctl_moni_init;

  constant rbaddr_hio   : slv16 := x"fef0"; -- fef0/4: 1111 1110 1111 00xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  DCM : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 10.0)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLK,
      LOCKED  => open
    );
  
  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,                    -- good for up to 127 MHz !
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2l4l_iob
    port map (
      CLK      => CLK,
      RESET    => '0',
      SEL      => SWI(0),
      RXD      => RXSD,
      TXD      => TXSD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_USB_RXD,
      O_TXD0   => O_USB_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );

  HIO : sn_humanio_demu_rbus
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
      I_SWI   => I_HIO_SWI,                 
      I_BTN   => I_HIO_BTN,
      O_LED   => O_HIO_LED
    );

  FX2_CNTL_IC : if sys_conf_fx2_type = "ic2" generate
    CNTL : fx2_2fifoctl_ic
      generic map (
        RXFAWIDTH  => 5,
        TXFAWIDTH  => 5,
        PETOWIDTH  => sys_conf_fx2_petowidth,
        CCWIDTH    => sys_conf_fx2_ccwidth,
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
  end generate FX2_CNTL_IC;

  FX2_CNTL_IC3 : if sys_conf_fx2_type = "ic3" generate
    CNTL : fx2_3fifoctl_ic
      generic map (
        RXFAWIDTH  => 5,
        TXFAWIDTH  => 5,
        PETOWIDTH  => sys_conf_fx2_petowidth,
        CCWIDTH    => sys_conf_fx2_ccwidth,
        RXAEMPTY_THRES => 1,
        TXAFULL_THRES  => 1,
        TX2AFULL_THRES => 1)
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
        TX2DATA  => FX2_TX2DATA,
        TX2ENA   => FX2_TX2ENA,
        TX2BUSY  => FX2_TX2BUSY,
        TX2AFULL => FX2_TX2AFULL,
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
  end generate FX2_CNTL_IC3;
    
  TST : entity work.tst_rlink_cuff
    port map (
      CLK         => CLK,
      RESET       => '0',
      CE_USEC     => CE_USEC,
      CE_MSEC     => CE_MSEC,
      RB_MREQ_TOP => RB_MREQ,
      RB_SRES_TOP => RB_SRES_HIO,
      SWI         => SWI,
      BTN         => BTN(3 downto 0),
      LED         => LED,
      DSP_DAT     => DSP_DAT,
      DSP_DP      => DSP_DP,
      RXSD        => RXSD,
      TXSD        => TXSD,
      RTS_N       => RTS_N,
      CTS_N       => CTS_N,
      FX2_RXDATA  => FX2_RXDATA,
      FX2_RXVAL   => FX2_RXVAL,
      FX2_RXHOLD  => FX2_RXHOLD,
      FX2_TXDATA  => FX2_TXDATA,
      FX2_TXENA   => FX2_TXENA,
      FX2_TXBUSY  => FX2_TXBUSY,
      FX2_TX2DATA => FX2_TX2DATA,
      FX2_TX2ENA  => FX2_TX2ENA,
      FX2_TX2BUSY => FX2_TX2BUSY,
      FX2_MONI    => FX2_MONI
    );

end syn;

