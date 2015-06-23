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


module uartRec(clk, reset, sTick, rx, rxDoneTick, dOut);

		parameter dataBits = `dataBits;
		parameter sbTick = `sbTick;
		
		input clk, reset, sTick, rx;
		output rxDoneTick;
		output [dataBits-1:0] dOut;
		
		reg rxDoneTick;
		// states:
		
	localparam idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
	
		reg [1:0] stateReg, stateNext;	// current and next states
		reg [3:0] sReg, sNext;		//	counter
		reg [2:0] nReg, nNext;		// counter
		reg [7:0] bReg, bNext;		// data recieved in this..
		
		
		always @ (posedge clk or posedge reset)
		begin
			if (reset)
			begin
				stateReg <= idle;
				sReg <= 1'b0;
				bReg <= 1'b0;
				nReg <= 1'b0;
			end	// end if
			
			else
			begin
				stateReg <= stateNext;
				sReg <= sNext;
				bReg <= bNext;
				nReg <= nNext;
			end	// end else
		
		end	// end always
		
		
		
		// FSM next state logic:
		
		always @ *
		begin
		
				stateNext = stateReg;
				sNext = sReg;
				bNext = bReg;
				nNext = nReg;
				rxDoneTick = 1'b0;
				
			case (stateReg)
			
			idle	:	if (~rx)
						begin
							stateNext = start;	// start when rx is activated
							sNext = 0;	// initialize sampling counter
						end	// end if rx
						
			start	:	if (sTick)
							if (sReg == 7)
							begin
								stateNext = data;		// at middle of oversampled start
													// bit, go to data state
								sNext = 0;
								nNext = 0;
							end	// end if sReg==7
							
							else
								sNext = sReg + 1;	// otherwise keep increment sReg upto 7
			
			data	:	if (sTick)
							if (sReg == 15)	// if reached middle of next bit
							begin
								sNext = 0;	// reset counter
								bNext = {rx, bReg[7:1]};	// LSB first, and the
														//data recieved in bReg
								if (nReg == (dataBits-1))	// if all data recvd,
									stateNext = stop;	// go to stop bit(s) state
								else
									nNext = nReg + 1;
							end	// end if sReg==15
							
							else
								sNext = sReg + 1;	// otherwise keep increment sReg upto 15
							
			stop	:	if (sTick)
							if (sReg == (sbTick-1))
							begin
								stateNext = idle;		// done reception, go to idle state
								rxDoneTick = 1'b1;	// raise done tick!
							end	// end if sReg==sbTick-1
							
							else
								sNext = sReg + 1;		// otherwise keep increment sReg 
															//upto (sbTick-1)
			endcase
		
		end	// end always combinatorial
		
		
		// recvd data output
		
		assign dOut = bReg;


endmodule
