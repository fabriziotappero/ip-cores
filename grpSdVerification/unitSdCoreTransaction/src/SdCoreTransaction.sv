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
// File        : SdCoreTransaction.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDCORETRANSACTION_SV
`define SDCORETRANSACTION_SV

typedef bit[0:511][7:0] DataBlock;

class SdCoreTransaction;

	typedef enum { readSingleBlock, readMultipleBlock, writeSingleBlock,
		writeMultipleBlocks, erase, readSdCardStatus } kinds;

	rand kinds kind;
	rand int startAddr;
	rand int endAddr;
	rand DataBlock data[];

	local int maxAddr = 31;

	constraint datablocks {
		if (kind == writeMultipleBlocks) {
			data.size() inside {[0:1000]};
		}
		else if (kind == writeSingleBlock) {
			data.size() == 1;
		}
		else {
			data.size() == 0;
		}

		kind == readSingleBlock || 
		kind == writeSingleBlock;

		startAddr inside {[0:maxAddr]};
		endAddr inside {[0:maxAddr]};
	};

	function SdCoreTransaction copy();
		SdCoreTransaction rhs = new();
		rhs.kind = this.kind;
		rhs.startAddr = this.startAddr;
		rhs.endAddr = this.endAddr;
		rhs.data = new[this.data.size()];
		rhs.data = this.data;
		return rhs;
	endfunction

	function string toString();
		string s;
		$swrite(s, "kind: %p, addresses: %d, %d", kind, startAddr, endAddr);
		return s;
	endfunction

	// compare kind and addresses
	// NOTE: data has to be checked with other objects
	function bit compare(input SdCoreTransaction rhs);
		if (rhs.kind == this.kind && rhs.startAddr == this.startAddr)
			return 1;
		else return 0;
	endfunction

endclass

class SdCoreTransactionSequence;

	rand SdCoreTransaction transactions[];
	local const int size = 1000;

	function new();
		transactions = new[size];
		foreach(transactions[i]) transactions[i] = new();
	endfunction

	constraint randlength {
		transactions.size() inside {[100:1000]};
		transactions.size() < size;
	}

endclass

typedef mailbox #(SdCoreTransaction) SdCoreTransSeqMb;

`endif
