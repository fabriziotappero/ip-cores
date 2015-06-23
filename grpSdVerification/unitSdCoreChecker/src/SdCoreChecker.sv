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
// File        : SdCoreChecker.sv
// Owner       : Rainer Kastl
// Description : Checker for SdCoreTransactions
// Links       : 
// 

`ifndef SDCORECHECKER_SV
`define SDCORECHECKER_SV

`include "SdCoreTransaction.sv";
`include "RamAction.sv";
`include "ExpectedResult.sv";
`include "Logger.sv";

class SdCoreChecker;

	SdCoreTransSeqMb SdTransInMb;
	RamActionMb RamActionInMb;
	ExpectedResultMb ExpectedResultInMb;
	Logger Log = new();
	
	local SdCoreTransaction trans;

	covergroup SdCoreTransactions;
		coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus};
			bins transitions[] = (SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus => 
							SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus);
		}

		singleblock: coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock};
		}

		multiblock: coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase};
		}

		startAddr: coverpoint trans.startAddr {
			bins legal = {[0:1000]};
			illegal_bins ill = default;
		}

		endAddr: coverpoint trans.endAddr {
			bins legal = {[0:1000]};
			illegal_bins ill = default;
		}

		addressrange: coverpoint (trans.endAddr - trans.startAddr) {
			bins valid = {[1:$]};
			bins zero = {0};
			bins invalid = {[$:-1]};
		}

		cross singleblock, startAddr;
		cross multiblock, startAddr, endAddr;
		cross multiblock, addressrange;
	endgroup

	int StopAfter = -1;

	function new();
		SdCoreTransactions = new();
	endfunction

	task start();
		fork
			run();
		join_none
	endtask

	function void checkRamAction(RamAction actual, RamAction expected, DataBlock block);
		if (expected.Kind == RamAction::Write) begin
			if (actual.Kind != expected.Kind ||
				actual.Addr != expected.Addr ||
				actual.Data != expected.Data) begin

				string msg;
				$swrite(msg, "RamActions differ: %s%p%s%p%s%d%s%d%s%p%s%p",
				"\nactual kind ", actual.Kind, ", expected kind ", expected.Kind,
				"\nactual addr ", actual.Addr, ", expected addr ", expected.Addr,
				"\nactual data ", actual.Data, ", expected data ", expected.Data);
				Log.error(msg);

			end
	    end	else begin
			if (actual.Kind != expected.Kind ||
				actual.Addr != expected.Addr ||
				actual.Data != block) begin

				string msg;
				$swrite(msg, "RamActions differ: %s%p%s%p%s%d%s%d%s%p%s%p",
				"\nactual kind ", actual.Kind, ", expected kind ", expected.Kind,
				"\nactual addr ", actual.Addr, ", expected addr ", expected.Addr,
				"\nactual data ", actual.Data, ", expected data ", block);
				Log.error(msg);

			end
		end
	endfunction

	task run();
		while (StopAfter != 0) begin
			ExpectedResult res;
			RamAction ram[];

			// get transactions
			ExpectedResultInMb.get(res);
			ram = new[res.RamActions.size()];
			foreach(ram[i]) RamActionInMb.get(ram[i]);
			SdTransInMb.get(trans);

			// update functional coverage
			SdCoreTransactions.sample();

			// check transaction
			if (res.trans.compare(trans) == 1) begin
				string msg;
				Log.note("Checker: Transaction successful");
				$swrite(msg, "%s", trans.toString());
				Log.note(msg);
			end
			else begin
				string msg;
				$swrite(msg, "Actual: %s, Expected: %s", trans.toString(), res.trans.toString());
				Log.error(msg);
			end

			// check data
			foreach(ram[i]) begin
				checkRamAction(ram[i], res.RamActions[i], trans.data[i]);
			end

			if (StopAfter > 0) StopAfter--;
		end

	endtask

endclass

`endif
