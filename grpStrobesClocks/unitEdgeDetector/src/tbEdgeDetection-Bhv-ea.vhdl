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
-- File        : tbEdgeDetection-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

library ieee;
use ieee.std_logic_1164.all;
use work.Global.all;

entity tbEdgeDet is

end entity tbEdgeDet;

architecture Bhv of tbEdgeDet is

   -- generics
   constant cClkFrequency  : natural := 25E6;
   constant simulationTime : time    := 1200 ns;

   -- component ports
   signal Clk                                    : std_ulogic := cInactivated;
   signal nResetAsync                            : std_ulogic := cnInactivated;
   signal EdgeDetected, ClearEdgeDetected, iLine : std_ulogic;
   signal EdgeDetected2, EdgeDetected3           : std_ulogic;
   signal EdgeDetected4, EdgeDetected5           : std_ulogic;
   signal EdgeDetected6                          : std_ulogic;

begin  -- architecture Bhv

   -- component instantiation
   DUT : entity work.EdgeDetector(Rtl)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected);

   DUT2 : entity work.EdgeDetector(Rtl)
      generic map (
         gEdgeDetection => cDetectFallingEdge)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected2);

   DUT3 : entity work.EdgeDetector(Rtl)
      generic map (
         gEdgeDetection => cDetectAnyEdge)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected3);
   DUT4 : entity work.EdgeDetector(Rtl)
      generic map (gOutputRegistered => false)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected4);

   DUT5 : entity work.EdgeDetector(Rtl)
      generic map (
         gEdgeDetection    => cDetectFallingEdge,
         gOutputRegistered => false)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected5);

   DUT6 : entity work.EdgeDetector(Rtl)
      generic map (
         gEdgeDetection    => cDetectAnyEdge,
         gOutputRegistered => false)
      port map (
         iLine              => iLine,
         inResetAsync       => nResetAsync,
         iClk               => Clk,
         iClearEdgeDetected => ClearEdgeDetected,
         oEdgeDetected      => EdgeDetected6);

   Clk <= not Clk after (1 sec / cClkFrequency) / 2;

   nResetAsync <= cnInactivated after 0 ns,
                  cnActivated   after 100 ns,
                  cnInactivated after 200 ns;


   TestProcess : process is
   begin
      
      iLine <= '0' after 0 ns, '1' after 301 ns, '0' after 390 ns,
               '1' after 550 ns, '0' after 600 ns, '1' after 690 ns,
               '0' after 1000 ns;
      
      ClearEdgeDetected <= '0' after 0 ns, '1' after 430 ns, '0' after 470 ns, '1'
                           after 590 ns, '0' after 630 ns, '1' after 810 ns,
                           '0'               after 830 ns;
      wait;
   end process TestProcess;

   -- Simulation is finished after predefined time.
   SimulationFinished : process
   begin
      wait for simulationTime;
      assert false
         report "This is not a failure: Simulation finished !!!"
         severity failure;
   end process SimulationFinished;
   
end architecture Bhv;

