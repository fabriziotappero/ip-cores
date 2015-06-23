-- $Id: ibd_iist.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2009-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibd_iist - syn
-- Description:    ibus dev(loc): IIST
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4   112  510    0  291 s 15.8
-- 2010-10-17   314 12.1    M53d xc3s1000-4   111  504    0  290 s 15.6
-- 2009-06-01   223 10.1.03 K39  xc3s1000-4   111  439    0  256 s  9.8
-- 2009-06-01   221 10.1.03 K39  xc3s1000-4   111  449    0  258 s 13.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   0.8.1  now numeric_std clean
-- 2010-10-17   333   0.8    use ibus V2 interface
-- 2009-06-07   224   0.7    send inverted stc_stp; remove pgc_err; honor msk_im
--                           also for dcf_dcf and exc_rte; add iist_mreq and
--                           iist_sreq, boot and lock interfaces
-- 2009-06-05   223   0.6    level interrupt, parity logic, exc.ui logic
--                           st logic modified (partially tested)
-- 2009-06-01   221   0.5    Initial version (untested, lock&boot missing)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.ibdlib.all;

-- ----------------------------------------------------------------------------
entity ibd_iist is                      -- ibus dev(loc): IIST
                                        -- fixed address: 177500
  generic (
    SID : slv2 := "00");                -- self id
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit;                  -- interrupt acknowledge
    IIST_BUS : in iist_bus_type;        -- iist bus (input from all iist's)
    IIST_OUT : out iist_line_type;      -- iist output
    IIST_MREQ : out iist_mreq_type;     -- iist->cpu requests
    IIST_SRES : in iist_sres_type       -- cpu->iist responses
  );
end ibd_iist;

architecture syn of ibd_iist is

  constant ibaddr_iist : slv16 := slv(to_unsigned(8#177500#,16));

  constant tdlysnd : natural := 150;    -- send delay timer

  constant ibaddr_acr : slv1 := "0";    -- acr address offset
  constant ibaddr_adr : slv1 := "1";    -- adr address offset
  
  constant acr_ibf_clr :    integer := 15;                  -- clear flag
  subtype  acr_ibf_sid      is integer range  9 downto  8;  -- self id
  subtype  acr_ibf_ac       is integer range  3 downto  0;  -- ac code

  constant ac_pge : slv4 := "0000";     --  0 program generated enables
  constant ac_pgc : slv4 := "0001";     --  1 program generated control/status
  constant ac_ste : slv4 := "0010";     --  2 sanity timer enables
  constant ac_stc : slv4 := "0011";     --  3 sanity timer control/status
  constant ac_msk : slv4 := "0100";     --  4 input masks
  constant ac_pgf : slv4 := "0101";     --  5 program generated flags
  constant ac_stf : slv4 := "0110";     --  6 sanity timer flags
  constant ac_dcf : slv4 := "0111";     --  7 disconnect flags
  constant ac_exc : slv4 := "1000";     -- 10 exceptions
  constant ac_mtc : slv4 := "1101";     -- 15 maintenance control

  subtype  pge_ibf_pbe      is integer range 11 downto  8;  -- pg boot ena
  subtype  pge_ibf_pie      is integer range  3 downto  0;  -- pg int ena

  constant pgc_ibf_err :    integer := 15;                  -- error
  constant pgc_ibf_grj :    integer := 14;                  -- go reject
  constant pgc_ibf_pgrmr :  integer := 13;                  -- pg req refused
  constant pgc_ibf_strmr :  integer := 12;                  -- st req refused
  constant pgc_ibf_rdy :    integer := 11;                  -- ready flag
  subtype  pgc_ibf_sid      is integer range  9 downto  8;  -- self id
  constant pgc_ibf_ip :     integer :=  3;                  -- int pending
  constant pgc_ibf_ie :     integer :=  2;                  -- int enable
  constant pgc_ibf_ptp :    integer :=  1;                  -- pg parity
  constant pgc_ibf_go :     integer :=  0;                  -- go flag

  subtype  ste_ibf_sbe      is integer range 11 downto  8;  -- st boot enable
  subtype  ste_ibf_sie      is integer range  3 downto  0;  -- st int  enable

  subtype  stc_ibf_count    is integer range 15 downto  8;  -- count
  constant stc_ibf_tmo :    integer :=  3;                  -- timeout
  constant stc_ibf_lke :    integer :=  2;                  -- lockup enable
  constant stc_ibf_stp :    integer :=  1;                  -- st parity
  constant stc_ibf_enb :    integer :=  0;                  -- enable
  
  subtype  msk_ibf_bm       is integer range 11 downto  8;  -- boot mask
  subtype  msk_ibf_im       is integer range  3 downto  0;  -- int  mask

  subtype  pgf_ibf_pbf      is integer range 11 downto  8;  -- boot flags
  subtype  pgf_ibf_pif      is integer range  3 downto  0;  -- int  flags

  subtype  stf_ibf_sbf      is integer range 11 downto  8;  -- boot flags
  subtype  stf_ibf_sif      is integer range  3 downto  0;  -- int  flags

  subtype  dcf_ibf_brk      is integer range 11 downto  8;  -- break flags
  subtype  dcf_ibf_dcf      is integer range  3 downto  0;  -- disconnect flags

  subtype  exc_ibf_ui       is integer range 11 downto  8;  -- unexpected int
  subtype  exc_ibf_rte      is integer range  3 downto  0;  -- transm. error

  constant mtc_ibf_mttp :   integer := 11;                  -- maint. type
  constant mtc_ibf_mfrm :   integer := 10;                  -- maint. frame err
  subtype  mtc_ibf_mid      is integer range  9 downto  8;  -- maint. id
  constant mtc_ibf_dsbt :   integer :=  3;                  -- disable boot
  constant mtc_ibf_enmxd :  integer :=  2;                  -- enable maint mux
  constant mtc_ibf_enmlp :  integer :=  1;                  -- enable maint loop
  constant mtc_ibf_dsdrv :  integer :=  0;                  -- disable driver

  type state_type is (
    s_idle,                             -- idle state
    s_clear,                            -- handle acr clr
    s_stsnd,                            -- handle st transmit 
    s_pgsnd                             -- handle pg transmit
  );

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    acr_ac : slv4;                      -- acr: ac 
    pge_pbe : slv4;                     -- pge: pg boot ena
    pge_pie : slv4;                     -- pge: pg int ena
    pgc_grj : slbit;                    -- pgc: go reject
    pgc_pgrmr : slbit;                  -- pgc: pg req refused
    pgc_strmr : slbit;                  -- pgc: st req refused
    pgc_ie  : slbit;                    -- pgc: int enable
    pgc_ptp : slbit;                    -- pgc: pg parity
    ste_sbe : slv4;                     -- ste: st boot enable
    ste_sie : slv4;                     -- ste: st int  enable
    stc_count : slv8;                   -- stc: count
    stc_tmo : slbit;                    -- stc: timeout
    stc_lke : slbit;                    -- stc: lockup enable
    stc_stp : slbit;                    -- stc: st parity
    stc_enb : slbit;                    -- stc: enable
    msk_bm  : slv4;                     -- msk: boot mask
    msk_im  : slv4;                     -- msk: int  mask
    pgf_pbf : slv4;                     -- pgf: boot flags
    pgf_pif : slv4;                     -- pgf: int  flags
    stf_sbf : slv4;                     -- stf: boot flags
    stf_sif : slv4;                     -- stf: int  flags
    dcf_brk : slv4;                     -- dcf: break flags
    dcf_dcf : slv4;                     -- dcf: disconnect flags
    exc_ui  : slv4;                     -- exc: unexpected int
    exc_rte : slv4;                     -- exc: transm. error
    mtc_mttp  : slbit;                  -- mtc: maint. type
    mtc_mfrm  : slbit;                  -- mtc: maint. frame err
    mtc_mid   : slv2;                   -- mtc: maint. id
    mtc_dsbt  : slbit;                  -- mtc: disable boot
    mtc_enmxd : slbit;                  -- mtc: enable maint mux
    mtc_enmlp : slbit;                  -- mtc: enable maint loop
    mtc_dsdrv : slbit;                  -- mtc: disable driver
    state : state_type;                 -- state
    req_clear : slbit;                  -- request clear
    req_stsnd : slbit;                  -- request sanity timer transmit
    req_pgsnd : slbit;                  -- request prog. gen.   transmit
    tcnt256 : slv8;                     -- usec clock divider for st clock
    tcntsnd : slv8;                     -- timer for transmit delay
    req_lock : slbit;                   -- cpu lock request
    req_boot : slbit;                   -- cpu boot request
   end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    "0000",                             -- acr_ac
    "0000","0000",                      -- pge_pbe, pge_pie
    '0',                                -- pgc_grj
    '0','0',                            -- pgc_pgrmr, pgc_strmr
    '0','0',                            -- pgc_ie, pgc_ptp
    "0000","0000",                      -- ste_sbe, ste_sie
    (others=>'0'),                      -- stc_count
    '0','0',                            -- stc_tmo, stc_lke
    '0','0',                            -- stc_stp, stc_enb
    "0000","0000",                      -- msk_bm, msk_im
    "0000","0000",                      -- pgf_pbf, pgf_pif
    "0000","0000",                      -- stf_sbf, stf_sif
    "0000","0000",                      -- dcf_brk, dcf_dcf
    "0000","0000",                      -- exc_ui, exc_rte
    '0','0',                            -- mtc_mttp, mtc_mfrm
    "00",                               -- mtc_mid
    '0','0',                            -- mtc_dsbt, mtc_enmxd
    '0','0',                            -- mtc_enmlp, mtc_dsdrv
    s_idle,                             -- state
    '0',                                -- req_clear
    '0','0',                            -- req_stsnd, req_pgsnd
    (others=>'0'),                      -- tcnt256
    (others=>'0'),                      -- tcntsnd
    '0','0'                             -- req_lock, req_boot
  );
  
  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' or                -- BRESET is 1 for system and ibus reset
         R_REGS.req_clear='1' then
        R_REGS <= regs_init;            --
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.pgf_pbf <= N_REGS.pgf_pbf; -- don't reset pg boot flags
          R_REGS.stf_sbf <= N_REGS.stf_sbf; -- don't reset st boot flags
          R_REGS.tcnt256 <= N_REGS.tcnt256; -- don't reset st clock divider
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, CE_USEC, IB_MREQ, EI_ACK, EI_ACK,
                       IIST_BUS(0), IIST_BUS(1), IIST_BUS(2), IIST_BUS(3),
                       IIST_SRES)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibhold : slbit := '0';
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable int_or : slbit := '0';
    variable tcnt256_end : slbit := '0';
    variable tcntsnd_end : slbit := '0';
    variable eff_id  : slv2 := "00";
    variable eff_bus : iist_bus_type := iist_bus_init;
    variable par_err : slbit := '0';
    variable act_ibit : slbit := '0';
    variable act_bbit : slbit := '0';
    variable iout : iist_line_type := iist_line_init;
  begin

    r := R_REGS;
    n := R_REGS;

    ibhold := '0';
    idout  := (others=>'0');
    ibreq  := IB_MREQ.re or IB_MREQ.we;
    ibrd   := IB_MREQ.re;
    ibw0   := IB_MREQ.we and IB_MREQ.be0;
    ibw1   := IB_MREQ.we and IB_MREQ.be1;

    int_or := r.pgc_grj or r.pgc_pgrmr or r.pgc_strmr;
    for i in r.dcf_dcf'range loop
      int_or := int_or or r.dcf_dcf(i) or
                          r.exc_rte(i) or
                          r.pgf_pif(i) or
                          r.stf_sif(i);
    end loop;  -- i
    
    tcnt256_end := '0';
    if CE_USEC='1' and r.stc_enb='1'then   -- if st enabled on every usec
      n.tcnt256 := slv(unsigned(r.tcnt256) + 1);  -- advance 8 bit counter
      if unsigned(r.tcnt256) = 255 then      -- if wrap
        tcnt256_end := '1';                  -- signal 256 usec passed
      end if;
    end if;
    
    tcntsnd_end := '0';
    n.tcntsnd := slv(unsigned(r.tcntsnd) + 1);  -- advance send timer counter
    if unsigned(r.tcntsnd) = tdlysnd-1 then -- if delay time reached 
      tcntsnd_end := '1';                    -- signal end
    end if;
    
    eff_id := SID;                      -- effective self-id, normally SID
    if r.mtc_enmxd = '1' then           -- if maint. mux enabled
      eff_id := r.mtc_mid;                -- use maint. id
    end if;

    eff_bus  := IIST_BUS;

    par_err  := '0';
    act_ibit := '0';
    act_bbit := '0';
    iout     := iist_line_init;            -- default state of out line
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 2)=ibaddr_iist(12 downto 2) then
      n.ibsel := '1';
    end if;

    -- internal state machine
    case r.state is
      when s_idle =>                    -- idle state
        n.tcntsnd := (others=>'0');       -- keep send delay timer zero
        if r.req_stsnd = '1' then         -- sanity timer request pending
          n.state := s_stsnd;
        elsif r.req_pgsnd = '1' then      -- prog. gen. request pending
          n.state := s_pgsnd;
        end if;
          
      when s_clear =>                   -- handle acr clr
        ibhold := r.ibsel;              -- keep req pending if selected
        -- r.req_clear is set when in this state and cause a reset in prog_regs
        --   --> n.req_clear := '0';
        --   --> n.state := s_idle;

      when s_stsnd =>                   -- handle st transmit
        if tcntsnd_end = '1' then         -- send delay expired
          n.req_stsnd := '0';               -- clear st transmit request
          iout.req   := '1';                -- do transmit
          iout.stf   := '1';                -- signal type = st
          iout.imask := r.ste_sie;          -- int  enables
          iout.bmask := r.ste_sbe;          -- boot enables
          iout.par   := not r.stc_stp;      -- send parity (odd incl. stf!)
          iout.frm   := '0';                -- frame always ok
          n.state   := s_idle;
        end if;
          
      when s_pgsnd =>                   -- handle pg transmit
        if tcntsnd_end = '1' then         -- send delay expired
          n.req_pgsnd := '0';               -- clear pg transmit request
          iout.req   := '1';                -- do transmit
          iout.stf   := '0';                -- signal type = pg
          iout.imask := r.pge_pie;          -- int  enables
          iout.bmask := r.pge_pbe;          -- boot enables
          iout.par   := r.pgc_ptp;          -- send parity
          iout.frm   := '0';                -- frame always ok
          n.state := s_idle;
        end if;
        
      when others => null;
    end case;

    if r.mtc_enmxd = '1' then              -- if maintenance mux enabled
      iout.stf := r.mtc_mttp;                -- force type  from mtc_mttp
      iout.frm := r.mtc_mfrm;                -- force frame from mtc_mfrm
    end if;
    
    -- ibus transactions
    if r.ibsel = '1' and ibhold='0' then

      if IB_MREQ.addr(1 downto 1) = "0" then -- ACR -- access control reg -----

        idout(acr_ibf_sid) := SID;
        idout(acr_ibf_ac)  := r.acr_ac;

        if ibw1 = '1' then
          if IB_MREQ.din(acr_ibf_clr) = '1' then
            n.req_clear := '1';
            n.state     := s_clear;
          end if;
        end if;
        if ibw0 = '1' then
          n.acr_ac  := IB_MREQ.din(acr_ibf_ac);
        end if;

      else                                  -- ADR -- access data reg --------
        case r.acr_ac is

          when ac_pge =>                -- PGE -- program gen enables --------

            idout(pge_ibf_pbe) := r.pge_pbe;
            idout(pge_ibf_pie) := r.pge_pie;

            if IB_MREQ.we = '1' then
              
              if r.req_pgsnd = '0' then   -- no pg transmit pending
                if ibw1 = '1' then
                  n.pge_pbe := IB_MREQ.din(pge_ibf_pbe);
                end if;
                if ibw0 = '1' then
                  n.pge_pie := IB_MREQ.din(pge_ibf_pie);
                end if;
              else                        -- if collision with pg transmit
                n.pgc_pgrmr := '1';         -- set pge refused flag
              end if;

            end if;

          when ac_pgc =>                -- PGC -- program gen control/status -

            idout(pgc_ibf_err)   := r.pgc_grj or r.pgc_pgrmr or r.pgc_strmr;
            idout(pgc_ibf_grj)   := r.pgc_grj;
            idout(pgc_ibf_pgrmr) := r.pgc_pgrmr;
            idout(pgc_ibf_strmr) := r.pgc_strmr;
            idout(pgc_ibf_rdy)   := not r.req_pgsnd;
            idout(pgc_ibf_sid)   := eff_id;
            idout(pgc_ibf_ip)    := int_or;
            idout(pgc_ibf_ie)    := r.pgc_ie;
            idout(pgc_ibf_ptp)   := r.pgc_ptp;

            if ibw1 = '1' then
              if IB_MREQ.din(pgc_ibf_err) = '1' then -- '1' written into ERR
                n.pgc_grj   := '0';                  -- clears GRJ
                n.pgc_pgrmr := '0';                  -- clears PGRMR
                n.pgc_strmr := '0';                  -- clears STRMR
              end if;
            end if;
            if ibw0 = '1' then
              n.pgc_ie  := IB_MREQ.din(pgc_ibf_ie);
              n.pgc_ptp := IB_MREQ.din(pgc_ibf_ptp);
              if IB_MREQ.din(pgc_ibf_go) = '1' then -- GO bit set
                if r.req_pgsnd = '0' then           -- if ready (no pgsnd pend)
                  n.req_pgsnd := '1';                 -- request pgsnd
                else                                -- if not ready
                  n.pgc_grj := '1';                   -- set go reject flag
                end if;
              end if;
            end if;

          when ac_ste =>                -- STE -- sanity timer enables -------

            idout(ste_ibf_sbe)   := r.ste_sbe;
            idout(ste_ibf_sie)   := r.ste_sie;

            if IB_MREQ.we = '1' then
              
              if r.req_stsnd = '0' then   -- no st transmit pending
                if ibw1 = '1' then
                  n.ste_sbe := IB_MREQ.din(ste_ibf_sbe);
                end if;
                if ibw0 = '1' then
                  n.ste_sie := IB_MREQ.din(ste_ibf_sie);
                end if;
                
              else                        -- if collision with st transmit
                n.pgc_strmr := '1';         -- set ste refused flag
              end if;

            end if;
            
          when ac_stc =>                -- STC -- sanity timer control/status

            idout(stc_ibf_count) := r.stc_count;
            idout(stc_ibf_tmo)   := r.stc_tmo;
            idout(stc_ibf_lke)   := r.stc_lke;
            idout(stc_ibf_stp)   := r.stc_stp;
            idout(stc_ibf_enb)   := r.stc_enb;

            if ibw1 = '1' then
              n.stc_count := IB_MREQ.din(stc_ibf_count);    -- reset st count
              n.tcnt256   := (others=>'0');                 -- reset usec count
            end if;
            if ibw0 = '1' then
              if IB_MREQ.din(stc_ibf_tmo) = '1' then -- 1 written into TMO
                n.stc_tmo := '0';
              end if;
              n.stc_lke   := IB_MREQ.din(stc_ibf_lke);
              n.stc_stp   := IB_MREQ.din(stc_ibf_stp);
              n.stc_enb   := IB_MREQ.din(stc_ibf_enb);
            end if;

          when ac_msk =>                -- MSK -- input masks ----------------

            idout(msk_ibf_bm)    := r.msk_bm;
            idout(msk_ibf_im)    := r.msk_im;

            if ibw1 = '1' then
              n.msk_bm  := IB_MREQ.din(msk_ibf_bm);
            end if;
            if ibw0 = '1' then
              n.msk_im  := IB_MREQ.din(msk_ibf_im);
            end if;

          when ac_pgf =>                -- PGF -- program generated flags ----

            idout(pgf_ibf_pbf)   := r.pgf_pbf;
            idout(pgf_ibf_pif)   := r.pgf_pif;

            if ibw1 = '1' then
              n.pgf_pbf := r.pgf_pbf and not IB_MREQ.din(pgf_ibf_pbf);
            end if;
            if ibw0 = '1' then
              n.pgf_pif := r.pgf_pif and not IB_MREQ.din(pgf_ibf_pif);
            end if;

          when ac_stf =>                -- STF -- sanity timer flags ---------

            idout(stf_ibf_sbf)   := r.stf_sbf;
            idout(stf_ibf_sif)   := r.stf_sif;

            if ibw1 = '1' then
              n.stf_sbf := r.stf_sbf and not IB_MREQ.din(stf_ibf_sbf);
            end if;
            if ibw0 = '1' then
              n.stf_sif := r.stf_sif and not IB_MREQ.din(stf_ibf_sif);
            end if;

          when ac_dcf =>                -- DCE -- disconnect flags -----------

            idout(dcf_ibf_brk)   := r.dcf_brk;
            idout(dcf_ibf_dcf)   := r.dcf_dcf;

            if ibw0 = '1' then
              n.dcf_dcf := r.dcf_dcf and not IB_MREQ.din(dcf_ibf_dcf);
            end if;

          when ac_exc =>                -- EXC -- exceptions -----------------

            idout(exc_ibf_ui)    := r.exc_ui;
            idout(exc_ibf_rte)   := r.exc_rte;

            if ibw1 = '1' then
              n.exc_ui  := r.exc_ui  and not IB_MREQ.din(exc_ibf_ui);
            end if;
            if ibw0 = '1' then
              n.exc_rte := r.exc_rte and not IB_MREQ.din(exc_ibf_rte);
            end if;

          when ac_mtc =>                -- MTC -- maintenance control --------

            idout(mtc_ibf_mttp)  := r.mtc_mttp;
            idout(mtc_ibf_mfrm)  := r.mtc_mfrm;
            idout(mtc_ibf_mid)   := r.mtc_mid;
            idout(mtc_ibf_dsbt)  := r.mtc_dsbt;
            idout(mtc_ibf_enmxd) := r.mtc_enmxd;
            idout(mtc_ibf_enmlp) := r.mtc_enmlp;
            idout(mtc_ibf_dsdrv) := r.mtc_dsdrv;

            if ibw1 = '1' then
              n.mtc_mttp  := IB_MREQ.din(mtc_ibf_mttp);
              n.mtc_mfrm  := IB_MREQ.din(mtc_ibf_mfrm);
              n.mtc_mid   := IB_MREQ.din(mtc_ibf_mid);
            end if;
            if ibw0 = '1' then
              n.mtc_dsbt  := IB_MREQ.din(mtc_ibf_dsbt);
              n.mtc_enmxd := IB_MREQ.din(mtc_ibf_enmxd);
              n.mtc_enmlp := IB_MREQ.din(mtc_ibf_enmlp);
              n.mtc_dsdrv := IB_MREQ.din(mtc_ibf_dsdrv);
            end if;

          when others =>                -- access to undefined AC code -------
            null;
            
        end case;

        if unsigned(r.acr_ac) <= unsigned(ac_exc) then -- if ac 0,..,10
          if IB_MREQ.rmw = '0' then                    -- if not 1st part of rmw
            n.acr_ac := slv(unsigned(r.acr_ac) + 1);     -- autoincrement
          end if;
        end if;
        
      end if;
      
    end if;    

    -- sanity timer

    if tcnt256_end = '1' then           -- if 256 usec expired (and enabled)
      n.stc_count := slv(unsigned(r.stc_count) - 1);
      if unsigned(r.stc_count) = 0 then   -- if sanity timer expired
        n.stc_tmo := '1';                   -- set timeout flag
        n.req_stsnd := '1';                 -- request st transmit
        if r.stc_lke = '1' then             -- if lockup enabled
          n.req_lock := '1';                  -- request lockup
        end if;
      end if;
    end if;

    -- process iist bus inputs

    if r.mtc_enmlp = '1' then           -- if mainentance loop
      for i in eff_bus'range loop
        eff_bus(i) := iout;               -- local signal on all input ports
        eff_bus(i).dcf := '0';            -- all ports considered connected
      end loop;  -- i
    end if;
    
    for i in eff_bus'range loop

      par_err := eff_bus(i).stf xor
                 eff_bus(i).imask(0) xor eff_bus(i).imask(1) xor
                 eff_bus(i).imask(2) xor eff_bus(i).imask(3) xor
                 eff_bus(i).bmask(0) xor eff_bus(i).bmask(1) xor
                 eff_bus(i).bmask(2) xor eff_bus(i).bmask(3) xor
                 not eff_bus(i).par;
      
      act_ibit := eff_bus(i).imask(to_integer(unsigned(eff_id)));
      act_bbit := eff_bus(i).bmask(to_integer(unsigned(eff_id)));
      
      n.dcf_brk(i) := eff_bus(i).dcf;     -- trace dcf state in brk
      
      if eff_bus(i).dcf = '1' then        -- if disconnected
        if r.msk_im(i) = '0' then           -- if not disabled
          n.dcf_dcf(i) := '1';                -- set dcf flag
        end if;
          
      else                                -- if connected
        if eff_bus(i).req = '1' then        -- request received ?
          if eff_bus(i).frm='1' or            -- frame error seen ?
             par_err='1' then                 -- parity error seen ?
            if r.msk_im(i) = '0' then           -- if not disabled
              n.exc_rte(i) := '1';                -- set rte flag
            end if;
              
          else                                -- here if valid request seen
            if act_ibit = '1' then              -- interrupt request
              if r.msk_im(i) = '1' then           -- if disabled
                n.exc_ui(i) := '1';                 -- set ui flag
              else                                -- if enabled
                n.req_lock := '0';                  -- release lock
                if eff_bus(i).stf = '0' then        -- and pg request
                  n.pgf_pif(i) := '1';                -- set pif flag
                else                                -- and st request
                  n.stf_sif(i) := '1';                -- set sif flag
                end if;
              end if;
            end if; -- act_ibit='1'

            if act_bbit = '1' then              -- boot request
              if r.msk_bm(i) = '1' then           -- if msk disabled
                n.exc_ui(i) := '1';                 -- set ui flag
              else                                -- if msk enabled
                if r.mtc_dsbt = '0' then            -- if mtc enabled
                  n.req_lock := '0';                  -- release lock
                  n.req_boot := '1';                  -- request boot
                end if;
                if eff_bus(i).stf = '0' then        -- and pg request
                  n.pgf_pbf(i) := '1';                -- set pbf flag
                else                                -- and st request
                  n.stf_sbf(i) := '1';                -- set sbf flag
                end if;
              end if;
            end if; -- act_bbit='1'
            
          end if;
          
        end if;
      end if;
    end loop;
    
    -- process cpu->iist responses
    if IIST_SRES.ack_lock = '1' then
      n.req_lock := '0';
    end if;
    if IIST_SRES.ack_boot = '1' then
      n.req_boot := '0';
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= ibhold  and ibreq;

    EI_REQ <= r.pgc_ie and int_or;

    if r.mtc_dsdrv = '1' then           -- if driver disconnected
      iout.dcf := '1';                    -- set dcf flag
      iout.req := '0';                    -- suppress requests
    end if;
    IIST_OUT <= iout;                   -- and finally send it out...

    IIST_MREQ.lock <= r.req_lock;
    IIST_MREQ.boot <= r.req_boot;
    
  end process proc_next;

    
end syn;
