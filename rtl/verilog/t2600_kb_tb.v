////////////////////////////////////////////////////////////////////////////
////									////
//// T2600LP IP Core	 						////
////									////
//// This file is part of the T2600LP project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// t2600 keyboard controller						////
////									////
//// TODO:								////
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

module t2600_kb_tb();
	// all inputs are regs
	reg clk;
	reg reset_n;
	reg kd;
	reg kc;
	// all outputs are wires
	wire [15:0] io_lines; 

	always #10 clk <= ~clk;
	
	initial begin
		clk = 1'b0;
		reset_n = 1'b1;
		kd = 1'b0;
		kc = 1'b0;

		#10;
		reset_n = 1'b0;
	
		#40000; 
		$finish;
	end

	always @(clk) begin
		kc = $random;
		kd = $random;
	end


	T2600_KB T2600_KB (
		.CLK		(clk),
		.RST		(reset_n),
		.io_lines	(io_lines),
		.KC		(kc),
		.KD		(kd)
	);


endmodule
