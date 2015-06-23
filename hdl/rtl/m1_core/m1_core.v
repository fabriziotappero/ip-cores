/*
 * Simply RISC M1 Core Top-Level
 *
 * Schematic with instances of CPU, ALU, Mul, Div and MMU
 */

module m1_core (

    // System
    input sys_clock_i,                            // System clock
    input sys_reset_i,                            // System reset
    input sys_irq_i,                              // Interrupt Request

    // Wishbone master interface
    output wb_cyc_o,                              // WB Cycle
    output wb_stb_o,                              // WB Strobe
    output wb_we_o,                               // WB Write Enable
    output[31:0] wb_adr_o,                        // WB Address
    output[31:0] wb_dat_o,                        // WB Data Out
    output[3:0] wb_sel_o,                         // WB Byte Select
    input wb_ack_i,                               // WB Ack
    input[31:0] wb_dat_i                          // WB Data In

  );
   
  /*
   * Wires
   */

  // ALU
  wire[31:0] alu_a;
  wire[31:0] alu_b;
  wire[4:0] alu_func;
  wire alu_signed;
  wire[32:0] alu_result;

  // Multiplier
  wire mul_req;
  wire[31:0] mul_a;
  wire[31:0] mul_b;
  wire mul_signed;
  wire mul_ack;
  wire[63:0] mul_product;

  // Divider
  wire div_req;
  wire[31:0] div_a;
  wire[31:0] div_b;
  wire div_signed;
  wire div_ack;
  wire[31:0] div_quotient;
  wire[31:0] div_remainder;

  // Instruction Memory
  wire imem_read;
  wire[31:0] imem_addr;
  wire imem_done;
  wire[31:0] imem_data;

  // Data Memory
  wire dmem_read;
  wire dmem_write;
  wire[31:0] dmem_addr;
  wire[31:0] dmem_data_w;
  wire[3:0] dmem_sel;
  wire dmem_done;
  wire[31:0] dmem_data_r;

  /*
   * Module instances
   */

  // CPU
  m1_cpu m1_cpu_0 (

    // System
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),
    .sys_irq_i(sys_irq_i),

    // ALU
    .alu_a_o(alu_a),
    .alu_b_o(alu_b),
    .alu_func_o(alu_func),
    .alu_signed_o(alu_signed),
    .alu_result_i(alu_result),

    // Multiplier
    .mul_req_o(mul_req),
    .mul_a_o(mul_a),
    .mul_b_o(mul_b),
    .mul_signed_o(mul_signed),
    .mul_ack_i(mul_ack),
    .mul_product_i(mul_product),

    // Divider
    .div_req_o(div_req),
    .div_a_o(div_a),
    .div_b_o(div_b),
    .div_signed_o(div_signed),
    .div_ack_i(div_ack),
    .div_quotient_i(div_quotient),
    .div_remainder_i(div_remainder),

    // Instruction Memory
    .imem_read_o(imem_read),
    .imem_addr_o(imem_addr),
    .imem_data_i(imem_data),
    .imem_done_i(imem_done),

    // Data Memory
    .dmem_read_o(dmem_read),
    .dmem_write_o(dmem_write),
    .dmem_sel_o(dmem_sel),
    .dmem_addr_o(dmem_addr),
    .dmem_data_o(dmem_data_w),
    .dmem_data_i(dmem_data_r),
    .dmem_done_i(dmem_done)

  );

  // ALU
  m1_alu m1_alu_0 (
    .a_i(alu_a),
    .b_i(alu_b),
    .func_i(alu_func),
    .signed_i(alu_signed),
    .result_o(alu_result)
  );

  // Multiplier
  m1_mul m1_mul_0 (
    .sys_reset_i(sys_reset_i),
    .sys_clock_i(sys_clock_i),

    .abp_req_i(mul_req),
    .a_i(mul_a),
    .b_i(mul_b),
    .signed_i(mul_signed),
    .abp_ack_o(mul_ack),
    .product_o(mul_product)
  );

  // Divider
  m1_div m1_div_0 (
    .sys_reset_i(sys_reset_i),
    .sys_clock_i(sys_clock_i),

    .abp_req_i(div_req),
    .a_i(div_a),
    .b_i(div_b),
    .signed_i(div_signed),
    .abp_ack_o(div_ack),
    .quotient_o(div_quotient),
    .remainder_o(div_remainder)
  );

  // MMU
  m1_mmu m1_mmu_0 (

    // System
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),

    // Instruction Memory
    .imem_read_i(imem_read),
    .imem_addr_i(imem_addr),
    .imem_data_o(imem_data),
    .imem_done_o(imem_done),

    // Data Memory
    .dmem_read_i(dmem_read),
    .dmem_write_i(dmem_write),
    .dmem_sel_i(dmem_sel),
    .dmem_addr_i(dmem_addr),
    .dmem_data_i(dmem_data_w),
    .dmem_data_o(dmem_data_r),
    .dmem_done_o(dmem_done),

    // Wishbone master interface
    .wb_cyc_o(wb_cyc_o),
    .wb_stb_o(wb_stb_o),
    .wb_we_o(wb_we_o),
    .wb_adr_o(wb_adr_o),
    .wb_dat_o(wb_dat_o),
    .wb_sel_o(wb_sel_o),
    .wb_ack_i(wb_ack_i),
    .wb_dat_i(wb_dat_i)

  );

endmodule

