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


module timer (clk, en, reset, type, preset, DN, TT, ACC);

	input clk, en, reset;
	input [`tcTypeLen-1:0] type;
	input [`tcPresetLen-1:0] preset;
	
	output DN, TT;
	output [`tcAccLen-1:0] ACC;
	
	reg DN = 0, TT = 0;
	reg [`tcAccLen-1:0] ACC = 0;
	
	reg [`tcTypeLen-1:0]	TimerType;
	reg [`tcTypeLen-1:0]	typeNext;
	

	
	parameter	OnDelayTimer			= `tcTypeLen'b0;
	parameter	OffDelayTimer			= `tcTypeLen'b1;
	parameter	RetOnDelayTimer		= `tcTypeLen'b10;
	parameter	defaultType				= `tcTypeLen'b11;
	
	always @ (type)
	begin
		case (type)
		
		`timerType1		:	begin
								typeNext = OnDelayTimer;
								end
								
		`timerType2		:	begin
								typeNext = OffDelayTimer;
								end
								
		`timerType3		:	begin
								typeNext = RetOnDelayTimer;
								end
								
		default			:	begin

								$display("\nTimer is defined for unknown type.\n Valid types: On-delay, Off-delay, retentive-on-delay");
								end
								
		endcase
	end
	
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			$write ("\ntimer module is reset	");
			TimerType = defaultType;
		end
		else
		begin
			TimerType = typeNext;
		end
	end
	
	
	always @ (posedge clk)
	begin

	
		case (TimerType)
		
		OnDelayTimer	:	begin
										if (reset)
										begin
											ACC = `tcAccLen'b0;
											DN = 1'b0;
											TT = 1'b0;
										end
										else
										begin
											if (en)
											begin
												if (ACC < preset)
												begin
													ACC = ACC + 1'b1;
													DN = 1'b0;
													TT = 1'b1;
												end
												else if (ACC >= preset)
												begin
													ACC = ACC;

													DN = 1'b1;
													TT = 1'b0;
												end
											end
											else
											begin
												ACC = `tcAccLen'b0;	// if not enabled
												DN = 1'b0;
												TT = 1'b0;
											end
										end
									end	// end this case
		
		OffDelayTimer	:	begin							// not correct implementation!
										if (reset)
										begin
											ACC = `tcAccLen'b0;
											DN = 1'b0;
											TT = 1'b0;
										end
										else
										begin
											if (!en)
											begin
												if (ACC < preset)
												begin
													ACC = ACC + 1'b1;
													DN = 1'b0;
													TT = 1'b1;
												end
												else if (ACC >= preset)
												begin
													ACC = ACC;
													DN = 1'b1;
													TT = 1'b0;
												end
											end
											else
											begin
												ACC = `tcAccLen'b0;	// if not enabled
												DN = 1'b0;
												TT = 1'b0;
											end
										end
									end	// end this case
		
		RetOnDelayTimer	:	begin

										if (reset)
										begin
											ACC = `tcAccLen'b0;
											DN = 1'b0;
											TT = 1'b0;
										end
										else
										begin
											if (en)
											begin
												if (ACC < preset)
												begin
													ACC = ACC + 1'b1;
													DN = 1'b0;
													TT = 1'b1;
												end
												else if (ACC >= preset)
												begin
													ACC = ACC;
													DN = 1'b1;




													TT = 1'b0;
												end
											end
											else
											begin
												ACC = ACC;	// retain ACC
												DN = 1'b0;
												TT = 1'b0;
											end
										end
									end	// end this case
				
				
				default		:	begin
									if (!reset)
									$display("\nError in timer type	");
									end
									
				endcase
		
	end

		
endmodule
