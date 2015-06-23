//==============================================================
// Test address and data pins blocks
//==============================================================
`timescale 1us/ 100 ns

module test_pins;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (24) #1 clk = ~clk;

// ------------------------ ADDRESS PINS ---------------------
logic [15:0] ab;            // Internal address bus
logic ctl_ab_we;            // Write enable to address pin latch
logic pin_control_oe;        // Output enable to address pins; otherwise tri-stated
wire [15:0] apin;           // Output address bus to address pins

// ------------------------ DATA PINS ------------------------
logic ctl_db_we;            // Write enable to data pin output latch
logic ctl_db_oe;            // Output enable to internal data bus
logic ctl_db_pin_re;        // Read from the data pin into the latch
logic ctl_db_pin_oe;        // Output enable to data pins; otherwise tri-stated
logic ctl_pin_oe;

// ----------------------------------------------------
// Bidirectional internal data bus
logic  [7:0] db_w;          // Drive it using this bus
wire [7:0] db;              // Read it using this bus
assign db = db_w;           // Drive 3-state bidirectional bus
always_comb                 // Output to pin bus only when our
begin                       // test is not driving it
    if (db_w==='z)
        ctl_db_oe = 1;
    else
        ctl_db_oe = 0;
end

// ----------------------------------------------------
// Bidirectional external data pins
logic  [7:0] dpin_w;        // Drive it using this bus
wire [7:0] dpin;            // Read it using this bus
assign dpin = dpin_w;       // Drive 3-state bidirectional
always_comb                 // Output to pin bus only when our
begin                       // test is not driving it
    if (dpin_w==='z)
        ctl_db_pin_oe = 1;
    else
        ctl_db_pin_oe = 0;
end

// ----------------- TEST -------------------
`define CHECKA(arg) \
   assert(apin===arg);

`define CHECKD(arg) \
   assert(dpin===arg);

initial begin
    ab = 16'h0;
    ctl_ab_we = 0;
    pin_control_oe = 0;
    db_w = 'z;
    dpin_w = 'z;
    ctl_db_we = 0;

    //------------------------------------------------------------
    // Test the address pin logic
    `T  ab = 16'hAA55;      // Latch a value and output it
        ctl_ab_we = 1;
        pin_control_oe = 1;
    `T  ctl_ab_we = 0;
    `T `CHECKA(16'hAA55);
        pin_control_oe = 0;
        ab = 16'h1234;      // Should not affect
    `T  pin_control_oe = 1;  // Toggle output on and off
    `T `CHECKA(16'hAA55);
        pin_control_oe = 0;
    `T `CHECKA(16'hz);

    //------------------------------------------------------------
    // Test the data pin logic
    `T  dpin_w = 8'hAA;     // Load and latch a value
        ctl_db_pin_re = 1;  // Read into the latch

    `T  dpin_w = 'z;
        db_w = 8'h55;
        ctl_db_pin_re = 0;
        ctl_db_we = 1;
       `CHECKD(8'hAA);
    `T  db_w = 'z;

    `T $display("End of test");
end

//--------------------------------------------------------------
// Instantiate bus block and assign identical nets and variables
//--------------------------------------------------------------

address_pins address_pins_inst( .*, .bus_ab_pin_we(ctl_ab_we), .address(ab[15:0]), .abus(apin[15:0]) );

data_pins data_pins_inst( .*, .bus_db_oe(ctl_db_pin_oe), .ctl_bus_db_we(ctl_db_we), .bus_db_pin_oe(ctl_db_pin_oe), .bus_db_pin_re(ctl_db_pin_re), .D(dpin[7:0]) );

endmodule
