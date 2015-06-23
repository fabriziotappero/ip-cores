////////////////////////////////////////////////////////////////////////////
//
// Filename: 	mpy_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the shift and add shiftaddmpy.v subfile of
//		the double clocked FFT.  This file may be run autonomously. 
//		If so, the last line output will either read "SUCCESS" on
//		success, or some other failure message otherwise.
//
//		This file depends upon verilator to both compile, run, and
//		therefore test shiftaddmpy.v
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Tecnology, LLC
//
///////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
///////////////////////////////////////////////////////////////////////////
#include "Vshiftaddmpy.h"
#include "verilated.h"

class	MPYTB {
public:
	Vshiftaddmpy	*mpy;
	long	vals[32];
	int	m_addr;

	MPYTB(void) {
		mpy = new Vshiftaddmpy;

		for(int i=0; i<32; i++)
			vals[i] = 0;
		m_addr = 0;
	}
	~MPYTB(void) {
		delete mpy;
	}

	void	tick(void) {
		mpy->i_clk = 0;
		mpy->eval();
		mpy->i_clk = 1;
		mpy->eval();
	}

	void	reset(void) {
		mpy->i_clk = 0;
		mpy->i_ce = 1;
		mpy->i_a = 0;
		mpy->i_b = 0;

		for(int k=0; k<20; k++)
			tick();
	}

	bool	test(const int ia, const int ib) {
		bool	success;
		int	a, b;
		long	out;

		a = ia & 0x0ffff;
		b = ib & 0x0ffff;
		mpy->i_ce = 1;
		mpy->i_a = a & 0x0ffff;
		mpy->i_b = b & 0x0ffff;

		if (a&0x8000) a |= (-1 << 15);
		if (b&0x8000) b |= (-1 << 15);

		vals[m_addr&31] = (long)a * (long)b;

		tick();

		printf("k=%3d: A =%06x, B =%06x, ANS =%10lx, S=%3d,%3d,%3d,%3d, O = %8x\n",
			m_addr, a & 0x0ffffff, b & 0x0ffffff,
			vals[m_addr&31] & (~(-1l<<40)),
			mpy->v__DOT__sgn,
			mpy->v__DOT__r_s[0],
			mpy->v__DOT__r_s[1],
			mpy->v__DOT__r_s[2],
			mpy->o_r);

		out = mpy->o_r;
		if (out & (1<<31)) out |= (-1 << 31);

		m_addr++;

		success = (m_addr < 20)||(out == vals[(m_addr-18)&31]);
		if (!success) {
			fprintf(stderr, "WRONG ANSWER: %8lx != %8lx\n", vals[(m_addr-18)&0x01f], out);
			exit(-1);
		}
		
		return success;
	}
};

int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	MPYTB		*tb = new MPYTB;

	tb->reset();

	for(int k=0; k<15; k++) {
		int	a, b;

		a = (1<<k);
		b = 1;
		tb->test(a, b);
	}

	for(int k=0; k<15; k++) {
		int	a, b, out;

		a = (1<<15);
		b = (1<<k);
		tb->test(a, b);
	}

	for(int k=0; k<200; k++) {
		int	a, b, out;

		tb->test(rand(), rand());
	}

	delete	tb;

	printf("SUCCESS!\n");
	exit(0);
}
