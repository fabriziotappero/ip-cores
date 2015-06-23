-- $Id: tst_serloop_hiomap.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    tst_serloop_hiomap - syn
-- Description:    default human I/O mapper 
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-09   437   1.0.2  rename serport stat->moni port
-- 2011-11-16   426   1.0.1  setup leds and dps
-- 2011-11-05   420   1.0    Initial version
------------------------------------------------------------------------------
--
-- Usage of Switches, Buttons, LEDs:
--
--    BTN(3):   -- unused --
--       (2):   -- unused --
--       (1):   load enables from SWI(7:4)
--                SWI(7) -> ENAFTDI
--                SWI(6) -> ENATHROTTLE
--                SWI(5) -> ENAESC
--                SWI(4) -> ENAXON
--       (0):   reset state  [!! decoded by top level design !!]
--
--    SWI(7:4)  select display or enable pattern (when BTN(1) pressed)
--       (3)    -- unused --
--       (2:1): mode  00  idle
--                    01  rxblast
--                    10  txblast
--                    11  loop
--    SWI(0)    0 -> main board RS232 port
--              1 -> Pmod1 RS232 port
--
--    LED(7)    enaesc
--       (6)    enaxon
--       (5)    rxfecnt > 0                     (frame error)
--       (4)    rxoecnt > 0                     (overrun error)
--       (3)    rxsecnt > 0                     (sequence error)
--       (2)    abact                           (shows ab activity)
--       (1)    (not rxok) or (not txok)        (shows back preasure)
--       (0)    rxact or txact                  (shows activity)
--
--    DSP       data as selected by SWI(7:4)
--                0000 -> rxfecnt
--                0001 -> rxoecnt
--                0010 -> rxsecnt
--                0100 -> rxcnt.l
--                0101 -> rxcnt.h
--                0110 -> txcnt.l
--                0111 -> txcnt.h
--                1000 -> rxokcnt
--                1001 -> txokcnt
--                1010 -> rxuicnt,rxuidat
--                1111 -> abclkdiv
--
--    DP(3):    not SER_MONI.txok   (shows tx back preasure)
--      (2):    SER_MONI.txact      (shows tx activity)
--      (1):    not SER_MONI.rxok   (shows rx back preasure)
--      (0):    SER_MONI.rxact      (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.tst_serlooplib.all;

-- ----------------------------------------------------------------------------

entity tst_serloop_hiomap is            -- default human I/O mapper 
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    HIO_CNTL : out hio_cntl_type;       -- tester controls from hio
    HIO_STAT : in hio_stat_type;        -- tester status to diaplay by hio
    SER_MONI : in serport_moni_type;    -- serport monitor to display by hio
    SWI : in slv8;                      -- switch settings
    BTN : in slv4;                      -- button settings
    LED : out slv8;                     -- led data
    DSP_DAT : out slv16;                -- display data
    DSP_DP : out slv4                   -- display decimal points
  );
end tst_serloop_hiomap;

architecture syn of tst_serloop_hiomap is

  type regs_type is record
    enaxon : slbit;                     -- enable xon/xoff handling
    enaesc : slbit;                     -- enable xon/xoff escaping
    enathrottle : slbit;                -- enable 1 msec tx throttling
    enaftdi : slbit;                    -- enable ftdi flush handling
    dspdat : slv16;                     -- display data
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0','0','0',                    -- enaxon,enaesc,enathrottle,enaftdi
    (others=>'0')                       -- dspdat

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

  proc_next: process (R_REGS, HIO_STAT, SER_MONI, SWI, BTN)    

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

    -- handle BTN(1) "load enables" press

    if BTN(1) = '1' then
      n.enaxon  := SWI(4);
      n.enaesc  := SWI(5);
      n.enathrottle := SWI(6);
      n.enaftdi := SWI(7);
    end if;

    -- setup tester controls
    
    icntl.mode := SWI(2 downto 1);
    icntl.enaxon  := r.enaxon;
    icntl.enaesc  := r.enaesc;
    icntl.enathrottle := r.enathrottle;
    icntl.enaftdi := r.enaftdi;
    
    -- setup leds
    iled(7) := icntl.enaesc;
    iled(6) := icntl.enaxon;
    if unsigned(HIO_STAT.rxfecnt) > 0 then iled(5) := '1'; end if;
    if unsigned(HIO_STAT.rxoecnt) > 0 then iled(4) := '1'; end if;
    if unsigned(HIO_STAT.rxsecnt) > 0 then iled(3) := '1'; end if;
    iled(2) := SER_MONI.abact;
    iled(1) := (not SER_MONI.rxok) or (not SER_MONI.txok);
    iled(0) := SER_MONI.rxact or SER_MONI.txact;
    
    -- setup display data
    
    case SWI(7 downto 4) is
      when "0000" => idat := HIO_STAT.rxfecnt;
      when "0001" => idat := HIO_STAT.rxoecnt;
      when "0010" => idat := HIO_STAT.rxsecnt;
      when "0100" => idat := HIO_STAT.rxcnt(15 downto 0);
      when "0101" => idat := HIO_STAT.rxcnt(31 downto 16);
      when "0110" => idat := HIO_STAT.txcnt(15 downto 0);
      when "0111" => idat := HIO_STAT.txcnt(31 downto 16);
      when "1000" => idat := HIO_STAT.rxokcnt;
      when "1001" => idat := HIO_STAT.txokcnt;
      when "1010" => idat := HIO_STAT.rxuicnt & HIO_STAT.rxuidat;
      when "1111" => idat := SER_MONI.abclkdiv;
      when others => null;
    end case;
    n.dspdat := idat;

    -- setup display decimal points

    idp(3) := not SER_MONI.txok;        -- tx back preasure
    idp(2) := SER_MONI.txact;           -- tx activity
    idp(1) := not SER_MONI.rxok;        -- rx back preasure
    idp(0) := SER_MONI.rxact;           -- rx activity

    N_REGS <= n;

    HIO_CNTL <= icntl;
    LED      <= iled;
    DSP_DAT  <= r.dspdat;
    DSP_DP   <= idp;
      
  end process proc_next;
  
end syn;
