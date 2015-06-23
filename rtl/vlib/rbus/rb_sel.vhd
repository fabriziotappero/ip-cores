-- $Id: rb_sel.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2010-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rb_sel - syn
-- Description:    rbus: address select logic
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 12.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-15   583   4.0    rb_mreq addr now 16 bit
-- 2010-12-26   349   1.0    Initial version (cloned from ibus/ib_sel)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity rb_sel is                        -- rbus address select logic
  generic (
    RB_ADDR : slv16;                    -- rbus address base
    SAWIDTH : natural := 0);            -- device subaddress space width
  port (
    CLK : in slbit;                     -- clock
    RB_MREQ :  in rb_mreq_type;         -- ibus request
    SEL : out slbit                     -- select state bit
  );
end rb_sel;

architecture syn of rb_sel is
  signal R_SEL : slbit := '0';  
begin

  assert SAWIDTH<=15                    -- at most 32k word devices
    report "assert(SAWIDTH<=15)" severity failure;
   
  proc_regs: process (CLK)
    variable isel : slbit := '0';
  begin
    if rising_edge(CLK) then
      isel := '0';
      if RB_MREQ.aval='1' and
        RB_MREQ.addr(15 downto SAWIDTH)=RB_ADDR(15 downto SAWIDTH) then
        isel := '1';
      end if;
      R_SEL <= isel;
    end if;
  end process proc_regs;

  SEL <= R_SEL;
  
end syn;
