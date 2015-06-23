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
-- File        : tbSdClockMaster-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Non automated testbench
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity tbSdClockMaster is
	end entity tbSdClockMaster;

architecture Bhv of tbSdClockMaster is

	signal Clk             : std_ulogic := cInactivated;
	constant cClkFrequency : natural    := 100E6;
	constant cClkPeriod    : time       := (1 sec / cClkFrequency);
	signal RstSync         : std_ulogic := cActivated;
	constant cResetTime    : time       := 5 * cClkPeriod;
	signal Finished        : boolean    := false;

	-- DUT signals

	signal iHighSpeed, iDisable : std_ulogic := cInactivated;
 	signal  	oStrobe, oSdClk : std_ulogic;

begin

	-- generate clock and reset

	Clk     <= not Clk after cClkPeriod / 2 when Finished = false else cInactivated;
	RstSync <= cInactivated after cResetTime;

	-- stimuli

	stimuli : process 
	begin
		iHighSpeed <= cActivated after 1001 ns,
					  cInactivated after 1026 ns,
					  cActivated after 1306 ns;

		iDisable   <= cActivated after 2346 ns,
					  cInactivated after 3001 ns,
					  cActivated after 3423 ns;
		Finished   <= true after 5001 ns;
		wait;
	end process stimuli;

	DUT: entity work.SdClockMaster
	port map(
		iClk       => Clk,
		iRstSync   => RstSync,

		iHighSpeed => iHighSpeed,
		iDisable   => iDisable,

		oSdStrobe  => oStrobe,
		oSdCardClk => oSdClk
	);


end architecture Bhv;	

