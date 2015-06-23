`include "../../../rtl/verilog/gfx/div_uu.v"
`include "../../../rtl/verilog/gfx/gfx_interp.v"
`include "../../../rtl/verilog/gfx/basic_fifo.v"

module interp_bench();

parameter point_width  = 16;
parameter delay_width  = 5;
parameter result_width = 3;

reg                       clk_i;     // system clock
reg                       rst_i;     // system reset
reg                       ack_i;     // ack

wire                      ack_o;

reg                       write_i;

reg    [2*point_width -1:0] edge0_i;   // divident
reg    [2*point_width -1:0] edge1_i;   // divident
reg    [2*point_width -1:0] area_i;    // divisor

reg    [point_width -1:0] x_i;
reg    [point_width -1:0] y_i;
wire   [point_width -1:0] x_o;
wire   [point_width -1:0] y_o;

wire   [point_width -1:0] factor0_o; // 
wire   [point_width -1:0] factor1_o; // 

wire                      write_o;

initial begin
  $dumpfile("interp.vcd");
  $dumpvars(0,interp_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  write_i = 0;

//timing
#2 rst_i = 0;

  write_i = 1;
  edge0_i = 25;
  edge1_i = 10;
  area_i  = 30;
  x_i = 15;
  y_i = 17;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 45;
  edge1_i = 67;
  area_i  = 10;
  x_i = 777;
  y_i = 888;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 67;
  edge1_i = 98;
  area_i  = 18;
  x_i = 111;
  y_i = 222;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 78;
  edge1_i = 115;
  area_i  = 11;
  x_i = 3;
  y_i = 4;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 56;
  edge1_i = 34;
  area_i  = 23;
  x_i = 5;
  y_i = 6;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 45;
  edge1_i = 67;
  area_i  = 10;
  x_i = 777;
  y_i = 888;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 67;
  edge1_i = 98;
  area_i  = 18;
  x_i = 111;
  y_i = 222;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 78;
  edge1_i = 115;
  area_i  = 11;
  x_i = 3;
  y_i = 4;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 56;
  edge1_i = 34;
  area_i  = 23;
  x_i = 5;
  y_i = 6;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 45;
  edge1_i = 67;
  area_i  = 10;
  x_i = 777;
  y_i = 888;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 67;
  edge1_i = 98;
  area_i  = 18;
  x_i = 111;
  y_i = 222;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 78;
  edge1_i = 115;
  area_i  = 11;
  x_i = 3;
  y_i = 4;
#2 write_i = 0;

#2 write_i = 1;
  edge0_i = 56;
  edge1_i = 34;
  area_i  = 23;
  x_i = 5;
  y_i = 6;
#2 write_i = 0;

// end sim
  #2000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

always @(posedge clk_i)
  ack_i <= #100 write_o;

gfx_interp interp(
.clk_i     (clk_i),
.rst_i     (rst_i),
.ack_i     (ack_i),
.ack_o     (ack_o),
.write_i   (write_i),
.edge0_i   (edge0_i),
.edge1_i   (edge1_i),
.area_i    (area_i),
.x_i       (x_i),
.y_i       (y_i),
.x_o       (x_o),
.y_o       (y_o),
.factor0_o (factor0_o),
.factor1_o (factor1_o),
.write_o   (write_o)
);

defparam interp.point_width  = point_width;
defparam interp.delay_width  = delay_width; // log2(point_width+1)
defparam interp.result_width = result_width;

endmodule

