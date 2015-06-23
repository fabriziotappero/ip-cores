-- $Id: sn_humanio.vhd 637 2015-01-25 18:36:40Z mueller $
--
-- Copyright 2010-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sn_humanio - syn
-- Description:    BTN,SWI,LED and DSP handling for s3board, nexys, basys
--
-- Dependencies:   xlib/iob_reg_o_gen
--                 bpgen/bp_swibtnled
--                 bpgen/sn_7segctl
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-01-24   637 14.7  131013 xc6slx16-2    77   79    0   28 s  3.5 ns (n4)
-- 2015-01-24   637 14.7  131013 xc6slx16-2    47   52    0   18 s  3.4 ns (n2)
-- 2015-01-24   410 14.7  131013 xc6slx16-2    47   52    0   18 s  3.4 ns
-- 2011-09-17   409 13.1    O40d xc3s1000-4    49   86    0   53 s  5.3 ns 
-- 2011-07-02   387 12.1    M53d xc3s1000-4    48   87    0   53 s  5.1 ns 
-- 2010-04-10   275 11.4    L68  xc3s1000-4    48   87    0   53 s  5.2 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-24   637   1.3    add SWIDTH,LWIDTH,DCWIDTH (for nexys4,basys3)
-- 2011-07-30   400   1.2.1  use CDWIDTH=7 for sn_4x7segctl (for 100 MHz)
-- 2011-07-08   390   1.2    renamed from s3_humanio, add BWIDTH generic
-- 2011-07-02   387   1.1.2  use bp_swibtnled
-- 2010-04-17   278   1.1.1  rename dispdrv -> s3_dispdrv
-- 2010-04-11   276   1.1    instantiate BTN/SWI debouncers via DEBOUNCE generic
-- 2010-04-10   275   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio is                    -- human i/o handling: swi,btn,led,dsp
  generic (
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0);      -- display decimal points
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0); -- pad-o: leds
    O_ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- pad-o: disp: anodes (act.low)
    O_SEG_N : out slv8                         -- pad-o: disp: segments (act.low)
  );
end sn_humanio;

architecture syn of sn_humanio is
  
  signal N_ANO_N :  slv((2**DCWIDTH)-1 downto 0) := (others=>'0');
  signal N_SEG_N :  slv8 := (others=>'0');
  
begin

  IOB_ANO_N : iob_reg_o_gen
    generic map (DWIDTH => 2**DCWIDTH)
    port map (CLK => CLK, CE => '1', DO => N_ANO_N, PAD => O_ANO_N);
  
  IOB_SEG_N : iob_reg_o_gen
    generic map (DWIDTH => 8)
    port map (CLK => CLK, CE => '1', DO => N_SEG_N, PAD => O_SEG_N);

 HIO : bp_swibtnled
    generic map (
      SWIDTH   => SWIDTH,
      BWIDTH   => BWIDTH,
      LWIDTH   => LWIDTH,
      DEBOUNCE => DEBOUNCE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
    );

  DRV : sn_7segctl
    generic map (
      DCWIDTH => DCWIDTH,
      CDWIDTH => 7)                     -- 7 good for 100 MHz on nexys2
    port map (
      CLK   => CLK,
      DIN   => DSP_DAT,
      DP    => DSP_DP,
      ANO_N => N_ANO_N,
      SEG_N => N_SEG_N
    );
  
end syn;
