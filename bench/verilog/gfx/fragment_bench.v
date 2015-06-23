`include "../../../rtl/verilog/gfx/gfx_fragment_processor.v"
`include "../../../rtl/verilog/gfx/gfx_color.v"

module fragment_bench();
reg clk_i;
reg rst_i;

parameter point_width = 16;

reg             [7:0] pixel_alpha_i;

// from raster
reg [point_width-1:0] x_counter_i;
reg [point_width-1:0] y_counter_i;
reg signed [point_width-1:0] z_i;
reg [point_width-1:0] u_i;
reg [point_width-1:0] v_i;
reg [point_width-1:0] bezier_factor0_i;
reg [point_width-1:0] bezier_factor1_i;
reg                   bezier_inside_i;
reg            [31:0] pixel_color_i;
reg                   write_i;
reg                   curve_write_i;
reg                   ack_i;

//to blender
wire [point_width-1:0] pixel_x_o;
wire [point_width-1:0] pixel_y_o;
wire            [31:0] pixel_color_o;
wire             [7:0] pixel_alpha_o;
wire                   write_o;
wire                   ack_o;

// to/from wishbone master read
reg                    texture_ack_i;
reg             [31:0] texture_data_i;
wire            [31:2] texture_addr_o;
wire             [3:0] texture_sel_o;
wire                   texture_request_o;

// from wishbone slave
reg                   texture_enable_i;
reg            [31:2] tex0_base_i;
reg [point_width-1:0] tex0_size_x_i;
reg [point_width-1:0] tex0_size_y_i;
reg             [1:0] color_depth_i;
reg                   colorkey_enable_i;
reg            [31:0] colorkey_i;

initial begin
  $dumpfile("fragment.vcd");
  $dumpvars(0,fragment_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  write_i = 0;
  curve_write_i = 0;
  bezier_inside_i = 0;
  texture_enable_i = 0;
  color_depth_i = 2'b01;
  ack_i = 0;
  pixel_alpha_i = 8'hff;
  pixel_color_i = 32'h12345678;
  tex0_base_i = 32'h12341234;
  tex0_size_x_i = 12;
  tex0_size_y_i = 10;
  u_i = 0;
  v_i = 0;
  z_i = 10;
  bezier_factor0_i = 0; 
  bezier_factor1_i = 0;
  x_counter_i = 0;
  y_counter_i = 0;
  texture_data_i = 32'hf800ffff;
  colorkey_enable_i = 0;
  colorkey_i = 32'h00000000;

//timing
  #4 rst_i = 0;
  #2 write_i = 1;
  #2 write_i = 0;
  #6 texture_enable_i = 1;
  #40 write_i = 1;
  #2 write_i = 0;
// end sim
  #100 $finish;
end

always @(posedge clk_i)
begin  
    ack_i <= #1 write_o;
    texture_ack_i <= #1 texture_request_o;
end

always begin
  #1 clk_i = ~clk_i;
end

gfx_fragment_processor fragment(
.clk_i            (clk_i),
.rst_i            (rst_i),
.pixel_alpha_i    (pixel_alpha_i),
.x_counter_i      (x_counter_i),
.y_counter_i      (y_counter_i),
.z_i              (z_i),
.u_i              (u_i),
.v_i              (v_i),
.bezier_factor0_i (bezier_factor0_i),
.bezier_factor1_i (bezier_factor1_i),
.bezier_inside_i  (bezier_inside_i),
.pixel_color_i    (pixel_color_i),
.write_i          (write_i),
.curve_write_i    (curve_write_i),
.ack_i            (ack_i),
.pixel_x_o        (pixel_x_o), 
.pixel_y_o        (pixel_y_o), 
.pixel_color_o    (pixel_color_o),
.pixel_alpha_o    (pixel_alpha_o),
.write_o          (write_o),
.ack_o            (ack_o),
.texture_ack_i    (texture_ack_i),
.texture_data_i   (texture_data_i),
.texture_addr_o   (texture_addr_o),
.texture_sel_o    (texture_sel_o),
.texture_request_o(texture_request_o),
.texture_enable_i (texture_enable_i),
.tex0_base_i      (tex0_base_i),
.tex0_size_x_i    (tex0_size_x_i),
.tex0_size_y_i    (tex0_size_y_i),
.color_depth_i    (color_depth_i),
.colorkey_enable_i(colorkey_enable_i),
.colorkey_i       (colorkey_i)
);
endmodule
