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
-- File        : WbClkDomain-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Top level of wishbone clock domain
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity WbClkDomain is
	port (
		iWbClk      : in std_ulogic;
		iWbRstSync  : in std_ulogic;
		iCyc        : in std_ulogic;
		iLock       : in std_ulogic;
		iStb        : in std_ulogic;
		iWe         : in std_ulogic;
		iCti        : in std_ulogic_vector(2 downto 0);
		iBte        : in std_ulogic_vector(1 downto 0);
		iSel        : in std_ulogic_vector(0 downto 0);
		iAdr        : in std_ulogic_vector(6 downto 4);
		iDat        : in std_ulogic_vector(31 downto 0);
		oDat        : out std_ulogic_vector(31 downto 0);
		oAck        : out std_ulogic;
		oErr        : out std_ulogic;
		oRty        : out std_ulogic;
		iWriteFifo  : in aiWriteFifo;
		iReadFifo   : in aiReadFifo;
		oWriteFifo  : out aoWriteFifo;
		oReadFifo   : out aoReadFifo;
		oWbToSdCtrl : out aSdWbSlaveToSdController;
		iSdCtrlToWb : in aSdControllerToSdWbSlave
	);

end entity WbClkDomain;

architecture Rtl of WbClkDomain is

	signal iWbCtrl                      : aWbSlaveCtrlInput;
	signal oWbCtrl                      : aWbSlaveCtrlOutput;
	signal iWbDat                       : aSdWbSlaveDataInput;
	signal oWbDat                       : aSdWbSlaveDataOutput;
	
begin

	SdWbSlave_inst : entity work.SdWbSlave
	port map (
		iClk                => iWbClk,
		iRstSync            => iWbRstSync,

		-- wishbone
		iWbCtrl             => iWbCtrl,
		oWbCtrl             => oWbCtrl,
		iWbDat              => iWbDat,
		oWbDat              => oWbDat,

		-- To sd controller
		iController         => iSdCtrlToWb,
		oController         => oWbToSdCtrl,

		-- To write fifo
		oWriteFifo          => oWriteFifo,
		iWriteFifo          => iWriteFifo,

		-- To read fifo
		oReadFifo           => oReadFifo,
		iReadFifo           => iReadFifo
	);

	-- map wishbone signals to internal signals
	iWbCtrl <= (
			   Cyc  => iCyc,
			   Lock => iLock,
			   Stb  => iStb,
			   We   => iWe,
			   Cti  => iCti,
			   Bte  => iBte
		   );

	oAck <= oWbCtrl.Ack;
	oErr <= oWbCtrl.Err;
	oRty <= oWbCtrl.Rty;
	oDat <= oWbDat.Dat;

	iWbDat <= (
			  Sel => iSel,
			  Adr => iAdr,
			  Dat => iDat
		  );


end architecture Rtl;

