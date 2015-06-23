-- $Id: pdp11_hio70.vhd 672 2015-05-02 21:58:28Z mueller $
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
-- Module Name:    pdp11_hio70 - syn
-- Description:    pdp11: hio led and dsp for sys70
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-01   672   1.0    Initial version (extracted from sys_w11a_*)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_hio70 is                   -- hio led and dsp for sys70
  generic (
    LWIDTH : positive := 8;             -- led width
    DCWIDTH : positive := 2);           -- digit counter width (2 or 3)
  port (
    SEL_LED : in slbit;                 -- led select (0=stat;1=dr)
    SEL_DSP : in slv2;                  -- dsp select
    MEM_ACT_R : in slbit;               -- memory active read
    MEM_ACT_W : in slbit;               -- memory active write
    CP_STAT : in cp_stat_type;          -- console port status
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status
    ABCLKDIV : in slv16;                -- serport clock divider
    DISPREG : in slv16;                 -- display register
    LED : out slv(LWIDTH-1 downto 0);   -- hio leds
    DSP_DAT : out slv(4*(2**DCWIDTH)-1 downto 0)  -- display data
  );
end pdp11_hio70;

architecture syn of pdp11_hio70 is

  signal STATLEDS :  slv8 := (others=>'0');
  
begin

  LED_CPU : pdp11_statleds
    port map (
      MEM_ACT_R  => MEM_ACT_R,
      MEM_ACT_W  => MEM_ACT_W,
      CP_STAT    => CP_STAT,
      DM_STAT_DP => DM_STAT_DP,
      STATLEDS   => STATLEDS
    );
  
  LED_MUX : pdp11_ledmux
    generic map (
      LWIDTH => LWIDTH)
    port map (
      SEL        => SEL_LED,
      STATLEDS   => STATLEDS,
      DM_STAT_DP => DM_STAT_DP,
      LED        => LED
    );
    
  DSP_MUX : pdp11_dspmux
    generic map (
      DCWIDTH => DCWIDTH)
    port map (
      SEL        => SEL_DSP,
      ABCLKDIV   => ABCLKDIV,
      DM_STAT_DP => DM_STAT_DP,
      DISPREG    => DISPREG,
      DSP_DAT    => DSP_DAT
    );
    
end syn;
