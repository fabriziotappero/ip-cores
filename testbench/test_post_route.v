`timescale 1ns / 1ns
`include "../rtl/inc.v"
/* purpose of this module is ISE post-route simulation */
/* if you don't use Xilinx ISE, please ignore this file :) */
module test_post_route;

    // Inputs
    reg clk;
    reg reset;
    reg [`WIDTH:0] x1, y1, x2, y2;

    // Outputs
    wire done, ok;

    // Instantiate the Unit Under Test (UUT)
    post_route_debug uut (
        .clk(clk), 
        .reset(reset), 
        .x1(x1), 
        .y1(y1), 
        .x2(x2), 
        .y2(y2), 
        .done(done), 
        .ok(ok)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        x1 = 0;
        y1 = 0;
        x2 = 0;
        y2 = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        x1 = 194'h6a18950064046a122a14118668466a262a91509688159890;
        y1 = 194'h69112569422aa0a25224aa010888066061124a8685566825;
        x2 = 194'h155945aa8924654812564110544995a28845901211454814;
        y2 = 194'h8481099460280628960a82559920000a99a2106955289a40;
        @ (negedge clk); reset = 1;
        @ (negedge clk); reset = 0;
        @ (posedge done); @ (negedge clk);
        if (ok !== 1'b1) $display("E");
        $finish;

    end

    always #5 clk = ~clk;      
endmodule

