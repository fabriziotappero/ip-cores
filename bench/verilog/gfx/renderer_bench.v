`include "../../../rtl/verilog/gfx/gfx_renderer.v"
`include "../../../rtl/verilog/gfx/gfx_color.v"

module render_bench();
reg clk_i;
reg rst_i;

// Render target information, used for checking out of bounds and stride when writing pixels
reg [31:2] target_base_i;
reg [31:2] zbuffer_base_i;
reg [15:0] target_size_x_i;
reg [15:0] target_size_y_i;

reg [1:0] color_depth_i;

reg [15:0] pixel_x_i;
reg [15:0] pixel_y_i;
reg signed [15:0] pixel_z_i;
reg zbuffer_enable_i;
reg [31:0] color_i;

reg write_i;
wire write_o;

// wire registers connected to the wbm
wire [31:2] render_addr_o;
wire [3:0] render_sel_o;
wire [31:0] render_dat_o;

// TODO add ack signals
wire ack_o;
reg ack_i;


initial begin
  $dumpfile("render.vcd");
  $dumpvars(0,render_bench);

// init values
  clk_i = 1;
  rst_i = 1;
  target_base_i = 0;
  zbuffer_base_i = 64;
  target_size_x_i = 640;
  target_size_y_i = 480;
  color_depth_i = 2'b01;
  pixel_x_i = 4;
  pixel_y_i = 2;
  pixel_z_i = 2;
  zbuffer_enable_i = 0;
  color_i = 0;
  write_i = 0;
  ack_i = 0;

//timing
  #4 rst_i =0;

  #10 write_i = 1;
  #2 write_i = 0;

  #10 write_i = 1;
  zbuffer_enable_i = 1;
  #2 write_i = 0;

  #10 write_i = 1;
  #2 write_i = 0;

// end sim
  #100 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

always @(posedge clk_i)
begin  
    ack_i <= #1 write_o;
end

gfx_renderer render(
.clk_i           (clk_i), 
.rst_i           (rst_i),
.target_base_i   (target_base_i), 
.zbuffer_base_i  (zbuffer_base_i),
.target_size_x_i (target_size_x_i), 
.target_size_y_i (target_size_y_i), 
.color_depth_i   (color_depth_i),
.pixel_x_i       (pixel_x_i), 
.pixel_y_i       (pixel_y_i), 
.pixel_z_i       (pixel_z_i), 
.zbuffer_enable_i(zbuffer_enable_i),
.color_i         (color_i),
.render_addr_o   (render_addr_o), 
.render_sel_o    (render_sel_o), 
.render_dat_o    (render_dat_o),
.ack_o           (ack_o), 
.ack_i           (ack_i),
.write_i (write_i), 
.write_o (write_o)
);
endmodule
