`include "../../../rtl/verilog/gfx/gfx_transform.v"

module transform_bench();

reg clk_i;
reg rst_i;

parameter point_width = 16;
parameter subpixel_width = 16;

reg signed [point_width-1:-subpixel_width] x_i;
reg signed [point_width-1:-subpixel_width] y_i;
reg signed [point_width-1:-subpixel_width] z_i;
reg                           [1:0] point_id_i; // point 0,1,2,3

reg signed [point_width-1:-subpixel_width] aa;
reg signed [point_width-1:-subpixel_width] ab;
reg signed [point_width-1:-subpixel_width] ac;
reg signed [point_width-1:-subpixel_width] tx;
reg signed [point_width-1:-subpixel_width] ba;
reg signed [point_width-1:-subpixel_width] bb;
reg signed [point_width-1:-subpixel_width] bc;
reg signed [point_width-1:-subpixel_width] ty;
reg signed [point_width-1:-subpixel_width] ca;
reg signed [point_width-1:-subpixel_width] cb;
reg signed [point_width-1:-subpixel_width] cc;
reg signed [point_width-1:-subpixel_width] tz;

wire signed [point_width-1:-subpixel_width] p0_x_o;
wire signed [point_width-1:-subpixel_width] p0_y_o;
wire signed               [point_width-1:0] p0_z_o;
wire signed [point_width-1:-subpixel_width] p1_x_o;
wire signed [point_width-1:-subpixel_width] p1_y_o;
wire signed               [point_width-1:0] p1_z_o;
wire signed [point_width-1:-subpixel_width] p2_x_o;
wire signed [point_width-1:-subpixel_width] p2_y_o;
wire signed               [point_width-1:0] p2_z_o;

wire signed [point_width-1:0] p0_x_int = p0_x_o[point_width-1:0];
wire signed [point_width-1:0] p0_y_int = p0_y_o[point_width-1:0];
wire signed [point_width-1:0] p1_x_int = p1_x_o[point_width-1:0];
wire signed [point_width-1:0] p1_y_int = p1_y_o[point_width-1:0];
wire signed [point_width-1:0] p2_x_int = p2_x_o[point_width-1:0];
wire signed [point_width-1:0] p2_y_int = p2_y_o[point_width-1:0];

reg transform_i, forward_i;

wire ack_o;

parameter FIXEDW = (1<<subpixel_width);

initial begin
  $dumpfile("transform.vcd");
  $dumpvars(0,transform_bench);
 
  clk_i = 0;
  rst_i = 1;

  transform_i   = 0;
  forward_i     = 0;
  x_i        = 0;
  y_i        = 0;
  z_i        = 0;
  point_id_i = 0;
  // Set transform to identity
  aa  = -1 * FIXEDW;
  ab  = 0;
  ac  = 0;
  tx  = 10 * FIXEDW;
  ba  = 0;
  bb  = 1 * FIXEDW;
  bc  = 0;
  ty  = 15 * FIXEDW;
  ca  = 0;
  cb  = 0;
  cc  = 1 * FIXEDW;
  tz  = -20 * FIXEDW;

// timing
#2 rst_i = 0;
  transform_i = 1;
  x_i = -20 * FIXEDW;
  y_i = 0;
  z_i = 0;
  point_id_i = 0;

#4 point_id_i = 1;
#4 point_id_i = 2;
#4 forward_i = 0;

#10  transform_i = 1;
  point_id_i = 0;
  aa = 2*FIXEDW;
  ab = 1*FIXEDW;
  ac = 0;

  #1000 $finish;
end


always begin
  #1 clk_i = ~clk_i;
end

gfx_transform transform(
.clk_i           (clk_i),
.rst_i           (rst_i),
.x_i             (x_i),
.y_i             (y_i),
.z_i             (z_i),
.point_id_i      (point_id_i),
// Matrix
.aa              (aa),
.ab              (ab),
.ac              (ac),
.tx              (tx),
.ba              (ba),
.bb              (bb),
.bc              (bc),
.ty              (ty),
.ca              (ca),
.cb              (cb),
.cc              (cc),
.tz              (tz),
// Output points
.p0_x_o          (p0_x_o),
.p0_y_o          (p0_y_o),
.p0_z_o          (p0_z_o),
.p1_x_o          (p1_x_o),
.p1_y_o          (p1_y_o),
.p1_z_o          (p1_z_o),
.p2_x_o          (p2_x_o),
.p2_y_o          (p2_y_o),
.p2_z_o          (p2_z_o),
.transform_i     (transform_i),
.forward_i       (forward_i),
.ack_o           (ack_o)
);

defparam transform.point_width = point_width;
defparam transform.subpixel_width = subpixel_width;

endmodule

