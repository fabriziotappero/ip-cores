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
// File        : SdCardModel.sv
// Owner       : Rainer Kastl
// Description : SD Card model
// Links       : 
// 

`ifndef SDCARDMODEL
`define SDCARDMODEL

const logic cActivated = 1;
const logic cInactivated = 0;

`include "Crc.sv";
`include "SdCommand.sv";
`include "SdBFM.sv";
`include "Logger.sv";
`include "RamAction.sv";

class RamModel;
	local bit[0:511][7:0] data[];
	RamActionMb RamActionOutMb;

	function new(int size);
		data = new[size];
	endfunction

	function int size();
		return data.size();
	endfunction

	task getDataBlock(logic[31:0] addr, output SdDataBlock block);
		RamAction action = new(RamAction::Read, addr, data[addr]);
		block = new();

		for (int i = 0; i < 512; i++) begin
			for (int j = 7; j >= 0; j--) begin
				block.data.push_back(data[addr][i][j]);
			end
		end

		if (RamActionOutMb != null)	
		begin
			RamActionOutMb.put(action);
		end
	endtask

	task setDataBlock(logic[31:0] addr, SdDataBlock block);
		for (int i = 0; i < 512; i++) begin
			for (int j = 7; j >= 0; j--) begin
				data[addr][i][j] = block.data.pop_front();
			end
		end

		if (RamActionOutMb != null)	
		begin
			RamAction action = new(RamAction::Write, addr, data[addr]);
			RamActionOutMb.put(action);
		end
	endtask

endclass

class SdCardModel;
	
	SdBfmMb SdTransOutMb;
	SdBfmMb SdTransInMb;

	SdBFM bfm;
	local SdCardModelState state = new();
	local RCA_t rca;
	local logic CCS;
	local Mode_t mode;
	local DataMode_t datamode;
	local Logger log = new();
	RamModel ram;

	//local rand int datasize; // ram addresses = 2^datasize - 1; 512 byte blocks
	//constraint cdatasize {datasize == 32;}
	
	/*function void post_randomize() ;
		this.ram = new[datasize];
	endfunction*/

	function new();
		this.CCS = 1;
		rca = 0;
		mode = standard;
		ram = new(100);
	endfunction

	task start();
		fork
			run();
		join_none
	endtask

	task reset();
	endtask

	task automatic init();
		SDCommandR7 voltageresponse;
		SDCommandR1 response;
		SDCommandR3 acmd41response;
		SDCommandR2 cidresponse;
		SDOCR ocr;
		SDCommandR6 rcaresponse;
		logic data[$];
		SdBusTransToken token;

		log.note("Expecting CMD0");
		// expect CMD0 so that state is clear
		this.bfm.receive(token);
		assert(token.id == cSdCmdGoIdleState) else log.error("Received invalid token.");
		
		// expect CMD8: voltage and SD 2.00 compatible
		log.note("Expecting CMD8");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendIfCond) else log.error("Received invalid token.");	
		assert(token.arg[12:8] == 'b0001) else
		begin
			string msg;
			$swrite(msg, "Received invalid arg: %b", token.arg);
			log.error(msg); // Standard voltage
		end;

		// respond with R7: we are SD 2.00 compatible and compatible to the
		// voltage
		voltageresponse = new(token.arg);
		this.bfm.send(voltageresponse);

		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		log.note("Expect ACMD41 (with HCS = 1)");
		this.bfm.receive(token);
		assert(token.id == cSdCmdACMD41) else log.error("Received invalid token.\n");
		assert(token.arg == cSdArgACMD41HCS) else begin
			string msg;
			$swrite(msg, "Received invalid arg: %b, Expected: %b", token.arg, cSdArgACMD41HCS);
			log.error(msg);
		end;
		state.AppCmd = 0;

		// respond with R3, not done
		ocr = new(CCS, cSdVoltageWindow);
		acmd41response = new(ocr);
		this.bfm.send(acmd41response);
		
		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		log.note("Expect ACMD41 (with HCS = 1)");
		this.bfm.receive(token);
		assert(token.id == cSdCmdACMD41) else log.error("Received invalid token.\n");
		assert(token.arg == cSdArgACMD41HCS) else begin
			string msg;
			$swrite(msg, "Received invalid arg: %b, Expected: %b", token.arg, cSdArgACMD41HCS);
			log.error(msg);
		end;
		state.AppCmd = 0;

		// respond with R3
		ocr.setBusy(cOCRDone);
		acmd41response = new(ocr);
		this.bfm.send(acmd41response);

		// expect CMD2
		log.note("Expect CMD2");
		this.bfm.receive(token);
		assert(token.id == cSdCmdAllSendCID) else log.error("Received invalid token.\n");

		// respond with R2
		cidresponse = new();
		this.bfm.send(cidresponse);

		// expect CMD3
		log.note("Expect CMD3");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendRelAdr) else log.error("Received invalid token.\n");

		// respond with R3
		rcaresponse = new(rca, state);
		this.bfm.send(rcaresponse);

		// expect CMD7
		log.note("Expect CMD7");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSelCard);
		assert(token.arg[31:16] == rca);

		// respond with R1, no busy
		state.ReadyForData = 1;
		response = new(cSdCmdSelCard, state);
		this.bfm.send(response);

		// expect ACMD51
		recvCMD55(rca);
		log.note("Expect ACMD51");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendSCR);

		// respond with R1 and dummy SCR
		response = new(cSdCmdSendSCR, state);
		response.DataBlocks = new[1];
		response.DataBlocks[0] = new();
		
		// send dummy SCR
		for (int i = 0; i < 64; i++)
			response.DataBlocks[0].data.push_back(0);
		
		response.DataBlocks[0].data[63-50] = 1;
		response.DataBlocks[0].data[63-48] = 1;

		this.bfm.send(response);

		// expect ACMD6
		recvCMD55(rca);
		log.note("Expect ACMD6");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSetBusWidth);
		assert(token.arg == 'h00000002);

		response = new(cSdCmdSetBusWidth, state);
		this.bfm.send(response);

		this.bfm.Mode = wide;
		mode = wide;

		// expect CMD6
		log.note("Expect CMD6");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSwitchFuntion);
		assert(token.arg == 'h00FFFFF1);

		response.DataBlocks = new[1];
		response.DataBlocks[0] = new();
		
		for (int i = 0; i < 512; i++)
			response.DataBlocks[0].data.push_back(0);

		response.DataBlocks[0].data[511-401] = 1;
		response.DataBlocks[0].data[511-376] = 1;

		this.bfm.send(response);

		// expect CMD6 with set
		log.note("Expect CMD6 with set");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSwitchFuntion);
		assert(token.arg == 'h80FFFFF1);
		this.bfm.send(response);

		// switch to 50MHz
		// expect CMD13
		log.note("Expect CMD13");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendStatus);
		assert(token.arg == rca);
		response = new(cSdCmdSendStatus, state);
		this.bfm.send(response);

		log.note("Card init done");
	endtask

	task run();
		this.init();

		forever begin
			SdBusTransToken token;
			this.bfm.receive(token);

			case (token.id)
				cSdCmdWriteSingleBlock:	this.write(token);
				cSdCmdReadSingleBlock: this.read(token);
				default: begin
						string msg;
						$swrite(msg, "Token not handled, ID: %b", token.id);
						log.error(msg);
				end
			endcase
		end
	endtask

	task read(SdBusTransToken token);
		SDCommandR1 response;
		logic[31:0] addr;

		// expect Read
		assert(token.id == cSdCmdReadSingleBlock);
		addr = token.arg;
		assert(addr <= ram.size()) else log.error("Read outside of available RAM");
		response = new(cSdCmdReadSingleBlock, state);
		response.DataBlocks = new[1];
		
		//$display("Ram before read (%h):  %h", addr, ram[addr]);
		ram.getDataBlock(addr, response.DataBlocks[0]);

		this.bfm.send(response);
	endtask

	task write(SdBusTransToken token);
		SDCommandR1 response;
		SdDataBlock rdblock;
		logic[31:0] addr;

		// expect Write
		assert(token.id == cSdCmdWriteSingleBlock);
		addr = token.arg;
		assert(addr <= ram.size()) else log.error("Write outside of available RAM");
		response = new(cSdCmdWriteSingleBlock, state);
		this.bfm.send(response);

		// recv data
		this.bfm.receiveDataBlock(rdblock);
		ram.setDataBlock(addr, rdblock);
	
		this.bfm.waitUntilReady();
		this.bfm.sendBusy();
	
	endtask

	task recvCMD55(RCA_t rca);
		SDCommandR1 response;
		SdBusTransToken token;
		
		// expect CMD55
		this.bfm.receive(token);
		assert(token.id == cSdCmdNextIsACMD);
		assert(token.arg[31:16] == rca);
		state.recvCMD55();

		// respond with R1
		response = new(cSdCmdNextIsACMD, state);
		this.bfm.send(response);	
	endtask
	
endclass

class NoSdCardModel extends SdCardModel;

	function new();
		super.new();
	endfunction

	task automatic init();
	endtask

endclass

`endif
