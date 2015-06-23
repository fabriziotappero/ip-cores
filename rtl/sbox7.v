`include "../bench/timescale.v"
module sbox7(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h0;
        5'h01:out=2'h3;
        5'h02:out=2'h2;
        5'h03:out=2'h2;
        5'h04:out=2'h3;
        5'h05:out=2'h0;
        5'h06:out=2'h0;
        5'h07:out=2'h1;
        5'h08:out=2'h3;
        5'h09:out=2'h0;
        5'h0a:out=2'h1;
        5'h0b:out=2'h3;
        5'h0c:out=2'h1;
        5'h0d:out=2'h2;
        5'h0e:out=2'h2;
        5'h0f:out=2'h1;
        5'h10:out=2'h1;
        5'h11:out=2'h0;
        5'h12:out=2'h3;
        5'h13:out=2'h3;
        5'h14:out=2'h0;
        5'h15:out=2'h1;
        5'h16:out=2'h1;
        5'h17:out=2'h2;
        5'h18:out=2'h2;
        5'h19:out=2'h3;
        5'h1a:out=2'h1;
        5'h1b:out=2'h0;
        5'h1c:out=2'h2;
        5'h1d:out=2'h3;
        5'h1e:out=2'h0;
        5'h1f:out=2'h2;
        endcase
endmodule
