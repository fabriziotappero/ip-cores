-- $Id: bp_swibtnled.vhd 637 2015-01-25 18:36:40Z mueller $
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
-- Module Name:    bp_swibtnled - syn
-- Description:    Generic SWI, BTN and LED handling
--
-- Dependencies:   xlib/iob_reg_i_gen
--                 xlib/iob_reg_o_gen
--                 genlib/debounce_gen
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-01   386   1.0    Initial version, extracted from s3_humanio
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity bp_swibtnled is                  -- generic SWI, BTN and LED handling
  generic (
    SWIDTH : positive := 4;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 4;             -- LED port width
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0)  -- pad-o: leds
  );
end bp_swibtnled;

architecture syn of bp_swibtnled is
  
  signal RI_SWI :  slv(SWIDTH-1 downto 0) := (others=>'0');
  signal RI_BTN :  slv(BWIDTH-1 downto 0) := (others=>'0');

begin

  IOB_SWI : iob_reg_i_gen
    generic map (DWIDTH => SWIDTH)
    port map (CLK => CLK, CE => '1', DI => RI_SWI, PAD => I_SWI);
  
  IOB_BTN : iob_reg_i_gen
    generic map (DWIDTH => BWIDTH)
    port map (CLK => CLK, CE => '1', DI => RI_BTN, PAD => I_BTN);
  
  IOB_LED : iob_reg_o_gen
    generic map (DWIDTH => LWIDTH)
    port map (CLK => CLK, CE => '1', DO => LED,    PAD => O_LED);
  
  DEB: if DEBOUNCE generate

    DEB_SWI : debounce_gen
      generic map (
        CWIDTH => 2,
        CEDIV  => 3,
        DWIDTH => SWIDTH)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CE_INT => CE_MSEC,
        DI     => RI_SWI,
        DO     => SWI
      );

    DEB_BTN : debounce_gen
      generic map (
        CWIDTH => 2,
        CEDIV  => 3,
        DWIDTH => BWIDTH)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CE_INT => CE_MSEC,
        DI     => RI_BTN,
        DO     => BTN
      );
    
  end generate DEB;

  NODEB: if not DEBOUNCE generate
    SWI <= RI_SWI;
    BTN <= RI_BTN;
  end generate NODEB;
  
end syn;
