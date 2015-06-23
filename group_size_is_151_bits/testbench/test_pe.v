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
`define P 20

module test_pe;

	// Inputs
	reg clk;
	reg reset;
	reg [10:0] ctrl;
	reg [197:0] d0;
	reg [193:0] d1;
	reg [193:0] d2;
    reg [193:0] wish;

	// Outputs
	wire [193:0] out;

	// Instantiate the Unit Under Test (UUT)
	PE uut (
		.clk(clk), 
		.reset(reset), 
		.ctrl(ctrl), 
		.d0(d0), 
		.d1(d1), 
        .d2(d2),
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		ctrl = 0;
		d0 = 0;
		d1 = 0;
        d2 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        // test mult
        d0 = 194'h15a25886512165251569195908560596a6695612620504191;
        d1 = 194'h159546442405a181195655549614540592955a15a26984015;
        d2 = d1;
        wish = 194'h21019120440545215a1462a194a24a6019441081402410969;
        
        @(negedge clk);
        reset=1;#`P reset=0;
        ctrl=11'b11111_000000; #`P;
        ctrl=11'b00000_111111; #(33*`P);
        check;
        
        // test cubic
        d0 = {6'b10101, 192'd0};
        d1 = 194'h0894286a45940549565566512aa04a15558406850485454a4;
        d2 = d1;
        wish = 194'h1049480a48a0855a494855810160a90956659914560616652;
        
        @(negedge clk);
        reset=1;#`P reset=0;
        ctrl=11'b11111_000000; #`P;
        ctrl=1; #(33*`P);
        check;
        
        // test add
        d0 = {6'b000101, 192'd0};
        d1 = 194'h0994544a41588446516618a14691a545542521a4158868428;
        d2 = 194'h1901269451681914415481656104980811a5a555155546949;
        wish = 194'h16954a129284915a928a9916a4954141659a96092a11a2165;
        
        @(negedge clk);
        reset=1;#`P reset=0;
        ctrl=11'b11111_000000; #`P;
        ctrl=11'b10001; #(33*`P);
        check;

        // test sub
        d0 = {6'b001001, 192'd0};
        d1 = 194'h0994544a41588446516618a14691a545542521a4158868428;
        d2 = 194'h1901269451681914415481656104980811a5a555155546949;
        wish = 194'h209661a62020aa6210125a481599194946404852006625aa2;
        
        @(negedge clk);
        reset=1;#`P reset=0;
        ctrl=11'b11111_000000; #`P;
        ctrl=11'b10001; #(33*`P);
        check;

        $display("Good!");
        $finish;
	end

    initial #100 forever #(`P/2) clk = ~clk;

    task check;
        begin
          if (out !== wish)
            begin $display("E %h %h", out, wish); $finish; end
        end
    endtask
endmodule

