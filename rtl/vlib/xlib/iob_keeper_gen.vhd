-- $Id: iob_keeper_gen.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    iob_keeper_gen - sim
-- Description:    keeper for IOB, vector
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-03   299   1.1    add explicit R_KEEP and driver
-- 2008-05-22   148   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity iob_keeper_gen is                -- keeper for IOB, vector
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end iob_keeper_gen;

-- Is't possible to directly use 'PAD<='H' in proc_pad. Introduced R_KEEP and
-- the explicit driver 'PAD<=R_KEEP' to state the keeper function more clearly.

architecture sim of iob_keeper_gen is
  signal R_KEEP : slv(DWIDTH-1 downto 0) := (others=>'W');
begin

  proc_keep: process (PAD)
  begin
    for i in PAD'range loop
      if PAD(i) = '1' then
        R_KEEP(i) <= 'H';
      elsif PAD(i) = '0' then
        R_KEEP(i) <= 'L';
      elsif PAD(i)='X' or PAD(i)='U' then
        R_KEEP(i) <= 'W';
      end if;        
    end loop;
    PAD <= R_KEEP;
  end process proc_keep;

end sim;
