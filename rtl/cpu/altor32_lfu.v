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
// Module: Load Forwarding Unit
//-----------------------------------------------------------------
module altor32_lfu
(
    // Opcode
    input [7:0]         opcode_i /*verilator public*/,

    // Memory load result
    input [31:0]        mem_result_i /*verilator public*/,
    input [1:0]         mem_offset_i /*verilator public*/,

    // Result
    output reg [31:0]   load_result_o /*verilator public*/,
    output reg          load_insn_o /*verilator public*/
);

//-------------------------------------------------------------------
// Load forwarding unit
//-------------------------------------------------------------------
always @ *
begin
    load_result_o   = 32'h00000000;
    load_insn_o     = 1'b0;

    case (opcode_i)

        `INST_OR32_LBS: // l.lbs
        begin
            case (mem_offset_i)
                2'b00 :   load_result_o[7:0] = mem_result_i[31:24];
                2'b01 :   load_result_o[7:0] = mem_result_i[23:16];
                2'b10 :   load_result_o[7:0] = mem_result_i[15:8];
                2'b11 :   load_result_o[7:0] = mem_result_i[7:0];
                default : ;
            endcase
        
            // Sign extend LB
            if (load_result_o[7] == 1'b1)
                load_result_o[31:8] = 24'hFFFFFF;

            load_insn_o = 1'b1;
        end
        
        `INST_OR32_LBZ: // l.lbz
        begin
            case (mem_offset_i)
                2'b00 :   load_result_o[7:0] = mem_result_i[31:24];
                2'b01 :   load_result_o[7:0] = mem_result_i[23:16];
                2'b10 :   load_result_o[7:0] = mem_result_i[15:8];
                2'b11 :   load_result_o[7:0] = mem_result_i[7:0];
                default : ;
            endcase

            load_insn_o = 1'b1;
        end

        `INST_OR32_LHS: // l.lhs
        begin
            case (mem_offset_i)
                2'b00 :   load_result_o[15:0] = mem_result_i[31:16];
                2'b10 :   load_result_o[15:0] = mem_result_i[15:0];
                default : ;                
            endcase

            // Sign extend LH
            if (load_result_o[15] == 1'b1)
                load_result_o[31:16] = 16'hFFFF;

            load_insn_o = 1'b1;
        end
        
        `INST_OR32_LHZ: // l.lhz
        begin
            case (mem_offset_i)
                2'b00 :   load_result_o[15:0] = mem_result_i[31:16];
                2'b10 :   load_result_o[15:0] = mem_result_i[15:0];
                default : ;
            endcase

            load_insn_o = 1'b1;
        end

        `INST_OR32_LWZ, `INST_OR32_LWS: // l.lwz l.lws
        begin
            load_result_o   = mem_result_i;
            load_insn_o  = 1'b1;
        end

        default :
            ;
    endcase  
end

endmodule
