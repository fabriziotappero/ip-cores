-- $Id: ibdr_lp11.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    ibdr_lp11 - syn
-- Description:    ibus dev(rem): LP11
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4    12   35    0   24 s  5.6
-- 2009-07-11   232 10.1.03 K39  xc3s1000-4    11   30    0   19 s  5.8
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-05-04   515   1.3    BUGFIX: r.err was cleared in racc read !
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  rename RRI_LAM->RB_LAM;
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-06-21   228   1.0.1  generate interrupt locally when err=1
-- 2009-05-30   220   1.0    Initial version 
------------------------------------------------------------------------------
--
-- Notes:
--   - the ERR bit is just a status flag
--   - no hardware interlock (DONE forced 0 when ERR=1), like in simh
--   - also no interrupt when ERR goes 1, like in simh


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_lp11 is                     -- ibus dev(rem): LP11
                                        -- fixed address: 177514
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibdr_lp11;

architecture syn of ibdr_lp11 is

  constant ibaddr_lp11 : slv16 := slv(to_unsigned(8#177514#,16));

  constant ibaddr_csr : slv1 := "0";   -- csr address offset
  constant ibaddr_buf : slv1 := "1";   -- buf address offset
  
  constant csr_ibf_err :   integer := 15;
  constant csr_ibf_done :  integer :=  7;
  constant csr_ibf_ie :    integer :=  6;
  constant buf_ibf_val :   integer :=  8;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    err : slbit;                        -- csr: error flag
    done : slbit;                       -- csr: done flag
    ie : slbit;                         -- csr: interrupt enable
    buf : slv7;                         -- buf:
    intreq : slbit;                     -- interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '1',                                -- err  !! is set !!
    '1',                                -- done !! is set !!
    '0',                                -- ie
    (others=>'0'),                      -- buf
    '0'                                 -- intreq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then              -- BRESET is 1 for system and ibus reset
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.err <= N_REGS.err;         -- don't reset ERR flag
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK)
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
       IB_MREQ.addr(12 downto 2)=ibaddr_lp11(12 downto 2) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then
      case IB_MREQ.addr(1 downto 1) is

        when ibaddr_csr =>              -- CSR -- control status -------------
          idout(csr_ibf_err)  := r.err;
          idout(csr_ibf_done) := r.done;
          idout(csr_ibf_ie)   := r.ie;
          if IB_MREQ.racc = '0' then      -- cpu
            if ibw0 = '1' then
              n.ie   := IB_MREQ.din(csr_ibf_ie);
              if IB_MREQ.din(csr_ibf_ie) = '1' then
                if r.done='1' and r.ie='0' then   -- ie set while done=1
                  n.intreq := '1';                -- request interrupt
                end if;
              else
                n.intreq := '0';
              end if;
            end if;
          else                          -- rri
            if ibw1 = '1' then
              n.err := IB_MREQ.din(csr_ibf_err);
            end if;
          end if;

        when ibaddr_buf =>              -- BUF -- data buffer ----------------
          if IB_MREQ.racc = '0' then      -- cpu
            if ibw0 = '1' then
              n.buf    := IB_MREQ.din(n.buf'range);
              if r.err = '0' then         -- if online (handle via rbus)
                ilam     := '1';            -- request attention
                n.done   := '0';            -- clear done
                n.intreq := '0';            -- clear interrupt
              else                        -- if offline (discard locally)
                n.done   := '1';            -- set done
                if r.ie = '1' then          -- if interrupts enabled
                  n.intreq := '1';            -- request interrupt
                end if;
              end if;
            end if;
          else                          -- rri
            idout(r.buf'range)  := r.buf;
            idout(buf_ibf_val)  := not r.done;
            if ibrd = '1' then
              n.done := '1';
              if r.ie = '1' then
                n.intreq := '1';
              end if;
            end if;
          end if;

        when others => null;
      end case;

    end if;    

    -- other state changes
    if EI_ACK = '1' then
      n.intreq := '0';
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= '0';

    RB_LAM <= ilam;
    EI_REQ <= r.intreq;
    
  end process proc_next;

    
end syn;
