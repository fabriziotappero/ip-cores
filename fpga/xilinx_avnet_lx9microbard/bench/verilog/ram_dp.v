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
//                      Scalable Dual-Port RAM model
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------

module ram_dp (

// OUTPUTs
    ram_douta,                     // RAM data output (Port A)
    ram_doutb,                     // RAM data output (Port B)

// INPUTs
    ram_addra,                     // RAM address (Port A)
    ram_cena,                      // RAM chip enable (low active) (Port A)
    ram_clka,                      // RAM clock (Port A)
    ram_dina,                      // RAM data input (Port A)
    ram_wena,                      // RAM write enable (low active) (Port A)
    ram_addrb,                     // RAM address (Port B)
    ram_cenb,                      // RAM chip enable (low active) (Port B)
    ram_clkb,                      // RAM clock (Port B)
    ram_dinb,                      // RAM data input (Port B)
    ram_wenb                       // RAM write enable (low active) (Port B)
);

// PARAMETERs
//============
parameter ADDR_MSB   =  6;         // MSB of the address bus
parameter MEM_SIZE   =  256;       // Memory size in bytes

// OUTPUTs
//============
output      [15:0] ram_douta;      // RAM data output (Port A)
output      [15:0] ram_doutb;      // RAM data output (Port B)

// INPUTs
//============
input [ADDR_MSB:0] ram_addra;      // RAM address (Port A)
input              ram_cena;       // RAM chip enable (low active) (Port A)
input              ram_clka;       // RAM clock (Port A)
input       [15:0] ram_dina;       // RAM data input (Port A)
input        [1:0] ram_wena;       // RAM write enable (low active) (Port A)
input [ADDR_MSB:0] ram_addrb;      // RAM address (Port B)
input              ram_cenb;       // RAM chip enable (low active) (Port B)
input              ram_clkb;       // RAM clock (Port B)
input       [15:0] ram_dinb;       // RAM data input (Port B)
input        [1:0] ram_wenb;       // RAM write enable (low active) (Port B)


// RAM
//============

reg         [15:0] mem [0:(MEM_SIZE/2)-1];
reg   [ADDR_MSB:0] ram_addra_reg;
reg   [ADDR_MSB:0] ram_addrb_reg;

wire        [15:0] mem_vala = mem[ram_addra];
wire        [15:0] mem_valb = mem[ram_addrb];
   
  
always @(posedge ram_clka)
  if (~ram_cena && (ram_addra<(MEM_SIZE/2)))
    begin
      if      (ram_wena==2'b00) mem[ram_addra] <=  ram_dina;
      else if (ram_wena==2'b01) mem[ram_addra] <= {ram_dina[15:8],  mem_vala[7:0]};
      else if (ram_wena==2'b10) mem[ram_addra] <= {mem_vala[15:8],  ram_dina[7:0]};
      ram_addra_reg <= ram_addra;
    end

assign ram_douta = mem[ram_addra_reg];


always @(posedge ram_clkb)
  if (~ram_cenb && (ram_addrb<(MEM_SIZE/2)))
    begin
      if      (ram_wenb==2'b00) mem[ram_addrb] <=  ram_dinb;
      else if (ram_wenb==2'b01) mem[ram_addrb] <= {ram_dinb[15:8],  mem_valb[7:0]};
      else if (ram_wenb==2'b10) mem[ram_addrb] <= {mem_valb[15:8],  ram_dinb[7:0]};
      ram_addrb_reg <= ram_addrb;
    end

assign ram_doutb = mem[ram_addrb_reg];


endmodule // ram_dp
