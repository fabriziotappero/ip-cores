/*
Multibits Shift Register
2010-2011 sclai <laikos@yahoo.com>

This library is free software; you can redistribute it and/or modify it 
 under the terms of the GNU Lesser General Public License as published by 
 the Free Software Foundation; either version 2.1 of the License, 
 or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful, but 
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 USA
*/
module ddr3_sr36 #(
parameter PIPE_LEN=7
)(
input wire        clk,
input wire [35:0] shift_in,
output wire [35:0]shift_out
);
//register to hold value
reg [PIPE_LEN-1:0] d0;
reg [PIPE_LEN-1:0] d1;
reg [PIPE_LEN-1:0] d2;
reg [PIPE_LEN-1:0] d3;
reg [PIPE_LEN-1:0] d4;
reg [PIPE_LEN-1:0] d5;
reg [PIPE_LEN-1:0] d6;
reg [PIPE_LEN-1:0] d7;
reg [PIPE_LEN-1:0] d8;
reg [PIPE_LEN-1:0] d9;
reg [PIPE_LEN-1:0] d10;
reg [PIPE_LEN-1:0] d11;
reg [PIPE_LEN-1:0] d12;
reg [PIPE_LEN-1:0] d13;
reg [PIPE_LEN-1:0] d14;
reg [PIPE_LEN-1:0] d15;
reg [PIPE_LEN-1:0] d16;
reg [PIPE_LEN-1:0] d17;
reg [PIPE_LEN-1:0] d18;
reg [PIPE_LEN-1:0] d19;
reg [PIPE_LEN-1:0] d20;
reg [PIPE_LEN-1:0] d21;
reg [PIPE_LEN-1:0] d22;
reg [PIPE_LEN-1:0] d23;
reg [PIPE_LEN-1:0] d24;
reg [PIPE_LEN-1:0] d25;
reg [PIPE_LEN-1:0] d26;
reg [PIPE_LEN-1:0] d27;
reg [PIPE_LEN-1:0] d28;
reg [PIPE_LEN-1:0] d29;
reg [PIPE_LEN-1:0] d30;
reg [PIPE_LEN-1:0] d31;
reg [PIPE_LEN-1:0] d32;
reg [PIPE_LEN-1:0] d33;
reg [PIPE_LEN-1:0] d34;
reg [PIPE_LEN-1:0] d35;
always @(posedge clk)
begin
  d35 <={shift_in[35],d35[PIPE_LEN-1:1]};
  d34 <={shift_in[34],d34[PIPE_LEN-1:1]};
  d33 <={shift_in[33],d33[PIPE_LEN-1:1]};
  d32 <={shift_in[32],d32[PIPE_LEN-1:1]};
  d31 <={shift_in[31],d31[PIPE_LEN-1:1]};
  d30 <={shift_in[30],d30[PIPE_LEN-1:1]};
  d29 <={shift_in[29],d29[PIPE_LEN-1:1]};
  d28 <={shift_in[28],d28[PIPE_LEN-1:1]};
  d27 <={shift_in[27],d27[PIPE_LEN-1:1]};
  d26 <={shift_in[26],d26[PIPE_LEN-1:1]};
  d25 <={shift_in[25],d25[PIPE_LEN-1:1]};
  d24 <={shift_in[24],d24[PIPE_LEN-1:1]};
  d23 <={shift_in[23],d23[PIPE_LEN-1:1]};
  d22 <={shift_in[22],d22[PIPE_LEN-1:1]};
  d21 <={shift_in[21],d21[PIPE_LEN-1:1]};
  d20 <={shift_in[20],d20[PIPE_LEN-1:1]};
  d19 <={shift_in[19],d19[PIPE_LEN-1:1]};
  d18 <={shift_in[18],d18[PIPE_LEN-1:1]};
  d17 <={shift_in[17],d17[PIPE_LEN-1:1]};
  d16 <={shift_in[16],d16[PIPE_LEN-1:1]};
  d15 <={shift_in[15],d15[PIPE_LEN-1:1]};
  d14 <={shift_in[14],d14[PIPE_LEN-1:1]};
  d13 <={shift_in[13],d13[PIPE_LEN-1:1]};
  d12 <={shift_in[12],d12[PIPE_LEN-1:1]};
  d11 <={shift_in[11],d11[PIPE_LEN-1:1]};
  d10 <={shift_in[10],d10[PIPE_LEN-1:1]};
  d9  <={shift_in[ 9], d9[PIPE_LEN-1:1]};
  d8  <={shift_in[ 8], d8[PIPE_LEN-1:1]};
  d7  <={shift_in[ 7], d7[PIPE_LEN-1:1]};
  d6  <={shift_in[ 6], d6[PIPE_LEN-1:1]};
  d5  <={shift_in[ 5], d5[PIPE_LEN-1:1]};
  d4  <={shift_in[ 4], d4[PIPE_LEN-1:1]};
  d3  <={shift_in[ 3], d3[PIPE_LEN-1:1]};
  d2  <={shift_in[ 2], d2[PIPE_LEN-1:1]};
  d1  <={shift_in[ 1], d1[PIPE_LEN-1:1]};
  d0  <={shift_in[ 0], d0[PIPE_LEN-1:1]};
end    
  
assign shift_out={d35[0],d34[0],d33[0],d32[0],
d31[0],d30[0],d29[0],d28[0],d27[0],d26[0],d25[0],d24[0],
d23[0],d22[0],d21[0],d20[0],d19[0],d18[0],d17[0],d16[0],
d15[0],d14[0],d13[0],d12[0],d11[0],d10[0],d9[0],d8[0],
d7[0],d6[0],d5[0],d4[0],d3[0],d2[0],d1[0],d0[0]
};
endmodule



