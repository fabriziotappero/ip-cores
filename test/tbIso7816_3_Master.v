/*
Author: Sebastien Riou (acapola)
Creation date: 22:16:42 01/10/2011 

$LastChangedDate: 2011-04-18 12:57:36 +0200 (Mon, 18 Apr 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 20 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/tbIso7816_3_Master.v $				 

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

module tbIso7816_3_Master;
parameter CLK_PERIOD = 10;//should be %2
	// Inputs
	reg nReset;
	reg clk;
	reg [15:0] clkPerCycle;
	reg startActivation;
	reg startDeactivation;
	reg [7:0] dataIn;
	reg nWeDataIn;
	reg [12:0] cyclesPerEtu;
	reg nCsDataOut;
	reg nCsStatusOut;

	// Outputs
	wire [7:0] dataOut;
	wire [7:0] statusOut;
	wire isActivated;
	wire useIndirectConvention;
	wire tsError;
	wire tsReceived;
	wire atrIsEarly;
	wire atrIsLate;
	wire isoClk;
	wire isoReset;
	wire isoVdd;
	
	//probe outputs
	wire probe_termMon;
	wire probe_cardMon;

	// Bidirs
	wire isoSioTerm;
	wire isoSioCard;

wire isTxTerm;
reg isoSioInTerm;
wire isoSioOutTerm;
assign isoSioTerm = isTx ? isoSioOutTerm : 1'bz;
pullup(isoSioTerm);
always @(*) isoSioInTerm = isoSioTerm;

wire COM_statusOut=statusOut;
wire COM_clk=isoClk;
integer COM_errorCnt;

wire txRun,txPending, rxRun, rxStartBit, isTx, overrunErrorFlag, frameErrorFlag, bufferFull;
assign {txRun, txPending, rxRun, rxStartBit, isTx, overrunErrorFlag, frameErrorFlag, bufferFull} = statusOut;

`include "ComDriverTasks.v"


wire [3:0] spy_fiCode;
wire [3:0] spy_diCode;
wire [12:0] spy_fi;
wire [7:0] spy_di;
wire [12:0] spy_cyclesPerEtu;
wire [7:0] spy_fMax;
wire spy_isActivated,spy_tsReceived,spy_tsError;
wire spy_useIndirectConvention,spy_atrIsEarly,spy_atrIsLate;
wire [3:0] spy_atrK;
wire spy_atrHasTck,spy_atrCompleted; 
wire spy_useT0,spy_useT1,spy_useT15,spy_waitCardTx,spy_waitTermTx,spy_cardTx,spy_termTx,spy_guardTime; 
wire spy_overrunError,spy_frameError;
wire spy_comOnGoing;
wire [7:0] spy_lastByte;
wire [31:0] spy_bytesCnt;

	// Instantiate the Unit Under Test (UUT)
	Iso7816_3_Master uut (
		.nReset(nReset), 
		.clk(clk), 
		.clkPerCycle(clkPerCycle), 
		.startActivation(startActivation), 
		.startDeactivation(startDeactivation), 
		.dataIn(dataIn), 
		.nWeDataIn(nWeDataIn), 
		.cyclesPerEtu(cyclesPerEtu), 
		.dataOut(dataOut), 
		.nCsDataOut(nCsDataOut), 
		.statusOut(statusOut), 
		.nCsStatusOut(nCsStatusOut), 
		.isActivated(isActivated), 
		.useIndirectConvention(useIndirectConvention), 
		.tsError(tsError),
		.tsReceived(tsReceived),
		.atrIsEarly(atrIsEarly), 
		.atrIsLate(atrIsLate), 
		.isTx(isTxTerm),
		.isoSioIn(isoSioInTerm),
		.isoSioOut(isoSioOutTerm),
		.isoClk(isoClk), 
		.isoReset(isoReset), 
		.isoVdd(isoVdd)
	);
	
	DummyCard card(
		.isoReset(isoReset),
		.isoClk(isoClk),
		.isoVdd(isoVdd),
		.isoSio(isoSioCard)
	);
	
	Iso7816_directionProbe probe(
		.isoSioTerm(isoSioTerm),
		.isoSioCard(isoSioCard),
		.termMon(probe_termMon),
		.cardMon(probe_cardMon)
	);

	Iso7816_3_t0_analyzer spy (
    .nReset(nReset), 
    .clk(clk), 
    .clkPerCycle(clkPerCycle[0]), 
    .isoReset(isoReset), 
    .isoClk(isoClk), 
    .isoVdd(isoVdd), 
    .isoSioTerm(probe_termMon), 
    .isoSioCard(probe_cardMon), 
	 .useDirectionProbe(1'b1),
    .fiCode(spy_fiCode), 
    .diCode(spy_diCode), 
    .fi(spy_fi), 
    .di(spy_di), 
    .cyclesPerEtu(spy_cyclesPerEtu), 
    .fMax(spy_fMax), 
    .isActivated(spy_isActivated), 
    .tsReceived(spy_tsReceived), 
    .tsError(spy_tsError), 
    .useIndirectConvention(spy_useIndirectConvention), 
    .atrIsEarly(spy_atrIsEarly), 
    .atrIsLate(spy_atrIsLate), 
    .atrK(spy_atrK), 
    .atrHasTck(spy_atrHasTck), 
    .atrCompleted(spy_atrCompleted), 
    .useT0(spy_useT0), 
    .useT1(spy_useT1), 
    .useT15(spy_useT15), 
    .waitCardTx(spy_waitCardTx), 
    .waitTermTx(spy_waitTermTx), 
    .cardTx(spy_cardTx), 
    .termTx(spy_termTx), 
    .guardTime(spy_guardTime), 
    .overrunError(spy_overrunError), 
    .frameError(spy_frameError), 
    .comOnGoing(spy_comOnGoing),
	 .lastByte(spy_lastByte),
    .bytesCnt(spy_bytesCnt)
    );

	
	integer tbErrorCnt;
	reg tbTestSequenceDone;
	initial begin
		// Initialize Inputs
		tbErrorCnt=0;
		COM_errorCnt=0;
		nReset = 0;
		clk = 0;
		clkPerCycle = 0;
		startActivation = 0;
		startDeactivation = 0;
		dataIn = 0;
		nWeDataIn = 1'b1;
		cyclesPerEtu = 372-1;
		nCsDataOut = 1'b1;
		nCsStatusOut = 1'b1;

		// Wait 100 ns for global reset to finish
		#100;
      nReset = 1;  
		// Add stimulus here
		#100
		startActivation = 1'b1;
		wait(isActivated);
		wait(tsReceived);
		if(tsError) begin
			$display("ERROR: ATR's TS is invalid");
			tbErrorCnt=tbErrorCnt+1;
		end
		if(atrIsEarly) begin
			$display("ERROR: ATR is early");
			tbErrorCnt=tbErrorCnt+1;
		end
		if(atrIsLate) begin
			$display("ERROR: ATR is late");
			tbErrorCnt=tbErrorCnt+1;
		end
		@(posedge clk);
		while((1'b0===spy_atrCompleted)||(txRun===1'b1)||(rxRun===1'b1)||(rxStartBit===1'b1)) begin
			while((1'b0===spy_atrCompleted)||(txRun===1'b1)||(rxRun===1'b1)||(rxStartBit===1'b1)) begin
				@(posedge clk);
			end
			@(posedge clk);
		end
		if(1'b1!==tbTestSequenceDone) begin
			$display("ERROR: Two cycle pause in communication detected, stop simulation, time=",$time);
			#(CLK_PERIOD*372*12);
			$finish;
		end
	end
	//T=0 tpdu stimuli
	reg [8*256:0] bytesFromCard;
	initial begin
		tbTestSequenceDone=1'b0;
		//receiveAndCheckHexBytes("3B00");
		receiveByte(bytesFromCard[7:0]);//3B or 3F, so we don't check (Master and Spy do)
		//receiveAndCheckHexBytes("9497801F42BABEBABE");
		receiveAndCheckHexBytes("90974020");
		//TODO: handle TCK-->receiveAndCheckHexBytes("9E 97 80 1F C7 80 31 E0 73 FE 21 1B 66 D0 00 28 24 01 00 0D");
		//receiveAndCheckHexBytes("9E 97 80 1F C7 80 31 E0 73 FE 21 1B 66 D0 00 28 24 01 00");
		sendHexBytes("FF109778");
		receiveAndCheckHexBytes("FF109778");
		cyclesPerEtu=8-1;
		//sendHexBytes("000C000001");
		//receiveAndCheckHexBytes("0C");
		//sendHexBytes("55");
		sendT0TpduLc("000C000004 CAFEBABE");//write buffer
		receiveAndCheckHexBytes("9000");
		
		sendT0TpduLc("00FC000000");//change convention for next ATR
		receiveAndCheckHexBytes("9000");
		
		sendT0TpduLeCheck("000A000004","CAFEBABE");//read buffer
		receiveAndCheckHexBytes("9000");
		
/*		//Reset not supported by the dummy card yet because we use "wait()" in Com tasks...
		wait(spy_comOnGoing===1'b0);
		wait(spy_guardTime===1'b0);
		
		startActivation = 1'b0;
		startDeactivation = 1'b1;
		cyclesPerEtu = 372-1;
		wait(1'b0===spy_isActivated);
		startDeactivation = 0;
		startActivation = 1'b1;
		
		receiveAndCheckHexBytes("3B 9E 97 80 1F C7 80 31 E0 73 FE 21 1B 66 D0 00 28 24 01 00");
		sendT0TpduLeCheck("000A000004","CAFEBABE");//read buffer
		receiveAndCheckHexBytes("9000");
*/		
		tbTestSequenceDone=1'b1;
		#(CLK_PERIOD*372*12);
		if(0===tbErrorCnt) $display("SUCCESS: test sequence completed.");
		$finish;
	end
	initial begin
		// timeout
		#10000000;  
      tbErrorCnt=tbErrorCnt+1;
      $display("ERROR: timeout expired");
      #10;
		$finish;
	end
	always
		#(CLK_PERIOD/2) clk =  ! clk;       
endmodule
`default_nettype wire

