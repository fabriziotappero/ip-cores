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
-- File        : SdCardSynchronizer-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronizes SD Bus inputs
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity SdCardSynchronizer is
	generic (
		gSyncCount : natural := 1
	);
	port (

		iClk      : in std_ulogic;
		iRstSync  : in std_ulogic;
		iStrobe   : in std_ulogic;
		iCmd      : in std_logic;
		iData     : in std_logic_vector(3 downto 0);
		oCmdSync  : out std_ulogic;
		oDataSync : out std_ulogic_vector(3 downto 0)

	);
end entity SdCardSynchronizer;

architecture Rtl of SdCardSynchronizer is

	type aDataSync is array (0 to gSyncCount - 1) of std_ulogic_vector(3 downto 0);

	signal CmdSync  : std_ulogic_vector(gSyncCount - 1 downto 0);
	signal DataSync : aDataSync;

begin

	-- Registers 
	Reg : process (iClk, iRstSync)
	begin
		if (rising_edge(iClk)) then
			-- synchronous reset
			if (iRstSync = cActivated) then

				CmdSync  <= (others => '0');
				DataSync <= (others => (others => '0'));

			else

				if (iStrobe = cActivated) then
					-- register input data
					CmdSync(0)  <= iCmd;
					DataSync(0) <= std_ulogic_vector(iData);

					-- additional synchronization FFs
					for i in 1 to gSyncCount - 1 loop

						CmdSync(i)  <= CmdSync(i - 1);
						DataSync(i) <= DataSync(i - 1);

					end loop;
				end if;
			end if;
		end if;
	end process Reg;

	-- output the last registers

	oCmdSync  <= CmdSync(gSyncCount - 1);
	oDataSync <= DataSync(gSyncCount - 1);

end architecture Rtl;

