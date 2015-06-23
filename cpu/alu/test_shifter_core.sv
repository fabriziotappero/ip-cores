//==============================================================
// Test ALU shifter core block
//==============================================================
`timescale 100 ns/ 100 ns

module test_shifter_core;

// ----------------- INPUT -----------------
logic [7:0] db;                 // Input data bus
logic shift_in;                 // Input bit to be shifted in
logic shift_left;               // Input control to left-shift
logic shift_right;              // Input control to right-shift

// ----------------- OUTPUT -----------------
wire shift_db0;                 // db[0] for shift logic
wire shift_db7;                 // db[7] for shift logic
wire [3:0] out_high;            // To internal ALU bus, high nibble
wire [3:0] out_low;             // ..low nibble

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert({out_high,out_low}==arg);

initial begin
    db = 8'h00;
    shift_left = 0;
    shift_right = 0;
    shift_in = 0;

    //------------------------------------------------------------
    // Test load without shifting
        db = 8'hAA;
    #1 `CHECK(8'hAA);
        db = 8'h55;
    #1 `CHECK(8'h55);

    //------------------------------------------------------------
    // Test right shift, no carry-in
    #1  db =  8'b00000001;
        shift_right = 1;
        shift_in = 0;
    #1 `CHECK(8'b00000000);
        db =  8'b00000010;
    #1 `CHECK(8'b00000001);
        db =  8'b00000100;
    #1 `CHECK(8'b00000010);
        db =  8'b00001000;
    #1 `CHECK(8'b00000100);
        db =  8'b00010000;
    #1 `CHECK(8'b00001000);
        db =  8'b00100000;
    #1 `CHECK(8'b00010000);
        db =  8'b01000000;
    #1 `CHECK(8'b00100000);
        db =  8'b10000000;
    #1 `CHECK(8'b01000000);

    // With carry-in
    #1  db =  8'b00000001;
        shift_in = 1;
    #1 `CHECK(8'b10000000);
        db =  8'b00000010;
    #1 `CHECK(8'b10000001);
        db =  8'b00000100;
    #1 `CHECK(8'b10000010);
        db =  8'b00001000;
    #1 `CHECK(8'b10000100);
        db =  8'b00010000;
    #1 `CHECK(8'b10001000);
        db =  8'b00100000;
    #1 `CHECK(8'b10010000);
        db =  8'b01000000;
    #1 `CHECK(8'b10100000);
        db =  8'b10000000;
    #1 `CHECK(8'b11000000);

    //------------------------------------------------------------
    // Test left shift, no carry-in
    #1  db =  8'b00000001;
        shift_right = 0;
        shift_left = 1;
        shift_in = 0;
    #1 `CHECK(8'b00000010);
        db =  8'b00000010;
    #1 `CHECK(8'b00000100);
        db =  8'b00000100;
    #1 `CHECK(8'b00001000);
        db =  8'b00001000;
    #1 `CHECK(8'b00010000);
        db =  8'b00010000;
    #1 `CHECK(8'b00100000);
        db =  8'b00100000;
    #1 `CHECK(8'b01000000);
        db =  8'b01000000;
    #1 `CHECK(8'b10000000);
        db =  8'b10000000;
    #1 `CHECK(8'b00000000);

    // With carry-in
    #1  db =  8'b00000001;
        shift_in = 1;
    #1 `CHECK(8'b00000011);
        db =  8'b00000010;
    #1 `CHECK(8'b00000101);
        db =  8'b00000100;
    #1 `CHECK(8'b00001001);
        db =  8'b00001000;
    #1 `CHECK(8'b00010001);
        db =  8'b00010000;
    #1 `CHECK(8'b00100001);
        db =  8'b00100000;
    #1 `CHECK(8'b01000001);
        db =  8'b01000000;
    #1 `CHECK(8'b10000001);
        db =  8'b10000000;
    #1 `CHECK(8'b00000001);

    //------------------------------------------------------------
    // Test right shift, no carry-in - special SRA instruction
    // This instruction simply duplicates bit [7] instead of using CY
    #1  db =  8'b00000001;
        shift_right = 1;
        shift_left = 0;
        shift_in = shift_db7;
    #1 `CHECK(8'b10000000);
        db =  8'b00000010;
    #1 `CHECK(8'b10000001);
        db =  8'b00000100;
    #1 `CHECK(8'b10000010);
        db =  8'b00001000;
    #1 `CHECK(8'b10000100);
        db =  8'b00010000;
    #1 `CHECK(8'b10001000);
        db =  8'b00100000;
    #1 `CHECK(8'b10010000);
        db =  8'b01000000;
    #1 `CHECK(8'b10100000);
        db =  8'b10000000;
    #1 `CHECK(8'b11000000);

    // With carry-in
    #1  db =  8'b00000001;
        shift_in = 1;
    #1 `CHECK(8'b10000000);
        db =  8'b00000010;
    #1 `CHECK(8'b10000001);
        db =  8'b00000100;
    #1 `CHECK(8'b10000010);
        db =  8'b00001000;
    #1 `CHECK(8'b10000100);
        db =  8'b00010000;
    #1 `CHECK(8'b10001000);
        db =  8'b00100000;
    #1 `CHECK(8'b10010000);
        db =  8'b01000000;
    #1 `CHECK(8'b10100000);
        db =  8'b10000000;
    #1 `CHECK(8'b11000000);

    #1 $display("End of test");
end

//--------------------------------------------------------------
// Instantiate shifter core block and assign identical nets and variables
//--------------------------------------------------------------

alu_shifter_core alu_shifter_core_inst( .* );

endmodule
