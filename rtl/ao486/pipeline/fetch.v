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

module fetch(
    input               clk,
    input               rst_n,
    
    input               pr_reset,
    
    // get prefetch_eip
    input       [31:0]  wr_eip,
    
    output      [31:0]  prefetch_eip,
    
    // prefetch_fifo
    output              prefetchfifo_accept_do,
    input       [67:0]  prefetchfifo_accept_data,
    input               prefetchfifo_accept_empty,
    
    // fetch interface to decode
    output      [3:0]   fetch_valid,
    output      [63:0]  fetch,
    output              fetch_limit,
    output              fetch_page_fault,
    
    // feedback from decode
    input       [3:0]   dec_acceptable
);

//------------------------------------------------------------------------------

wire partial;

//------------------------------------------------------------------------------

assign prefetch_eip = wr_eip;

//------------------------------------------------------------------------------

assign fetch_valid      = (prefetchfifo_accept_empty || prefetchfifo_accept_data[67:64] >= `PREFETCH_MIN_FAULT)? 4'd0 : prefetchfifo_accept_data[67:64] - fetch_count;

assign fetch_limit      = prefetchfifo_accept_empty == `FALSE && prefetchfifo_accept_data[67:64] == `PREFETCH_GP_FAULT;
assign fetch_page_fault = prefetchfifo_accept_empty == `FALSE && prefetchfifo_accept_data[67:64] == `PREFETCH_PF_FAULT;

assign fetch =
    (prefetchfifo_accept_empty)?      64'd0 :
    (fetch_count == 4'd0)?                   prefetchfifo_accept_data[63:0] :
    (fetch_count == 4'd1)?          {  8'd0, prefetchfifo_accept_data[63:8] } :
    (fetch_count == 4'd2)?          { 16'd0, prefetchfifo_accept_data[63:16] } :
    (fetch_count == 4'd3)?          { 24'd0, prefetchfifo_accept_data[63:24] } :
    (fetch_count == 4'd4)?          { 32'd0, prefetchfifo_accept_data[63:32] } :
    (fetch_count == 4'd5)?          { 40'd0, prefetchfifo_accept_data[63:40] } :
    (fetch_count == 4'd6)?          { 48'd0, prefetchfifo_accept_data[63:48] } :
                                    { 56'd0, prefetchfifo_accept_data[63:56] };

//------------------------------------------------------------------------------

assign prefetchfifo_accept_do   = dec_acceptable >= fetch_valid && prefetchfifo_accept_empty == `FALSE && prefetchfifo_accept_data[67:64] < `PREFETCH_MIN_FAULT;

assign partial                  = dec_acceptable <  fetch_valid && prefetchfifo_accept_empty == `FALSE && prefetchfifo_accept_data[67:64] < `PREFETCH_MIN_FAULT;

//------------------------------------------------------------------------------

reg [3:0] fetch_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               fetch_count <= 4'd0;
    else if(pr_reset)               fetch_count <= 4'd0;
    else if(prefetchfifo_accept_do) fetch_count <= 4'd0;
    else if(partial)                fetch_count <= fetch_count + dec_acceptable;
end

//------------------------------------------------------------------------------
                                        
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
