-- $Id: s7_cmt_sfs_gsim.vhd 675 2015-05-08 21:05:08Z mueller $
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
-- Module Name:    s7_cmt_sfs - sim
-- Description:    Series-7 CMT  for simple frequency synthesis
--                 simple vhdl model, without Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  xst 14.5; viv 2014.4; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-09-28   535   1.0    Initial version (derived from dcm_sfs_gsim)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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


architecture sim of s7_cmt_sfs is

  signal CLK_DIVPULSE : slbit := '0';
  signal CLKOUT_PERIOD : time := 0 ns;
  signal R_CLKOUT : slbit := '0';
  signal R_LOCKED : slbit := '0';
  
begin

  proc_init : process

    -- currently frequency limits taken from Artix-7 speed grade -1
    constant f_vcomin_pll  : integer :=  800;
    constant f_vcomax_pll  : integer := 1600;
    constant f_pdmin_pll   : integer :=   19;
    constant f_pdmax_pll   : integer :=  450;

    constant f_vcomin_mmcm : integer :=  600;
    constant f_vcomax_mmcm : integer := 1200;
    constant f_pdmin_mmcm  : integer :=   10;
    constant f_pdmax_mmcm  : integer :=  450;

    variable t_vco : time := 0 ns;
    variable t_vcomin : time := 0 ns;
    variable t_vcomax : time := 0 ns;
    variable t_pd : time := 0 ns;
    variable t_pdmin : time := 0 ns;
    variable t_pdmax : time := 0 ns;

  begin
    -- validate generics

    
    if not (GEN_TYPE = "PLL" or GEN_TYPE = "MMCM") then
      assert false 
        report "assert(GEN_TYPE='PLL' or GEN_TYPE='MMCM')"
        severity failure;
    end if;

    if VCO_DIVIDE/=1 or VCO_MULTIPLY/=1 or OUT_DIVIDE/=1 then

      if GEN_TYPE = "PLL" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>56 or
          VCO_MULTIPLY<2 or VCO_MULTIPLY>64 or
          OUT_DIVIDE<1   or OUT_DIVIDE>128
        then
          assert false 
            report
          "assert(VCO_DIVIDE in 1:56 VCO_MULTIPLY in 2:64 OUT_DIVIDE in 1:128)"
            severity failure;
        end if;
        -- setup VCO and PD range check boundaries
        t_vcomin := (1000 ns / f_vcomax_pll) - 1 ps;
        t_vcomax := (1000 ns / f_vcomin_pll) + 1 ps;
        t_pdmin  := (1000 ns / f_pdmax_pll) - 1 ps;
        t_pdmax  := (1000 ns / f_pdmin_pll) + 1 ps;

      end if; -- GEN_TYPE = "PLL"

      if GEN_TYPE = "MMCM" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>106 or
           VCO_MULTIPLY<2 or VCO_MULTIPLY>64 or
           OUT_DIVIDE<1   or OUT_DIVIDE>128
        then
          assert false 
            report
          "assert(VCO_DIVIDE in 1:106 VCO_MULTIPLY in 2:64 OUT_DIVIDE in 1:128)"
            severity failure;
        end if;
        -- setup VCO and PD range check boundaries
        t_vcomin := (1000 ns / f_vcomax_pll) - 1 ps;
        t_vcomax := (1000 ns / f_vcomin_pll) + 1 ps;
        t_pdmin  := (1000 ns / f_pdmax_pll) - 1 ps;
        t_pdmax  := (1000 ns / f_pdmin_pll) + 1 ps;

      end if; -- GEN_TYPE = "MMCM"

      -- now common check whether VCO and PD frequency is in range
      t_pd  := (1 ps * (1000.0*CLKIN_PERIOD)) * VCO_DIVIDE;
      t_vco := t_pd / VCO_MULTIPLY;

      if t_vco<t_vcomin or t_vco>t_vcomax then
        assert false 
          report "assert(VCO frequency out of range)"
          severity failure;
      end if;
      
      if t_pd<t_pdmin or t_pd>t_pdmax then
        assert FALSE 
          report "assert(PD frequency out of range)"
          severity failure;
      end if;

    end if;  -- one factor /= 1
      
    wait;
  end process proc_init;

  proc_clkin : process (CLKIN)
    variable t_lastclkin : time := 0 ns;
    variable t_lastperiod : time := 0 ns;
    variable t_period : time := 0 ns;
    variable nclkin : integer := 1;
  begin
    
    if CLKIN'event then
      if CLKIN = '1' then               -- if CLKIN rising edge

        if t_lastclkin > 0 ns then
          t_lastperiod := t_period;
          t_period := now - t_lastclkin;
          CLKOUT_PERIOD <= (t_period * VCO_DIVIDE * OUT_DIVIDE) / VCO_MULTIPLY;
          if t_lastperiod > 0 ns and abs(t_period-t_lastperiod) > 1 ps then
            report "s7_cmt_sp_sfs: CLKIN unstable" severity warning;
          end if;
        end if;
        t_lastclkin := now;
        
        if t_period > 0 ns then
          nclkin := nclkin - 1;
          if nclkin <= 0 then
            nclkin := VCO_DIVIDE * OUT_DIVIDE;
            CLK_DIVPULSE <= '1';
            R_LOCKED     <= '1';
          end if;
        end if;

      else                              -- if CLKIN falling edge
        CLK_DIVPULSE <= '0';
      end if;     
    end if;
    
  end process proc_clkin;

  proc_clkout : process
    variable t_lastclkin : time := 0 ns;
    variable t_lastperiod : time := 0 ns;
    variable t_period : time := 0 ns;
    variable nclkin : integer := 1;
  begin

    loop
      wait until CLK_DIVPULSE = '1';

      for i in 1 to VCO_MULTIPLY loop
        R_CLKOUT <= '1';
        wait for CLKOUT_PERIOD/2;
        R_CLKOUT <= '0';
        if i /= VCO_MULTIPLY then
          wait for CLKOUT_PERIOD/2;
        end if;
      end loop;  -- i

    end loop;
    
  end process proc_clkout;

  CLKFX  <= R_CLKOUT;
  LOCKED <= R_LOCKED;
  
end sim;
