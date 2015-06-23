-- $Id: led_pulse_stretch.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2012- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    led_pulse_stretch - syn
-- Description:    pulse stretcher for leds
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-12-29   466   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity led_pulse_stretch is             -- pulse stretcher for leds
  port (
    CLK : in slbit;                     -- clock
    CE_INT : in slbit;                  -- pulse time unit clock enable
    RESET : in slbit := '0';            -- reset
    DIN : in slbit;                     -- data in
    POUT : out slbit                    -- pulse out
  );
end entity led_pulse_stretch;

architecture syn of led_pulse_stretch is

  type regs_type is record              -- state registers
    seen : slbit;                       -- DIN seen
    busy : slbit;                       -- POUT busy
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- seen
    '0'                                 -- busy
  );
  
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, CE_INT, DIN)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

  begin

    r := R_REGS;
    n := R_REGS;

    if CE_INT='1' then
      n.seen := DIN;
      n.busy := r.seen;
    else
      if DIN='1' then
        n.seen := '1';
      end if;
    end if;
    
    N_REGS <= n;

    POUT   <= r.busy;
    
  end process proc_next;
 
end syn;
