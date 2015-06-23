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
// Module - Cache substitute (used when ICache disabled)
//-----------------------------------------------------------------
module altor32_noicache 
( 
    input                       clk_i /*verilator public*/,
    input                       rst_i /*verilator public*/,
    
    // Processor interface
    input                       rd_i /*verilator public*/,
    input [31:0]                pc_i /*verilator public*/,
    output [31:0]               instruction_o /*verilator public*/,
    output                      valid_o /*verilator public*/,

    // Invalidate (not used)
    input                       invalidate_i /*verilator public*/,
    
    // Memory interface
    output [31:0]               wbm_addr_o /*verilator public*/,
    input [31:0]                wbm_dat_i /*verilator public*/,
    output [2:0]                wbm_cti_o /*verilator public*/,
    output                      wbm_cyc_o /*verilator public*/,
    output                      wbm_stb_o /*verilator public*/,
    input                       wbm_stall_i/*verilator public*/,
    input                       wbm_ack_i/*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// Current state
parameter STATE_CHECK   = 0;
parameter STATE_FETCH   = 1;
reg                     state_q;

reg                     drop_resp_q;

wire                    mem_fetch_w = (state_q == STATE_CHECK); 
wire                    mem_valid_w; 
wire                    mem_final_w;

//-----------------------------------------------------------------
// Fetch unit
//-----------------------------------------------------------------
altor32_wb_fetch
u_wb
( 
    .clk_i(clk_i),
    .rst_i(rst_i),

    .fetch_i(mem_fetch_w),
    .burst_i(1'b0),
    .address_i(pc_i),

    .resp_addr_o(/* not used */),
    .data_o(instruction_o),
    .valid_o(mem_valid_w),
    .final_o(mem_final_w),

    .wbm_addr_o(wbm_addr_o),
    .wbm_dat_i(wbm_dat_i),
    .wbm_cti_o(wbm_cti_o),
    .wbm_cyc_o(wbm_cyc_o),
    .wbm_stb_o(wbm_stb_o),
    .wbm_stall_i(wbm_stall_i),
    .wbm_ack_i(wbm_ack_i)
);

//-----------------------------------------------------------------
// Control logic
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        drop_resp_q <= 1'b0;
        state_q     <= STATE_CHECK;   
   end
   else
   begin
        case (state_q)

            //-----------------------------------------
            // CHECK - Accept read request
            //-----------------------------------------
            STATE_CHECK :
            begin
                drop_resp_q         <= 1'b0;
                state_q             <= STATE_FETCH;
            end
            //-----------------------------------------
            // FETCH - Wait for read response
            //-----------------------------------------
            STATE_FETCH :
            begin
                // Read whilst waiting for previous response?        
                if (rd_i)
                    drop_resp_q     <= 1'b1;

                // Data ready from memory?
                if (mem_final_w)
                    state_q         <= STATE_CHECK;
            end
            
            default:
                ;
           endcase
   end
end

assign valid_o              = mem_valid_w & ~drop_resp_q & ~rd_i;
assign instruction_o        = wbm_dat_i;

endmodule

