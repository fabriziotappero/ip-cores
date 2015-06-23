//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 2 bit 2:1 Multiplexer
//--------------------------------------------------------------------------------

module mux_21 
   (
    input wire [1:0] a,
    input wire [1:0] b,
    input wire   sel,
    output reg [1:0] o
    );

  always @ (a or b or sel)
  begin
    case (sel)
      1'b0: 
          o = a;
      1'b1: 
          o = b;
    endcase
  end

endmodule

