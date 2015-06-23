-- $Id: tb_nexys4_core.vhd 643 2015-02-07 17:41:53Z mueller $
--
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_nexys4_core - sim
-- Description:    Test bench for nexys4 - core device handling
--
-- Dependencies:   -
--
-- To test:        generic, any nexys4 target
--
-- Target Devices: generic
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-06   643   1.2    factor out memory
-- 2015-02-01   641   1.1    separate I_BTNRST_N
-- 2013-09-21   534   1.0    Initial version (derived from tb_nexys3_core)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.simbus.all;

entity tb_nexys4_core is
  port (
    I_SWI : out slv16;                  -- n4 switches
    I_BTN : out slv5;                   -- n4 buttons
    I_BTNRST_N : out slbit              -- n4 reset button
  );
end tb_nexys4_core;

architecture sim of tb_nexys4_core is
  
  signal R_SWI    : slv16 := (others=>'0');
  signal R_BTN    : slv5  := (others=>'0');
  signal R_BTNRST : slbit := '0';

  constant sbaddr_swi:  slv8 := slv(to_unsigned( 16,8));
  constant sbaddr_btn:  slv8 := slv(to_unsigned( 17,8));

begin
  
  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_swi then
        R_SWI <= to_x01(SB_DATA(R_SWI'range));
      end if;
      if SB_ADDR = sbaddr_btn then
        R_BTN    <= to_x01(SB_DATA(R_BTN'range));
        R_BTNRST <= to_x01(SB_DATA(5));
      end if;
    end if;
  end process proc_simbus;

  I_SWI <= R_SWI;
  I_BTN <= R_BTN;
  I_BTNRST_N <= not R_BTNRST;
  
end sim;
