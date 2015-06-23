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

module hpdmc_oddr32 #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT = 1'b0,
	parameter SRTYPE = "ASYNC"
) (
	output [31:0] Q,
	input C0,
	input C1,
	input CE,
	input [31:0] D0,
	input [31:0] D1,
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
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr4 (
	.Q(Q[4]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[4]),
	.D1(D1[4]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr5 (
	.Q(Q[5]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[5]),
	.D1(D1[5]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr6 (
	.Q(Q[6]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[6]),
	.D1(D1[6]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr7 (
	.Q(Q[7]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[7]),
	.D1(D1[7]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr8 (
	.Q(Q[8]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[8]),
	.D1(D1[8]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr9 (
	.Q(Q[9]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[9]),
	.D1(D1[9]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr10 (
	.Q(Q[10]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[10]),
	.D1(D1[10]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr11 (
	.Q(Q[11]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[11]),
	.D1(D1[11]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr12 (
	.Q(Q[12]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[12]),
	.D1(D1[12]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr13 (
	.Q(Q[13]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[13]),
	.D1(D1[13]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr14 (
	.Q(Q[14]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[14]),
	.D1(D1[14]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr15 (
	.Q(Q[15]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[15]),
	.D1(D1[15]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr16 (
	.Q(Q[16]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[16]),
	.D1(D1[16]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr17 (
	.Q(Q[17]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[17]),
	.D1(D1[17]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr18 (
	.Q(Q[18]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[18]),
	.D1(D1[18]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr19 (
	.Q(Q[19]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[19]),
	.D1(D1[19]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr20 (
	.Q(Q[20]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[20]),
	.D1(D1[20]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr21 (
	.Q(Q[21]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[21]),
	.D1(D1[21]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr22 (
	.Q(Q[22]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[22]),
	.D1(D1[22]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr23 (
	.Q(Q[23]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[23]),
	.D1(D1[23]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr24 (
	.Q(Q[24]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[24]),
	.D1(D1[24]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr25 (
	.Q(Q[25]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[25]),
	.D1(D1[25]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr26 (
	.Q(Q[26]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[26]),
	.D1(D1[26]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr27 (
	.Q(Q[27]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[27]),
	.D1(D1[27]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr28 (
	.Q(Q[28]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[28]),
	.D1(D1[28]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr29 (
	.Q(Q[29]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[29]),
	.D1(D1[29]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr30 (
	.Q(Q[30]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[30]),
	.D1(D1[30]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr31 (
	.Q(Q[31]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[31]),
	.D1(D1[31]),
	.R(R),
	.S(S)
);

endmodule
