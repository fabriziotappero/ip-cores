/*
 * Copyright (c) 2009, Kendall Correll
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

`timescale 1ns / 1ps

module lfsr #(
	parameter width = 0,
	parameter reset_value = {width{1'b1}}
)(
	input enable,
	input load,
	input in,
	output reg [width-1:0] out,
	
	input clock,
	input reset
);

// it's assumed that the msb is a tap so it need not be in this table,
// indexes are 0-based, you can add cases for any other widths
function is_tap (
	input integer width, index
);
begin
	case(width)
	3:   is_tap = index == 1;
	4:   is_tap = index == 2;
	5:   is_tap = index == 2;
	6:   is_tap = index == 4;
	7:   is_tap = index == 5;
	8:   is_tap = index == 5   || index == 4   || index == 3;
	15:  is_tap = index == 13;
	16:  is_tap = index == 14  || index == 12  || index == 3;
	31:  is_tap = index == 27;
	32:  is_tap = index == 21  || index == 1   || index == 0;
	63:  is_tap = index == 61;
	64:  is_tap = index == 62  || index == 60  || index == 59;
	127: is_tap = index == 125;
	128: is_tap = index == 125 || index == 100 || index == 98;
	default: is_tap = 0;
	endcase
end
endfunction

// combine the taps to compute the next lsb
function [0:0] feedback (
	input [width-1:0] value
);
integer i;
begin
	// always include the msb
	feedback = value[width-1];
	
	// include the other taps specified by the table
	for(i = 0; i < width - 1; i = i + 1)
	begin
		if(is_tap(width, i))
			feedback = feedback ^ value[i];
	end
end
endfunction

// the shift register
always @(posedge clock, posedge reset)
begin
	if(reset)
		out <= reset_value;
	else
	begin
		if(enable)
			out <= {out[width-2:0], load ? in : feedback(out)};
	end
end

endmodule
