// Copyright (C) 2012
// Ashwin A. Mendon
//
// This file is part of SATA2 core.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.



////////////////////////////////////////////////////////////////////////////////////////
// ENTITY: scrambler
// Version: 1.0
// Author:  Ashwin Mendon
// Description: This sub/module implements the Scrambler Circuit for the SATA Protocol
//              The code provides a parallel implementation of the following
//              generator polynomial
//                          16  15  13  4
//                  G(x) = x + x + x + x + 1
//              The output of this scrambler is then XORed with the input data DWORD
//              The scrambler is initialized to a value of 0xF0F6.
//              The first DWORD output of the implementation is equal to 0xC2D2768D
// PORTS:
/////////////////////////////////////////////////////////////////////////////////////////


module scrambler (
  clk,
  rst,
  en,
  prim_scrambler,
  din,
  dout
);
input               clk;
input               rst;
input               en;
input               prim_scrambler;
input   [31:0]      din;
output  [31:0]      dout;

//Parameters
parameter           SCRAMBLER_INIT  = 16'hF0F6;

//Registers/Wires
reg     [15:0]      context;
wire    [31:0]      context_next;
reg     [31:0]      context_reg;

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    context         <=  SCRAMBLER_INIT;
    context_reg     <=  32'h0;
  end
  else begin
    if (en) begin
      context         <=  context_next[31:16];
      context_reg     <=  context_next;
    end
  end
end

assign  dout           =  (prim_scrambler) ? context_reg : context_reg ^ din;

//Aysnchronous Logic
assign context_next[31] =  context[12] ^
                           context[10] ^
                           context[7]  ^
                           context[3]  ^
                           context[1]  ^
                           context[0];

assign context_next[30] =  context[15] ^
                           context[14] ^
                           context[12] ^
                           context[11] ^
                           context[9]  ^
                           context[6]  ^
                           context[3]  ^
                           context[2]  ^
                           context[0];

assign context_next[29] =  context[15] ^
                           context[13] ^
                           context[12] ^
                           context[11] ^
                           context[10] ^
                           context[8]  ^
                           context[5]  ^
                           context[3]  ^
                           context[2]  ^
                           context[1];

assign context_next[28] =  context[14] ^
                           context[12] ^
                           context[11] ^
                           context[10] ^
                           context[9]  ^
                           context[7]  ^
                           context[4]  ^
                           context[2]  ^
                           context[1]  ^
                           context[0];

assign context_next[27] =  context[15] ^
                           context[14] ^
                           context[13] ^
                           context[12] ^
                           context[11] ^
                           context[10] ^
                           context[9]  ^
                           context[8]  ^
                           context[6]  ^
                           context[1]  ^
                           context[0];

assign context_next[26] =  context[15] ^
                           context[13] ^
                           context[11] ^
                           context[10] ^
                           context[9]  ^
                           context[8]  ^
                           context[7]  ^
                           context[5]  ^
                           context[3]  ^
                           context[0];

assign context_next[25] =  context[15] ^
                           context[10] ^
                           context[9]  ^
                           context[8]  ^
                           context[7]  ^
                           context[6]  ^
                           context[4]  ^
                           context[3]  ^
                           context[2];

assign context_next[24] =  context[14] ^
                           context[9]  ^
                           context[8]  ^
                           context[7]  ^
                           context[6]  ^
                           context[5]  ^
                           context[3]  ^
                           context[2]  ^
                           context[1];

assign context_next[23] =  context[13] ^
                           context[8]  ^
                           context[7]  ^
                           context[6]  ^
                           context[5]  ^
                           context[4]  ^
                           context[2]  ^
                           context[1]  ^
                           context[0];

assign context_next[22] =  context[15] ^
                           context[14] ^
                           context[7]  ^
                           context[6]  ^
                           context[5]  ^
                           context[4]  ^
                           context[1]  ^
                           context[0];

assign context_next[21] =  context[15] ^
                           context[13] ^
                           context[12] ^
                           context[6]  ^
                           context[5]  ^
                           context[4]  ^
                           context[0];

assign context_next[20] =  context[15] ^
                           context[11] ^
                           context[5]  ^
                           context[4];

assign context_next[19] =  context[14] ^
                           context[10] ^
                           context[4]  ^
                           context[3];

assign context_next[18] =  context[13] ^
                           context[9]  ^
                           context[3]  ^
                           context[2];

assign context_next[17] =  context[12] ^
                           context[8]  ^
                           context[2]  ^
                           context[1];

assign context_next[16] =  context[11] ^
                           context[7]  ^
                           context[1]  ^
                           context[0];

assign context_next[15] =  context[15] ^
                           context[14] ^
                           context[12] ^
                           context[10] ^
                           context[6]  ^
                           context[3]  ^
                           context[0];

assign context_next[14] =  context[15] ^
                           context[13] ^
                           context[12] ^
                           context[11] ^
                           context[9]  ^
                           context[5]  ^
                           context[3]  ^
                           context[2];

assign context_next[13] =  context[14] ^
                           context[12] ^
                           context[11] ^
                           context[10] ^
                           context[8]  ^
                           context[4]  ^
                           context[2]  ^
                           context[1];

assign context_next[12] =  context[13] ^
                           context[11] ^
                           context[10] ^
                           context[9]  ^
                           context[7]  ^
                           context[3]  ^
                           context[1]  ^
                           context[0];

assign context_next[11] =  context[15] ^
                           context[14] ^
                           context[10] ^
                           context[9] ^
                           context[8] ^
                           context[6] ^
                           context[3] ^
                           context[2] ^
                           context[0];

assign context_next[10] =  context[15] ^
                           context[13] ^
                           context[12] ^
                           context[9]  ^
                           context[8]  ^
                           context[7]  ^
                           context[5]  ^
                           context[3]  ^
                           context[2]  ^
                           context[1];

assign context_next[9] =   context[14] ^
                           context[12] ^
                           context[11] ^
                           context[8]  ^
                           context[7]  ^
                           context[6]  ^
                           context[4]  ^
                           context[2]  ^
                           context[1]  ^
                           context[0];

assign context_next[8] =   context[15] ^
                           context[14] ^
                           context[13] ^
                           context[12] ^
                           context[11] ^
                           context[10] ^
                           context[7]  ^
                           context[6]  ^
                           context[5]  ^
                           context[1]  ^
                           context[0];

assign context_next[7] =   context[15] ^
                           context[13] ^
                           context[11] ^
                           context[10] ^
                           context[9]  ^
                           context[6]  ^
                           context[5]  ^
                           context[4]  ^
                           context[3]  ^
                           context[0];

assign context_next[6] =   context[15] ^
                           context[10] ^
                           context[9]  ^
                           context[8]  ^
                           context[5]  ^
                           context[4]  ^
                           context[2];

assign context_next[5] =   context[14] ^
                           context[9]  ^
                           context[8]  ^
                           context[7]  ^
                           context[4]  ^
                           context[3]  ^
                           context[1];

assign context_next[4] =   context[13] ^
                           context[8]  ^
                           context[7]  ^
                           context[6]  ^
                           context[3]  ^
                           context[2]  ^
                           context[0];

assign context_next[3] =   context[15] ^
                           context[14] ^
                           context[7]  ^
                           context[6]  ^
                           context[5]  ^
                           context[3]  ^
                           context[2]  ^
                           context[1];

assign context_next[2] =   context[14] ^
                           context[13] ^
                           context[6]  ^
                           context[5]  ^
                           context[4]  ^
                           context[2]  ^
                           context[1]  ^
                           context[0];

assign context_next[1] =   context[15] ^
                           context[14] ^
                           context[13] ^
                           context[5]  ^
                           context[4]  ^
                           context[1]  ^
                           context[0];

assign context_next[0] =   context[15] ^
                           context[13] ^
                           context[4]  ^
                           context[0];




endmodule
