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

//TYPE: done delayed one cycle
//TYPE: full save

module link_dcachewrite(
    input               clk,
    input               rst_n,
    
    // dcachewrite REQ
    input               req_dcachewrite_do,
    output              req_dcachewrite_done,
    
    input   [2:0]       req_dcachewrite_length,
    input               req_dcachewrite_cache_disable,
    input   [31:0]      req_dcachewrite_address,
    input               req_dcachewrite_write_through,
    input   [31:0]      req_dcachewrite_data,
    
    // dcachewrite RESP
    output              resp_dcachewrite_do,
    input               resp_dcachewrite_done,
    
    output  [2:0]       resp_dcachewrite_length,
    output              resp_dcachewrite_cache_disable,
    output  [31:0]      resp_dcachewrite_address,
    output              resp_dcachewrite_write_through,
    output  [31:0]      resp_dcachewrite_data
);

//------------------------------------------------------------------------------

reg         current_do;
reg [2:0]   length;
reg         cache_disable;
reg [31:0]  address;
reg         write_through;
reg [31:0]  data;

reg         done_delayed;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_dcachewrite_do && ~(resp_dcachewrite_done) && ~(req_dcachewrite_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_dcachewrite_do;
    else if(resp_dcachewrite_done)  current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) length        <= 3'd0;  else if(save) length        <= req_dcachewrite_length;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cache_disable <= 1'b0;  else if(save) cache_disable <= req_dcachewrite_cache_disable; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address       <= 32'd0; else if(save) address       <= req_dcachewrite_address;       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) write_through <= 1'b0;  else if(save) write_through <= req_dcachewrite_write_through; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) data          <= 32'd0; else if(save) data          <= req_dcachewrite_data;          end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               done_delayed <= `FALSE;
    else                            done_delayed <= resp_dcachewrite_done;
end

//------------------------------------------------------------------------------

assign req_dcachewrite_done = done_delayed;

assign resp_dcachewrite_do            = (req_dcachewrite_do)? req_dcachewrite_do            : current_do;
assign resp_dcachewrite_length        = (req_dcachewrite_do)? req_dcachewrite_length        : length;
assign resp_dcachewrite_cache_disable = (req_dcachewrite_do)? req_dcachewrite_cache_disable : cache_disable;
assign resp_dcachewrite_address       = (req_dcachewrite_do)? req_dcachewrite_address       : address;
assign resp_dcachewrite_write_through = (req_dcachewrite_do)? req_dcachewrite_write_through : write_through;
assign resp_dcachewrite_data          = (req_dcachewrite_do)? req_dcachewrite_data          : data;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
