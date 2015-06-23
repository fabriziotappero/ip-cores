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
// Module - Instruction Fetch
//-----------------------------------------------------------------
module altor32_fetch
(
    // General
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Instruction Fetch
    output              fetch_o /*verilator public*/,
    output reg [31:0]   pc_o /*verilator public*/,
    input [31:0]        data_i /*verilator public*/,
    input               data_valid_i/*verilator public*/,

    // Branch target
    input               branch_i /*verilator public*/,
    input [31:0]        branch_pc_i /*verilator public*/,
    input               stall_i /*verilator public*/,

    // Decoded opcode
    output [31:0]       opcode_o /*verilator public*/,
    output [31:0]       opcode_pc_o /*verilator public*/,
    output              opcode_valid_o /*verilator public*/,

    // Decoded register details
    output [4:0]        ra_o /*verilator public*/,
    output [4:0]        rb_o /*verilator public*/,
    output [4:0]        rd_o /*verilator public*/
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter   BOOT_VECTOR             = 32'h00000000;
parameter   CACHE_LINE_SIZE_WIDTH   = 5; /* 5-bits -> 32 entries */
parameter   PIPELINED_FETCH         = "DISABLED";

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg         rd_q;
reg [31:0]  pc_q;
reg [31:0]  pc_last_q;

//-------------------------------------------------------------------
// Next PC state machine
//-------------------------------------------------------------------
wire [31:0] next_pc_w = pc_q + 32'd4;

always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i)
   begin
        pc_q        <= BOOT_VECTOR + `VECTOR_RESET;
        pc_last_q   <= BOOT_VECTOR + `VECTOR_RESET;
        rd_q        <= 1'b1;
   end
   else if (~stall_i)
   begin
        // Branch - Next PC = branch target + 4
        if (branch_i)
        begin
            rd_q        <= 1'b0;
            pc_last_q   <= pc_o;
            pc_q        <= branch_pc_i + 4;
        end
        // Normal sequential execution (and instruction is ready)
        else if (data_valid_i)
        begin
            // New cache line?
            if (next_pc_w[CACHE_LINE_SIZE_WIDTH-1:0] == {CACHE_LINE_SIZE_WIDTH{1'b0}})
                rd_q    <= 1'b1;
            else
                rd_q    <= 1'b0;

            pc_last_q   <= pc_o;
            pc_q        <= next_pc_w;
        end
        else
        begin
            rd_q        <= 1'b0;
            pc_last_q   <= pc_o;
        end
   end
end

//-------------------------------------------------------------------
// Instruction Fetch
//-------------------------------------------------------------------
always @ *
begin
    // Stall, revert to last requested PC
    if (stall_i)
        pc_o    = pc_last_q;
    else if (branch_i)
        pc_o    = branch_pc_i;
    else if (~data_valid_i)
        pc_o    = pc_last_q;
    else
        pc_o    = pc_q;
end

assign fetch_o  = branch_i ? 1'b1 : rd_q;

//-------------------------------------------------------------------
// Opcode output (retiming)
//-------------------------------------------------------------------
generate
if (PIPELINED_FETCH == "ENABLED")
begin: FETCH_FLOPS
    reg [31:0] opcode_q;
    reg [31:0] opcode_pc_q;
    reg        opcode_valid_q;
    reg        branch_q;

    always @ (posedge clk_i or posedge rst_i)
    begin
       if (rst_i)
       begin
            opcode_q        <= 32'b0;
            opcode_pc_q     <= 32'b0;
            opcode_valid_q  <= 1'b0;
            branch_q        <= 1'b0;
       end
       else 
       begin
            branch_q        <= branch_i;

            if (~stall_i)
            begin
                opcode_pc_q     <= pc_last_q;
                opcode_q        <= data_i;
                opcode_valid_q  <= (data_valid_i & !branch_i);
            end        
       end
    end

    // Opcode output
    assign opcode_valid_o  = opcode_valid_q & ~branch_i & ~branch_q;
    assign opcode_o        = opcode_q;
    assign opcode_pc_o     = opcode_pc_q;    
end
//-------------------------------------------------------------------
// Opcode output
//-------------------------------------------------------------------
else
begin : NO_FETCH_FLOPS
    assign opcode_valid_o  = (data_valid_i & !branch_i);
    assign opcode_o        = data_i;
    assign opcode_pc_o     = pc_last_q;
end
endgenerate

//-------------------------------------------------------------------
// Opcode output
//-------------------------------------------------------------------
// If simulation, RA = 03 if NOP instruction
`ifdef SIMULATION
    wire [7:0] fetch_inst_w = {2'b00, opcode_o[31:26]};
    wire       nop_inst_w   = (fetch_inst_w == `INST_OR32_NOP);
    assign     ra_o         = nop_inst_w ? 5'd3 : opcode_o[20:16];
`else
    assign     ra_o         = opcode_o[20:16];
`endif

assign rb_o            = opcode_o[15:11];
assign rd_o            = opcode_o[25:21];

endmodule
