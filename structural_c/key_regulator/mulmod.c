//Nama file : mulmod.c
//Deskripsi : blok multiplier modulo (2^16 + 1)
//Author   : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
DEF_LOFIG ("mulmod");
LOCON ("in1[15:0]", IN, "in1[15:0]");
LOCON ("in2[15:0]", IN, "in2[15:0]");
LOCON ("en", IN, "en");
LOCON ("rst", IN, "rst");
LOCON ("cke", IN, "cke");
LOCON ("mulout[15:0]", OUT, "mulout[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("comparator", "comparator1", "in1[15:0]", "kout1[16:0]", "vdd", "vss", 0);
LOINS ("comparator", "comparator2", "in2[15:0]", "kout2[16:0]", "vdd", "vss", 0);
LOINS ("multiplier17", "mul17", "kout1[16:0]", "kout2[16:0]", "has[33:0]", "vdd", "vss", 0);
LOINS ("comparator2", "comparator3", "has[15:0]", "has[31:16]", "kout3[15:0]", "vdd", "vss", 0);
LOINS ("fullsubstractor16", "fullsubstractor1", "has[15:0]", "has[31:16]", "diff[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg1", "kout3[15:0]", "en", "rst", "cke", "b1[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg2", "diff[15:0]", "en", "rst", "cke", "b2[15:0]", "vdd", "vss", 0);
LOINS ("fulladder16", "fulladder1", "b1[15:0]", "b2[15:0]", "mulout[15:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}
