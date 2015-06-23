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

module dcache_to_icache_fifo(
    input           clk,
    input           rst_n,
    
    //RESP:
    input           dcachetoicache_write_do,
    input [31:0]    dcachetoicache_write_address,
    //END
    
    
    //RESP:
    input           dcachetoicache_accept_do,
    output [31:0]   dcachetoicache_accept_address,
    output          dcachetoicache_accept_empty
    //END
);

//------------------------------------------------------------------------------

wire [27:0] q;

simple_fifo #(
    .width      (28),
    .widthu     (5)
)
dcache_to_icache_fifo_inst (
    .clk        (clk),      //input
    .rst_n      (rst_n),    //input
    .sclr       (1'b0),     //input
    
    .rdreq      (dcachetoicache_accept_do),             //input
    .wrreq      (dcachetoicache_write_do),              //input
    .data       (dcachetoicache_write_address[31:4]),   //input [27:0]
    
    
    .empty      (dcachetoicache_accept_empty),          //output
    .q          (q),                                    //output [27:0]
    
    /* verilator lint_off PINNOCONNECT */
    .full       (),                                     //output not used
    .usedw      ()                                      //output [4:0] not used
    /* verilator lint_on PINNOCONNECT */
);

//------------------------------------------------------------------------------

assign dcachetoicache_accept_address = { q, 4'd0 };

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, dcachetoicache_write_address[3:0],  1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------


endmodule
