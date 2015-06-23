//==============================================================
// Test ALU op1 MUX which is a bit more complicated
//==============================================================
`timescale 100 ns/ 100 ns

module test_mux_3z;

// ----------------- INPUT -----------------
reg sel_a_sig;
reg sel_b_sig;
reg sel_zero_sig;
reg [3:0] a_sig;
reg [3:0] b_sig;

// ----------------- OUTPUT -----------------
wire [3:0] Q_sig;           // Output of a mux
wire ena_out_sig;           // Write enable to the latch

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert(Q_sig==arg);

initial begin
    sel_a_sig = 0;
    sel_b_sig = 0;
    sel_zero_sig = 0;
    a_sig = 4'hA;
    b_sig = 4'h5;
    #1  `CHECK(0);

    sel_zero_sig = 0;
    sel_a_sig = 0;
    sel_b_sig = 0;
    #1  `CHECK(0);

    sel_zero_sig = 1;
    sel_a_sig = 0;
    sel_b_sig = 0;
    #1  `CHECK(0);

    sel_zero_sig = 0;
    sel_a_sig = 1;
    sel_b_sig = 0;
    #1  `CHECK(a_sig);

    sel_zero_sig = 0;
    sel_a_sig = 0;
    sel_b_sig = 1;
    #1  `CHECK(b_sig);

    sel_zero_sig = 1;
    sel_a_sig = 1;
    sel_b_sig = 1;
    #1  `CHECK(0);

    #1 $display("End of test");
end

//--------------------------------------------------------------
// Instantiate a mux
//--------------------------------------------------------------
alu_mux_3z alu_mux_3z_inst
(
    .sel_zero(sel_zero_sig) ,   // input  sel_zero_sig
    .sel_a(sel_a_sig) ,         // input  sel_a_sig
    .b(b_sig) ,                 // input [3:0] b_sig
    .sel_b(sel_b_sig) ,         // input  sel_b_sig
    .a(a_sig) ,                 // input [3:0] a_sig
    .Q(Q_sig) ,                 // output [3:0] Q_sig
    .ena(ena_out_sig)           // output  ena_out_sig
);

endmodule
