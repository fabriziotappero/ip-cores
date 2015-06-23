//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SPI GPIO IP Core                                             ////
////                                                              ////
//// This file is part of the spigpio project                     ////
//// http://www.opencores.org/project,spislave                    ////
////                                                              ////
//// Description                                                  ////
//// Implementation of spislave IP core according to              ////
//// spigpio IP core specification document.                      ////
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
////       RTL program for SPI GPIO --                            ////  

`define		P0_OP		7'b0000000 //0x00
`define		P1_OP		7'b0000001 //0x01
`define		P2_OP		7'b0000010 //0x02
`define		P3_OP		7'b0000011 //0x03
`define		P4_OP		7'b0000100 //0x04
`define		P5_OP		7'b0000101 //0x05
`define		P6_OP		7'b0000110 //0x06
`define		P7_OP		7'b0000111 //0x07
`define		P8_OP		7'b0001000 //0x08
`define		P9_OP		7'b0001001 //0x09

`define		P0_P9_OP	7'b0001010 //0x0A
`define		P0_P3_OP	7'b0001011 //0x0B
`define		P4_P7_OP	7'b0001100 //0x0C
`define		P8_P9_OP	7'b0001101 //0x0D

`define		PO_P7_IP	7'b0001110 //0x0E	
`define		P8_P9_IP	7'b0001111 //0x0F

`define		RAM	        7'b0010011 //0x13

module spigpio(clk, cs, sr_in, gpioin, gpioout, sr_out);
  
	input clk, cs;
	input sr_in;
	input [9:0] gpioin;
	
	output sr_out;
	output [9:0] gpioout;

	reg [9:0] gpioout;
	reg sr_out;

	reg [7:0] ram;
	wire [6:0] addr;
	wire [7:0] data;	
	wire rw;
	reg [15:0] sr;

	assign rw = sr[15];	
	assign addr = sr[14:8];
	assign data = sr[7:0];

	always@(posedge clk or posedge cs)
	begin
		if (cs == 1'b0)
		begin 
			sr_out <= sr[15];
			sr[15:1] <= sr[14:0];
			sr[0] <= sr_in;
		end 		
		
		if (cs == 1'b1)
		begin 
		
			if (rw == 1'b0)
			begin 
			
				case (addr)
				`P0_OP    : gpioout[0] <= data[0];
				`P1_OP    : gpioout[1] <= data[0];
				`P2_OP    : gpioout[2] <= data[0];
				`P3_OP    : gpioout[3] <= data[0];
				`P4_OP    : gpioout[4] <= data[0];
				`P5_OP    : gpioout[5] <= data[0];
				`P6_OP    : gpioout[6] <= data[0];
				`P7_OP    : gpioout[7] <= data[0];
				`P8_OP    : gpioout[8] <= data[0];
				`P9_OP    : gpioout[9] <= data[0];
				
				`P0_P9_OP : gpioout[9:0] <= {data[0], data[0], data[0], data[0], data[0],
							     data[0], data[0], data[0], data[0], data[0]};
				`P0_P3_OP : gpioout[3:0] <= {data[0], data[0], data[0], data[0]};
				`P4_P7_OP : gpioout[7:4] <= {data[0], data[0], data[0], data[0]};
				`P8_P9_OP : gpioout[9:8] <= {data[0], data[0]};
				`RAM      : ram[7:0] <= data[7:0];					
				endcase	
			end
			
			if (rw == 1'b1)             // READ THE PORT LEVEL
			begin 
		
				case (addr)
				`P0_OP	  : sr[7:0] <= {7'b0, gpioout[0]};
				`P1_OP    : sr[7:0] <= {7'b0, gpioout[1]};
				`P2_OP    : sr[7:0] <= {7'b0, gpioout[2]};
				`P3_OP    : sr[7:0] <= {7'b0, gpioout[3]};
				`P4_OP    : sr[7:0] <= {7'b0, gpioout[4]};
				`P5_OP    : sr[7:0] <= {7'b0, gpioout[5]};
				`P6_OP    : sr[7:0] <= {7'b0, gpioout[6]};
				`P7_OP    : sr[7:0] <= {7'b0, gpioout[7]};
				`P8_OP    : sr[7:0] <= {7'b0, gpioout[8]};
				`P9_OP    : sr[7:0] <= {7'b0, gpioout[9]};
				`P0_P9_OP : sr[7:0] <= {7'b0, gpioout[0]};
				`P0_P3_OP : sr[7:0] <= {7'b0, gpioout[0]};
				`P4_P7_OP : sr[7:0] <= {7'b0, gpioout[4]};
				`P8_P9_OP : sr[7:0] <= {7'b0, gpioout[8]};
				`PO_P7_IP : sr[7:0] <= gpioin[7:0];
				`P8_P9_IP : sr[7:0] <= gpioin[9:8];
				`RAM 	  : sr[7:0] <= ram[7:0];						
				endcase
			end
	 	end
	end
endmodule
