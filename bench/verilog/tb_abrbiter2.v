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

`timescale 1ns / 1ps

// This bench applies req vectors, deasserts req lines as
// they are granted, and tests that each req is granted
// only once for each vector. It seems to be a pretty good
// test because it is similar to the arbiter's intended
// application, and it focuses on fairness, the most
// important aspect of the arbiter's behavior. This test
// also makes it easy to use large arbiter configurations,
// which tend to find more problems.

`define WIDTH 128
`define SELECT_WIDTH 7
`define TURNAROUND 3
//`define TURNAROUND 6 for arbiter x2
`define TICK 10
`define HALF_TICK 5
`define TEST_VEC_COUNT 8
`define PATTERN_FILE "tb_arbiter2.txt"
`define ROUND_COUNT 3

module tb_arbiter2;

reg reset;
reg clock;

reg [`WIDTH-1:0] req;
wire [`WIDTH-1:0] grant;
wire [`SELECT_WIDTH-1:0] select;
wire valid;

reg [`WIDTH-1:0] pattern[`TEST_VEC_COUNT-1:0];

integer test_i;
integer grant_i;
integer grant_count;
integer req_i;
integer req_count[`TEST_VEC_COUNT-1:0];
integer failures;
integer monitor_exceptions;
integer fill_i;
integer round;
integer reqs[`WIDTH-1:0];
integer grants[`ROUND_COUNT-1:0][`WIDTH-1:0];

//
// UUT
//

arbiter #(
	.width(`WIDTH),
	.select_width(`SELECT_WIDTH)
) arbiter (
	.enable(1'b1),
	.req(req),
	.grant(grant),
	.select(select),
	.valid(valid),
	
	.clock(clock),
	.reset(reset)
);

//
// clock
//

always @(clock)
	#`HALF_TICK clock <= !clock;

//
// test monitors
//

always @(grant)
begin
	grant_count = 0;
	for(grant_i = 0; grant_i < `WIDTH; grant_i = grant_i + 1)
	begin
		if(grant[grant_i])
		begin
			grant_count = grant_count + 1;
			grants[round][grant_i] = grants[round][grant_i] + 1;
			
			if(!req[grant_i])
			begin
				monitor_exceptions = monitor_exceptions + 1;
				
				$display("EXCEPTION @%e: grant line %d with no req",
					$realtime, grant_i);
			end
			
			if(select != grant_i)
			begin
				monitor_exceptions = monitor_exceptions + 1;
				
				$display("EXCEPTION @%e: select of %d does not match grant of line %d",
					$realtime, select, grant_i);
			end
		end
	end
	
	if(grant_count > 1)
	begin
		monitor_exceptions = monitor_exceptions + 1;
		
		$display("EXCEPTION @%e: grant %h asserts multiple lines",
			$realtime, grant);
	end
end

//
// test sequence
//

initial
begin
	$readmemh(`PATTERN_FILE, pattern);
	failures = 0;
	monitor_exceptions = 0;
	fill_i = 0;
	round = 0;
	for(req_i = 0; req_i < `WIDTH; req_i = req_i + 1)
	begin
		reqs[req_i] = 0;
		
		grants[0][req_i] = 0;
		grants[1][req_i] = 0;
		grants[2][req_i] = 0;
	end
	// pre-calculate some values used in the test
	for(test_i = 0; test_i < `TEST_VEC_COUNT; test_i = test_i + 1)
	begin
		req_count[test_i] = 0;
		for(req_i = 0; req_i < `WIDTH; req_i = req_i + 1)
		begin
			if(pattern[test_i][req_i])
			begin
				req_count[test_i] = req_count[test_i] + 1;
				reqs[req_i] = reqs[req_i] + 1;
			end
		end
	end
	
	clock = 1;
	req = 0;
	reset = 1;
	#`TICK @(negedge clock) reset = 0;
	
	// apply reqs, and turn off granted reqs permanently
	for(test_i = 0; test_i < `TEST_VEC_COUNT; test_i = test_i + 1)
	begin
		req = pattern[test_i];
		
		for(req_i = 0; req_i < req_count[test_i]; req_i = req_i + 1)
		begin
			#(`TURNAROUND*`TICK);
			
			req = req & ~grant;
		end
		
		// one clock to deassert the last req before we apply
		// the next req vector
		#`TICK;
	end
	
	// apply reqs, but only turn off granted reqs temporarily
	round = round + 1;
	for(test_i = 0; test_i < `TEST_VEC_COUNT; test_i = test_i + 1)
	begin
		req = pattern[test_i];
		
		for(req_i = 0; req_i < req_count[test_i]; req_i = req_i + 1)
		begin
			#(`TURNAROUND*`TICK);
			
			req = pattern[test_i] & ~grant;
		end
		
		// one clock to deassert the reqs before we apply the
		// next req vector
		req = 0;
		#`TICK;
	end
	
	// apply reqs, and fill behind with the next vector as reqs
	// are granted
	round = round + 1;
	req = pattern[0];
	fill_i = `WIDTH;
	for(test_i = 0; test_i < `TEST_VEC_COUNT; test_i = test_i + 1)
	begin
		for(req_i = 0; req_i < req_count[test_i]; req_i = req_i + 1)
		begin
			#(`TURNAROUND*`TICK);
			
			req = req & ~grant;
			
			for(fill_i = fill_i; ~grant[fill_i%`WIDTH]; fill_i = fill_i + 1)
			begin
				req[fill_i%`WIDTH] = (fill_i/`WIDTH < `TEST_VEC_COUNT)
					? pattern[fill_i/`WIDTH][fill_i%`WIDTH]
					: 1'b0;
			end
		end
	end
	
	// check the results
	for(req_i = 0; req_i < `WIDTH; req_i = req_i + 1)
	begin
		if(reqs[req_i] != grants[0][req_i]
			|| reqs[req_i] != grants[1][req_i]
			|| reqs[req_i] != grants[2][req_i])
		begin
			failures = failures + 1;
			
			$display("FAILED %d: %d reqs, %d %d %d grants",
				req_i, reqs[req_i], grants[0][req_i],
				grants[1][req_i], grants[2][req_i]);
		end
		else
		begin
			$display("ok %d: %d reqs, %d %d %d grants",
				req_i, reqs[req_i], grants[0][req_i],
				grants[1][req_i], grants[2][req_i]);
		end
	end
	
	$display("%d failures", failures);
	$display("%d monitor exceptions", monitor_exceptions);
	
	if(failures == 0 && monitor_exceptions == 0)
		$display("PASS");
	else
		$display("FAIL");
end

endmodule
