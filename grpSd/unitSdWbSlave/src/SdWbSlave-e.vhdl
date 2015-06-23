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
-- File        : SdWbSlave-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone interface of SDHC-SC-Core
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;
use work.SdWb.all;

entity SdWbSlave is
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		-- wishbone
		iWbCtrl : in aWbSlaveCtrlInput; -- All control signals for a wishbone slave
		oWbCtrl : out aWbSlaveCtrlOutput; -- All output signals for a wishbone slave
		iWbDat  : in aSdWbSlaveDataInput;
		oWbDat  : out aSdWbSlaveDataOutput; 
		
		-- To sd controller
		iController : in aSdControllerToSdWbSlave;
		oController : out aSdWbSlaveToSdController;

		-- To write fifo
		oWriteFifo : out aoWriteFifo;
		iWriteFifo : in aiWriteFifo;
		
		-- To read fifo
		oReadFifo : out aoReadFifo;
		iReadFifo : in aiReadFifo
	);
end entity;

