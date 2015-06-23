`timescale 1us/1us
// Do BCD addition
module digitadd( input [3:0] a, input [3:0] b, input cyin, output reg [3:0] z, output reg cyout);
   wire [4:0] temp;
// add everything together in binary
   assign temp={1'b0,a}+{1'b0,b}+{4'b0, cyin};
   
// Now look at the answer and decode
   always @(temp) begin
   case (temp)
     10: begin z=4'h0; cyout=1'b1; end
     11: begin z=4'h1; cyout=1'b1; end
     12: begin z=4'h2; cyout=1'b1; end
     13: begin z=4'h3; cyout=1'b1; end
     14: begin z=4'h4; cyout=1'b1; end
     15: begin z=4'h5; cyout=1'b1; end
     16: begin z=4'h6; cyout=1'b1; end
     17: begin z=4'h7; cyout=1'b1; end
     18: begin z=4'h8; cyout=1'b1; end
     19: begin z=4'h9; cyout=1'b1; end
// all other cases are easy
     default: begin z=temp[3:0];  cyout=1'b0; end
   endcase 
   end
endmodule // digitadd
