-- $Id: tst_serloop.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    tst_serloop - syn
-- Description:    simple stand-alone tester for serport components
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-10   438   1.0.2  clr fecnt when abact; add rxui(cnt|dat) regs
-- 2011-12-09   437   1.0.1  rename serport stat->moni port
-- 2011-11-06   420   1.0    Initial version
-- 2011-10-14   416   0.5    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.tst_serlooplib.all;

-- ----------------------------------------------------------------------------

entity tst_serloop is                   -- tester for serport components
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- msec pulse
    HIO_CNTL : in hio_cntl_type;        -- humanio controls
    HIO_STAT : out hio_stat_type;       -- humanio status
    SER_MONI : in serport_moni_type;    -- serport monitor
    RXDATA : in slv8;                   -- receiver data out
    RXVAL : in slbit;                   -- receiver data valid
    RXHOLD : out slbit;                 -- receiver data hold
    TXDATA : out slv8;                  -- transmit data in
    TXENA : out slbit;                  -- transmit data enable
    TXBUSY : in slbit                   -- transmit busy
  );
end tst_serloop;

architecture syn of tst_serloop is

  type regs_type is record
    rxdata : slv8;                      -- next rx char
    txdata : slv8;                      -- next tx char
    rxfecnt : slv16;                    -- rx frame error counter
    rxoecnt : slv16;                    -- rx overrun error counter
    rxsecnt : slv16;                    -- rx sequence error counter
    rxcnt : slv32;                      -- rx char counter
    txcnt : slv32;                      -- tx char counter
    rxuicnt : slv8;                     -- rx unsolicited input counter
    rxuidat : slv8;                     -- rx unsolicited input data
    rxokcnt : slv16;                    -- rxok 1->0 transition counter
    txokcnt : slv16;                    -- txok 1->0 transition counter
    rxok_1 : slbit;                     -- rxok last cycle
    txok_1 : slbit;                     -- txok last cycle
    rxthrottle : slbit;                 -- rx throttle flag
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- rxdata
    (others=>'0'),                      -- txdata
    (others=>'0'),                      -- rxfecnt
    (others=>'0'),                      -- rxoecnt
    (others=>'0'),                      -- rxsecnt
    (others=>'0'),                      -- rxcnt
    (others=>'0'),                      -- txcnt
    (others=>'0'),                      -- rxuicnt
    (others=>'0'),                      -- rxuidat
    (others=>'0'),                      -- rxokcnt
    (others=>'0'),                      -- txokcnt
    '0','0',                            -- rxok_1,txok_1
    '0'                                 -- rxthrottle
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

  proc_next: process (R_REGS, CE_MSEC, HIO_CNTL, SER_MONI,
                      RXDATA, RXVAL, TXBUSY)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irxhold : slbit := '1';
    variable itxena  : slbit := '0';
    variable itxdata : slv8 := (others=>'0');
    variable skipxon : slbit := '0';

    function nextchar(skipxon: in slbit; data: in slv8) return slv8 is
      variable inc : slv8 := (others=>'0');
    begin
      inc := "00000001";
      if skipxon='1' and (data=c_serport_xon or data=c_serport_xoff) then
        inc := "00000010";
      end if;
      return slv(unsigned(data)+unsigned(inc));
    end function nextchar; 
    
  begin
    r := R_REGS;
    n := R_REGS;

    irxhold := '1';
    itxena  := '0';

    itxdata  := RXDATA;
    if HIO_CNTL.mode = c_mode_txblast then
      itxdata := r.txdata;
    end if;

    skipxon := '0';
    if HIO_CNTL.enaxon='1' and HIO_CNTL.enaesc='0'  then
      skipxon := '1';
    end if;

    if HIO_CNTL.enathrottle = '1' then
      if CE_MSEC = '1' then
        n.rxthrottle := not r.rxthrottle;
      end if;
    else
      n.rxthrottle := '0';
    end if;

    
    case HIO_CNTL.mode is
      when c_mode_idle =>
        null;

      when c_mode_rxblast =>
        if RXVAL='1' and r.rxthrottle='0' then
          irxhold := '0';
          if RXDATA /= r.rxdata then
            n.rxsecnt := slv(unsigned(r.rxsecnt) + 1);
          end if;
          n.rxdata := nextchar(skipxon, RXDATA);
        end if;
        
      when c_mode_txblast =>
        if TXBUSY = '0' then
          itxena := '1';
          n.txdata := nextchar(skipxon, r.txdata);
        end if;
        irxhold := '0';
        if RXVAL = '1' then
          n.rxuicnt := slv(unsigned(r.rxuicnt) + 1);
          n.rxuidat := RXDATA;
        end if;
        
      when c_mode_loop =>
        if RXVAL='1' and r.rxthrottle='0' and TXBUSY = '0' then
          irxhold := '0';
          itxena  := '1';
        end if;
        
      when others => null;
    end case;

    
    if SER_MONI.abact = '1' then        -- if auto bauder active 
      n.rxfecnt := (others=>'0');         -- reset frame error counter
    else                                -- otherwise
      if SER_MONI.rxerr = '1' then        -- count rx frame errors
        n.rxfecnt := slv(unsigned(r.rxfecnt) + 1);
      end if;
    end if;
    
    if SER_MONI.rxovr = '1' then
      n.rxoecnt := slv(unsigned(r.rxoecnt) + 1);
    end if;
    
    if RXVAL='1' and irxhold='0' then
      n.rxcnt := slv(unsigned(r.rxcnt) + 1);
    end if;
    
    if itxena = '1' then
      n.txcnt := slv(unsigned(r.txcnt) + 1);
    end if;

    n.rxok_1 := SER_MONI.rxok;
    n.txok_1 := SER_MONI.txok;

    if SER_MONI.rxok='0' and r.rxok_1='1' then
      n.rxokcnt := slv(unsigned(r.rxokcnt) + 1);
    end if;
    if SER_MONI.txok='0' and r.txok_1='1' then
      n.txokcnt := slv(unsigned(r.txokcnt) + 1);
    end if;
    
    N_REGS <= n;

    RXHOLD <= irxhold;
    TXENA  <= itxena;
    TXDATA <= itxdata;

    HIO_STAT.rxfecnt <= r.rxfecnt;
    HIO_STAT.rxoecnt <= r.rxoecnt;
    HIO_STAT.rxsecnt <= r.rxsecnt;
    HIO_STAT.rxcnt   <= r.rxcnt;
    HIO_STAT.txcnt   <= r.txcnt;
    HIO_STAT.rxuicnt <= r.rxuicnt;
    HIO_STAT.rxuidat <= r.rxuidat;
    HIO_STAT.rxokcnt <= r.rxokcnt;
    HIO_STAT.txokcnt <= r.txokcnt;

  end process proc_next;
    
end syn;
