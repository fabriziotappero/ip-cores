`include "../../../rtl/verilog/gfx/gfx_triangle.v"
`include "../../../rtl/verilog/gfx/div_uu.v"

module triangle_bench();

parameter point_width = 16;
parameter subpixel_width = 16;

reg clk_i;
reg rst_i;

reg ack_i;
wire ack_o;

reg triangle_write_i;
reg texture_enable_i;

reg signed [point_width-1:-subpixel_width] dest_pixel0_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel0_y_i;
reg signed [point_width-1:-subpixel_width] dest_pixel1_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel1_y_i;
reg signed [point_width-1:-subpixel_width] dest_pixel2_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel2_y_i;

wire [point_width-1:0] x_counter_o;
wire [point_width-1:0] y_counter_o;
wire write_o;


initial begin
  $dumpfile("triangle.vcd");
  $dumpvars(0,triangle_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  ack_i = 0;
  triangle_write_i = 0;
  dest_pixel0_x_i = -5 << subpixel_width;
  dest_pixel0_y_i = 5 << subpixel_width;
  dest_pixel1_x_i = 210 << subpixel_width;
  dest_pixel1_y_i = 10 << subpixel_width;
  dest_pixel2_x_i = 5 << subpixel_width;
  dest_pixel2_y_i = 210 << subpixel_width;
  texture_enable_i = 0;

//timing
  #4 rst_i = 0;

  #10 triangle_write_i = 1;
  #2 triangle_write_i = 0;

  #200 
  dest_pixel0_x_i = 5 << subpixel_width;
  dest_pixel0_y_i = 15 << subpixel_width;
  dest_pixel1_x_i = 10 << subpixel_width;
  dest_pixel1_y_i = 10 << subpixel_width;
  dest_pixel2_x_i = 5 << subpixel_width;
  dest_pixel2_y_i = 10 << subpixel_width;

  #10 triangle_write_i = 1;
  #2 triangle_write_i = 0;

// end sim

  #1000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

always @(posedge clk_i)
begin  
    ack_i <= #1 write_o;
end

gfx_triangle triangle(
.clk_i            (clk_i),
.rst_i            (rst_i),
.ack_i            (ack_i),
.ack_o            (ack_o),
.triangle_write_i (triangle_write_i),
.texture_enable_i (texture_enable_i),
.dest_pixel0_x_i  (dest_pixel0_x_i),
.dest_pixel0_y_i  (dest_pixel0_y_i),
.dest_pixel1_x_i  (dest_pixel1_x_i),
.dest_pixel1_y_i  (dest_pixel1_y_i),
.dest_pixel2_x_i  (dest_pixel2_x_i),
.dest_pixel2_y_i  (dest_pixel2_y_i),
.x_counter_o      (x_counter_o),
.y_counter_o      (y_counter_o),
.write_o          (write_o)
);

defparam triangle.point_width = point_width;
defparam triangle.subpixel_width = subpixel_width;

endmodule

