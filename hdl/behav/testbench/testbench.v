/*
 * Simply RISC M1 Core Testbench
 */

`include "ddr_include.v"

module testbench();

  /*
   * Registers
   */

  // System
  reg sys_clock;
  reg sys_reset;

  /*
   * Wires
   */

  // VGA Port
  wire vga_rgb_r;
  wire vga_rgb_g;
  wire vga_rgb_b;
  wire vga_hsync;
  wire vga_vsync;

  // PS/2 Keyboard interface
  wire ps2_keyboard_clock;
  wire ps2_keyboard_data;
  wire[7:0] received_char;
  wire char_valid;

  // DDR Port
  wire ddr_clk;
  wire ddr_clk_n;
  wire ddr_clk_fb = ddr_clk;
  wire ddr_ras_n;
  wire ddr_cas_n;
  wire ddr_we_n;
  wire ddr_cke;
  wire ddr_cs_n;
  wire[`A_RNG] ddr_a;
  wire[`BA_RNG] ddr_ba;
  wire[`DQ_RNG] ddr_dq;
  wire[`DQS_RNG] ddr_dqs;
  wire[`DM_RNG] ddr_dm;

  /*
   * Module instances
   */

  // DUT (Design Under Test)
  spartan3esk_top spartan3esk_top_0 (

    // System
    .sys_clock_i(sys_clock),
    .sys_reset_i(sys_reset),

    // VGA Port
    .vga_rgb_r_o(vga_rgb_r),
    .vga_rgb_g_o(vga_rgb_g),
    .vga_rgb_b_o(vga_rgb_b),
    .vga_hsync_o(vga_hsync),
    .vga_vsync_o(vga_vsync),

    // PS/2 Keyboard interface
    .ps2_keyboard_clock_io(ps2_keyboard_clock),
    .ps2_keyboard_data_io(ps2_keyboard_data),
				     
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
    .ddr_dm(ddr_dm)

  );

  // PS/2 Keyboard model
  ps2_keyboard_model ps2_keyboard_model_0 (
    .kbd_clk_io(ps2_keyboard_clock),
    .kbd_data_io(ps2_keyboard_data),
    .last_char_received_o(received_char),
    .char_valid_o(char_valid)
  );

  // DDR model (Micron mt46v16m16)
  ddr ddr_0 (
    .Dq(ddr_dq),
    .Dqs(ddr_dqs),
    .Addr(ddr_a),
    .Ba(ddr_ba),
    .Clk(ddr_clk),
    .Clk_n(ddr_clk_n),
    .Cke(ddr_cke),
    .Cs_n(ddr_cs_n),
    .Ras_n(ddr_ras_n),
    .Cas_n(ddr_cas_n),
    .We_n(ddr_we_n),
    .Dm(ddr_dm)
  );

  /*
   * Sequential logic
   */

  // Clock
  always #10 sys_clock = !sys_clock;

  // Reset
  initial begin

    // Display start message
    $display("INFO: TBENCH(%m): Starting Simply RISC M1 Core simulation...");

    // Create VCD trace file
    $dumpfile("trace.vcd");
    $dumpvars();

    // Run the simulation
    sys_clock <= 1;
    sys_reset <= 1;
    #1000
    sys_reset <= 0;
    #99000
    $display("INFO: TBENCH(%m): Completed Simply RISC M1 Core simulation!");
    $finish;

  end

endmodule

