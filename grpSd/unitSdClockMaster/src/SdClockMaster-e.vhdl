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
-- File        : SdClockMaster-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Generation of SDClk and internal strobes
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity SdClockMaster is
	generic (
		gClkFrequency : natural := 100E6
	);
	port (
		iClk       : in std_ulogic; -- Clock active high
		iRstSync   : in std_ulogic; -- Synchronous reset active high

		iHighSpeed : in std_ulogic; -- Switches between High-Speed (50 MHz) and default mode (25 MHz)
		iDisable   : in std_ulogic; -- Disables the clock output

		oSdStrobe  : out std_ulogic; -- strobe signal to enable SdCmd and SdData
		oSdInStrobe : out std_ulogic; -- strobe signal to capture the input cmd and data
		oSdCardClk : out std_ulogic -- clock output to SD card
	);

	begin

		assert (gClkFrequency = 100E6)
		report "SdCore needs a SdClk with 100 MHz"
		severity failure;

end entity SdClockMaster;

