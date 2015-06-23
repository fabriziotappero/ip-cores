////////////////////////////////////////////////////////////////////////////
//
// Filename: 	qtrstage_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the qtrstage.v subfile of the double
//		clocked FFT.  This file may be run autonomously.  If so,
//		the last line output will either read "SUCCESS" on success,
//		or some other failure message otherwise.
//
//		This file depends upon verilator to both compile, run, and
//		therefore test qtrstage.v
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

#include "Vqtrstage.h"
#include "verilated.h"
#include "twoc.h"

#define	IWIDTH	16
#define	OWIDTH	(IWIDTH+1)
#define	LGWIDTH	8

#define	ASIZ	32
#define	AMSK	(ASIZ-1)

class	QTRTEST_TB {
public:
	Vqtrstage	*m_qstage;
	unsigned long	m_data[ASIZ];
	int		m_addr, m_offset;
	bool		m_syncd;

	QTRTEST_TB(void) {
		m_qstage = new Vqtrstage;
		m_addr = 0; m_offset = 6; m_syncd = false;
	}

	void	tick(void) {
		m_qstage->i_clk = 0;
		m_qstage->eval();
		m_qstage->i_clk = 1;
		m_qstage->eval();

		m_qstage->i_sync = 0;
	}

	void	reset(void) {
		m_qstage->i_ce  = 0;
		m_qstage->i_rst = 1;
		tick();
		m_qstage->i_ce  = 0;
		m_qstage->i_rst = 0;
		tick();

		m_addr = 0; m_offset = 6; m_syncd = false;
	}

	void	check_results(void) {
		int	ir0, ii0, ir1, ii1, ir2, ii2;
		int	sumr, sumi, difr, difi, or0, oi0;
		bool	fail = false;

		if ((!m_syncd)&&(m_qstage->o_sync)) {
			m_syncd = true;
			m_offset = m_addr;
		}

		if (!m_syncd)
			return;

		ir0 = sbits(m_data[(m_addr-m_offset-1)&AMSK]>>IWIDTH, IWIDTH);
		ii0 = sbits(m_data[(m_addr-m_offset-1)&AMSK], IWIDTH);
		ir1 = sbits(m_data[(m_addr-m_offset  )&AMSK]>>IWIDTH, IWIDTH);
		ii1 = sbits(m_data[(m_addr-m_offset  )&AMSK], IWIDTH);
		ir2 = sbits(m_data[(m_addr-m_offset+1)&AMSK]>>IWIDTH, IWIDTH);
		ii2 = sbits(m_data[(m_addr-m_offset+1)&AMSK], IWIDTH);

		sumr = ir1 + ir2;
		sumi = ii1 + ii2;
		difr = ir0 - ir1;
		difi = ii0 - ii1;

		or0 = sbits(m_qstage->o_data >> OWIDTH, OWIDTH);
		oi0 = sbits(m_qstage->o_data, OWIDTH);

		if (0==((m_addr-m_offset)&1)) {
			if (or0 != sumr)	{
				printf("FAIL 1: or0 != sumr (%x(exp) != %x(sut))\n", sumr, or0); fail = true;}
			if (oi0 != sumi)	{
				printf("FAIL 2: oi0 != sumi (%x(exp) != %x(sut))\n", sumi, oi0); fail = true;}
		} else if (1==((m_addr-m_offset)&1)) {
			if (or0 != difr)	{
				printf("FAIL 3: or0 != difr (%x(exp) != %x(sut))\n", difr, or0); fail = true;}
			if (oi0 != difi)	{
				printf("FAIL 4: oi0 != difi (%x(exp) != %x(sut))\n", difi, oi0); fail = true;}
		}

		if (m_qstage->o_sync != ((((m_addr-m_offset)&127) == 0)?1:0)) {
			printf("BAD O-SYNC, m_addr = %d, m_offset = %d\n", m_addr, m_offset); fail = true;
		}

		if (fail)
			exit(-1);
	}

	void	sync(void) {
		m_qstage->i_sync = 1;
		m_addr = 0;
	}

	void	test(unsigned int data) {
		int	isync = m_qstage->i_sync;
		m_qstage->i_ce = 1;
		m_qstage->i_data = data;
		// m_qstage->i_sync = (((m_addr&127)==2)?1:0);
		m_data[ (m_addr++)&AMSK] = data;
		tick();

		printf("k=%4d: ISYNC=%d, IN = %08x, OUT =%09lx, SYNC=%d\t%5x,%5x,%5x,%5x\t%x %4x %8x %d\n",
			(m_addr-m_offset), isync, m_qstage->i_data,
			m_qstage->o_data, m_qstage->o_sync,
			m_qstage->v__DOT__sum_r,
			m_qstage->v__DOT__sum_i,
			m_qstage->v__DOT__diff_r,
			m_qstage->v__DOT__diff_i,
			m_qstage->v__DOT__pipeline,
			m_qstage->v__DOT__iaddr,
			m_qstage->v__DOT__imem,
			m_qstage->v__DOT__wait_for_sync);

		check_results();
	}

	void	test(int ir0, int ii0) {
		unsigned int	data;

		data = (((ir0&((1<<IWIDTH)-1)) << IWIDTH) | (ii0 & ((1<<IWIDTH)-1)));
		// printf("%d,%d -> %8x\n", ir0, ii0, data);
		test(data);
	}

	void	random_test(void) {
		int	ir0, ii0;

		// Let's pick some random values
		ir0 = rand(); if (ir0&4) ir0 = -ir0;
		ii0 = rand(); if (ii0&2) ii0 = -ii0;
		test(ir0, ii0);
	}
};

int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	QTRTEST_TB	*tb = new QTRTEST_TB;
	int16_t		ir0, ii0, ir1, ii1, ir2, ii2;
	int32_t		sumr, sumi, difr, difi;

	tb->reset();

	tb->test( 16, 0);
	tb->test( 16, 0);
	tb->sync();
	tb->test(  0, 16);
	tb->test(  0, 16);
	tb->test( 16,  0);
	tb->test(-16,  0);
	tb->test(  0, 16);
	tb->test(  0,-16);

	for(int k=0; k<1060; k++) {
		tb->random_test();
	}

	delete	tb;

	printf("SUCCESS!\n");
	exit(0);
}





