-- $Id: simclkcnt.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    simclkcnt - sim
-- Description:    test bench system clock cycle counter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   2.0    CLK_CYCLE now an integer
-- 2011-11-12   423   1.0.1  now numeric_std clean
-- 2010-11-13    72   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.slvtypes.all;

entity simclkcnt is                   -- test bench system clock cycle counter
  port (
    CLK  : in slbit;                  -- clock
    CLK_CYCLE  : out integer          -- clock cycle number
  );
end entity simclkcnt;

architecture sim of simclkcnt is
  signal R_CLKCNT : integer := 0;
begin

  proc_clk: process (CLK)
  begin

    if rising_edge(CLK) then
      R_CLKCNT <= R_CLKCNT + 1;
    end if;
    
  end process proc_clk;

  CLK_CYCLE <= R_CLKCNT;
  
end sim;
