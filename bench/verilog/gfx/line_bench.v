`include "../../../rtl/verilog/gfx/gfx_line.v"

module line_bench();

parameter point_width = 16;
parameter subpixel_width = 16;

reg clk_i;
reg rst_i;

reg signed [point_width-1:-subpixel_width] pixel0_x_i;
reg signed [point_width-1:-subpixel_width] pixel1_x_i;
reg signed [point_width-1:-subpixel_width] pixel0_y_i;
reg signed [point_width-1:-subpixel_width] pixel1_y_i;

reg [point_width-1:0] delta_major_i;
reg [point_width-1:0] delta_minor_i;

reg draw_line_i;
reg read_pixel_i;
reg x_major_i;
reg minor_slope_positive_i;

wire busy_o;

wire signed [point_width-1:0] major_o;
wire signed [point_width-1:0] minor_o;

wire x_major_o;
wire valid_o;

initial begin
  $dumpfile("line.vcd");
  $dumpvars(0,line_bench);
 
  draw_line_i = 0;
  clk_i = 0;
  rst_i = 1;
  read_pixel_i = 0;

// timing
#2 rst_i = 0;

   pixel0_x_i = -(10 << subpixel_width);
   pixel0_y_i = (10 << subpixel_width);
   pixel1_x_i = (13 << subpixel_width);
   pixel1_y_i = (15 << subpixel_width);
#2 draw_line_i = 1;
#2 draw_line_i = 0;

#112 pixel0_x_i = 10 << subpixel_width;
    pixel0_y_i = 10 << subpixel_width;
    pixel1_x_i = 20 << subpixel_width;
#2  draw_line_i = 1;
#2  draw_line_i = 0;

#100 pixel0_x_i = 10 << subpixel_width;
    pixel0_y_i = 10 << subpixel_width;
    pixel1_x_i = 20 << subpixel_width;
#2  draw_line_i = 1;
#2  draw_line_i = 0;


#100 pixel0_x_i = 10 << subpixel_width;
    pixel0_y_i = 10 << subpixel_width;
    pixel1_x_i = 20 << subpixel_width;
#2  draw_line_i = 1;
#2  draw_line_i = 0;

#100 pixel0_x_i = 10 << subpixel_width;
    pixel0_y_i = 10 << subpixel_width;
    pixel1_x_i = 20 << subpixel_width;
#2  draw_line_i = 1;
#2  draw_line_i = 0;

#100 pixel0_x_i = 10 << subpixel_width;
    pixel0_y_i = 10 << subpixel_width;
    pixel1_x_i = 20 << subpixel_width;
#2  draw_line_i = 1;
#2  draw_line_i = 0;

  #1000 $finish;
end


always begin
  #1 clk_i = ~clk_i;
  #1 read_pixel_i = valid_o;
end

bresenham_line #(point_width, subpixel_width) bresenham(
.clk_i            ( clk_i         ), 
.rst_i            ( rst_i         ),
.pixel0_x_i       ( pixel0_x_i    ), 
.pixel0_y_i       ( pixel0_y_i    ), 
.pixel1_x_i       ( pixel1_x_i    ),
.pixel1_y_i       ( pixel1_y_i    ),
.draw_line_i      ( draw_line_i   ),
.read_pixel_i     ( read_pixel_i  ),
.busy_o           ( busy_o        ),
.x_major_o        ( x_major_o     ),
.major_o          ( major_o       ),
.minor_o          ( minor_o       ),
.valid_o          ( valid_o       )
);

endmodule
