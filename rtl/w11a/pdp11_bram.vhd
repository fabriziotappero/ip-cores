-- $Id: pdp11_bram.vhd 677 2015-05-09 21:52:32Z mueller $
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
-- Module Name:    pdp11_bram - syn
-- Description:    pdp11: BRAM based ext. memory dummy
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.0.3  now numeric_std clean
-- 2008-03-01   120   1.0.2  add addrzero constant to avoid XST errors
-- 2008-02-23   118   1.0.1  AWIDTH now a generic port
-- 2008-02-17   117   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.pdp11.all;

entity pdp11_bram is                   -- cache
  generic (
    AWIDTH : positive := 14);           -- address width
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    EM_MREQ : in em_mreq_type;          -- em request
    EM_SRES : out em_sres_type          -- em response
  );
end pdp11_bram;


architecture syn of pdp11_bram is

  type regs_type is record
    req_r : slbit;                      -- read request
    req_w : slbit;                      -- write request
    be : slv2;                          -- byte enables
    addr : slv(AWIDTH-1 downto 1);      -- address
  end record regs_type;

  constant addrzero : slv(AWIDTH-1 downto 1) := (others=>'0');

  constant regs_init : regs_type := (
    '0','0',                            -- req_r,w
    (others=>'0'),                      -- be
    addrzero                            -- addr
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal MEM_ENB : slbit := '0';
  signal MEM_WEA : slv2  := "00";
  signal MEM_DOA : slv16 := (others=>'0');
begin

  MEM_BYT0 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => AWIDTH-1,
      DWIDTH =>  8)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => EM_MREQ.req,
      ENB   => MEM_ENB,
      WEA   => MEM_WEA(0),
      WEB   => R_REGS.be(0),
      ADDRA => EM_MREQ.addr(AWIDTH-1 downto 1),
      ADDRB => R_REGS.addr,
      DIA   => EM_MREQ.din(7 downto 0),
      DIB   => MEM_DOA(7 downto 0),
      DOA   => MEM_DOA(7 downto 0),
      DOB   => open
      );

  MEM_BYT1 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => AWIDTH-1,
      DWIDTH =>  8)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => EM_MREQ.req,
      ENB   => MEM_ENB,
      WEA   => MEM_WEA(1),
      WEB   => R_REGS.be(1),
      ADDRA => EM_MREQ.addr(AWIDTH-1 downto 1),
      ADDRB => R_REGS.addr,
      DIA   => EM_MREQ.din(15 downto 8),
      DIB   => MEM_DOA(15 downto 8),
      DOA   => MEM_DOA(15 downto 8),
      DOB   => open
      );
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if GRESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  N_REGS.req_r  <= EM_MREQ.req and not EM_MREQ.we;
  N_REGS.req_w  <= EM_MREQ.req and EM_MREQ.we;
  N_REGS.be     <= EM_MREQ.be;
  N_REGS.addr   <= EM_MREQ.addr(N_REGS.addr'range);
  
  MEM_WEA(0) <= EM_MREQ.we and EM_MREQ.be(0);
  MEM_WEA(1) <= EM_MREQ.we and EM_MREQ.be(1);
  MEM_ENB    <= EM_MREQ.cancel and R_REGS.req_w;

  EM_SRES.ack_r <= R_REGS.req_r;
  EM_SRES.ack_w <= R_REGS.req_w;
  EM_SRES.dout  <= MEM_DOA;
  
end syn;
