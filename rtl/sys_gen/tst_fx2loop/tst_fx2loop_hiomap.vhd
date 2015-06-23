-- $Id: tst_fx2loop_hiomap.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011-2012 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tst_fx2loop_hiomap - syn
-- Description:    default human I/O mapper 
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-01-15   453   1.0.2  re-arrange DP,DSP usage
-- 2012-01-03   449   1.0.1  use new fx2ctl_moni layout
-- 2011-12-26   445   1.0    Initial version 
------------------------------------------------------------------------------
--
-- Usage of Switches, Buttons, LEDs:
--
--    BTN(3)    -- unused --
--       (2)    -- unused --
--       (1)    -- unused --
--       (0)    reset state  [!! decoded by top level design !!]
--
--    SWI(7:5)  select display 
--       (4)    -- unused --
--       (3)    throttle
--       (2)    tx2blast
--       (1:0)  mode  00  idle
--                    01  rxblast
--                    10  txblast
--                    11  loop
--
--    LED(7)    MONI.fifo_ep4
--       (6)    MONI.fifo_ep6
--       (5)    MONI.fifo_ep8
--       (4)    MONI.flag_ep4_empty
--       (3)    MONI.flag_ep4_almost
--       (2)    MONI.flag_ep6_full
--       (1)    MONI.flag_ep6_almost
--       (0)    rxsecnt > 0                     (sequence error)
--
--    DSP       data as selected by SWI(7:5)
--                000 -> rxsecnt
--                001 -> -- unused -- (display ffff)
--                010 -> rxcnt.l
--                011 -> rxcnt.h
--                100 -> txcnt.l
--                101 -> txcnt.h
--                110 -> tx2cnt.l
--                111 -> tx2cnt.h
--
--    DP(3)     FX2_TXBUSY      (shows tx back preasure)
--      (2)     FX2_MONI.slwr   (shows tx activity)
--      (1)     FX2_RXHOLD      (shows rx back preasure)
--      (0)     FX2_MONI.slrd   (shows rx activity)
--
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.fx2lib.all;
use work.tst_fx2looplib.all;

-- ----------------------------------------------------------------------------

entity tst_fx2loop_hiomap is            -- default human I/O mapper 
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    HIO_CNTL : out hio_cntl_type;       -- tester controls from hio
    HIO_STAT : in hio_stat_type;        -- tester status to diaplay by hio
    FX2_MONI : in fx2ctl_moni_type;     -- fx2ctl monitor to display by hio
    SWI : in slv8;                      -- switch settings
    BTN : in slv4;                      -- button settings
    LED : out slv8;                     -- led data
    DSP_DAT : out slv16;                -- display data
    DSP_DP : out slv4                   -- display decimal points
  );
end tst_fx2loop_hiomap;

architecture syn of tst_fx2loop_hiomap is

  type regs_type is record
    dspdat : slv16;                     -- display data
    dummy : slbit;                      -- <remove when 2nd signal added...>
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- dspdat
    '0'
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, HIO_STAT, FX2_MONI, SWI, BTN)    

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable icntl : hio_cntl_type := hio_cntl_init;
    variable iled  : slv8  := (others=>'0');
    variable idat  : slv16 := (others=>'0');
    variable idp   : slv4  := (others=>'0');

  begin

    r := R_REGS;
    n := R_REGS;

    icntl := hio_cntl_init;
    iled  := (others=>'0');
    idat  := (others=>'0');
    idp   := (others=>'0');

    -- setup tester controls
    
    icntl.mode := SWI(1 downto 0);
    icntl.tx2blast := SWI(2);
    icntl.throttle := SWI(3);
    
    -- setup leds
    iled(7) := FX2_MONI.fifo_ep4;
    iled(6) := FX2_MONI.fifo_ep6;
    iled(5) := FX2_MONI.fifo_ep8;
    iled(4) := FX2_MONI.flag_ep4_empty;
    iled(3) := FX2_MONI.flag_ep4_almost;
    iled(2) := FX2_MONI.flag_ep6_full;
    iled(1) := FX2_MONI.flag_ep6_almost;
    if unsigned(HIO_STAT.rxsecnt) > 0 then iled(0) := '1'; end if;
    
    -- setup display data
    
    case SWI(7 downto 5) is
      when "000" => idat := HIO_STAT.rxsecnt;
      when "001" => idat := (others=>'1');
      when "010" => idat := HIO_STAT.rxcnt(15 downto 0);
      when "011" => idat := HIO_STAT.rxcnt(31 downto 16);
      when "100" => idat := HIO_STAT.txcnt(15 downto 0);
      when "101" => idat := HIO_STAT.txcnt(31 downto 16);
      when "110" => idat := HIO_STAT.tx2cnt(15 downto 0);
      when "111" => idat := HIO_STAT.tx2cnt(31 downto 16);
      when others => null;
    end case;
    n.dspdat := idat;

    -- setup display decimal points

    idp(3) := HIO_STAT.txbusy;          -- tx back preasure
    idp(2) := FX2_MONI.slwr;            -- tx activity
    idp(1) := HIO_STAT.rxhold;          -- rx back preasure
    idp(0) := FX2_MONI.slrd;            -- rx activity

    N_REGS <= n;

    HIO_CNTL <= icntl;
    LED      <= iled;
    DSP_DAT  <= r.dspdat;
    DSP_DP   <= idp;
      
  end process proc_next;
  
end syn;
