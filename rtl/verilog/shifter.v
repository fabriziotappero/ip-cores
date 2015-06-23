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

module shifter #(
	parameter depth = 0,
	parameter width = 0
)(
	input enable,
	input load,
	
	input [(depth*width)-1:0] parallel_in,
	input [width-1:0] serial_in,
	output [(depth*width)-1:0] parallel_out,
	output [width-1:0] serial_out,
	
	input clock
);

reg [(depth*width)-1:0] internal;

assign parallel_out = internal;
assign serial_out = internal[width-1:0];

integer i;

always @(posedge clock)
begin
	if(enable)
	begin
		internal[(depth*width)-1-:width] <= load
			? parallel_in[(depth*width)-1-:width]
			: serial_in;
		
		for(i = depth - 1; i > 0; i = i - 1)
		begin
			internal[(i*width)-1-:width] <= load
				? parallel_in[(i*width)-1-:width]
				: internal[((i+1)*width)-1-:width];
		end
	end
end

endmodule
