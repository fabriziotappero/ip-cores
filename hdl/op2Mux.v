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


module op2Mux (op2MuxSel, inputReadOut, outputReadOut, bitOut, byteOut, op2MuxOut);

	input [`op2MuxSelLen-1:0] op2MuxSel;
	input inputReadOut, outputReadOut, bitOut;
	input [7:0] byteOut;
	
	output [7:0] op2MuxOut;
	
	reg [7:0] op2MuxOut = 0;
	
	
	always @ (op2MuxSel)
	begin
	
		case (op2MuxSel)
		
		`op2MuxSelInput	:	begin
								op2MuxOut = {7'b0, inputReadOut};
								end
								
		`op2MuxSelOutput	:	begin
								op2MuxOut = {7'b0, outputReadOut};
								end
								
		`op2MuxSelBitRam	:	begin
								op2MuxOut = {7'b0, bitOut};
								end
								
		`op2MuxSelByteRam	:	begin
								op2MuxOut = byteOut;
								end
								
								
		default			:	begin
								op2MuxOut = op2MuxOut;
								end
								
		endcase
		
	end	// end always


endmodule
