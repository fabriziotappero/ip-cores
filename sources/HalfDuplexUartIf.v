/*
Author: Sebastien Riou (acapola)
Creation date: 19:57:35 10/31/2010 

$LastChangedDate: 2011-04-17 23:31:29 +0200 (Sun, 17 Apr 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 19 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/HalfDuplexUartIf.v $				 

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
`default_nettype none

module HalfDuplexUartIf
#(//parameters to override
	parameter DIVIDER_WIDTH = 1,
	parameter CLOCK_PER_BIT_WIDTH = 13	//allow to support default speed of ISO7816
)
(
    input wire nReset,
    input wire clk,
    input wire [DIVIDER_WIDTH-1:0] clkPerCycle,
	 input wire [7:0] dataIn,
    input wire nWeDataIn,
    input wire [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,
    input wire stopBit2,//0: 1 stop bit, 1: 2 stop bits
	 input wire oddParity, //if 1, parity bit is such that data+parity have an odd number of 1
    input wire msbFirst,  //if 1, bits order is: startBit, b7, b6, b5...b0, parity
	 output wire [7:0] dataOut,
    input wire nCsDataOut,
    output wire [7:0] statusOut,
    input wire nCsStatusOut,
    input wire serialIn,
	 output wire serialOut,
	 output wire comClk
    );


   reg [7:0] dataReg;

	// Inputs
	wire [7:0] txData;
	reg txPending;
	wire ackFlags;

	// Outputs
	wire [7:0] rxData;
	wire overrunErrorFlag;
	wire dataOutReadyFlag;
	wire frameErrorFlag;
	wire txRun;
   wire endOfRx;
	wire rxRun;
	wire rxStartBit;
	wire txFull;
	wire isTx;
   
   wire rxFlagsSet = dataOutReadyFlag | overrunErrorFlag | frameErrorFlag;
   reg bufferFull;
   reg [1:0] flagsReg;
   
   assign txData = dataReg;
   
   assign dataOut=dataReg;
   assign statusOut[7:0]={txRun, txPending, rxRun, rxStartBit, isTx, flagsReg, bufferFull};

reg waitTxFull0;//internal reg for managing bufferFull bit in Tx

assign ackFlags=~txPending & ~txRun & rxFlagsSet & ((bufferFull & ~nCsDataOut)| ~bufferFull);

always @(posedge clk, negedge nReset) begin
   if(~nReset) begin
      bufferFull <= 1'b0;
      flagsReg <= 2'b00;
      txPending <= 1'b0;
   end else begin
      if(ackFlags) begin
         dataReg <= rxData;
         flagsReg <= {overrunErrorFlag, frameErrorFlag};
         if(rxFlagsSet)
            bufferFull <= 1'b1;
         else
            bufferFull <= 1'b0;
      end else if(txPending) begin
         if(waitTxFull0) begin
            if(~txFull)
               waitTxFull0 <= 1'b0;
         end else if(txFull) begin//tx actually started, clear txPending and free buffer
            txPending <= 1'b0;
            bufferFull <= 1'b0; //buffer is empty
         end
      end else if(~nCsDataOut) begin
         bufferFull <= 1'b0;
      end else if(~nWeDataIn) begin
         dataReg <= dataIn;
         bufferFull <= 1'b1;
         txPending <= 1'b1;
         waitTxFull0 <= txFull;
      end
   end
end   
wire endOfTx;
	BasicHalfDuplexUart #(
		.DIVIDER_WIDTH(DIVIDER_WIDTH),
		.CLOCK_PER_BIT_WIDTH(CLOCK_PER_BIT_WIDTH)
		)
	uart (
		.rxData(rxData), 
		.overrunErrorFlag(overrunErrorFlag), 
		.dataOutReadyFlag(dataOutReadyFlag), 
		.frameErrorFlag(frameErrorFlag), 
		.txRun(txRun), 
		.endOfRx(endOfRx),
		.endOfTx(endOfTx),
      .rxRun(rxRun), 
		.rxStartBit(rxStartBit), 
		.txFull(txFull), 
		.isTx(isTx), 
		.serialIn(serialIn),
		.serialOut(serialOut),
		.comClk(comClk),
		.txData(txData), 
		.clocksPerBit(clocksPerBit), 
		.stopBit2(stopBit2), 
		.oddParity(oddParity), 
      .msbFirst(msbFirst),  
	   .startTx(txPending), 
		.ackFlags(ackFlags),
		.clkPerCycle(clkPerCycle),
		.clk(clk), 
		.nReset(nReset)
	);

endmodule
`default_nettype wire
