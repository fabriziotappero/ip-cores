//////////////////////////////////////////////////////////////////
//                                                              //
//  8KBytes SRAM configured with boot software                  //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Holds just enough software to get the system going.         //
//  The boot loader fits into this 8KB embedded SRAM on the     //
//  FPGA and enables it to load large applications via the      //
//  serial port (UART) into the DDR3 memory                     //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module boot_mem32 #(
parameter WB_DWIDTH   = 32,
parameter WB_SWIDTH   = 4,
parameter MADDR_WIDTH = 12
)(
input                       i_wb_clk,     // WISHBONE clock

input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
output      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
output                      o_wb_ack,
output                      o_wb_err

);

wire                    start_write;
wire                    start_read;
`ifdef AMBER_WISHBONE_DEBUG
    reg  [7:0]              jitter_r = 8'h0f;
    reg  [1:0]              start_read_r = 'd0;
`else
    reg                     start_read_r = 'd0;
`endif
wire [WB_DWIDTH-1:0]    read_data;
wire [WB_DWIDTH-1:0]    write_data;
wire [WB_SWIDTH-1:0]    byte_enable;
wire [MADDR_WIDTH-1:0]  address;


// Can't start a write while a read is completing. The ack for the read cycle
// needs to be sent first
`ifdef AMBER_WISHBONE_DEBUG
    assign start_write = i_wb_stb &&  i_wb_we && !(|start_read_r) && jitter_r[0];
`else
    assign start_write = i_wb_stb &&  i_wb_we && !(|start_read_r);
`endif
assign start_read  = i_wb_stb && !i_wb_we && !start_read_r;


`ifdef AMBER_WISHBONE_DEBUG
    always @( posedge i_wb_clk )
        jitter_r <= {jitter_r[6:0], jitter_r[7] ^ jitter_r[4] ^ jitter_r[1]};
        
    always @( posedge i_wb_clk )
        if (start_read)
            start_read_r <= {3'd0, start_read};
        else if (o_wb_ack)
            start_read_r <= 'd0;
        else
            start_read_r <= {start_read_r[2:0], start_read};
`else
    always @( posedge i_wb_clk )
        start_read_r <= start_read;
`endif

assign o_wb_err = 1'd0;

assign write_data  = i_wb_dat;
assign byte_enable = i_wb_sel;
assign o_wb_dat    = read_data;
assign address     = i_wb_adr[MADDR_WIDTH+1:2];

`ifdef AMBER_WISHBONE_DEBUG
    assign o_wb_ack    = i_wb_stb && ( start_write || start_read_r[jitter_r[1]] );
`else
    assign o_wb_ack    = i_wb_stb && ( start_write || start_read_r );
`endif

// ------------------------------------------------------
// Instantiate SRAMs
// ------------------------------------------------------
//         
`ifdef XILINX_FPGA
    xs6_sram_4096x32_byte_en
#(
// This file holds a software image used for FPGA simulations
// This pre-processor syntax works with both the simulator
// and ISE, which I couldn't get to work with giving it the
// file name as a define.

`ifdef BOOT_MEM32_PARAMS_FILE
    `include `BOOT_MEM32_PARAMS_FILE
`else
    `ifdef BOOT_LOADER_ETHMAC
        `include "boot-loader-ethmac_memparams32.v"
    `else
        // default file
        `include "boot-loader_memparams32.v"
    `endif
`endif

)
`endif 

`ifndef XILINX_FPGA
generic_sram_byte_en
#(
    .DATA_WIDTH     ( WB_DWIDTH             ),
    .ADDRESS_WIDTH  ( MADDR_WIDTH           )
)
`endif 
u_mem (
    .i_clk          ( i_wb_clk             ),
    .i_write_enable ( start_write          ),
    .i_byte_enable  ( byte_enable          ),
    .i_address      ( address              ),  // 2048 words, 32 bits
    .o_read_data    ( read_data            ),
    .i_write_data   ( write_data           )
);


// =======================================================================================
// =======================================================================================
// =======================================================================================
// Non-synthesizable debug code
// =======================================================================================


//synopsys translate_off
`ifdef XILINX_SPARTAN6_FPGA
    `ifdef BOOT_MEM32_PARAMS_FILE
        initial
            $display("Boot mem file is %s", `BOOT_MEM32_PARAMS_FILE );
    `endif
`endif
//synopsys translate_on
    
endmodule


