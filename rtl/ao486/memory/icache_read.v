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

module icache_read(
    
    input [127:0]           line,
    input [31:0]            read_data,
    input [2:0]             read_length,
    
    input [31:0]            address,
    input [4:0]             length,
    
    output [11:0]           length_burst,
    output [11:0]           length_line,
    output [135:0]          prefetch_line,
    output [135:0]          prefetch_partial
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

assign length_burst =
    (address[1:0] == 2'd0)?    { 3'd4, 3'd4, 3'd4, 3'd4 } :
    (address[1:0] == 2'd1)?    { 3'd4, 3'd4, 3'd4, 3'd3 } :
    (address[1:0] == 2'd2)?    { 3'd4, 3'd4, 3'd4, 3'd2 } :
                               { 3'd4, 3'd4, 3'd4, 3'd1 };
assign length_line =
    (address[3:0] == 4'd0)?    { 3'd4, 3'd4, 3'd4, 3'd4 } :
    (address[3:0] == 4'd1)?    { 3'd4, 3'd4, 3'd4, 3'd3 } :
    (address[3:0] == 4'd2)?    { 3'd4, 3'd4, 3'd4, 3'd2 } :
    (address[3:0] == 4'd3)?    { 3'd4, 3'd4, 3'd4, 3'd1 } :
    (address[3:0] == 4'd4)?    { 3'd4, 3'd4, 3'd4, 3'd0 } :
    (address[3:0] == 4'd5)?    { 3'd4, 3'd4, 3'd3, 3'd0 } :
    (address[3:0] == 4'd6)?    { 3'd4, 3'd4, 3'd2, 3'd0 } :
    (address[3:0] == 4'd7)?    { 3'd4, 3'd4, 3'd1, 3'd0 } :
    (address[3:0] == 4'd8)?    { 3'd4, 3'd4, 3'd0, 3'd0 } :
    (address[3:0] == 4'd9)?    { 3'd4, 3'd3, 3'd0, 3'd0 } :
    (address[3:0] == 4'd10)?   { 3'd4, 3'd2, 3'd0, 3'd0 } :
    (address[3:0] == 4'd11)?   { 3'd4, 3'd1, 3'd0, 3'd0 } :
    (address[3:0] == 4'd12)?   { 3'd4, 3'd0, 3'd0, 3'd0 } :
    (address[3:0] == 4'd13)?   { 3'd3, 3'd0, 3'd0, 3'd0 } :
    (address[3:0] == 4'd14)?   { 3'd2, 3'd0, 3'd0, 3'd0 } :
                               { 3'd1, 3'd0, 3'd0, 3'd0 };

assign prefetch_line =
    (address[3:0] == 4'd15)? { 4'd0,                                                                   64'd0,                4'd1,                                56'd0, line[127:120] } :
    (address[3:0] == 4'd14)? { 4'd0,                                                                   64'd0,                (length > 5'd2)? 4'd2 : length[3:0], 48'd0, line[127:112] } :
    (address[3:0] == 4'd13)? { 4'd0,                                                                   64'd0,                (length > 5'd3)? 4'd3 : length[3:0], 40'd0, line[127:104] } :
    (address[3:0] == 4'd12)? { 4'd0,                                                                   64'd0,                (length > 5'd4)? 4'd4 : length[3:0], 32'd0, line[127:96] } :
    (address[3:0] == 4'd11)? { 4'd0,                                                                   64'd0,                (length > 5'd5)? 4'd5 : length[3:0], 24'd0, line[127:88] } :
    (address[3:0] == 4'd10)? { 4'd0,                                                                   64'd0,                (length > 5'd6)? 4'd6 : length[3:0], 16'd0, line[127:80] } :
    (address[3:0] == 4'd9)?  { 4'd0,                                                                   64'd0,                (length > 5'd7)? 4'd7 : length[3:0], 8'd0,  line[127:72] } :
    (address[3:0] == 4'd8)?  { 4'd0,                                                                   64'd0,                (length > 5'd8)? 4'd8 : length[3:0],        line[127:64] } :
    (address[3:0] == 4'd7)?  { (length > 5'd8)?  4'd1 : 4'd0,                                          56'd0, line[127:120], (length > 5'd8)? 4'd8 : length[3:0],        line[119:56] } :
    (address[3:0] == 4'd6)?  { (length > 5'd9)?  4'd2 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 48'd0, line[127:112], (length > 5'd8)? 4'd8 : length[3:0],        line[111:48] } :
    (address[3:0] == 4'd5)?  { (length > 5'd10)? 4'd3 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 40'd0, line[127:104], (length > 5'd8)? 4'd8 : length[3:0],        line[103:40] } :
    (address[3:0] == 4'd4)?  { (length > 5'd11)? 4'd4 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 32'd0, line[127:96],  (length > 5'd8)? 4'd8 : length[3:0],        line[95:32] } :
    (address[3:0] == 4'd3)?  { (length > 5'd12)? 4'd5 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 24'd0, line[127:88],  (length > 5'd8)? 4'd8 : length[3:0],        line[87:24] } :
    (address[3:0] == 4'd2)?  { (length > 5'd13)? 4'd6 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 16'd0, line[127:80],  (length > 5'd8)? 4'd8 : length[3:0],        line[79:16] } :
    (address[3:0] == 4'd1)?  { (length > 5'd14)? 4'd7 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0, 8'd0,  line[127:72],  (length > 5'd8)? 4'd8 : length[3:0],        line[71:8] } :
                             { (length > 5'd15)? 4'd8 : (length > 5'd8)? { 1'b0, length[2:0] } : 4'd0,        line[127:64],  (length > 5'd8)? 4'd8 : length[3:0],        line[63:0] };
                               
assign prefetch_partial =
    (read_length[2:0] == 3'd1)?   { 4'd0, 64'd0, 4'd1,                                56'd0, read_data[31:24] } :
    (read_length[2:0] == 3'd2)?   { 4'd0, 64'd0, (length > 5'd2)? 4'd2 : length[3:0], 48'd0, read_data[31:16] } :
    (read_length[2:0] == 3'd3)?   { 4'd0, 64'd0, (length > 5'd3)? 4'd3 : length[3:0], 40'd0, read_data[31:8] } :
                                  { 4'd0, 64'd0, (length > 5'd4)? 4'd4 : length[3:0], 32'd0, read_data[31:0] };

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address[31:4], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------
    
endmodule
