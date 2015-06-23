/*
Author: Sebastien Riou (acapola)
Creation date: 23:57:02 09/04/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/RxCoreSpec.v $				 

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

/*
non synthetizable model used as reference in test bench
*/

module RxCoreSpec(
    output reg [7:0] dataOut,
    output reg overrunErrorFlag,	//new data has been received before dataOut was read
    output reg dataOutReadyFlag,	//new data available
    output reg frameErrorFlag,		//bad parity or bad stop bits
    output reg endOfRx,
    output reg run,					//rx is definitely started, one of the three flag will be set
    output reg startBit,				//rx is started, but we don't know yet if real rx or just a glitch
	 input [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,			
	 input stopBit2,//0: 1 stop bit, 1: 2 stop bits
	 input ackFlags,
	 input serialIn,
    input clk,
    input nReset
    );
parameter CLK_PERIOD = 10;//should be %2
//parameters to override
parameter CLOCK_PER_BIT_WIDTH = 13;	//allow to support default speed of ISO7816
//invert the polarity of the output or not
parameter IN_POLARITY = 1'b0;
parameter PARITY_POLARITY = 1'b0;
//default conventions
parameter START_BIT = 1'b0;
parameter STOP_BIT1 = 1'b1;
parameter STOP_BIT2 = 1'b1;

//constant definition for states
localparam IDLE_BIT = ~START_BIT;

integer bitCounter;

reg parityBit;
reg rxStarted;

wire internalIn;
wire parityError;

assign internalIn = serialIn ^ IN_POLARITY;
assign parityError= parityBit ^ internalIn ^ PARITY_POLARITY ^ 1'b1;
reg syncClk;

/*logic to avoid race condition on flags
if internal logic set the flag and at the same time
the signal ackFlags is set (that normally clears the flags), the flag should be set
*/
reg setOverrunErrorFlag;
reg nResetOverrunErrorFlag;
always @(negedge clk) begin
	setOverrunErrorFlag<=1'b0;
end

//flag set has priority over flag nReset
always @(setOverrunErrorFlag,nResetOverrunErrorFlag) begin
	if((setOverrunErrorFlag===1'b1) || (setOverrunErrorFlag===1'bx)) begin
		overrunErrorFlag<=setOverrunErrorFlag;
		if(nResetOverrunErrorFlag)
			nResetOverrunErrorFlag=0;
	end else begin
		if(nResetOverrunErrorFlag) begin
			overrunErrorFlag<=0;
			nResetOverrunErrorFlag=0;
		end
	end
end

reg setDataOutReadyFlag;
reg nResetDataOutReadyFlag;
always @(negedge clk) begin
	setDataOutReadyFlag<=1'b0;
end

//flag set has priority over flag nReset
always @(setDataOutReadyFlag,nResetDataOutReadyFlag) begin
	if((setDataOutReadyFlag===1'b1) || (setDataOutReadyFlag===1'bx)) begin
		dataOutReadyFlag<=setDataOutReadyFlag;
		if(nResetDataOutReadyFlag)
			nResetDataOutReadyFlag=0;
	end else begin
		if(nResetDataOutReadyFlag) begin
			dataOutReadyFlag<=0;
			nResetDataOutReadyFlag=0;
		end
	end
end

reg setFrameErrorFlag;
reg nResetFrameErrorFlag;
always @(negedge clk) begin
	setFrameErrorFlag<=1'b0;
end

//flag set has priority over flag nReset
always @(setFrameErrorFlag,nResetFrameErrorFlag) begin
	if((setFrameErrorFlag===1'b1) || (setFrameErrorFlag===1'bx)) begin
		frameErrorFlag<=setFrameErrorFlag;
		if(nResetFrameErrorFlag)
			nResetFrameErrorFlag=0;
	end else begin
		if(nResetFrameErrorFlag) begin
			frameErrorFlag<=0;
			nResetFrameErrorFlag=0;
		end
	end
end

reg dataOutReadyFlagAckDone;
reg frameErrorFlagAckDone;

always @(posedge clk) begin:ACK_FLAGS
	if(ackFlags) begin
		if(0==rxStarted)
			nResetOverrunErrorFlag<=1;//otherwise, done in OVERRUN_BIT block
		if(dataOutReadyFlag!==1'bx)
			nResetDataOutReadyFlag<=1'b1;
		dataOutReadyFlagAckDone<=1'b1;
		if(frameErrorFlag!==1'bx)
			nResetFrameErrorFlag<=1'b1;
		frameErrorFlagAckDone<=1'b1;
	end
end

reg internalStart;
integer clockCounter;
always@(posedge internalStart) begin:CLOCK_COUNTER
	for(clockCounter=0;clockCounter<(11+stopBit2)*(clocksPerBit+1);clockCounter=clockCounter+1) begin
		syncClk=0;
		#(CLK_PERIOD/2);
		syncClk=1;
		#(CLK_PERIOD/2);
	end
end

reg abortStart;
always@(posedge abortStart) begin:ABORT_START
	abortStart<=0;
	startBit<=1'bx;
	#(CLK_PERIOD*(clocksPerBit+1)/4);
	if(internalIn)
		startBit<=0;
end
//Start bit spec
always@(negedge internalIn) begin:START_BIT_BLK
	if(frameErrorFlag | overrunErrorFlag) begin
		//nothing to do, wait clear from outside 
	end else begin
		internalStart<=1;
		startBit<=1'bx;
		#(CLK_PERIOD*(clocksPerBit+1)/4);
		internalStart<=0;
		startBit<=1;
		#(CLK_PERIOD*(clocksPerBit+1)/4);
		if(internalIn==0) begin
			startBit<=1'bx;
			#(CLK_PERIOD*(clocksPerBit+1)/4);
			startBit<=0;
			#(CLK_PERIOD*(clocksPerBit+1)/4);
			#(CLK_PERIOD*(10+stopBit2)*(clocksPerBit+1));//ignore falling edge until end of the byte
		end else begin
			abortStart<=1;
		end
	end
end

wire [31:0] stopStart=10*(clocksPerBit+1);
wire [31:0] stopEnd=((10+stopBit2)*(clocksPerBit+1)+((clocksPerBit+1)*3)/4);
wire isInStop=(clockCounter>=stopStart) && (clockCounter<stopEnd);
reg runBitSet;
//Run bit spec
always@(negedge internalIn) begin:RUN_BIT_SET
	if(frameErrorFlag | overrunErrorFlag) begin
		//nothing to do, wait clear from outside 
	end else if(~isInStop) begin
		runBitSet<=1'b0;
		#(CLK_PERIOD*(clocksPerBit+1)/2);
		if(internalIn == 0) begin
			fork
				begin
					runBitSet<=1'b1;
					run<=1'bx;
					#(CLK_PERIOD*(clocksPerBit+1)/4);
					run<=1;
				end 
				begin
					#(CLK_PERIOD*(clocksPerBit+1)/2);
					#(CLK_PERIOD*(9+stopBit2)*(clocksPerBit+1));
				end
			join
		end
	end
end

always@(posedge runBitSet) begin:RUN_BIT_CLEAR
	#(CLK_PERIOD*(clocksPerBit+1)/2);
	#(CLK_PERIOD*(((10+stopBit2)*(clocksPerBit+1))-2));
   if(runBitSet)
      endOfRx<=1'bx;
	#(CLK_PERIOD);
	if(runBitSet) begin//might be cleared by nReset
		run<=1'bx;
		#(CLK_PERIOD*(clocksPerBit+1)/4);
      endOfRx<=1'b0;
      run<=0;
	end
end

//overrun  bit spec
reg internalOv;
wire [31:0] minOvCount=(clocksPerBit+1);//WARNING: DATA_OUT block rely on this
wire [31:0] maxOvCount=((clocksPerBit+1)/2)+(clocksPerBit+1)+(clocksPerBit+1)/4;
always@(posedge syncClk) begin:OVERRUN_BIT
	if(clockCounter<maxOvCount) begin//internal requests to set the flag have priority over clear by ackFlags
		if(clockCounter==minOvCount)
			if(dataOutReadyFlag)
				setOverrunErrorFlag <= 1'bx;
	end else if(clockCounter==maxOvCount) begin
		if(1'bx===overrunErrorFlag)
			setOverrunErrorFlag <= 1;
	end else
		if(ackFlags)
			nResetOverrunErrorFlag <= 1;
end

reg [7:0] dataStorage;
reg waitStartBit;
//dataOut spec
//frameErrorFlag spec (1/2)
always@(negedge internalIn) begin:DATA_OUT
	if(frameErrorFlag | overrunErrorFlag) begin
		//nothing to do, wait clear from outside 
	end else begin
		waitStartBit<=1'b0;
		#(CLK_PERIOD*(clocksPerBit+1)/2);
		if(internalIn==0) begin
			#(CLK_PERIOD*(minOvCount-((clocksPerBit+1)/2)));
			fork
				if(0==dataOutReadyFlag) begin
					dataOut<=8'bx;
					#(CLK_PERIOD*(clocksPerBit+1)/2);
					#(CLK_PERIOD*8*(clocksPerBit+1));//wait 8 bits + parity
					parityBit <= ^dataStorage;
					if(0==(^dataStorage) ^ internalIn ^ PARITY_POLARITY ^ 1'b1) begin
						setDataOutReadyFlag<=1'bx;
						dataOutReadyFlagAckDone<=1'b0;
						#(CLK_PERIOD*2);//#(CLK_PERIOD*(clocksPerBit+1)/4);//allow 1/4 bit time latency
						dataOut<=dataStorage;
						if(~dataOutReadyFlagAckDone)
							setDataOutReadyFlag<=1'b1;
						else
							nResetDataOutReadyFlag<=1'b1;
					end else begin
						setFrameErrorFlag <= 1'bx;
						frameErrorFlagAckDone<=1'b0;
						#(CLK_PERIOD*2);//#(CLK_PERIOD*(clocksPerBit+1)/4);//allow 1/4 bit time latency
						if(~frameErrorFlagAckDone)
							setFrameErrorFlag<=1'b1;
						else
							nResetFrameErrorFlag<=1'b1;
					end
				end
				begin
					#(CLK_PERIOD*(clocksPerBit+1)/4);//we can detect start bit a 1/4 of bit time before the actual end of the transfer
					#(CLK_PERIOD*(9+stopBit2)*(clocksPerBit+1));
					#(CLK_PERIOD*(clocksPerBit+1)/2);
				end
			join
		end
		waitStartBit<=1'b1;
	end
end

//frameErrorFlag spec (2/2)
always@(negedge internalIn) begin:FRAME_ERROR
	if(frameErrorFlag | overrunErrorFlag) begin
		//nothing to do, wait clear from outside 
	end else begin
		if(isInStop) begin
			setFrameErrorFlag <= 1'bx;
			frameErrorFlagAckDone<=1'b0;
			#(CLK_PERIOD*(clocksPerBit+1)/1);//allow 1 bit time latency
			if(~frameErrorFlagAckDone)
				setFrameErrorFlag<=1'b1;
			else
				nResetFrameErrorFlag<=1'b1;
		end
	end
end

initial begin
	internalStart=0;
	clockCounter=0;
	abortStart=0;
	internalOv=0;
end

always @(negedge internalIn, negedge nReset) begin:MAIN
	if(~nReset) begin
		bitCounter <= 0;
		parityBit <= 0;
		nResetOverrunErrorFlag <= 1'b1;
		setOverrunErrorFlag <= 1'b0;
		nResetDataOutReadyFlag <= 1'b1;
		setDataOutReadyFlag <= 1'b0;
		nResetFrameErrorFlag <= 1'b1;
		setFrameErrorFlag<=1'b0;
      endOfRx<=1'b0;
		run <= 0;
		startBit <= 0;
		runBitSet<=0;
	end else if(frameErrorFlag | overrunErrorFlag) begin
		//nothing to do, wait clear from outside
	end else begin	
		rxStarted<=1'b1;
		#(CLK_PERIOD*(clocksPerBit+1)/2);
		if(internalIn == 0) begin
			@(posedge clk);
			for(bitCounter=0;bitCounter<8;bitCounter=bitCounter+1) begin
				#(CLK_PERIOD*(clocksPerBit+1)/1);
				if(~dataOutReadyFlag) begin
					dataStorage[bitCounter]<=internalIn;
				end
			end
			#(CLK_PERIOD*(clocksPerBit+1)/1);
			#(CLK_PERIOD*(clocksPerBit+1)/1);
			if(stopBit2) begin
				#(CLK_PERIOD*(clocksPerBit+1)/1);
			end
			rxStarted <= 1'b0;
		end
	end
end

endmodule
`default_nettype wire
