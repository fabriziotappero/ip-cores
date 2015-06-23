-- $Id: gray_cnt_gen.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    gray_cnt_gen - syn
-- Description:    Generic width Gray code counter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;

entity gray_cnt_gen is                  -- gray code counter, generic vector
  generic (
    DWIDTH : positive := 4);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end entity gray_cnt_gen;


architecture syn of gray_cnt_gen is

begin
  
  assert DWIDTH>=4
    report "assert(DWIDTH>=4): only 4 or more bit width supported"
    severity failure;


  GRAY_4: if DWIDTH=4 generate
  begin
    CNT : gray_cnt_4
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_4;

  GRAY_5: if DWIDTH=5 generate
  begin
    CNT : gray_cnt_5
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_5;

  GRAY_N: if DWIDTH>5 generate
  begin
    CNT : gray_cnt_n
      generic map (
        DWIDTH => DWIDTH)
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_N;

end syn;

