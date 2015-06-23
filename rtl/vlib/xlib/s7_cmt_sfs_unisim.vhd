-- $Id: s7_cmt_sfs_unisim.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    s7_cmt_sfs - syn
-- Description:    Series-7 CMT for simple frequency synthesis
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-09-28   535   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity s7_cmt_sfs is                    -- 7-Series CMT for simple freq. synth.
  generic (
    VCO_DIVIDE : positive := 1;         -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE : positive := 1;         -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE : string := "PLL");        -- PLL or MMCM
  port (
    CLKIN : in slbit;                   -- clock input
    CLKFX : out slbit;                  -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/mmcm locked
  );
end s7_cmt_sfs;


architecture syn of s7_cmt_sfs is

begin
    
  assert GEN_TYPE = "PLL" or GEN_TYPE = "MMCM"
    report "assert(GEN_TYPE='PLL' or GEN_TYPE='MMCM')"
    severity failure;

  NOGEN: if VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1 generate
    CLKFX  <= CLKIN;
    LOCKED <= '1';
  end generate NOGEN;

  USEPLL: if GEN_TYPE = "PLL" and
             not(VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1) generate

    signal CLKFBOUT         : slbit;
    signal CLKFBOUT_BUF     : slbit;
    signal CLKOUT0          : slbit;
    signal CLKOUT1_UNUSED   : slbit;
    signal CLKOUT2_UNUSED   : slbit;
    signal CLKOUT3_UNUSED   : slbit;
    signal CLKOUT4_UNUSED   : slbit;
    signal CLKOUT5_UNUSED   : slbit;
    signal CLKOUT6_UNUSED   : slbit;

    pure function bool2string (val : boolean) return string is
    begin
      if val then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end function bool2string;
      
  begin

    PLL : PLLE2_BASE
      generic map (
        BANDWIDTH            => "OPTIMIZED",
        DIVCLK_DIVIDE        => VCO_DIVIDE,
        CLKFBOUT_MULT        => VCO_MULTIPLY,
        CLKFBOUT_PHASE       => 0.000,
        CLKOUT0_DIVIDE       => OUT_DIVIDE,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKIN1_PERIOD        => CLKIN_PERIOD,
        REF_JITTER1          => CLKIN_JITTER,
        STARTUP_WAIT         => bool2string(STARTUP_WAIT))
      port map (
        CLKFBOUT            => CLKFBOUT,
        CLKOUT0             => CLKOUT0,
        CLKOUT1             => CLKOUT1_UNUSED,
        CLKOUT2             => CLKOUT2_UNUSED,
        CLKOUT3             => CLKOUT3_UNUSED,
        CLKOUT4             => CLKOUT4_UNUSED,
        CLKOUT5             => CLKOUT5_UNUSED,
        CLKFBIN             => CLKFBOUT_BUF,
        CLKIN1              => CLKIN,
        LOCKED              => LOCKED,
        PWRDWN              => '0',
        RST                 => '0'
      );

    BUFG_CLKFB : BUFG
      port map (
        I => CLKFBOUT,
        O => CLKFBOUT_BUF
      );

    BUFG_CLKOUT : BUFG
      port map (
        I => CLKOUT0,
        O => CLKFX
      );

  end generate USEPLL;
   
  USEMMCM: if GEN_TYPE = "MMCM" and
             not(VCO_DIVIDE=1 and VCO_MULTIPLY=1 and OUT_DIVIDE=1) generate

    signal CLKFBOUT         : slbit;
    signal CLKFBOUT_BUF     : slbit;
    signal CLKFBOUTB_UNUSED : slbit;
    signal CLKOUT0          : slbit;
    signal CLKOUT0B_UNUSED  : slbit;
    signal CLKOUT1_UNUSED   : slbit;
    signal CLKOUT1B_UNUSED  : slbit;
    signal CLKOUT2_UNUSED   : slbit;
    signal CLKOUT2B_UNUSED  : slbit;
    signal CLKOUT3_UNUSED   : slbit;
    signal CLKOUT3B_UNUSED  : slbit;
    signal CLKOUT4_UNUSED   : slbit;
    signal CLKOUT5_UNUSED   : slbit;
    signal CLKOUT6_UNUSED   : slbit;

  begin

    MMCM : MMCME2_BASE
      generic map (
        BANDWIDTH            => "OPTIMIZED",
        DIVCLK_DIVIDE        => VCO_DIVIDE,
        CLKFBOUT_MULT_F      => real(VCO_MULTIPLY),
        CLKFBOUT_PHASE       => 0.000,
        CLKOUT0_DIVIDE_F     => real(OUT_DIVIDE),
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKIN1_PERIOD        => CLKIN_PERIOD,
        REF_JITTER1          => CLKIN_JITTER,
        STARTUP_WAIT         => STARTUP_WAIT)
      port map (
        CLKFBOUT            => CLKFBOUT,
        CLKFBOUTB           => CLKFBOUTB_UNUSED,
        CLKOUT0             => CLKOUT0,
        CLKOUT0B            => CLKOUT0B_UNUSED,
        CLKOUT1             => CLKOUT1_UNUSED,
        CLKOUT1B            => CLKOUT1B_UNUSED,
        CLKOUT2             => CLKOUT2_UNUSED,
        CLKOUT2B            => CLKOUT2B_UNUSED,
        CLKOUT3             => CLKOUT3_UNUSED,
        CLKOUT3B            => CLKOUT3B_UNUSED,
        CLKOUT4             => CLKOUT4_UNUSED,
        CLKOUT5             => CLKOUT5_UNUSED,
        CLKFBIN             => CLKFBOUT_BUF,
        CLKIN1              => CLKIN,
        LOCKED              => LOCKED,
        PWRDWN              => '0',
        RST                 => '0'
      );

    BUFG_CLKFB : BUFG
      port map (
        I => CLKFBOUT,
        O => CLKFBOUT_BUF
      );

    BUFG_CLKOUT : BUFG
      port map (
        I => CLKOUT0,
        O => CLKFX
      );

  end generate USEMMCM;
   
end syn;
