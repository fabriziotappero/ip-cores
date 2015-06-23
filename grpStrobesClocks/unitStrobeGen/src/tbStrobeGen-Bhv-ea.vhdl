-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : tbStrobeGen-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

library ieee;
use ieee.std_logic_1164.all;

use work.Global.all;

entity tbStrobeGen is

end entity tbStrobeGen;

architecture Bhv of tbStrobeGen is

  -- component generics
  constant cClkFrequency               : natural := 25E6;
  constant cInResetDuration            : time    := 140 ns;
  constant cStrobeCycleTime            : time    := 1 us;  


  -- component ports
  signal Clk         : std_ulogic := cInactivated;
  signal nResetAsync : std_ulogic := cnInactivated;
  signal Strobe      : std_ulogic;

begin  -- architecture Bhv

  -- component instantiation
  DUT : entity work.StrobeGen
    generic map (
      gClkFrequency    => cClkFrequency,
      gStrobeCycleTime => cStrobeCycleTime)
    port map (
      iClk         => Clk,
      inResetAsync => nResetAsync,
      oStrobe      => Strobe);

  Clk <= not Clk after (1 sec / cClkFrequency) / 2;

  nResetAsync <= cnInactivated after 0 ns,
                 cnActivated   after cInResetDuration,
                 cnInactivated after 2*cInResetDuration;


  -- Process to measure the frequency of the strobe signal and the
  -- active strobe time.
  DetermineStrobeFreq : process
    variable vHighLevel : boolean := false;
    variable vTimestamp : time := 0 sec;
  begin
    wait until (Strobe'event);
    if Strobe = '1' then
      vHighLevel := true;
      if now > vTimestamp then
        assert false
          report "Frequency Value (Strobe) = " &
                 integer'image((1 sec / (now-vTimestamp))) &
                 "Hz; Period (Strobe) = " &
                 time'image(now-vTimestamp)
          severity note;
	    end if;
      vTimestamp := now;
    elsif vHighLevel and Strobe = '0' and
          ((now-vTimestamp)<(1 sec / cClkFrequency)) then
      assert false
        report "Strobe Active Time: " & time'image(now-vTimestamp) & "; " &
               "Clock Cycle time: " & time'image((1 sec / cClkFrequency))
        severity error;
	  end if;

  end process DetermineStrobeFreq;

  -- Simulation is finished after predefined time.
  SimulationFinished : process
  begin
    wait for (10*cStrobeCycleTime);
    assert false
      report "This is not a failure: Simulation finished !!!"
      severity failure;
  end process SimulationFinished;
  
end architecture Bhv;

