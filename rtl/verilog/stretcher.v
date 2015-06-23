/*
 * Copyright (c) 2008-2009, Kendall Correll
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

module stretcher #(
	parameter count = 1,
	parameter high_count = count,
	parameter low_count = count,
	parameter width = 1,
	parameter reset_value = {width{1'b0}}
)(
	input enable,
	input [width-1:0] in,
	output reg [width-1:0] out,
	output reg valid,
	
	input clock,
	input reset
);

`include "functions.v"

// edge detector
wire rising;
wire falling;

assign rising = |(~out & in);
assign falling = |(out & ~in);

/// counter width is the maximum size of the loaded value
parameter counter_width = max(flog2(count - 1) + 1,
	max(flog2(high_count - 1) + 1, flog2(low_count - 1) + 1));

reg [counter_width:0] counter;
reg [counter_width-1:0] counter_load;
wire counter_overflow;

assign counter_overflow = counter[counter_width];

// select counter value for rising or falling edge
always @(rising, falling)
begin
	case({rising, falling})
	'b11:
		counter_load = -count;
	'b10:
		counter_load = -high_count;
	'b01:
		counter_load = -low_count;
	default:
		counter_load = {counter_width{1'bx}};
	endcase
end

// the counter is reset on a rising or falling edge
// overflow has priority over reset, so input changes
// will be ignored until the full count is reached
always @(posedge clock, posedge reset)
begin
	if(reset)
		counter <= {counter_width{1'b0}};
	else
	begin
		if(enable & ~counter_overflow)
			counter <= counter + 1;
		else if((rising | falling) & counter_overflow)
			counter <= { 1'b0, counter_load };
	end
end

// output is gated by the counter overflow
always @(posedge clock, posedge reset)
begin
	if(reset)
		out <= reset_value;
	else
	begin
		if(counter_overflow)
			out <= in;
	end
end

always @(posedge clock, posedge reset)
begin
	if(reset)
		valid <= 0;
	else
		valid <= counter_overflow;
end

endmodule
