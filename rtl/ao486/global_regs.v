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

module global_regs(
    input               clk,
    input               rst_n,
    
    input               glob_param_1_set,
    input       [31:0]  glob_param_1_value,
    
    input               glob_param_2_set,
    input       [31:0]  glob_param_2_value,
    
    input               glob_param_3_set,
    input       [31:0]  glob_param_3_value,
    
    input               glob_param_4_set,
    input       [31:0]  glob_param_4_value,
    
    input               glob_param_5_set,
    input       [31:0]  glob_param_5_value,
    
    input               glob_descriptor_set,
    input       [63:0]  glob_descriptor_value,
    
    input               glob_descriptor_2_set,
    input       [63:0]  glob_descriptor_2_value,
    
    //output
    output reg  [31:0]  glob_param_1,
    output reg  [31:0]  glob_param_2,
    output reg  [31:0]  glob_param_3,
    output reg  [31:0]  glob_param_4,
    output reg  [31:0]  glob_param_5,

    output reg  [63:0]  glob_descriptor,
    output reg  [63:0]  glob_descriptor_2,
    
    output      [31:0]  glob_desc_base,
    output      [31:0]  glob_desc_limit,
    output      [31:0]  glob_desc_2_limit
);

//------------------------------------------------------------------------------

assign glob_desc_limit = glob_descriptor[`DESC_BIT_G]? { glob_descriptor[51:48], glob_descriptor[15:0], 12'hFFF } : { 12'd0, glob_descriptor[51:48], glob_descriptor[15:0] };
assign glob_desc_base  = { glob_descriptor[63:56], glob_descriptor[39:16] };

assign glob_desc_2_limit = glob_descriptor_2[`DESC_BIT_G]? { glob_descriptor_2[51:48], glob_descriptor_2[15:0], 12'hFFF } : { 12'd0, glob_descriptor_2[51:48], glob_descriptor_2[15:0] };


//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           glob_param_1 <= 32'd0;
    else if(glob_param_1_set)   glob_param_1 <= glob_param_1_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           glob_param_2 <= 32'd0;
    else if(glob_param_2_set)   glob_param_2 <= glob_param_2_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           glob_param_3 <= 32'd0;
    else if(glob_param_3_set)   glob_param_3 <= glob_param_3_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           glob_param_4 <= 32'd0;
    else if(glob_param_4_set)   glob_param_4 <= glob_param_4_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           glob_param_5 <= 32'd0;
    else if(glob_param_5_set)   glob_param_5 <= glob_param_5_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               glob_descriptor <= 64'd0;
    else if(glob_descriptor_set)    glob_descriptor <= glob_descriptor_value;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               glob_descriptor_2 <= 64'd0;
    else if(glob_descriptor_2_set)  glob_descriptor_2 <= glob_descriptor_2_value;
end

//------------------------------------------------------------------------------

endmodule
