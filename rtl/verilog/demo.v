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

/*
These results give a rough idea of how the timing and size scale
with the arbiter width. It is useful to look at the trends, but
the individual values should be taken with a grain of salt.

Preliminary results using XC6SLX45-2FGG484:

                  arbiter                        arbiter_x2
        /----------------------------\  /----------------------------\
 width     MHz     LEs   LUTs    FFs       MHz     LEs   LUTs    FFs
    8    289.855     42     34     35    399.672     56     36     53
   16    273.000     83     67     68    397.377    109     70    103
   32    230.240    188    156    133    289.855    214    143    188
   64    189.593    391    320    262    289.855    428    288    370
  128    166.073    796    650    519    261.852    886    618    699
  256    161.496   1582   1267   1032    261.852   1779   1245   1389
  512    136.753   3164   2493   2057    196.883   3489   2443   2686
 1024    122.155   6755   5348   4106    197.280   7015   4928   5360
 2048    102.198  12538   9485   8203    193.289  13956   9767  10513
 4096    103.433  27182  20683  16396    190.964  27813  19450  21011

note: width 4096 arbiter_x2 exceeds device capacity

Preliminary results using EP3C40F484C8:

                  arbiter                        arbiter_x2
        /---------------------------\  /---------------------------\
 width     MHz    LEs   LUTs    FFs       MHz    LEs   LUTs    FFs
    8    444.25     50     42     35    457.67     65     46     53
   16    313.77     92     91     68    396.67    114     92    103
   32    239.52    195    194    133    338.18    232    194    188
   64    185.08    388    387    262    311.04    465    393    370
  128    161.47    769    768    519    283.37    959    822    699
  256    138.26   1551   1550   1032    249.25   1889   1619   1389
  512    103.90   3132   3131   2057    155.88   3657   3132   2686
 1024     88.39   6150   6149   4106    132.93   7328   6282   5360
 2048     76.24  12283  12282   8203    138.12  14549  12479  10513
 4096     57.02  24533  24532  16396    128.07  29099  24964  21011
*/

`timescale 1ns / 1ps

module demo #(
	parameter width = 128,
	parameter select_width = 7
)(
	input next_test,
	input next_step,
	output [select_width-1:0] select,
	output valid,
	
	input clock,
	input reset
);

reg [width-1:0] req;
wire [width-1:0] seq;
wire [width-1:0] grant;

lfsr #(
	.width(width)
) lfsr (
	.enable(next_test),
	.load(1'b0),
	.in(1'bx),
	.out(seq),
	
	.clock(clock),
	.reset(reset)
);

arbiter #(
	.width(width),
	.select_width(select_width)
) arbiter (
	.enable(1'b1),
	.req(req),
	.grant(grant),
	.select(select),
	.valid(valid),
	
	.clock(clock),
	.reset(reset)
);

always @(posedge clock)
begin
	if(reset)
		req <= 0;
	else
	begin
		if(next_test)
			req <= seq;
		else if(next_step)
			req <= req & ~grant;
	end
end

endmodule
