-- $Id: serport_xontx.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    serport_xontx - syn
-- Description:    serial port: xon/xoff logic tx path
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-13   425   1.0    Initial version
-- 2011-10-22   417   0.5    First draft 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;

entity serport_xontx is                 -- serial port: xon/xoff logic tx path
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    UART_TXDATA : out slv8;             -- uart data in
    UART_TXENA : out slbit;             -- uart data enable
    UART_TXBUSY : in slbit;             -- uart data busy
    TXDATA : in slv8;                   -- user data in
    TXENA : in slbit;                   -- user data enable
    TXBUSY : out slbit;                 -- user data busy
    RXOK : in slbit;                    -- rx channel ok
    TXOK : in slbit                     -- tx channel ok
  );
end serport_xontx;


architecture syn of serport_xontx is

  type regs_type is record
    ibuf : slv8;                        -- input buffer
    ival : slbit;                       -- ibuf has valid data
    obuf : slv8;                        -- output buffer
    oval : slbit;                       -- obuf has valid data
    rxok : slbit;                       -- rx channel ok state
    enaxon_1 : slbit;                   -- last enaxon
    escpend : slbit;                    -- escape pending
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),'0',                  -- ibuf,ival
    (others=>'0'),'0',                  -- obuf,oval
    '1',                                -- rxok (startup default is ok !!)
    '0',                                -- enaxon_1
    '0'                                 -- escpend
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

  proc_next: process (R_REGS, ENAXON, ENAESC, UART_TXBUSY,
                      TXDATA, TXENA, RXOK, TXOK)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

  begin

    r := R_REGS;
    n := R_REGS;

    if TXENA='1' and r.ival='0' then
      n.ibuf := TXDATA;
      n.ival := '1';
    end if;

    if r.oval = '0' then
      if ENAXON='1' and r.rxok/=RXOK then
        n.rxok := RXOK;
        n.oval := '1';
        if r.rxok = '0' then
          n.obuf := c_serport_xon;
        else
          n.obuf := c_serport_xoff;
        end if;
      elsif TXOK = '1' then
        if r.escpend = '1' then
          n.obuf := not r.ibuf;
          n.oval := '1';
          n.escpend := '0';
          n.ival := '0';
        elsif r.ival = '1' then
          if ENAESC='1' and (r.ibuf=c_serport_xon or
                             r.ibuf=c_serport_xoff or
                             r.ibuf=c_serport_xesc)
          then
            n.obuf := c_serport_xesc;
            n.oval := '1';
            n.escpend := '1';
          else
            n.obuf := r.ibuf;
            n.oval := '1';
            n.ival := '0';
          end if;
        end if;
      end if;
    end if;

    if r.oval='1' and UART_TXBUSY='0' then
      n.oval := '0';
    end if;
    
    -- FIXME: document this hack
    n.enaxon_1 := ENAXON;
    if ENAXON='1' and r.enaxon_1='0' then
      n.rxok := not RXOK;
    end if;
    
    N_REGS <= n;

    TXBUSY      <= r.ival;
    UART_TXDATA <= r.obuf;
    UART_TXENA  <= r.oval;
    
  end process proc_next;

end syn;
