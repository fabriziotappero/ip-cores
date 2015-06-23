//////////////////////////////////////////////////////////////////
//                                                              //
//  Fetch - Instantiates the fetch stage sub-modules of         //
//  the Amber 2 Core                                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Instantiates the Cache and Wishbone I/F                     //
//  Also contains a little bit of logic to decode memory        //
//  accesses to decide if they are cached or not                //
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


module a23_fetch
(
input                       i_clk,

input       [31:0]          i_address,
input                       i_address_valid,
input       [31:0]          i_address_nxt,      // un-registered version of address to the cache rams
input       [31:0]          i_write_data,
input                       i_write_enable,
output       [31:0]         o_read_data,
input                       i_priviledged,
input                       i_exclusive,        // high for read part of swap access
input       [3:0]           i_byte_enable,
input                       i_data_access,      // high for data petch, low for instruction fetch
input                       i_cache_enable,     // cache enable
input                       i_cache_flush,      // cache flush
input       [31:0]          i_cacheable_area,   // each bit corresponds to 2MB address space
input                       i_system_rdy,
output                      o_fetch_stall,      // when this is asserted all registers 
                                                // in all 3 pipeline stages are held
                                                // at their current values

// Wishbone Master I/F
output      [31:0]          o_wb_adr,
output      [3:0]           o_wb_sel,
output                      o_wb_we,
input       [31:0]          i_wb_dat,
output      [31:0]          o_wb_dat,
output                      o_wb_cyc,
output                      o_wb_stb,
input                       i_wb_ack,
input                       i_wb_err

);

`include "memory_configuration.vh"

wire                        cache_stall;
wire                        wb_stall;
wire    [31:0]              cache_read_data;
wire                        sel_cache;
wire                        sel_wb;
wire                        cache_wb_req;
wire                        address_cachable;

// ======================================
// Memory Decode
// ======================================
assign address_cachable  = in_cachable_mem( i_address ) && i_cacheable_area[i_address[25:21]];

assign sel_cache         = address_cachable && i_address_valid && i_cache_enable &&  !i_exclusive;

// Don't start wishbone transfers when the cache is stalling the core
// The cache stalls the core during its initialization sequence
assign sel_wb            = !sel_cache && i_address_valid && !(cache_stall);

// Return read data either from the wishbone bus or the cache
assign o_read_data       = sel_cache  ? cache_read_data : 
                           sel_wb     ? i_wb_dat        :
                                        32'hffeeddcc    ;

// Stall the instruction decode and execute stages of the core
// when the fetch stage needs more than 1 cycle to return the requested
// read data
assign o_fetch_stall     = !i_system_rdy || wb_stall || cache_stall;


// ======================================
// L1 Cache (Unified Instruction and Data)
// ======================================
a23_cache u_cache (
    .i_clk                      ( i_clk                 ),
     
    .i_select                   ( sel_cache             ),
    .i_exclusive                ( i_exclusive           ),
    .i_write_data               ( i_write_data          ),
    .i_write_enable             ( i_write_enable        ),
    .i_address                  ( i_address             ),
    .i_address_nxt              ( i_address_nxt         ),
    .i_byte_enable              ( i_byte_enable         ),
    .i_cache_enable             ( i_cache_enable        ),
    .i_cache_flush              ( i_cache_flush         ),
    .o_read_data                ( cache_read_data       ),
    
    .o_stall                    ( cache_stall           ),
    .i_core_stall               ( o_fetch_stall         ),
    .o_wb_req                   ( cache_wb_req          ),
    .i_wb_address               ( o_wb_adr              ),
    .i_wb_read_data             ( i_wb_dat              ),
    .i_wb_stall                 ( o_wb_stb & ~i_wb_ack  )
);



// ======================================
//  Wishbone Master I/F
// ======================================
a23_wishbone u_wishbone (
    // CPU Side
    .i_clk                      ( i_clk                 ),
    
    // Core Accesses to Wishbone bus
    .i_select                   ( sel_wb                ),
    .i_write_data               ( i_write_data          ),
    .i_write_enable             ( i_write_enable        ),
    .i_byte_enable              ( i_byte_enable         ),
    .i_data_access              ( i_data_access         ),
    .i_exclusive                ( i_exclusive           ),
    .i_address                  ( i_address             ),
    .o_stall                    ( wb_stall              ),

    // Cache Accesses to Wishbone bus 
    // L1 Cache enable - used for hprot
    .i_cache_req                ( cache_wb_req          ),

    .o_wb_adr                   ( o_wb_adr              ),
    .o_wb_sel                   ( o_wb_sel              ),
    .o_wb_we                    ( o_wb_we               ),
    .i_wb_dat                   ( i_wb_dat              ),
    .o_wb_dat                   ( o_wb_dat              ),
    .o_wb_cyc                   ( o_wb_cyc              ),
    .o_wb_stb                   ( o_wb_stb              ),
    .i_wb_ack                   ( i_wb_ack              ),
    .i_wb_err                   ( i_wb_err              )
);


endmodule

