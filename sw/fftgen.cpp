/////////////////////////////////////////////////////////////////////////////
//
// Filename: 	fftgen.cpp
//
// Project:	A Doubletime Pipelined FFT
//
// Purpose:	This is the core generator for the project.  Every part
//		and piece of this project begins and ends in this program.
//		Once built, this program will build an FFT (or IFFT) core
//		of arbitrary width, precision, etc., that will run at
//		two samples per clock.  (Incidentally, I didn't pick two
//		samples per clock because it was easier, but rather because
//		there weren't any two-sample per clock FFT's posted on 
//		opencores.com.  Further, FFT's running at one sample per
//		clock aren't that hard to find.)
//
//		You can find the documentation for this program in two places.
//		One is in the usage() function below.  The second is in the
//		'doc'uments directory that comes with this package, 
//		specifically in the spec.pdf file.  If it's not there, type
//		make in the documents directory to build it.
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
//
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <string>
#include <math.h>
#include <ctype.h>
#include <assert.h>

#define	DEF_NBITSIN	16
#define	DEF_COREDIR	"fft-core"
#define	DEF_XTRACBITS	4
#define	DEF_NMPY	0
#define	DEF_XTRAPBITS	0

typedef	enum {
	RND_TRUNCATE, RND_FROMZERO, RND_HALFUP, RND_CONVERGENT
} ROUND_T;

const char	cpyleft[] = 
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Copyright (C) 2015, Gisselquist Technology, LLC\n"
"//\n"
"// This program is free software (firmware): you can redistribute it and/or\n"
"// modify it under the terms of  the GNU General Public License as published\n"
"// by the Free Software Foundation, either version 3 of the License, or (at\n"
"// your option) any later version.\n"
"//\n"
"// This program is distributed in the hope that it will be useful, but WITHOUT\n"
"// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or\n"
"// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License\n"
"// for more details.\n"
"//\n"
"// You should have received a copy of the GNU General Public License along\n"
"// with this program.  (It's in the $(ROOT)/doc directory, run make with no\n"
"// target there if the PDF file isn\'t present.)  If not, see\n"
"// <http://www.gnu.org/licenses/> for a copy.\n"
"//\n"
"// License:	GPL, v3, as defined and found on www.gnu.org,\n"
"//		http://www.gnu.org/licenses/gpl.html\n"
"//\n"
"//\n"
"///////////////////////////////////////////////////////////////////////////\n";
const char	prjname[] = "A Doubletime Pipelined FFT";
const char	creator[] =	"// Creator:	Dan Gisselquist, Ph.D.\n"
				"//		Gisselquist Tecnology, LLC\n";

int	lgval(int vl) {
	int	lg;

	for(lg=1; (1<<lg) < vl; lg++)
		;
	return lg;
}

int	nextlg(int vl) {
	int	r;

	for(r=1; r<vl; r<<=1)
		;
	return r;
}

int	bflydelay(int nbits, int xtra) {
	int	cbits = nbits + xtra;
	int	delay;
	if (nbits+1<cbits)
		delay = nbits+4;
	else
		delay = cbits+3;
	return delay;
}

int	lgdelay(int nbits, int xtra) {
	// The butterfly code needs to compare a valid address, of this
	// many bits, with an address two greater.  This guarantees we
	// have enough bits for that comparison.  We'll also end up with
	// more storage space to look for these values, but without a 
	// redesign that's just what we'll deal with.
	return lgval(bflydelay(nbits, xtra)+3);
}

void	build_truncator(const char *fname) {
	printf("TRUNCATING!\n");
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	truncate.v\n"
"//		\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	Truncation is one of several options that can be used\n"
"//		internal to the various FFT stages to drop bits from one \n"
"//		stage to the next.  In general, it is the simplest method\n"
"//		of dropping bits, since it requires only a bit selection.\n"
"//\n"
"//		This form of rounding isn\'t really that great for FFT\'s,\n"
"//		since it tends to produce a DC bias in the result.  (Other\n"
"//		less pronounced biases may also exist.)\n"
"//\n"
"//		This particular version also registers the output with the\n"
"//		clock, so there will be a delay of one going through this\n"
"//		module.  This will keep it in line with the other forms of\n"
"//		rounding that can be used.\n"
"//\n"
"//\n%s"
"//\n",
		prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"module	truncate(i_clk, i_ce, i_val, o_val);\n"
	"\tparameter\tIWID=16, OWID=8, SHIFT=0;\n"
	"\tinput\t\t\t\t\ti_clk, i_ce;\n"
	"\tinput\t\tsigned\t[(IWID-1):0]\ti_val;\n"
	"\toutput\treg\tsigned\t[(OWID-1):0]\to_val;\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\t\to_val <= i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
"\n"
"endmodule\n");
}


void	build_roundhalfup(const char *fname) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	roundhalfup.v\n"
"//		\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	Rounding half up is the way I was always taught to round in\n"
"//		school.  A one half value is added to the result, and then\n"
"//		the result is truncated.  When used in an FFT, this produces\n"
"//		less bias than the truncation method, although a bias still\n"
"//		tends to remain.\n"
"//\n"
"//\n%s"
"//\n",
		prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"module	roundhalfup(i_clk, i_ce, i_val, o_val);\n"
	"\tparameter\tIWID=16, OWID=8, SHIFT=0;\n"
	"\tinput\t\t\t\t\ti_clk, i_ce;\n"
	"\tinput\t\tsigned\t[(IWID-1):0]\ti_val;\n"
	"\toutput\treg\tsigned\t[(OWID-1):0]\to_val;\n"
"\n"
	"\t// Let's deal with two cases to be as general as we can be here\n"
	"\t//\n"
	"\t//	1. The desired output would lose no bits at all\n"
	"\t//	2. One or more bits would be dropped, so the rounding is simply\n"
	"\t//\t\ta matter of adding one to the bit about to be dropped,\n"
	"\t//\t\tmoving all halfway and above numbers up to the next\n"
	"\t//\t\tvalue.\n"
	"\tgenerate\n"
	"\tif (IWID-SHIFT == OWID)\n"
	"\tbegin // No truncation or rounding, output drops no bits\n"
"\n"
		"\t\talways @(posedge i_clk)\n"
			"\t\t\tif (i_ce)\to_val <= i_val[(IWID-SHIFT-1):0];\n"
"\n"
	"\tend else // if (IWID-SHIFT-1 >= OWID)\n"
	"\tbegin // Output drops one bit, can only add one or ... not.\n"
		"\t\twire\t[(OWID-1):0]	truncated_value, rounded_up;\n"
		"\t\twire\t\t\tlast_valid_bit, first_lost_bit;\n"
		"\t\tassign\ttruncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
		"\t\tassign\trounded_up=truncated_value + {{(OWID-1){1\'b0}}, 1\'b1 };\n"
		"\t\tassign\tfirst_lost_bit = i_val[(IWID-SHIFT-OWID-1)];\n"
"\n"
		"\t\talways @(posedge i_clk)\n"
		"\t\t\tif (i_ce)\n"
		"\t\t\tbegin\n"
			"\t\t\t\tif (~first_lost_bit) // Round down / truncate\n"
			"\t\t\t\t\to_val <= truncated_value;\n"
			"\t\t\t\telse\n"
			"\t\t\t\t\to_val <= rounded_up; // even value\n"
		"\t\t\tend\n"
"\n"
	"\tend\n"
	"\tendgenerate\n"
"\n"
"endmodule\n");
}

void	build_roundfromzero(const char *fname) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	roundfromzero.v\n"
"//		\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	Truncation is one of several options that can be used\n"
"//		internal to the various FFT stages to drop bits from one \n"
"//		stage to the next.  In general, it is the simplest method\n"
"//		of dropping bits, since it requires only a bit selection.\n"
"//\n"
"//		This form of rounding isn\'t really that great for FFT\'s,\n"
"//		since it tends to produce a DC bias in the result.  (Other\n"
"//		less pronounced biases may also exist.)\n"
"//\n"
"//		This particular version also registers the output with the\n"
"//		clock, so there will be a delay of one going through this\n"
"//		module.  This will keep it in line with the other forms of\n"
"//		rounding that can be used.\n"
"//\n"
"//\n%s"
"//\n",
		prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"module	convround(i_clk, i_ce, i_val, o_val);\n"
	"\tparameter\tIWID=16, OWID=8, SHIFT=0;\n"
	"\tinput\t\t\t\t\ti_clk, i_ce;\n"
	"\tinput\t\tsigned\t[(IWID-1):0]\ti_val;\n"
	"\toutput\treg\tsigned\t[(OWID-1):0]\to_val;\n"
"\n"
	"\t// Let's deal with three cases to be as general as we can be here\n"
	"\t//\n"
	"\t//\t1. The desired output would lose no bits at all\n"
	"\t//\t2. One bit would be dropped, so the rounding is simply\n"
	"\t//\t\tadjusting the value to be the closer to zero in\n"
	"\t//\t\tcases of being halfway between two.  If identically\n"
	"\t//\t\tequal to a number, we just leave it as is.\n"
	"\t//\t3. Two or more bits would be dropped.  In this case, we round\n"
	"\t//\t\tnormally unless we are rounding a value of exactly\n"
	"\t//\t\thalfway between the two.  In the halfway case, we\n"
	"\t//\t\tround away from zero.\n"
	"\tgenerate\n"
	"\tif (IWID-SHIFT == OWID)\n"
	"\tbegin // No truncation or rounding, output drops no bits\n"
"\n"
		"\t\talways @(posedge i_clk)\n"
			"\t\t\tif (i_ce)\to_val <= i_val[(IWID-SHIFT-1):0];\n"
"\n"
	"\tend else if (IWID-SHIFT-1 == OWID)\n"
	"\tbegin // Output drops one bit, can only add one or ... not.\n"
	"\t\twire\t[(OWID-1):0]\ttruncated_value, rounded_up;\n"
	"\t\twire\t\t\tsign_bit, first_lost_bit;\n"
	"\t\tassign\ttruncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
	"\t\tassign\trounded_up=truncated_value + {{(OWID-1){1\'b0}}, 1\'b1 };\n"
	"\t\tassign\tfirst_lost_bit = i_val[0];\n"
	"\t\tassign\tsign_bit = i_val[(IWID-1)];\n"
"\n"
	"\t\talways @(posedge i_clk)\n"
		"\t\t\tif (i_ce)\n"
		"\t\t\tbegin\n"
			"\t\t\t\tif (~first_lost_bit) // Round down / truncate\n"
				"\t\t\t\t\to_val <= truncated_value;\n"
			"\t\t\t\telse if (sign_bit)\n"
				"\t\t\t\t\to_val <= truncated_value;\n"
			"\t\t\t\telse\n"
				"\t\t\t\t\to_val <= rounded_up;\n"
		"\t\t\tend\n"
"\n"
	"\tend else // If there's more than one bit we are dropping\n"
	"\tbegin\n"
		"\t\twire\t[(OWID-1):0]\ttruncated_value, rounded_up;\n"
		"\t\twire\t\t\tsign_bit, first_lost_bit;\n"
		"\t\tassign\ttruncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
		"\t\tassign\trounded_up=truncated_value + {{(OWID-1){1\'b0}}, 1\'b1 };\n"
		"\t\tassign\tfirst_lost_bit = i_val[(IWID-SHIFT-OWID-1)];\n"
		"\t\tassign\tsign_bit = i_val[(IWID-1)];\n"
"\n"
		"\t\twire\t[(IWID-SHIFT-OWID-2):0]\tother_lost_bits;\n"
		"\t\tassign\tother_lost_bits = i_val[(IWID-SHIFT-OWID-2):0];\n"
"\n"
		"\t\talways @(posedge i_clk)\n"
			"\t\t\tif (i_ce)\n"
			"\t\t\tbegin\n"
			"\t\t\t\tif (~first_lost_bit) // Round down / truncate\n"
				"\t\t\t\t\to_val <= truncated_value;\n"
			"\t\t\t\telse if (|other_lost_bits) // Round up to\n"
				"\t\t\t\t\to_val <= rounded_up; // closest value\n"
			"\t\t\t\telse if (sign_bit)\n"
				"\t\t\t\t\to_val <= truncated_value;\n"
			"\t\t\t\telse\n"
				"\t\t\t\t\to_val <= rounded_up;\n"
			"\t\t\tend\n"
	"\tend\n"
	"\tendgenerate\n"
"\n"
"endmodule\n");
}

void	build_convround(const char *fname) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	convround.v\n"
"//		\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	A convergent rounding routine, also known as banker\'s\n"
"//		rounding, Dutch rounding, Gaussian rounding, unbiased\n"
"//		rounding, or ... more, at least according to Wikipedia.\n"
"//\n"
"//		This form of rounding works by rounding, when the direction\n"
"//		is in question, towards the nearest even value.\n"
"//\n"
"//\n%s"
"//\n",
		prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"module	convround(i_clk, i_ce, i_val, o_val);\n"
"\tparameter\tIWID=16, OWID=8, SHIFT=0;\n"
"\tinput\t\t\t\t\ti_clk, i_ce;\n"
"\tinput\t\tsigned\t[(IWID-1):0]\ti_val;\n"
"\toutput\treg\tsigned\t[(OWID-1):0]\to_val;\n"
"\n"
"\t// Let's deal with three cases to be as general as we can be here\n"
"\t//\n"
"\t//\t1. The desired output would lose no bits at all\n"
"\t//\t2. One bit would be dropped, so the rounding is simply\n"
"\t//\t\tadjusting the value to be the nearest even number in\n"
"\t//\t\tcases of being halfway between two.  If identically\n"
"\t//\t\tequal to a number, we just leave it as is.\n"
"\t//\t3. Two or more bits would be dropped.  In this case, we round\n"
"\t//\t\tnormally unless we are rounding a value of exactly\n"
"\t//\t\thalfway between the two.  In the halfway case we round\n"
"\t//\t\tto the nearest even number.\n"
"\tgenerate\n"
"\tif (IWID-SHIFT == OWID)\n"
"\tbegin // No truncation or rounding, output drops no bits\n"
"\n"
"\t\talways @(posedge i_clk)\n"
"\t\t\tif (i_ce)\to_val <= i_val[(IWID-SHIFT-1):0];\n"
"\n"
"\tend else if (IWID-SHIFT-1 == OWID)\n"
"\tbegin // Output drops one bit, can only add one or ... not.\n"
"\t\twire\t[(OWID-1):0]	truncated_value, rounded_up;\n"
"\t\twire\t\t\tlast_valid_bit, first_lost_bit;\n"
"\t\tassign\ttruncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
"\t\tassign\trounded_up=truncated_value + {{(OWID-1){1\'b0}}, 1\'b1 };\n"
"\t\tassign\tlast_valid_bit = truncated_value[0];\n"
"\t\tassign\tfirst_lost_bit = i_val[0];\n"
"\n"
"\t\talways @(posedge i_clk)\n"
"\t\t\tif (i_ce)\n"
"\t\t\tbegin\n"
"\t\t\t\tif (~first_lost_bit) // Round down / truncate\n"
"\t\t\t\t\to_val <= truncated_value;\n"
"\t\t\t\telse if (last_valid_bit)// Round up to nearest\n"
"\t\t\t\t\to_val <= rounded_up; // even value\n"
"\t\t\t\telse // else round down to the nearest\n"
"\t\t\t\t\to_val <= truncated_value; // even value\n"
"\t\t\tend\n"
"\n"
"\tend else // If there's more than one bit we are dropping\n"
"\tbegin\n"
"\t\twire\t[(OWID-1):0]	truncated_value, rounded_up;\n"
"\t\twire\t\t\tlast_valid_bit, first_lost_bit;\n"
"\t\tassign\ttruncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];\n"
"\t\tassign\trounded_up=truncated_value + {{(OWID-1){1\'b0}}, 1\'b1 };\n"
"\t\tassign\tlast_valid_bit = truncated_value[0];\n"
"\t\tassign\tfirst_lost_bit = i_val[(IWID-SHIFT-OWID-1)];\n"
"\n"
"\t\twire\t[(IWID-SHIFT-OWID-2):0]\tother_lost_bits;\n"
"\t\tassign\tother_lost_bits = i_val[(IWID-SHIFT-OWID-2):0];\n"
"\n"
"\t\talways @(posedge i_clk)\n"
"\t\t\tif (i_ce)\n"
"\t\t\tbegin\n"
"\t\t\t\tif (~first_lost_bit) // Round down / truncate\n"
"\t\t\t\t\to_val <= truncated_value;\n"
"\t\t\t\telse if (|other_lost_bits) // Round up to\n"
"\t\t\t\t\to_val <= rounded_up; // closest value\n"
"\t\t\t\telse if (last_valid_bit) // Round up to\n"
"\t\t\t\t\to_val <= rounded_up; // nearest even\n"
"\t\t\t\telse	// else round down to nearest even\n"
"\t\t\t\t\to_val <= truncated_value;\n"
"\t\t\tend\n"
"\tend\n"
"\tendgenerate\n"
"\n"
"endmodule\n");
}

void	build_quarters(const char *fname, ROUND_T rounding, bool dbg=false) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}
	const	char	*rnd_string;
	if (rounding == RND_TRUNCATE)
		rnd_string = "truncate";
	else if (rounding == RND_FROMZERO)
		rnd_string = "roundfromzero";
	else if (rounding == RND_HALFUP)
		rnd_string = "roundhalfup";
	else
		rnd_string = "convround";


	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	qtrstage%s.v\n"
"//		\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This file encapsulates the 4 point stage of a decimation in\n"
"//		frequency FFT.  This particular implementation is optimized\n"
"//		so that all of the multiplies are accomplished by additions\n"
"//		and multiplexers only.\n"
"//\n"
"//\n%s"
"//\n",
		(dbg)?"_dbg":"", prjname, creator);
	fprintf(fp, "%s", cpyleft);

	fprintf(fp,
"module\tqtrstage%s(i_clk, i_rst, i_ce, i_sync, i_data, o_data, o_sync%s);\n"
	"\tparameter	IWIDTH=16, OWIDTH=IWIDTH+1;\n"
	"\t// Parameters specific to the core that should be changed when this\n"
	"\t// core is built ... Note that the minimum LGSPAN is 2.  Smaller \n"
	"\t// spans must use the fftdoubles stage.\n"
	"\tparameter\tLGWIDTH=8, ODD=0, INVERSE=0,SHIFT=0;\n"
	"\tinput\t				i_clk, i_rst, i_ce, i_sync;\n"
	"\tinput\t	[(2*IWIDTH-1):0]	i_data;\n"
	"\toutput\treg	[(2*OWIDTH-1):0]	o_data;\n"
	"\toutput\treg				o_sync;\n"
	"\t\n", (dbg)?"_dbg":"", (dbg)?", o_dbg":"");
	if (dbg) { fprintf(fp, "\toutput\twire\t[33:0]\t\t\to_dbg;\n"
		"\tassign\to_dbg = { ((o_sync)&&(i_ce)), i_ce, o_data[(2*OWIDTH-1):(2*OWIDTH-16)],\n"
			"\t\t\t\t\to_data[(OWIDTH-1):(OWIDTH-16)] };\n"
"\n");
	}
	fprintf(fp,
	"\treg\t	wait_for_sync;\n"
	"\treg\t[3:0]	pipeline;\n"
"\n"
	"\treg\t[(IWIDTH):0]	sum_r, sum_i, diff_r, diff_i;\n"
"\n"
	"\treg\t[(2*OWIDTH-1):0]\tob_a;\n"
	"\twire\t[(2*OWIDTH-1):0]\tob_b;\n"
	"\treg\t[(OWIDTH-1):0]\t\tob_b_r, ob_b_i;\n"
	"\tassign\tob_b = { ob_b_r, ob_b_i };\n"
"\n"
	"\treg\t[(LGWIDTH-1):0]\t\tiaddr;\n"
	"\treg\t[(2*IWIDTH-1):0]\timem;\n"
"\n"
	"\twire\tsigned\t[(IWIDTH-1):0]\timem_r, imem_i;\n"
	"\tassign\timem_r = imem[(2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\timem_i = imem[(IWIDTH-1):0];\n"
"\n"
	"\twire\tsigned\t[(IWIDTH-1):0]\ti_data_r, i_data_i;\n"
	"\tassign\ti_data_r = i_data[(2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\ti_data_i = i_data[(IWIDTH-1):0];\n"
"\n"
	"\treg	[(2*OWIDTH-1):0]	omem;\n"
"\n");
	fprintf(fp,
	"\twire\tsigned\t[(OWIDTH-1):0]\trnd_sum_r, rnd_sum_i, rnd_diff_r, rnd_diff_i,\n");
	fprintf(fp,
	"\t\t\t\t\tn_rnd_diff_r, n_rnd_diff_i;\n");
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT)\tdo_rnd_sum_r(i_clk, i_ce,\n"
	"\t\t\t\tsum_r, rnd_sum_r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT)\tdo_rnd_sum_i(i_clk, i_ce,\n"
	"\t\t\t\tsum_i, rnd_sum_i);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT)\tdo_rnd_diff_r(i_clk, i_ce,\n"
	"\t\t\t\tdiff_r, rnd_diff_r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT)\tdo_rnd_diff_i(i_clk, i_ce,\n"
	"\t\t\t\tdiff_i, rnd_diff_i);\n\n", rnd_string);
	fprintf(fp, "\tassign n_rnd_diff_r = - rnd_diff_r;\n"
		"\tassign n_rnd_diff_i = - rnd_diff_i;\n");
/*
	fprintf(fp,
	"\twire	[(IWIDTH-1):0]	rnd;\n"
	"\tgenerate\n"
	"\tif ((ROUND)&&((IWIDTH+1-OWIDTH-SHIFT)>0))\n"
		"\t\tassign rnd = { {(IWIDTH-1){1\'b0}}, 1\'b1 };\n"
	"\telse\n"
		"\t\tassign rnd = { {(IWIDTH){1\'b0}}};\n"
	"\tendgenerate\n"
"\n"
*/
	fprintf(fp,
	"\tinitial wait_for_sync = 1\'b1;\n"
	"\tinitial iaddr = 0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\tbegin\n"
			"\t\t\twait_for_sync <= 1\'b1;\n"
			"\t\t\tiaddr <= 0;\n"
		"\t\tend else if ((i_ce)&&((~wait_for_sync)||(i_sync)))\n"
		"\t\tbegin\n"
			"\t\t\tiaddr <= iaddr + { {(LGWIDTH-1){1\'b0}}, 1\'b1 };\n"
			"\t\t\twait_for_sync <= 1\'b0;\n"
		"\t\tend\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
			"\t\t\timem <= i_data;\n"
		"\n\n");
	fprintf(fp,
	"\t// Note that we don\'t check on wait_for_sync or i_sync here.\n"
	"\t// Why not?  Because iaddr will always be zero until after the\n"
	"\t// first i_ce, so we are safe.\n"
	"\tinitial pipeline = 4\'h0;\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
			"\t\t\tpipeline <= 4\'h0;\n"
		"\t\telse if (i_ce) // is our pipeline process full?  Which stages?\n"
			"\t\t\tpipeline <= { pipeline[2:0], iaddr[0] };\n\n");
	fprintf(fp,
	"\t// This is the pipeline[-1] stage, pipeline[0] will be set next.\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif ((i_ce)&&(iaddr[0]))\n"
		"\t\tbegin\n"
			"\t\t\tsum_r  <= imem_r + i_data_r;\n"
			"\t\t\tsum_i  <= imem_i + i_data_i;\n"
			"\t\t\tdiff_r <= imem_r - i_data_r;\n"
			"\t\t\tdiff_i <= imem_i - i_data_i;\n"
		"\t\tend\n\n");
	fprintf(fp,
	"\t// pipeline[1] takes sum_x and diff_x and produces rnd_x\n\n");
	fprintf(fp,
	"\t// Now for pipeline[2].  We can actually do this at all i_ce\n"
	"\t// clock times, since nothing will listen unless pipeline[3]\n"
	"\t// on the next clock.  Thus, we simplify this logic and do\n"
	"\t// it independent of pipeline[2].\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\tob_a <= { rnd_sum_r, rnd_sum_i };\n"
			"\t\t\t// on Even, W = e^{-j2pi 1/4 0} = 1\n"
			"\t\t\tif (ODD == 0)\n"
			"\t\t\tbegin\n"
			"\t\t\t\tob_b_r <= rnd_diff_r;\n"
			"\t\t\t\tob_b_i <= rnd_diff_i;\n"
			"\t\t\tend else if (INVERSE==0) begin\n"
			"\t\t\t\t// on Odd, W = e^{-j2pi 1/4} = -j\n"
			"\t\t\t\tob_b_r <=   rnd_diff_i;\n"
			"\t\t\t\tob_b_i <= n_rnd_diff_r;\n"
			"\t\t\tend else begin\n"
			"\t\t\t\t// on Odd, W = e^{j2pi 1/4} = j\n"
			"\t\t\t\tob_b_r <= n_rnd_diff_i;\n"
			"\t\t\t\tob_b_i <=   rnd_diff_r;\n"
			"\t\t\tend\n"
		"\t\tend\n\n");
	fprintf(fp,
	"\talways\t@(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin // In sequence, clock = 3\n"
			"\t\t\tif (pipeline[3])\n"
			"\t\t\tbegin\n"
				"\t\t\t\tomem <= ob_b;\n"
				"\t\t\t\to_data <= ob_a;\n"
			"\t\t\tend else\n"
				"\t\t\t\to_data <= omem;\n"
		"\t\tend\n\n");

	fprintf(fp,
	"\t// Don\'t forget in the sync check that we are running\n"
	"\t// at two clocks per sample.  Thus we need to\n"
	"\t// produce a sync every 2^(LGWIDTH-1) clocks.\n"
	"\tinitial\to_sync = 1\'b0;\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\t\to_sync <= 1\'b0;\n"
		"\t\telse if (i_ce)\n"
			"\t\t\to_sync <= &(~iaddr[(LGWIDTH-2):3]) && (iaddr[2:0] == 3'b101);\n");
	fprintf(fp, "endmodule\n");
}

void	build_dblstage(const char *fname, ROUND_T rounding, const bool dbg = false) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	const	char	*rnd_string;
	if (rounding == RND_TRUNCATE)
		rnd_string = "truncate";
	else if (rounding == RND_FROMZERO)
		rnd_string = "roundfromzero";
	else if (rounding == RND_HALFUP)
		rnd_string = "roundhalfup";
	else
		rnd_string = "convround";


	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	dblstage%s.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This is part of an FPGA implementation that will process\n"
"//		the final stage of a decimate-in-frequency FFT, running\n"
"//		through the data at two samples per clock.  If you notice\n"
"//		from the derivation of an FFT, the only time both even and\n"
"//		odd samples are used at the same time is in this stage.\n"
"//		Therefore, other than this stage and these twiddles, all of\n"
"//		the other stages can run two stages at a time at one sample\n"
"//		per clock.\n"
"//\n"
"//		In this implementation, the output is valid one clock after\n"
"//		the input is valid.  The output also accumulates one bit\n"
"//		above and beyond the number of bits in the input.\n"
"//		\n"
"//		i_clk	A system clock\n"
"//		i_rst	A synchronous reset\n"
"//		i_ce	Circuit enable--nothing happens unless this line is high\n"
"//		i_sync	A synchronization signal, high once per FFT at the start\n"
"//		i_left	The first (even) complex sample input.  The higher order\n"
"//			bits contain the real portion, low order bits the\n"
"//			imaginary portion, all in two\'s complement.\n"
"//		i_right	The next (odd) complex sample input, same format as\n"
"//			i_left.\n"
"//		o_left	The first (even) complex output.\n"
"//		o_right	The next (odd) complex output.\n"
"//		o_sync	Output synchronization signal.\n"
"//\n%s"
"//\n", (dbg)?"_dbg":"", prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp, 
"module\tdblstage%s(i_clk, i_rst, i_ce, i_sync, i_left, i_right, o_left, o_right, o_sync%s);\n"
	"\tparameter\tIWIDTH=16,OWIDTH=IWIDTH+1, SHIFT=0;\n"
	"\tinput\t\ti_clk, i_rst, i_ce, i_sync;\n"
	"\tinput\t\t[(2*IWIDTH-1):0]\ti_left, i_right;\n"
	"\toutput\twire\t[(2*OWIDTH-1):0]\to_left, o_right;\n"
	"\toutput\treg\t\t\to_sync;\n"
	"\n", (dbg)?"_dbg":"", (dbg)?", o_dbg":"");

	if (dbg) { fprintf(fp, "\toutput\twire\t[33:0]\t\t\to_dbg;\n"
		"\tassign\to_dbg = { ((o_sync)&&(i_ce)), i_ce, o_left[(2*OWIDTH-1):(2*OWIDTH-16)],\n"
			"\t\t\t\t\to_left[(OWIDTH-1):(OWIDTH-16)] };\n"
"\n");
	}
	fprintf(fp, 
	"\twire\tsigned\t[(IWIDTH-1):0]\ti_in_0r, i_in_0i, i_in_1r, i_in_1i;\n"
	"\tassign\ti_in_0r = i_left[(2*IWIDTH-1):(IWIDTH)]; \n"
	"\tassign\ti_in_0i = i_left[(IWIDTH-1):0]; \n"
	"\tassign\ti_in_1r = i_right[(2*IWIDTH-1):(IWIDTH)]; \n"
	"\tassign\ti_in_1i = i_right[(IWIDTH-1):0]; \n"
	"\twire\t[(OWIDTH-1):0]\t\to_out_0r, o_out_0i,\n"
				"\t\t\t\t\to_out_1r, o_out_1i;\n"
"\n"
"\n"
	"\t// Handle a potential rounding situation, when IWIDTH>=OWIDTH.\n"
"\n"
"\n");
	fprintf(fp,
	"\t// Don't forget that we accumulate a bit by adding two values\n"
	"\t// together. Therefore our intermediate value must have one more\n"
	"\t// bit than the two originals.\n"
	"\treg\tsigned\t[(IWIDTH):0]\trnd_in_0r, rnd_in_0i, rnd_in_1r, rnd_in_1i;\n\n");
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_0r(i_clk, i_ce,\n"
	"\t\t\t\t\t\t\t\trnd_in_0r, o_out_0r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_0i(i_clk, i_ce,\n"
	"\t\t\t\t\t\t\t\trnd_in_0i, o_out_0i);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_1r(i_clk, i_ce,\n"
	"\t\t\t\t\t\t\t\trnd_in_1r, o_out_1r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_1i(i_clk, i_ce,\n"
	"\t\t\t\t\t\t\t\trnd_in_1i, o_out_1i);\n\n", rnd_string);

	fprintf(fp,
	"\n"
	"\t// As with any register connected to the sync pulse, these must\n"
	"\t// have initial values and be reset on the i_rst signal.\n"
	"\t// Other data values need only restrict their updates to i_ce\n"
	"\t// enabled clocks, but sync\'s must obey resets and initial\n"
	"\t// conditions as well.\n"
	"\treg\twait_for_sync, rnd_sync;\n"
"\n"
	"\tinitial begin\n"
	"\t\trnd_sync      = 1\'b0;\n"
	"\t\to_sync        = 1\'b0;\n"
	"\t\twait_for_sync = 1\'b1;\n"
	"\tend\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\tbegin\n"
			"\t\t\trnd_sync <= 1\'b0;\n"
			"\t\t\to_sync <= 1\'b0;\n"
			"\t\t\twait_for_sync <= 1\'b1;\n"
		"\t\tend else if ((i_ce)&&((~wait_for_sync)||(i_sync)))\n"
		"\t\tbegin\n"
			"\t\t\twait_for_sync <= 1\'b0;\n"
			"\t\t\t//\n"
			"\t\t\trnd_sync <= i_sync;\n"
			"\t\t\to_sync <= rnd_sync;\n"
		"\t\tend\n"
"\n"
	"\t// As with other variables, these are really only updated when in\n"
	"\t// the processing pipeline, after the first i_sync.  However, to\n"
	"\t// eliminate as much unnecessary logic as possible, we toggle\n"
	"\t// these any time the i_ce line is enabled.\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t//\n"
			"\t\t\trnd_in_0r <= i_in_0r + i_in_1r;\n"
			"\t\t\trnd_in_0i <= i_in_0i + i_in_1i;\n"
			"\t\t\t//\n"
			"\t\t\trnd_in_1r <= i_in_0r - i_in_1r;\n"
			"\t\t\trnd_in_1i <= i_in_0i - i_in_1i;\n"
			"\t\t\t//\n"
		"\t\tend\n"
"\n"
	"\tassign\to_left  = { o_out_0r, o_out_0i };\n"
	"\tassign\to_right = { o_out_1r, o_out_1i };\n"
"\n"
"endmodule\n");
	fclose(fp);
}

void	build_multiply(const char *fname) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	shiftaddmpy.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	A portable shift and add multiply.\n"
"//\n"
"//		While both Xilinx and Altera will offer single clock \n"
"//		multiplies, this simple approach will multiply two numbers\n"
"//		on any architecture.  The result maintains the full width\n"
"//		of the multiply, there are no extra stuff bits, no rounding,\n"
"//		no shifted bits, etc.\n"
"//\n"
"//		Further, for those applications that can support it, this\n"
"//		multiply is pipelined and will produce one answer per clock.\n"
"//\n"
"//		For minimal processing delay, make the first parameter\n"
"//		the one with the least bits, so that AWIDTH <= BWIDTH.\n"
"//\n"
"//		The processing delay in this multiply is (AWIDTH+1) cycles.\n"
"//		That is, if the data is present on the input at clock t=0,\n"
"//		the result will be present on the output at time t=AWIDTH+1;\n"
"//\n"
"//\n%s"
"//\n", prjname, creator);

	fprintf(fp, "%s", cpyleft);
	fprintf(fp, 
"module	shiftaddmpy(i_clk, i_ce, i_a, i_b, o_r);\n"
	"\tparameter\tAWIDTH=16,BWIDTH=AWIDTH;\n"
	"\tinput\t\t\t\t\ti_clk, i_ce;\n"
	"\tinput\t\t[(AWIDTH-1):0]\t\ti_a;\n"
	"\tinput\t\t[(BWIDTH-1):0]\t\ti_b;\n"
	"\toutput\treg\t[(AWIDTH+BWIDTH-1):0]\to_r;\n"
"\n"
	"\treg\t[(AWIDTH-1):0]\tu_a;\n"
	"\treg\t[(BWIDTH-1):0]\tu_b;\n"
	"\treg\t\t\tsgn;\n"
"\n"
	"\treg\t[(AWIDTH-2):0]\t\tr_a[0:(AWIDTH-1)];\n"
	"\treg\t[(AWIDTH+BWIDTH-2):0]\tr_b[0:(AWIDTH-1)];\n"
	"\treg\t\t\t\tr_s[0:(AWIDTH-1)];\n"
	"\treg\t[(AWIDTH+BWIDTH-1):0]\tacc[0:(AWIDTH-1)];\n"
	"\tgenvar k;\n"
"\n"
	"\t// If we were forced to stay within two\'s complement arithmetic,\n"
	"\t// taking the absolute value here would require an additional bit.\n"
	"\t// However, because our results are now unsigned, we can stay\n"
	"\t// within the number of bits given (for now).\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\tu_a <= (i_a[AWIDTH-1])?(-i_a):(i_a);\n"
			"\t\t\tu_b <= (i_b[BWIDTH-1])?(-i_b):(i_b);\n"
			"\t\t\tsgn <= i_a[AWIDTH-1] ^ i_b[BWIDTH-1];\n"
		"\t\tend\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\tacc[0] <= (u_a[0]) ? { {(AWIDTH){1\'b0}}, u_b }\n"
			"\t\t\t\t\t: {(AWIDTH+BWIDTH){1\'b0}};\n"
			"\t\t\tr_a[0] <= { u_a[(AWIDTH-1):1] };\n"
			"\t\t\tr_b[0] <= { {(AWIDTH-1){1\'b0}}, u_b };\n"
			"\t\t\tr_s[0] <= sgn; // The final sign, needs to be preserved\n"
		"\t\tend\n"
"\n"
	"\tgenerate\n"
	"\tfor(k=0; k<AWIDTH-1; k=k+1)\n"
	"\tbegin : genstages\n"
		"\t\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\tacc[k+1] <= acc[k] + ((r_a[k][0]) ? {r_b[k],1\'b0}:0);\n"
			"\t\t\tr_a[k+1] <= { 1\'b0, r_a[k][(AWIDTH-2):1] };\n"
			"\t\t\tr_b[k+1] <= { r_b[k][(AWIDTH+BWIDTH-3):0], 1\'b0};\n"
			"\t\t\tr_s[k+1] <= r_s[k];\n"
		"\t\tend\n"
	"\tend\n"
	"\tendgenerate\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
			"\t\t\to_r <= (r_s[AWIDTH-1]) ? (-acc[AWIDTH-1]) : acc[AWIDTH-1];\n"
"\n"
"endmodule\n");

	fclose(fp);
}

void	build_dblreverse(const char *fname) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	dblreverse.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This module bitreverses a pipelined FFT input.  Operation is\n"
"//		expected as follows:\n"
"//\n"
"//		i_clk	A running clock at whatever system speed is offered.\n"
"//		i_rst	A synchronous reset signal, that resets all internals\n"
"//		i_ce	If this is one, one input is consumed and an output\n"
"//			is produced.\n"
"//		i_in_0, i_in_1\n"
"//			Two inputs to be consumed, each of width WIDTH.\n"
"//		o_out_0, o_out_1\n"
"//			Two of the bitreversed outputs, also of the same\n"
"//			width, WIDTH.  Of course, there is a delay from the\n"
"//			first input to the first output.  For this purpose,\n"
"//			o_sync is present.\n"
"//		o_sync	This will be a 1\'b1 for the first value in any block.\n"
"//			Following a reset, this will only become 1\'b1 once\n"
"//			the data has been loaded and is now valid.  After that,\n"
"//			all outputs will be valid.\n"
"//\n"
"//	20150602 -- This module has undergone massive rework in order to\n"
"//		ensure that it uses resources efficiently.  As a result, \n"
"//		it now optimizes nicely into block RAMs.  As an unfortunately\n"
"//		side effect, it now passes it\'s bench test (dblrev_tb) but\n"
"//		fails the integration bench test (fft_tb).\n"
"//\n"
"//\n%s"
"//\n", prjname, creator);
	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"\n\n"
"//\n"
"// How do we do bit reversing at two smples per clock?  Can we separate out\n"
"// our work into eight memory banks, writing two banks at once and reading\n"
"// another two banks in the same clock?\n"
"//\n"
"//	mem[00xxx0] = s_0[n]\n"
"//	mem[00xxx1] = s_1[n]\n"
"//	o_0[n] = mem[10xxx0]\n"
"//	o_1[n] = mem[11xxx0]\n"
"//	...\n"
"//	mem[01xxx0] = s_0[m]\n"
"//	mem[01xxx1] = s_1[m]\n"
"//	o_0[m] = mem[10xxx1]\n"
"//	o_1[m] = mem[11xxx1]\n"
"//	...\n"
"//	mem[10xxx0] = s_0[n]\n"
"//	mem[10xxx1] = s_1[n]\n"
"//	o_0[n] = mem[00xxx0]\n"
"//	o_1[n] = mem[01xxx0]\n"
"//	...\n"
"//	mem[11xxx0] = s_0[m]\n"
"//	mem[11xxx1] = s_1[m]\n"
"//	o_0[m] = mem[00xxx1]\n"
"//	o_1[m] = mem[01xxx1]\n"
"//	...\n"
"//\n"
"//	The answer is that, yes we can but: we need to use four memory banks\n"
"//	to do it properly.  These four banks are defined by the two bits\n"
"//	that determine the top and bottom of the correct address.  Larger\n"
"//	FFT\'s would require more memories.\n"
"//\n"
"//\n");
	fprintf(fp, 
"module	dblreverse(i_clk, i_rst, i_ce, i_in_0, i_in_1,\n"
	"\t\to_out_0, o_out_1, o_sync);\n"
	"\tparameter\t\t\tLGSIZE=5, WIDTH=24;\n"
	"\tinput\t\t\t\ti_clk, i_rst, i_ce;\n"
	"\tinput\t\t[(2*WIDTH-1):0]\ti_in_0, i_in_1;\n"
	"\toutput\twire\t[(2*WIDTH-1):0]\to_out_0, o_out_1;\n"
	"\toutput\treg\t\t\to_sync;\n"
"\n"
	"\treg\t\t\tin_reset;\n"
	"\treg\t[(LGSIZE-1):0]\tiaddr;\n"
	"\twire\t[(LGSIZE-3):0]\tbraddr;\n"
"\n"
	"\tgenvar\tk;\n"
	"\tgenerate for(k=0; k<LGSIZE-2; k=k+1)\n"
	"\tbegin : gen_a_bit_reversed_value\n"
		"\t\tassign braddr[k] = iaddr[LGSIZE-3-k];\n"
	"\tend endgenerate\n"
"\n"
	"\tinitial iaddr = 0;\n"
	"\tinitial in_reset = 1\'b1;\n"
	"\tinitial o_sync = 1\'b0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\tbegin\n"
			"\t\t\tiaddr <= 0;\n"
			"\t\t\tin_reset <= 1\'b1;\n"
			"\t\t\to_sync <= 1\'b0;\n"
		"\t\tend else if (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\tiaddr <= iaddr + { {(LGSIZE-1){1\'b0}}, 1\'b1 };\n"
			"\t\t\tif (&iaddr[(LGSIZE-2):0])\n"
				"\t\t\t\tin_reset <= 1\'b0;\n"
			"\t\t\tif (in_reset)\n"
				"\t\t\t\to_sync <= 1\'b0;\n"
			"\t\t\telse\n"
				"\t\t\t\to_sync <= ~(|iaddr[(LGSIZE-2):0]);\n"
		"\t\tend\n"
"\n"
	"\treg\t[(2*WIDTH-1):0]\tmem_e [0:((1<<(LGSIZE))-1)];\n"
	"\treg\t[(2*WIDTH-1):0]\tmem_o [0:((1<<(LGSIZE))-1)];\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\tmem_e[iaddr] <= i_in_0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\tmem_o[iaddr] <= i_in_1;\n"
"\n"
"\n"
	"\treg [(2*WIDTH-1):0] evn_out_0, evn_out_1, odd_out_0, odd_out_1;\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n\t\t\tevn_out_0 <= mem_e[{~iaddr[LGSIZE-1],1\'b0,braddr}];\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n\t\t\tevn_out_1 <= mem_e[{~iaddr[LGSIZE-1],1\'b1,braddr}];\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n\t\t\todd_out_0 <= mem_o[{~iaddr[LGSIZE-1],1\'b0,braddr}];\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n\t\t\todd_out_1 <= mem_o[{~iaddr[LGSIZE-1],1\'b1,braddr}];\n"
"\n"
	"\treg\tadrz;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce) adrz = iaddr[LGSIZE-2];\n"
"\n"
	"\tassign\to_out_0 = (adrz)?odd_out_0:evn_out_0;\n"
	"\tassign\to_out_1 = (adrz)?odd_out_1:evn_out_1;\n"
"\n"
"endmodule\n");

	fclose(fp);
}

void	build_butterfly(const char *fname, int xtracbits, ROUND_T rounding) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}
	const	char	*rnd_string;
	if (rounding == RND_TRUNCATE)
		rnd_string = "truncate";
	else if (rounding == RND_FROMZERO)
		rnd_string = "roundfromzero";
	else if (rounding == RND_HALFUP)
		rnd_string = "roundhalfup";
	else
		rnd_string = "convround";

	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename:	butterfly.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This routine caculates a butterfly for a decimation\n"
"//		in frequency version of an FFT.  Specifically, given\n"
"//		complex Left and Right values together with a \n"
"//		coefficient, the output of this routine is given\n"
"//		by:\n"
"//\n"
"//		L' = L + R\n"
"//		R' = (L - R)*C\n"
"//\n"
"//		The rest of the junk below handles timing (mostly),\n"
"//		to make certain that L' and R' reach the output at\n"
"//		the same clock.  Further, just to make certain\n"
"//		that is the case, an 'aux' input exists.  This\n"
"//		aux value will come out of this routine synchronized\n"
"//		to the values it came in with.  (i.e., both L', R',\n"
"//		and aux all have the same delay.)  Hence, a caller\n"
"//		of this routine may set aux on the first input with\n"
"//		valid data, and then wait to see aux set on the output\n"
"//		to know when to find the first output with valid data.\n"
"//\n"
"//		All bits are preserved until the very last clock,\n"
"//		where any more bits than OWIDTH will be quietly\n"
"//		discarded.\n"
"//\n"
"//		This design features no overflow checking.\n"
"// \n"
"// Notes:\n"
"//		CORDIC:\n"
"//		Much as we would like, we can't use a cordic here.\n"
"//		The goal is to accomplish an FFT, as defined, and a\n"
"//		CORDIC places a scale factor onto the data.  Removing\n"
"//		the scale factor would cost a two multiplies, which\n"
"//		is precisely what we are trying to avoid.\n"
"//\n"
"//\n"
"//		3-MULTIPLIES:\n"
"//		It should also be possible to do this with three \n"
"//		multiplies and an extra two addition cycles.  \n"
"//\n"
"//		We want\n"
"//			R+I = (a + jb) * (c + jd)\n"
"//			R+I = (ac-bd) + j(ad+bc)\n"
"//		We multiply\n"
"//			P1 = ac\n"
"//			P2 = bd\n"
"//			P3 = (a+b)(c+d)\n"
"//		Then \n"
"//			R+I=(P1-P2)+j(P3-P2-P1)\n"
"//\n"
"//		WIDTHS:\n"
"//		On multiplying an X width number by an\n"
"//		Y width number, X>Y, the result should be (X+Y)\n"
"//		bits, right?\n"
"//		-2^(X-1) <= a <= 2^(X-1) - 1\n"
"//		-2^(Y-1) <= b <= 2^(Y-1) - 1\n"
"//		(2^(Y-1)-1)*(-2^(X-1)) <= ab <= 2^(X-1)2^(Y-1)\n"
"//		-2^(X+Y-2)+2^(X-1) <= ab <= 2^(X+Y-2) <= 2^(X+Y-1) - 1\n"
"//		-2^(X+Y-1) <= ab <= 2^(X+Y-1)-1\n"
"//		YUP!  But just barely.  Do this and you'll really want\n"
"//		to drop a bit, although you will risk overflow in so\n"
"//		doing.\n"
"//\n"
"//	20150602 -- The sync logic lines have been completely redone.  The\n"
"//		synchronization lines no longer go through the FIFO with the\n"
"//		left hand sum, but are kept out of memory.  This allows the\n"
"//		butterfly to use more optimal memory resources, while also\n"
"//		guaranteeing that the sync lines can be properly reset upon\n"
"//		any reset signal.\n"
"//\n"
"//\n%s"
"//\n", prjname, creator);
	fprintf(fp, "%s", cpyleft);

	fprintf(fp,
"module\tbutterfly(i_clk, i_rst, i_ce, i_coef, i_left, i_right, i_aux,\n"
		"\t\to_left, o_right, o_aux);\n"
	"\t// Public changeable parameters ...\n"
	"\tparameter IWIDTH=%d,CWIDTH=IWIDTH+%d,OWIDTH=IWIDTH+1;\n"
	"\t// Parameters specific to the core that should not be changed.\n"
	"\tparameter	MPYDELAY=%d'd%d, // (IWIDTH+1 < CWIDTH)?(IWIDTH+4):(CWIDTH+3),\n"
			"\t\t\tSHIFT=0, AUXLEN=%d;\n"
	"\t// The LGDELAY should be the base two log of the MPYDELAY.  If\n"
	"\t// this value is fractional, then round up to the nearest\n"
	"\t// integer: LGDELAY=ceil(log(MPYDELAY)/log(2));\n"
	"\tparameter\tLGDELAY=%d;\n"
	"\tinput\t\ti_clk, i_rst, i_ce;\n"
	"\tinput\t\t[(2*CWIDTH-1):0] i_coef;\n"
	"\tinput\t\t[(2*IWIDTH-1):0] i_left, i_right;\n"
	"\tinput\t\ti_aux;\n"
	"\toutput\twire	[(2*OWIDTH-1):0] o_left, o_right;\n"
	"\toutput\treg\to_aux;\n"
	"\n", 16, xtracbits, lgdelay(16,xtracbits),
	bflydelay(16, xtracbits), bflydelay(16, xtracbits)+3,
		lgdelay(16,xtracbits));
	fprintf(fp,
	"\twire\t[(OWIDTH-1):0]	o_left_r, o_left_i, o_right_r, o_right_i;\n"
"\n"
	"\treg\t[(2*IWIDTH-1):0]\tr_left, r_right;\n"
	"\treg\t\t\t\tr_aux, r_aux_2;\n"
	"\treg\t[(2*CWIDTH-1):0]\tr_coef, r_coef_2;\n"
	"\twire\tsigned\t[(IWIDTH-1):0]\tr_left_r, r_left_i, r_right_r, r_right_i;\n"
	"\tassign\tr_left_r  = r_left[ (2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\tr_left_i  = r_left[ (IWIDTH-1):0];\n"
	"\tassign\tr_right_r = r_right[(2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\tr_right_i = r_right[(IWIDTH-1):0];\n"
"\n"
	"\treg\tsigned\t[(IWIDTH):0]\tr_sum_r, r_sum_i, r_dif_r, r_dif_i;\n"
"\n"
	"\treg	[(LGDELAY-1):0]	fifo_addr;\n"
	"\twire	[(LGDELAY-1):0]	fifo_read_addr;\n"
	"\tassign\tfifo_read_addr = fifo_addr - MPYDELAY;\n"
	"\treg	[(2*IWIDTH+1):0]	fifo_left [ 0:((1<<LGDELAY)-1)];\n"
"\n");
	fprintf(fp,
	"\t// Set up the input to the multiply\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// One clock just latches the inputs\n"
			"\t\t\tr_left <= i_left;	// No change in # of bits\n"
			"\t\t\tr_right <= i_right;\n"
			"\t\t\tr_coef  <= i_coef;\n"
			"\t\t\t// Next clock adds/subtracts\n"
			"\t\t\tr_sum_r <= r_left_r + r_right_r; // Now IWIDTH+1 bits\n"
			"\t\t\tr_sum_i <= r_left_i + r_right_i;\n"
			"\t\t\tr_dif_r <= r_left_r - r_right_r;\n"
			"\t\t\tr_dif_i <= r_left_i - r_right_i;\n"
			"\t\t\t// Other inputs are simply delayed on second clock\n"
			"\t\t\tr_coef_2<= r_coef;\n"
	"\t\tend\n"
"\n");
	fprintf(fp,
	"\t// Don\'t forget to record the even side, since it doesn\'t need\n"
	"\t// to be multiplied, but yet we still need the results in sync\n"
	"\t// with the answer when it is ready.\n"
	"\tinitial fifo_addr = 0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
			"\t\t\tfifo_addr <= 0;\n"
		"\t\telse if (i_ce)\n"
			"\t\t\t// Need to delay the sum side--nothing else happens\n"
			"\t\t\t// to it, but it needs to stay synchronized with the\n"
			"\t\t\t// right side.\n"
			"\t\t\tfifo_addr <= fifo_addr + 1;\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
			"\t\t\tfifo_left[fifo_addr] <= { r_sum_r, r_sum_i };\n"
"\n"
	"\twire\tsigned\t[(CWIDTH-1):0]	ir_coef_r, ir_coef_i;\n"
	"\tassign\tir_coef_r = r_coef_2[(2*CWIDTH-1):CWIDTH];\n"
	"\tassign\tir_coef_i = r_coef_2[(CWIDTH-1):0];\n"
	"\twire\tsigned\t[((IWIDTH+2)+(CWIDTH+1)-1):0]\tp_one, p_two, p_three;\n"
"\n"
"\n");
	fprintf(fp,
	"\t// Multiply output is always a width of the sum of the widths of\n"
	"\t// the two inputs.  ALWAYS.  This is independent of the number of\n"
	"\t// bits in p_one, p_two, or p_three.  These values needed to \n"
	"\t// accumulate a bit (or two) each.  However, this approach to a\n"
	"\t// three multiply complex multiply cannot increase the total\n"
	"\t// number of bits in our final output.  We\'ll take care of\n"
	"\t// dropping back down to the proper width, OWIDTH, in our routine\n"
	"\t// below.\n"
"\n"
"\n");
	fprintf(fp,
	"\t// We accomplish here \"Karatsuba\" multiplication.  That is,\n"
	"\t// by doing three multiplies we accomplish the work of four.\n"
	"\t// Let\'s prove to ourselves that this works ... We wish to\n"
	"\t// multiply: (a+jb) * (c+jd), where a+jb is given by\n"
	"\t//\ta + jb = r_dif_r + j r_dif_i, and\n"
	"\t//\tc + jd = ir_coef_r + j ir_coef_i.\n"
	"\t// We do this by calculating the intermediate products P1, P2,\n"
	"\t// and P3 as\n"
	"\t//\tP1 = ac\n"
	"\t//\tP2 = bd\n"
	"\t//\tP3 = (a + b) * (c + d)\n"
	"\t// and then complete our final answer with\n"
	"\t//\tac - bd = P1 - P2 (this checks)\n"
	"\t//\tad + bc = P3 - P2 - P1\n"
	"\t//\t        = (ac + bc + ad + bd) - bd - ac\n"
	"\t//\t        = bc + ad (this checks)\n"
"\n"
"\n");
	fprintf(fp,
	"\t// This should really be based upon an IF, such as in\n"
	"\t// if (IWIDTH < CWIDTH) then ...\n"
	"\t// However, this is the only (other) way I know to do it.\n"
	"\tgenerate\n"
	"\tif (CWIDTH < IWIDTH+1)\n"
	"\tbegin\n"
		"\t\twire\t[(CWIDTH):0]\tp3c_in;\n"
		"\t\twire\t[(IWIDTH+1):0]\tp3d_in;\n"
		"\t\tassign\tp3c_in = ir_coef_i + ir_coef_r;\n"
		"\t\tassign\tp3d_in = r_dif_r + r_dif_i;\n"
		"\n"
		"\t\t// We need to pad these first two multiplies by an extra\n"
		"\t\t// bit just to keep them aligned with the third,\n"
		"\t\t// simpler, multiply.\n"
		"\t\tshiftaddmpy #(CWIDTH+1,IWIDTH+2) p1(i_clk, i_ce,\n"
				"\t\t\t\t{ir_coef_r[CWIDTH-1],ir_coef_r},\n"
				"\t\t\t\t{r_dif_r[IWIDTH],r_dif_r}, p_one);\n"
		"\t\tshiftaddmpy #(CWIDTH+1,IWIDTH+2) p2(i_clk, i_ce,\n"
				"\t\t\t\t{ir_coef_i[CWIDTH-1],ir_coef_i},\n"
				"\t\t\t\t{r_dif_i[IWIDTH],r_dif_i}, p_two);\n"
		"\t\tshiftaddmpy #(CWIDTH+1,IWIDTH+2) p3(i_clk, i_ce,\n"
			"\t\t\t\tp3c_in, p3d_in, p_three);\n"
	"\tend else begin\n"
		"\t\twire\t[(CWIDTH):0]\tp3c_in;\n"
		"\t\twire\t[(IWIDTH+1):0]\tp3d_in;\n"
		"\t\tassign\tp3c_in = ir_coef_i + ir_coef_r;\n"
		"\t\tassign\tp3d_in = r_dif_r + r_dif_i;\n"
		"\n"
		"\t\tshiftaddmpy #(IWIDTH+2,CWIDTH+1) p1a(i_clk, i_ce,\n"
				"\t\t\t\t{r_dif_r[IWIDTH],r_dif_r},\n"
				"\t\t\t\t{ir_coef_r[CWIDTH-1],ir_coef_r}, p_one);\n"
		"\t\tshiftaddmpy #(IWIDTH+2,CWIDTH+1) p2a(i_clk, i_ce,\n"
				"\t\t\t\t{r_dif_i[IWIDTH], r_dif_i},\n"
				"\t\t\t\t{ir_coef_i[CWIDTH-1],ir_coef_i}, p_two);\n"
		"\t\tshiftaddmpy #(IWIDTH+2,CWIDTH+1) p3a(i_clk, i_ce,\n"
				"\t\t\t\tp3d_in, p3c_in, p_three);\n"
	"\tend\n"
	"\tendgenerate\n"
"\n");
	fprintf(fp,
	"\t// These values are held in memory and delayed during the\n"
	"\t// multiply.  Here, we recover them.  During the multiply,\n"
	"\t// values were multiplied by 2^(CWIDTH-2)*exp{-j*2*pi*...},\n"
	"\t// therefore, the left_x values need to be right shifted by\n"
	"\t// CWIDTH-2 as well.  The additional bits come from a sign\n"
	"\t// extension.\n"
	"\twire\tsigned\t[(IWIDTH+CWIDTH):0]	fifo_i, fifo_r;\n"
	"\treg\t\t[(2*IWIDTH+1):0]	fifo_read;\n"
	"\tassign\tfifo_r = { {2{fifo_read[2*(IWIDTH+1)-1]}}, fifo_read[(2*(IWIDTH+1)-1):(IWIDTH+1)], {(CWIDTH-2){1\'b0}} };\n"
	"\tassign\tfifo_i = { {2{fifo_read[(IWIDTH+1)-1]}}, fifo_read[((IWIDTH+1)-1):0], {(CWIDTH-2){1\'b0}} };\n"
"\n"
"\n"
	"\treg\tsigned\t[(OWIDTH-1):0]	b_left_r, b_left_i,\n"
			"\t\t\t\t\t\tb_right_r, b_right_i;\n"
	"\treg\tsigned\t[(CWIDTH+IWIDTH+3-1):0]	mpy_r, mpy_i;\n"
"\n");
	fprintf(fp,
	"\t// Let's do some rounding and remove unnecessary bits.\n"
	"\t// We have (IWIDTH+CWIDTH+3) bits here, we need to drop down to\n"
	"\t// OWIDTH, and SHIFT by SHIFT bits in the process.  The trick is\n"
	"\t// that we don\'t need (IWIDTH+CWIDTH+3) bits.  We\'ve accumulated\n"
	"\t// them, but the actual values will never fill all these bits.\n"
	"\t// In particular, we only need:\n"
	"\t//\t IWIDTH bits for the input\n"
	"\t//\t     +1 bit for the add/subtract\n"
	"\t//\t+CWIDTH bits for the coefficient multiply\n"
	"\t//\t     +1 bit for the add/subtract in the complex multiply\n"
	"\t//\t ------\n"
	"\t//\t (IWIDTH+CWIDTH+2) bits at full precision.\n"
	"\t//\n"
	"\t// However, the coefficient multiply multiplied by a maximum value\n"
	"\t// of 2^(CWIDTH-2).  Thus, we only have\n"
	"\t//\t   IWIDTH bits for the input\n"
	"\t//\t       +1 bit for the add/subtract\n"
	"\t//\t+CWIDTH-2 bits for the coefficient multiply\n"
	"\t//\t       +1 (optional) bit for the add/subtract in the cpx mpy.\n"
	"\t//\t -------- ... multiply.  (This last bit may be shifted out.)\n"
	"\t//\t (IWIDTH+CWIDTH) valid output bits. \n"
	"\t// Now, if the user wants to keep any extras of these (via OWIDTH),\n"
	"\t// or if he wishes to arbitrarily shift some of these off (via\n"
	"\t// SHIFT) we accomplish that here.\n"
"\n");
	fprintf(fp,
	"\twire\tsigned\t[(OWIDTH-1):0]\trnd_left_r, rnd_left_i, rnd_right_r, rnd_right_i;\n\n");

	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_left_r(i_clk, i_ce,\n"
	"\t\t\t\t{ {2{fifo_r[(IWIDTH+CWIDTH)]}}, fifo_r }, rnd_left_r);\n\n",
		rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_left_i(i_clk, i_ce,\n"
	"\t\t\t\t{ {2{fifo_i[(IWIDTH+CWIDTH)]}}, fifo_i }, rnd_left_i);\n\n",
		rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_r(i_clk, i_ce,\n"
	"\t\t\t\tmpy_r, rnd_right_r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_i(i_clk, i_ce,\n"
	"\t\t\t\tmpy_i, rnd_right_i);\n\n", rnd_string);
	fprintf(fp,
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// First clock, recover all values\n"
			"\t\t\tfifo_read <= fifo_left[fifo_read_addr];\n"
			"\t\t\t// These values are IWIDTH+CWIDTH+3 bits wide\n"
			"\t\t\t// although they only need to be (IWIDTH+1)\n"
			"\t\t\t// + (CWIDTH) bits wide.  (We\'ve got two\n"
			"\t\t\t// extra bits we need to get rid of.)\n"
			"\t\t\tmpy_r <= p_one - p_two;\n"
			"\t\t\tmpy_i <= p_three - p_one - p_two;\n"
"\n"
			"\t\t\t// Second clock, round and latch for final clock\n"
			"\t\t\tb_right_r <= rnd_right_r;\n"
			"\t\t\tb_right_i <= rnd_right_i;\n"
			"\t\t\tb_left_r <= rnd_left_r;\n"
			"\t\t\tb_left_i <= rnd_left_i;\n"
		"\t\tend\n"
"\n");

	fprintf(fp,
	"\treg\t[(AUXLEN-1):0]\taux_pipeline;\n"
	"\tinitial\taux_pipeline = 0;\n"
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_rst)\n"
	"\t\t\taux_pipeline <= 0;\n"
	"\t\telse if (i_ce)\n"
	"\t\t\taux_pipeline <= { aux_pipeline[(AUXLEN-2):0], i_aux };\n"
"\n");
	fprintf(fp,
	"\tinitial o_aux = 1\'b0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\t\to_aux <= 1\'b0;\n"
		"\t\telse if (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// Second clock, latch for final clock\n"
			"\t\t\to_aux <= aux_pipeline[AUXLEN-1];\n"
		"\t\tend\n"
"\n");

	fprintf(fp,
	"\t// As a final step, we pack our outputs into two packed two\'s\n"
	"\t// complement numbers per output word, so that each output word\n"
	"\t// has (2*OWIDTH) bits in it, with the top half being the real\n"
	"\t// portion and the bottom half being the imaginary portion.\n"
	"\tassign	o_left = { rnd_left_r, rnd_left_i };\n"
	"\tassign	o_right= { rnd_right_r,rnd_right_i};\n"
"\n"
"endmodule\n");
	fclose(fp);
}

void	build_hwbfly(const char *fname, int xtracbits, ROUND_T rounding) {
	FILE	*fp = fopen(fname, "w");
	if (NULL == fp) {
		fprintf(stderr, "Could not open \'%s\' for writing\n", fname);
		perror("O/S Err was:");
		return;
	}

	const	char	*rnd_string;
	if (rounding == RND_TRUNCATE)
		rnd_string = "truncate";
	else if (rounding == RND_FROMZERO)
		rnd_string = "roundfromzero";
	else if (rounding == RND_HALFUP)
		rnd_string = "roundhalfup";
	else
		rnd_string = "convround";


	fprintf(fp,
"///////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename:	hwbfly.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This routine is identical to the butterfly.v routine found\n"
"//		in 'butterfly.v', save only that it uses the verilog \n"
"//		operator '*' in hopes that the synthesizer would be able\n"
"//		to optimize it with hardware resources.\n"
"//\n"
"//		It is understood that a hardware multiply can complete its\n"
"//		operation in a single clock.\n"
"//\n"
"//\n%s"
"//\n", prjname, creator);
	fprintf(fp, "%s", cpyleft);
	fprintf(fp,
"module	hwbfly(i_clk, i_rst, i_ce, i_coef, i_left, i_right, i_aux,\n"
		"\t\to_left, o_right, o_aux);\n"
	"\t// Public changeable parameters ...\n"
	"\tparameter IWIDTH=16,CWIDTH=IWIDTH+%d,OWIDTH=IWIDTH+1;\n"
	"\t// Parameters specific to the core that should not be changed.\n"
	"\tparameter\tSHIFT=0;\n"
	"\tinput\t\ti_clk, i_rst, i_ce;\n"
	"\tinput\t\t[(2*CWIDTH-1):0]\ti_coef;\n"
	"\tinput\t\t[(2*IWIDTH-1):0]\ti_left, i_right;\n"
	"\tinput\t\ti_aux;\n"
	"\toutput\twire\t[(2*OWIDTH-1):0]\to_left, o_right;\n"
	"\toutput\treg\to_aux;\n"
"\n", xtracbits);
	fprintf(fp,
	"\twire\t[(OWIDTH-1):0]	o_left_r, o_left_i, o_right_r, o_right_i;\n"
"\n"
	"\treg\t[(2*IWIDTH-1):0]	r_left, r_right;\n"
	"\treg\t			r_aux, r_aux_2;\n"
	"\treg\t[(2*CWIDTH-1):0]	r_coef, r_coef_2;\n"
	"\twire	signed	[(IWIDTH-1):0]	r_left_r, r_left_i, r_right_r, r_right_i;\n"
	"\tassign\tr_left_r  = r_left[ (2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\tr_left_i  = r_left[ (IWIDTH-1):0];\n"
	"\tassign\tr_right_r = r_right[(2*IWIDTH-1):(IWIDTH)];\n"
	"\tassign\tr_right_i = r_right[(IWIDTH-1):0];\n"
	"\treg	signed	[(CWIDTH-1):0]	ir_coef_r, ir_coef_i;\n"
"\n"
	"\treg	signed	[(IWIDTH):0]	r_sum_r, r_sum_i, r_dif_r, r_dif_i;\n"
"\n"
	"\treg	[(2*IWIDTH+2):0]	leftv, leftvv;\n"
"\n"
	"\t// Set up the input to the multiply\n"
	"\tinitial r_aux   = 1\'b0;\n"
	"\tinitial r_aux_2 = 1\'b0;\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
		"\t\tbegin\n"
			"\t\t\tr_aux <= 1\'b0;\n"
			"\t\t\tr_aux_2 <= 1\'b0;\n"
		"\t\tend else if (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// One clock just latches the inputs\n"
			"\t\t\tr_aux <= i_aux;\n"
			"\t\t\t// Next clock adds/subtracts\n"
			"\t\t\t// Other inputs are simply delayed on second clock\n"
			"\t\t\tr_aux_2 <= r_aux;\n"
		"\t\tend\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// One clock just latches the inputs\n"
			"\t\t\tr_left <= i_left;	// No change in # of bits\n"
			"\t\t\tr_right <= i_right;\n"
			"\t\t\tr_coef  <= i_coef;\n"
			"\t\t\t// Next clock adds/subtracts\n"
			"\t\t\tr_sum_r <= r_left_r + r_right_r; // Now IWIDTH+1 bits\n"
			"\t\t\tr_sum_i <= r_left_i + r_right_i;\n"
			"\t\t\tr_dif_r <= r_left_r - r_right_r;\n"
			"\t\t\tr_dif_i <= r_left_i - r_right_i;\n"
			"\t\t\t// Other inputs are simply delayed on second clock\n"
			"\t\t\tir_coef_r <= r_coef[(2*CWIDTH-1):CWIDTH];\n"
			"\t\t\tir_coef_i <= r_coef[(CWIDTH-1):0];\n"
		"\t\tend\n"
	"\n\n");
	fprintf(fp,
"\t// See comments in the butterfly.v source file for a discussion of\n"
"\t// these operations and the appropriate bit widths.\n\n");
	fprintf(fp, 
	"\treg\tsigned	[((IWIDTH+1)+(CWIDTH)-1):0]	p_one, p_two;\n"
	"\treg\tsigned	[((IWIDTH+2)+(CWIDTH+1)-1):0]	p_three;\n"
"\n"
	"\treg\tsigned	[(CWIDTH-1):0]	p1c_in, p2c_in; // Coefficient multiply inputs\n"
	"\treg\tsigned	[(IWIDTH):0]	p1d_in, p2d_in; // Data multiply inputs\n"
	"\treg\tsigned	[(CWIDTH):0]	p3c_in; // Product 3, coefficient input\n"
	"\treg\tsigned	[(IWIDTH+1):0]	p3d_in; // Product 3, data input\n"
"\n"
	"\tinitial leftv    = 0;\n"
	"\tinitial leftvv   = 0;\n"
	"\talways @(posedge i_clk)\n"
	"\tbegin\n"
		"\t\tif (i_rst)\n"
		"\t\tbegin\n"
			"\t\t\tleftv <= 0;\n"
			"\t\t\tleftvv <= 0;\n"
		"\t\tend else if (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// Second clock, pipeline = 1\n"
			"\t\t\tleftv <= { r_aux_2, r_sum_r, r_sum_i };\n"
"\n"
			"\t\t\t// Third clock, pipeline = 3\n"
			"\t\t\t//   As desired, each of these lines infers a DSP48\n"
			"\t\t\tleftvv <= leftv;\n"
		"\t\tend\n"
	"\tend\n"
"\n"
	"\talways @(posedge i_clk)\n"
		"\t\tif (i_ce)\n"
		"\t\tbegin\n"
			"\t\t\t// Second clock, pipeline = 1\n"
			"\t\t\tp1c_in <= ir_coef_r;\n"
			"\t\t\tp2c_in <= ir_coef_i;\n"
			"\t\t\tp1d_in <= r_dif_r;\n"
			"\t\t\tp2d_in <= r_dif_i;\n"
			"\t\t\tp3c_in <= ir_coef_i + ir_coef_r;\n"
			"\t\t\tp3d_in <= r_dif_r + r_dif_i;\n"
"\n"
"\n"
			"\t\t\t// Third clock, pipeline = 3\n"
			"\t\t\t//   As desired, each of these lines infers a DSP48\n"
			"\t\t\tp_one   <= p1c_in * p1d_in;\n"
			"\t\t\tp_two   <= p2c_in * p2d_in;\n"
			"\t\t\tp_three <= p3c_in * p3d_in;\n"
		"\t\tend\n"
"\n"
	"\twire\tsigned	[((IWIDTH+2)+(CWIDTH+1)-1):0]	w_one, w_two;\n"
	"\tassign\tw_one = { {(2){p_one[((IWIDTH+1)+(CWIDTH)-1)]}}, p_one };\n"
	"\tassign\tw_two = { {(2){p_two[((IWIDTH+1)+(CWIDTH)-1)]}}, p_two };\n"
"\n");

	fprintf(fp, 
	"\t// These values are held in memory and delayed during the\n"
	"\t// multiply.  Here, we recover them.  During the multiply,\n"
	"\t// values were multiplied by 2^(CWIDTH-2)*exp{-j*2*pi*...},\n"
	"\t// therefore, the left_x values need to be right shifted by\n"
	"\t// CWIDTH-2 as well.  The additional bits come from a sign\n"
	"\t// extension.\n"
	"\twire\taux_s;\n"
	"\twire\tsigned\t[(IWIDTH+CWIDTH):0]	left_si, left_sr;\n"
	"\treg\t\t[(2*IWIDTH+2):0]	left_saved;\n"
	"\tassign\tleft_sr = { {2{left_saved[2*(IWIDTH+1)-1]}}, left_saved[(2*(IWIDTH+1)-1):(IWIDTH+1)], {(CWIDTH-2){1\'b0}} };\n"
	"\tassign\tleft_si = { {2{left_saved[(IWIDTH+1)-1]}}, left_saved[((IWIDTH+1)-1):0], {(CWIDTH-2){1\'b0}} };\n"
	"\tassign\taux_s = left_saved[2*IWIDTH+2];\n"
"\n"
"\n"
	"\t(* use_dsp48=\"no\" *)\n"
	"\treg	signed	[(CWIDTH+IWIDTH+3-1):0]	mpy_r, mpy_i;\n");
	fprintf(fp,
	"\twire\tsigned\t[(OWIDTH-1):0]\trnd_left_r, rnd_left_i, rnd_right_r, rnd_right_i;\n\n");

	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+1,OWIDTH,SHIFT+2) do_rnd_left_r(i_clk, i_ce,\n"
	"\t\t\t\tleft_sr, rnd_left_r);\n\n",
		rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+1,OWIDTH,SHIFT+2) do_rnd_left_i(i_clk, i_ce,\n"
	"\t\t\t\tleft_si, rnd_left_i);\n\n",
		rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_r(i_clk, i_ce,\n"
	"\t\t\t\tmpy_r, rnd_right_r);\n\n", rnd_string);
	fprintf(fp,
	"\t%s #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_i(i_clk, i_ce,\n"
	"\t\t\t\tmpy_i, rnd_right_i);\n\n", rnd_string);

	fprintf(fp,
	"\tinitial left_saved = 0;\n"
	"\tinitial o_aux      = 1\'b0;\n"
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_rst)\n"
	"\t\tbegin\n"
		"\t\t\tleft_saved <= 0;\n"
		"\t\t\to_aux <= 1\'b0;\n"
	"\t\tend else if (i_ce)\n"
	"\t\tbegin\n"
		"\t\t\t// First clock, recover all values\n"
		"\t\t\tleft_saved <= leftvv;\n"
"\n"
		"\t\t\t// Second clock, round and latch for final clock\n"
		"\t\t\to_aux <= aux_s;\n"
	"\t\tend\n"
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_ce)\n"
	"\t\tbegin\n"
		"\t\t\t// These values are IWIDTH+CWIDTH+3 bits wide\n"
		"\t\t\t// although they only need to be (IWIDTH+1)\n"
		"\t\t\t// + (CWIDTH) bits wide.  (We've got two\n"
		"\t\t\t// extra bits we need to get rid of.)\n"
		"\n"
		"\t\t\t// These two lines also infer DSP48\'s.\n"
		"\t\t\t// To keep from using extra DSP48 resources,\n"
		"\t\t\t// they are prevented from using DSP48\'s\n"
		"\t\t\t// by the (* use_dsp48 ... *) comment above.\n"
		"\t\t\tmpy_r <= w_one - w_two;\n"
		"\t\t\tmpy_i <= p_three - w_one - w_two;\n"
	"\t\tend\n"
	"\n");

	fprintf(fp,
	"\t// As a final step, we pack our outputs into two packed two's\n"
	"\t// complement numbers per output word, so that each output word\n"
	"\t// has (2*OWIDTH) bits in it, with the top half being the real\n"
	"\t// portion and the bottom half being the imaginary portion.\n"
	"\tassign\to_left = { rnd_left_r, rnd_left_i };\n"
	"\tassign\to_right= { rnd_right_r,rnd_right_i};\n"
"\n"
"endmodule\n");

}

void	build_stage(const char *fname, const char *coredir, int stage, bool odd, int nbits, bool inv, int xtra, bool hwmpy=false, bool dbg=false) {
	FILE	*fstage = fopen(fname, "w");
	int	cbits = nbits + xtra;

	if ((cbits * 2) >= sizeof(long long)*8) {
		fprintf(stderr, "ERROR: CMEM Coefficient precision requested overflows long long data type.\n");
		exit(-1);
	}

	if (fstage == NULL) {
		fprintf(stderr, "ERROR: Could not open %s for writing!\n", fname);
		perror("O/S Err was:");
		fprintf(stderr, "Attempting to continue, but this file will be missing.\n");
		return;
	}

	fprintf(fstage,
"////////////////////////////////////////////////////////////////////////////\n"
"//\n"
"// Filename: 	%sfftstage_%c%d%s.v\n"
"//\n"
"// Project:	%s\n"
"//\n"
"// Purpose:	This file is (almost) a Verilog source file.  It is meant to\n"
"//		be used by a FFT core compiler to generate FFTs which may be\n"
"//		used as part of an FFT core.  Specifically, this file \n"
"//		encapsulates the options of an FFT-stage.  For any 2^N length\n"
"//		FFT, there shall be (N-1) of these stages.  \n"
"//\n%s"
"//\n",
		(inv)?"i":"", (odd)?'o':'e', stage*2, (dbg)?"_dbg":"", prjname, creator);
	fprintf(fstage, "%s", cpyleft);
	fprintf(fstage, "module\t%sfftstage_%c%d%s(i_clk, i_rst, i_ce, i_sync, i_data, o_data, o_sync%s);\n",
		(inv)?"i":"", (odd)?'o':'e', stage*2, (dbg)?"_dbg":"",
		(dbg)?", o_dbg":"");
	// These parameter values are useless at this point--they are to be
	// replaced by the parameter values in the calling program.  Only
	// problem is, the CWIDTH needs to match exactly!
	fprintf(fstage, "\tparameter\tIWIDTH=%d,CWIDTH=%d,OWIDTH=%d;\n",
		nbits, cbits, nbits+1);
	fprintf(fstage,
"\t// Parameters specific to the core that should be changed when this\n"
"\t// core is built ... Note that the minimum LGSPAN (the base two log\n"
"\t// of the span, or the base two log of the current FFT size) is 3.\n"
"\t// Smaller spans (i.e. the span of 2) must use the dblstage module.\n"
"\tparameter\tLGWIDTH=11, LGSPAN=9, LGBDLY=5, BFLYSHIFT=0;\n");
	fprintf(fstage, 
"\tinput					i_clk, i_rst, i_ce, i_sync;\n"
"\tinput		[(2*IWIDTH-1):0]	i_data;\n"
"\toutput	reg	[(2*OWIDTH-1):0]	o_data;\n"
"\toutput	reg				o_sync;\n"
"\n");
	if (dbg) { fprintf(fstage, "\toutput\twire\t[33:0]\t\t\to_dbg;\n"
		"\tassign\to_dbg = { ((o_sync)&&(i_ce)), i_ce, o_data[(2*OWIDTH-1):(2*OWIDTH-16)],\n"
			"\t\t\t\t\to_data[(OWIDTH-1):(OWIDTH-16)] };\n"
"\n");
	}
	fprintf(fstage, 
"\treg	wait_for_sync;\n"
"\treg	[(2*IWIDTH-1):0]	ib_a, ib_b;\n"
"\treg	[(2*CWIDTH-1):0]	ib_c;\n"
"\treg	ib_sync;\n"
"\n"
"\treg	b_started;\n"
"\twire	ob_sync;\n"
"\twire	[(2*OWIDTH-1):0]\tob_a, ob_b;\n");
	fprintf(fstage, 
"\n"
"\t// %scmem is defined as an array of real and complex values,\n"
"\t// where the top CWIDTH bits are the real value and the bottom\n"
"\t// CWIDTH bits are the imaginary value.\n"
"\t//\n"
"\t// %scmem[i] = { (2^(CWIDTH-2)) * cos(2*pi*i/(2^LGWIDTH)),\n"
"\t//		(2^(CWIDTH-2)) * sin(2*pi*i/(2^LGWIDTH)) };\n"
"\t//\n"
"\treg	[(2*CWIDTH-1):0]	%scmem [0:((1<<LGSPAN)-1)];\n"
"\tinitial\t$readmemh(\"%scmem_%c%d.hex\",%scmem);\n\n",
		(inv)?"i":"", (inv)?"i":"", (inv)?"i":"",
		(inv)?"i":"", (odd)?'o':'e',stage<<1, (inv)?"i":"");
	{
		FILE	*cmem;

		{
			char	*memfile, *ptr;

			memfile = new char[strlen(fname)+128];
			strcpy(memfile, fname);
			if ((NULL != (ptr = strrchr(memfile, '/')))&&(ptr>memfile)) {
				ptr++;
				sprintf(ptr, "%scmem_%c%d.hex", (inv)?"i":"", (odd)?'o':'e', stage*2);
			} else {
				sprintf(memfile, "%s/%scmem_%c%d.hex",
					coredir, (inv)?"i":"",
					(odd)?'o':'e', stage*2);
			}
			// strcpy(&memfile[strlen(memfile)-2], ".hex");
			cmem = fopen(memfile, "w");
			if (NULL == cmem) {
				fprintf(stderr, "Could not open/write \'%s\' with FFT coefficients.\n", memfile);
				perror("Err from O/S:");
				exit(-2);
			}

			delete[] memfile;
		}
		// fprintf(cmem, "// CBITS = %d, inv = %s\n", cbits, (inv)?"true":"false");
		for(int i=0; i<stage/2; i++) {
			int k = 2*i+odd;
			double	W = ((inv)?1:-1)*2.0*M_PI*k/(double)(2*stage);
			double	c, s;
			long long ic, is, vl;

			c = cos(W); s = sin(W);
			ic = (long long)round((1ll<<(cbits-2)) * c);
			is = (long long)round((1ll<<(cbits-2)) * s);
			vl = (ic & (~(-1ll << (cbits))));
			vl <<= (cbits);
			vl |= (is & (~(-1ll << (cbits))));
			fprintf(cmem, "%0*llx\n", ((cbits*2+3)/4), vl);
			/*
			fprintf(cmem, "%0*llx\t\t// %f+j%f -> %llx +j%llx\n",
				((cbits*2+3)/4), vl, c, s,
				ic & (~(-1ll<<(((cbits+3)/4)*4))),
				is & (~(-1ll<<(((cbits+3)/4)*4))));
			*/
		} fclose(cmem);
	}

	fprintf(fstage,
"\treg	[(LGWIDTH-2):0]		iaddr;\n"
"\treg	[(2*IWIDTH-1):0]	imem	[0:((1<<LGSPAN)-1)];\n"
"\n"
"\treg	[LGSPAN:0]		oB;\n"
"\treg	[(2*OWIDTH-1):0]	omem	[0:((1<<LGSPAN)-1)];\n"
"\n"
"\tinitial wait_for_sync = 1\'b1;\n"
"\tinitial iaddr = 0;\n"
"\talways @(posedge i_clk)\n"
	"\t\tif (i_rst)\n"
	"\t\tbegin\n"
		"\t\t\twait_for_sync <= 1\'b1;\n"
		"\t\t\tiaddr <= 0;\n"
	"\t\tend\n"
	"\t\telse if ((i_ce)&&((~wait_for_sync)||(i_sync)))\n"
	"\t\tbegin\n"
		"\t\t\t//\n"
		"\t\t\t// First step: Record what we\'re not ready to use yet\n"
		"\t\t\t//\n"
		"\t\t\tiaddr <= iaddr + { {(LGWIDTH-2){1\'b0}}, 1\'b1 };\n"
		"\t\t\twait_for_sync <= 1\'b0;\n"
	"\t\tend\n"
"\talways @(posedge i_clk) // Need to make certain here that we don\'t read\n"
	"\t\tif ((i_ce)&&(~iaddr[LGSPAN])) // and write the same address on\n"
		"\t\t\timem[iaddr[(LGSPAN-1):0]] <= i_data; // the same clk\n"
	"\n");

	fprintf(fstage,
	"\t//\n"
	"\t// Now, we have all the inputs, so let\'s feed the butterfly\n"
	"\t//\n"
	"\tinitial ib_sync = 1\'b0;\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif (i_rst)\n"
			"\t\t\tib_sync <= 1\'b0;\n"
		"\t\telse if ((i_ce)&&(iaddr[LGSPAN]))\n"
			"\t\t\tbegin\n"
				"\t\t\t\t// Set the sync to true on the very first\n"
				"\t\t\t\t// valid input in, and hence on the very\n"
				"\t\t\t\t// first valid data out per FFT.\n"
				"\t\t\t\tib_sync <= (iaddr==(1<<(LGSPAN)));\n"
			"\t\t\tend\n"
	"\talways\t@(posedge i_clk)\n"
		"\t\tif ((i_ce)&&(iaddr[LGSPAN]))\n"
		"\t\t\tbegin\n"
			"\t\t\t\t// One input from memory, ...\n"
			"\t\t\t\tib_a <= imem[iaddr[(LGSPAN-1):0]];\n"
			"\t\t\t\t// One input clocked in from the top\n"
			"\t\t\t\tib_b <= i_data;\n"
			"\t\t\t\t// and the coefficient or twiddle factor\n"
			"\t\t\t\tib_c <= %scmem[iaddr[(LGSPAN-1):0]];\n"
		"\t\t\tend\n\n", (inv)?"i":"");

	if (hwmpy) {
		fprintf(fstage,
	"\thwbfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),\n"
			"\t\t\t.SHIFT(BFLYSHIFT))\n"
		"\t\tbfly(i_clk, i_rst, i_ce, ib_c,\n"
			"\t\t\tib_a, ib_b, ib_sync, ob_a, ob_b, ob_sync);\n");
	} else {
	fprintf(fstage,
	"\tbutterfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),\n"
		"\t\t\t.MPYDELAY(%d\'d%d),.LGDELAY(LGBDLY),.SHIFT(BFLYSHIFT))\n"
	"\t\tbfly(i_clk, i_rst, i_ce, ib_c,\n"
		"\t\t\tib_a, ib_b, ib_sync, ob_a, ob_b, ob_sync);\n",
			lgdelay(nbits, xtra), bflydelay(nbits, xtra));
	}

	fprintf(fstage,
	"\t//\n"
	"\t// Next step: recover the outputs from the butterfly\n"
	"\t//\n"
	"\tinitial oB        = 0;\n"
	"\tinitial o_sync    = 0;\n"
	"\tinitial b_started = 0;\n"
	"\talways\t@(posedge i_clk)\n"
	"\t\tif (i_rst)\n"
	"\t\tbegin\n"
		"\t\t\toB <= 0;\n"
		"\t\t\to_sync <= 0;\n"
		"\t\t\tb_started <= 0;\n"
	"\t\tend else if (i_ce)\n"
	"\t\tbegin\n"
	"\t\t\to_sync <= (~oB[LGSPAN])?ob_sync : 1\'b0;\n"
	"\t\t\tif (ob_sync||b_started)\n"
		"\t\t\t\toB <= oB + { {(LGSPAN){1\'b0}}, 1\'b1 };\n"
	"\t\t\tif ((ob_sync)&&(~oB[LGSPAN]))\n"
		"\t\t\t// A butterfly output is available\n"
			"\t\t\t\tb_started <= 1\'b1;\n"
	"\t\tend\n\n");
	fprintf(fstage,
	"\treg	[(LGSPAN-1):0]\t\tdly_addr;\n"
	"\treg	[(2*OWIDTH-1):0]\tdly_value;\n"
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_ce)\n"
	"\t\tbegin\n"
	"\t\t\tdly_addr <= oB[(LGSPAN-1):0];\n"
	"\t\t\tdly_value <= ob_b;\n"
	"\t\tend\n"
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_ce)\n"
		"\t\t\tomem[dly_addr] <= dly_value;\n"
"\n");
	fprintf(fstage,
	"\talways @(posedge i_clk)\n"
	"\t\tif (i_ce)\n"
	"\t\t\to_data <= (~oB[LGSPAN])?ob_a : omem[oB[(LGSPAN-1):0]];\n"
"\n");
	fprintf(fstage, "endmodule\n");
}

void	usage(void) {
	fprintf(stderr,
"USAGE:\tfftgen [-f <size>] [-d dir] [-c cbits] [-n nbits] [-m mxbits] [-s]\n"
// "\tfftgen -i\n"
"\t-1\tBuild a normal FFT, running at one clock per complex sample, or (for\n"
"\t\ta real FFT) at one clock per two real input samples.\n"
"\t-c <cbits>\tCauses all internal complex coefficients to be\n"
"\t\tlonger than the corresponding data bits, to help avoid\n"
"\t\tcoefficient truncation errors.  The default is %d bits lnoger\n"
"\t\tthan the data bits.\n"
"\t-d <dir>\tPlaces all of the generated verilog files into <dir>.\n"
"\t\tThe default is a subdirectory of the current directory named %s.\n"
"\t-f <size>\tSets the size of the FFT as the number of complex\n"
"\t\tsamples input to the transform.  (No default value, this is\n"
"\t\ta required parameter.)\n"
"\t-i\tAn inverse FFT, meaning that the coefficients are\n"
"\t\tgiven by e^{ j 2 pi k/N n }.  The default is a forward FFT, with\n"
"\t\tcoefficients given by e^{ -j 2 pi k/N n }.\n"
"\t-m <mxbits>\tSets the maximum bit width that the FFT should ever\n"
"\t\tproduce.  Internal values greater than this value will be\n"
"\t\ttruncated to this value.  (The default value grows the input\n"
"\t\tsize by one bit for every two FFT stages.)\n"
"\t-n <nbits>\tSets the bitwidth for values coming into the (i)FFT.\n"
"\t\tThe default is %d bits input for each component of the two\n"
"\t\tcomplex values into the FFT.\n"
"\t-p <nmpy>\tSets the number of stages that will use any hardware \n"
"\t\tmultiplication facility, instead of shift-add emulation.\n"
"\t\tThree multiplies per butterfly, or six multiplies per stage will\n"
"\t\tbe accelerated in this fashion.  The default is not to use any\n"
"\t\thardware multipliers.\n"
"\t-r\tBuild a real-FFT at four input points per sample, rather than a\n"
"\t\tcomplex FFT.  (Default is a Complex FFT.)\n"
"\t-s\tSkip the final bit reversal stage.  This is useful in\n"
"\t\talgorithms that need to apply a filter without needing to do\n"
"\t\tbin shifting, as these algorithms can, with this option, just\n"
"\t\tmultiply by a bit reversed correlation sequence and then\n"
"\t\tinverse FFT the (still bit reversed) result.  (You would need\n"
"\t\ta decimation in time inverse to do this, which this program does\n"
"\t\tnot yet provide.)\n"
"\t-S\tInclude the final bit reversal stage (default).\n"
"\t-x <xtrabits>\tUse this many extra bits internally, before any final\n"
"\t\trounding or truncation of the answer to the final number of bits.\n"
"\t\tThe default is to use %d extra bits internally.\n",
/*
"\t-0\tA forward FFT (default), meaning that the coefficients are\n"
"\t\tgiven by e^{-j 2 pi k/N n }.\n"
"\t-1\tAn inverse FFT, meaning that the coefficients are\n"
"\t\tgiven by e^{ j 2 pi k/N n }.\n",
*/
	DEF_XTRACBITS, DEF_COREDIR, DEF_NBITSIN, DEF_XTRAPBITS);
}

// Features still needed:
//	Interactivity.
int main(int argc, char **argv) {
	int	fftsize = -1, lgsize = -1;
	int	nbitsin = DEF_NBITSIN, xtracbits = DEF_XTRACBITS,
			nummpy=DEF_NMPY, nonmpy=2;
	int	nbitsout, maxbitsout = -1, xtrapbits=DEF_XTRAPBITS;
	bool	bitreverse = true, inverse=false,
		verbose_flag = false, single_clock = false,
		real_fft = false;
	FILE	*vmain;
	std::string	coredir = DEF_COREDIR, cmdline = "";
	ROUND_T	rounding = RND_CONVERGENT;
	// ROUND_T	rounding = RND_HALFUP;

	bool	dbg = false;
	int	dbgstage = 128;

	if (argc <= 1)
		usage();

	cmdline = argv[0];
	for(int argn=1; argn<argc; argn++) {
		cmdline += " ";
		cmdline += argv[argn];
	}

	for(int argn=1; argn<argc; argn++) {
		if ('-' == argv[argn][0]) {
			for(int j=1; (argv[argn][j])&&(j<100); j++) {
				switch(argv[argn][j]) {
					/*
					case '0':
						inverse = false;
						break;
					*/
					case '1':
						single_clock = true;
						break;
					case 'c':
						if (argn+1 >= argc) {
							printf("ERR: No extra number of coefficient bits given!\n\n");
							usage(); exit(-1);
						}
						xtracbits = atoi(argv[++argn]);
						j+= 200;
						break;
					case 'd':
						if (argn+1 >= argc) {
							printf("ERR: No directory given into which to place the core!\n\n");
							usage(); exit(-1);
						}
						coredir = argv[++argn];
						j += 200;
						break;
					case 'D':
						dbg = true;
						if (argn+1 >= argc) {
							printf("ERR: No debug stage number given!\n\n");
							usage(); exit(-1);
						}
						dbgstage = atoi(argv[++argn]);
						j+= 200;
						break;
					case 'f':
						if (argn+1 >= argc) {
							printf("ERR: No FFT Size given!\n\n");
							usage(); exit(-1);
						}
						fftsize = atoi(argv[++argn]);
						{ int sln = strlen(argv[argn]);
						if (!isdigit(argv[argn][sln-1])){
							switch(argv[argn][sln-1]) {
							case 'k': case 'K':
								fftsize <<= 10;
								break;
							case 'm': case 'M':
								fftsize <<= 20;
								break;
							case 'g': case 'G':
								fftsize <<= 30;
								break;
							default:
								printf("ERR: Unknown FFT size, %s!\n", argv[argn]);
								exit(-1);
							}
						}}
						j += 200;
						break;
					case 'h':
						usage();
						exit(0);
						break;
					case 'i':
						inverse = true;
						break;
					case 'm':
						if (argn+1 >= argc) {
							printf("ERR: No maximum output bit value given!\n\n");
							exit(-1);
						}
						maxbitsout = atoi(argv[++argn]);
						j += 200;
						break;
					case 'n':
						if (argn+1 >= argc) {
							printf("ERR: No input bit size given!\n\n");
							exit(-1);
						}
						nbitsin = atoi(argv[++argn]);
						j += 200;
						break;
					case 'p':
						if (argn+1 >= argc) {
							printf("ERR: No number given for number of hardware multiply stages!\n\n");
							exit(-1);
						}
						nummpy = atoi(argv[++argn]);
						j += 200;
						break;
					case 'r':
						real_fft = true;
						break;
					case 'S':
						bitreverse = true;
						break;
					case 's':
						bitreverse = false;
						break;
					case 'x':
						if (argn+1 >= argc) {
							printf("ERR: No extra number of bits given!\n\n");
							usage(); exit(-1);
						} j+= 200;
						xtrapbits = atoi(argv[++argn]);
						break;
					case 'v':
						verbose_flag = true;
						break;
					default: 
						printf("Unknown argument, -%c\n", argv[argn][j]);
						usage();
						exit(-1);
				}
			}
		} else {
			printf("Unrecognized argument, %s\n", argv[argn]);
			usage();
			exit(-1);
		}
	}

	if (real_fft) {
		printf("The real FFT option is not implemented yet, but still on\nmy to do list.  Please try again later.\n");
		exit(0);
	} if (single_clock) {
		printf("The single clock FFT option is not implemented yet, but still on\nmy to do list.  Please try again later.\n");
		exit(0);
	} if (!bitreverse) {
		printf("WARNING: While I can skip the bit reverse stage, the code to do\n");
		printf("an inverse FFT on a bit--reversed input has not yet been\n");
		printf("built.\n");
	}

	if ((lgsize < 0)&&(fftsize > 1)) {
		for(lgsize=1; (1<<lgsize) < fftsize; lgsize++)
			;
	}

	if ((fftsize <= 0)||(nbitsin < 1)||(nbitsin>48)) {
		printf("INVALID PARAMETERS!!!!\n");
		exit(-1);
	}


	if (nextlg(fftsize) != fftsize) {
		fprintf(stderr, "ERR: FFTSize (%d) *must* be a power of two\n",
				fftsize);
		exit(-1);
	} else if (fftsize < 2) {
		fprintf(stderr, "ERR: Minimum FFTSize is 2, not %d\n",
				fftsize);
		if (fftsize == 1) {
			fprintf(stderr, "You do realize that a 1 point FFT makes very little sense\n");
			fprintf(stderr, "in an FFT operation that handles two samples per clock?\n");
			fprintf(stderr, "If you really need to do an FFT of this size, the output\n");
			fprintf(stderr, "can be connected straight to the input.\n");
		} else {
			fprintf(stderr, "Indeed, a size of %d doesn\'t make much sense to me at all.\n", fftsize);
			fprintf(stderr, "Is such an operation even defined?\n");
		}
		exit(-1);
	}

	// Calculate how many output bits we'll have, and what the log
	// based two size of our FFT is.
	{
		int	tmp_size = fftsize;

		// The first stage always accumulates one bit, regardless
		// of whether you need to or not.
		nbitsout = nbitsin + 1;
		tmp_size >>= 1;

		while(tmp_size > 4) {
			nbitsout += 1;
			tmp_size >>= 2;
		}

		if (tmp_size > 1)
			nbitsout ++;

		if (fftsize <= 2)
			bitreverse = false;
	} if ((maxbitsout > 0)&&(nbitsout > maxbitsout))
		nbitsout = maxbitsout;

	// Figure out how many multiply stages to use, and how many to skip
	{
		int	lgv = lgval(fftsize);

		nonmpy = lgv - nummpy;
		if (nonmpy < 2)	nonmpy = 2;
		nummpy = lgv - nonmpy;
	}

	{
		struct stat	sbuf;
		if (lstat(coredir.c_str(), &sbuf)==0) {
			if (!S_ISDIR(sbuf.st_mode)) {
				fprintf(stderr, "\'%s\' already exists, and is not a directory!\n", coredir.c_str());
				fprintf(stderr, "I will stop now, lest I overwrite something you care about.\n");
				fprintf(stderr, "To try again, please remove this file.\n");
				exit(-1);
			}
		} else	
			mkdir(coredir.c_str(), 0755);
		if (access(coredir.c_str(), X_OK|W_OK) != 0) {
			fprintf(stderr, "I have no access to the directory \'%s\'.\n", coredir.c_str());
			exit(-1);
		}
	}

	{
		std::string	fname_string;

		fname_string = coredir;
		fname_string += "/";
		if (inverse) fname_string += "i";
		fname_string += "fftmain.v";

		vmain = fopen(fname_string.c_str(), "w");
		if (NULL == vmain) {
			fprintf(stderr, "Could not open \'%s\' for writing\n", fname_string.c_str());
			perror("Err from O/S:");
			exit(-1);
		}
	}

	fprintf(vmain, "/////////////////////////////////////////////////////////////////////////////\n");
	fprintf(vmain, "//\n");
	fprintf(vmain, "// Filename: 	%sfftmain.v\n", (inverse)?"i":"");
	fprintf(vmain, "//\n");
	fprintf(vmain, "// Project:	%s\n", prjname);
	fprintf(vmain, "//\n");
	fprintf(vmain, "// Purpose:	This is the main module in the Doubletime FPGA FFT project.\n");
	fprintf(vmain, "//		As such, all other modules are subordinate to this one.\n");
	fprintf(vmain, "//		(I have been reading too much legalese this week ...)\n");
	fprintf(vmain, "//		This module accomplish a fixed size Complex FFT on %d data\n", fftsize);
	fprintf(vmain, "//		points.  The FFT is fully pipelined, and accepts as inputs\n");
	fprintf(vmain, "//		two complex two\'s complement samples per clock.\n");
	fprintf(vmain, "//\n");
	fprintf(vmain, "// Parameters:\n");
	fprintf(vmain, "//	i_clk\tThe clock.  All operations are synchronous with this clock.\n");
	fprintf(vmain, "//\ti_rst\tSynchronous reset, active high.  Setting this line will\n");
	fprintf(vmain, "//\t\t\tforce the reset of all of the internals to this routine.\n");
	fprintf(vmain, "//\t\t\tFurther, following a reset, the o_sync line will go\n");
	fprintf(vmain, "//\t\t\thigh the same time the first output sample is valid.\n");
	fprintf(vmain, "//	i_ce\tA clock enable line.  If this line is set, this module\n");
	fprintf(vmain, "//\t\t\twill accept two complex values as inputs, and produce\n");
	fprintf(vmain, "//\t\t\ttwo (possibly empty) complex values as outputs.\n");
	fprintf(vmain, "//\t\ti_left\tThe first of two complex input samples.  This value\n");
	fprintf(vmain, "//\t\t\tis split into two two\'s complement numbers, of \n");
	fprintf(vmain, "//\t\t\t%d bits each, with the real portion in the high\n", nbitsin);
	fprintf(vmain, "//\t\t\torder bits, and the imaginary portion taking the\n");
	fprintf(vmain, "//\t\t\tbottom %d bits.\n", nbitsin);
	fprintf(vmain, "//\t\ti_right\tThis is the same thing as i_left, only this is the\n");
	fprintf(vmain, "//\t\t\tsecond of two such samples.  Hence, i_left would\n");
	fprintf(vmain, "//\t\t\tcontain input sample zero, i_right would contain\n");
	fprintf(vmain, "//\t\t\tsample one.  On the next clock i_left would contain\n");
	fprintf(vmain, "//\t\t\tinput sample two, i_right number three and so forth.\n");
	fprintf(vmain, "//\t\to_left\tThe first of two output samples, of the same\n");
	fprintf(vmain, "//\t\t\tformat as i_left, only having %d bits for each of\n", nbitsout);
	fprintf(vmain, "//\t\t\tthe real and imaginary components, leading to %d\n", nbitsout*2);
	fprintf(vmain, "//\t\t\tbits total.\n");
	fprintf(vmain, "//\t\to_right\tThe second of two output samples produced each clock.\n");
	fprintf(vmain, "//\t\t\tThis has the same format as o_left.\n");
	fprintf(vmain, "//\t\to_sync\tA one bit output indicating the first valid sample\n");
	fprintf(vmain, "//\t\t\tproduced by this FFT following a reset.  Ever after,\n");
	fprintf(vmain, "//\t\t\tthis will indicate the first sample of an FFT frame.\n");
	fprintf(vmain, "//\n");
	fprintf(vmain, "// Arguments:\tThis file was computer generated using the\n");
	fprintf(vmain, "//\t\tfollowing command line:\n");
	fprintf(vmain, "//\n");
	fprintf(vmain, "//\t\t%% %s\n", cmdline.c_str());
	fprintf(vmain, "//\n");
	fprintf(vmain, "%s", creator);
	fprintf(vmain, "//\n");
	fprintf(vmain, "%s", cpyleft);


	fprintf(vmain, "//\n");
	fprintf(vmain, "//\n");
	fprintf(vmain, "module %sfftmain(i_clk, i_rst, i_ce,\n", (inverse)?"i":"");
	fprintf(vmain, "\t\ti_left, i_right,\n");
	fprintf(vmain, "\t\to_left, o_right, o_sync%s);\n",
			(dbg)?", o_dbg":"");
	fprintf(vmain, "\tparameter\tIWIDTH=%d, OWIDTH=%d, LGWIDTH=%d;\n", nbitsin, nbitsout, lgsize);
	assert(lgsize > 0);
	fprintf(vmain, "\tinput\t\ti_clk, i_rst, i_ce;\n");
	fprintf(vmain, "\tinput\t\t[(2*IWIDTH-1):0]\ti_left, i_right;\n");
	fprintf(vmain, "\toutput\treg\t[(2*OWIDTH-1):0]\to_left, o_right;\n");
	fprintf(vmain, "\toutput\treg\t\t\to_sync;\n");
	if (dbg)
		fprintf(vmain, "\toutput\twire\t[33:0]\t\to_dbg;\n");
	fprintf(vmain, "\n\n");

	fprintf(vmain, "\t// Outputs of the FFT, ready for bit reversal.\n");
	fprintf(vmain, "\twire\t[(2*OWIDTH-1):0]\tbr_left, br_right;\n"); 
	fprintf(vmain, "\n\n");

	int	tmp_size = fftsize, lgtmp = lgsize;
	if (fftsize == 2) {
		if (bitreverse) {
			fprintf(vmain, "\treg\tbr_start;\n");
			fprintf(vmain, "\tinitial br_start = 1\'b0;\n");
			fprintf(vmain, "\talways @(posedge i_clk)\n");
			fprintf(vmain, "\t\tif (i_rst)\n");
			fprintf(vmain, "\t\t\tbr_start <= 1\'b0;\n");
			fprintf(vmain, "\t\telse if (i_ce)\n");
			fprintf(vmain, "\t\t\tbr_start <= 1\'b1;\n");
		}
		fprintf(vmain, "\n\n");
		fprintf(vmain, "\tdblstage\t#(IWIDTH)\tstage_2(i_clk, i_rst, i_ce,\n");
		fprintf(vmain, "\t\t\t(~i_rst), i_left, i_right, br_left, br_right);\n");
		fprintf(vmain, "\n\n");
	} else {
		int	nbits = nbitsin, dropbit=0;
		int	obits = nbits+1+xtrapbits;

		if ((maxbitsout > 0)&&(obits > maxbitsout))
			obits = maxbitsout;

		// Always do a first stage
		fprintf(vmain, "\n\n");
		fprintf(vmain, "\twire\t\tw_s%d, w_os%d;\n", fftsize, fftsize);
		fprintf(vmain, "\twire\t[%d:0]\tw_e%d, w_o%d;\n", 2*(obits+xtrapbits)-1, fftsize, fftsize);
		fprintf(vmain, "\t%sfftstage_e%d%s\t#(IWIDTH,IWIDTH+%d,%d,%d,%d,%d,0)\tstage_e%d(i_clk, i_rst, i_ce,\n",
			(inverse)?"i":"", fftsize,
				((dbg)&&(dbgstage == fftsize))?"_dbg":"",
			xtracbits, obits+xtrapbits,
			lgsize, lgtmp-2, lgdelay(nbits,xtracbits),
			fftsize);
		fprintf(vmain, "\t\t\t(~i_rst), i_left, w_e%d, w_s%d%s);\n", fftsize, fftsize, ((dbg)&&(dbgstage == fftsize))?", o_dbg":"");
		fprintf(vmain, "\t%sfftstage_o%d\t#(IWIDTH,IWIDTH+%d,%d,%d,%d,%d,0)\tstage_o%d(i_clk, i_rst, i_ce,\n",
			(inverse)?"i":"", fftsize,
			xtracbits, obits+xtrapbits,
			lgsize, lgtmp-2, lgdelay(nbits,xtracbits),
			fftsize);
		fprintf(vmain, "\t\t\t(~i_rst), i_right, w_o%d, w_os%d);\n", fftsize, fftsize);
		fprintf(vmain, "\n\n");

		{
			std::string	fname;
			char	numstr[12];
			bool	mpystage;

			// Last two stages are always non-multiply stages
			// since the multiplies can be done by adds
			mpystage = ((lgtmp-2) <= nummpy);

			fname = coredir + "/";
			if (inverse) fname += "i";
			fname += "fftstage_e";
			sprintf(numstr, "%d", fftsize);
			fname += numstr;
			if ((dbg)&&(dbgstage == fftsize))
				fname += "_dbg";
			fname += ".v";
			build_stage(fname.c_str(), coredir.c_str(), fftsize/2, 0, nbits, inverse, xtracbits, mpystage, (dbg)&&(dbgstage == fftsize));	// Even stage

			fname = coredir + "/";
			if (inverse) fname += "i";
			fname += "fftstage_o";
			sprintf(numstr, "%d", fftsize);
			fname += numstr;
			fname += ".v";
			build_stage(fname.c_str(), coredir.c_str(), fftsize/2, 1, nbits, inverse, xtracbits, mpystage, false);	// Odd  stage
		}

		nbits = obits;	// New number of input bits
		tmp_size >>= 1; lgtmp--;
		dropbit = 0;
		fprintf(vmain, "\n\n");
		while(tmp_size >= 8) {
			obits = nbits+((dropbit)?0:1);

			if ((maxbitsout > 0)&&(obits > maxbitsout))
				obits = maxbitsout;

			fprintf(vmain, "\twire\t\tw_s%d, w_os%d;\n", tmp_size, tmp_size);
			fprintf(vmain, "\twire\t[%d:0]\tw_e%d, w_o%d;\n", 2*(obits+xtrapbits)-1, tmp_size, tmp_size);
			fprintf(vmain, "\t%sfftstage_e%d%s\t#(%d,%d,%d,%d,%d,%d,%d)\tstage_e%d(i_clk, i_rst, i_ce,\n",
				(inverse)?"i":"", tmp_size,
				((dbg)&&(dbgstage == tmp_size))?"_dbg":"",
				nbits+xtrapbits, nbits+xtracbits+xtrapbits, obits+xtrapbits,
				lgsize, lgtmp-2, lgdelay(nbits+xtrapbits,xtracbits), (dropbit)?0:0,
				tmp_size);
			fprintf(vmain, "\t\t\t\t\t\tw_s%d, w_e%d, w_e%d, w_s%d%s);\n", tmp_size<<1, tmp_size<<1, tmp_size, tmp_size, ((dbg)&&(dbgstage == tmp_size))?", o_dbg":"");
			fprintf(vmain, "\t%sfftstage_o%d\t#(%d,%d,%d,%d,%d,%d,%d)\tstage_o%d(i_clk, i_rst, i_ce,\n",
				(inverse)?"i":"", tmp_size,
				nbits+xtrapbits, nbits+xtracbits+xtrapbits, obits+xtrapbits,
				lgsize, lgtmp-2, lgdelay(nbits+xtrapbits,xtracbits), (dropbit)?0:0,
				tmp_size);
			fprintf(vmain, "\t\t\t\t\t\tw_s%d, w_o%d, w_o%d, w_os%d);\n", tmp_size<<1, tmp_size<<1, tmp_size, tmp_size);
			fprintf(vmain, "\n\n");

			{
				std::string	fname;
				char		numstr[12];
				bool		mpystage;

				mpystage = ((lgtmp-2) <= nummpy);

				fname = coredir + "/";
				if (inverse) fname += "i";
				fname += "fftstage_e";
				sprintf(numstr, "%d", tmp_size);
				fname += numstr;
				if ((dbg)&&(dbgstage == tmp_size))
					fname += "_dbg";
				fname += ".v";
				build_stage(fname.c_str(), coredir.c_str(), tmp_size/2, 0,
					nbits+xtrapbits, inverse, xtracbits,
					mpystage, ((dbg)&&(dbgstage == tmp_size)));	// Even stage

				fname = coredir + "/";
				if (inverse) fname += "i";
				fname += "fftstage_o";
				sprintf(numstr, "%d", tmp_size);
				fname += numstr;
				fname += ".v";
				build_stage(fname.c_str(), coredir.c_str(), tmp_size/2, 1,
					nbits+xtrapbits, inverse, xtracbits,
					mpystage, false);	// Odd  stage
			}


			dropbit ^= 1;
			nbits = obits;
			tmp_size >>= 1; lgtmp--;
		}

		if (tmp_size == 4) {
			obits = nbits+((dropbit)?0:1);

			if ((maxbitsout > 0)&&(obits > maxbitsout))
				obits = maxbitsout;

			fprintf(vmain, "\twire\t\tw_s4, w_os4;\n");
			fprintf(vmain, "\twire\t[%d:0]\tw_e4, w_o4;\n", 2*(obits+xtrapbits)-1);
			fprintf(vmain, "\tqtrstage%s\t#(%d,%d,%d,0,%d,%d)\tstage_e4(i_clk, i_rst, i_ce,\n",
				((dbg)&&(dbgstage==4))?"_dbg":"",
				nbits+xtrapbits, obits+xtrapbits, lgsize,
				(inverse)?1:0, (dropbit)?0:0);
			fprintf(vmain, "\t\t\t\t\t\tw_s8, w_e8, w_e4, w_s4%s);\n",
				((dbg)&&(dbgstage==4))?", o_dbg":"");
			fprintf(vmain, "\tqtrstage\t#(%d,%d,%d,1,%d,%d)\tstage_o4(i_clk, i_rst, i_ce,\n",
				nbits+xtrapbits, obits+xtrapbits, lgsize, (inverse)?1:0, (dropbit)?0:0);
			fprintf(vmain, "\t\t\t\t\t\tw_s8, w_o8, w_o4, w_os4);\n");
			dropbit ^= 1;
			nbits = obits;
			tmp_size >>= 1; lgtmp--;
		}

		{
			obits = nbits+((dropbit)?0:1);
			if (obits > nbitsout)
				obits = nbitsout;
			if ((maxbitsout>0)&&(obits > maxbitsout))
				obits = maxbitsout;
			fprintf(vmain, "\twire\t\tw_s2;\n");
			fprintf(vmain, "\twire\t[%d:0]\tw_e2, w_o2;\n", 2*obits-1);
			fprintf(vmain, "\tdblstage\t#(%d,%d,%d)\tstage_2(i_clk, i_rst, i_ce,\n", nbits+xtrapbits, obits,(dropbit)?0:1);
			fprintf(vmain, "\t\t\t\t\tw_s4, w_e4, w_o4, w_e2, w_o2, w_s2);\n");

			fprintf(vmain, "\n\n");
			nbits = obits;
		}

		fprintf(vmain, "\t// Prepare for a (potential) bit-reverse stage.\n");
		fprintf(vmain, "\tassign\tbr_left  = w_e2;\n");
		fprintf(vmain, "\tassign\tbr_right = w_o2;\n");
		fprintf(vmain, "\n");
		if (bitreverse) {
			fprintf(vmain, "\twire\tbr_start;\n");
			fprintf(vmain, "\treg\tr_br_started;\n");
			fprintf(vmain, "\tinitial\tr_br_started = 1\'b0;\n");
			fprintf(vmain, "\talways @(posedge i_clk)\n");
			fprintf(vmain, "\t\tif (i_rst)\n");
			fprintf(vmain, "\t\t\tr_br_started <= 1\'b0;\n");
			fprintf(vmain, "\t\telse if (i_ce)\n");
			fprintf(vmain, "\t\t\tr_br_started <= r_br_started || w_s2;\n");
			fprintf(vmain, "\tassign\tbr_start = r_br_started || w_s2;\n");
		}
	}

	fprintf(vmain, "\n");
	fprintf(vmain, "\t// Now for the bit-reversal stage.\n");
	fprintf(vmain, "\twire\tbr_sync;\n");
	fprintf(vmain, "\twire\t[(2*OWIDTH-1):0]\tbr_o_left, br_o_right;\n");
	if (bitreverse) {
		fprintf(vmain, "\tdblreverse\t#(%d,%d)\trevstage(i_clk, i_rst,\n", lgsize, nbitsout);
		fprintf(vmain, "\t\t\t(i_ce & br_start), br_left, br_right,\n");
		fprintf(vmain, "\t\t\tbr_o_left, br_o_right, br_sync);\n");
	} else {
		fprintf(vmain, "\tassign\tbr_o_left  = br_left;\n");
		fprintf(vmain, "\tassign\tbr_o_right = br_right;\n");
		fprintf(vmain, "\tassign\tbr_sync    = w_s2;\n");
	}

	fprintf(vmain, "\n\n");
	fprintf(vmain, "\t// Last clock: Register our outputs, we\'re done.\n");
	fprintf(vmain, "\tinitial\to_sync  = 1\'b0;\n");
	fprintf(vmain, "\talways @(posedge i_clk)\n");
	fprintf(vmain, "\t\tif (i_rst)\n");
	fprintf(vmain, "\t\t\to_sync  <= 1\'b0;\n");
	fprintf(vmain, "\t\telse if (i_ce)\n");
	fprintf(vmain, "\t\t\to_sync  <= br_sync;\n");
	fprintf(vmain, "\n");
	fprintf(vmain, "\talways @(posedge i_clk)\n");
	fprintf(vmain, "\t\tif (i_ce)\n");
	fprintf(vmain, "\t\tbegin\n");
	fprintf(vmain, "\t\t\to_left  <= br_o_left;\n");
	fprintf(vmain, "\t\t\to_right <= br_o_right;\n");
	fprintf(vmain, "\t\tend\n");
	fprintf(vmain, "\n\n");
	fprintf(vmain, "endmodule\n");
	fclose(vmain);

	{
		std::string	fname;

		fname = coredir + "/butterfly.v";
		build_butterfly(fname.c_str(), xtracbits, rounding);

		if (nummpy > 0) {
			fname = coredir + "/hwbfly.v";
			build_hwbfly(fname.c_str(), xtracbits, rounding);
		}

		fname = coredir + "/shiftaddmpy.v";
		build_multiply(fname.c_str());

		if ((dbg)&&(dbgstage == 4)) {
			fname = coredir + "/qtrstage_dbg.v";
			build_quarters(fname.c_str(), rounding, true);
		}
		fname = coredir + "/qtrstage.v";
		build_quarters(fname.c_str(), rounding, false);

		if ((dbg)&&(dbgstage == 2))
			fname = coredir + "/dblstage_dbg.v";
		else
			fname = coredir + "/dblstage.v";
		build_dblstage(fname.c_str(), rounding, (dbg)&&(dbgstage==2));

		if (bitreverse) {
			fname = coredir + "/dblreverse.v";
			build_dblreverse(fname.c_str());
		}

		const	char	*rnd_string = "";
		switch(rounding) {
			case RND_TRUNCATE:	rnd_string = "/truncate.v"; break;
			case RND_FROMZERO:	rnd_string = "/roundfromzero.v"; break;
			case RND_HALFUP:	rnd_string = "/roundhalfup.v"; break;
			default:
				rnd_string = "/convround.v"; break;
		} fname = coredir + rnd_string;
		switch(rounding) {
			case RND_TRUNCATE: build_truncator(fname.c_str()); break;
			case RND_FROMZERO: build_roundfromzero(fname.c_str()); break;
			case RND_HALFUP: build_roundhalfup(fname.c_str()); break;
			default:
				build_convround(fname.c_str()); break;
		}

	}
}


