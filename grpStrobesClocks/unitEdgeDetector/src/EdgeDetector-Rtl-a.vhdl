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
-- File        : EdgeDetector-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;


architecture Rtl of EdgeDetector is
	signal nQ, detection, Q : std_ulogic;
begin  -- Rtl

	FF1 : process (iClk, inResetAsync) is
	begin  -- process FF1
		if inResetAsync = cnActivated then
			nQ <= cnInactivated;
		elsif iClk'event and iClk = cActivated then  -- rising clock edge
			if (iRstSync = cActivated) then
				nQ <= cnInactivated;
			else
				nQ <= not iLine;
			end if;
		end if;
	end process FF1;

	Gen : if gOutputRegistered = true generate  -- only generate 2nd FF, if
												-- condition is true
		FF2 : process (iClk, iClearEdgeDetected, inResetAsync) is
		begin  -- process FF2
			if inResetAsync = cnActivated then
				Q <= cInactivated;
			elsif iClk'event and iClk = cActivated then  -- rising clock edge
				if (iRstSync = cActivated) then
					Q <= cInactivated;
				else
					if iClearEdgeDetected = cActivated then
						Q <= cInactivated;
					elsif detection = cActivated then
						Q <= cActivated;
					end if;
				end if;
			end if;
		end process FF2;

		oEdgeDetected <= Q;
	end generate;

	Gen2 : if gOutputRegistered = false generate
	  -- else detection is Output
		oEdgeDetected <= detection;
	end generate;

	Detect : process (nQ, iLine) is
	begin
		case gEdgeDetection is
			when cDetectRisingEdge  => detection <= (iLine and nQ);
			when cDetectFallingEdge => detection <= (iLine nor nQ);
			when cDetectAnyEdge     => detection <= (iLine and nQ) or (iLine nor nQ);
			when others             => null;
		end case;
	end process Detect;
end Rtl;
