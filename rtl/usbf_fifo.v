//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
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
// Module: USB FIFO - simple FIFO
//-----------------------------------------------------------------
module usbf_fifo
(
    clk_i,
    rst_i,

    data_i,
    push_i,

    full_o,
    empty_o,

    data_o,
    pop_i,

    flush_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter               WIDTH   = 8;
parameter               DEPTH   = 4;
parameter               ADDR_W  = 2;
parameter               COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input                   clk_i /*verilator public*/;
input                   rst_i /*verilator public*/;
input [WIDTH-1:0]       data_i /*verilator public*/;
input                   push_i /*verilator public*/;
output                  full_o /*verilator public*/;
output                  empty_o /*verilator public*/;
output [WIDTH-1:0]      data_o /*verilator public*/;
input                   pop_i /*verilator public*/;
input                   flush_i /*verilator public*/;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]         ram [DEPTH-1:0];
reg [ADDR_W-1:0]        rd_ptr;
reg [ADDR_W-1:0]        wr_ptr;
reg [COUNT_W-1:0]       count;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
    if (rst_i == 1'b1)
    begin
        count   <= {(COUNT_W) {1'b0}};
        rd_ptr  <= {(ADDR_W) {1'b0}};
        wr_ptr  <= {(ADDR_W) {1'b0}};
    end
    else
    begin

        if (flush_i)
        begin
            count   <= {(COUNT_W) {1'b0}};
            rd_ptr  <= {(ADDR_W) {1'b0}};
            wr_ptr  <= {(ADDR_W) {1'b0}};
        end

        // Push
        if (push_i & ~full_o)
        begin
            ram[wr_ptr] <= data_i;
            wr_ptr      <= wr_ptr + 1;
        end

        // Pop
        if (pop_i & ~empty_o)
        begin
            rd_ptr      <= rd_ptr + 1;
        end

        // Count up
        if ((push_i & ~full_o) & ~(pop_i & ~empty_o))
        begin
            count <= count + 1;
        end
        // Count down
        else if (~(push_i & ~full_o) & (pop_i & ~empty_o))
        begin
            count <= count - 1;
        end
    end
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
assign full_o    = (count == DEPTH);
assign empty_o   = (count == 0);

assign data_o    = ram[rd_ptr];

endmodule
