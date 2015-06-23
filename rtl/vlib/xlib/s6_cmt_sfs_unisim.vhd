-- $Id: s6_cmt_sfs_unisim.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    s6_cmt_sfs - syn
-- Description:    Spartan-6 CMT for simple frequency synthesis
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan-6
-- Tool versions:  xst 14.5-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-10-05   537   1.0    Initial version (derived from s7_cmt_sfs)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity s6_cmt_sfs is                    -- Spartan-6 CMT for simple freq. synth.
  generic (
    VCO_DIVIDE : positive := 1;         -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE : positive := 1;         -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE : string := "PLL");        -- PLL or DCM
  port (
    CLKIN : in slbit;                   -- clock input
    CLKFX : out slbit;                  -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/dcm locked
  );
end s6_cmt_sfs;


architecture syn of s6_cmt_sfs is

begin
    
  assert GEN_TYPE = "PLL" or GEN_TYPE = "DCM"
    report "assert(GEN_TYPE='PLL' or GEN_TYPE='DCM')"
    severity failure;

  NOGEN: if VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1 generate
    CLKFX  <= CLKIN;
    LOCKED <= '1';
  end generate NOGEN;

  USEPLL: if GEN_TYPE = "PLL" and
             not(VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1) generate

    signal CLKFBOUT         : slbit;
    signal CLKOUT0          : slbit;
    signal CLKOUT1_UNUSED   : slbit;
    signal CLKOUT2_UNUSED   : slbit;
    signal CLKOUT3_UNUSED   : slbit;
    signal CLKOUT4_UNUSED   : slbit;
    signal CLKOUT5_UNUSED   : slbit;

  begin

    PLL : pll_base
      generic map (
        BANDWIDTH            => "OPTIMIZED",
        CLK_FEEDBACK         => "CLKFBOUT",
        COMPENSATION         => "INTERNAL",
        DIVCLK_DIVIDE        => VCO_DIVIDE,
        CLKFBOUT_MULT        => VCO_MULTIPLY,
        CLKFBOUT_PHASE       => 0.000,
        CLKOUT0_DIVIDE       => OUT_DIVIDE,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKIN_PERIOD         => CLKIN_PERIOD,
        REF_JITTER           => CLKIN_JITTER)
      port map (
        CLKFBOUT            => CLKFBOUT,
        CLKOUT0             => CLKOUT0,
        CLKOUT1             => CLKOUT1_UNUSED,
        CLKOUT2             => CLKOUT2_UNUSED,
        CLKOUT3             => CLKOUT3_UNUSED,
        CLKOUT4             => CLKOUT4_UNUSED,
        CLKOUT5             => CLKOUT5_UNUSED,
        CLKFBIN             => CLKFBOUT,
        CLKIN               => CLKIN,
        LOCKED              => LOCKED,
        RST                 => '0'
      );

    BUFG_CLKOUT : bufg
      port map (
        I => CLKOUT0,
        O => CLKFX
      );

  end generate USEPLL;
   
  USEDCM: if GEN_TYPE = "DCM" and
             not(VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1)  generate

    signal CLKOUT0          : slbit;

  begin

    DCM : dcm_sp
      generic map (
        CLK_FEEDBACK       => "NONE",
        CLKFX_DIVIDE       => VCO_DIVIDE,
        CLKFX_MULTIPLY     => VCO_MULTIPLY,
        CLKIN_DIVIDE_BY_2  => false,
        CLKIN_PERIOD       => CLKIN_PERIOD,
        CLKOUT_PHASE_SHIFT => "NONE",
        DESKEW_ADJUST      => "SYSTEM_SYNCHRONOUS",
        DSS_MODE           => "NONE",
        STARTUP_WAIT       => STARTUP_WAIT)
      port map (
        CLKIN   => CLKIN,
        CLKFX   => CLKOUT0,
        LOCKED  => LOCKED
      );

    BUFG_CLKOUT : bufg
      port map (
        I => CLKOUT0,
        O => CLKFX
      );

  end generate USEDCM;
   
end syn;
