-- $Id: cdc_pulse.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    cdc_pulse - syn
-- Description:    clock domain cross for pulse
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version    Comment
-- 2011-11-09   422   1.0      Initial version
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity cdc_pulse is                     -- clock domain cross for pulse
  generic (
    POUT_SINGLE : boolean := false;     -- if true: single cycle pout
    BUSY_WACK : boolean := false);      -- if true: busy waits for ack
  port (
    CLKM : in slbit;                    -- clock master
    RESET : in slbit := '0';            -- M|reset
    CLKS : in slbit;                    -- clock slave
    PIN : in slbit;                     -- M|pulse in
    BUSY : out slbit;                   -- M|busy
    POUT : out slbit                    -- S|pulse out
  );
end entity cdc_pulse;


architecture syn of cdc_pulse is

  signal R_REQ   : slbit := '0';
  signal R_REQ_C : slbit := '0';
  signal R_ACK   : slbit := '0';
  signal R_ACK_C : slbit := '0';
  signal R_ACK_S : slbit := '0';

begin

  proc_master: process (CLKM)
  begin
    if rising_edge(CLKM) then
      if RESET = '1' then
        R_REQ <= '0';
      else
        if PIN = '1' then
          R_REQ <= '1';
        elsif R_ACK_S = '1' then
          R_REQ <= '0';
        end if;
      end if;
      R_ACK_C <= R_ACK;
      R_ACK_S <= R_ACK_C;
    end if;
  end process proc_master;

  proc_slave: process (CLKS)
  begin
    if rising_edge(CLKS) then
      R_REQ_C <= R_REQ;
      R_ACK   <= R_REQ_C;
    end if;
  end process proc_slave;

  SINGLE1: if POUT_SINGLE = true generate
    signal R_ACK_1 : slbit := '0';
    signal R_POUT  : slbit := '0';
  begin
    proc_pout: process (CLKS)
    begin
      if rising_edge(CLKS) then
        R_ACK_1 <= R_ACK;
        if R_ACK='1' and R_ACK_1='0' then
          R_POUT <= '1';
        else
          R_POUT <= '0';
        end if;
      end if;
    end process proc_pout;
    POUT <= R_POUT;
  end generate SINGLE1;

  SINGLE0: if POUT_SINGLE = false generate
  begin
    POUT <= R_ACK;
  end generate SINGLE0;
  
  BUSY1: if BUSY_WACK = true generate
  begin
    BUSY <= R_REQ or R_ACK_S;
  end generate BUSY1;

  BUSY0: if BUSY_WACK = false generate
  begin
    BUSY <= R_REQ;
  end generate BUSY0;
  
end syn;

