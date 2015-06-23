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
// File        : SdCoreTransferFunction.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDCORETRANSFERFUNCTION_SV
`define SDCORETRANSFERFUNCTION_SV

`include "SdCoreTransaction.sv";
`include "ExpectedResult.sv";
`include "Logger.sv";
`include "SdCardModel.sv";

class SdCoreTransferFunction;

	SdCoreTransSeqMb TransInMb;
	ExpectedResultMb ExpectedResultOutMb;

	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction transaction;
			ExpectedResult res = new();

			TransInMb.get(transaction);
			res.trans = transaction;

			case(transaction.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Read;
						res.RamActions[0].Addr = transaction.startAddr;
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Write;
						res.RamActions[0].Addr = transaction.startAddr;
						res.RamActions[0].Data = transaction.data[0];
					end
			default:
					begin
						string msg;
						$swrite(msg, "TF: Transaction kind %s not handled.", transaction.kind.name());
						Log.error(msg);
					end
			endcase

			ExpectedResultOutMb.put(res);

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
