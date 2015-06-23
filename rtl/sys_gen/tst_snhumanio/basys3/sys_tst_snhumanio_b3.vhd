-- $Id: sys_tst_snhumanio_b3.vhd 640 2015-02-01 09:56:53Z mueller $
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
-- Module Name:    sys_tst_snhumanio_b3 - syn
-- Description:    snhumanio tester design for basys3
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/sn_humanio
--                 tst_snhumanio
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2015-01-30   636 2014.4  xc7a35t-1     154   133     0     0    63  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-16   636   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Basys 3 Switches, Buttons, LEDs:
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_snhumanio_b3 is          -- top level
                                        -- implements basys3_aif
  port (
    I_CLK100 : in slbit;                -- 100  MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv16;                   -- b3 switches
    I_BTN : in slv5;                    -- b3 buttons
    O_LED : out slv16;                  -- b3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- 7 segment disp: segments (act.low)
  );
end sys_tst_snhumanio_b3;

architecture syn of sys_tst_snhumanio_b3 is

  signal CLK :   slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
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

  HIO : sn_humanio
    generic map (
      BWIDTH   => 5,
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
      I_SWI   => I_SWI(7 downto 0),                  
      I_BTN   => I_BTN,
      O_LED   => O_LED(7 downto 0),
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  HIOTEST : entity work.tst_snhumanio
    generic map (
      BWIDTH => 5)
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

  O_TXD <= I_RXD;
  O_LED(15 downto 8) <= not I_SWI(15 downto 8);
  
end syn;
