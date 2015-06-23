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
-- File        : Sd-p.vhdl
-- Owner       : Rainer Kastl
-- Description : Definitions for SD cards and controllers (Spec 2.0)
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;

package Sd is

	-- CMD transfer: constants
	constant cSdStartBit      : std_ulogic := '0';
	constant cSdEndBit        : std_ulogic := '1';
	constant cSdTransBitHost  : std_ulogic := '1';
	constant cSdTransBitSlave : std_ulogic := '0';

	-- CMD transfer: types
	constant cSdCmdIdHigh : natural := 6;
	subtype aSdCmdId is std_ulogic_vector(cSdCmdIdHigh-1 downto 0);
	subtype aSdCmdArg is std_ulogic_vector(31 downto 0);

	type aSdCmdContent is record
		id  : aSdCmdId;
		arg : aSdCmdArg;
	end record aSdCmdContent;

	constant cDefaultSdCmdContent : aSdCmdContent := (
	id  => (others => '0'),
	arg => (others => '0'));

	type aSdCmdToken is record
		startbit : std_ulogic; -- cSdStartBit
		transbit : std_ulogic;
		content  : aSdCmdContent;
		crc7     : std_ulogic_vector(6 downto 0); -- CRC of content
		endbit   : std_ulogic; --cSdEndBit
	end record aSdCmdToken;

	constant cDefaultSdCmdToken : aSdCmdToken := (
	startbit => cActivated,
	transbit => cActivated,
	content  => cDefaultSdCmdContent,
	crc7     => (others => '0'),
	endbit   => cInactivated);

	-- SD Card Regs
	subtype aVoltageWindow is std_ulogic_vector(23 downto 15);
	constant cVoltageWindow : aVoltageWindow := (others => '1');
	constant cSdR3Id        : aSdCmdId       := (others => '1');
	constant cSdR2Id        : aSdCmdId       := (others => '1');

	type aSdRegOCR is record
		voltagewindow : aVoltageWindow;
		ccs           : std_ulogic;
		nBusy         : std_ulogic;
	end record aSdRegOCR;

	subtype aSdCardStatus is std_ulogic_vector(31 downto 0);
	constant cSdStatusReadyForDataBit : natural := 8;
	constant cDefaultSdCardStatus : aSdCardStatus := (others => '0');
	
	constant cSdOCRQuery : aSdRegOCR := (
	voltagewindow => (others => '0'),
	ccs           => '0',
	nBusy         => '0');

	function OCRToArg (ocr : in aSdRegOCR) return aSdCmdArg;
	function ArgToOcr (arg : in aSdCmdArg) return aSdRegOCR;

	subtype aSdCIDMID is std_ulogic_vector(7 downto 0);
	subtype aSdCIDOID is std_ulogic_vector(15 downto 0);
	subtype aSdCIDPNM is std_ulogic_vector(39 downto 0);
	subtype aSdCIDPRV is std_ulogic_vector(7 downto 0);
	subtype aSdCIDPSN is std_ulogic_vector(31 downto 0);
	subtype aSdCIDMDT is std_ulogic_vector(11 downto 0);

	type aSdRegCID is record
		mid          : aSdCIDMID;
		oid          : aSdCIDOID;
		name         : aSdCIDPNM;
		revision     : aSdCIDPRV;
		serialnumber : aSdCIDPSN;
		date         : aSdCIDMDT;
	end record;

	constant cCIDLength : natural := 127;

	constant cDefaultSdRegCID : aSdRegCID := (
	mid          => (others => '0'),
	oid          => (others => '0'),
	name         => (others => '0'),
	revision     => (others => '0'),
	serialnumber => (others => '0'),
	date         => (others => '0'));

	function UpdateCID(icid : in aSdRegCID; data : in std_ulogic; pos : in
	natural) return aSdRegCID;

	subtype aSdRCA is std_ulogic_vector(15 downto 0);
	constant cDefaultRCA : aSdRCA := (others => '0');

	constant cSdWideModeBit : natural := 31-(63-50); -- first word

	-- Data types
	subtype aSdData is std_ulogic_vector(3 downto 0);
	constant cSdStartBits : aSdData := (others => cSdStartBit);
	constant cSdEndBits   : aSdData := (others => cSdEndBit);

	constant cBlocklen : natural := 512 * 8; -- 512 bytes
	subtype aSdDataBlock is std_ulogic_vector(cBlocklen - 1 downto 0);

	type aSdDataBusMode is (standard, wide);
	type aSdDataMode is (usual, widewidth);
	type aSdDataBits is (ScrBits, SwitchFunctionBits);
	
	constant cScrBitsCount             : natural := 4096 - 64 + 7; -- expressed in bits
	constant cSwitchFunctionBitsCount  : natural := 4096 - 512 + 7; -- expressed in bits
	constant cWideModeBitAddr          : natural := 50;
	constant cHighSpeedBitAddr 		   : natural := 401;
	constant cSwitchFunctionBitLowAddr : natural := 376;

	-- Types for entities
	-- between SdController and SdCmd
	type aSdCmdFromController is record
		Content   : aSdCmdContent; -- id and arg to sent to card
		Valid     : std_ulogic; -- gets asserted when Content is valid and can be sent to card
		ExpectCID : std_ulogic; -- gets asserted when next response is R2
		CheckCrc  : std_ulogic; -- gets asserted when CRC has to be checked (exceptions is R3)
	end record aSdCmdFromController;

	type aSdCmdToController is record
		Ack       : std_ulogic; -- Gets asserted when crc was sent, but endbit was not. This way we can minimize the wait time between sending 2 cmds.
		Receiving : std_ulogic; -- gets asserted when a response is received currently
		Content   : aSdCmdContent; -- received id and arg, see valid
		Valid     : std_ulogic; -- gets asserted when CmdContent is valid (therefore  a cmd was received and can be saved)
		Err       : std_ulogic; -- gets asserted when an error occurred during receiving a cmd, for example the crc check does not hold
		Cid       : aSdRegCID; -- received CID register of the card, see valid
	end record aSdCmdToController;

	constant cDefaultSdCmdToController : aSdCmdToController := (
	Ack       => cInactivated,
	Receiving => cInactivated,
	Valid     => cInactivated,
	Content   => cDefaultSdCmdContent,
	Err       => cInactivated,
	Cid       => cDefaultSdRegCID);

	constant cDataRamAddrWidth : natural := 7;
	constant cDataRamDataWidth : natural := 32;
	subtype aWord is std_ulogic_vector(cDataRamDataWidth - 1 downto 0);
	subtype aAddr is natural range 0 to 2**cDataRamAddrWidth - 1;

	type aSdControllerToRam is record
		Addr : aAddr;
	end record aSdControllerToRam;

	constant cDefaultSdControllerToRam : aSdControllerToRam := (Addr => 0);

	type aSdControllerFromRam is record
		Data : aWord;
	end record aSdControllerFromRam;

	-- between SdController and SdData
	type aSdDataFromController is record
		Mode       : aSdDataBusMode; -- select 1 bit or 4 bit mode
		DataMode   : aSdDataMode; -- select usual or wide width data
		ExpectBits : aSdDataBits; -- how many bits are expected in wide with data mode
		Valid      : std_ulogic; -- valid, when the datablock is valid and has to be sent
		CheckBusy  : std_ulogic; -- check for busy signaling
		DisableRb  : std_ulogic; -- disable read back: do not save read data to fifo
	end record aSdDataFromController;

	constant cDefaultSdDataFromController : aSdDataFromController := (
	Mode       => standard,
	DataMode   => usual,
	ExpectBits => ScrBits,
	Valid      => cInactivated,
	CheckBusy  => cInactivated,
	DisableRb  => cActivated);

	type aSpeedBits is record
		HighSpeedSupported : std_ulogic;
		SwitchFunctionOK   : std_ulogic_vector(3 downto 0); -- 0x01 when ok
	end record aSpeedBits;

	constant cDefaultSpeedBits : aSpeedBits := (
	HighSpeedSupported => '0',
	SwitchFunctionOK   => (others => '0'));

	type aSdDataToController is record
		Ack       : std_ulogic; -- gets asserted when a datablock was sent to the card
		Receiving : std_ulogic; -- gets asserted when a datablock is currently received
		Valid     : std_ulogic; -- gets asserted when DataBlock is valid and therefore it was received correctly
		Busy      : std_ulogic; -- gets asserted when the card returns busy
		Err       : std_ulogic; -- gets asserted when an error occurred during receiving a data block (CRC)
		SpeedBits : aSpeedBits; -- gets set, when data for check or switch function cmd is received (DataMode = widewidth and ExpectBits = SwitchFunctionBits
		WideMode  : std_ulogic; -- gets set, when scr is read (datamode = widewidth and ExpectBits = ScrBits)
	end record aSdDataToController;

	constant cDefaultSdDataToController : aSdDataToController := (
	Ack       => cInactivated,
	Receiving => cInactivated,
	Valid     => cInactivated,
	Busy      => cInactivated,
	Err       => cInactivated,
	SpeedBits => cDefaultSpeedBits,
	WideMode  => cInactivated);

	-- SdData to Ram
	type aSdDataToRam is record
		En   : std_ulogic;
		Addr : aAddr;
		Data : aWord;
		We   : std_ulogic;
	end record aSdDataToRam;

	constant cDefaultSdDataToRam : aSdDataToRam := (
	En   => cInactivated,
	Addr => 0,
	Data => (others => '0'),
	We   => cInactivated);

	type aSdDataFromRam is record
		Data : aWord;
	end record aSdDataFromRam;

	-- between SdController and wishbone interface
	type aSdRegisters is record
		CardStatus : aSdCardStatus;
	end record aSdRegisters;

	-- constants for SdController
	subtype aRCA is std_ulogic_vector(15 downto 0);
	constant cSdDefaultRCA : aRCA := (others => '0');

	-- command ids
	-- abbreviations:
	-- RCA: relative card address

	constant cSdCmdGoIdleState : aSdCmdId := std_ulogic_vector(to_unsigned(0,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdAllSendCID : aSdCmdId := std_ulogic_vector(to_unsigned(2,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSendRelAdr : aSdCmdId := std_ulogic_vector(to_unsigned(3,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSetDSR : aSdCmdId := std_ulogic_vector(to_unsigned(4,
	cSdCmdIdHigh)); -- [31:16] DSR

	constant cSdCmdSelCard : aSdCmdId := std_ulogic_vector(to_unsigned(7,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdDeselCard : aSdCmdId := cSdCmdSelCard; -- [31:16] RCA

	constant cSdCmdSendIfCond : aSdCmdId := std_ulogic_vector(to_unsigned(8,
	cSdCmdIdHigh));

	constant cSdDefaultVoltage : std_ulogic_vector(3 downto 0) := "0001"; -- 2.7
	-- - 3.6 V
	constant cCheckpattern : std_ulogic_vector(7 downto 0) := "10101010";
	-- recommended

	constant cSdArgVoltage : aSdCmdArg := 
		"00000000000000000000" & -- reserved 
		cSdDefaultVoltage & -- supply voltage
		cCheckPattern;

	constant cSdCmdSendCSD : aSdCmdId := std_ulogic_vector(to_unsigned(9,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdSendCID : aSdCmdId := std_ulogic_vector(to_unsigned(10,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdStopTrans : aSdCmdId := std_ulogic_vector(to_unsigned(12,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSendStatus : aSdCmdId := std_ulogic_vector(to_unsigned(13,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdNextIsACMD : aSdCmdId := std_ulogic_vector(to_unsigned(55,
	cSdCmdIdHigh));
	constant cSdACMDArg : aSdCmdArg := cSdDefaultRCA & X"0000"; -- [31:16] RCA
	constant cSdArgAppCmdPos : natural := 5;

	constant cSdCmdReadSingleBlock : aSdCmdId := std_ulogic_vector(to_unsigned(17, cSdCmdIdHigh));
	constant cSdCmdWriteSingleBlock : aSdCmdId := std_ulogic_vector(to_unsigned(24, cSdCmdIdHigh));

	constant cSdCmdACMD41 : aSdCmdId := std_ulogic_vector(to_unsigned(41, cSdCmdIdHigh));
	constant cSdCmdSendSCR : aSdCmdId := std_ulogic_vector(to_unsigned(51, cSdCmdIdHigh));
	constant cSdCmdSetBusWidth : aSdCmdId := std_ulogic_vector(to_unsigned(6, cSdCmdIdHigh)); -- [31:2] stuff, [1:0] bus width
	constant cSdWideBusWidth : std_ulogic_vector(1 downto 0) := "10";
	constant cSdStandardBusWidth : std_ulogic_vector(1 downto 0) := "00";

	constant cSdCmdSwitchFunction : aSdCmdId := std_ulogic_vector(to_unsigned(6, cSdCmdIdHigh));
	-- 31: mode
	constant cSdCmdCheckMode : std_ulogic := '0';
	constant cSdCmdSwitchMode : std_ulogic := '1';
	-- 30:24 reserved
	-- 23:8 function group 6 - 3
	-- 7:4 group 2 for command system
	-- 3:0 group 1 for access mode
	constant cSdCmdCheckSpeedSupport        : aSdCmdArg := X"00FFFFF1";
	constant cSdCmdSwitchSpeed              : aSdCmdArg := X"80FFFFF1";
	constant cSdHighSpeedFunctionSupportBit : natural   := 401;
	constant cSdHighSpeedFunctionGroupLow   : natural   := 376;

	type aiSdCmd is record
		Cmd : std_ulogic;
	end record aiSdCmd;

	type aoSdCmd is record
		Cmd : std_ulogic;
		En : std_ulogic;
	end record aoSdCmd;


	type aiSdData is record
		Data : aSdData;
	end record aiSdData;

	type aoSdData is record
		Data : aSdData;
		En   : aSdData;
	end record aoSdData;

	constant cDefaultSdData : aoSdData := (
	Data => (others => '0'),
	En   => (others => '0'));
	
end package Sd;

package body Sd is

	function OCRToArg (ocr : in aSdRegOCR) return aSdCmdArg is
		variable temp : aSdCmdArg;
	begin
		temp := ocr.nBusy & ocr.ccs & "000000" & ocr.voltagewindow &
		"000000000000000";
		return temp;
	end function OCRtoArg;

	function ArgToOcr (arg : in aSdCmdArg) return aSdRegOCR is
		variable ocr : aSdRegOCR;
	begin
		ocr.nBusy := arg(31);
		ocr.ccs := arg(30);
		ocr.voltagewindow := arg(23 downto 15);
		return ocr;
	end function ArgToOcr;

	function UpdateCID(icid : in aSdRegCID; data : in std_ulogic; pos : in
	natural) return aSdRegCID is
		variable cid : aSdRegCID;
	begin
		cid := icid;

		if (pos <= 127 and pos >= 120) then
			cid.mid(pos-120) := data;
		elsif (pos <= 119 and pos >= 104) then
			cid.oid(pos-104) := data;
		elsif (pos <= 103 and pos >= 64) then
			cid.name(pos-64) := data;
		elsif (pos <= 63 and pos >= 56) then
			cid.revision(pos-56) := data;
		elsif (pos <= 55 and pos >= 24) then
			cid.serialnumber(pos-24) := data;
		elsif (pos <= 19 and pos >= 8) then
			cid.date(pos-8) := data;
		end if;

		return cid;
	end function UpdateCID;

end package body Sd;

