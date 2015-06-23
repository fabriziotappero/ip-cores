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
-- File        : TimeoutGenerator-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

architecture Rtl of TimeoutGenerator is

	constant cMax      : natural := gClkFrequency / (1 sec / gTimeoutTime) - 1;
	constant cBitWidth : natural := LogDualis(cMax);

	signal Counter : unsigned (cBitWidth - 1 downto 0);
	signal Enabled : std_ulogic;

begin

	Regs : process (iClk)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then
				Counter  <= (others => '0');
				Enabled  <= cInactivated;
				oTimeout <= cInactivated;
			else
				oTimeout <= cInactivated; -- Default

				if (iDisable = cActivated) then
					Enabled <= cInactivated;
					Counter <= (others => '0');

				elsif (iEnable = cActivated or Enabled = cActivated) then
					Counter <= Counter + 1;
					Enabled <= cActivated;

					if (Counter >= cMax) then
						Counter  <= to_unsigned(0, cBitWidth);
						Enabled  <= cInactivated;
						oTimeout <= cActivated;
					end if;
				end if;
			end if;
		end if;
	end process Regs;

end architecture Rtl;

