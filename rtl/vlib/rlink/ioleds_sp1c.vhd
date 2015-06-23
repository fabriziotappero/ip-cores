-- $Id: ioleds_sp1c.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    ioleds_sp1c - syn
-- Description:    io activity leds for rlink+serport_1clk combo
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 17.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-21   649   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.serportlib.all;

entity ioleds_sp1c is                   -- io activity leds for rlink_sp1c
  port (
    SER_MONI : in serport_moni_type;    -- ser: monitor port
    IOLEDS : out slv4                   -- 4 bit IO monitor (e.g. for DSP_DP)
  );
end entity ioleds_sp1c;


architecture syn of ioleds_sp1c is

begin

  -- currently very minimal implementation
  IOLEDS(3) <= not SER_MONI.txok;
  IOLEDS(2) <= SER_MONI.txact;
  IOLEDS(1) <= not SER_MONI.rxok;
  IOLEDS(0) <= SER_MONI.rxact;

end syn;
