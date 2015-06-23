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
// Module: Load / Store Unit
//-----------------------------------------------------------------
module altor32_lsu
(
    // Current instruction
    input               opcode_valid_i /*verilator public*/,
    input [7:0]         opcode_i /*verilator public*/,

    // Load / Store pending
    input               load_pending_i /*verilator public*/,
    input               store_pending_i /*verilator public*/,

    // Load dest register
    input [4:0]         rd_load_i /*verilator public*/,

    // Load insn in WB stage
    input               load_wb_i /*verilator public*/,

    // Memory status
    input               mem_access_i /*verilator public*/,
    input               mem_ack_i /*verilator public*/,

    // Load / store still pending
    output reg          load_pending_o /*verilator public*/,
    output reg          store_pending_o /*verilator public*/,

    // Insert load result into pipeline
    output reg          write_result_o /*verilator public*/,

    // Stall pipeline due load / store / insert
    output reg          stall_o /*verilator public*/
);

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"
`include "altor32_funcs.v"

//-------------------------------------------------------------------
// Outstanding memory access logic
//-------------------------------------------------------------------
reg inst_load_r;
reg inst_store_r;

always @ *
begin
    
    load_pending_o   = load_pending_i;
    store_pending_o  = store_pending_i;
    stall_o          = 1'b0;
    write_result_o   = 1'b0;

    // Is this instruction a load or store?
    inst_load_r     = is_load_operation(opcode_i);
    inst_store_r    = is_store_operation(opcode_i);

    // Store operation just completed?
    if (store_pending_o & mem_ack_i & ~mem_access_i)
    begin
    `ifdef CONF_CORE_DEBUG       
        $display("   Store operation now completed");
    `endif            
        store_pending_o = 1'b0;
    end

    // Load just completed (and result ready in-time for writeback stage)?
    if (load_pending_o & mem_ack_i & ~mem_access_i & load_wb_i)
    begin
        // Load complete
        load_pending_o       = 1'b0;

    `ifdef CONF_CORE_DEBUG
        $display("   Load operation completed in writeback stage");
    `endif
    end
    // Load just completed (later than writeback stage)?
    else if (load_pending_o & mem_ack_i & ~mem_access_i)
    begin
    `ifdef CONF_CORE_DEBUG        
        $display("   Load operation completed later than writeback stage");
    `endif
        
        // Valid target register?
        if (rd_load_i != 5'b00000)
        begin
    `ifdef CONF_CORE_DEBUG            
            $display("   Load result now ready for R%d", rd_load_i);
    `endif
            // Stall instruction and write load result to pipeline
            stall_o         = opcode_valid_i;
            write_result_o  = 1'b1;
        end
        else
        begin
    `ifdef CONF_CORE_DEBUG            
            $display("   Load result ready but not needed");
    `endif
        end
        
        // Load complete
        load_pending_o       = 1'b0;
    end       

    // If load or store in progress (and this instruction is valid)
    if ((load_pending_o | store_pending_o) & opcode_valid_i)
    begin
        // Load or store whilst memory bus busy
        if (inst_load_r | inst_store_r)
        begin
    `ifdef CONF_CORE_DEBUG            
            $display("   Data bus already busy, stall (load_pending_o=%d, store_pending_o=%d)",  load_pending_o, store_pending_o);
    `endif                
            // Stall!
            stall_o         = 1'b1; 
        end
    end
end

endmodule
