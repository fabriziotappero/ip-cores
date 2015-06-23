////////////////////////////////////////////////////////////////////////////
//
// Filename: 	dblrev_tb.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	A test-bench for the dblreverse.v subfile of the double
//		clocked FFT.  This file may be run autonomously.  If so,
//		the last line output will either read "SUCCESS" on success,
//		or some other failure message otherwise.
//
//		This file depends upon verilator to both compile, run, and
//		therefore test dblreverse.v
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
#include "Vdblreverse.h"
#include "verilated.h"

#define	FFTBITS	5
#define	FFTSIZE	(1<<(FFTBITS))
#define	FFTMASK	(FFTSIZE-1)
#define	DATALEN	(1<<(FFTBITS+1))
#define	DATAMSK	(DATALEN-1)
#define	PAGEMSK	(FFTSIZE)

void	tick(Vdblreverse *dblrev) {
	dblrev->i_clk = 0;
	dblrev->eval();
	dblrev->i_clk = 1;
	dblrev->eval();

	dblrev->i_ce = 0;
}

void	reset(Vdblreverse *dblrev) {
	dblrev->i_ce  = 0;
	dblrev->i_rst = 1;
	tick(dblrev);
	dblrev->i_ce  = 0;
	dblrev->i_rst = 0;
	tick(dblrev);
}

unsigned long	bitrev(const int nbits, const unsigned long vl) {
	unsigned long	r = 0;
	unsigned long	val = vl;

	for(int k=0; k<nbits; k++) {
		r <<= 1;
		r |= (val & 1);
		val >>= 1;
	}

	return r;
}

int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	Vdblreverse	*dblrev = new Vdblreverse;
	int syncd = 0;
	unsigned long	datastore[DATALEN], dataidx=0;

	reset(dblrev);

	printf("FFTSIZE = %08x\n", FFTSIZE);
	printf("FFTMASK = %08x\n", FFTMASK);
	printf("DATALEN = %08x\n", DATALEN);
	printf("DATAMSK = %08x\n", DATAMSK);

	for(int k=0; k<4*(FFTSIZE); k++) {
		dblrev->i_ce = 1;
		dblrev->i_in_0 = 2*k;
		dblrev->i_in_1 = 2*k+1;
		datastore[(dataidx++)&(DATAMSK)] = dblrev->i_in_0;
		datastore[(dataidx++)&(DATAMSK)] = dblrev->i_in_1;
		tick(dblrev);

		printf("k=%3d: IN = %6lx : %6lx, OUT = %6lx : %6lx, SYNC = %d\t(%x)\n",
			k, dblrev->i_in_0, dblrev->i_in_1,
			dblrev->o_out_0, dblrev->o_out_1, dblrev->o_sync,
			dblrev->v__DOT__iaddr);

		if ((k>0)&&(((0==(k&(FFTMASK>>1)))?1:0) != dblrev->o_sync)) {
			fprintf(stdout, "FAIL, BAD SYNC\n");
			exit(-1);
		} else if (dblrev->o_sync) {
			syncd = 1;
		}
		if ((syncd)&&((dblrev->o_out_0&FFTMASK) != bitrev(FFTBITS, 2*k))) {
			fprintf(stdout, "FAIL: BITREV.0 of k (%2x) = %2lx, not %2lx\n",
				k, dblrev->o_out_0, bitrev(FFTBITS, 2*k));
			// exit(-1);
		}

		if ((syncd)&&((dblrev->o_out_1&FFTMASK) != bitrev(FFTBITS, 2*k+1))) {
			fprintf(stdout, "FAIL: BITREV.1 of k (%2x) = %2lx, not %2lx\n",
				k, dblrev->o_out_1, bitrev(FFTBITS, 2*k+1));
			// exit(-1);
		}
	}

	for(int k=0; k<4*(FFTSIZE); k++) {
		dblrev->i_ce = 1;
		dblrev->i_in_0 = rand() & 0x0ffffff;
		dblrev->i_in_1 = rand() & 0x0ffffff;
		datastore[(dataidx++)&(DATAMSK)] = dblrev->i_in_0;
		datastore[(dataidx++)&(DATAMSK)] = dblrev->i_in_1;
		tick(dblrev);

		printf("k=%3d: IN = %6lx : %6lx, OUT = %6lx : %6lx, SYNC = %d\n",
			k, dblrev->i_in_0, dblrev->i_in_1,
			dblrev->o_out_0, dblrev->o_out_1, dblrev->o_sync);

		if ((k>0)&&(((0==(k&(FFTMASK>>1)))?1:0) != dblrev->o_sync)) {
			fprintf(stdout, "FAIL, BAD SYNC\n");
			exit(-1);
		} else if (dblrev->o_sync)
			syncd = 1;
		if ((syncd)&&(dblrev->o_out_0 != datastore[(((dataidx-2-FFTSIZE)&PAGEMSK) + bitrev(FFTBITS, (dataidx-FFTSIZE-2)&FFTMASK))])) {
			fprintf(stdout, "FAIL: BITREV.0 of k (%2x) = %2lx, not %2lx (expected %lx -> %lx)\n",
				k, dblrev->o_out_0,
				datastore[(((dataidx-2-FFTSIZE)&PAGEMSK)
					+ bitrev(FFTBITS, (dataidx-FFTSIZE-2)&FFTMASK))],
				(dataidx-2)&DATAMSK,
				(((dataidx-2)&PAGEMSK)
					+ bitrev(FFTBITS, (dataidx-FFTSIZE-2)&FFTMASK)));
			// exit(-1);
		}

		if ((syncd)&&(dblrev->o_out_1 != datastore[(((dataidx-2-FFTSIZE)&PAGEMSK) + bitrev(FFTBITS, (dataidx-FFTSIZE-1)&FFTMASK))])) {
			fprintf(stdout, "FAIL: BITREV.1 of k (%2x) = %2lx, not %2lx (expected %lx)\n",
				k, dblrev->o_out_1,
				datastore[(((dataidx-2-FFTSIZE)&PAGEMSK)
					+ bitrev(FFTBITS, (dataidx-FFTSIZE-1)&FFTMASK))],
				(((dataidx-1)&PAGEMSK)
					+ bitrev(FFTBITS, (dataidx-FFTSIZE-1)&FFTMASK)));
			// exit(-1);
		}
	}

	delete	dblrev;

	printf("SUCCESS!\n");
	exit(0);
}
