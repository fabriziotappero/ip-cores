//==============================================================
// Test complete ALU block
//==============================================================
`timescale 100 ns/ 100 ns

module test_alu;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (24) #1 clk = ~clk;

// ------------------------ BUS LOGIC ------------------------
// Bus control
logic alu_oe;               // ALU unit output enable to the outside bus

// Write to the ALU internal data buses
logic alu_op1_oe;           // Enable writing by the OP1 latch
logic alu_op2_oe;           // Enable writing by the OP2 latch
logic alu_res_oe;           // Enable writing by the ALU result latch
logic alu_shift_oe;         // Enable writing by the input shifter
logic alu_bs_oe;            // Enable writing by the input bit selector
// Our own test internal mux to select ALU bus writers
logic [2:0] bus_sel;        // Select internal bus writer:

typedef enum logic[2:0] {
    BUS_HIGHZ, BUS_OP1, BUS_OP2, BUS_RES, BUS_SHIFT, BUS_BS
} bus_t;

// Mux to select only one block to drive internal ALU bus
always_comb
begin
    alu_op1_oe = 0;
    alu_op2_oe = 0;
    alu_res_oe = 0;
    alu_shift_oe = 0;
    alu_bs_oe = 0;
    case (bus_sel)
        BUS_OP1     : alu_op1_oe = 1;
        BUS_OP2     : alu_op2_oe = 1;
        BUS_RES     : alu_res_oe = 1;
        BUS_SHIFT   : alu_shift_oe = 1;
        BUS_BS      : alu_bs_oe = 1;
    endcase
end

// ------------------------ INPUT ------------------------
// Input shifter control wires and output from the shifter
logic alu_shift_in;         // Carry-in into the shifter
logic alu_shift_right;      // Shift right
logic alu_shift_left;       // Shift left
wire alu_shift_db0;         // Output db[0] from the shifter for the shift logic
wire alu_shift_db7;         // Output db[7] from the shifter for the shift logic

// Input bit selector control wires
logic [2:0] bsel;           // Selects a bit to generate

// Operator latch 1 mux select
logic alu_op1_sel_bus;      // OP1 is read from the internal bus
logic alu_op1_sel_low;      // OP1 is read from the low nibble
logic alu_op1_sel_zero;     // OP1 is loaded with zero

// Operator 2 latch mux select
logic alu_op2_sel_bus;      // OP2 is read from the internal bus
logic alu_op2_sel_lq;       // OP2 is read from the L-Q gates (see schematic)
logic alu_op2_sel_zero;     // OP2 is loaded with zero

// ALU operator mux select
logic alu_sel_op2_neg;      // Selects complemented OP2
logic alu_sel_op2_high;     // Selects high OP2 nibble as opposed to low

// ALU Core operations
logic alu_core_cf_in;       // Carry input into the ALU core
logic alu_core_R;           // Operation control "R"
logic alu_core_S;           // Operation control "S"
logic alu_core_V;           // Operation control "V"
logic alu_op_low;           // Signal to compute and store the low nibble (see schematic)
wire alu_core_cf_out;       // Output carry bit from the ALU core
wire alu_vf_out;            // Output overflow flag from the ALU

// Zero-detect, parity calculation, flag preparation and DAA-preparation logic
logic alu_parity_in;        // Input parity bit from a previous nibble
wire alu_parity_out;        // Output parity on the result and a previous nibble
wire alu_zero;              // Output signal that the result is zero
wire alu_sf_out;            // Output signal containing the result sign bit
wire alu_yf_out;            // Output signal containing the result[5] bit which is YF
wire alu_xf_out;            // Output signal containing the result[3] bit which is XF
wire alu_low_gt_9;          // Output signal that the low nibble result > 9
wire alu_high_gt_9;         // Output signal that the high nibble result > 9
wire alu_high_eq_9;         // Output signal that the high nibble result == 9

// ------------------------ BUSSES ------------------------
// Bidirectional data bus, interface to the outside world
logic  [7:0] db_w;          // Drive it using this bus
wire [7:0] db;              // Read it using this bus

wire [3:0] test_db_low;     // Test point to probe internal low nibble bus
wire [3:0] test_db_high;    // Test point to probe internal high nibble bus

// ------------------------ FLAGS  ------------------------
reg cf;                     // Carry flag
reg pf;                     // Parity flag
reg hf;                     // Half-carry flag

// ----------------- TEST -------------------
initial begin
    // Init / reset
    db_w = 8'h00;
    bus_sel = BUS_HIGHZ;

    alu_shift_in = 0;
    alu_shift_right = 0;
    alu_shift_left = 0;

    bsel = 2'h0;

    alu_op1_sel_bus = 0;
    alu_op1_sel_low = 0;
    alu_op1_sel_zero = 0;

    alu_op2_sel_bus = 0;
    alu_op2_sel_lq = 0;
    alu_op2_sel_zero = 0;

    alu_sel_op2_neg = 0;
    alu_sel_op2_high = 0;

    alu_parity_in = 0;
    alu_core_cf_in = 0;
    alu_core_R = 0;
    alu_core_S = 0;
    alu_core_V = 0;
    alu_op_low = 0;

    cf = 0;
    hf = 0;
    pf = 0;

    //------------------------------------------------------------
    // Test loading to internal bus from the input shifter through the OP1 latch
    `T  db_w = 8'h24;                   // High: 0010  Low: 0100
        bus_sel = BUS_SHIFT;
        alu_shift_right = 1;            // Enable shift and shift *right*
        alu_shift_in = 1;               // shift in <- 1
        alu_op1_sel_bus = 1;            // Write into the OP1 latch

    `T  db_w = 'z;
        alu_op1_sel_bus = 0;
        alu_shift_in = 0;
        bus_sel = BUS_OP1;              // Read back OP1 latch
        alu_shift_right = 0;
        // Expected output on the external ALU bus : 1001 0010, 0x92
    `T  assert(db==8'h92);
        // Reset
        bus_sel = BUS_HIGHZ;

    //------------------------------------------------------------
    // Test loading to internal bus from the input bit selector through the OP2 latch
    `T  db_w = 'z;                      // Not using external bus to load, but the bit-select
        bsel = 2'h3;                    // Bit 3:  0000 1000
        bus_sel = BUS_BS;
        alu_op2_sel_bus = 1;            // Write into the OP2 latch

    `T  db_w = 'z;
        alu_op2_sel_bus = 0;
        alu_shift_in = 0;
        bus_sel = BUS_OP2;
        bsel = 2'h0;
        // Expected output on the external ALU bus : 0000 1000, 0x08
    `T  assert(db==8'h08);
        // Reset
    `T  bus_sel = BUS_HIGHZ;

    //------------------------------------------------------------
    // Test the full adding function, ADD
    `T  db_w = 8'h8C;                   // Operand 1:  8C
        bus_sel = BUS_SHIFT;            // Shifter writes to internal bus
        alu_op1_sel_bus = 1;            // Write into the OP1 latch

    `T  db_w = 8'h68;                   // Operand 1:  68
        alu_op_low = 1;                 // Perform the low nibble calculation
        alu_op1_sel_bus = 0;
        bus_sel = BUS_SHIFT;            // Shifter writes to internal bus
        alu_op2_sel_bus = 1;            // Write into the OP2 latch
        // Do a low nibble addition in this cycle
        alu_sel_op2_high = 0;           // ALU select low OP nibble
        alu_parity_in = 0;              // Reset parity of the nibble
        alu_core_cf_in = 0;             // CF in 0
        alu_core_R = 0;
        alu_core_S = 0;
        alu_core_V = 0;
        hf = alu_core_cf_out;           // Load the HF with the half-carry out
        pf = alu_parity_out;            // Load the PF with the parity of the nibble result

    `T  db_w = 'z;
        alu_op_low = 0;                 // Perform the high nibble calculation
        alu_op2_sel_bus = 0;
        alu_sel_op2_high = 1;           // ALU select high OP2 nibble
        alu_core_cf_in = 0;
        alu_core_cf_in = hf;            // Carry in the half-carry
        alu_parity_in = pf;             // Parity in the parity of the low result nibble
        bus_sel = BUS_RES;              // ALU result latch writes to the bus
        // Expected output on the external ALU bus : 8C + 68 = F4
    `T  assert(db==8'hF4);
        // Reset
        bus_sel = BUS_HIGHZ;

    `T  $display("End of test");
end

//--------------------------------------------------------------
// External bus logic
assign db = db_w;           // Drive 3-state bidirectional bus
always_comb                 // Output internal ALU bus only when our
begin                       // test is not driving it
    if (db_w==='z)
        alu_oe = 1;
    else
        alu_oe = 0;
end

//--------------------------------------------------------------
// Instantiate ALU block and assign identical nets and variables
//--------------------------------------------------------------

alu alu_inst( .* );

endmodule
