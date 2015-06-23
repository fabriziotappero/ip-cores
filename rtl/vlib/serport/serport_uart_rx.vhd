-- $Id: serport_uart_rx.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- The uart expects CLKDIV+1 wide input bit symbols.
-- This implementation counts the number of 1's in the first CLKDIV clock
-- cycles, and checks in the last cycle of the symbol time whether the
-- number of 1's was > CLKDIV/2. This supresses short glitches nicely,
-- especially for larger clock dividers.
--
------------------------------------------------------------------------------
-- Module Name:    serport_uart_rx - syn
-- Description:    serial port UART - receiver
--
-- Dependencies:   -
-- Test bench:     tb/tb_serport_uart_rxtx
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-22   417   2.0.3  now numeric_std clean
-- 2009-07-12   233   2.0.2  remove snoopers
-- 2008-03-02   121   2.0.1  comment out snoopers
-- 2007-10-21    91   2.0    re-designed and -implemented with state machine.
--                           allow CLKDIV=0 with 1 stop bit; allow max. CLKDIV
--                           (all 1's); aborts bad start bit after 1/2 cell;
--                           accepts stop bit after 1/2 cell, permits tx clock
--                           be ~3 percent faster than rx clock.
--                           for 3s1000ft256: 50 -> 58 slices for CDWIDTH=13
-- 2007-10-14    89   1.1    almost full rewrite, handles now CLKDIV=0 properly
--                           for 3s1000ft256: 43 -> 50 slices for CDWIDTH=13
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity serport_uart_rx is               -- serial port uart: receive part
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit                   -- receiver active
  );
end serport_uart_rx;


architecture syn of serport_uart_rx is

  type state_type is (
    s_idle,                             -- s_idle:  idle
    s_colb0,                            -- s_colb0: collect b0 (start bit)
    s_endb0,                            -- s_endb0: finish  b0 (start bit)
    s_colbx,                            -- s_colbx: collect bx
    s_endbx,                            -- s_endbx: finish  bx
    s_colb9,                            -- s_colb9: collect bx (stop bit)
    s_endb9                             -- s_endb9: finish  bx (stop bit)
  );
  
  type regs_type is record
    state : state_type;                 -- state
    ccnt : slv(CDWIDTH-1 downto 0);     -- clock divider counter
    dcnt : slv(CDWIDTH   downto 0);     -- data '1' counter
    bcnt : slv4;                        -- bit counter
    sreg : slv8;                        -- input shift register
  end record regs_type;

  constant ccntzero : slv(CDWIDTH-1 downto 0) := (others=>'0');
  constant dcntzero : slv(CDWIDTH   downto 0) := (others=>'0');
  constant regs_init : regs_type := (
    s_idle,                             -- state
    ccntzero,                           -- ccnt
    dcntzero,                           -- dcnt
    (others=>'0'),                      -- bcnt
    (others=>'0')                       -- sreg
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
begin

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, RESET, CLKDIV, RXSD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable dbit : slbit := '0';
    variable ld_ccnt : slbit := '0';
    variable tc_ccnt : slbit := '0';
    variable tc_bcnt : slbit := '0';
    variable ld_dcnt : slbit := '0';
    variable ld_bcnt : slbit := '0';
    variable ce_bcnt : slbit := '0';
    variable iact : slbit := '0';
    variable ival : slbit := '0';
    variable ierr : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    dbit := '0';
    ld_ccnt := '0';
    tc_ccnt := '0';
    tc_bcnt := '0';
    ld_dcnt := '0';
    ld_bcnt := '0';
    ce_bcnt := '0';
    iact := '1';
    ival := '0';
    ierr := '0';
    
    if unsigned(r.ccnt) = 0 then
      tc_ccnt := '1';
    end if;
    if unsigned(r.bcnt) = 9 then
      tc_bcnt := '1';
    end if;
    
    if unsigned(r.dcnt) > unsigned("00" & CLKDIV(CDWIDTH-1 downto 1)) then
      dbit := '1';
    end if;

    case r.state is

      when s_idle =>                    -- s_idle: idle ----------------------
        iact := '0';
        ld_dcnt := '1';                   -- always keep dcnt in reset
        if RXSD = '0' then                -- if start bit seen
          if tc_ccnt = '1' then
            n.state := s_endb0;             -- finish b0
            ld_ccnt := '1';                 -- start next bit
            ce_bcnt := '1';
          else
            n.state := s_colb0;             -- collect b0
          end if;
        else                              -- otherwise
          ld_ccnt := '1';                   -- keep all counters in reset
          ld_bcnt := '1';
        end if;

      when s_colb0 =>                   -- s_colb0: collect b0 (start bit) ---
        if tc_ccnt = '1' then           -- last cycle of b0 ?
          n.state := s_endb0;             -- finish b0
          ld_ccnt := '1';                 -- "
          ce_bcnt := '1';
        else                            -- continue in b0 ?
          if dbit='1' and RXSD='1' then   -- too many 1's ?
            n.state := s_idle;              -- abort to idle
            ld_dcnt := '1';                 -- put counters in reset
            ld_ccnt := '1';
            ld_bcnt := '1';
          end if;
        end if;
        
      when s_endb0 =>                   -- s_endb0: finish  b0 (start bit) ---
        ld_dcnt := '1';                 -- start next bit
        if dbit = '1' then              -- was it a 1 ?
          n.state := s_idle;              -- abort to idle
          ld_ccnt := '1';                 -- put counters in reset
          ld_bcnt := '1';
        else
          if tc_ccnt = '1' then           -- last cycle of bx ?
            n.state := s_endbx;             -- finish bx
            ld_ccnt := '1';
            ce_bcnt := '1';
          else                            -- continue in b0 ?
            n.state := s_colbx;             -- collect bx
          end if;
        end if;
        
      when s_colbx =>                   -- s_colbx: collect bx ---------------
        if tc_ccnt = '1' then           -- last cycle of bx ?
          n.state := s_endbx;             -- finish bx
          ld_ccnt := '1';
          ce_bcnt := '1';
        end if;

      when s_endbx =>                   -- s_endbx: finish  bx ---------------
        ld_dcnt := '1';                 -- start next bit
        n.sreg := dbit & r.sreg(7 downto 1);
        if tc_ccnt = '1' then           -- last cycle of bx ?
          if tc_bcnt = '1' then
            n.state := s_endb9;             -- finish b9
            ld_bcnt := '1';                 -- and wrap bcnt
          else
            n.state := s_endbx;             -- finish bx
            ce_bcnt := '1';
          end if;
          ld_ccnt := '1';
        else                            -- continue in bx ?
          if tc_bcnt = '1' then
            n.state := s_colb9;             -- collect b9
          else
            n.state := s_colbx;             -- collect bx
          end if;
        end if;

      when s_colb9 =>                   -- s_colb9: collect bx (stop bit) ----
        if tc_ccnt = '1' then           -- last cycle of b9 ?
          n.state := s_endb9;             -- finish b9
          ld_ccnt := '1';                 -- "
          ld_bcnt := '1';                 -- and wrap bcnt
        else                            -- continue in b9 ?
          if dbit='1' and RXSD='1' then   -- already enough 1's ?
            n.state := s_idle;              -- finish to idle
            ld_dcnt := '1';                 -- put counters in reset
            ld_ccnt := '1';
            ld_bcnt := '1';
            ival := '1';
          end if;
        end if;

      when s_endb9 =>                   -- s_endb9: finish  bx (stop bit) ----
        ld_dcnt := '1';                 -- start next bit
        if dbit = '1' then              -- was it a valid stop bit ?
          ival := '1';
        else
          ierr := '1';
        end if;
        if RXSD = '1' then              -- line in idle state ?
          n.state := s_idle;              -- finish to idle state
          ld_ccnt := '1';                 -- and put counters in reset
          ld_bcnt := '1';                 -- "
        else
          if tc_ccnt = '1' then           -- last cycle of b9 ?
            n.state := s_endb0;             -- finish b0
            ld_ccnt := '1';                 -- "
            ce_bcnt := '1';
          else                            -- continue in b0 ?
            n.state := s_colb0;             -- collect bx
          end if;
        end if;

      when others => null;              -- -----------------------------------

    end case;
    
    if RESET = '1' then                 -- RESET seen
      ld_ccnt := '1';                     -- keep all counters in reset
      ld_dcnt := '1';
      ld_bcnt := '1';
      n.state := s_idle;
    end if;    
    
    if ld_ccnt = '1' then               -- implement ccnt
      n.ccnt := CLKDIV;
    else
      n.ccnt := slv(unsigned(r.ccnt) - 1);
    end if;

    if ld_dcnt = '1' then               -- implement dcnt
      n.dcnt(CDWIDTH downto 1) := (others=>'0');
      n.dcnt(0) := RXSD;
    else
      if RXSD = '1' then
        n.dcnt := slv(unsigned(r.dcnt) + 1);
      end if;
    end if;

    if ld_bcnt = '1' then               -- implement bcnt
      n.bcnt := (others=>'0');
    else
      if ce_bcnt = '1' then
        n.bcnt := slv(unsigned(r.bcnt) + 1);
      end if;
    end if;

    N_REGS <= n;

    RXDATA  <= r.sreg;
    RXACT   <= iact;
    RXVAL   <= ival;
    RXERR   <= ierr;

  end process proc_next;

end syn;
