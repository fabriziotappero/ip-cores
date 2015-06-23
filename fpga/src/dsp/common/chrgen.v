//
// chrgen.v -- character generator
//


module chrgen(clk, pixclk,
              chrcode, chrrow, chrcol,
              pixel,
              attcode_in, blank_in, hsync_in, vsync_in, blink_in,
              attcode_out, blank_out, hsync_out, vsync_out, blink_out);
    input clk;
    input pixclk;
    input [7:0] chrcode;
    input [3:0] chrrow;
    input [2:0] chrcol;
    output pixel;
    input [7:0] attcode_in;
    input blank_in;
    input hsync_in;
    input vsync_in;
    input blink_in;
    output reg [7:0] attcode_out;
    output reg blank_out;
    output reg hsync_out;
    output reg vsync_out;
    output reg blink_out;

  wire [13:0] addr;
  wire [0:0] pixel_lo;
  wire [0:0] pixel_hi;

  reg mux_ctrl;

  assign addr[13:7] = chrcode[6:0];
  assign addr[6:3] = chrrow[3:0];
  assign addr[2:0] = chrcol[2:0];

  assign pixel = (mux_ctrl == 0) ? pixel_lo[0] : pixel_hi[0];

  // RAMB16_S1: Spartan-3 16kx1 Single-Port RAM

  RAMB16_S1 character_rom_lo (
    .DO(pixel_lo),  // 1-bit Data Output
    .ADDR(addr),    // 14-bit Address Input
    .CLK(clk),      // Clock
    .DI(1'b0),      // 1-bit Data Input
    .EN(pixclk),    // RAM Enable Input
    .SSR(1'b0),     // Synchronous Set/Reset Input
    .WE(1'b0)       // Write Enable Input
  );

  `include "chrgenlo.init"

  // RAMB16_S1: Spartan-3 16kx1 Single-Port RAM

  RAMB16_S1 character_rom_hi (
    .DO(pixel_hi),  // 1-bit Data Output
    .ADDR(addr),    // 14-bit Address Input
    .CLK(clk),      // Clock
    .DI(1'b0),      // 1-bit Data Input
    .EN(pixclk),    // RAM Enable Input
    .SSR(1'b0),     // Synchronous Set/Reset Input
    .WE(1'b0)       // Write Enable Input
  );

  `include "chrgenhi.init"

  always @(posedge clk) begin
    if (pixclk == 1) begin
      attcode_out[7:0] <= attcode_in[7:0];
      blank_out <= blank_in;
      hsync_out <= hsync_in;
      vsync_out <= vsync_in;
      blink_out <= blink_in;
      mux_ctrl <= chrcode[7];
    end
  end

endmodule
