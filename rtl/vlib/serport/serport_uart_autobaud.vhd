-- $Id: serport_uart_autobaud.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    serport_uart_autobaud - syn
-- Description:    serial port UART - autobauder
--
-- Dependencies:   -
-- Test bench:     tb/tb_serport_autobaud
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-01   641   1.1    add CLKDIV_F
-- 2011-10-22   417   1.0.4  now numeric_std clean
-- 2010-04-18   279   1.0.3  change ccnt start value to -3, better rounding
-- 2007-10-14    89   1.0.2  all instantiation with CDINIT=0
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity serport_uart_autobaud is         -- serial port uart: autobauder
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT: natural := 15);             -- clk divider initial/reset setting
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    CLKDIV : out slv(CDWIDTH-1 downto 0); -- clock divider setting
    CLKDIV_F: out slv3;                   -- clock divider fractional part
    ACT : out slbit;                    -- active; if 1 clkdiv is invalid
    DONE : out slbit                    -- resync done
  );
end serport_uart_autobaud;


architecture syn of serport_uart_autobaud is

  type state_type is (
    s_idle,
    s_break,
    s_wait,
    s_sync
  );
  
  type regs_type is record
    ccnt : slv(CDWIDTH-1+3 downto 0);   -- clock divider counter
    mcnt : slv7;                        -- msec counter
    seen1 : slbit;                      -- seen a '1' in this msec
    state : state_type;                 -- state
  end record regs_type;

  -- Note on initialization of ccnt:
  -- - in the current logic ccnt is incremented n-1 times when n is number
  --   clock cycles with a RXD of '0'. When running at 50 MBaud, ccnt will
  --   be incremented 7 (not 8!) times.
  -- - the three LSBs of ccnt should be at 100 under perfect conditions, this
  --   gives the best rounded estimate of CLKDIV.
  -- - therefore ccnt is inititialized with 111111.101: 101 + 111 -> 1100 
  --   --> ccntinit = -3
  
  constant ccntinit : slv(CDWIDTH-1+3 downto 0) :=
    slv(to_unsigned(2**(CDWIDTH+3)-3, CDWIDTH+3));
  constant mcntzero : slv7 := (others=>'0');
  constant mcntlast : slv7 := (others=>'1');
  constant regs_init : regs_type := (
    slv(to_unsigned(CDINIT,CDWIDTH))&"000",
    (others=>'0'),
    '0',
    s_idle
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
begin

  assert CDINIT <= 2**CDWIDTH-1
  report "assert(CDINIT <= 2**CDWIDTH-1): CDINIT too large for given CDWIDTH"
  severity FAILURE;
  
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

  proc_next: process (R_REGS, CE_MSEC, RESET, RXSD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable iact : slbit := '0';
    variable idone : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    iact  := '1';
    idone := '0';
    
    case r.state is
      when s_idle =>                    -- s_idle: idle, detect break --------
        iact := '0';
        if CE_MSEC = '1' then             -- if end of msec
          if r.seen1 = '0' then             -- if no '1' seen on RXD
            n.mcnt := slv(unsigned(r.mcnt) + 1); -- up break timer counter
            if r.mcnt = mcntlast then         -- after 127 msec
              n.state := s_break;                -- break detected !
            end if;
          else                              -- otherwise if '1' seen
            n.mcnt := mcntzero;               -- clear break timer again
          end if;
          n.seen1 := RXSD;                  -- latch current RXD value
        else                              -- otherwise if not at end-of-msec
          n.seen1 := r.seen1 or RXSD;       -- remember whether RXS=1 seen
        end if;
        
      when s_break =>                   -- s_break: detect end of break ------
        if RXSD = '1' then                -- if end of break seen 
          n.state := s_wait;                -- to s_wait to wait for sync char
          n.ccnt := ccntinit;               -- and initialize ccnt
        end if;                           -- otherwise stay in s_break
        
      when s_wait =>                    -- s_wait: wait for sync char --------
        if RXSD = '0' then                -- if start bit if sync char seen
          n.state := s_sync;                -- to s_sync to wait for end of '0'
        end if;                           -- otherwise stay in s_wait
                     
      when s_sync =>                    -- s_sync: wait for end of '0' bits --
        if RXSD = '1' then                -- if end of '0' bits seen
          n.state := s_idle;                -- to s_idle, autobauding done
          idone := '1';                     -- emit done pulse
        else                              -- otherwise still in '0' of sync
          n.ccnt := slv(unsigned(n.ccnt) + 1); -- increment ccnt
        end if;

      when others => null;              -- -----------------------------------
    end case;
    
    N_REGS   <= n;
    
    CLKDIV   <= r.ccnt(CDWIDTH-1+3 downto 3);
    CLKDIV_F <= r.ccnt(2 downto 0);
    ACT      <= iact or RESET;
    DONE     <= idone;
    
  end process proc_next;
  
end syn;
