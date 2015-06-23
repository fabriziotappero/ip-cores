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

module test_padder;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] in;
    reg in_ready;
    reg is_last;
    reg [1:0] byte_num;
    reg f_ack;

    // Outputs
    wire buffer_full;
    wire [575:0] out;
    wire out_ready;

    // Var
    integer i;

    // Instantiate the Unit Under Test (UUT)
    padder uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .in_ready(in_ready),
        .is_last(is_last),
        .byte_num(byte_num),
        .buffer_full(buffer_full),
        .out(out),
        .out_ready(out_ready),
        .f_ack(f_ack)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;
        f_ack = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

        // pad an empty string, should not eat next input
        reset = 1; #(`P); reset = 0;
        #(7*`P); // wait some cycles
        if (buffer_full !== 0) error;
        in_ready = 1;
        is_last = 1;
        #(`P);
        in_ready = 1; // next input
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;

        while (out_ready !== 1)
            #(`P);
        check({8'h1, 560'h0, 8'h80});
        f_ack = 1; #(`P); f_ack = 0;
        for(i=0; i<5; i=i+1)
          begin
            #(`P);
            if (buffer_full !== 0) error; // should be 0
          end

        // pad an (576-8) bit string
        reset = 1; #(`P); reset = 0;
        #(4*`P); // wait some cycles
        in_ready = 1; is_last = 0;
        byte_num = 3; /* should have no effect */
        for (i=0; i<8; i=i+1)
          begin
            in = 32'h12345678; #(`P);
            in = 32'h90ABCDEF; #(`P);
          end
        in = 32'h12345678; #(`P);
        in = 32'h90ABCDEF; is_last = 1; #(`P);
        in_ready = 0;
        is_last = 0;
        check({ {8{64'h1234567890ABCDEF}}, 64'h1234567890ABCD81 });

        // pad an (576-64) bit string
        reset = 1; #(`P); reset = 0;
        // don't wait any cycle
        in_ready = 1; is_last = 0;
        byte_num = 1; /* should have no effect */
        for (i=0; i<8; i=i+1)
          begin
            in = 32'h12345678; #(`P);
            in = 32'h90ABCDEF; #(`P);
          end
        is_last = 1;
        byte_num = 0;
        #(`P);
        in_ready = 0;
        is_last = 0;
        #(`P);
        check({ {8{64'h1234567890ABCDEF}}, 64'h0100000000000080 });

        // pad an (576*2-16) bit string
        reset = 1; #(`P); reset = 0;
        in_ready = 1;
        byte_num = 7; /* should have no effect */
        is_last = 0;
        for (i=0; i<9; i=i+1)
          begin
            in = 32'h12345678; #(`P);
            in = 32'h90ABCDEF; #(`P);
          end
        if (out_ready !== 1) error;
        check({9{64'h1234567890ABCDEF}});
        #(`P/2);
        if (buffer_full !== 1) error; // should not eat
        #(`P/2);
        in = 64'h999; // should not eat this
        #(`P/2);
        if (buffer_full !== 1) error; // should not eat
        #(`P/2);
        f_ack = 1; #(`P); f_ack = 0;
        if (out_ready !== 0) error;
        // feed next (576-16) bit
        for (i=0; i<8; i=i+1)
          begin
            in = 32'h12345678; #(`P);
            in = 32'h90ABCDEF; #(`P);
          end
        in = 32'h12345678; #(`P);
        byte_num = 2;
        is_last = 1;
        in = 32'h90ABCDEF; #(`P);
        if (out_ready !== 1) error;
        check({ {8{64'h1234567890ABCDEF}}, 64'h1234567890AB0180 });
        is_last = 0;
        // eat these bits
        f_ack = 1; #(`P); f_ack = 0;
        // should not provide any more bits, if user provides nothing
        in_ready = 0;
        is_last = 0;
        for (i=0; i<10; i=i+1)
          begin
            if (out_ready === 1) error;
            #(`P);
          end
        in_ready = 0;

        $display("Good!");
        $finish;
    end

    always #(`P/2) clk = ~ clk;

    task error;
        begin
              $display("E");
              $finish;
        end
    endtask

    task check;
        input [575:0] wish;
        begin
          if (out !== wish)
            begin
              $display("out:%h wish:%h", out, wish);
              error;
            end
        end
    endtask
endmodule

`undef P
