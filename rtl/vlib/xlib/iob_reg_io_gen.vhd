-- $Id: iob_reg_io_gen.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2008 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    iob_reg_io_gen - syn
-- Description:    Registered IOB, in/output, vector
--
-- Dependencies:   iob_keeper_gen                 [sim only]
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-05-22   149   1.0.4  use internally TE to match OBUFT T polarity
-- 2008-05-22   148   1.0.3  remove UNISIM prim's; PULL implemented only for sim
-- 2008-05-18   147   1.0.2  add PULL generic, to enable PULL-UP,-DOWN or KEEPER
-- 2007-12-16   101   1.0.1  add INIT generic ports
-- 2007-12-08   100   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity iob_reg_io_gen is                -- registered IOB, in/output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INITI : slbit := '0';               -- initial state ( in flop)
    INITO : slbit := '0';               -- initial state (out flop)
    INITE : slbit := '0';               -- initial state ( oe flop)
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    CLK  : in slbit;                    -- clock
    CEI  : in slbit := '1';             -- clock enable ( in flops)
    CEO  : in slbit := '1';             -- clock enable (out flops)
    OE   : in slbit;                    -- output enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data   (read from pad)
    DO   : in slv(DWIDTH-1 downto 0);   -- output data  (write  to pad)
    PAD  : inout slv(DWIDTH-1 downto 0) -- i/o pad
  );
end iob_reg_io_gen;


architecture syn of iob_reg_io_gen is

  signal R_TE  : slbit := not INITE;
  signal R_DI  : slv(DWIDTH-1 downto 0) := (others=>INITI);
  signal R_DO  : slv(DWIDTH-1 downto 0) := (others=>INITO);

  constant all_z : slv(DWIDTH-1 downto 0) := (others=>'Z');
  constant all_l : slv(DWIDTH-1 downto 0) := (others=>'L');
  constant all_h : slv(DWIDTH-1 downto 0) := (others=>'H');
  
  attribute iob : string;
  attribute iob of R_TE : signal is "true";
  attribute iob of R_DI : signal is "true";
  attribute iob of R_DO : signal is "true";

begin

  assert PULL="NONE" or PULL="UP" or PULL="DOWN" or PULL="KEEP"
    report "assert(PULL): only NONE, UP, DOWN, OR KEEP supported"
    severity failure;
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      R_TE <= not OE;
      if CEI = '1' then
        R_DI <= to_x01(PAD);
      end if;
      if CEO = '1' then
        R_DO <= DO;
      end if;
    end if;
  end process proc_regs;

  proc_comb: process (R_TE, R_DO)
  begin
    if R_TE = '1' then
      PAD <= all_z;
    else
      PAD <= R_DO;
    end if;
  end process proc_comb;

  DI <= R_DI;

-- Note: PULL (UP, DOWN or KEEP) is only implemented for simulation, not
--       for inference in synthesis. Use pin attributes in UCF's or use
--       iob_reg_io_gen_unisim
--
-- synthesis translate_off

  PULL_UP: if PULL = "UP" generate
    PAD <= all_h;
  end generate PULL_UP;
  
  PULL_DOWN: if PULL = "DOWN" generate
    PAD <= all_l;
  end generate PULL_DOWN;
  
  PULL_KEEP: if PULL = "KEEP" generate
    KEEPER : iob_keeper_gen
      generic map (DWIDTH => DWIDTH)
      port map    (PAD => PAD);
  end generate PULL_KEEP;

-- synthesis translate_on

end syn;
