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

module test_fsm;

	// Inputs
	reg clk;
	reg reset;
	reg [25:0] rom_q;

	// Outputs
	wire [8:0] rom_addr;
	wire [5:0] ram_a_addr;
	wire [5:0] ram_b_addr;
	wire ram_b_w;
	wire [10:0] pe;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	FSM uut (
		.clk(clk), 
		.reset(reset), 
		.rom_addr(rom_addr), 
		.rom_q(rom_q), 
		.ram_a_addr(ram_a_addr), 
		.ram_b_addr(ram_b_addr), 
		.ram_b_w(ram_b_w), 
		.pe(pe), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        #(`P/2); reset = 1; #(`P); reset = 0;
        
        @(posedge done);
        $finish;
	end
    
    initial #100 forever #(`P/2) clk = ~clk;
    
    /* rom code format 
     * wire [5:0] dest, src1, src2, times; wire [1:0] op;
     * assign {dest, src1, op, times, src2} = rom_q;
     */
    parameter ADD=2'd0, SUB=2'd1, CUBIC=2'd2, MULT=2'd3;

    always @ (posedge clk)
        case(rom_addr)
        0: rom_q <= {6'd10, 6'd11, ADD, 6'd1, 6'd12};
        1: rom_q <= {6'd20, 6'd21, SUB, 6'd1, 6'd22};
        2: rom_q <= {6'd30, 6'd31, CUBIC, 6'd5, 6'd32};
        3: rom_q <= {6'd40, 6'd41, MULT, 6'd33, 6'd42};
        default: rom_q <= 0;
        endcase
endmodule

