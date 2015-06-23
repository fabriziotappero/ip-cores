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
// File        : SdBFM-impl.sv
// Owner       : Rainer Kastl
// Description : Implementation of SD BFM
// Links       : SdBFM.sv 
// 

`ifndef SDBFMIMPL_SV
`define SDBFMIMPL_SV

function SdBFM::new(virtual ISdBus card);
	this.ICard = card;
	this.Log = new;
	this.Sem = new(1);

	// disable outputs
	ICard.cb.Cmd <= 'z;
	ICard.cb.Data <= 'z;
endfunction 

function void SdBFM::stop(int AfterCount);
	StopAfter = AfterCount;
endfunction

task SdBFM::sendCmd(inout SdBusTransData data);
	// startbit
	@ICard.cb;
	ICard.cb.Cmd <= cSdStartbit;

	// data
	begin

		foreach(data[i]) begin
			@ICard.cb;
			ICard.cb.Cmd <= data[i];
		end
		data.delete();
	end

	// endbit
	@ICard.cb;
	ICard.cb.Cmd <= cSdEndbit;

	@ICard.cb;
	ICard.cb.Cmd <= 'z;
	
	waitUntilReady();
endtask

task SdBFM::sendAllDataBlocks(SdDataBlock blocks[]);
	foreach(blocks[i]) begin
		sendDataBlock(blocks[i]);
		//waitUntilReady(); // TODO: check pauses between transactions on the bus without waits
	end
endtask

task SdBFM::waitUntilReady();
	//repeat (8) @ICard.cb;
endtask

task SdBFM::sendDataBlock(SdDataBlock block);
	if (Mode == standard) sendStandardDataBlock(block.data);
	else sendWideDataBlock(block.data);
endtask

task SdBFM::sendStandardDataBlock(logic data[$]);
	data.push_front(0); // startbit
	CrcOnContainer(data);
	data.push_back(1); // endbit

	foreach(data[i]) begin
		@ICard.cb;
		ICard.cb.Data[0] <= data[i];
	end

	@ICard.cb;
	ICard.cb.Data <= 'z; 
endtask

task SdBFM::sendWideDataBlock(logic data[$]);
	logic dat0[$];
	logic dat1[$];
	logic dat2[$];
	logic dat3[$];

	for (int i = 0; i < data.size(); i+=4) begin
		dat3.push_back(data[i]);
		dat2.push_back(data[i+1]);
		dat1.push_back(data[i+2]);
		dat0.push_back(data[i+3]);
	end
	CrcOnContainer(dat0);
	CrcOnContainer(dat1);
	CrcOnContainer(dat2);
	CrcOnContainer(dat3);

	@ICard.cb;
	ICard.cb.Data <= 0;

	for(int i = 0; i < dat0.size(); i++) begin
		@ICard.cb;
		ICard.cb.Data <= (dat3[i]<<3) + (dat2[i] <<2) + (dat1[i] <<1) + dat0[i];
	end
	
	@ICard.cb;
	ICard.cb.Data <= 0;

	@ICard.cb;
	ICard.cb.Data <= 'z;			
endtask

task SdBFM::sendBusy();
	repeat (2) @ICard.cb;

	@ICard.cb;
	ICard.cb.Data[0] <= 0;

	// send valid status
	@ICard.cb;
	ICard.cb.Data[0] <= 0;
	@ICard.cb;
	ICard.cb.Data[0] <= 1;
	@ICard.cb;
	ICard.cb.Data[0] <= 0;

	// endbit
	@ICard.cb;
	ICard.cb.Data[0] <= 1;

	// 10 busy cycles
	@ICard.cb;
	ICard.cb.Data[0] <= 0;
	repeat (10) @ICard.cb;
	ICard.cb.Data[0] <= 1;

	@ICard.cb;
	ICard.cb.Data <= 'z;
endtask

task SdBFM::send(input SdBusTrans token);
	SdBusTransData data;
	
	this.Sem.get(1);
	data = token.packToData();
	
	if (data.size() > 0) sendCmd(data);
	if (token.DataBlocks.size() > 0) sendAllDataBlocks(token.DataBlocks);
	else if (token.SendBusy == 1) sendBusy();
	
	this.Sem.put(1);		
endtask

task SdBFM::receive(output SdBusTransToken token);
	this.Sem.get(1);

	wait(ICard.cb.Cmd == cSdStartbit);
	recv(token);		
	
	this.Sem.put(1);
endtask

task SdBFM::recv(output SdBusTransToken token);
	token = new();		

	// data
	begin
		SdBusTransData data;

		for (int i = 0; i < 46; i++) begin
			@ICard.cb;
			data.push_back(ICard.cb.Cmd);
		end

		token.unpackFromData(data);
	end

	// endbit
	@ICard.cb;
	assert(ICard.cb.Cmd == cSdEndbit) else
	begin
		this.Log.error("Received invalid endbit during SdBFM.receive.\n");
	end
endtask

task SdBFM::receiveDataBlock(output SdDataBlock block);
	ICard.cb.Data <= 'bzzzz;

	if (Mode == wide) wait (ICard.cb.Data == 'b0000);
	else wait (ICard.cb.Data[0] == '0);

	recvDataBlock(block);
endtask

task SdBFM::recvDataBlock(output SdDataBlock block);
	if (Mode == standard) recvStandardDataBlock(block);
	else recvWideDataBlock(block);
endtask

task SdBFM::recvStandardDataBlock(output SdDataBlock block);
	Log.error("recvStandardDataBlock not implemented");
endtask

function void SdBFM::compareCrc16(aCrc16 actual, aCrc16 expected);
	assert(actual == expected) else begin
		string msg;
		$swrite(msg, "Data CRC error: %h %h", actual, expected);
		Log.error(msg);
	end
endfunction

task SdBFM::recvWideDataBlock(output SdDataBlock block);
	aCrc16 crc[4];
	logic dat0[$];
	logic dat1[$];
	logic dat2[$];
	logic dat3[$];

	block = new();

	for (int j = 0; j < 512*2; j++) begin
		@ICard.cb;
		dat0.push_back(ICard.cb.Data[0]);
		dat1.push_back(ICard.cb.Data[1]);
		dat2.push_back(ICard.cb.Data[2]);
		dat3.push_back(ICard.cb.Data[3]);
		for(int i = 3; i >= 0; i--) begin
			block.data.push_back(ICard.cb.Data[i]);
		end
	end

	// crc
	for (int j = 0; j < 16; j++) begin
		@ICard.cb;
		for(int i = 3; i >= 0; i--) begin
			crc[i][15-j] = ICard.cb.Data[i];
		end
	end

	compareCrc16(crc[0], calcCrc16(dat0));
	compareCrc16(crc[1], calcCrc16(dat1));
	compareCrc16(crc[2], calcCrc16(dat2));
	compareCrc16(crc[3], calcCrc16(dat3));

	// end bits
	@ICard.cb;
	assert(ICard.cb.Data == 'b1111);
endtask

task SdBFM::receiveOrSend();
	if(ICard.cb.Cmd == cSdStartbit) begin
		SdBusTransToken token;
		recv(token);
		ReceivedTransMb.put(token);
	end
	else begin
		int flag;
		SdBusTransToken token;

		flag = SendTransMb.try_get(token);
		if (flag == 1) send(token);
		else if (flag == -1) Log.error("Error accessing SendTransMb.");
	end
	@ICard.cb;
endtask

task SdBFM::run();
	while (StopAfter != 0) begin
		receiveOrSend();

		if (StopAfter > 0) StopAfter--;
	end
endtask

task SdBFM::start();
	fork
		begin
			//run();
		end
	join_none
endtask

`endif
