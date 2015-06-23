`include "../../../rtl/verilog/gfx/gfx_blender.v"
`include "../../../rtl/verilog/gfx/gfx_color.v"

module blender_bench();
reg clk_i;
reg rst_i;

reg blending_enable_i;
reg [31:2] target_base_i;
reg [15:0] target_size_x_i;
reg [15:0] target_size_y_i;
reg [1:0] color_depth_i;

// from fragment
reg [15:0] x_counter_i;
reg [15:0] y_counter_i;
reg signed [15:0] z_i;
reg [7:0] global_alpha_i;
reg [7:0] alpha_i;
reg [31:0] pixel_color_i;
reg write_i;
reg ack_i;

// Wbm
reg target_ack_i;
wire [31:2] target_addr_o;
reg [31:0] target_data_i;
wire [3:0] target_sel_o;
wire target_request_o;
reg wbm_busy_i;

//to render
wire [15:0] pixel_x_o;
wire [15:0] pixel_y_o;
wire [31:0] pixel_color_o;
wire write_o;
wire ack_o;

initial begin
  $dumpfile("blender.vcd");
  $dumpvars(0,blender_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  write_i = 0;
  blending_enable_i = 0;
  alpha_i = 8'h80;
  global_alpha_i = 8'hff;
  x_counter_i = 0;
  y_counter_i = 0;
  z_i = 10;
  wbm_busy_i = 0;
  color_depth_i = 2'b01; // 16 bit
  target_base_i = 32'h01f00000;
  target_size_x_i = 12;
  target_size_y_i = 10;
  pixel_color_i = 32'h00001234;
  target_data_i = 32'h00000000;
  ack_i = 0;

//timing
  #4 rst_i = 0;
  #4 write_i = 1;
  #2 write_i = 0;

  #10 pixel_color_i = 32'h00005678;
  #10 pixel_color_i = 32'h00009abc;
  #10 pixel_color_i = 32'h0000f800;
// end sim
  #100 $finish;
end

always @(posedge clk_i)
begin
  ack_i <= #1 write_o;
  target_ack_i <= #1 target_request_o;
end

always begin
  #1 clk_i = ~clk_i;
end

gfx_blender blender(
.clk_i            (clk_i),
.rst_i            (rst_i),
.blending_enable_i(blending_enable_i),
.target_base_i    (target_base_i),
.target_size_x_i  (target_size_x_i),
.target_size_y_i  (target_size_y_i), 
.color_depth_i    (color_depth_i),
.x_counter_i      (x_counter_i),
.y_counter_i      (y_counter_i),
.z_i              (z_i),
.alpha_i          (alpha_i),
.global_alpha_i   (global_alpha_i),
.pixel_color_i    (pixel_color_i),
.write_i          (write_i), 
.ack_i            (ack_i),
.target_ack_i     (target_ack_i),
.target_addr_o    (target_addr_o),
.target_data_i    (target_data_i),
.target_sel_o     (target_sel_o),
.target_request_o (target_request_o),
.wbm_busy_i       (wbm_busy_i),
.pixel_x_o        (pixel_x_o), 
.pixel_y_o        (pixel_y_o),
.pixel_color_o    (pixel_color_o),
.write_o          (write_o),
.ack_o            (ack_o)
);
endmodule
