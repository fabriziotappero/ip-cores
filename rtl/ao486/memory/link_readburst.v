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

module link_readburst(
    input               clk,
    input               rst_n,
    
    // readburst REQ
    input               req_readburst_do,
    output              req_readburst_done,
    
    input       [31:0]  req_readburst_address,
    input       [1:0]   req_readburst_dword_length,
    input       [3:0]   req_readburst_byte_length,
    output      [95:0]  req_readburst_data,
    
    // readburst RESP
    output              resp_readburst_do,
    input               resp_readburst_done,
    
    output      [31:0]  resp_readburst_address,
    output      [1:0]   resp_readburst_dword_length,
    output      [3:0]   resp_readburst_byte_length,
    input       [95:0]  resp_readburst_data
);

//------------------------------------------------------------------------------

reg         current_do;
reg [31:0]  address;
reg [1:0]   dword_length;
reg [3:0]   byte_length;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_readburst_do && ~(resp_readburst_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_readburst_do;
    else if(resp_readburst_done)    current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address      <= 32'd0; else if(save) address      <= req_readburst_address;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dword_length <= 2'd0;  else if(save) dword_length <= req_readburst_dword_length; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) byte_length  <= 4'd0;  else if(save) byte_length  <= req_readburst_byte_length;  end

//------------------------------------------------------------------------------

assign req_readburst_done = resp_readburst_done;
assign req_readburst_data = resp_readburst_data;

assign resp_readburst_do           = (req_readburst_do)? req_readburst_do           : current_do;
assign resp_readburst_address      = (req_readburst_do)? req_readburst_address      : address;
assign resp_readburst_dword_length = (req_readburst_do)? req_readburst_dword_length : dword_length;
assign resp_readburst_byte_length  = (req_readburst_do)? req_readburst_byte_length  : byte_length;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
