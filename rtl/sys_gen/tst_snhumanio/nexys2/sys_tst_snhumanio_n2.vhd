-- $Id: sys_tst_snhumanio_n2.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    sys_tst_snhumanio_n2 - syn
-- Description:    snhumanio tester design for nexys2
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/sn_humanio
--                 tst_snhumanio
--                 vlib/nxcramlib/nx_cram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-09-17   410 13.1    O40d xc3s1200e-4  149  207    -  144 t 10.2
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    remove clksys output hack
-- 2011-11-26   433   1.0.3  use nx_cram_dummy now
-- 2011-11-23   432   1.0.3  update O_FLA_CE_N usage
-- 2011-10-25   419   1.0.2  get entity name right...
-- 2011-09-17   410   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Nexys 2 Switches, Buttons, LEDs:
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_snhumanio_n2 is          -- top level
                                        -- implements nexys2_aif
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
    O_FLA_CE_N : out slbit              -- flash ce..          (act.low)
  );
end sys_tst_snhumanio_n2;

architecture syn of sys_tst_snhumanio_n2 is

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
  
  CLK <= I_CLK50;

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => 50,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  HIO : sn_humanio
    generic map (
      BWIDTH   => 4,
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
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
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

  O_TXD <= I_RXD;

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
