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

module dcache_matched(
    input [31:0]    address,
    
    input [10:0]    control,
    input [147:0]   data_0,
    input [147:0]   data_1,
    input [147:0]   data_2,
    input [147:0]   data_3,
    
    output          matched,
    output [1:0]    matched_index,
    output [127:0]  matched_data_line,
    
    output [1:0]    plru_index,
    output [147:0]  plru_data_line,
    
    output [10:0]   control_after_match,
    output [10:0]   control_after_line_read,
    output [10:0]   control_after_write_to_existing,
    output [10:0]   control_after_write_to_new,
    
    output          writeback_needed
);

//------------------------------------------------------------------------------

wire [2:0] matched_full_index;

//------------------------------------------------------------------------------

assign matched_full_index =
    (control[0] && data_0[147:128] == address[31:12])?  3'd0 :
    (control[2] && data_1[147:128] == address[31:12])?  3'd1 :
    (control[4] && data_2[147:128] == address[31:12])?  3'd2 :
    (control[6] && data_3[147:128] == address[31:12])?  3'd3 :
                                                        3'd4;
assign matched_index = matched_full_index[1:0];         
                                               
assign matched = matched_full_index != 3'd4;

assign matched_data_line =
    (matched_full_index == 3'd0)? data_0[127:0] :
    (matched_full_index == 3'd1)? data_1[127:0] :
    (matched_full_index == 3'd2)? data_2[127:0] :
                                  data_3[127:0];

assign control_after_match =
    (matched_full_index == 3'd0)?    { control[10], 2'b11,     control[7:0] } :
    (matched_full_index == 3'd1)?    { control[10], 2'b01,     control[7:0] } :
    (matched_full_index == 3'd2)?    { 1'b1, control[9], 1'b0, control[7:0] } :
                                     { 1'b0, control[9], 1'b0, control[7:0] };
            
assign control_after_line_read =
    (~(control[0]))?        { control[10], 2'b11,     control[7:0] | 8'b00000001 } :
    (~(control[2]))?        { control[10], 2'b01,     control[7:0] | 8'b00000100 } :
    (~(control[4]))?        { 1'b1, control[9], 1'b0, control[7:0] | 8'b00010000 } :
    (~(control[6]))?        { 1'b0, control[9], 1'b0, control[7:0] | 8'b01000000 } :
    (plru_index == 2'd0)?   { control[10], 2'b11,     control[7:0] } :
    (plru_index == 2'd1)?   { control[10], 2'b01,     control[7:0] } :
    (plru_index == 2'd2)?   { 1'b1, control[9], 1'b0, control[7:0] } :
                            { 1'b0, control[9], 1'b0, control[7:0] }; //match dcache_ram_3_q[]

assign control_after_write_to_existing =
    (matched_full_index == 3'd0)?    { control[10], 2'b11,     control[7:0] | 8'b00000010 } :
    (matched_full_index == 3'd1)?    { control[10], 2'b01,     control[7:0] | 8'b00001000 } :
    (matched_full_index == 3'd2)?    { 1'b1, control[9], 1'b0, control[7:0] | 8'b00100000 } :
                                     { 1'b0, control[9], 1'b0, control[7:0] | 8'b10000000}; //match dcache_ram_3_q[]

assign control_after_write_to_new =
    (~(control[0]))?        { control[10], 2'b11,     control[7:0] | 8'b00000011 } :
    (~(control[2]))?        { control[10], 2'b01,     control[7:0] | 8'b00001100 } :
    (~(control[4]))?        { 1'b1, control[9], 1'b0, control[7:0] | 8'b00110000 } :
    (~(control[6]))?        { 1'b0, control[9], 1'b0, control[7:0] | 8'b11000000 } :
    (plru_index == 2'd0)?   { control[10], 2'b11,     control[7:0] | 8'b00000010 } :
    (plru_index == 2'd1)?   { control[10], 2'b01,     control[7:0] | 8'b00001000 } :
    (plru_index == 2'd2)?   { 1'b1, control[9], 1'b0, control[7:0] | 8'b00100000 } :
                            { 1'b0, control[9], 1'b0, control[7:0] | 8'b10000000 }; //match dcache_ram_3_q[]

assign plru_index =
    (~(control[0]))?                    2'd0 :
    (~(control[2]))?                    2'd1 :
    (~(control[4]))?                    2'd2 :
    (~(control[6]))?                    2'd3 :   
    (~(control[8]) && ~(control[9]))?   2'd0 :
    (~(control[8]) &&  (control[9]))?   2'd1 :
    ( (control[8]) && ~(control[10]))?  2'd2 :
                                        2'd3; // ( (control[8]) &&  (control[10]))?

assign plru_data_line =
    (plru_index == 2'd0)?   data_0 :
    (plru_index == 2'd1)?   data_1 :
    (plru_index == 2'd2)?   data_2 :
                            data_3;

assign writeback_needed =
    control[0] && control[2] && control[4] && control[6] &&
    ( (plru_index == 2'd0 && control[1]) || (plru_index == 2'd1 && control[3]) ||
      (plru_index == 2'd2 && control[5]) || (plru_index == 2'd3 && control[7]) );
                            
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address[11:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------
 
endmodule
