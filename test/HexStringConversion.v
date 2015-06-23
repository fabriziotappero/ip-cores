/*
Author: Sebastien Riou (acapola)
Creation date: 17:16:40 01/09/2011 

$LastChangedDate: 2011-02-13 16:20:10 +0100 (Sun, 13 Feb 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 15 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/HexStringConversion.v $				 

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
 
function [7:0] hexString2Byte;
	input [15:0] byteInHexString;
	integer i;
	reg [7:0] hexDigit;
	reg [4:0] nibble;
	begin
		for(i=0;i<2;i=i+1) begin
			nibble=5'b10000;//invalid
			hexDigit=byteInHexString[i*8+:8];
			if(("0"<=hexDigit)&&("9">=hexDigit))
				nibble=hexDigit-"0";
			if(("a"<=hexDigit)&&("f">=hexDigit))
				nibble=10+hexDigit-"a";
			if(("A"<=hexDigit)&&("F">=hexDigit))
				nibble=10+hexDigit-"A";
			if(nibble>15) begin
				$display("Invalid input for hex conversion: '%s', hexDigit='%s' (%x), nibble=%d",byteInHexString,hexDigit,hexDigit,nibble);
				$finish;
			end
			hexString2Byte[i*4+:4]=nibble;
		end
	end
endfunction

task getNextHexByte;
input [8*3*(256+5+1+2):0] bytesString;
input integer indexIn;
output reg [7:0] byteOut;
output integer indexOut;
reg [15:0] byteInHex;
begin
	byteInHex="  ";
	//$display("bytesString: %x",bytesString);	
	while((indexIn>=16)&((8'h0==byteInHex[15:8])|(8'h20==byteInHex[15:8]))) begin
		byteInHex=bytesString[(indexIn-1)-:16];
		indexIn=indexIn-8;
		//$display("indexIn: %d",indexIn);		
	end
	indexOut=indexIn-8;
	//$display("indexOut: %d, byteInHex: '%s' (%x)",indexOut, byteInHex, byteInHex);
	if((16'h0!=byteInHex) & (indexOut>=0) & (8'h20!=byteInHex[7:0])) begin
		byteOut=hexString2Byte(byteInHex);
		//$display("byteOut: %x",byteOut);
	end else begin
		indexOut=-1;
	end
end
endtask

task hexStringToBytes;
input [8*3*(256+5+1+2):0] bytesString;
output reg [8*(256+5+1+2):0] bytesOut;
output integer nBytes;
integer i;
reg [7:0] newByte;
begin
	nBytes=0;
	i=8*3*(256+5+1+2);
	//$display("bytesString: %x",bytesString);
	getNextHexByte(bytesString, i, newByte, i);
	while(i!=-1) begin
		//$display("i: %d, nBytes: %d, newByte: %x",i, nBytes, newByte);
		bytesOut[nBytes*8+:8]=newByte;
		nBytes=nBytes+1;
		getNextHexByte(bytesString, i, newByte, i);
	end
end
endtask
