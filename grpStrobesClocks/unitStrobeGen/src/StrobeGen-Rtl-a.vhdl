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
-- File        : StrobeGen-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

architecture Rtl of StrobeGen is

	constant max       : natural                           := gClkFrequency/(1 sec/ gStrobeCycleTime);
	constant cBitWidth : natural                           := LogDualis(max);  -- Bitwidth
	signal   Counter   : unsigned (cBitWidth - 1 downto 0) := (others => '0');

begin  -- architecture Rtl

	StateReg : process (iClk, inResetAsync) is
	begin  -- process StateReg
		if inResetAsync = cnActivated then  -- asynchronous reset (active low)
			Counter <= (others => '0');
			oStrobe <= cInactivated;
		elsif iClk'event and iClk = cActivated then  -- rising clock edge
			if (iRstSync = cActivated) then
				Counter <= (others => '0');
				oStrobe <= cInactivated;

			else
				Counter <= Counter + 1;
				if Counter < max - 1 then
					oStrobe <= cInactivated;
				else
					oStrobe <= cActivated;
					Counter <= TO_UNSIGNED(0, cBitWidth);
				end if;
			end if;
		end if;
	end process StateReg;
end architecture Rtl;
