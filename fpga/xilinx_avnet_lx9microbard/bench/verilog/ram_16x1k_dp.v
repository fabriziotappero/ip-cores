//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: ram.v
// 
// *Module Description:
//                      Scalable RAM model
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------

module ram_16x1k_dp (
  clka,
  ena,
  wea,
  addra,
  dina,
  douta,
  clkb,
  enb,
  web,
  addrb,
  dinb,
  doutb
);

input clka;
input ena;
input [1 : 0] wea;
input [9 : 0] addra;
input [15 : 0] dina;
output [15 : 0] douta;
input clkb;
input enb;
input [1 : 0] web;
input [9 : 0] addrb;
input [15 : 0] dinb;
output [15 : 0] doutb;


//============
// RAM
//============

ram_dp #(.ADDR_MSB(9), .MEM_SIZE(2048)) ram_dp_inst (

// OUTPUTs
    .ram_douta     ( douta),      // RAM data output (Port A)
    .ram_doutb     ( douta),      // RAM data output (Port B)

// INPUTs
    .ram_addra     ( addra),      // RAM address (Port A)
    .ram_cena      (~ena),        // RAM chip enable (low active) (Port A)
    .ram_clka      ( clka),       // RAM clock (Port A)
    .ram_dina      ( dina),       // RAM data input (Port A)
    .ram_wena      (~wea),        // RAM write enable (low active) (Port A)
    .ram_addrb     ( addrb),      // RAM address (Port B)
    .ram_cenb      (~enb),        // RAM chip enable (low active) (Port B)
    .ram_clkb      ( clkb),       // RAM clock (Port B)
    .ram_dinb      ( dinb),       // RAM data input (Port B)
    .ram_wenb      (~web)         // RAM write enable (low active) (Port B)
);


endmodule // ram_16x1k_dp

