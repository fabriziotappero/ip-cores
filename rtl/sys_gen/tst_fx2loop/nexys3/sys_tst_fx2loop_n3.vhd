-- $Id: sys_tst_fx2loop_n3.vhd 638 2015-01-25 22:01:38Z mueller $
--
-- Copyright 2012-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_tst_fx2loop_n3 - syn
-- Description:    test of Cypress EZ-USB FX2 controller
--
-- Dependencies:   vlib/xlib/s6_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bpgen/sn_humanio
--                 tst_fx2loop_hiomap
--                 tst_fx2loop
--                 bplib/fx2lib/fx2_2fifoctl_ic   [sys_conf_fx2_type="ic2"]
--                 bplib/fx2lib/fx2_3fifoctl_ic   [sys_conf_fx2_type="ic3"]
--                 bplib/nxcramlib/nx_cram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ctl/MHz
-- 2013-04-25   510 14.5    P58f xc6slx16-2   416  516   68  199 p  5.3 ic3/150
-- 2013-04-24   510 13.3    O76d xc6slx16-2   417  674   68  228 p  5.3 ic3/175
-- 2012-04-09   461 13.3    O76d xc6slx16-2   429  620   48  232 p  7.2 ic3/100
--
-- 2013-04-25   510 14.5    P58f xc6slx16-2   349  427   48  163 p  5.4 ic2/150
-- 2013-04-24   510 13.3    O76d xc6slx16-2   355  569   48  208 p  5.4 ic2/175
-- 2012-04-09   461 13.3    O76d xc6slx16-2   347  499   32  175 p  7.9 ic2/100
--
-- 2013-04-24   510 13.3    O76d xc6slx16-2   299  486   32  175 p FAIL as2/100
-- 2012-04-09   461 13.3    O76d xc6slx16-2   299  460   32  164 p FAIL as2/100
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-10-06   538   1.1    pll support, use clksys_vcodivide ect
-- 2013-04-24   510   1.0.1  CLKDIV.CDUWIDTH now 8, support >127 sysclk
-- 2012-04-09   461   1.0    Initial version (derived from sys_tst_fx2loop_n2)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.tst_fx2looplib.all;
use work.fx2lib.all;
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_fx2loop_n3 is            -- top level
                                        -- implements nexys3_aif + fx2 pins
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n3 switches
    I_BTN : in slv5;                    -- n3 buttons
    O_LED : out slv8;                   -- n3 leds
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
    O_PPCM_CE_N : out slbit;            -- ppcm: ...
    O_PPCM_RST_N : out slbit;           -- ppcm: ...
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end sys_tst_fx2loop_n3;

architecture syn of sys_tst_fx2loop_n3 is
  
  signal CLK :   slbit := '0';
  signal RESET : slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');
  
  signal LED_MAP : slv8  := (others=>'0');  

  signal HIO_CNTL : hio_cntl_type := hio_cntl_init;
  signal HIO_STAT : hio_stat_type := hio_stat_init;

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
  signal FX2_TX2BUSY  : slbit := '1';
  signal FX2_TX2AFULL : slbit := '0';
  signal FX2_MONI  : fx2ctl_moni_type := fx2ctl_moni_init;

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

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
      CDUWIDTH => 8,                    -- good for up to 255 MHz !
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  HIO : sn_humanio
    generic map (
      BWIDTH   => 5,
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => '0',
      CE_MSEC => CE_MSEC,
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

  RESET <= BTN(0);                      -- BTN(0) will reset tester !!
  
  HIOMAP : tst_fx2loop_hiomap
    port map (
      CLK      => CLK,
      RESET    => RESET,
      HIO_CNTL => HIO_CNTL,
      HIO_STAT => HIO_STAT,
      FX2_MONI => FX2_MONI,
      SWI      => SWI,
      BTN      => BTN(3 downto 0),
      LED      => LED_MAP,
      DSP_DAT  => DSP_DAT,
      DSP_DP   => DSP_DP
    );

  proc_led: process (SWI, LED_MAP, FX2_TX2BUSY, FX2_TX2ENA,
                     FX2_TXBUSY, FX2_TXENA, FX2_RXHOLD, FX2_RXVAL)
  begin

    if SWI(4) = '1' then
      LED(7) <= '0';
      LED(6) <= '0';
      LED(5) <= FX2_TX2BUSY;
      LED(4) <= FX2_TX2ENA;
      LED(3) <= FX2_TXBUSY;
      LED(2) <= FX2_TXENA;
      LED(1) <= FX2_RXHOLD;
      LED(0) <= FX2_RXVAL;
    else
      LED <= LED_MAP;
    end if;
    
  end process proc_led;
  
  
  TST : tst_fx2loop
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_MSEC     => CE_MSEC,
      HIO_CNTL    => HIO_CNTL,
      HIO_STAT    => HIO_STAT,
      FX2_MONI    => FX2_MONI,
      RXDATA      => FX2_RXDATA,
      RXVAL       => FX2_RXVAL,
      RXHOLD      => FX2_RXHOLD,
      TXDATA      => FX2_TXDATA,
      TXENA       => FX2_TXENA,
      TXBUSY      => FX2_TXBUSY,
      TX2DATA     => FX2_TX2DATA,
      TX2ENA      => FX2_TX2ENA,
      TX2BUSY     => FX2_TX2BUSY
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
    
  SRAM_PROT : nx_cram_dummy            -- connect CRAM to protection dummy
    port map (
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

  O_PPCM_CE_N  <= '1';                  -- keep parallel PCM memory disabled
  O_PPCM_RST_N <= '1';                  --

  O_TXD <= I_RXD;                       -- loop-back in serial port...
  
end syn;

