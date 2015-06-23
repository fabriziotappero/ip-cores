////////////////////////////////////////////////////////////////////////////
////									////
//// T6532 IP Core	 						////
////									////
//// This file is part of the T2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// 6532 testbench							////
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

module t6532_tb();
	// mem_rw signals
	localparam MEM_READ = 1'b0;
	localparam MEM_WRITE = 1'b1;

	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd10; // this is the *local* addr_size

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;

	reg clk; // regs are inputs
	reg reset_n;
	reg [15:0] io_lines;
	reg enable;
	reg mem_rw;
	reg [ADDR_SIZE_:0] address;

	reg [DATA_SIZE_:0] data_drv;
	tri [DATA_SIZE_:0] data = data_drv;

	t6532 #(DATA_SIZE, ADDR_SIZE) t6532(
		.clk		(clk),
		.reset_n	(reset_n),
		.io_lines	(io_lines),
		.enable		(enable),
		.mem_rw		(mem_rw),
		.address	(address),
		.data		(data)
	);

	always #10 clk = ~clk;

	always @(*) begin
		if (mem_rw == MEM_READ) begin
			data_drv = 8'hZ;
		end
	end 

	initial begin
		clk = 1'b0;
		reset_n = 1'b0;
		io_lines = 16'd0;
		enable = 1'b0;
		mem_rw = MEM_READ;
		address = 0;
		
		@(negedge clk) // will wait for next negative edge of the clock (t=20)
		reset_n=1'b1;

		@(negedge clk) // testing the port_b. all switches must change!
		io_lines = 16'h00FF;

		@(negedge clk) // testing the port_b. all switches must change!
		io_lines = 16'h00FF;

		@(negedge clk) // testing the port_a. all switches must change since ddra = 0. (0 == input)
		io_lines = 16'hFF00;

		@(negedge clk) // setting ddra = FF. (output)
		enable = 1'b1;
		io_lines = 16'hFF00;
		address = 10'h281;
		mem_rw = MEM_WRITE;
		data_drv = 8'hFF;

		@(negedge clk) // testing port_a again. no switching this time!
		enable = 1'b0;
		io_lines = 16'h0000;
		address = 0;
		mem_rw = MEM_READ;

		@(negedge clk) // writing at the memory
		enable = 1'b1;
		address = 10'd255;
		mem_rw = MEM_WRITE;
		data_drv = 8'h11;

		@(negedge clk) // reading memory (output)
		enable = 1'b1;
		address = 10'd255;
		mem_rw = MEM_READ;

		@(negedge clk) // using the timer to count 100*1 cycle.
		enable = 1'b1;
		address = 10'h294;
		mem_rw = MEM_WRITE;
		data_drv = 8'd100;

		@(negedge clk);
		mem_rw = MEM_READ;
		enable = 1'b0;
		#2040; 

		@(negedge clk) // using the timer to count 10*8 cycles.
		enable = 1'b1;
		address = 10'h295;
		mem_rw = MEM_WRITE;
		data_drv = 8'd10;

		@(negedge clk);
		mem_rw = MEM_READ;
		enable = 1'b0;
		#1640; 



		$finish; // to shut down the simulation
	end //initial

endmodule
