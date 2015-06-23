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
-- File        : SdClkDomain-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Top level of Sd clock domain
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity SdClkDomain is
	generic (
		gClkFrequency  : natural := 100E6;
		gHighSpeedMode : boolean := true
	);
	port (
		iSdClk       : in std_ulogic;
		iSdRstSync   : in std_ulogic;
		ioCmd        : inout std_logic;
		oSclk        : out std_ulogic;
		ioData       : inout std_logic_vector(3 downto 0);
		oLedBank     : out aLedBank;
		oSdCtrl      : out aSdControllerToSdWbSlave;
		iSdCtrl      : in aSdWbSlaveToSdController;
		iSdWriteFifo : in aiReadFifo;
		oSdWriteFifo : out aoReadFifo;
		iSdReadFifo  : in aiWriteFifo;
		oSdReadFifo  : out aoWriteFifo
	);

end entity SdClkDomain;

architecture Rtl of SdClkDomain is

	signal SdCmdToController       : aSdCmdToController;
	signal SdCmdFromController     : aSdCmdFromController;
	signal SdDataToController      : aSdDataToController;
	signal SdDataFromController    : aSdDataFromController;
	signal SdDataFromRam           : aSdDataFromRam;
	signal SdDataToRam             : aSdDataToRam;
	signal SdControllerToDataRam   : aSdControllerToRam;
	signal SdControllerFromDataRam : aSdControllerFromRam;
	signal SdStrobe                : std_ulogic;
	signal SdInStrobe              : std_ulogic;
	signal HighSpeed               : std_ulogic;
	signal DisableSdClk            : std_ulogic;
	signal iCmd                    : aiSdCmd;
	signal oCmd                    : aoSdCmd;
	signal iData                   : aiSdData;
	signal oData                   : aoSdData;

begin

	-- units
	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iClk         => iSdClk,
		iRstSync     => iSdRstSync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		oSdWbSlave   => oSdCtrl,
		iSdWbSlave   => iSdCtrl,
		oLedBank     => oLedBank
	);

	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iSdClk,
		iRstSync        => iSdRstSync,
		iStrobe         => SdStrobe,
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		iCmd            => iCmd,
		oCmd            => oCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iSdClk,
		iRstSync			  => iSdRstSync,
		iStrobe               => SdStrobe,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		iData                 => iData,
		oData                 => oData,
		oReadWriteFifo        => oSdWriteFifo,
		iReadWriteFifo        => iSdWriteFifo,
		oWriteReadFifo        => oSdReadFifo,
		iWriteReadFifo        => iSdReadFifo,
		oDisableSdClk         => DisableSdClk
	);


	SdClockMaster_inst: entity work.SdClockMaster
	generic map (
		gClkFrequency => gClkFrequency
	)
	port map (
		iClk       => iSdClk,
		iRstSync   => iSdRstSync,
		iHighSpeed => HighSpeed,
		iDisable   => DisableSdClk,
		oSdStrobe  => SdStrobe,
		oSdInStrobe => SdInStrobe,
		oSdCardClk => oSClk
	);

	SdCardSynchronizer_inst : entity work.SdCardSynchronizer
	port map (
		iClk       => iSdClk,
		iRstSync   => iSdRstSync,
		iStrobe    => SdInStrobe,
		iCmd       => ioCmd,
		iData      => ioData,
		oCmdSync   => iCmd.Cmd,
		oDataSync  => iData.Data
	);

	-- generate tristate logic
	ioCmd <= oCmd.Cmd when oCmd.En = cActivated else 'Z';
	Gen_data : for i in 0 to 3 generate
		ioData(i) <= oData.Data(i) when oData.En(i) = cActivated else 'Z';
	end generate;

end architecture Rtl;

