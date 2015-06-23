// Copyright 2004-2005 Openchip
// http://www.openchip.org

// ---------------------------------------------------------------------------
// Clock Prescaler
//
// For Xilinx Passive serial we use
// Divide by 16 or 1:1 clock deliver from FGPA (6MHz)
// ---------------------------------------------------------------------------

module mmc_boot_prescaler_16_1(
  rst,
  sys_clk,
  mmc_clk,
  mode_transfer
  );

input rst;
input sys_clk;
output mmc_clk;
input mode_transfer;

reg [3:0] prescaler;

always @(posedge sys_clk)
  if (rst)
    prescaler <= 4'b0000;
  else
    prescaler <= prescaler + 4'b0001;

// ---------------------------------------------------------------------------
// Select divide by 16 or direct sys_clk (CCLK)
// ---------------------------------------------------------------------------

assign mmc_clk = mode_transfer ?  sys_clk : prescaler[3]; 


endmodule
