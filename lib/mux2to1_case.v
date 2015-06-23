
module mux2to1_case (input a, input b, input sel, output reg z);

always @(sel, a, b)
  case (sel)
    1'b0    : z = a;
    1'b1    : z = b;
    default : z = 1'bx;
  endcase

endmodule
