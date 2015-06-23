////////////////////////////////////////////////////////////////// ////
////                                                              ////
//// SPI SLAVE IP Core                                            ////
////                                                              ////
//// This file is part of the spislave project                     ////
//// http://www.opencores.org/project,spislave                    ////
////                                                              ////
//// Description                                                  ////
//// Implementation of spislave IP core according to              ////
//// spislave IP core specification document.                     ////
////                                                              ////
//// To Do:                                                       ////
////   -                                                          ////
////                                                              ////
//// Author(s):                                                   ////
////      - Sivakumar.B , email: siva@zilogic.com                 ////
////                      email: siva12@opencores.org             ////
////        Engineer  Zilogic systems,chennai. www.zilogic.com    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Zilogic Systems and OPENCORES.ORG         ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////       RTL program for SPI GPIO -- shift 8 bit register       ////  

`define		P0_P9_OP	8'b10101010 //0xAA
`define		P0_P3_OP	8'b11111111 //0xFF
`define		P4_P7_OP	8'b11111110 //0xFE
 
module spigpio(clk, cs, sr_in, gpioout, sr_out);
  
	input clk, cs;
	input sr_in;
	output sr_out;
	output [7:0] gpioout;

	reg [7:0] gpioout;
	reg sr_out;
	
	wire rw;
	reg [7:0] sr;

	assign rw = sr[7];	
	
	always@(posedge clk )
	begin
		if (cs == 1'b0)
		begin 
			sr_out <= sr[7];
			sr[7:1] <= sr[6:0];
			sr[0] <= sr_in;
		end 		
		
		if (cs == 1'b1)
		begin 
		
			if (rw == 1'b1)
			begin 
			
				case (sr)
				`P0_P9_OP : gpioout[7:0] <= { sr[0], sr[1], sr[2], sr[3],
							      sr[4], sr[5], sr[6], sr[7]};
				`P0_P3_OP : gpioout[3:0] <= {sr[0], sr[1], sr[2], sr[3]};
				`P4_P7_OP : gpioout[7:4] <= { sr[4], sr[5], sr[6], sr[7]};
				default   : gpioout[0] <= sr[0];
				endcase	
			end
	 	end
	end
endmodule
