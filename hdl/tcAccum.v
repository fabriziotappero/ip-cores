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


module tcAccum (tcAccumRead, tcAddr, tcAccumIn, tcAccumOut);

	input tcAccumRead;
	input [`tcAddrLen-1:0] tcAddr;
	input [(`tcAccLen*`tcNumbers)-1:0] tcAccumIn;
	
	output [`tcAccLen-1:0] tcAccumOut;
	
	wire [`tcAccLen-1:0] ACC_all [`tcNumbers-1:0];	// used in continuous assignment
	reg [`tcAccLen-1:0] tcAccumOut;
	
	
	always @ (posedge tcAccumRead)
	begin
		if (tcAccumRead)
		begin
			tcAccumOut = ACC_all[tcAddr];
			$write ("\nreading t/c accumulated value	: module tcAccum	");
		end
	end
	
	assign ACC_all[0] = tcAccumIn[`tcAccLen-1:0];
	assign ACC_all[1] = tcAccumIn[(`tcAccLen*2)-1:`tcAccLen];
	assign ACC_all[2] = tcAccumIn[(`tcAccLen*3)-1:(`tcAccLen*2)];
	assign ACC_all[3] = tcAccumIn[(`tcAccLen*4)-1:(`tcAccLen*3)];
	assign ACC_all[4] = tcAccumIn[(`tcAccLen*5)-1:(`tcAccLen*4)];
	assign ACC_all[5] = tcAccumIn[(`tcAccLen*6)-1:(`tcAccLen*5)];
	assign ACC_all[6] = tcAccumIn[(`tcAccLen*7)-1:(`tcAccLen*6)];
	assign ACC_all[7] = tcAccumIn[(`tcAccLen*8)-1:(`tcAccLen*7)];
//	assign ACC_all[8] = tcAccumIn[(`tcAccLen*9)-1:(`tcAccLen*8)];
//	assign ACC_all[9] = tcAccumIn[(`tcAccLen*10)-1:(`tcAccLen*9)];
//	assign ACC_all[10] = tcAccumIn[(`tcAccLen*11)-1:(`tcAccLen*10)];
//	assign ACC_all[11] = tcAccumIn[(`tcAccLen*12)-1:(`tcAccLen*11)];
//	assign ACC_all[12] = tcAccumIn[(`tcAccLen*13)-1:(`tcAccLen*12)];
//	assign ACC_all[13] = tcAccumIn[(`tcAccLen*14)-1:(`tcAccLen*13)];
//	assign ACC_all[14] = tcAccumIn[(`tcAccLen*15)-1:(`tcAccLen*14)];
//	assign ACC_all[15] = tcAccumIn[(`tcAccLen*16)-1:(`tcAccLen*15)];
	

endmodule
