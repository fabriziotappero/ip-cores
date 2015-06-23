-- $Id: serport_uart_tx.vhd 641 2015-02-01 22:12:15Z mueller $
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
------------------------------------------------------------------------------
-- Module Name:    serport_uart_tx - syn
-- Description:    serial port UART - transmitter
--
-- Dependencies:   -
-- Test bench:     tb/tb_serport_uart_rxtx
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-22   417   1.0.4  now numeric_std clean
-- 2007-10-21    91   1.0.3  use 1 stop bits (redesigned _rx allows this)
-- 2007-10-19    90   1.0.2  use 2 stop bits (allow CLKDIV=0 operation in sim)
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity serport_uart_tx is               -- serial port uart: transmit part
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit                  -- transmit busy
  );
end serport_uart_tx;


architecture syn of serport_uart_tx is

  type regs_type is record
    ccnt : slv(CDWIDTH-1 downto 0);     -- clock divider counter
    bcnt : slv4;                        -- bit counter
    sreg : slv9;                        -- output shift register
    busy : slbit;
  end record regs_type;

  constant cntzero : slv(CDWIDTH-1 downto 0) := (others=>'0');
  constant regs_init : regs_type := (
    cntzero,
    (others=>'0'),
    (others=>'1'),                      -- sreg to all 1 !!
    '0'
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

  proc_next: process (R_REGS, RESET, CLKDIV, TXDATA, TXENA)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ld_ccnt : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;
    ld_ccnt := '0';
    
    if r.busy = '0' then
      ld_ccnt := '1';
      n.bcnt := (others=>'0');
      if TXENA = '1' then
        n.sreg := TXDATA & '0';         -- add start (0) bit
        n.busy := '1';
      end if;
      
    else

      if unsigned(r.ccnt) = 0 then
        ld_ccnt := '1';
        n.sreg := '1' & r.sreg(8 downto 1);
        n.bcnt := slv(unsigned(r.bcnt) + 1);
        if unsigned(r.bcnt) = 9 then    -- if 10 bits send
          n.busy := '0';                -- declare all done
        end if;
      end if;
    end if;

    if RESET = '1' then
      ld_ccnt := '1';
      n.busy  := '0';
    end if;
    
    if ld_ccnt = '1' then
      n.ccnt := CLKDIV;
    else
      n.ccnt := slv(unsigned(r.ccnt) - 1);
    end if;
    
    N_REGS <= n;
    
    TXBUSY <= r.busy;
    TXSD   <= r.sreg(0);
      
  end process proc_next;
  
end syn;
