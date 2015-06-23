//////////////////////////////////////////////////////////////////
//                                                              //
//  Memory Access - Instantiates the memory access stage        //
//  sub-modules of the Amber 25 Core                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Instantiates the Data Cache                                 //
//  Also contains a little bit of logic to decode memory        //
//  accesses to decide if they are cached or not                //
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


module a25_mem
(
input                       i_clk,
input                       i_fetch_stall,          // Fetch stage asserting stall
input                       i_exec_stall,           // Execute stage asserting stall
output                      o_mem_stall,            // Mem stage asserting stall

input       [31:0]          i_daddress,
input                       i_daddress_valid,
input       [31:0]          i_daddress_nxt,         // un-registered version of address to the cache rams
input       [31:0]          i_write_data,
input                       i_write_enable,
input                       i_exclusive,            // high for read part of swap access
input       [3:0]           i_byte_enable,
input       [8:0]           i_exec_load_rd,         // The destination register for a load instruction
input                       i_cache_enable,         // cache enable
input                       i_cache_flush,          // cache flush
input       [31:0]          i_cacheable_area,       // each bit corresponds to 2MB address space

output      [31:0]          o_mem_read_data,
output                      o_mem_read_data_valid,
output      [10:0]          o_mem_load_rd,          // The destination register for a load instruction

// Wishbone accesses                                                         
output                      o_wb_cached_req,        // Cached Request
output                      o_wb_uncached_req,      // Unached Request
output                      o_wb_write,             // Read=0, Write=1
output     [15:0]           o_wb_byte_enable,       // byte eable
output     [127:0]          o_wb_write_data,
output     [31:0]           o_wb_address,           // wb bus                                 
input      [127:0]          i_wb_uncached_rdata,    // wb bus                              
input      [127:0]          i_wb_cached_rdata,      // wb bus                              
input                       i_wb_cached_ready,      // wishbone access complete and read data valid
input                       i_wb_uncached_ready     // wishbone access complete and read data valid
);

`include "memory_configuration.vh"

wire    [31:0]              cache_read_data;
wire                        address_cachable;
wire                        sel_cache_p;
wire                        sel_cache;
wire                        cached_wb_req;
wire                        uncached_data_access;
wire                        uncached_data_access_p;
wire                        cache_stall;
wire                        uncached_wb_wait;
reg                         uncached_wb_req_r = 'd0;
reg                         uncached_wb_stop_r = 'd0;
reg                         cached_wb_stop_r = 'd0;
wire                        daddress_valid_p;  // pulse
reg      [31:0]             mem_read_data_r = 'd0;
reg                         mem_read_data_valid_r = 'd0;
reg      [10:0]             mem_load_rd_r = 'd0;
wire     [10:0]             mem_load_rd_c;
wire     [31:0]             mem_read_data_c;
wire                        mem_read_data_valid_c;
reg                         mem_stall_r = 'd0;
wire                        use_mem_reg;
reg                         fetch_only_stall_r = 'd0;
wire                        fetch_only_stall;
wire                        void_output;
wire                        wb_stop;
reg                         daddress_valid_stop_r = 'd0;
wire     [31:0]             wb_rdata32;

// ======================================
// Memory Decode
// ======================================
assign address_cachable         = in_cachable_mem( i_daddress ) && i_cacheable_area[i_daddress[25:21]];
assign sel_cache_p              = daddress_valid_p && address_cachable && i_cache_enable && !i_exclusive;
assign sel_cache                = i_daddress_valid && address_cachable && i_cache_enable && !i_exclusive;
assign uncached_data_access     = i_daddress_valid && !sel_cache && !cache_stall;
assign uncached_data_access_p   = daddress_valid_p && !sel_cache;

assign use_mem_reg              = wb_stop && !mem_stall_r;
assign o_mem_read_data          = use_mem_reg ? mem_read_data_r       : mem_read_data_c;
assign o_mem_load_rd            = use_mem_reg ? mem_load_rd_r         : mem_load_rd_c;
assign o_mem_read_data_valid    = !void_output && (use_mem_reg ? mem_read_data_valid_r : mem_read_data_valid_c);


// Return read data either from the wishbone bus or the cache
assign wb_rdata32               = i_daddress[3:2] == 2'd0 ? i_wb_uncached_rdata[ 31: 0] :
                                  i_daddress[3:2] == 2'd1 ? i_wb_uncached_rdata[ 63:32] :
                                  i_daddress[3:2] == 2'd2 ? i_wb_uncached_rdata[ 95:64] :
                                                            i_wb_uncached_rdata[127:96] ;
                                                            
assign mem_read_data_c          = sel_cache             ? cache_read_data : 
                                  uncached_data_access  ? wb_rdata32      :
                                                          32'h76543210    ;
                                                          
assign mem_load_rd_c            = {i_daddress[1:0], i_exec_load_rd};
assign mem_read_data_valid_c    = i_daddress_valid && !i_write_enable && !o_mem_stall;

assign o_mem_stall              = uncached_wb_wait || cache_stall;

// Request wishbone access
assign o_wb_byte_enable         = i_daddress[3:2] == 2'd0 ? {12'd0, i_byte_enable       } :
                                  i_daddress[3:2] == 2'd1 ? { 8'd0, i_byte_enable,  4'd0} :
                                  i_daddress[3:2] == 2'd2 ? { 4'd0, i_byte_enable,  8'd0} :
                                                            {       i_byte_enable, 12'd0} ;

assign o_wb_write               = i_write_enable;
assign o_wb_address             = {i_daddress[31:2], 2'd0};
assign o_wb_write_data          = {4{i_write_data}};
assign o_wb_cached_req          = !cached_wb_stop_r && cached_wb_req;
assign o_wb_uncached_req        = !uncached_wb_stop_r && uncached_data_access_p;

assign uncached_wb_wait         = (o_wb_uncached_req || uncached_wb_req_r) && !i_wb_uncached_ready;

always @( posedge i_clk )
    begin
    uncached_wb_req_r <=  (o_wb_uncached_req || uncached_wb_req_r) && !i_wb_uncached_ready;
    end

assign fetch_only_stall     = i_fetch_stall && !o_mem_stall;

always @( posedge i_clk )
    fetch_only_stall_r <= fetch_only_stall;

assign void_output = (fetch_only_stall_r && fetch_only_stall) || (fetch_only_stall_r && mem_read_data_valid_r);


// pulse this signal
assign daddress_valid_p = i_daddress_valid && !daddress_valid_stop_r;

always @( posedge i_clk )
    begin
    uncached_wb_stop_r      <= (uncached_wb_stop_r || (uncached_data_access_p&&!cache_stall)) && (i_fetch_stall || o_mem_stall);
    cached_wb_stop_r        <= (cached_wb_stop_r   || cached_wb_req)          && (i_fetch_stall || o_mem_stall);
    daddress_valid_stop_r   <= (daddress_valid_stop_r || daddress_valid_p)    && (i_fetch_stall || o_mem_stall);
    // hold this until the mem access completes
    mem_stall_r <= o_mem_stall;
    end


assign wb_stop = uncached_wb_stop_r || cached_wb_stop_r;

always @( posedge i_clk )
    if ( !wb_stop || o_mem_stall )
        begin
        mem_read_data_r         <= mem_read_data_c;
        mem_load_rd_r           <= mem_load_rd_c;
        mem_read_data_valid_r   <= mem_read_data_valid_c;
        end


// ======================================
// L1 Data Cache
// ======================================
a25_dcache u_dcache (
    .i_clk                      ( i_clk                 ),
    .i_fetch_stall              ( i_fetch_stall         ),
    .i_exec_stall               ( i_exec_stall          ),
    .o_stall                    ( cache_stall           ),
     
    .i_request                  ( sel_cache_p           ),
    .i_exclusive                ( i_exclusive           ),
    .i_write_data               ( i_write_data          ),
    .i_write_enable             ( i_write_enable        ),
    .i_address                  ( i_daddress            ),
    .i_address_nxt              ( i_daddress_nxt        ),
    .i_byte_enable              ( i_byte_enable         ),

    .i_cache_enable             ( i_cache_enable        ),
    .i_cache_flush              ( i_cache_flush         ),
    .o_read_data                ( cache_read_data       ),
    
    .o_wb_cached_req            ( cached_wb_req         ),
    .i_wb_cached_rdata          ( i_wb_cached_rdata     ),
    .i_wb_cached_ready          ( i_wb_cached_ready     )
);



endmodule

