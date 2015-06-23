//
// Filename: 	fft_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the main program, fftmain.v, of the double
//		clocked FFT.  This file may be run autonomously  (when
//		fully functional).  If so, the last line output will either
//		read "SUCCESS" on success, or some other failure message
//		otherwise.
//
//		This file depends upon verilator to both compile, run, and
//		therefore test fftmain.v
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
#include <math.h>
#include <fftw3.h>

#include "verilated.h"
#include "Vfftmain.h"
#include "twoc.h"

#define	LGWIDTH	11
#define	IWIDTH	16
// #define	OWIDTH	16
#define	OWIDTH	22

#define	NFTLOG	8
#define	FFTLEN	(1<<LGWIDTH)

unsigned long bitrev(const int nbits, const unsigned long vl) {
	unsigned long	r = 0;
	unsigned long	val = vl;

	for(int k=0; k<nbits; k++) {
		r<<= 1;
		r |= (val & 1);
		val >>= 1;
	}

	return r;
}

class	FFT_TB {
public:
	Vfftmain	*m_fft;
	long		m_data[FFTLEN], m_log[NFTLOG*FFTLEN];
	int		m_iaddr, m_oaddr, m_ntest, m_logbase;
	FILE		*m_dumpfp;
	fftw_plan	m_plan;
	double		*m_fft_buf;
	bool		m_syncd;

	FFT_TB(void) {
		m_fft = new Vfftmain;
		m_iaddr = m_oaddr = 0;
		m_dumpfp = NULL;

		m_fft_buf = (double *)fftw_malloc(sizeof(fftw_complex)*(FFTLEN));
		m_plan = fftw_plan_dft_1d(FFTLEN, (fftw_complex *)m_fft_buf,
				(fftw_complex *)m_fft_buf,
				FFTW_FORWARD, FFTW_MEASURE);
		m_syncd = false;
		m_ntest = 0;
	}

	void	tick(void) {
		m_fft->i_clk = 0;
		m_fft->eval();
		m_fft->i_clk = 1;
		m_fft->eval();

		/*
		int nrpt = (rand()&0x01f) + 1;
		m_fft->i_ce = 0;
		for(int i=0; i<nrpt; i++) {
			m_fft->i_clk = 0;
			m_fft->eval();
			m_fft->i_clk = 1;
			m_fft->eval();
		}
		*/
	}

	void	reset(void) {
		m_fft->i_ce  = 0;
		m_fft->i_rst = 1;
		tick();
		m_fft->i_rst = 0;
		tick();

		m_iaddr = m_oaddr = m_logbase = 0;
		m_syncd = false;
	}

	long	twos_complement(const long val, const int bits) {
		return sbits(val, bits);
	}

	void	checkresults(void) {
		double	*dp, *sp; // Complex array
		double	vout[FFTLEN*2];
		double	isq=0.0, osq = 0.0;
		long	*lp;

		// Fill up our test array from the log array
		printf("%3d : CHECK: %8d %5x m_log[-%x=%x]\n", m_ntest, m_iaddr, m_iaddr,
			m_logbase, (m_iaddr-m_logbase)&((NFTLOG*FFTLEN-1)&(-FFTLEN)));
		dp = m_fft_buf; lp = &m_log[(m_iaddr-m_logbase)&((NFTLOG*FFTLEN-1)&(-FFTLEN))];
		for(int i=0; i<FFTLEN; i++) {
			long	tv = *lp++;

			dp[0] = sbits(tv >> IWIDTH, IWIDTH);
			dp[1] = sbits(tv, IWIDTH);

			// printf("IN[%4d = %4x] = %9.1f %9.1f\n",
				// i+((m_iaddr-FFTLEN*3)&((4*FFTLEN-1)&(-FFTLEN))),
				// i+((m_iaddr-FFTLEN*3)&((4*FFTLEN-1)&(-FFTLEN))),
				// dp[0], dp[1]);
			dp += 2;
		}

		// Let's measure ... are we the zero vector?  If not, how close?
		dp = m_fft_buf;
		for(int i=0; i<FFTLEN*2; i++) {
			isq += (*dp) * (*dp); dp++;
		}

		fftw_execute(m_plan);

		// Let's load up the output we received into vout
		dp = vout;
		for(int i=0; i<FFTLEN; i++) {
			*dp = rdata(i);
			osq += (*dp) * (*dp); dp++;
			*dp = idata(i);
			osq += (*dp) * (*dp); dp++;
		}


		// Let's figure out if there's a scale factor difference ...
		double	scale = 0.0, wt = 0.0;
		sp = m_fft_buf;  dp = vout;
		for(int i=0; i<FFTLEN*2; i++) {
			scale += (*sp) * (*dp++);
			wt += (*sp) * (*sp); sp++;
		} scale = scale / wt;

		if (wt == 0.0) scale = 1.0;

		double xisq = 0.0;
		sp = m_fft_buf;  dp = vout;

		if ((true)&&(m_dumpfp)) {
			double	tmp[FFTLEN*2], nscl;

			if (fabs(scale) < 1e-4)
				nscl = 1.0;
			else
				nscl = scale;
			for(int i=0; i<FFTLEN*2; i++)
				tmp[i] = m_fft_buf[i] * nscl;
			fwrite(tmp, sizeof(double), FFTLEN*2, m_dumpfp);
		}

		for(int i=0; i<FFTLEN*2; i++) {
			double vl = (*sp++) * scale - (*dp++);
			xisq += vl * vl;
		}

		printf("%3d : SCALE = %12.6f, WT = %18.1f, ISQ = %15.1f, ",
			m_ntest, scale, wt, isq);
		printf("OSQ = %18.1f, ", osq);
		printf("XISQ = %18.1f\n", xisq);
		if (xisq > 1.4 * FFTLEN/2) {
			printf("TEST FAIL!!  Result is out of bounds from ");
			printf("expected result with FFTW3.\n");
			// exit(-2);
		}
		m_ntest++;
	}

	bool	test(int lft, int rht) {
		m_fft->i_ce    = 1;
		m_fft->i_rst   = 0;
		m_fft->i_left  = lft;
		m_fft->i_right = rht;

		m_log[(m_iaddr++)&(NFTLOG*FFTLEN-1)] = (long)lft;
		m_log[(m_iaddr++)&(NFTLOG*FFTLEN-1)] = (long)rht;

		tick();

		if (m_fft->o_sync) {
			if (!m_syncd) {
				m_logbase = m_iaddr;
			} // else printf("RESYNC AT %lx\n", m_fft->m_tickcount);
			m_oaddr &= (-1<<LGWIDTH);
			m_syncd = true;
		} else m_oaddr += 2;

		printf("%8x,%5d: %08x,%08x -> %011lx,%011lx",
			m_iaddr, m_oaddr,
			lft, rht, m_fft->o_left, m_fft->o_right);
		printf( // "\t%011lx,%011lx"
			"\t%3x"
			"\t%011lx,%011lx"		// w_e128, w_o128
			// "\t%011lx,%011lx"		// w_e4, w_o4
			// "\t%06x,%06x"
			// "\t%06x,%06x"
			// "\t%011lx,%06x,%06x"
			"\t%011lx,%06x,%06x"		// ob_a, ob_b_r, ob_b_i
			"\t%06x,%06x,%06x,%06x",	// o_out_xx
			// "\t%011lx,%011lx"
			m_fft->v__DOT__revstage__DOT__iaddr,
			m_fft->v__DOT__w_e128,
			m_fft->v__DOT__w_o128,
			// m_fft->v__DOT__w_e4,
			// m_fft->v__DOT__w_o4,
			// m_fft->v__DOT__stage_e512__DOT__ib_a,
			// m_fft->v__DOT__stage_e512__DOT__ib_b,
			// m_fft->v__DOT__stage_e256__DOT__ib_a,
			// m_fft->v__DOT__stage_e256__DOT__ib_b,
			// m_fft->v__DOT__stage_e128__DOT__ib_a,
			// m_fft->v__DOT__stage_e128__DOT__ib_b,
			// m_fft->v__DOT__stage_e64__DOT__ib_a,
			// m_fft->v__DOT__stage_e64__DOT__ib_b,
			// m_fft->v__DOT__stage_e32__DOT__ib_a,
			// m_fft->v__DOT__stage_e32__DOT__ib_b,
			// m_fft->v__DOT__stage_e16__DOT__ib_a,
			// m_fft->v__DOT__stage_e16__DOT__ib_b,
			// m_fft->v__DOT__stage_e8__DOT__ib_a,
			// m_fft->v__DOT__stage_e8__DOT__ib_b,
			// m_fft->v__DOT__stage_o8__DOT__ib_a,
			// m_fft->v__DOT__stage_o8__DOT__ib_b,
			// m_fft->v__DOT__stage_e4__DOT__sum_r,
			// m_fft->v__DOT__stage_e4__DOT__sum_i,
			// m_fft->v__DOT__stage_o4__DOT__sum_r,
			// m_fft->v__DOT__stage_o4__DOT__sum_i,
			// m_fft->v__DOT__stage_e4__DOT__ob_a,
			// m_fft->v__DOT__stage_e4__DOT__ob_b_r,
			// m_fft->v__DOT__stage_e4__DOT__ob_b_i,
			m_fft->v__DOT__stage_o4__DOT__ob_a,
			m_fft->v__DOT__stage_o4__DOT__ob_b_r,
			m_fft->v__DOT__stage_o4__DOT__ob_b_i,
			m_fft->v__DOT__stage_2__DOT__o_out_0r,
			m_fft->v__DOT__stage_2__DOT__o_out_0i,
			m_fft->v__DOT__stage_2__DOT__o_out_1r,
			m_fft->v__DOT__stage_2__DOT__o_out_1i);
/*
		printf(" DBG:%c%c:%08x [%6d,%6d]",
				(m_fft->o_dbg&(1l<<33))?'T':' ',
				(m_fft->o_dbg&(1l<<32))?'C':' ',
				(unsigned)(m_fft->o_dbg&((-1l<<32)-1)),
				((int)(m_fft->o_dbg))>>16,
				(((unsigned)(m_fft->o_dbg&0x0ffff))
					|((m_fft->o_dbg&0x08000)?(-1<<16):0)));
*/
		printf(" %s%s%s%s%s%s%s %s%s\n",
			// m_fft->v__DOT__br_o_left,
			// m_fft->v__DOT__br_o_right,
			// (m_fft->v__DOT__w_s2048)?"S":"-",
			// (m_fft->v__DOT__w_s1024)?"S":"-",
			// (m_fft->v__DOT__w_s512)?"S":"-",
			// (m_fft->v__DOT__w_s256)?"S":"-",
			(m_fft->v__DOT__w_s128)?"S":"-",
			(m_fft->v__DOT__w_s64)?"S":"-",
			(m_fft->v__DOT__w_s32)?"S":"-",
			(m_fft->v__DOT__w_s16)?"S":"-",
			(m_fft->v__DOT__w_s8)?"S":"-",
			(m_fft->v__DOT__w_s4)?"S":"-",
			(m_fft->v__DOT__br_sync)?"S":((m_fft->v__DOT__r_br_started)?".":"x"),
			(m_fft->o_sync)?"\t(SYNC!)":"",
			(m_fft->o_left | m_fft->o_right)?"  (NZ)":"");

		m_data[(m_oaddr  )&(FFTLEN-1)] = m_fft->o_left;
		m_data[(m_oaddr+1)&(FFTLEN-1)] = m_fft->o_right;

		if ((m_syncd)&&((m_oaddr&(FFTLEN-1)) == FFTLEN-2)) {
			dumpwrite();
			checkresults();
		}

		return (m_fft->o_sync);
	}

	bool	test(double lft_r, double lft_i, double rht_r, double rht_i) {
		int	ilft, irht, ilft_r, ilft_i, irht_r, irht_i;

		ilft_r = (int)(lft_r) & ((1<<IWIDTH)-1);
		ilft_i = (int)(lft_i) & ((1<<IWIDTH)-1);
		irht_r = (int)(rht_r) & ((1<<IWIDTH)-1);
		irht_i = (int)(rht_i) & ((1<<IWIDTH)-1);

		ilft = (ilft_r << IWIDTH) | ilft_i;
		irht = (irht_r << IWIDTH) | irht_i;

		return test(ilft, irht);
	}

	double	rdata(int addr) {
		int	index = addr & (FFTLEN-1);

		// index = bitrev(LGWIDTH, index);
		return (double)sbits(m_data[index]>>OWIDTH, OWIDTH);
	}

	double	idata(int addr) {
		int	index = addr & (FFTLEN-1);

		// index = bitrev(LGWIDTH, index);
		return (double)sbits(m_data[index], OWIDTH);
	}

	void	dump(FILE *fp) {
		m_dumpfp = fp;
	}

	void	dumpwrite(void) {
		if (!m_dumpfp)
			return;

		double	*buf;

		buf = new double[FFTLEN * 2];
		for(int i=0; i<FFTLEN; i++) {
			buf[i*2] = rdata(i);
			buf[i*2+1] = idata(i);
		}

		fwrite(buf, sizeof(double), FFTLEN*2, m_dumpfp);
		delete[] buf;
	}
};


int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	FFT_TB *fft = new FFT_TB;
	FILE	*fpout;

	fpout = fopen("fft_tb.dbl", "w");
	if (NULL == fpout) {
		fprintf(stderr, "Cannot write output file, fft_tb.dbl\n");
		exit(-1);
	}

	fft->reset();
	fft->dump(fpout);

	// 1.
	fft->test(0.0, 0.0, 32767.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 2. 
	fft->test(32767.0, 0.0, 32767.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 3. 
	fft->test(0.0,0.0,0.0,0.0);
	fft->test(32767.0, 0.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 4.
	for(int k=0; k<8; k++)
		fft->test(32767.0, 0.0, 32767.0, 0.0);
	for(int k=8; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 5.
	if (FFTLEN/2 >= 16) {
		for(int k=0; k<16; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=16; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	// 6.
	if (FFTLEN/2 >= 32) {
		for(int k=0; k<32; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=32; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	// 7.
	if (FFTLEN/2 >= 64) {
		for(int k=0; k<64; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=64; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	if (FFTLEN/2 >= 128) {
		for(int k=0; k<128; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=128; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	if (FFTLEN/2 >= 256) {
		for(int k=0; k<256; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=256; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	if (FFTLEN/2 >= 512) {
		for(int k=0; k<256+128; k++)
			fft->test(32767.0, 0.0, 32767.0, 0.0);
		for(int k=256+128; k<FFTLEN/2; k++)
			fft->test(0.0,0.0,0.0,0.0);
	}

	/*
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,0.0);
	*/

#ifndef	NO_JUNK
	// 7.

	//     1 -> 0x0001 
	//     2 -> 0x0002 
	//     4 -> 0x0004 
	//     8 -> 0x0008 
	//    16 -> 0x0010 
	//    32 -> 0x0020 
	//    64 -> 0x0040 
	//   128 -> 0x0080 
	//   256 -> 0x0100 
	//   512 -> 0x0200 
	//  1024 -> 0x0400 
	//  2048 -> 0x0800
	//  4096 -> 0x1000
	//  8192 -> 0x2000
	// 16384 -> 0x4000
	for(int v=1; v<32768; v<<=1) for(int k=0; k<FFTLEN/2; k++)
		fft->test((double)v,0.0,(double)v,0.0);
	//     1 -> 0xffff 	
	//     2 -> 0xfffe
	//     4 -> 0xfffc
	//     8 -> 0xfff8
	//    16 -> 0xfff0
	//    32 -> 0xffe0
	//    64 -> 0xffc0
	//   128 -> 0xff80
	//   256 -> 0xff00
	//   512 -> 0xfe00
	//  1024 -> 0xfc00
	//  2048 -> 0xf800
	//  4096 -> 0xf000
	//  8192 -> 0xe000
	// 16384 -> 0xc000
	// 32768 -> 0x8000
	fft->test(0.0,0.0,16384.0,0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	for(int v=1; v<=32768; v<<=1) for(int k=0; k<FFTLEN/2; k++)
		fft->test(-(double)v,0.0,-(double)v,0.0);
	//     1 -> 0x000040 	CORRECT!!
	//     2 -> 0x000080 
	//     4 -> 0x000100 
	//     8 -> 0x000200
	//    16 -> 0x000400
	//    32 -> 0x000800
	//    64 -> 0x001000
	//   128 -> 0x002000
	//   256 -> 0x004000
	//   512 -> 0x008000
	//  1024 -> 0x010000
	//  2048 -> 0x020000
	//  4096 -> 0x040000
	//  8192 -> 0x080000
	// 16384 -> 0x100000
	for(int v=1; v<32768; v<<=1) for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,(double)v,0.0,(double)v);
	//     1 -> 0x3fffc0
	//     2 -> 0x3fff80
	//     4 -> 0x3fff00
	//     8 -> 0x3ffe00
	//    16 -> 0x3ffc00
	//    32 -> 0x3ff800
	//    64 -> 0x3ff000
	//   128 -> 0x3fe000
	//   256 -> 0x3fc000
	//   512 -> 0x3f8000
	//  1024 -> 0x3f0000
	//  2048 -> 0x3e0000
	//  4096 -> 0x3c0000
	//  8192 -> 0x380000
	// 16384 -> 0x300000
	for(int v=1; v<32768; v<<=1) for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,-(double)v,0.0,-(double)v);

	// 61. Now, how about the smallest alternating real signal
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(2.0,0.0,0.0,0.0); // Don't forget to expect a bias!
	// 62. Now, how about the smallest alternating imaginary signal
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,2.0,0.0,0.0); // Don't forget to expect a bias!
	// 63. Now, how about the smallest alternating real signal,2nd phase
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,2.0,0.0); // Don't forget to expect a bias!
	// 64.Now, how about the smallest alternating imaginary signal,2nd phase
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,0.0,0.0,2.0); // Don't forget to expect a bias!

	// 65.
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(32767.0,0.0,-32767.0,0.0);
	// 66.
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,-32767.0,0.0,32767.0);
	// 67.
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(-32768.0,-32768.0,-32768.0,-32768.0);
	// 68.
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,-32767.0,0.0,32767.0);
	// 69.
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(0.0,32767.0,0.0,-32767.0);
	// 70. 
	for(int k=0; k<FFTLEN/2; k++)
		fft->test(-32768.0,-32768.0,-32768.0,-32768.0);

	// 71. Now let's go for an impulse (SUCCESS)
	fft->test(16384.0, 0.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 72. And another one on the next clock (FAILS, ugly)
	fft->test(0.0, 0.0, 16384.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 72. And another one on the next clock (FAILS, ugly)
	fft->test(0.0, 0.0,  8192.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 72. And another one on the next clock (FAILS, ugly)
	fft->test(0.0, 0.0,   512.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 73. And an imaginary one on the second clock
	fft->test(0.0, 0.0, 0.0, 16384.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 74. Likewise the next clock
	fft->test(0.0,0.0,0.0,0.0);
	fft->test(16384.0, 0.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 75. And it's imaginary counterpart
	fft->test(0.0,0.0,0.0,0.0);
	fft->test(0.0, 16384.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 76. Likewise the next clock
	fft->test(0.0,0.0,0.0,0.0);
	fft->test(0.0, 0.0, 16384.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		fft->test(0.0,0.0,0.0,0.0);

	// 77. And it's imaginary counterpart
	fft->test(0.0,0.0,0.0,0.0);
	fft->test(0.0, 0.0, 0.0, 16384.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		fft->test(0.0,0.0,0.0,0.0);


	// 78. Now let's try some exponentials
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN;
		cl = cos(W * (2*k  )) * 16383.0;
		sl = sin(W * (2*k  )) * 16383.0;
		cr = cos(W * (2*k+1)) * 16383.0;
		sr = sin(W * (2*k+1)) * 16383.0;
		fft->test(cl, sl, cr, sr);
	}

	// 72.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 5;
		cl = cos(W * (2*k  )) * 16383.0;
		sl = sin(W * (2*k  )) * 16383.0;
		cr = cos(W * (2*k+1)) * 16383.0;
		sr = sin(W * (2*k+1)) * 16383.0;
		fft->test(cl, sl, cr, sr);
	}

	// 73.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 8;
		cl = cos(W * (2*k  )) * 8190.0;
		sl = sin(W * (2*k  )) * 8190.0;
		cr = cos(W * (2*k+1)) * 8190.0;
		sr = sin(W * (2*k+1)) * 8190.0;
		fft->test(cl, sl, cr, sr);
	}

	// 74.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 25;
		cl = cos(W * (2*k  )) * 4.0;
		sl = sin(W * (2*k  )) * 4.0;
		cr = cos(W * (2*k+1)) * 4.0;
		sr = sin(W * (2*k+1)) * 4.0;
		fft->test(cl, sl, cr, sr);
	}
#endif
	// 19.--24. And finally, let's clear out our results / buffer
	for(int k=0; k<(FFTLEN/2) * 5; k++)
		fft->test(0.0,0.0,0.0,0.0);



	fclose(fpout);

	printf("SUCCESS!!\n");
	exit(0);
}


