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

// Two synchronous arbiter implementations are provided:
// 'arbiter' and 'arbiter_x2'. Both are round-robin arbiters
// with a configurable number of inputs. The algorithm used is
// recursive in that you can build a larger arbiter from a
// tree of smaller arbiters. 'arbiter_x2' is a tree of
// 'arbiter' modules, 'arbiter' is a tree of 'arbiter_node'
// modules, and 'arbiter_node' is the primitive of the
// algorithm, a two input round-robin arbiter.
//
// Both 'arbiter' and 'arbiter_x2' can take multiple clocks
// to grant a request. (Of course, neither arbiter should
// assert an invalid grant while changing state.) 'arbiter'
// can take up to three clocks to grant a req, and 'arbiter_x2'
// can take up to five clocks. 'arbiter_x2' is probably only
// necessary for configurations over a thousand inputs.
// Presently, the width of both 'arbiter' and 'arbiter_x2'
// must be power of two due to the way they instantiate a tree
// of sub-arbiters. Extra inputs can be assigned to zero, and
// extra outputs can be left disconnected.
//
// Parameters for 'arbiter' and 'arbiter_x2':
//   'width' is width of the 'req' and 'grant' ports, which
//     must be a power of two.
//   'select_width' is the width of the 'select' port, which
//     should be the log base two of 'width'.
//
// Ports for 'arbiter' and 'arbiter_x2':
//   'enable' masks the 'grant' outputs. It is used to chain
//     arbiters together, but it might be useful otherwise.
//     It can be left disconnected if not needed.
//   'req' are the input lines asserted to request access to
//     the arbitrated resource.
//   'grant' are the output lines asserted to grant each
//     requestor access to the arbitrated resource.
//   'select' is a binary encoding of the bitwise 'grant'
//     output. It is useful to control a mux that connects
//     requestor outputs to the arbitrated resource. It can
//     be left disconnected if not needed.
//   'valid' is asserted when any 'req' is asserted. It is
//     used to chain arbiters together, but it might be
//     otherwise useful. It can be left disconnected if not
//     needed.

// 'arbiter_x2' is a two-level tree of arbiters made from
// registered 'arbiter' modules. It allows a faster clock in
// large configurations by breaking the arbiter into two
// registered stages. For most uses, the standard 'arbiter'
// module is plenty fast. See the 'demo_arbiter' module for
// some implemntation results.

module arbiter_x2 #(
	parameter width = 0,
	parameter select_width = 1
)(
	input enable,
	input [width-1:0] req,
	output reg [width-1:0] grant,
	output reg [select_width-1:0] select,
	output reg valid,
	
	input clock,
	input reset
);

`include "functions.v"

// 'width1' is the width of the first stage arbiters, which
// is the square root of 'width' rounded up to the nearest
// power of 2, calculated as: exp2(ceiling(log2(width)/2))
parameter width1 = 1 << ((clog2(width)/2) + (clog2(width)%2));
parameter select_width1 = clog2(width1);

// 'width0' is the the width of the second stage arbiter,
// which is the number of arbiters in the first stage.
parameter width0 = width/width1;
parameter select_width0 = clog2(width0);

genvar g;

wire [width-1:0] grant1;
wire [(width0*select_width1)-1:0] select1;
wire [width0-1:0] enable1;
wire [width0-1:0] req0;
wire [width0-1:0] grant0;
wire [select_width0-1:0] select0;
wire valid0;
wire [select_width1-1:0] select_mux[width0-1:0];

assign enable1 = grant0 & req0;

// Register the outputs.
always @(posedge clock, posedge reset)
begin
	if(reset)
	begin
		valid <= 0;
		grant <= 0;
		select <= 0;
	end
	else
	begin
		valid <= valid0;
		grant <= grant1;
		select <= { select0, select_mux[select0] };
	end
end

// Instantiate the first stage of the arbiter tree.
arbiter #(
	.width(width1),
	.select_width(select_width1)
) stage1_arbs[width0-1:0] (
	.enable(enable1),
	.req(req),
	.grant(grant1),
	.select(select1),
	.valid(req0),
	
	.clock(clock),
	.reset(reset)
);

// Instantiate the second stage of the arbiter tree.
arbiter #(
	.width(width0),
	.select_width(select_width0)
) stage0_arb (
	.enable(enable),
	.req(req0),
	.grant(grant0),
	.select(select0),
	.valid(valid0),
	
	.clock(clock),
	.reset(reset)
);

// Generate muxes for the select outputs.
generate
for(g = 0; g < width0; g = g + 1)
begin: gen_mux
	assign select_mux[g] = select1[((g+1)*select_width1)-1-:select_width1];
end
endgenerate

endmodule

// 'arbiter' is a tree made from unregistered 'arbiter_node'
// modules. Unregistered carries between nodes allows
// the tree to change state on the same clock. The tree
// contains (width - 1) nodes, so resource usage of the
// arbiter grows linearly. The number of levels and thus the
// propogation delay down the tree grows with log2(width).
// The logarithmic delay scaling makes this arbiter suitable
// for large configuations. This module can take up to three
// clocks to grant the next requestor after its inputs change
// (two clocks for the 'arbiter_node' modules and one clock
// for the output registers).

module arbiter #(
	parameter width = 0,
	parameter select_width = 1
)(
	input enable,
	input [width-1:0] req,
	output reg [width-1:0] grant,
	output reg [select_width-1:0] select,
	output reg valid,
	
	input clock,
	input reset
);

`include "functions.v"

genvar g;

// These wires interconnect arbiter nodes.
wire [2*width-2:0] interconnect_req;
wire [2*width-2:0] interconnect_grant;
wire [width-2:0] interconnect_select;
wire [mux_sum(width,clog2(width))-1:0] interconnect_mux;

// Assign inputs to some interconnects.
assign interconnect_req[2*width-2-:width] = req;
assign interconnect_grant[0] = enable;

// Assign the select outputs of the first arbiter stage to
// the first mux stage.
assign interconnect_mux[mux_sum(width,clog2(width))-1-:width/2] = interconnect_select[width-2-:width/2];

// Register some interconnects as outputs.
always @(posedge clock, posedge reset)
begin
	if(reset)
	begin
		valid <= 0;
		grant <= 0;
		select <= 0;
	end
	else
	begin
		valid <= interconnect_req[0];
		grant <= interconnect_grant[2*width-2-:width];
		select <= interconnect_mux[clog2(width)-1:0];
	end
end

// Generate the stages of the arbiter tree. Each stage is
// instantiated as an array of 'abiter_node' modules and
// is half the width of the previous stage. Some simple
// arithmetic part-selects the interconnects for each stage.
// See the "Request/Grant Interconnections" diagram of an
// arbiter in the documentation.
generate
for(g = width; g >= 2; g = g / 2)
begin: gen_arb
	arbiter_node nodes[(g/2)-1:0] (
		.enable(interconnect_grant[g-2-:g/2]),
		.req(interconnect_req[2*g-2-:g]),
		.grant(interconnect_grant[2*g-2-:g]),
		.select(interconnect_select[g-2-:g/2]),
		.valid(interconnect_req[g-2-:g/2]),
		
		.clock(clock),
		.reset(reset)
	);
end
endgenerate

// Generate the select muxes for each stage of the arbiter
// tree. The generate begins on the second stage because
// there are no muxes in the first stage. Each stage is
// a two dimensional array of muxes, where the dimensions
// are number of arbiter nodes in the stage times the
// number of preceeding stages. It takes some tricky
// arithmetic to part-select the interconnects for each
// stage. See the "Select Interconnections" diagram of an
// arbiter in the documentation.
generate
for(g = width/2; g >= 2; g = g / 2)
begin: gen_mux
	mux_array #(
		.width(g/2)
	) mux_array[clog2(width/g)-1:0] (
		.in(interconnect_mux[mux_sum(g,clog2(width))-1-:clog2(width/g)*g]),
		.select(interconnect_select[g-2-:g/2]),
		.out(interconnect_mux[mux_sum(g/2,clog2(width))-(g/2)-1-:clog2(width/g)*g/2])
	);
	assign interconnect_mux[mux_sum(g/2,clog2(width))-1-:g/2] = interconnect_select[g-2-:g/2];
end
endgenerate

endmodule

module mux_array #(
	parameter width = 0
)(
	input [(2*width)-1:0] in,
	input [width-1:0] select,
	output [width-1:0] out
);

mux_node nodes[width-1:0] (
	.in(in),
	.select(select),
	.out(out)
	);

endmodule

module mux_node (
	input [1:0] in,
	input select,
	output out
);

assign out = select ?  in[1] : in[0];

endmodule

// This is a two input round-robin arbiter with the
// addition of the 'valid' and 'enable' signals
// that allow multiple nodes to be connected to form a
// larger arbiter. Outputs are not registered to allow
// interconnected nodes to change state on the same clock.

module arbiter_node (
	input enable,
	input [1:0] req,
	output [1:0] grant,
	output select,
	output valid,
	
	input clock,
	input reset
);

// The state determines which 'req' is granted. State '0'
// grants 'req[0]', state '1' grants 'req[1]'.
reg grant_state;
wire next_state;

// The 'grant' of this stage is masked by 'enable', which
// carries the grants of the subsequent stages back to this
// stage. The 'grant' is also masked by 'req' to ensure that
// 'grant' is dropped as soon 'req' goes away.
assign grant[0] = req[0] & ~grant_state & enable;
assign grant[1] = req[1] & grant_state & enable;

// Select is a binary value that tracks grant. It could
// be used to control a mux on the arbitrated resource.
assign select = grant_state;

// The 'valid' carries reqs to subsequent stages. It is
// high when the 'req's are high, except during 1-to-0 state
// transistions when it's dropped for a cycle to allow
// subsequent arbiter stages to make progress. This causes a
// two cycle turnaround for 1-to-0 state transistions.
/*
always @(grant_state, next_state, req)
begin
	if(grant_state & ~next_state)
		valid <= 0;
	else if(req[0] | req[1])
		valid <= 1;
	else
		valid <= 0;
end
*/
// reduced 'valid' logic
assign valid = (req[0] & ~grant_state) | req[1];

// The 'next_state' logic implements round-robin fairness
// for two inputs. When both reqs are asserted, 'req[0]' is
// granted first. This state machine along with some output
// logic can be cascaded to implement round-robin fairness
// for many inputs.
/*
always @(grant_state, req)
begin
	case(grant_state)
	0:
		if(req[0])
			next_state <= 0;
		else if(req[1])
			next_state <= 1;
		else
			next_state <= 0;
	1:
		if(req[1])
			next_state <= 1;
		else
			next_state <= 0;
	endcase
end
*/
// reduced next state logic
assign next_state = (req[1] & ~req[0]) | (req[1] & grant_state);

// state register
always @(posedge clock, posedge reset)
begin
	if(reset)
		grant_state <= 0;
	else
		grant_state <= next_state;
end

endmodule
