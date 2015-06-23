-- $Id: fifo_1c_dram_raw.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    fifo_1c_dram_raw - syn
-- Description:    FIFO, single clock domain, distributed RAM based, 'raw'
--                 interface exposing dram signals.
--
-- Dependencies:   ram_1swar_1ar_gen
--
-- Test bench:     tb/tb_fifo_1c_dram
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-07   421   1.0.2  now numeric_std clean
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-03    47   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;

entity fifo_1c_dram_raw is              -- fifo, 1 clock, dram based, raw
  generic (
    AWIDTH : positive :=  4;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    WE : in slbit;                      -- write enable
    RE : in slbit;                      -- read enable
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    SIZE : out slv(AWIDTH-1 downto 0);  -- number of used slots
    EMPTY : out slbit;                  -- empty flag
    FULL : out slbit                    -- full flag
  );
end fifo_1c_dram_raw;


architecture syn of fifo_1c_dram_raw is

  type regs_type is record
    waddr : slv(AWIDTH-1 downto 0);     -- write address
    raddr : slv(AWIDTH-1 downto 0);     -- read address
    empty : slbit;                      -- empty flag
    full  : slbit;                      -- full flag
  end record regs_type;

  constant memsize : positive := 2**AWIDTH;
  constant regs_init : regs_type := (
    slv(to_unsigned(0,AWIDTH)),         -- waddr
    slv(to_unsigned(0,AWIDTH)),         -- raddr
    '1','0'                             -- empty,full
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal RAM_WE : slbit := '0';
  
begin

  RAM : ram_1swar_1ar_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => DWIDTH)
    port map (
      CLK   => CLK,
      WE    => RAM_WE,
      ADDRA => R_REGS.waddr,
      ADDRB => R_REGS.raddr,
      DI    => DI,
      DOA   => open,
      DOB   => DO
    );
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, RESET, WE, RE)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable isize : slv(AWIDTH-1 downto 0) := (others=>'0');

    variable we_val : slbit := '0';
    variable re_val : slbit := '0';
    variable iram_we : slbit := '0';

  begin

    r := R_REGS;
    n := R_REGS;

    re_val := RE and not r.empty;
    we_val := WE and ((not r.full) or RE);
    isize := slv(unsigned(r.waddr) - unsigned(r.raddr));
    iram_we := '0';
    
    if RESET = '1' then
      n := regs_init;

    else

      if we_val = '1' then
        n.waddr := slv(unsigned(r.waddr) + 1);
        iram_we := '1';
        if re_val = '0' then
          n.empty := '0';
          if unsigned(isize) = memsize-1 then
            n.full := '1';
          end if;
        end if;
      end if;

      if re_val = '1' then
        n.raddr := slv(unsigned(r.raddr) + 1);
        if we_val = '0' then
          n.full := '0';
          if unsigned(isize) = 1 then
            n.empty := '1';
          end if;
        end if;
      end if;

    end if;

    N_REGS <= n;

    RAM_WE <= iram_we;

    SIZE  <= isize;
    EMPTY <= r.empty;
    FULL  <= r.full;
    
  end process proc_next;
  
end syn;
