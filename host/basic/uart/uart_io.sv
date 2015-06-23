//============================================================================
// Module uart IO interface
//
// This module implements RS232 (UART) transmitter block and its IO interface:
// 8 bits of IO addresses map to:
//   Address 8  - Write a byte to UART
//   Address 10 - Get UART busy status in bit 0
//
// The signalling uses *positive* logic.
//
//  Copyright (C) 2014  Goran Devic
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================
// altera message_off 10175
module uart_io (reset, clk, Address, Data, IORQ, RD, WR, uart_tx);

input reset, clk;
input [7:0] Address;
inout [7:0] Data;
input IORQ, RD, WR;
output uart_tx;

extern module uart_core
(
    output uart_tx,                // UART transmit wire
    output busy_tx,                // Signal that we are busy transmitting
    input clk,                     // Input clock that drives the execution
    input reset,                   // Async positive edge reset
    input [7:0] data_in,           // Byte to transmit
    input data_in_wr               // Signal to accept a byte to transmit
);


logic uart_tx;                  // UART transmit wire
logic busy_tx;                  // Busy transmitting
logic data_in_wr;               // Write a new byte to transmit

always @(posedge clk)
begin
    if (Address[7:0]==8'd8 && IORQ==1 && RD==0 && WR==1 && !busy_tx) begin
        data_in_wr <= 1;
        $strobe("[UART] %c", Data);
    end else begin
        data_in_wr <= 0;
    end
end

assign Data[7:0] = (Address[7:0]==8'd10 && IORQ==1 && RD==1 && WR==0) ? {{7{1'b0}},busy_tx}  : {8{1'bz}} ;

uart_core uart_core_( .*, .data_in(Data) );

endmodule
