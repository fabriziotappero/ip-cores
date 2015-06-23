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
// File        : WbTransaction.sv
// Owner       : Rainer Kastl
// Description : Transaction on the wishbone bus
// Links       : 
// 

`ifndef WBTRANSACTION_SV
`define WBTRANSACTION_SV

typedef bit[2:0] WbAddr;
typedef bit[31:0] WbData;

class WbTransaction;

	typedef enum { Read, Write } kinds;
	typedef enum { Classic, Burst, End } types;

	rand types Type;
	rand kinds Kind;
	rand WbAddr Addr;
	rand WbData Data;

	function void display();
		$display(toString());
	endfunction

	function string toString();
		string s;
		$swrite(s, "Transaction: %s, %s, %b, %b", Type.name(), Kind.name(), Addr, Data);
		return s;
	endfunction

	constraint NotImplementedYet {
		Type == Classic;
	};
endclass

class WbTransactionSequence;

	rand WbTransaction transactions[];
	int size = 0;

	constraint Transactions {
		transactions.size() == size;

		foreach(transactions[i]) {
			if (i > 0) {
				if (transactions[i].Type == WbTransaction::Burst)
					transactions[i].Type == WbTransaction::Burst || WbTransaction::End;
			}
		}

		if (transactions[size - 2].Type == WbTransaction::Burst)
			transactions[size - 1].Type == WbTransaction::End;
	};

	function void display();
		foreach(transactions[i])
			transactions[i].display();
	endfunction

endclass


typedef mailbox #(WbTransaction) WbTransMb;

`endif

