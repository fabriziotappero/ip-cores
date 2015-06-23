-- $Id: sys_tst_snhumanio_atlys.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    sys_tst_snhumanio_atlys - syn
-- Description:    snhumanio tester design for atlys
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/sn_humanio_demu
--                 tst_snhumanio
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-10-11   414 13.1    O40d xc6slx45     166  196    -   60 t  4.9
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-11   414   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Atlys Switches, Buttons, LEDs:
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_snhumanio_atlys is       -- top level
                                        -- implements atlys_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
--  O_CLKSYS : out slbit;               -- DCM derived system clock
    I_USB_RXD : in slbit;               -- USB UART receive data (board view)
    O_USB_TXD : out slbit;              -- USB UART transmit data (board view)
    I_HIO_SWI : in slv8;                -- atlys hio switches
    I_HIO_BTN : in slv6;                -- atlys hio buttons
    O_HIO_LED: out slv8;                -- atlys hio leds
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_snhumanio_atlys;

architecture syn of sys_tst_snhumanio_atlys is

  signal CLK :   slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_MSEC : slbit := '0';

begin

  RESET <= '0';                         -- so far not used
  
  CLK <= I_CLK100;

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => 100,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  HIO : sn_humanio_demu
    generic map (
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_HIO_SWI,                 
      I_BTN   => I_HIO_BTN,
      O_LED   => O_HIO_LED
    );

  HIOTEST : entity work.tst_snhumanio
    generic map (
      BWIDTH => 4)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP
    );

  O_USB_TXD    <= I_USB_RXD;
  O_FUSP_TXD   <= I_FUSP_RXD;
  O_FUSP_RTS_N <= I_FUSP_CTS_N;
  
end syn;
