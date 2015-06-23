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
-- File        : tbRs232Tx-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench for Rs232 Transmitter
-- Links       : Rs232Tx-Rtl-ea.vhdl
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Rs232.all;

entity tbRs232Tx is
end entity tbRs232Tx;

architecture Bhv of tbRs232Tx is

	constant cClkFrequency : natural := 25E6;
	constant cBaudRate     : natural := 9600;
	constant cResetTime    : time    := 1 sec / cClkFrequency * 3;

	signal Clk         : std_ulogic := cActivated;
	signal nResetAsync : std_ulogic := cnActivated;
	signal iRs232Tx    : aiRs232Tx;
	signal oRs232Tx    : aoRs232Tx;
	signal Finished    : std_ulogic := cInactivated;

begin

	Clk <=  not Clk after 1 sec / cClkFrequency / 2 when Finished = cInactivated;
	nResetAsync <= cnInactivated after cResetTime;

	Stimuli : process is
	begin
		iRs232Tx.Transmit      <= cActivated;
		iRs232Tx.Data          <= (others => '-');
		iRs232Tx.DataAvailable <= cInactivated;

		wait for cResetTime;

		wait for 1 us;

		iRs232Tx.Data          <= X"5A";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;

		wait until Clk = cActivated;
		wait until Clk = cActivated;
		
		iRs232Tx.Data          <= X"7E";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.Data <= X"96";

		wait until Clk = cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;

		wait for 500 us;

		iRs232Tx.Data          <= X"97";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;
		iRs232Tx.Transmit      <= cInactivated;

		wait for 5 ms;

		Finished <= cActivated;

		wait;
	end process Stimuli;

	StrobeGen_Rs232 : entity work.StrobeGen
	generic map (
		gClkFrequency    => cClkFrequency,
		gStrobeCycleTime => 1 sec / cBaudRate)
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		oStrobe      => iRs232Tx.BitStrobe);

	DUT: entity work.Rs232Tx
	generic map (
		gDataBitWidth => 8
	)
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		iRs232Tx     => iRs232Tx,
		oRs232Tx     => oRs232Tx
	);

end architecture Bhv;	

