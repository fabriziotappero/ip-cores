//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
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
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"

//-----------------------------------------------------------------
// Module - Writeback
//-----------------------------------------------------------------
module altor32_writeback
(
    // General
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Opcode
    input [31:0]        opcode_i /*verilator public*/,

    // Register target
    input [4:0]         rd_i /*verilator public*/,

    // ALU result
    input [31:0]        alu_result_i /*verilator public*/,

    // Memory load result
    input [31:0]        mem_result_i /*verilator public*/,
    input [1:0]         mem_offset_i /*verilator public*/,
    input               mem_ready_i /*verilator public*/,

    // Multiplier result
    input [63:0]        mult_result_i /*verilator public*/,

    // Outputs
    output reg          write_enable_o /*verilator public*/,
    output reg [4:0]    write_addr_o /*verilator public*/,
    output reg [31:0]   write_data_o /*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// Register address
reg [4:0]  rd_q;

// Register writeback value
reg [31:0] result_q;

reg [7:0]  opcode_q;

// Register writeback enable
reg        write_rd_q;

reg [1:0]  mem_offset_q;

//-------------------------------------------------------------------
// Pipeline Registers
//-------------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       write_rd_q   <= 1'b1;
       result_q     <= 32'h00000000;
       rd_q         <= 5'b00000;
       opcode_q     <= 8'b0;
       mem_offset_q <= 2'b0;
   end
   else
   begin      
        rd_q        <= rd_i;
        result_q    <= alu_result_i;

        opcode_q    <= {2'b00,opcode_i[31:26]};
        mem_offset_q<= mem_offset_i;

        // Register writeback required?
        if (rd_i != 5'b00000)
            write_rd_q  <= 1'b1;
        else
            write_rd_q  <= 1'b0;
   end
end

//-------------------------------------------------------------------
// Load result resolve
//-------------------------------------------------------------------
wire            load_inst_w;
wire [31:0]     load_result_w;

altor32_lfu
u_lfu
(
    // Opcode
    .opcode_i(opcode_q),

    // Memory load result
    .mem_result_i(mem_result_i),
    .mem_offset_i(mem_offset_q),

    // Result
    .load_result_o(load_result_w),
    .load_insn_o(load_inst_w)
);

//-------------------------------------------------------------------
// Writeback
//-------------------------------------------------------------------
always @ *
begin
    write_addr_o = rd_q;

    // Load result
    if (load_inst_w)
    begin
        write_enable_o = write_rd_q & mem_ready_i;
        write_data_o   = load_result_w;
    end   
    // Normal ALU instruction
    else
    begin
        write_enable_o = write_rd_q;
        write_data_o   = result_q;
    end    
end

endmodule
