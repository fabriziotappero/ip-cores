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

module link_readcode(
    input               clk,
    input               rst_n,
    
    // readcode REQ
    input               req_readcode_do,
    output              req_readcode_done,
    
    input       [31:0]  req_readcode_address,
    output      [127:0] req_readcode_line,
    output      [31:0]  req_readcode_partial,
    output              req_readcode_partial_done,
    
    // readcode RESP
    output              resp_readcode_do,
    input               resp_readcode_done,
    
    output      [31:0]  resp_readcode_address,
    input       [127:0] resp_readcode_line,
    input       [31:0]  resp_readcode_partial,
    input               resp_readcode_partial_done
);

//------------------------------------------------------------------------------

reg         current_do;
reg [31:0]  address;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_readcode_do && ~(resp_readcode_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_readcode_do;
    else if(resp_readcode_done)     current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address <= 32'd0; else if(save) address <= req_readcode_address; end

//------------------------------------------------------------------------------

assign req_readcode_done         = resp_readcode_done;
assign req_readcode_line         = resp_readcode_line;
assign req_readcode_partial      = resp_readcode_partial;
assign req_readcode_partial_done = resp_readcode_partial_done;

assign resp_readcode_do      = (req_readcode_do)? req_readcode_do      : current_do;
assign resp_readcode_address = (req_readcode_do)? req_readcode_address : address;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
