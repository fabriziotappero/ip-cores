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

module bitRam (clk, reset, bitRamEn, bitRamRw, bitRamIn, bitRamAddr, bitRamOut);


		input	clk, reset, bitRamEn, bitRamRw, bitRamIn;
		input [`bitRamAddrLen-1:0]	bitRamAddr;
		
		output bitRamOut;
		
		reg bitRam [`bitRamDepth-1:0];
		reg bitRamOut;
		
		
		always @ (posedge clk or posedge reset)
		begin
		
			if (reset)
			begin
				bitRamOut = 1'b0;
				$write ("\nmodule bitRam is reset	");
			end
			
			else
			begin
			
			if (bitRamEn)
			begin
				if (bitRamRw)	// read operation
				begin
					bitRamOut = bitRam[bitRamAddr];
//					$write ("\nreading bit-RAM	:	module bitRAM	");
				end
				
				else				// write operation
				begin
					bitRam[bitRamAddr] = bitRamIn;
//					$write ("\nwriting to bit-RAM	:	module bitRam	");
				end
			end
			
			else
			begin
				bitRamOut = 1'bZ;
			end
			
			end	// end else of reset
				
		end	// end always block
		
		
endmodule
