-- $Id: ibdr_dl11.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    ibdr_dl11 - syn
-- Description:    ibus dev(rem): DL11-A/B
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4    39  126    0   72 s  7.6
-- 2009-07-12   233 10.1.03 K39  xc3s1000-4    38  119    0   69 s  6.3
-- 2009-07-11   232 10.1.03 K39  xc3s1000-4    23   61    0   40 s  5.5
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  rename RRI_LAM->RB_LAM;
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.5  add RESET, CE_USEC port; implement input rate limit
-- 2008-08-22   161   1.0.6  use iblib; add EI_ACK_* to proc_next sens. list
-- 2008-05-09   144   1.0.5  use intreq flop, use EI_ACK
-- 2008-03-22   128   1.0.4  rename xdone -> xval (no functional change)
-- 2008-01-27   115   1.0.3  BUGFIX: set ilam when rbuf read by cpu;
--                           add xdone and rrdy bits to rri xbuf read
-- 2008-01-20   113   1.0.2  fix maint mode logic (proper double buffer now)
-- 2008-01-20   112   1.0.1  use BRESET
-- 2008-01-05   108   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_dl11 is                     -- ibus dev(rem): DL11-A/B
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#177560#,16)));
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_RX : out slbit;              -- interrupt request, receiver
    EI_REQ_TX : out slbit;              -- interrupt request, transmitter
    EI_ACK_RX : in slbit;               -- interrupt acknowledge, receiver
    EI_ACK_TX : in slbit                -- interrupt acknowledge, transmitter
  );
end ibdr_dl11;

architecture syn of ibdr_dl11 is

  constant ibaddr_rcsr : slv2 := "00";  -- rcsr address offset
  constant ibaddr_rbuf : slv2 := "01";  -- rbuf address offset
  constant ibaddr_xcsr : slv2 := "10";  -- xcsr address offset
  constant ibaddr_xbuf : slv2 := "11";  -- xbuf address offset
  
  subtype  rcsr_ibf_rrlim   is integer range 14 downto 12;
  constant rcsr_ibf_rdone : integer :=  7;
  constant rcsr_ibf_rie :   integer :=  6;
  
  constant xcsr_ibf_xrdy :  integer :=  7;
  constant xcsr_ibf_xie :   integer :=  6;
  constant xcsr_ibf_xmaint: integer :=  2;

  constant xbuf_ibf_xval :  integer :=  8;
  constant xbuf_ibf_rrdy :  integer :=  9;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    rrlim : slv3;                       -- rcsr: receiver rate limit
    rdone : slbit;                      -- rcsr: receiver done
    rie : slbit;                        -- rcsr: receiver interrupt enable
    rbuf : slv8;                        -- rbuf:
    rval : slbit;                       -- rx rbuf valid
    rintreq : slbit;                    -- rx interrupt request
    rdlybsy : slbit;                    -- rx delay busy
    rdlycnt : slv10;                    -- rx delay counter
    xrdy : slbit;                       -- xcsr: transmitter ready
    xie : slbit;                        -- xcsr: transmitter interrupt enable
    xmaint : slbit;                     -- xcsr: maintenance mode
    xbuf : slv8;                        -- xbuf:
    xintreq : slbit;                    -- tx interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    (others=>'0'),                      -- rrlim
    '0','0',                            -- rdone, rie
    (others=>'0'),                      -- rbuf
    '0','0','0',                        -- rval,rintreq,rdlybsy
    (others=>'0'),                      -- rdlycnt
    '1',                                -- xrdy !! is set !!
    '0','0',                            -- xie,xmaint
    (others=>'0'),                      -- xbuf
    '0'                                 -- xintreq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.rrlim   <= N_REGS.rrlim;   -- don't reset rx rate limit
          R_REGS.rdlybsy <= N_REGS.rdlybsy; -- don't reset rx delay busy
          R_REGS.rdlycnt <= N_REGS.rdlycnt; -- don't reset rx delay counter
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (CE_USEC, R_REGS, IB_MREQ, EI_ACK_RX, EI_ACK_TX)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
    variable rdlystart : slbit := '0';
    variable rdlyinit : slv10 := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    ibrd  := IB_MREQ.re;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;
    ibw1  := IB_MREQ.we and IB_MREQ.be1;
    ilam  := '0';
    rdlystart := '0';
      
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=IB_ADDR(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_rcsr =>             -- RCSR -- receive control status ----
          idout(rcsr_ibf_rdone) := r.rdone;
          idout(rcsr_ibf_rie)   := r.rie;
          
          if IB_MREQ.racc = '0' then     -- cpu ---------------------
            if ibw0 = '1' then
              n.rie := IB_MREQ.din(rcsr_ibf_rie);
              if IB_MREQ.din(rcsr_ibf_rie) = '1' then
                if r.rdone='1' and r.rie='0' then -- ie set while done=1
                  n.rintreq := '1';               -- request interrupt
                end if;
              else
                n.rintreq := '0';
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rcsr_ibf_rrlim) := r.rrlim;
            if ibw1 = '1' then
              n.rrlim := IB_MREQ.din(rcsr_ibf_rrlim);
            end if;
          end if;

        when ibaddr_rbuf =>             -- RBUF -- receive data buffer -------

          idout(r.rbuf'range)   := r.rbuf;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibrd = '1' then
              n.rdone   := '0';           -- clear DONE
              n.rval    := '0';           -- clear rbuf valid
              n.rintreq := '0';           -- clear pending interrupts
              rdlystart := '1';           -- start rx delay counter
              if r.xmaint = '0' then      -- if not in loop-back
                ilam := '1';                -- request rb attention
              end if;
            end if;

          else                          -- rri ---------------------
            if ibw0 = '1' then
              n.rbuf := IB_MREQ.din(n.rbuf'range);
              n.rval := '1';              -- set rbuf valid
              if r.rdlybsy = '0' then     -- if rdly timer not running
                n.rdone := '1';             -- set DONE
                if r.rie = '1' then         -- if rx interrupt enabled
                  n.rintreq := '1';           -- request interrupt
                end if;
              end if;
            end if;
          end if;

        when ibaddr_xcsr =>             -- XCSR -- transmit control status ---

          idout(xcsr_ibf_xrdy)  := r.xrdy;
          idout(xcsr_ibf_xie)   := r.xie;
          idout(xcsr_ibf_xmaint):= r.xmaint;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.xie   := IB_MREQ.din(xcsr_ibf_xie);
              if IB_MREQ.din(xcsr_ibf_xie) = '1' then
                if r.xrdy='1' and r.xie='0' then -- ie set while ready=1
                  n.xintreq := '1';               -- request interrupt
                end if;
              else
                n.xintreq := '0';
              end if;
              n.xmaint := IB_MREQ.din(xcsr_ibf_xmaint);
            end if;
          end if;
          
        when ibaddr_xbuf =>             -- XBUF -- transmit data buffer ------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.xbuf := IB_MREQ.din(n.xbuf'range);
              n.xrdy := '0';
              n.xintreq := '0';
              if r.xmaint = '0' then
                ilam := '1';
              end if;
            end if;

          else                          -- rri ---------------------
            idout(r.xbuf'range)  := r.xbuf;
            if r.xmaint = '0' then        -- if not in maintenace mode
              idout(xbuf_ibf_xval) := not r.xrdy;
              idout(xbuf_ibf_rrdy) := not r.rval;
            end if;
            if ibrd = '1' then
              n.xrdy := '1';
              if r.xie = '1' then
                n.xintreq := '1';
              end if;
            end if;
          end if;

        when others => null;
      end case;

    else                                -- if unselected handle loop-back
      if r.xmaint = '1' and               -- if in maintenace mode
          r.xrdy='0' and                  -- and transmit pending
          r.rdone='0' and                 -- and receive buffer empty
          r.rdlybsy='0' then              -- and rdly timer not running
        n.rbuf  := r.xbuf;                  -- copy transmit to receive buffer
        n.xrdy  := '1';                     -- mark transmit done
        n.rdone := '1';                     -- make receive done
        if r.rie = '1' then                 -- if rx interrupt enabled
          n.rintreq := '1';                   -- request it
        end if;
        if r.xie = '1' then                 -- if tx interrupt enabled
          n.xintreq := '1';                   -- request it
        end if;
      end if;
        
    end if;    

    -- other state changes

    rdlyinit := (others=>'0');
    case r.rrlim is
      when "000" => rdlyinit := "0000000000"; -- rlim=0 -> disabled
      when "001" => rdlyinit := "0000000011"; -- rlim=1 -> delay by    3+ usec
      when "010" => rdlyinit := "0000001111"; -- rlim=2 -> delay by   15+ usec
      when "011" => rdlyinit := "0000111111"; -- rlim=3 -> delay by   63+ usec
      when "100" => rdlyinit := "0001111111"; -- rlim=4 -> delay by  127+ usec
      when "101" => rdlyinit := "0011111111"; -- rlim=5 -> delay by  255+ usec
      when "110" => rdlyinit := "0111111111"; -- rlim=6 -> delay by  511+ usec
      when "111" => rdlyinit := "1111111111"; -- rlim=7 -> delay by 1023+ usec
      when others => null;
    end case;
    
    if rdlystart = '1' then                 -- if rdly timer start requested
      n.rdlycnt := rdlyinit;                  -- init counter
      if r.rrlim /= "000" then                -- rate limiter enabled ?
        n.rdlybsy := '1';                       -- set busy 
      end if;
    elsif CE_USEC = '1' then                -- if end-of-usec
      n.rdlycnt := slv(unsigned(r.rdlycnt) - 1);   -- decrement
      if r.rdlybsy='1' and                   -- if delay busy
          unsigned(r.rdlycnt) = 0 then        --   and counter at zero
        n.rdlybsy := '0';                       -- clear busy
        if n.rval = '1' then                    -- if rbuf is valid or is set
                                                --   valid this cycle (use n.!!)
          n.rdone := '1';                         -- set DONE
          if r.rie = '1' then                     -- if rx interrupt enabled
            n.rintreq := '1';                       -- request interrupt 
          end if;
        end if;
      end if;
    end if;
    
    if EI_ACK_RX = '1' then
      n.rintreq := '0';
    end if;
    if EI_ACK_TX = '1' then
      n.xintreq := '0';
    end if;

    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= '0';

    RB_LAM    <= ilam;
    EI_REQ_RX <= r.rintreq;
    EI_REQ_TX <= r.xintreq;
    
  end process proc_next;

    
end syn;
