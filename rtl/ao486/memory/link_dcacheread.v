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

//TYPE: full save

module link_dcacheread(
    input               clk,
    input               rst_n,
    
    // dcacheread REQ
    input               req_dcacheread_do,
    output              req_dcacheread_done,
    
    input   [3:0]       req_dcacheread_length,
    input               req_dcacheread_cache_disable,
    input   [31:0]      req_dcacheread_address,
    output  [63:0]      req_dcacheread_data,
    
    // dcacheread RESP
    output              resp_dcacheread_do,
    input               resp_dcacheread_done,
    
    output  [3:0]       resp_dcacheread_length,
    output              resp_dcacheread_cache_disable,
    output  [31:0]      resp_dcacheread_address,
    input   [63:0]      resp_dcacheread_data
);

//------------------------------------------------------------------------------

reg         current_do;
reg [3:0]   length;
reg         cache_disable;
reg [31:0]  address;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_dcacheread_do && ~(resp_dcacheread_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_dcacheread_do;
    else if(resp_dcacheread_done)   current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) length        <= 4'd0;  else if(save) length        <= req_dcacheread_length;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) cache_disable <= 1'b0;  else if(save) cache_disable <= req_dcacheread_cache_disable; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address       <= 32'd0; else if(save) address       <= req_dcacheread_address;       end

//------------------------------------------------------------------------------

assign req_dcacheread_done = resp_dcacheread_done;
assign req_dcacheread_data = resp_dcacheread_data;

assign resp_dcacheread_do            = (req_dcacheread_do)? req_dcacheread_do            : current_do;
assign resp_dcacheread_length        = (req_dcacheread_do)? req_dcacheread_length        : length;
assign resp_dcacheread_cache_disable = (req_dcacheread_do)? req_dcacheread_cache_disable : cache_disable;
assign resp_dcacheread_address       = (req_dcacheread_do)? req_dcacheread_address       : address;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
