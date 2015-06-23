////////////////////////////////////////////////////////////////////////////
////									////
//// t6532 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// 6532 top level					 		////
////									////
//// TODO:								////
//// - Add the timer, ram and i/o					////
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

module t6532(clk, reset_n, io_lines, enable, mem_rw, address, data);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd10; // this is the *local* addr_size

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;

	input clk; // master clock signal, 1.19mhz
	input reset_n;
	input [15:0] io_lines; // inputs from the keyboard controller
	input enable; // since the address bus is shared an enable signal is used
	input mem_rw; // read == 0, write == 1
	input [ADDR_SIZE_:0] address; // system address bus
	inout [DATA_SIZE_:0] data; // controler <=> riot data bus

	reg [DATA_SIZE_:0] ram [8'hFF:8'h80]; // the ram itself. TODO: test the memory compiler
	reg [DATA_SIZE_:0] port_a;
	reg [DATA_SIZE_:0] port_b;
	reg [DATA_SIZE_:0] ddra;
	reg [DATA_SIZE_:0] timer; // the timer
	reg c1_timer; // 1 clock cycle counter enable
	reg c8_timer; // 8 clock cycles counter enable
	reg c64_timer; // 64 clock cycles counter enable
	reg c1024_timer; // 1024 clock cycles counter enable
	reg [10:0] counter; // also called the prescaler
	reg flipped; // a flag to remember if the timer already flipped

	reg reading; // combinational logic for easing the control over timers
	reg writing;
	reg writing_at_timer;
	
	reg [DATA_SIZE_:0] data_drv; // wrapper for the data bus

	assign data = (mem_rw || !reset_n) ? 8'bZ : data_drv; // if under writing the bus receives the data from cpu, else local data.  

	always @(posedge clk or negedge reset_n) begin // I/O handling
		if (reset_n == 1'b0) begin
			port_a <= 8'h00;
			port_b <= 8'b00001000; // D3=1, color!
			ddra <= 8'h00;
		end
		else begin
			if (io_lines[0]) begin // these are switches
				port_b[0] <= !port_b[0];
			end
			if (io_lines[1]) begin
				port_b[1] <= !port_b[1];
			end 
			if (io_lines[3]) begin
				port_b[3] <= !port_b[3];
			end 
			if (io_lines[6]) begin
				port_b[6] <= !port_b[6];
			end 
			if (io_lines[7]) begin
				port_b[7] <= !port_b[7];
			end
	
			port_a[0] <= (ddra[0] == 1'b0) ? io_lines[8] : port_a[0]; 
			port_a[1] <= (ddra[1] == 1'b0) ? io_lines[9] : port_a[1]; 
			port_a[2] <= (ddra[2] == 1'b0) ? io_lines[10] : port_a[2]; 
			port_a[3] <= (ddra[3] == 1'b0) ? io_lines[11] : port_a[3]; 
			port_a[4] <= (ddra[4] == 1'b0) ? io_lines[12] : port_a[4]; 
			port_a[5] <= (ddra[5] == 1'b0) ? io_lines[13] : port_a[5]; 
			port_a[6] <= (ddra[6] == 1'b0) ? io_lines[14] : port_a[6]; 
			port_a[7] <= (ddra[7] == 1'b0) ? io_lines[15] : port_a[7]; 
		end
	end

	always @(posedge clk  or negedge reset_n) begin // R/W register/memory handling
		if (reset_n == 1'b0) begin
			data_drv <= 8'h00;
			c1_timer <= 1'b0;
			c8_timer <= 1'b0;
			c64_timer <= 1'b0;
			c1024_timer <= 1'b0;
			timer <= 8'h00;
			flipped <= 1'b0;
			counter <= 11'd0;
		end
		else begin
			if (reading) begin // reading! 
				case (address) 
					10'h280: data_drv <= port_a;
					10'h281: data_drv <= ddra;
					10'h282: data_drv <= port_b;
					10'h283: data_drv <= 8'h00; // portb ddr is always input
					10'h284: data_drv <= timer;
					default: data_drv <= ram[address];
				endcase
			end  	
			else if (writing) begin // writing! 
				case (address)
					10'h281: begin
						ddra <= data;
					end 
					10'h294: begin
						c1_timer <= 1'b1;
						c8_timer <= 1'b0;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd1;
					end
					10'h295: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b1;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd7;
					end
					10'h296: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b0;
						c64_timer <= 1'b1;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd63;
					end
					10'h297: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b0;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b1;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd1023;
					end
					default: begin
						ram[address] <= data;
					end
				endcase
			end
		
			if (!writing_at_timer) begin
				if (flipped || timer == 8'd0) begin // finished counting
					counter <= 11'd0;
					timer <= timer - 8'd1;
					flipped <= 1'b1;
				end
				else begin
					if (counter == 11'd0) begin
						timer <= timer - 8'd1;
	
						if (c1_timer) begin
							counter <= 11'd0;
						end
						if (c8_timer) begin
							counter <= 11'd7;
						end
						if (c64_timer) begin
							counter <= 11'd63;
						end
						if (c1024_timer) begin
							counter <= 11'd1023;
						end
					end
					else begin
						counter <= counter - 11'd1;
					end
				end
			end
		end
	end
	
	always @(*) begin // logic for easier controlling
		reading = 1'b0;
		writing = 1'b0;
		writing_at_timer = 1'b0;

		if (enable && reset_n) begin
			if (mem_rw == 1'b0) begin
				reading = 1'b1;
			end
			else begin
				writing = 1'b1;

				if ( (address == 10'h294) || (address == 10'h295) || (address == 10'h296) || (address == 10'h297) ) begin
					writing_at_timer = 1'b1;
				end
			end
		end
	end
	
endmodule
