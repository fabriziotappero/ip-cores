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

module dcache_read(
    
    input [127:0]           line,
    input [95:0]            read_data,
    
    input [31:0]            address,
    input [3:0]             length,
    
    output [63:0]           read_from_line,
    output [1:0]            read_burst_dword_length,
    output [3:0]            read_burst_byte_length,
    output [63:0]           read_from_burst
);

//------------------------------------------------------------------------------

assign read_from_line =
    (address[3:0] == 4'd0)?              line[63:0] :
    (address[3:0] == 4'd1)?              line[71:8] :
    (address[3:0] == 4'd2)?              line[79:16] :
    (address[3:0] == 4'd3)?              line[87:24] :
    (address[3:0] == 4'd4)?              line[95:32] :
    (address[3:0] == 4'd5)?              line[103:40] :
    (address[3:0] == 4'd6)?              line[111:48] :
    (address[3:0] == 4'd7)?              line[119:56] :
    (address[3:0] == 4'd8)?              line[127:64] :
    (address[3:0] == 4'd9)?     { 8'd0,  line[127:72] } :
    (address[3:0] == 4'd10)?    { 16'd0, line[127:80] } :
    (address[3:0] == 4'd11)?    { 24'd0, line[127:88] } :
    (address[3:0] == 4'd12)?    { 32'd0, line[127:96] } :
    (address[3:0] == 4'd13)?    { 40'd0, line[127:104] } :
    (address[3:0] == 4'd14)?    { 48'd0, line[127:112] } :
                                { 56'd0, line[127:120] };

assign read_burst_dword_length =
    (length == 4'd2 && address[1:0] == 2'b11)?   2'd2 :
    (length == 4'd3 && address[1]   == 1'b1)?    2'd2 :
    (length == 4'd4 && address[1:0] != 2'b00)?   2'd2 :
    (length <= 4'd4)?                            2'd1 :
    (length == 4'd5)?                            2'd2 :
    (length == 4'd6 && address[1:0] == 2'b11)?   2'd3 :
    (length == 4'd7 && address[1]   == 1'b1)?    2'd3 :
    (length == 4'd8 && address[1:0] != 2'b00)?   2'd3 :
                                                 2'd2;

assign read_burst_byte_length = length;

assign read_from_burst =
    (address[1:0] == 2'd0)?     read_data[63:0] :
    (address[1:0] == 2'd1)?     read_data[71:8] :
    (address[1:0] == 2'd2)?     read_data[79:16] :
                                read_data[87:24];

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, read_data[95:88], address[31:4], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
