-- $Id: sys_tst_snhumanio_s3.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    sys_tst_snhumanio_s3 - syn
-- Description:    snhumanio tester design for s3board
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/sn_humanio
--                 tst_snhumanio
--                 s3board/s3_sram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-09-18   410 13.1    O40d xc3s1000-4   149  211    -  143 t 11.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-25   419   1.0.2  get entity name right...
-- 2011-10-15   416   1.0.1  remove O_CLKSYS top level port
-- 2011-09-18   410   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of S3BOARD Switches, Buttons, LEDs:
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.s3boardlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_snhumanio_s3 is          -- top level
                                        -- implements s3board_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz clock
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
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end sys_tst_snhumanio_s3;

architecture syn of sys_tst_snhumanio_s3 is

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

  SRAM_PROT : s3_sram_dummy             -- connect SRAM to protection dummy
    port map (
      O_MEM_CE_N => O_MEM_CE_N,
      O_MEM_BE_N => O_MEM_BE_N,
      O_MEM_WE_N => O_MEM_WE_N,
      O_MEM_OE_N => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

end syn;
