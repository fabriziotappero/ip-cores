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

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_oddr4 #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT = 1'b0,
	parameter SRTYPE = "ASYNC"
) (
	output [3:0] Q,
	input C0,
	input C1,
	input CE,
	input [3:0] D0,
	input [3:0] D1,
	input R,
	input S
);

ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr0 (
	.Q(Q[0]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[0]),
	.D1(D1[0]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr1 (
	.Q(Q[1]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[1]),
	.D1(D1[1]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr2 (
	.Q(Q[2]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[2]),
	.D1(D1[2]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr3 (
	.Q(Q[3]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[3]),
	.D1(D1[3]),
	.R(R),
	.S(S)
);

endmodule
