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
// Module - Simple AltOR32 (wrapper for cutdown core)
//-----------------------------------------------------------------
module cpu
(
    // General
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Maskable interrupt    
    input               intr_i /*verilator public*/,

    // Unmaskable interrupt
    input               nmi_i /*verilator public*/,

    // Fault
    output              fault_o /*verilator public*/,

    // Breakpoint / Trap
    output              break_o /*verilator public*/,

    // Instruction memory (unused)
    output [31:0]       imem_addr_o /*verilator public*/,
    input [31:0]        imem_dat_i /*verilator public*/,
    output [2:0]        imem_cti_o /*verilator public*/,
    output              imem_cyc_o /*verilator public*/,
    output              imem_stb_o /*verilator public*/,
    input               imem_stall_i/*verilator public*/,
    input               imem_ack_i/*verilator public*/,  

    // Memory interface
    output [31:0]       dmem_addr_o /*verilator public*/,
    input [31:0]        dmem_dat_i /*verilator public*/,
    output [31:0]       dmem_dat_o /*verilator public*/,
    output [2:0]        dmem_cti_o /*verilator public*/,
    output              dmem_cyc_o /*verilator public*/,
    output              dmem_stb_o /*verilator public*/,
    output              dmem_we_o /*verilator public*/,
    output [3:0]        dmem_sel_o /*verilator public*/,
    input               dmem_stall_i/*verilator public*/,
    input               dmem_ack_i/*verilator public*/ 
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           BOOT_VECTOR         = 32'h00000000;
parameter           ISR_VECTOR          = 32'h00000000;
parameter           REGISTER_FILE_TYPE  = "SIMULATION";
parameter           ENABLE_ICACHE       = "DISABLED"; // Unused
parameter           ENABLE_DCACHE       = "DISABLED"; // Unused
parameter           SUPPORT_32REGS      = "ENABLED";

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------
// CPU
altor32_lite
#(
    .BOOT_VECTOR(BOOT_VECTOR),
    .ISR_VECTOR(ISR_VECTOR),
    .REGISTER_FILE_TYPE(REGISTER_FILE_TYPE) 
)
u_exec
(
    // General - clocking & reset
    .clk_i(clk_i),
    .rst_i(rst_i),
    .fault_o(fault_o),
    .break_o(break_o),
    .nmi_i(nmi_i),
    .intr_i(intr_i),
    .enable_i(1'b1),

    .mem_addr_o(dmem_addr_o),
    .mem_dat_o(dmem_dat_o),
    .mem_dat_i(dmem_dat_i),
    .mem_sel_o(dmem_sel_o),
    .mem_cti_o(dmem_cti_o),
    .mem_cyc_o(dmem_cyc_o),
    .mem_we_o(dmem_we_o),
    .mem_stb_o(dmem_stb_o),
    .mem_stall_i(dmem_stall_i),
    .mem_ack_i(dmem_ack_i)
);

// Unused outputs
assign imem_addr_o = 32'b0;
assign imem_cti_o  = 3'b0;
assign imem_cyc_o  = 1'b0;
assign imem_stb_o  = 1'b0;

endmodule
