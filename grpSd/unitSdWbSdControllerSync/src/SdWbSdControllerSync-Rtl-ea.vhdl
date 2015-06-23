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
-- File        : SdWbSdControllerSync-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronization of ctrl and data between Wb clock domain and Sd clock domain
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;
use work.SdWb.all;

entity SdWbControllerSync is
	generic (

		-- both clocks are the same, therefore we don´t need synchronization
		gUseSameClocks : boolean := false;
		gSyncCount     : natural := 2

	);
	port (
		-- clocked by iWbClk
		iWbClk               : in std_ulogic;
		iWbRstSync           : in std_ulogic;
		iSdWb                : in aSdWbSlaveToSdController;
		oSdWb                : out aSdControllerToSdWbSlave;

		-- clocked by iSdClk
		iSdClk               : in std_ulogic;
		iSdRstSync           : in std_ulogic;
		iSdController        : in aSdControllerToSdWbSlave;
		oSdController        : out aSdWbSlaveToSdController

	);
end entity SdWbControllerSync;

architecture Rtl of SdWbControllerSync is

	signal ReqOperationSync : std_ulogic;
	signal ReqOperationEdge : std_ulogic;

	signal AckOperationSync : std_ulogic;
	signal AckOperationEdge : std_ulogic;

begin

	-- synchronization, when different clocks are used
	Sync_gen : if gUseSameClocks = false generate

		Sync_ToSdWb: entity work.Synchronizer
		generic map (
			gSyncCount => gSyncCount
		)
		port map (
			iRstSync => iWbRstSync,
			iToClk   => iWbClk,
			iSignal  => iSdController.ReqOperation,
			oSync    => ReqOperationSync
		);

		Sync_ToSdController: entity work.Synchronizer
		generic map (
			gSyncCount => gSyncCount
		)
		port map (
			iRstSync => iSdRstSync,
			iToClk   => iSdClk,
			iSignal  => iSdWb.AckOperation,
			oSync    => AckOperationSync
		);

	end generate;

	-- no synchronization, when the same clocks are used
	NoSync_gen : if gUseSameClocks = true generate

		ReqOperationSync <= iSdController.ReqOperation;
		AckOperationSync <= iSdWb.AckOperation;

	end generate;

	-- detect egdes: every toggle is a new request / acknowledgement
	ReqEdge_inst : entity work.EdgeDetector
	generic map (
		gEdgeDetection     => cDetectAnyEdge,
		gOutputRegistered  => false
	)
	port map (
		iClk               => iWbClk,
		iRstSync           => iWbRstSync,
		iLine              => ReqOperationSync,
		iClearEdgeDetected => cInactivated,
		oEdgeDetected      => ReqOperationEdge
	);	

	AckEdge_inst : entity work.EdgeDetector
	generic map (
		gEdgeDetection     => cDetectAnyEdge,
		gOutputRegistered  => false
	)
	port map (
		iClk               => iSdClk,
		iRstSync           => iSdRstSync,
		iLine              => AckOperationSync,
		iClearEdgeDetected => cInactivated,
		oEdgeDetected      => AckOperationEdge
	);	

	-- outputs

	oSdWb.ReqOperation <= ReqOperationEdge;
	oSdWb.ReadData     <= iSdController.ReadData;

	oSdController.AckOperation   <= AckOperationEdge;
	oSdController.OperationBlock <= iSdWb.OperationBlock;
	oSdController.WriteData      <= iSdWb.WriteData;

end architecture Rtl;


