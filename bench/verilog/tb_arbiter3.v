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

// This bench walks the demo through its sequence, but it does not verify outputs.

`define WIDTH 16
`define SELECT_WIDTH 4
`define TURNAROUND 3
`define TICK 10
`define HALF_TICK 5

module tb_arbiter3;

reg clock;
reg reset;

reg next_test;
reg next_step;

wire [`SELECT_WIDTH-1:0] select;
wire valid;

integer test_i;

`include "functions.v"

//
// UUT
//

demo #(
	.width(`WIDTH),
	.select_width(`SELECT_WIDTH)
) demo (
	.next_test(next_test),
	.next_step(next_step),
	.select(select),
	.valid(valid),
	.clock(clock),
	.reset(reset)
);

//
// clock
//

always @(clock)
begin
	#`HALF_TICK clock <= !clock;
end

//
// test sequence
//

initial begin
	clock = 1;
	next_test = 0;
	next_step = 0;
	reset = 1;
	#`TICK @(negedge clock) reset = 0;
	
	// step through the stimulus sequence, 'req_enable' is always high, so
	// reqs will be deasserted as soon as they are granted
	while(1'b1)
	begin
		#`TICK next_test = 1;
		#`TICK next_test = 0;
		
		for(test_i = 0; test_i < `WIDTH; test_i = test_i + 1)
		begin
			#(`TURNAROUND*`TICK) next_step = 1;
			#`TICK next_step = 0;
		end
	end
end

endmodule
