//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone master interface for the Amber 25 core             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Turns memory access requests from the execute stage and     //
//  instruction and data caches into wishbone bus cycles.       //
//  For 4-word read requests from either cache and swap         //
//  accesses ( read followed by write to the same address)      //
//  from the execute stage, a block transfer is done.           //
//  All other requests result in single word transfers.         //
//                                                              //
//  Write accesses can be done in a single clock cycle on       //
//  the wishbone bus, is the destination allows it. The         //
//  next transfer will begin immediately on the                 //
//  next cycle on the bus. This looks like a block transfer     //
//  and does hold ownership of the wishbone bus, preventing     //
//  the other master ( the ethernet MAC) from gaining           //
//  ownership between those two cycles. But otherwise it would  //
//  be necessary to insert a wait cycle after every write,      //
//  slowing down the performance of the core by around 5 to     //
//  10%.                                                        //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
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


// TODO add support for exclusive accesses

module a25_wishbone
(
input                       i_clk,


// Port 0 - dcache uncached
input                       i_port0_req,
output                      o_port0_ack,
input                       i_port0_write,
input       [127:0]         i_port0_wdata,
input       [15:0]          i_port0_be,
input       [31:0]          i_port0_addr,
output      [127:0]         o_port0_rdata,

// Port 1 - dcache cached
input                       i_port1_req,
output                      o_port1_ack,
input                       i_port1_write,
input       [127:0]         i_port1_wdata,
input       [15:0]          i_port1_be,
input       [31:0]          i_port1_addr,
output      [127:0]         o_port1_rdata,

// Port 2 - instruction cache accesses, read only
input                       i_port2_req,
output                      o_port2_ack,
input                       i_port2_write,
input       [127:0]         i_port2_wdata,
input       [15:0]          i_port2_be,
input       [31:0]          i_port2_addr,
output      [127:0]         o_port2_rdata,


// 128-bit Wishbone Bus
output reg  [31:0]          o_wb_adr = 'd0,
output reg  [15:0]          o_wb_sel = 'd0,
output reg                  o_wb_we  = 'd0,
output reg  [127:0]         o_wb_dat = 'd0,
output reg                  o_wb_cyc = 'd0,
output reg                  o_wb_stb = 'd0,
input       [127:0]         i_wb_dat,
input                       i_wb_ack,
input                       i_wb_err
);


// ----------------------------------------------------
// Parameters
// ----------------------------------------------------
localparam WBUF = 3;


// ----------------------------------------------------
// Signals
// ----------------------------------------------------
wire [0:0]                  wbuf_valid          [WBUF-1:0];
wire [0:0]                  wbuf_accepted       [WBUF-1:0];
wire [0:0]                  wbuf_write          [WBUF-1:0];
wire [127:0]                wbuf_wdata          [WBUF-1:0];
wire [15:0]                 wbuf_be             [WBUF-1:0];
wire [31:0]                 wbuf_addr           [WBUF-1:0];
wire [0:0]                  wbuf_rdata_valid    [WBUF-1:0];
wire                        new_access;
reg  [WBUF-1:0]             serving_port = 'd0;


// ----------------------------------------------------
// Instantiate the write buffers
// ----------------------------------------------------
a25_wishbone_buf u_a25_wishbone_buf_p0 (
    .i_clk          ( i_clk                 ),

    .i_req          ( i_port0_req           ),
    .o_ack          ( o_port0_ack           ),
    .i_write        ( i_port0_write         ),
    .i_wdata        ( i_port0_wdata         ),
    .i_be           ( i_port0_be            ),
    .i_addr         ( i_port0_addr          ),
    .o_rdata        ( o_port0_rdata         ),

    .o_valid        ( wbuf_valid       [0]  ),
    .i_accepted     ( wbuf_accepted    [0]  ),
    .o_write        ( wbuf_write       [0]  ),
    .o_wdata        ( wbuf_wdata       [0]  ),
    .o_be           ( wbuf_be          [0]  ),
    .o_addr         ( wbuf_addr        [0]  ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid [0]  )
    );


a25_wishbone_buf u_a25_wishbone_buf_p1 (
    .i_clk          ( i_clk                 ),

    .i_req          ( i_port1_req           ),
    .o_ack          ( o_port1_ack           ),
    .i_write        ( i_port1_write         ),
    .i_wdata        ( i_port1_wdata         ),
    .i_be           ( i_port1_be            ),
    .i_addr         ( i_port1_addr          ),
    .o_rdata        ( o_port1_rdata         ),

    .o_valid        ( wbuf_valid        [1] ),
    .i_accepted     ( wbuf_accepted     [1] ),
    .o_write        ( wbuf_write        [1] ),
    .o_wdata        ( wbuf_wdata        [1] ),
    .o_be           ( wbuf_be           [1] ),
    .o_addr         ( wbuf_addr         [1] ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid  [1] )
    );
    

a25_wishbone_buf u_a25_wishbone_buf_p2 (
    .i_clk          ( i_clk                 ),

    .i_req          ( i_port2_req           ),
    .o_ack          ( o_port2_ack           ),
    .i_write        ( i_port2_write         ),
    .i_wdata        ( i_port2_wdata         ),
    .i_be           ( i_port2_be            ),
    .i_addr         ( i_port2_addr          ),
    .o_rdata        ( o_port2_rdata         ),

    .o_valid        ( wbuf_valid        [2] ),
    .i_accepted     ( wbuf_accepted     [2] ),
    .o_write        ( wbuf_write        [2] ),
    .o_wdata        ( wbuf_wdata        [2] ),
    .o_be           ( wbuf_be           [2] ),
    .o_addr         ( wbuf_addr         [2] ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid  [2] )
    );    


assign new_access       = !o_wb_stb || i_wb_ack;
assign wbuf_accepted[0] = new_access &&  wbuf_valid[0];
assign wbuf_accepted[1] = new_access && !wbuf_valid[0] &&  wbuf_valid[1];
assign wbuf_accepted[2] = new_access && !wbuf_valid[0] && !wbuf_valid[1] && wbuf_valid[2];


always @(posedge i_clk)
    begin
    if (new_access)
        begin
        if (wbuf_valid[0])
            begin
            o_wb_adr        <= wbuf_addr [0];
            o_wb_sel        <= wbuf_be   [0];
            o_wb_we         <= wbuf_write[0];
            o_wb_dat        <= wbuf_wdata[0];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b001;
            end
        else if (wbuf_valid[1])
            begin
            o_wb_adr        <= wbuf_addr [1];
            o_wb_sel        <= wbuf_be   [1];
            o_wb_we         <= wbuf_write[1];
            o_wb_dat        <= wbuf_wdata[1];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b010;
            end
        else if (wbuf_valid[2])
            begin
            o_wb_adr        <= wbuf_addr [2];
            o_wb_sel        <= wbuf_be   [2];
            o_wb_we         <= wbuf_write[2];
            o_wb_dat        <= wbuf_wdata[2];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b100;
            end
        else
            begin
            o_wb_cyc        <= 1'd0;
            o_wb_stb        <= 1'd0;
            
            // Don't need to change these values because they are ignored
            // when stb is low, but it makes for a cleaner waveform, at the expense of a few gates
            o_wb_we         <= 1'd0;
            o_wb_adr        <= 'd0;
            o_wb_dat        <= 'd0;
            
            serving_port    <= 3'b000;
            end    
        end
    end


assign {wbuf_rdata_valid[2], wbuf_rdata_valid[1], wbuf_rdata_valid[0]} = {3{i_wb_ack & ~ o_wb_we}} & serving_port;

    
endmodule


