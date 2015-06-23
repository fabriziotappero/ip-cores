`timescale 1ns / 1ns
`include "../rtl/inc.v"

module test_second_part;

    // Inputs
    reg clk;
    reg reset;
    reg [`W6:0] a,w;

    // Outputs
    wire done;
    wire [`W6:0] c;

    // Instantiate the Unit Under Test (UUT)
    second_part uut (
        .clk(clk), 
        .reset(reset), 
        .a(a), 
        .c(c), 
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        a = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        a = {{194'h1204a208505851241694660a526600a5458a2146924560a45,194'h205aaa952a9194aa810582958a44a26450215504612a46414},{194'h2a45a0864044919108410218084641146a6998849a4621651,194'h22a848590260089606082518041602a196a616829a2a80140},{194'h19491668519a946a6024288a5112a24a61a09955a90a1a228,194'h89204a1905581664001424a2218884a81a4018082628016a}};
        w = {{194'h29a595141a15aaaaa986118869958824916644820599a9105,194'h1058412a52a604a8928a154a55625062004a8156558a25456},{194'h265269409a62958689a49a5044a024a4944252894154a5089,194'h1a00a6298165562952615a009190225988a28809955a49aaa},{194'h2285858aa2486869a809409269941a8595252895401015459,194'h124469156610a888686061a9128002611404aa18a26850589}};
        @ (negedge clk); reset = 1;
        @ (negedge clk); reset = 0;
        @ (posedge done);
        @ (negedge clk);
        if (c !== w) $display("E");
        $finish;
    end
      
endmodule

