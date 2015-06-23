//==============================================================
// Test interrupts unit
//==============================================================
`timescale 100 ns/ 100 ns

module test_interrupts;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (20) #1 clk = ~clk;

logic nreset = 0;

// ----------------- CONTROL ----------------
logic ctl_iff1_iff2_sig=0;
logic ctl_iffx_we_sig=0;
logic ctl_iffx_bit_sig=0;
logic nmi_sig=0;
logic setM1_sig=0;
logic intr_sig=0;
logic ctl_im_we_sig=0;
logic [1:0] db_sig=0;
logic clk_sig=0;
logic ctl_no_ints_sig=0;

// ----------------- STATES ----------------
wire iff1_sig;
wire iff2_sig;
wire im1_sig;
wire im2_sig;
wire in_nmi_sig;
wire in_intr_sig;

// ----------------- TEST -------------------
initial begin
    // Init / reset
    `T  nreset = 1;
        // Test interrupt modes
        db_sig = 2'b10;             // IM1
        ctl_im_we_sig = 1;
    `T  assert(im1_sig==1 && im2_sig==0);
        db_sig = 2'b11;             // IM2
    `T  assert(im1_sig==0 && im2_sig==1);
        db_sig = 2'b00;             // IM0
    `T  assert(im1_sig==0 && im2_sig==0);

        // Test IFF state flags
        assert(iff1_sig==0 && iff2_sig==0);
        ctl_iff1_iff2_sig = 1;
        ctl_iffx_we_sig = 1;
        ctl_iffx_bit_sig = 1;
    `T  assert(iff1_sig==0 && iff2_sig==1);
    `T  assert(iff1_sig==1 && iff2_sig==1);
        ctl_iff1_iff2_sig = 0;
        ctl_iffx_we_sig = 0;
        ctl_iffx_bit_sig = 0;

        // Simulate NMI triggering
        nmi_sig = 1;
    `T  setM1_sig = 1;
    `T  assert(iff1_sig==0 && iff2_sig==1);

    `T  $display("End of test");
end

//--------------------------------------------------------------
// Instantiate interrupts
//--------------------------------------------------------------

interrupts interrupts_inst
(
    .ctl_iff1_iff2(ctl_iff1_iff2_sig) , // input  ctl_iff1_iff2_sig
    .nmi(nmi_sig) ,                     // input  nmi_sig
    .setM1(setM1_sig) ,                 // input  setM1_sig
    .intr(intr_sig) ,                   // input  intr_sig
    .ctl_iffx_we(ctl_iffx_we_sig) ,     // input  ctl_iffx_we_sig
    .ctl_iffx_bit(ctl_iffx_bit_sig) ,   // input  ctl_iffx_bit_sig
    .ctl_im_we(ctl_im_we_sig) ,         // input  ctl_im_we_sig
    .db(db_sig) ,                       // input [1:0] db_sig
    .clk(clk) ,                         // input  clk
    .ctl_no_ints(ctl_no_ints_sig) ,     // input  ctl_no_ints_sig
    .nreset(nreset) ,                   // input  nreset
    .iff1(iff1_sig) ,                   // output  iff1_sig
    .iff2(iff2_sig) ,                   // output  iff2_sig
    .im1(im1_sig) ,                     // output  im1_sig
    .im2(im2_sig) ,                     // output  im2_sig
    .in_nmi(in_nmi_sig) ,               // output  in_nmi_sig
    .in_intr(in_intr_sig)               // output  in_intr_sig
);

endmodule
