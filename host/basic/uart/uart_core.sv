//============================================================================
// Module uart
//
// This module implements RS232 (UART) transmitter block
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
module uart_core #(parameter BAUD = 115200)
(
    //----------------------------------------------------------
    // Outputs from the module
    //----------------------------------------------------------
    output reg uart_tx,                // UART transmit wire
    output reg busy_tx,                // Signal that we are busy transmitting

    //----------------------------------------------------------
    // Inputs to the module
    //----------------------------------------------------------
    input wire clk,                     // Input clock that drives the execution
    input wire reset,                   // Async positive edge reset
    input wire [7:0] data_in,           // Byte to transmit
    input wire data_in_wr               // Signal to accept a byte to transmit
);

//============================================================================
// Define internal registers and states
//============================================================================
`define COUNT  (50000000/BAUD)          // Given 50MHz input, determine the proper divisor for a given BAUD rate
integer baud_count = `COUNT;            // Counter for clock divide down to meet the BAUD rate

reg [7:0] data;                         // Stores a byte to transmit

typedef enum logic[3:0] { IDLE, START, D0, D1, D2, D3, D4, D5, D6, D7, STOP, BRK1 } TState;
TState state = IDLE, next_state = IDLE;

//============================================================================
// State and cycle change logic
//============================================================================

// Store the byte to transmit when the wr signal is asserted
always @ (posedge data_in_wr)
begin
    if (!busy_tx)
        data <= data_in;
end

// Present state logic
always_ff @ (posedge clk or posedge reset)
begin
   if (reset) begin
      state <= IDLE;
      baud_count <= `COUNT;
   end else begin
      baud_count <= baud_count - 1;
      if (baud_count==0) begin
         state <= next_state;
         baud_count <= `COUNT;
      end
   end
end

// Next state logic
always @(posedge clk)
begin
   case (state)
      IDLE  :   if (data_in_wr) begin
                    next_state <= START;
                end
      START :   next_state <= D0;
      D0    :   next_state <= D1;
      D1    :   next_state <= D2;
      D2    :   next_state <= D3;
      D3    :   next_state <= D4;
      D4    :   next_state <= D5;
      D5    :   next_state <= D6;
      D6    :   next_state <= D7;
      D7    :   next_state <= STOP;
      STOP  :   next_state <= BRK1; // BRK bit is providing necessary space between characters
      BRK1  :   next_state <= IDLE;
   endcase
   // Make it 'busy' if we are not idling or if the new data is being written
   busy_tx <= (state==IDLE && next_state==IDLE) ? 1'h0 | data_in_wr : 1'h1;
end

always_comb
begin
   case (state)
      START :   uart_tx = 'b0;       // Start bit is low (start detect is neg edge)
      D0    :   uart_tx = data[0];   // Followed by 8 data bits
      D1    :   uart_tx = data[1];
      D2    :   uart_tx = data[2];
      D3    :   uart_tx = data[3];
      D4    :   uart_tx = data[4];
      D5    :   uart_tx = data[5];
      D6    :   uart_tx = data[6];
      D7    :   uart_tx = data[7];
      STOP, BRK1 : uart_tx = 'b1;    // "Stop" and "break" bits are high
      default : uart_tx = 'b1;       // By default, keep the data line high
   endcase
end

endmodule
