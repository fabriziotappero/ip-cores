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
// File        : WbTransactionWriteSingleBlock.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef WBTRANSACTIONWRITESINGLEBLOCK_SV
`define WBTRANSACTIONWRITESINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";
`include "SdCoreTransaction.sv";

class WbTransactionSequenceWriteSingleBlock extends WbTransactionSequence;

	WbData StartAddr;
	WbData EndAddr;
	WbData Data[$];

	function new(WbData StartAddr, WbData EndAddr, DataBlock Datablock);
		size = 1 + 1 + 1 + 512*8/32; // startaddr, endaddr, operation, write data
	
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;

		for (int i = 0; i < 512/4; i++) begin
			WbData temp = 0;
			temp = { >> {Datablock[i*4+3], Datablock[i*4+2], Datablock[i*4+1], Datablock[i*4+0]}};
			Data.push_back(temp);
		end
	endfunction

	constraint WriteAddrFirst {
		transactions[2].Addr == cOperationAddr;
		transactions[1].Addr == cEndAddrAddr;
		transactions[1].Data == EndAddr;
		transactions[0].Addr == cStartAddrAddr;
		transactions[0].Data == StartAddr;

		foreach(transactions[i]) {
			transactions[i].Kind == WbTransaction::Write;

			if (i > 2) {
				transactions[i].Addr == cWriteDataAddr;
			}
			transactions[i].Addr == cOperationAddr -> transactions[i].Data == cOperationWrite;
		}
	};

	function void post_randomize();
		for (int i = 3; i < size; i++) begin
			transactions[i].Data = Data.pop_front();
		end
	endfunction

endclass

`endif 
