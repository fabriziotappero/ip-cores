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
-- File        : Synchronizer-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronization between two clock domains
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity Synchronizer is
	generic (
		gSyncCount : natural := 2
	);
	port (
		-- Resets
		inResetAsync : in std_ulogic := '1';
		iRstSync     : in std_ulogic := '0';

		iToClk       : in std_ulogic;
		iSignal      : in std_ulogic;

		oSync        : out std_ulogic
	);
end entity Synchronizer;

architecture Rtl of Synchronizer is

	signal Sync : std_ulogic_vector(gSyncCount - 1 downto 0);

begin

	SyncReg : process (iToClk, inResetAsync)
	begin
		-- asynchronous reset
		if (inResetAsync = cnActivated) then
			Sync <= (others => '0');

		elsif (rising_edge(iToClk)) then
			-- synchronous reset
			if (iRstSync = cActivated) then
				Sync <= (others => '0');

			else
				-- synchronize
				Sync(0) <= iSignal;

				for i in 1 to gSyncCount - 1 loop

					Sync(i) <= Sync(i-1);

				end loop;

			end if;
		end if;	
	end process SyncReg;

	oSync <= Sync(gSyncCount - 1);

end architecture Rtl;

