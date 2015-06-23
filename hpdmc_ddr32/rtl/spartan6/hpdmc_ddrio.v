/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_ddrio(
	input sys_clk,
	input sys_clk_n,
	input dqs_clk,
	input dqs_clk_n,
	
	input direction,
	input direction_r,
	input [7:0] mo,
	input [63:0] do,
	output [63:0] di,
	
	output [3:0] sdram_dm,
	inout [31:0] sdram_dq,
	inout [3:0] sdram_dqs,
	
	input idelay_rst,
	input idelay_ce,
	input idelay_inc
);

/******/
/* DQ */
/******/

wire [31:0] sdram_dq_t;
wire [31:0] sdram_dq_out;
wire [31:0] sdram_dq_in;

hpdmc_iobuf32 iobuf_dq(
	.T(sdram_dq_t),
	.I(sdram_dq_out),
	.O(sdram_dq_in),
	.IO(sdram_dq)
);

hpdmc_oddr32 oddr_dq_t(
	.Q(sdram_dq_t),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0({32{~direction_r}}),
	.D1({32{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_oddr32 oddr_dq(
	.Q(sdram_dq_out),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(do[63:32]),
	.D1(do[31:0]),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_iddr32 iddr_dq(
	.Q0(di[31:0]),
	.Q1(di[63:32]),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D(sdram_dq_in),
	.R(1'b0),
	.S(1'b0)
);

/*******/
/* DM */
/*******/

hpdmc_oddr4 oddr_dm(
	.Q(sdram_dm),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(mo[7:4]),
	.D1(mo[3:0]),
	.R(1'b0),
	.S(1'b0)
);

/*******/
/* DQS */
/*******/

wire [3:0] sdram_dqs_t;
wire [3:0] sdram_dqs_out;

hpdmc_obuft4 obuft_dqs(
	.T(sdram_dqs_t),
	.I(sdram_dqs_out),
	.O(sdram_dqs)
);

hpdmc_oddr4 oddr_dqs_t(
	.Q(sdram_dqs_t),
	.C0(dqs_clk),
	.C1(dqs_clk_n),
	.CE(1'b1),
	.D0({4{~direction_r}}),
	.D1({4{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_oddr4 oddr_dqs(
	.Q(sdram_dqs_out),
	.C0(dqs_clk),
	.C1(dqs_clk_n),
	.CE(1'b1),
	.D0(4'hf),
	.D1(4'h0),
	.R(1'b0),
	.S(1'b0)
);

endmodule
