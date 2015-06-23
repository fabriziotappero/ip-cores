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

module cache_data_ram(
    input               clk,
    input               rst_n,
    
    input [31:0]        address,
    
    //RESP:
    input               read_do,
    output [147:0]      q,
    //END
    
    //RESP:
    input               write_do,
    input  [127:0]      data
    //END
);

//------------------------------------------------------------------------------

reg [7:0] last_address;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   last_address <= 8'd0;
    else if(read_do)    last_address <= address[11:4];
end

//------------------------------------------------------------------------------

// port a: q - 20 bit tag + 128 bit data = 148 bits

simple_ram #(
    .width      (148),
    .widthad    (8)
)
cache_data_ram_inst(
    .clk        (clk),  //input
    
    .wraddress  (address[11:4]),            //input [7:0]
    .wren       (write_do),                 //input
    .data       ({ address[31:12], data }), //input [147:0]
    
    .rdaddress  ((read_do)? address[11:4] : last_address),  //input [7:0]
    .q          (q)                                         //output [147:0]
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address[3:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------
    
endmodule
