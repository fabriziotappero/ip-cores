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
// File        : SDOCR.sv
// Owner       : Rainer Kastl
// Description : SD OCR Register
// Links       : 
// 

`ifndef SDOCR
`define SDOCR

typedef logic[23:15] voltage_t;
const voltage_t cSdVoltageWindow = 'b111111111;
const logic cOCRBusy = 0;
const logic cOCRDone = 1;

class SDOCR;
	local logic[14:0] reserved; // 7 reserved for low voltage
	local voltage_t voltage;
	local logic[29:24] reserved2;
	local logic CCS;
	local logic busy;

	function new(logic CCS, voltage_t voltage);
		reserved = 0;
		reserved2 = 0;
		this.CCS = CCS;
		this.voltage = voltage;
		this.busy = cOCRBusy;
	endfunction

	function void setBusy(logic busy);
		this.busy = busy;
	endfunction

	function automatic SDCommandArg get();
		SDCommandArg temp = 0;
		temp[31] = busy;
		temp[30] = CCS;
		temp[29:24] = reserved2;
		temp[23:15] = voltage;
		temp[14:0] = reserved;
		return temp;
	endfunction

endclass

`endif

