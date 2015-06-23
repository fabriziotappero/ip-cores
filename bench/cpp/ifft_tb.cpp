//
// Filename: 	ifft_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the combined work of both fftmain.v and
//		ifftmain.v.  If they work together, in concert like they should,
//		then the operation of both in series should yield an identity.
//		This program attempts to check that identity with various
//		inputs given to it.
//
//		This file has a variety of dependencies, not the least of which
//		are verilator, ifftmain.v and fftmain.v (both produced by
//		fftgen), but also on the ifft_tb.v verilog test bench found
//		within this directory.
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
#include <assert.h>

#include "verilated.h"
#include "Vifft_tb.h"
#include "twoc.h"

#define	LGWIDTH	11
#define	IWIDTH	16
#define	MWIDTH	22
#define	OWIDTH	28

#define	FFTLEN	(1<<LGWIDTH)

class	IFFT_TB {
public:
	Vifft_tb	*m_tb;
	unsigned int	m_log[8*FFTLEN];
	long		m_data[2*FFTLEN];
	int		m_iaddr, m_oaddr, m_offset;
	FILE		*m_dumpfp;
	// double		*m_tb_buf;
	// int			m_ntest;
	bool		m_syncd;

	IFFT_TB(void) {
		m_tb = new Vifft_tb;
		m_iaddr = m_oaddr = 0;
		m_dumpfp = NULL;

		m_syncd = false;
		// m_ntest = 0;
	}

	void	tick(void) {
		m_tb->i_clk = 0;
		m_tb->eval();
		m_tb->i_clk = 1;
		m_tb->eval();
	}

	void	reset(void) {
		m_tb->i_ce  = 0;
		m_tb->i_rst = 1;
		tick();
		m_tb->i_rst = 0;
		tick();

		m_iaddr = m_oaddr = 0;
		m_syncd = false;
	}

	long	twos_complement(const long val, const int bits) {
		return sbits(val, bits);
	}

	void	checkresults(void) {
	/*
		double	*dp, *sp; // Complex array
		double	vout[FFTLEN*2];
		double	isq=0.0, osq = 0.0;
		long	*lp;

		// Fill up our test array from the log array
		printf("%3d : CHECK: %8d %5x\n", m_ntest, m_iaddr, m_iaddr);
		dp = m_tb_buf; lp = &m_log[(m_iaddr-FFTLEN*3)&((4*FFTLEN-1)&(-FFTLEN))];
		for(int i=0; i<FFTLEN; i++) {
			long	tv = *lp++;

			dp[0] = twos_complement(tv >> IWIDTH, IWIDTH);
			dp[1] = twos_complement(tv, IWIDTH);

			printf("IN[%4d = %4x] = %9.1f %9.1f\n",
				i+((m_iaddr-FFTLEN*3)&((4*FFTLEN-1)&(-FFTLEN))),
				i+((m_iaddr-FFTLEN*3)&((4*FFTLEN-1)&(-FFTLEN))),
				dp[0], dp[1]);
			dp += 2;
		}

		// Let's measure ... are we the zero vector?  If not, how close?
		dp = m_tb_buf;
		for(int i=0; i<FFTLEN; i++)
			isq += (*dp) * (*dp);

		fftw_execute(m_plan);

		// Let's load up the output we received into vout
		dp = vout;
		for(int i=0; i<FFTLEN; i++) {
			long	tv = m_data[i];

			printf("OUT[%4d = %4x] = ", i, i);
			printf("%16lx = ", tv);
			*dp = twos_complement(tv >> OWIDTH, OWIDTH);
			printf("%12.1f + ", *dp);
			osq += (*dp) * (*dp); dp++;
			*dp = twos_complement(tv, OWIDTH);
			printf("%12.1f j", *dp);
			osq += (*dp) * (*dp); dp++;
			printf(" <-> %12.1f %12.1f\n", m_tb_buf[2*i], m_fft_buf[2*i+1]);
		}


		// Let's figure out if there's a scale factor difference ...
		double	scale = 0.0, wt = 0.0;
		sp = m_tb_buf;  dp = vout;
		for(int i=0; i<FFTLEN*2; i++) {
			scale += (*sp) * (*dp++);
			wt += (*sp) * (*sp); sp++;
		} scale = scale / wt;

		if (wt == 0.0) scale = 1.0;

		double xisq = 0.0;
		sp = m_tb_buf;  dp = vout;
		for(int i=0; i<FFTLEN*2; i++) {
			double vl = (*sp++) * scale - (*dp++);
			xisq += vl * vl;
		}

		printf("%3d : SCALE = %12.6f, WT = %18.1f, ISQ = %15.1f, ",
			m_ntest, scale, wt, isq);
		printf("OSQ = %18.1f, ", osq);
		printf("XISQ = %18.1f\n", xisq);
		m_ntest++;
		*/
	}

	bool	test(int lft, int rht) {
		m_tb->i_ce    = 1;
		m_tb->i_rst   = 0;
		m_tb->i_left  = lft;
		m_tb->i_right = rht;

		m_log[(m_iaddr++)&(8*FFTLEN-1)] = lft;
		m_log[(m_iaddr++)&(8*FFTLEN-1)] = rht;

		tick();

		if ((m_tb->o_sync)&&(!m_syncd)) {
			m_offset = m_iaddr;
			m_oaddr = 0;
			m_syncd = true;
		}

		m_data[(m_oaddr++)&(FFTLEN-1)] = m_tb->o_left;
		m_data[(m_oaddr++)&(FFTLEN-1)] = m_tb->o_right;

		if ((m_syncd)&&((m_oaddr&(FFTLEN-1)) == 0)) {
			dumpwrite();
			// checkresults();
		}

		return (m_tb->o_sync);
	}

	bool	test(double lft_r, double lft_i, double rht_r, double rht_i) {
		int	ilft, irht, ilft_r, ilft_i, irht_r, irht_i;

		assert(2*IWIDTH <= 32);
		ilft_r = (int)(lft_r) & ((1<<IWIDTH)-1);
		ilft_i = (int)(lft_i) & ((1<<IWIDTH)-1);
		irht_r = (int)(rht_r) & ((1<<IWIDTH)-1);
		irht_i = (int)(rht_i) & ((1<<IWIDTH)-1);

		ilft = (ilft_r << IWIDTH) | ilft_i;
		irht = (irht_r << IWIDTH) | irht_i;

		return test(ilft, irht);
	}

	double	rdata(int addr) {
		long	ivl = m_data[addr & (FFTLEN-1)];

		ivl = twos_complement(ivl >> OWIDTH, OWIDTH);
		return (double)ivl;
	}

	double	idata(int addr) {
		long	ivl = m_data[addr & (FFTLEN-1)];

		ivl = twos_complement(ivl, OWIDTH);
		return (double)ivl;
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
	IFFT_TB *tb = new IFFT_TB;
	FILE	*fpout;

	fpout = fopen("ifft_tb.dbl", "w");
	if (NULL == fpout) {
		fprintf(stderr, "Cannot write output file, fft_tb.dbl\n");
		exit(-1);
	}

	tb->reset();
	tb->dump(fpout);

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
		tb->test((double)v,0.0,(double)v,0.0);
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
	for(int v=1; v<=32768; v<<=1) for(int k=0; k<FFTLEN/2; k++)
		tb->test(-(double)v,0.0,-(double)v,0.0);
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
		tb->test(0.0,(double)v,0.0,(double)v);
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
		tb->test(0.0,-(double)v,0.0,-(double)v);

	// 61. Now, how about the smallest alternating real signal
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(2.0,0.0,0.0,0.0); // Don't forget to expect a bias!
	// 62. Now, how about the smallest alternating imaginary signal
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,2.0,0.0,0.0); // Don't forget to expect a bias!
	// 63. Now, how about the smallest alternating real signal,2nd phase
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,0.0,2.0,0.0); // Don't forget to expect a bias!
	// 64.Now, how about the smallest alternating imaginary signal,2nd phase
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,0.0,0.0,2.0); // Don't forget to expect a bias!

	// 65.
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(32767.0,0.0,-32767.0,0.0);
	// 66.
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,-32767.0,0.0,32767.0);
	// 67.
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(-32768.0,-32768.0,-32768.0,-32768.0);
	// 68.
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,-32767.0,0.0,32767.0);
	// 69.
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(0.0,32767.0,0.0,-32767.0);
	// 70. 
	for(int k=0; k<FFTLEN/2; k++)
		tb->test(-32768.0,-32768.0,-32768.0,-32768.0);

	// 71. Now let's go for an impulse (SUCCESS)
	tb->test(16384.0, 0.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 72. And another one on the next clock (FAILS, ugly)
	//	Lot's of roundoff error, or some error in small bits
	tb->test(0.0, 0.0, 16384.0, 0.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 73. And an imaginary one on the second clock
	//	Much roundoff error, as in last test
	tb->test(0.0, 0.0, 0.0, 16384.0);
	for(int k=0; k<FFTLEN/2-1; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 74. Likewise the next clock
	//	Much roundoff error, as in last test
	tb->test(0.0,0.0,0.0,0.0);
	tb->test(16384.0, 0.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 75. And it's imaginary counterpart
	//	Much roundoff error, as in last test
	tb->test(0.0,0.0,0.0,0.0);
	tb->test(0.0, 16384.0, 0.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 76. Likewise the next clock
	//	Much roundoff error, as in last test
	tb->test(0.0,0.0,0.0,0.0);
	tb->test(0.0, 0.0, 16384.0, 0.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		tb->test(0.0,0.0,0.0,0.0);

	// 77. And it's imaginary counterpart
	//	Much roundoff error, as in last test
	tb->test(0.0,0.0,0.0,0.0);
	tb->test(0.0, 0.0, 0.0, 16384.0);
	for(int k=0; k<FFTLEN/2-2; k++)
		tb->test(0.0,0.0,0.0,0.0);


	// 78. Now let's try some exponentials
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN;
		cl = cos(W * (2*k  )) * 16383.0;
		sl = sin(W * (2*k  )) * 16383.0;
		cr = cos(W * (2*k+1)) * 16383.0;
		sr = sin(W * (2*k+1)) * 16383.0;
		tb->test(cl, sl, cr, sr);
	}

	// 79.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 5;
		cl = cos(W * (2*k  )) * 16383.0;
		sl = sin(W * (2*k  )) * 16383.0;
		cr = cos(W * (2*k+1)) * 16383.0;
		sr = sin(W * (2*k+1)) * 16383.0;
		tb->test(cl, sl, cr, sr);
	}

	// 80.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 8;
		cl = cos(W * (2*k  )) * 8190.0;
		sl = sin(W * (2*k  )) * 8190.0;
		cr = cos(W * (2*k+1)) * 8190.0;
		sr = sin(W * (2*k+1)) * 8190.0;
		tb->test(cl, sl, cr, sr);
	}

	// 81.
	for(int k=0; k<FFTLEN/2; k++) {
		double cl, cr, sl, sr, W;
		W = - 2.0 * M_PI / FFTLEN * 25;
		cl = cos(W * (2*k  )) * 4.0;
		sl = sin(W * (2*k  )) * 4.0;
		cr = cos(W * (2*k+1)) * 4.0;
		sr = sin(W * (2*k+1)) * 4.0;
		tb->test(cl, sl, cr, sr);
	}

	// 19.--24. And finally, let's clear out our results / buffer
	for(int k=0; k<(FFTLEN/2) * 5; k++)
		tb->test(0.0,0.0,0.0,0.0);

	fclose(fpout);
}


