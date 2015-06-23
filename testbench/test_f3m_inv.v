`timescale 1ns / 1ps
`define CLOCK_PERIOD 10
module test_f3m_inv;

    // Inputs
    reg [193:0] A;
    reg clk;
    reg reset;

    // Outputs
    wire [193:0] C;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    f3m_inv uut (
        .A(A), 
        .clk(clk), 
        .reset(reset), 
        .C(C),
        .done(done)
    );

    always #`CLOCK_PERIOD clk = ~clk;

    initial begin
        // Initialize Inputs
        A = 0;
        clk = 0;
        reset = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        A = 32'b10_01_01_10_01_00; // A = "x";
        @(negedge clk); reset = 1;
        @(negedge clk); reset = 0;
        #(200*2*`CLOCK_PERIOD);
        if (C != 192'h65450169824811252a919a8a02964184221a1562655252a9) $display("Error!");
        $display("Good!"); $finish;
    end
      
endmodule

