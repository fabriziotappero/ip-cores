//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "oc_mac.h"

//`include "technology.h"

`default_nettype none

module rx_control(
		// Inputs
		input wire		clk,
		input wire		res_n,
		input wire [63:0]	rx_inc_data,
		input wire [7:0]	rx_inc_status,
		// Outputs

		output reg [63:0]	rx_data,
		output reg [7:0]	rx_data_valid,
		output reg		rx_good_frame,
		output reg		rx_bad_frame);


reg 	error;


`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin

		rx_data <= 64'b0;
		rx_data_valid <= 8'b0;
		rx_good_frame <= 1'b0;
		rx_bad_frame <= 1'b0;
		error <= 1'b0;
	end
	else begin
	
	rx_data <= rx_inc_data;
	
	case ({rx_inc_status[`RXSTATUS_SOP], rx_inc_status[`RXSTATUS_EOP], rx_inc_status[`RXSTATUS_VALID], rx_inc_status[`RXSTATUS_ERR]})
		4'b1010: begin	// normal start
				rx_data_valid <= 8'hff;
				error <= 1'b0;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
		4'b0110: begin // normal end
				if (error) begin
					rx_bad_frame <= 1'b1;
					rx_good_frame <= 1'b0;
				end
				else begin
					rx_bad_frame <= 1'b0;
					rx_good_frame <= 1'b1;
				end
				case(rx_inc_status[2:0])
					3'b000:  rx_data_valid	<= 8'b11111111;
					3'b001:  rx_data_valid	<= 8'b00000001;
					3'b010:  rx_data_valid	<= 8'b00000011;
					3'b011:  rx_data_valid	<= 8'b00000111;
					3'b100:  rx_data_valid	<= 8'b00001111;
					3'b101:  rx_data_valid	<= 8'b00011111;
					3'b110:  rx_data_valid	<= 8'b00111111;
					default: rx_data_valid	<= 8'b01111111;
				endcase
			end
		4'b0111: begin // end of frame bad
				rx_bad_frame <= 1'b1;
				rx_good_frame <= 1'b0;
				case(rx_inc_status[2:0])
					3'b000:  rx_data_valid	<= 8'b11111111;
					3'b001:  rx_data_valid	<= 8'b00000001;
					3'b010:  rx_data_valid	<= 8'b00000011;
					3'b011:  rx_data_valid	<= 8'b00000111;
					3'b100:  rx_data_valid	<= 8'b00001111;
					3'b101:  rx_data_valid	<= 8'b00011111;
					3'b110:  rx_data_valid	<= 8'b00111111;
					default: rx_data_valid	<= 8'b01111111;
				endcase
			end
		4'b0010: begin // ongoing transmission
				rx_data_valid <= 8'hff;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
		4'b0011: begin
				rx_data_valid <= 8'hff;
				error <= 1'b1;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
			
		default: begin
				rx_data_valid <= 8'h00;
				error <= 1'b1;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
	endcase
	end

		
end
		
endmodule
`default_nettype wire
