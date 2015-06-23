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
-- File        : tbTimeoutGenerator-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;

entity tbTimeoutGenerator is

	end entity tbTimeoutGenerator;

architecture Bhv of tbTimeoutGenerator is

	constant cClkFrequency : natural     := 25E6;
	constant cClkPeriod    : time        := 1 sec / cClkFrequency;
	constant cResetTime    : time        := 4 * cClkPeriod;
	constant cTimeoutTime  : time        := 10 us;
	signal Clk             : std_ulogic  := '1';
	signal ResetSync       : std_ulogic  := cActivated;
	signal Done            : std_ulogic  := cInactivated;
	signal Timeout         : std_ulogic;
	signal Enable          : std_ulogic  := cInactivated;

begin

	Clk       <= not Clk after (cClkPeriod / 2) when Done = cInactivated else '0';
	ResetSync <= cInactivated after cResetTime;

	DUT : entity work.TimeoutGenerator
	generic map (
		gClkFrequency => cClkFrequency,
		gTimeoutTime  => cTimeoutTime
	)
	port map (
		iClk     => Clk,
		iRstSync => ResetSync,
		iDisable => cInactivated,
		iEnable  => Enable,
		oTimeout => Timeout
	);

	Stimuli : process
	begin
		wait for cResetTime;

		wait for cTimeoutTime;
		Enable <= cActivated,
				  cInactivated after 2 * cClkPeriod;

		wait for 2*cTimeoutTime;
		Enable <= cActivated;

		wait;
	end process Stimuli;

	Checker : process (Timeout)
	begin
		if (Timeout = cActivated or Timeout = cInactivated) then -- first 'U'
			if (now = cResetTime + 2 * cTimeoutTime or
			now = cResetTime + 4 * cTimeoutTime) then
				assert (Timeout = cActivated)
				report "Timeout was not activated at the right time"
				severity error;
			elsif (now = cResetTime + 5 * cTimeoutTime) then
				assert (Timeout = cActivated)
				report "Timeout was not activated at the right time"
				severity error;
				Done <= cActivated;
			else 
				assert (Timeout = cInactivated)
				report "Timeout was activated at a wrong time"
				severity error;
			end if;
		end if;
	end process Checker;

end architecture Bhv;	

