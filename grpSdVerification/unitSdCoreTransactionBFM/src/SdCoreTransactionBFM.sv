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
// File        : SdCoreTransactionBFM.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDCORETRANSACTIONBFM_SV
`define SDCORETRANSACTIONBFM_SV

`include "SdCoreTransaction.sv";
`include "WbTransaction.sv";
`include "WbTransactionReadSingleBlock.sv";
`include "WbTransactionWriteSingleBlock.sv";

class SdCoreTransactionBFM;

	SdCoreTransSeqMb SdTransInMb;
	SdCoreTransSeqMb SdTransOutMb;
	WbTransMb WbTransOutMb;
	WbTransMb WbTransInMb;
	
	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction trans;
			WbTransactionSequence seq;

			SdTransInMb.get(trans);

			case (trans.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						int j = 0;
						WbTransactionSequenceReadSingleBlock tmp = new(trans.startAddr, trans.endAddr);
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						trans.data = new[1];

						foreach(seq.transactions[i]) begin
							WbTransaction tr;

							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);

							// receive read data
							if (tr.Kind == WbTransaction::Read && tr.Addr == cReadDataAddr) begin
								trans.data[0][j++] = tr.Data[7:0];
								trans.data[0][j++] = tr.Data[15:8];
								trans.data[0][j++] = tr.Data[23:16];
								trans.data[0][j++] = tr.Data[31:24];
							end
						end
						
						SdTransOutMb.put(trans);
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						WbTransactionSequenceWriteSingleBlock tmp = new(trans.startAddr, trans.endAddr, trans.data[0]);
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						foreach(seq.transactions[i]) begin
							WbTransaction tr;
							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);
						end
						
						SdTransOutMb.put(trans);
					end
				default:
					begin
						string msg;
						$swrite(msg, "Transaction kind %s not handled.", trans.kind.name());
						Log.error(msg);
					end
			endcase
	

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
