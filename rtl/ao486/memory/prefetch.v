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

module prefetch(
    input               clk,
    input               rst_n,
    
    input               pr_reset,
    
    input       [1:0]   prefetch_cpl,
    input       [31:0]  prefetch_eip,
    input       [63:0]  cs_cache,
    
    //to tlb
    output      [31:0]  prefetch_address,
    output      [4:0]   prefetch_length,
    output              prefetch_su,
    
    //RESP:
    input               prefetched_do,
    input       [4:0]   prefetched_length,
    //END
    
    output              prefetchfifo_signal_limit_do
);

//------------------------------------------------------------------------------

reg [31:0] linear;
reg [31:0] limit;
reg        limit_signaled;

//------------------------------------------------------------------------------

wire [4:0] length;

wire [31:0] cs_base;
wire [31:0] cs_limit;

assign cs_base     = { cs_cache[63:56], cs_cache[39:16] };
assign cs_limit    = cs_cache[`DESC_BIT_G]? { cs_cache[51:48], cs_cache[15:0], 12'hFFF } : { 12'd0, cs_cache[51:48], cs_cache[15:0] };

//------------------------------------------------------------------------------
assign prefetch_su = prefetch_cpl == 2'd3; //0=supervisor; 1=user

assign prefetch_address = linear;

assign prefetch_length = (limit > 32'd16)? 5'd16 : limit[4:0];

assign length = (limit < {  27'd0, prefetched_length })? limit[4:0] : prefetched_length;

assign prefetchfifo_signal_limit_do = limit == 32'd0 && limit_signaled == `FALSE;

//------------------------------------------------------------------------------
   
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       limit <= `STARTUP_PREFETCH_LIMIT;
    else if(pr_reset)       limit <= (cs_limit >= prefetch_eip)? cs_limit - prefetch_eip + 32'd1 : 32'd0;
    else if(prefetched_do)  limit <= limit - { 27'd0, length };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       linear <= `STARTUP_PREFETCH_LINEAR;
    else if(pr_reset)       linear <= cs_base + prefetch_eip;
    else if(prefetched_do)  linear <= linear + { 27'd0, length };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       limit_signaled <= `FALSE;
    else if(pr_reset)                       limit_signaled <= `FALSE;
    else if(prefetchfifo_signal_limit_do)   limit_signaled <= `TRUE;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, cs_cache[54:52], cs_cache[47:40], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
