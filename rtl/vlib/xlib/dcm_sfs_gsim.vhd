-- $Id: dcm_sfs_gsim.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    dcm_sfs - sim
-- Description:    DCM for simple frequency synthesis
--                 simple vhdl model, without Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan-3A,-3E
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-17   426   1.0.1  rename dcm_sp_sfs -> dcm_sfs
-- 2010-11-12   338   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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


architecture sim of dcm_sfs is

  signal CLK_DIVPULSE : slbit := '0';
  signal CLKOUT_PERIOD : time := 0 ns;
  signal R_CLKOUT : slbit := '0';
  signal R_LOCKED : slbit := '0';
  
begin

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
          CLKOUT_PERIOD <= (t_period * CLKFX_DIVIDE) / CLKFX_MULTIPLY;
          if t_lastperiod > 0 ns and abs(t_period-t_lastperiod) > 1 ps then
            report "dcm_sp_sfs: CLKIN unstable" severity warning;
          end if;
        end if;
        t_lastclkin := now;
        
        if t_period > 0 ns then
          nclkin := nclkin - 1;
          if nclkin <= 0 then
            nclkin := CLKFX_DIVIDE;
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

      for i in 1 to CLKFX_MULTIPLY loop
        R_CLKOUT <= '1';
        wait for CLKOUT_PERIOD/2;
        R_CLKOUT <= '0';
        if i /= CLKFX_MULTIPLY then
          wait for CLKOUT_PERIOD/2;
        end if;
      end loop;  -- i

    end loop;
    
  end process proc_clkout;

  CLKFX  <= R_CLKOUT;
  LOCKED <= R_LOCKED;
  
end sim;
