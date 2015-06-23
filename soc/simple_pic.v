`include "defines.v"

module simple_pic (
`ifdef DEBUG
    output reg [1:0] irr,
`endif
    input        clk,
    input        rst,
    input  [1:0] int,
    input        inta,
    output       intr,
    output reg   iid
  );

  // Registers
`ifndef DEBUG
  reg [1:0] irr;
`endif

  // Continuous assignments
  assign intr = |irr;

  // Behaviour
  // irr
  always @(posedge clk)
    irr[0] <= rst ? 1'b0 : (int[0] | irr[0] & (iid | !inta));

  always @(posedge clk)
    irr[1] <= rst ? 1'b0 : (int[1] | irr[1] & !(iid & inta));

  // iid
  always @(posedge clk)
    iid <= rst ? 1'b0 : (!irr[0] | inta);

endmodule
