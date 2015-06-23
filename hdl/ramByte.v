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

module byteRam (clk, reset, byteRamEn, byteRamRw, byteRamIn, byteRamAddr, byteRamOut);

		input clk, reset, byteRamEn, byteRamRw;
		input [`byteRamLen-1:0] byteRamIn;
		input [`byteRamAddrLen-1:0] byteRamAddr;
		
		output [`byteRamLen-1:0] byteRamOut;
		
		reg [`byteRamLen-1:0] byteRam [`byteRamDepth-1:0];
		reg [`byteRamLen-1:0] byteRamOut;
		
		
		always @ (posedge clk or posedge reset)
		begin
		
			if (reset)
			begin
				byteRamOut = `byteRamLen'b0;
				$write ("\nmodule byteRam is reset	");
			end
			
			else
			begin				
			
			if (byteRamEn)
			begin
			
				if (byteRamRw)		// read operation
				begin
					byteRamOut = byteRam[byteRamAddr];
//					$write ("\nreading byte RAM : module byteRam	");
				end
				
				
				else					// write operation
				begin
					byteRam[byteRamAddr] = byteRamIn;
//					$write ("\nwriting to byte RAM	:	module byteRam	");
				end
			
			end
			
			else			// if Enable = 0
			begin
			
				byteRamOut = `byteRamLen'bz;
				
			end
			
			end		// end else of reset
		
		end	// end always
		
endmodule
