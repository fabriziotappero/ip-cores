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

module hpdmc_iobuf32(
	input [31:0] T,
	input [31:0] I,
	output [31:0] O,
	inout [31:0] IO
);

IOBUF iobuf0(
	.T(T[0]),
	.I(I[0]),
	.O(O[0]),
	.IO(IO[0])
);
IOBUF iobuf1(
	.T(T[1]),
	.I(I[1]),
	.O(O[1]),
	.IO(IO[1])
);
IOBUF iobuf2(
	.T(T[2]),
	.I(I[2]),
	.O(O[2]),
	.IO(IO[2])
);
IOBUF iobuf3(
	.T(T[3]),
	.I(I[3]),
	.O(O[3]),
	.IO(IO[3])
);
IOBUF iobuf4(
	.T(T[4]),
	.I(I[4]),
	.O(O[4]),
	.IO(IO[4])
);
IOBUF iobuf5(
	.T(T[5]),
	.I(I[5]),
	.O(O[5]),
	.IO(IO[5])
);
IOBUF iobuf6(
	.T(T[6]),
	.I(I[6]),
	.O(O[6]),
	.IO(IO[6])
);
IOBUF iobuf7(
	.T(T[7]),
	.I(I[7]),
	.O(O[7]),
	.IO(IO[7])
);
IOBUF iobuf8(
	.T(T[8]),
	.I(I[8]),
	.O(O[8]),
	.IO(IO[8])
);
IOBUF iobuf9(
	.T(T[9]),
	.I(I[9]),
	.O(O[9]),
	.IO(IO[9])
);
IOBUF iobuf10(
	.T(T[10]),
	.I(I[10]),
	.O(O[10]),
	.IO(IO[10])
);
IOBUF iobuf11(
	.T(T[11]),
	.I(I[11]),
	.O(O[11]),
	.IO(IO[11])
);
IOBUF iobuf12(
	.T(T[12]),
	.I(I[12]),
	.O(O[12]),
	.IO(IO[12])
);
IOBUF iobuf13(
	.T(T[13]),
	.I(I[13]),
	.O(O[13]),
	.IO(IO[13])
);
IOBUF iobuf14(
	.T(T[14]),
	.I(I[14]),
	.O(O[14]),
	.IO(IO[14])
);
IOBUF iobuf15(
	.T(T[15]),
	.I(I[15]),
	.O(O[15]),
	.IO(IO[15])
);
IOBUF iobuf16(
	.T(T[16]),
	.I(I[16]),
	.O(O[16]),
	.IO(IO[16])
);
IOBUF iobuf17(
	.T(T[17]),
	.I(I[17]),
	.O(O[17]),
	.IO(IO[17])
);
IOBUF iobuf18(
	.T(T[18]),
	.I(I[18]),
	.O(O[18]),
	.IO(IO[18])
);
IOBUF iobuf19(
	.T(T[19]),
	.I(I[19]),
	.O(O[19]),
	.IO(IO[19])
);
IOBUF iobuf20(
	.T(T[20]),
	.I(I[20]),
	.O(O[20]),
	.IO(IO[20])
);
IOBUF iobuf21(
	.T(T[21]),
	.I(I[21]),
	.O(O[21]),
	.IO(IO[21])
);
IOBUF iobuf22(
	.T(T[22]),
	.I(I[22]),
	.O(O[22]),
	.IO(IO[22])
);
IOBUF iobuf23(
	.T(T[23]),
	.I(I[23]),
	.O(O[23]),
	.IO(IO[23])
);
IOBUF iobuf24(
	.T(T[24]),
	.I(I[24]),
	.O(O[24]),
	.IO(IO[24])
);
IOBUF iobuf25(
	.T(T[25]),
	.I(I[25]),
	.O(O[25]),
	.IO(IO[25])
);
IOBUF iobuf26(
	.T(T[26]),
	.I(I[26]),
	.O(O[26]),
	.IO(IO[26])
);
IOBUF iobuf27(
	.T(T[27]),
	.I(I[27]),
	.O(O[27]),
	.IO(IO[27])
);
IOBUF iobuf28(
	.T(T[28]),
	.I(I[28]),
	.O(O[28]),
	.IO(IO[28])
);
IOBUF iobuf29(
	.T(T[29]),
	.I(I[29]),
	.O(O[29]),
	.IO(IO[29])
);
IOBUF iobuf30(
	.T(T[30]),
	.I(I[30]),
	.O(O[30]),
	.IO(IO[30])
);
IOBUF iobuf31(
	.T(T[31]),
	.I(I[31]),
	.O(O[31]),
	.IO(IO[31])
);

endmodule
