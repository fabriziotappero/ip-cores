`include "../../../rtl/verilog/gfx/gfx_cuvz.v"

module cuvz_bench();

parameter point_width     = 16;

reg                     clk_i;
reg                     rst_i;

reg      ack_i;
wire     ack_o;

reg      write_i;

reg  [point_width-1:0] factor0_i;
reg  [point_width-1:0] factor1_i;

reg             [31:0] color0_i;
reg             [31:0] color1_i;
reg             [31:0] color2_i;
reg              [1:0] color_depth_i;
wire            [31:0] color_o;

reg  [point_width-1:0] z0_i;
reg  [point_width-1:0] z1_i;
reg  [point_width-1:0] z2_i;
wire [point_width-1:0] z_o;

reg              [7:0] a0_i;
reg              [7:0] a1_i;
reg              [7:0] a2_i;
wire             [7:0] a_o;

reg  [point_width-1:0] u0_i;
reg  [point_width-1:0] u1_i;
reg  [point_width-1:0] u2_i;
wire [point_width-1:0] u_o;
reg  [point_width-1:0] v0_i;
reg  [point_width-1:0] v1_i;
reg  [point_width-1:0] v2_i;
wire [point_width-1:0] v_o;

reg  [point_width-1:0] x_i;
reg  [point_width-1:0] y_i;
wire [point_width-1:0] x_o;
wire [point_width-1:0] y_o;

// Write pixel output signal
wire                   write_o;

initial begin
  $dumpfile("cuvz.vcd");
  $dumpvars(0,cuvz_bench);

// init values
  clk_i = 0;
  rst_i = 1;

  x_i = 1;
  y_i = 2;
  write_i = 0;
  factor0_i = 35000;
  factor1_i = 0;
  color0_i = 255;
  color1_i = 255 << 8;
  color2_i = 255 << 16;
  color_depth_i = 3; // 0 = 8 bits, 1 = 16 bits, 3 = 32 bits
  z0_i = 150;
  z1_i = 75;
  z2_i = 0;
  a0_i = 150;
  a1_i = 75;
  a2_i = 0;
  u0_i = 0;
  u1_i = 0;
  u2_i = 0;
  v0_i = 0;
  v1_i = 0;
  v2_i = 0;


//timing
#2 rst_i = 0;
  write_i = 1;
#2 write_i = 0;

#4 write_i = 1;
  factor1_i = 10000;
#2 write_i = 0;

// end sim
  #2000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

always @(posedge clk_i)
  #1 ack_i <= write_o;

gfx_cuvz cuvz(
.clk_i     (clk_i),
.rst_i     (rst_i),
.ack_i     (ack_i),
.ack_o     (ack_o),
.write_i   (write_i),
// Variables needed for interpolation
.factor0_i (factor0_i),
.factor1_i (factor1_i),
// Color
.color0_i  (color0_i),
.color1_i  (color1_i),
.color2_i  (color2_i),
.color_depth_i (color_depth_i),
.color_o   (color_o),
// Depth
.z0_i      (z0_i),
.z1_i      (z1_i),
.z2_i      (z2_i),
.z_o       (z_o),
// Alpha
.a0_i      (a0_i),
.a1_i      (a1_i),
.a2_i      (a2_i),
.a_o       (a_o),
// Texture coordinates
.u0_i      (u0_i),
.v0_i      (v0_i),
.u1_i      (u1_i),
.v1_i      (v1_i),
.u2_i      (u2_i),
.v2_i      (v2_i),
.u_o       (u_o),
.v_o       (v_o),
// Raster position
.x_i       (x_i),
.y_i       (y_i),
.x_o       (x_o),
.y_o       (y_o),

.write_o   (write_o)
);

defparam cuvz.point_width     = point_width;

endmodule

