-- $Id: sys_tst_serloop_s3.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_tst_serloop_s3 - syn
-- Description:    Tester serial link for s3board
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 genlib/clkdivce
--                 bpgen/bp_rs232_2l4l_iob
--                 bpgen/sn_humanio
--                 tst_serloop_hiomap
--                 vlib/serport/serport_1clock
--                 tst_serloop
--                 s3board/s3_sram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-11-16   426 13.1    O40d xc3s1000-4   424  602   64  476 t 13.6
-- 2011-11-13   425 13.1    O40d xc3s1000-4   421  586   64  466 t 13.6
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-09   437   1.0.2  rename serport stat->moni port
-- 2011-11-17   426   1.0.1  use dcm_sfs now
-- 2011-11-12   423   1.0    Initial version
-- 2011-10-25   419   0.5    First draft
------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.tst_serlooplib.all;
use work.serportlib.all;
use work.s3boardlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_serloop_s3 is            -- top level
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32;          -- sram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_serloop_s3;

architecture syn of sys_tst_serloop_s3 is
  
  signal CLK :   slbit := '0';
  signal RESET : slbit := '0';

  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RXD :   slbit := '0';
  signal TXD :   slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';
  
  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal HIO_CNTL : hio_cntl_type := hio_cntl_init;
  signal HIO_STAT : hio_stat_type := hio_stat_init;
  
  signal RXDATA : slv8  := (others=>'0');
  signal RXVAL :  slbit := '0';
  signal RXHOLD : slbit := '0';
  signal TXDATA : slv8  := (others=>'0');
  signal TXENA :  slbit := '0';
  signal TXBUSY : slbit := '0';
  
  signal SER_MONI : serport_moni_type  := serport_moni_init;

begin

  DCM : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => 5,
      CLKFX_MULTIPLY => 6,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => sys_conf_clkdiv_usecdiv,   -- syn:   60  sim:  12
      MSECDIV  => sys_conf_clkdiv_msecdiv)   -- syn: 1000  sim:   5
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  HIO : sn_humanio
    generic map (
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
  
  HIOMAP : tst_serloop_hiomap
    port map (
      CLK      => CLK,
      RESET    => RESET,
      HIO_CNTL => HIO_CNTL,
      HIO_STAT => HIO_STAT,
      SER_MONI => SER_MONI,
      SWI      => SWI,
      BTN      => BTN,
      LED      => LED,
      DSP_DAT  => DSP_DAT,
      DSP_DP   => DSP_DP
    );

  IOB_RS232 : bp_rs232_2l4l_iob
    port map (
      CLK      => CLK,
      RESET    => '0',
      SEL      => SWI(0),               -- port selection
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
  
  SERPORT : serport_1clock
    generic map (
      CDWIDTH   => 15,
      CDINIT    => sys_conf_uart_cdinit,
      RXFAWIDTH => 5,
      TXFAWIDTH => 5)
    port map (
      CLK     => CLK,
      CE_MSEC => CE_MSEC,
      RESET   => RESET,
      ENAXON  => HIO_CNTL.enaxon,
      ENAESC  => HIO_CNTL.enaesc,
      RXDATA  => RXDATA,
      RXVAL   => RXVAL,
      RXHOLD  => RXHOLD,
      TXDATA  => TXDATA,
      TXENA   => TXENA,
      TXBUSY  => TXBUSY,
      MONI    => SER_MONI,
      RXSD    => RXD,
      TXSD    => TXD,
      RXRTS_N => RTS_N,
      TXCTS_N => CTS_N
    );

  TESTER : tst_serloop
    port map (
      CLK      => CLK,
      RESET    => RESET,
      CE_MSEC  => CE_MSEC,
      HIO_CNTL => HIO_CNTL,
      HIO_STAT => HIO_STAT,
      SER_MONI => SER_MONI,
      RXDATA   => RXDATA,
      RXVAL    => RXVAL,
      RXHOLD   => RXHOLD,
      TXDATA   => TXDATA,
      TXENA    => TXENA,
      TXBUSY   => TXBUSY
    );
  
  SRAM : s3_sram_dummy                  -- connect SRAM to protection dummy
    port map (
      O_MEM_CE_N => O_MEM_CE_N,
      O_MEM_BE_N => O_MEM_BE_N,
      O_MEM_WE_N => O_MEM_WE_N,
      O_MEM_OE_N => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

end syn;

