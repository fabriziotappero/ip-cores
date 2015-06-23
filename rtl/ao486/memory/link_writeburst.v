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

module link_writeburst(
    input               clk,
    input               rst_n,
    
    // writeburst REQ
    input               req_writeburst_do,
    output              req_writeburst_done,
    
    input       [31:0]  req_writeburst_address,
    input       [1:0]   req_writeburst_dword_length,
    input       [3:0]   req_writeburst_byteenable_0,
    input       [3:0]   req_writeburst_byteenable_1,
    input       [55:0]  req_writeburst_data,
    
    // writeburst RESP
    output              resp_writeburst_do,
    input               resp_writeburst_done,
    
    output      [31:0]  resp_writeburst_address,
    output      [1:0]   resp_writeburst_dword_length,
    output      [3:0]   resp_writeburst_byteenable_0,
    output      [3:0]   resp_writeburst_byteenable_1,
    output      [55:0]  resp_writeburst_data
);

//------------------------------------------------------------------------------

reg         current_do;
reg [31:0]  address;
reg [1:0]   dword_length;
reg [3:0]   byteenable_0;
reg [3:0]   byteenable_1;
reg [55:0]  data;

reg         done_delayed;

//------------------------------------------------------------------------------

wire save;

//------------------------------------------------------------------------------

assign save  = req_writeburst_do && ~(resp_writeburst_done) && ~(req_writeburst_done);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               current_do <= `FALSE;
    else if(save)                   current_do <= req_writeburst_do;
    else if(resp_writeburst_done)   current_do <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address      <= 32'd0; else if(save) address      <= req_writeburst_address;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dword_length <= 2'd0;  else if(save) dword_length <= req_writeburst_dword_length; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) byteenable_0 <= 4'd0;  else if(save) byteenable_0 <= req_writeburst_byteenable_0; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) byteenable_1 <= 4'd0;  else if(save) byteenable_1 <= req_writeburst_byteenable_1; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) data         <= 56'd0; else if(save) data         <= req_writeburst_data;         end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               done_delayed <= `FALSE;
    else                            done_delayed <= resp_writeburst_done;
end


//------------------------------------------------------------------------------

assign req_writeburst_done = done_delayed;

assign resp_writeburst_do           = (req_writeburst_do)? req_writeburst_do           : current_do;
assign resp_writeburst_address      = (req_writeburst_do)? req_writeburst_address      : address;
assign resp_writeburst_dword_length = (req_writeburst_do)? req_writeburst_dword_length : dword_length;
assign resp_writeburst_byteenable_0 = (req_writeburst_do)? req_writeburst_byteenable_0 : byteenable_0;
assign resp_writeburst_byteenable_1 = (req_writeburst_do)? req_writeburst_byteenable_1 : byteenable_1;
assign resp_writeburst_data         = (req_writeburst_do)? req_writeburst_data         : data;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
