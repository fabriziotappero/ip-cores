/*
Author: Sebastien Riou (acapola)
Creation date: 17:16:40 01/09/2011 

$LastChangedDate: 2011-02-14 15:11:43 +0100 (Mon, 14 Feb 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 16 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/ComTxDriverTasks.v $				 

This file is under the BSD licence:
Copyright (c) 2011, Sebastien Riou

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
The names of contributors may not be used to endorse or promote products derived from this software without specific prior written permission. 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`include "HexStringConversion.v"

//low level tasks
task sendByte;
  input [7:0] data;
  begin
      wait(bufferFull==1'b0);
      dataIn=data;
      nWeDataIn=0;
      @(posedge COM_clk);
      dataIn=8'hxx;
      nWeDataIn=1;
      @(posedge COM_clk);
	end
endtask
task sendWord;
  input [15:0] data;
  begin
      sendByte(data[15:8]);
		sendByte(data[7:0]);
	end
endtask

//return when the stop bit of the last byte is starting
task waitEndOfTx;
  begin
      @(posedge COM_clk)
		wait(txPending==0);
		wait(isTx==0);
	end
endtask


//Higher level tasks


task sendHexBytes;
	input [16*257:0] bytesString;
	integer i;
	reg [15:0] byteInHex;
	reg [7:0] byteToSend;
begin
	i=16*257;
	getNextHexByte(bytesString, i, byteToSend, i);
	while(i!=-1) begin
		sendByte(byteToSend);
		getNextHexByte(bytesString, i, byteToSend, i);
	end
end
endtask

task sendT0TpduLc;
	input [8*3*(256+5+1+2):0] bytesString;
	integer i;
	reg [15:0] byteInHex;
	reg [7:0] byteToSend;
	reg [8*(256+5+1+2):0] cmdBytes;
	integer nBytes;
begin
	hexStringToBytes(bytesString,cmdBytes,nBytes);
	sendByte(cmdBytes[0*8+:8]);
	sendByte(cmdBytes[1*8+:8]);
	sendByte(cmdBytes[2*8+:8]);
	sendByte(cmdBytes[3*8+:8]);
	sendByte(cmdBytes[4*8+:8]);
	if(0!==cmdBytes[4*8+:8]) begin
		i=5;
		receiveAndCheckByte(cmdBytes[1*8+:8]);//TODO: handle NACK
		while(i!=nBytes) begin
			sendByte(cmdBytes[i*8+:8]);
			i=i+1;
		end
	end
end
endtask

task sendT0TpduLeFull;
	input [8*3*5:0] bytesString;
	output [8*256:0] leBytes;
	output integer le;
	integer i;
	reg [15:0] byteInHex;
	reg [7:0] byteToSend;
	reg [8*(256+5+1+2):0] cmdBytes;
	integer nBytes;
begin
	hexStringToBytes(bytesString,cmdBytes,nBytes);
	sendByte(cmdBytes[0*8+:8]);
	sendByte(cmdBytes[1*8+:8]);
	sendByte(cmdBytes[2*8+:8]);
	sendByte(cmdBytes[3*8+:8]);
	sendByte(cmdBytes[4*8+:8]);
	le = (0===cmdBytes[4*8+:8]) ? 256 : cmdBytes[4*8+:8];
	if((nBytes!==5) & (le !== nBytes-5)) begin
		$display("ERROR: le (%d) don't match with nBytes (%d) in command %s",le,nBytes,bytesString);
		$finish;
	end
	receiveByte(cmdBytes[1*8+:8]);
	for(i=0;i<le;i=i+1) begin
		receiveByte(leBytes[i*8+:8]);
	end
end
endtask

task sendT0TpduLe;
	input [8*3*5:0] bytesString;
	output [8*256:0] leBytes;
	integer i;
begin
	sendT0TpduLeFull(bytesString,leBytes,i);
end
endtask

task sendT0TpduLeCheck;
	input [8*3*5:0] bytesString;
	input [8*3*256:0] expectedLeBytesString;
	integer i;
	reg [15:0] byteInHex;
	reg [7:0] byteToSend;
	reg [8*(256+5+1+2):0] cmdBytes;
	reg [8*256:0] leBytes;
	reg [8*256:0] expectedLeBytes;
	integer nBytes;
	integer expectedLe;
	integer le;
begin
	sendT0TpduLeFull(bytesString,leBytes,le);
	hexStringToBytes(expectedLeBytesString,expectedLeBytes,expectedLe);
	if(expectedLe !== le) begin
		$display("ERROR: expectedLe (%d) don't match with le (%d) in command %s, %s",expectedLe,le,bytesString, expectedLeBytesString);
		$finish;
	end
	for(i=0;i<le;i=i+1) begin
		if(leBytes[i*8+:8]!==expectedLeBytes[i*8+:8]) begin
			$display("ERROR: recived %x instead of %x at index %d in command %s, %s",leBytes[i*8+:8],expectedLeBytes[i*8+:8],i,bytesString, expectedLeBytesString);
			$finish;
		end
	end
end
endtask

