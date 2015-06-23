`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: General storage.
// 
// Additional Comments: Drum storage is implemented as an array of 24000 5-bit
//  digits. An array address is formed by decoding the static portion of the
//  bi-quinary address into an origin (a multiple of 600), then adding the 
//  dynamic portion of the address (range 0..599).
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module gen_store (
   input rst,
   input ap, dp,
   input write_gate,
   input [0:6] addr_th, addr_h, addr_t,
   input [0:9] dynamic_addr,
   input [0:4] gs_in,
   input [0:14] console_ram_addr,
   input console_read_gs, console_write_gs,
   output reg[0:4] gs_out,
   output double_write, no_write
   );

   reg [0:4] gs_mem [0:32767];   // Rounded size up from 24000 to next 2^n. 
   
   //-----------------------------------------------------------------------------
   // Calculate the early (next digit) and on-time RAM addresses. Console read
   // and write are implementation extensions.
   //-----------------------------------------------------------------------------
   wire [0:14] band_addr, gs_addr, gs_addr_early;
   ram_band_addr rba(addr_th, addr_h, addr_t, band_addr);
   wire console_acc = console_read_gs | console_write_gs;
   assign gs_addr = console_acc? console_ram_addr : (band_addr + dynamic_addr);
   // The % operator fixes a spurious warning from XST synthesis due to use of a
   // 32-bit mux for ? operator. Uses no gates. 
   assign gs_addr_early = (console_acc? console_ram_addr
                        : (band_addr + ((dynamic_addr + 1) % 600))) % 32768;
   
   //-----------------------------------------------------------------------------
   // These 650 write errors are not possible for this implementation.
   //-----------------------------------------------------------------------------
   assign double_write = 0;
   assign no_write = 0;
      
   //-----------------------------------------------------------------------------
   // A : Read from RAM at on-time address.
   //-----------------------------------------------------------------------------
   always @(posedge ap)
      if (rst) begin
         gs_out <= `biq_blank;
      end else begin
         gs_out <= gs_mem[gs_addr];
      end;
   
   //-----------------------------------------------------------------------------
   // D : Write to RAM at early address.
   //-----------------------------------------------------------------------------
   always @(posedge dp)
      if (write_gate)
         gs_mem[gs_addr_early] <= gs_in;
      
endmodule
