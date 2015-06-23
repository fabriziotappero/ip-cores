//==============================================================
// Test sequencer
//==============================================================
`timescale 100 ns/ 100 ns

module test_sequencer;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (100) #1 clk = ~clk;

logic nreset = 0;

// ----------------- CONTROL ----------------
logic nextM_sig;
logic setM1_sig;
logic hold_clk_iorq_sig=0;
logic hold_clk_wait_sig=0;
logic hold_clk_busrq_sig=0;

wire T6_sig;
wire M6_sig;
assign nextM_sig = T6_sig;      // Restart when reaching T6
assign setM1_sig = M6_sig;      // Restart when reaching M6

// ----------------- TEST -------------------
initial begin
    // Init / reset
    `T  nreset = 1;
    repeat (100) @(posedge clk); nreset <= 1;

    // This test does not use assert() -- we just check visually

    `T  $display("End of test");
end

//--------------------------------------------------------------
// Instantiate sequencer
//--------------------------------------------------------------

sequencer sequencer_inst
(
    .clk(clk) ,                         // input  clk
    .nextM(nextM_sig) ,                 // input  nextM_sig
    .setM1(setM1_sig) ,                 // input  setM1_sig
    .nreset(nreset) ,                   // input  nreset
    .hold_clk_iorq(hold_clk_iorq_sig) , // input  hold_clk_iorq_sig
    .hold_clk_wait(hold_clk_wait_sig) , // input  hold_clk_wait_sig
    .hold_clk_busrq(hold_clk_busrq_sig),// input  hold_clk_busrq_sig
    .M1(M1_sig) ,                       // output  M1_sig
    .M2(M2_sig) ,                       // output  M2_sig
    .M3(M3_sig) ,                       // output  M3_sig
    .M4(M4_sig) ,                       // output  M4_sig
    .M5(M5_sig) ,                       // output  M5_sig
    .M6(M6_sig) ,                       // output  M6_sig
    .T1(T1_sig) ,                       // output  T1_sig
    .T2(T2_sig) ,                       // output  T2_sig
    .T3(T3_sig) ,                       // output  T3_sig
    .T4(T4_sig) ,                       // output  T4_sig
    .T5(T5_sig) ,                       // output  T5_sig
    .T6(T6_sig) ,                       // output  T6_sig
    .timings_en(timings_en_sig)         // output  timings_en_sig
);

endmodule
