`include "../../../rtl/verilog/gfx/gfx_rasterizer.v"
`include "../../../rtl/verilog/gfx/gfx_line.v"
`include "../../../rtl/verilog/gfx/gfx_triangle.v"
`include "../../../rtl/verilog/gfx/div_uu.v"
module raster_bench();

parameter point_width = 16;
parameter subpixel_width = 16;

reg clk_i;
reg rst_i;

reg clip_ack_i;
reg interp_ack_i;
wire ack_o;

reg rect_write_i;
reg line_write_i;
reg triangle_write_i;
reg interpolate_i;
reg texture_enable_i;
reg clipping_enable_i;

reg [point_width-1:0] src_pixel0_x_i;
reg [point_width-1:0] src_pixel0_y_i;
reg [point_width-1:0] src_pixel1_x_i;
reg [point_width-1:0] src_pixel1_y_i;
reg signed [point_width-1:-subpixel_width] dest_pixel0_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel0_y_i;
reg signed [point_width-1:-subpixel_width] dest_pixel1_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel1_y_i;
reg signed [point_width-1:-subpixel_width] dest_pixel2_x_i;
reg signed [point_width-1:-subpixel_width] dest_pixel2_y_i;
reg [point_width-1:0] clip_pixel0_x_i;
reg [point_width-1:0] clip_pixel0_y_i;
reg [point_width-1:0] clip_pixel1_x_i;
reg [point_width-1:0] clip_pixel1_y_i;

reg [point_width-1:0] target_size_x_i;
reg [point_width-1:0] target_size_y_i;

wire [point_width-1:0] x_counter_o;
wire [point_width-1:0] y_counter_o;
wire [point_width-1:0] u_o;
wire [point_width-1:0] v_o;
wire clip_write_o;
wire interp_write_o;

parameter FIXEDW = 2**subpixel_width;

initial begin
  $dumpfile("raster.vcd");
  $dumpvars(0,raster_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  clip_ack_i = 0;
  interp_ack_i = 0;
  rect_write_i = 0;
  line_write_i = 0;
  triangle_write_i = 0;
  interpolate_i = 0;
  dest_pixel0_x_i = -5 * FIXEDW;
  dest_pixel0_y_i = 5 * FIXEDW;
  dest_pixel1_x_i = 10 * FIXEDW;
  dest_pixel1_y_i = 10 * FIXEDW;
  dest_pixel2_x_i = 5 * FIXEDW;
  dest_pixel2_y_i = 10 * FIXEDW;
  src_pixel0_x_i = 5;
  src_pixel0_y_i = 5;
  src_pixel1_x_i = 10;
  src_pixel1_y_i = 10;
  clip_pixel0_x_i = 0;
  clip_pixel0_y_i = 0;
  clip_pixel1_x_i = 10;
  clip_pixel1_y_i = 10;
  target_size_x_i = 640;
  target_size_y_i = 480;
  texture_enable_i = 0;
  clipping_enable_i = 0;


//timing
  #4 rst_i = 0;
  #2 rect_write_i = 1;
  #2 rect_write_i = 0;

  #100 line_write_i = 1;
  #2 line_write_i = 0;
  #100 triangle_write_i = 1;
  #2 triangle_write_i = 0;

// end sim

  #1000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

always @(posedge clk_i)
begin  
  clip_ack_i     <= #1 clip_write_o;
  interp_ack_i   <= #1 interp_write_o;
end

gfx_rasterizer #(point_width, subpixel_width) raster(
.clk_i            (clk_i),
.rst_i            (rst_i),
.clip_ack_i       (clip_ack_i),
.interp_ack_i     (interp_ack_i),
.ack_o            (ack_o),
.rect_write_i     (rect_write_i),
.line_write_i     (line_write_i),
.triangle_write_i (triangle_write_i),
.interpolate_i    (interpolate_i),
.texture_enable_i (texture_enable_i),
.src_pixel0_x_i   (src_pixel0_x_i),
.src_pixel0_y_i   (src_pixel0_y_i),
.src_pixel1_x_i   (src_pixel1_x_i),
.src_pixel1_y_i   (src_pixel1_y_i),
.dest_pixel0_x_i  (dest_pixel0_x_i),
.dest_pixel0_y_i  (dest_pixel0_y_i),
.dest_pixel1_x_i  (dest_pixel1_x_i),
.dest_pixel1_y_i  (dest_pixel1_y_i),
.dest_pixel2_x_i  (dest_pixel2_x_i),
.dest_pixel2_y_i  (dest_pixel2_y_i),
.clipping_enable_i(clipping_enable_i),
.clip_pixel0_x_i  (clip_pixel0_x_i),
.clip_pixel0_y_i  (clip_pixel0_y_i),
.clip_pixel1_x_i  (clip_pixel1_x_i),
.clip_pixel1_y_i  (clip_pixel1_y_i),
.target_size_x_i  (target_size_x_i),
.target_size_y_i  (target_size_y_i),
.x_counter_o      (x_counter_o),
.y_counter_o      (y_counter_o),
.u_o              (u_o),
.v_o              (v_o),
.clip_write_o     (clip_write_o),
.interp_write_o   (interp_write_o)
);
endmodule
