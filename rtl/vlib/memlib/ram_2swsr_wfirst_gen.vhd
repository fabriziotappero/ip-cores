-- $Id: ram_2swsr_wfirst_gen.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ram_2swsr_wfirst_gen - syn
-- Description:    Dual-Port RAM with with two synchronous read/write ports
--                 and 'read-through' semantics (as block RAM).
--                 The code is inspired by Xilinx example rams_16.vhd. The
--                 'ram_style' attribute is set to 'block', this will
--                 force in XST a synthesis as block RAM.
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-08   422   1.0.4  now numeric_std clean
-- 2010-06-03   299   1.0.3  use sv_ prefix for shared variables
-- 2008-03-08   123   1.0.2  use std_..._arith, not _unsigned; use unsigned();
-- 2008-03-02   122   1.0.1  change generic default for BRAM models
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity ram_2swsr_wfirst_gen is          -- RAM, 2 sync r/w ports, write first
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9);           -- data port width
  port(
    CLKA  : in slbit;                   -- clock port A
    CLKB  : in slbit;                   -- clock port B
    ENA   : in slbit;                   -- enable port A
    ENB   : in slbit;                   -- enable port B
    WEA   : in slbit;                   -- write enable port A
    WEB   : in slbit;                   -- write enable port B
    ADDRA : in slv(AWIDTH-1 downto 0);  -- address port A
    ADDRB : in slv(AWIDTH-1 downto 0);  -- address port B
    DIA   : in slv(DWIDTH-1 downto 0);  -- data in port A
    DIB   : in slv(DWIDTH-1 downto 0);  -- data in port B
    DOA   : out slv(DWIDTH-1 downto 0); -- data out port A
    DOB   : out slv(DWIDTH-1 downto 0)  -- data out port B
  );
end ram_2swsr_wfirst_gen;


architecture syn of ram_2swsr_wfirst_gen is
  constant memsize : positive := 2**AWIDTH;
  constant datzero : slv(DWIDTH-1 downto 0) := (others=>'0');
  type ram_type is array (0 to memsize-1) of slv(DWIDTH-1 downto 0);
  shared variable sv_ram : ram_type := (others=>datzero);

  attribute ram_style : string;
  attribute ram_style of sv_ram : variable is "block";
  
  signal R_DOA : slv(DWIDTH-1 downto 0) := datzero;
  signal R_DOB : slv(DWIDTH-1 downto 0) := datzero;
begin

  proc_clka: process (CLKA)
  begin
    if rising_edge(CLKA) then
      if ENA = '1' then
        if WEA = '1' then
          sv_ram(to_integer(unsigned(ADDRA))) := DIA;
        end if;
        R_DOA <= sv_ram(to_integer(unsigned(ADDRA)));
      end if;
    end if;
  end process proc_clka;

  proc_clkb: process (CLKB)
  begin
    if rising_edge(CLKB) then
      if ENB = '1' then
        if WEB = '1' then
          sv_ram(to_integer(unsigned(ADDRB))) := DIB;
        end if;
        R_DOB <= sv_ram(to_integer(unsigned(ADDRB)));
      end if;
    end if;
  end process proc_clkb;

  DOA <= R_DOA;
  DOB <= R_DOB;
  
end syn;
