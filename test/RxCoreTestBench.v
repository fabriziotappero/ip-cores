/*
Author: Sebastien Riou (acapola)
Creation date: 21:02:24 09/02/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/RxCoreTestBench.v $				 

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
`timescale 1ns / 1ps

module tb_RxCoreComparator(
	output reg implMismatch,
    output [7:0] dataOut,
    output overrunErrorFlag,	//new data has been received before dataOut was read
    output dataOutReadyFlag,	//new data available
    output frameErrorFlag,		//bad parity or bad stop bits
    output endOfRx,
    output run,					//rx is definitely started, one of the three flag will be set
    output startBit,				//rx is started, but we don't know yet if real rx or just a glitch
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

wire [7:0] ref_dataOut; 
wire ref_overrunErrorFlag;
wire ref_dataOutReadyFlag;
wire ref_frameErrorFlag;
wire ref_endOfRx;
wire ref_run;
wire ref_startBit; 

RxCoreSpec #(.PARITY_POLARITY(PARITY_POLARITY)) ref (
		.dataOut(ref_dataOut), 
		.overrunErrorFlag(ref_overrunErrorFlag), 
		.dataOutReadyFlag(ref_dataOutReadyFlag), 
		.frameErrorFlag(ref_frameErrorFlag), 
		.endOfRx(ref_endOfRx),
      .run(ref_run), 
		.startBit(ref_startBit), 
		.clocksPerBit(clocksPerBit),
		.stopBit2(stopBit2),
		.ackFlags(ackFlags), 
		.serialIn(serialIn),
		.clk(clk), 
		.nReset(nReset)
	);
	
RxCoreSelfContained #(.PARITY_POLARITY(PARITY_POLARITY)) uut (
	.dataOut(dataOut), 
	.overrunErrorFlag(overrunErrorFlag), 
	.dataOutReadyFlag(dataOutReadyFlag), 
	.frameErrorFlag(frameErrorFlag), 
	.endOfRx(endOfRx),
   .run(run), 
	.startBit(startBit), 
	.clocksPerBit(clocksPerBit),
	.stopBit2(stopBit2),
	.ackFlags(ackFlags), 
	.serialIn(serialIn),
	.clk(clk), 
	.nReset(nReset)
);

initial 
	implMismatch=0;
	
always @(posedge clk, posedge nReset) begin
	implMismatch=0;
	if(dataOut!=ref_dataOut) begin
		implMismatch=1;
		$display ("ERROR: dataOut!=ref_dataOut");
	end
	if(overrunErrorFlag!=ref_overrunErrorFlag) begin
		implMismatch=1;
		$display ("ERROR: overrunErrorFlag!=ref_overrunErrorFlag");
	end
	if(dataOutReadyFlag!=ref_dataOutReadyFlag) begin
		implMismatch=1;
		$display ("ERROR: dataOutReadyFlag!=ref_dataOutReadyFlag");
	end
	if(frameErrorFlag!=ref_frameErrorFlag) begin
		implMismatch=1;
		$display ("ERROR: frameErrorFlag!=ref_frameErrorFlag");
	end
	if(endOfRx!=ref_endOfRx) begin
		implMismatch=1;
		$display ("ERROR: endOfRx!=ref_endOfRx");
	end
	if(run!=ref_run) begin
		implMismatch=1;
		$display ("ERROR: run!=ref_run");
	end
	if(startBit!=ref_startBit) begin
		implMismatch=1;
		$display ("ERROR: startBit!=ref_startBit");
	end
end
	
endmodule


module tb_RxCore;
parameter PARITY	= 1;
parameter CLK_PERIOD = 10;//should be %2
	// Inputs
	reg [12:0] clocksPerBit;
	reg stopBit2;
	reg ackFlags;
	wire realSerialIn;
	reg clk;
	reg nReset;

	// Outputs
	wire [7:0] dataOut;
	wire overrunErrorFlag;
	wire dataOutReadyFlag;
	wire frameErrorFlag;
	wire run;
	wire startBit;
	wire stopBit;


reg serialIn;
assign #1 realSerialIn = serialIn;

	// Instantiate the Unit Under Test (UUT)
	wire implMismatch;
	tb_RxCoreComparator #(.PARITY_POLARITY(PARITY)) uut (
		.implMismatch(implMismatch),
		.dataOut(dataOut), 
		.overrunErrorFlag(overrunErrorFlag), 
		.dataOutReadyFlag(dataOutReadyFlag), 
		.frameErrorFlag(frameErrorFlag), 
		.endOfRx(endOfRx),
      .run(run), 
		.startBit(startBit), 
		.stopBit(stopBit),
      .clocksPerBit(clocksPerBit),
		.stopBit2(stopBit2),
		.ackFlags(ackFlags), 
		.serialIn(realSerialIn),
		.clk(clk), 
		.nReset(nReset)
	);


//test bench signals
reg tbClock;
integer tbError;
integer tbClockCounter;
integer tbBitTime;
integer tbStartBitTime,tbRunBitFallTime, tbByteTime, tbByteMinTime, tbByteClockCounter;
integer tbLastStartBit;
reg tbStartBitEn;//set this to 0 to turn of start bit detection (useful when testing glitch)

event TrigResetDut;
event TrigResetDutRelease;
event TrigTerminateSim;

initial
begin
 $display ("###################################################");
 clk = 0;
 nReset = 0;
 tbError = 0;
 tbClockCounter=0;
end

initial
@ (TrigTerminateSim)  begin
 $display ("Terminating simulation");
 if (tbError == 0) begin
   $display ("Simulation Result : PASSED");
 end
 else begin
   $display ("Simulation Result : FAILED, %d error(s)", tbError);
 end
 $display ("###################################################");
 #1 $finish;
end

//parameter values for SendByte task
localparam WRONG_PARITY=8;
localparam ACKFLAGS=4;
localparam EXPECT_OVERRUN=2;
localparam EXPECT_FRAME_ERROR=1;	

initial
forever begin
 @ (TrigResetDut);
 $display ("Applying nReset");
   nReset = 0;
	#(CLK_PERIOD*10);
   nReset = 1;
 $display ("Reset release");
 -> TrigResetDutRelease;
end	
	
	initial begin
		//tb signals
		tbBitTime=8;
		tbStartBitEn=1;
		// DUT Inputs
		clocksPerBit = tbBitTime-1;
		stopBit2=0;
		ackFlags = 0;
		clk = 0;
		nReset = 0;
		tbClock=0;
		tbError=0;
		serialIn=1;

		//tb signals which depends on DUT config
		//those times are in clock cycle unit
		tbByteTime=(11+stopBit2)*tbBitTime;
		tbByteMinTime=tbByteTime-(tbBitTime/4);
		tbdataOutReadyBitMinTime=9*tbBitTime+(tbBitTime/2)-1;
		tbdataOutReadyBitMaxTime=tbdataOutReadyBitMinTime+(tbBitTime/4)+1;

		tc01_basicTransfer();
		tc02_earliestAckFlags();
		tc03_ackFlagsPolling();
		tc04_contiuousTransfer();
		tc05_parityError();
		tc06_basicOverrun();
		tc07_abortedStart();
		tc08_stopBitViolation();
		tc09_ackFlagsPollingFrameError();
		
		#(CLK_PERIOD*12);
		-> TrigTerminateSim;
	end

reg ackFlagsDone;
task ackFlagsTask;
	begin
		ackFlags=1;
		#(CLK_PERIOD*1);
		ackFlagsDone=1;
		ackFlags=0;
		#(CLK_PERIOD*1);
		if(dataOutReadyFlag) begin
			tbError=tbError+1;
			$display("Error %d: dataOutReadyFlag is still set",tbError);
		end
	end
endtask

task tc01_basicTransfer;
	begin
		//uut.dataOut=8'b0;//to see the point where it becomes undefined when a rx started
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h55, 0);
		#(CLK_PERIOD*tbBitTime*2);
		ackFlagsTask();
	end
endtask

task tc02_earliestAckFlags;
	begin
		//uut.dataOut=8'b0;//to see the point where it becomes undefined when a rx started
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		fork
			SendByte(8'h55, 0);
			begin
				wait(dataOutReadyFlag===1);
				ackFlagsTask();
			end
		join
	end
endtask

task tc03_ackFlagsPolling;
	begin
		//uut.dataOut=8'b0;//to see the point where it becomes undefined when a rx started
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		ackFlags=1;//stuck it to one to simulate intensive polling
		#(CLK_PERIOD*2);
		fork
			SendByte(8'h55, 0);
			begin
				wait(dataOutReadyFlag===1);//check that dataOutReadyFlag is set even if ackFlags is set continuously
				#1;
				ackFlagsDone=1;//set ackFlagsDone to avoid to get dummy error due to the check within SendByte
			end
		join
		ackFlags=0;
	end
endtask

task tc04_contiuousTransfer;
	integer i,tc04Done;
	begin
		tc04Done=0;
		//uut.dataOut=8'b0;//to see the point where it becomes undefined when a rx started
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		lateAckFlagsEnable=1;
		fork
			begin
				for(i=0;i<256;i=i+1) begin
					SendByte(i, 0);
					//not supported by ISE12.2 (AR#  	36304)
					//replaced by LATE_ACKFLAGS
					/*fork
						SendByte(i, 0);
						begin//ackFlags at the latest time possible for continuous transfer
							#(CLK_PERIOD*((tbBitTime/2)+tbBitTime-1));
							ackFlagsTask();
						end
					join*/
				end
				tc04Done=1;
			end
			begin
				wait(run===1);
				@(negedge tbIsRx);
            //Spec change, run goes low one cycles earlier so a negedge happen even during continuous transfers
            //to emulate old behavior, a signal following run can be implement using a flip flop and combine run and following signal with an or gate...
				/*if(0==tc04Done) begin
					tbError=tbError+1;
					$display("Error %d: tbIsRx went low during continuous transfer",tbError);
				end*/
			end
		join
		lateAckFlagsEnable=0;
	end
endtask

task tc05_parityError;
	begin
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		SendByte(8'h55, WRONG_PARITY|EXPECT_FRAME_ERROR);
		#(CLK_PERIOD*10);
		ackFlagsTask();
		#(CLK_PERIOD*10);
		SendByte(8'hAA, ACKFLAGS);
	end
endtask

task tc06_basicOverrun;
	begin
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		SendByte(8'h55, 0);
		SendByte(8'hAA, EXPECT_OVERRUN);
	end
endtask

task tc07_abortedStart;
	begin
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		tbStartBitEn=0;
		serialIn=0;
		#(CLK_PERIOD*((tbBitTime/2)-1));
		serialIn=1;
		tbStartBitEn=1;
		#(CLK_PERIOD*(tbBitTime/2));
		SendByte(8'h55, ACKFLAGS);
	end
endtask

task tc08_stopBitViolation;
	begin
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByteEarlyExit(8'h00, ACKFLAGS);
		SendByte(8'h55, ACKFLAGS|EXPECT_FRAME_ERROR);
	end
endtask

task tc09_ackFlagsPollingFrameError;
	begin
		//uut.dataOut=8'b0;//to see the point where it becomes undefined when a rx started
		-> TrigResetDut;@(TrigResetDutRelease);
		#(CLK_PERIOD*2);
		SendByte(8'h00, ACKFLAGS);
		ackFlags=1;//stuck it to one to simulate intensive polling
		#(CLK_PERIOD*2);
		fork
			SendByte(8'h55, WRONG_PARITY|EXPECT_FRAME_ERROR);
			begin
				wait(frameErrorFlag===1);//check that frameErrorFlag is set even if ackFlags is set continuously
				#1;
				ackFlagsDone=1;//set ackFlagsDone to avoid to get dummy error due to the check within SendByte
			end
		join
		ackFlags=0;
	end
endtask

	/*always 
		#1	tbClock =  ! tbClock;*/
	always
		#(CLK_PERIOD/2) clk =  ! clk;
		
	always @(posedge clk) begin
		tbClockCounter = tbClockCounter + 1;
		if(implMismatch)
			tbError=tbError+1;
	end


reg tbIsRx;
always @(posedge clk) begin
	case({run, startBit})
		2'bx0:	tbIsRx<=1'b0;
		2'b0x:	tbIsRx<=1'b0;
		2'b00:	tbIsRx<=1'b0;
		2'b01:	tbIsRx<=1'b1;
		2'b10:	tbIsRx<=1'b1;
		2'bx1:	tbIsRx<=1'b1;
		2'b1x:	tbIsRx<=1'b1;
		2'b11:	begin
			tbError=tbError+1;
			$display("Error %d: run & StartBit are set simultaneously during clock rising edge",tbError);
		end
	endcase
end

reg lateAckFlagsEnable;
initial
	lateAckFlagsEnable=0;

always @(posedge SendByteStart) begin:LATE_ACKFLAGS
	if(lateAckFlagsEnable) begin
		#(CLK_PERIOD*(tbBitTime-1));
		//#(CLK_PERIOD);//to test it is really the latest cycle to ack the flags
		ackFlagsTask();
	end
end


function  computeParity;
input [7:0] data;
integer parity;
begin
	parity = 0;
	parity = ^data;
	parity = parity  ^ PARITY ^ 1;
	computeParity = parity;
end
endfunction

integer tbStartBitTimeSampler;
initial
forever begin
	@ (posedge startBit);
	if(tbStartBitEn && (1===startBit)) begin //ignore posedge from 0 to x.
		tbStartBitTimeSampler = tbClockCounter;
		tbByteClockCounter=0;
		tbLastStartBit=startBit;
		fork
			begin
				#(CLK_PERIOD*tbBitTime);
				tbStartBitTime=tbStartBitTimeSampler;
			end
			for(tbByteClockCounter=0;tbByteClockCounter<tbByteTime;tbByteClockCounter=tbByteClockCounter+1) begin
				@ (posedge clk);
				if((tbLastStartBit ==0) && (startBit == 1)) begin //this is to handle early start bit (happens before end of previous byte)
					$display("Early start bit (%d)",tbClockCounter);
					if(tbClockCounter-tbStartBitTime < tbByteMinTime) begin //frame error case
						if(frameErrorFlag != 1) begin
							tbError=tbError+1;
							$display("Error %d: start bit too early but frameErrorFlag is not set",tbError);
						end
					end else begin
						if(frameErrorFlag != 0) begin
							tbError=tbError+1;
							$display("Error %d: start bit within tolerated advance but frameErrorFlag is set",tbError);
						end
					end
					tbStartBitTime = tbClockCounter;
					tbByteClockCounter=0;
				end
				tbLastStartBit=startBit;
			end
		join
	end
end
initial
forever begin
	@ (negedge run);
	if(0===run) begin //ignore negedge from 1 to x.
		tbRunBitFallTime = tbClockCounter;
		if(tbRunBitFallTime-tbStartBitTime < tbByteMinTime) begin
			tbError=tbError+1;
			$display("Error %d: tbRunBitFallTime-tbStartBitTime =%d, >= %d was expected",tbError, tbRunBitFallTime-tbStartBitTime, tbByteMinTime );
		end
		if(tbRunBitFallTime-tbStartBitTime > tbByteTime) begin
			tbError=tbError+1;
			$display("Error %d: tbRunBitFallTime-tbStartBitTime =%d, <=%d was expected",tbError, tbRunBitFallTime-tbStartBitTime, tbByteTime );
		end
	end
end
initial
forever begin
	wait(dataOutReadyFlag===1);
	ackFlagsDone=0;
	wait(dataOutReadyFlag===0);
end	

reg [7:0] latchedDataOut;
integer tbdataOutReadyBitTime;
integer tbdataOutReadyBitMinTime,tbdataOutReadyBitMaxTime;
initial
forever begin
	@ (posedge dataOutReadyFlag);
	if(1===dataOutReadyFlag) begin //ignore posedge from 0 to x.
		latchedDataOut<=dataOut;
		tbdataOutReadyBitTime = tbClockCounter;
		if(tbdataOutReadyBitTime-tbStartBitTime < tbdataOutReadyBitMinTime) begin
			tbError=tbError+1;
			$display("Error %d: tbdataOutReadyBitTime-tbStartBitTime =%d, >= %d was expected",tbError, tbdataOutReadyBitTime-tbStartBitTime, tbdataOutReadyBitMinTime );
		end
		if(tbdataOutReadyBitTime-tbStartBitTime > tbdataOutReadyBitMaxTime) begin
			tbError=tbError+1;
			$display("Error %d: tbdataOutReadyBitTime-tbStartBitTime =%d, <=%d was expected",tbError, tbdataOutReadyBitTime-tbStartBitTime, tbdataOutReadyBitMaxTime );
		end
	end
end

reg SendByteStart;
task SendByte;
  input [7:0] data;
  input [3:0] flags;
  begin
	SendByteEarlyExit(data,flags);
	#(CLK_PERIOD*(tbBitTime-3));
	end
endtask
task SendByteEarlyExit;
  input [7:0] data;
  input [3:0] flags;
  reg wrongParity;
  reg ackFlagsWhenReady;
  reg expectOverrunError;
  reg expectFrameError;
  reg [7:0] initialData;
  begin
		{wrongParity,ackFlagsWhenReady,expectOverrunError,expectFrameError}=flags;
		initialData=data;
		serialIn=0;//start bit
		fork
			begin
				SendByteStart=1;
				#1;
				SendByteStart=0;
			end
			#(CLK_PERIOD*tbBitTime);
		join
		serialIn=data[0];//0
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[1];//1
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[2];//2
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[3];//3
		`ifdef TEST_TB
			force uut.internalIn=1;
		`endif
		#(CLK_PERIOD*tbBitTime);
		`ifdef TEST_TB
			release uut.internalIn;
		`endif
		serialIn=data[4];//4
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[5];//5
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[6];//6
		#(CLK_PERIOD*tbBitTime);
		serialIn=data[7];//7
		#(CLK_PERIOD*tbBitTime);
		if(wrongParity)
			serialIn=~computeParity(data);//wrong parity
		else
			serialIn=computeParity(data);//parity
		#(CLK_PERIOD*tbBitTime);
		if(expectOverrunError & ~ackFlagsDone) begin
			if(overrunErrorFlag != 1) begin
				tbError=tbError+1;
				$display("Error %d: Overrun error expected but overrunErrorFlag is not set",tbError);
			end else if(data!=initialData) begin
				tbError=tbError+1;
				$display("Error %d: Data changed despite overrun condition",tbError);
			end
		end
		if(expectFrameError & ~ackFlagsDone) begin
			if(frameErrorFlag != 1) begin
				tbError=tbError+1;
				$display("Error %d: Frame error expected but frameErrorFlag is not set",tbError);
			end
			serialIn=1;
			#(CLK_PERIOD*tbBitTime*12);//make sure the receiver return to idle state
		end
		if(~expectOverrunError & ~expectFrameError) begin
			if(dataOut!=latchedDataOut)begin
				tbError=tbError+1;
				$display("Error %d: latchedDataOut mismatch-->dataOut changed after dataOutReadyFlag edge, dataOut=0x%x, latchedDataOut=0x%x",tbError, dataOut, latchedDataOut);
			end
			if(data!==dataOut)begin
				tbError=tbError+1;
				$display("Error %d: dataOut mismatch, dataOut=0x%x, 0x%x was expected",tbError, dataOut, data);
			end
			if(~dataOutReadyFlag & ~ackFlagsDone)begin
				tbError=tbError+1;
				$display("Error %d: dataOutReadyFlag is not set",tbError);
			end
			if(frameErrorFlag|overrunErrorFlag)begin
				tbError=tbError+1;
				$display("Error %d: frameErrorFlag|overrunErrorFlag not expected but set",tbError);
			end
		end
		serialIn=1;//stop1
		fork
			if(ackFlagsWhenReady) begin
				#(CLK_PERIOD*1);
				ackFlagsTask();
			end else
				#(CLK_PERIOD*3);
		join
  end
endtask

      
endmodule
`default_nettype wire

