`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    02:05:46 08/01/2008
// Design Name:
// Module Name:    test_vdu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module test_vdu (
    input         sys_clk_in,
    output       tft_lcd_clk,
    output [1:0] tft_lcd_r,
    output [1:0] tft_lcd_g,
    output [1:0] tft_lcd_b,
    output       tft_lcd_hsync,
    output       tft_lcd_vsync,

    output led
  );

  // Net declarations
  wire lock, rst;

  // Module instantiations
  clock clk0 (
    .CLKIN_IN   (sys_clk_in),
    .CLKDV_OUT  (tft_lcd_clk),
    .LOCKED_OUT (lock)
  );

  vdu vdu0 (
    .wb_rst_i    (rst),
    .wb_clk_i    (tft_lcd_clk),     // 25MHz	VDU clock
    .vga_red_o   (tft_lcd_r),
    .vga_green_o (tft_lcd_g),
    .vga_blue_o  (tft_lcd_b),
    .horiz_sync  (tft_lcd_hsync),
    .vert_sync   (tft_lcd_vsync)
  );

  // Continuous assignments
  assign rst = !lock;
  assign led = 1'b1;
endmodule
