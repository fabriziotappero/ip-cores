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

/* test "f permutation".
 * write a block, wait 3 cycles, write another block, do not wait, write the third block */

`timescale 1ns / 1ps
`define P 20

module test_f_permutation;

    // Inputs
    reg clk;
    reg reset;
    reg [575:0] in;
    reg in_ready;

    // Outputs
    wire ack;
    wire [1599:0] out;
    wire out_ready;

    integer i;

    // Instantiate the Unit Under Test (UUT)
    f_permutation uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .in_ready(in_ready),
        .ack(ack),
        .out(out),
        .out_ready(out_ready)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        in = 0;
        in_ready = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);
        if (out !== 0) error; /* should be 0 */
        if (ack !== 0) error; /* should be 0 */
        if (out_ready !== 0) error; /* should be 0 */

        #(`P);
        reset = 0;
        in = 0;
        in_ready = 1;
        #(`P);
        if (out_ready !== 0) error; /* should be 0 */
        in_ready = 0;

        /* check 1~22-th cycles */
        for(i=0; i<22; i=i+1)
          begin
            if (out === 0) error; /* should not be 0 */
            if (ack !== 0) error; /* should be 0 */
            if (out_ready !== 0) error; /* should be 0 */
            #(`P);
          end

        /* check the 23-th cycle */
        if (out === 0) error; /* should not be 0 */
        if (ack !== 0) error; /* should be 0 */
        if (out_ready !== 0) error; /* should be 0 */
        #(`P);

        /* check the 24-th cycle */
        #(`P); /* wait out */
        if (out_ready !== 1) error; /* should be 1 */
        if(out !== 1600'hf1258f7940e1dde784d5ccf933c0478ad598261ea65aa9eebd1547306f80494d8b284e056253d057ff97a42d7f8e6fd490fee5a0a44647c48c5bda0cd6192e76ad30a6f71b19059c30935ab7d08ffc64eb5aa93f2317d635a9a6e6260d71210381a57c16dbcf555f43b831cd0347c82601f22f1a11a5569f05e5635a21d9ae6164befef28cc970f2613670957bc46611b87c5a554fd00ecb8c3ee88a1ccf32c8940c7922ae3a26141841f924a2c509e416f53526e70465c275f644e97f30a13beaf1ff7b5ceca249) error;

        #(3*`P); /* wait more cycles */
        if (out_ready !== 1) error; /* should be 1 */
        /* "out" should not change */
        if(out !== 1600'hf1258f7940e1dde784d5ccf933c0478ad598261ea65aa9eebd1547306f80494d8b284e056253d057ff97a42d7f8e6fd490fee5a0a44647c48c5bda0cd6192e76ad30a6f71b19059c30935ab7d08ffc64eb5aa93f2317d635a9a6e6260d71210381a57c16dbcf555f43b831cd0347c82601f22f1a11a5569f05e5635a21d9ae6164befef28cc970f2613670957bc46611b87c5a554fd00ecb8c3ee88a1ccf32c8940c7922ae3a26141841f924a2c509e416f53526e70465c275f644e97f30a13beaf1ff7b5ceca249) error;

        in_ready = 1; /* feed in one more block */
        in = 0;
        #(`P);
        if (out_ready !== 0) error; /* should be 0 */
        in_ready = 0;
        
        while (out_ready !== 1)
            #(`P);
        if(out !== 1600'h2d5c954df96ecb3c6a332cd07057b56d093d8d1270d76b6c8a20d9b25569d0944f9c4f99e5e7f156f957b9a2da65fb3885773dae1275af0dfaf4f247c3d810f71f1b9ee6f79a8759e4fecc0fee98b42568ce61b6b9ce68a1deea66c4ba8f974f33c43d836eafb1f5e00654042719dbd97cf8a9f009831265fd5449a6bf17474397ddad33d8994b4048ead5fc5d0be774e3b8c8ee55b7b03c91a0226e649e42e9900e3129e7badd7b202a9ec5faa3cce85b3402464e1c3db6609f4e62a44c105920d06cd26a8fbf5c) error;
        
        /* no wait, feed in one more block */
        in_ready = 1;
        #(`P);
        if (out_ready !== 0) error; /* should be 0 */
        in_ready = 0;

        while (out_ready !== 1)
            #(`P);
        if(out !== 1600'h55eabb80767d364686c354c8d01cbace9452d254b0979b3dde59422be2c66f16c660e4f2d4d8212e78414f691b639bb3cbb20f9f1b22e381cf16da5fac2da63f83c0b76552d95f7c44efc84eaf017e1548d380ff3e532c9592436ec5c5e02f05bde57ca1ee8de7e9240970468a1fd1b012a978439cbb7686d26b59fcceff8b4dd2aa0f472110fff87bd44abf53f72551e15ad2b722d00bb7c56095932c792c459e02d1766ad3a79c312f2da72ada4ec368b9f274a8d7d6b92b7239f7e51eea1eb6947f6894d77aeb) error;

        $display("Good!");
        $finish;
    end

    always #(`P/2) clk = ~ clk;

    task error;
      begin
        $display("Error!");
        $finish;
      end
    endtask
endmodule

`undef P
