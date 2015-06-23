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

module test_pairing;

	// Inputs
	reg clk;
	reg reset;
	reg sel;
	reg [5:0] addr;
	reg w;
    reg update;
    reg ready;
    reg i;

	// Outputs
	wire done;
    wire o;

    // Buffers
	reg [197:0] out;

	// Instantiate the Unit Under Test (UUT)
	pairing uut (
        .clk(clk), 
        .reset(reset), 
        .sel(sel), 
        .addr(addr), 
        .w(w), 
        .update(update),
        .ready(ready),
        .i(i),
        .o(o),
        .done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		sel = 0;
		addr = 0;
		w = 0;
        update = 0;
        ready = 0;
        i = 0;
        out = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        /* keep FSM silent */
        reset = 1;
            /* init xp, yp, xq, yq */
            write(3, 194'h21181940120548aa020568aa65a5989609251595a89a44598);
            write(5, 194'h0a905590506a8a845592a09644a2095291422910a968a5048);
            write(6, 194'h21181940120548aa020568aa65a5989609251595a89a44598);
            write(7, 194'h0a905590506a8a845592a09644a2095291422910a968a5048);
            /* read back. uncomment me if error happens */
            /* read(3);
            $display("xp = %h", out);
            read(5);
            $display("yp = %h", out);
            read(6);
            $display("xq = %h", out);
            read(7);
            $display("yq = %h", out);*/
        reset = 0;
        
        sel = 0; w = 0;
        @(posedge done);
        @(negedge clk);
            read(9);
            check(194'h09a49266428495042842965645266a2164a1268408a669866);
            read(10);
            check(194'h204446152452400968480544296829199a169a2562a908520);
            read(11);
            check(194'h1699142918666651a156954a80544689590a5094624610281);
            read(12);
            check(194'h2461998924145511611291626a4a295888569280285884661);
            read(13);
            check(194'h1040525045a404150a1881aa91a99156660a1658a090a1091);
            read(14);
            check(194'h2400a94249694808254880924a06494816081900811198925);
            $display("Good");
        $finish;
	end

    initial #100 forever #(`P/2) clk = ~clk;

    task write;
        input [5:0] adr;
        input [197:0] dat;
        integer j;
        begin
            sel = 1; 
            w = 0;
            addr = adr;
            update = 1;
            #`P;
            update = 0;
            ready = 1;
            for(j=0;j<198;j=j+1)
               begin
               i = dat[j];
               #`P;
               end
            ready = 0;
            w = 1; #`P; w = 0;
        end
    endtask

    task read;
        input [5:0] adr;
        integer j;
        begin
            sel = 1;
            w = 0;
            addr = adr;
            #`P;
            update = 1;
            #`P;
            update = 0;
            out = 0;
            ready = 1;
            for(j=0;j<198;j=j+1)
               begin
               out = {o, out[197:1]};
               #`P;
               end
        end
    endtask
    
    task check;
        input [197:0] wish;
        begin
            if (out !== wish) 
                begin $display("Error!"); $finish; end
        end
    endtask    
endmodule

