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


module uartTrans (clk, reset, sTick, txDoneTick, din, tx, txStart);

		parameter dataBits = `dataBits;
		parameter sbTick = `sbTick;
		
		input [dataBits-1 :0] din;
		input clk, reset, sTick, txStart;
		output tx, txDoneTick;
		
		reg txDoneTick;
		
/*
should be impleneted as a 4-state FSM : idle, start, data, stop;

*/

	localparam [1:0] idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
	
		reg [1:0] stateReg, stateNext;	// current and next states
		reg [3:0] sReg, sNext;		//	counter
		reg [2:0] nReg, nNext;		// counter
		reg [7:0] bReg, bNext;		// perhaps keeps data to be sent
		reg		 txReg, txNext;	// current bit being transferred
		
		
		//	reset and non-reset conditions:
		
		always @ (posedge clk or posedge reset)
		begin
			if (reset)
			begin
				stateReg <= idle;
				sReg <= 1'b0;
				bReg <= 1'b0;
				nReg <= 1'b0;
				txReg <= 1'b1;
			end	// end if
			
			else
			begin
				stateReg <= stateNext;
				sReg <= sNext;
				bReg <= bNext;
				nReg <= nNext;
				txReg <= txNext;
			end	// end else
		
		end	// end always
		
		// FSM:
		
		always @ *
		begin
				stateNext = stateReg;
				sNext = sReg;
				bNext = bReg;
				nNext = nReg;
				txNext = txReg;
				
				txDoneTick = 1'b0;		// not done yet!
				
			case	(stateReg)
			
				idle	:	begin
								txNext = 1'b1;	// start bit '0'; thus, send '1' in idle
								
								if (txStart)
								begin
									txDoneTick = 1'b1;	// generate rd for fifo **
									stateNext = start;	// should go into start state
									sNext = 0;
								end	// end if txStart
							// in idle state unless txStart...
							end	// end idle case
							
				start	:	begin
								txNext = 0;
								txDoneTick = 1'b0;		// **
								bNext = din;		// take din into bReg
								if (sTick)
									if (sReg == 15)
									begin
										stateNext = data;
										sNext = 1'b0;
										nNext = 1'b0;
									end	// end if sReg==15
									
									else
										sNext = sReg + 1;	// keep incrementing sNext (sReg)
										// sReg = sNext on each clk edge !!
							end	// end start case
							
				data	:	begin
								txNext = bReg[0];	// keep sending LSB of bReg
								
								if (sTick)
									if (sReg == 15)
									begin
										sNext = 0;	// reset counter
										bNext = bReg >> 1;	// shift word to be sent
										
										if (nReg == (dataBits-1))
											stateNext = stop;
										else
											nNext = nReg +1;
									end	// end if sReg==15
								else
									sNext = sReg + 1;
				
							end	// end data state
							
				stop	:	begin
								txNext = 1'b1;
								
								if (sTick)
									if (sReg == sbTick-1)
									begin
										stateNext = idle;
										//txDoneTick = 1'b1; it's working as read signal to
										// fifo, so, used at starting . . .
									end //end if sReg==15
									else
										sNext = sReg + 1;
							end	// end stop state
			
			endcase
		
		end	// end always combinatorial

		
		// output bit-stream
		
		assign tx = txReg;

endmodule
