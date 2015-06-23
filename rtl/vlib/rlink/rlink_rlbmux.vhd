-- $Id: rlink_rlbmux.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2012- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_rlbmux - syn
-- Description:    rlink rlb multiplexer
--
-- Dependencies:   -
-- Test bench:     -
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-12-29   466   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;

entity rlink_rlbmux is               -- rlink rlb multiplexer
  port (
    SEL : in slbit;                     -- port select (0:RLB<->P0; 1:RLB<->P1)
    RLB_DI : out slv8;                  -- rlb: data in
    RLB_ENA : out slbit;                -- rlb: data enable
    RLB_BUSY : in slbit;                -- rlb: data busy
    RLB_DO : in slv8;                   -- rlb: data out
    RLB_VAL : in slbit;                 -- rlb: data valid
    RLB_HOLD : out slbit;               -- rlb: data hold
    P0_RXDATA : in slv8;                -- p0: rx data
    P0_RXVAL : in slbit;                -- p0: rx valid
    P0_RXHOLD : out slbit;              -- p0: rx hold
    P0_TXDATA : out slv8;               -- p0: tx data
    P0_TXENA : out slbit;               -- p0: tx enable
    P0_TXBUSY : in slbit;               -- p0: tx busy
    P1_RXDATA : in slv8;                -- p1: rx data
    P1_RXVAL : in slbit;                -- p1: rx valid
    P1_RXHOLD : out slbit;              -- p1: rx hold
    P1_TXDATA : out slv8;               -- p1: tx data
    P1_TXENA : out slbit;               -- p1: tx enable
    P1_TXBUSY : in slbit                -- p1: tx busy
  );
end rlink_rlbmux;


architecture syn of rlink_rlbmux is

begin

  proc_rlmux : process (SEL, RLB_DO, RLB_VAL, RLB_BUSY,
                        P0_RXDATA, P0_RXVAL, P0_TXBUSY,
                        P1_RXDATA, P1_RXVAL, P1_TXBUSY)
  begin

    P0_TXDATA <= RLB_DO;
    P1_TXDATA <= RLB_DO;
    
    if SEL = '0' then 
      RLB_DI    <= P0_RXDATA;
      RLB_ENA   <= P0_RXVAL;
      P0_RXHOLD <= RLB_BUSY;
      P0_TXENA  <= RLB_VAL;
      RLB_HOLD  <= P0_TXBUSY;
      P1_RXHOLD <= '0';
      P1_TXENA  <= '0';
    else
      RLB_DI    <= P1_RXDATA;
      RLB_ENA   <= P1_RXVAL;
      P1_RXHOLD <= RLB_BUSY;
      P1_TXENA  <= RLB_VAL;
      RLB_HOLD  <= P1_TXBUSY;      
      P0_RXHOLD <= '0';
      P0_TXENA  <= '0';
    end if;
    
  end process proc_rlmux;

end syn;
