//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone master interface for the Amber core                //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Turns memory access requests from the execute stage and     //
//  cache into wishbone bus cycles. For 4-word read requests    //
//  from the cache and swap accesses ( read followed by write   //
//  to the same address) from the execute stage,                //
//  a block transfer is done. All other requests result in      //
//  single word transfers.                                      //
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


module a23_wishbone
(
input                       i_clk,

// Core Accesses to Wishbone bus
input                       i_select,
input       [31:0]          i_write_data,
input                       i_write_enable,
input       [3:0]           i_byte_enable,    // valid for writes only
input                       i_data_access,
input                       i_exclusive,      // high for read part of swap access
input       [31:0]          i_address,
output                      o_stall,

// Cache Accesses to Wishbone bus
input                       i_cache_req,

// Wishbone Bus
output reg  [31:0]          o_wb_adr = 'd0,
output reg  [3:0]           o_wb_sel = 'd0,
output reg                  o_wb_we  = 'd0,
input       [31:0]          i_wb_dat,
output reg  [31:0]          o_wb_dat = 'd0,
output reg                  o_wb_cyc = 'd0,
output reg                  o_wb_stb = 'd0,
input                       i_wb_ack,
input                       i_wb_err

);


localparam [3:0] WB_IDLE            = 3'd0,
                 WB_BURST1          = 3'd1,
                 WB_BURST2          = 3'd2,
                 WB_BURST3          = 3'd3,
                 WB_WAIT_ACK        = 3'd4;

reg     [2:0]               wishbone_st = WB_IDLE;

wire                        core_read_request;
wire                        core_write_request;
wire                        cache_read_request;
wire                        cache_write_request;
wire                        start_access;
reg                         servicing_cache = 'd0;
wire    [3:0]               byte_enable;
reg                         exclusive_access = 'd0;
wire                        read_ack;
wire                        wait_write_ack;
wire                        wb_wait;

// Write buffer
reg     [31:0]              wbuf_addr_r = 'd0;
reg     [3:0]               wbuf_sel_r  = 'd0;
reg                         wbuf_busy_r = 'd0;


assign read_ack             = !o_wb_we && i_wb_ack;
assign o_stall              = ( core_read_request  && !read_ack )       || 
                              ( core_read_request  && servicing_cache ) ||
                              ( core_write_request && servicing_cache ) ||
                              ( core_write_request && wishbone_st == WB_WAIT_ACK) ||
                              ( cache_write_request && wishbone_st == WB_WAIT_ACK) ||
                              wbuf_busy_r;

                              // Don't stall on writes
                              // Wishbone is doing burst read so make core wait to execute the write
                              // ( core_write_request && !i_wb_ack )  ;
                              
assign core_read_request    = i_select && !i_write_enable;
assign core_write_request   = i_select &&  i_write_enable;

assign cache_read_request   = i_cache_req && !i_write_enable;
assign cache_write_request  = i_cache_req &&  i_write_enable;

assign wb_wait              = o_wb_stb && !i_wb_ack;
assign start_access         = (core_read_request || core_write_request || i_cache_req) && !wb_wait ;

// For writes the byte enable is always 4'hf
assign byte_enable          = wbuf_busy_r                                   ? wbuf_sel_r    :
                              ( core_write_request || cache_write_request ) ? i_byte_enable : 
                                                                              4'hf          ;
                                    


// ======================================
// Write buffer
// ======================================


always @( posedge i_clk )
    if ( wb_wait && !wbuf_busy_r && (core_write_request || cache_write_request) )
        begin
        wbuf_addr_r <= i_address;
        wbuf_sel_r  <= i_byte_enable;
        wbuf_busy_r <= 1'd1;
        end
    else if (!o_wb_stb)
        wbuf_busy_r <= 1'd0;
    
// ======================================
// Register Accesses
// ======================================
always @( posedge i_clk )
    if ( start_access )
        o_wb_dat <= i_write_data;


assign wait_write_ack = o_wb_stb && o_wb_we && !i_wb_ack;


always @( posedge i_clk )
    case ( wishbone_st )
        WB_IDLE :
            begin 
                
            if ( start_access )
                begin
                o_wb_stb            <= 1'd1; 
                o_wb_cyc            <= 1'd1; 
                o_wb_sel            <= byte_enable;
                end
            else if ( !wait_write_ack )
                begin
                o_wb_stb            <= 1'd0;
                
                // Hold cyc high after an exclusive access
                // to hold ownership of the wishbone bus
                o_wb_cyc            <= exclusive_access;
                end

            // cache has priority over the core                     
            servicing_cache <= cache_read_request && !wait_write_ack;

            if ( wait_write_ack )
                begin
                // still waiting for last (write) access to complete
                wishbone_st      <= WB_WAIT_ACK;
                end  
            // do a burst of 4 read to fill a cache line                   
            else if ( cache_read_request )
                begin
                wishbone_st         <= WB_BURST1;
                exclusive_access    <= 1'd0;
                end                    
            else if ( core_read_request )
                begin
                wishbone_st         <= WB_WAIT_ACK;
                exclusive_access    <= i_exclusive;
                end                    
           // The core does not currently issue exclusive write requests
           // but there's no reason why this might not be added some
           // time in the future so allow for it here
            else if ( core_write_request )
                exclusive_access <= i_exclusive;

                            
            if ( start_access )
                begin
                if (wbuf_busy_r)
                    begin
                    o_wb_we              <= 1'd1;
                    o_wb_adr[31:2]       <= wbuf_addr_r[31:2];
                    end
                else
                    begin
                    o_wb_we              <= core_write_request || cache_write_request;
                    // only update these on new wb access to make debug easier
                    o_wb_adr[31:2]       <= i_address[31:2];
                    end
                    
                o_wb_adr[1:0]        <= byte_enable == 4'b0001 ? 2'd0 :
                                        byte_enable == 4'b0010 ? 2'd1 :
                                        byte_enable == 4'b0100 ? 2'd2 :
                                        byte_enable == 4'b1000 ? 2'd3 :
                                       
                                        byte_enable == 4'b0011 ? 2'd0 :
                                        byte_enable == 4'b1100 ? 2'd2 :
                                       
                                                                 2'd0 ;
                end
            end
                    

        // Read burst, wait for first ack
        WB_BURST1:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_BURST2;
                end
            
            
        // Read burst, wait for second ack
        WB_BURST2:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_BURST3;
                end
            
            
        // Read burst, wait for third ack
        WB_BURST3:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_WAIT_ACK;
                end


        // Wait for the wishbone ack to be asserted
        WB_WAIT_ACK:   
            if ( i_wb_ack )
                begin
                wishbone_st         <= WB_IDLE;
                o_wb_stb            <= 1'd0; 
                o_wb_cyc            <= exclusive_access; 
                o_wb_we             <= 1'd0;
                servicing_cache     <= 1'd0;
                end
                         
    endcase
        
        

// ========================================================
// Debug Wishbone bus - not synthesizable
// ========================================================
//synopsys translate_off
wire    [(14*8)-1:0]   xAS_STATE;


assign xAS_STATE  = wishbone_st == WB_IDLE       ? "WB_IDLE"       :
                    wishbone_st == WB_BURST1     ? "WB_BURST1"     :
                    wishbone_st == WB_BURST2     ? "WB_BURST2"     :
                    wishbone_st == WB_BURST3     ? "WB_BURST3"     :
                    wishbone_st == WB_WAIT_ACK   ? "WB_WAIT_ACK"   :
                                                      "UNKNOWN"       ;

//synopsys translate_on
    
endmodule

