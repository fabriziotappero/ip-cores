////////////////////////////////////////////////////////////////////////////
//
// Filename: 	dblstage_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the dblstage.v subfile of the double
//		clocked FFT.  This file may be run autonomously.  If so,
//		the last line output will either read "SUCCESS" on success,
//		or some other failure message otherwise.
//
//		This file depends upon verilator to both compile, run, and
//		therefore test dblstage.v
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
#include <stdio.h>
#include <stdint.h>

#include "Vdblstage.h"
#include "verilated.h"
#include "twoc.h"

#define	IWIDTH	16
#define	OWIDTH	(IWIDTH+1)
#define	SHIFT	0
#define	ROUND	1

#define	ASIZ	16
#define	AMSK	(ASIZ-1)

class	DBLSTAGE_TB {
public:
	Vdblstage	*m_dstage;
	unsigned long	m_left[ASIZ], m_right[ASIZ];
	bool		m_syncd;
	int		m_addr, m_offset;

	DBLSTAGE_TB(void) {
		m_dstage = new Vdblstage;
		m_syncd = false; m_addr = 0, m_offset = 0;
	}

	void	tick(void) {
		m_dstage->i_clk = 0;
		m_dstage->eval();
		m_dstage->i_clk = 1;
		m_dstage->eval();
		m_dstage->i_rst  = 0;
		m_dstage->i_sync = 0;
	}

	void	reset(void) {
		m_dstage->i_rst = 1;
		tick();

		m_syncd = false; m_addr = 0, m_offset = 0;
	}

	void	check_results(void) {
		bool	failed = false;
		int	ir0, ir1, ii0, ii1, or0, oi0, or1, oi1;

		if ((!m_syncd)&&(m_dstage->o_sync)) {
			m_syncd = true;
			m_offset = m_addr;
		}

		ir0 = sbits(m_left[ (m_addr-m_offset)&AMSK]>>IWIDTH, IWIDTH);
		ir1 = sbits(m_right[(m_addr-m_offset)&AMSK]>>IWIDTH, IWIDTH);
		ii0 = sbits(m_left[ (m_addr-m_offset)&AMSK], IWIDTH);
		ii1 = sbits(m_right[(m_addr-m_offset)&AMSK], IWIDTH);


		or0 = sbits(m_dstage->o_left  >> OWIDTH, OWIDTH);
		oi0 = sbits(m_dstage->o_left           , OWIDTH);
		or1 = sbits(m_dstage->o_right >> OWIDTH, OWIDTH);
		oi1 = sbits(m_dstage->o_right          , OWIDTH);


		// Sign extensions
		printf("k=%3d: IN = %08x:%08x, OUT =%09lx:%09lx, S=%d\n",
			m_addr, m_dstage->i_left, m_dstage->i_right,
			m_dstage->o_left, m_dstage->o_right,
			m_dstage->o_sync);

		/*
		printf("\tI0 = { %x : %x }, I1 = { %x : %x }, O0 = { %x : %x }, O1 = { %x : %x }\n",
			ir0, ii0, ir1, ii1, or0, oi0, or1, oi1);
		*/

		if (m_syncd) {
			if (or0 != (ir0 + ir1))	{
				printf("FAIL 1: or0 != (ir0+ir1), or %x(exp) != %x(sut)\n", (ir0+ir1), or0);
				failed=true;}
			if (oi0 != (ii0 + ii1))	{printf("FAIL 2\n"); failed=true;}
			if (or1 != (ir0 - ir1))	{printf("FAIL 3\n"); failed=true;}
			if (oi1 != (ii0 - ii1))	{printf("FAIL 4\n"); failed=true;}
		} else if (m_addr > 20) {
			printf("NO SYNC!\n");
			failed = true;
		}

		if (failed)
			exit(-2);
	}

	void	sync(void) {
		m_dstage->i_sync = 1;
	}

	void	test(unsigned long left, unsigned long right) {
		m_dstage->i_ce    = 1;
		m_dstage->i_left  = left;
		m_dstage->i_right = right;

		if (m_dstage->i_sync)
			m_addr = 0;
		m_left[ m_addr&AMSK] = m_dstage->i_left;
		m_right[m_addr&AMSK] = m_dstage->i_right;
		m_addr++;

		tick();

		check_results();
	}

	void	test(int ir0, int ii0, int ir1, int ii1) {
		unsigned long	left, right, mask = (1<<IWIDTH)-1;

		left  = ((ir0&mask) << IWIDTH) | (ii0 & mask);
		right = ((ir1&mask) << IWIDTH) | (ii1 & mask);
		test(left, right);
	}
};

int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	DBLSTAGE_TB	*tb = new DBLSTAGE_TB;

	tb->reset();

	tb->test(16,16,0,0);
	tb->test(0,0,16,16);
	tb->sync();
	tb->test(16,-16,0,0);
	tb->test(0,0,16,-16);
	tb->test(16,16,0,0);
	tb->test(0,0,16,16);

	for(int k=0; k<64; k++) {
		int16_t	ir0, ii0, ir1, ii1;

		// Let's pick some random values, ...
		ir0 = rand(); if (ir0&4) ir0 = -ir0;
		ii0 = rand(); if (ii0&2) ii0 = -ii0;
		ir1 = rand(); if (ir1&1) ir1 = -ir1;
		ii1 = rand(); if (ii1&8) ii1 = -ii1;

		tb->test(ir0, ii0, ir1, ii1);

	}

	delete	tb;

	printf("SUCCESS!\n");
	exit(0);
}






