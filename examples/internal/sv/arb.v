
module bus_arb (
  rst_n, // reset not
  clk,   // input clock
  addr,  // address
  sel    // selects
);


input        rst_n;
input        clk;
input  [3:0] addr;
output [15:0] sel;

reg [15:0] tsel;
assign sel = tsel;

  always @(addr) begin
    case (addr)
      0:  tsel = 16'h0001;
      1:  tsel = 16'h0002;
      2:  tsel = 16'h0004;
      3:  tsel = 16'h0008;
      4:  tsel = 16'h0010;
      5:  tsel = 16'h0020;
      6:  tsel = 16'h0040;
      7:  tsel = 16'h0080;
      8:  tsel = 16'h0100;
      9:  tsel = 16'h0200;
      10: tsel = 16'h0400;
      11: tsel = 16'h0800;
      12: tsel = 16'h1000;
      13: tsel = 16'h2000;
      14: tsel = 16'h4000;
      15: tsel = 16'h8000;
    endcase
  end


endmodule
