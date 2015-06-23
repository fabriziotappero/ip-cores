////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// VGA controller test file. This is just a test file, it does not	////
//// contain any part of the design itself		 		////
////									////
//// TODO:								////
//// - Feed the controller with data					////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module controller_test(reset_n, clk_50, pixel, write_addr, write_data, write_enable_n, clk_358);

input reset_n;
input clk_50;
output reg [2:0] pixel;
output reg [10:0] write_addr;
output reg [2:0] write_data;
output reg write_enable_n;
output reg clk_358; // 3.58mhz

reg [3:0] counter;

//reg [3:0] red;
//reg [3:0] green;
//reg [3:0] blue;

reg [8:0] vert_counter;
reg [7:0] hor_counter;

always @ (posedge clk_50 or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		clk_358 <= 1'b0;
		counter <= 4'd0;
		//red <= 4'b1010;
		//green <= 4'b0001;
		//blue <= 4'b1110;
	end
	else begin
		//red <= 4'b1010;
		//green <= 4'b0001;
		//blue <= 4'b1110;

		if (counter == 4'h6) begin
			clk_358 <= !clk_358;
			counter <= 4'd0;
		end
		else begin
			counter <= counter + 4'd1;
		end
	end
end

always @ (posedge clk_358 or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		hor_counter <= 8'd0;
		vert_counter <= 9'd0;
	end
	else begin
		if (hor_counter == 8'd227) begin // last colum
			hor_counter <= 8'd0;

			if (vert_counter == 9'd261) begin // last line
				vert_counter <= 9'd0;
			end
			else begin
				vert_counter <= vert_counter + 9'd1;
			end
		end
		else begin
			hor_counter <= hor_counter + 8'd1;
		end
	end
end

always @(*) begin // comb logic
	if (hor_counter < 68 || vert_counter < 40 || vert_counter > 232) begin
		pixel = 3'd0;
		write_enable_n = 1'b1;
		write_addr = 0;
		write_data = vert_counter[2:0];
	end
	else begin
		pixel = 3'd4;
		write_enable_n = 1'b0;
		write_addr = (hor_counter - 68) + (vert_counter - 40)*160;
		write_data = 3'd4;
	end
end

endmodule
