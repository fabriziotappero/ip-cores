//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 32 bit 4:1 Multiplexer
//--------------------------------------------------------------------------------

module mux_41 
   (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [1:0] sel,
    output reg [31:0] o
    );

  always @ (a or b or c or d or sel)
  begin
    case (sel)
      2'b00: 
          o = a;
      2'b01: 
          o = b;
      2'b10: 
          o = c; 
      2'b11:
          o = d;  
     endcase     
  end

endmodule

