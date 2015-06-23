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

module link_readline(
    input               clk,
    input               rst_n,
    
    // readline REQ
    input               req_readline_do,
    output              req_readline_done,
    
    input       [31:0]  req_readline_address,
    output      [127:0] req_readline_line,
    
    // readline RESP
    output              resp_readline_do,
    input               resp_readline_done,
    
    output      [31:0]  resp_readline_address,
    input       [127:0] resp_readline_line
);

//------------------------------------------------------------------------------

reg         current_do;
reg [31:0]  address;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_readline_do && ~(resp_readline_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_readline_do;
    else if(resp_readline_done)     current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address <= 32'd0; else if(save) address <= req_readline_address;      end

//------------------------------------------------------------------------------

assign req_readline_done = resp_readline_done;
assign req_readline_line = resp_readline_line;

assign resp_readline_do      = (req_readline_do)? req_readline_do      : current_do;
assign resp_readline_address = (req_readline_do)? req_readline_address : address;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
