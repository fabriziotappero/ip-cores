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


module outputReg (reset, outputRw, outputRwAddr, outputWriteIn, outputReadOut, outputs);

	input reset, outputRw;
	input [`outputAddrLen-1:0] outputRwAddr;
	input outputWriteIn;
	
	output outputReadOut;
	output wire [`outputNumber-1:0] outputs;
	
	reg outputReadOut;
//	reg [`outputNumber-1:0] outputs = 0;
	reg [`outputNumber-1 :0] outputReg = 0;
	
	
	
	always @ (reset or outputRw or outputRwAddr or outputWriteIn or outputReg)
	begin
	
		if (reset)
		begin
			outputReadOut = 1'bz;
			$write ("\nmodule outputRegister is reset	");
		end
		
		else
		begin
		
			if (outputRw)	// read output status
			begin
				outputReadOut = outputReg[outputRwAddr];
//				$write ("\nreading output register	:	module outputRegister	");
			end
			else				// write operation
			begin
				outputReg[outputRwAddr] = outputWriteIn;
				$write ("\nwriting to the output register	:	module outputRegister	");
			end
		
		end
	
	end
	
	assign outputs = outputReg;


endmodule
