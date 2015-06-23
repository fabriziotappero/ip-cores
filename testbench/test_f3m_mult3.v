`timescale 1ns / 1ps
`include "../rtl/inc.v"

module test_f3m_mult3;

    // Inputs
    reg clk;
    reg reset;
    reg [`WIDTH:0] a0,b0,a1,b1,a2,b2,w0,w1,w2;

    // Outputs
    wire [`WIDTH:0] c0,c1,c2;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    f3m_mult3 uut (
        .clk(clk), 
        .reset(reset), 
        .a0(a0), 
        .b0(b0), 
        .c0(c0), 
        .a1(a1), 
        .b1(b1), 
        .c1(c1), 
        .a2(a2), 
        .b2(b2), 
        .c2(c2), 
        .done(done)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        a0 = 0;
        b0 = 0;
        a1 = 0;
        b1 = 0;
        a2 = 0;
        b2 = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        a0 = 194'h2581921511a6952a4244918a069446a520480660152916412;
        a1 = 194'haa59080a98122082111a110a400642169102154006590a28;
        a2 = 194'h90026a06416441992252a2820a2860269a094a0a06428285;
        b0 = 194'h158a5419212805158a941010a495a80966995599a660686a5;
        b1 = 194'h115a25602090915a9086a1165169041652888086051510024;
        b2 = 194'h191a5669201405a8589951644158119264522a6496809952;
        w0 = 194'h145a548a114016289482246816a449911942a088540160102;
        w1 = 194'h220652040980466020556941115a5085a5904a60118605858;
        w2 = 194'h280a8885992001a950615026585a5592096891a9954506155;
        @ (negedge clk); reset = 1;
        @ (negedge clk); reset = 0;
        @ (posedge done);
        #5;
        if (c0 !== w0) $display("E");
        if (c1 !== w1) $display("E");
        if (c2 !== w2) $display("E");
        $finish;
    end

    always #5 clk = ~clk;
endmodule

