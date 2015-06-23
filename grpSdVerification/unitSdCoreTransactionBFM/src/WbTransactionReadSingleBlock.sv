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
// File        : WbTransactionReadSingleBlock.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef WBTRANSACTIONREADSINGLEBLOCK_SV
`define WBTRANSACTIONREADSINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";

class WbTransactionSequenceReadSingleBlock extends WbTransactionSequence;

	WbData StartAddr;
	WbData EndAddr;

	function new(WbData StartAddr, WbData EndAddr);
		size = 1 + 1 + 1 + 512*8/32; // startaddr, endaddr, operation, read data back
		
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;
	endfunction

	constraint ReadSingleBlock {
		transactions[2].Addr == cOperationAddr;
		transactions[2].Data == cOperationRead;

		transactions[0].Addr == cStartAddrAddr || 
		transactions[0].Addr == cEndAddrAddr;
		if (transactions[0].Addr == cStartAddrAddr) {
			transactions[1].Addr == cEndAddrAddr;
			transactions[1].Data == EndAddr;
			transactions[0].Data == StartAddr;
		} else if (transactions[0].Addr == cEndAddrAddr) {
			transactions[1].Addr == cStartAddrAddr;
			transactions[0].Data == EndAddr;
			transactions[1].Data == StartAddr;
		}

		foreach(transactions[i]) {
			if (i inside {[0:2]}) {
				transactions[i].Kind == WbTransaction::Write;
			} else {
				transactions[i].Kind == WbTransaction::Read;
				transactions[i].Addr == cReadDataAddr;
			}
		}
	};

endclass


`endif
 
