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


module accumulatorMUX (accMuxSel, immData, aluOut 
								`ifdef timerAndCounter_peripheral
								, tcLoadIn, tcAccIn
								`endif
								`ifdef UART_peripheral
								, uartDataIn, uartStatIn
								`endif
								, accMuxOut
								);

	input [`accMuxSelLen-1:0]	accMuxSel;
	input [`immDataLen-1:0]		immData;
	input	[7:0]	aluOut;
	`ifdef timerAndCounter_peripheral
	input [7:0] tcLoadIn, tcAccIn;
	`endif
	`ifdef UART_peripheral
	input [7:0] uartDataIn, uartStatIn;
	`endif
	
	output [7:0]	accMuxOut;
	
	reg [7:0]	accMuxOut;
	
	
	always @ *
	begin
	
		case (accMuxSel)
		
			`accMuxSelImmData	:	begin
										accMuxOut = immData;
										end
								
			`accMuxSelAluOut	:	begin
										accMuxOut = aluOut;
										end
			
			`ifdef timerAndCounter_peripheral
			`accMuxSelTcLoad	:	begin
										accMuxOut = tcLoadIn;
										end
			
			`accMuxSelTcAcc	:	begin
										accMuxOut = tcAccIn;
										end
			`endif
			
			`ifdef UART_peripheral
			`accMuxSelUartData	:		begin
										accMuxOut = uartDataIn;
										end
										
			`accMuxSelUartStat	:		begin
										accMuxOut = uartStatIn;
										end
			`endif
			
			
			
			default		:	begin
								accMuxOut = 8'bzzzzzzzz;
								end
								
		endcase
	
	end


endmodule
