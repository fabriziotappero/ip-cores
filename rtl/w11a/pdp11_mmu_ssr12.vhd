-- $Id: pdp11_mmu_ssr12.vhd 677 2015-05-09 21:52:32Z mueller $
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
-- Module Name:    pdp11_mmu_ssr12 - syn
-- Description:    pdp11: mmu register ssr1 and ssr2
--
-- Dependencies:   ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  use ib_sel
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2009-05-30   220   1.1.4  final removal of snoopers (were already commented)
-- 2008-08-22   161   1.1.3  rename ubf_ -> ibf_; use iblib
-- 2008-03-02   121   1.1.2  remove snoopers
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_mmu_ssr12 is               -- mmu register ssr1 and ssr2
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    TRACE : in slbit;                   -- trace enable
    MONI : in mmu_moni_type;            -- MMU monitor port data
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_mmu_ssr12;

architecture syn of pdp11_mmu_ssr12 is

  constant ibaddr_ssr1 : slv16 := slv(to_unsigned(8#177574#,16));
  constant ibaddr_ssr2 : slv16 := slv(to_unsigned(8#177576#,16));
  
  subtype ssr1_ibf_rb_delta is integer range 15 downto 11;
  subtype ssr1_ibf_rb_num is integer range 10 downto 8;
  subtype ssr1_ibf_ra_delta is integer range 7 downto 3;
  subtype ssr1_ibf_ra_num is integer range 2 downto 0;

  signal IBSEL_SSR1 : slbit := '0';
  signal IBSEL_SSR2 : slbit := '0';
  signal R_SSR1 : mmu_ssr1_type := mmu_ssr1_init;
  signal R_SSR2 : slv16 := (others=>'0');
  signal N_SSR1 : mmu_ssr1_type := mmu_ssr1_init;
  signal N_SSR2 : slv16 := (others=>'0');

begin

  SEL_SSR1 : ib_sel
    generic map (
      IB_ADDR => ibaddr_ssr1)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_SSR1
    );
  SEL_SSR2 : ib_sel
    generic map (
      IB_ADDR => ibaddr_ssr2)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_SSR2
    );

  proc_ibres : process (IBSEL_SSR1, IBSEL_SSR2, IB_MREQ, R_SSR1, R_SSR2)
    variable ssr1out : slv16 := (others=>'0');
    variable ssr2out : slv16 := (others=>'0');
  begin

    ssr1out := (others=>'0');
    if IBSEL_SSR1 = '1' then
      ssr1out(ssr1_ibf_rb_delta) := R_SSR1.rb_delta;
      ssr1out(ssr1_ibf_rb_num)   := R_SSR1.rb_num;
      ssr1out(ssr1_ibf_ra_delta) := R_SSR1.ra_delta;
      ssr1out(ssr1_ibf_ra_num)   := R_SSR1.ra_num;
    end if;
    
    ssr2out := (others=>'0');
    if IBSEL_SSR2 = '1' then
      ssr2out := R_SSR2;
    end if;
     
    IB_SRES.dout <= ssr1out or ssr2out;
    IB_SRES.ack  <= (IBSEL_SSR1 or IBSEL_SSR2) and
                    (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';

  end process proc_ibres;

  proc_regs : process (CLK)
  begin
    if rising_edge(CLK) then
      R_SSR1 <= N_SSR1;
      R_SSR2 <= N_SSR2;
    end if;
  end process proc_regs;

  proc_comb : process (CRESET, IBSEL_SSR1, IB_MREQ,
                       R_SSR1, R_SSR2, TRACE, MONI)

    variable nssr1 : mmu_ssr1_type := mmu_ssr1_init;
    variable nssr2 : slv16 := (others=>'0');
    variable delta : slv5 := (others=>'0');
    variable use_rb : slbit := '0';
    
  begin

    nssr1 := R_SSR1;
    nssr2 := R_SSR2;
    delta := "0" & MONI.delta;

    use_rb := '0';
    if MONI.regnum/=nssr1.ra_num and unsigned(nssr1.ra_delta)/=0 then
      use_rb := '1';
    end if;

    if CRESET = '1' then
      nssr1 := mmu_ssr1_init;
      nssr2 := (others=>'0');
      
    elsif IBSEL_SSR1='1' and IB_MREQ.we='1' then
      
      if IB_MREQ.be1 = '1' then
        nssr1.rb_delta := IB_MREQ.din(ssr1_ibf_rb_delta);
        nssr1.rb_num   := IB_MREQ.din(ssr1_ibf_rb_num);
      end if;
      if IB_MREQ.be0 = '1' then
        nssr1.ra_delta := IB_MREQ.din(ssr1_ibf_ra_delta);
        nssr1.ra_num   := IB_MREQ.din(ssr1_ibf_ra_num);
      end if;
      
    elsif TRACE = '1' then

      if MONI.istart = '1' then
        nssr1 := mmu_ssr1_init;
        nssr2 := MONI.pc;

      elsif MONI.regmod = '1' then
        if use_rb = '0' then
          nssr1.ra_num := MONI.regnum;
          if MONI.isdec = '0' then
            nssr1.ra_delta := slv(signed(nssr1.ra_delta) + signed(delta));
          else
            nssr1.ra_delta := slv(signed(nssr1.ra_delta) - signed(delta));
          end if;
        else
          nssr1.rb_num := MONI.regnum;
          if MONI.isdec = '0' then
            nssr1.rb_delta := slv(signed(nssr1.rb_delta) + signed(delta));
          else
            nssr1.rb_delta := slv(signed(nssr1.rb_delta) - signed(delta));
          end if;
        end if;
      end if;

    end if;

    N_SSR1 <= nssr1;
    N_SSR2 <= nssr2;

  end process proc_comb;  

end syn;
