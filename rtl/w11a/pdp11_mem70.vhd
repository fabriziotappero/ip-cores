-- $Id: pdp11_mem70.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2008-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_mem70 - syn
-- Description:    pdp11: 11/70 memory system registers
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.1.1  now numeric_std clean
-- 2010-10-17   333   1.1    use ibus V2 interface
-- 2008-08-22   161   1.0.2  rename ubf_ -> ibf_; use iblib
-- 2008-02-23   118   1.0.1  use sys_conf_mem_losize; rename CACHE_ENA->_FMISS
-- 2008-01-27   115   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_mem70 is                   -- 11/70 memory system registers
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    HM_ENA : in slbit;                  -- hit/miss enable
    HM_VAL : in slbit;                  -- hit/miss value
    CACHE_FMISS : out slbit;            -- cache force miss
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_mem70;

architecture syn of pdp11_mem70 is
  
  constant ibaddr_loaddr : slv16 := slv(to_unsigned(8#177740#,16));
  constant ibaddr_hiaddr : slv16 := slv(to_unsigned(8#177742#,16));
  constant ibaddr_syserr : slv16 := slv(to_unsigned(8#177744#,16));
  constant ibaddr_cntl   : slv16 := slv(to_unsigned(8#177746#,16));
  constant ibaddr_maint  : slv16 := slv(to_unsigned(8#177750#,16));
  constant ibaddr_hm     : slv16 := slv(to_unsigned(8#177752#,16));
  constant ibaddr_losize : slv16 := slv(to_unsigned(8#177760#,16));
  constant ibaddr_hisize : slv16 := slv(to_unsigned(8#177762#,16));

  subtype  cntl_ibf_frep    is integer range  5 downto  4;
  subtype  cntl_ibf_fmiss   is integer range  3 downto  2;
  constant cntl_ibf_disutrap : integer :=  1;
  constant cntl_ibf_distrap  : integer :=  0;

  type regs_type is record              -- state registers
    ibsel_cr : slbit;                   -- ibus select cntl
    ibsel_hm : slbit;                   -- ibus select hitmiss
    ibsel_ls : slbit;                   -- ibus select losize
    ibsel_nn : slbit;                   -- ibus select others
    hm_data : slv6;                     -- hit/miss: data
    cr_frep : slv2;                     -- cntl: force replacement bits
    cr_fmiss : slv2;                    -- cntl: force miss bits
    cr_disutrap: slbit;                 -- cntl: disable unibus trap
    cr_distrap: slbit;                  -- cntl: disable traps
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0','0','0',                    -- ibsel_*
    (others=>'0'),                      -- hm_data
    "00","00",                          -- cr_frep,_fmiss
    '0','0'                             -- dis(u)trap
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if CRESET = '1' then
        R_REGS <= regs_init;
     else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next: process (R_REGS, HM_ENA, HM_VAL, IB_MREQ)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibw0 : slbit := '0';
  begin
    
    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;

    -- ibus address decoder
    n.ibsel_cr := '0';
    n.ibsel_hm := '0';
    n.ibsel_ls := '0';
    n.ibsel_nn := '0';
    if IB_MREQ.aval = '1' then
      if IB_MREQ.addr = ibaddr_cntl(12 downto 1) then
        n.ibsel_cr := '1';
      end if;
      if IB_MREQ.addr = ibaddr_hm(12 downto 1) then
        n.ibsel_hm := '1';
      end if;
      if IB_MREQ.addr = ibaddr_losize(12 downto 1) then
        n.ibsel_ls := '1';
      end if;
      if IB_MREQ.addr=ibaddr_loaddr(12 downto 1) or
         IB_MREQ.addr=ibaddr_hiaddr(12 downto 1) or
         IB_MREQ.addr=ibaddr_syserr(12 downto 1) or
         IB_MREQ.addr=ibaddr_maint(12 downto 1)  or
         IB_MREQ.addr=ibaddr_hisize(12 downto 1) then
        n.ibsel_nn := '1';
      end if;
    end if;
    
    -- ibus transactions
    if r.ibsel_cr = '1' then
      idout(cntl_ibf_frep)     := r.cr_frep;
      idout(cntl_ibf_fmiss)    := r.cr_fmiss;
      idout(cntl_ibf_disutrap) := r.cr_disutrap;
      idout(cntl_ibf_distrap)  := r.cr_distrap;
    end if;
    if r.ibsel_hm = '1' then
      idout(r.hm_data'range)  := r.hm_data;
    end if;
    if r.ibsel_ls = '1' then
      idout := slv(to_unsigned(sys_conf_mem_losize,16));
    end if;

    if r.ibsel_cr='1' and ibw0='1' then
      n.cr_frep     := IB_MREQ.din(cntl_ibf_frep);
      n.cr_fmiss    := IB_MREQ.din(cntl_ibf_fmiss);
      n.cr_disutrap := IB_MREQ.din(cntl_ibf_disutrap);
      n.cr_distrap  := IB_MREQ.din(cntl_ibf_distrap);
    end if;

    if HM_ENA = '1' then
     n.hm_data := r.hm_data(r.hm_data'left-1 downto 0) & HM_VAL;
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= (r.ibsel_cr or r.ibsel_hm or
                     r.ibsel_ls or r.ibsel_nn) and ibreq;
    IB_SRES.busy <= '0';

  end process proc_next;

  CACHE_FMISS <= (R_REGS.cr_fmiss(1) or R_REGS.cr_fmiss(0));
    
end syn;
