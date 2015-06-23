-- $Id: sn_7segctl.vhd 637 2015-01-25 18:36:40Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sn_7segctl - syn
-- Description:    7 segment display controller (for s3board,nexys,basys)
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-01-24   637 14.7  131013 xc6slx16-2     9   27    0   16 s  3.1 ns DC=3
-- 2015-01-24   637 14.7  131013 xc6slx16-2     8   19    0    9 s  3.1 ns DC=2
-- 2015-01-24   410 14.7  131013 xc6slx16-2     8   19    0    8 s  3.1 ns

-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-24   637   1.3    renamed from sn_4x7segctl; add DCWIDTH,
--                           allow 4(DC=2) or 8(DC=3) digit display
-- 2011-09-17   410   1.2.1  now numeric_std clean
-- 2011-07-30   400   1.2    digit dark in last quarter (not 16 clocks)
-- 2011-07-08   390   1.1.2  renamed from s3_dispdrv
-- 2010-04-17   278   1.1.1  renamed from dispdrv
-- 2010-03-29   272   1.1    add all ANO off time to allow to driver turn-off
--                           delay and to avoid cross talk between digits
-- 2007-12-16   101   1.0.1  use _N for active low
-- 2007-09-16    83   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity sn_7segctl is                    -- 7 segment display controller
  generic (
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    CDWIDTH : positive := 6);           -- clk divider width (must be >= 5)
  port (
    CLK : in slbit;                     -- clock
    DIN : in slv(4*(2**DCWIDTH)-1 downto 0);  -- data                16 or 32
    DP : in slv((2**DCWIDTH)-1 downto 0);     -- decimal points       4 or  8
    ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- anodes    (act.low)  4 or  8
    SEG_N : out slv8                          -- segements (act.low)
  );
end sn_7segctl;

architecture syn of sn_7segctl is
  type regs_type is record
    cdiv : slv(CDWIDTH-1 downto 0);     -- clock divider counter
    dcnt : slv(DCWIDTH-1 downto 0);     -- digit counter
  end record regs_type;

  constant regs_init : regs_type := (
    slv(to_unsigned(0,CDWIDTH)),        -- cdiv
    slv(to_unsigned(0,DCWIDTH))         -- dcnt
  );

  type hex2segtbl_type is array (0 to 15) of slv7;

  constant hex2segtbl : hex2segtbl_type :=
     ("0111111",                        -- 0: "0000"
      "0000110",                        -- 1: "0001"
      "1011011",                        -- 2: "0010"
      "1001111",                        -- 3: "0011"
      "1100110",                        -- 4: "0100"
      "1101101",                        -- 5: "0101"
      "1111101",                        -- 6: "0110"
      "0000111",                        -- 7: "0111"
      "1111111",                        -- 8: "1000"
      "1101111",                        -- 9: "1001"
      "1110111",                        -- a: "1010"
      "1111100",                        -- b: "1011"
      "0111001",                        -- c: "1100"
      "1011110",                        -- d: "1101"
      "1111001",                        -- e: "1110"
      "1110001"                         -- f: "1111"
      );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  signal CHEX : slv4 := (others=>'0');     -- current hex number
  signal CDP  : slbit := '0';              -- current decimal point

begin

  assert DCWIDTH=2 or DCWIDTH=3
  report "assert(DCWIDTH=2 or DCWIDTH=3): unsupported DCWIDTH"
  severity FAILURE;

  assert CDWIDTH >= 5
  report "assert(CDWIDTH >= 5): CDWIDTH too small"
  severity FAILURE;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;

  end process proc_regs;


  proc_next: process (R_REGS, CHEX, CDP)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable cano : slv((2**DCWIDTH)-1 downto 0) := (others=>'0');
   
  begin

    r := R_REGS;
    n := R_REGS;

    n.cdiv := slv(unsigned(r.cdiv) - 1);
    if unsigned(r.cdiv) = 0 then
      n.dcnt := slv(unsigned(r.dcnt) + 1);
    end if;

    -- the logic below ensures that the anode PNP driver transistor is switched
    -- off in the last quarter of the digit cycle.This  prevents 'cross talk'
    -- between digits due to transistor turn off delays.
    -- For a nexys2 board at 50 MHz observed:
    --   no or 4 cycles gap well visible cross talk
    --   with 8 cycles still some weak cross talk
    --   with 16 cycles none is visible.
    --   --> The turn-off delay of the anode driver PNP's this therefore
    --       larger 160 ns and below 320 ns.
    -- As consquence CDWIDTH should be at least 6 for 50 MHz and 7 for 100 MHz.

    cano := (others=>'1');
    if r.cdiv(CDWIDTH-1 downto CDWIDTH-2) /= "00" then
      cano(to_integer(unsigned(r.dcnt))) := '0';
    end if;
    
    N_REGS <= n;

    ANO_N <= cano;
    SEG_N <= not (CDP & hex2segtbl(to_integer(unsigned(CHEX))));

  end process proc_next;

  proc_mux: process (R_REGS, DIN, DP)
  begin
    CDP     <= DP(to_integer(unsigned(R_REGS.dcnt)));
    CHEX(0) <= DIN(0+4*to_integer(unsigned(R_REGS.dcnt)));
    CHEX(1) <= DIN(1+4*to_integer(unsigned(R_REGS.dcnt)));
    CHEX(2) <= DIN(2+4*to_integer(unsigned(R_REGS.dcnt)));
    CHEX(3) <= DIN(3+4*to_integer(unsigned(R_REGS.dcnt)));
  end process proc_mux;
  
end syn;
