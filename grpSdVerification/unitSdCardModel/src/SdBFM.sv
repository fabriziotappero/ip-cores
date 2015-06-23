// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010, Rainer Kastl
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// File        : SdBFM.sv
// Owner       : Rainer Kastl
// Description : SD BFM
// Links       : 
// 

`ifndef SDBFM_SV
`define SDBFM_SV

`include "SdBusInterface.sv"
`include "Crc.sv"
`include "Logger.sv"
`include "SDCommandArg.sv"
`include "SdBusTrans.sv"

typedef enum {
	standard,
	wide
} Mode_t;

class SdBFM;

	virtual ISdBus.card ICard;
	SdBfmMb ReceivedTransMb;
	SdBfmMb SendTransMb;
	Mode_t Mode;
	
	extern function new(virtual ISdBus card);

	extern task start(); // starts a thread for receiving and sending via mailboxes
	extern function void stop(int AfterCount); // stop the thread

	extern task send(input SdBusTrans token);
	extern task sendBusy();
	extern task receive(output SdBusTransToken token);
	extern task receiveDataBlock(output SdDataBlock block);
	extern task waitUntilReady();

	extern local task sendCmd(inout SdBusTransData data);
	extern local task sendAllDataBlocks(SdDataBlock blocks[]);
	extern local task sendDataBlock(SdDataBlock block);
	extern local task sendStandardDataBlock(logic data[$]);
	extern local task sendWideDataBlock(logic data[$]);
	extern local task recvDataBlock(output SdDataBlock block);
	extern local task recvStandardDataBlock(output SdDataBlock block);
	extern local task recvWideDataBlock(output SdDataBlock block);
	extern local task recv(output SdBusTransToken token);
	extern local task receiveOrSend();
	extern local task run();
	extern local function void compareCrc16(aCrc16 actual, aCrc16 expected);

	local semaphore Sem;
	local Logger Log;
	local int StopAfter = -1;
endclass

`include "SdBFM-impl.sv";
`endif
