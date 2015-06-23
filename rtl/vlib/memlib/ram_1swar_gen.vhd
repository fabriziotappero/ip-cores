-- $Id: ram_1swar_gen.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ram_1swar_gen - syn
-- Description:    Single-Port RAM with with one synchronous write and one
--                 asynchronius read port (as distributed RAM).
--                 The code is inspired by Xilinx example rams_04.vhd. The
--                 'ram_style' attribute is set to 'distributed', this will
--                 force in XST a synthesis as distributed RAM.
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-08   422   1.0.2  now numeric_std clean
-- 2008-03-08   123   1.0.1  use std_..._arith, not _unsigned; use unsigned()
-- 2007-06-03    45   1.0    Initial version 
--
-- Some synthesis results:
-- - 2007-12-31 ise 8.2.03 for xc3s1000-ft256-4:
--   AWIDTH DWIDTH  LUTl LUTm   Comments
--        4     16     -   16   16*RAM16X1S
--        5     16     -   32   16*RAM32X1S
--        6     16    18   64   32*RAM32X1S  Note: A(4) via F5MUX, A(5) via LUT
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity ram_1swar_gen is                 -- RAM, 1 sync w asyn r port
  generic (
    AWIDTH : positive :=  4;            -- address port width
    DWIDTH : positive := 16);           -- data port width
  port (
    CLK  : in slbit;                    -- clock
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address port
    DI   : in slv(DWIDTH-1 downto 0);   -- data in port
    DO   : out slv(DWIDTH-1 downto 0)   -- data out port
  );
end ram_1swar_gen;


architecture syn of ram_1swar_gen is
  constant memsize : positive := 2**AWIDTH;
  constant datzero : slv(DWIDTH-1 downto 0) := (others=>'0');
  type ram_type is array (memsize-1 downto 0) of slv (DWIDTH-1 downto 0);
  signal RAM : ram_type := (others=>datzero);

  attribute ram_style : string;
  attribute ram_style of RAM : signal is "distributed";

begin

  proc_clk: process (CLK)
  begin
    if rising_edge(CLK) then
      if WE = '1' then
        RAM(to_integer(unsigned(ADDR))) <= DI;
      end if;
    end if;
  end process proc_clk;

  DO <= RAM(to_integer(unsigned(ADDR)));

end syn;
