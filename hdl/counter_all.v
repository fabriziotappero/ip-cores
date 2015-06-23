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


module counter (clk, reset, preset, type, DN, CU, CD, ACC);

	input clk, reset;
	input [`tcPresetLen-1:0] preset;
	input [`tcTypeLen-1:0] type;
	
	output DN, CU, CD;
	output [`tcAccLen-1:0] ACC;
	
	reg DN = 0, CU = 0, CD = 0;
	reg [`tcAccLen-1:0] ACC = 0;
	
	reg [`tcTypeLen-1:0] CounterType;
	reg [`tcTypeLen-1:0] typeNext;
	
	
	parameter	UpCounter	= `tcTypeLen'b01;
	parameter	DownCounter	= `tcTypeLen'b10;
	parameter	defaultType	= `tcTypeLen'b00;
	
	
	
	always @ (type)
	begin
	
		case (type)
		
		`counterType1	:	begin
								typeNext = UpCounter;
								end
								
		`counterType2	:	begin
								typeNext = DownCounter;
								end
								
		default			:	begin
								$display ("\ncounter is of undefined type.\n Valid types are Up counter & Down counter");
								end
		endcase
	end
	
	
	always @ (posedge clk or posedge reset)
	begin
	
		if (reset)
		begin
			$display ("counter module is reset");
			CounterType = defaultType;
		end
		else
		begin
			CounterType = typeNext;
		end
	end
	
	
	always @ (posedge clk)
	begin
	
		case (CounterType)
		
		UpCounter	:	begin
									CD = 0;			// CD id always 0 for this state
									
									if (reset)
									begin
										ACC = `tcAccLen-1'b0;	// starts at lowest value
										CU = 0;
										DN = 0;
									end
									else
									begin
										ACC = ACC + 1'b1;
										CU = 1'b1;
										if (ACC > preset)
										begin
											DN = 1'b1;
										end
									end
							end
		
		
		
		DownCounter	:	begin
									CU = 0;			// CU id always 0 for this state
									
									if (reset)
									begin
										ACC = `tcAccLen-1'b1;	// starts at highest value
										CD = 0;
										DN = 0;
									end
									else
									begin
										ACC = ACC - 1'b1;
										CD = 1'b1;
										if (ACC < preset)
										begin
											DN = 1'b1;
										end
									end
							end
		
		
		
		default		:	begin
							$display ("\nerror in counter type	");
							end
				
		endcase
	end


endmodule
