-- $Id: dcm_sfs_unisim_s3.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    dcm_sfs - syn
-- Description:    DCM for simple frequency synthesis; SPARTAN-3 version
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan-3A,-3E
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-17   426   1.0.3  rename dcm_sp_sfs -> dcm_sfs, SPARTAN-3 version
-- 2011-11-10   423   1.0.2  add FAMILY generic, SPARTAN-3 support
-- 2010-11-12   338   1.0.1  drop SB_CLK generic; allow DIV=1,MUL=1 without DCM
-- 2010-11-07   337   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity dcm_sfs is                       -- DCM for simple frequency synthesis
  generic (
    CLKFX_DIVIDE : positive := 1;       -- FX clock divide   (1-32)
    CLKFX_MULTIPLY : positive := 1;     -- FX clock multiply (2-32) (1->no DCM)
    CLKIN_PERIOD : real := 20.0);       -- CLKIN period (def is 20.0 ns)
  port (
    CLKIN : in slbit;                   -- clock input
    CLKFX : out slbit;                  -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- dcm locked
  );
end dcm_sfs;


architecture syn of dcm_sfs is

begin

  assert (CLKFX_DIVIDE=1 and CLKFX_MULTIPLY=1) or CLKFX_MULTIPLY>=2
  report "assert((FX_DIV=1 and FX_MULT)=1 or FX_MULT>=2"
  severity failure;

  DCM0: if CLKFX_DIVIDE=1 and CLKFX_MULTIPLY=1 generate
    CLKFX  <= CLKIN;
    LOCKED <= '1';
  end generate DCM0;

  DCM1: if CLKFX_MULTIPLY>=2 generate
    
    DCM : dcm
      generic map (
        CLK_FEEDBACK       => "NONE",
        CLKFX_DIVIDE       => CLKFX_DIVIDE,
        CLKFX_MULTIPLY     => CLKFX_MULTIPLY,
        CLKIN_DIVIDE_BY_2  => false,
        CLKIN_PERIOD       => CLKIN_PERIOD,
        CLKOUT_PHASE_SHIFT => "NONE",
        DESKEW_ADJUST      => "SYSTEM_SYNCHRONOUS",
        DSS_MODE           => "NONE")
      port map (
        CLKIN   => CLKIN,
        CLKFX   => CLKFX,
        LOCKED  => LOCKED
      );

  end generate DCM1;
   
end syn;
