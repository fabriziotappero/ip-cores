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

module prefetch_fifo(
    input           clk,
    input           rst_n,
    
    input           pr_reset,
    
    //RESP:
    input           prefetchfifo_signal_limit_do,
    //END
    
    //RESP:
    input           prefetchfifo_signal_pf_do,
    //END
    
    //RESP:
    input           prefetchfifo_write_do,
    input   [135:0] prefetchfifo_write_data,
    //END
    
    output  [4:0]   prefetchfifo_used,
    
    //RESP:
    input           prefetchfifo_accept_do,
    output [67:0]   prefetchfifo_accept_data,
    output          prefetchfifo_accept_empty
    //END
);

//------------------------------------------------------------------------------

assign prefetchfifo_accept_data = (second_processing)? second : q[67:0];

assign prefetchfifo_accept_empty= empty && second_processing == `FALSE;

//------------------------------------------------------------------------------

wire [135:0] q;
wire         empty;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

reg        second_processing;
reg [67:0] second;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   second_processing <= `FALSE;
    else if(pr_reset)                                                                                   second_processing <= `FALSE;
    else if(prefetchfifo_accept_do && second_processing == `FALSE && q[135:132] != 4'd0 && ~(empty))    second_processing <= `TRUE;
    else if(prefetchfifo_accept_do && second_processing == `TRUE)                                       second_processing <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               second <= 68'd0;
    else if(prefetchfifo_accept_do && second_processing == `FALSE)  second <= q[135:68];
end


//------------------------------------------------------------------------------

simple_fifo #(
    .width      (136),
    .widthu     (4)
)
prefetch_fifo_inst(
    .clk        (clk),      //input
    .rst_n      (rst_n),    //input
    .sclr       (pr_reset), //input
    
    .rdreq      (prefetchfifo_accept_do && second_processing == `FALSE),                                //input
    .wrreq      (prefetchfifo_write_do || prefetchfifo_signal_limit_do || prefetchfifo_signal_pf_do),   //input
    .data       ((prefetchfifo_signal_limit_do)? { 4'd0, 64'd0, `PREFETCH_GP_FAULT, 64'd0 } :
                 (prefetchfifo_signal_pf_do)?    { 4'd0, 64'd0, `PREFETCH_PF_FAULT, 64'd0 } :
                                                     prefetchfifo_write_data),                          //input [135:0]
    
    
    .empty      (empty),                    //output
    .full       (prefetchfifo_used[4]),     //output
    .q          (q),                        //output [135:0]
    .usedw      (prefetchfifo_used[3:0])    //output [3:0]
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule
