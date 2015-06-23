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
// Module: Data Forwarding Unit
//-----------------------------------------------------------------
module altor32_dfu
(
    // Input registers
    input [4:0]         ra_i /*verilator public*/,
    input [4:0]         rb_i /*verilator public*/,

    // Input register contents
    input [31:0]        ra_regval_i /*verilator public*/,
    input [31:0]        rb_regval_i /*verilator public*/,

    // Dest register (EXEC stage)
    input [4:0]         rd_ex_i/*verilator public*/,

    // Dest register (WB stage)
    input [4:0]         rd_wb_i/*verilator public*/,

    // Load pending / target
    input               load_pending_i /*verilator public*/,
    input [4:0]         rd_load_i /*verilator public*/,

    // Multiplier status
    input               mult_ex_i /*verilator public*/,

    // Result (EXEC)
    input [31:0]        result_ex_i /*verilator public*/,

    // Result (WB)
    input [31:0]        result_wb_i /*verilator public*/,

    // Resolved register values
    output reg [31:0]   result_ra_o /*verilator public*/,
    output reg [31:0]   result_rb_o /*verilator public*/,

    // Result required resolving
    output reg          resolved_o /*verilator public*/,

    // Stall due to failed resolve
    output reg          stall_o /*verilator public*/
);

//-------------------------------------------------------------------
// Data forwarding unit
//-------------------------------------------------------------------
always @ *
begin
   // Default to no forwarding
   result_ra_o  = ra_regval_i;
   result_rb_o  = rb_regval_i;
   stall_o      = 1'b0;
   resolved_o   = 1'b0;

   //---------------------------------------------------------------
   // RA - Hazard detection & forwarding
   //---------------------------------------------------------------

   // Register[ra] hazard detection & forwarding logic
   // (higher priority = latest results!)
   if (ra_i != 5'b00000)
   begin
       //---------------------------------------------------------------
       // RA from load (result not ready)
       //---------------------------------------------------------------
       if (ra_i == rd_load_i & load_pending_i)
       begin
            stall_o     = 1'b1;  
`ifdef CONF_CORE_DEBUG
            $display(" rA[%d] not ready as load still pending", ra_i);
`endif   
       end   
       //---------------------------------------------------------------
       // RA from PC-4 (exec)
       //---------------------------------------------------------------
       else if (ra_i == rd_ex_i)
       begin
            // Multiplier has one cycle latency, stall if needed now
            if (mult_ex_i)
                stall_o     = 1'b1;  
            else
            begin
                result_ra_o = result_ex_i;
                resolved_o  = 1'b1;
`ifdef CONF_CORE_DEBUG
                $display(" rA[%d] forwarded 0x%08x (PC-4)", ra_i, result_ra_o);
`endif   
            end
       end
       //---------------------------------------------------------------
       // RA from PC-8 (writeback)
       //---------------------------------------------------------------
       else if (ra_i == rd_wb_i)
       begin
            result_ra_o = result_wb_i;

            resolved_o  = 1'b1;
`ifdef CONF_CORE_DEBUG
            $display(" rA[%d] forwarded 0x%08x (PC-8)", ra_i, result_ra_o);
`endif
       end
   end
   
   //---------------------------------------------------------------
   // RB - Hazard detection & forwarding
   //---------------------------------------------------------------       

   // Register[rb] hazard detection & forwarding logic
   // (higher priority = latest results!)
   if (rb_i != 5'b00000)
   begin

       //---------------------------------------------------------------
       // RB from load (result not ready)
       //---------------------------------------------------------------
       if (rb_i == rd_load_i & load_pending_i)
       begin
            stall_o     = 1'b1;  
`ifdef CONF_CORE_DEBUG
            $display(" rB[%d] not ready as load still pending", rb_i);
`endif   
       end 
       //---------------------------------------------------------------
       // RB from PC-4 (exec)
       //---------------------------------------------------------------
       else if (rb_i == rd_ex_i)
       begin
            // Multiplier has one cycle latency, stall if needed now
            if (mult_ex_i)
                stall_o     = 1'b1;  
            else
            begin           
                result_rb_o = result_ex_i;
                resolved_o  = 1'b1;

`ifdef CONF_CORE_DEBUG
                $display(" rB[%d] forwarded 0x%08x (PC-4)", rb_i, result_rb_o);
`endif
            end
       end
       //---------------------------------------------------------------
       // RB from PC-8 (writeback)
       //---------------------------------------------------------------
       else if (rb_i == rd_wb_i)
       begin        
            result_rb_o = result_wb_i;

            resolved_o  = 1'b1;

`ifdef CONF_CORE_DEBUG
            $display(" rB[%d] forwarded 0x%08x (PC-8)", rb_i, result_rb_o);
`endif
       end
   end
end

endmodule
