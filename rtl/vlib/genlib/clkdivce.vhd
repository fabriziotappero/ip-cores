-- $Id: clkdivce.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    clkgen - syn
-- Description:    Generate usec and msec enable signals
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date        Rev  Version    Comment
-- 2011-10-22   418   1.0.3  now numeric_std clean
-- 2008-01-20   112   1.0.2  rename clkgen->clkdivce; remove SYS_CLK port
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity clkdivce is                      -- generate usec/msec ce pulses
  generic (
    CDUWIDTH : positive := 6;           -- usec clock divider width
    USECDIV : positive :=  50;          -- divider ratio for usec pulse
    MSECDIV : positive := 1000);        -- divider ratio for msec pulse
  port (
    CLK     : in slbit;                 -- input clock
    CE_USEC : out slbit;                -- usec pulse
    CE_MSEC : out slbit                 -- msec pulse
  );
end clkdivce;


architecture syn of clkdivce is

  type regs_type is record
    ucnt : slv(CDUWIDTH-1 downto 0);    -- usec clock divider counter
    mcnt : slv10;                       -- msec clock divider counter
    usec : slbit;                       -- usec pulse
    msec : slbit;                       -- msec pulse
  end record regs_type;

  constant regs_init : regs_type := (
    slv(to_unsigned(USECDIV-1,CDUWIDTH)),
    slv(to_unsigned(MSECDIV-1,10)),
    '0','0'
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  assert USECDIV <= 2**CDUWIDTH and MSECDIV <= 1024
    report "assert(USECDIV <= 2**CDUWIDTH and MSECDIV <= 1024): " &
           "USECDIV too large for given CDUWIDTH or MSECDIV>1024"
    severity FAILURE;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

  begin

    r := R_REGS;
    n := R_REGS;

    n.usec := '0';
    n.msec := '0';

    n.ucnt := slv(unsigned(r.ucnt) - 1);
    if unsigned(r.ucnt) = 0 then
      n.usec := '1';
      n.ucnt := slv(to_unsigned(USECDIV-1,CDUWIDTH));
      n.mcnt := slv(unsigned(r.mcnt) - 1);
      if unsigned(r.mcnt) = 0 then
        n.msec := '1';
        n.mcnt := slv(to_unsigned(MSECDIV-1,10));
      end if;
    end if;
    
    N_REGS <= n;

    CE_USEC <= r.usec;
    CE_MSEC <= r.msec;
    
  end process proc_next;


end syn;
