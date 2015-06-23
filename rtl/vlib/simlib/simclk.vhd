-- $Id: simclk.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    simclk - sim
-- Description:    Clock generator for test benches
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   2.0    remove CLK_CYCLE output port
-- 2011-11-18   427   1.0.3  now numeric_std clean
-- 2008-03-24   129   1.0.2  CLK_CYCLE now 31 bits
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-10    72   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.slvtypes.all;

entity simclk is                      -- test bench clock generator
  generic (
    PERIOD : time := 20 ns;           -- clock period
    OFFSET : time := 200 ns);         -- clock offset (first up transition)
  port (
    CLK  : out slbit;                 -- clock
    CLK_STOP : in slbit               -- clock stop trigger
  );
end entity simclk;

architecture sim of simclk is
begin

  proc_clk: process
    constant clock_halfperiod : time := PERIOD/2;
  begin

    CLK <= '0';
    wait for OFFSET;

    clk_loop: loop
      CLK <= '1';
      wait for clock_halfperiod;
      CLK <= '0';
      wait for PERIOD-clock_halfperiod;
      exit clk_loop when CLK_STOP = '1';
    end loop;
    
    CLK <= '1';                         -- final clock cycle for clk_sim
    wait for clock_halfperiod;
    CLK <= '0';
    wait for PERIOD-clock_halfperiod;
    
    wait;                               -- endless wait, simulator will stop
    
  end process proc_clk;

end sim;
