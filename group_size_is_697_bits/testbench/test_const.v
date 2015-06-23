/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns / 1ps
`define P 20 // clock period

module test_const;

	// Inputs
    reg clk;
	reg [5:0] addr;

	// Outputs
	wire [1007:0] out;
	wire effective;
    reg [1007:0] w_out;
    reg w_effective;
    
	// Instantiate the Unit Under Test (UUT)
	const_ uut (
        .clk(clk),
		.addr(addr), 
		.out(out), 
		.effective(effective)
	);

	initial begin
		// Initialize Inputs
		addr = 0; clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        @ (negedge clk);
        addr = 1; w_out = 0; w_effective = 1;
        #(`P); check;
        addr = 2; w_out = 1;
        #(`P); check;
        addr = 4; w_out = {6'b000101, 1002'd0};
        #(`P); check;
        addr = 8; w_out = {6'b001001, 1002'd0};
        #(`P); check;
        addr = 16; w_out = {6'b010101, 1002'd0};
        #(`P); check;
        addr = 0; w_out = 0; w_effective = 0;
        #(`P); check;
        $display("Good");
        $finish;
	end

    initial #100 forever #(`P/2) clk = ~clk;

    task check;
      begin
        if (out !== w_out || effective !== w_effective)
            $display("E %d %h %h", addr, out, w_out);
      end
    endtask
endmodule
