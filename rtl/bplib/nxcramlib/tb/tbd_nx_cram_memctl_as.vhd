-- $Id: tbd_nx_cram_memctl_as.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbd_nx_cram_memctl_as - syn
-- Description:    Wrapper for nx_cram_memctl_as to avoid records & generics.
--                 It has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   nx_cram_memctl_as
-- To test:        nx_cram_memctl_as
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-06-03   299  11.4   L68  xc3s1200e-4   91  122    0  107 t 11.4 
-- 2010-05-30   297  11.4   L68  xc3s1200e-4   91   99    0   95 t 13.1 
--
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.2    renamed from tbd_n2_cram_memctl_as
-- 2011-11-23   432   1.1    remove O_FLA_CE_N port from n2_cram_memctl
-- 2010-06-03   298   1.0.1  add hack to force IOB'FFs to O_MEM_ADDR
-- 2010-05-30   297   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.nxcramlib.all;

entity tbd_nx_cram_memctl_as is         -- CRAM driver (async mode) [tb design]
                                        -- generic: READ0=2;READ1=2;WRITE=3
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv22;                    -- address  (32 bit word address)
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N : out slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end tbd_nx_cram_memctl_as;


architecture syn of tbd_nx_cram_memctl_as is

  signal ADDR_X : slv22 := (others=>'0');
  
begin

  -- Note: This is a HACk to ensure that the IOB flops are on the O_MEM_ADDR
  --   pins. Without par might choose to use IFF's on ADDR, causing varying
  --   routing delays to O_MEM_ADDR. Didn't find a better way, setting
  --   iob "false" attributes in ADDR didn't help.
  --   This logic doesn't hurt, and prevents that IFFs for ADDR compete with
  --   OFF's for O_MEM_ADDR.
  
  ADDR_X <= ADDR when RESET='0' else (others=>'0');
  
  MEMCTL : nx_cram_memctl_as
    generic map (
      READ0DELAY => 2,
      READ1DELAY => 2,
      WRITEDELAY => 3)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      REQ    => REQ,
      WE     => WE,
      BUSY   => BUSY,
      ACK_R  => ACK_R,
      ACK_W  => ACK_W,
      ACT_R  => ACT_R,
      ACT_W  => ACT_W,
      ADDR   => ADDR_X,
      BE     => BE,
      DI     => DI,
      DO     => DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );
  
end syn;
