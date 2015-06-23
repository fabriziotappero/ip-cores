//==============================================================
// Test address latch and increment block
//==============================================================
`timescale 1us/ 100 ns

module test_bus;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (24) #1 clk = ~clk;

// ----------------------------------------------------
// Bi-directional bus that can also be tri-stated
reg  [15:0] abusw;          // Drive it using this bus
wire [15:0] abus;           // Read it using this bus
wire [15:0] address;        // Final address ouput

// ----------------- INPUT CONTROL -----------------
reg ctl_al_we;              // Write enable to address latch
reg ctl_bus_inc_oe;         // Write incrementer onto the internal data bus
reg ctl_apin_mux;           // Selects mux1
reg ctl_apin_mux2;          // Selects mux2

// ----------------- INC/DEC -----------------
reg ctl_inc_dec;            // Perform decrement (1) or increment (0)
reg ctl_inc_limit6;         // Limit increment to 6 bits (for incrementing IR)
reg ctl_inc_cy;             // Address increment, carry in value (+/-1 or 0)
reg ctl_inc_zero;           // Output zero from the incrementer

// ----------------- OUTPUT/STATUS -----------------
wire address_is_1;          // Signals when the final address is 1

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert(address==arg);

initial begin
    abusw = 'z;
    ctl_al_we = 0;
    ctl_bus_inc_oe = 0;
    ctl_inc_dec = 0;
    ctl_inc_limit6 = 0;
    ctl_inc_cy = 0;
    ctl_inc_zero = 0;
    ctl_apin_mux = 0;
    ctl_apin_mux2 = 0;

    //------------------------------------------------------------
    // Perform a simple increment and decrement
    `T  abusw = 16'h1234;
        ctl_al_we = 1;          // Write value to the latch
        ctl_apin_mux = 1;       // Output incrementer to the address bus
        ctl_inc_cy = 1;         // +1  show "1235"
    `T `CHECK(16'h1235);
        ctl_inc_dec = 1;        // -1  show "1233"
    `T `CHECK(16'h1233);
    // ...through overflow
        abusw = 16'hffff;
        ctl_inc_dec = 0;
        ctl_inc_cy = 1;         // +1  show "0"
    `T `CHECK(16'h0000);
        ctl_inc_dec = 1;        // -1  show "FFFE"
    `T `CHECK(16'hFFFE);
        abusw = 16'h0;
        ctl_inc_dec = 0;
        ctl_inc_cy = 1;         // +1  show "1"
    `T `CHECK(16'h0001);
        ctl_inc_dec = 1;        // -1  show "FFFF"
    `T `CHECK(16'hFFFF);
        ctl_inc_cy = 0;         // show "0000"
    `T `CHECK(16'h0000);
        ctl_inc_dec = 0;        // show "0000"

    //------------------------------------------------------------
    // Test the address latch and the mux
    `T  abusw = 16'hAA50;
        ctl_al_we = 1;          // Write AA55 to the latch
        ctl_inc_cy = 1;
    `T  ctl_al_we = 0;          // show "AA51"
    `T `CHECK(16'hAA51);
        ctl_apin_mux = 0;
        ctl_apin_mux2 = 1;

    //------------------------------------------------------------
    // Test the tri-state db
    `T  abusw = 'z;
        ctl_bus_inc_oe = 1;     // Output latched value (AA50)
    `T `CHECK(16'hAA50);

    `T  $display("End of test");
end

// Drive 3-state bidirectional bus with these statements
assign abus = abusw;

//--------------------------------------------------------------
// Instantiate address latch block
//--------------------------------------------------------------

address_latch address_latch_( .* );

endmodule
