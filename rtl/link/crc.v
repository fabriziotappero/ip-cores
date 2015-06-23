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
// ENTITY: crc
// Version: 1.0
// Author:  Ashwin Mendon
// Description: This sub/module implements the CRC Circuit for the SATA Protocol
//              The code takes 32/bit data word inputs and calculates the CRC for the stream
//              The generator polynomial used is
//                      32  26  23  22  16  12  11  10  8   7   5   4   2
//              G(x) = x + x + x + x + x + x + x + x + x + x + x + x + x + x + 1
//              The CRC value is initialized to 0x52325032 as defined in the Serial ATA
//              specification
// PORTS:
/////////////////////////////////////////////////////////////////////////////////////////


module crc (
  clk,
  rst,
  en,
  din,
  dout
);

input               clk;
input               rst;
input               en;
input   [31:0]      din;
output  reg [31:0]  dout;


parameter         CRC_INIT  = 32'h52325032;
//Registers/Wires
wire    [31:0]    crc_next;
wire    [31:0]    crc_new;


always @ (posedge clk) begin
  if (rst) begin
    dout           <=  CRC_INIT;
  end
  else if (en) begin
    dout           <=  crc_next;
  end
end

assign crc_new    = dout ^ din;

assign crc_next[31] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[5];



assign crc_next[30] =crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[4];

assign crc_next[29] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[3];

assign crc_next[28] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[12]   ^
                     crc_new[8]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[2];

assign crc_next[27] =crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[11]   ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[1];

assign crc_next[26] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[10]   ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[0];

assign crc_next[25] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[3]    ^
                     crc_new[2];

assign crc_next[24] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[2]    ^
                     crc_new[1];

assign crc_next[23] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[22] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[0];

assign crc_next[21] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[5];

assign crc_next[20] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[4];

assign crc_next[19] =crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[3];

assign crc_next[18] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[2];

assign crc_next[17] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[1];

assign crc_next[16] =crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[8]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[0];

assign crc_next[15] =crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[3];

assign crc_next[14] =crc_new[29]   ^
                     crc_new[26]   ^
                     crc_new[23]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[2];

assign crc_next[13] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[25]   ^
                     crc_new[22]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[1];

assign crc_next[12] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[11] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[20]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[10] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[19]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];

assign crc_next[9] = crc_new[29]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[18]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1];

assign crc_next[8] = crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[17]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[7] = crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];

assign crc_next[6] = crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[25]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[14]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1];

assign crc_next[5] = crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[4] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[15]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];

assign crc_next[3] = crc_new[31]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[1];

assign crc_next[2] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[2]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[1] = crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[1]    ^
                     crc_new[0];

assign crc_next[0] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[16]   ^
                     crc_new[12]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[0];

endmodule
