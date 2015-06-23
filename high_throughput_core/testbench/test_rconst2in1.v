/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
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

module test_rconst2in1;

    // Inputs
    reg [11:0] i;

    // Outputs
    wire [63:0] rc1;
    wire [63:0] rc2;

    // Instantiate the Unit Under Test (UUT)
    rconst2in1 uut (
        .i(i), 
        .rc1(rc1), 
        .rc2(rc2)
    );

    initial begin
        // Initialize Inputs
        i = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        i=0; i[0] = 1;
        #(`P/2);
        if(rc1 !== 64'h1) begin $display("E"); $finish; end
        if(rc2 !== 64'h8082) begin $display("E"); $finish; end
        i=0; i[1] = 1;
        #(`P/2);
        if(rc1 !== 64'h800000000000808a) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000080008000) begin $display("E"); $finish; end
        i=0; i[2] = 1;
        #(`P/2);
        if(rc1 !== 64'h808b) begin $display("E"); $finish; end
        if(rc2 !== 64'h80000001) begin $display("E"); $finish; end
        i=0; i[3] = 1;
        #(`P/2);
        if(rc1 !== 64'h8000000080008081) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000000008009) begin $display("E"); $finish; end
        i=0; i[4] = 1;
        #(`P/2);
        if(rc1 !== 64'h8a) begin $display("E"); $finish; end
        if(rc2 !== 64'h88) begin $display("E"); $finish; end
        i=0; i[5] = 1;
        #(`P/2);
        if(rc1 !== 64'h80008009) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000a) begin $display("E"); $finish; end
        i=0; i[6] = 1;
        #(`P/2);
        if(rc1 !== 64'h8000808b) begin $display("E"); $finish; end
        if(rc2 !== 64'h800000000000008b) begin $display("E"); $finish; end
        i=0; i[7] = 1;
        #(`P/2);
        if(rc1 !== 64'h8000000000008089) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000000008003) begin $display("E"); $finish; end
        i=0; i[8] = 1;
        #(`P/2);
        if(rc1 !== 64'h8000000000008002) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000000000080) begin $display("E"); $finish; end
        i=0; i[9] = 1;
        #(`P/2);
        if(rc1 !== 64'h800a) begin $display("E"); $finish; end
        if(rc2 !== 64'h800000008000000a) begin $display("E"); $finish; end
        i=0; i[10] = 1;
        #(`P/2);
        if(rc1 !== 64'h8000000080008081) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000000008080) begin $display("E"); $finish; end
        i=0; i[11] = 1;
        #(`P/2);
        if(rc1 !== 64'h80000001) begin $display("E"); $finish; end
        if(rc2 !== 64'h8000000080008008) begin $display("E"); $finish; end
        $display("Good!");
        $finish;
    end
      
endmodule

`undef P
