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

module read_debug(
    input               clk,
    input               rst_n,
    
    input       [31:0]  dr0,
    input       [31:0]  dr1,
    input       [31:0]  dr2,
    input       [31:0]  dr3,
    input       [31:0]  dr7,
    
    input       [2:0]   debug_len0,
    input       [2:0]   debug_len1,
    input       [2:0]   debug_len2,
    input       [2:0]   debug_len3,
    
    input               rd_ready,
    
    input               read_do,
    input       [31:0]  read_address,
    input       [3:0]   read_length,
    
    output      [3:0]   rd_debug_read 
);


//------------------------------------------------------------------------------

wire        rd_debug_trigger;
wire [31:0] rd_debug_linear;
wire [3:0]  rd_debug_length;

wire [31:0] rd_debug_linear_last;

wire        rd_debug_b0_trigger;
wire        rd_debug_b1_trigger;
wire        rd_debug_b2_trigger;
wire        rd_debug_b3_trigger;

//------------------------------------------------------------------------------

reg rd_debug_b0_reg;
reg rd_debug_b1_reg;
reg rd_debug_b2_reg;
reg rd_debug_b3_reg;

//------------------------------------------------------------------------------

assign rd_debug_trigger = read_do; //can be many cycles
assign rd_debug_linear  = read_address;
assign rd_debug_length  = read_length;

assign rd_debug_linear_last = rd_debug_linear + { 28'd0, rd_debug_length } - 32'd1;

assign rd_debug_read = {
    rd_debug_b3_trigger | rd_debug_b3_reg, rd_debug_b2_trigger | rd_debug_b2_reg,
    rd_debug_b1_trigger | rd_debug_b1_reg, rd_debug_b0_trigger | rd_debug_b0_reg };

//------------------------------------------------------------------------------ breakpoint 0
assign rd_debug_b0_trigger =
    rd_debug_trigger && dr7[17:16] == 2'b11 && // RW bits = read or write
    ( rd_debug_linear      <= { dr0[31:3], dr0[2:0] | ~(debug_len0)} ) &&
    ( rd_debug_linear_last >= { dr0[31:3], dr0[2:0] &   debug_len0 } );
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rd_debug_b0_reg <= `FALSE;
    else if(rd_ready)               rd_debug_b0_reg <= `FALSE;
    else if(rd_debug_b0_trigger)    rd_debug_b0_reg <= `TRUE;
end

//------------------------------------------------------------------------------ breakpoint 1
assign rd_debug_b1_trigger =
    rd_debug_trigger && dr7[21:20] == 2'b11 && // RW bits = read or write
    ( rd_debug_linear      <= { dr1[31:3], dr1[2:0] | ~(debug_len1)} ) &&
    ( rd_debug_linear_last >= { dr1[31:3], dr1[2:0] &   debug_len1 } );

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rd_debug_b1_reg <= `FALSE;
    else if(rd_ready)               rd_debug_b1_reg <= `FALSE;
    else if(rd_debug_b1_trigger)    rd_debug_b1_reg <= `TRUE;
end

//------------------------------------------------------------------------------ breakpoint 2
assign rd_debug_b2_trigger =
    rd_debug_trigger && dr7[25:24] == 2'b11 && // RW bits = read or write
    ( rd_debug_linear      <= { dr2[31:3], dr2[2:0] | ~(debug_len2)} ) &&
    ( rd_debug_linear_last >= { dr2[31:3], dr2[2:0] &   debug_len2 } );

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rd_debug_b2_reg <= `FALSE;
    else if(rd_ready)               rd_debug_b2_reg <= `FALSE;
    else if(rd_debug_b2_trigger)    rd_debug_b2_reg <= `TRUE;
end

//------------------------------------------------------------------------------ breakpoint 3
assign rd_debug_b3_trigger =
    rd_debug_trigger && dr7[29:28] == 2'b11 && // RW bits = read or write
    ( rd_debug_linear      <= { dr3[31:3], dr3[2:0] | ~(debug_len3)} ) &&
    ( rd_debug_linear_last >= { dr3[31:3], dr3[2:0] &   debug_len3 } );

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rd_debug_b3_reg <= `FALSE;
    else if(rd_ready)               rd_debug_b3_reg <= `FALSE;
    else if(rd_debug_b3_trigger)    rd_debug_b3_reg <= `TRUE;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, dr7[31:30], dr7[27:26], dr7[23:22], dr7[19:18], dr7[15:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
