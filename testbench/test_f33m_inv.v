`timescale 1ns / 1ps
`include "../rtl/inc.v"

module test_f33m_inv;

    // Inputs
    reg clk;
    reg reset;
    reg [`W3:0] a, w;

    // Outputs
    wire done;
    wire [`W3:0] c;

    // Instantiate the Unit Under Test (UUT)
    f33m_inv uut (
        .clk(clk), 
        .reset(reset), 
        .a(a), 
        .c(c), 
        .done(done)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        a = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        a = {194'h210226252a484596150544098559162512219149194a91008,194'h12622041181115a64a84159a001a15a0a0609a642962068a5,194'h25429526606a8552a8622169050aa29921641120a05866014};
        w = {194'h9a08022aa299850a48900010428a4aa66211109901a00a89,194'h95869a60454411009148081200aaaa121864220208592809,194'h564a6642212a164990212611055046496851a96918954695};
        @ (negedge clk); reset = 1;
        @ (posedge clk); reset = 0;
        @ (posedge done); @(negedge clk);
        if (c !== w) $display("E");
        $finish;
    end
    
    always #5 clk = ~clk;
endmodule

