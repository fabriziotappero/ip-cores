module dff (input d, input clk, output reg q);
  always @(posedge clk)
    q = d;
endmodule
