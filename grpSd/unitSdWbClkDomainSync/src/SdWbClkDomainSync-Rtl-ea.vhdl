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
-- File        : SdWbClkDomainSync-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronization between Sd and Wb clk domains
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity SdWbClkDomainSync is
	generic (
		gUseSameClocks : boolean := false
	);
	port (
		iWbClk       : in std_ulogic;
		iWbRstSync   : in std_ulogic;
		iSdClk       : in std_ulogic;
		iSdRstSync   : in std_ulogic;

		iWbCtrl      : in aSdWbSlaveToSdController;
		iWbWriteFifo : in aoWriteFifo;
		iWbReadFifo  : in aoReadFifo;
		
		iSdCtrl      : in aSdControllerToSdWbSlave;
		iSdWriteFifo : in aoReadFifo;
		iSdReadFifo  : in aoWriteFifo;

		oWbCtrlSync  : out aSdControllerToSdWbSlave;
		oWbWriteFifo : out aiWriteFifo;
		oWbReadFifo  : out aiReadFifo;
	
		oSdCtrlSync  : out aSdWbSlaveToSdController;
		oSdWriteFifo : out aiReadFifo;
		oSdReadFifo  : out aiWriteFifo
	);
end entity SdWbClkDomainSync;

architecture Rtl of SdWbClkDomainSync is
	
	signal ReadFifoQTemp    : std_logic_vector(31 downto 0);
	signal WriteFifoQTemp   : std_logic_vector(31 downto 0);

begin

	SdWbControllerSync_inst: entity work.SdWbControllerSync
	generic map (
		gUseSameClocks => gUseSameClocks
	)
	port map (
		iWbClk        => iWbClk,
		iWbRstSync    => iWbRstSync,
		iSdClk        => iSdClk,
		iSdRstSync    => iSdRstSync,
		iSdWb         => iWbCtrl,
		oSdWb         => oWbCtrlSync,
		iSdController => iSdCtrl,
		oSdController => oSdCtrlSync
	);

	WriteDataFifo_inst: entity work.WriteDataFifo
	port map (
		data    => std_logic_vector(iWbWriteFifo.data),
		rdclk   => iSdClk,
		rdreq   => iSdWriteFifo.rdreq,
		wrclk   => iWbClk,
		wrreq   => iWbWriteFifo.wrreq,
		q       => ReadFifoQTemp,
		rdempty => oSdWriteFifo.rdempty,
		wrfull  => oWbWriteFifo.wrfull
	);
	oSdWriteFifo.q <= std_ulogic_vector(ReadFifoQTemp);

	ReadDataFifo_inst: entity work.WriteDataFifo
	port map (
		data    => std_logic_vector(iSdReadFifo.data),
		rdclk   => iWbClk,
		rdreq   => iWbReadFifo.rdreq,
		wrclk   => iSdClk,
		wrreq   => iSdReadFifo.wrreq,
		q       => WriteFifoQTemp,
		rdempty => oWbReadFifo.rdempty,
		wrfull  => oSdReadFifo.wrfull
	);
	oWbReadFifo.q <= std_ulogic_vector(WriteFifoQTemp);

end architecture Rtl;

