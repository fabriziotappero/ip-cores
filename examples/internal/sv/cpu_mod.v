
module cpu_mod (
  rst_n, // reset not
  clk,   // input clock
  addr,  // address
  datai,  // data in
  datao,  // data out
  w_n,   // Write  not
  ack    // ack 
);

input         rst_n;
input         clk;
output        w_n;
output [31:0] addr;
output [31:0] datao;
input  [31:0] datai;
input         ack;


wire  tack;
wire  trst_n;


endmodule
