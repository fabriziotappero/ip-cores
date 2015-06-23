-- $Id: debounce_gen.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    debounce_gen - syn
-- Description:    Generic signal debouncer
--
-- Dependencies:   -
-- Test bench:     tb/tb_debounce_gen
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-22   418   1.0.3  now numeric_std clean
-- 2007-12-26   105   1.0.2  add default for RESET
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-29    61   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity debounce_gen is                  -- debounce, generic vector
  generic (
    CWIDTH : positive := 2;             -- clock interval counter width
    CEDIV : positive := 3;              -- clock interval divider
    DWIDTH : positive := 8);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_INT : in slbit;                  -- clock interval enable (usec or msec)
    DI : in slv(DWIDTH-1 downto 0);     -- data in
    DO : out slv(DWIDTH-1 downto 0)     -- data out
  );
end entity debounce_gen;


architecture syn of debounce_gen is

  constant cntzero : slv(CWIDTH-1 downto 0) := (others=>'0');
  constant datazero : slv(dWIDTH-1 downto 0) := (others=>'0');

  type regs_type is record
    cecnt : slv(CWIDTH-1 downto 0);     -- clock interval counter
    dref : slv(DWIDTH-1 downto 0);      -- data reference
    dchange : slv(DWIDTH-1 downto 0);   -- data change flag
    dout : slv(DWIDTH-1 downto 0);      -- data output
  end record regs_type;
  
  constant regs_init : regs_type := (
    cntzero,
    datazero,
    datazero,
    datazero
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  assert CEDIV<=2**CWIDTH report "assert(CEDIV<=2**CWIDTH)" severity failure;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS.cecnt <= cntzero;
        R_REGS.dref  <= DI;
        R_REGS.dchange <= datazero;
        R_REGS.dout  <= DI;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, CE_INT, DI)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

  begin

    r := R_REGS;
    n := R_REGS;

    for i in DI'range loop
      if DI(i) /= r.dref(i) then
        n.dchange(i) := '1';
      end if;
    end loop;

    if CE_INT = '1' then
      if unsigned(r.cecnt) = 0 then
        n.cecnt := slv(to_unsigned(CEDIV-1,CWIDTH));
        n.dref  := DI;
        n.dchange := datazero;
        for i in DI'range loop
          if r.dchange(i) = '0' then
            n.dout(i) := r.dref(i);
          end if;
        end loop;

      else
        n.cecnt := slv(unsigned(r.cecnt) - 1);
      end if;
    end if;
    
    N_REGS <= n;

    DO <= r.dout;

  end process proc_next;


end syn;

