`include "../../../rtl/verilog/gfx/gfx_color.v"

module color_bench();

reg clk_i;

reg [1:0] color_depth_i;

reg  [31:0] color_i;
reg  [1:0]  x_lsb_i;
wire [31:0] mem_o;
wire [3:0]  mem_sel_o;

reg  [31:0] mem_i;
wire [31:0] color_o;
wire [3:0]  col_sel_o;

initial begin
  $dumpfile("color.vcd");
  $dumpvars(0,color_bench);

// init values
  clk_i = 0;
  color_depth_i = 0;
  color_i = 0;
  x_lsb_i = 0;
  mem_i = 0;

// 8 bit tests
  #10 color_i = 32'h12345678;
  mem_i = 32'habcd1234;
  #10 x_lsb_i = 1;
  #10 x_lsb_i = 2;
  #10 x_lsb_i = 3;



// 16 bit tests
  #10 color_depth_i = 1;
  x_lsb_i = 0;
  #10 x_lsb_i = 1;
  #10 x_lsb_i = 2;
  #10 x_lsb_i = 3;

// 24 bit tests (not supported!)
  #10 color_depth_i = 2;
  x_lsb_i = 0;
  #10 x_lsb_i = 1;
  #10 x_lsb_i = 2;
  #10 x_lsb_i = 3;

// 32 bit tests
  #10 color_depth_i = 3;
  x_lsb_i = 0;
  #10 x_lsb_i = 1;
  #10 x_lsb_i = 2;
  #10 x_lsb_i = 3;

// end sim
  #100 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

color_to_memory color_proc(
.color_depth_i (color_depth_i),
.color_i (color_i),
.x_lsb_i (x_lsb_i),
.mem_o (mem_o),
.sel_o (mem_sel_o)
);

memory_to_color memory_proc(
.color_depth_i (color_depth_i),
.mem_i (mem_i),
.mem_lsb_i (x_lsb_i),
.color_o (color_o),
.sel_o (col_sel_o)
);

endmodule
