//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone Slave to Xilinx Spartan-6 MCB (DDR3 controller)    //
//  Bridge                                                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Converts wishbone read and write accesses to the signalling //
//  used by the Xilinx DDR3 Controller in Spartan-6 FPGAs.      //
//                                                              //
//  The MCB is configured with a single 128-bit port.           //
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
`include "global_defines.vh"

module wb_xs6_ddr3_bridge #(
parameter WB_DWIDTH   = 32,
parameter WB_SWIDTH   = 4
)(
input                          i_clk,

input                          i_mem_ctrl,  // 0=128MB, 1=32MB

// Wishbone Bus
input       [31:0]             i_wb_adr,
input       [WB_SWIDTH-1:0]    i_wb_sel,
input                          i_wb_we,
output reg  [WB_DWIDTH-1:0]    o_wb_dat         = 'd0,
input       [WB_DWIDTH-1:0]    i_wb_dat,
input                          i_wb_cyc,
input                          i_wb_stb,
output                         o_wb_ack,
output                         o_wb_err,

output                         o_cmd_en,                // Command Enable
output reg [2:0]               o_cmd_instr      = 'd0,  // write = 000, read = 001
output reg [29:0]              o_cmd_byte_addr  = 'd0,  // Memory address
input                          i_cmd_full,              // DDR3 I/F Command FIFO is full

input                          i_wr_full,               // DDR3 I/F Write Data FIFO is full
output                         o_wr_en,                 // Write data enable
output reg [15:0]              o_wr_mask        = 'd0,  // 1 bit per byte
output reg [127:0]             o_wr_data        = 'd0,  // 16 bytes write data
input      [127:0]             i_rd_data,               // 16 bytes of read data
input                          i_rd_empty               // low when read data is valid

);
                 
wire            write_request;
wire            read_request;
reg             write_request_r;
reg             read_request_r;
reg             read_active_r = 'd0;
reg  [29:0]     wb_adr_r;
reg             cmd_full_r = 1'd0;
reg             read_ack_r = 'd0;
reg             read_ready = 1'd1;
reg             cmd_en_r = 'd0;
reg             wr_en_r = 'd0;
wire            write_ack;

// Buffer 1 write request
reg                     write_buf_r = 1'd0;
reg     [WB_SWIDTH-1:0] wb_sel_buf_r = 'd0;
reg     [WB_DWIDTH-1:0] wb_dat_buf_r = 'd0;
reg     [31:0]          wb_adr_buf_r = 'd0;
wire    [WB_SWIDTH-1:0] wb_sel;
wire    [WB_DWIDTH-1:0] wb_dat;
wire    [31:0]          wb_adr;


assign write_request = i_wb_stb && i_wb_we && !read_request_r;
assign read_request  = i_wb_stb && !i_wb_we && read_ready;

assign o_wb_err      = 'd0;

// ------------------------------------------------------
// Outputs
// ------------------------------------------------------
always @( posedge i_clk )
    cmd_full_r       <= i_cmd_full;

// Command FIFO
always @( posedge i_clk )
    if ( !i_cmd_full )
        begin
        o_cmd_byte_addr  <= {wb_adr_r[29:4], 4'd0};
        cmd_en_r         <= ( write_request_r || read_request_r );
        o_cmd_instr      <= write_request_r ? 3'd0 : 3'd1;
        end

assign o_cmd_en = cmd_en_r && !i_cmd_full;


// ------------------------------------------------------
// Write Buffer
// ------------------------------------------------------
always @( posedge i_clk )
    if ( i_cmd_full && write_request )
        begin
        write_buf_r     <= 1'd1;
        wb_sel_buf_r    <= i_wb_sel;
        wb_dat_buf_r    <= i_wb_dat;
        wb_adr_buf_r    <= i_wb_adr;
        end
    else if ( !i_cmd_full )
        write_buf_r     <= 1'd0;

// ------------------------------------------------------
// Write
// ------------------------------------------------------

// Select between incoming reqiests and the write request buffer
assign wb_sel = write_buf_r ? wb_sel_buf_r : i_wb_sel;
assign wb_dat = write_buf_r ? wb_dat_buf_r : i_wb_dat;
assign wb_adr = write_buf_r ? wb_adr_buf_r : i_wb_adr;


generate
if (WB_DWIDTH == 32) begin :wb32w

    always @( posedge i_clk )
        if ( !i_cmd_full )
            begin
            wr_en_r    <= write_request || write_buf_r;
            
            o_wr_mask  <= wb_adr[3:2] == 2'd0 ? { 12'hfff, ~wb_sel          } : 
                          wb_adr[3:2] == 2'd1 ? { 8'hff,   ~wb_sel, 4'hf    } : 
                          wb_adr[3:2] == 2'd2 ? { 4'hf,    ~wb_sel, 8'hff   } : 
                                                {          ~wb_sel, 12'hfff } ; 
            
            o_wr_data  <= {4{wb_dat}};
            end

end
else begin : wb128w

    always @( posedge i_clk )
        if ( !i_cmd_full )
            begin
            wr_en_r    <= write_request;
            o_wr_mask  <= ~wb_sel; 
            o_wr_data  <= wb_dat;
            end

end
endgenerate

assign o_wr_en = wr_en_r && !i_cmd_full;


// ------------------------------------------------------
// Read
// ------------------------------------------------------
always @( posedge i_clk )
    begin
    if ( read_ack_r )
        read_ready <= 1'd1;
    else if ( read_request )
        read_ready <= 1'd0;
    
    if ( !i_cmd_full )
        begin
        write_request_r  <= write_request;
        read_request_r   <= read_request;
        wb_adr_r         <= i_mem_ctrl ? {5'd0, i_wb_adr[24:0]} : i_wb_adr[29:0];
        end
        
    if ( read_request  )
        read_active_r <= 1'd1;
    else if ( read_ack_r )
        read_active_r <= 1'd0;
    
    if ( i_rd_empty == 1'd0 && read_active_r )
        read_ack_r  <= 1'd1;
    else
        read_ack_r  <= 1'd0;
    end


generate
if (WB_DWIDTH == 32) begin :wb32r

    always @( posedge i_clk )
        if ( !i_rd_empty && read_active_r )
            o_wb_dat  <= i_wb_adr[3:2] == 2'd0 ? i_rd_data[ 31: 0] :
                         i_wb_adr[3:2] == 2'd1 ? i_rd_data[ 63:32] :
                         i_wb_adr[3:2] == 2'd2 ? i_rd_data[ 95:64] :
                                                 i_rd_data[127:96] ;

end
else begin : wb128r

    always @( posedge i_clk )
        if ( !i_rd_empty && read_active_r )
            o_wb_dat  <= i_rd_data;

end
endgenerate

assign write_ack = write_request && !write_buf_r;         
assign o_wb_ack  = ( i_wb_stb && read_ack_r ) || write_ack;

    
endmodule

