//---------------------------------------------------------------------------
// BCD to binary converter, serial implementation, 1 clock per input bit.
//
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 2002 John Clayton and OPENCORES.ORG (this Verilog version)
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation;  either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source.
// If not, download it from http://www.opencores.org/lgpl.shtml
//
//-----------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : Nov. 24, 2003
// Update: Nov. 24, 2003  Copied this file from "binary_to_bcd.v" and
//                        modified it.
// Update: Nov. 25, 2003  Tested this module.  It works!
// Update: Nov. 25, 2003  Changed bit_counter and related logic so that long
//                        start pulses produce correct results at the end of
//                        the pulse.
//
//-----------------------------------------------------------------------------
// Description:
//
// This module takes a BCD input, and converts it into binary output, with each
// binary coded decimal input digit (of course) occupying 4-bits.
// The user can specify the number of input digits separately from the number
// of output bits.  Be sure that you have specified enough output bits to
// represent the largest input number you expect to convert, or else the
// most significant portion of the BCD input will never be processed.
// This module processes the BCD digits starting with the least significant
// and working its way through to the more significant digits, until the binary
// output register is "fully stuffed" with output bits.
// This means that a particular BCD input digit might only be processed half
// way!
// Also, there is no checking for invalid BCD digit contents...  Behavior is
// undefined for "BCD" input values outside the range [0..9], although it would
// be very easy to add error checking with an error indicator output bit.
//
//-----------------------------------------------------------------------------


module bcd_to_binary (
  clk_i,
  ce_i,
  rst_i,
  start_i,
  dat_bcd_i,
  dat_binary_o,
  done_o
  );
parameter BCD_DIGITS_IN_PP   = 5;  // # of digits of BCD input
parameter BITS_OUT_PP        = 16; // # of bits of binary output
parameter BIT_COUNT_WIDTH_PP = 4;  // Width of bit counter

// I/O declarations
input  clk_i;                      // clock signal
input  ce_i;                       // clock enable input
input  rst_i;                      // synchronous reset
input  start_i;                    // initiates a conversion
input  [4*BCD_DIGITS_IN_PP-1:0] dat_bcd_i;  // input bus
output [BITS_OUT_PP-1:0] dat_binary_o;      // output bus
output done_o;                     // indicates conversion is done

reg [BITS_OUT_PP-1:0] dat_binary_o;

// Internal signal declarations

reg  [BITS_OUT_PP-1:0] bin_reg;
reg  [4*BCD_DIGITS_IN_PP-1:0] bcd_reg;
wire [BITS_OUT_PP-1:0] bin_next;
reg  [4*BCD_DIGITS_IN_PP-1:0] bcd_next;
reg  busy_bit;
reg  [BIT_COUNT_WIDTH_PP-1:0] bit_count;
wire bit_count_done;

//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------

function [4*BCD_DIGITS_IN_PP-1:0] bcd_asr;
  input [4*BCD_DIGITS_IN_PP-1:0] din;
  integer k;
  reg cin;
  reg [3:0] digit;
  reg [3:0] digit_more;

  begin
    cin = 1'b0;
    for (k=BCD_DIGITS_IN_PP-1; k>=0; k=k-1) // From MS digit to LS digit
    begin
      digit[3] = 1'b0;
      digit[2] = din[4*k+3];
      digit[1] = din[4*k+2];
      digit[0] = din[4*k+1];
      digit_more = digit + 5;
      if (cin)
      begin
        bcd_asr[4*k+3] = digit_more[3];
        bcd_asr[4*k+2] = digit_more[2];
        bcd_asr[4*k+1] = digit_more[1];
        bcd_asr[4*k+0] = digit_more[0];
      end
      else
      begin
        bcd_asr[4*k+3] = digit[3];
        bcd_asr[4*k+2] = digit[2];
        bcd_asr[4*k+1] = digit[1];
        bcd_asr[4*k+0] = digit[0];
      end
      cin = din[4*k+0];
    end  // end of for loop
  end

endfunction

//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

// Perform proper shifting, binary ASL and BCD ASL
assign bin_next = {bcd_reg[0],bin_reg[BITS_OUT_PP-1:1]};
always @(bcd_reg)
begin
  bcd_next <= bcd_asr(bcd_reg);
//  bcd_next <= bcd_reg >> 1;  Just for testing...
end

// Busy bit, input and output registers
always @(posedge clk_i)
begin
  if (rst_i)
  begin
    busy_bit <= 0;  // Synchronous reset
    dat_binary_o <= 0;
  end
  else if (start_i && ~busy_bit)
  begin
    busy_bit <= 1;
    bcd_reg <= dat_bcd_i;
    bin_reg <= 0;
  end
  else if (busy_bit && ce_i && bit_count_done && ~start_i)
  begin
    busy_bit <= 0;
    dat_binary_o <= bin_next;
  end
  else if (busy_bit && ce_i & ~bit_count_done)
  begin
    bin_reg <= bin_next;
    bcd_reg <= bcd_next;
  end
end
assign done_o = ~busy_bit;

// Bit counter
always @(posedge clk_i)
begin
  if (~busy_bit) bit_count <= 0;
  else if (ce_i && ~bit_count_done) bit_count <= bit_count + 1;
end
assign bit_count_done = (bit_count == (BITS_OUT_PP-1));

endmodule

