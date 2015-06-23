
module  top (
  rst_n, // reset not
  clk,   //  input clock
  out1,  // output buss one
  in1,   // output buss two
  state  //  acknowlage out.
);

input rst_n;
input clk;
output [31:0] out1;
input  [31:0] in1;
output [7:0]  state;


wire  rstw;
wire  clkw;
wire  [31:0] addrw;
wire  [15:0] selw;
wire  [31:0] dataow;
wire  [31:0] dataiw;
wire  w_nw;

wire [31:0] tout1;

assign out1 = tout1;
assign clkw = clk;
assign rstw = rst_n;

bus_arb  arb (
  .rst_n  (rstw),
  .clk    (clkw),
  .addr   (addrw[31:28]),
  .sel    (selw)
);

mem_mod mem (
  .clk    (clkw),
  .addr   (addrw),
  .datai  (dataow),
  .datao  (dataiw),
  .sel    (selw[1]),
  .w_n    (w_nw)
);

gpio_mod gpio (
  .clk    (clkw),
  .rst_n  (rstw),
  .addr   (addrw),
  .datai  (dataow),
  .datao  (dataiw),
  .w_n    (w_nw),
  .sel    (selw[2]),
  .io_o   (tout1),
  .io_i   (in1)
);

cpu_mod cpu (
  .rst_n  (rstw),
  .clk    (clkw),
  .addr   (addrw),
  .datai  (dataiw),
  .datao  (dataow),
  .w_n    (w_nw),
  .ack    ()
);

endmodule
