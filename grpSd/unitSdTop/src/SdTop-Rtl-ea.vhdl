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
-- File        : SdTop-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Top level connecting all sub entities
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity SdTop is
	generic (
		gUseSameClocks : boolean := false;
		gClkFrequency  : natural := 100E6;
		gHighSpeedMode : boolean := true
	);
	port (
		-- Wishbone interface
		iWbClk     : in std_ulogic;
		iWbRstSync : in std_ulogic;

		iCyc  : in std_ulogic;
		iLock : in std_ulogic;
		iStb  : in std_ulogic;
		iWe   : in std_ulogic;
		iCti  : in std_ulogic_vector(2 downto 0);
		iBte  : in std_ulogic_vector(1 downto 0);
		iSel  : in std_ulogic_vector(0 downto 0);
		iAdr  : in std_ulogic_vector(6 downto 4);
		iDat  : in std_ulogic_vector(31 downto 0);

		oDat  : out std_ulogic_vector(31 downto 0);
		oAck  : out std_ulogic;
		oErr  : out std_ulogic;
		oRty  : out std_ulogic;

		-- Sd interface
		iSdClk       : in std_ulogic;
		iSdRstSync   : in std_ulogic;
		-- SD Card
		ioCmd  : inout std_logic;
		oSclk  : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oLedBank              : out aLedBank
	);

end entity SdTop;

architecture Rtl of SdTop is

	signal iSdCtrlSync  : aSdWbSlaveToSdController;
	signal oWbCtrl      : aSdWbSlaveToSdController;
	signal oSdCtrl      : aSdControllerToSdWbSlave;
	signal iWbCtrlSync  : aSdControllerToSdWbSlave;
	signal iSdWriteFifo : aiReadFifo;
	signal oSdWriteFifo : aoReadFifo;
	signal iSdReadFifo  : aiWriteFifo;
	signal oSdReadFifo  : aoWriteFifo;
	signal iWbWriteFifo : aiWriteFifo;
	signal oWbWriteFifo : aoWriteFifo;
	signal iWbReadFifo  : aiReadFifo;
	signal oWbReadFifo  : aoReadFifo;

begin

	SdClkDomain_inst: entity work.SdClkDomain
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iSdClk       => iSdClk,
		iSdRstSync   => iSdRstSync,
		ioCmd        => ioCmd,
		oSclk        => oSclk,
		ioData       => ioData,
		oLedBank     => oLedBank,
		oSdCtrl      => oSdCtrl,
		iSdCtrl      => iSdCtrlSync,
		iSdWriteFifo => iSdWriteFifo,
		oSdWriteFifo => oSdWriteFifo,
		iSdReadFifo  => iSdReadFifo,
		oSdReadFifo  => oSdReadFifo
	);

	WbClkDomain_inst: entity work.WbClkDomain
	port map (
		iWbClk      => iWbClk,
		iWbRstSync  => iWbRstSync,
		iCyc        => iCyc,
		iLock       => iLock,
		iStb        => iStb,
		iWe         => iWe,
		iCti        => iCti,
		iBte        => iBte,
		iSel        => iSel,
		iAdr        => iAdr,
		iDat        => iDat,
		oDat        => oDat,
		oAck        => oAck,
		oErr        => oErr,
		oRty        => oRty,
		iWriteFifo  => iWbWriteFifo,
		iReadFifo   => iWbReadFifo,
		oWriteFifo  => oWbWriteFifo,
		oReadFifo   => oWbReadFifo,
		oWbToSdCtrl => oWbCtrl,
		iSdCtrlToWb => iWbCtrlSync
	);

	SdWbClkDomainSync_inst: entity work.SdWbClkDomainSync
	generic map (
		gUseSameClocks => gUseSameClocks
	)
	port map (
		iWbClk       => iWbClk,
		iWbRstSync   => iWbRstSync,
		iSdClk       => iSdClk,
		iSdRstSync   => iSdRstSync,
		iWbCtrl      => oWbCtrl,
		iWbWriteFifo => oWbWriteFifo,
		iWbReadFifo  => oWbReadFifo,
		iSdCtrl      => oSdCtrl,
		iSdWriteFifo => oSdWriteFifo,
		iSdReadFifo  => oSdReadFifo,
		oWbCtrlSync  => iWbCtrlSync,
		oWbWriteFifo => iWbWriteFifo,
		oWbReadFifo  => iWbReadFifo,
		oSdCtrlSync  => iSdCtrlSync,
		oSdWriteFifo => iSdWriteFifo,
		oSdReadFifo  => iSdReadFifo
	 );
	
end architecture Rtl;

