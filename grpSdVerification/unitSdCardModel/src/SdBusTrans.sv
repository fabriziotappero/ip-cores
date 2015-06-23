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
// File        : SdBusTrans.sv
// Owner       : Rainer Kastl
// Description : Transmission classes for the SD Bus
// Links       : 
// 

`ifndef SDBUSTRANS_SV
`define SDBUSTRANS_SV

`include "SdDataBlock.sv"

const logic cSdStartbit = 0;
const logic cSdEndbit = 1;

typedef logic SdBusTransData[$];

class SdBusTrans;

	SdDataBlock DataBlocks[];
	bit SendBusy = 0;

	virtual function SdBusTransData packToData();
		return {1};
	endfunction

	virtual function void unpackFromData(ref SdBusTransData data);
	endfunction

endclass

class SdBusTransToken extends SdBusTrans;
	
	logic transbit;
	logic[5:0] id;
	SDCommandArg arg;
	aCrc7 crc;

	function aCrc7 calcCrcOfToken();
		logic temp[$] = { >> { cSdStartbit, this.transbit, this.id, this.arg}};
		return calcCrc7(temp);
	endfunction

	virtual function SdBusTransData packToData();
		SdBusTransData data = { >> {transbit, id, arg, crc}};
		return data;
	endfunction
	
	virtual function void unpackFromData(ref SdBusTransData data);
		{ >> {transbit, id, arg, crc}} = data;	
	endfunction

endclass;

typedef mailbox #(SdBusTransToken) SdBfmMb;

`endif
