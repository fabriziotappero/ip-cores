`include "../../../rtl/verilog/gfx/gfx_clip.v"
`include "../../../rtl/verilog/gfx/gfx_color.v"

module clip_bench();

parameter point_width = 16;

reg                   clk_i;
reg                   rst_i;

reg                   clipping_enable_i;
reg                   zbuffer_enable_i;
reg            [31:2] zbuffer_base_i;
reg [point_width-1:0] target_size_x_i;
reg [point_width-1:0] target_size_y_i;
//clip pixels
reg [point_width-1:0] clip_pixel0_x_i;
reg [point_width-1:0] clip_pixel0_y_i;
reg [point_width-1:0] clip_pixel1_x_i;
reg [point_width-1:0] clip_pixel1_y_i;

// from raster
reg [point_width-1:0] raster_pixel_x_i;
reg [point_width-1:0] raster_pixel_y_i;
reg [point_width-1:0] raster_u_i;
reg [point_width-1:0] raster_v_i;
reg            [31:0] flat_color_i;
reg                   raster_write_i;
wire                  ack_o;

// from cuvz
reg [point_width-1:0] cuvz_pixel_x_i;
reg [point_width-1:0] cuvz_pixel_y_i;
reg signed [point_width-1:0] cuvz_pixel_z_i;
reg [point_width-1:0] cuvz_u_i;
reg [point_width-1:0] cuvz_v_i;
reg             [7:0] cuvz_a_i;
reg            [31:0] cuvz_color_i;
reg                   cuvz_write_i;

// Interface against wishbone master (reader)
reg                   z_ack_i;
wire           [31:2] z_addr_o;
reg            [31:0] z_data_i;
wire            [3:0] z_sel_o;
wire                  z_request_o;
reg                   wbm_busy_i;

//to render
wire [point_width-1:0] pixel_x_o;
wire [point_width-1:0] pixel_y_o;
wire [point_width-1:0] pixel_z_o;
wire [point_width-1:0] u_o;
wire [point_width-1:0] v_o;


reg  [point_width-1:0] bezier_factor0_i;
reg  [point_width-1:0] bezier_factor1_i;
wire [point_width-1:0] bezier_factor0_o;
wire [point_width-1:0] bezier_factor1_o;

wire            [31:0] color_o;
wire                   write_o;
reg                    ack_i;

initial begin
  $dumpfile("clip.vcd");
  $dumpvars(0,clip_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  cuvz_write_i = 0;
  raster_write_i = 0;
  clipping_enable_i = 0;
  clip_pixel0_x_i = 0;
  clip_pixel0_y_i = 0;
  clip_pixel1_x_i = 10;
  clip_pixel1_y_i = 10;
  raster_pixel_x_i = 0;
  raster_pixel_y_i = 0;
  cuvz_pixel_x_i = 0;
  cuvz_pixel_y_i = 0;
  cuvz_pixel_z_i = -12;
  cuvz_a_i = 0;
  bezier_factor0_i = 0;
  bezier_factor1_i = 0;
  wbm_busy_i = 0;
  zbuffer_enable_i = 1;
  zbuffer_base_i = 32'h33000000;
  target_size_x_i = 100;
  target_size_y_i = 100;
  z_data_i = 32'h80008000;
  ack_i = 0;

  flat_color_i = 0;
  cuvz_color_i = 1;

//timing
  #4 rst_i = 0;
  #4 cuvz_write_i = 1;
  #2 cuvz_write_i = 0;

  #10 cuvz_write_i = 1;
  cuvz_pixel_x_i = 20;
  cuvz_pixel_y_i = 20;
  cuvz_pixel_z_i = 12;
  #2 cuvz_write_i = 0;

  #10 raster_write_i = 1;
  clipping_enable_i = 1;
  raster_pixel_x_i = 20;
  raster_pixel_y_i = 20;
  #2 raster_write_i = 0;

// end sim
  #100 $finish;
end

always @(posedge clk_i)
begin
  ack_i <= #1 write_o;
  z_ack_i <= #1 z_request_o;
end

always begin
  #1 clk_i = ~clk_i;
end

gfx_clip clip(
.clk_i            (clk_i),
.rst_i            (rst_i),
.clipping_enable_i(clipping_enable_i),
.zbuffer_enable_i (zbuffer_enable_i),
.zbuffer_base_i   (zbuffer_base_i),
.target_size_x_i  (target_size_x_i),
.target_size_y_i  (target_size_y_i),
.clip_pixel0_x_i  (clip_pixel0_x_i),
.clip_pixel0_y_i  (clip_pixel0_y_i),
.clip_pixel1_x_i  (clip_pixel1_x_i),
.clip_pixel1_y_i  (clip_pixel1_y_i),
.raster_pixel_x_i (raster_pixel_x_i),
.raster_pixel_y_i (raster_pixel_y_i),
.raster_u_i       (raster_u_i),
.raster_v_i       (raster_v_i),
.flat_color_i     (flat_color_i),
.raster_write_i   (raster_write_i),
.cuvz_pixel_x_i   (cuvz_pixel_x_i),
.cuvz_pixel_y_i   (cuvz_pixel_y_i),
.cuvz_pixel_z_i   (cuvz_pixel_z_i),
.cuvz_u_i         (cuvz_u_i),
.cuvz_v_i         (cuvz_v_i),
.cuvz_a_i         (cuvz_a_i),
.cuvz_color_i     (cuvz_color_i),
.cuvz_write_i     (cuvz_write_i),
.ack_o            (ack_o),
.z_ack_i          (z_ack_i),
.z_addr_o         (z_addr_o),
.z_data_i         (z_data_i),
.z_sel_o          (z_sel_o),
.z_request_o      (z_request_o),
.wbm_busy_i       (wbm_busy_i),
.pixel_x_o        (pixel_x_o),
.pixel_y_o        (pixel_y_o),
.pixel_z_o        (pixel_z_o),
.u_o              (u_o),
.v_o              (v_o),
.bezier_factor0_i (bezier_factor0_i),
.bezier_factor1_i (bezier_factor1_i),
.bezier_factor0_o (bezier_factor0_o),
.bezier_factor1_o (bezier_factor1_o),
.color_o          (color_o),
.write_o          (write_o),
.ack_i            (ack_i)
);
endmodule
