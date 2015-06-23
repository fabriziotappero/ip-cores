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
// File        : WishboneBFM.sv
// Owner       : Rainer Kastl
// Description : Wishbone BFM
// Links       : Wishbone Spec B.3
// 

`ifndef WISHBONE
`define WISHBONE

`include "IWishboneBus.sv";
`include "WbTransaction.sv";
`include "Logger.sv";

class WbBFM;

	virtual IWishboneBus.Master Bus;
	WbTransMb TransInMb;
	WbTransMb TransOutMb;
	int StopAfter = -1;
	Logger Log = new();

	function new(virtual IWishboneBus.Master Bus);
		this.Bus = Bus;
	endfunction

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		Idle();

		while (StopAfter != 0) begin
			WbTransaction transaction;

			TransInMb.get(transaction);
			
			case (transaction.Type)
			WbTransaction::Classic: begin
				case (transaction.Kind)
				WbTransaction::Read: begin 
					Read(transaction.Addr, transaction.Data);
				end
				WbTransaction::Write: begin 
					Write(transaction.Addr, transaction.Data);
				end
				endcase
			end
			
			default: begin
				string msg;
				$swrite(msg, "Transaction.Type %s not handled.", transaction.Type.name());
				Log.error(msg);
			end
			endcase

			TransOutMb.put(transaction);
			if (StopAfter > 0) StopAfter--;
		end
	endtask

	task Idle();
		@(posedge this.Bus.CLK_I)
		this.Bus.cbMaster.CYC_O  <= cNegated;
		this.Bus.cbMaster.ADR_O  <= '{default: cDontCare};
		this.Bus.cbMaster.DAT_O  <= '{default: cDontCare};
		this.Bus.cbMaster.SEL_O  <= '{default: cDontCare};
		this.Bus.cbMaster.STB_O  <= cNegated;
		this.Bus.cbMaster.TGA_O  <= '{default: cDontCare};
		this.Bus.cbMaster.TGC_O  <= '{default: cDontCare};
		this.Bus.cbMaster.TGD_O  <= cDontCare;
		this.Bus.cbMaster.WE_O   <= cDontCare;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		this.Bus.cbMaster.CTI_O  <= '{default: cDontCare};
		Log.note("WbBus idle");
	endtask;

	function void checkResponse();

		// Analyse slave response
		if (this.Bus.cbMaster.ERR_I == cAsserted) begin
			Log.error("MasterWrite: ERR_I asserted; Slave encountered an error.");
		end
		if (this.Bus.cbMaster.RTY_I == cAsserted) begin
			Log.note("MasterWrite: RTY_I asserted; Retry requested.");
		end

	endfunction;

	task Read(logic [`cWishboneWidth-1 : 0] Address,
			   ref bit [`cWishboneWidth-1 : 0] Data,
			   input logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
			   input logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		@(posedge this.Bus.CLK_I);
		this.Bus.cbMaster.ADR_O <= Address;
		this.Bus.cbMaster.TGA_O <= TGA;
		this.Bus.cbMaster.WE_O <= cNegated;
		this.Bus.cbMaster.SEL_O <= BankSelect;
		this.Bus.cbMaster.CYC_O <= cAsserted;
		this.Bus.cbMaster.TGC_O <= cAsserted;
		this.Bus.cbMaster.STB_O <= cAsserted;
		this.Bus.cbMaster.CTI_O <= ClassicCycle;

		//$display("%t : MasterRead: Waiting for slave resonse", $time);
		// Wait until slave responds
		wait ((this.Bus.cbMaster.ACK_I == cAsserted)
		||  (this.Bus.cbMaster.ERR_I == cAsserted)
		||  (this.Bus.cbMaster.RTY_I == cAsserted));

		checkResponse();

		Data = this.Bus.cbMaster.DAT_I; // latch it before the CLOCK???
		
		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		@(posedge this.Bus.CLK_I);

	endtask;

	task BlockRead(logic [`cWishboneWidth-1 : 0] Address,
					ref logic [`cWishboneWidth-1 : 0] Data[],
					input logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
					input logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		foreach(Data[i]) begin
			this.Bus.cbMaster.WE_O <= cNegated;
			this.Bus.cbMaster.CYC_O <= cAsserted;
			this.Bus.cbMaster.TGC_O <= cAsserted;
			this.Bus.cbMaster.STB_O <= cAsserted;
			this.Bus.cbMaster.LOCK_O <= cAsserted;
			this.Bus.cbMaster.ADR_O <= Address+i;
			this.Bus.cbMaster.TGA_O <= TGA;
			this.Bus.cbMaster.SEL_O <= BankSelect;
			this.Bus.cbMaster.CTI_O <= ClassicCycle;
			@(posedge this.Bus.CLK_I);

			//$display("%t : MasterRead: Waiting for slave response.", $time);
			// Wait until slave responds
			wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));

			checkResponse();
			Data[i] = this.Bus.cbMaster.DAT_I;
			//$display("%t : Reading %h", $time, Data[i]);
		end

		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		@(posedge this.Bus.CLK_I);

	endtask;

	task Write(logic [`cWishboneWidth-1 : 0] Address,
	           logic [`cWishboneWidth-1 : 0] Data,
	           logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
	           logic [`cWishboneWidth-1 : 0] TGD = cDontCare,
	           logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		@(posedge this.Bus.CLK_I)
		// CLOCK EDGE 0
		this.Bus.cbMaster.ADR_O <= Address;
		this.Bus.cbMaster.TGA_O <= TGA;
		this.Bus.cbMaster.DAT_O <= Data;
		this.Bus.cbMaster.TGD_O <= TGD;
		this.Bus.cbMaster.WE_O  <= cAsserted;
		this.Bus.cbMaster.SEL_O <= BankSelect;
		this.Bus.cbMaster.CYC_O <= cAsserted;
		this.Bus.cbMaster.TGC_O <= cAsserted; // Assert all?
		this.Bus.cbMaster.STB_O <= cAsserted;
		this.Bus.cbMaster.CTI_O <= ClassicCycle;
		//$display("%t : MasterWrite: Waiting for slave response.", $time);
		// Wait until slave responds

		wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));
		checkResponse();
		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;

		@(posedge this.Bus.CLK_I);
		// CLOCK EDGE 1
		//$display("%t : MasterWrite completed.", $time);
	endtask;

	task BlockWrite (logic [`cWishboneWidth-1 : 0] Address,
	                 logic [`cWishboneWidth-1 : 0] Data [],
	                 logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
	                 logic [`cWishboneWidth-1 : 0] TGD = cDontCare,
	                 logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1}
	);

		foreach(Data[i]) begin

			@(posedge this.Bus.CLK_I)
			// CLOCK EDGE 0
			this.Bus.cbMaster.ADR_O <= Address + i;
			this.Bus.cbMaster.TGA_O <= TGA;
			this.Bus.cbMaster.DAT_O <= Data[i];
			this.Bus.cbMaster.TGD_O <= TGD;
			this.Bus.cbMaster.WE_O  <= cAsserted;
			this.Bus.cbMaster.SEL_O <= BankSelect;
			this.Bus.cbMaster.CYC_O <= cAsserted;
			this.Bus.cbMaster.TGC_O <= cAsserted; // Assert all?
			this.Bus.cbMaster.STB_O <= cAsserted;
			this.Bus.cbMaster.LOCK_O <= cAsserted;
			this.Bus.cbMaster.CTI_O <= ClassicCycle;

			// Wait until slave responds
			wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));
			checkResponse();
			//$display("%t : MasterBlockWrite phase %d completed.", $time, i);
		end

		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		@(posedge this.Bus.CLK_I);
		// CLOCK EDGE 1
		//$display("%t : MasterBlockWrite completed.", $time);
	endtask;

	task TestSingleOps (logic [`cWishboneWidth-1 : 0] Address,
					   logic [`cWishboneWidth-1 : 0] Data);

		bit [`cWishboneWidth-1 : 0] rd;

		this.Write(Address, Data);
		this.Read(Address, rd);

		$display("%t : %h (read) == %h (written)", $time, rd, Data);
		assert (rd == Data);
	endtask;

	task TestBlockOps (logic [`cWishboneWidth-1 : 0] Address,
						logic [`cWishboneWidth-1 : 0] Data []);

		logic [`cWishboneWidth-1 : 0] blockData [];

		blockData = new [Data.size()];

		this.BlockWrite(Address, Data);
		this.BlockRead(Address, blockData);

		foreach(blockData[i]) begin
			$display("%t : %h (read) == %h (written)", $time, blockData[i], Data[i]);
			assert (Data[i] == blockData[i]);
		end

		blockData.delete();

	endtask;

endclass

`endif

