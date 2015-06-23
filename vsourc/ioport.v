/** @package zGlue

    @file ioport.v
        
    @brief building blocks for I/O port and peripheral registers;
            for eZ80 Family host processor with 24-bit address bus.

<BR>Simplified (2-clause) BSD License

Copyright (c) 2012, Douglas Beattie Jr.
All rights reserved.

Redistribution and use in source and hardware/binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in hardware/binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.

THIS RTL SOURCE IS PROVIDED BY DOUGLAS BEATTIE JR. "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL DOUGLAS BEATTIE JR. BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS RTL SOURCE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
                 
    Author: Douglas Beattie
    Created on: 4/12/2012 8:50:12 PM
	Last change: DBJR 4/28/2012 5:31:56 PM
*/
`timescale 1ns / 100ps

module ioport_a16_d8_wo(reset_n, wr_n, data_in, ouplatched_bus);
input           reset_n, wr_n;
input   [7:0]   data_in;
output reg  [7:0]   ouplatched_bus;
parameter INIT_VAL  = 8'b0 ;

always  @ (posedge wr_n or negedge reset_n)
    if (! reset_n)
        ouplatched_bus <= #1 INIT_VAL;
    else if (wr_n)
        ouplatched_bus <= #1 data_in;

endmodule

module ioport_a16_dx_wo(reset_n, wr_n, data_in, ouplatched_bus);
parameter NUM_BITS  = 8;
parameter INIT_VAL  = 0 ;
input       reset_n, wr_n;
input       [NUM_BITS-1:0]   data_in;
output reg  [NUM_BITS-1:0]   ouplatched_bus;

always  @ (posedge wr_n or negedge reset_n)
    if (! reset_n)
        ouplatched_bus <= #1 INIT_VAL;
    else if (wr_n)
        ouplatched_bus <= #1 data_in;

endmodule

