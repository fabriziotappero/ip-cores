-- $Id: tst_fx2loop.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tst_fx2loop - syn
-- Description:    simple stand-alone tester for fx2lib components
--
-- Dependencies:   comlib/byte2word
--                 comlib/word2byte
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-24   510   1.0.1  fix sensitivity list of proc_next
-- 2012-01-15   453   1.0    Initial version
-- 2011-12-26   445   0.5    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;
use work.fx2lib.all;
use work.tst_fx2looplib.all;

-- ----------------------------------------------------------------------------

entity tst_fx2loop is                   -- tester for fx2lib components
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- msec pulse
    HIO_CNTL : in hio_cntl_type;        -- humanio controls
    HIO_STAT : out hio_stat_type;       -- humanio status
    FX2_MONI : in fx2ctl_moni_type;     -- fx2ctl monitor
    RXDATA : in slv8;                   -- receiver data out
    RXVAL : in slbit;                   -- receiver data valid
    RXHOLD : out slbit;                 -- receiver data hold
    TXDATA : out slv8;                  -- transmit data in
    TXENA : out slbit;                  -- transmit data enable
    TXBUSY : in slbit;                  -- transmit busy
    TX2DATA : out slv8;                 -- transmit 2 data in
    TX2ENA : out slbit;                 -- transmit 2 data enable
    TX2BUSY : in slbit                  -- transmit 2 busy
  );
end tst_fx2loop;

architecture syn of tst_fx2loop is

  type regs_type is record
    rxdata : slv16;                     -- next rx word
    txdata : slv16;                     -- next tx word
    tx2data : slv16;                    -- next tx2 word
    rxsecnt : slv16;                    -- rx sequence error counter
    rxcnt : slv32;                      -- rx word counter
    txcnt : slv32;                      -- tx word counter
    tx2cnt : slv32;                     -- tx2 word counter
    rxthrottle : slbit;                 -- rx throttle flag
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- rxdata
    (others=>'0'),                      -- txdata
    (others=>'0'),                      -- tx2data
    (others=>'0'),                      -- rxsecnt
    (others=>'0'),                      -- rxcnt
    (others=>'0'),                      -- txcnt
    (others=>'0'),                      -- tx2cnt
    '0'                                 -- rxthrottle
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal RXWDATA  : slv16 := (others=>'0');
  signal RXWVAL   : slbit := '0';
  signal RXWHOLD  : slbit := '0';
  signal RXODD    : slbit := '0';
  
  signal TXWDATA  : slv16 := (others=>'0');
  signal TXWENA   : slbit := '0';
  signal TXWBUSY  : slbit := '0';
  signal TXODD    : slbit := '0';
  signal TX2WDATA : slv16 := (others=>'0');
  signal TX2WENA  : slbit := '0';
  signal TX2WBUSY : slbit := '0';
  signal TX2ODD   : slbit := '0';

  signal RXHOLD_L : slbit := '0';       -- local copy of out port signal
  signal TXENA_L  : slbit := '0';       -- local copy of out port signal
  signal TX2ENA_L : slbit := '0';       -- local copy of out port signal
  signal CNTL_RESET_L : slbit := '0';   -- local copy of out port signal

begin

  CNTL_RESET_L <= '0';                  -- so far unused

  RXB2W : byte2word
    port map (
      CLK   => CLK,
      RESET => CNTL_RESET_L,
      DI    => RXDATA,
      ENA   => RXVAL,
      BUSY  => RXHOLD_L,
      DO    => RXWDATA,
      VAL   => RXWVAL,
      HOLD  => RXWHOLD,
      ODD   => RXODD
    );

  TX1W2B : word2byte
    port map (
      CLK   => CLK,
      RESET => CNTL_RESET_L,
      DI    => TXWDATA,
      ENA   => TXWENA,
      BUSY  => TXWBUSY,
      DO    => TXDATA,
      VAL   => TXENA_L,
      HOLD  => TXBUSY,
      ODD   => TXODD
    );

  TX2W2B : word2byte
    port map (
      CLK   => CLK,
      RESET => CNTL_RESET_L,
      DI    => TX2WDATA,
      ENA   => TX2WENA,
      BUSY  => TX2WBUSY,
      DO    => TX2DATA,
      VAL   => TX2ENA_L,
      HOLD  => TX2BUSY,
      ODD   => TX2ODD
    );

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

  proc_next: process (R_REGS, CE_MSEC, HIO_CNTL, FX2_MONI,
                      RXWDATA, RXWVAL, TXWBUSY, TX2WBUSY,
                      RXHOLD_L, TXBUSY, TX2BUSY)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irxwhold  : slbit := '1';
    variable itxwena   : slbit := '0';
    variable itxwdata  : slv16 := (others=>'0');
    variable itx2wena  : slbit := '0';
    
  begin
    r := R_REGS;
    n := R_REGS;

    irxwhold := '1';
    itxwena  := '0';
    itxwdata := RXWDATA;
    itx2wena := '0';

    if HIO_CNTL.throttle = '1' then
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
        if RXWVAL='1' and r.rxthrottle='0' then
          irxwhold := '0';
          if RXWDATA /= r.rxdata then
            n.rxsecnt := slv(unsigned(r.rxsecnt) + 1);
          end if;
          n.rxdata := slv(unsigned(RXWDATA) + 1);
        end if;
        
      when c_mode_txblast =>
        itxwdata := r.txdata;
        if TXWBUSY = '0' then
          itxwena := '1';
          n.txdata := slv(unsigned(r.txdata) + 1);
        end if;
        irxwhold := '0';
        
      when c_mode_loop =>
        itxwdata := RXWDATA;
        if RXWVAL='1' and r.rxthrottle='0' and TXWBUSY = '0' then
          irxwhold := '0';
          itxwena  := '1';
        end if;
        
      when others => null;
    end case;

    if HIO_CNTL.tx2blast = '1' then
      if TX2WBUSY = '0' then
        itx2wena := '1';
        n.tx2data := slv(unsigned(r.tx2data) + 1);
      end if;
    end if;
    
    if RXWVAL='1' and irxwhold='0' then
      n.rxcnt := slv(unsigned(r.rxcnt) + 1);
    end if;
    
    if itxwena = '1' then
      n.txcnt := slv(unsigned(r.txcnt) + 1);
    end if;

    if itx2wena = '1' then
      n.tx2cnt := slv(unsigned(r.tx2cnt) + 1);
    end if;
    
    N_REGS <= n;

    RXWHOLD  <= irxwhold;
    TXWENA   <= itxwena;
    TXWDATA  <= itxwdata;
    TX2WENA  <= itx2wena;
    TX2WDATA <= r.tx2data;

    HIO_STAT.rxhold  <= RXHOLD_L;
    HIO_STAT.txbusy  <= TXBUSY;
    HIO_STAT.tx2busy <= TX2BUSY;
    HIO_STAT.rxsecnt <= r.rxsecnt;
    HIO_STAT.rxcnt   <= r.rxcnt;
    HIO_STAT.txcnt   <= r.txcnt;
    HIO_STAT.tx2cnt  <= r.tx2cnt;

  end process proc_next;

  RXHOLD  <= RXHOLD_L;
  TXENA   <= TXENA_L;
  TX2ENA  <= TX2ENA_L;
 
end syn;
