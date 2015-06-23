/*
 * Simply RISC M1 Core System for Xilinx Spartan-3E 500 Starter Kit
 */

`include "ddr_include.v"

module spartan3esk_top (

    // System
    input sys_clock_i,
    input sys_reset_i,

    // VGA Port
    output vga_rgb_r_o,
    output vga_rgb_g_o,
    output vga_rgb_b_o,
    output vga_hsync_o,
    output vga_vsync_o,

    // PS/2 Keyboard interface
    inout ps2_keyboard_clock_io,
    inout ps2_keyboard_data_io,

    // DDR Port
    output ddr_clk,
    output ddr_clk_n,
    input ddr_clk_fb,
    output ddr_ras_n,
    output ddr_cas_n,
    output ddr_we_n,
    output ddr_cke,
    output ddr_cs_n,
    output[`A_RNG] ddr_a,
    output[`BA_RNG] ddr_ba,
    inout[`DQ_RNG] ddr_dq,
    inout[`DQS_RNG] ddr_dqs,
    output[`DM_RNG] ddr_dm

  );

  /*
   * Wires
   */

  // Interrupts
  wire sys_irq;
  wire[31:0] sys_irqs;
  assign sys_irqs[31:1] = 31'h00000000;

  // Rotary interface
  wire[2:0] rot = 3'b000;

  // PS/2 Keyboard interface
  wire ps2_keyboard_clock_i;
  wire ps2_keyboard_data_i;
  wire ps2_keyboard_clock_o;
  wire ps2_keyboard_data_o;
  wire ps2_keyboard_clock_padoe_o;
  wire ps2_keyboard_data_padoe_o;
  assign ps2_keyboard_clock_io  = (ps2_keyboard_clock_padoe_o  ? ps2_keyboard_clock_o  : 1'bZ);
  assign ps2_keyboard_data_io = (ps2_keyboard_data_padoe_o ? ps2_keyboard_data_o : 1'bZ);

  // Wishbone interface
  wire wb_cyc_core, wb_cyc_intc, wb_cyc_text, wb_cyc_ps2, wb_cyc_ddr;
  wire wb_stb_core, wb_stb_intc, wb_stb_text, wb_stb_ps2, wb_stb_ddr;
  wire wb_we_core, wb_we_intc, wb_we_text, wb_we_ps2, wb_we_ddr;
  wire[31:0] wb_adr_core, wb_adr_intc, wb_adr_text, wb_adr_ps2, wb_adr_ddr;
  wire[31:0] wb_wdat_core, wb_wdat_intc, wb_wdat_text, wb_wdat_ps2, wb_wdat_ddr;
  wire[3:0] wb_sel_core, wb_sel_intc, wb_sel_text, wb_sel_ps2, wb_sel_ddr;
  wire wb_ack_core, wb_ack_intc, wb_ack_text, wb_ack_ps2, wb_ack_ddr;
  wire[31:0] wb_rdat_core, wb_rdat_intc, wb_rdat_text, wb_rdat_ps2, wb_rdat_ddr;

  // The most significant byte of the address is used to select the destination
  wire request_to_ddr = (wb_stb_core && wb_cyc_core && wb_adr_core[31:24]==8'h00);
  wire request_to_intc = (wb_stb_core && wb_cyc_core && wb_adr_core[31:24]==8'hF8);
  wire request_to_text = (wb_stb_core && wb_cyc_core && wb_adr_core[31:24]==8'hFA);
  wire request_to_ps2 = (wb_stb_core && wb_cyc_core && wb_adr_core[31:24]==8'hFB);

  // Select outputs connected to M1 Core inputs
  assign wb_ack_core = (request_to_ddr ? wb_ack_ddr :
    (request_to_intc ? wb_ack_intc :
      (request_to_text ? wb_ack_text : wb_ack_ps2) ) );
  assign wb_rdat_core = (request_to_ddr ? wb_rdat_ddr :
    (request_to_intc ? wb_rdat_intc :
      (request_to_text ? wb_rdat_text : wb_rdat_ps2) ) );

  // Select outputs connected to Interrupt Controller inputs
  assign wb_cyc_intc = (request_to_intc ? wb_cyc_core : 1'b0);
  assign wb_stb_intc = (request_to_intc ? wb_stb_core : 1'b0);
  assign wb_adr_intc = (request_to_intc ? wb_adr_core : 32'h00000000);
  assign wb_we_intc = (request_to_intc ? wb_we_core : 1'b0);
  assign wb_sel_intc = (request_to_intc ? wb_sel_core : 4'b0000);
  assign wb_wdat_intc = (request_to_intc ? wb_wdat_core : 32'h00000000);

  // Select outputs connected to Text-only VGA Controller inputs
  assign wb_cyc_text = (request_to_text ? wb_cyc_core : 1'b0);
  assign wb_stb_text = (request_to_text ? wb_stb_core : 1'b0);
  assign wb_adr_text = (request_to_text ? wb_adr_core : 32'h00000000);
  assign wb_we_text = (request_to_text ? wb_we_core : 1'b0);
  assign wb_sel_text = (request_to_text ? wb_sel_core : 4'b0000);
  assign wb_wdat_text = (request_to_text ? wb_wdat_core : 32'h00000000);

  // Select outputs connected to PS/2 Keyboard Interface inputs
  assign wb_cyc_ps2 = (request_to_ps2 ? wb_cyc_core : 1'b0);
  assign wb_stb_ps2 = (request_to_ps2 ? wb_stb_core : 1'b0);
  assign wb_adr_ps2 = (request_to_ps2 ? wb_adr_core : 32'h00000000);
  assign wb_we_ps2 = (request_to_ps2 ? wb_we_core : 1'b0);
  assign wb_sel_ps2 = (request_to_ps2 ? wb_sel_core : 4'b0000);
  assign wb_wdat_ps2 = (request_to_ps2 ? wb_wdat_core : 32'h00000000);

  // Select outputs connected to DDR Controller inputs
  assign wb_cyc_ddr = (request_to_ddr ? wb_cyc_core : 1'b0);
  assign wb_stb_ddr = (request_to_ddr ? wb_stb_core : 1'b0);
  assign wb_adr_ddr = (request_to_ddr ? wb_adr_core : 32'h00000000);
  assign wb_we_ddr = (request_to_ddr ? wb_we_core : 1'b0);
  assign wb_sel_ddr = (request_to_ddr ? wb_sel_core : 4'b0000);
  assign wb_wdat_ddr = (request_to_ddr ? wb_wdat_core : 32'h00000000);

  /*
   * Module instances
   */

  // M1 Core
  m1_core m1_core_0 (

    // System
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),
    .sys_irq_i(sys_irq),

    // Wishbone master interface
    .wb_cyc_o(wb_cyc_core),
    .wb_stb_o(wb_stb_core),
    .wb_we_o(wb_we_core),
    .wb_sel_o(wb_sel_core),
    .wb_adr_o(wb_adr_core),
    .wb_dat_o(wb_wdat_core),
    .wb_ack_i(wb_ack_core),
    .wb_dat_i(wb_rdat_core)

  );

  // Interrupt Controller
  wb_int_ctrl wb_int_ctrl_0 (

    // System
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),

    // Interrupts
    .sys_irqs_i(sys_irqs),
    .sys_irq_o(sys_irq),

    // Wishbone slave interface
    .wb_cyc_i(wb_cyc_intc),
    .wb_stb_i(wb_stb_intc),
    .wb_adr_i(wb_adr_intc),
    .wb_we_i(wb_we_intc),
    .wb_sel_i(wb_sel_intc),
    .wb_dat_i(wb_wdat_intc),
    .wb_ack_o(wb_ack_intc),
    .wb_dat_o(wb_rdat_intc)

  );

  // Text-only VGA Controller
  wb_text_vga wb_text_vga_0 (

    // System
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),

    // Wishbone slave interface
    .wb_cyc_i(wb_cyc_text),
    .wb_stb_i(wb_stb_text),
    .wb_adr_i(wb_adr_text),
    .wb_we_i(wb_we_text),
    .wb_sel_i(wb_sel_text),
    .wb_dat_i(wb_wdat_text),
    .wb_ack_o(wb_ack_text),
    .wb_dat_o(wb_rdat_text),

    // VGA Port
    .vga_rgb_r_o(vga_rgb_r_o),
    .vga_rgb_g_o(vga_rgb_g_o),
    .vga_rgb_b_o(vga_rgb_b_o),
    .vga_hsync_o(vga_hsync_o),
    .vga_vsync_o(vga_vsync_o)

  );

  // PS/2 Keyboard Interface
  ps2_top wb_ps2_keyboard_0
  (

    // System
    .wb_clk_i(sys_clock_i),
    .wb_rst_i(sys_reset_i),
   
    // Wishbone slave interface
    .wb_cyc_i(wb_cyc_ps2),
    .wb_stb_i(wb_stb_ps2),
    .wb_we_i(wb_we_ps2),
    .wb_sel_i(wb_sel_ps2),
    .wb_adr_i(wb_adr_ps2[3:0]),
    .wb_dat_i(wb_wdat_ps2),
    .wb_dat_o(wb_rdat_ps2),
    .wb_ack_o(wb_ack_ps2),

    // Interrupt
    .wb_int_o(sys_irqs[0]),

    // PS/2 Keyboard Port
    .ps2_kbd_clk_pad_i(ps2_keyboard_clock_i),
    .ps2_kbd_data_pad_i(ps2_keyboard_data_i),
    .ps2_kbd_clk_pad_o(ps2_keyboard_clock_o),
    .ps2_kbd_data_pad_o(ps2_keyboard_data_o),
    .ps2_kbd_clk_pad_oe_o(ps2_keyboard_clock_padoe_o),
    .ps2_kbd_data_pad_oe_o(ps2_keyboard_data_padoe_o)

  );
   
  // DDR Controller
  wb_ddr wb_ddr_0 (

    // System
    .clk(sys_clock_i),
    .reset(sys_reset_i),

    // DDR Port
    .ddr_clk(ddr_clk),
    .ddr_clk_n(ddr_clk_n),
    .ddr_clk_fb(ddr_clk_fb),
    .ddr_ras_n(ddr_ras_n),
    .ddr_cas_n(ddr_cas_n),
    .ddr_we_n(ddr_we_n),
    .ddr_cke(ddr_cke),
    .ddr_cs_n(ddr_cs_n),
    .ddr_a(ddr_a),
    .ddr_ba(ddr_ba),
    .ddr_dq(ddr_dq),
    .ddr_dqs(ddr_dqs),
    .ddr_dm(ddr_dm),

    // Wishbone master interface
    .wb_cyc_i(wb_cyc_ddr),
    .wb_stb_i(wb_stb_ddr),
    .wb_we_i(wb_we_ddr),
    .wb_adr_i(wb_adr_ddr),
    .wb_dat_o(wb_rdat_ddr),
    .wb_dat_i(wb_wdat_ddr),
    .wb_sel_i(wb_sel_ddr),
    .wb_ack_o(wb_ack_ddr),

    // phase shifting
    .rot(rot)

  );


endmodule

