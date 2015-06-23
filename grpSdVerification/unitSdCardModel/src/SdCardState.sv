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
// File        : SdCardState.sv
// Owner       : Rainer Kastl
// Description : State of an SD Card model
// Links       : 
// 

`ifndef SDCARDSTATE
`define SDCARDSTATE

`include "SDCommandArg.sv"

typedef enum {
	idle = 0, ready = 1, ident = 2, stby = 3, trans = 4,
	data = 5, rcv = 6, prg = 7, dis = 8
} SdCardModelStates;

class SdCardModelState;
	logic OutOfRange;
	logic AddressError;
	logic BlockLenError;
	logic ComCrcError;
	logic IllegalCommand;
	logic Error;
	logic[3:0] state;	
	logic ReadyForData;
	logic AppCmd;
	logic AkeSeqError;

	function new();
		OutOfRange = 0;
		AddressError = 0;
		BlockLenError = 0;
		ComCrcError = 0;
		IllegalCommand = 0;
		Error = 0;
		state = idle;
		ReadyForData = 0;
		AppCmd = 0;
		AkeSeqError = 0;
	endfunction	

	function void recvCMD55();
		AppCmd = 1;
	endfunction

	function automatic SDCommandArg get();
		SDCommandArg temp = 0;
		temp[31] = OutOfRange;
		temp[30] = AddressError;
		temp[29] = BlockLenError;
		temp[12:9] = state;
		temp[8] = ReadyForData;
		temp[5] = AppCmd;
		return temp;
	endfunction

endclass

`endif

