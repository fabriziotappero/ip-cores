/*
 * Copyright (c) 2008, Kendall Correll
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

function integer min (
	input integer a, b
);
begin
	min = a < b ? a : b;
end
endfunction

function integer max (
	input integer a, b
);
begin
	max = a > b ? a : b;
end
endfunction

// compute the log base 2 of a number, rounded down to the
// nearest whole number
function integer flog2 (
	input integer number
);
integer i;
integer count;
begin
	flog2 = 0;
	for(i = 0; i < 32; i = i + 1)
	begin
		if(number&(1<<i))
			flog2 = i;
	end
end
endfunction

// compute the log base 2 of a number, rounded up to the
// nearest whole number
function integer clog2 (
	input integer number
);
integer i;
integer count;
begin
	clog2 = 0;
	count = 0;
	for(i = 0; i < 32; i = i + 1)
	begin
		if(number&(1<<i))
		begin
			clog2 = i;
			count = count + 1;
		end
	end
	// clog2 holds the largest set bit position and count
	// holds the number of bits set. More than one bit set
	// indicates that the input was not an even power of 2,
	// so round the result up.
	if(count > 1)
		clog2 = clog2 + 1;
end
endfunction

// compute the size of the interconnect for the arbiter's
// 'select' muxes
function integer mux_sum (
	input integer width, select_width
);
integer i, number;
begin
	mux_sum = 0;
	number = 1;
	for(i = select_width; i > 0 && number <= width; i = i - 1)
	begin
		mux_sum = mux_sum + i*(number);
		number = number * 2;
	end
end
endfunction