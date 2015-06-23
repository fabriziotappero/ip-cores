-- $Id: iob_reg_o_gen.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    iob_reg_o_gen - syn
-- Description:    Registered IOB, output only, vector
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-12-16   101   1.0.1  add INIT generic port
-- 2007-12-08   100   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity iob_reg_o_gen is                 -- registered IOB, output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slv(DWIDTH-1 downto 0);   -- output data
    PAD  : out slv(DWIDTH-1 downto 0)   -- i/o pad
  );
end iob_reg_o_gen;


architecture syn of iob_reg_o_gen is

  signal R_DO  : slv(DWIDTH-1 downto 0) := (others=>INIT);

  attribute iob : string;
  attribute iob of R_DO : signal is "true";

begin

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if CE = '1' then
        R_DO <= DO;
      end if;
    end if;
  end process proc_regs;

  PAD <= R_DO;
  
end syn;
