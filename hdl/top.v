////////////////////////////////////////////////////////////////////////////////////////////////
////                                                              							////
////                                                              							////
////  	This file is part of the project                 									////
////	"instruction_list_pipelined_processor_with_peripherals"								////
////                                                              							////
////  http://opencores.org/project,instruction_list_pipelined_processor_with_peripherals	////
////                                                              							////
////                                                              							////
//// 				 Author:                                                  				////
////      			- Mahesh Sukhdeo Palve													////
////																						////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////																						////
//// 											                 							////
////                                                              							////
//// 					This source file may be used and distributed without         		////
//// 					restriction provided that this copyright statement is not    		////
//// 					removed from the file and that any derivative work contains  		////
//// 					the original copyright notice and the associated disclaimer. 		////
////                                                              							////
//// 					This source file is free software; you can redistribute it   		////
//// 					and/or modify it under the terms of the GNU Lesser General   		////
//// 					Public License as published by the Free Software Foundation; 		////
////					either version 2.1 of the License, or (at your option) any   		////
//// 					later version.                                               		////
////                                                             							////
//// 					This source is distributed in the hope that it will be       		////
//// 					useful, but WITHOUT ANY WARRANTY; without even the implied   		////
//// 					warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      		////
//// 					PURPOSE.  See the GNU Lesser General Public License for more 		////
//// 					details.                                                     		////
////                                                              							////
//// 					You should have received a copy of the GNU Lesser General    		////
//// 					Public License along with this source; if not, download it   		////
//// 					from http://www.opencores.org/lgpl.shtml                     		////
////                                                              							////
////////////////////////////////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "defines.v"

module top(clk, reset, IN, OUT

				`ifdef UART_peripheral
					, rx, tx
				`endif
				
				);


	input	clk,reset;
	input [`inputNumber-1:0] IN;
	output [`outputNumber-1:0] OUT;
	
	`ifdef UART_peripheral
	input rx;
	output tx;
	`endif


// wires (interconnects) of execution unit

	wire	[`instAddrLen-1:0]			pcOut;
	wire	[`instOpCodeLen+`instFieldLen-1:0] romOut;
	wire	[`instOpCodeLen-1:0]	instOpCode;
	wire	[`instFieldLen-1:0] 	instField;
	
	wire	[7:0]		accMuxOut;
	wire	[7:0]		accOut;
	wire	[7:0]		op2MuxOut;
	wire	[7:0]		aluOut;
	
	wire	bitNegatorRamOut, bitOut;
	wire	[7:0]	byteNegatorRamOut, byteOut;
	
	wire	inputReadOutData, outputReadOut;
	
	wire branchOutc;
	wire [`accMuxSelLen-1:0]	accMuxSelOutc;
	wire accEnOutc;
	wire [`op2MuxSelLen-1:0]	op2MuxSelOutc;
	wire aluEnc;
	wire [`aluOpcodeLen-1:0] aluOpcodeOutc;
	wire bitRamEnOutc, bitRamRwOutc, byteRamEnOutc, byteRamRwOutc;
	wire outputRwOutc;
	`ifdef timerAndCounter_peripheral
	wire entypeEnOutc, tcAccReadOutc, tcResetEnOutc, tcPresetEnOutc;
	`endif
	`ifdef UART_peripheral
	wire uartReadOutc, uartWriteOutc;
	wire [7:0] uartDataOut;
	wire rxEmpty, txFull;
	`endif

	wire branchOut;
	wire [`accMuxSelLen-1:0]	accMuxSelOut;
	wire accEnOut;
	wire [`op2MuxSelLen-1:0]	op2MuxSelOut;
	wire aluEn;
	wire [`aluOpcodeLen-1:0] aluOpcodeOut;
	wire bitRamEnOut, bitRamRwOut, byteRamEnOut, byteRamRwOut;
	wire outputRwOut;
	`ifdef timerAndCounter_peripheral
	wire entypeEnOut, tcAccReadOut, tcResetEnOut, tcPresetEnOut;
	`endif
	`ifdef UART_peripheral
	wire uartReadOut, uartWriteOut;
	`endif
	
	
// wires (interconnects) of timer & counter

`ifdef timerAndCounter_peripheral

	wire	[(`tcNumbers*`tcPresetLen)-1:0] presetWires;
	wire	[7:0] tcAccOut;
	wire	[7:0] tcLoadOut;
	wire [`tcNumbers-1:0] enWires;
	wire [`tcNumbers-1:0] resetWires;
	wire [`tcNumbers-1:0] dnWires, ttWires, cuWires, cdWires;
	wire [(`tcNumbers*2)-1:0] typeWires;
	wire [(`tcNumbers*`tcAccLen)-1:0] tcAccWires;

`endif


	wire clk_d, clk_t;
	reg [10:0] cnt = 0;
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			cnt =0;
		end
		else
		begin
			cnt = cnt + 1'b1;
		end
	end
	
	assign clk_d = cnt[0];
	assign clk_t = cnt[10];

	

//-------- Fetch Unit Module Instances
// all necessary
	
	wire branch = (~romOut[14] & ~romOut[13] & ~romOut[12] & ~romOut[11] & ~romOut[10]) | ((romOut[10] & ~romOut[13] & ~romOut[12] & ~romOut[11] & ~romOut[14]) & accOut[0]);				// END = 00000; JMP = 00001

	pgmCounter		ProgramCounter (clk_d, reset, branch, romOut[9:0], pcOut);
	
	
// instruction ROM is declared using xilinx primitive
//	RAMB16_S18 rom ( .DI(),
//				 .DIP(),
//				 .ADDR(pcOut),
//				 .EN(1'b1),
//				 .WE(),   
//				 .SSR(1'b0),
//				 .CLK(clk_d),
//				 .DO(romOut),
//				 .DOP());

	rom	CodeMem (clk_d, pcOut, romOut);

// pipeline register

	wire	[`instOpCodeLen-1:0] instOpCode1;
	wire	[`instFieldLen-1:0] instField1;
	wire	[`instFieldLen-1:0] instField2;
	
	ppReg1	PipeLine_Reg1 (clk_d, romOut[`instLen-1:`instLen-`instOpCodeLen], romOut[`instFieldLen-1:0], instOpCode1, instField1);


//-------- Control Unit Module Instance

	controlUnit		CONTROL_UNIT (clk, reset, instOpCode1, instField2[8:7],
									accMuxSelOutc, accEnOutc, op2MuxSelOutc, aluEnc, aluOpcodeOutc, bitRamEnOutc,
									bitRamRwOutc, byteRamEnOutc, byteRamRwOutc, outputRwOutc
								`ifdef timerAndCounter_peripheral
								, entypeEnOutc, tcAccReadOutc, tcResetEnOutc, tcPresetEnOutc
								`endif
								`ifdef UART_peripheral
								, uartReadOutc, uartWriteOutcc
								`endif
											
											);



// pipeline register

	

	ppReg2	PipeLine_Reg2 (clk,
									accMuxSelOutc, accEnOutc, op2MuxSelOutc, aluEnc, aluOpcodeOutc, bitRamEnOutc,
									bitRamRwOutc, byteRamEnOutc, byteRamRwOutc, outputRwOutc
								`ifdef timerAndCounter_peripheral
								, entypeEnOutc, tcAccReadOutc, tcResetEnOutc, tcPresetEnOutc
								`endif
								`ifdef UART_peripheral
								, uartReadOutc, uartWriteOutcc
								`endif
								, instField1
									
									,accMuxSelOut, accEnOut, op2MuxSelOut, aluEn, aluOpcodeOut,
									bitRamEnOut, bitRamRwOut, byteRamEnOut, byteRamRwOut,
									outputRwOut
									
									`ifdef timerAndCounter_peripheral
										, entypeEnOut, tcAccReadOut, tcResetEnOut, tcPresetEnOut
									`endif
									
									`ifdef UART_peripheral
										, uartReadOut, uartWriteOut
									`endif
									
									, instField2
								);


//-------- Execute Unit Modules Instances
// all necessary


	
	
	accumulatorMUX		accMUX1	(accMuxSelOut, instField2[7:0], aluOut 
										`ifdef timerAndCounter_peripheral
										, tcLoadOut, tcAccOut
										`endif
										`ifdef UART_peripheral
										, uartDataOut, {rxEmpty, txFull}
										`endif
										, accMuxOut
										);

	
	accumulator			acc		(accMuxOut, accEnOut, accOut);

	op2Mux				op2MUX1	(op2MuxSelOut, inputReadOutData, outputReadOut, bitOut, byteOut, op2MuxOut);
	
	wire [7:0] op2Out;
	
	byteNegator			byteNegatorForOp2Mux (op2MuxOut, instField2[9], op2Out);
	
	alu					arithLogicUnit	(aluOpcodeOut, accOut, op2Out, aluEn, aluOut, carryOut);
	
	wire bitIn;
	
	bitNegator			bitNegatorForBitRam	(accOut[0], instField2[9], bitIn);
	
	bitRam				RAM_Bit	(clk, reset, bitRamEnOut, bitRamRwOut, bitIn, instField2[6:0], bitOut);
	
	wire [7:0] byteIn;
	
	byteNegator			byteNegatorForByteRam	(accOut, instField2[9], byteIn);
	
	byteRam				RAM_Byte	(clk, reset, byteRamEnOut, byteRamRwOut, byteIn, instField2[6:0], byteOut);
	
	inputRegister		inputStorage	(IN, instField2[6:0], inputReadOutData);
	
	wire outIn;
	
	bitNegator			bitNegatorForOutReg	(accOut[0], instField2[9], outIn);
	
	outputReg			outputStorage	(reset, outputRwOut, instField2[6:0], outIn, outputReadOut, OUT);
	

//---------- Timer & Counter Modules
// optional

`ifdef timerAndCounter_peripheral


	tcEnableAndType	tcEnableAndTypeModule(entypeEnOut, accOut[0], instField2[5:4], instField2[3:0], enWires, typeWires);
	
	tcAccum				tcAccumModule(tcAccReadOut, instField2[3:0], tcAccWires, tcAccOut);
	
	tcReset				tcResetModule(tcResetEnOut, accOut[0], instField2[3:0], resetWires);
	
	tcPreset				tcPresetModule(tcPresetEnOut, accOut, instField2[3:0], presetWires);
	
	tcLoad				tcLoadModule(instField2[3:0], dnWires, ttWires, cuWires, cdWires, tcLoadOut);
	
	timer					timer0	(clk_t, enWires[0], resetWires[0], typeWires[1:0], presetWires[7:0], dnWires[0], ttWires[0], tcAccWires[7:0]);
	
	timer					timer1	(clk_t, enWires[1], resetWires[1], typeWires[3:2], presetWires[15:8], dnWires[1], ttWires[1], tcAccWires[15:8]);
	
	timer					timer2	(clk_t, enWires[2], resetWires[2], typeWires[5:4], presetWires[23:16], dnWires[2], ttWires[2], tcAccWires[23:16]);
	
	timer					timer3	(clk_t, enWires[3], resetWires[3], typeWires[7:6], presetWires[31:24], dnWires[3], ttWires[3], tcAccWires[31:24]);
	
	counter				counter0	(enWires[4], resetWires[4], presetWires[39:32], typeWires[9:8], dnWires[4], cuWires[0], cdWires[0], tcAccWires[39:32]);
	
	counter				counter1	(enWires[5], resetWires[5], presetWires[47:40], typeWires[11:10], dnWires[5], cuWires[1], cdWires[1], tcAccWires[47:40]);
	
	counter				counter2	(enWires[6], resetWires[6], presetWires[55:48], typeWires[13:12], dnWires[6], cuWires[2], cdWires[2], tcAccWires[55:48]);
	
	counter				counter3	(enWires[7], resetWires[7], presetWires[63:56], typeWires[15:14], dnWires[7], cuWires[3], cdWires[3], tcAccWires[63:56]);

`endif

//---------- UART Modules
// optional

`ifdef UART_peripheral

	wire	brgOut;
	wire txDoneTick, txStart;
	wire rxDoneTick;
	wire [7:0] recFifoData, transFifoData;
	

	uartTrans	UART_TRANSMITTER (clk, reset, brgOut, txDoneTick, transFifoData, tx, ~txStart);
	
	uartRec		UART_RECIEVER (clk, reset, brgOut, rx, rxDoneTick, recFifoData);
	
	uartBrg		UART_BitRateGenerator (.clk(clk), .reset(reset), .outp(brgOut));
	
	uartFifo		UART_TRANS_FIFO (clk, reset, accOut, transFifoData, uartWriteOut, txDoneTick, txFull, txStart);
	
	uartFifo		UART_REC_FIFO (clk, reset, recFifoData, uartDataOut, rxDoneTick, uartReadOut, rxFull, rxEmpty);

`endif

endmodule
