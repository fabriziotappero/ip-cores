//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone Slave to Xilinx MCB (DDR3 controller) Bridge       //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Converts wishbone read and write accesses to the signalling //
//  used by the Xilinx DDR3 Controller in Spartan-6 FPGAs.      //
//                                                              //
//  The MCB is confgiured with a single 128-bit port.           //
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


module wb_ddr3_bridge
(
input                          i_clk,

// MBus Ports
input       [31:0]             i_wb_adr,
input       [3:0]              i_wb_sel,
input                          i_wb_we,
output reg  [31:0]             o_wb_dat         = 'd0,
input       [31:0]             i_wb_dat,
input                          i_wb_cyc,
input                          i_wb_stb,
output                         o_wb_ack,
output                         o_wb_err,

output reg                     o_cmd_en         = 'd0,  // Command Enable
output reg [2:0]               o_cmd_instr      = 'd0,  // write = 000, read = 001
output reg [29:0]              o_cmd_byte_addr  = 'd0,  // Memory address
input                          i_cmd_full,              // DDR3 I/F Command FIFO is full

input                          i_wr_full,               // DDR3 I/F Write Data FIFO is full
output reg                     o_wr_en          = 'd0,  // Write data enable
output reg [15:0]              o_wr_mask        = 'd0,  // 1 bit per byte
output reg [127:0]             o_wr_data        = 'd0,  // 16 bytes write data
input      [127:0]             i_rd_data,               // 16 bytes of read data
input                          i_rd_empty               // low when read data is valid

);
                 
wire            start_write;
wire            start_read;
reg             start_write_d1;
reg             start_read_d1;
reg             start_read_hold = 'd0;
reg  [31:0]     wb_adr_d1;
wire            ddr3_busy;
reg             read_ack = 'd0;
reg             read_ready = 1'd1;

assign start_write = i_wb_stb && i_wb_we && !start_read_d1;
assign start_read  = i_wb_stb && !i_wb_we && read_ready;
assign ddr3_busy   = i_cmd_full || i_wr_full;

assign o_wb_err = 'd0;

// ------------------------------------------------------
// Outputs
// ------------------------------------------------------

// Command FIFO
always @( posedge i_clk )
    begin
    o_cmd_byte_addr  <= {wb_adr_d1[29:4], 4'd0};
    o_cmd_en         <= !ddr3_busy && ( start_write_d1 || start_read_d1 );
    o_cmd_instr      <= start_write_d1 ? 3'd0 : 3'd1;
    end


// ------------------------------------------------------
// Write
// ------------------------------------------------------
always @( posedge i_clk )
    begin
    o_wr_en          <= start_write;
    
    `ifdef XILINX_VIRTEX6_FPGA
        o_wr_mask        <= i_wb_adr[2] == 2'd2 ? { 8'h0, 4'hf,  ~i_wb_sel        } : 
                                                  { 8'h0,        ~i_wb_sel, 4'hf  } ; 
    `else
        o_wr_mask        <= i_wb_adr[3:2] == 2'd0 ? { 12'hfff, ~i_wb_sel          } : 
                            i_wb_adr[3:2] == 2'd1 ? { 8'hff,   ~i_wb_sel, 4'hf    } : 
                            i_wb_adr[3:2] == 2'd2 ? { 4'hf,    ~i_wb_sel, 8'hff   } : 
                                                    {          ~i_wb_sel, 12'hfff } ; 
    `endif
    
    o_wr_data        <= {4{i_wb_dat}};
    end

    
// ------------------------------------------------------
// Read
// ------------------------------------------------------

always @( posedge i_clk )
    begin
    if ( read_ack )
        read_ready <= 1'd1;
    else if ( start_read )
        read_ready <= 1'd0;
    
    start_write_d1  <= start_write;
    start_read_d1   <= start_read;
    wb_adr_d1       <= i_wb_adr;
    
    if ( start_read  )
        start_read_hold <= 1'd1;
    else if ( read_ack )
        start_read_hold <= 1'd0;
    
    if ( i_rd_empty == 1'd0 && start_read_hold )
        begin
        `ifdef XILINX_VIRTEX6_FPGA
            o_wb_dat  <= i_wb_adr[2] == 2'd2   ? i_rd_data[  31:0] :
                                                 i_rd_data[ 63:32] ;
        `else
            o_wb_dat  <= i_wb_adr[3:2] == 2'd0 ? i_rd_data[ 31: 0] :
                         i_wb_adr[3:2] == 2'd1 ? i_rd_data[ 63:32] :
                         i_wb_adr[3:2] == 2'd2 ? i_rd_data[ 95:64] :
                                                 i_rd_data[127:96] ;
        `endif
        read_ack  <= 1'd1;
        end
    else
        read_ack  <= 1'd0;
    end
                    
assign o_wb_ack = i_wb_stb && ( start_write || read_ack );


// Debug DDR3 - Wishbone Bridge  - not synthesizable
// ========================================================
//synopsys translate_off

`ifdef LP_MEMIF_DEBUG
    always @( posedge i_clk )
        begin
        if (start_write)
            $display("DDR3 Write Addr 0x%08x Data 0x%08h %08h %08h %08h, BE %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d", 
                     i_i_wb_adr, i_mwdata[127:96], i_mwdata[95:64], i_mwdata[63:32], i_mwdata[31:0],
                     i_mwben[15], i_mwben[14], i_mwben[13], i_mwben[12], 
                     i_mwben[11], i_mwben[10], i_mwben[9],  i_mwben[8], 
                     i_mwben[7],  i_mwben[6],  i_mwben[5],  i_mwben[4], 
                     i_mwben[3],  i_mwben[2],  i_mwben[1],  i_mwben[0] 
                     );
                     
        if (i_rd_empty == 1'd0)
            $display("DDR3 Read  Addr 0x%08x Data 0x%08h %08h %08h %08h", 
                     i_i_wb_adr, i_rd_data[127:96], i_rd_data [95:64], i_rd_data [63:32], i_rd_data [31:0]);
        end
`endif
//synopsys translate_on

    
endmodule

