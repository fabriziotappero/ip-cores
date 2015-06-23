/*
Author: Sebastien Riou (acapola)
Creation date: 17:16:40 01/09/2011 

$LastChangedDate: 2011-02-10 16:40:57 +0100 (Thu, 10 Feb 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 14 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/ComRxDriverTasks.v $				 

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

//wire txRun,txPending, rxRun, rxStartBit, isTx, overrunErrorFlag, frameErrorFlag, bufferFull;
//assign {txRun, txPending, rxRun, rxStartBit, isTx, overrunErrorFlag, frameErrorFlag, bufferFull} = COM_statusOut;


task privateTaskReceiveByteCore;
  begin
      wait(txPending==1'b0);//wait start of last tx if any
      wait(txRun==1'b0);//wait end of previous transmission if any
      wait(bufferFull==1'b1);//wait reception of a byte
      @(posedge COM_clk);
      nCsDataOut=0;
      @(posedge COM_clk);
      nCsDataOut=1;
	end
endtask
task receiveByte;
output reg [7:0] rxData;
	begin
		privateTaskReceiveByteCore;
		rxData=dataOut;
      @(posedge COM_clk);
	end
endtask
task receiveAndCheckByte;
  input [7:0] data;
  begin
      privateTaskReceiveByteCore;
      if(data!=dataOut) begin
         COM_errorCnt=COM_errorCnt+1;
         $display("ERROR %d: Received %x instead of %x",COM_errorCnt, dataOut, data);
      end
		@(posedge COM_clk);
	end
endtask

//Higher level tasks
task receiveAndCheckHexBytes;
	input [16*257:0] bytesString;
	integer i;
	reg [15:0] byteInHex;
	reg [7:0] byteToCheck;
begin
	i=16*257;
	getNextHexByte(bytesString, i, byteToCheck, i);
	while(i!=-1) begin
		receiveAndCheckByte(byteToCheck);
		getNextHexByte(bytesString, i, byteToCheck, i);
	end
end
endtask
