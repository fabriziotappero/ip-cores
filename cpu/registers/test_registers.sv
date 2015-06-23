//==============================================================
// Test register control and register file blocks
//==============================================================
`timescale 100 ns/ 100 ns

module test_registers;

// ----------------- CLOCKS AND RESET -----------------
// Define one full T-clock cycle delay
`define T #2
bit clk = 1;
initial repeat (36) #1 clk = ~clk;

logic nreset = 0;

// ----------------- BUSES -----------------
// We have 4 Bi-directional buses that can also be 3-stated:

// On the address-side, there are high and low 8-bit buses
reg  [7:0] db_lo_as=8'hz;           // Drive it using this bus
wire [7:0] db_lo_as_sig;            // Read it using this bus

reg  [7:0] db_hi_as=8'hz;           // Drive it using this bus
wire [7:0] db_hi_as_sig;            // Read it using this bus

// On the data-side, there are high and low 8-bit buses
reg  [7:0] db_lo_ds=8'hz;           // Drive it using this bus
wire [7:0] db_lo_ds_sig;            // Read it using this bus

reg  [7:0] db_hi_ds=8'hz;           // Drive it using this bus
wire [7:0] db_hi_ds_sig;            // Read it using this bus

// ----------------- BUS SWITCHES ------------
logic ctl_sw_4u_sig=0;              // Bus switch #4 upstream gate
logic ctl_sw_4d_sig=0;              // Bus switch #4 downstream gate

logic ctl_reg_in_hi_sig=0;          // Input to the register file high
logic ctl_reg_in_lo_sig=0;          // Input to the register file low
logic ctl_reg_out_hi_sig=0;         // Output from the register file high
logic ctl_reg_out_lo_sig=0;         // Output from the register file low

// ----------------- CONTROL -----------------
logic [1:0] ctl_reg_gp_sel_sig=0;   // Selection of a general purpose register
logic [1:0] ctl_reg_gp_hilo_sig=0;  // Hi/Lo selector for GP registers
logic ctl_reg_gp_we_sig=0;          // Write to a general purpose register
logic [1:0] ctl_reg_sys_hilo_sig=0; // Hi/Lo selector for system registers
logic ctl_reg_sys_we_lo_sig=0;      // Write to low byte of a system register
logic ctl_reg_sys_we_hi_sig=0;      // Write to high byte of a system register
logic ctl_reg_sys_we_sig=0;         // Write to system register
logic use_ixiy_sig=0;               // Use IX or IY
logic use_ix_sig=0;                 // Use IX and not IY

logic ctl_reg_exx_sig=0;            // Exchange register banks
logic ctl_reg_ex_af_sig=0;          // Exchange AF banks
logic ctl_reg_ex_de_hl_sig=0;       // Exchange HL/DE banks
logic ctl_reg_use_sp_sig=0;         // Use SP register
logic ctl_reg_sel_pc_sig=0;         // Select PC
logic ctl_reg_sel_ir_sig=0;         // Select IR
logic ctl_reg_sel_wz_sig=0;         // Select WZ
logic ctl_reg_not_pc_sig=0;         // Do not select PC

// ----------------- TEST -------------------
`define CHECK(arg) \
   assert({db_hi_ds_sig,db_lo_ds_sig}===arg);

initial begin
    `T  nreset = 1;

    //------------------------------------------------------------
    // Identify each 16-bit system register and check access to it
    `T  ctl_sw_4d_sig = 1;          // Use unified bus: downstream
        ctl_sw_4u_sig = 0;
        ctl_reg_in_hi_sig = 1;
        ctl_reg_in_lo_sig = 1;
        db_hi_ds = 8'h81;
        db_lo_ds = 8'h41;
        ctl_reg_sys_hilo_sig = 2'b11;
        ctl_reg_sys_we_hi_sig = 1;  // 16-bit access
        ctl_reg_sys_we_lo_sig = 1;  // 16-bit access
        ctl_reg_sel_wz_sig = 1;     // WZ
    `T  db_hi_ds = 8'h82;
        db_lo_ds = 8'h42;
        ctl_reg_sel_wz_sig = 0;     // WZ off
        ctl_reg_sel_pc_sig = 1;     // PC
    `T  db_hi_ds = 8'h83;
        db_lo_ds = 8'h43;
        ctl_reg_sel_pc_sig = 0;     // PC off
        ctl_reg_sel_ir_sig = 1;     // IR
    `T  db_hi_ds = 'z;
        db_lo_ds = 'z;
        ctl_reg_sel_ir_sig = 0;     // IR off
    // Read back
        ctl_sw_4d_sig = 0;
        ctl_sw_4u_sig = 0;          // Upstream
        ctl_reg_in_hi_sig = 0;
        ctl_reg_in_lo_sig = 0;
        ctl_reg_out_hi_sig = 1;
        ctl_reg_out_lo_sig = 1;
        ctl_reg_sys_we_hi_sig = 0;
        ctl_reg_sys_we_lo_sig = 0;
        ctl_reg_sel_wz_sig = 1;     // WZ
    `T `CHECK(16'h8141);
        ctl_reg_sel_wz_sig = 0;     // WZ off
        ctl_sw_4u_sig = 1;          // Upstream
        ctl_reg_sel_pc_sig = 1;     // PC
    `T `CHECK(16'h8242);
        ctl_reg_sel_pc_sig = 0;     // PC off
        ctl_reg_sel_ir_sig = 1;     // IR
    `T `CHECK(16'h8343);
        ctl_reg_sel_ir_sig = 0;     // IR off
        ctl_sw_4d_sig = 0;
        ctl_sw_4u_sig = 0;
        ctl_reg_sys_hilo_sig = 2'b00;

    //------------------------------------------------------------
    // Identify a 16-bit system register and check access to it
    `T  ctl_reg_in_hi_sig = 1;
        ctl_reg_in_lo_sig = 1;
        ctl_reg_out_hi_sig = 0;
        ctl_reg_out_lo_sig = 0;
        ctl_reg_gp_we_sig = 1;      // Write to a GP register
        ctl_reg_gp_hilo_sig = 2'b11;// 16-bit write
        db_hi_ds = 8'hAA;
        db_lo_ds = 8'h55;
        ctl_reg_gp_sel_sig = 2'b00; // AF
    `T  db_hi_ds = 8'hAB;
        db_lo_ds = 8'h56;
        ctl_reg_gp_sel_sig = 2'b01; // BC
    `T  db_hi_ds = 8'hAC;
        db_lo_ds = 8'h57;
        ctl_reg_gp_sel_sig = 2'b10; // DE
    `T  db_hi_ds = 8'hAD;
        db_lo_ds = 8'h58;
        ctl_reg_gp_sel_sig = 2'b11; // HL
    `T  db_hi_ds = 'z;
        db_lo_ds = 'z;
    // Read back
        ctl_reg_in_hi_sig = 0;
        ctl_reg_in_lo_sig = 0;
        ctl_reg_out_hi_sig = 1;
        ctl_reg_out_lo_sig = 1;
        ctl_reg_gp_we_sig = 0;
        ctl_reg_gp_sel_sig = 2'b00; // Check AF
    `T `CHECK(16'hAA55);
        ctl_reg_gp_sel_sig = 2'b01; // Check BC
    `T `CHECK(16'hAB56);
        ctl_reg_gp_sel_sig = 2'b10; // Check DE
    `T `CHECK(16'hAC57);
        ctl_reg_gp_sel_sig = 2'b11; // Check HL
    `T `CHECK(16'hAD58);

    `T  $display("End of test");
end

// Drive 3-state bidirectional buses with these statements
assign db_lo_as_sig = db_lo_as;
assign db_hi_as_sig = db_hi_as;

assign db_lo_ds_sig = db_lo_ds;
assign db_hi_ds_sig = db_hi_ds;

// Instantiate register control block
reg_control reg_control_inst
(
    .ctl_reg_gp_sel(ctl_reg_gp_sel_sig) ,   // input [1:0] ctl_reg_gp_sel_sig
    .ctl_reg_sys_hilo(ctl_reg_sys_hilo_sig),// input [1:0] ctl_reg_sys_hilo_sig
    .ctl_reg_exx(ctl_reg_exx_sig) ,         // input  ctl_reg_exx_sig
    .ctl_reg_ex_af(ctl_reg_ex_af_sig) ,     // input  ctl_reg_ex_af_sig
    .ctl_reg_ex_de_hl(ctl_reg_ex_de_hl_sig),// input  ctl_reg_ex_de_hl_sig
    .ctl_reg_use_sp(ctl_reg_use_sp_sig) ,   // input  ctl_reg_use_sp_sig
    .ctl_reg_gp_hilo(ctl_reg_gp_hilo_sig) , // input [1:0] ctl_reg_gp_hilo_sig
    .nreset(nreset) ,                       // input  nreset
    .ctl_reg_sel_pc(ctl_reg_sel_pc_sig) ,   // input  ctl_reg_sel_pc_sig
    .ctl_reg_sel_ir(ctl_reg_sel_ir_sig) ,   // input  ctl_reg_sel_ir_sig
    .ctl_reg_sel_wz(ctl_reg_sel_wz_sig) ,   // input  ctl_reg_sel_wz_sig
    .ctl_reg_gp_we(ctl_reg_gp_we_sig) ,     // input  ctl_reg_gp_we_sig
    .ctl_reg_not_pc(ctl_reg_not_pc_sig) ,   // input  ctl_reg_not_pc_sig
    .use_ixiy(use_ixiy_sig) ,               // input  use_ixiy_sig
    .use_ix(use_ix_sig) ,                   // input  use_ix_sig
    .ctl_reg_sys_we_lo(ctl_reg_sys_we_lo_sig),// input  ctl_reg_sys_we_lo_sig
    .ctl_reg_sys_we_hi(ctl_reg_sys_we_hi_sig),// input  ctl_reg_sys_we_hi_sig
    .ctl_reg_sys_we(ctl_reg_sys_we_sig) ,   // input  ctl_reg_sys_we_sig
    .clk(clk) ,                             // input  clk
    .reg_sel_bc(reg_sel_bc_sig) ,           // output  reg_sel_bc_sig
    .reg_sel_bc2(reg_sel_bc2_sig) ,         // output  reg_sel_bc2_sig
    .reg_sel_ix(reg_sel_ix_sig) ,           // output  reg_sel_ix_sig
    .reg_sel_iy(reg_sel_iy_sig) ,           // output  reg_sel_iy_sig
    .reg_sel_de(reg_sel_de_sig) ,           // output  reg_sel_de_sig
    .reg_sel_hl(reg_sel_hl_sig) ,           // output  reg_sel_hl_sig
    .reg_sel_de2(reg_sel_de2_sig) ,         // output  reg_sel_de2_sig
    .reg_sel_hl2(reg_sel_hl2_sig) ,         // output  reg_sel_hl2_sig
    .reg_sel_af(reg_sel_af_sig) ,           // output  reg_sel_af_sig
    .reg_sel_af2(reg_sel_af2_sig) ,         // output  reg_sel_af2_sig
    .reg_sel_wz(reg_sel_wz_sig) ,           // output  reg_sel_wz_sig
    .reg_sel_pc(reg_sel_pc_sig) ,           // output  reg_sel_pc_sig
    .reg_sel_ir(reg_sel_ir_sig) ,           // output  reg_sel_ir_sig
    .reg_sel_sp(reg_sel_sp_sig) ,           // output  reg_sel_sp_sig
    .reg_sel_gp_hi(reg_sel_gp_hi_sig) ,     // output  reg_sel_gp_hi_sig
    .reg_sel_gp_lo(reg_sel_gp_lo_sig) ,     // output  reg_sel_gp_lo_sig
    .reg_sel_sys_lo(reg_sel_sys_lo_sig) ,   // output  reg_sel_sys_lo_sig
    .reg_sel_sys_hi(reg_sel_sys_hi_sig) ,   // output  reg_sel_sys_hi_sig
    .reg_gp_we(reg_gp_we_sig) ,             // output  reg_gp_we_sig
    .reg_sys_we_lo(reg_sys_we_lo_sig) ,     // output  reg_sys_we_lo_sig
    .reg_sys_we_hi(reg_sys_we_hi_sig)       // output  reg_sys_we_hi_sig
);

// Instantiate register file block
reg_file reg_file_inst
(
    .reg_sel_sys_lo(reg_sel_sys_lo_sig) ,   // input  reg_sel_sys_lo_sig
    .reg_sel_gp_lo(reg_sel_gp_lo_sig) ,     // input  reg_sel_gp_lo_sig
    .reg_sel_sys_hi(reg_sel_sys_hi_sig) ,   // input  reg_sel_sys_hi_sig
    .reg_sel_gp_hi(reg_sel_gp_hi_sig) ,     // input  reg_sel_gp_hi_sig
    .reg_sel_ir(reg_sel_ir_sig) ,           // input  reg_sel_ir_sig
    .reg_sel_pc(reg_sel_pc_sig) ,           // input  reg_sel_pc_sig
    .ctl_sw_4d(ctl_sw_4d_sig) ,             // input  ctl_sw_4d_sig
    .ctl_sw_4u(ctl_sw_4u_sig) ,             // input  ctl_sw_4u_sig
    .reg_sel_wz(reg_sel_wz_sig) ,           // input  reg_sel_wz_sig
    .reg_sel_sp(reg_sel_sp_sig) ,           // input  reg_sel_sp_sig
    .reg_sel_iy(reg_sel_iy_sig) ,           // input  reg_sel_iy_sig
    .reg_sel_ix(reg_sel_ix_sig) ,           // input  reg_sel_ix_sig
    .reg_sel_hl2(reg_sel_hl2_sig) ,         // input  reg_sel_hl2_sig
    .reg_sel_hl(reg_sel_hl_sig) ,           // input  reg_sel_hl_sig
    .reg_sel_de2(reg_sel_de2_sig) ,         // input  reg_sel_de2_sig
    .reg_sel_de(reg_sel_de_sig) ,           // input  reg_sel_de_sig
    .reg_sel_bc2(reg_sel_bc2_sig) ,         // input  reg_sel_bc2_sig
    .reg_sel_bc(reg_sel_bc_sig) ,           // input  reg_sel_bc_sig
    .reg_sel_af2(reg_sel_af2_sig) ,         // input  reg_sel_af2_sig
    .reg_sel_af(reg_sel_af_sig) ,           // input  reg_sel_af_sig
    .reg_gp_we(reg_gp_we_sig) ,             // input  reg_gp_we_sig
    .reg_sys_we_lo(reg_sys_we_lo_sig) ,     // input  reg_sys_we_lo_sig
    .reg_sys_we_hi(reg_sys_we_hi_sig) ,     // input  reg_sys_we_hi_sig
    .ctl_reg_in_hi(ctl_reg_in_hi_sig) ,     // input  ctl_reg_in_hi_sig
    .ctl_reg_in_lo(ctl_reg_in_lo_sig) ,     // input  ctl_reg_in_lo_sig
    .ctl_reg_out_lo(ctl_reg_out_lo_sig) ,   // input  ctl_reg_out_lo_sig
    .ctl_reg_out_hi(ctl_reg_out_hi_sig) ,   // input  ctl_reg_out_hi_sig
    .clk(clk) ,                             // input  clk
    .db_lo_ds(db_lo_ds_sig) ,               // inout [7:0] db_lo_ds_sig
    .db_hi_ds(db_hi_ds_sig) ,               // inout [7:0] db_hi_ds_sig
    .db_lo_as(db_lo_as_sig) ,               // inout [7:0] db_lo_as_sig
    .db_hi_as(db_hi_as_sig)                 // inout [7:0] db_hi_as_sig
);

endmodule
