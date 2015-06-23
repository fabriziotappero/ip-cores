//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
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
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: ram_dp8 - dual port block RAM
//-----------------------------------------------------------------
module ram_dp8
(
    aclk_i,
    aadr_i,
    adat_i,
    awr_i,
    adat_o,

    bclk_i,
    badr_i,
    bdat_i,
    bwr_i,
    bdat_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter  [31:0]       WIDTH       = 8;
parameter  [31:0]       SIZE        = 14;
parameter               FILENAME    = "mem.hex";

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input                   aclk_i /*verilator public*/;
output [(WIDTH - 1):0]  adat_o /*verilator public*/;
input [(WIDTH - 1):0]   adat_i /*verilator public*/;
input [(SIZE - 1):0]    aadr_i /*verilator public*/;
input                   awr_i /*verilator public*/;
input                   bclk_i /*verilator public*/;
output [(WIDTH - 1):0]  bdat_o /*verilator public*/;
input [(WIDTH - 1):0]   bdat_i /*verilator public*/;
input [(SIZE - 1):0]    badr_i /*verilator public*/;
input                   bwr_i /*verilator public*/;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [(WIDTH - 1):0]     ram [((2<< (SIZE-1)) - 1):0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [(SIZE - 1):0]      rd_addr_a;
reg [(SIZE - 1):0]      rd_addr_b;
wire [(WIDTH - 1):0]    adat_o;
wire [(WIDTH - 1):0]    bdat_o;

//-----------------------------------------------------------------
// Processes
//-----------------------------------------------------------------
always @ (posedge aclk_i)
begin
    if (awr_i == 1'b1)
        ram[aadr_i] <= adat_i;
    rd_addr_a <= aadr_i;
end
always @ (posedge bclk_i)
begin
    if (bwr_i == 1'b1)
        ram[badr_i] <= bdat_i;
    rd_addr_b <= badr_i;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
assign adat_o = ram[rd_addr_a];
assign bdat_o = ram[rd_addr_b];

//-----------------------------------------------------------------
// Load memory image
//-----------------------------------------------------------------
integer i;
initial
begin
    for (i=0;i<((2<< (SIZE-1)) - 1);i=i+1)
    begin
        ram[i] = 0;
    end
    $readmemh(FILENAME, ram);
end

endmodule
