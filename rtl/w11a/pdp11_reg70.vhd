-- $Id: pdp11_reg70.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2008-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_reg70 - syn
-- Description:    pdp11: 11/70 system registers
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-30   670   1.1.2  rename sys70 -> reg70
-- 2011-11-18   427   1.1.1  now numeric_std clean
-- 2010-10-17   333   1.1    use ibus V2 interface
-- 2008-08-22   161   1.0.1  use iblib
-- 2008-04-20   137   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;
use work.iblib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_reg70 is                   -- 11/70 memory system registers
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_reg70;

architecture syn of pdp11_reg70 is
  
  constant ibaddr_mbrk   : slv16 := slv(to_unsigned(8#177770#,16));
  constant ibaddr_sysid  : slv16 := slv(to_unsigned(8#177764#,16));

  type regs_type is record              -- state registers
    ibsel_mbrk : slbit;                 -- ibus select mbrk
    ibsel_sysid : slbit;                -- ibus select sysid
    mbrk    : slv8;                     -- status of mbrk register
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0',                            -- ibsel_*
    mbrk=>(others=>'0')                 -- mbrk
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

  proc_next: process (R_REGS, IB_MREQ)
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
    n.ibsel_mbrk  := '0';
    n.ibsel_sysid := '0';
    if IB_MREQ.aval = '1' then
      if IB_MREQ.addr = ibaddr_mbrk(12 downto 1) then
        n.ibsel_mbrk  := '1';
      end if;
      if IB_MREQ.addr = ibaddr_sysid(12 downto 1) then
        n.ibsel_sysid := '1';
      end if;
    end if;    
    
    -- ibus transactions
    if r.ibsel_mbrk = '1' then
      idout(r.mbrk'range) := r.mbrk;
    end if;
    if r.ibsel_sysid = '1' then
      idout := slv(to_unsigned(8#123456#,16));
    end if;

    if r.ibsel_mbrk='1' and ibw0='1' then
      n.mbrk := IB_MREQ.din(n.mbrk'range);
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= (r.ibsel_mbrk or r.ibsel_sysid) and ibreq;
    IB_SRES.busy <= '0';

  end process proc_next;
    
end syn;
