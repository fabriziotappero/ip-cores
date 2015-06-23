-- $Id: sys_tst_serloop2_n2.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    sys_tst_serloop2_n2 - syn
-- Description:    Tester serial link for nexys2
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 genlib/clkdivce
--                 bpgen/bp_rs232_2l4l_iob
--                 bpgen/sn_humanio
--                 tst_serloop_hiomap
--                 vlib/serport/serport_2clock
--                 tst_serloop
--                 vlib/nxcramlib/nx_cram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-12-16   439 13.1    O40d xc3s1200e-4  516  696   64  575 t xx.x
-- 2011-11-16   426 13.1    O40d xc3s1200e-4  494  661   64  547 t xx.x
-- 2011-11-13   425 13.1    O40d xc3s1200e-4  487  645   64  532 t xx.x
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    remove clksys output hack
-- 2011-12-09   437   1.0.4  rename serport stat->moni port
-- 2011-11-26   433   1.0.3  use nx_cram_dummy now
-- 2011-11-23   432   1.0.2  update O_FLA_CE_N usage
-- 2011-11-17   426   1.0.1  use dcm_sfs now
-- 2011-11-12   423   1.0    Initial version
-- 2011-11-09   422   0.5    First draft
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
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_serloop2_n2 is            -- top level
                                        -- implements nexys2_fusp_aif
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
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_serloop2_n2;

architecture syn of sys_tst_serloop2_n2 is

  signal CLK :   slbit := '0';
  signal RESET : slbit := '0';

  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CLKS :   slbit := '0';
  signal CES_MSEC : slbit := '0';

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

  DCM_U : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => 2,
      CLKFX_MULTIPLY => 4,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV_U : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clkudiv_usecdiv,  -- syn:  100  sim:  20
      MSECDIV  => sys_conf_clkdiv_msecdiv)   -- syn: 1000  sim:   5
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  DCM_S : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => 5,
      CLKFX_MULTIPLY => 6,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLKS,
      LOCKED  => open
    );

  CLKDIV_S : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => sys_conf_clksdiv_usecdiv,  -- syn:   60  sim:  12
      MSECDIV  => sys_conf_clkdiv_msecdiv)   -- syn: 1000  sim:   5
    port map (
      CLK     => CLKS,
      CE_USEC => open,
      CE_MSEC => CES_MSEC
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
      CLK      => CLKS,
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
  
  SERPORT : serport_2clock
    generic map (
      CDWIDTH   => 15,
      CDINIT    => sys_conf_uart_cdinit,
      RXFAWIDTH => 5,
      TXFAWIDTH => 5)
    port map (
      CLKU     => CLK,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => HIO_CNTL.enaxon,
      ENAESC   => HIO_CNTL.enaesc,
      RXDATA   => RXDATA,
      RXVAL    => RXVAL,
      RXHOLD   => RXHOLD,
      TXDATA   => TXDATA,
      TXENA    => TXENA,
      TXBUSY   => TXBUSY,
      MONI     => SER_MONI,
      RXSD     => RXD,
      TXSD     => TXD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
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
  
  O_FLA_CE_N  <= '1';                   -- keep Flash memory disabled

end syn;
