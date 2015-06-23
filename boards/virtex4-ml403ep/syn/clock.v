module clock #(
    parameter div = 16  // main clock divider
  ) (
    input  sys_clk_in_,
    output clk,
    output clk_100M,
    output vdu_clk,
    output rst
  );

  // Register declarations
  reg [6:0] count;

  // Net declarations
  wire ref_clk;
  wire ref_clk0;
  wire lock;
  wire vdu_lock;
  wire fpga_lock;
  wire vdu_clk0;
  wire fpga_fb;
  wire fpga_fb0;
  wire fpga_clk0;

  // Module instantiations
  IBUFG ref_buf (
    .O (ref_clk),
    .I (sys_clk_in_)
  );

  // DCM for the VGA - 25 Mhz
  DCM_ADV vdu_dcm (
    .CLKIN  (ref_clk),
    .CLKFB  (clk_100M),
    .CLK0   (ref_clk0),
    .CLKDV  (vdu_clk0),
    .RST    (1'b0),
    .LOCKED (vdu_lock)
  );
  defparam vdu_dcm.CLKIN_PERIOD = 10.000;
  defparam vdu_dcm.CLKDV_DIVIDE = 4;
  defparam vdu_dcm.DCM_AUTOCALIBRATION = "FALSE";

  BUFG b_clk_100M (
    .O (clk_100M),
    .I (ref_clk0)
  );

  BUFG b_vdu_clk (
    .O (vdu_clk),
    .I (vdu_clk0)
  );

  // fpga DCM
  DCM_ADV fpga_dcm (
    .CLKIN  (ref_clk),
    .CLKFB  (fpga_fb),
    .CLK0   (fpga_fb0),
    .CLKDV  (fpga_clk0),
    .RST    (1'b0),
    .LOCKED (fpga_lock)
  );
  defparam fpga_dcm.CLKIN_PERIOD = 10.000;
  defparam fpga_dcm.CLKDV_DIVIDE = div;
  defparam fpga_dcm.DCM_AUTOCALIBRATION = "FALSE";

  BUFG b_fpga_fb (
    .O (fpga_fb),
    .I (fpga_fb0)
  );

  BUFG b_fpga_clk (
    .O (clk),
    .I (fpga_clk0)
  );

  // Continuous assignments
  assign rst    = (count!=7'h7f);
  assign lock   = vdu_lock & fpga_lock;

  // Behavioral description
  // count
  always @(posedge clk)
    if (!lock) count <= 7'b0;
    else count <= (count==7'h7f) ? count : (count + 7'h1);

endmodule
