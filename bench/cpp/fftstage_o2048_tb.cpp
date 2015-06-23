////////////////////////////////////////////////////////////////////////////
//
// Filename: 	fftstage_o2048_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the generic FFT stage which has been
//		instantiated by fftgen as fftstage_o2048.v.  Specifically,
//		This is the stage with the odd half of the coefficients.
//		This file may be run autonomously.  If so, the last line
//		output will either read "SUCCESS" on success, or some other
//		failure message otherwise.  Likewise the exit code will
//		also indicate success (exit(0)) or failure (anything else).
//
//		This file depends upon verilator to both compile, run, and
//		therefore test fftstage_o2048.v.  Also, you'll need to place
//		a copy of the cmem_o2048 hex file into the directory where
//		you run this test bench.
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
#include "Vfftstage_o2048.h"
#include "verilated.h"

#define	FFTBITS	11
#define	FFTLEN	(1<<FFTBITS)
#define	FFTSIZE	FFTLEN
#define	FFTMASK	(FFTLEN-1)
#define	LGSPAN	9
#define	SPANLEN	(1<<LGSPAN)
#define	SPANMASK	(SPANLEN-1)
#define	DBLSPANLEN	(1<<(LGSPAN+4))
#define	DBLSPANMASK	(DBLSPANLEN-1)
#define	IWIDTH	16
#define	CWIDTH	20
#define	OWIDTH	17
#define	BFLYSHIFT	0
#define	LGWIDTH	11
#define	LGSPAN	9
#define	ROUND	true

class	FFTSTAGE_TB {
public:
	Vfftstage_o2048	*m_ftstage;
	long		m_oaddr, m_iaddr;
	long		m_vals[SPANLEN], m_out[DBLSPANLEN];
	bool		m_syncd;
	int		m_offset;

	FFTSTAGE_TB(void) {
		m_ftstage = new Vfftstage_o2048;
		m_syncd = false;
		m_iaddr = m_oaddr = 0;
		m_offset = 0;
	}

	void	tick(void) {
		m_ftstage->i_clk = 0;
		m_ftstage->eval();
		m_ftstage->i_clk = 1;
		m_ftstage->eval();
	}

	void	reset(void) {
		m_ftstage->i_ce  = 0;
		m_ftstage->i_rst = 1;
		tick();

		// Let's give it several ticks with no sync
		m_ftstage->i_ce = 0;
		m_ftstage->i_rst = 0;
		for(int i=0; i<8192; i++) {
			m_ftstage->i_data = rand();
			m_ftstage->i_sync = 0;
			m_ftstage->i_ce = 1;

			tick();

			assert(m_ftstage->o_sync == 0);
		}

		m_iaddr = 0;
		m_oaddr = 0;
		m_offset = 0;
		m_syncd = false;
	}

	long	twos_complement(const long val, const int nbits) {
		long	r;
		r = val & ((1l<<nbits)-1);
		if (r & (1l<<(nbits-1)))
			r |= (-1l << nbits);
		return r;
	}

	void	butterfly(const long cv, const long lft, const long rht,
				long &o_lft, long &o_rht) {
		long	cv_r, cv_i;
		long	lft_r, lft_i, rht_r, rht_i;
		long	o_lft_r, o_lft_i, o_rht_r, o_rht_i;

		cv_r = twos_complement(cv>>CWIDTH, CWIDTH);
		cv_i = twos_complement(cv & ((1<<CWIDTH)-1), CWIDTH);

		lft_r = twos_complement(lft>>IWIDTH, IWIDTH);
		lft_i = twos_complement(lft & ((1<<IWIDTH)-1), IWIDTH);

		rht_r = twos_complement(rht>>IWIDTH, IWIDTH);
		rht_i = twos_complement(rht & ((1<<IWIDTH)-1), IWIDTH);

		o_lft_r = lft_r + rht_r;
		o_lft_i = lft_i + rht_i;

		o_lft_r &= (~(-1l << OWIDTH));
		o_lft_i &= (~(-1l << OWIDTH));

		// o_lft_r >>= 1;
		// o_lft_i >>= 1;
		o_lft = (o_lft_r << OWIDTH) | (o_lft_i);

		o_rht_r = (cv_r * (lft_r-rht_r)) - (cv_i * (lft_i-rht_i));
		o_rht_i = (cv_r * (lft_i-rht_i)) + (cv_i * (lft_r-rht_r));

		if (ROUND) {
			o_rht_r += (1<<(CWIDTH-3));
			o_rht_i += (1<<(CWIDTH-3));
		}

		o_rht_r >>= (CWIDTH-2);
		o_rht_i >>= (CWIDTH-2);

		o_rht_r &= (~(-1l << OWIDTH));
		o_rht_i &= (~(-1l << OWIDTH));
		o_rht = (o_rht_r << OWIDTH) | (o_rht_i);

		/*
		printf("%10lx %10lx %10lx -> %10lx %10lx\n",
			cv & ((1l<<(2*CWIDTH))-1l),
			lft & ((1l<<(2*IWIDTH))-1l),
			rht & ((1l<<(2*IWIDTH))-1l),
			o_lft & ((1l<<(2*OWIDTH))-1l),
			o_rht & ((1l<<(2*OWIDTH))-1l));
		*/
	}

	void	test(bool i_sync, long i_data) {
		long	cv;
		bool	bc;
		int	raddr;
		bool	failed = false;

		m_ftstage->i_rst  = 0;
		m_ftstage->i_ce   = 1;
		m_ftstage->i_sync = i_sync;
		i_data &= (~(-1l<<(2*IWIDTH)));
		m_ftstage->i_data = i_data;

		cv = m_ftstage->v__DOT__cmem[m_iaddr & SPANMASK];
		bc = m_iaddr & (1<<LGSPAN);
		if (!bc)
			m_vals[m_iaddr & (SPANMASK)] = i_data;
		else {
			int	waddr = m_iaddr ^ (1<<LGSPAN);
			waddr &= (DBLSPANMASK);
			if (m_iaddr & (1<<(LGSPAN+1)))
				waddr |= (1<<(LGSPAN));
			butterfly(cv, m_vals[m_iaddr & (SPANMASK)], i_data,
				m_out[(m_iaddr-SPANLEN) & (DBLSPANMASK)],
				m_out[m_iaddr & (DBLSPANMASK)]);
			/*
			printf("BFLY: C=%16lx M=%8lx I=%10lx -> %10lx %10lx\n",
				cv, m_vals[m_iaddr & (SPANMASK)], i_data,
				m_out[(m_iaddr-SPANLEN)&(DBLSPANMASK)],
				m_out[m_iaddr & (DBLSPANMASK)]);
			*/
		}

		tick();

		if ((!m_syncd)&&(m_ftstage->o_sync)) {
			m_syncd = true;
			// m_oaddr = m_iaddr - 0x219;
			// m_oaddr = m_iaddr - 0;
			m_offset = m_iaddr;
			m_oaddr = 0;

			printf("SYNC!!!!\n");
		}

		raddr = (m_iaddr-m_offset) & DBLSPANMASK;
		/*
		if (m_oaddr & (1<<(LGSPAN+1)))
			raddr |= (1<<LGSPAN);
		*/

		printf("%4ld, %4ld: %d %9lx -> %9lx %d ... %4x %15lx (%10lx)\n",
			m_iaddr, m_oaddr,
			i_sync, i_data & (~(-1l << (2*IWIDTH))),
			m_ftstage->o_data, m_ftstage->o_sync,
			m_ftstage->v__DOT__iaddr&(FFTMASK>>1),
			m_ftstage->v__DOT__cmem[m_ftstage->v__DOT__iaddr&(SPANMASK>>1)] & (~(-1l<<(2*CWIDTH))),
			m_out[raddr]);

		if ((m_syncd)&&(m_ftstage->o_sync != ((((m_iaddr-m_offset)&((1<<(LGSPAN+1))-1))==0)?1:0))) {
			fprintf(stderr, "Bad output sync (m_iaddr = %lx, m_offset = %x)\n", (m_iaddr-m_offset) & SPANMASK, m_offset);
			failed = true;
		}

		if (m_syncd) {
			if (m_out[raddr] != m_ftstage->o_data) {
				printf("Bad output data, ([%lx - %x = %x] %lx(exp) != %lx(sut))\n", m_iaddr, m_offset, raddr, m_out[raddr], m_ftstage->o_data);
				failed = true;
			}
		} else if (m_iaddr > 4096) {
			printf("NO OUTPUT SYNC!\n");
			failed = true;
		}
		m_iaddr++;
		m_oaddr++;

		if (failed)
			exit(-1);
	}
};
		


int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	FFTSTAGE_TB	*ftstage = new FFTSTAGE_TB;

	ftstage->reset();

	// Medium real (constant) value ... just for starters
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x00200000l);
	// Medium imaginary (constant) value ... just for starters
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x00000020l);
	// Medium sine wave, real
	for(int k=1; k<FFTSIZE; k+=2) {
		long vl;
		vl= (long)(cos(2.0 * M_PI * 1.0 / FFTSIZE * k)*(1l<<30) + 0.5);
		vl &= (-1l << 16); // Turn off the imaginary bit portion
		vl &= (~(-1l << (IWIDTH*2))); // Turn off unused high order bits
		ftstage->test((k==1), vl);
	}
	// Smallest real value
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x00080000l);
	// Smallest imaginary value
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x00000001l);
	// Largest real value
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x200000000l);
	// Largest negative imaginary value
	for(int k=1; k<FFTSIZE; k+=2)
		ftstage->test((k==1), 0x000010000l);
	// Let's try an impulse
	for(int k=0; k<FFTSIZE; k+=2)
		ftstage->test((k==0), (k==0)?0x020000000l:0l);
	// Now, let's clear out the result
	for(int k=0; k<FFTSIZE; k+=2)
		ftstage->test((k==0), 0x000000000l);
	for(int k=0; k<FFTSIZE; k+=2)
		ftstage->test((k==0), 0x000000000l);
	for(int k=0; k<FFTSIZE; k+=2)
		ftstage->test((k==0), 0x000000000l);
	for(int k=0; k<FFTSIZE; k+=2)
		ftstage->test((k==0), 0x000000000l);

	printf("SUCCESS! (Offset = %d)\n", ftstage->m_offset);
	delete	ftstage;

	exit(0);
}
