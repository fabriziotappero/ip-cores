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

module dcache_write(
    
    input [127:0]           line,
    input [31:0]            address,
    input [2:0]             length,
    input [31:0]            write_data,
    
    output [1:0]            write_burst_dword_length,
    output [3:0]            write_burst_byteenable_0,
    output [3:0]            write_burst_byteenable_1,
    output [55:0]           write_burst_data,
    output [127:0]          line_merged
);

//------------------------------------------------------------------------------

assign write_burst_dword_length =
    (length == 3'd2 && address[1:0] == 2'b11)?  2'd2 :
    (length == 3'd3 && address[1]   == 1'b1)?   2'd2 :
    (length == 3'd4 && address[1:0] != 2'b00)?  2'd2 :
                                                2'd1;
                                                
assign write_burst_byteenable_0 =
    (address[1:0] == 2'd0 && length == 3'd1)?   4'b0001 :
    (address[1:0] == 2'd1 && length == 3'd1)?   4'b0010 :
    (address[1:0] == 2'd2 && length == 3'd1)?   4'b0100 :
    (address[1:0] == 2'd0 && length == 3'd2)?   4'b0011 :
    (address[1:0] == 2'd1 && length == 3'd2)?   4'b0110 :
    (address[1:0] == 2'd0 && length == 3'd3)?   4'b0111 :
    (address[1:0] == 2'd1 && length >= 3'd3)?   4'b1110 :
    (address[1:0] == 2'd2 && length >= 3'd2)?   4'b1100 :
    (address[1:0] == 2'd0 && length == 3'd4)?   4'b1111 :
                                                4'b1000; //(address[1:0] == 2'd3)?

assign write_burst_byteenable_1 =
   (address[1:0] == 2'd3 && length == 3'd2)?   4'b0001 :
   (address[1:0] == 2'd2 && length == 3'd3)?   4'b0001 :
   (address[1:0] == 2'd3 && length == 3'd3)?   4'b0011 :
   (address[1:0] == 2'd1 && length == 3'd4)?   4'b0001 :
   (address[1:0] == 2'd2 && length == 3'd4)?   4'b0011 :
                                               4'b0111; //(address[1:0] == 2'd3 && length == 3'd4)? 
                                               
assign write_burst_data =
    (address[1:0] == 2'd0)?   { 24'd0, write_data[31:0] } :
    (address[1:0] == 2'd1)?   { 16'd0, write_data[31:0], 8'd0 } :
    (address[1:0] == 2'd2)?   { 8'd0,  write_data[31:0], 16'd0 } :
                              {        write_data[31:0], 24'd0 };
                          
assign line_merged =
    (address[3:0] == 4'd0  && length == 3'd1)? { line[127:8],   write_data[7:0] } :
    (address[3:0] == 4'd1  && length == 3'd1)? { line[127:16],  write_data[7:0], line[7:0] } :
    (address[3:0] == 4'd2  && length == 3'd1)? { line[127:24],  write_data[7:0], line[15:0] } :
    (address[3:0] == 4'd3  && length == 3'd1)? { line[127:32],  write_data[7:0], line[23:0] } :
    (address[3:0] == 4'd4  && length == 3'd1)? { line[127:40],  write_data[7:0], line[31:0] } :
    (address[3:0] == 4'd5  && length == 3'd1)? { line[127:48],  write_data[7:0], line[39:0] } :
    (address[3:0] == 4'd6  && length == 3'd1)? { line[127:56],  write_data[7:0], line[47:0] } :
    (address[3:0] == 4'd7  && length == 3'd1)? { line[127:64],  write_data[7:0], line[55:0] } :
    (address[3:0] == 4'd8  && length == 3'd1)? { line[127:72],  write_data[7:0], line[63:0] } :
    (address[3:0] == 4'd9  && length == 3'd1)? { line[127:80],  write_data[7:0], line[71:0] } :
    (address[3:0] == 4'd10 && length == 3'd1)? { line[127:88],  write_data[7:0], line[79:0] } :
    (address[3:0] == 4'd11 && length == 3'd1)? { line[127:96],  write_data[7:0], line[87:0] } :
    (address[3:0] == 4'd12 && length == 3'd1)? { line[127:104], write_data[7:0], line[95:0] } :
    (address[3:0] == 4'd13 && length == 3'd1)? { line[127:112], write_data[7:0], line[103:0] } :
    (address[3:0] == 4'd14 && length == 3'd1)? { line[127:120], write_data[7:0], line[111:0] } :
    (address[3:0] == 4'd15 && length == 3'd1)? {                write_data[7:0], line[119:0] } :
    
    (address[3:0] == 4'd0   && length == 3'd2)? { line[127:16],  write_data[15:0] } :
    (address[3:0] == 4'd1   && length == 3'd2)? { line[127:24],  write_data[15:0], line[7:0] } :
    (address[3:0] == 4'd2   && length == 3'd2)? { line[127:32],  write_data[15:0], line[15:0] } :
    (address[3:0] == 4'd3   && length == 3'd2)? { line[127:40],  write_data[15:0], line[23:0] } :
    (address[3:0] == 4'd4   && length == 3'd2)? { line[127:48],  write_data[15:0], line[31:0] } :
    (address[3:0] == 4'd5   && length == 3'd2)? { line[127:56],  write_data[15:0], line[39:0] } :
    (address[3:0] == 4'd6   && length == 3'd2)? { line[127:64],  write_data[15:0], line[47:0] } :
    (address[3:0] == 4'd7   && length == 3'd2)? { line[127:72],  write_data[15:0], line[55:0] } :
    (address[3:0] == 4'd8   && length == 3'd2)? { line[127:80],  write_data[15:0], line[63:0] } :
    (address[3:0] == 4'd9   && length == 3'd2)? { line[127:88],  write_data[15:0], line[71:0] } :
    (address[3:0] == 4'd10  && length == 3'd2)? { line[127:96],  write_data[15:0], line[79:0] } :
    (address[3:0] == 4'd11  && length == 3'd2)? { line[127:104], write_data[15:0], line[87:0] } :
    (address[3:0] == 4'd12  && length == 3'd2)? { line[127:112], write_data[15:0], line[95:0] } :
    (address[3:0] == 4'd13  && length == 3'd2)? { line[127:120], write_data[15:0], line[103:0] } :
    (address[3:0] == 4'd14  && length == 3'd2)? {                write_data[15:0], line[111:0] } :
    
    (address[3:0] == 4'd0   && length == 3'd3)? { line[127:24],  write_data[23:0] } :
    (address[3:0] == 4'd1   && length == 3'd3)? { line[127:32],  write_data[23:0], line[7:0] } :
    (address[3:0] == 4'd2   && length == 3'd3)? { line[127:40],  write_data[23:0], line[15:0] } :
    (address[3:0] == 4'd3   && length == 3'd3)? { line[127:48],  write_data[23:0], line[23:0] } :
    (address[3:0] == 4'd4   && length == 3'd3)? { line[127:56],  write_data[23:0], line[31:0] } :
    (address[3:0] == 4'd5   && length == 3'd3)? { line[127:64],  write_data[23:0], line[39:0] } :
    (address[3:0] == 4'd6   && length == 3'd3)? { line[127:72],  write_data[23:0], line[47:0] } :
    (address[3:0] == 4'd7   && length == 3'd3)? { line[127:80],  write_data[23:0], line[55:0] } :
    (address[3:0] == 4'd8   && length == 3'd3)? { line[127:88],  write_data[23:0], line[63:0] } :
    (address[3:0] == 4'd9   && length == 3'd3)? { line[127:96],  write_data[23:0], line[71:0] } :
    (address[3:0] == 4'd10  && length == 3'd3)? { line[127:104], write_data[23:0], line[79:0] } :
    (address[3:0] == 4'd11  && length == 3'd3)? { line[127:112], write_data[23:0], line[87:0] } :
    (address[3:0] == 4'd12  && length == 3'd3)? { line[127:120], write_data[23:0], line[95:0] } :
    (address[3:0] == 4'd13  && length == 3'd3)? {                write_data[23:0], line[103:0] } :
    (address[3:0] == 4'd0   && length == 3'd4)? { line[127:32],  write_data[31:0] } :
    (address[3:0] == 4'd1   && length == 3'd4)? { line[127:40],  write_data[31:0], line[7:0] } :
    (address[3:0] == 4'd2   && length == 3'd4)? { line[127:48],  write_data[31:0], line[15:0] } :
    (address[3:0] == 4'd3   && length == 3'd4)? { line[127:56],  write_data[31:0], line[23:0] } :
    (address[3:0] == 4'd4   && length == 3'd4)? { line[127:64],  write_data[31:0], line[31:0] } :
    (address[3:0] == 4'd5   && length == 3'd4)? { line[127:72],  write_data[31:0], line[39:0] } :
    (address[3:0] == 4'd6   && length == 3'd4)? { line[127:80],  write_data[31:0], line[47:0] } :
    (address[3:0] == 4'd7   && length == 3'd4)? { line[127:88],  write_data[31:0], line[55:0] } :
    (address[3:0] == 4'd8   && length == 3'd4)? { line[127:96],  write_data[31:0], line[63:0] } :
    (address[3:0] == 4'd9   && length == 3'd4)? { line[127:104], write_data[31:0], line[71:0] } :
    (address[3:0] == 4'd10  && length == 3'd4)? { line[127:112], write_data[31:0], line[79:0] } :
    (address[3:0] == 4'd11  && length == 3'd4)? { line[127:120], write_data[31:0], line[87:0] } :
                                                {                write_data[31:0], line[95:0] }; //(address[3:0] == 3'd12  && dlength == 3'd4)?  

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address[31:4], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------


endmodule
