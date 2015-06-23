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
// Module:
//-----------------------------------------------------------------
module cpu_if
(
    // General - Clocking & Reset
    input               clk_i,
    input               rst_i,

    // Instruction Memory 0 (0x10000000 - 0x10FFFFFF)
    output [31:0]       imem0_addr_o,
    input [31:0]        imem0_data_i,
    output [3:0]        imem0_sel_o,
    output              imem0_stb_o,
    output              imem0_cyc_o,
    output [2:0]        imem0_cti_o,
    input               imem0_ack_i,
    input               imem0_stall_i,

    // Data Memory 0 (0x10000000 - 0x10FFFFFF)
    output [31:0]       dmem0_addr_o,
    output [31:0]       dmem0_data_o,
    input [31:0]        dmem0_data_i,
    output [3:0]        dmem0_sel_o,
    output              dmem0_we_o,
    output              dmem0_stb_o,
    output              dmem0_cyc_o,
    output [2:0]        dmem0_cti_o,
    input               dmem0_ack_i,
    input               dmem0_stall_i,

    // Data Memory 1 (0x11000000 - 0x11FFFFFF)
    output [31:0]       dmem1_addr_o,
    output [31:0]       dmem1_data_o,
    input [31:0]        dmem1_data_i,
    output [3:0]        dmem1_sel_o,
    output              dmem1_we_o,
    output              dmem1_stb_o,
    output              dmem1_cyc_o,
    output [2:0]        dmem1_cti_o,
    input               dmem1_ack_i,
    input               dmem1_stall_i,

    // Data Memory 2 (0x12000000 - 0x12FFFFFF)
    output [31:0]       dmem2_addr_o,
    output [31:0]       dmem2_data_o,
    input [31:0]        dmem2_data_i,
    output [3:0]        dmem2_sel_o,
    output              dmem2_we_o,
    output              dmem2_stb_o,
    output              dmem2_cyc_o,
    output [2:0]        dmem2_cti_o,
    input               dmem2_ack_i,
    input               dmem2_stall_i,

    output              fault_o,
    output              break_o,
    input               intr_i,
    input               nmi_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           CLK_KHZ              = 12288;
parameter           ENABLE_ICACHE        = "ENABLED";
parameter           ENABLE_DCACHE        = "ENABLED";
parameter           BOOT_VECTOR          = 0;
parameter           ISR_VECTOR           = 0;
parameter           REGISTER_FILE_TYPE   = "SIMULATION";

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
wire [31:0]         dmem_addr;
wire [31:0]         dmem_data_w;
wire [31:0]         dmem_data_r;
wire [3:0]          dmem_sel;
wire [2:0]          dmem_cti;
wire                dmem_cyc;
wire                dmem_we;
wire                dmem_stb;
wire                dmem_stall;
wire                dmem_ack;
    
wire [31:0]         imem_address;
wire [31:0]         imem_data;
wire [2:0]          imem_cti;
wire                imem_cyc;
wire                imem_stb;
wire                imem_stall;
wire                imem_ack;

//-----------------------------------------------------------------
// CPU core
//-----------------------------------------------------------------
cpu
#(
    .BOOT_VECTOR(BOOT_VECTOR),
    .ISR_VECTOR(ISR_VECTOR),
    .REGISTER_FILE_TYPE(REGISTER_FILE_TYPE),
    .ENABLE_ICACHE(ENABLE_ICACHE),
    .ENABLE_DCACHE(ENABLE_DCACHE)
)
u1_cpu
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .intr_i(intr_i),
    .nmi_i(nmi_i),
    
    // Status
    .fault_o(fault_o),
    .break_o(break_o),
    
    // Instruction memory
    .imem_addr_o(imem_address),
    .imem_dat_i(imem_data),
    .imem_cti_o(imem_cti),
    .imem_cyc_o(imem_cyc),
    .imem_stb_o(imem_stb),
    .imem_stall_i(imem_stall),
    .imem_ack_i(imem_ack),
    
    // Data memory
    .dmem_addr_o(dmem_addr),
    .dmem_dat_o(dmem_data_w),
    .dmem_dat_i(dmem_data_r),
    .dmem_sel_o(dmem_sel),
    .dmem_cti_o(dmem_cti),
    .dmem_cyc_o(dmem_cyc),
    .dmem_we_o(dmem_we),
    .dmem_stb_o(dmem_stb),
    .dmem_stall_i(dmem_stall),
    .dmem_ack_i(dmem_ack)
);

//-----------------------------------------------------------------
// Instruction Memory MUX
//-----------------------------------------------------------------

assign imem0_addr_o     = imem_address;
assign imem0_sel_o      = 4'b1111;
assign imem0_stb_o      = imem_stb;
assign imem0_cyc_o      = imem_cyc;
assign imem0_cti_o      = imem_cti;
assign imem_data        = imem0_data_i;
assign imem_stall       = imem0_stall_i;
assign imem_ack         = imem0_ack_i;


//-----------------------------------------------------------------
// Data Memory MUX
//-----------------------------------------------------------------
dmem_mux3
#(
    .ADDR_MUX_START(24)
)
u_dmux
(
    // Outputs
    // 0x10000000 - 0x10FFFFFF
    .out0_addr_o(dmem0_addr_o),
    .out0_data_o(dmem0_data_o),
    .out0_data_i(dmem0_data_i),
    .out0_sel_o(dmem0_sel_o),
    .out0_we_o(dmem0_we_o),
    .out0_stb_o(dmem0_stb_o),
    .out0_cyc_o(dmem0_cyc_o),
    .out0_cti_o(dmem0_cti_o),
    .out0_ack_i(dmem0_ack_i),
    .out0_stall_i(dmem0_stall_i),

    // 0x11000000 - 0x11FFFFFF
    .out1_addr_o(dmem1_addr_o),
    .out1_data_o(dmem1_data_o),
    .out1_data_i(dmem1_data_i),
    .out1_sel_o(dmem1_sel_o),
    .out1_we_o(dmem1_we_o),
    .out1_stb_o(dmem1_stb_o),
    .out1_cyc_o(dmem1_cyc_o),
    .out1_cti_o(dmem1_cti_o),
    .out1_ack_i(dmem1_ack_i),
    .out1_stall_i(dmem1_stall_i),

    // 0x12000000 - 0x12FFFFFF
    .out2_addr_o(dmem2_addr_o),
    .out2_data_o(dmem2_data_o),
    .out2_data_i(dmem2_data_i),
    .out2_sel_o(dmem2_sel_o),
    .out2_we_o(dmem2_we_o),
    .out2_stb_o(dmem2_stb_o),
    .out2_cyc_o(dmem2_cyc_o),
    .out2_cti_o(dmem2_cti_o),
    .out2_ack_i(dmem2_ack_i),
    .out2_stall_i(dmem2_stall_i),

    // Input - CPU core bus
    .mem_addr_i(dmem_addr),
    .mem_data_i(dmem_data_w),
    .mem_data_o(dmem_data_r),
    .mem_sel_i(dmem_sel),
    .mem_we_i(dmem_we),
    .mem_stb_i(dmem_stb),
    .mem_cyc_i(dmem_cyc),
    .mem_cti_i(dmem_cti),
    .mem_ack_o(dmem_ack),
    .mem_stall_o(dmem_stall)
);

endmodule
