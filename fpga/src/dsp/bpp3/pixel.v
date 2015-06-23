//
// pixel.v -- last stage in display pipeline
//


module pixel(clk, pixclk, attcode,
             pixel, blank, hsync_in, vsync_in, blink,
             hsync, vsync, r, g, b);
    input clk;
    input pixclk;
    input [7:0] attcode;
    input pixel;
    input blank;
    input hsync_in;
    input vsync_in;
    input blink;
    output reg hsync;
    output reg vsync;
    output reg r;
    output reg g;
    output reg b;

  wire blink_bit;
  wire bg_red;
  wire bg_green;
  wire bg_blue;
  wire invrs_bit;
  wire fg_red;
  wire fg_green;
  wire fg_blue;
  wire foreground;
  wire red;
  wire green;
  wire blue;

  assign blink_bit = attcode[7];
  assign bg_red = attcode[6];
  assign bg_green = attcode[5];
  assign bg_blue = attcode[4];
  assign invrs_bit = attcode[3];
  assign fg_red = attcode[2];
  assign fg_green = attcode[1];
  assign fg_blue = attcode[0];

  assign foreground =
    (pixel & ~(blink_bit & blink)) ^ invrs_bit;

  assign red = (foreground ? fg_red : bg_red);
  assign green = (foreground ? fg_green : bg_green);
  assign blue = (foreground ? fg_blue : bg_blue);

  always @(posedge clk) begin
    if (pixclk == 1) begin
      hsync <= hsync_in;
      vsync <= vsync_in;
      r <= blank & red;
      g <= blank & green;
      b <= blank & blue;
    end
  end

endmodule
