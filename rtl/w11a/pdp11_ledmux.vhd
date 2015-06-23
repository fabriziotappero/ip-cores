-- $Id: pdp11_ledmux.vhd 677 2015-05-09 21:52:32Z mueller $
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
-- Module Name:    pdp11_ledmux - syn
-- Description:    pdp11: hio led mux
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-27   652   1.0    Initial version 
-- 2015-02-20   649   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_ledmux is                  -- hio led mux
  generic (
    LWIDTH : positive := 8);            -- led width
  port (
    SEL : in slbit;                     -- select (0=stat;1=dr)
    STATLEDS : in slv8;                 -- 8 bit CPU status
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    LED : out slv(LWIDTH-1 downto 0)    -- hio leds
  );
end pdp11_ledmux;

architecture syn of pdp11_ledmux is
  
begin

  assert LWIDTH=8 or LWIDTH=16 
    report "assert(LWIDTH=8 or LWIDTH=16): unsupported LWIDTH"
    severity failure;

  proc_mux: process (SEL, STATLEDS, DM_STAT_DP.dsrc)
    variable iled : slv(LWIDTH-1 downto 0) := (others=>'0');
  begin
    iled := (others=>'0');

    if SEL = '0' then
      iled(STATLEDS'range) := STATLEDS;
    else
      if LWIDTH=8 then
        iled :=  DM_STAT_DP.dsrc(11 downto 4); --take middle part
      else
        iled :=  DM_STAT_DP.dsrc(iled'range);
      end if;
    end if;

    LED <= iled;
    
  end process proc_mux;

end syn;
