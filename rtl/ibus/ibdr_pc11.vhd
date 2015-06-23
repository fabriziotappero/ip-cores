-- $Id: ibdr_pc11.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2009-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibdr_pc11 - syn
-- Description:    ibus dev(rem): PC11
--
-- Dependencies:   -
-- Test bench:     xxdp: zpcae0
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4    26   97    0   57 s  6.0
-- 2009-06-28   230 10.1.03 K39  xc3s1000-4    25   92    0   54 s  4.9
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-05-04   515   1.3    BUGFIX: r.rbuf was immediately cleared ! Was broken
--                             since ibus V2 update, never tested afterwards...
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  rename RRI_LAM->RB_LAM;
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-06-28   230   1.0    prdy now inits to '1'; setting err bit in csr now
--                           causes interrupt, if enabled; validated with zpcae0
-- 2009-06-01   221   0.9    Initial version (untested)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_pc11 is                     -- ibus dev(rem): PC11
                                        -- fixed address: 177550
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_PTR : out slbit;             -- interrupt request, reader
    EI_REQ_PTP : out slbit;             -- interrupt request, punch
    EI_ACK_PTR : in slbit;              -- interrupt acknowledge, reader
    EI_ACK_PTP : in slbit               -- interrupt acknowledge, punch
  );
end ibdr_pc11;

architecture syn of ibdr_pc11 is

  constant ibaddr_pc11 : slv16 := slv(to_unsigned(8#177550#,16));

  constant ibaddr_rcsr : slv2 := "00";  -- rcsr address offset
  constant ibaddr_rbuf : slv2 := "01";  -- rbuf address offset
  constant ibaddr_pcsr : slv2 := "10";  -- pcsr address offset
  constant ibaddr_pbuf : slv2 := "11";  -- pbuf address offset
  
  constant rcsr_ibf_rerr :  integer := 15;
  constant rcsr_ibf_rbusy : integer := 11;
  constant rcsr_ibf_rdone : integer :=  7;
  constant rcsr_ibf_rie :   integer :=  6;
  constant rcsr_ibf_renb :  integer :=  0;
  
  constant pcsr_ibf_perr :  integer := 15;
  constant pcsr_ibf_prdy :  integer :=  7;
  constant pcsr_ibf_pie :   integer :=  6;

  constant pbuf_ibf_pval :  integer :=  8;
  constant pbuf_ibf_rbusy : integer :=  9;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    rerr : slbit;                       -- rcsr: reader error
    rbusy : slbit;                      -- rcsr: reader busy
    rdone : slbit;                      -- rcsr: reader done
    rie : slbit;                        -- rcsr: reader interrupt enable
    rbuf : slv8;                        -- rbuf:
    rintreq : slbit;                    -- ptr interrupt request
    perr : slbit;                       -- pcsr: punch error
    prdy : slbit;                       -- pcsr: punch ready
    pie : slbit;                        -- pcsr: punch interrupt enable
    pbuf : slv8;                        -- pbuf:
    pintreq : slbit;                    -- ptp interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '1',                                -- rerr (init=1!)
    '0','0','0',                        -- rbusy,rdone,rie
    (others=>'0'),                      -- rbuf
    '0',                                -- rintreq
    '1',                                -- perr (init=1!)
    '1',                                -- prdy (init=1!)
    '0',                                -- pie
    (others=>'0'),                      -- pbuf
    '0'                                 -- pintreq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then              -- BRESET is 1 for system and ibus reset
        R_REGS <= regs_init;            --
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.rerr <= N_REGS.rerr;       -- don't reset RERR flag
          R_REGS.perr <= N_REGS.perr;       -- don't reset PERR flag
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK_PTR, EI_ACK_PTP)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    ibrd  := IB_MREQ.re;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;
    ibw1  := IB_MREQ.we and IB_MREQ.be1;
    ilam  := '0';
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=ibaddr_pc11(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_rcsr =>             -- RCSR -- reader control status -----

          idout(rcsr_ibf_rerr)  := r.rerr;
          idout(rcsr_ibf_rbusy) := r.rbusy;
          idout(rcsr_ibf_rdone) := r.rdone;
          idout(rcsr_ibf_rie)   := r.rie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.rie := IB_MREQ.din(rcsr_ibf_rie);
              if IB_MREQ.din(rcsr_ibf_rie) = '1' then-- set IE to 1
                if r.rie = '0' and                     -- IE 0->1 transition
                   IB_MREQ.din(rcsr_ibf_renb)='0' and  -- when RENB not set
                   (r.rerr='1' or r.rdone='1') then    -- but err or done set
                  n.rintreq := '1';                      -- request interrupt
                end if;
              else                                   -- set IE to 0
                n.rintreq := '0';                      -- cancel interrupts
              end if;
              if IB_MREQ.din(rcsr_ibf_renb) = '1' then -- set RENB
                if r.rerr = '0' then                   -- if not in error state
                  n.rbusy := '1';                        -- set busy
                  n.rdone := '0';                        -- clear done
                  n.rbuf  := (others=>'0');              -- clear buffer
                  n.rintreq := '0';                      -- cancel interrupt
                  ilam    := '1';                        -- rri lam
                else                                   -- if in error state
                  if r.rie = '1' then                    -- if interrupts on
                    n.rintreq := '1';                      -- request interrupt
                  end if;
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            if ibw1 = '1' then
              n.rerr := IB_MREQ.din(rcsr_ibf_rerr);  -- set ERR bit
              if IB_MREQ.din(rcsr_ibf_rerr)='1'      -- if 0->1 transition
                 and r.rerr='0' then
                n.rbusy := '0';                        -- clear busy
                n.rdone := '0';                        -- clear done
                if r.rie = '1' then                    -- if interrupts on
                  n.rintreq := '1';                      -- request interrupt
                end if;
              end if;
            end if;
          end if;

        when ibaddr_rbuf =>             -- RBUF -- reader data buffer --------

          idout(r.rbuf'range)   := r.rbuf;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibreq = '1' then           -- !! PC11 is unusual !!
              n.rdone := '0';             -- *any* read or write will clear done
              n.rbuf  := (others=>'0');   -- and the reader buffer 
              n.rintreq := '0';           -- also interrupt is canceled
            end if;

          else                          -- rri ---------------------
            if ibw0 = '1' then
              n.rbuf := IB_MREQ.din(n.rbuf'range);
              n.rbusy := '0';
              n.rdone := '1';
              if r.rie = '1' then
                n.rintreq := '1';
              end if;
            end if;
          end if;

        when ibaddr_pcsr =>             -- PCSR -- punch control status ------

          idout(pcsr_ibf_perr)  := r.perr;
          idout(pcsr_ibf_prdy)  := r.prdy;
          idout(pcsr_ibf_pie)   := r.pie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.pie   := IB_MREQ.din(pcsr_ibf_pie);
              if IB_MREQ.din(pcsr_ibf_pie) = '1' then-- set IE to 1
                if r.pie='0' and                       -- IE 0->1 transition
                  (r.perr='1' or r.prdy='1') then      -- but err or done set
                  n.pintreq := '1';               -- request interrupt
                end if;
              else                                   -- set IE to 0
                n.pintreq := '0';                      -- cancel interrupts
              end if;
            end if;

          else                          -- rri ---------------------
            if ibw1 = '1' then
              n.perr := IB_MREQ.din(pcsr_ibf_perr);  -- set ERR bit
              if IB_MREQ.din(pcsr_ibf_perr)='1'      -- if 0->1 transition
                 and r.perr='0' then
                n.prdy := '1';                         -- set ready
                if r.pie = '1' then                    -- if interrupts on
                  n.pintreq := '1';                      -- request interrupt
                end if;
              end if;
            end if;
          end if;

        when ibaddr_pbuf =>             -- PBUF -- punch data buffer ---------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              if r.perr = '0' then        -- if not in error state
                n.pbuf := IB_MREQ.din(n.pbuf'range);
                n.prdy := '0';              -- clear ready
                n.pintreq := '0';           -- cancel interrupts
                ilam := '1';                -- rri lam
              else                        -- if in error state
                if r.pie = '1' then         -- if interrupts on
                  n.pintreq := '1';           -- request interrupt
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(r.pbuf'range) := r.pbuf;
            idout(pbuf_ibf_pval)  := not r.prdy;
            idout(pbuf_ibf_rbusy) := r.rbusy;
            if ibrd = '1' then
              n.prdy := '1';
              if r.pie = '1' then
                n.pintreq := '1';
              end if;
            end if;
          end if;

        when others => null;
      end case;
      
    end if;    

    -- other state changes
    if EI_ACK_PTR = '1' then
      n.rintreq := '0';
    end if;
    if EI_ACK_PTP = '1' then
      n.pintreq := '0';
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= '0';

    RB_LAM     <= ilam;
    EI_REQ_PTR <= r.rintreq;
    EI_REQ_PTP <= r.pintreq;
    
  end process proc_next;

    
end syn;
