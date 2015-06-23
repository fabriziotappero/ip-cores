-- $Id: serport_xonrx.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    serport_xonrx - syn
-- Description:    serial port: xon/xoff logic rx path
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-22   417   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;

entity serport_xonrx is                 -- serial port: xon/xoff logic rx path
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    UART_RXDATA : in slv8;              -- uart data out
    UART_RXVAL : in slbit;              -- uart data valid
    RXDATA : out slv8;                  -- user data out
    RXVAL : out slbit;                  -- user data valid
    RXHOLD : in slbit;                  -- user data hold
    RXOVR : out slbit;                  -- user data overrun
    TXOK : out slbit                    -- tx channel ok
  );
end serport_xonrx;


architecture syn of serport_xonrx is

  type regs_type is record
    txok : slbit;                       -- tx channel ok state
    escseen : slbit;                    -- escape seen
    rxdata : slv8;                      -- user rxdata
    rxval : slbit;                      -- user rxval
    rxovr : slbit;                      -- user rxovr
  end record regs_type;

  constant regs_init : regs_type := (
    '1',                                -- txok (startup default is ok !!)
    '0',                                -- escseen
    (others=>'0'),                      -- rxdata
    '0','0'                             -- rxval,rxovr
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
begin

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

  proc_next: process (R_REGS, ENAXON, ENAESC, UART_RXDATA, UART_RXVAL, RXHOLD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    
  begin

    r := R_REGS;
    n := R_REGS;

    if ENAXON = '0' then
      n.txok := '1';
    end if;
    if ENAESC = '0' then
      n.escseen := '0';
    end if;

    n.rxovr := '0';                     -- ensure single clock pulse

    if UART_RXVAL = '1' then
      if ENAXON='1' and UART_RXDATA=c_serport_xon then
        n.txok := '1';
      elsif ENAXON='1' and UART_RXDATA=c_serport_xoff then
        n.txok := '0';
      elsif ENAESC='1' and UART_RXDATA=c_serport_xesc then
        n.escseen := '1';

      else
        if r.escseen = '1' then
          n.escseen := '0';
        end if;

        if r.rxval = '0' then
          n.rxval := '1';
          if r.escseen = '1' then
            n.rxdata := not UART_RXDATA;
          else
            n.rxdata := UART_RXDATA;
          end if;
        else
          n.rxovr := '1';
        end if;
      end if;
    end if;

    if r.rxval='1' and RXHOLD='0' then
      n.rxval := '0';
    end if;
    
    N_REGS <= n;

    RXDATA <= r.rxdata;
    RXVAL  <= r.rxval;
    RXOVR  <= r.rxovr;
    TXOK   <= r.txok;
    
  end process proc_next;

end syn;
