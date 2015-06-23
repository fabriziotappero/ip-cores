/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`include "defines.v"

//PARSED_COMMENTS: this file contains parsed script comments

module prefetch_control(
    input           clk,
    input           rst_n,
    
    input           pr_reset, //same as reset to icache
    
    //from prefetch
    input   [31:0]  prefetch_address,
    input   [4:0]   prefetch_length,
    input           prefetch_su,
    
    //from prefetchfifo
    input   [4:0]   prefetchfifo_used,
    
    //REQ:
    output          tlbcoderequest_do,
    output  [31:0]  tlbcoderequest_address,
    output          tlbcoderequest_su,
    //END

    //RESP:
    input           tlbcode_do,
    input   [31:0]  tlbcode_linear,
    input   [31:0]  tlbcode_physical,
    input           tlbcode_cache_disable,
    //END
    
    //REQ:
    output          icacheread_do,
    output  [31:0]  icacheread_address,
    output  [4:0]   icacheread_length, // takes into account: page size and cs segment limit
    output          icacheread_cache_disable
    //END
);

//------------------------------------------------------------------------------

reg [1:0]  state;
reg [31:0] linear;
reg [31:0] physical;
reg        cache_disable;

//------------------------------------------------------------------------------

localparam [1:0] STATE_TLB_REQUEST = 2'd0;
localparam [1:0] STATE_ICACHE      = 2'd1;

//------------------------------------------------------------------------------

wire [12:0] left_in_page;
wire [4:0]  length;

wire        offset_update;
wire        page_cross;

//------------------------------------------------------------------------------

assign tlbcoderequest_address = prefetch_address;
assign tlbcoderequest_su      = prefetch_su;

assign left_in_page = 13'd4096 - { 1'b0, prefetch_address[11:0] };
assign length       = (left_in_page < { 8'd0, prefetch_length })?  left_in_page[4:0] : prefetch_length;

assign offset_update = prefetch_address[31:12] == linear[31:12] && prefetch_address[11:0] != linear[11:0];
assign page_cross    = prefetch_address[31:12] != linear[31:12];

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

/*******************************************************************************SCRIPT

IF(state == STATE_TLB_REQUEST);

    IF(~(pr_reset) && prefetch_length > 5'd0 && prefetchfifo_used < 5'd3);

        SET(tlbcoderequest_do);
    
        IF(tlbcode_do);
        
            SAVE(linear,        tlbcode_linear);
            SAVE(physical,      tlbcode_physical);
            SAVE(cache_disable, tlbcode_cache_disable);
        
            SET(icacheread_do);
            SET(icacheread_address,       tlbcode_physical);
            SET(icacheread_length,        length);
            SET(icacheread_cache_disable, tlbcode_cache_disable);
        
            SAVE(state, STATE_ICACHE);
        ENDIF();
    ENDIF();
ENDIF();

*/

/*******************************************************************************SCRIPT

IF(state == STATE_ICACHE);

    IF(page_cross || pr_reset || prefetchfifo_used >= 5'd8);
        SAVE(state, STATE_TLB_REQUEST);
    ELSE();
        SET(icacheread_do);
    ENDIF();

    SET(icacheread_address,       (offset_update)? { physical[31:12], prefetch_address[11:0] } : physical);
    SET(icacheread_length,        length);
    SET(icacheread_cache_disable, cache_disable);
    
    IF(offset_update);
        SAVE(linear,   { linear[31:12],   prefetch_address[11:0] });
        SAVE(physical, { physical[31:12], prefetch_address[11:0] });
    ENDIF();
ENDIF();
*/


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

`include "autogen/prefetch_control.v"

endmodule
