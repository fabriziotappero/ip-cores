 /*
  *  Phase accumulator clock:
  *   Fo = Fc * N / 2^bits
  *   here N: 154619 and bits: 24
  */

module clk_uart (
    input  clk_100M,
    input  rst,
    output clk_921600,
    output rst2
  );

  // Registers
  reg [25:0] cnt;
  reg [ 2:0] init;

  // Continuous assignments
  assign clk_921600 = cnt[25];
  assign rst2 = init[2];

  // Behaviour
  // cnt
  always @(posedge clk_100M)
    cnt <= rst ? 26'd0 : cnt + 26'd154619;

  // init[0]
  always @(posedge clk_100M)
    init[0] <= rst ? 1'b1 : (clk_921600 ? 1'b0 : init[0]);

  // init[2:1]
  always @(posedge clk_921600)
    init[2:1] <= init[0] ? 2'b11 : init[1:0];
endmodule
