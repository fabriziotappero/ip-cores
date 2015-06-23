module test_ps2_keyb (
    input        clk_,
    output [8:0] led_,
    inout        ps2_clk_,
    inout        ps2_data_


  );

  // Net declarations
  wire        sys_clk_0;
  wire        lock;
  wire        rst;

  // Module instances
  clock c0 (
    .CLKIN_IN   (clk_),
    .CLKDV_OUT  (sys_clk_0),
    .LOCKED_OUT (lock)
  );

  ps2_keyb #(2950, // number of clks for 60usec.
             12,   // number of bits needed for 60usec. timer
             63,   // number of clks for debounce
             6,    // number of bits needed for debounce timer
             0     // Trap the shift keys, no event generated
            ) keyboard0 (      // Instance name
    .wb_clk_i (sys_clk_0),
    .wb_rst_i (rst),
    .wb_dat_o (led_[7:0]),
    .test     (led_[8]),

    .ps2_clk_  (ps2_clk_),
    .ps2_data_ (ps2_data_)
  );

  // Continuous assignments
  assign rst = !lock;
endmodule
