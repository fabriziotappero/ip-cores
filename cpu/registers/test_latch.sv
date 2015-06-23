//==============================================================
// Test 8-bit latch block
//==============================================================
`timescale 100 ns/ 100 ns

module test_latch;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (30) #1 clk = ~clk;

// ----------------------------------------------------
// Bi-directional bus with 3-state
reg  [7:0] db;              // Drive it using these wires
wire [7:0] db_sig;          // Read it using these wires

reg oe_sig;
reg we_sig;

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert(db_sig===arg);

initial begin
    oe_sig = 0;
    we_sig = 0;

    // Test bidirectional data bus and leave it at Z
    `T  db = 8'hAA;
    `T  db = 'z;
    `T `CHECK(8'hz);

    // Write a byte into the latch
    `T  db = 8'h55;
    `T  we_sig = 1;
    `T  we_sig = 0;
    `T  db = 'z;

    // Read latch
    `T  db = 'z;
    `T  oe_sig = 1;
    `T `CHECK(8'h55);
    `T  oe_sig = 0;

    `T  $display("End of test");
end

// Drive a 3-state bidirectional bus with this statement
assign db_sig = db;

//--------------------------------------------------------------
// Instantiate register latch
//--------------------------------------------------------------

reg_latch reg_latch_inst
(
    .clk(clk),
    .oe(oe_sig) ,               // input  oe_sig
    .we(we_sig) ,               // input  we_sig
    .db(db_sig[7:0])            // inout [7:0] db_sig
);

endmodule
